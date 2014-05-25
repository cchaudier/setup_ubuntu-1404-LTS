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
  #run sudo 'echo "deb http://archive.ubuntu.com/ubuntu precise main universe" >> /etc/apt/sources.list'
  run sudo apt-get update 
  run sudo apt-get upgrade -y 
  run sudo apt-get dist-upgrade
  install_package zsh curl git-core vim
  install_package language-pack-fr
  install_rcm
  install_nginx
  trace " --> packages OK"
}

install_lemp() {
  install_package nginx php5 php5-fpm php-apc
  run sudo mkdir -p /usr/share/nginx/www/$sever_name
  sudo rm /etc/nginx/sites-enabled/default
  run sudo cp /app/setup_ubuntu/nginx.conf /etc/nginx/sites-available/$server_name
  run sudo ln -fs /etc/nginx/sites-available/$server_name /etc/nginx/sites-enabled/$server_name
  run sudo cp /app/setup_ubuntu/info.php /usr/share/nginx/www/$server_name
  run sudo service php5-fpm restart
  run sudo nginx -t && sudo service nginx restart
  install_mariadb
  trace " --> lemp OK"
}

install_mariadb() {
  run sudo apt-get install software-properties-common
  run sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
  run sudo add-apt-repository 'deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/10.0/ubuntu trusty main'
}

install_package() {
    run sudo apt-get install -y $*
}

install_rcm() {
    trace "Installation rcm"
    cd /tmp
    run wget http://thoughtbot.github.io/rcm/debs/rcm_1.2.0_all.deb
    run sudo dpkg -i rcm_1.2.0_all.deb
    rm -f rcm_1.2.0_all.deb
    cd -
}

create_users() {
    trace "Creating all users... ${!USERS[*]}"
    for user in ${!USERS[*]}; do
        trace "Create user : $user"
        id $user >/dev/null || create_user.sh $user ${USERS[${user}]}
    done
}

trace "Installation du minimal vital sur $os_version serveur"
test_os
change_name
install_packages
#create_users
sortie 0
