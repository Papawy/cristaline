#!/bin/sh

if [ "$#" -lt 1 ]; then
    echo "Usage: ./cristaline.sh [OPTIONS...] CONFLOOSE"
    exit 1
fi

#masterlist_url="https://raw.githubusercontent.com/Papawy/cristaline/master/masterlist"
masterlist_url="https://pastebin.com/raw/YyyRFyNw"

mode_verbose=0
mode_noexec=0
mode_list=0

for arg; do
    if [ "$arg" == "-h" ] || [ "$arg" == "--help" ]; then
        echo "Usage: ./cristaline.sh [OPTIONS...] CONFLOOSE"
        echo -e "Options:"
        echo -e "\t-v --verbose\tverbose mode"
        echo -e "\t-n --no-exec\tno-exec mode, does not execute script after downloading them, mostly for testing"
        echo -e "\t-l --list\tlist all available confloose from masterlist"
        exit 0
    elif [ "$arg" == "-v" ] || [ "$arg" == "--verbose" ]; then
        mode_verbose=1
        shift
        continue
    elif [ "$arg" == "-n" ] || [ "$arg" == "--no-exec" ]; then
        mode_noexec=1
        shift
        continue
    elif [ "$arg" == "-l" ] || [ "$arg" == "--list" ]; then
        mode_list=1
        shift
        continue
    fi
done

verbose()
{
    if [ "$mode_verbose" -eq 1 ]; then
        echo -e "$1"
    fi
}

# exec_confloose user, repo, confloose_name
exec_conflooe()
{
    verbose "Getting the conflose $3 from $1 in $2..."
    wget --quiet "https://github.com/$1/$2/blob/master/$3.sh -O confloose.sh"

    verbose "Executing confloose script in background."
    if [ "$mode_noexec" -eq 1 ]; then
        verbose "\tNo Exec mode activated"
    else
        bash "confloose.sh" &
    fi

    if [ "$mode_noexec" -eq 0]; then
        verbose "Removing confloose script file."
        rm -f "confloose.sh"
    fi
}

# Getting confuse list from internet
verbose "Getting confuse list from internet."

repo=""
user=""
conf_name=""
found=0

curl --silent "$masterlist_url" > "/dev/null"
if [ $? -ne 0 ]; then
    verbose "Masterlist not found, exiting"
    exit 1
fi

if [ "$mode_list" -eq 1 ]; then
    verbose "Confloose list:"
    for line in $(curl -s "$masterlist_url"); do
        read -r user repo conf_name <<<$(echo "$line" | sed -r "s/([^,]*),([^,]*),([^,]*)/\1 \2 \3/")
        verbose "-- Confloose: $conf_name"
        verbose "\tby: $user"
        verbose "\trepo: $repo"
    done
    exit 0
fi

if [ -z "$1" ]; then
    verbose "No confloose given"
    exit 1
fi

# Looking for script existence
verbose "User selected $1, seeing if it exist"

#format : user,repo,conf
while IFS=''; read -r line; do
    read -r repo user conf_name <<<$(echo "$line" | sed -r "s/([^,]*),([^,]*),([^,]*)/\1 \2 \3/")
    if [ "$1" == conf_name ]; then
        found=1
        break
    fi
done <$(curl -s "$masterlist_url");

if [ "$found" -ne 1 ]; then
    verbose "Confloose $1 not found, try ./cristaline.sh -l for a list of available confloose"
    exit 1
fi

# Executing exec_confuse with corresponding parameters
verbose "Script $conf_name found !"

exec_confloose "$user" "$repo" "$conf_name"

if [ "$mode_noexec" -eq 0]; then
    verbose "Removing confuse install script (this script)."
    rm -f "$0"
fi

exit 0
