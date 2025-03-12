#!/bin/bash
#--------------------------------------------------------------------------------------------------
# remove white spaces from a variable
#--------------------------------------------------------------------------------------------------
function trim()
{
    trimmed=$1
    trimmed=${trimmed%% }
    trimmed=${trimmed## }
    echo $trimmed
}
#--------------------------------------------------------------------------------------------------
# $1 is a mode, -build is to build target files list, -update is to check if it's needed 
# $2 is a path to the root folder
# $3 is a path to the build folder.
# $4 is a chace dir path
#--------------------------------------------------------------------------------------------------
#crawl recursively through all dirs mentioned in buildfiles file
#if file is not a directory then it's a source file
function scan_dir()
{ 	
	if [ -e "$1/buildfiles" ]; then
		echo " $1/buildfiles \\" >> "$CACHEDIR/buildcache2.mk"
		IFS=$'\n\r'
		local lines=( $(< "$1/buildfiles" ) )
		local i
		for ((i=0; i < "${#lines[@]}"; i++)); do 
			local FILENAME=$(trim "${lines[${i}]}")

			local test2=$FILENAME
			if [[ $FILENAME =~ '[a-zA-Z0-9/ .\\]+|\[[a-zA-Z0-9]+\]' ]]
			then
					echo "dupa"
					echo "$BASH_REMATCH : ${BASH_REMATCH[1]}"
			fi
			
			echo "dupa2"
 			
			
			if [ -e "$1/$FILENAME" ]; then
				if [ -d "$1/$FILENAME" ]; then
					local SAVEDIR=$(realpath "./")
					#cd "$FILENAME"
					scan_dir "$1/$FILENAME/"
					#cd "$SAVEDIR"
				else
					#rel_path=$(echo $ROOTDIR | sed -e "s/^.*$FILENAME/$FILENAME/")
					#rel_path=/$rel_path
					echo " $1/$FILENAME \\" >> "$CACHEDIR/buildcache.mk"
					#echo "$(realpath $FILENAME) \\" >> "$CACHEDIR/buildcache.mk"
				fi
			else
				rm "$CACHEDIR/buildcache2.mk"
				rm "$CACHEDIR/buildcache.mk"
				printf "\nError: folder or file doesn't exist:\n"
				echo $FILENAME
				printf "In build file:\n"
				echo "$(realpath "./")/buildfiles"
				exit -1
			fi
		done
		sleep 0.1		#WTF??
	fi
}
#--------------------------------------------------------------------------------------------------
function build_source_list()
{
	if [ -e "$CACHEDIR/buildcache.mk" ]; then
		rm "$CACHEDIR/buildcache.mk"
	fi

	if [ -e "$CACHEDIR/buildcache2.mk" ]; then
		rm "$CACHEDIR/buildcache2.mk"
	fi

	echo "FILES:= \\" >> "$CACHEDIR/buildcache.mk"
	echo "BUILDFILES:= $2/build.conf \\" >> "$CACHEDIR/buildcache2.mk"
	#cd "$ROOTDIR"
	scan_dir $1		#call scan dir
	echo "" >> "$CACHEDIR/buildcache.mk"
	echo "" >> "$CACHEDIR/buildcache2.mk"
}
#--------------------------------------------------------------------------------------------------
#ROOTDIR=$2
ROOTDIR=$(realpath $2)
#BUILDDIR=$(realpath $3)
if [ ! -d "$4" ]; then
	mkdir "$4"
fi
CACHEDIR=$(realpath $4)
	
if [ $1 == "-build" ]; then
	build_source_list $2 $3 $4
else
	echo "FATAL ERROR! UNKNOWN TASK IN BUILD HELPER!"
fi