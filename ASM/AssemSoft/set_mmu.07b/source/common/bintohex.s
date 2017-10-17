		text
*****************************************************************************************
*BINTOHEX	Converts a binary number passed in D0 into a hexadesimal ASCII string	*
*	whose address is passed here in A0						*
*											*
*											*
*	 D0 = Binary number to convert							*
*	 A0 = Pointer to string  to contain resoulting hex ASCII string		*
*											*
*	 D1 = Lenght of the resulting ASCII string					*
*****************************************************************************************
bintohex:	movem.l	d0/a0-2,-(sp)	

		lea	.binhexsum(pc),a1	;ASCII sum buffer
		move.b	#48,(a1)		;In case the resoult is 0
		lea	.hextable(pc),a2

.binhex1:	move.l	d0,d1
		and.w	#$f,d1
		move.b	0(a2,d1.w),(a1)+
		lsr.l	#4,d0
		bne.s	.binhex1

.binhex2:	move.b	-(a1),(a0)+
		bpl.s	.binhex2
		clr.b	-1(a0)
		
		move.l	a0,d1
		sub.l	4(sp),d1		;Lenght of resulting string in D1

.exit:		movem.l	(sp)+,d0/a0-2
		rts
.hextable:	dc.b '0123456789ABCDEF'
		dc.w	255	;Do not remove this..
.binhexsum:	ds.l	2	;..or this!
