#!/bin/zsh

DIRNAME="$( cd "$(dirname "$0")" ; pwd -P )"

# Install oh-my-zsh
if [ -z "${ZSH}" ]; then 
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# Add local dotfiles
DOTFILES_MIXIN="source $DIRNAME/zsh/init.zsh"

echo "DIRNAME=$DIRNAME"
echo "DOTFILES_MIXIN=$DOTFILES_MIXIN"

if grep -q $DOTFILES_MIXIN $HOME/.zshrc; then
    echo "dotfile mixins already applied"
else
    echo "adding dotfile mixins"
    echo $DOTFILES_MIXIN >> $HOME/.zshrc
    source $HOME/.zshrc
fi

echo "dotfile initialization complete"
