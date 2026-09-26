class Redvim < Formula
  desc "Astrohacker modal editor with built-in Nushell highlighting"
  homepage "https://github.com/astrohackerlabs/redvim"
  url "https://github.com/astrohackerlabs/redvim/releases/download/v0.7.9/redvim-0.7.9-aarch64-apple-darwin.tar.gz"
  version "0.7.9"
  sha256 "870317ac16ea68202df9ec4d60f38ee7628e7f57d746e333495b711423a986f5"
  license all_of: ["MIT", "Apache-2.0", "W3C-20150513", "BSD-3-Clause"]

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "bin/redvim"
    (share/"redvim").install "share/redvim/legal"
  end

  test do
    assert_equal "redvim #{version}", shell_output("#{bin}/redvim --version").strip
    ENV["XDG_CONFIG_HOME"] = (testpath/"config").to_s
    ENV.delete "REDVIM_RUNTIME"
    ENV.delete "RED_RUNTIME"
    (testpath/"config/redvim/config.toml").write "invalid = ["
    config = testpath/"config/astrohacker/redvim/config.toml"
    config.write "relative_line_numbers = true\n"
    assert_match "config ok", shell_output("#{bin}/redvim --check-config")
    config.unlink
    config.write "invalid = ["
    assert_match config.to_s, shell_output("#{bin}/redvim --check-config 2>&1", 1)
    config.unlink
    output = shell_output("#{bin}/redvim --self-check")
    assert_match "language nu: bundled highlighting ok", output
    %w[c cpp python html css ruby zig swift xml make sql hcl objc proto dockerfile gn wgsl caddyfile applescript typst].each do |language|
      assert_match "language #{language}: bundled highlighting ok", output
    end
    assert_match "redvim self-check ok", output
  end
end
