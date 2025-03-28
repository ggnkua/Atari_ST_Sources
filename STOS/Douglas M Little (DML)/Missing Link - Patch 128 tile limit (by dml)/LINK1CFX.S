
	COMMENT		HEAD=0
	OPT		P=68000,NOTYPE
	OPT		S-
	OPT		W+
	OPT		O-

	text


enable_fixes	=	1

START:
	dc.l	PARA-START
	dc.l	DATA-START
	dc.l	FN_START-START


cat_next	macro
	dc.w	\1-\2
	endm

	
CATALOG:
	cat_next	FN_overlap,FN_landscape
	cat_next	FN_bob,FN_overlap
	cat_next	FN_map_toggle,FN_bob
	cat_next	FN_wipe,FN_map_toggle
	cat_next	FN_boundary,FN_wipe
	cat_next	FN_tile,FN_boundary
	cat_next	FN_palt,FN_tile
	cat_next	FN_world,FN_palt
	cat_next	FN_musato,FN_world
	cat_next	FN_musplay,FN_musato
	cat_next	FN_which_block,FN_musplay
	cat_next	FN_relocate,FN_which_block
	cat_next	FN_p_left,FN_relocate
	cat_next	FN_p_on,FN_p_left
	cat_next	FN_p_joy,FN_p_on
	cat_next	FN_p_stop,FN_p_joy
	cat_next	FN_p_up,FN_p_stop
	cat_next	FN_set_block,FN_p_up
	cat_next	FN_p_right,FN_set_block
	cat_next	FN_palsplit,FN_p_right
	cat_next	FN_p_down,FN_palsplit
	cat_next	FN_floodpal,FN_p_down
	cat_next	FN_p_fire,FN_floodpal
	cat_next	FN_digi_play,FN_p_fire
	cat_next	FN_string,FN_digi_play
	cat_next	FN_samsign,FN_string
	cat_next	FN_depack,FN_samsign
	cat_next	FN_replace_blocks,FN_depack
	cat_next	FN_dload,FN_replace_blocks
	cat_next	FN_display_pc1,FN_dload
	cat_next	FN_dsave,FN_display_pc1
	;
	cat_next	FN_END,FN_dsave


;	dc.b	$02,$f8,$00,'N'
;	dc.b	$0b,$90,$00,'R',$02,$04,$00,$0a
;	dc.b	$03,$b0,$00,'p',$06,'f',$03,$e4
;	dc.b	$00,$a2,$00,'l',$00,'J',$00,$1a
;	dc.b	$00,'Z',$00,$1a,$00,'F',$00,$1a
;	dc.b	$00,'T',$00,$1a,$02,'`',$00,$1a
;	dc.b	$00,':',$00,$1a,$09,$f8,$00,'@'
;	dc.b	$00,$10,$10,' ',$00,'F',$00,'^'
;	dc.b	$00,$aa,$00,$d8

PARA:
	dc.w	32	; number of library routines
	dc.w	32	; number of extension commands
	
; todo: tidy this up...

	dc.b	$00,'D',$00,'S',$00,'f',$00,'u'
	dc.b	$00,'z',$00,$7f,$00,$84,$00,$91
	dc.b	$00,$96,$00,$a5,$00,$ae,$00,$b7
	dc.b	$00,$c0,$00,$c5,$00,$ca,$00,$ce
	dc.b	$00,$d3,$00,$d7,$00,$dc,$00,$e7
	dc.b	$00,$ec,$00,$f9,$00,$fe,$01,$03
	dc.b	$01,$08,$01,$15,$01,$1a,$01,'!'
	dc.b	$01,'&',$01,'/',$01,':',$01,'A'
	dc.b	$00,$00,',',$00,',',$00,',',$00
	dc.b	',',$00,',',$00,$01,$01,$00,$00
	dc.b	$00,',',$00,',',$00,',',$00,','
	dc.b	$00,',',$00,',',$00,',',$00,$01
	dc.b	$01,$00,$00,$00,',',$00,',',$00
	dc.b	',',$00,',',$00,',',$00,$01,$01
	dc.b	$00,$00,$00,$01,$01,$00,$00,$00
	dc.b	$01,$01,$00,$00,$00,$01,$01,$00
	dc.b	$00,$00,',',$00,',',$00,',',$00
	dc.b	',',$00,$01,$01,$00,$00,$00,$01
	dc.b	$01,$00,$00,$00,',',$00,',',$00
	dc.b	',',$00,',',$00,',',$00,$01,$01
	dc.b	$00,$00,$00,',',$00,',',$00,$01
	dc.b	$01,$00,$00,$00,',',$00,',',$00
	dc.b	$01,$01,$00,$00,$00,',',$00,','
	dc.b	$00,$01,$01,$00,$00,$00,$01,$01
	dc.b	$00,$00,$00,$01,$01,$00,$00,$01
	dc.b	$01,$00,$00,$00,$01,$01,$00,$00
	dc.b	$01,$01,$00,$00,$00,$01,$01,$00
	dc.b	$00,$00,',',$00,',',$00,',',$00
	dc.b	$01,$01,$00,$00,$00,$01,$01,$00
	dc.b	$00,$00,',',$00,',',$00,',',$00
	dc.b	',',$00,$01,$01,$00,$00,$00,$01
	dc.b	$01,$00,$00,$00,$01,$01,$00,$00
	dc.b	$00,$01,$01,$00,$00,$00,',',$00
	dc.b	',',$00,',',$00,',',$00,$01,$01
	dc.b	$00,$00,$00,$01,$01,$00,$00,$00
	dc.b	',',$00,$01,$01,$00,$00,$00,$01
	dc.b	$01,$00,$00,$00,',',$00,',',$00
	dc.b	$01,$01,$00,$00,$00,',',$00,','
	dc.b	$00,',',$00,$01,$01,$00,$00,$00
	move.l	d0,d6
	btst	d0,d1
	ori.b	#$2c,d0
	ori.b	#$2c,1(a4)
	btst	d0,d0

DATA:
	bra	COLDST


COLDST:
	lea	END(pc),a2
	rts

END:
	rts

; -----------------------------------------------------------------------------
FN_START:
; -----------------------------------------------------------------------------

; LIB

; -----------------------------------------------------------------------------
FN_landscape:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movem.l	a0-a5,-(a7)
	move.l	(a6)+,d0
	tst.w	d0
	bne	l000b
	move.l	(a6)+,d7
	move.l	(a6)+,d6
	movea.l	(a6)+,a1
	movea.l	(a6)+,a2
	movea.l	(a6)+,a0
	move.l	a6,-(a7)
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	movea.l	d1,a3
	movea.l	d1,a4
	movea.l	d1,a5
	movea.l	d1,a6
	tst.w	d0
	bne	l000b
	cmpi.l	#$3031973,(a1)+
	bne	l000a
	cmpi.l	#$18e7074c,(a2)+
	bne	l000a
	lea	36(a2),a2
	moveq	#0,d0
	lea	l0014(pc),a3
	adda.w	(a3)+,a0
	move.w	(a3)+,d3
	move.w	(a3),d2
	movem.w	(a1)+,d4-d5
	addq.w	#2,d4
	lea	l0016(pc),a3
	move.w	d4,(a3)
	lsr.w	#1,d5
	subq.w	#1,d5
	subq.w	#1,d5
	sub.w	d2,d5
	lsl.w	#4,d5
	cmp.w	d5,d7
	ble.s	l0002
	move.w	d5,d7
l0002:
	tst.w	d7
	bge.s	l0003
	moveq	#0,d7
l0003:
	lsr.w	#4,d6
	add.w	d6,d6
	adda.w	d6,a1
	move.w	d7,d6
	andi.w	#$f,d7
	lsl.w	#3,d7
	lsr.w	#4,d6
	mulu	d4,d6
	adda.w	d6,a1
	movea.l	a2,a6
	move.w	d2,d0
	move.w	d7,d6
	move.w	d3,d1
	lea	-8(a0),a4

	ifne	(enable_fixes)
	moveq	#0,d4			; dml	
	endc

; todo: this bit can be optimized

l0004:
	movea.l	a6,a2
	adda.w	d7,a2

	ifne	(enable_fixes)
	move.w	(a1)+,d4		; dml	
	add.l	d4,a2
	else
	adda.w	(a1)+,a2
	endc
	
	lea	l0005(pc,d7.w),a3

	lea	8(a4),a4
	movea.l	a4,a0
	jmp	(a3)
l0005:
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2),(a0)+
	dbf	d1,l0004

	ifne	(enable_fixes)
	moveq	#$13,d4			; dml
	else
	move.w	#$13,d4
	endc

	sub.w	d3,d4
	lsl.w	#3,d4
	adda.w	d4,a0
	lea	l0016(pc),a4
	move.w	(a4),d4
	sub.w	d3,d4
	sub.w	d3,d4
	subq.w	#2,d4
	adda.w	d4,a1

	ifne	(enable_fixes)
	moveq	#0,d1			; dml
	endc
	
l0006:
	movea.l	a0,a5
	movea.l	a0,a4
	move.w	d3,d7
l0007:
	movea.l	a6,a2

	ifne	(enable_fixes)
	move.w	(a1)+,d1		; dml
	add.l	d1,a2
	else
	adda.w	(a1)+,a2
	endc
	
	movea.l	a4,a0
	lea	8(a4),a4
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2),(a0)
	dbf	d7,l0007
	lea	2560(a5),a0
	adda.w	d4,a1
	dbf	d0,l0006

	ifne	(enable_fixes)
	moveq	#$78,d7			; dml
	else
	move.w	#$78,d7
	endc
	
	sub.w	d6,d7
	move.w	d3,d1

	ifne	(enable_fixes)
	lea	l0009(pc,d7.w),a3	; dml
	endc

l0008:
	movea.l	a6,a2

	ifne	(enable_fixes)
	move.w	(a1)+,d7		; dml
	add.l	d7,a2
	else
	adda.w	(a1)+,a2
	lea	l0009(pc,d7.w),a3
	endc

	movea.l	a0,a4
	jmp	(a3)
l0009:
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)
	lea	156(a0),a0
	move.l	(a2)+,(a0)+
	move.l	(a2),(a0)
	nop
	nop
	lea	8(a4),a0
	dbf	d1,l0008
l000a:
	movea.l	(a7)+,a6
	movem.l	(a7)+,a0-a5
	rts

l000b:
	lea	4(a6),a6
	move.l	(a6)+,d3
	move.l	(a6)+,d2
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	tst.w	d0
	bge.s	l000c
	moveq	#0,d0
l000c:
	cmpi.w	#$130,d0
	ble.s	l000d
	move.w	#$130,d0
l000d:
	tst.w	d1
	bge.s	l000e
	moveq	#0,d1
l000e:
	cmpi.w	#$b8,d1
	ble.s	l000f
	move.w	#$b8,d1
l000f:
	sub.w	d1,d3
	sub.w	d0,d2
	lsr.w	#4,d3
	lsr.w	#4,d2
	andi.w	#$fff0,d0
	lsr.w	#1,d0
	mulu	#$a0,d1
	add.w	d1,d0
	lea	l0014(pc),a0
	move.w	d0,(a0)
	move.w	d2,d0
	move.w	d3,d1
	subq.w	#1,d0
	subq.w	#2,d1
	tst.w	d0
	bge.s	l0010
	moveq	#0,d0
l0010:
	tst.w	d1
	bge.s	l0011
	moveq	#0,d1
l0011:
	cmpi.w	#$13,d0
	ble.s	l0012
	moveq	#$13,d0
l0012:
	cmpi.w	#$a,d1
	ble.s	l0013
	moveq	#$a,d1
l0013:
	lea	l0015(pc),a0
	move.w	d0,(a0)+
	move.w	d1,(a0)
	movem.l	(a7)+,a0-a5
	rts

l0014:
	dc.w	0
l0015:
	dc.b	$00,$13,$00,$0a
l0016:
	dc.w	0

; LIB
	
; -----------------------------------------------------------------------------
FN_overlap:	
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movem.l	a0/d5-d7,-(a7)
	move.l	(a6)+,d7
	move.l	(a6)+,d6
	move.l	(a6)+,d5
	move.l	(a6)+,d4
	move.l	(a6)+,d3
	move.l	(a6)+,d2
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	movea.w	d0,a0
	adda.w	d4,a0
	cmpa.w	d2,a0
	blt.s	l0017
	movea.w	d2,a0
	adda.w	d6,a0
	cmp.w	a0,d0
	bge.s	l0017
	movea.w	d1,a0
	adda.w	d5,a0
	cmpa.w	d3,a0
	blt.s	l0017
	movea.w	d3,a0
	adda.w	d7,a0
	cmp.w	a0,d1
	bge.s	l0017
	move.l	#$ffffffff,-(a6)
	movem.l	(a7)+,a0/d5-d7
	rts

l0017:
	move.l	#0,-(a6)
	movem.l	(a7)+,a0/d5-d7
	rts

; -----------------------------------------------------------------------------
FN_bob: ; no lib calls
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movem.l	a0-a5,-(a7)
	move.l	(a6)+,d6
	cmpi.w	#1,d6
	beq	l005a
	move.l	(a6)+,d2
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	movea.l	(a6)+,a1
	movea.l	(a6)+,a0
	move.l	a6,-(a7)
	moveq	#0,d3
	move.l	d3,d4
	move.l	d3,d5
	move.l	d3,d7
	movea.l	d3,a2
	movea.l	d3,a3
	movea.l	d3,a4
	movea.l	d3,a5
	movea.l	d3,a6
l0018:
	cmpi.w	#$ffc0,d1
	blt	l005f
l0019:
	cmpi.w	#$140,d1
	bge	l005f
l001a:
	cmpi.w	#$ffc0,d2
	blt	l005f
l001b:
	cmpi.w	#$c8,d2
	bge	l005f
	cmpi.l	#$38964820,(a1)
	bne	l005f
	move.w	4(a1),d7
	cmp.w	d7,d0
	bge	l005f
	lsl.w	#2,d0
	lea	38(a1,d0.w),a2
	adda.l	(a2),a1
	move.w	(a1)+,d4
	move.w	(a1)+,d7
	moveq	#$10,d5
	move.w	(a1)+,d3
	lsr.w	d3,d5
	move.w	d1,d3
	andi.w	#$f,d3
	divu	d5,d3
	move.w	d3,d0
	mulu	(a1)+,d3
	movea.w	(a1)+,a5
	tst.w	d0
	beq.s	l001c
	sub.w	a5,d3
	bra.s	l001d
l001c:
	subi.w	#$10,d4
	tst.w	d4
	bge.s	l001d
	moveq	#0,d4
l001d:
	adda.l	d3,a1
	cmpi.w	#$63,d6
	bne.s	l001e
	lsr.w	#4,d4
	move.w	d4,d5
	bra	l0057
l001e:
	move.w	#0,d5
	sub.w	d7,d5
	lea	l0022(pc),a2
	move.w	d5,2(a2)
	lea	l0026(pc),a2
	move.w	d7,2(a2)
l001f:
	move.w	#$c7,d5
	sub.w	d7,d5
	lea	l0027(pc),a2
	move.w	d5,2(a2)
	lea	l0028(pc),a2
	move.w	d5,2(a2)
l0020:
	cmpi.w	#$c7,d2
	blt.s	l0021
	bra	l005f
l0021:
	cmpi.w	#0,d2
	bge.s	l0027
l0022:
	cmpi.w	#$fff0,d2
	bgt.s	l0023
	bra	l005f
l0023:
	move.w	#0,d7
	sub.w	d2,d7
	tst.w	d7
	bge.s	l0024
	neg.w	d7
l0024:
	move.w	d7,d2
	lsl.w	#3,d2
	add.w	d7,d2
	add.w	d7,d2
	add.w	d7,d2
	add.w	d7,d2
	adda.w	d2,a1
l0025:
	move.w	#0,d2
l0026:
	move.w	#$10,d6
	sub.w	d7,d6
	move.w	d6,d7
	bra.s	l0029
