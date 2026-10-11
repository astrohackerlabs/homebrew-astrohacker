class Ahnexus < Formula
  desc "Nexus chat shell for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/ahnexus"
  url "https://github.com/astrohackerlabs/ahnexus/releases/download/v0.4.3/ahnexus-0.4.3-aarch64-apple-darwin.tar.gz"
  version "0.4.3"
  sha256 "cca713066317b2d412b089cca7293e3b6d4a42bd0fa63c02644c219472b7bbeb"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    libexec.install "ahnexus", "ui", "LICENSE", "NOTICE", "third_party"
    bin.install_symlink libexec/"ahnexus"
  end

  def caveats
    <<~EOS
      The chat shell requires Astrohacker TermSurf, installed separately.
      Run ahnexus inside an Astrohacker TermSurf pane.
    EOS
  end

  test do
    assert_equal "Astrohacker Nexus #{version}", shell_output("#{bin}/ahnexus --version").strip
  end
end
