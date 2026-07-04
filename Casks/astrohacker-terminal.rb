cask "astrohacker-terminal" do
  version "0.1.0"
  sha256 "a04b6e03d319eab8df8da730dee47db7a613244413b509ed88713b6743eac4e4"

  url "https://github.com/astrohackerlabs/astrohacker-terminal/releases/download/v#{version}/astrohacker-terminal-#{version}-aarch64-apple-darwin.tar.gz",
      verified: "github.com/astrohackerlabs/astrohacker-terminal/"
  name "Astrohacker Terminal"
  desc "Terminal with embedded GPU-accelerated browser panes"
  homepage "https://astrohacker.com/"

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Astrohacker Terminal.app"
  binary "web"
  binary "termsurf"
  binary "roamium/roamium", target: "roamium"
  binary "surfari/surfari", target: "surfari"
  binary "girlbat/bin/girlbat", target: "girlbat"
  artifact "roamium", target: "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-roamium"
  artifact "surfari", target: "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-surfari"
  artifact "girlbat", target: "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-girlbat"
  artifact "gtui", target: "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-gtui"

  postflight do
    app_path = "#{appdir}/Astrohacker Terminal.app"
    roamium_dir = "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-roamium"
    surfari_dir = "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-surfari"
    girlbat_dir = "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-girlbat"
    gtui_dir = "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-gtui"
    surfari_runtime_artifacts = [
      "surfari",
      "libtermsurf_webkit.dylib",
      "WebKit.framework",
      "WebCore.framework",
      "JavaScriptCore.framework",
      "WebKitLegacy.framework",
      "WebInspectorUI.framework",
      "WebGPU.framework",
      "libANGLE-shared.dylib",
      "libWebKitSwift.dylib",
      "libwebrtc.dylib",
      "com.apple.WebKit.GPU.xpc",
      "com.apple.WebKit.Model.xpc",
      "com.apple.WebKit.Networking.xpc",
      "com.apple.WebKit.WebContent.CaptivePortal.xpc",
      "com.apple.WebKit.WebContent.Development.xpc",
      "com.apple.WebKit.WebContent.EnhancedSecurity.xpc",
      "com.apple.WebKit.WebContent.xpc",
    ]
    girlbat_executable_artifacts = [
      "bin/girlbat",
      "bin/ImageDecoder",
      "bin/RequestServer",
      "bin/WebContent",
      "bin/WebWorker",
      "bin/Compositor",
    ]

    clear_xattrs = lambda do |path|
      system_command "find", args: [path.to_s, "!", "-type", "l",
                                    "-exec", "xattr", "-c", "{}", "+"]
    end

    clear_xattrs.call(app_path)
    clear_xattrs.call(roamium_dir)
    clear_xattrs.call(gtui_dir)
    clear_xattrs.call(girlbat_dir)
    surfari_runtime_artifacts.each do |artifact|
      clear_xattrs.call("#{surfari_dir}/#{artifact}")
    end
    clear_xattrs.call(staged_path/"web")
    clear_xattrs.call(staged_path/"termsurf")

    system_command "codesign", args: ["--force", "--sign", "-", staged_path/"web"]
    system_command "codesign", args: ["--force", "--sign", "-", staged_path/"termsurf"]
    system_command "codesign", args: ["--force", "--sign", "-", "#{roamium_dir}/roamium"]
    surfari_runtime_artifacts.each do |artifact|
      system_command "codesign", args: ["--force", "--deep", "--sign", "-", "#{surfari_dir}/#{artifact}"]
    end
    Dir["#{girlbat_dir}/lib/*.dylib"].each do |dylib|
      system_command "codesign", args: ["--force", "--sign", "-", dylib]
    end
    girlbat_executable_artifacts.each do |artifact|
      path = "#{girlbat_dir}/#{artifact}"
      next unless File.exist?(path)

      system_command "codesign", args: ["--force", "--deep", "--sign", "-", path]
    end
    system_command "codesign",
                   args: ["--force", "--deep", "--sign", "-",
                          app_path]
  end

  uninstall quit:   "com.termsurf",
            delete: [
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-girlbat",
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-gtui",
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-roamium",
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-surfari",
            ]

  zap trash: [
    "~/.config/termsurf",
    "~/.local/share/termsurf",
    "~/.local/state/termsurf",
  ]
end
