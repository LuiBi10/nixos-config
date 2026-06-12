{ pkgs, pythonWithPackages }:

pkgs.mkShell {
  buildInputs = [
    pythonWithPackages
    pkgs.gcc
    pkgs.nodejs # necesario para algunas extensiones de Jupyter
    pkgs.zeromq # ✅ librería para pyzmq
    pkgs.stdenv.cc.cc.lib # ✅ libstdc++ para C++
    pkgs.jupyter
    pkgs.jupyterlab
  ];

  shellHook = ''
    echo "🐍 Activando Python env $(python --version)"

    # Crear venv si no existe
    if [ ! -d .venv ]; then
      echo "📦 Creando virtualenv local..."
      python -m venv .venv --system-site-packages
    fi

    source .venv/bin/activate

    # Variables de entorno desde .env (opcional)
    if [ -f .env ]; then
      echo "🔐 Cargando variables de entorno desde .env"
      export $(grep -v '^#' .env | xargs)
    fi

    # Instalar extensiones y librerías extra vía pip
    if [ ! -f .venv/.installed ]; then
      echo "📦 Instalando paquetes extra vía pip..."
      pip install --upgrade pip wheel setuptools

      # 📊 librerías de ciencia de datos
      pip install pandas seaborn matplotlib scikit-learn jupyter ipykernel

      # 🎨 JupyterLab + extensiones
      pip install \
        catppuccin-jupyterlab \
        notebook-intelligence \
        jupyterlab-lsp \
        jupyterlab-git \
        jupyter-ai[all]

      touch .venv/.installed
    fi

    # Registrar kernel en Jupyter
    if ! jupyter kernelspec list | grep -q "nix-python"; then
      echo "📝 Registrando kernel Python (Nix)..."
      python -m ipykernel install --user --name=nix-python --display-name "Python (Nix)"
    fi

    # 🔑 Fix: librerías en runtime
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zeromq}/lib:$LD_LIBRARY_PATH"

    alias jl="jupyter lab"
    echo "✅ Usa 'jl' para lanzar JupyterLab con todas las extensiones"
  '';
}
