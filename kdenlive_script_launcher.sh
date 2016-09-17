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
    tput civis
    for file in $KDENLIVE_SCRIPTS_PATH*.sh; do
	if [ $line -gt $((`tput lines` - 10)) ]; then
	    fnPrintHeader
	fi

	# Load variables from kdenlive script to get information about the project
	fnLoadFileData $file

	target=`echo $TARGET_0 | sed -e 's/^"//' -e 's/"$//' | sed -e 's/^file:\/\///'`
	txt_file=$target'.txt'
	tput cup $line 6
	echo -en "\e[0;34mProcessing "; tput bold; echo -en $TARGET_0; tput sgr0
	$file &>/dev/null &
	pid=$!
	fnIncrementLine 1
	tput cup $line 5
	echo "["
	tput cup $line 106
	echo "]"
	tput cup $((line + 2)) 5
	((total_files=total_files-1))
	echo "$total_files Files remaining"
	tput cup $line 6
	sleep 2
	percentage=`tail -1 $txt_file | cut -d: -f4 | sed -e 's/^ //' | sed -e 's/$ //'`
	while [ "$percentage" != "100" ] && kill -0 $pid 2> /dev/null; do
	    tput cup $line 0
	    tput bold; echo -en $percentage%; tput sgr0
	    tput cup $line 6
	    for i in $(seq 1 $percentage); do
		tput bold; echo -en '\e[0;32m#'; tput sgr0
	    done
	    percentage=`tail -1 $txt_file 2> /dev/null | cut -d: -f4 | sed -e 's/^ //' | sed -e 's/$ //'`
	done
	fnIncrementLine 5
    done
    tput cup $line 5
    tput bold;echo "All scripts processed"; tput sgr0
    echo ""
    echo ""
    tput dim; echo -en "Press ENTER to continue"; tput sgr0
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
