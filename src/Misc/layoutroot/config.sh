#!/bin/bash

user_id=`id -u`

# we want to snapshot the environment of the config user
if [ $user_id -eq 0 ]; then
    echo "Must not run with sudo"
    exit 1
fi

# Check dotnet core 2.0 dependencies for Linux
if [[ (`uname` == "Linux") ]]
then
    command -v ldd > /dev/null
    if [ $? -ne 0 ]
    then
        echo "Can not find 'ldd'. Please install 'ldd' and try again."
        exit 1
    fi

    ldd ./bin/libcoreclr.so | grep 'not found'
    if [ $? -eq 0 ]; then
        echo "Dependencies is missing for Dotnet Core 2.0"
        echo "Execute ./bin/installdependencies.sh to install any missing Dotnet Core 2.0 dependencies."
        exit 1
    fi

    ldd ./bin/System.Security.Cryptography.Native.OpenSsl.so | grep 'not found'
    if [ $? -eq 0 ]; then
        echo "Dependencies is missing for Dotnet Core 2.0"
        echo "Execute ./bin/installdependencies.sh to install any missing Dotnet Core 2.0 dependencies."
        exit 1
    fi

    ldd ./bin/System.IO.Compression.Native.so | grep 'not found'
    if [ $? -eq 0 ]; then
        echo "Dependencies is missing for Dotnet Core 2.0"
        echo "Execute ./bin/installdependencies.sh to install any missing Dotnet Core 2.0 dependencies."
        exit 1
    fi

    ldd ./bin/System.Net.Http.Native.so | grep 'not found'
    if [ $? -eq 0 ]; then
        echo "Dependencies is missing for Dotnet Core 2.0"
        echo "Execute ./bin/installdependencies.sh to install any missing Dotnet Core 2.0 dependencies."
        exit 1
    fi

    if ! [ -x "$(command -v ldconfig)" ]; then        
        LDCONFIG_COMMAND="/sbin/ldconfig"
        if ! [ -x "$LDCONFIG_COMMAND" ]; then
            echo "Can not find 'ldconfig' in PATH and '/sbin/ldconfig' doesn't exists either. Please install 'ldconfig' and try again."
            exit 1
        fi
    else
        LDCONFIG_COMMAND="ldconfig"
    fi

    libpath=${LD_LIBRARY_PATH:-}
    $LDCONFIG_COMMAND -NXv ${libpath//:/} 2>&1 | grep libicu >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Libicu's dependencies is missing for Dotnet Core 2.0"
        echo "Execute ./bin/installdependencies.sh to install any missing Dotnet Core 2.0 dependencies."
        exit 1
    fi
fi

# Change directory to the script root directory
# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd $DIR

source ./env.sh

shopt -s nocasematch
if [[ "$1" == "remove" ]]; then
    ./bin/Agent.Listener "$@"
else
    ./bin/Agent.Listener configure "$@"
fi
