#
# this setjmp adapted from the DLIBS one by jrd
#
.text
.globl _setjmp
_setjmp:
	movel	sp@(4),a0		| address of jmp_buf[]
	movel	sp,a0@+			| save stack pointer
	movel	a6,a0@+			| save frame pointer
	movel	sp@,a0@+		| save return address
	moveml	#0x3CFC,a0@		| save registers d2-d7/a2-a5
	clrl	d0			| return value is 0
	rts

.globl _longjmp
_longjmp:
	movel	sp@(4),a0		| address of jmp_buf[]
	movel	sp@(8),d0		| value to return
	movel	a0@+,sp			| restore stack pointer
	movel	a0@+,a6			| restore frame pointer
	movel	a0@+,sp@		| restore return address
	moveml	a0@,#0x3CFC		| restore registers d2-d7/a2-a5
	rts
