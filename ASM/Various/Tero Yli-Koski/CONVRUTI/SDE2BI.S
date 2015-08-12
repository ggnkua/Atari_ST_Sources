* signed decimal to binary conversion subroutine by Tero Yli-Koski
* a0=input decimal string, d0=output 32-bit binary number
* You can use negative numbers with - 
* but positive numbers without +
* destroy d0-d2

de2bi	moveq.l	#0,d2			DESIMAL TO BINARY
	cmp.b	#45,(a0)		if negative then d2bne
	beq	d2bne
d2bloop	move.b	(a0)+,d1
	sub.b	#$30,d1
	cmp.b	#9,d1
	bhi	done
	mulu.l	#10,d0
	add.l	d1,d0
	bra	d2bloop
done	tst.l	d2			if mark=1 then d2bne2
	bne	d2bne2
	rts				RETURN
d2bne	addq.l	#1,a0			mark=1
	moveq.l	#1,d2
	bra	d2bloop
d2bne2	neg.l	d0			negate d0
	rts				RETURN
	
