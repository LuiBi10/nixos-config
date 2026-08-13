{ pkgs, pythonWithPackages }:

pkgs.mkShell {
  buildInputs = [
    pythonWithPackages
    pkgs.gcc
    pkgs.nodejs # Required for certain JupyterLab extensions
    pkgs.zeromq # Native library for pyzmq dependency
    pkgs.stdenv.cc.cc.lib # Provides libstdc++.so.6
    pkgs.pkg-config # Helps pip compile native extensions
  ];

  shellHook = ''
    echo "🐍 Activating Python env $(python --version)"

    # Create an isolated venv without inheriting system packages to avoid path contamination
    if [ ! -d .venv ]; then
      echo "📦 Creating isolated local virtualenv..."
      python -m venv .venv
    fi

    source .venv/bin/activate

    # Set binary priority to the local venv so Jupyter loads pip-installed extensions
    export PATH="$PWD/.venv/bin:$PATH"

    # Fix runtime missing libraries (Loaded early to prevent libstdc++.so.6 errors)
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zeromq}/lib:''${LD_LIBRARY_PATH}"

    # Load environment variables from local .env file if it exists
    if [ -f .env ]; then
      echo "🔐 Loading environment variables from .env"
      export $(grep -v '^#' .env | xargs)
    fi

    # Install packages inside the local venv if not already done
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

    # Register the kernel using the venv's local Jupyter instance
    python -m ipykernel install --user --name=nix-python --display-name "Python (Nix)"

    alias jl="jupyter lab"
    echo "✅ Use 'jl' or 'jupyter lab' to launch your workspace with all extensions loaded"
  '';
}
