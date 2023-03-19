FROM tensorflow/tensorflow:latest-gpu-jupyter
RUN mkdir /app
WORKDIR /app

RUN apt-get update -qq
RUN apt-get install -qq git vim zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
RUN sed -i 's/ZSH_THEME="\(.*\)"/ZSH_THEME="candy"/' $HOME/.zshrc

CMD jupyter notebook \
  --allow-root \
  --ip=0.0.0.0 \
  --no-browser \
  --NotebookApp.password='' \
  --NotebookApp.token='' \
  --port=80
