
; More old code ......
; Tiny Pictures De-Compaction Code !
; Palette saved in 'tinpal' after de-pack
; Code	  : Axe of Delight
; Other messing around by Tony -B-
; Tabs	  : 10


	section	text
call:	macro
	move.w	#\1,-(sp)		; Lazy macro call to save me
	trap	#\2		; typing in a couple of lines
	lea	\3(sp),sp		; & it saves me a few bytes..!!
	endm
	
	pea	0
	call	$20,1,6		; Supervisor mode
	move.l	d0,oldssp		; Store value
	
	call	4,14,2		; Get screen resolution
	move.w	d0,rez		; Store value for exit
	move.w	#0,-(sp)		; Set screen resolution
	move.l	$44e.w,-(sp)
	move.l	$44e.w,-(sp)
	call	5,14,12
	
	move.b	#4,$484.w		; Turn off key clicks/repeats etc..
	pea	off(pc)		; lose mouse
	clr.w	-(sp)
	call	$19,14,8

	lea	picture,a0	; source picture address
	lea	$66000,a1		; destination address -background
	bsr	tiny		; de-pack
	
	movem.l	tinpal,d0-d7
	movem.l	d0-d7,$ffff8240.w	; set palette
	
q_draw:	move.w	#1000,d0
	move.l	$44e.w,a2		; actual screen
.qdraw:	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+	; quick draw onto logical
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	dbra	d0,.qdraw

scan:	cmpi.b	#$1,$fffffc02.w	; wait for ESC
	beq.s	exit
	bra.s	scan

* and now we exit...
exit:	pea	gempal(pc)
	call	6,14,6
	pea	on(pc)
	clr.w	-(sp)		; mousey on
	call	$19,14,8
	move.b	#-1,$484.w	; Restore console vectors
	move.w	rez(pc),-(sp)	; Back to old resolution
	move.l	$44e.w,-(sp)
	move.l	$44e.w,-(sp)
	call	5,14,12
	move.l	oldssp(pc),-(sp)
	call	$20,1,6		; User mode
	pea	0
	call	$4c,1		; Function 'P_Term'


; the de-packing code !
tiny:	movem.l	d1-d6/a2-a5,-(sp)
	bsr	t_getpal		; read resolution and palette
	move.l	a4,d5
	move.l	a1,d6
	addi.l	#$7d00,d6
	move.l	a1,d4
	addi.l	#$a0,d4
	bra.s	t17a0a
t179be:	moveq	#0,d0
	move.b	(a5)+,d0
	beq.s	t179ce
	cmpi.b	#1,d0
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
	cmpa.l	d6,a1
	blt.s	t17a06
	lea	$ffff8308(a1),a1
	cmp.l	d4,a1
	blt.s	t17a06
	lea	$ffffff62(a1),a1
t17a06:	dbra	d0,t179ee
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
t17a2e:	dbra	d0,t17a18
	cmpa.l	d5,a5
	blt.s	t179be
	moveq	#1,d0
	movem.l	(sp)+,d1-d6/a2-a5
	rts

; find out resolution and palette
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


*	Constants & values	*
	section	bss
oldssp:	ds.l	1
rez:	ds.w	1
tinpal:	ds.w	16

	section	data
off:	even
	dc.b	$12,0
on:	dc.b	$8,0
gempal:	even	; 4th color = $770 for low res. !
	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000
	even
picture:	incbin	a:\tiny\union.tn4
	even
