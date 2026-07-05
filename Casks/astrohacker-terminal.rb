cask "astrohacker-terminal" do
  version "0.1.4"
  sha256 "37167814ff9a265705f558c3a6615e675aad050a7e0b6e0c25a1faf114481470"

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
  binary "ah-chromiumd/ah-chromiumd", target: "ah-chromiumd"
  binary "ah-webkitd/ah-webkitd", target: "ah-webkitd"
  binary "ah-ladybirdd/bin/ah-ladybirdd", target: "ah-ladybirdd"
  artifact "ah-chromiumd", target: "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-ah-chromiumd"
  artifact "ah-webkitd", target: "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-ah-webkitd"
  artifact "ah-ladybirdd", target: "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-ah-ladybirdd"
  artifact "gtui", target: "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-gtui"

  postflight do
    app_path = "#{appdir}/Astrohacker Terminal.app"
    chromiumd_dir = "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-ah-chromiumd"
    webkitd_dir = "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-ah-webkitd"
    ladybirdd_dir = "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-ah-ladybirdd"
    gtui_dir = "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-gtui"
    surfari_runtime_artifacts = [
      "ah-webkitd",
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
      "bin/ah-ladybirdd",
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
    clear_xattrs.call(chromiumd_dir)
    clear_xattrs.call(gtui_dir)
    clear_xattrs.call(ladybirdd_dir)
    surfari_runtime_artifacts.each do |artifact|
      clear_xattrs.call("#{webkitd_dir}/#{artifact}")
    end
    clear_xattrs.call(staged_path/"web")
    clear_xattrs.call(staged_path/"termsurf")

    system_command "codesign", args: ["--force", "--sign", "-", staged_path/"web"]
    system_command "codesign", args: ["--force", "--sign", "-", staged_path/"termsurf"]
    system_command "codesign", args: ["--force", "--sign", "-", "#{chromiumd_dir}/ah-chromiumd"]
    surfari_runtime_artifacts.each do |artifact|
      system_command "codesign", args: ["--force", "--deep", "--sign", "-", "#{webkitd_dir}/#{artifact}"]
    end
    Dir["#{ladybirdd_dir}/lib/*.dylib"].each do |dylib|
      system_command "codesign", args: ["--force", "--sign", "-", dylib]
    end
    girlbat_executable_artifacts.each do |artifact|
      path = "#{ladybirdd_dir}/#{artifact}"
      next unless File.exist?(path)

      system_command "codesign", args: ["--force", "--deep", "--sign", "-", path]
    end
    system_command "codesign",
                   args: ["--force", "--deep", "--sign", "-",
                          app_path]
  end

  uninstall quit:   "com.termsurf",
            delete: [
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-ah-chromiumd",
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-ah-ladybirdd",
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-ah-webkitd",
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-girlbat",
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-gtui",
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-roamium",
              "#{HOMEBREW_PREFIX}/opt/astrohacker-terminal-surfari",
            ]

  zap trash: [
    "~/.config/astrohacker",
    "~/.local/share/astrohacker",
    "~/.local/state/astrohacker",
    "~/.config/termsurf",
    "~/.local/share/termsurf",
    "~/.local/state/termsurf",
  ]
end
