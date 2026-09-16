class Termplot < Formula
  desc "Interactive Plotly viewer for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/termplot"
  url "https://github.com/astrohackerlabs/termplot/releases/download/v0.3.26/termplot-0.3.26-aarch64-apple-darwin.tar.gz"
  version "0.3.26"
  sha256 "c870262c65c55b02adba7eebb46d644eff34539787f0c2f55355e86db7e00426"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    libexec.install "dist", "build", "public", "package.json", "LICENSE", "NOTICE", "third_party"
    bin.install_symlink libexec/"dist/termplot"
  end

  def caveats
    <<~EOS
      Plotting requires Astrohacker TermSurf, installed separately.
      Run termplot inside an Astrohacker TermSurf pane.
      No Bun, Node or Playwright installation is needed to use this package.
    EOS
  end

  test do
    assert_equal "termplot #{version}", shell_output("#{bin}/termplot --version").strip
  end
end
