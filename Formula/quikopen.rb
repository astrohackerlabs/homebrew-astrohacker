class Quikopen < Formula
  desc "Image viewer for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/quikopen"
  url "https://github.com/astrohackerlabs/quikopen/releases/download/v0.1.7/quikopen-0.1.7-aarch64-apple-darwin.tar.gz"
  version "0.1.7"
  sha256 "f8e78fd63687a712a067df19e75c93a22d97981ba047d9474754fa6d01a69507"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    libexec.install "dist", "build", "public", "package.json", "LICENSE", "NOTICE", "third_party"
    bin.install_symlink libexec/"dist/quikopen"
  end

  def caveats
    <<~EOS
      Opening images requires Astrohacker TermSurf, installed separately.
      Run quikopen inside an Astrohacker TermSurf pane.
      No Bun, Node or Playwright installation is needed to use this package.
    EOS
  end

  test do
    assert_equal "QuikOpen #{version}", shell_output("#{bin}/quikopen --version").strip
  end
end
