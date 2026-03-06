FROM ubuntu:24.04

WORKDIR /tmp

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get install -qq bzip2 ca-certificates curl git vim zsh && \
    rm -rf /var/lib/apt/lists/*

RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i 's/ZSH_THEME="\(.*\)"/ZSH_THEME="candy"/' $HOME/.zshrc

RUN ARCH="$(dpkg --print-architecture)"; \
    case "$ARCH" in \
      amd64) MICROMAMBA_URL='https://micro.mamba.pm/api/micromamba/linux-64/latest' ;; \
      arm64) MICROMAMBA_URL='https://micro.mamba.pm/api/micromamba/linux-aarch64/latest' ;; \
      *) echo "unsupported architecture: $ARCH" >&2; exit 1; ;; \
    esac; \
    curl -Ls "$MICROMAMBA_URL" | tar -xvj bin/micromamba
RUN mv ./bin/micromamba /bin/micromamba && \
    rm -rf ./bin && \
    micromamba shell init --shell zsh

COPY env.yaml .
RUN micromamba install --name base --file env.yaml --yes && \
    micromamba clean --all --yes

WORKDIR /app

CMD ["micromamba", "run", "--name", "base", "jupyter", "lab", "--allow-root", "--ip=0.0.0.0", "--no-browser", "--port=80", "--ServerApp.password=''", "--ServerApp.token=''"]
