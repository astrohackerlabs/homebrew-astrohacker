class Nutorch < Formula
  desc "Nushell-based shell with built-in GPU tensors and neural networks"
  homepage "https://github.com/astrohackerlabs/nutorch"
  url "https://github.com/astrohackerlabs/nutorch/releases/download/v2.0.3/nutorch-2.0.3-arm64-tahoe.tar.gz"
  version "2.0.3"
  sha256 "da7d932378aa91b2506694c95b08c2e0f2a06a112e93f18d9ff6caeed7315b5d"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    odie "This binary requires Apple-silicon macOS Tahoe (26.x)" unless Hardware::CPU.arm? && MacOS.version.to_s.split(".").first == "26"
    bin.install "bin/nutorch"
    libexec.install "libexec/libtorch"
    (pkgshare/"legal").install Dir["share/nutorch/legal/*"]
  end

  test do
    assert_equal "nutorch #{version}\n", shell_output("#{bin}/nutorch --version")
    assert_equal "42\n", shell_output("#{bin}/nutorch --no-config-file -c '21 * 2'")
  end
end