l0027:
	cmpi.w	#$b8,d2
	ble.s	l0029
	move.l	d2,d6
l0028:
	subi.w	#$b8,d6
	sub.w	d6,d7
l0029:
	lsr.w	#3,d4
	lea	.jtab(pc),a2
	adda.w	0(a2,d4.w),a2
	jmp	(a2)
.jtab:
;	dc.b	$01,$94,$01,'d',$01,$1a,$00,$a4
;	dc.b	$00,$0a
	dc.w	l0055-.jtab	; jt[0]
	dc.w	l004f-.jtab	; jt[1]
	dc.w	l0046-.jtab	; jt[2]
	dc.w	l003a-.jtab	; jt[3]
	dc.w	l002b-.jtab	; jt[4]

l002b:
	cmpi.w	#0,d1
	bge.s	l0034
l002c:
	cmpi.w	#$fff0,d1
	blt.s	l002e
	adda.w	a5,a1
	moveq	#3,d5
l002d:
	move.w	#0,d1
	bra	l0057
l002e:
	cmpi.w	#$ffe0,d1
	blt.s	l0030
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#2,d5
l002f:
	move.w	#0,d1
	bra	l0057
l0030:
	cmpi.w	#$ffd0,d1
	blt.s	l0032
	adda.w	a5,a1
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#1,d5
l0031:
	move.w	#0,d1
	bra	l0057
l0032:
	cmpi.w	#$ffc0,d1
	ble	l005f
	adda.w	a5,a1
	adda.w	a5,a1
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#0,d5
l0033:
	move.w	#0,d1
	bra	l0057
l0034:
	cmpi.w	#$140,d1
	bge	l005f
l0035:
	cmpi.w	#$130,d1
	blt.s	l0036
	moveq	#0,d5
	bra	l0057
l0036:
	cmpi.w	#$120,d1
	blt.s	l0037
	moveq	#1,d5
	bra	l0057
l0037:
	cmpi.w	#$110,d1
	blt.s	l0038
	moveq	#2,d5
	bra	l0057
l0038:
	cmpi.w	#$100,d1
	blt.s	l0039
	moveq	#3,d5
	bra	l0057
l0039:
	moveq	#4,d5
	bra	l0057

; jt[3]
l003a:
	cmpi.w	#0,d1
	bge.s	l0041

l003b:
	cmpi.w	#$fff0,d1
	blt.s	l003d
	adda.w	a5,a1
	moveq	#2,d5
l003c:
	move.w	#0,d1
	bra	l0057
l003d:
	cmpi.w	#$ffe0,d1
	blt.s	l003f
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#1,d5
l003e:
	move.w	#0,d1
	bra	l0057
l003f:
	cmpi.w	#$ffd0,d1
	blt	l005f
	adda.w	a5,a1
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#0,d5
l0040:
	move.w	#0,d1
	bra	l0057
l0041:
	cmpi.w	#$140,d1
	bge	l005f
l0042:
	cmpi.w	#$130,d1
	blt.s	l0043
	moveq	#0,d5
	bra	l0057
l0043:
	cmpi.w	#$120,d1
	blt.s	l0044
	moveq	#1,d5
	bra	l0057
l0044:
	cmpi.w	#$110,d1
	blt.s	l0045
	moveq	#2,d5
	bra	l0057
l0045:
	moveq	#3,d5
	bra	l0057

; jt[2]
l0046:
	cmpi.w	#0,d1
	bge.s	l004b
l0047:
	cmpi.w	#$fff0,d1
	blt.s	l0049
	adda.w	a5,a1
	moveq	#1,d5
l0048:
	move.w	#0,d1
	bra.s	l0057
l0049:
	cmpi.w	#$ffe0,d1
	ble	l005f
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#0,d5
l004a:
	move.w	#0,d1
	bra.s	l0057
l004b:
	cmpi.w	#$140,d1
	bge	l005f
l004c:
	cmpi.w	#$130,d1
	blt.s	l004d
	moveq	#0,d5
	bra.s	l0057
l004d:
	cmpi.w	#$120,d1
	blt.s	l004e
	moveq	#1,d5
	bra.s	l0057
l004e:
	moveq	#2,d5
	bra.s	l0057
; jt[1]
l004f:
	cmpi.w	#0,d1
	bge.s	l0052
l0050:
	cmpi.w	#$fff0,d1
	blt	l005f
	adda.w	a5,a1
	moveq	#0,d5
l0051:
	move.w	#0,d1
	bra.s	l0057
l0052:
	cmpi.w	#$140,d1
	blt.s	l0053
	bra	l005f
l0053:
	cmpi.w	#$130,d1
	blt.s	l0054
	moveq	#0,d5
	bra.s	l0057
l0054:
	moveq	#1,d5
	bra.s	l0057

; jt[0]
l0055:
	cmpi.w	#0,d1
	blt	l005f
l0056:
	cmpi.w	#$140,d1
	bge	l005f
	moveq	#0,d5
l0057:
	andi.w	#$fff0,d1
	lsr.w	#1,d1
	add.w	d2,d2
	lea	local_scanline_table1(pc),a2
	adda.w	d2,a2
	adda.w	(a2),a0
	adda.w	d1,a0
	moveq	#$40,d6
	sub.w	d7,d6
	move.w	d6,d7
	lsl.w	#4,d6
	add.w	d7,d6
	add.w	d7,d6
	add.w	d7,d6
	add.w	d7,d6
	movea.l	a0,a2
	movea.l	a1,a3

	ifne	(enable_fixes)
	lea	l0059(pc,d6.w),a4
	endc
l0058:

	ifne	(enable_fixes)
	else
	lea	l0059(pc,d6.w),a4
	endc
	
	jmp	(a4)
l0059:
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	move.l	(a1)+,d0
	move.l	d0,d1
	and.l	(a0),d0
	or.l	(a1)+,d0
	move.l	d0,(a0)+
	and.l	(a0),d1
	or.l	(a1)+,d1
	move.l	d1,(a0)
	lea	156(a0),a0
	addq.w	#8,a2
	movea.l	a2,a0
	adda.w	a5,a3
	movea.l	a3,a1
	dbf	d5,l0058

	bra	l005f

l005a:
	lea	4(a6),a6
	move.l	(a6)+,d3
	move.l	(a6)+,d2
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	move.l	a6,-(a7)
	cmpi.w	#0,d0
	bge.s	l005b
	moveq	#0,d0
l005b:
	cmpi.w	#$140,d2
	ble.s	l005c
	move.w	#$140,d2
l005c:
	cmpi.w	#0,d1
	bge.s	l005d
	moveq	#0,d1
l005d:
	cmpi.w	#$c8,d3
	ble.s	l005e
	move.w	#$c8,d3
l005e:
	andi.w	#$fff0,d0
	andi.w	#$fff0,d2
	lea	l0021(pc),a0
	move.w	d1,2(a0)
	lea	l0025(pc),a0
	move.w	d1,2(a0)
	lea	l0023(pc),a0
	move.w	d1,2(a0)
	lea	l001e(pc),a0
	move.w	d1,2(a0)
	subi.w	#$40,d1
	lea	l001a(pc),a0
	move.w	d1,2(a0)
	lea	l0020(pc),a0
	move.w	d3,2(a0)
	lea	l001f(pc),a0
	move.w	d3,2(a0)
	lea	l001b(pc),a0
	move.w	d3,2(a0)
	lea	l004f(pc),a0
	move.w	d0,2(a0)
	lea	l0055(pc),a0
	move.w	d0,2(a0)
	lea	l0046(pc),a0
	move.w	d0,2(a0)
	lea	l0048(pc),a0
	move.w	d0,2(a0)
	lea	l004a(pc),a0
	move.w	d0,2(a0)
	lea	l0051(pc),a0
	move.w	d0,2(a0)
	lea	l003a(pc),a0
	move.w	d0,2(a0)
	lea	l003c(pc),a0
	move.w	d0,2(a0)
	lea	l003e(pc),a0
	move.w	d0,2(a0)
	lea	l0040(pc),a0
	move.w	d0,2(a0)
	lea	l002b(pc),a0
	move.w	d0,2(a0)
	lea	l002d(pc),a0
	move.w	d0,2(a0)
	lea	l002f(pc),a0
	move.w	d0,2(a0)
	lea	l0031(pc),a0
	move.w	d0,2(a0)
	lea	l0033(pc),a0
	move.w	d0,2(a0)
	subi.w	#$10,d0
	lea	l0050(pc),a0
	move.w	d0,2(a0)
	lea	l0047(pc),a0
	move.w	d0,2(a0)
	lea	l003b(pc),a0
	move.w	d0,2(a0)
	lea	l002c(pc),a0
	move.w	d0,2(a0)
	subi.w	#$10,d0
	lea	l0049(pc),a0
	move.w	d0,2(a0)
	lea	l003d(pc),a0
	move.w	d0,2(a0)
	lea	l002e(pc),a0
	move.w	d0,2(a0)
	subi.w	#$10,d0
	lea	l003f(pc),a0
	move.w	d0,2(a0)
	lea	l0030(pc),a0
	move.w	d0,2(a0)
	subi.w	#$10,d0
	lea	l0032(pc),a0
	lea	l0018(pc),a0
	move.w	d0,2(a0)
	lea	l0052(pc),a0
	move.w	d2,2(a0)
	lea	l004b(pc),a0
	move.w	d2,2(a0)
	lea	l0041(pc),a0
	move.w	d2,2(a0)
	lea	l0056(pc),a0
	move.w	d2,2(a0)
	lea	l0034(pc),a0
	move.w	d2,2(a0)
	lea	l0019(pc),a0
	move.w	d2,2(a0)
	subi.w	#$10,d2
	lea	l0053(pc),a0
	move.w	d2,2(a0)
	lea	l004c(pc),a0
	move.w	d2,2(a0)
	lea	l0042(pc),a0
	move.w	d2,2(a0)
	lea	l0035(pc),a0
	move.w	d2,2(a0)
	subi.w	#$10,d2
	lea	l004d(pc),a0
	move.w	d2,2(a0)
	lea	l0043(pc),a0
	move.w	d2,2(a0)
	lea	l0036(pc),a0
	move.w	d2,2(a0)
	subi.w	#$10,d2
	lea	l0044(pc),a0
	move.w	d2,2(a0)
	lea	l0037(pc),a0
	move.w	d2,2(a0)
	subi.w	#$10,d2
	lea	l0038(pc),a0
	move.w	d2,2(a0)
l005f:
	movea.l	(a7)+,a6
	movem.l	(a7)+,a0-a5
	rts

local_scanline_table1:
	dc.b	$00,$00,$00,$a0,$01,'@',$01,$e0
	dc.b	$02,$80,$03,' ',$03,$c0,$04,'`'
	dc.b	$05,$00,$05,$a0,$06,'@',$06,$e0
	dc.b	$07,$80,$08,' ',$08,$c0,$09,'`'
	dc.b	$0a,$00,$0a,$a0,$0b,'@',$0b,$e0
	dc.b	$0c,$80,$0d,' ',$0d,$c0,$0e,'`'
	dc.b	$0f,$00,$0f,$a0,$10,'@',$10,$e0
	dc.b	$11,$80,$12,' ',$12,$c0,$13,'`'
	dc.b	$14,$00,$14,$a0,$15,'@',$15,$e0
	dc.b	$16,$80,$17,' ',$17,$c0,$18,'`'
	dc.b	$19,$00,$19,$a0,$1a,'@',$1a,$e0
	dc.b	$1b,$80,$1c,' ',$1c,$c0,$1d,'`'
	dc.b	$1e,$00,$1e,$a0,$1f,'@',$1f,$e0
	dc.b	' ',$80,'! !',$c0,'"`'
	dc.b	'#',$00,'#',$a0,'$@$',$e0
	dc.b	'%',$80,'& &',$c0,$27,'`'
	dc.b	'(',$00,'(',$a0,')@)',$e0
	dc.b	'*',$80,'+ +',$c0,',`'
	dc.b	'-',$00,'-',$a0,'.@.',$e0
	dc.b	'/',$80,'0 0',$c0,'1`'
	dc.b	'2',$00,'2',$a0,'3@3',$e0
	dc.b	'4',$80,'5 5',$c0,'6`'
	dc.b	'7',$00,'7',$a0,'8@8',$e0
	dc.b	'9',$80,': :',$c0,';`'
	dc.b	'<',$00,'<',$a0,'=@=',$e0
	dc.b	'>',$80,'? ?',$c0,'@`'
	dc.b	'A',$00,'A',$a0,'B@B',$e0
	dc.b	'C',$80,'D D',$c0,'E`'
	dc.b	'F',$00,'F',$a0,'G@G',$e0
	dc.b	'H',$80,'I I',$c0,'J`'
	dc.b	'K',$00,'K',$a0,'L@L',$e0
	dc.b	'M',$80,'N N',$c0,'O`'
	dc.b	'P',$00,'P',$a0,'Q@Q',$e0
	dc.b	'R',$80,'S S',$c0,'T`'
	dc.b	'U',$00,'U',$a0,'V@V',$e0
	dc.b	'W',$80,'X X',$c0,'Y`'
	dc.b	'Z',$00,'Z',$a0,'[@[',$e0
	dc.b	'\',$80,'] ]',$c0,'^`'
	dc.b	'_',$00,'_',$a0,'`@`',$e0
	dc.b	'a',$80,'b b',$c0,'c`'
	dc.b	'd',$00,'d',$a0,'e@e',$e0
	dc.b	'f',$80,'g g',$c0,'h`'
	dc.b	'i',$00,'i',$a0,'j@j',$e0
	dc.b	'k',$80,'l l',$c0,'m`'
	dc.b	'n',$00,'n',$a0,'o@o',$e0
	dc.b	'p',$80,'q q',$c0,'r`'
	dc.b	's',$00,'s',$a0,'t@t',$e0
	dc.b	'u',$80,'v v',$c0,'w`'
	dc.b	'x',$00,'x',$a0,'y@y',$e0
	dc.b	'z',$80,'{ {',$c0,'|`'
	
; -----------------------------------------------------------------------------
FN_map_toggle:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	a0,-(a7)
	movea.l	(a6)+,a0
	cmpi.l	#$3031973,(a0)
	bne.s	l0062
	moveq	#7,d4
	moveq	#8,d5
	move.l	#$2528e54,(a0)+
	bra.s	l0063
l0062:
	cmpi.l	#$2528e54,(a0)
	bne.s	l0065
	moveq	#8,d4
	moveq	#7,d5
	move.l	#$3031973,(a0)+
l0063:
	moveq	#0,d2
	movem.w	(a0)+,d2-d3
	addq.w	#2,d2
	lsr.w	#1,d2
	lsr.w	#1,d3
	mulu	d3,d2
	subq.w	#1,d2
l0064:
	move.w	(a0),d3
	lsr.w	d4,d3
	lsl.w	d5,d3
	move.w	d3,(a0)+
	dbf	d2,l0064
l0065:
	movea.l	(a7)+,a0
	move.l	#0,(a6)
	rts

; -----------------------------------------------------------------------------
FN_wipe:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movem.l	a0-a6,-(a7)
	movea.l	(a6)+,a5
	lea	32000(a5),a6
	moveq	#0,d1
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,d7
	movea.l	d1,a0
	movea.l	d1,a1
	movea.l	d1,a2
	movea.l	d1,a3
	movea.l	d1,a4
	movea.l	d1,a5
	moveq	#5,d0
l0066:
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	dbf	d0,l0066
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	a0-a5/d1-d7,-(a6)
	movem.l	d1-d5,-(a6)
	movem.l	(a7)+,a0-a6
	addq.w	#4,a6
	rts

; -----------------------------------------------------------------------------
FN_boundary:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
; todo: disassemble manually
;	dc.b $02,'n',$ff,$f0,$00,$02
	and.w	#-16,2(a6)
	rts

