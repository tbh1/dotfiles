#!/bin/zsh
DIRNAME="$( cd "$(dirname "$0")" ; pwd -P )"

# Shell behavior
#bindkey -v

# Environment variables
export DOTFILES=$DIRNAME
export GOPATH=$HOME/go
export GROOVY_HOME=/opt/groovy/2.4.7/
export VISUAL=vim
export EDITOR="$VISUAL"
export GOOGLE_CLOUD_SDK=/opt/google/cloud/sdk

# Path configuration
export PATH=$PATH:$DIRNAME/util
export PATH=$PATH:$HOME/go/bin

# Aliases
alias flushdns="sudo /etc/init.d/dns-clean restart"
alias gs="gss"
alias gccl="gcloud config configurations list"
alias gcca="gcloud config configurations activate"
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
alias ups="sudo apt update && sudo apt upgrade -y"
alias zedit="subl -nw ~/.zprofile && source ~/.zprofile && echo changes applied"
alias ledger="sudo udevadm control --reload-rules"

# Functions
tfup() {
	docker run --rm -p 8888:8888 -it --name tfps \
	-v ${1:-`pwd`}:/notebooks:rw \
	tensorflow/tensorflow
}

# Completions
for f in $DIRNAME/completions/*; do source $f; done

# if [ $commands[oc] ]; then
#   source <(oc completion zsh)
# fi

# if [ $commands[minikube] ]; then
#   source <(minikube completion zsh)
# fi

if [ $commands[helm] ]; then
  source <(helm completion zsh)
fi
