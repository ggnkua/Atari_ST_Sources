#NO_APP
gcc_compiled.:
.text
	.even
LC0:
	.double 0r1.00000000000000000000e+00
	.even
LC1:
	.double 0r-1.00000000000000000000e+00
	.even
.globl _main
_main:
	link a6,#0
	movel LC0+4,sp@-
	movel LC0,sp@-
	jbsr _exit
	movel LC1+4,sp@-
	movel LC1,sp@-
	jbsr _exit
L1:
	unlk a6
	rts
