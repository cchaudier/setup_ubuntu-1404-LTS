#!/bin/bash
# Creat a user

sortie() {
    rc=$1
    test $rc -eq 0  && echo "User $user created." || echo "Error [$rc] !"
    exit $rc
}

trace() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") | $*"
}

run() {
    echo "==[cmd : $*]=="
    $* || sortie 1
}

create_user() {
    trace "Create user : $user"
    run sudo useradd $user -d /home/$user -m -s /bin/zsh
    run sudo mkdir -p /home/$user/.ssh
    trace " Install SSH key $ssh_key"
    run sudo touch /home/$user/.ssh/authorized_key
    run sudo chmod 777 /home/$user/.ssh/authorized_key
    curl $ssh_key > /home/$user/.ssh/authorized_key
    run sudo chmod 600 /home/$user/.ssh/authorized_key
    run sudo chmod 700 /home/$user/.ssh
    run sudo chmod 750 /home/$user
    run sudo chown -R $user:$user /home/$user
    trace " --> User $user created"
}

config_user() {
    #Install oh-my-zsh
    sudo su $user -c 'curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh'
    #Instal dotfiles
    run "cd && git clone git://github.com/thoughtbot/dotfiles.git && cd dotfiles && ./install.sh"
    #The Ultimate Vim Distribution
    #http://vim.spf13.com/
    curl http://j.mp/spf13-vim3 -L -o - | sh

}


user=$1
ssh_key=$2

trace "Creating the user $user with she ssh key $ssh_key"
create_user
config_user
sortie 0
