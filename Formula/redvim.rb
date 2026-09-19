class Redvim < Formula
  desc "Astrohacker modal editor with built-in Nushell highlighting"
  homepage "https://github.com/astrohackerlabs/redvim"
  url "https://github.com/astrohackerlabs/redvim/releases/download/v0.7.3/redvim-0.7.3-aarch64-apple-darwin.tar.gz"
  version "0.7.3"
  sha256 "0098fa1e6aebdee28d0426edd50dca2f7bddf1895d4b30dc151b7d903c6a1b14"
  license all_of: ["MIT", "Apache-2.0"]

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
    %w[c cpp python html css ruby zig swift xml make].each do |language|
      assert_match "language #{language}: bundled highlighting ok", output
    end
    assert_match "redvim self-check ok", output
  end
end
