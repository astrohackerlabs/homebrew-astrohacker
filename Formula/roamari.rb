class Roamari < Formula
  desc "Terminal browser client for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/roamari"
  url "https://github.com/astrohackerlabs/roamari/releases/download/v0.1.1/roamari-0.1.1-aarch64-apple-darwin.tar.gz"
  version "0.1.1"
  sha256 "dfada32ac16ea759279115601ec83a509e73974300d79a4b45deb086166e08c7"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :tahoe

  def install
    bin.install "roamari"
  end

  def caveats
    <<~EOS
      Browsing requires Astrohacker TermSurf, installed separately.
      Run roamari inside an Astrohacker TermSurf pane.
      The Chromium engine remains ah-chromiumd from TermSurf.
    EOS
  end

  test do
    assert_equal "Roamari #{version}", shell_output("#{bin}/roamari --version").strip
  end
end
