class Nutorch < Formula
  desc "Nushell-based shell with built-in GPU tensors and neural networks"
  homepage "https://github.com/astrohackerlabs/nutorch"
  url "https://github.com/astrohackerlabs/nutorch/releases/download/v2.0.5/nutorch-2.0.5-arm64-tahoe.tar.gz"
  version "2.0.5"
  sha256 "576d9c10aa3b2f81f4ab1dc327024efd809a0bc7efaeaef5f749f28cbbf04928"
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
