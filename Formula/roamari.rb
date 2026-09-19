class Roamari < Formula
  desc "Terminal browser client for Astrohacker TermSurf"
  homepage "https://github.com/astrohackerlabs/roamari"
  url "https://github.com/astrohackerlabs/roamari/releases/download/v0.1.0/roamari-0.1.0-aarch64-apple-darwin.tar.gz"
  version "0.1.0"
  sha256 "47de4b5468b739ba1a01c1a6a47ea3ff3e04f31434565a8836ba5877e083ff8d"
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
