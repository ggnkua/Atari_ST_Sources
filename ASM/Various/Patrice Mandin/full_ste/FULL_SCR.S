; Hardscroll overscan STE
; DATA 29/11/92 16:47:30

	;incdir	macros
	
	TEXT

	include	macros\gemdos.s
	include	macros\xbios.s

	SETBLOCK	#pile
	tst.l	d0
	bne.s	error
	MALLOC	#96000
	move.l	d0,mem_alloc
	beq.s	error

	GETREZ
	move	d0,-(sp)
	LOGBASE
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move	#5,-(sp)
	SETSCREEN	#-1,#-1,#0
	SUPEXEC	#go
	trap	#14
	lea	12(sp),sp
	MFREE	mem_alloc

error	PTERM0		
		
go	lea	image+34,a0
	move.l	mem_alloc,a1

	move.l	#$00020000,$ffff8a20.w
	move.l	a0,$ffff8a24.w
	move.l	#$ffffffff,$ffff8a28.w
	move	#0,$ffff8a2c.w
	move.l	#$00020140,$ffff8a2e.w
	move.l	a1,$ffff8a32.w
	move.l	#$005100c8,$ffff8a36.w
	move.l	#$0203c000,$ffff8a3a.w

	lea	160(a1),a1
	move.l	#$00020000,$ffff8a20.w
	move.l	a0,$ffff8a24.w
	move.l	#$ffffffff,$ffff8a28.w
	move	#0,$ffff8a2c.w
	move.l	#$00020140,$ffff8a2e.w
	move.l	a1,$ffff8a32.w
	move.l	#$005100c8,$ffff8a36.w
	move.l	#$0203c000,$ffff8a3a.w

	lea	160(a1),a1
	move.l	#$00020000,$ffff8a20.w
	move.l	a0,$ffff8a24.w
	move.l	#$ffffffff,$ffff8a28.w
	move	#0,$ffff8a2c.w
	move.l	#$00020140,$ffff8a2e.w
	move.l	a1,$ffff8a32.w
	move.l	#$005100c8,$ffff8a36.w
	move.l	#$0203c000,$ffff8a3a.w
			
	move	#$2700,sr
	move	$ffff820a.w,-(sp)
	move.l	$70.w,-(sp)
	lea	$ffff8240.w,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(sp)
	lea	$fffffa00.w,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,-(sp)

	move.l	#vbl,$70.w
	clr.l	$fffffa06.w
	lea	$ffff8240.w,a0
	lea	image+2,a1
	moveq	#7,d0
bcl	move.l	(a1)+,(a0)+
	dbra	d0,bcl
	moveq	#0,d5
	move	#$2300,sr
		
attente	cmp.b	#$39,$fffffc02.w
	bne.s	attente
		
	move	#$2700,sr
	lea	$fffffa20.w,a0
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(a0)
	lea	$ffff8260.w,a0
	movem.l	(sp)+,d0-d7
	movem.l	d0-d7,-(a0)
	move.l	(sp)+,$70.w
	move	(sp)+,$ffff820a.w
	clr	$ffff820e.w
	clr	$ffff8264.w
	move	#$2300,sr
	
vide_kbd	btst	#0,$fffffc00.w
	beq.s	fin
	move.b	$fffffc02.w,d0
	bra.s	vide_kbd
fin	rts

vbl	lea	$ffff820a.w,a6
	clr.b	$65-$0a(a6)

	addq	#1,d5
	cmp	#640,d5
	bmi.s	continue
	sub	#640,d5
continue	move	d5,d1
	and.l	#$fff0,d1
	lsr	#1,d1
	add.l	mem_alloc,d1
	
sync	move.b	$ffff8209.w,d7
	beq.s	sync
	neg	d7
	lsl.l	d7,d7
	
	dcb.w	72-2-1-33,$4e71
	move	#198,d6	; 2

ligne	nop
	move.b	d7,(a6)	; 2
	move	a6,(a6)	; 2
	dcb.w	12,$4e71	; 12
	move	a6,$60-$0a(a6)	; 3
	move.b	d7,$60-$0a(a6)	; 3
	dcb.w	2,$4e71	; 5
	move.b	d7,$65-$0a(a6)	; 3
	movep.l	d1,$03-$0a(a6)	; 6

	move	a6,$60-$0a(a6)	; 3
	move.b	d7,$60-$0a(a6)	; 3
	move.b	d5,$65-$0a(a6)	; 3
	dcb.w	89-3-4-4,$4e71
	add.l	#3*160,d1	; 4

	dbra	d6,ligne	; 4
	move.b	d7,(a6)	; 2
	move	a6,(a6)	; 2
	dcb.w	12,$4e71
	move	a6,$60-$0a(a6)	; 3
	move.b	d7,$60-$0a(a6)	; 3

	rte

	DATA

image	incbin	beast.pi1

	BSS
	
mem_alloc	ds.l	1
	ds.l	256
pile	ds.l	1
