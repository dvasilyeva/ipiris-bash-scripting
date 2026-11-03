#!/bin/bash
dirpath="${PWD}"
mask="*"
number=$(nproc)

while :
do
    case "$1" in
        --path)
            dirpath=$2
            shift 2
        ;;
        --mask)
            mask=$2
            shift 2
        ;;
        --number)
            number=$2
            shift 2
        ;;
        *)
            break
        ;;
    esac
done

command=$1

if [[ ! -d "${dirpath}" ]]
    then
        echo "Ошибка: каталог ${dirpath} не существует"
        exit 1
fi

if [[ -z "${mask}" ]]
    then
        echo "Ошибка: маска не может быть пустой"
        exit 1
fi

case "${number}" in
    ""|*[!0-9]*|0*)
        echo "Ошибка: number должно быть целым числом больше нуля"
        exit 1
    ;;
esac

command_path=$(type -P "${command}")

if [[ -z "${command_path}" ]]
    then
        echo "Ошибка: команда ${command} не найдена или не исполняемая"
        exit 1
fi

dirpath=$(cd "${dirpath}" && pwd)

declare -i running=0

for file in "${dirpath}"/${mask}
do
    if [[ ! -f "${file}" || -L "${file}" ]]
        then
            continue
    fi

    if (( running >= number ))
        then
            wait -n
            running+=-1
    fi

    "${command_path}" "${file}" &
    running+=1
done

wait
