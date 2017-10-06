* GEM definitions
* by James Ingram, May 1994


print	macro

	move.l	#\1,a0
	bsr	print_line
	endm

wait_key	macro
	bsr	conin_no_echo
	endm

