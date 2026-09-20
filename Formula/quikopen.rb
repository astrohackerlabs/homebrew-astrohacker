class Quikopen < Formula
  desc "SVG viewer for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/quikopen"
  url "https://github.com/astrohackerlabs/quikopen/releases/download/v0.1.1/quikopen-0.1.1-aarch64-apple-darwin.tar.gz"
  version "0.1.1"
  sha256 "2f1f33a6e3b24c07dc2c854a1896b0ae15e52ca863e9f54c976deed3d37e8948"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    libexec.install "dist", "build", "public", "package.json", "LICENSE", "NOTICE", "third_party"
    bin.install_symlink libexec/"dist/quikopen"
  end

  def caveats
    <<~EOS
      Opening SVGs requires Astrohacker TermSurf, installed separately.
      Run quikopen inside an Astrohacker TermSurf pane.
      No Bun, Node or Playwright installation is needed to use this package.
    EOS
  end

  test do
    assert_equal "Quikopen #{version}", shell_output("#{bin}/quikopen --version").strip
  end
end
