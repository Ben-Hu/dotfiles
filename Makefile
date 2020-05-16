SHELL := /bin/bash

DIR := $(shell pwd)

ERLANG_VER := 23.0
ELIXIR_VER := 1.10.3-otp-23

PYENV_ROOT := ${HOME}/.pyenv
PYTHON_VER := 3.7.5

NODE_VER := v14.2.0

GO_VER := go1.14.3

TERRAFORM_VER := 0.12.25

init:
	ln -fs $(DIR)/bash/.bashrc ${HOME}/.bashrc
	ln -fs $(DIR)/bash/.bash_aliases ${HOME}/.bash_aliases
	ln -fs $(DIR)/ssh/config ${HOME}/.ssh/config
	ln -fs $(DIR)/vim/.vimrc ${HOME}/.vimrc
	ln -fs $(DIR)/git/.gitconfig ${HOME}/.gitconfig
	ln -fs $(DIR)/git/.gitignore ${HOME}/.gitignore
	ln -fs $(DIR)/iex/.iex.exs ${HOME}/.iex.exs
	ln -fsT $(DIR)/bin ${HOME}/.bin

base:
	sudo apt-get update
	sudo apt-get install -y build-essential libssl-dev libssh-dev zlib1g-dev libbz2-dev \
	libreadline-dev libsqlite3-dev wget curl llvm lldb libncurses5-dev libncursesw5-dev xz-utils \
	tk-dev libffi-dev liblzma-dev python-openssl automake autoconf libyaml-dev libxslt-dev libtool \
	unixodbc-dev libwxgtk3.0-dev libgl1-mesa-dev libglu1-mesa-dev xsltproc fop libxml2-utils \
	default-jdk valgrind gdb wireshark tshark git unzip byobu direnv

awscli:
	curl -fLSs -o awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
	unzip awscliv2.zip && rm awscliv2.zip
	sudo ./aws/install --update && rm -rf ./aws

terraform:
	curl -fLSs -o tf.zip \
	https://releases.hashicorp.com/terraform/$(TERRAFORM_VER)/terraform_$(TERRAFORM_VER)_linux_amd64.zip
	unzip tf.zip && rm tf.zip
	mkdir -p ${HOME}/.terraform/bin && mv terraform ${HOME}/.terraform/bin

circleci:
	mkdir -p ${HOME}/.circleci/bin/
	curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh \
	| DESTDIR=${HOME}/.circleci/bin/ bash
	circleci update install

docker:
	sudo apt-get update
	sudo apt-get install -y docker docker-compose
	sudo usermod -aG docker ${USER}
	sudo systemctl enable docker.service
	sudo systemctl start docker.service

postgresql:
	sudo apt-get update
	sudo apt-get install -y postgresql postgresql-contrib
	sudo service postgresql start

redis:
	sudo apt-get update
	sudo apt-get install -y redis
	sudo service redis-server start

asdf:
	test -s ${HOME}/.asdf || git clone https://github.com/asdf-vm/asdf.git ${HOME}/.asdf

asdf_erlang: asdf
	asdf plugin-list | grep erlang > /dev/null ||  asdf plugin-add erlang

asdf_elixir: asdf
	asdf plugin-list | grep elixir > /dev/null ||  asdf plugin-add elixir

erlang: asdf_erlang
	asdf install erlang $(ERLANG_VER)
	asdf global erlang $(ERLANG_VER)

elixir: asdf_elixir erlang
	asdf install elixir $(ELIXIR_VER)
	asdf global elixir $(ELIXIR_VER)

python:
	test -s ${PYENV_ROOT} || git clone git@github.com:pyenv/pyenv.git ${PYENV_ROOT}
	pyenv install $(PYTHON_VER)
	pyenv global $(PYTHON_VER)
	pip install --user --upgrade pipenv poetry black flake8 isort mypy

go:
	test -s ${HOME}/.gvm || \
	curl -fLSs https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash
	gvm install $(GO_VER) -B
	source ${HOME}/.gvm/scripts/gvm && gvm use ${GO_VER} --default

node:
	curl -fLSs https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
	. ${HOME}/.nvm/nvm.sh && nvm install $(NODE_VER) && nvm alias default $(NODE_VER)
