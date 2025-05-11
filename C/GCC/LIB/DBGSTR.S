|
| debug code: dbgstr(str);
|
.text
	.even
.globl	_dbgstr
_dbgstr:
	link	a6,#0		| nothing in frame
	movel	a2,sp@-		| save a2
	movel	a3,sp@-		| save a3
	movel	a6@(8),a3	| get str ptr
dbg1:
	moveb	a3@+,d0		| get a byte
	beq	dbg9
	andl	#255,d0
	movew	d0,sp@-		| push a byte
	movew	#2,sp@-		| push dev 2
	movew	#3,sp@-		| push Bconout
	trap	#13
	addl	#6,sp
	bra	dbg1
dbg9:
	movel	sp@+,a3		| get a3 back
	movel	sp@+,a2		| get a2 back
	unlk	a6
	rts
|
| that's all.

