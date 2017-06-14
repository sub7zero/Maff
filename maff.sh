#!/bin/bash
SCRIPTDIR=$(dirname "$0")

PATH=$SCRIPTDIR/bin/wget-1.17-win32:$PATH
PATH=$SCRIPTDIR/bin/7z-9.20:$PATH
#-
if [[ "$1" = "" ]] || [[ "$2" = "" ]]; then
	echo "Maff 1.0, a script to save webpages in the .maff format"
	echo "by Alex Izeld, email : sub7zero@hotmail.com"
	echo ""
	echo "USAGE :"
	echo "1- maff.sh -s <output file/dir> <url>"
	echo "2- maff.sh -m <output dir> <url1> <url2> ..."
	echo "3- maff.sh -l <output dir> <list.txt> "
	echo ""
	echo "REQUIREMENTS :"
	echo "- wget >= 1.17 (included for windows)"
	echo "- 7z >= 9.20 (included for windows)"
	echo ""
	echo "NOTES :"
	echo "- running with -s returns 0 on succes & 1 on error"
	echo "- urls that didn't get saved are printed out to stderr"
	echo "- the output filename with (-l & -m) is the title of the page"
	exit
fi
#-
echoerr(){
	echo "$@" 1>&2;
}
savepage(){
	#expects $1=url $2=output
	#returns 0 on success, 1 on error
	rm -rf "$SCRIPTDIR/tmp/"*
	#-
	local url=$1
	local out=$2
	wget -q --show-progress -E -H -k -p --no-directories --directory-prefix "$SCRIPTDIR/tmp/" --restrict-file-names=windows --no-check-certificate -e robots=off "$url"
	file=$(find "$SCRIPTDIR/tmp/" -iname "*.HTML" -printf "%f\n" | head -n 1)
	title=$(cat "$SCRIPTDIR/tmp/$file" | perl -ne 'if (/<\s*title\s*>([\s\S]+)<\s*\/title\s*>/i) {print $1}')
	date=$(date -R)
	if [ "$title" = "" ]; then
		return 1
	fi
	#-
	sed "s|#DATE#|${date}|g;s|#TITLE#|${title}|g;s|#URL#|${url}|g;s|#FILE#|${file}|g" "$SCRIPTDIR/data/index.rdf" >"$SCRIPTDIR/tmp/index.rdf"
	#-
	if [[ -d $out ]]; then
		name=$(echo $title | tr -d ":" | sed "s:[<>:\"\/\\\|\?\*]::g;s:[\. ]*$::g") #convert title to a valid windows filename
		out="$out/$name.maff"
	fi
	if [[ -f $out ]]; then
		rm $out
	fi
	rand=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 32 | head -n 1)
	mkdir "$SCRIPTDIR/$rand"
	mv "$SCRIPTDIR/tmp/"* "$SCRIPTDIR/$rand"
	7za a -tzip "$out" "$SCRIPTDIR/$rand"
	ret=$?
	rm -rf "$SCRIPTDIR/$rand"
	rm -rf "$SCRIPTDIR/tmp/"*
	if [ $ret -eq 0 ]; then
	  return 0
	else
	  return 1
	fi
}
#-
if [ "$1" = "-s" ]; then
	savepage $3 $2 2>&1
	exitcode=$?
	if [ "$exitcode" == "1" ]; then
		echoerr $3
	fi
	exit $exitcode
elif [ "$1" = "-m" ]; then
	if [[ -f $2 ]]; then
		echo "Error, the output you specified appears to be a file."
		exit
	fi
	out=$2
	shift 2
	for url in "$@"
	do
		savepage $url $out 2>&1
		if [ "$?" == "1" ]; then
			echoerr $url
		fi
	done
elif [ "$1" = "-l" ]; then
	if [[ -f $2 ]]; then
		echo "Error, the output you specified appears to be a file."
		exit
	fi
	printf '%s\n' $(cat "$3") | while IFS= read -r line
	do
	   savepage $line $2 2>&1
		if [ "$?" == "1" ]; then
			echoerr $line
		fi
	done
fi
