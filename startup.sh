#!/usr/bin/env bash

set -o errtrace

errorhandler(){
    echo "$@"
    exit 1
}

destroy() {
    echo "Undo"
    docker-compose down
    if [ -f "./configs/certs/nginx-proxy.local.key" ]; then
        sed -i 's/- CERT_NAME/# - CERT_NAME/g' docker-compose.yaml
        sed -i 's/- "443:443"/# - "443:443"/g' docker-compose.yaml
        sed -i "s%- ./configs/certs%# - ./configs/certs%g" docker-compose.yaml
        rm -f configs/certs/*
    fi
    exit 0
}

openbrowser(){
    echo "Open you bnrowser"
    [[ -x $BROWSER ]] && BPATH=$BROWSER || BPATH=$(which xdg-open || which gnome-open)
    exec "$BPATH" "$URL" >/dev/null 2>&1
}

runtest(){
    echo "sleep for 5s before helth check..."
    sleep 5
    [[ $(curl -kLI "$URL" -o /dev/null -w '%{http_code}\n' -s) == "200" ]] && echo "Container is healty" || errorhandler "Seems like the container crash or its taken too long"
}

ssl() {
    echo "Make the SSL certificate."
    mkdir -p configs/certs
    command -v openssl && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout configs/certs/nginx-proxy.local.key -out configs/certs/nginx-proxy.local.crt || errorhandler "You dont have openssl on your system"
    sed -i 's/# //g' docker-compose.yaml
    sudo bash -c 'echo "127.0.0.1 nginx-proxy.local" >> /etc/hosts'
    return 0
}

main(){
    echo "
    ╔╦╗┬┌┐┌┌┬┐╔╦╗┬┌┐┌┌─┐┬─┐┌─┐  ╔╦╗┌─┐┬  ┬╔═╗┌─┐┌─┐  ╔═╗┬ ┬┌─┐┬  ┬  ┌─┐┌┐┌┌─┐┌─┐
    ║║║││││ ││║║║││││├┤ ├┬┘└─┐   ║║├┤ └┐┌┘║ ║├─┘└─┐  ║  ├─┤├─┤│  │  ├─┤││││ ┬├┤ 
    ╩ ╩┴┘└┘─┴┘╩ ╩┴┘└┘└─┘┴└─└─┘  ═╩╝└─┘ └┘ ╚═╝┴  └─┘  ╚═╝┴ ┴┴ ┴┴─┘┴─┘┴ ┴┘└┘└─┘└─┘
    "

    case $1 in
    *"ssl"*)
        ssl ;;
    *"destroy"*)
       destroy ;;
    esac

    [[ "$1" == "ssl" ]] && URL=https://nginx-proxy.local/app1 || URL=http://localhost:8080/app1
    docker-compose up -d
    runtest "$URL"
    openbrowser "$URL"
}

main "$@"
