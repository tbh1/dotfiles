#!/bin/zsh

DIRNAME="$( cd "$(dirname "$0")" ; pwd -P )"

# Install oh-my-zsh
if [ -z "${ZSH}" ]; then 
    echo "installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

# Add custom theme
if [ ! -a "$ZSH/themes/tedland.zsh-theme" ]; then
    echo "adding custom theme"
    ln -s "$DIRNAME/zsh/themes/tedland.zsh-theme" "$ZSH/themes/tedland.zsh-theme"
fi

sed -i 's/^ZSH_THEME=.*$/ZSH_THEME="tedland"/g' $HOME/.zshrc

# Add local dotfiles
DOTFILES_MIXIN="source $DIRNAME/zsh/init.zsh"

if grep -q $DOTFILES_MIXIN $HOME/.zshrc; then
    echo "dotfile mixins already applied"
else
    echo "adding dotfile mixins"
    echo $DOTFILES_MIXIN >> $HOME/.zshrc
fi

# Add vim config
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "installing vim-plug"
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if [ ! -f "$HOME/.vimrc" ]; then
    touch "$HOME/.vimrc"
fi

VIMRC_MIXIN="source $DIRNAME/vim/vim_profile"
if ! grep -q VIMRC_MIXIN "$HOME/.vimrc"; then
    echo "\n$VIMRC_MIXIN" >> "$HOME/.vimrc"
fi

source $HOME/.zshrc

echo "dotfile initialization complete"
echo "run 'source ~/.zshrc' to apply changes"
