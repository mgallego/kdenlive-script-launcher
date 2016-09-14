#!/bin/bash
# http://www.thegeekstuff.com/2011/01/tput-command-examples/
# https://www.gnu.org/software/termutils/manual/termutils-2.0/html_chapter/tput_1.html
# http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/x405.html

fnInitializeLine()
{
    line=2
}

fnIncrementLine()
{
    inc=$1
    ((line=line+inc))
}

fnPrintHeader()
{
    tput reset
    fnInitializeLine
    tput cup $line 46
    tput bold; echo -en "SCRIPT LAUNCHER"; tput sgr0
    fnIncrementLine 3
}

fnShowMenu()
{
    fnPrintHeader
    tput cup $line 5
    echo "Available actions:"
    fnIncrementLine 3
    tput cup $line 5
    tput bold;echo -en "1)"; tput sgr0; echo " Launch all scripts"
    fnIncrementLine 1
    tput cup $line 5
    tput bold;echo -en "2)"; tput sgr0; echo " Script Status"
    fnIncrementLine 2
    tput cup $line 5
    tput bold;echo -en "q)"; tput sgr0; echo " Quit"
    fnIncrementLine 2
    tput cup $line 5
    echo -en "Action: "
    read action
    fnExecAction $action
}

fnExecAction()
{
    case "$1" in
	"1")
	    fnProcessScripts
	    ;;
	"2")
	    fnProcessScripts
	    ;;
	"q"|"Q")
	    tput reset
	    ;;
	*)
	    fnShowMenu
	    ;;
	esac
}

fnLoadFileData()
{
    file=$1
    eval $(sed '/=/!d;/^ *#/d;s/=/ /;' < "$file" | while read -r key val
    	do
    	    str="$key='$val'"
    	    echo "$str"
    	      done)
}

fnProcessScripts()
{
    fnPrintHeader
    total_files=`ls $KDENLIVE_SCRIPTS_PATH*.sh | wc -l`
    for file in $KDENLIVE_SCRIPTS_PATH*.sh; do
	if [ $line -gt $((`tput lines` - 10)) ]; then
	    fnPrintHeader
	fi

	# Load variables from kdenlive script to get information about the project
	fnLoadFileData $file
	tput cup $line 6
	echo -en "\e[0;34mProcessing "; tput bold; echo -en $file; tput sgr0
	fnIncrementLine 1
	tput cup $line 5
	echo "["
	tput cup $line 106
	echo "]"
	tput cup $((line + 2)) 5
	((total_files=total_files-1))
	echo "$total_files Files remaining"
	tput cup $line 6
	for i in $(seq 1 100); do
	    tput sc
	    tput cup $line 0
	    tput bold; echo -en $i%; tput sgr0
	    tput rc
	    # sleep 0.006
	    tput bold; echo -en '\e[0;32m#'; tput sgr0
	done
	fnIncrementLine 5
    done
    tput cup $line 5
    tput bold;echo "All scripts processed"; tput sgr0
    echo ""
    echo ""
    tput dim; echo -en "Press ENTER to continue"; tput sgr0
    tput civis
    stty_orig=`stty -g`; stty -echo
    read key
    stty $stty_orig
    tput cnorm
    fnShowMenu
}

fnMain(){
    fnLoadFileData "./kdenlive_script_launcher.conf"
    fnShowMenu
}

fnMain
