#
# INSTALL
#
# This program helped me to settle on just what programs I wanted
# in my AUTO folder.  Using this, I could quickly install several
# programs, in a particular order, and experiment with the result.

# This GULAM program, "install.g", deletes every file in "A:\AUTO"
# and the directory  "A:\AUTO"  itself.  It then re-creates the
# directory "A:\AUTO" and copies the specified files into "A:\AUTO".
# The order of programs in the directory matters, because the order
# of the "prg" files in the file access tables determines order of
# execution.  The order of copying into a new directory guarantees
# the order of the files in the directory.  The RAMDISK must be first,
# and if you start an ordinary GEM program such as one that you would
# "click on from the desk", that must be last.
#
# The variable "fnl" is the File Name List to put into the AUTO folder:

set	fnl	"	etrnl2.prg	ramdisk.dat "	# must be first
set	fnl	" $fnl	acache.prg "
set	fnl	" $fnl	idle12.prg "
set	fnl	" $fnl	autotime.prh "
set	fnl	" $fnl	biclock.prh "
set	fnl	" $fnl	autocopy.prg	autocopy.dat "
set	fnl	" $fnl	startgem.prg	startgem.inf "	# The last .PRG
set	fnl	" $fnl	install.g "		# Dont forget this file too.

echo Make sure all listed files are present.
set OK 1
foreach fName { $fnl }
	if { -f $fName } then
		# file found, no problem.
	ef
		echo Could not find the file $fName.
		set OK 0
	endif
endfor
unset fName

set magic 7890
if { $OK == 1 }
	# all well, proceed.
	echo All files found, proceed.
ef
	echo One or more file is missing.
	echo 'Enter the password (' $magic ') to proceed anyway.'
	if { $< == $magic }
		echo Right.  Proceed.
	ef
		echo This program stops.
		unset magic
		unset OK
		unset fnl
		exit
	endif
endif

set	target a:\auto
if { -f $target } then
	echo 'There is a problem:  There is a *FILE* called' $target.
	echo This program stops.
	unset target
	unset OK
	unset magic
	unset fnl
	exit
endif	

echo "Make sure $target is gone."
if { -d $target } then
	echo 'This program will remove all the files in' $target.
	if { 1 == $OK }
		#
	echo 'It will install those in' $cwd 'instead.'
	set msg 'If you want this,'
		#
	ef
		#
	set msg 'Warning!  Some of the listed replacements are not'
	echo $msg 'in this directory!.'
	set msg 'If you want to proceed anyway,'
		#
	endif	

	echo $msg 'type the magic number (' $magic ') now:'
	if { $< == $magic }
		echo Right.  Proceed.
	ef
		echo This program stops.
		unset fnl
		unset OK
		unset magic
		unset target
		unset msg
		exit
	endif

	echo pushd $target
	pushd $target
	echo Remove everything in $target
	rm *			# remove the files in A:\AUTO
	echo popd
	popd
	echo Remove the directory $target itself.
	rmdir $target
endif
unset OK
unset magic

echo Make the directory $target.

if { -d $target } then
	echo 'There is a problem:'
	echo 'We still have directory $target. This might be because:'
	echo '		there is a sub directory, or'
	echo '		the disk is write protected.'
	echo This program stops.
	unset target
	unset msg
	unset fnl
	exit
ef
	# nothing
endif

# create the directory
mkdir $target

if { -d $target } then
	# nothing
ef
	echo 'Disaster.  Unable to make directory' $target.
	echo This program stops.
	unset target
	unset msg
	unset fnl
	exit
endif

foreach fName { $fnl }
	if { -e $fName } then
		echo	cp +t $fName $target\$fName
			cp +t $fName $target\$fName
	ef
		echo Could not find the file $fName.
	endif
endfor
unset target
unset fnl

echo ' '
set fName startgem.inf
if { -e $fName } then
	echo 	cp +t $fName a:\$fName
		cp +t $fName a:\$fName
endif	
unset msg
unset fName

echo Installation complete.

