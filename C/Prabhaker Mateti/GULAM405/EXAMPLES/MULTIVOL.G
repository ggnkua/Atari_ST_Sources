#
# MULTIVOL
#
# syntax:
#	multivol volname sequence_number
#
# What it does:
# For each of several floppies,
#	select a Volume Id. containing the index number,
#	FORMAT the floppy,
#	create a file whose name is the index number,
#	write the Volume Id.

# A prompt for
set prpt1 ' Please press the RETURN key. '
set ginprompt ' Begin processing floppy diskettes.'
# echo "Begin processing floppy diskettes.  Enter any positive integer to quit."

# Collect the arguments ------------------------------------------------------
	set arg1 $1
	set arg2 $2
	set arg3 $3
	set arg4 $4

# Check arguments ------------------------------------------------------------
set argc 0
foreach xx { $- }
	set argc $argc + 1
endfor
unset xx

if { $argc < 2 }
		echo 'The syntax for the MULTIVOL command is:'
		echo '	'
		echo '	' multivol volname sequence_number
		echo '	'
		echo 'Need at least two arguments.'
		echo
		unset argc
		unset prpt1
		unset ginprompt
		unset arg1
		unset arg2
		unset arg3
		unset arg4
		exit
endif

if { $arg2 == 0 }
	echo 'Do you really want to start with index number of zero?'
	set magic 7890
	set ginprompt " If yes, enter $magic, the magic number: "
	set xx $<
	set ginprompt " $prpt1 "
	if { $xx == $magic }
		unset xx
		unset magic
		# nothing
	ef
		echo Quit.
		unset xx
		unset magic
		unset ginprompt
		unset arg1
		unset arg2
		unset arg3
		unset arg4
		unset argc
		unset prpt1
		exit
	endif
endif

# Set parameters for the loop ------------------------------------------------
set	V_name $arg1	# Name to use for volume id
set	Starter	$arg2	# The first sequence number to use

if { $argc < 3 }	# How many diskettes to do.
	set hi_lim 10		
ef
	set hi_lim $arg3
endif

if { 0 == $hi_lim }
	echo 'Ok, just did 0 diskettes.  Quit'
	unset arg3
	unset arg2
	unset arg1
	unset V_name
	unset Starter
	unset ginprompt
	unset arg1
	unset arg2
	unset arg3
	unset arg4
	unset argc
	unset prpt1
	exit
endif
	
# echo "Begin processing floppy diskettes.  Enter any positive integer to quit."
set count 0
# The main loop ----------------------------------------------------------
while { $count < $hi_lim }

	# echo ' '
	
	if { 0 == $count }
	ef
		echo 'Remove disk number' $Index_Num.
	endif
	
	set	Index_Num	$Starter + $count
	set	Vol_Id		$V_name.$Index_Num
	set	to_go		$hi_lim - $count
	set	msg		"$count done, $to_go to go."
	
	echo 'Insert disk number' $Index_Num. '  (' $msg ')'
	
	# read the keybd.
	set ginprompt '(Enter any non-zero number to abort.)'
	set xx $<
	set c1 $count + 1
	if { $c1 == $hi_lim }
		set ginprompt " Done.  Press return. "
	ef
		set ginprompt " $prpt1 "
	endif
	if { 0 == $xx } then
		unset xx
		
		# format the disk
		echo '1	format -2 a:'	# No. of sides, which drive.
		#	format -2 a:
		
		# Make a file with the number as its name.
		echo '2	echo	' "	$Vol_Id > a:\$Index_Num "
		#	echo		$Vol_Id > a:\$Index_Num
		
		# Make the "disktop" file.
		echo '3	echo	' "	$Vol_Id > a:\disktop.inf"
		#	echo		$Vol_Id > a:\disktop.inf
		
		# Write the Volume Id.
		echo '4	vol a' "	$Vol_Id"
		#	vol a		$Vol_Id
		
		# Tell user something
		echo '5	vol a'
			vol a	
		
		# echo ' '
	ef
		unset xx
		set count 1 + $hi_lim  	# make it too big, to quit
		set ginprompt '   DONE.  press return. '
	endif
	set count 1 + $count
endwhile

# echo "Done"

unset ginprompt
unset V_name
unset Index_Num
unset hi_lim
unset Vol_Id
unset Starter
unset to_go
unset msg
unset argc
unset arg1
unset arg2
unset arg3
unset arg4
unset argc
unset prpt1
unset count
unset c1
exit
