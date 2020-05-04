#!/bin/bash

echo
echo "##     ## ######## ##       ##     ##"
echo "##     ## ##       ##       ###   ###"
echo "##     ## ##       ##       #### ####"
echo "######### ######   ##       ## ### ##"
echo "##     ## ##       ##       ##     ##" 
echo "##     ## ##       ##       ##     ##" 
echo "##     ## ######## ######## ##     ##" 
echo

helper() {
    echo
    echo "Examples:"
    echo "# bash chart-installer.bash [DATA_LIST_PATH] [NAMESPACE?]"
    echo
}

if [ -z "$1" ]; then
    echo
    echo "Could not be opened: parameter is null"
    helper
    exit 1
fi

currentPath=$(pwd)
input="$currentPath/$1"
namespace="default"

if [ ! -z "$2" ]; then
    namespace="$2"
fi

if [ ! -r $input ]; then
    if [ -r $1 ]
    then
        input="$1"
    else
        echo
        echo "Could not be opened: '$1'"
        helper
        exit 1
    fi
fi

failedList=()

while IFS= read -r line
do
    chartName=$line

    echo
    echo "==================     $chartName     ===================="
    sudo microk8s.helm install ./$chartName --name $chartName --namespace $namespace

    if [ $? -gt 0 ]; then
        echo "Could be installed chart: $chartName"
        failedList+=("$chartName")
        continue
    fi

done < "$input"

echo
echo "FAILED COUNT: ${#failedList[@]}"

if [ ${#failedList[@]} -gt 0 ]; then
    echo
    echo "FAILED LIST" > "$currentPath/result.log"
    echo ${failedList[@]} | sed -r -e 's/\s+/\n/g' >> "$currentPath/result.log"
    echo "CHECK LOG: $currentPath/result.log"
fi
