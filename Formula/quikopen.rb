class Quikopen < Formula
  desc "Image viewer for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/quikopen"
  url "https://github.com/astrohackerlabs/quikopen/releases/download/v0.1.4/quikopen-0.1.4-aarch64-apple-darwin.tar.gz"
  version "0.1.4"
  sha256 "9dd9d254a70abb7587302d22d28ad1343e8cf14306dc0679858b9c1579bc244d"
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
