
;- test shell --------------------------------------------------------------

	ifnd	DEMO_SYSTEM
testmode:=	0
	include	tester.s
	text
	endc

;- plugin table ------------------------------------------------------------

	dc.l	mainloop
	dc.l	init
	dc.l	rt_init
	dc.l	deinit
	dc.l	set_fader_downer
	dc.l	set_mouse_fader_upper
	dc.l	0

;- plugin routines ---------------------------------------------------------

init:
	move.l	#piccy,piccy_adr
	move.l	#mousepic,mousepic_adr

	movea.l	piccy_adr,a1
	addq	#2,a1
	lea	fade_pal_table,a2
	bsr	calc_faded_palettes
	movea.l	mousepic_adr,a1
	addq	#2,a1
	lea	mouse_fade_pal_table,a2
	bsr	calc_faded_palettes

	rts

rt_init:
	cmpi.w	#falcon,computer
	beq.s	.no_shifter_kick
	move.l	#overscan_vbl_stable,palirq
	move.l	#fader_upper,faderout
	bra.s	.end_shifter_kick

.no_shifter_kick:
	move.l	#fader_upper,palirq

	cmpi.w	#rgb50,monitormode
	beq.s	.rgb
; 320x240 vga60
	MOVE.L	#$041903F3,$FFFF82A2.W
	MOVE.L	#$003F003F,$FFFF82A6.W
	MOVE.L	#$04150415,$FFFF82AA.W
	bra.s	.end_shifter_kick
; 320x240 rgb50
.rgb:	move.l	#$02710265,$ffff82a2.w
	move.l	#$00570057,$ffff82a6.w
	move.l	#$0235026b,$ffff82aa.w

.end_shifter_kick:

	movea.l	scr,a0
	movea.l	piccy_adr,a1
	lea	34(a1),a1
	move.w	#320*240/8-1,d7
.loop:	move.l	(a1)+,(a0)+
	dbf	d7,.loop

	rts

deinit:	bsr	reset_res
	move.l	#dummy,palirq
	rts

mainloop:
	ifeq	testmode
;	move.w	#$00F0,$FFFF8240.w

	move.l	scr,d0
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	endc

	move.w	$0468.w,d0
.vbl	cmp.w	$0468.w,d0
	beq.s	.vbl

	rts

;--------------------------------------------------------------------------

set_fader_downer:
	cmpi.w	#falcon,computer
	beq.s	.falcon
	move.l	#fader_downer,faderout
	rts
.falcon:move.l	#fader_downer,palirq
	rts

set_mouse_fader_upper:
	bsr	reset_res

	movea.l	scr,a0
	movea.l	mousepic_adr,a1
	lea	34(a1),a1
	move.w	#320*200/8-1,d7
.loop:	move.l	(a1)+,(a0)+
	dbf	d7,.loop

	move.l	#mouse_fader_upper,palirq
	rts

reset_res:
	cmpi.w	#falcon,computer
	bne.s	.st

	move.w	$468.w,d0
.wait:	cmp.w	$468.w,d0
	beq.s	.wait

	cmpi.w	#rgb50,monitormode
	beq.s	.rgb
; 320x200 vga60
	MOVE.L	#$41903B9,$FFFF82A2.W
	MOVE.L	#$61008D,$FFFF82A6.W
	MOVE.L	#$3AD0415,$FFFF82AA.W
	bra.s	.end_shifter_kick
; 320x200 rgb50
.rgb:   MOVE.L   #$02710265,$FFFF82A2.W
        MOVE.L   #$001F006F,$FFFF82A6.W
        MOVE.L   #$01FF026B,$FFFF82AA.W
.end_shifter_kick:
	rts
.st:	move.l	#dummy,palirq
	rts

; calculate some blackfaded versions of the palette..
; input:
; a1: src palette
; a2: dst fade buffer
calc_faded_palettes:

; 1: extract (ste) palette to easy format.
	lea	.pal_tbl(pc),a0
	moveq	#16-1,d7

.preloop:
	move.w	(a1)+,d0
	move.w	d0,d1
	move.w	d0,d2
	move.w	d0,d3
	move.w	d0,d4
	move.w	d0,d5

	andi.w	#$0700,d0
	lsr.w	#7,d0
	rol.w	#5,d3
	andi.w	#$0001,d3
	or.w	d3,d0

	andi.w	#$0070,d1
	lsr.w	#3,d1
	rol.b	#1,d4
	andi.w	#$0001,d4
	or.w	d4,d1
	
	andi.w	#$0007,d2
	add.w	d2,d2
	rol.b	#5,d5
	andi.w	#$0001,d5
	or.w	d5,d2

	move.b	d0,(a0)+
	move.b	d1,(a0)+
	move.b	d2,(a0)+

	dbf	d7,.preloop

