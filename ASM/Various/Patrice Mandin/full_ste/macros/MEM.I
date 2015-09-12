;	Fonctions standards

memset	MACRO	adresse,valeur,taille
	move	\3,-(sp)
	move	\2,-(sp)
	move.l	\1,-(sp)
	bsr.l	memset_rout
	addq.l	#8,sp
	ENDM

movedata	MACRO	srcseg,srcoff,dstseg,dstoff,size
	ENDM

memcpy	MACRO	source,dest,taille
	move.l	\3,-(sp)
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	bsr.l	memcpy_rout
	lea	12(sp),sp
	ENDM
	
	DATA

; -------------	memset

	RsReset
	rs.l	4
memset.1	rs.l	1
memset.2	rs.w	1
memset.3	rs.w	1
	
memset_rout	movem.l	d0-d1/a0,-(sp)
	move.l	memset.1(sp),a0
	move	memset.2(sp),d0
	move	memset.3(sp),d1

	subq	#1,d1
memset_bcl	move.b	d0,(a0)+
	dbra	d1,memset_bcl

	movem.l	(sp)+,d0-d1/a0
	rts

; -------------	memcpy

	RsReset
	rs.l	4
memcpy.1	rs.l	1
memcpy.2	rs.l	1
memcpy.3	rs.l	1

memcpy_rout	movem.l	d0/a0-a1,-(sp)
	move.l	memset.1(sp),a0
	move.l	memset.2(sp),a1
	move.l	memset.3(sp),d0

	subq.l	#1,d0
memcpy_bcl	move.b	(a0)+,(a1)+
	dbra	d0,memcpy_bcl

	movem.l	(sp)+,d0/a0-a1
	rts