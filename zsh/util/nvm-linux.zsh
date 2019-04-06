if [ "$(expr substr $(uname -s) 1 5)" != "Linux" ]; then
  return 0;
fi


lazynvm() {
  unset -f nvm node npm
  # export NVM_DIR=~/.nvm
  export NVM_DIR=~/.nvm
  [ -s "/usr/share/nvm/nvm.sh" ] && . "/usr/share/nvm/nvm.sh"  # This loads nvm
}

nvm() {
  lazynvm 
  nvm $@
}

node() {
  lazynvm
  node $@
}

npm() {
  lazynvm
  npm $@
}
