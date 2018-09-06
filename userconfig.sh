#!/bin/bash
###### userconfig.sh
appname=$2
user=$1


echo "Generate a RSA key"
ssh-keygen -t rsa

echo  "Copying to the home folder"
cp /home/$user/.ssh/id_rsa.pub /home/$user/$user.pub

echo -e "\e[1m\e[5m\033[31m!!!IMPORTANT!!!\e[0m\e[25m\e[21m"
read -p "Your new public key is in your home folder [press any key to continue] "
echo ""
echo ""
cat /home/$user/$user.pub
echo ""
echo ""
echo ""

read -p "Would you like to setup a GIT user? [y/N]? "
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Your name for the git config? "
    if [[ ! $REPLY ]]; then
        echo "You must set a name"
        echo "Goodbye"
        echo ""
        echo ""
        exit 1
    fi
    git config --global user.name "$REPLY"

    read -p "Your email for the git config? "
    if [[ ! $REPLY ]]; then
        echo "You must set a email"
        echo "Goodbye"
        echo ""
        echo ""
        exit 1
    fi
    git config --global user.email "$REPLY"
    
    git config --global credential.helper cache
    git config --global credential.helper 'cache --timeout=3600'
fi



echo "Setup GIT status"
cat > ~/.bashrc << EOF
    if [ -f ~/.bash_git ]; then
       . ~/.bash_git
    fi
EOF

cat > ~/.bash_git << EOF
    function parse_git_dirty {
      [[ \$(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo "*"
    }
    function parse_git_branch {
      git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1\$(parse_git_dirty)]/"
    }
    export PS1='\u@\h \[\033[1;33m\]\w\[\033[0m\]\$(parse_git_branch)$ '
EOF

source /home/$user/.bashrc


echo "Setting vendor bin path"
echo 'PATH="./vendor/bin:$PATH"' >> ~/.profile

echo "Setting default home folder"
echo "cd /home/$user/$appname" >> ~/.profile




#echo "init git flow"
#git flow init

echo "Add an SSH key"
read -p "Would you like to add an SSH key? [y/N]? "
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Please paste you key "
    if [[ $REPLY ]]; then
        echo ""
        
        cat > /home/$user/.ssh/authorized_keys << EOF
$REPLY
EOF
        cat > /home/$user/.ssh/authorized_keys2 << EOF
$REPLY
EOF

    else
        echo "No key to add."
    fi
fi
echo ""
echo ""
