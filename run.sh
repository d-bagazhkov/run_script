#!/bin/bash

######### START   CONFIGURATION #########
PROGRAM_NAME='YoUr PrOgRaM nAmE';
ROOT_DIRECTORY='/mnt/d/Workspace/Bash&Batch/java_run';
LOG_DIRECTORY_NAME='logs';
DEFAULT_ARGUMENT_FUNCTION="1"

# "printHelp:help:h" - where printHelp - function name, help - long flag, h - short flag
AVAILABLE_FLAGS=(
    "printHelp:help:h"
    "stopFunction:stop:o"
    "startFunction:start:a"
    "startFunction:debug:d"
);
######### END     CONFIGURATION #########
######### START   SCRIPT FUNCIONS #########
function printHelp {
    echo "$HELP_STRINGS";
    exit;
}
function stopFunction {
    arg=$1;
    echo "stopFunction($arg)";
}
function startFunction {
    arg=$1;
    echo "startFunction($arg)";
}

######### END     SCRIPT FUNCIONS #########

LOG_DIRECTORY=$ROOT_DIRECTORY/$LOG_DIRECTORY_NAME
if [ ! -d $LOG_DIRECTORY ]; then 
    mkdir $LOG_DIRECTORY;
fi

if [ -z $DEFAULT_ARGUMENT_FUNCTION ]; then 
    DEFAULT_ARGUMENT_FUNCTION=1
fi
HELP_STRINGS=`sed "s/{PROGRAM_NAME}/$PROGRAM_NAME/g" help.txt`;

get() {
    str=$1; num=$2; sep=$3;
    if [[ -z $3 ]]; then
        sep=':'
    fi
    IFS=':' read -r -a array <<< "$str"
    echo "${array[$num]}"
}

getArgumentFlag() {
    searched="$1";
    for keys in ${INPUT_FLAGS[@]}
    do  
        if [[ `get $keys 1` = "$searched" ]] || [[ `get $keys 2` = "$searched" ]]; then 
            echo `get $keys 3`; return 0;
        fi
    done;
    return 1;
}

if [[ -z "$@" ]]; then 
    echo -e "Nothing to run. Please, specify parameters\n";
    echo "$HELP_STRINGS"; 
    exit;
fi

INPUT_FLAGS=();
for arg in $@; do
    if [[ $arg == -* ]]; then
        key="${arg%=*}" 
        key="${key#*-}"
        if [[ "$key" = -* ]]; then
            key="${key#*-}"
        fi
        value=$DEFAULT_ARGUMENT_FUNCTION
        if [[ "$arg" = *=* ]]; then
            value="${arg#*=}"
        fi
        result=""
        for flags in ${AVAILABLE_FLAGS[@]}
        do
            if [[ `get $flags 1` = "$key" ]] || [[ `get $flags 2` = "$key" ]]; then
                result=("$flags:$value"); 
                break;
            fi
        done
        if [ -z "$result" ]; then
            echo -e "Incorrect flag '$key'\n";
            echo "$HELP_STRINGS"; 
            exit;
        fi
        INPUT_FLAGS+=($result)
    fi
done

for flag in ${AVAILABLE_FLAGS[@]}; do
    flagLong=`get $flag 1`
    if [[ -n `getArgumentFlag $flagLong` ]] && [[ -n `get $flag 0` ]]; then
        func=`get $flag 0`
        arg=`getArgumentFlag $flagLong`
        $func $arg
    fi
done