; Source for unpacking Tiny-pictures - Written by Axe of Delight
; Assemble with Devpac 2.08, Tab-position: 10
; You need source (packed tiny screen) and destination (screen address)
; for unpacking. After unpacking, the palette is saved at tinpal.

	lea	source,a0	; source
	lea	destination,a1	; destination
	bsr	tiny

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
tiny:	movem.l	d1-d6/a2-a5,-(sp)
	bsr	t_getpal		; read resolution and palette
	move.l	a4,d5
	move.l	a1,d6
	add.l	#$7d00,d6
	move.l	a1,d4
	add.l	#$a0,d4
	bra.s	t17a0a
t179be:	moveq	#0,d0
	move.b	(a5)+,d0
	beq.s	t179ce
	cmp.b	#1,d0
	beq.s	t179d6
	ext.w	d0
	bra.s	t179de
t179ce:	move.b	(a5)+,d0
	lsl.w	#8,d0
	move.b	(a5)+,d0
	bra.s	t179de
t179d6:	move.b	(a5)+,d0
	lsl.w	#8,d0
	move.b	(a5)+,d0
	neg.w	d0
t179de:	tst.w	d0
	bmi.s	t179ea
	move.b	(a4)+,d3
	lsl.w	#8,d3
	move.b	(a4)+,d3
	bra.s	t17a2e
t179ea:	neg.w	d0
	bra.s	t17a06
t179ee:	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	lea	$9e(a1),a1
	cmp.l	d6,a1
	blt.s	t17a06
	lea	$ffff8308(a1),a1
	cmp.l	d4,a1
	blt.s	t17a06
	lea	$ffffff62(a1),a1
t17a06:	dbf	d0,t179ee
t17a0a:	cmp.l	d5,a5
	blt.s	t179be
	moveq	#1,d0
t_end:	movem.l	(sp)+,d1-d6/a2-a5
	rts
t17a18:	move.w	d3,(a1)+
	lea	$9e(a1),a1
	cmp.l	d6,a1
	blt.s	t17a2e
	lea	$ffff8308(a1),a1
	cmp.l	d4,a1
	blt.s	t17a2e
	lea	$ffffff62(a1),a1
t17a2e:	dbf	d0,t17a18
	cmp.l	d5,a5
	blt.s	t179be
	moveq	#1,d0
	movem.l	(sp)+,d1-d6/a2-a5
	rts

t_getpal: cmpi.b	#2,(a0)+		; Color mode?
	ble.s	t_color
	addq.l	#4,a0
t_color:	moveq	#31,d0		; install palette
	lea	tinpal(pc),a2
t_copypal:move.b	(a0)+,(a2)+
	dbra	d0,t_copypal
	move.b	(a0)+,d1
	lsl.w	#8,d1
	move.b	(a0)+,d1
	addq.l	#2,a0
	movea.l	a0,a5		; beginning of Data
	ext.l	d1
	adda.l	d1,a0
	movea.l	a0,a4		; end of Data
	moveq	#1,d0
	rts

tinpal:	ds.w 16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


