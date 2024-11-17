FROM alpine:edge

RUN apk update
RUN apk add --no-cache \
   git build-base make coreutils curl wget unzip tar gzip \
   bash fish file fd sed ripgrep nodejs npm alpine-sdk neovim tree-sitter
   
# RUN mkdir -p /root
# WORKDIR /root
# RUN wget 'https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz'
# RUN tar -xzf nvim-linux64.tar.gz
# ENV PATH="/root/nvim-linux64/bin:${PATH}"


RUN mkdir ~/.npm-global && npm config set prefix '~/.npm-global'
ENV PATH="/root/.npm-global/bin:${PATH}"
# RUN npm i -g neovim ls_emmet tree-sitter-cli

RUN git clone https://github.com/NvChad/starter /root/.config/nvim
WORKDIR /root/.config/nvim
