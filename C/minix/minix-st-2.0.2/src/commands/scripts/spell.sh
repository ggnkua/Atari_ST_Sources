case $# in
1)	prep $1 | sort -u | comm -23 - /usr/lib/dict/words
	;;

3)	if [ x$1 = "x-d" ]
	then if [ ! -r /usr/lib/dict/$2 ]
	     then echo The dictionary file /usr/lib/dict/$2 is not readable
		  exit
	     fi
	     prep $3 | sort -u | comm -23 - /usr/lib/dict/$2
	else echo Usagex: spell [-d dict] file
	fi
	;;

*)	echo Usage: spell [-d dict] file
	;;
esac
