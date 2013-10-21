;	String.i

atol	MACRO	adr1
	move.l	\1,-(sp)
	bsr.l	atol_rout
	addq	#4,sp
	ENDM

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

strlen	MACRO	adr1
	move.l	\1,-(sp)
	bsr.l	strlen_rout
	addq	#4,sp
	ENDM

strcmp	MACRO
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	bsr.l	strcmp_rout
	addq	#8,sp
	ENDM

	DATA

; -------------	atol

	RsReset
	rs.l	2+1
atol.1	rs.l	1

atol_rout
	movem.l	d1/a0,-(sp)
	move.l	atol.1(sp),a0
	moveq	#0,d0
	moveq	#0,d1
atol_bcl
	move.b	(a0)+,d1
	cmp.b	#"0",d1
	bmi.s	atol_stop
	cmp.b	#"9"+1,d1
	bpl.s	atol_stop
	sub.b	#"0",d1
	add.l	d1,d0
	mulu.l	#10,d0
	bra.s	atol_bcl	
atol_stop
	divu.l	#10,d0	
	movem.l	(sp)+,d1/a0
	rts

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

; -------------	strlen

	RsReset
	rs.l	1+1
strlen.adr1	rs.l	1

strlen_rout	move.l	a0,-(sp)

	move.l	strlen.adr1(sp),a0
	moveq	#0,d0
strlen_bcl	tst.b	(a0)+
	beq.s	strlen_stop
	addq	#1,d0
	bra.s	strlen_bcl
strlen_stop
	move.l	(sp)+,a0
	rts

; -------------	strcmp

	Rsreset
	rs.l	1+2
strcmp.adr1	rs.l	1
strcmp.adr2	rs.l	1

strcmp_rout	movem.l	a0-a1,-(sp)

	move.l	strcmp.adr1(sp),a0
	move.l	strcmp.adr2(sp),a1
strcmp_bcl
	move.b	(a1)+,d0
	sub.b	(a0)+,d0
	bne.s	strcmp_stop1	; different = stop
	tst.b	-1(a0)
	bne.s	strcmp_bcl	; si deux egaux … zero : stop ok
strcmp_stop0
	moveq	#0,d0
	movem.l	(sp)+,a0-a1
	rts
strcmp_stop1
	extb.l	d0
	movem.l	(sp)+,a0-a1
	rts
											