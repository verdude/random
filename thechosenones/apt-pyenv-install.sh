#!/usr/bin/env bash

sudo apt install zlib1g \
  zlib1g-dev \
  libssl-dev \
  libbz2-dev \
  libsqlite3-dev \
  libedit-dev \
  liblzma-dev \
  tk-dev \
  libreadline-dev \
  libffi-dev \
  curl

curl https://pyenv.run | bash -
