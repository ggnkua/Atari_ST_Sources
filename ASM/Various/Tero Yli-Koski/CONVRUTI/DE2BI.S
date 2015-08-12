* decimal to binary conversion subroutine by Tero Yli-Koski
* a0=input decimal string, d0=output binary number
* destroy d0 and d1

de2bi	move.b	(a0)+,d1		DESIMAL TO BINARY
	sub.b	#$30,d1
	cmp.b	#9,d1
	bhi	done
	mulu.l	#10,d0
	add.l	d1,d0
	bra	de2bi
done	rts				RETURN
	
