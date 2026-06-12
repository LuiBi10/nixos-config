{ pkgs }:

pkgs.python3.withPackages (ps:
  with ps; [
    pip
    jupyterlab
    ipykernel
    numpy
    pandas
    matplotlib
    scipy
    scikit-learn
    seaborn
    notebook
    jupyter-server
    jupyter-client
    jupyter-core
    traitlets
    tornado
  ])
