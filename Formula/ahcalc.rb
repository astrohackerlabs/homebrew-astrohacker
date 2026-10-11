class Ahcalc < Formula
  desc "Scientific calculator for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/ahcalc"
  url "https://github.com/astrohackerlabs/ahcalc/releases/download/v0.4.3/ahcalc-0.4.3-aarch64-apple-darwin.tar.gz"
  version "0.4.3"
  sha256 "e3234466103c727e2166ba302985412c9e047120d3983df3f25644a72f47ac2d"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    libexec.install "dist", "build", "public", "package.json", "LICENSE", "NOTICE", "third_party"
    bin.install_symlink libexec/"dist/ahcalc"
  end

  def caveats
    <<~EOS
      The calculator requires Astrohacker TermSurf, installed separately.
      Run ahcalc inside an Astrohacker TermSurf pane.
      No Bun, Node or Playwright installation is needed to use this package.
    EOS
  end

  test do
    assert_equal "Astrohacker Calculator #{version}", shell_output("#{bin}/ahcalc --version").strip
  end
end
