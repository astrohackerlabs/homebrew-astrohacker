class Quikopen < Formula
  desc "SVG viewer for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/quikopen"
  url "https://github.com/astrohackerlabs/quikopen/releases/download/v0.1.0/quikopen-0.1.0-aarch64-apple-darwin.tar.gz"
  version "0.1.0"
  sha256 "51e8afe9984f885a14e593024177e061047d812c06df4f9bb53e4ce66bd89757"
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
