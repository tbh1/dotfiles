## Global
```bash
# /etc/profile.d/dotfiles.sh
export DOTFILES=/path/to/dotfiles
```

## Fish

Prereqs:
- fisherman https://github.com/fisherman/fisherman

```sh
# ~/.config/fish/conf.d/dotfiles.fish
for snippet in $DOTFILES/fish/**.fish
    source $snippet
end

set -g -x fisher_file $DOTFILES/fish/fishfile
```

## Neovim

Prereqs:
- vim-plug: https://github.com/junegunn/vim-plug

```vim
" ~/.config/nvim/dotfiles.vim
for f in split(glob('$DOTFILES/neovim/**.vim'), '\n')
    exe 'source' f
endfor
```
