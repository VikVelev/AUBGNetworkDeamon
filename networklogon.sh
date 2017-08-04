#!/bin/bash

#Initializing variables;
post_data=( )
test_data=0
sleeptime=3600
username=0
key=0
typeof=0
credentialsArr=( )
preferencesArr=( )

#preferenceArr is an array with preferences, [0] is the default usage
#Select preferences
if [ -f preferences -a -r preferences ]; then
    echo "Preferences file found..."

    lc=0
    while read -r LINE || [[ -n $LINE ]]; do
        preferenceArr[$lc]=$LINE
        let lc+=1
    done < preferences
    typeof=${preferenceArr[0]}
    sleeptime=${preferenceArr[1]}
else
    echo "Single usage or use as a deamon in the background? (type 1 or 2)"
    echo "(You can change it by simply deleting the preferences file and running the script again.)"

    while true; do
        read typeof
        echo $typeof >> preferences

        case $typeof in
            ''|*[!0-9]*) echo "NaN, Try again."; continue;;
            *) echo "";;
        esac

        if [ $typeof -eq 1 -o $typeof -eq 2 ]; then
            if [ $typeof -eq 2 ]; then
                echo "How frequent do you want to try and connect? (in minutes)"
                while true; do
                    read sleeptime
                    case $sleeptime in
                        ''|*[!0-9]*) echo "NaN, Try again."; continue;;
                        *) echo "" ;;
                    esac
                    let sleeptime*=60 #Converting from minutes to seconds because that's how "sleep" works.
                    if [ $sleeptime -lt 1800 ]; then
                        echo "That's too frequent."
                        continue
                    else
                        echo $sleeptime >> preferences        
                        break
                    fi
                done
            fi
            break
        else
            echo "Invalid choice"
            continue
        fi
    done
fi

#Get username and password
if [ -f credentials -a -r credentials ]; then
    echo "Credentials found, initializing variables."

    linecounter=0
    while read -r LINE || [[ -n $LINE ]]; do
        credentialsArr[$linecounter]=$LINE
        let linecounter+=1
    done < credentials

    username=${credentialsArr[0]}
    key=${credentialsArr[1]}
    sleep 2

    echo "Initialized...Connecting"
    sleep 2
else
    echo "You've never run this script before, type in your username and password"
    echo "Username:"
    read username
    echo $username >> credentials
    echo "Password:"
    read key
    echo $key >> credentials
fi

#Deamon
while true; do

    post_data[0]=bash curl --data "fname=wba_login&username=$username&key=$key" http://wlc8.lib/aaa/wba_form.html?wbaredirect=http://www.gstatic.com/generate_204 &> /dev/null
    post_data[1]=bash curl --data "fname=wba_login&username=$username&key=$key" http://wlc2801.sc/aaa/wba_form.html?wbaredirect=http://www.gstatic.com/generate_204 &> /dev/null

    if [ -z ${post_data[0]} -a -z ${post_data[1]} ]; then
        #Check for data response here
        echo "Login failed. Possibly already logged in or unknown network or maybe a success, who knows."
        if [ $typeof -eq 1 ]; then
            exit;
        fi
        echo "Running deamon..."
    else
        echo "Logging in..."
        sleep 2
        test_data=ping 8.8.8.8 -c 1 &> /dev/null
        if [ -z $test_data ]; then
            echo "Probably wrong password."
        else
            echo "Probably Success."
        fi
    fi

    if [ $sleeptime ]; then 
        sleep $sleeptime
    fi
done