; -----------------------------------------------------------------------------
FN_tile:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d2
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	movea.l	(a6)+,a1
	movea.l	(a6)+,a0
	movem.l	a1-a6,-(a7)
	cmpi.l	#$3d2067,(a1)+
	bne	l0069
	move.w	(a1)+,d3
	cmp.w	d3,d0
	bne.s	l0067
	move.w	d3,d0
l0067:
	andi.w	#$f,d1
	andi.w	#$f,d2
	moveq	#$c,d3
	lsl.w	d3,d0
	lsl.w	#8,d1
	lsl.w	#3,d2
	add.w	d1,d0
	add.w	d2,d0
	lea	32(a1,d0.w),a1
	lea	32000(a0),a0
	movea.l	a1,a6
	moveq	#$b,d7
l0068:
	movea.l	a6,a1
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	dbf	d7,l0068
	movea.l	a6,a1
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	(a1)+,d0-d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d0,d6
	movea.l	d1,a2
	movea.l	d0,a3
	movea.l	d1,a4
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
	movem.l	a2-a4/d0-d6,-(a0)
l0069:
	movem.l	(a7)+,a1-a6
	rts

; -----------------------------------------------------------------------------
FN_palt:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movea.l	(a6),a0
	cmpi.l	#$19861987,(a0)
	beq.s	l006e
	cmpi.l	#$3d2067,(a0)
	bne.s	l006a
	moveq	#6,d1
	bra.s	l0070
l006a:
	cmpi.l	#$7793868,(a0)
	bne.s	l006b
	moveq	#8,d1
	bra.s	l0070
l006b:
	cmpi.l	#$18e7074c,(a0)
	bne.s	l006c
	moveq	#8,d1
	bra.s	l0070
l006c:
	cmpi.l	#$38964820,(a0)
	bne.s	l006d
	move.w	#6,d1
	bra.s	l0070
l006d:
	move.l	#0,(a6)
	rts

l006e:
	move.l	#$1f3ff,d0
	moveq	#4,d1
l006f:
	cmpi.l	#$50414c54,(a0)
	beq.s	l0070
	lea	2(a0),a0
	dbf	d0,l006f
	move.l	#0,(a6)
	rts

l0070:
	adda.l	d1,a0
	move.l	a0,$45a.w
	move.l	a0,(a6)
	rts

; -----------------------------------------------------------------------------
FN_world:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
; todo: disassemble manually
;	dc.b 'Jžf',$00,$04,'R'
	tst.l	(a6)+
	bne	l0080
	
	movem.l	a0-a5,-(a7)
	move.l	(a6)+,d3
	move.l	(a6)+,d2
	movea.l	(a6)+,a2
	movea.l	(a6)+,a1
	movea.l	(a6)+,a0
	move.l	a6,-(a7)
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	tst.w	d7
	bne	l0080
	cmpi.l	#$7793868,(a1)+
	bne	l007f
	cmpi.l	#$2528e54,(a2)+
	bne	l007f
	tst.w	d2
	bge.s	l0071
	moveq	#0,d2
l0071:
	tst.w	d3
	bge.s	l0072
	moveq	#0,d3
l0072:
	move.w	(a2)+,d0
	lea	l008a(pc),a5
	move.w	d0,(a5)
	move.w	(a2)+,d1
	subq.w	#2,d1
	lsr.w	#1,d0
	lsr.w	#1,d1
	lea	l0089(pc),a5
	sub.w	(a5)+,d0
	sub.w	(a5),d1
	lsl.w	#4,d0
	lsl.w	#4,d1
	cmp.w	d0,d2
	ble.s	l0073
	move.w	d0,d2
l0073:
	cmp.w	d1,d3
	ble.s	l0074
	move.w	d1,d3
l0074:
	movem.w	l0089(pc),d0-d1
	moveq	#$10,d5
	move.w	(a1)+,d6
	lsr.w	d6,d5
	move.w	d2,d6
	andi.w	#$f,d6
	divu	d5,d6
	mulu	(a1)+,d6
	lea	32(a1,d6.l),a3
	lea	128(a3),a1
	andi.w	#$fff0,d2
	lsr.w	#3,d2
	adda.w	d2,a2
	move.w	d3,d2
	andi.w	#$f,d3
	lea	l008b(pc),a5
	move.w	d3,(a5)
	lsr.w	#4,d2
	tst.w	d2
	bge.s	l0075
	moveq	#0,d2
	bra.s	l0076
l0075:
	move.w	l008a(pc),d6
	addq.w	#2,d6
	mulu	d6,d2
l0076:
	adda.l	d2,a2
	moveq	#0,d5
	move.l	d5,d6
	adda.w	l008c(pc),a0
	moveq	#0,d7
	move.l	a0,-(a7)
	move.l	a2,-(a7)
	move.w	d3,d7
	lsl.w	#3,d7
	move.w	d7,d2
	add.w	d7,d7
	move.w	d3,d4
	add.w	d4,d4
	lea	local_scanline_table2(pc),a5
	adda.w	d4,a5
	move.w	#$960,d6
	sub.w	(a5),d6
	neg.w	d6		; ?????

	ifne	(enable_fixes)
	lea	l0078(pc,d7.w),a4		; dml
	endc
	
l0077:
	movea.l	a1,a5
	adda.w	d2,a5
	movea.l	a3,a6
	adda.w	d2,a6

	ifne	(enable_fixes)
	move.w	(a2)+,d7			; dml
	add.l	d7,a5
	move.w	(a2),d7
	add.l	d7,a6
	else
	adda.w	(a2)+,a5
	adda.w	(a2),a6
	lea	l0078(pc,d7.w),a4
	endc

	jmp	(a4)
l0078:
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6),d4-d5
	or.l	(a5)+,d4
	or.l	(a5),d5
	movem.l	d4-d5,(a0)
	lea	8(a0,d6.w),a0
	dbf	d0,l0077

	subq.w	#1,d1
	movea.l	(a7)+,a2
	lea	2(a2),a2
	neg.w	d6
	movea.l	(a7)+,a0
	adda.w	d6,a0
	lea	160(a0),a0
	adda.w	l008a(pc),a2
	tst.w	d1
	bge.s	l0079
	movem.w	l0089(pc),d0-d1
	bra	l007c
l0079:
	move.w	l0089(pc),d0
	movea.l	a0,a4
	move.l	a0,-(a7)
	move.w	d1,-(a7)
l007a:
	move.w	(a7),d1
	move.l	a2,-(a7)
l007b:
	movea.l	a1,a5
	movea.l	a3,a6

	ifne	(enable_fixes)
	moveq	#0,d2			; dml
	move.w	(a2)+,d2
	add.l	d2,a5
	move.w	(a2),d2
	add.l	d2,a6
	else
	adda.w	(a2)+,a5
	adda.w	(a2),a6
	endc

	movem.l	(a6)+,d2-d7
	or.l	(a5)+,d2
	or.l	(a5)+,d3
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	or.l	(a5)+,d6
	or.l	(a5)+,d7
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,160(a0)
	movem.l	d6-d7,320(a0)
	lea	480(a0),a0
	movem.l	(a6)+,d2-d7
	or.l	(a5)+,d2
	or.l	(a5)+,d3
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	or.l	(a5)+,d6
	or.l	(a5)+,d7
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,160(a0)
	movem.l	d6-d7,320(a0)
	lea	480(a0),a0
	movem.l	(a6)+,d2-d7
	or.l	(a5)+,d2
	or.l	(a5)+,d3
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	or.l	(a5)+,d6
	or.l	(a5)+,d7
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,160(a0)
	movem.l	d6-d7,320(a0)
	lea	480(a0),a0
	movem.l	(a6)+,d2-d7
	or.l	(a5)+,d2
	or.l	(a5)+,d3
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	or.l	(a5)+,d6
	or.l	(a5)+,d7
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,160(a0)
	movem.l	d6-d7,320(a0)
	lea	480(a0),a0
	movem.l	(a6)+,d2-d7
	or.l	(a5)+,d2
	or.l	(a5)+,d3
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	or.l	(a5)+,d6
	or.l	(a5)+,d7
	movem.l	d2-d3,(a0)
	movem.l	d4-d5,160(a0)
	movem.l	d6-d7,320(a0)
	lea	480(a0),a0
	movem.l	(a6),d2-d3
	or.l	(a5)+,d2
	or.l	(a5),d3
	movem.l	d2-d3,(a0)
	lea	160(a0),a0
	adda.w	l008a(pc),a2
	dbf	d1,l007b

	lea	8(a4),a4
	movea.l	a4,a0
	movea.l	(a7)+,a2
	addq.w	#2,a2
	dbf	d0,l007a
	addq.w	#2,a7
	movea.l	(a7)+,a0
	movem.w	l0089(pc),d0-d1
	lsl.w	#1,d0
	suba.l	d0,a2
	subq.w	#2,a2
	lsr.w	#1,d0
	moveq	#0,d7
	move.w	l008a(pc),d7
	addq.w	#2,d7
	mulu	d1,d7
	adda.w	d7,a2
	lsl.w	#5,d1
	lea	local_scanline_table2(pc),a5
	adda.w	d1,a5
	adda.w	(a5),a0
l007c:
	move.w	l008b(pc),d1
	tst.w	d1
	beq	l007f
	moveq	#$f,d7
	sub.w	d1,d7
	lsl.w	#4,d7

	ifne	(enable_fixes)
	lea	l007e(pc,d7.w),a4		; dml
	endc

l007d:
	lea	128(a3),a5

	ifne	(enable_fixes)
	move.w	(a2)+,d7			; dml
	add.l	d7,a5
	move.l	a3,a6
	move.w	(a2),d7
	add.l	d7,a6
	else
	adda.w	(a2)+,a5
	movea.l	a3,a6
	adda.w	(a2),a6
	lea	l007e(pc,d7.w),a4
	endc

	movea.l	a0,a1
	jmp	(a4)
l007e:
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6)+,d4-d5
	or.l	(a5)+,d4
	or.l	(a5)+,d5
	movem.l	d4-d5,(a0)
	lea	160(a0),a0
	movem.l	(a6),d4-d5
	or.l	(a5)+,d4
	or.l	(a5),d5
	movem.l	d4-d5,(a0)
	lea	8(a1),a0
	dbf	d0,l007d
l007f:
	movea.l	(a7)+,a6
	movem.l	(a7)+,a0-a5
	rts

l0080:
	lea	4(a6),a6
	move.l	(a6)+,d3
	move.l	(a6)+,d2
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	move.l	a0,-(a7)
	tst.w	d0
	bge.s	l0081
	moveq	#0,d0
l0081:
	cmpi.w	#$130,d0
	ble.s	l0082
	move.w	#$130,d0
l0082:
	tst.w	d1
	bge.s	l0083
	moveq	#0,d1
l0083:
	cmpi.w	#$b8,d1
	ble.s	l0084
	move.w	#$b8,d1
l0084:
	sub.w	d1,d3
	sub.w	d0,d2
	lsr.w	#4,d3
	lsr.w	#4,d2
	andi.w	#$fff0,d0
	lsr.w	#1,d0
	mulu	#$a0,d1
	add.w	d1,d0
	lea	l008c(pc),a0
	move.w	d0,(a0)
	subq.w	#1,d2
	subq.w	#1,d3
	tst.w	d2
	bge.s	l0085
	moveq	#0,d2
l0085:
	tst.w	d3
	bge.s	l0086
	moveq	#0,d3
l0086:
	cmpi.w	#$13,d2
	ble.s	l0087
	moveq	#$13,d2
l0087:
	cmpi.w	#$b,d3
	ble.s	l0088
	moveq	#$b,d3
l0088:
	lea	l0089(pc),a0
	move.w	d2,(a0)+
	move.w	d3,(a0)
	movea.l	(a7)+,a0
	rts

l0089:
	dc.b	$00,$13,$00,$09
l008a:
	dc.b	$03,$1e
l008b:
	dc.b	$00,$00
l008c:
	dc.b	$00,$00

local_scanline_table2:
	dc.b	$00,$00,$00,$a0,$01,'@',$01,$e0
	dc.b	$02,$80,$03,' ',$03,$c0,$04,'`'
	dc.b	$05,$00,$05,$a0,$06,'@',$06,$e0
	dc.b	$07,$80,$08,' ',$08,$c0,$09,'`'
	dc.b	$0a,$00,$0a,$a0,$0b,'@',$0b,$e0
	dc.b	$0c,$80,$0d,' ',$0d,$c0,$0e,'`'
	dc.b	$0f,$00,$0f,$a0,$10,'@',$10,$e0
	dc.b	$11,$80,$12,' ',$12,$c0,$13,'`'
	dc.b	$14,$00,$14,$a0,$15,'@',$15,$e0
	dc.b	$16,$80,$17,' ',$17,$c0,$18,'`'
	dc.b	$19,$00,$19,$a0,$1a,'@',$1a,$e0
	dc.b	$1b,$80,$1c,' ',$1c,$c0,$1d,'`'
	dc.b	$1e,$00,$1e,$a0,$1f,'@',$1f,$e0
	dc.b	' ',$80,'! !',$c0,'"`'
	dc.b	'#',$00,'#',$a0,'$@$',$e0
	dc.b	'%',$80,'& &',$c0,$27,'`'
	dc.b	'(',$00,'(',$a0,')@)',$e0
	dc.b	'*',$80,'+ +',$c0,',`'
	dc.b	'-',$00,'-',$a0,'.@.',$e0
	dc.b	'/',$80,'0 0',$c0,'1`'
	dc.b	'2',$00,'2',$a0,'3@3',$e0
	dc.b	'4',$80,'5 5',$c0,'6`'
	dc.b	'7',$00,'7',$a0,'8@8',$e0
	dc.b	'9',$80,': :',$c0,';`'
	dc.b	'<',$00,'<',$a0,'=@=',$e0
	dc.b	'>',$80,'? ?',$c0,'@`'
	dc.b	'A',$00,'A',$a0,'B@B',$e0
	dc.b	'C',$80,'D D',$c0,'E`'
	dc.b	'F',$00,'F',$a0,'G@G',$e0
	dc.b	'H',$80,'I I',$c0,'J`'
	dc.b	'K',$00,'K',$a0,'L@L',$e0
	dc.b	'M',$80,'N N',$c0,'O`'
	dc.b	'P',$00,'P',$a0,'Q@Q',$e0
	dc.b	'R',$80,'S S',$c0,'T`'
	dc.b	'U',$00,'U',$a0,'V@V',$e0
	dc.b	'W',$80,'X X',$c0,'Y`'
	dc.b	'Z',$00,'Z',$a0,'[@[',$e0
	dc.b	'\',$80,'] ]',$c0,'^`'
	dc.b	'_',$00,'_',$a0,'`@`',$e0
	dc.b	'a',$80,'b b',$c0,'c`'
	dc.b	'd',$00,'d',$a0,'e@e',$e0
	dc.b	'f',$80,'g g',$c0,'h`'
	dc.b	'i',$00,'i',$a0,'j@j',$e0
	dc.b	'k',$80,'l l',$c0,'m`'
	dc.b	'n',$00,'n',$a0,'o@o',$e0
	dc.b	'p',$80,'q q',$c0,'r`'
	dc.b	's',$00,'s',$a0,'t@t',$e0
	dc.b	'u',$80,'v v',$c0,'w`'
	dc.b	'x',$00,'x',$a0,'y@y',$e0
	dc.b	'z',$80,'{ {',$c0,'|`'

; **********

; -----------------------------------------------------------------------------
FN_musato:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movem.l	a0-a5/d0-d7,-(a7)
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	movea.l	(a6)+,a0
	move.l	a6,-(a7)
	andi.l	#$fffffffe,d1
	tst.w	d0
	beq	l00ae
	lea	l00b9(pc),a1
	cmpi.w	#1,(a1)
	beq	l00b7
	move.w	#1,(a1)
	lea	l00ba(pc),a2
	lea	l00bb(pc),a3
	movea.l	a0,a1
