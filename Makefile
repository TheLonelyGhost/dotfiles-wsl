.DEFAULT_GOAL := apply

AWK := /usr/bin/awk
CURL := /usr/bin/curl
DELTA := /usr/bin/delta
GO := /usr/local/go/bin/go
GHQ := $(HOME)/.local/bin/ghq
GIT := /usr/bin/git
GPG := /usr/bin/gpg
INSTALL := /usr/bin/install
RIG := $(HOME)/.local/bin/rig
RIPGREP := /usr/bin/rg
SSHKEYGEN := /usr/bin/ssh-keygen
STOW := /usr/bin/stow
STARSHIP := $(HOME)/.local/bin/starship
TAR := /usr/bin/tar
TMUX := /usr/bin/tmux
TPM := $(HOME)/.config/tmux/plugins/tpm
VIM := /usr/bin/nvim
ZSH := /usr/bin/zsh

DELTA_VERSION := 0.18.2
GO_VERSION := 1.23.4
RIG_VERSION := 1.0.0
STARSHIP_VERSION := 1.22.1

##### SETUP FOLDERS

$(HOME)/.local/bin:
	mkdir -p -m0755 $(HOME)/.local/bin

$(HOME)/.config:
	mkdir -p -m0755 $(HOME)/.config

$(HOME)/.gnupg:
	mkdir -p -m0700 $(HOME)/.gnupg

$(HOME)/.ssh:
	mkdir -p -m0755 $(HOME)/.ssh

##### INSTALL TOOLS

$(DELTA): $(CURL)
	@if ! [ -x $(DELTA) ]; then \
		echo "Installing git-delta to $(DELTA)"; \
		$(CURL) -SsLo /tmp/git-delta.deb https://github.com/dandavison/delta/releases/download/$(DELTA_VERSION)/git-delta_$(DELTA_VERSION)_amd64.deb; \
		sudo dpkg -i /tmp/git-delta.deb; \
		rm -f /tmp/git-delta.deb; \
	fi

$(GO):
	curl -SsLo /tmp/go.tgz https://go.dev/dl/go$(GO_VERSION).linux-amd64.tar.gz
	sudo tar -xz -C /usr/local /tmp/go.tgz
	rm /tmp/go.tgz

$(GHQ): $(GO) $(HOME)/.local/bin
	@if ! [ -x $(GHQ) ]; then \
		echo "Installing ghq to $(GHQ)"; \
		$(GO) install github.com/x-motemen/ghq@latest; \
		$(INSTALL) -m0755 $(HOME)/go/bin/ghq $(HOME)/.local/bin/; \
	fi

$(TPM): $(TMUX) $(GIT) $(HOME)/.config
	@if ! [ -d $(TPM) ]; then \
		echo "Installing tmux plugin manager to $(TPM)"; \
		mkdir -p $(HOME)/.config/tmux/plugins; \
		$(GIT) clone https://github.com/tmux-plugins/tpm.git $(TPM); \
	fi

$(RIG): $(HOME)/.local/bin $(GIT) $(RIPGREP)
	@if ! [ -x $(RIG) ]; then \
		echo "Installing rig to $(RIG)"; \
		$(CURL) -SsLo /tmp/rig https://github.com/TheLonelyGhost/rig/releases/download/v$(RIG_VERSION)/rig-linux-amd64; \
		$(INSTALL) -m0755 /tmp/rig $(HOME)/.local/bin/; \
	fi

$(STARSHIP): $(HOME)/.local/bin $(CURL) $(TAR) $(INSTALL)
	@if ! [ -x $(STARSHIP) ]; then \
		echo "Installing starship to $(STARSHIP)"; \
		$(CURL) -SsLo /tmp/starship.tgz https://github.com/starship/starship/releases/download/v$(STARSHIP_VERSION)/starship-x86_64-unknown-linux-musl.tar.gz; \
		mkdir -p /tmp/starship; \
		$(TAR) -xz -C /tmp/starship -f /tmp/starship.tgz; \
		$(INSTALL) -m0755 /tmp/starship/starship $(HOME)/.local/bin/starship; \
		rm -rf /tmp/starship /tmp/starship.tgz; \
	fi

$(AWK) $(CURL) $(GIT) $(GPG) $(INSTALL) $(MAN) $(SSHKEYGEN) $(STOW) $(TAR) $(TMUX) $(VIM) $(ZSH) $(RIPGREP):
	sudo apt-get update -y
	sudo apt-get install -y build-essential curl gawk git gnupg man-db neovim openssh-client ripgrep stow tmux zsh

##### CONFIGURE SOFTWARE

.PHONY: ssh
ssh: $(HOME)/.ssh $(SSHKEYGEN)
	@if ! [ -e $(HOME)/.ssh/id_ed25519 ]; then \
		echo "Generating default ed25519 SSH key into ~/.ssh directory"; \
		$(SSHKEYGEN) -t ed25519; \
	fi

.PHONY: gpg
gpg: $(HOME)/.gnupg $(GPG)
	@if [ -n "$(EMAIL)" ] && ! $(GPG) --list-secret-keys $(EMAIL) | grep -qFe '$(EMAIL)' >/dev/null 2>&1; then \
		echo "Generating GPG private key for $(EMAIL)"; \
		$(GPG) --full-generate-key; \
	fi

.PHONY: tmux
tmux: $(TPM) $(GIT)
	env TMUX='' $(TMUX) new-session $(TPM)/scripts/install_plugins.sh

.PHONY: vim
vim: $(VIM)
	@true

.PHONY: zsh
zsh: $(AWK) $(ZSH)
	@if ! getent passwd $(USER) | $(AWK) -F: '{ print $$NF }' | grep -qFe "$(ZSH)" >/dev/null 2>&1; then \
		chsh -s $(ZSH); \
	fi

##### SYMLINK DOTFILES

.PHONY: stow
stow: $(STOW) $(GIT) $(STARSHIP) $(HOME)/.config $(HOME)/.gnupg $(TPM)
	$(STOW) --restow --dotfiles .
	$(GIT) config --global user.name 'David Alexander'
	@if [ -n "$(EMAIL)" ]; then \
		echo "$(GIT) config --global user.email $(EMAIL)"; \
		$(GIT) config --global user.email $(EMAIL); \
	fi

.PHONY: apply
apply: stow gpg ssh tmux vim zsh $(GHQ) $(RIG) $(DELTA)
	@if [ -z "$(EMAIL)" ]; then \
		printf 'ERROR: Missing the EMAIL flag. Repeat this command with `EMAIL=<your-email>` passed to `make` to complete the configuration.\n'; \
	fi
