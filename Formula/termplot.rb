class Termplot < Formula
  desc "Interactive Plotly viewer for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/termplot"
  url "https://github.com/astrohackerlabs/termplot/releases/download/v0.3.25/termplot-0.3.25-aarch64-apple-darwin.tar.gz"
  version "0.3.25"
  sha256 "f303f67d1559d04494d9b15a510d70081882c2654afd24befdcdb45b3ec3761e"
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
