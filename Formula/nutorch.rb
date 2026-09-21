class Nutorch < Formula
  desc "Nushell-based shell with built-in GPU tensors and neural networks"
  homepage "https://github.com/astrohackerlabs/nutorch"
  url "https://github.com/astrohackerlabs/nutorch/releases/download/v2.0.9/nutorch-2.0.9-arm64-tahoe.tar.gz"
  version "2.0.9"
  sha256 "bb9edcac7137f14c57ec8223485e9eae97c78e227444235b635aa79451dea859"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "bin/nutorch"
    libexec.install "libexec/libtorch"
    (pkgshare/"legal").install Dir["share/nutorch/legal/*"]
  end

  test do
    assert_equal "nutorch #{version}\n", shell_output("#{bin}/nutorch --version")
    assert_equal "42\n", shell_output("#{bin}/nutorch --no-config-file -c '21 * 2'")
  end
end
