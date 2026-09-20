class Roamari < Formula
  desc "TermSurf-protocol browser client and Chromium engine"
  homepage "https://github.com/astrohackerlabs/roamari"
  url "https://github.com/astrohackerlabs/roamari/releases/download/v0.1.3/roamari-0.1.3-aarch64-apple-darwin.tar.gz"
  version "0.1.3"
  sha256 "b5954f26782def3e1c6045affd43ba067cc08f4e6dd9bd9b197a910f7c761169"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "roamari"
    libexec.install "roamari-chromiumd"
    bin.install_symlink libexec/"roamari-chromiumd/roamari-chromiumd"
  end

  def post_install
    helper = libexec/"roamari-chromiumd/roamari-chromiumd"
    warmup_log = "#{HOMEBREW_PREFIX}/var/log/astrohacker/roamari-postinstall-warmup.log"
    system_command "mkdir", args: ["-p", File.dirname(warmup_log)]
    system_command "codesign", args: ["--force", "--sign", "-", helper]

    if ENV["HOMEBREW_ASTROHACKER_TERMINAL_SKIP_POSTFLIGHT_WARMUP"] == "1" ||
       ENV["ASTROHACKER_TERMINAL_SKIP_POSTFLIGHT_WARMUP"] == "1" ||
       ENV["HOMEBREW_TERMSURF_SKIP_POSTFLIGHT_WARMUP"] == "1"
      File.open(warmup_log, "a") do |log|
        log.puts("RoamariPostInstallWarmup event=skipped " \
                 "wall_ms=#{(Time.now.to_f * 1000).to_i} " \
                 "reason=skip_env")
      end
      return
    end

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

  def caveats
    <<~EOS
      Browsing requires a TermSurf-protocol host. Astrohacker TermSurf is one such host, installed separately.
      Run roamari inside a TermSurf-protocol pane.
    EOS
  end

  test do
    assert_equal "Roamari #{version}", shell_output("#{bin}/roamari --version").strip
    assert_equal "Roamari Chromium Engine #{version}",
                 shell_output("#{bin}/roamari-chromiumd --version").strip
  end
end