l008f:
	cmpi.l	#$54464d58,(a1)
	bne.s	l0090
	move.w	#1,(a2)
	move.w	#8,(a3)
	bra	l00a6
l0090:
	cmpi.l	#$434f534f,(a1)
	bne.s	l0091
	move.w	#1,(a2)
	move.w	#8,(a3)
	bra	l00a6
l0091:
	cmpi.l	#$436f756e,(a1)
	bne.s	l0092
	move.w	#2,(a2)
	move.w	#2,(a3)
	bra	l00a6
l0092:
	cmpi.l	#$50203139,(a1)
	bne.s	l0093
	move.w	#3,(a2)
	move.w	#$3e,(a3)
	bra	l00a6
l0093:
	cmpi.l	#$41502039,(a1)
	bne.s	l0094
	move.w	#4,(a2)
	move.w	#8,(a3)
	bra	l00a6
l0094:
	cmpi.l	#$594d3231,(a1)
	bne.s	l0095
	move.w	#5,(a2)
	move.w	#4,(a3)
	bra	l00a6
l0095:
	cmpi.l	#$53544943,(a1)
	bne.s	l0096
	move.w	#$a,(a2)
	move.w	#2,(a3)
	bra	l00a6
l0096:
	cmpi.l	#$696c6c65,(a1)
	bne.s	l0097
	move.w	#$b,(a2)
	move.w	#8,(a3)
	bra	l00a6
l0097:
	cmpi.l	#$4e444541,(a1)
	bne.s	l0098
	move.w	#6,(a2)
	move.w	#8,(a3)
	bra	l00a6
l0098:
	cmpi.l	#$5a4f554e,(a1)
	bne.s	l0099
	move.w	#7,(a2)
	move.w	#8,(a3)
	bra	l00a6
l0099:
	cmpi.l	#$5448495a,(a1)
	bne.s	l009a
	move.w	#8,(a2)
	move.w	#4,(a3)
	bra	l00a6
l009a:
	cmpi.l	#$454e4558,(a1)
	bne.s	l009b
	move.w	#9,(a2)
	move.w	#4,(a3)
	bra	l00a6
l009b:
	cmpi.l	#$20432044,(a1)
	bne.s	l009c
	move.w	#$c,(a2)
	move.w	#$1a,(a3)
	bra	l00a6
l009c:
	cmpi.l	#$42414446,(a1)
	bne.s	l009d
	move.w	#$d,(a2)
	move.w	#8,(a3)
	bra	l00a6
l009d:
	cmpi.l	#$4d344d31,(a1)
	bne.s	l009e
	move.w	#$e,(a2)
	move.w	#4,(a3)
	bra	l00a6
l009e:
	cmpi.l	#$4c415259,(a1)
	bne.s	l009f
	move.w	#$f,(a2)
	move.w	#$22,(a3)
	bra	l00a6
l009f:
	cmpi.l	#$2863294c,(a1)
	bne.s	l00a0
	move.w	#$12,(a2)
	move.w	#$138,(a3)
	bra.s	l00a6
l00a0:
	cmpi.l	#$54414f2d,(a1)
	bne.s	l00a1
	move.w	#$13,(a2)
	move.w	#8,(a3)
	bra.s	l00a6
l00a1:
	cmpi.l	#$2d54414f,(a1)
	bne.s	l00a2
	move.w	#$13,(a2)
	move.w	#8,(a3)
	bra.s	l00a6
l00a2:
	cmpi.l	#$544f4a47,(a1)
	bne.s	l00a3
	move.w	#$14,(a2)
	move.w	#8,(a3)
	bra.s	l00a6
l00a3:
	cmpi.l	#$2d4e4558,(a1)
	bne.s	l00a4
	move.w	#$15,(a2)
	move.w	#2,(a3)
	bra.s	l00a6
l00a4:
	cmpi.l	#$4e455855,(a1)
	bne.s	l00a5
	move.w	#$15,(a2)
	move.w	#2,(a3)
	bra.s	l00a6
l00a5:
	lea	2(a1),a1
	dbf	d1,l008f
	move.l	#0,-(a6)
	bra	l00b8
l00a6:
	lea	l00be(pc),a1
	move.l	$114.w,(a1)
	lea	l00bf(pc),a1
	move.b	$fffffa09.w,(a1)
	lea	l00c2(pc),a1
	move.b	$fffffa1d.w,(a1)
	lea	l00c0(pc),a1
	move.b	$fffffa15.w,(a1)
	lea	l00c1(pc),a1
	move.b	$fffffa17.w,(a1)
	lea	l00bc(pc),a1
	move.l	$70.w,(a1)
	lea	l00ba(pc),a1
	move.w	(a1)+,d2
	move.w	(a1),d1
	cmp.w	#$a,d2
	bne.s	l00a7
	subq.w	#1,d0
	lsl.w	#2,d0
	addi.w	#$ff00,d0
	move.w	d0,(a0)
	bra.s	l00ad
l00a7:
	cmpi.w	#$c,d2
	bne.s	l00a8
	subq.w	#1,d0
	bra.s	l00ac
l00a8:
	cmp.w	#$e,d2
	bne.s	l00a9
	subq.w	#1,d0
	bra.s	l00ac
l00a9:
	cmp.w	#$12,d2
	bne.s	l00aa
	movea.l	a0,a2
	lea	350(a2),a0
	lea	368(a2),a1
	move.l	a0,10(a1)
	move.l	a1,10(a0)
	lea	32(a2),a0
	jsr	(a0)
	lea	1774(a2),a0
	jsr	(a2)
	movea.l	a2,a0
	bra.s	l00ad
l00aa:
	cmp.w	#$13,d2
	bne.s	l00ab
	moveq	#1,d0
	bra.s	l00ac
l00ab:
	cmp.w	#$14,d2
	bne.s	l00ac
	moveq	#0,d0
l00ac:
	movem.l	a0-a6/d0-d7,-(a7)
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
l00ad:
	adda.l	d1,a0
	lea	l00bd(pc),a1
	move.l	a0,(a1)
	lea	l00b6(pc),a0
	move.l	a0,$70.w
	bra	l00b7
l00ae:
	lea	l00b9(pc),a2
	tst.w	(a2)
	beq	l00b7
	lea	l00bc(pc),a1
	move.l	(a1),$70.w
	lea	l00b9(pc),a1
	move.w	#0,(a1)
	lea	l00ba(pc),a1
	move.w	(a1),d1
	lea	l00bd(pc),a1
	movea.l	(a1),a0
	cmp.w	#$c,d1
	bne.s	l00af
	subq.w	#8,a0
	movem.l	a0-a6/d0-d7,-(a7)
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	move.l	#$ff,d0
	suba.l	#$12,a0
	movem.l	a0-a6/d0-d7,-(a7)
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	bra.s	l00b5
l00af:
	cmp.w	#$a,d1
	bne.s	l00b0
	move.w	#$ffff,-2(a0)
	jsr	(a0)
	bra.s	l00b5
l00b0:
	cmp.w	#$b,d1
	bne.s	l00b1
	subq.w	#4,a0
	jsr	(a0)
	bra.s	l00b5
l00b1:
	cmp.w	#$12,d1
	bne.s	l00b2
	lea	l00bd(pc),a1
	movea.l	(a1),a0
	lea	-166(a0),a0
	jsr	(a0)
	bra.s	l00b5
l00b2:
	cmp.w	#$13,d1
	bne.s	l00b3
	moveq	#0,d0
	lea	l00bd(pc),a1
	movea.l	(a1),a0
	lea	-8(a0),a0
	jsr	(a0)
	bra.s	l00b5
l00b3:
	cmp.w	#$14,d1
	bne.s	l00b4
	moveq	#1,d0
	lea	l00bd(pc),a1
	movea.l	(a1),a0
	lea	-8(a0),a0
	jsr	(a0)
	bra.s	l00b5
l00b4:
	cmp.w	#$15,d1
	bne.s	l00b5
	lea	l00bd(pc),a1
	movea.l	(a1),a0
	lea	2(a0),a0
	jsr	(a0)
l00b5:
	lea	l00be(pc),a0
	move.l	(a0),$114.w
	lea	l00bf(pc),a0
	move.b	(a0),$fffffa09.w
	lea	l00c2(pc),a0
	move.b	(a0),$fffffa1d.w
	lea	l00c0(pc),a0
	move.b	(a0),$fffffa15.w
	lea	l00c1(pc),a0
	move.b	(a0),$fffffa17.w
	move.l	#$8000000,$ffff8800.w
	move.l	#$9000000,$ffff8800.w
	move.l	#$a000000,$ffff8800.w
	bra.s	l00b7
l00b6:
	movem.l	a0-a6/d0-d7,-(a7)
	movea.l	l00bd(pc),a0
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	move.l	l00bc(pc),-(a7)
	rts

l00b7:
	movea.l	(a7)+,a6
	lea	l00ba(pc),a0
	moveq	#0,d0
	move.w	(a0),d0
	move.l	d0,-(a6)
l00b8:
	movem.l	(a7)+,a0-a5/d0-d7
	rts

l00b9:
	dc.b	$00,$00
l00ba:
	dc.b	$00,$00
l00bb:
	dc.b	$00,$00
l00bc:
	dcb.w	2,0
l00bd:
	dcb.w	2,0
l00be:
	dcb.w	2,0
l00bf:
	dc.b	$00
l00c0:
	dc.b	$00
l00c1:
	dc.b	$00
l00c2:
	dc.b	$00

; -----------------------------------------------------------------------------
FN_musplay:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movem.l	a0-a5/d0-d7,-(a7)
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	movea.l	(a6)+,a0
	move.l	a6,-(a7)
	tst.w	d0
	beq.s	l00c4
	lea	l00c7(pc),a1
	move.w	(a1),d2
	tst.w	d2
	bne.s	l00c3
	move.w	#1,(a1)
	lea	l00c9(pc),a1
	move.l	$70.w,(a1)
l00c3:
	movem.l	a0-a6/d0-d7,-(a7)
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	adda.l	d1,a0
	lea	l00c8(pc),a1
	move.l	a0,(a1)
	lea	l00c5(pc),a0
	move.l	a0,$70.w
	bra.s	l00c6
l00c4:
	lea	l00c7(pc),a2
	tst.w	(a2)
	beq.s	l00c6
	lea	l00c9(pc),a1
	move.l	(a1),$70.w
	lea	l00c7(pc),a1
	move.w	#0,(a1)
	lea	l00c8(pc),a1
	movea.l	(a1),a0
	move.l	#$8000000,$ffff8800.w
	move.l	#$9000000,$ffff8800.w
	move.l	#$a000000,$ffff8800.w
	bra.s	l00c6
l00c5:
	movem.l	a0-a6/d0-d7,-(a7)
	movea.l	l00c8(pc),a0
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	move.l	l00c9(pc),-(a7)
	rts

l00c6:
	movea.l	(a7)+,a6
	movem.l	(a7)+,a0-a5/d0-d7
	rts

l00c7:
	dc.b	$00,$00
l00c8:
	dcb.w	2,0
l00c9:
	dcb.w	2,0

; -----------------------------------------------------------------------------
FN_which_block:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	movea.l	(a6)+,a0
	cmpi.l	#$3031973,(a0)+
	bne.s	l00ca
	moveq	#7,d5
	bra.s	l00cb
l00ca:
	cmpi.l	#$2528e54,-4(a0)
	bne	l00cc
	moveq	#8,d5
l00cb:
	tst.w	d0
	blt.s	l00cd
	tst.w	d1
	blt.s	l00cd
	moveq	#0,d4
	move.w	(a0)+,d4
	addq.w	#2,d4
	lsl.w	#3,d4
	cmp.w	d4,d0
	bge.s	l00cd
	lsr.w	#3,d4
	move.w	(a0)+,d6
	lsl.w	#3,d6
	cmp.w	d6,d1
	bge.s	l00cd
	lsr.w	#4,d1
	mulu	d4,d1
	andi.w	#$fff0,d0
	lsr.w	#3,d0
	adda.w	d0,a0
	adda.l	d1,a0
	moveq	#0,d3
	move.w	(a0),d3
	lsr.w	d5,d3
	tst.w	d3
	bge	l00cc
	move.l	#$ffff,d3
l00cc:
	move.l	d3,-(a6)
	rts

l00cd:
	move.l	#$ffff,d3
	bra.s	l00cc

; -----------------------------------------------------------------------------
FN_relocate:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movea.l	(a6)+,a0
	movem.l	a0-a5/d0-d7,-(a7)
	cmpi.w	#$601a,(a0)
	beq.s	l00ce
	bra.s	l00d2
l00ce:
	move.l	a0,d2
	addi.l	#$1c,d2
	lea	28(a0),a1
	movea.l	a1,a2
	adda.l	2(a0),a2
	adda.l	(a2)+,a1
	add.l	d2,(a1)
l00cf:
	tst.b	(a2)
	beq.s	l00d2
	moveq	#0,d1
l00d0:
	moveq	#0,d0
	move.b	(a2)+,d0
	cmp.b	#1,d0
	bne.s	l00d1
	addi.w	#$fe,d1
	bra.s	l00d0
l00d1:
	add.w	d0,d1
	adda.w	d1,a1
	add.l	d2,(a1)
	bra.s	l00cf
l00d2:
	movem.l	(a7)+,a0-a5/d0-d7
	rts

; -----------------------------------------------------------------------------
FN_p_left:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d3
	lea	$41c.w,a0
	adda.w	d3,a0
	moveq	#0,d3
	move.b	(a0),d0
	btst	#2,d0
	beq.s	l00d3
	moveq	#$ff,d3
l00d3:
	move.l	d3,-(a6)
	rts

; -----------------------------------------------------------------------------
FN_p_on:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
; todo: disassemble manually
;	dc.b	$0c,'x',$12,'4',$04,$1e
;	dc.b	'g8'
	cmp.w	#$1234,$41e.w
	beq.s	.exit

	move.w	#$1234,$41e.w
	movem.l	a0-a2/d0-d2,-(a7)
	move.w	#$14,-(a7)
	move.w	#4,-(a7)
	move.w	#3,-(a7)		;bconout
	trap	#$d
	addq.l	#6,a7
	move.w	#$22,-(a7)		;kbdvbase
	trap	#$e
	addq.l	#2,a7
	movea.l	d0,a0
	adda.l	#$18,a0
	move.l	(a0),$418.w
	lea	l00d4(pc),a1
	move.l	a1,(a0)
	movem.l	(a7)+,a0-a2/d0-d2
.exit:
	rts

l00d4:
	movem.l	a0-a1,-(a7)
	move.b	1(a0),$41c.w
	move.b	2(a0),$41d.w
	movem.l	(a7)+,a0-a1
	rts

; -----------------------------------------------------------------------------
FN_p_joy:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d3
	tst.b	d3
	bne.s	l00d5
	moveq	#0,d3
	move.b	$41c.w,d3
	bra.s	l00d6
l00d5:
	moveq	#0,d3
	move.b	$41d.w,d3
l00d6:
	move.l	d3,-(a6)
	rts

; -----------------------------------------------------------------------------
FN_p_stop:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
; todo: disassemble manually
;	dc.b	$0c,'x',$12,'4',$04,$1e
;	dc.b	'f:'
	cmp.w	#$1234,$41e.w
	bne.s	.exit
	
	move.w	#$ffff,$41e.w
	move.w	#$22,-(a7)		;kbdvbase
	trap	#$e
	addq.l	#2,a7
	movea.l	d0,a0
	adda.l	#$18,a0
	move.l	$418.w,(a0)
	move.w	#$80,-(a7)
	move.w	#4,-(a7)
	move.w	#3,-(a7)		;bconout
	trap	#$d
	addq.l	#6,a7
	move.w	#1,-(a7)
	move.w	#4,-(a7)
	move.w	#3,-(a7)		;bconout
	trap	#$d
	addq.l	#6,a7
.exit:	rts

