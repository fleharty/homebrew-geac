class Geac < Formula
  desc "Genomic Evidence Atlas of Cohorts — collect alt-base metrics and explore coverage"
  homepage "https://github.com/fleharty/GEAC"
  version "0.4.5"

  on_macos do
    on_arm do
      url "https://github.com/fleharty/GEAC/releases/download/v#{version}/geac-macos-arm64.tar.gz"
      sha256 "543090bf57a14fe371836658c29800de6e40b9d19d10f093b6a4b6260dc21b72"
    end
  end

  depends_on "htslib"
  depends_on "python@3.12"

  resource "geac-apps" do
    url "https://github.com/fleharty/GEAC/archive/refs/tags/v0.4.5.tar.gz"
    sha256 "7dcdc3dd533ea53f70cd03e6da133cff362c33d7f16ca063adeff084f87b3c22"
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
