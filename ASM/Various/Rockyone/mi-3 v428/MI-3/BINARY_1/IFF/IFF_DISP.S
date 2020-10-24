* rockyone			pour MI_3			28.10.2020
*
*
*
*
*
*
*	Call iff_display( L buffer_palette )
*
*
*-------------------------------------------------------------------------


	movem.l	d0-d7/a0-a6,-(sp)
	lea.l	pal_buffer(pc),a5
	move.l	64(sp),(a5)


	move.b	#2,$FFFF820A.l			; 60 Hz
	lea.l	NeoMaster(pc),a0
	move.l	a0,$4CE.w			; VBL
	movem.l	(sp)+,d0-d7/a0-a6
	rts

NeoMaster:
	move.w	SR,-(sp)
	ori.w	#$700,SR
	
	move.l	pal_buffer(pc),a3
	lea.l	$FF8240.l,a4
	lea.l	$FF8209.l,a5
	lea.l	blc(pc),a6
	
	move.l	#198,d7

	movea.l	a4,a1			; Palette de couleur
	movem.l (a3)+,d0-d6/a2		; pour la premiŠre ligne
	movem.l	d0-d6/a2,(a1)		; de l'ecran.

	moveq.l	#0,d0
*	move.w	d0,(a4)


wait:	tst.b	(a5)
	beq.s	wait
	move.b	(a5),d0
	adda.l	d0,a6
	jmp	(a6)

blc:	nop	; 1
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 10
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 20
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 30
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 40
	nop	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 50
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 60
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 70
	nop
	nop
	nop	
	nop	; 74
palettes:
	movea.l	a4,a1
	movem.l (a3)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)

	nop	; 1
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 10
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 20
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 30
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 40
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 50
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 60
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 70
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 80
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 87
	dbra.w	d7,palettes

*	movea.l	a4,a1
*	movem.l (a3)+,d0-d6/a2
*	movem.l	d0-d6/a2,(a1)


	move.w	#$0,(a4)		; bordure inf‚rieur couleur noir

	move.w	(sp)+,SR
	rts

*L005		dc.l	$0
pal_buffer:	dc.l	$0

	end