; -----------------------------------------------------------------------------
FN_p_up:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d3
	lea	$41c.w,a0
	adda.w	d3,a0
	moveq	#0,d3
	move.b	(a0),d0
	btst	#0,d0
	beq.s	l00d7
	moveq	#$ff,d3
l00d7:
	move.l	d3,-(a6)
	rts

; -----------------------------------------------------------------------------
FN_set_block:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d2
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	movea.l	(a6)+,a0
	cmpi.l	#$3031973,(a0)+
	bne.s	l00d8
	lsl.w	#7,d2
	bra.s	l00d9
l00d8:
	cmpi.l	#$2528e54,-4(a0)
	bne	l00da
	lsl.w	#8,d2
l00d9:
	tst.w	d0
	blt.s	l00da
	tst.w	d1
	blt.s	l00da
	moveq	#0,d3
	move.w	(a0)+,d3
	addq.w	#2,d3
	lsl.w	#3,d3
	cmp.w	d3,d0
	bge.s	l00da
	lsr.w	#3,d3
	move.w	(a0)+,d4
	lsl.w	#3,d4
	cmp.w	d4,d1
	bge.s	l00da
	andi.w	#$fff0,d0
	lsr.w	#3,d0
	lsr.w	#4,d1
	mulu	d1,d3
	adda.w	d0,a0
	adda.l	d3,a0
	move.w	d2,(a0)
l00da:
	rts

; -----------------------------------------------------------------------------
FN_p_right:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d3
	lea	$41c.w,a0
	adda.w	d3,a0
	moveq	#0,d3
	move.b	(a0),d0
	btst	#3,d0
	beq.s	l00db
	moveq	#$ff,d3
l00db:
	move.l	d3,-(a6)
	rts

; -----------------------------------------------------------------------------
FN_palsplit:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d3
	move.l	(a6)+,d2
	move.l	(a6)+,d0
	movea.l	(a6)+,a0
	move.l	(a6)+,d1
	tst.w	d1
	beq	l00de
	lea	l00e9(pc),a2
	tst.w	(a2)
	beq.s	l00dc
	clr.b	$fffffa1b.l
	lea	l00e1(pc),a2
	move.b	d0,2(a2)
	lea	l00e2(pc),a2
	move.b	d2,2(a2)
	lea	l00ea(pc),a2
	move.w	d3,(a2)
	move.b	#8,$fffffa1b.l
	bra	l00df
l00dc:
	lea	l00e1(pc),a2
	move.w	d0,2(a2)
	lea	l00e2(pc),a2
	move.w	d2,2(a2)
	lea	l00ec(pc),a2
	move.l	a0,(a2)
	lea	l00ea(pc),a2
	move.w	d3,(a2)
	lea	$ffff8240.w,a0
	lea	l00e0(pc),a1
	lea	2(a1),a1
	move.w	#7,d0
l00dd:
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	dbf	d0,l00dd
	lea	l00e7(pc),a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move	#$2700,sr
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	bclr	#3,$fffffa17.w
	clr.b	$fffffa1b.w
	lea	l00e8(pc),a2
	move.l	$70.w,(a2)
	lea	l00e0(pc),a2
	move.l	a2,$70.w
	move	#$2300,sr
	lea	l00e9(pc),a2
	move.w	#1,(a2)
	bra.s	l00df
l00de:
	lea	l00e9(pc),a2
	tst.w	(a2)
	beq.s	l00df
	move	#$2700,sr
	lea	l00e7(pc),a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.l	l00e8(pc),$70.w
	move	#$2300,sr
	lea	l00e9(pc),a2
	move.w	#0,(a2)
l00df:
	rts

l00e0:
	move.l	#$777,$ffff8240.w
	move.l	#$777,$ffff8244.w
	move.l	#$777,$ffff8248.w
	move.l	#$777,$ffff824c.w
	move.l	#$777,$ffff8250.w
	move.l	#$777,$ffff8254.w
	move.l	#$777,$ffff8258.w
	move.l	#$333222,$ffff825c.w
	movem.l	a0-a1,-(a7)
	lea	l00ec(pc),a1
	movea.l	(a1),a0
	lea	l00e4(pc),a1
	lea	2(a1),a1
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	lea	l00ed(pc),a1
	move.l	a0,(a1)
	lea	l00ea(pc),a0
	lea	l00eb(pc),a1
	move.w	(a0),(a1)
	clr.b	$fffffa1b.w
	lea	l00e3(pc),a0
	move.l	a0,$120.w
l00e1:
	move.b	#$63,$fffffa21.w
	move.b	#8,$fffffa1b.w
l00e2:
	move.b	#1,$fffffa21.w
	movem.l	(a7)+,a0-a1
	move.l	l00e8(pc),-(a7)
	rts

l00e3:
	movem.l	a0-a2/d0,-(a7)
l00e4:
	move.l	#$777,$ffff8240.w
	move.l	#$777,$ffff8244.w
	move.l	#$777,$ffff8248.w
	move.l	#$777,$ffff824c.w
	move.l	#$777,$ffff8250.w
	move.l	#$777,$ffff8254.w
	move.l	#$777,$ffff8258.w
	move.l	#$333222,$ffff825c.w
	lea	l00eb(pc),a0
	subq.w	#1,(a0)
	bge.s	l00e5
	clr.b	$fffffa1b.w
	bra.s	l00e6
l00e5:
	lea	l00ed(pc),a0
	movea.l	(a0),a1
	lea	l00e4(pc),a2
	lea	2(a2),a2
	move.l	(a1)+,(a2)
	lea	8(a2),a2
	move.l	(a1)+,(a2)
	lea	8(a2),a2
	move.l	(a1)+,(a2)
	lea	8(a2),a2
	move.l	(a1)+,(a2)
	lea	8(a2),a2
	move.l	(a1)+,(a2)
	lea	8(a2),a2
	move.l	(a1)+,(a2)
	lea	8(a2),a2
	move.l	(a1)+,(a2)
	lea	8(a2),a2
	move.l	(a1)+,(a2)
	lea	8(a2),a2
	move.l	a1,(a0)
l00e6:
	movem.l	(a7)+,a0-a2/d0
	rte

l00e7:
	dcb.w	2,0
l00e8:
	dcb.w	2,0
l00e9:
	dc.b	$00,$00
l00ea:
	dc.b	$00,$00
l00eb:
	dc.b	$00,$00
l00ec:
	dcb.w	2,0
l00ed:
	dcb.w	2,0

; -----------------------------------------------------------------------------
FN_p_down:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d3
	lea	$41c.w,a0
	adda.w	d3,a0
	moveq	#0,d3
	move.b	(a0),d0
	btst	#1,d0
	beq.s	l00ee
	moveq	#$ff,d3
l00ee:
	move.l	d3,-(a6)
	rts

; -----------------------------------------------------------------------------
FN_floodpal:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d3
	moveq	#$f,d0
	lea	l00f0(pc),a0
l00ef:
	move.w	d3,(a0)+
	dbf	d0,l00ef
	lea	l00f0(pc),a0
	move.l	a0,$45a.w
	rts

l00f0:
	dcb.w	16,0

; -----------------------------------------------------------------------------
FN_p_fire:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d3
	lea	$41c.w,a0
	adda.l	d3,a0
	moveq	#0,d3
	move.b	(a0),d0
	btst	#7,d0
	beq.s	l00f1
	moveq	#$ff,d3
l00f1:
	move.l	d3,-(a6)
	rts

; -----------------------------------------------------------------------------
FN_digi_play:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	lea	l0107(pc),a0
	tst.w	(a0)
	beq.s	l00f2
	move.w	#0,(a0)
	move	sr,-(a7)
	move	#$2700,sr
	move.l	l00f9(pc),$134.w
	move.b	l0108(pc),$fffffa07.w
	move.b	l0109(pc),$fffffa13.w
	move.b	l010a(pc),$fffffa17.w
	move.b	l010b(pc),$fffffa19.w
	lea	l0103(pc),a0
	move.w	#0,(a0)
	move	(a7)+,sr
l00f2:
	move.l	(a6)+,d3
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	movea.l	(a6)+,a0
	move.l	(a6)+,d2
	tst.w	d2
	beq	l00f7
	subq.w	#1,d1
	cmpi.w	#2,d1
	blt.s	l00f5
	cmpi.w	#$20,d1
	bgt.s	l00f5
	lea	l0103(pc),a1
	move.w	d3,(a1)
	cmpi.l	#$858b8c1,(a0)
	bne.s	l00f4
	move.w	4(a0),d3
	cmp.w	d3,d0
	ble.s	l00f3
	move.w	d3,d0
l00f3:
	lsl.w	#3,d0
	lea	6(a0,d0.w),a1
	adda.l	(a1)+,a0
	move.l	(a1),d0
l00f4:
	lea	l0106(pc),a1
	move.b	0(a1,d1.w),d1
	lea	l0104(pc),a1
	move.b	d1,(a1)
	bsr	l00fa
	bsr	l00f6
l00f5:
	rts

l00f6:
	lea	l0107(pc),a1
	move.w	#1,(a1)
	move	sr,-(a7)
	move	#$2700,sr
	lea	l0108(pc),a1
	move.b	$fffffa07.w,(a1)+
	move.b	$fffffa13.w,(a1)+
	move.b	$fffffa17.w,(a1)+
	move.b	$fffffa19.w,(a1)
	lea	l00f9(pc),a1
	move.l	$134.w,(a1)
	lea	l00fc(pc),a1
	move.l	a1,$134.w
	move.b	#1,$fffffa19.w
	move.b	l0104(pc),$fffffa1f.w
	bset	#5,$fffffa07.w
	bset	#5,$fffffa13.w
	bclr	#3,$fffffa17.w
	rte

l00f7:
	move	sr,-(a7)
	lea	l0107(pc),a0
	tst.w	(a0)
	beq.s	l00f8
	move.w	#0,(a0)
	move	#$2700,sr
	move.l	l00f9(pc),$134.w
	move.b	l0108(pc),$fffffa07.w
	move.b	l0109(pc),$fffffa13.w
	move.b	l010a(pc),$fffffa17.w
	move.b	l010b(pc),$fffffa19.w
	lea	l0103(pc),a0
	move.w	#0,(a0)
l00f8:
	rte

l00f9:
	dcb.w	2,0
l00fa:
	lea	l0102(pc),a1
	move.l	d0,(a1)
	lea	l0101(pc),a1
	move.l	a0,(a1)
	lea	l0100(pc),a1
	move.l	d0,(a1)
	lea	l00ff(pc),a1
	move.l	a0,(a1)
	move.b	#$a,d1
	moveq	#0,d0
	movea.w	#$8800,a0
l00fb:
	move.b	d1,(a0)
	move.b	d0,2(a0)
	dbf	d1,l00fb
	move.b	#7,(a0)
	move.b	#$ff,2(a0)
	rts

l00fc:
	movem.l	a0-a1/d0-d1,-(a7)
	moveq	#0,d0
	lea	l0100(pc),a0
	subq.l	#1,(a0)
	movea.l	l00ff(pc),a0
	bne.s	l00fe
	lea	l0103(pc),a1
	tst.w	(a1)
	bne.s	l00fd
	bsr	l00f7
l00fd:
	movea.l	l0101(pc),a0
	lea	l0100(pc),a1
	move.l	l0102(pc),(a1)
l00fe:
	move.b	(a0)+,d0
	lea	l00ff(pc),a1
	move.l	a0,(a1)
	lsl.w	#3,d0
	movem.l	l0105(pc,d0.w),d0-d1
	movea.w	#$8800,a0
	movep.l	d0,0(a0)
	move.l	d1,(a0)
	movem.l	(a7)+,a0-a1/d0-d1
	rte

l00ff:
	dcb.w	2,0
l0100:
	dcb.w	2,0
l0101:
	dcb.w	2,0
l0102:
	dcb.w	2,0
l0103:
	dcb.w	2,0
l0104:
	dc.b	'=',$00
