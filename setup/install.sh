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
  run sudo dpkg --configure -a
  run sudo apt-get update -y
  run sudo apt-get upgrade -y 
  run sudo apt-get dist-upgrade -y
  install_package zsh curl git-core vim software-properties-common samba unzip
  install_package language-pack-fr
  install_rcm
  install_lemp
  install_panel
  trace " --> packages OK"
}

install_lemp() {
  trace "Installation stack LEMP"
  install_mariadb
  install_package nginx php5 php5-fpm php-apc php5-mysql php5-curl php5-mcrypt bind9
  run sudo mkdir -p $web_rootpath/$sever_name
  run sudo service php5-fpm restart
  trace "  -> PHP OK"
  run sudo nginx -t && sudo service nginx restart
  trace "  -> nginx OK"
  install_phpmyadmin
  trace " --> lemp OK"
}

install_mariadb() {
  sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
  sudo add-apt-repository 'deb http://ftp.igh.cnrs.fr/pub/mariadb/repo/10.0/ubuntu trusty main'
  run sudo apt-get update
  install_package mariadb-server mariadb-client
  run mysql -V 
  trace "  -> mariadb OK"
}

install_phpmyadmin() {
  install_package phpmyadmin
  #run sudo htpasswd /etc/phpmyadmin/htpasswd.setup admin
  run sudo ln -s /usr/share/phpmyadmin/ $web_rootpath/phpmyadmin
  trace "  -> phpmyadmin OK"
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
  trace "  -> rcm OK"
}

install_panel() {
  #install_package froxlor
  wget http://repo.ajenti.org/debian/key -O- | sudo apt-key add -
  sudo add-apt-repository 'deb http://repo.ajenti.org/ng/debian main main ubuntu'
  run sudo apt-get update
  install_package ajenti
  install_package ajenti-v ajenti-v-nginx ajenti-v-mysql ajenti-v-php-fpm
  run sudo service ajenti restart
  trace "  -> Panel OK"
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
