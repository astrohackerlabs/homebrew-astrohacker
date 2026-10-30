cask "roamari" do
  version "0.1.8"
  sha256 "4c23ea8e3fa7dd4ff0e79ede58fbfbb60dfc0b41fe8e47335387f6b17f458bd5"

  url "https://github.com/astrohackerlabs/roamari/releases/download/v#{version}/roamari-#{version}-aarch64-apple-darwin.tar.gz"
  name "Roamari"
  desc "TermSurf-protocol browser client and Chromium engine"
  homepage "https://github.com/astrohackerlabs/roamari"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  binary "roamari"
  artifact "roamari-chromiumd", target: "#{HOMEBREW_PREFIX}/opt/roamari-chromiumd"

  postflight_steps do
    mkdir_p "{{HOMEBREW_PREFIX}}/var/log/astrohacker"

    # Clear quarantine xattrs so the ad-hoc re-signed binaries will launch.
    # `opt` is not sandbox-writable by default, so steps touching the Chromium
    # helper directory declare it via `writable_paths`.
    run "find",
        args:           ["{{HOMEBREW_PREFIX}}/opt/roamari-chromiumd", "!", "-type", "l",
                         "-exec", "xattr", "-c", "{}", "+"],
        writable_paths: ["{{HOMEBREW_PREFIX}}/opt/roamari-chromiumd"]
    run "find",
        args: ["{{HOMEBREW_PREFIX}}/bin/roamari", "!", "-type", "l",
               "-exec", "xattr", "-c", "{}", "+"]
    run "find",
        args: ["{{staged_path}}/roamari", "!", "-type", "l",
               "-exec", "xattr", "-c", "{}", "+"]

    run "codesign", args: ["--force", "--sign", "-", "{{HOMEBREW_PREFIX}}/bin/roamari"]
    run "codesign", args: ["--force", "--sign", "-", "{{staged_path}}/roamari"]
    run "codesign",
        args:           ["--force", "--sign", "-",
                         "{{HOMEBREW_PREFIX}}/opt/roamari-chromiumd/roamari-chromiumd"],
        writable_paths: ["{{HOMEBREW_PREFIX}}/opt/roamari-chromiumd"]

    # Warm up roamari-chromiumd so the first browser launch is fast. Steps blocks
    # are declarative and evaluated when the cask is loaded, so the skip-env
    # checks, timeout watchdog, and structured event logging from the former
    # Ruby postflight now live in this POSIX-sh wrapper. It always exits 0:
    # warmup problems are logged and reported on stderr, never failing install.
    run "/bin/sh",
        args:           [
          "-c",
          <<~SHELL,
            log="$TERMSURF_ENGINE_STARTUP_TRACE_FILE"
            helper="{{HOMEBREW_PREFIX}}/opt/roamari-chromiumd/roamari-chromiumd"
            wall_ms() { echo $(( $(date +%s) * 1000 )); }

            if [ "${HOMEBREW_ASTROHACKER_TERMINAL_SKIP_POSTFLIGHT_WARMUP:-}" = "1" ] ||
               [ "${ASTROHACKER_TERMINAL_SKIP_POSTFLIGHT_WARMUP:-}" = "1" ] ||
               [ "${HOMEBREW_TERMSURF_SKIP_POSTFLIGHT_WARMUP:-}" = "1" ]; then
              echo "RoamariPostInstallWarmup event=skipped wall_ms=$(wall_ms) reason=skip_env" >> "$log"
              exit 0
            fi

            echo "==> Warming up roamari-chromiumd. First browser launch may be slow without this step."
            start_line="RoamariPostInstallWarmup event=start engine=chromium wall_ms=$(wall_ms)"
            echo "$start_line binary=$helper" >> "$log"

            start_s=$(date +%s)
            "$helper" --browser-name=chromium --termsurf-warmup >> "$log" 2>&1 &
            pid=$!
            ( sleep 180; kill -TERM "$pid" 2>/dev/null; sleep 1; kill -KILL "$pid" 2>/dev/null ) &
            watchdog=$!

            timed_out=false
            if wait "$pid"; then
              status=0
            else
              status=$?
              case "$status" in
                137|143) timed_out=true ;;
              esac
            fi
            kill "$watchdog" 2>/dev/null
            wait "$watchdog" 2>/dev/null

            duration_ms=$(( ($(date +%s) - start_s) * 1000 ))
            success=false
            if [ "$status" -eq 0 ] && [ "$timed_out" = false ]; then
              success=true
            fi

            done_line="RoamariPostInstallWarmup event=done engine=chromium wall_ms=$(wall_ms)"
            done_line="$done_line duration_ms=$duration_ms success=$success"
            done_line="$done_line timed_out=$timed_out exit_status=$status"
            echo "$done_line" >> "$log"

            if [ "$success" != true ]; then
              echo "Warning: roamari-chromiumd install warmup failed or timed out;" >&2
              echo "first browser launch may be slower. See $log." >&2
            fi
            exit 0
          SHELL
        ],
        env:            {
          "TERMSURF_ENGINE_STARTUP_TRACE" => "1",
          "TERMSURF_ENGINE_STARTUP_TRACE_FILE" =>
            "{{HOMEBREW_PREFIX}}/var/log/astrohacker/roamari-postinstall-warmup.log",
        },
        must_succeed:   false,
        print_stdout:   true,
        writable_paths: ["{{HOMEBREW_PREFIX}}/opt/roamari-chromiumd"]
  end

  caveats <<~EOS
    Browsing requires a TermSurf-protocol host. Astrohacker TermSurf is one such host, installed separately.
    Run roamari inside a TermSurf-protocol pane.
    Chromium helper: #{HOMEBREW_PREFIX}/opt/roamari-chromiumd/roamari-chromiumd
    If a previous formula install exists: brew uninstall roamari && brew install --cask roamari
  EOS
end
