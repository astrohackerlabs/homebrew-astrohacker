class Nutorch < Formula
  desc "Nushell-based shell with built-in GPU tensors and neural networks"
  homepage "https://github.com/astrohackerlabs/nutorch"
  url "https://github.com/astrohackerlabs/nutorch/releases/download/v2.0.14/nutorch-2.0.14-arm64-tahoe.tar.gz"
  version "2.0.14"
  sha256 "9d73c4d5e179c2effe6c227dbf13f097af9e10d85f7e5f186389b2d68f75e880"
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
