class Geac < Formula
  desc "Genomic Evidence Atlas of Cohorts — collect alt-base metrics and explore coverage"
  homepage "https://github.com/fleharty/GEAC"
  version "0.4.47"

  on_macos do
    on_arm do
      url "https://github.com/fleharty/GEAC/releases/download/v#{version}/geac-macos-arm64.tar.gz"
      sha256 "a18a4dc297c99e31bd7b4d033add803b18dc8e7d4b6b27a96bd8ead8205fae86"
    end
  end

  depends_on "htslib"
  depends_on "python@3.12"

  resource "geac-apps" do
    url "https://github.com/fleharty/GEAC/archive/refs/tags/v0.4.47.tar.gz"
    sha256 "0756783a87780270ef7add6433b6977383d24a19c06111db071ebbd66926505c"
  end

  def install
    bin.install "geac"

    resource("geac-apps").stage do
      libexec.install Dir["app/*"]
      libexec.install "schema"
    end

    python = Formula["python@3.12"].opt_bin/"python3.12"
    venv = libexec/"venv"
    system python, "-m", "venv", venv
    system venv/"bin/pip", "install", "--upgrade", "pip", "--quiet"
    system venv/"bin/pip", "install", "--quiet",
      "streamlit>=1.35",
      "duckdb>=1.0",
      "altair>=5.3",
      "pandas>=2.0",
      "numpy>=1.26",
      "scipy>=1.13",
      "scikit-learn>=1.5",
      "pytz>=2024.1",
      "google-cloud-storage",
      "google-auth"

    (bin/"geac-cohort").write <<~SH
      #!/bin/bash
      exec "#{libexec}/venv/bin/streamlit" run "#{libexec}/geac_explorer.py" "$@"
    SH
    chmod 0755, bin/"geac-cohort"

    (bin/"geac-coverage-explorer").write <<~SH
      #!/bin/bash
      exec "#{libexec}/venv/bin/streamlit" run "#{libexec}/geac_coverage_explorer.py" "$@"
    SH
    chmod 0755, bin/"geac-coverage-explorer"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/geac --version")
  end
end