; 2: make faded versions..
	movea.l	a2,a0
	moveq	#16-1,d7

.lowloop:
	lea	.pal_tbl(pc),a1
	moveq	#16-1,d6

.lowentryloop:
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2

; do the actual fade..
	move.b	(a1)+,d0
	sub.b	d7,d0
	bpl.s	.r_ok
	moveq	#0,d0
.r_ok:	move.b	(a1)+,d1
	sub.b	d7,d1
	bpl.s	.g_ok
	moveq	#0,d1
.g_ok:	move.b	(a1)+,d2
	sub.b	d7,d2
	bpl.s	.b_ok
	moveq	#0,d2
.b_ok:

; Put in rorred format, weird STe crap..
	lsr.w	d0
	bcc.s	.rok
	addq.w	#8,d0
.rok:	lsr.w	d1
	bcc.s	.gok
	addq.w	#8,d1
.gok:	lsr.w	d2
	bcc.s	.bok
	addq.w	#8,d2
.bok:	

; Pack rgb, and store..
	lsl.w	#8,d0
	lsl.w	#4,d1
	or.w	d0,d2
	or.w	d1,d2
	move.w	d2,(a0)+
	dbf	d6,.lowentryloop

	dbf	d7,.lowloop
	rts

.pal_tbl:
	ds.b	3*16

fader_upper:
	lea	$FFFF8240.w,a0
	lea	fade_pal_table,a1
	move.w	fadepos(pc),d0
	lsl.w	#4+1,d0
	movem.l	(a1,d0.w),d0-d7
	movem.l	d0-d7,(a0)

	move.w	fadepos(pc),d0
	addq.w	#1,d0
	cmpi.w	#16,d0
	bge.s	.end
	move.w	d0,fadepos
.end:	rts

fadepos:dc.w	0

fader_downer:
	lea	$FFFF8240.w,a0
	lea	fade_pal_table,a1
	move.w	fadepos(pc),d0
	lsl.w	#4+1,d0
	movem.l	(a1,d0.w),d0-d7
	movem.l	d0-d7,(a0)

	move.w	fadepos(pc),d0
	subq.w	#1,d0
	bmi.s	.end
	move.w	d0,fadepos
.end:	rts

mouse_fader_upper:
	lea	$FFFF8240.w,a0
	lea	mouse_fade_pal_table,a1
	move.w	.fadepos(pc),d0
	lsl.w	#4+1,d0
	movem.l	(a1,d0.w),d0-d7
	movem.l	d0-d7,(a0)

	move.w	.fadepos(pc),d0
	addq.w	#1,d0
	cmpi.w	#16,d0
	bge.s	.end
	move.w	d0,.fadepos
.end:	rts

.fadepos:
	dc.w	0

;--------------------------------------------------------------------------

overscan_vbl_stable:
	move.b	#2,$FFFF820A.w				; 50 Hz

	clr.b	$fffffa1b.w

	move.b	#150,$fffffa21.w

	move.b	#8,$fffffa1b.w
	move.l	#overscan_hbl_stable,$120.w
	bset	#0,$fffffa07.w
	bset	#0,$fffffa13.w

	movea.l	faderout,a0
	jmp	(a0)

; maxymiser stabilised version of lower border rout..
; really silly, i'd better hack the player, but who cares..
overscan_hbl_stable:
	move	#$2700,sr
	movem.l	d0/d1,-(sp)

	; debug color
	;move.w	#$FFF,$FFFF8240.w

.sync:	cmpi.b	#101,$FFFFFA21.w
	bne.s	.sync

	move.b	$FFFFFA21.w,d0
.sync2:	cmp.b	$FFFFFA21.w,d0
	beq.s	.sync2
	rept	2
	or.l	d0,d0
	or.l	d0,d0
	or.l	d0,d0
	bchg	#1,$FFFF820A.w
	endr

	; debug color
	;move.w	#$000,$FFFF8240.w

; disable timer B when lower border has been removed..
	bclr	#0,$fffffa07.w
	bclr	#0,$fffffa13.w

	movem.l	(sp)+,d0/d1
	move	#$2300,sr
	rte

;--------------------------------------------------------------------------

	data

	ifnd	DEMO_SYSTEM
piccy:	incbin	lemon.pi1
mousepic:
	incbin	mouse18.pi1
	endc

faderout:
	dc.l	fader_upper

	bss

;--------------------------------------------------------------------------

piccy_adr:
	ds.l	1
mousepic_adr:
	ds.l	1
fade_pal_table:
	ds.w	16*16
mouse_fade_pal_table:
	ds.w	16*16
