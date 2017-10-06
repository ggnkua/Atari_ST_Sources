#NO_APP
gcc_compiled.:
.text
	.even
.globl _dabs
_dabs:
	andb #127,sp@(4)
	movel sp@(4),d0
	movel sp@(8),d1
	rts
	.even
.globl _fabs
_fabs:
	andb #127,sp@(4)
	movel sp@(4),d0
	movel sp@(8),d1
	rts
