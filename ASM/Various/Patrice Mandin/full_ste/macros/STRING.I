;	String.i

strcpy	MACRO	adr1,adr2
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	bsr.l	strcpy_rout
	addq	#8,sp
	
	ENDM

strcat	MACRO	adr1,adr2
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	bsr.l	strcat_rout
	addq	#8,sp
	ENDM

	DATA

; -------------	strcat
	
	RsReset
	rs.l	3+1
strcat.1	rs.l	1
strcat.2	rs.l	1
	
strcat_rout	movem.l	d0/a0-a1,-(sp)
	move.l	strcat.1(sp),a0
	move.l	strcat.2(sp),a1

	; Se positionner sur le 0 dans la chaine a0
strcat_bcl	
	tst.b	(a0)+
	bne.s	strcat_bcl
	subq.l	#1,a0
	
	; Recopier a1 dans a0

strcat_cpy	move.b	(a1)+,d0
	beq.s	strcat_stop
	move.b	d0,(a0)+
	bra.s	strcat_cpy

strcat_stop	clr.b	(a0)

	movem.l	(sp)+,d0/a0-a1
	rts

; -------------	strcpy

	RsReset
	rs.l	1+3
strcpy.adr1	rs.l	1
strcpy.adr2	rs.l	1

strcpy_rout	movem.l	d0/a0-a1,-(sp)

	move.l	strcpy.adr1(sp),a0
	move.l	strcpy.adr2(sp),a1

strcpy_bcl	move.b	(a1)+,d0
	beq.s	strcpy_stop
	move.b	d0,(a0)+
	bra.s	strcpy_bcl
strcpy_stop	clr.b	(a0)

	movem.l	(sp)+,d0/a0-a1
	rts