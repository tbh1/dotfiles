################################################
# Terminal behavior
################################################
set fish_greeting
set -x EDITOR nvim

################################################
# User environment
################################################


################################################
# General Aliases
################################################
alias grep='grep --color'
alias l="ls -lahG --almost-all"
alias vim=nvim
alias gofish='fisher ls-remote --format="%name(%stars): \n\t%info [%url]\n\n"'


################################################
# Google Cloud
################################################
set -x GCLOUD_HOME /opt/google/cloud/sdk

test -d $GCLOUD_HOME/bin       ; and set PATH $GCLOUD_HOME/bin $PATH
test -d $GCLOUD_HOME/bin       ; and set MANPATH $GCLOUD_HOME/help/man $MANPATH
