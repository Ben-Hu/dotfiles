SHELL := /bin/bash

DIR := $(shell pwd)

ASDF_ROOT := ${HOME}/.asdf

ERLANG_VER := 23.0
ELIXIR_VER := 1.10.3-otp-23

PYENV_ROOT := ${HOME}/.pyenv
PYTHON_VER := 3.7.5

NVM_ROOT := ${HOME}/.nvm
NODE_VER := v14.2.0

GVM_ROOT := ${HOME}/.gvm
GO_VER := go1.14.3

TERRAFORM_ROOT := ${HOME}/.terraform
TERRAFORM_VER := 0.12.25

.PHONY: init
init:
	ln -fs $(DIR)/bash/.bashrc ${HOME}/.bashrc
	ln -fs $(DIR)/bash/.bash_aliases ${HOME}/.bash_aliases
	ln -fs $(DIR)/vim/.vimrc ${HOME}/.vimrc
	ln -fs $(DIR)/screen/.screenrc ${HOME}/.screenrc
	mkdir -p ~/.ssh/ && ln -fs $(DIR)/ssh/config ${HOME}/.ssh/config
	ln -fs $(DIR)/git/.gitconfig ${HOME}/.gitconfig
	ln -fs $(DIR)/git/.gitignore ${HOME}/.gitignore
	mkdir -p ${HOME}/.psql_history && ln -fs $(DIR)/psql/.psqlrc ${HOME}/.psqlrc
	ln -fs $(DIR)/iex/.iex.exs ${HOME}/.iex.exs
	ln -fsT $(DIR)/bin ${HOME}/.bin
	curl -fLSs -o ${HOME}/.git-completion.bash \
	https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash

.PHONY: base
base:
	sudo apt-get update
	sudo apt-get install -y build-essential libssl-dev libssh-dev zlib1g-dev libbz2-dev \
	libreadline-dev libsqlite3-dev wget curl llvm lldb libncurses5-dev libncursesw5-dev xz-utils \
	tk-dev libffi-dev liblzma-dev python-openssl automake autoconf libyaml-dev libxslt-dev libtool \
	unixodbc-dev libwxgtk3.0-dev libgl1-mesa-dev libglu1-mesa-dev xsltproc fop libxml2-utils \
	default-jdk valgrind gdb wireshark tshark git unzip screen direnv jq

.PHONY: vscode
vscode:
	curl -fLSs -o vscode.deb https://go.microsoft.com/fwlink/?LinkID=760868
	sudo apt install ./vscode.deb && rm ./vscode.deb
	cat vscode/extensions.txt  | xargs -L 1 code --install-extension
	ln -fs $(DIR)/vscode/settings.json ${HOME}/.config/Code/User/settings.json
	ln -fs $(DIR)/vscode/keybindings.json ${HOME}/.config/Code/User/keybindings.json

.PHONY: awscli
awscli:
	curl -fLSs -o awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
	unzip awscliv2.zip && rm awscliv2.zip
	sudo ./aws/install --update && rm -rf ./aws

.PHONY: terraform
terraform:
	curl -fLSs -o tf.zip \
	https://releases.hashicorp.com/terraform/$(TERRAFORM_VER)/terraform_$(TERRAFORM_VER)_linux_amd64.zip
	unzip tf.zip && rm tf.zip
	mkdir -p ${TERRAFORM_ROOT}/bin && mv terraform ${TERRAFORM_ROOT}/bin

.PHONY: tfswitch
tfswitch:
	curl -fLSs -o tfswitch.sh \
	https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh
	chmod u+x tfswitch.sh
	./tfswitch.sh -b ${TERRAFORM_ROOT}/bin
	rm ./tfswitch.sh

.PHONY: circleci
circleci:
	mkdir -p ${HOME}/.circleci/bin/
	curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh \
	| DESTDIR=${HOME}/.circleci/bin/ bash
	circleci update install

.PHONY: docker
docker:
	sudo apt-get update
	sudo apt-get install -y docker docker-compose
	sudo usermod -aG docker ${USER}
	sudo systemctl enable docker.service
	sudo systemctl start docker.service

.PHONY: postgresql
postgresql:
	sudo apt-get update
	sudo apt-get install -y postgresql postgresql-contrib
	sudo service postgresql start

.PHONY: redis
redis:
	sudo apt-get update
	sudo apt-get install -y redis
	sudo service redis-server start

.PHONY: asdf
asdf:
	test -s $(ASDF_ROOT) || git clone https://github.com/asdf-vm/asdf.git $(ASDF_ROOT)

.PHONY: asdf_erlang
asdf_erlang: asdf
	asdf plugin-list | grep erlang > /dev/null ||  asdf plugin-add erlang

.PHONY: asdf_elixir
asdf_elixir: asdf
	asdf plugin-list | grep elixir > /dev/null ||  asdf plugin-add elixir

.PHONY: erlang
erlang: asdf_erlang
	asdf install erlang $(ERLANG_VER)
	asdf global erlang $(ERLANG_VER)

.PHONY: elixir
elixir: asdf_elixir erlang
	asdf install elixir $(ELIXIR_VER)
	asdf global elixir $(ELIXIR_VER)

.PHONY: python
python:
	test -s $(PYENV_ROOT) || git clone git@github.com:pyenv/pyenv.git $(PYENV_ROOT)
	pyenv install $(PYTHON_VER)
	pyenv global $(PYTHON_VER)
	pip install --user --upgrade pipenv poetry black flake8 isort mypy

.PHONY: go
go:
	test -s $(GVM_ROOT) || \
	curl -fLSs https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer | bash
	gvm install $(GO_VER) -B
	source $(GVM_ROOT)/scripts/gvm && gvm use $(GO_VER) --default
	GO111MODULE=on go get -u -v golang.org/x/tools/cmd/goimports
	GO111MODULE=on go get -u -v golang.org/x/tools/gopls@latest
	GO111MODULE=on go get -u -v golang.org/x/lint/golint

.PHONY: node
node:
	curl -fLSs https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
	. $(NVM_ROOT)/nvm.sh && nvm install $(NODE_VER) && nvm alias default $(NODE_VER)
