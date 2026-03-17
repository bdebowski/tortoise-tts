FROM nvidia/cuda:12.2.0-base-ubuntu22.04

RUN apt-get update && \
    apt-get install -y --allow-unauthenticated --no-install-recommends \
    wget \
    git \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV HOME="/root"
ENV CONDA_DIR="${HOME}/miniconda"
ENV PATH="$CONDA_DIR/bin":$PATH
ENV CONDA_AUTO_UPDATE_CONDA=false
ENV PIP_DOWNLOAD_CACHE="$HOME/.pip/cache"
ENV TORTOISE_MODELS_DIR="$HOME/tortoise-tts/build/lib/tortoise/models"

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda3.sh \
    && bash /tmp/miniconda3.sh -b -p "${CONDA_DIR}" -f -u \
    && "${CONDA_DIR}/bin/conda" init bash \
    && rm -f /tmp/miniconda3.sh \
    && echo ". '${CONDA_DIR}/etc/profile.d/conda.sh'" >> "${HOME}/.profile"

# --login option used to source bashrc (thus activating conda env) at every RUN statement
SHELL ["/bin/bash", "--login", "-c"]

RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
    && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN conda create --name tortoise python=3.9 numba inflect -y \
    && conda activate tortoise \
    && conda install --yes pytorch==2.2.2 torchvision==0.17.2 torchaudio==2.2.2 pytorch-cuda=12.1 -c pytorch -c nvidia \
    && conda install --yes transformers=4.31.0

RUN conda activate tortoise \
    && conda install -c conda-forge scikit-learn

COPY . /app

RUN cd /app \
    && conda activate tortoise \
    && python setup.py install

ENV TORTOISE_MODELS_DIR="/app/build/lib/tortoise/models"
ENV PYTHONPATH="/app/tortoise"
