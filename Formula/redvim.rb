class Redvim < Formula
  desc "Astrohacker modal editor with built-in Nushell highlighting"
  homepage "https://github.com/astrohackerlabs/redvim"
  url "https://github.com/astrohackerlabs/redvim/releases/download/v0.7.0/redvim-0.7.0-aarch64-apple-darwin.tar.gz"
  version "0.7.0"
  sha256 "f1daea624eef0e30f7f599c1a7be8e496e8c3d4d09a9b5521dd06b38c487c76d"
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
    output = shell_output("#{bin}/redvim --self-check")
    assert_match "language nu: bundled highlighting ok", output
    assert_match "redvim self-check ok", output
  end
end