l0105:
	dc.b	$08,$0c,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$08,$0a,$08,$00,$00
	dc.b	$08,$0b,$09,$0b,$0a,$0b,$00,$00
	dc.b	$08,$0d,$09,$09,$0a,$05,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$08,$00,$00
	dc.b	$08,$0d,$09,$09,$0a,$02,$00,$00
	dc.b	$08,$0d,$09,$08,$0a,$06,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$07,$00,$00
	dc.b	$08,$0d,$09,$07,$0a,$07,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$06,$00,$00
	dc.b	$08,$0c,$09,$0a,$0a,$09,$00,$00
	dc.b	$08,$0b,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$02,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$00,$00,$00
	dc.b	$08,$0c,$09,$0a,$0a,$08,$00,$00
	dc.b	$08,$0d,$09,$06,$0a,$04,$00,$00
	dc.b	$08,$0d,$09,$05,$0a,$05,$00,$00
	dc.b	$08,$0d,$09,$05,$0a,$04,$00,$00
	dc.b	$08,$0c,$09,$09,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$04,$0a,$03,$00,$00
	dc.b	$08,$0b,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0c,$09,$0a,$0a,$05,$00,$00
	dc.b	$08,$0b,$09,$0a,$0a,$0a,$00,$00
	dc.b	$08,$0c,$09,$09,$0a,$08,$00,$00
	dc.b	$08,$0b,$09,$0b,$0a,$08,$00,$00
	dc.b	$08,$0c,$09,$0a,$0a,$00,$00,$00
	dc.b	$08,$0c,$09,$0a,$0a,$00,$00,$00
	dc.b	$08,$0c,$09,$09,$0a,$07,$00,$00
	dc.b	$08,$0b,$09,$0b,$0a,$07,$00,$00
	dc.b	$08,$0c,$09,$09,$0a,$06,$00,$00
	dc.b	$08,$0b,$09,$0b,$0a,$06,$00,$00
	dc.b	$08,$0b,$09,$0a,$0a,$09,$00,$00
	dc.b	$08,$0b,$09,$0b,$0a,$05,$00,$00
	dc.b	$08,$0a,$09,$0a,$0a,$0a,$00,$00
	dc.b	$08,$0b,$09,$0b,$0a,$02,$00,$00
	dc.b	$08,$0b,$09,$0a,$0a,$08,$00,$00
	dc.b	$08,$0c,$09,$07,$0a,$07,$00,$00
	dc.b	$08,$0c,$09,$08,$0a,$04,$00,$00
	dc.b	$08,$0c,$09,$07,$0a,$06,$00,$00
	dc.b	$08,$0b,$09,$09,$0a,$09,$00,$00
	dc.b	$08,$0c,$09,$06,$0a,$06,$00,$00
	dc.b	$08,$0a,$09,$0a,$0a,$09,$00,$00
	dc.b	$08,$0c,$09,$07,$0a,$03,$00,$00
	dc.b	$08,$0b,$09,$0a,$0a,$05,$00,$00
	dc.b	$08,$0b,$09,$09,$0a,$08,$00,$00
	dc.b	$08,$0b,$09,$0a,$0a,$03,$00,$00
	dc.b	$08,$0a,$09,$0a,$0a,$08,$00,$00
	dc.b	$08,$0b,$09,$0a,$0a,$00,$00,$00
	dc.b	$08,$0b,$09,$09,$0a,$07,$00,$00
	dc.b	$08,$0b,$09,$08,$0a,$08,$00,$00
	dc.b	$08,$0a,$09,$0a,$0a,$07,$00,$00
	dc.b	$08,$0a,$09,$09,$0a,$09,$00,$00
	dc.b	$08,$0c,$09,$01,$0a,$01,$00,$00
	dc.b	$08,$0a,$09,$0a,$0a,$06,$00,$00
	dc.b	$08,$0b,$09,$08,$0a,$07,$00,$00
	dc.b	$08,$0a,$09,$0a,$0a,$05,$00,$00
	dc.b	$08,$0a,$09,$09,$0a,$08,$00,$00
	dc.b	$08,$0a,$09,$0a,$0a,$02,$00,$00
	dc.b	$08,$0a,$09,$0a,$0a,$01,$00,$00
	dc.b	$08,$0a,$09,$0a,$0a,$00,$00,$00
	dc.b	$08,$09,$09,$09,$0a,$09,$00,$00
	dc.b	$08,$0a,$09,$08,$0a,$08,$00,$00
	dc.b	$08,$0b,$09,$08,$0a,$01,$00,$00
	dc.b	$08,$0a,$09,$09,$0a,$06,$00,$00
	dc.b	$08,$0b,$09,$07,$0a,$04,$00,$00
	dc.b	$08,$0a,$09,$09,$0a,$05,$00,$00
	dc.b	$08,$09,$09,$09,$0a,$08,$00,$00
	dc.b	$08,$0a,$09,$09,$0a,$03,$00,$00
	dc.b	$08,$0a,$09,$08,$0a,$06,$00,$00
	dc.b	$08,$0a,$09,$09,$0a,$00,$00,$00
	dc.b	$08,$09,$09,$09,$0a,$07,$00,$00
	dc.b	$08,$09,$09,$08,$0a,$08,$00,$00
	dc.b	$08,$0a,$09,$08,$0a,$04,$00,$00
	dc.b	$08,$09,$09,$09,$0a,$06,$00,$00
	dc.b	$08,$0a,$09,$08,$0a,$01,$00,$00
	dc.b	$08,$09,$09,$09,$0a,$05,$00,$00
	dc.b	$08,$09,$09,$08,$0a,$07,$00,$00
	dc.b	$08,$08,$09,$08,$0a,$08,$00,$00
	dc.b	$08,$09,$09,$09,$0a,$02,$00,$00
	dc.b	$08,$09,$09,$08,$0a,$06,$00,$00
	dc.b	$08,$09,$09,$09,$0a,$00,$00,$00
	dc.b	$08,$09,$09,$07,$0a,$07,$00,$00
	dc.b	$08,$08,$09,$08,$0a,$07,$00,$00
	dc.b	$08,$09,$09,$07,$0a,$06,$00,$00
	dc.b	$08,$09,$09,$08,$0a,$02,$00,$00
	dc.b	$08,$08,$09,$08,$0a,$06,$00,$00
	dc.b	$08,$09,$09,$06,$0a,$06,$00,$00
	dc.b	$08,$08,$09,$07,$0a,$07,$00,$00
	dc.b	$08,$08,$09,$08,$0a,$04,$00,$00
	dc.b	$08,$08,$09,$07,$0a,$06,$00,$00
	dc.b	$08,$08,$09,$08,$0a,$02,$00,$00
	dc.b	$08,$07,$09,$07,$0a,$07,$00,$00
	dc.b	$08,$08,$09,$06,$0a,$06,$00,$00
	dc.b	$08,$08,$09,$07,$0a,$04,$00,$00
	dc.b	$08,$07,$09,$07,$0a,$06,$00,$00
	dc.b	$08,$08,$09,$06,$0a,$05,$00,$00
	dc.b	$08,$08,$09,$06,$0a,$04,$00,$00
	dc.b	$08,$07,$09,$06,$0a,$06,$00,$00
	dc.b	$08,$07,$09,$07,$0a,$04,$00,$00
	dc.b	$08,$08,$09,$05,$0a,$04,$00,$00
	dc.b	$08,$06,$09,$06,$0a,$06,$00,$00
	dc.b	$08,$07,$09,$06,$0a,$04,$00,$00
	dc.b	$08,$07,$09,$05,$0a,$05,$00,$00
	dc.b	$08,$06,$09,$06,$0a,$05,$00,$00
	dc.b	$08,$06,$09,$06,$0a,$04,$00,$00
	dc.b	$08,$06,$09,$05,$0a,$05,$00,$00
	dc.b	$08,$06,$09,$06,$0a,$02,$00,$00
	dc.b	$08,$06,$09,$05,$0a,$04,$00,$00
	dc.b	$08,$05,$09,$05,$0a,$05,$00,$00
	dc.b	$08,$06,$09,$05,$0a,$02,$00,$00
	dc.b	$08,$05,$09,$05,$0a,$04,$00,$00
	dc.b	$08,$05,$09,$04,$0a,$04,$00,$00
	dc.b	$08,$05,$09,$05,$0a,$02,$00,$00
	dc.b	$08,$04,$09,$04,$0a,$04,$00,$00
	dc.b	$08,$04,$09,$04,$0a,$03,$00,$00
	dc.b	$08,$04,$09,$04,$0a,$02,$00,$00
	dc.b	$08,$04,$09,$03,$0a,$03,$00,$00
	dc.b	$08,$03,$09,$03,$0a,$03,$00,$00
	dc.b	$08,$03,$09,$03,$0a,$02,$00,$00
	dc.b	$08,$03,$09,$02,$0a,$02,$00,$00
	dc.b	$08,$02,$09,$02,$0a,$02,$00,$00
	dc.b	$08,$02,$09,$02,$0a,$01,$00,$00
	dc.b	$08,$01,$09,$01,$0a,$01,$00,$00
	dc.b	$08,$02,$09,$01,$0a,$00,$00,$00
	dc.b	$08,$01,$09,$01,$0a,$00,$00,$00
	dc.b	$08,$01,$09,$00,$0a,$00,$00,$00
	dc.b	$08,$00,$09,$00,$0a,$00,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0c,$00,$00
	dc.b	$08,$0f,$09,$03,$0a,$00,$00,$00
	dc.b	$08,$0f,$09,$03,$0a,$00,$00,$00
	dc.b	$08,$0f,$09,$03,$0a,$00,$00,$00
	dc.b	$08,$0f,$09,$03,$0a,$00,$00,$00
	dc.b	$08,$0f,$09,$03,$0a,$00,$00,$00
	dc.b	$08,$0f,$09,$03,$0a,$00,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0c,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$00,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0d,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0d,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0d,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0d,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0d,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0d,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0a,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0c,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0c,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$09,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$09,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$05,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$00,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$00,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$0c,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$07,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$00,$00,$00
	dc.b	$08,$0e,$09,$0b,$0a,$00,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$09,$00,$00
	dc.b	$08,$0e,$09,$0a,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$08,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$07,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$04,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$00,$00,$00
	dc.b	$08,$0e,$09,$0a,$0a,$04,$00,$00
	dc.b	$08,$0e,$09,$09,$0a,$09,$00,$00
	dc.b	$08,$0e,$09,$09,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$09,$0a,$08,$00,$00
	dc.b	$08,$0e,$09,$09,$0a,$08,$00,$00
	dc.b	$08,$0e,$09,$09,$0a,$07,$00,$00
	dc.b	$08,$0e,$09,$08,$0a,$08,$00,$00
	dc.b	$08,$0e,$09,$09,$0a,$01,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$0c,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$08,$0a,$06,$00,$00
	dc.b	$08,$0e,$09,$07,$0a,$07,$00,$00
	dc.b	$08,$0e,$09,$08,$0a,$00,$00,$00
	dc.b	$08,$0e,$09,$07,$0a,$05,$00,$00
	dc.b	$08,$0e,$09,$06,$0a,$06,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$09,$00,$00
	dc.b	$08,$0e,$09,$05,$0a,$05,$00,$00
	dc.b	$08,$0e,$09,$04,$0a,$04,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$08,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$00,$0a,$00,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$06,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$05,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$02,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$0a,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$0a,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$0a,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$0a,$0a,$0a,$00,$00
	dc.b	$08,$0d,$09,$0a,$0a,$0a,$00,$00
	dc.b	$08,$0d,$09,$0a,$0a,$0a,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$09,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$09,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$06,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$0b,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$08,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$00,$00,$00
	dc.b	$08,$0d,$09,$0b,$0a,$00,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$07,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$06,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$05,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$03,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$01,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0d,$09,$0a,$0a,$05,$00,$00
	dc.b	$08,$0d,$09,$0a,$0a,$04,$00,$00
	dc.b	$08,$0d,$09,$0a,$0a,$02,$00,$00
	dc.b	$08,$0d,$09,$09,$0a,$08,$00,$00
	dc.b	$08,$0d,$09,$09,$0a,$08,$00,$00
	dcb.w	2,0
l0106:
	dc.b	$00,$00,$cc,$99,'zfWL'
	dc.b	'D=73/+(&'
	dc.b	'$" ',$1e,$1d,$1b,$1a,$19
	dc.b	$18,$17,$16,$15,$15,$14,$13,$12
	dc.b	$12,$11,$11,$10,$10,$0f,$0f,$0e
	dc.b	$0e,$0e,$0d,$0d,$0d,$0d,$0c,$0c
	dc.b	$0c,$00
l0107:
	dc.b	$00,$00
l0108:
	dc.b	$00
l0109:
	dc.b	$00
l010a:
	dc.b	$00
l010b:
	dc.b	$00

; -----------------------------------------------------------------------------
FN_string:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6),d3
	lea	l010e(pc),a0
	tst.l	d3
	bgt.s	l010c
	move.b	#$30,-(a0)		;#'0'
	bra.s	l010d
l010c:
	tst.w	d3
	beq.s	l010d
	divu	#$a,d3
	swap	d3
	addi.w	#$30,d3
	move.b	d3,-(a0)
	move.w	#0,d3
	swap	d3
	bra.s	l010c
l010d:
	move.l	a0,(a6)
	rts

; ?????

	dc.b	'        '
	dc.b	'      '
l010e:
	dc.b	' ',$00
	rts

; -----------------------------------------------------------------------------
FN_samsign:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d0
	movea.l	(a6)+,a0
l010f:
	addi.b	#$80,(a0)+
	subq.w	#1,d0
	bne.s	l010f
	rts

; -----------------------------------------------------------------------------
FN_depack:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movea.l	(a6)+,a0
	cmpi.l	#$49434521,(a0)
	beq.s	l0110
	cmpi.l	#$46495245,(a0)
	beq.s	l0111
	cmpi.l	#$41544d35,(a0)
	beq.s	l0113
	cmpi.l	#$41553521,(a0)
	beq.s	l0112
	cmpi.l	#$53503230,(a0)
	beq.s	l0114
	cmpi.l	#$53507633,(a0)
	beq.s	l0115
	clr.l	-(a7)
	bra.s	l0116
l0110:
	move.l	8(a0),-(a7)
	bsr	l0150
	bra.s	l0116
l0111:
	move.l	8(a0),-(a7)
	bsr	l016f
	bra.s	l0116
l0112:
	move.l	8(a0),-(a7)
	bsr	l0194
	bra.s	l0116
l0113:
	move.l	4(a0),-(a7)
	bsr.s	l0117
	bra.s	l0116
l0114:
	move.l	12(a0),-(a7)
	bsr	l01b3
	bra.s	l0116
l0115:
	move.l	12(a0),-(a7)
	bsr	l01db
l0116:
	move.l	(a7)+,d0
	move.l	d0,-(a6)
	rts

l0117:
	movem.l	a0-a6/d0-d7,-(a7)
	cmpi.l	#$41544d35,(a0)+
	bne	l0145
	link	a2,#$ffe4
	move.l	(a0)+,d0
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	movea.l	a5,a4
	lea	128(a4),a5
	lea	-12(a4),a4
	move.l	(a0)+,d0
	movea.l	a0,a6
	adda.l	d0,a6
	moveq	#0,d0
	move.b	-(a6),d0
	move.w	d0,-2(a2)
	lsl.w	#2,d0
	suba.w	d0,a4
	lea	l014f(pc),a3
	move.w	-2(a2),d0
	lsl.w	#2,d0
	addi.w	#$8c,d0
	bra.s	l0119
l0118:
	move.b	(a4)+,(a3)+
	subq.w	#1,d0
l0119:
	bne.s	l0118
	movem.l	a3-a4,-(a7)
	pea	(a5)
	move.b	-(a6),d7
	bra	l0139
l011a:
	move.w	d3,d5
l011b:
	add.b	d7,d7
l011c:
	dbcs	d5,l011b
	beq.s	l011f
	bcc.s	l011d
	sub.w	d3,d5
	neg.w	d5
	bra.s	l0122
l011d:
	moveq	#3,d6
	bsr.s	l0128
	beq.s	l011e
	bra.s	l0121
l011e:
	moveq	#7,d6
	bsr.s	l0128
	beq.s	l0120
	addi.w	#$f,d5
	bra.s	l0121
l011f:
	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l011c
l0120:
	moveq	#$d,d6
	bsr.s	l0128
	addi.w	#$10e,d5
l0121:
	add.w	d3,d5
l0122:
	lea	l0146(pc),a4
	move.w	d5,d2
	bne.s	l012c
	add.b	d7,d7
	bne.s	l0123
	move.b	-(a6),d7
	addx.b	d7,d7
l0123:
	bcs.s	l0124
	moveq	#1,d6
	bra.s	l012d
l0124:
	moveq	#3,d6
	bsr.s	l0128
	tst.b	-28(a2)
	beq.s	l0125
	move.b	-18(a2,d5.w),-(a5)
	bra	l0138
l0125:
	move.b	(a5),d0
	btst	#3,d5
	bne.s	l0126
	bra.s	l0127
l0126:
	addi.b	#$f0,d5
l0127:
	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	l0138
l0128:
	clr.w	d5
l0129:
	add.b	d7,d7
	beq.s	l012b
l012a:
	addx.w	d5,d5
	dbf	d6,l0129
	tst.w	d5
	rts

l012b:
	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l012a
l012c:
	moveq	#2,d6
l012d:
	bsr.s	l0128
	move.w	d5,d4
	move.b	14(a4,d4.w),d6
	ext.w	d6
	tst.b	-27(a2)
	bne.s	l012e
	addq.w	#4,d6
	bra.s	l0132
l012e:
	bsr.s	l0128
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	l0128
	cmp.b	#7,d5
	blt.s	l0130
	moveq	#0,d6
	bsr.s	l0128
	beq.s	l012f
	moveq	#2,d6
	bsr.s	l0128
	add.w	d5,d5
	or.w	d1,d5
	bra.s	l0133
l012f:
	or.b	-26(a2),d1
	bra.s	l0131
l0130:
	or.b	-25(a2,d5.w),d1
l0131:
	move.w	d1,d5
	bra.s	l0133
l0132:
	bsr.s	l0128
l0133:
	add.w	d4,d4
	beq.s	l0134
	add.w	-2(a4,d4.w),d5
l0134:
	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
l0135:
	move.b	-(a4),-(a5)
	dbf	d2,l0135
	bra.s	l0138
l0136:
	add.b	d7,d7
	bne.s	l0137
	move.b	-(a6),d7
	addx.b	d7,d7
l0137:
	bcs.s	l0141
	move.b	-(a6),-(a5)
l0138:
	cmpa.l	a5,a3
	bne.s	l0136
	cmpa.l	a6,a0
	beq.s	l0142
