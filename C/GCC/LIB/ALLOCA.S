#NO_APP
|
| alloca(nbytes) allocate junk in stack frame
|

	.text
|adbg1:
|	.ascii "alloca(%d)\n\0"
|adbg2:
|	.ascii "->%lx\n\0"
|	.even

.globl	_alloca
_alloca:
	movel	sp@+,d1		| get return addr
	movel	sp@,d0		| get size

|	movel	d1,sp@-		| save it
|	movel   d0,sp@-
|	pea	adbg1
|	jsr	_printf
|	addql	#4,sp		| pop the string
|	movel	sp@+,d0
|	movel	sp@+,d1

	addql	#1,d0		| ensure address even
	andl	#0xFFFFFFFE,d0	| lop off extra bits
|	addql	#8,d0		| slush -- probably not necessary

	subl	d0,sp		| increase stack frame size by that much
	movel	sp,d0		| set up to return it
	addql	#4,d0		| add 4 to point past where stack will be
				|  when we return.  effectively skips the
				|  size arg

|	movel	d1,sp@-
|	movel	d0,sp@-
|	pea	adbg2
|	jsr	_printf
|	addql	#4,sp		| pop the string
|	movel	sp@+,d0
|	movel	sp@+,d1

	movel	d1,sp@-		| push ret addr
	rts			| and go there
