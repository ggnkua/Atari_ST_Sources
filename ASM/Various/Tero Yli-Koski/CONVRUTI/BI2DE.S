* binary to desimal conversion subroutine by Tero Yli-Koski
* a0=output decimal string address, d0=input 32-bit unsigned binary number
* Not works with 68000
* destroy d0-d2

bi2de	moveq.l	#0,d2			BINARY TO DESIMAL
	move.w	#0,-(sp)
b2dloop	moveq.l	#0,d1
	addq.l	#1,d2
	divul.l	#10,d1:d0
	add.b	#$30,d1
	move.b	d1,-(sp)
	tst.l	d0
	bne	b2dloop
b2dloo2	move.b	(sp)+,(a0)+		
	dbeq	d2,b2dloo2
	rts				RETURN
