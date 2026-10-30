cask "termsurf" do
  version "0.4.3"
  sha256 "2314a1efd38f3826fec7ba8ae6e31d87fb5cd1c263c9ec56dd6d3c35e73734ff"

  url "https://github.com/astrohackerlabs/termsurf/releases/download/v#{version}/astrohacker-#{version}-aarch64-apple-darwin.tar.gz"
  name "Astrohacker TermSurf"
  desc "Terminal, shell, and web tools"
  homepage "https://termsurf.com/"

  depends_on arch: :arm64
  depends_on cask: "astrohackerlabs/astrohacker/roamari"
  depends_on formula: "astrohackerlabs/astrohacker/nutorch"
  depends_on macos: :tahoe

  app "Astrohacker TermSurf.app"
  binary "Astrohacker TermSurf.app/Contents/MacOS/termsurf", target: "termsurf"

  postflight_steps do
    run "find",
        args: ["{{appdir}}/Astrohacker TermSurf.app", "!", "-type", "l",
               "-exec", "xattr", "-c", "{}", "+"]
    run "codesign",
        args: ["--force", "--deep", "--sign", "-",
               "{{appdir}}/Astrohacker TermSurf.app"]
    # The former postflight ended with an "Open Astrohacker TermSurf.app" notice.
    # Cask steps blocks cannot emit notices (`warn` is formula-only) and caveats
    # print mid-upgrade, so the notice is dropped.
  end

  uninstall quit: "com.astrohacker.terminal"

  zap trash: [
    "~/.cache/astrohacker/editor",
    "~/.cache/astrohacker/terminal",
    "~/.cache/astrohacker/termsurf",
    "~/.config/astrohacker/editor",
    "~/.config/astrohacker/terminal",
    "~/.config/astrohacker/termsurf",
    "~/.config/termsurf",
    "~/.local/share/astrohacker/editor",
    "~/.local/share/astrohacker/terminal",
    "~/.local/share/astrohacker/termsurf",
    "~/.local/share/termsurf",
    "~/.local/state/astrohacker/terminal",
    "~/.local/state/astrohacker/termsurf",
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
