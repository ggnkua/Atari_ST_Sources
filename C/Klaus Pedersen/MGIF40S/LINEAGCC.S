#NO_APP
.text
.globl	__linea0
	

__linea0:
	link	a6,#0
	moveml	a0-a2,sp@-

	.word	40960

	moveml	sp@+,a0-a2
	unlk	a6

	rts


.globl	__linea3


.text

__linea3:
	link	a6,#0
	moveml	d2/a1-a2,sp@-

	movel	a6@(8),a0

	movew	#1,a0@(24)
	movew	#1,a0@(26)
	movew	#1,a0@(28)
	movew	#1,a0@(30)
	movew	a6@(24),a0@(32)
	movew	a6@(22),a0@(34)
	movew	a6@(20),a0@(36)
	movel	a6@(12),a0@(38)
	movel	a6@(16),a0@(42)

	.word	40963

	moveml	sp@+,d2/a1-a2
	unlk	a6

	rts