l0139:
	moveq	#0,d6
	bsr	l0128
	beq.s	l013c
	move.b	-(a6),d0
	lea	-26(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
l013a:
	cmp.b	d0,d1
	bne.s	l013b
	addq.w	#2,d1
l013b:
	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,l013a
	st	-27(a2)
	bra.s	l013d
l013c:
	sf	-27(a2)
l013d:
	moveq	#0,d6
	bsr	l0128
	beq.s	l013f
	lea	-18(a2),a1
	moveq	#$f,d0
l013e:
	move.b	-(a6),(a1)+
	dbf	d0,l013e
	st	-28(a2)
	bra.s	l0140
l013f:
	sf	-28(a2)
l0140:
	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	movea.l	a5,a3
	suba.w	d0,a3
	bra.s	l0136
l0141:
	bra	l011a
l0142:
	movea.l	(a7)+,a0
	pea	(a2)
	bsr.s	l0147
	movea.l	(a7)+,a2
	movem.l	(a7)+,a3-a4
	move.l	(a7)+,d0
	bsr.s	l014d
	move.w	-2(a2),d0
	lsl.w	#2,d0
	addi.w	#$8c,d0
	bra.s	l0144
l0143:
	move.b	-(a3),-(a4)
	subq.w	#1,d0
l0144:
	bne.s	l0143
	unlk	a2
l0145:
	movem.l	(a7)+,a0-a6/d0-d7
	rts

l0146:
	dc.b	$00,' ',$00,'`',$01,'`',$03,'`'
	dc.b	$07,'`',$0f,'`',$1f,'`',$00,$01
	dc.b	$03,$04,$05,$06,$07,$08
l0147:
	move.w	-2(a2),d7
l0148:
	dbf	d7,l0149
	rts

l0149:
	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
	lea	32000(a1),a2
l014a:
	moveq	#3,d6
l014b:
	move.w	(a1)+,d0
	moveq	#3,d5
l014c:
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,l014c
	dbf	d6,l014b
	movem.w	d1-d4,-8(a1)
	cmpa.l	a1,a2
	bne.s	l014a
	bra.s	l0148
l014d:
	lsr.l	#4,d0
	lea	-12(a6),a6
l014e:
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbf	d0,l014e
	rts

l014f:
	dcb.w	142,0
l0150:
	link	a3,#$ff88
	movem.l	a0-a6/d0-d7,-(a7)
	lea	120(a0),a4
	movea.l	a4,a6
	bsr	l0159
	cmpi.l	#$49434521,d0
	bne.s	l0158
	bsr.s	l0159
	lea	-8(a0,d0.l),a5
	bsr.s	l0159
	move.l	d0,(a7)
	adda.l	d0,a6
	movea.l	a6,a1
	moveq	#$77,d0
l0151:
	move.b	-(a1),-(a3)
	dbf	d0,l0151
	movea.l	a6,a3
	move.b	-(a5),d7
	bsr.s	l015b
	movea.l	a3,a5
	bsr	l015f
	bcc.s	l0155
	move.w	#$f9f,d7
	bsr	l015f
	bcc.s	l0152
	moveq	#$f,d0
	bsr	l0161
	move.w	d1,d7
l0152:
	moveq	#3,d6
l0153:
	move.w	-(a3),d4
	moveq	#3,d5
l0154:
	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbf	d5,l0154
	dbf	d6,l0153
	movem.w	d0-d3,(a3)
	dbf	d7,l0152
l0155:
	movem.l	(a7),a0-a3/d0-d7
l0156:
	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	l0156
	moveq	#$77,d0
l0157:
	move.b	-(a3),-(a5)
	dbf	d0,l0157
l0158:
	movem.l	(a7)+,a0-a6/d0-d7
	unlk	a3
	rts

l0159:
	moveq	#3,d1
l015a:
	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,l015a
	rts

l015b:
	bsr.s	l015f
	bcc.s	l015e
	moveq	#0,d1
	bsr.s	l015f
	bcc.s	l015d
	lea	l016c(pc),a1
	moveq	#4,d3
l015c:
	move.l	-(a1),d0
	bsr.s	l0161
	swap	d0
	cmp.w	d0,d1
	dbne	d3,l015c
	add.l	20(a1),d1
l015d:
	move.b	-(a5),-(a6)
	dbf	d1,l015d
l015e:
	cmpa.l	a4,a6
	bgt.s	l0164
	rts

l015f:
	add.b	d7,d7
	bne.s	l0160
	move.b	-(a5),d7
	addx.b	d7,d7
l0160:
	rts

l0161:
	moveq	#0,d1
l0162:
	add.b	d7,d7
	bne.s	l0163
	move.b	-(a5),d7
	addx.b	d7,d7
l0163:
	addx.w	d1,d1
	dbf	d0,l0162
	rts

l0164:
	lea	l016d(pc),a1
	moveq	#3,d2
l0165:
	bsr.s	l015f
	dbcc	d2,l0165
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	l0166
	bsr.s	l0161
l0166:
	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	l0168
	lea	l016e(pc),a1
	moveq	#1,d2
l0167:
	bsr.s	l015f
	dbcc	d2,l0167
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	l0161
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	l016a
	sub.w	d4,d1
	bra.s	l016a
l0168:
	moveq	#0,d1
	moveq	#5,d0
	moveq	#$ff,d2
	bsr.s	l015f
	bcc.s	l0169
	moveq	#8,d0
	moveq	#$3f,d2
l0169:
	bsr.s	l0161
	add.w	d2,d1
l016a:
	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
l016b:
	move.b	-(a1),-(a6)
	dbf	d4,l016b
	bra	l015b
	
	dc.b	$7f,$ff,$00,$0e,$00,$ff,$00,$07
	dc.b	$00,$07,$00,$02,$00,$03,$00,$01
	dc.b	$00,$03,$00,$01
l016c:
	dc.b	$00,$00,$01,$0d,$00,$00,$00,$0e
	dc.b	$00,$00,$00,$07,$00,$00,$00,$04
	dc.b	$00,$00,$00,$01
l016d:
	dc.b	$09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b	$01,$00
l016e:
	dc.b	$0b,$04,$07,$00,$01,$1f,$ff,$ff
	dc.b	$00,$1f
l016f:
	link	a3,#$ff88
	movem.l	a0-a6/d0-d7,-(a7)
	lea	120(a0),a4
	movea.l	a4,a6
	bsr.s	l0178
	cmpi.l	#$46495245,d0
	bne.s	l0177
	bsr.s	l0178
	lea	-8(a0,d0.l),a5
	bsr.s	l0178
	move.l	d0,(a7)
	adda.l	d0,a6
	movea.l	a6,a1
	moveq	#$77,d0
l0170:
	move.b	-(a1),-(a3)
	dbf	d0,l0170
	movea.l	a6,a3
	move.b	-(a5),d7
	lea	l0193(pc),a2
	moveq	#1,d6
	swap	d6
	moveq	#0,d5
l0171:
	bsr.s	l017a
	bcc.s	l0174
	moveq	#0,d1
	bsr.s	l017a
	bcc.s	l0173
	movea.l	a2,a0
	moveq	#3,d3
l0172:
	move.l	-(a0),d0
	bsr.s	l017c
	swap	d0
	cmp.w	d0,d1
	dbne	d3,l0172
	add.l	16(a0),d1
l0173:
	move.b	-(a5),-(a6)
	dbf	d1,l0173
l0174:
	cmpa.l	a4,a6
	bgt.s	l0180
	movem.l	(a7),a5/a0-a2/d0-d7
l0175:
	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	l0175
	moveq	#$77,d0
l0176:
	move.b	-(a5),-(a3)
	dbf	d0,l0176
l0177:
	movem.l	(a7)+,a0-a6/d0-d7
	unlk	a3
	rts

l0178:
	moveq	#3,d1
l0179:
	rol.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,l0179
	rts

l017a:
	add.b	d7,d7
	beq.s	l017b
	rts

l017b:
	move.b	-(a5),d7
	addx.b	d7,d7
	rts

l017c:
	moveq	#0,d1
l017d:
	add.b	d7,d7
	beq.s	l017f
l017e:
	addx.w	d1,d1
	dbf	d0,l017d
	rts

l017f:
	move.b	-(a5),d7
	addx.b	d7,d7
	bra.s	l017e
l0180:
	moveq	#1,d0
	bsr.s	l017c
	subq.w	#1,d1
	bmi.s	l0184
	beq.s	l0186
	subq.w	#1,d1
	beq.s	l0187
	bsr.s	l017a
	bcc.s	l0185
	bsr.s	l017a
	bcc.s	l0188
	bra.s	l0189
l0181:
	moveq	#1,d0
	bsr.s	l017c
	subq.w	#1,d1
	bpl.s	l0183
	moveq	#0,d0
	rts

l0182:
	moveq	#1,d0
	bsr.s	l017c
l0183:
	add.w	d1,d1
	add.w	d1,d1
	movem.w	16(a2,d1.w),d5/d0
	bsr.s	l017c
	add.l	d5,d1
	rts

l0184:
	moveq	#1,d0
	bsr.s	l017c
	subq.w	#1,d1
	bmi.s	l018d
	add.w	d1,d1
	add.w	d1,d1
	movem.w	32(a2,d1.w),d2/d0
	bsr.s	l017c
	add.w	d1,d2
	bsr.s	l0182
	move.w	d2,d0
	bra.s	l018f
l0185:
	moveq	#2,d0
	bsr.s	l017c
	moveq	#0,d0
	bset	d1,d0
	bra.s	l018c
l0186:
	moveq	#7,d0
	bsr.s	l017c
	moveq	#0,d0
	bra.s	l0190
l0187:
	bsr.s	l0181
	tst.w	d0
	beq.s	l018c
	moveq	#1,d0
	bra.s	l0190
l0188:
	bsr.s	l0181
	tst.w	d0
	beq.s	l018b
	moveq	#2,d0
	bra.s	l0190
l0189:
	bsr.s	l0181
	tst.w	d0
	beq.s	l018a
	moveq	#3,d0
	bra.s	l0190
l018a:
	moveq	#$ff,d0
	bra.s	l018c
l018b:
	move.b	(a6),d0
l018c:
	move.b	d0,-(a6)
	bra.s	l0192
l018d:
	bsr.s	l0182
	beq.s	l0192
	move.b	(a6),d0
l018e:
	move.b	d0,-(a6)
	dbf	d1,l018e
	sub.l	d6,d1
	bmi.s	l0192
	bra.s	l018e
l018f:
	subq.w	#2,d0
l0190:
	lea	2(a6,d1.l),a0
	adda.w	d0,a0
	move.b	-(a0),-(a6)
l0191:
	move.b	-(a0),-(a6)
	dbf	d0,l0191
l0192:
	bra	l0171

	dc.b	$03,$ff,$00,$09,$00,$07,$00,$02
	dc.b	$00,$03,$00,$01,$00,$03,$00,$01
l0193:
	dc.b	$00,$00,$00,$0e,$00,$00,$00,$07
	dc.b	$00,$00,$00,$04,$00,$00,$00,$01
	dc.b	$00,$03,$00,$00,$00,$07,$00,$10
	dc.b	$00,$0b,$01,$10,$00,$0f,$11,$10
	dc.b	$00,$03,$00,$05,$00,$05,$00,$15
	dc.b	$00,$07,$00,'U'
l0194:
	link	a3,#$ff88
	movem.l	a0-a6/d0-d7,-(a7)
	lea	120(a0),a4
	movea.l	a4,a6
	bsr.s	l019d
	cmpi.l	#$41553521,d0
	bne.s	l019c
	bsr.s	l019d
	lea	-8(a0,d0.l),a5
	bsr.s	l019d
	move.l	d0,(a7)
	adda.l	d0,a6
	movea.l	a6,a1
	moveq	#$77,d0
l0195:
	move.b	-(a1),-(a3)
	dbf	d0,l0195
	movea.l	a6,a3
	move.b	-(a5),d7
	bsr.s	l019f
	movea.l	a3,a5
	bsr.s	l01a3
	bcc.s	l0199
	move.w	#$f9f,d7
l0196:
	moveq	#3,d6
l0197:
	move.w	-(a3),d4
	moveq	#3,d5
l0198:
	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbf	d5,l0198
	dbf	d6,l0197
	movem.w	d0-d3,(a3)
	dbf	d7,l0196
l0199:
	movem.l	(a7),a0-a3/d0-d7
l019a:
	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	l019a
	moveq	#$77,d0
l019b:
	move.b	-(a3),-(a5)
	dbf	d0,l019b
l019c:
	movem.l	(a7)+,a0-a6/d0-d7
	unlk	a3
	rts

l019d:
	moveq	#3,d1
l019e:
	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,l019e
	rts

l019f:
	bsr.s	l01a3
	bcc.s	l01a2
	moveq	#0,d1
	bsr.s	l01a3
	bcc.s	l01a1
	lea	l01b0(pc),a1
	moveq	#4,d3
l01a0:
	move.l	-(a1),d0
	bsr.s	l01a5
	swap	d0
	cmp.w	d0,d1
	dbne	d3,l01a0
	add.l	20(a1),d1
l01a1:
	move.b	-(a5),-(a6)
	dbf	d1,l01a1
l01a2:
	cmpa.l	a4,a6
	bgt.s	l01a8
	rts

l01a3:
	add.b	d7,d7
	bne.s	l01a4
	move.b	-(a5),d7
	addx.b	d7,d7
l01a4:
	rts

l01a5:
	moveq	#0,d1
l01a6:
	add.b	d7,d7
	bne.s	l01a7
	move.b	-(a5),d7
	addx.b	d7,d7
l01a7:
	addx.w	d1,d1
	dbf	d0,l01a6
	rts

l01a8:
	lea	l01b1(pc),a1
	moveq	#3,d2
l01a9:
	bsr.s	l01a3
	dbcc	d2,l01a9
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	l01aa
	bsr.s	l01a5
l01aa:
	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	l01ac
	lea	l01b2(pc),a1
	moveq	#1,d2
l01ab:
	bsr.s	l01a3
	dbcc	d2,l01ab
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	l01a5
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	l01ae
	sub.w	d4,d1
	bra.s	l01ae
l01ac:
	moveq	#0,d1
	moveq	#5,d0
	moveq	#$ff,d2
	bsr.s	l01a3
	bcc.s	l01ad
	moveq	#8,d0
	moveq	#$3f,d2
l01ad:
	bsr.s	l01a5
	add.w	d2,d1
l01ae:
	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
l01af:
	move.b	-(a1),-(a6)
	dbf	d4,l01af
	bra	l019f

	dc.b	$7f,$ff,$00,$0e,$00,$ff,$00,$07
	dc.b	$00,$07,$00,$02,$00,$03,$00,$01
	dc.b	$00,$03,$00,$01
l01b0:
	dc.b	$00,$00,$01,$0d,$00,$00,$00,$0e
	dc.b	$00,$00,$00,$07,$00,$00,$00,$04
	dc.b	$00,$00,$00,$01
l01b1:
	dc.b	$09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b	$01,$00
l01b2:
	dc.b	$0b,$04,$07,$00,$01,$1f,$ff,$ff
	dc.b	$00,$1f
l01b3:
	movem.l	a0-a6/d1-d7,-(a7)
	clr.l	-(a7)
	cmpi.l	#$53503230,(a0)+
	bne.s	l01b8
	tst.w	(a0)
	bne.s	l01b8
	movea.l	a0,a5
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d1,(a7)
	tst.w	d5
	beq.s	l01b4
	swap	d5
	btst	#1,$ffff8260.w
	bne.s	l01b4
	lea	$ffff8240.w,a5
	move.w	(a5),d5
	swap	d5
l01b4:
	lea	64(a0),a1
	movea.l	a1,a2
	adda.l	d0,a0
	adda.l	d1,a1
	movea.l	a1,a3
	movea.l	a7,a6
	moveq	#$4f,d0
l01b5:
	move.b	-(a3),-(a6)
	dbf	d0,l01b5
	exg	a6,a7
	bsr.s	l01b9
	lea	-80(a1),a3
	move.l	(a6),d0
l01b6:
	move.b	(a1)+,(a3)+
	subq.l	#1,d0
	bne.s	l01b6
	exg	a6,a7
	moveq	#$4f,d0
l01b7:
	move.b	(a6)+,(a3)+
	dbf	d0,l01b7
l01b8:
	movem.l	(a7)+,a0-a6/d0-d7
	rts

l01b9:
	moveq	#0,d6
	moveq	#1,d7
	lea	l01d9(pc),a3
	jsr	(a3)
	roxr.l	d7,d0
l01ba:
	add.l	d0,d0
	bne.s	l01bb
	jsr	(a3)
l01bb:
	bcs.s	l01cb
	move.b	-(a0),d1
	bra.s	l01c0
l01bc:
	moveq	#2,d2
	bsr.s	l01c3
	move.l	d6,d1
	bset	d2,d1
	bra.s	l01c0
l01bd:
	add.l	d0,d0
	bne.s	l01be
	jsr	(a3)
l01be:
	bcs	l01d4
	moveq	#3,d2
	bsr.s	l01c3
	add.w	d7,d2
	lsr.w	d7,d2
	bcc.s	l01bf
	not.w	d2
l01bf:
	move.b	(a1),d1
	add.w	d2,d1
l01c0:
	move.b	d1,-(a1)
	clr.w	(a5)
l01c1:
	cmpa.l	a1,a2
	bne.s	l01ba
	swap	d5
	move.w	d5,(a5)
	rts

l01c2:
	move.l	d7,d2
l01c3:
	move.l	d6,d1
l01c4:
	add.l	d0,d0
	bne.s	l01c5
	jsr	(a3)
l01c5:
	addx.w	d1,d1
	dbf	d2,l01c4
l01c6:
	move.l	d1,d2
	rts

l01c7:
	bsr.s	l01c2
l01c8:
	beq.s	l01c9
	move.b	-(a0),d1
	subq.w	#2,d2
	bcs.s	l01c6
l01c9:
	add.w	d7,d2
	add.w	d2,d2
l01ca:
	add.w	d2,d2
	sub.w	d7,d2
	bra.s	l01c4
l01cb:
	add.l	d0,d0
	bne.s	l01cc
	jsr	(a3)
l01cc:
	bcs.s	l01ce
	add.l	d0,d0
	bne.s	l01cd
	jsr	(a3)
l01cd:
	bcs.s	l01bd
	move.l	d6,d1
	move.b	-(a0),d1
	moveq	#0,d3
	bra.s	l01d7
l01ce:
	add.l	d0,d0
	bne.s	l01cf
	jsr	(a3)
l01cf:
	bcs.s	l01d0
	bsr.s	l01c2
	beq.s	l01c0
	moveq	#1,d3
	bra.s	l01d6
l01d0:
	add.l	d0,d0
	bne.s	l01d1
	jsr	(a3)
l01d1:
	bcs	l01bc
	add.l	d0,d0
	bne.s	l01d2
	jsr	(a3)
l01d2:
	bcs.s	l01d3
	bsr.s	l01c2
	beq.s	l01bf
	moveq	#2,d3
	bra.s	l01d6
l01d3:
	moveq	#3,d3
	bsr.s	l01c7
	bra.s	l01d7
l01d4:
	bsr.s	l01c2
	beq.s	l01d5
	move.l	d6,d1
	add.w	d7,d2
	bsr.s	l01ca
	move.l	d2,d3
	bsr.s	l01c7
	bra.s	l01d7
l01d5:
	bsr.s	l01c7
	not.l	d1
	move.l	d2,d3
	bra.s	l01d7
l01d6:
	move.l	d6,d1
	sub.w	d7,d2
	bsr.s	l01c8
l01d7:
	movea.l	a1,a4
	addq.l	#2,a4
	adda.l	d1,a4
	adda.l	d3,a4
	move.b	-(a4),-(a1)
l01d8:
	move.b	-(a4),-(a1)
	dbf	d3,l01d8
	move.w	d5,(a5)
	bra	l01c1
l01d9:
	move.w	a0,d4
	btst	d6,d4
	bne.s	l01da
	move.l	-(a0),d0
	addx.l	d0,d0
	rts

l01da:
	move.l	-5(a0),d0
	lsl.l	#8,d0
	move.b	-(a0),d0
	subq.l	#3,a0
	add.l	d0,d0
	bset	d6,d0
	rts

l01db:
	moveq	#0,d0
	movem.l	a0-a6/d0-d7,-(a7)
	lea	l020f(pc),a6
	movea.l	a0,a1
	cmpi.l	#$53507633,(a1)+
	bne.s	l01dd
	tst.w	(a1)
	bne.s	l01dd
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(a7)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(a7),a1
	lea	402(a6),a3
	moveq	#$7f,d0
l01dc:
	move.l	(a2)+,(a3)+
	dbf	d0,l01dc
	suba.l	a2,a3
	move.l	a3,-(a7)
	bsr.s	l01de
	bsr	l01f0
	move.b	-(a0),d0
	adda.l	(a7)+,a0
	move.b	d0,(a0)+
	lea	402(a6),a2
	bsr	l01f1
	bsr	l01ea
l01dd:
	movem.l	(a7)+,a0-a6/d0-d7
	rts

l01de:
	move	sr,d1
	andi.w	#$2000,d1
	beq.s	l01df
	move.w	$ffff8240.w,2(a6)
	btst	#1,$ffff8260.w
	bne.s	l01df
	swap	d5
l01df:
	clr.w	d5
	move.w	-(a0),d6
	lea	4(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
l01e0:
	cmp.b	d6,d3
	bne.s	l01e1
	addq.w	#2,d3
l01e1:
	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,l01e0
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	273(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
l01e2:
	move.b	-(a0),-(a3)
	dbf	d4,l01e2
	move.b	-(a0),-(a3)
	beq.s	l01e3
	suba.w	d4,a0
l01e3:
	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
l01e4:
	bsr.s	l01e5
	bsr.s	l01e5
	dbf	d2,l01e4
	rts

l01e5:
	not.w	d4
	add.b	d7,d7
	bne.s	l01e6
	move.b	-(a0),d7
	addx.b	d7,d7
l01e6:
	bcs.s	l01e7
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts

l01e7:
	moveq	#2,d1
	bsr	l0207
	add.w	d0,d0
	beq.s	l01e8
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	l0207
	add.w	d0,d0
	move.b	d0,-(a3)
	rts

l01e8:
	moveq	#2,d1
	bsr	l0207
	move.w	12(a6),d1
	add.w	d0,d0
	beq.s	l01e9
	move.w	14(a6),d1
l01e9:
	or.w	d1,d0
	move.w	d0,-(a3)
	rts

l01ea:
	move	sr,d1
	andi.w	#$2000,d1
	beq.s	l01eb
	move.w	2(a6),$ffff8240.w
l01eb:
	tst.w	d6
	bpl.s	l01ef
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(a7),a3
l01ec:
	moveq	#3,d6
l01ed:
	move.w	(a2)+,d0
	moveq	#3,d5
l01ee:
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,l01ee
	dbf	d6,l01ed
	cmpa.l	a2,a3
	blt.s	l01ef
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	l01ec
l01ef:
	rts

l01f0:
	move.b	-(a0),-(a1)
l01f1:
	swap	d5
	beq.s	l01f2
	move.w	d5,$ffff8240.w
l01f2:
	lea	270(a6),a3
	cmpa.l	a0,a2
	blt.s	l01f4
	rts

l01f3:
	adda.w	d3,a3
l01f4:
	add.b	d7,d7
	bcc.s	l01f7
	beq.s	l01f6
l01f5:
	move.w	(a3),d3
	bmi.s	l01f3
	bra.s	l01f8
l01f6:
	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	l01f5
l01f7:
	move.w	-(a3),d3
	bmi.s	l01f3
l01f8:
	ext.w	d3
	jmp	l01f9(pc,d3.w)
l01f9:
	bra.s	l01f9
	bra.s	l0204
	bra.s	l0204
	bra.s	l0204
	bra.s	l0204
	bra.s	l0204
	bra.s	l0200
	bra.s	l01ff
	bra.s	l01fb
	bra.s	l01fc
	bra.s	l01fa
	bra.s	l01fd
	bra.s	l01f0
l01fa:
	move.b	(a5),-(a1)
	bra.s	l01f1
l01fb:
	bsr.s	l0206
	move.b	1(a5,d0.w),-(a1)
	bra.s	l01f1
l01fc:
	bsr.s	l0206
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	l01f1
l01fd:
	moveq	#3,d1
	bsr.s	l0207
	lsr.w	#1,d0
	bcc.s	l01fe
	not.w	d0
l01fe:
	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	l01f1
l01ff:
	lea	-36(a6),a4
	bsr.s	l020b
	addi.w	#$10,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	l01f1
l0200:
	moveq	#3,d1
	bsr.s	l0207
	tst.w	d0
	beq.s	l0201
	addq.w	#5,d0
	bra.s	l0203
l0201:
	move.b	-(a0),d0
	beq.s	l0202
	addi.w	#$14,d0
	bra.s	l0203
l0202:
	moveq	#$d,d1
	bsr.s	l0207
	addi.w	#$114,d0
l0203:
	move.w	d0,d3
	add.w	d3,d3
l0204:
	lea	-34(a6),a4
	bsr.s	l020b
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
l0205:
	move.b	-(a3),-(a1)
	dbf	d3,l0205
	bra	l01f1
l0206:
	moveq	#0,d1
	move.b	(a3),d1
l0207:
	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	l020a
l0208:
	add.b	d7,d7
	beq.s	l0209
	addx.w	d0,d0
	dbf	d1,l0208
	rts

l0209:
	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,l0208
	rts

l020a:
	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	l0208
	rts

l020b:
	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	l0207
	tst.b	d6
	beq.s	l020e
	move.w	d0,d4
	andi.w	#$fff0,d4
	andi.w	#$f,d0
	beq.s	l020d
	lsr.w	#1,d0
	beq.s	l020c
	roxr.b	#1,d7
	bcc.s	l020d
	move.b	d7,(a0)+
	moveq	#$80,d7
	bra.s	l020d
l020c:
	moveq	#2,d1
	bsr.s	l0207
	add.w	d0,d0
	or.w	d4,d0
	bra.s	l020e
l020d:
	lea	4(a6),a3
	or.b	0(a3,d0.w),d4
	move.w	d4,d0
l020e:
	add.w	18(a4),d0
	rts

	dc.b	$00,$03,$00,$04,$00,$05,$00,$07
	dc.b	$00,$08,$00,$09,$00,$0a,$00,$0b
	dc.b	$00,$0c,$ff,$f0,$00,$00,$00,' '
	dc.b	$00,'`',$01,'`',$03,'`',$07,'`'
	dc.b	$0f,'`',$1f,'`'
l020f:
	dcb.w	457,0

; -----------------------------------------------------------------------------
FN_replace_blocks:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d1
	move.l	(a6)+,d0
	movea.l	(a6)+,a0
	move.l	a1,-(a7)
	cmpi.l	#$3031973,(a0)+
	bne.s	l0210
	moveq	#7,d4
	bra.s	l0211
l0210:
	cmpi.l	#$2528e54,-4(a0)
	bne.s	l0214
	moveq	#8,d4
l0211:
	movem.w	(a0)+,d2-d3
	addq.w	#2,d2
	lsr.w	#1,d2
	lsr.w	#1,d3
	mulu	d3,d2
	subq.w	#1,d2
	lsl.w	d4,d0
	lsl.w	d4,d1
l0212:
	move.w	(a0)+,d3
	cmp.w	d3,d0
	bne.s	l0213
	move.w	d1,-2(a0)
l0213:
	dbf	d2,l0212
l0214:
	movea.l	(a7)+,a1
	rts

; -----------------------------------------------------------------------------
FN_dload:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d4
	move.l	(a6)+,d3
	movea.l	(a6)+,a4
	move.l	a3,-(a7)
	movea.l	(a6)+,a3
	moveq	#0,d6
	clr.w	-(a7)
	move.l	a3,-(a7)
	move.w	#$3d,-(a7)		;fopen
	trap	#1
	addq.l	#8,a7
	move.w	d0,d7
	move.w	d0,d6
	cmpi.w	#0,d0
	blt.s	l0216
	clr.w	-(a7)
	move.w	d7,-(a7)
	move.l	d3,-(a7)
	move.w	#$42,-(a7)		;fseek
	trap	#1
	lea	10(a7),a7
	move.w	d0,d6
	cmpi.w	#0,d0
	blt.s	l0215
	move.l	a4,-(a7)
	move.l	d4,-(a7)
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)		;fread
	trap	#1
	lea	12(a7),a7
	move.w	d0,d6
l0215:
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)		;fclose
	trap	#1
	addq.l	#4,a7
l0216:
	movea.l	(a7)+,a3
	move.l	d6,-(a6)
	rts

; -----------------------------------------------------------------------------
FN_display_pc1:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	movem.l	a0-a5,-(a7)
	movea.l	(a6)+,a1
	movea.l	(a6)+,a0
	lea	2(a0),a3
	move.l	a3,$45a.w
	movea.l	a1,a3
	lea	34(a0),a0
	move.w	#$c7,d4
l0217:
	moveq	#3,d3
l0218:
	lea	l0221(pc),a1
	bsr.s	l0219
	bsr.s	l021f
	addq.w	#2,a3
	dbf	d3,l0218
	lea	152(a3),a3
	dbf	d4,l0217
	movem.l	(a7)+,a0-a5
	rts

l0219:
	movem.l	a1-a2/d1,-(a7)
	movea.l	a1,a2
	lea	40(a2),a2
l021a:
	moveq	#0,d1
	move.b	(a0)+,d1
	bmi.s	l021c
l021b:
	move.b	(a0)+,(a1)+
	dbf	d1,l021b
	cmpa.l	a2,a1
	blt.s	l021a
	bra.s	l021e
l021c:
	neg.b	d1
	move.b	(a0)+,d0
l021d:
	move.b	d0,(a1)+
	dbf	d1,l021d
	cmpa.l	a2,a1
	blt.s	l021a
l021e:
	movem.l	(a7)+,a1-a2/d1
	rts

l021f:
	movem.l	a0-a3/d0,-(a7)
	lea	l0221(pc),a0
	moveq	#$13,d0
l0220:
	move.w	(a0)+,(a3)+
	addq.w	#6,a3
	dbf	d0,l0220
	movem.l	(a7)+,a0-a3/d0
	rts

l0221:
	dcb.w	20,0

; -----------------------------------------------------------------------------
FN_dsave:
; -----------------------------------------------------------------------------
	dc.w	0		; no lib calls
; -----------------------------------------------------------------------------
	move.l	(a6)+,d4
	move.l	(a6)+,d3
	movea.l	(a6)+,a4
	move.l	a3,-(a7)
	movea.l	(a6)+,a3
	move.w	#$2f,-(a7)		;fgetdta
	trap	#1
	addq.l	#2,a7
	lea	l0226(pc),a0
	move.l	d0,(a0)
	pea	l0227(pc)
	move.w	#$1a,-(a7)		;dsetdta
	trap	#1
	addq.l	#6,a7
	move.w	#$ffff,-(a7)
	move.l	a3,-(a7)
	move.w	#$4e,-(a7)		;fsfirst
	trap	#1
	addq.l	#8,a7
	moveq	#0,d6
	tst.w	d0
	beq.s	l0222
	clr.w	-(a7)
	move.l	a3,-(a7)
	move.w	#$3c,-(a7)		;fcreate
	trap	#1
	addq.l	#8,a7
	bra.s	l0223
l0222:
	clr.w	-(a7)
	move.l	a3,-(a7)
	move.w	#$3d,-(a7)		;fopen
	trap	#1
	addq.l	#8,a7
l0223:
	move.w	d0,d7
	move.w	d0,d6
	cmpi.w	#0,d0
	blt.s	l0225
	clr.w	-(a7)
	move.w	d7,-(a7)
	move.l	d3,-(a7)
	move.w	#$42,-(a7)		;fseek
	trap	#1
	lea	10(a7),a7
	move.w	d0,d6
	cmpi.w	#0,d0
	blt.s	l0224
	move.l	a4,-(a7)
	move.l	d4,-(a7)
	move.w	d7,-(a7)
	move.w	#$40,-(a7)		;fwrite
	trap	#1
	lea	12(a7),a7
	move.w	d0,d6
l0224:
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)		;fclose
	trap	#1
	addq.l	#4,a7
l0225:
	lea	l0226(pc),a0
	move.l	(a0),-(a7)
	move.w	#$1a,-(a7)		;dsetdta
	trap	#1
	addq.l	#6,a7
	move.l	d6,-(a6)
	movea.l	(a7)+,a3
	rts

l0226:
	dcb.w	2,0
l0227:
	dcb.w	23,0

; terminate extension here

; -----------------------------------------------------------------------------
FN_END:
; -----------------------------------------------------------------------------
	dc.w 0
; -----------------------------------------------------------------------------
