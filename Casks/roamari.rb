cask "roamari" do
  version "0.1.6"
  sha256 "cf97cdcc006519d1aa632cf8a0a0b4c55a07f003edd0c707bf2a6c4494b5a947"

  url "https://github.com/astrohackerlabs/roamari/releases/download/v#{version}/roamari-#{version}-aarch64-apple-darwin.tar.gz"
  name "Roamari"
  desc "TermSurf-protocol browser client and Chromium engine"
  homepage "https://github.com/astrohackerlabs/roamari"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  binary "roamari"
  artifact "roamari-chromiumd", target: "#{HOMEBREW_PREFIX}/opt/roamari-chromiumd"

  postflight do
    chromiumd_dir = "#{HOMEBREW_PREFIX}/opt/roamari-chromiumd"
    helper = "#{chromiumd_dir}/roamari-chromiumd"
    roamari_bin = "#{HOMEBREW_PREFIX}/bin/roamari"
    warmup_log = "#{HOMEBREW_PREFIX}/var/log/astrohacker/roamari-postinstall-warmup.log"
    system_command "mkdir", args: ["-p", File.dirname(warmup_log)]

    clear_xattrs = lambda do |path|
      system_command "find", args: [path.to_s, "!", "-type", "l",
                                    "-exec", "xattr", "-c", "{}", "+"]
    end
    clear_xattrs.call(chromiumd_dir)
    clear_xattrs.call(roamari_bin)
    clear_xattrs.call(staged_path/"roamari")

    system_command "codesign", args: ["--force", "--sign", "-", roamari_bin]
    system_command "codesign", args: ["--force", "--sign", "-", staged_path/"roamari"]
    system_command "codesign", args: ["--force", "--sign", "-", helper]

    if ENV["HOMEBREW_ASTROHACKER_TERMINAL_SKIP_POSTFLIGHT_WARMUP"] == "1" ||
       ENV["ASTROHACKER_TERMINAL_SKIP_POSTFLIGHT_WARMUP"] == "1" ||
       ENV["HOMEBREW_TERMSURF_SKIP_POSTFLIGHT_WARMUP"] == "1"
      File.open(warmup_log, "a") do |log|
        log.puts("RoamariPostInstallWarmup event=skipped " \
                 "wall_ms=#{(Time.now.to_f * 1000).to_i} " \
                 "reason=skip_env")
      end
    else
      timeout_seconds = 180
      start_mono = Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond)
      start_wall = (Time.now.to_f * 1000).to_i
      ohai "Warming up roamari-chromiumd. First browser launch may be slow without this step."
      File.open(warmup_log, "a") do |log|
        log.puts("RoamariPostInstallWarmup event=start engine=chromium " \
                 "wall_ms=#{start_wall} binary=#{helper}")
      end

      env = {
        "TERMSURF_ENGINE_STARTUP_TRACE"      => "1",
        "TERMSURF_ENGINE_STARTUP_TRACE_FILE" => warmup_log,
      }
      status = nil
      timed_out = false
      pid = nil
      begin
        File.open(warmup_log, "a") do |child_log|
          child_log.sync = true
          pid = Process.spawn(env, helper.to_s, "--browser-name=chromium", "--termsurf-warmup",
                              out: child_log, err: child_log)
        end
        deadline = Time.now + timeout_seconds
        loop do
          waited = Process.waitpid2(pid, Process::WNOHANG)
          if waited
            status = waited[1]
            break
          end
          if Time.now >= deadline
            timed_out = true
            begin
              Process.kill("TERM", pid)
            rescue Errno::ESRCH
              timed_out = true
            end
            sleep 1
            begin
              Process.kill("KILL", pid)
            rescue Errno::ESRCH
              timed_out = true
            end
            begin
              Process.wait(pid)
            rescue Errno::ECHILD
              timed_out = true
            end
            break
          end
          sleep 0.25
        end
      rescue SystemCallError => e
        File.open(warmup_log, "a") do |log|
          log.puts("RoamariPostInstallWarmup event=spawn_error engine=chromium " \
                   "wall_ms=#{(Time.now.to_f * 1000).to_i} error=#{e.class} message=#{e.message.inspect}")
        end
      end

      duration_ms = Process.clock_gettime(Process::CLOCK_MONOTONIC, :millisecond) - start_mono
      success = status&.success? == true && !timed_out
      exit_status = if status
        status.exitstatus
      else
        "unknown"
      end
      File.open(warmup_log, "a") do |log|
        log.puts("RoamariPostInstallWarmup event=done engine=chromium " \
                 "wall_ms=#{(Time.now.to_f * 1000).to_i} " \
                 "duration_ms=#{duration_ms} success=#{success} " \
                 "timed_out=#{timed_out} exit_status=#{exit_status}")
      end
      unless success
        opoo "roamari-chromiumd install warmup failed or timed out; " \
             "first browser launch may be slower. See #{warmup_log}."
      end
    end
  end

  caveats <<~EOS
    Browsing requires a TermSurf-protocol host. Astrohacker TermSurf is one such host, installed separately.
    Run roamari inside a TermSurf-protocol pane.
    Chromium helper: #{HOMEBREW_PREFIX}/opt/roamari-chromiumd/roamari-chromiumd
    If a previous formula install exists: brew uninstall roamari && brew install --cask roamari
  EOS
end
