{ pkgs, pythonWithPackages }:

pkgs.mkShell {
  buildInputs = [
    pythonWithPackages
    pkgs.gcc
    pkgs.nodejs # Needed by some JupyterLab extensions
    pkgs.zeromq # Native library for pyzmq
    pkgs.stdenv.cc.cc.lib # Provides libstdc++.so.6
    pkgs.pkg-config # Lets pip build native extensions
  ];

  shellHook = ''
    echo "🐍 Activating Python env $(python --version)"

    # Isolated venv (no system site-packages)
    if [ ! -d .venv ]; then
      echo "📦 Creating isolated local virtualenv..."
      python -m venv .venv
    fi

    source .venv/bin/activate

    # Venv binaries first, so Jupyter loads pip-installed extensions
    export PATH="$PWD/.venv/bin:$PATH"

    # Native libraries needed at runtime (libstdc++.so.6, libzmq)
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zeromq}/lib:''${LD_LIBRARY_PATH}"

    # Load .env if present
    if [ -f .env ]; then
      echo "🔐 Loading environment variables from .env"
      export $(grep -v '^#' .env | xargs)
    fi

    # Install pip packages once per venv
    if [ ! -f .venv/.installed ]; then
      echo "📦 Installing JupyterLab and extra packages via pip..."
      pip install --upgrade pip wheel setuptools

      # Data science libraries
      pip install pandas seaborn matplotlib scikit-learn jupyter ipykernel

      # JupyterLab UI and AI extensions
      pip install \
        catppuccin-jupyterlab \
        notebook-intelligence \
        jupyterlab-lsp \
        jupyterlab-git \
        jupyter-ai[all]

      touch .venv/.installed
    fi

    # Register the venv as a Jupyter kernel
    python -m ipykernel install --user --name=nix-python --display-name "Python (Nix)"

    alias jl="jupyter lab"
    echo "✅ Use 'jl' or 'jupyter lab' to launch your workspace with all extensions loaded"
  '';
}
