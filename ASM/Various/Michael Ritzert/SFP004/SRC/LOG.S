# mjr: # pml compatible lib for the atari sfp004
#
# Michael Ritzert, Oktober 1990
# ritzert@dfg.dbp.de
#
# FUNCTION:	LOG(X)
#
# base =	0xfffa50
#      the fpu addresses are taken relatively to "base":

comm =	 -6
resp =	-16
zahl =	  0

	.even
LC0:
	.ascii "log: zero argument\12\15\0"
	.even
LC1:
	.ascii "log: argument negative\12\15\0"
	.even
.globl _log
_log:
	tstl	a7@(4)
	bpl	continue
	bmi	nan
	moveml	d0-d7/a0-a6,a7@-
	pea	LC0
	jra	cconws
nan:	moveml	d0-d7/a0-a6,a7@-
	pea	LC1
cconws:
	movew	#9,a7@-
	trap	#1
	addql	#6,a7
	moveml	a7@+,d0-d7/a0-a6
#	rts				| continue to get infinity or NAN
continue:
	lea	0xfffa50,a0
	movew	#0x5414,a0@(comm)	| specify function
	cmpiw	#0x8900,a0@(resp)	| check
	movel	a7@(4),a0@		| load arg_hi
	movel	a7@(8),a0@		| load arg_low
	movew	#0x7400,a0@(comm)	| result to d0
# wait
	.long	0x0c688900, 0xfff067f8
	movel	a0@,d0
	movel	a0@,d1
	rts
