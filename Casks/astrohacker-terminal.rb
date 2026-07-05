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

  uninstall quit:   "com.astrohacker.terminal",
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
    "~/.config/termsurf",
    "~/.local/share/astrohacker",
    "~/.local/share/termsurf",
    "~/.local/state/astrohacker",
    "~/.local/state/termsurf",
    "~/Library/Application Support/com.astrohacker.terminal",
    "~/Library/Application Support/com.astrohacker.terminal.debug",
    "~/Library/Application Support/com.mitchellh.ghostty",
    "~/Library/Application Support/com.termsurf",
    "~/Library/Application Support/com.termsurf.debug",
    "~/Library/Application Support/com.termsurf.ghostboard",
    "~/Library/Application Support/com.termsurf.ghostboard.debug",
    "~/Library/Caches/com.astrohacker.terminal",
    "~/Library/Caches/com.astrohacker.terminal.debug",
    "~/Library/Caches/com.mitchellh.ghostty",
    "~/Library/Caches/com.mitchellh.ghostty.debug",
    "~/Library/Caches/com.termsurf",
    "~/Library/Caches/com.termsurf.debug",
    "~/Library/Caches/com.termsurf.ghostboard",
    "~/Library/Caches/com.termsurf.ghostboard.debug",
    "~/Library/Caches/termsurf",
    "~/Library/HTTPStorages/com.astrohacker.terminal",
    "~/Library/HTTPStorages/com.astrohacker.terminal.debug",
    "~/Library/HTTPStorages/com.mitchellh.ghostty",
    "~/Library/HTTPStorages/com.mitchellh.ghostty.debug",
    "~/Library/HTTPStorages/com.termsurf",
    "~/Library/HTTPStorages/com.termsurf.debug",
    "~/Library/HTTPStorages/com.termsurf.ghostboard",
    "~/Library/HTTPStorages/com.termsurf.ghostboard.debug",
    "~/Library/Preferences/com.astrohacker.terminal.debug.plist",
    "~/Library/Preferences/com.astrohacker.terminal.plist",
    "~/Library/Preferences/com.mitchellh.ghostty.debug.plist",
    "~/Library/Preferences/com.mitchellh.ghostty.plist",
    "~/Library/Preferences/com.termsurf.debug.plist",
    "~/Library/Preferences/com.termsurf.ghostboard.debug.plist",
    "~/Library/Preferences/com.termsurf.ghostboard.plist",
    "~/Library/Preferences/com.termsurf.plist",
    "~/Library/Saved Application State/com.astrohacker.terminal.debug.savedState",
    "~/Library/Saved Application State/com.astrohacker.terminal.savedState",
    "~/Library/Saved Application State/com.mitchellh.ghostty.debug.savedState",
    "~/Library/Saved Application State/com.mitchellh.ghostty.savedState",
    "~/Library/Saved Application State/com.termsurf.debug.savedState",
    "~/Library/Saved Application State/com.termsurf.ghostboard.debug.savedState",
    "~/Library/Saved Application State/com.termsurf.ghostboard.savedState",
    "~/Library/Saved Application State/com.termsurf.savedState",
    "~/Library/WebKit/com.astrohacker.terminal",
    "~/Library/WebKit/com.astrohacker.terminal.debug",
    "~/Library/WebKit/com.mitchellh.ghostty",
    "~/Library/WebKit/com.mitchellh.ghostty.debug",
    "~/Library/WebKit/com.termsurf",
    "~/Library/WebKit/com.termsurf.debug",
    "~/Library/WebKit/com.termsurf.ghostboard",
    "~/Library/WebKit/com.termsurf.ghostboard.debug",
  ]
end
