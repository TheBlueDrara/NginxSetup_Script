#!/usr/bin/env bash
################################### Start Safe Header ##########################
#Developed by Alex Umansky aka TheBlueDrara
#Porpuse 
#Date 1.3.2025
set -o nounset
set -o exiterr
set -o pipefail
################################## End Safe Header ############################
SITES_AVAILABLE="/etc/nginx/sites-available"
SITES_ENABLED="/etc/nginx/sites-enabled"

function main(){

    echo "Please chose your desired option"
    echo -e "a) install nginx\n
             b) Check if VH exist, if not, configure your own\n
             c) Create a public html folder\n
             d) Create an authentication\n
             *) Exit"
             
    while getopts "a,b,c,d,*" NAME
    do
        case $NAME in
            a) install_nginx
            b) configure_vh
            c) enable_user_dir
            d) auth
            *) exit 0 
        esac
    done
}

function install_nginx(){

    if ! dpkg -l |grep -E '^\s*ii\s+nginx' > /dev/null; then
        MISSING_PACKAGES+="nginx "
    fi

    if ! dpkg -l |grep -E '^\s*ii\s+nginx-extras' > /dev/null; then
        MISSING_PACKAGES+="nginx-extras "
    fi

    if [ -n "$MISSING_PACKAGES" ]; then
        echo "nginx and enginx-extras are already installed..."
    elif
        echo "The following packages are missing: $MISSING_PACKAGES"
        echo "Would you like to install them (yes/no)?"
        read -r PAR1
        [ $PAR1 == "yes" ]; then
        sudo apt-get update && sudo apt-get install -y $MISSING_PACKAGES
    else
        echo "Goodbye!"
        
    fi
    main
}

function configure_vh(){

    echo "please enter your server name:"
    read -r FIND_SERVER
    VHOSTS=$(grep $FIND_SERVER $SITES_AVAILABLE 2>/dev/null)

    if [ -n $VHOSTS ]; then
        echo "Virtual host found:"
        echo $VHOSTS
    else 
        echo "No virtual host found"
    fi

    echo "Would you like to create a new VH? (yes/no)"
    read -r PAR2
    if [ $PAR2 == "yes" ]; then
    echo "Please enter new VH name:"
    read -r SERVER_NAME
    touch $SITES_AVAIABLE/$SERVER_NAME
    echo "server {
    listen 80;
    server_name $SERVER_NAME;
    root /var/www/$SERVER_NAME;
    index index.html; }" >> $SITES_AVAIABLE/$SERVER_NAME
    ln -s $SITES_AVAILABLE/$SERVER_NAME $SITES_ENABLED
    echo "Please enter a header name for your webpage:"
    read -r HEADER_NAME
    echo "<h1>$HEADER_NAME</h1>" >> /var/www/$SERVER_NAME2/index.html

    sudo systemctl restart nginx
    curl -I http://$SERVER_NAME
    fi
    main
}

function enable_user_dir(){

    echo 'location ~ ^/~(.+?)(/.*)?$ {
    alias /home/$1/public_html$2; }' >> $SITES_AVAIABLE/default
    sudo systemctl restart nginx
    bash curl -I http://localhost/~$USER
    if [ $? -eq 0 ] && echo "Configured a personal webpage successfully" || echo "Failed"
    fi
    main
}

function auth(){
    
    sudo apt-get update && sudo apt-get install apache2-utils
    echo "Please enter a username:"
    read -r USERNAME
    sudo htpasswd -c /etc/nginx/.htpasswd $USERNAME
    echo "location /secure {
    auth_basic "Restricted Area";
    auth_basic_user_file /etc/nginx/.htpasswd; }" >> $SITES_AVAILABLE/$SERVER_NAME
    sudo systemctl restart nginx
    curl -u $USERNAME:password -I http://localhost/secure
    if [ $? -eq 0 ] && echo "Username and Password created successfully!" || echo "Error"
    fi
    main

}
 














main


















