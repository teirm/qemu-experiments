#!/bin/bash

# A bash script to handle the generation and clean up
# of alpine linux qemu images

OPTION=$1
PORT=$2

function f_error {
    echo "Error occured during $1"
    echo "Exiting with error code $2"
    exit $2
}

function f_usage {
    echo "Usage: bash alpine-driver.sh [boot|create <port>|clean] "
    exit 1;
}

function f_boot {
   
    if [[ $PORT == "" ]]; then
        echo "No port number provided"
        f_usage 
    fi 

    echo "Going to boot alpine linux"
    
    if [ ! -e alpine.qcow ]; then
        echo "File 'alpine.qcow' does not exist"
        exit 1
    fi
    echo "Accessible on port $PORT"
    
    # not catching this error since this function creates a bash shell
    qemu-system-x86_64 alpine.qcow -boot c -net nic -net user -m 256 -localtime -redir tcp:$PORT::22

}

function f_create {
    
    echo "Going to create alpine linux image with 8GB hdd"
    if [ -e alpine.qcow ]; then
        echo "File 'alpine.qcow' exists!"
        exit 1
    fi
    qemu-img create alpine.qcow 8G 
    if [[ $? != 0 ]]; then 
        f_error 'qemu-img create' $?
    fi

    # Get ISO name
    

    # Not catching the error here since this command starts an Xwindow
    qemu-system-x86_64 -cdrom *.iso -hda alpine.qcow -boot d -net nic -net user -m 256 -localtime

}

function f_clean {
    echo "Going to clean alpine linux image"

    if [ ! -e alpine.qcow ]; then 
        echo "File 'alpine.qcow' does not exist"
        exit 1
    fi
    
    read -p "Are you sure you want to delete 'alpine.qcow'? " yn

    case $yn in
        [Yy]*) rm alpine.qcow
               echo "Deleted 'alpine.qcow'"
               ;;
        *) echo "Unknown input -- assuming no."
           ;;
    esac
}


if [[ $OPTION == "" || $PORT == "" ]]; then
    echo "No Option given"
    f_usage
fi

case $OPTION in
    boot)
        f_boot
        ;;
    create)
        f_create  
        ;;
    clean)
        f_clean
        ;;
    *)
        f_usage 
        ;;
esac

