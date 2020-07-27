
# CPSETUP, copy some files, if necessary.

# ------------- Variables used ---------------
# list 	The list of file names to be copied.
# fn	One file name from the list
# src 	The Path and File Name of the source file.
# tgt 	The Path and File Name of the target file.
# warn	A warning message.
# ------------- The List ---------------
set	list	" $list arc.ttp "
set	list	" $list diff.prg "
set	list	" $list gu.prg "
set	list	" $list gulam.g "
set	list	" $list gulamend.g "
set	list	" $list head.prg "
set	list	" $list more14.ttp "
set	list	" $list lv.tos "
set	list	" $list uud.ttp "
set	list	" $list uue.ttp "
set	list	" $list vol.ttp "
# ------------- The Loop ---------------
set warn 'Warning, not found: '
foreach fn { $list }
	set src a:\$fn		# the Source directory
	set tgt d:\$fn		# the Target directory
	if { -e $tgt }
		# echo 'found:' $tgt
	ef { -e $src }
		echo ' copy:' $src
		cp $src $tgt
	ef
		echo '		' $warn $src
	endif
endfor
# ------------- Tidy up ---------------
unset src 
unset tgt 
unset list 
unset warn
unset fn
# ------------- The End ---------------
