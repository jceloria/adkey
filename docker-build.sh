#!/usr/bin/env bash

SDIR=$(readlink -f ${0%/*})
NAME=${SDIR##*/}

docker info >/dev/null 2>&- || { retval=$?; echo "docker isn't running"; exit ${retval}; }

docker stop ${NAME}

IMAGES=($(docker images -a | tail -n +2 | awk '$0~/<none>|'"${NAME}"'/{print $3}'))

if [[ ${#IMAGES[@]} -gt 0 ]]; then
    docker images -a | awk '$0~/REPOSITORY|<none>|'"${NAME}"'/'
    read -p 'Hit [Enter] to remove above images, [Ctrl-c] to cancel: '

    docker rmi ${IMAGES[@]}
    read -p 'Hit [Enter] to continue: '
fi

read -p "Preparing to build ${USER}/${NAME}, hit [Enter] to continue: "
docker build --rm --no-cache --pull -t ${USER}/${NAME} .
