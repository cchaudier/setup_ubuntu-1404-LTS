#!/bin/bash
# Install ubuntu base

. install.dist.cfg

sortie() {
  rc=$1
  test $rc -eq 0  && echo "Install completed." || echo "Install error [$rc]"
  exit $rc
}

trace() {
  echo "$(date "+%Y-%m-%d %H:%M:%S") | $*"
}

run() {
  echo "==[cmd : $*]=="
  $* || sortie 1
}

install_package() {
  run sudo apt-get install -y $*
}

test_os() {
  trace "Test OS version"
  grep "$os_version" /etc/issue >/dev/null|| (trace "OS not $os_version" && sortie 1)
  trace " --> Os OK"

}

change_name() {
  run sudo cp -p /etc/hostname /etc/hostname.sav
  run sudo echo $server_name > /etc/hostname
  trace "Server name now : $server_name"
}

install_packages() {
  trace "Installation packages"
  run sudo dpkg --configure -a
  run sudo apt-get update -y
  run sudo apt-get upgrade -y 
  run sudo apt-get dist-upgrade -y
  install_package zsh curl wget subversion software-properties-common samba unzip
  install_package language-pack-fr
  install_git
  install_tmux
  create_dev_env
  install_ohmyzsh
  install_dotfiles
  install_bats
  install_ruby
  install_vim
  install_docker
  get_projets
  trace " --> packages OK"
}

install_git() {
  trace "Install Git and co"
  #TODO utiliser NVM
  install_package git-core git-flow nodejs npm nodejs-legacy
  run sudo -H npm install -g ungit
  trace "  -> Git and co OK"
}

get_projets() {
  trace "Récupération des projets"
  cd ~/dev/app
  #TODO
  cd ~/dev/env
  #TODO
  trace "  -> Projets OK"
}

install_tmux() {
  trace "Install tmux"
  install_package tmux
  run gem install tmuxinator
  trace "  -> tmux OK"
}

install_docker() {
  trace "Install docker.io"
  #TODO
  install_package docker.io
  run sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
  run sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
  trace "  -> docker.io OK"
}

install_vim() {
  trace "Install VIM"
  install_package vim
  #TODO vundle
  trace "  -> VIM OK"
}

install_dotfiles() {
  trace "Installation dotfiles"
  cd /tmp
  run wget http://thoughtbot.github.io/rcm/debs/rcm_1.2.0_all.deb
  run sudo dpkg -i rcm_1.2.0_all.deb 
  rm -f rcm_1.2.0_all.deb
  cd ~
  #Thoughtbot dotfiles
  run git clone git://github.com/thoughtbot/dotfiles.git
  run rcup -d dotfiles -x README.md -x LICENSE -x Brewfile
  #dotfiles perso !
  #TODO
  trace "  -> dotfiles OK"
}

install_ohmyzsh() {
  trace "Installation OhMyZSH"
  run curl -L http://install.ohmyz.sh | sh
  run mkdir -p ~/.fonts/ && cd ~/.fonts/ 
  run wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
  run fc-cache -vf ~/.fonts  
  run mkdir -p ~/.config/fontconfig/conf.d/ && cd ~/.config/fontconfig/conf.d/
  run wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
  trace "  -> OhMyZsh OK"
}

install_bats() {
  trace "Install bats"
  cd ~/dev/src
  run git clone https://github.com/sstephenson/bats.git
  cd bats
  run sudo ./install.sh /usr/local
  trace "  -> Bats OK"
}

install_ruby() {
  trace "Install RUBY"
  run git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  run git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
  run rbenv install $ruby_version
  run rbenv global $ruby_version
  run gem install bundler foreman pg thin guard --no-rdoc --no-ri
  run gem update
  trace "  -> RUBY OK"
}

creat_dev_env() {
  trace "Create DEV env"
  cd ~
  run mkdir -p dev/app
  run mkdir -p dev/env
  run mkdir -p dev/src
  trace "  -> Dev env OK"
}

create_users() {
  trace "Creating all users... ${!USERS[*]}"
  for user in ${!USERS[*]}; do
    trace "Create user : $user"
    id $user >/dev/null || create_user.sh $user ${USERS[${user}]}
  done
}

trace "Installation du minimal vital sur $os_version dev worksation"
test_os
change_name
install_packages
#create_users
sortie 0
