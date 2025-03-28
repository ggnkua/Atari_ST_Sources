
	COMMENT		HEAD=0
	OPT		P=68000,NOTYPE
	OPT		S-
	OPT		W+
	OPT		O-


	text


enable_fixes	=	1

begin:
	bra	INIT

	dc.b	128			; first token ID

; 	token table: [token keyword], [token ID] 
	
TOKENS:
	dc.b	'landscape',128
	dc.b	'overlap',129
	dc.b	'bob',130
	dc.b	'map toggle',131
	dc.b	'wipe',132
	dc.b	'boundary',133
	dc.b	'tile',134
	dc.b	'palt',135
	dc.b	'world',136
	dc.b	'musauto',137
	dc.b	'musplay',138
	dc.b	'which block',139
	dc.b	'relocate',140
	dc.b	'p left',141
	dc.b	'p on',142
	dc.b	'p joy',143
	dc.b	'p stop',144
	dc.b	'p up',145
	dc.b	'set block',146
	dc.b	'p right',147
	dc.b	'palsplit',148
	dc.b	'p down',149
	dc.b	'floodpal',150
	dc.b	'p fire',151
	dc.b	'digi play',152
	dc.b	'string',153
	dc.b	'samsign',154
	dc.b	'depack',155
	dc.b	'replace blocks',156
	dc.b	'dload',157
	dc.b	'display pc1',158
	dc.b	'dsave',159
	dc.b	'honesty',160		; this one not present in compiler ext!
	dc.b	0			; terminate
	even

;	function table

JUMPS:
	dc.w	33	;40		; number of extension commands

	dc.l	FN_landscape
	dc.l	FN_overlap
	dc.l	FN_bob
	dc.l	FN_map_toggle
	dc.l	FN_wipe
	dc.l	FN_boundary
	dc.l	FN_tile
	dc.l	FN_palt
	dc.l	FN_world
	dc.l	FN_musato
	dc.l	FN_musplay
	dc.l	FN_which_block
	dc.l	FN_relocate
	dc.l	FN_p_left
	dc.l	FN_p_on
	dc.l	FN_p_joy
	dc.l	FN_p_stop
	dc.l	FN_p_up
	dc.l	FN_set_block
	dc.l	FN_p_right
	dc.l	FN_palsplit
	dc.l	FN_p_down
	dc.l	FN_floodpal
	dc.l	FN_p_fire
	dc.l	FN_digi_play
	dc.l	FN_string
	dc.l	FN_samsign
	dc.l	FN_depack
	dc.l	FN_replace_blocks
	dc.l	FN_dload
	dc.l	FN_display_pc1
	dc.l	FN_dsave
	dc.l	FN_honesty		; dml: only 33 actually linked in the table?

;	welcom messages: English, French
	
WELCOME:
	dc.b	$0a,$0d,'The Missing Link'
	dc.b	$0a,$0d,'(c) 1993 Top Notch Software.'
	dc.b	$0a,$0d,'* fixes by dml/2016.'
	dc.b	$0a,$0d
	dc.b	$0a,$0d
	dc.b	0
	dc.b	$0a,$0d,'The Missing Link'
	dc.b	$0a,$0d,'(c) 1993 Top Notch Software.'
	dc.b	$0a,$0d,'* fixes by dml/2016.'
	dc.b	$0a,$0d
	dc.b	$0a,$0d
	dc.b	0
	even
	
;	linkage mechanisms
	
SYSTEM:
	dc.l	0
RETURN:
	dc.l	0

INIT:
	lea	EXIT,a0
	lea	COLDST,a1
	rts

;	cold start (point of first loading into STOS)

COLDST:
	move.l	a0,SYSTEM
	lea	WELCOME,a0
	lea	WARMST,a1
	lea	TOKENS,a2
	lea	JUMPS,a3
	movem.l	a0-a6/d0-d7,-(a7)
	move.w	#2,-(a7)		;physbase
	trap	#$e
	addq.w	#2,a7
	movea.l	d0,a1
	movem.l	a0-a6/d1-d7,-(a7)
	move.w	#4,-(a7)		;getrez
	trap	#$e
	addq.w	#2,a7
	movem.l	(a7)+,a0-a6/d1-d7
	move.l	d0,d2
	adda.l	#$6980,a1
	movea.l	a1,a2
	suba.l	#$8000,a2
	lea	l0262(pc),a0
	move.w	#$1a,d0
	cmpi.w	#2,d2
	beq	l0009
	cmpi.w	#1,d2
	beq	l0008
l0007:
	move.w	(a0),(a1)
	move.w	2(a0),8(a1)
	move.w	4(a0),16(a1)
	move.w	6(a0),24(a1)
	lea	160(a1),a1
	move.w	(a0)+,(a2)
	move.w	(a0)+,8(a2)
	move.w	(a0)+,16(a2)
	move.w	(a0)+,24(a2)
	lea	160(a2),a2
	dbf	d0,l0007
	bra.s	l000a
l0008:
	move.w	(a0),(a1)
	move.w	2(a0),4(a1)
	move.w	4(a0),8(a1)
	move.w	6(a0),12(a1)
	lea	160(a1),a1
	move.w	(a0)+,(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,8(a2)
	move.w	(a0)+,12(a2)
	lea	160(a2),a2
	dbf	d0,l0008
	bra.s	l000a
l0009:
	move.w	(a0),(a1)
	move.w	2(a0),2(a1)
	move.w	4(a0),4(a1)
	move.w	6(a0),6(a1)
	lea	80(a1),a1
	move.w	(a0)+,(a2)
	move.w	(a0)+,2(a2)
	move.w	(a0)+,4(a2)
	move.w	(a0)+,6(a2)
	lea	80(a2),a2
	dbf	d0,l0009
l000a:
	move.w	#$4d2,$380.l
	move.w	#$2710,d0
	moveq	#1,d1
	move.w	$ffff8240.w,d3
l000b:
	move.w	#$707,$ffff8240.w
	lsl.w	d1,d2
	move.w	#$77,$ffff8240.w
	lsl.w	d1,d2
	addq.w	#1,d1
	dbf	d0,l000b
	move.w	d3,$ffff8240.w
	movem.l	(a7)+,a0-a6/d0-d7
	rts

;	warm start (response to UNDO keyword)

WARMST:
	movem.l	a0-a6/d0-d7,-(a7)
	lea	l0014(pc),a0
	tst.w	(a0)
	bne	l000d
	move.w	#$ffff,(a0)
	movem.l	a0/d7,-(a7)
	move.l	#2,d0
	moveq	#4,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0016,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0017,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	move.l	#1,d0
	moveq	#4,d7
	trap	#3
	movem.l	(a7)+,a0/d7
l000d:
	lea	l00d0(pc),a2
	tst.w	(a2)
	beq	l000e
	lea	l00d2(pc),a1
	move.l	(a1),$70.l
	lea	l00d0(pc),a1
	move.w	#0,(a1)
	lea	l00d1(pc),a1
	movea.l	(a1),a0
	move.l	#$8000000,$ffff8800.l
	move.l	#$9000000,$ffff8800.l
	move.l	#$a000000,$ffff8800.l
l000e:
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	lea	l000f(pc),a0
	move.l	a0,RETURN
	bra	l00bc
l000f:
	movem.l	(a7)+,a0-a6/d0-d7
	rts

	lea	l0122(pc),a0
	tst.w	(a0)
	beq.s	l0010
	move.w	#0,(a0)
	move	sr,-(a7)
	move	#$2700,sr
	move.l	l0114,$134.w
	move.b	l0123,$fffffa07.w
	move.b	l0124,$fffffa13.w
	move.b	l0125,$fffffa17.w
	move.b	l0126,$fffffa19.w
	move.w	#0,l011e
	move	(a7)+,sr
l0010:
	tst.w	l00fa
	beq.s	l0011
	move	#$2700,sr
	lea	l00f8,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.l	l00f9,$70.w
	move	#$2300,sr
	move.w	#0,l00fa
l0011:
	lea	l00e1(pc),a0
	tst.w	(a0)
	beq.s	l0012
	move.w	#0,(a0)
	move.w	#$22,-(a7)		;kbdvbase
	trap	#$e
	addq.l	#2,a7
	movea.l	d0,a0
	adda.l	#$18,a0
	move.l	$418.l,(a0)
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
l0012:
	movem.l	(a7)+,a0-a6/d0-d7
	rts

honesty_check:
	movea.l	(a7)+,a0
	movem.l	(a7)+,d2-d4
	
;	ifne	(enable_fixes)
	tst.b	d2
	bne.s	l0019
;	endc
	
	jmp	(a0)
	
	dc.b	$00,$00
l0014:
	dc.b	$00,$00
l0015:
	dc.b	$0a,$0d,$00
l0016:
	dc.b	'type ',$27,'honesty',$27,' for registration details',$00
l0017:
	dc.b	'for Missing Link',$00
l0018:
	moveq	#$c,d0
	bra.s	l001b
l0019:
	moveq	#$13,d0
	bra.s	l001b
	moveq	#$d,d0
	bra.s	l001b
l001a:
	moveq	#0,d0
	bra	l001b
l001b:
	movea.l	SYSTEM(pc),a0
	movea.l	20(a0),a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_landscape:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#6,d0
	bne.s	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	move.l	d3,l025f
	bsr	honesty_check
	move.l	d3,l025e
	bsr	honesty_check
	move.l	d3,l025d
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	movea.l	l025a(pc),a0
	movea.l	l025b(pc),a2
	movea.l	l025c(pc),a1
	movem.l	l025d(pc),d6-d7
	move.l	l025f(pc),d0
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
	bne	l0026
	cmpi.l	#$3031973,(a1)+
	bne	l001a
	cmpi.l	#$18e7074c,(a2)+
	bne	l001a
	lea	36(a2),a2
	moveq	#0,d0
	lea	l0030(pc),a3
	adda.w	(a3)+,a0
	move.w	(a3)+,d3
	move.w	(a3),d2
	movem.w	(a1)+,d4-d5
	addq.w	#2,d4
	lea	l0032(pc),a3
	move.w	d4,(a3)
	lsr.w	#1,d5
	subq.w	#1,d5
	subq.w	#1,d5
	sub.w	d2,d5
	lsl.w	#4,d5
	cmp.w	d5,d7
	ble.s	l001d
	move.w	d5,d7
l001d:
	tst.w	d7
	bge.s	l001e
	moveq	#0,d7
l001e:
	tst.w	d6
	bge.s	l001f
	moveq	#0,d6
l001f:
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
	moveq	#0,d4		; dml	
	endc

; todo: this bit can be optimized

l0020:
	movea.l	a6,a2
	adda.w	d7,a2
	
	ifne	(enable_fixes)
	move.w	(a1)+,d4		; dml	
	add.l	d4,a2
	else
	adda.w	(a1)+,a2
	endc
	
	lea	l0021(pc,d7.w),a3

	lea	8(a4),a4
	movea.l	a4,a0
	jmp	(a3)
l0021:
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
	dbf	d1,l0020

	ifne	(enable_fixes)
	moveq	#$13,d4			; dml
	else
	move.w	#$13,d4
	endc
	
	sub.w	d3,d4
	lsl.w	#3,d4
	adda.w	d4,a0
	lea	l0032(pc),a4
	move.w	(a4),d4
	sub.w	d3,d4
	sub.w	d3,d4
	subq.w	#2,d4
	adda.w	d4,a1
	
	ifne	(enable_fixes)
	moveq	#0,d1			; dml
	endc

l0022:
	movea.l	a0,a5
	movea.l	a0,a4
	move.w	d3,d7
l0023:
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
	dbf	d7,l0023
	lea	2560(a5),a0
	adda.w	d4,a1
	dbf	d0,l0022

	ifne	(enable_fixes)
	moveq	#$78,d7			; dml
	else
	move.w	#$78,d7
	endc
	
	sub.w	d6,d7
	move.w	d3,d1
	
	ifne	(enable_fixes)
	lea	l0025(pc,d7.w),a3	; dml
	endc
	
l0024:
	movea.l	a6,a2

	ifne	(enable_fixes)
	move.w	(a1)+,d7		; dml
	add.l	d7,a2
	else
	adda.w	(a1)+,a2
	lea	l0025(pc,d7.w),a3
	endc

	movea.l	a0,a4
	jmp	(a3)
l0025:
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
	dbf	d1,l0024
	
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)

l0026:
	movem.l	l025a(pc),d0-d3
	tst.w	d0
	bge.s	l0027
	moveq	#0,d0
l0027:
	cmpi.w	#$130,d0
	ble.s	l0028
	move.w	#$130,d0
l0028:
	tst.w	d1
	bge.s	l0029
	moveq	#0,d1
l0029:
	cmpi.w	#$b8,d1
	ble.s	l002a
	move.w	#$b8,d1
l002a:
	sub.w	d1,d3
	sub.w	d0,d2
	lsr.w	#4,d3
	lsr.w	#4,d2
	andi.w	#$fff0,d0
	lsr.w	#1,d0
	mulu	#$a0,d1
	add.w	d1,d0
	lea	l0030(pc),a0
	move.w	d0,(a0)
	move.w	d2,d0
	move.w	d3,d1
	subq.w	#1,d0
	subq.w	#2,d1
	tst.w	d0
	bge.s	l002b
	moveq	#0,d0
l002b:
	tst.w	d1
	bge.s	l002c
	moveq	#0,d1
l002c:
	cmpi.w	#$13,d0
	ble.s	l002d
	moveq	#$13,d0
l002d:
	cmpi.w	#$a,d1
	ble.s	l002e
	moveq	#$a,d1
l002e:
	lea	l0031,a0
	move.w	d0,(a0)+
	move.w	d1,(a0)
l002f:
	lea	l0259(pc),a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)
l0030:
	dc.b	$00,$00
l0031:
	dcb.w	2,0
l0032:
	dc.b	$00,$00

; -----------------------------------------------------------------------------
FN_overlap:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmpi.w	#8,d0
	bne	l0018
	bsr	honesty_check
	move.l	d3,l0261
	bsr	honesty_check
	move.l	d3,l0260
	bsr	honesty_check
	move.l	d3,l025f
	bsr	honesty_check
	move.l	d3,l025e
	bsr	honesty_check
	move.l	d3,l025d
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	movem.l	d5-d7,-(a7)
	movem.l	l025a(pc),d0-d7
	movea.w	d0,a0
	adda.w	d4,a0
	cmpa.w	d2,a0
	blt.s	l0034
	movea.w	d2,a0
	adda.w	d6,a0
	cmp.w	a0,d0
	bge.s	l0034
	movea.w	d1,a0
	adda.w	d5,a0
	cmpa.w	d3,a0
	blt.s	l0034
	movea.w	d3,a0
	adda.w	d7,a0
	cmp.w	a0,d1
	bge.s	l0034
	moveq	#$ff,d3
	moveq	#0,d2
	movem.l	(a7)+,d5-d7
	movea.l	RETURN,a0
	jmp	(a0)
l0034:
	moveq	#0,d3
	moveq	#0,d2
	movem.l	(a7)+,d5-d6
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_bob:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#6,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	move.l	d3,l025f
	bsr	honesty_check
	move.l	d3,l025e
	bsr	honesty_check
	move.l	d3,l025d
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	move.l	l025f(pc),d6
	cmpi.w	#1,d6
	beq	l0078
	movem.l	l025a(pc),a0-a1
	movem.l	l025c(pc),d0-d2
	moveq	#0,d3
	move.l	d3,d4
	move.l	d3,d5
	move.l	d3,d7
	movea.l	d3,a2
	movea.l	d3,a3
	movea.l	d3,a4
	movea.l	d3,a5
	movea.l	d3,a6
l0036:
	cmpi.w	#$ffc0,d1
	blt	l007d
l0037:
	cmpi.w	#$140,d1
	bge	l007d
l0038:
	cmpi.w	#$ffc0,d2
	blt	l007d
l0039:
	cmpi.w	#$c8,d2
	bge	l007d
	cmpi.l	#$38964820,(a1)
	bne	l001a
	move.w	4(a1),d7
	cmp.w	d7,d0
	bge	l007d
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
	beq.s	l003a
	sub.w	a5,d3
	bra.s	l003b
l003a:
	subi.w	#$10,d4
l003b:
	adda.l	d3,a1
	cmpi.w	#$63,d6
	bne.s	l003c
	lsr.w	#4,d4
	move.w	d4,d5
	bra	l0075
l003c:
	move.w	#0,d5
	sub.w	d7,d5
	lea	l0040(pc),a2
	move.w	d5,2(a2)
	lea	l0044(pc),a2
	move.w	d7,2(a2)
l003d:
	move.w	#$c7,d5
	sub.w	d7,d5
	lea	l0045(pc),a2
	move.w	d5,2(a2)
	lea	l0046(pc),a2
	move.w	d5,2(a2)
l003e:
	cmpi.w	#$c7,d2
	blt.s	l003f
	bra	l007d
l003f:
	cmpi.w	#0,d2
	bge.s	l0045
l0040:
	cmpi.w	#$fff0,d2
	bgt.s	l0041
	bra	l007d
l0041:
	move.w	#0,d7
	sub.w	d2,d7
	tst.w	d7
	bpl.s	l0042
	neg.w	d7
l0042:
	move.w	d7,d2
	lsl.w	#3,d2
	add.w	d7,d2
	add.w	d7,d2
	add.w	d7,d2
	add.w	d7,d2
	adda.w	d2,a1
l0043:
	move.w	#0,d2
l0044:
	move.w	#$fff0,d6
	sub.w	d7,d6
	move.w	d6,d7
	bra.s	l0047
l0045:
	cmpi.w	#$b8,d2
	ble.s	l0047
	move.l	d2,d6
l0046:
	subi.w	#$b8,d6
	sub.w	d6,d7
l0047:
	lsr.w	#3,d4
	lea	.jtab(pc),a2
	adda.w	0(a2,d4.w),a2
	jmp	(a2)

;	jumptable
.jtab:
;	dc.b	$01,$94,$01,'d',$01,$1a,$00,$a4
;	dc.b	$00,$0a
	dc.w	l0073-.jtab	; jt[0]
	dc.w	l006d-.jtab	; jt[1]
	dc.w	l0064-.jtab	; jt[2]
	dc.w	l0058-.jtab	; jt[3]
	dc.w	l0049-.jtab	; jt[4]

; jt[4]
l0049:
	cmpi.w	#0,d1
	bge.s	l0052
l004a:
	cmpi.w	#$fff0,d1
	blt.s	l004c
	adda.w	a5,a1
	moveq	#3,d5
l004b:
	move.w	#0,d1
	bra	l0075
l004c:
	cmpi.w	#$ffe0,d1
	blt.s	l004e
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#2,d5
l004d:
	move.w	#0,d1
	bra	l0075
l004e:
	cmpi.w	#$ffd0,d1
	blt.s	l0050
	adda.w	a5,a1
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#1,d5
l004f:
	move.w	#0,d1
	bra	l0075
l0050:
	cmpi.w	#$ffc0,d1
	ble	l007d
	adda.w	a5,a1
	adda.w	a5,a1
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#0,d5
l0051:
	move.w	#0,d1
	bra	l0075
l0052:
	cmpi.w	#$140,d1
	bge	l007d
l0053:
	cmpi.w	#$130,d1
	blt.s	l0054
	moveq	#0,d5
	bra	l0075
l0054:
	cmpi.w	#$120,d1
	blt.s	l0055
	moveq	#1,d5
	bra	l0075
l0055:
	cmpi.w	#$110,d1
	blt.s	l0056
	moveq	#2,d5
	bra	l0075
l0056:
	cmpi.w	#$100,d1
	blt.s	l0057
	moveq	#3,d5
	bra	l0075
l0057:
	moveq	#4,d5
	bra	l0075

; jt[3]
l0058:
	cmpi.w	#0,d1
	bge.s	l005f
l0059:
	cmpi.w	#$fff0,d1
	blt.s	l005b
	adda.w	a5,a1
	moveq	#2,d5
l005a:
	move.w	#0,d1
	bra	l0075
l005b:
	cmpi.w	#$ffe0,d1
	blt.s	l005d
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#1,d5
l005c:
	move.w	#0,d1
	bra	l0075
l005d:
	cmpi.w	#$ffd0,d1
	blt	l007d
	adda.w	a5,a1
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#0,d5
l005e:
	move.w	#0,d1
	bra	l0075
l005f:
	cmpi.w	#$140,d1
	bge	l007d
l0060:
	cmpi.w	#$130,d1
	blt.s	l0061
	moveq	#0,d5
	bra	l0075
l0061:
	cmpi.w	#$120,d1
	blt.s	l0062
	moveq	#1,d5
	bra	l0075
l0062:
	cmpi.w	#$110,d1
	blt.s	l0063
	moveq	#2,d5
	bra	l0075
l0063:
	moveq	#3,d5
	bra	l0075

; jt[2]
l0064:
	cmpi.w	#0,d1
	bge.s	l0069
l0065:
	cmpi.w	#$fff0,d1
	blt.s	l0067
	adda.w	a5,a1
	moveq	#1,d5
l0066:
	move.w	#0,d1
	bra.s	l0075
l0067:
	cmpi.w	#$ffe0,d1
	ble	l007d
	adda.w	a5,a1
	adda.w	a5,a1
	moveq	#0,d5
l0068:
	move.w	#0,d1
	bra.s	l0075
l0069:
	cmpi.w	#$140,d1
	bge	l007d
l006a:
	cmpi.w	#$130,d1
	blt.s	l006b
	moveq	#0,d5
	bra.s	l0075
l006b:
	cmpi.w	#$120,d1
	blt.s	l006c
	moveq	#1,d5
	bra.s	l0075
l006c:
	moveq	#2,d5
	bra.s	l0075

; jt[1]
l006d:
	cmpi.w	#0,d1
	bge.s	l0070
l006e:
	cmpi.w	#$fff0,d1
	blt	l007d
	adda.w	a5,a1
	moveq	#0,d5
l006f:
	move.w	#0,d1
	bra.s	l0075
l0070:
	cmpi.w	#$140,d1
	blt.s	l0071
	bra	l007d
l0071:
	cmpi.w	#$130,d1
	blt.s	l0072
	moveq	#0,d5
	bra.s	l0075
l0072:
	moveq	#1,d5
	bra.s	l0075

; jt[0]
l0073:
	cmpi.w	#0,d1
	blt	l007d
l0074:
	cmpi.w	#$140,d1
	bge	l007d
	moveq	#0,d5
l0075:
	andi.w	#$fff0,d1
	lsr.w	#1,d1
	add.w	d2,d2
	lea	global_scanline_table(pc),a2
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
	lea	l0077(pc,d6.w),a4	; dml
	endc
l0076:

	ifne	(enable_fixes)
	else
	lea	l0077(pc,d6.w),a4	; dml
	endc

	jmp	(a4)
l0077:
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
	dbf	d5,l0076
	
	bra	l007d

l0078:
	movem.l	l025a(pc),d0-d3
	cmpi.w	#0,d0
	bge	l0079
	moveq	#0,d0
l0079:
	cmpi.w	#$140,d2
	ble	l007a
	move.w	#$140,d2
l007a:
	cmpi.w	#0,d1
	bge	l007b
	moveq	#0,d1
l007b:
	cmpi.w	#$c8,d3
	ble	l007c
	move.w	#$c8,d3
l007c:
	andi.w	#$fff0,d0
	andi.w	#$fff0,d2
	lea	l003f(pc),a0
	move.w	d1,2(a0)
	lea	l0043(pc),a0
	move.w	d1,2(a0)
	lea	l0041(pc),a0
	move.w	d1,2(a0)
	lea	l003c(pc),a0
	move.w	d1,2(a0)
	subi.w	#$40,d1
	lea	l0038(pc),a0
	move.w	d1,2(a0)
	lea	l003e(pc),a0
	move.w	d3,2(a0)
	lea	l003d(pc),a0
	move.w	d3,2(a0)
	lea	l0039(pc),a0
	move.w	d3,2(a0)
	lea	l006d(pc),a0
	move.w	d0,2(a0)
	lea	l0073(pc),a0
	move.w	d0,2(a0)
	lea	l0064(pc),a0
	move.w	d0,2(a0)
	lea	l0066(pc),a0
	move.w	d0,2(a0)
	lea	l0068(pc),a0
	move.w	d0,2(a0)
	lea	l006f(pc),a0
	move.w	d0,2(a0)
	lea	l0058(pc),a0
	move.w	d0,2(a0)
	lea	l005a(pc),a0
	move.w	d0,2(a0)
	lea	l005c(pc),a0
	move.w	d0,2(a0)
	lea	l005e(pc),a0
	move.w	d0,2(a0)
	lea	l0049(pc),a0
	move.w	d0,2(a0)
	lea	l004b(pc),a0
	move.w	d0,2(a0)
	lea	l004d(pc),a0
	move.w	d0,2(a0)
	lea	l004f(pc),a0
	move.w	d0,2(a0)
	lea	l0051(pc),a0
	move.w	d0,2(a0)
	subi.w	#$10,d0
	lea	l006e(pc),a0
	move.w	d0,2(a0)
	lea	l0065(pc),a0
	move.w	d0,2(a0)
	lea	l0059(pc),a0
	move.w	d0,2(a0)
	lea	l004a(pc),a0
	move.w	d0,2(a0)
	subi.w	#$10,d0
	lea	l0067(pc),a0
	move.w	d0,2(a0)
	lea	l005b(pc),a0
	move.w	d0,2(a0)
	lea	l004c(pc),a0
	move.w	d0,2(a0)
	subi.w	#$10,d0
	lea	l005d(pc),a0
	move.w	d0,2(a0)
	lea	l004e(pc),a0
	move.w	d0,2(a0)
	subi.w	#$10,d0
	lea	l0050(pc),a0
	lea	l0036(pc),a0
	move.w	d0,2(a0)
	lea	l0070(pc),a0
	move.w	d2,2(a0)
	lea	l0069(pc),a0
	move.w	d2,2(a0)
	lea	l005f(pc),a0
	move.w	d2,2(a0)
	lea	l0074(pc),a0
	move.w	d2,2(a0)
	lea	l0052(pc),a0
	move.w	d2,2(a0)
	lea	l0037(pc),a0
	move.w	d2,2(a0)
	subi.w	#$10,d2
	lea	l0071(pc),a0
	move.w	d2,2(a0)
	lea	l006a(pc),a0
	move.w	d2,2(a0)
	lea	l0060(pc),a0
	move.w	d2,2(a0)
	lea	l0053(pc),a0
	move.w	d2,2(a0)
	subi.w	#$10,d2
	lea	l006b(pc),a0
	move.w	d2,2(a0)
	lea	l0061(pc),a0
	move.w	d2,2(a0)
	lea	l0054(pc),a0
	move.w	d2,2(a0)
	subi.w	#$10,d2
	lea	l0062(pc),a0
	move.w	d2,2(a0)
	lea	l0055(pc),a0
	move.w	d2,2(a0)
	subi.w	#$10,d2
	lea	l0056(pc),a0
	move.w	d2,2(a0)
l007d:
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_map_toggle:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmpi.w	#1,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	movea.l	d3,a0
	cmpi.l	#$3031973,(a0)
	bne.s	l007f
	moveq	#7,d4
	moveq	#8,d5
	move.l	#$2528e54,(a0)+
	bra.s	l0080
l007f:
	cmpi.l	#$2528e54,(a0)
	bne	l001a
	moveq	#8,d4
	moveq	#7,d5
	move.l	#$3031973,(a0)+
l0080:
	moveq	#0,d2
	movem.w	(a0)+,d2-d3
	addq.w	#2,d2
	lsr.w	#1,d2
	lsr.w	#1,d3
	mulu	d3,d2
	subq.w	#1,d2
l0081:
	move.w	(a0),d3
	lsr.w	d4,d3
	lsl.w	d5,d3
	move.w	d3,(a0)+
	dbf	d2,l0081
	moveq	#0,d2
	moveq	#0,d3
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_wipe:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmpi.w	#1,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	movea.l	d3,a6
	lea	32000(a6),a6
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
l0083:
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
	dbf	d0,l0083
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
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_boundary:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmpi.w	#1,d0
	bne	l0018
	bsr	honesty_check
	andi.w	#$fff0,d3
	moveq	#0,d2
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_tile:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#5,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	move.l	d3,l025e
	bsr	honesty_check
	move.l	d3,l025d
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	movem.l	l025a(pc),a0-a1
	movem.l	l025c(pc),d0-d2
	cmpi.l	#$3d2067,(a1)+
	bne	l0088
	move.w	(a1)+,d3
	cmp.w	d3,d0
	bne.s	l0086
	move.w	d3,d0
l0086:
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
l0087:
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
	dbf	d7,l0087
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
l0088:
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_palt:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	bsr	honesty_check
	movea.l	d3,a0
	cmpi.l	#$19861987,(a0)
	beq.s	l008e
	cmpi.l	#$3d2067,(a0)
	bne.s	l008a
	moveq	#6,d1
	bra.s	l0090
l008a:
	cmpi.l	#$7793868,(a0)
	bne.s	l008b
	moveq	#8,d1
	bra.s	l0090
l008b:
	cmpi.l	#$18e7074c,(a0)
	bne.s	l008c
	moveq	#8,d1
	bra.s	l0090
l008c:
	cmpi.l	#$38964820,(a0)
	bne.s	l008d
	move.w	#6,d1
	bra.s	l0090
l008d:
	bra	l001a
l008e:
	move.l	#$1f3ff,d0
	moveq	#4,d1
l008f:
	cmpi.l	#$50414c54,(a0)
	beq.s	l0090
	lea	2(a0),a0
	dbf	d0,l008f
	bra	l001a
l0090:
	adda.l	d1,a0
	move.l	a0,$45a.l
	move.l	a0,d3
	moveq	#0,d2
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_world:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmpi.w	#6,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	move.l	d3,l025f
	bsr	honesty_check
	move.l	d3,l025e
	bsr	honesty_check
	move.l	d3,l025d
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	movem.l	l025a(pc),a0-a2
	movem.l	l025d(pc),d2-d3
	move.l	l025f(pc),d7
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	tst.w	d7
	bne	l00a0
	cmpi.l	#$7793868,(a1)+
	bne	l001a
	cmpi.l	#$2528e54,(a2)+
	bne	l001a
	tst.w	d2
	bge.s	l0092
	moveq	#0,d2
l0092:
	tst.w	d3
	bge.s	l0093
	moveq	#0,d3
l0093:
	movem.w	(a2)+,d0-d1
	move.w	d0,l00aa
	subq.w	#2,d1
	lsr.w	#1,d0
	lsr.w	#1,d1
	lea	l00a9(pc),a5
	sub.w	(a5)+,d0
	sub.w	(a5),d1
	lsl.w	#4,d0
	lsl.w	#4,d1
	cmp.w	d0,d2
	ble.s	l0094
	move.w	d0,d2
l0094:
	cmp.w	d1,d3
	ble.s	l0095
	move.w	d1,d3
l0095:
	movem.w	l00a9(pc),d0-d1
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
	move.w	d3,l00ab
	lsr.w	#4,d2
	tst.w	d2
	bge.s	l0096
	moveq	#0,d2
	bra.s	l0097
l0096:
	move.w	l00aa(pc),d6
	addq.w	#2,d6
	mulu	d6,d2
l0097:
	adda.l	d2,a2
	moveq	#0,d5
	move.l	d5,d6
	adda.w	l00ac(pc),a0
	moveq	#0,d7
	move.l	a0,-(a7)
	move.l	a2,-(a7)
	move.w	d3,d7
	lsl.w	#3,d7
	move.w	d7,d2
	add.w	d7,d7
	move.w	d3,d4
	add.w	d4,d4
	lea	global_scanline_table(pc),a5
	adda.w	d4,a5
	move.w	#$960,d6
	sub.w	(a5),d6

	ifne	(enable_fixes)
	lea	l0099(pc,d7.w),a4		; dml
	endc

l0098:
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
	lea	l0099(pc,d7.w),a4
	endc	
	
	jmp	(a4)
l0099:
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
	suba.w	d6,a0
	lea	8(a0),a0
	dbf	d0,l0098
	
	subq.w	#1,d1
	movea.l	(a7)+,a2
	addq.w	#2,a2
	movea.l	(a7)+,a0
	lea	160(a0),a0
	adda.w	d6,a0
	adda.w	l00aa(pc),a2
	tst.w	d1
	bge.s	l009a
	movem.w	l00a9(pc),d0-d1
	bra	l009d
l009a:
	move.w	l00a9(pc),d0
	movea.l	a0,a4
	move.l	a0,-(a7)
	move.w	d1,-(a7)
l009b:
	move.w	(a7),d1
	move.l	a2,-(a7)
l009c:
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
	adda.w	l00aa(pc),a2
	dbf	d1,l009c
	
	lea	8(a4),a4
	movea.l	a4,a0
	movea.l	(a7)+,a2
	lea	2(a2),a2
	dbf	d0,l009b
	addq.w	#2,a7
	movea.l	(a7)+,a0
	movem.w	l00a9(pc),d0-d1
	suba.w	d0,a2
	suba.w	d0,a2
	subq.w	#2,a2
	moveq	#0,d7
	move.w	l00aa(pc),d7
	addq.w	#2,d7
	mulu	d1,d7
	adda.w	d7,a2
	lsl.w	#5,d1
	lea	global_scanline_table(pc),a5
	adda.w	d1,a5
	adda.w	(a5),a0
l009d:
	move.w	l00ab(pc),d1
	tst.w	d1
	beq	l002f
	moveq	#$f,d7
	sub.w	d1,d7
	lsl.w	#4,d7

	ifne	(enable_fixes)
	lea	l009f(pc,d7.w),a4		; dml
	endc

l009e:
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
	lea	l009f(pc,d7.w),a4
	endc

	movea.l	a0,a1
	jmp	(a4)
l009f:
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
	dbf	d0,l009e
	
	bra	l002f
l00a0:
	movem.l	l025a(pc),d0-d3
	tst.w	d0
	bge.s	l00a1
	moveq	#0,d0
l00a1:
	cmpi.w	#$130,d0
	ble.s	l00a2
	move.w	#$130,d0
l00a2:
	tst.w	d1
	bge.s	l00a3
	moveq	#0,d1
l00a3:
	cmpi.w	#$b8,d1
	ble.s	l00a4
	move.w	#$b8,d1
l00a4:
	sub.w	d1,d3
	sub.w	d0,d2
	lsr.w	#4,d3
	lsr.w	#4,d2
	andi.w	#$fff0,d0
	lsr.w	#1,d0
	add.w	d1,d1
	lea	global_scanline_table(pc),a0
	adda.w	d1,a0
	add.w	(a0),d0
	lea	l00ac(pc),a0
	move.w	d0,(a0)
	move.w	d2,d0
	move.w	d3,d1
	subq.w	#1,d0
	subq.w	#1,d1
	tst.w	d0
	bge.s	l00a5
	moveq	#0,d0
l00a5:
	tst.w	d1
	bge.s	l00a6
	moveq	#0,d1
l00a6:
	cmpi.w	#$13,d0
	ble.s	l00a7
	moveq	#$13,d0
l00a7:
	cmpi.w	#$b,d1
	ble.s	l00a8
	moveq	#$b,d1
l00a8:
	lea	l00a9,a0
	move.w	d0,(a0)+
	move.w	d1,(a0)
	lea	l0259(pc),a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)

l00a9:
	dc.b	$00,$13,$00,$0b
l00aa:
	dc.b	$00,$00
l00ab:
	dc.b	$00,$00
l00ac:
	dc.b	$00,$00

; **********

; -----------------------------------------------------------------------------
FN_musato:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmpi.w	#3,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	move.l	d3,d1
	bsr	honesty_check
	move.l	d3,d6
	bsr	honesty_check
	movea.l	d3,a1
	cmpa.l	#0,a1
	beq	l00bc
	lea	l00c7(pc),a3
	tst.w	(a3)
	bge	l00b2
	lea	l00c5(pc),a3
	move.l	a1,(a3)
	lea	l00c6(pc),a3
	move.l	d6,(a3)
	lea	l00c8(pc),a0
	move.l	$70.w,(a0)+
	move.l	$110.w,(a0)+
	move.b	$fffffa01.w,(a0)+
	move.b	$fffffa03.w,(a0)+
	move.b	$fffffa05.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa0b.w,(a0)+
	move.b	$fffffa0d.w,(a0)+
	move.b	$fffffa0f.w,(a0)+
	move.b	$fffffa11.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	move.b	$fffffa1f.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	move.b	$484.w,(a0)+
	andi.b	#$fa,$484.w
	movea.l	a1,a0
	move.l	d1,d7
l00ae:
	lea	l00ca(pc),a1
	move.b	(a0),d1
	move.b	1(a0),d2
	move.b	2(a0),d3
	move.b	3(a0),d4
	move.w	#$20,d0
l00af:
	cmp.b	(a1),d1
	bne.s	l00b0
	cmp.b	1(a1),d2
	bne.s	l00b0
	cmp.b	2(a1),d3
	bne.s	l00b0
	cmp.b	3(a1),d4
	beq	l00b1
l00b0:
	addq.l	#4,a1
	dbf	d0,l00af
	addq.l	#1,a0
	dbf	d7,l00ae
	moveq	#0,d3
	lea	l00c7(pc),a3
	move.w	#$ffff,(a3)
	bra	l00ba
l00b1:
	move.w	#$20,d1
	sub.w	d0,d1
	lea	l00c7(pc),a2
	move.w	d1,(a2)
l00b2:
	move.w	l00c7(pc),d0
	move.l	l00c6(pc),d7
	add.w	d0,d0
	lea	l00b3(pc),a0
	adda.w	0(a0,d0.w),a0
	jmp	(a0)

;	jumptable
l00b3:
	dc.b	$00,'@',$00,'@',$00,'F',$00,'L'
	dc.b	$00,'T',$00,'V',$00,'^',$00,'f'
	dc.b	$00,'j',$00,'p',$00,'x',$00,'|'
	dc.b	$00,$80,$00,$84,$00,$88,$00,$96
	dc.b	$00,$9c,$00,$d0,$00,$ea,$00,$f2
	dc.b	$00,$fa,$01,$06,$01,$12,$01,$16
	dc.b	$01,$1a,$01,'"',$01,':',$01,'B'
	dc.b	$01,'F',$01,'J',$01,'N',$00,'x'
l00b4:
	moveq	#8,d6
	bra	l00b8
l00b5:
	moveq	#6,d6
	bra	l00b8
l00b6:
	moveq	#4,d6
	moveq	#1,d7
	bra	l00b8
	bra.s	l00b6
	moveq	#8,d6
	moveq	#0,d7
	bra	l00b8
	moveq	#8,d6
	moveq	#1,d7
	bra	l00b8
	bra	l00b4
	moveq	#$3e,d6
	bra	l00b8
l00b7:
	moveq	#8,d6
	moveq	#1,d7
	bra	l00b8
	bra	l00b4
	bra	l00b4
	bra	l00b4
	bra	l00b6
	movea.l	l00c5(pc),a0
	move.w	#$ff00,(a0)
	moveq	#2,d6
	bra	l00b9
	moveq	#1,d7
	bra	l00b5
	movea.l	l00c5(pc),a3
	lea	350(a3),a0
	lea	368(a3),a1
	move.l	a0,10(a1)
	move.l	a1,10(a0)
	adda.l	#$20,a3
	jsr	(a3)
	movea.l	l00c5(pc),a3
	lea	1774(a3),a0
	jsr	(a3)
	movea.l	l00c5(pc),a3
	move.l	#$138,d6
	bra	l00b9
	movea.l	l00c5(pc),a3
	moveq	#0,d0
	jsr	(a3)
	movea.l	l00c5(pc),a3
	adda.l	#$12,a3
	jsr	(a3)
	moveq	#$1a,d6
	bra	l00b9
	moveq	#4,d6
	subq.l	#1,d7
	bra	l00b8
	moveq	#0,d7
	moveq	#2,d6
	bra	l00b8
	moveq	#0,d7
	move.l	#$a8,d6
	bra	l00b8
	moveq	#0,d7
	move.l	#$9c,d6
	bra	l00b8
	bra	l00b6
	bra	l00b6
	moveq	#1,d7
	moveq	#$10,d6
	bra	l00b8
	movea.l	l00c5(pc),a3
	jsr	(a3)
	movea.l	l00c5(pc),a3
	addq.l	#4,a3
	move.l	l00c6(pc),d0
	jsr	(a3)
	moveq	#8,d6
	bra	l00b9
	moveq	#0,d7
	moveq	#$22,d6
	bra	l00b8
	bra	l00b7
	bra	l00b7
	bra	l00b4
	move.w	#1,d7
	bra	l00b5
l00b8:
	move.l	d6,-(a7)
	movea.l	l00c5(pc),a0
	move.l	d7,d0
	jsr	(a0)
	move.l	(a7)+,d6
l00b9:
	moveq	#0,d3
	move.w	l00c7(pc),d3
	addq.l	#1,d3
	lea	l00c9(pc),a0
	move.l	d6,(a0)
	lea	l00bb(pc),a0
	move.l	a0,$70.w
l00ba:
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	moveq	#0,d2
	movea.l	RETURN(pc),a0
	jmp	(a0)
l00bb:
	movem.l	a0-a6/d0-d7,-(a7)
	movea.l	l00c5(pc),a0
	move.l	l00c9(pc),d0
	adda.l	d0,a0
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	move.l	l00c8(pc),-(a7)
	rts

l00bc:
	lea	l00c7(pc),a3
	tst.w	(a3)
	bmi	l00c4
	move.l	l00c8(pc),$70.w
	moveq	#0,d0
	move.w	l00c7(pc),d0
	add.w	d0,d0
	lea	l00bd(pc),a0
	adda.w	0(a0,d0.w),a0
	jmp	(a0)

;	jumptable
l00bd:
	dc.b	$00,'@',$00,'@',$00,'H',$00,'P'
	dc.b	$00,'T',$00,'X',$00,'`',$00,'h'
	dc.b	$00,'l',$00,'p',$00,'x',$00,'|'
	dc.b	$00,$80,$00,$84,$00,$88,$00,$96
	dc.b	$00,$9a,$00,$a6,$00,$be,$00,$c2
	dc.b	$00,$c6,$00,$ca,$00,$ce,$00,$d2
	dc.b	$00,$d6,$00,$da,$00,$de,$00,$e2
	dc.b	$00,$e6,$00,$ea,$00,$ee,$00,'x'
l00be:
	moveq	#4,d6
	moveq	#0,d7
	bra	l00c2
l00bf:
	moveq	#2,d6
	moveq	#0,d7
	bra	l00c2
l00c0:
	bra	l00c3
	bra	l00c0
	moveq	#0,d6
	moveq	#1,d7
	bra	l00c2
	moveq	#0,d6
	moveq	#0,d6
	bra	l00c2
	bra	l00be
	bra	l00c3
l00c1:
	moveq	#0,d6
	moveq	#0,d7
	bra	l00c2
	bra	l00be
	bra	l00be
	bra	l00be
	bra	l00c3
	movea.l	l00c5(pc),a0
	move.w	#$ffff,(a0)+
	jsr	(a0)
	bra	l00c3
	bra	l00bf
	move.l	#$92,d6
	moveq	#0,d7
	bra	l00c2
	move.l	#$ff,d0
	movea.l	l00c5(pc),a0
	jsr	(a0)
	move.l	#$12,d6
	moveq	#$ff,d0
	bra	l00c2
	bra	l00c3
	bra	l00be
	bra	l00c3
	bra	l00c3
	bra	l00c3
	bra	l00c3
	bra	l00c3
	bra	l00c3
	bra	l00c3
	bra	l00c1
	bra	l00c1
	bra	l00be
	bra	l00bf
l00c2:
	movea.l	l00c5(pc),a0
	adda.l	d6,a0
	move.l	d7,d0
	jsr	(a0)
l00c3:
	lea	l00c8(pc),a0
	move.l	(a0)+,$70.w
	move.l	(a0)+,$110.w
	move.b	(a0)+,$fffffa01.w
	move.b	(a0)+,$fffffa03.w
	move.b	(a0)+,$fffffa05.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa0b.w
	move.b	(a0)+,$fffffa0d.w
	move.b	(a0)+,$fffffa0f.w
	move.b	(a0)+,$fffffa11.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1d.w
	move.b	(a0)+,$fffffa1f.w
	move.b	(a0)+,$fffffa21.w
	move.b	(a0)+,$484.w
	lea	$ffff8800.w,a0
	move.l	#$707ffff,(a0)
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
	lea	l00c7(pc),a3
	move.w	#$ffff,(a3)
l00c4:
	moveq	#0,d3
	bra	l00ba
l00c5:
	dcb.w	2,0
l00c6:
	dcb.w	2,0
l00c7:
	dc.b	$ff,$ff
l00c8:
	dcb.w	40,0
l00c9:
	dcb.w	2,0
l00ca:
	dc.b	'TFMXCOSO'
	dc.b	'CounYM21'
	dc.b	'THIZTOJG'
	dc.b	'-TAOP 90'
	dc.b	'P 19BADF'
	dc.b	'illeUNDE'
	dc.b	'ZOUNENEX'
	dc.b	'MYSTTriM'
	dc.b	'LAP9 C D'
	dc.b	'Rip:NEXU'
	dc.b	'HRISHRIS'
	dc.b	'QQQQBIRD'
	dc.b	'Blip G.S'
	dc.b	'LARYa6J@'
	dc.b	'lineILLE'
	dc.b	'AXX THKE'
	dc.b	'&',$00
	moveq	#0,d2
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_musplay:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#3,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	movea.l	l025a(pc),a0
	movem.l	l025b(pc),d0-d1
	tst.w	d0
	beq	l00cd
	lea	l00d0(pc),a1
	tst.w	(a1)
	bne	l00cc
	move.w	#1,(a1)
	lea	l00d2(pc),a1
	move.l	$70.w,(a1)
l00cc:
	movem.l	a0-a6/d0-d7,-(a7)
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	adda.l	d1,a0
	lea	l00d1(pc),a1
	move.l	a0,(a1)
	lea	l00ce(pc),a0
	move.l	a0,$70.w
	bra	l00cf
l00cd:
	lea	l00d0(pc),a2
	tst.w	(a2)
	beq	l00cf
	lea	l00d2(pc),a1
	move.l	(a1),$70.l
	lea	l00d0(pc),a1
	move.w	#0,(a1)
	lea	l00d1(pc),a1
	movea.l	(a1),a0
	move.l	#$8000000,$ffff8800.l
	move.l	#$9000000,$ffff8800.l
	move.l	#$a000000,$ffff8800.l
	bra.s	l00cf
l00ce:
	movem.l	a0-a6/d0-d7,-(a7)
	movea.l	l00d1(pc),a0
	jsr	(a0)
	movem.l	(a7)+,a0-a6/d0-d7
	move.l	l00d2(pc),-(a7)
	rts

l00cf:
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)
l00d0:
	dc.b	$00,$00
l00d1:
	dcb.w	2,0
l00d2:
	dcb.w	2,0

; -----------------------------------------------------------------------------
FN_which_block:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#3,d0
	bne	l0018
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	movea.l	l025a(pc),a0
	move.l	l025b(pc),d0
	move.l	l025c(pc),d1
	cmpi.l	#$3031973,(a0)+
	bne.s	l00d4
	moveq	#7,d5
	bra.s	l00d5
l00d4:
	cmpi.l	#$2528e54,-4(a0)
	bne	l001a
	moveq	#8,d5
l00d5:
	tst.w	d0
	blt.s	l00d7
	tst.w	d1
	blt.s	l00d7
	moveq	#0,d4
	move.w	(a0)+,d4
	addq.w	#2,d4
	lsl.w	#3,d4
	cmp.w	d4,d0
	bge.s	l00d7
	lsr.w	#3,d4
	move.w	(a0)+,d6
	lsl.w	#3,d6
	cmp.w	d6,d1
	bge.s	l00d7
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
	bge	l00d6
	move.l	#$ffff,d3
l00d6:
	moveq	#0,d2
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)
l00d7:
	move.l	#$ffff,d3
	bra.s	l00d6

; -----------------------------------------------------------------------------
FN_relocate:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	movea.l	d3,a0
	cmpi.w	#$601a,(a0)
	beq.s	l00d9
	bra.s	l00dd
l00d9:
	move.l	a0,d2
	addi.l	#$1c,d2
	lea	28(a0),a1
	movea.l	a1,a2
	adda.l	2(a0),a2
	adda.l	(a2)+,a1
	add.l	d2,(a1)
l00da:
	tst.b	(a2)
	beq.s	l00dd
	moveq	#0,d1
l00db:
	moveq	#0,d0
	move.b	(a2)+,d0
	cmp.b	#1,d0
	bne.s	l00dc
	addi.w	#$fe,d1
	bra.s	l00db
l00dc:
	add.w	d0,d1
	adda.w	d1,a1
	add.l	d2,(a1)
	bra.s	l00da
l00dd:
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_p_on:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	lea	l00e1(pc),a0
	tst.w	(a0)
	bne.s	l00df
	move.w	#1,(a0)
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
	move.l	(a0),$418.l
	lea	l00e0(pc),a1
	move.l	a1,(a0)
l00df:
	movea.l	RETURN,a0
	jmp	(a0)
l00e0:
	dc.b	'H',$e7,$00,$c0,$13,$e8,$00,$01
	dc.b	$00,$00,$04,$1c,$13,$e8,$00,$02
	dc.b	$00,$00,$04,$1d,'L',$df,$03,$00
	dc.b	'Nu'
l00e1:
	dc.b	$00,$00

; -----------------------------------------------------------------------------
FN_p_joy:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmpi.b	#1,d0
	bne	l0018
	bsr	honesty_check
	tst.b	d3
	bne.s	l00e3
	moveq	#0,d3
	move.b	$41c.l,d3
	bra.s	l00e4
l00e3:
	moveq	#0,d3
	move.b	$41d.l,d3
l00e4:
	moveq	#0,d2
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_p_stop:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	lea	l00e1(pc),a0
	tst.w	(a0)
	beq.s	l00e6
	move.w	#0,(a0)
	move.w	#$22,-(a7)		;kbdvbase
	trap	#$e
	addq.l	#2,a7
	movea.l	d0,a0
	adda.l	#$18,a0
	move.l	$418.l,(a0)
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
l00e6:
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_set_block:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#4,d0
	bne	l0018
	bsr	honesty_check
	move.l	d3,l025d
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	movea.l	d3,a0
	movem.l	l025b(pc),d0-d2
	cmpi.l	#$3031973,(a0)+
	bne.s	l00e8
	lsl.w	#7,d2
	bra.s	l00e9
l00e8:
	cmpi.l	#$2528e54,-4(a0)
	bne	l001a
	lsl.w	#8,d2
l00e9:
	tst.w	d0
	blt	l00ea
	tst.w	d1
	blt	l00ea
	moveq	#0,d3
	move.w	(a0)+,d3
	addq.w	#2,d3
	lsl.w	#3,d3
	cmp.w	d3,d0
	bge	l00ea
	lsr.w	#3,d3
	move.w	(a0)+,d4
	lsl.w	#3,d4
	cmp.w	d4,d1
	bge	l00ea
	andi.w	#$fff0,d0
	lsr.w	#3,d0
	lsr.w	#4,d1
	mulu	d1,d3
	adda.w	d0,a0
	adda.l	d3,a0
	move.w	d2,(a0)
l00ea:
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_palsplit:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmpi.w	#5,d0
	bne	l0018
	bsr	honesty_check
	move.l	d3,l025e
	bsr	honesty_check
	move.l	d3,l025d
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	lea	l025a,a0
	movem.l	a0-a2/d0-d1,-(a0)
	move.l	l025a(pc),d1
	movea.l	l025b(pc),a0
	move.l	l025c(pc),d0
	movem.l	l025d(pc),d2-d3
	tst.w	d1
	beq	l00ef
	cmpi.w	#2,d2
	bge.s	l00ec
	moveq	#2,d2
l00ec:
	tst.w	l00fa
	beq.s	l00ed
	clr.b	$fffffa1b.l
	lea	l00f2(pc),a2
	move.b	d0,2(a2)
	lea	l00f3(pc),a2
	move.b	d2,2(a2)
	lea	l00fb(pc),a2
	move.w	d3,(a2)
	move.b	#8,$fffffa1b.l
	bra	l00f0
l00ed:
	lea	l00f2(pc),a2
	move.w	d0,2(a2)
	lea	l00f3(pc),a2
	move.w	d2,2(a2)
	lea	l00fd(pc),a2
	move.l	a0,(a2)
	lea	l00fb(pc),a2
	move.w	d3,(a2)
	lea	$ffff8240.l,a0
	lea	l00f1,a1
	lea	2(a1),a1
	move.w	#7,d0
l00ee:
	move.l	(a0)+,(a1)
	lea	8(a1),a1
	dbf	d0,l00ee
	lea	l00f8,a0
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move	#$2700,sr
	ori.b	#1,$fffffa07.w
	ori.b	#1,$fffffa13.w
	bclr	#3,$fffffa17.w
	clr.b	$fffffa1b.w
	move.l	$70.w,l00f9
	move.l	#l00f1,$70.w
	move	#$2300,sr
	move.w	#1,l00fa
	bra.s	l00f0
l00ef:
	tst.w	l00fa
	beq.s	l00f0
	move	#$2700,sr
	lea	l00f8,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.l	l00f9,$70.w
	move	#$2300,sr
	move.w	#0,l00fa
l00f0:
	lea	l0259,a0
	movem.l	(a7)+,a0-a2/d0-d1
	movea.l	RETURN,a0
	jmp	(a0)
l00f1:
	move.l	#$777,$ffff8240.w
	move.l	#$777,$ffff8244.w
	move.l	#$777,$ffff8248.w
	move.l	#$777,$ffff824c.w
	move.l	#$777,$ffff8250.w
	move.l	#$777,$ffff8254.w
	move.l	#$777,$ffff8258.w
	move.l	#$333222,$ffff825c.w
	movem.l	a0-a1,-(a7)
	lea	l00fd(pc),a1
	movea.l	(a1),a0
	lea	l00f5,a1
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
	lea	l00fe(pc),a1
	move.l	a0,(a1)
	lea	l00fb(pc),a0
	lea	l00fc(pc),a1
	move.w	(a0),(a1)
	movem.l	(a7)+,a0-a1
	clr.b	$fffffa1b.w
	move.l	#l00f4,$120.w
l00f2:
	move.b	#$63,$fffffa21.w
	move.b	#8,$fffffa1b.w
l00f3:
	move.b	#1,$fffffa21.w
	move.l	l00f9,-(a7)
	rts

l00f4:
	movem.l	a0-a2/d0,-(a7)
l00f5:
	move.l	#$777,$ffff8240.w
	move.l	#$777,$ffff8244.w
	move.l	#$777,$ffff8248.w
	move.l	#$777,$ffff824c.w
	move.l	#$777,$ffff8250.w
	move.l	#$777,$ffff8254.w
	move.l	#$777,$ffff8258.w
	move.l	#$333222,$ffff825c.w
	lea	l00fc(pc),a0
	subq.w	#1,(a0)
	bge.s	l00f6
	clr.b	$fffffa1b.w
	bra.s	l00f7
l00f6:
	lea	l00fe(pc),a0
	movea.l	(a0),a1
	lea	l00f5(pc),a2
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
l00f7:
	movem.l	(a7)+,a0-a2/d0
	rte

l00f8:
	dcb.w	2,0
l00f9:
	dcb.w	2,0
l00fa:
	dc.b	$00,$00
l00fb:
	dc.b	$00,$00
l00fc:
	dc.b	$00,$00
l00fd:
	dcb.w	2,0
l00fe:
	dcb.w	2,0

; -----------------------------------------------------------------------------
FN_p_left:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	bsr	honesty_check
	lea	$41c.l,a0
	adda.l	d3,a0
	moveq	#0,d3
	moveq	#0,d2
	move.b	(a0),d0
	btst	#2,d0
	beq	l0100
	move.l	#$ffffffff,d3
l0100:
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_p_up:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	bsr	honesty_check
	lea	$41c.l,a0
	adda.l	d3,a0
	moveq	#0,d3
	moveq	#0,d2
	move.b	(a0),d0
	btst	#0,d0
	beq	l0102
	move.l	#$ffffffff,d3
l0102:
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_p_right:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	bsr	honesty_check
	lea	$41c.l,a0
	adda.l	d3,a0
	moveq	#0,d3
	moveq	#0,d2
	move.b	(a0),d0
	btst	#3,d0
	beq	l0104
	move.l	#$ffffffff,d3
l0104:
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_p_down:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	bsr	honesty_check
	lea	$41c.l,a0
	adda.l	d3,a0
	moveq	#0,d3
	moveq	#0,d2
	move.b	(a0),d0
	btst	#1,d0
	beq	l0106
	move.l	#$ffffffff,d3
l0106:
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_floodpal:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	bsr	honesty_check
	moveq	#$f,d0
	lea	l0109(pc),a0
l0108:
	move.w	d3,(a0)+
	dbf	d0,l0108
	lea	l0109(pc),a0
	move.l	a0,$45a.l
	movea.l	RETURN,a0
	jmp	(a0)
l0109:
	dcb.w	16,0

; -----------------------------------------------------------------------------
FN_p_fire:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	bsr	honesty_check
	lea	$41c.l,a0
	adda.l	d3,a0
	moveq	#0,d3
	moveq	#0,d2
	move.b	(a0),d0
	btst	#7,d0
	beq	l010b
	move.l	#$ffffffff,d3
l010b:
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_digi_play:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#5,d0
	bne	l0018
	bsr	honesty_check
	move.l	d3,l025e
	bsr	honesty_check
	move.l	d3,l025d
	bsr	honesty_check
	move.l	d3,l025c
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	move.l	l025a(pc),d3
	movea.l	l025b(pc),a0
	movem.l	l025c(pc),d0-d2
	tst.w	l0122
	beq.s	l010d
	move.w	#0,l0122
	move	sr,-(a7)
	move	#$2700,sr
	move.l	l0114,$134.w
	move.b	l0123,$fffffa07.w
	move.b	l0124,$fffffa13.w
	move.b	l0125,$fffffa17.w
	move.b	l0126,$fffffa19.w
	move.w	#0,l011e
	move	(a7)+,sr
l010d:
	tst.w	d3
	beq	l0112
	tst.w	d2
	lea	l011e(pc),a1
	move.w	d2,(a1)
	subq.w	#1,d1
	cmpi.w	#2,d1
	blt.s	l0110
	cmpi.w	#$20,d1
	bgt.s	l0110
	cmpi.l	#$858b8c1,(a0)
	bne.s	l010f
	move.w	4(a0),d3
	cmp.w	d3,d0
	ble.s	l010e
	move.w	d3,d0
l010e:
	lsl.w	#3,d0
	lea	6(a0,d0.w),a1
	adda.l	(a1)+,a0
	move.l	(a1),d0
l010f:
	lea	l0121(pc),a1
	move.b	0(a1,d1.w),d1
	lea	l011f(pc),a1
	move.b	d1,(a1)
	jsr	l0115
	jsr	l0111
l0110:
	movea.l	RETURN,a0
	jmp	(a0)
l0111:
	lea	l0122(pc),a0
	move.w	#1,(a0)
	move	sr,-(a7)
	move	#$2700,sr
	move.l	$134.w,l0114
	move.l	#l0117,$134.w
	move.b	$fffffa07.l,l0123
	move.b	$fffffa13.l,l0124
	move.b	$fffffa17.l,l0125
	move.b	$fffffa19.l,l0126
	move.b	#1,$fffffa19.w
	move.b	l011f(pc),$fffffa1f.w
	bset	#5,$fffffa07.w
	bset	#5,$fffffa13.w
	bclr	#3,$fffffa17.w
	rte

l0112:
	move	sr,-(a7)
	lea	l0122(pc),a0
	tst.w	(a0)
	beq.s	l0113
	move.w	#0,(a0)
	move	#$2700,sr
	move.l	l0114,$134.w
	move.b	l0123,$fffffa07.w
	move.b	l0124,$fffffa13.w
	move.b	l0125,$fffffa17.w
	move.b	l0126,$fffffa19.w
	move.w	#0,l011e
l0113:
	rte

l0114:
	dcb.w	2,0
l0115:
	move.l	d0,l011d
	move.l	a0,l011c
	move.l	d0,l011b
	move.l	a0,l011a
	move.b	#$a,d1
	moveq	#0,d0
	movea.w	#$8800,a0
l0116:
	move.b	d1,(a0)
	move.b	d0,2(a0)
	dbf	d1,l0116
	move.b	#7,(a0)
	move.b	#$ff,2(a0)
	rts

l0117:
	movem.l	a0-a1/d0-d3,-(a7)
	moveq	#0,d0
	movea.l	l011a,a0
	subq.l	#1,l011b
	bne.s	l0119
	lea	l011e(pc),a1
	tst.w	(a1)
	bne.s	l0118
	jsr	l0112
l0118:
	movea.l	l011c,a0
	lea	l011b(pc),a1
	move.l	l011d(pc),(a1)
l0119:
	move.b	(a0)+,d0
	move.l	a0,l011a
	lsl.w	#3,d0
	movem.l	l0120(pc,d0.w),d0-d1
	movea.w	#$8800,a0
	movep.l	d0,0(a0)
	move.l	d1,(a0)
	movem.l	(a7)+,a0-a1/d0-d3
	rte

l011a:
	dcb.w	2,0
l011b:
	dcb.w	2,0
l011c:
	dcb.w	2,0
l011d:
	dcb.w	2,0
l011e:
	dc.b	$00,$00
l011f:
	dc.b	'=',$00
l0120:
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
l0121:
	dc.b	$00,$00,$cc,$99,'zfWL'
	dc.b	'D=73/+(&'
	dc.b	'$" ',$1e,$1d,$1b,$1a,$19
	dc.b	$18,$17,$16,$15,$15,$14,$13,$12
	dc.b	$12,$11,$11,$10,$10,$0f,$0f,$0e
	dc.b	$0e,$0e,$0d,$0d,$0d,$0d,$0c,$0c
	dc.b	$0c,$00
l0122:
	dc.b	$00,$00
l0123:
	dcb.w	2,0
l0124:
	dcb.w	2,0
l0125:
	dcb.w	2,0
l0126:
	dcb.w	2,0

; -----------------------------------------------------------------------------
FN_string:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	bsr	honesty_check
	lea	l012a(pc),a0
	tst.l	d3
	bgt.s	l0128
	move.b	#$30,-(a0)		;#'0'
	bra.s	l0129
l0128:
	tst.w	d3
	beq.s	l0129
	divu	#$a,d3
	swap	d3
	addi.w	#$30,d3
	move.b	d3,-(a0)
	move.w	#0,d3
	swap	d3
	bra.s	l0128
l0129:
	move.l	a0,d3
	moveq	#0,d2
	movea.l	RETURN,a0
	jmp	(a0)

; ?????

	dc.b	'        '
	dc.b	'      '
l012a:
	dc.b	' ',$00

; -----------------------------------------------------------------------------
FN_samsign:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#2,d0
	bne	l0018
	bsr	honesty_check
	move.l	d3,d0
	bsr	honesty_check
	movea.l	d3,a0
l012c:
	addi.b	#$80,(a0)+
	subq.w	#1,d0
	bne.s	l012c
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_depack:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#1,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	movea.l	d3,a0
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	movea.l	d0,a1
	movea.l	d0,a2
	movea.l	d0,a3
	movea.l	d0,a4
	movea.l	d0,a5
	movea.l	d0,a6
	cmpi.l	#$49434521,(a0)
	beq	l012e
	cmpi.l	#$46495245,(a0)
	beq	l012f
	cmpi.l	#$41544d35,(a0)
	beq	l0131
	cmpi.l	#$41553521,(a0)
	beq	l0130
	cmpi.l	#$53503230,(a0)
	beq	l0132
	cmpi.l	#$53507633,(a0)
	beq	l0133
	clr.l	-(a7)
	bra	l0134
l012e:
	move.l	8(a0),-(a7)
	bsr	l016e
	bra	l0134
l012f:
	move.l	8(a0),-(a7)
	bsr	l018d
	bra	l0134
l0130:
	move.l	8(a0),-(a7)
	bsr	l01b2
	bra	l0134
l0131:
	move.l	4(a0),-(a7)
	bsr	l0135
	bra	l0134
l0132:
	move.l	12(a0),-(a7)
	bsr	l01d1
	bra	l0134
l0133:
	move.l	12(a0),-(a7)
	bsr	l01f9
l0134:
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	move.l	(a7)+,d3
	moveq	#0,d2
	movea.l	RETURN,a0
	jmp	(a0)
l0135:
	movem.l	a0-a6/d0-d7,-(a7)
	cmpi.l	#$41544d35,(a0)+
	bne	l0163
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
	lea	l016d(pc),a3
	move.w	-2(a2),d0
	lsl.w	#2,d0
	addi.w	#$8c,d0
	bra.s	l0137
l0136:
	move.b	(a4)+,(a3)+
	subq.w	#1,d0
l0137:
	bne.s	l0136
	movem.l	a3-a4,-(a7)
	pea	(a5)
	move.b	-(a6),d7
	bra	l0157
l0138:
	move.w	d3,d5
l0139:
	add.b	d7,d7
l013a:
	dbcs	d5,l0139
	beq.s	l013d
	bcc.s	l013b
	sub.w	d3,d5
	neg.w	d5
	bra.s	l0140
l013b:
	moveq	#3,d6
	bsr.s	l0146
	beq.s	l013c
	bra.s	l013f
l013c:
	moveq	#7,d6
	bsr.s	l0146
	beq.s	l013e
	addi.w	#$f,d5
	bra.s	l013f
l013d:
	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l013a
l013e:
	moveq	#$d,d6
	bsr.s	l0146
	addi.w	#$10e,d5
l013f:
	add.w	d3,d5
l0140:
	lea	l0164(pc),a4
	move.w	d5,d2
	bne.s	l014a
	add.b	d7,d7
	bne.s	l0141
	move.b	-(a6),d7
	addx.b	d7,d7
l0141:
	bcs.s	l0142
	moveq	#1,d6
	bra.s	l014b
l0142:
	moveq	#3,d6
	bsr.s	l0146
	tst.b	-28(a2)
	beq.s	l0143
	move.b	-18(a2,d5.w),-(a5)
	bra	l0156
l0143:
	move.b	(a5),d0
	btst	#3,d5
	bne.s	l0144
	bra.s	l0145
l0144:
	addi.b	#$f0,d5
l0145:
	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	l0156
l0146:
	clr.w	d5
l0147:
	add.b	d7,d7
	beq.s	l0149
l0148:
	addx.w	d5,d5
	dbf	d6,l0147
	tst.w	d5
	rts

l0149:
	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	l0148
l014a:
	moveq	#2,d6
l014b:
	bsr.s	l0146
	move.w	d5,d4
	move.b	14(a4,d4.w),d6
	ext.w	d6
	tst.b	-27(a2)
	bne.s	l014c
	addq.w	#4,d6
	bra.s	l0150
l014c:
	bsr.s	l0146
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	l0146
	cmp.b	#7,d5
	blt.s	l014e
	moveq	#0,d6
	bsr.s	l0146
	beq.s	l014d
	moveq	#2,d6
	bsr.s	l0146
	add.w	d5,d5
	or.w	d1,d5
	bra.s	l0151
l014d:
	or.b	-26(a2),d1
	bra.s	l014f
l014e:
	or.b	-25(a2,d5.w),d1
l014f:
	move.w	d1,d5
	bra.s	l0151
l0150:
	bsr.s	l0146
l0151:
	add.w	d4,d4
	beq.s	l0152
	add.w	-2(a4,d4.w),d5
l0152:
	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
l0153:
	move.b	-(a4),-(a5)
	dbf	d2,l0153
	bra.s	l0156
l0154:
	add.b	d7,d7
	bne.s	l0155
	move.b	-(a6),d7
	addx.b	d7,d7
l0155:
	bcs.s	l015f
	move.b	-(a6),-(a5)
l0156:
	cmpa.l	a5,a3
	bne.s	l0154
	cmpa.l	a6,a0
	beq.s	l0160
l0157:
	moveq	#0,d6
	bsr	l0146
	beq.s	l015a
	move.b	-(a6),d0
	lea	-26(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
l0158:
	cmp.b	d0,d1
	bne.s	l0159
	addq.w	#2,d1
l0159:
	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,l0158
	st	-27(a2)
	bra.s	l015b
l015a:
	sf	-27(a2)
l015b:
	moveq	#0,d6
	bsr	l0146
	beq.s	l015d
	lea	-18(a2),a1
	moveq	#$f,d0
l015c:
	move.b	-(a6),(a1)+
	dbf	d0,l015c
	st	-28(a2)
	bra.s	l015e
l015d:
	sf	-28(a2)
l015e:
	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	movea.l	a5,a3
	suba.w	d0,a3
	bra.s	l0154
l015f:
	bra	l0138
l0160:
	movea.l	(a7)+,a0
	pea	(a2)
	bsr.s	l0165
	movea.l	(a7)+,a2
	movem.l	(a7)+,a3-a4
	move.l	(a7)+,d0
	bsr	l016b
	move.w	-2(a2),d0
	lsl.w	#2,d0
	addi.w	#$8c,d0
	bra.s	l0162
l0161:
	move.b	-(a3),-(a4)
	subq.w	#1,d0
l0162:
	bne.s	l0161
	unlk	a2
l0163:
	movem.l	(a7)+,a0-a6/d0-d7
	rts

l0164:
	dc.b	$00,' ',$00,'`',$01,'`',$03,'`'
	dc.b	$07,'`',$0f,'`',$1f,'`',$00,$01
	dc.b	$03,$04,$05,$06,$07,$08
l0165:
	move.w	-2(a2),d7
l0166:
	dbf	d7,l0167
	rts

l0167:
	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
	lea	32000(a1),a2
l0168:
	moveq	#3,d6
l0169:
	move.w	(a1)+,d0
	moveq	#3,d5
l016a:
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,l016a
	dbf	d6,l0169
	movem.w	d1-d4,-8(a1)
	cmpa.l	a1,a2
	bne.s	l0168
	bra.s	l0166
l016b:
	lsr.l	#4,d0
	lea	-12(a6),a6
l016c:
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	move.l	(a5)+,(a6)+
	dbf	d0,l016c
	rts

l016d:
	dcb.w	142,0
l016e:
	link	a3,#$ff88
	movem.l	a0-a6/d0-d7,-(a7)
	lea	120(a0),a4
	movea.l	a4,a6
	bsr	l0177
	cmpi.l	#$49434521,d0
	bne	l0176
	bsr.s	l0177
	lea	-8(a0,d0.l),a5
	bsr.s	l0177
	move.l	d0,(a7)
	adda.l	d0,a6
	movea.l	a6,a1
	moveq	#$77,d0
l016f:
	move.b	-(a1),-(a3)
	dbf	d0,l016f
	movea.l	a6,a3
	move.b	-(a5),d7
	bsr.s	l0179
	movea.l	a3,a5
	bsr	l017d
	bcc.s	l0173
	move.w	#$f9f,d7
	bsr	l017d
	bcc.s	l0170
	moveq	#$f,d0
	bsr	l017f
	move.w	d1,d7
l0170:
	moveq	#3,d6
l0171:
	move.w	-(a3),d4
	moveq	#3,d5
l0172:
	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbf	d5,l0172
	dbf	d6,l0171
	movem.w	d0-d3,(a3)
	dbf	d7,l0170
l0173:
	movem.l	(a7),a0-a3/d0-d7
l0174:
	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	l0174
	moveq	#$77,d0
l0175:
	move.b	-(a3),-(a5)
	dbf	d0,l0175
l0176:
	movem.l	(a7)+,a0-a6/d0-d7
	unlk	a3
	rts

l0177:
	moveq	#3,d1
l0178:
	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,l0178
	rts

l0179:
	bsr.s	l017d
	bcc.s	l017c
	moveq	#0,d1
	bsr.s	l017d
	bcc.s	l017b
	lea	l018a(pc),a1
	moveq	#4,d3
l017a:
	move.l	-(a1),d0
	bsr.s	l017f
	swap	d0
	cmp.w	d0,d1
	dbne	d3,l017a
	add.l	20(a1),d1
l017b:
	move.b	-(a5),-(a6)
	dbf	d1,l017b
l017c:
	cmpa.l	a4,a6
	bgt.s	l0182
	rts

l017d:
	add.b	d7,d7
	bne.s	l017e
	move.b	-(a5),d7
	addx.b	d7,d7
l017e:
	rts

l017f:
	moveq	#0,d1
l0180:
	add.b	d7,d7
	bne.s	l0181
	move.b	-(a5),d7
	addx.b	d7,d7
l0181:
	addx.w	d1,d1
	dbf	d0,l0180
	rts

l0182:
	lea	l018b(pc),a1
	moveq	#3,d2
l0183:
	bsr.s	l017d
	dbcc	d2,l0183
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	l0184
	bsr.s	l017f
l0184:
	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	l0186
	lea	l018c(pc),a1
	moveq	#1,d2
l0185:
	bsr.s	l017d
	dbcc	d2,l0185
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	l017f
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	l0188
	sub.w	d4,d1
	bra.s	l0188
l0186:
	moveq	#0,d1
	moveq	#5,d0
	moveq	#$ff,d2
	bsr.s	l017d
	bcc.s	l0187
	moveq	#8,d0
	moveq	#$3f,d2
l0187:
	bsr.s	l017f
	add.w	d2,d1
l0188:
	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
l0189:
	move.b	-(a1),-(a6)
	dbf	d4,l0189
	bra	l0179
	dc.b	$7f,$ff,$00,$0e,$00,$ff,$00,$07
	dc.b	$00,$07,$00,$02,$00,$03,$00,$01
	dc.b	$00,$03,$00,$01
l018a:
	dc.b	$00,$00,$01,$0d,$00,$00,$00,$0e
	dc.b	$00,$00,$00,$07,$00,$00,$00,$04
	dc.b	$00,$00,$00,$01
l018b:
	dc.b	$09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b	$01,$00
l018c:
	dc.b	$0b,$04,$07,$00,$01,$1f,$ff,$ff
	dc.b	$00,$1f
l018d:
	link	a3,#$ff88
	movem.l	a0-a6/d0-d7,-(a7)
	lea	120(a0),a4
	movea.l	a4,a6
	bsr.s	l0196
	cmpi.l	#$46495245,d0
	bne	l0195
	bsr.s	l0196
	lea	-8(a0,d0.l),a5
	bsr.s	l0196
	move.l	d0,(a7)
	adda.l	d0,a6
	movea.l	a6,a1
	moveq	#$77,d0
l018e:
	move.b	-(a1),-(a3)
	dbf	d0,l018e
	movea.l	a6,a3
	move.b	-(a5),d7
	lea	l01b1(pc),a2
	moveq	#1,d6
	swap	d6
	moveq	#0,d5
l018f:
	bsr.s	l0198
	bcc.s	l0192
	moveq	#0,d1
	bsr.s	l0198
	bcc.s	l0191
	movea.l	a2,a0
	moveq	#3,d3
l0190:
	move.l	-(a0),d0
	bsr.s	l019a
	swap	d0
	cmp.w	d0,d1
	dbne	d3,l0190
	add.l	16(a0),d1
l0191:
	move.b	-(a5),-(a6)
	dbf	d1,l0191
l0192:
	cmpa.l	a4,a6
	bgt.s	l019e
	movem.l	(a7),a5/a0-a2/d0-d7
l0193:
	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	l0193
	moveq	#$77,d0
l0194:
	move.b	-(a5),-(a3)
	dbf	d0,l0194
l0195:
	movem.l	(a7)+,a0-a6/d0-d7
	unlk	a3
	rts

l0196:
	moveq	#3,d1
l0197:
	rol.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,l0197
	rts

l0198:
	add.b	d7,d7
	beq.s	l0199
	rts

l0199:
	move.b	-(a5),d7
	addx.b	d7,d7
	rts

l019a:
	moveq	#0,d1
l019b:
	add.b	d7,d7
	beq.s	l019d
l019c:
	addx.w	d1,d1
	dbf	d0,l019b
	rts

l019d:
	move.b	-(a5),d7
	addx.b	d7,d7
	bra.s	l019c
l019e:
	moveq	#1,d0
	bsr.s	l019a
	subq.w	#1,d1
	bmi.s	l01a2
	beq.s	l01a4
	subq.w	#1,d1
	beq.s	l01a5
	bsr.s	l0198
	bcc.s	l01a3
	bsr.s	l0198
	bcc.s	l01a6
	bra.s	l01a7
l019f:
	moveq	#1,d0
	bsr.s	l019a
	subq.w	#1,d1
	bpl.s	l01a1
	moveq	#0,d0
	rts

l01a0:
	moveq	#1,d0
	bsr.s	l019a
l01a1:
	add.w	d1,d1
	add.w	d1,d1
	movem.w	16(a2,d1.w),d5/d0
	bsr.s	l019a
	add.l	d5,d1
	rts

l01a2:
	moveq	#1,d0
	bsr.s	l019a
	subq.w	#1,d1
	bmi.s	l01ab
	add.w	d1,d1
	add.w	d1,d1
	movem.w	32(a2,d1.w),d2/d0
	bsr.s	l019a
	add.w	d1,d2
	bsr.s	l01a0
	move.w	d2,d0
	bra.s	l01ad
l01a3:
	moveq	#2,d0
	bsr.s	l019a
	moveq	#0,d0
	bset	d1,d0
	bra.s	l01aa
l01a4:
	moveq	#7,d0
	bsr.s	l019a
	moveq	#0,d0
	bra.s	l01ae
l01a5:
	bsr.s	l019f
	tst.w	d0
	beq	l01aa
	moveq	#1,d0
	bra.s	l01ae
l01a6:
	bsr.s	l019f
	tst.w	d0
	beq.s	l01a9
	moveq	#2,d0
	bra.s	l01ae
l01a7:
	bsr.s	l019f
	tst.w	d0
	beq.s	l01a8
	moveq	#3,d0
	bra.s	l01ae
l01a8:
	moveq	#$ff,d0
	bra.s	l01aa
l01a9:
	move.b	(a6),d0
l01aa:
	move.b	d0,-(a6)
	bra.s	l01b0
l01ab:
	bsr.s	l01a0
	beq.s	l01b0
	move.b	(a6),d0
l01ac:
	move.b	d0,-(a6)
	dbf	d1,l01ac
	sub.l	d6,d1
	bmi.s	l01b0
	bra.s	l01ac
l01ad:
	subq.w	#2,d0
l01ae:
	lea	2(a6,d1.l),a0
	adda.w	d0,a0
	move.b	-(a0),-(a6)
l01af:
	move.b	-(a0),-(a6)
	dbf	d0,l01af
l01b0:
	bra	l018f
	dc.b	$03,$ff,$00,$09,$00,$07,$00,$02
	dc.b	$00,$03,$00,$01,$00,$03,$00,$01
l01b1:
	dc.b	$00,$00,$00,$0e,$00,$00,$00,$07
	dc.b	$00,$00,$00,$04,$00,$00,$00,$01
	dc.b	$00,$03,$00,$00,$00,$07,$00,$10
	dc.b	$00,$0b,$01,$10,$00,$0f,$11,$10
	dc.b	$00,$03,$00,$05,$00,$05,$00,$15
	dc.b	$00,$07,$00,'U'
l01b2:
	link	a3,#$ff88
	movem.l	a0-a6/d0-d7,-(a7)
	lea	120(a0),a4
	movea.l	a4,a6
	bsr.s	l01bb
	cmpi.l	#$41553521,d0
	bne	l01ba
	bsr.s	l01bb
	lea	-8(a0,d0.l),a5
	bsr.s	l01bb
	move.l	d0,(a7)
	adda.l	d0,a6
	movea.l	a6,a1
	moveq	#$77,d0
l01b3:
	move.b	-(a1),-(a3)
	dbf	d0,l01b3
	movea.l	a6,a3
	move.b	-(a5),d7
	bsr.s	l01bd
	movea.l	a3,a5
	bsr.s	l01c1
	bcc.s	l01b7
	move.w	#$f9f,d7
l01b4:
	moveq	#3,d6
l01b5:
	move.w	-(a3),d4
	moveq	#3,d5
l01b6:
	add.w	d4,d4
	addx.w	d0,d0
	add.w	d4,d4
	addx.w	d1,d1
	add.w	d4,d4
	addx.w	d2,d2
	add.w	d4,d4
	addx.w	d3,d3
	dbf	d5,l01b6
	dbf	d6,l01b5
	movem.w	d0-d3,(a3)
	dbf	d7,l01b4
l01b7:
	movem.l	(a7),a0-a3/d0-d7
l01b8:
	move.b	(a4)+,(a0)+
	subq.l	#1,d0
	bne.s	l01b8
	moveq	#$77,d0
l01b9:
	move.b	-(a3),-(a5)
	dbf	d0,l01b9
l01ba:
	movem.l	(a7)+,a0-a6/d0-d7
	unlk	a3
	rts

l01bb:
	moveq	#3,d1
l01bc:
	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,l01bc
	rts

l01bd:
	bsr.s	l01c1
	bcc.s	l01c0
	moveq	#0,d1
	bsr.s	l01c1
	bcc.s	l01bf
	lea	l01ce(pc),a1
	moveq	#4,d3
l01be:
	move.l	-(a1),d0
	bsr.s	l01c3
	swap	d0
	cmp.w	d0,d1
	dbne	d3,l01be
	add.l	20(a1),d1
l01bf:
	move.b	-(a5),-(a6)
	dbf	d1,l01bf
l01c0:
	cmpa.l	a4,a6
	bgt.s	l01c6
	rts

l01c1:
	add.b	d7,d7
	bne.s	l01c2
	move.b	-(a5),d7
	addx.b	d7,d7
l01c2:
	rts

l01c3:
	moveq	#0,d1
l01c4:
	add.b	d7,d7
	bne.s	l01c5
	move.b	-(a5),d7
	addx.b	d7,d7
l01c5:
	addx.w	d1,d1
	dbf	d0,l01c4
	rts

l01c6:
	lea	l01cf(pc),a1
	moveq	#3,d2
l01c7:
	bsr.s	l01c1
	dbcc	d2,l01c7
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	l01c8
	bsr.s	l01c3
l01c8:
	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	l01ca
	lea	l01d0(pc),a1
	moveq	#1,d2
l01c9:
	bsr.s	l01c1
	dbcc	d2,l01c9
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	l01c3
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	l01cc
	sub.w	d4,d1
	bra.s	l01cc
l01ca:
	moveq	#0,d1
	moveq	#5,d0
	moveq	#$ff,d2
	bsr.s	l01c1
	bcc.s	l01cb
	moveq	#8,d0
	moveq	#$3f,d2
l01cb:
	bsr.s	l01c3
	add.w	d2,d1
l01cc:
	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
l01cd:
	move.b	-(a1),-(a6)
	dbf	d4,l01cd
	bra	l01bd
	dc.b	$7f,$ff,$00,$0e,$00,$ff,$00,$07
	dc.b	$00,$07,$00,$02,$00,$03,$00,$01
	dc.b	$00,$03,$00,$01
l01ce:
	dc.b	$00,$00,$01,$0d,$00,$00,$00,$0e
	dc.b	$00,$00,$00,$07,$00,$00,$00,$04
	dc.b	$00,$00,$00,$01
l01cf:
	dc.b	$09,$01,$00,$ff,$ff,$08,$04,$02
	dc.b	$01,$00
l01d0:
	dc.b	$0b,$04,$07,$00,$01,$1f,$ff,$ff
	dc.b	$00,$1f
l01d1:
	movem.l	a0-a6/d1-d7,-(a7)
	clr.l	-(a7)
	cmpi.l	#$53503230,(a0)+
	bne.s	l01d6
	tst.w	(a0)
	bne.s	l01d6
	movea.l	a0,a5
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	d1,(a7)
	tst.w	d5
	beq.s	l01d2
	swap	d5
	btst	#1,$ffff8260.w
	bne.s	l01d2
	lea	$ffff8240.w,a5
	move.w	(a5),d5
	swap	d5
l01d2:
	lea	64(a0),a1
	movea.l	a1,a2
	adda.l	d0,a0
	adda.l	d1,a1
	movea.l	a1,a3
	movea.l	a7,a6
	moveq	#$4f,d0
l01d3:
	move.b	-(a3),-(a6)
	dbf	d0,l01d3
	exg	a6,a7
	bsr.s	l01d7
	lea	-80(a1),a3
	move.l	(a6),d0
l01d4:
	move.b	(a1)+,(a3)+
	subq.l	#1,d0
	bne.s	l01d4
	exg	a6,a7
	moveq	#$4f,d0
l01d5:
	move.b	(a6)+,(a3)+
	dbf	d0,l01d5
l01d6:
	movem.l	(a7)+,a0-a6/d0-d7
	rts

l01d7:
	moveq	#0,d6
	moveq	#1,d7
	lea	l01f7(pc),a3
	jsr	(a3)
	roxr.l	d7,d0
l01d8:
	add.l	d0,d0
	bne.s	l01d9
	jsr	(a3)
l01d9:
	bcs.s	l01e9
	move.b	-(a0),d1
	bra.s	l01de
l01da:
	moveq	#2,d2
	bsr.s	l01e1
	move.l	d6,d1
	bset	d2,d1
	bra.s	l01de
l01db:
	add.l	d0,d0
	bne.s	l01dc
	jsr	(a3)
l01dc:
	bcs	l01f2
	moveq	#3,d2
	bsr.s	l01e1
	add.w	d7,d2
	lsr.w	d7,d2
	bcc.s	l01dd
	not.w	d2
l01dd:
	move.b	(a1),d1
	add.w	d2,d1
l01de:
	move.b	d1,-(a1)
	clr.w	(a5)
l01df:
	cmpa.l	a1,a2
	bne.s	l01d8
	swap	d5
	move.w	d5,(a5)
	rts

l01e0:
	move.l	d7,d2
l01e1:
	move.l	d6,d1
l01e2:
	add.l	d0,d0
	bne.s	l01e3
	jsr	(a3)
l01e3:
	addx.w	d1,d1
	dbf	d2,l01e2
l01e4:
	move.l	d1,d2
	rts

l01e5:
	bsr.s	l01e0
l01e6:
	beq.s	l01e7
	move.b	-(a0),d1
	subq.w	#2,d2
	bcs.s	l01e4
l01e7:
	add.w	d7,d2
	add.w	d2,d2
l01e8:
	add.w	d2,d2
	sub.w	d7,d2
	bra.s	l01e2
l01e9:
	add.l	d0,d0
	bne.s	l01ea
	jsr	(a3)
l01ea:
	bcs.s	l01ec
	add.l	d0,d0
	bne.s	l01eb
	jsr	(a3)
l01eb:
	bcs.s	l01db
	move.l	d6,d1
	move.b	-(a0),d1
	moveq	#0,d3
	bra.s	l01f5
l01ec:
	add.l	d0,d0
	bne.s	l01ed
	jsr	(a3)
l01ed:
	bcs.s	l01ee
	bsr.s	l01e0
	beq.s	l01de
	moveq	#1,d3
	bra.s	l01f4
l01ee:
	add.l	d0,d0
	bne.s	l01ef
	jsr	(a3)
l01ef:
	bcs	l01da
	add.l	d0,d0
	bne.s	l01f0
	jsr	(a3)
l01f0:
	bcs.s	l01f1
	bsr.s	l01e0
	beq.s	l01dd
	moveq	#2,d3
	bra.s	l01f4
l01f1:
	moveq	#3,d3
	bsr.s	l01e5
	bra.s	l01f5
l01f2:
	bsr.s	l01e0
	beq.s	l01f3
	move.l	d6,d1
	add.w	d7,d2
	bsr.s	l01e8
	move.l	d2,d3
	bsr.s	l01e5
	bra.s	l01f5
l01f3:
	bsr.s	l01e5
	not.l	d1
	move.l	d2,d3
	bra.s	l01f5
l01f4:
	move.l	d6,d1
	sub.w	d7,d2
	bsr.s	l01e6
l01f5:
	movea.l	a1,a4
	addq.l	#2,a4
	adda.l	d1,a4
	adda.l	d3,a4
	move.b	-(a4),-(a1)
l01f6:
	move.b	-(a4),-(a1)
	dbf	d3,l01f6
	move.w	d5,(a5)
	bra	l01df
l01f7:
	move.w	a0,d4
	btst	d6,d4
	bne.s	l01f8
	move.l	-(a0),d0
	addx.l	d0,d0
	rts

l01f8:
	move.l	-5(a0),d0
	lsl.l	#8,d0
	move.b	-(a0),d0
	subq.l	#3,a0
	add.l	d0,d0
	bset	d6,d0
	rts

l01f9:
	moveq	#0,d0
	movem.l	a0-a6/d0-d7,-(a7)
	lea	l022d(pc),a6
	movea.l	a0,a1
	cmpi.l	#$53507633,(a1)+
	bne.s	l01fb
	tst.w	(a1)
	bne.s	l01fb
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
l01fa:
	move.l	(a2)+,(a3)+
	dbf	d0,l01fa
	suba.l	a2,a3
	move.l	a3,-(a7)
	bsr.s	l01fc
	bsr	l020e
	move.b	-(a0),d0
	adda.l	(a7)+,a0
	move.b	d0,(a0)+
	lea	402(a6),a2
	bsr	l020f
	bsr	l0208
l01fb:
	movem.l	(a7)+,a0-a6/d0-d7
	rts

l01fc:
	move	sr,d1
	andi.w	#$2000,d1
	beq.s	l01fd
	move.w	$ffff8240.w,2(a6)
	btst	#1,$ffff8260.w
	bne.s	l01fd
	swap	d5
l01fd:
	clr.w	d5
	move.w	-(a0),d6
	lea	4(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
l01fe:
	cmp.b	d6,d3
	bne.s	l01ff
	addq.w	#2,d3
l01ff:
	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,l01fe
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
l0200:
	move.b	-(a0),-(a3)
	dbf	d4,l0200
	move.b	-(a0),-(a3)
	beq.s	l0201
	suba.w	d4,a0
l0201:
	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
l0202:
	bsr.s	l0203
	bsr.s	l0203
	dbf	d2,l0202
	rts

l0203:
	not.w	d4
	add.b	d7,d7
	bne.s	l0204
	move.b	-(a0),d7
	addx.b	d7,d7
l0204:
	bcs.s	l0205
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts

l0205:
	moveq	#2,d1
	bsr	l0225
	add.w	d0,d0
	beq.s	l0206
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	l0225
	add.w	d0,d0
	move.b	d0,-(a3)
	rts

l0206:
	moveq	#2,d1
	bsr	l0225
	move.w	12(a6),d1
	add.w	d0,d0
	beq.s	l0207
	move.w	14(a6),d1
l0207:
	or.w	d1,d0
	move.w	d0,-(a3)
	rts

l0208:
	move	sr,d1
	andi.w	#$2000,d1
	beq.s	l0209
	move.w	2(a6),$ffff8240.w
l0209:
	tst.w	d6
	bpl.s	l020d
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(a7),a3
l020a:
	moveq	#3,d6
l020b:
	move.w	(a2)+,d0
	moveq	#3,d5
l020c:
	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,l020c
	dbf	d6,l020b
	cmpa.l	a2,a3
	blt.s	l020d
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	l020a
l020d:
	rts

l020e:
	move.b	-(a0),-(a1)
l020f:
	swap	d5
	beq.s	l0210
	move.w	d5,$ffff8240.w
l0210:
	lea	270(a6),a3
	cmpa.l	a0,a2
	blt.s	l0212
	rts

l0211:
	adda.w	d3,a3
l0212:
	add.b	d7,d7
	bcc.s	l0215
	beq.s	l0214
l0213:
	move.w	(a3),d3
	bmi.s	l0211
	bra.s	l0216
l0214:
	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	l0213
l0215:
	move.w	-(a3),d3
	bmi.s	l0211
l0216:
	ext.w	d3
	jmp	l0217(pc,d3.w)
l0217:
	bra.s	l0217
	bra.s	l0222
	bra.s	l0222
	bra.s	l0222
	bra.s	l0222
	bra.s	l0222
	bra.s	l021e
	bra.s	l021d
	bra.s	l0219
	bra.s	l021a
	bra.s	l0218
	bra.s	l021b
	bra.s	l020e
l0218:
	move.b	(a5),-(a1)
	bra.s	l020f
l0219:
	bsr.s	l0224
	move.b	1(a5,d0.w),-(a1)
	bra.s	l020f
l021a:
	bsr.s	l0224
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	l020f
l021b:
	moveq	#3,d1
	bsr.s	l0225
	lsr.w	#1,d0
	bcc.s	l021c
	not.w	d0
l021c:
	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	l020f
l021d:
	lea	-36(a6),a4
	bsr.s	l0229
	addi.w	#$10,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	l020f
l021e:
	moveq	#3,d1
	bsr.s	l0225
	tst.w	d0
	beq.s	l021f
	addq.w	#5,d0
	bra.s	l0221
l021f:
	move.b	-(a0),d0
	beq.s	l0220
	addi.w	#$14,d0
	bra.s	l0221
l0220:
	moveq	#$d,d1
	bsr.s	l0225
	addi.w	#$114,d0
l0221:
	move.w	d0,d3
	add.w	d3,d3
l0222:
	lea	-34(a6),a4
	bsr.s	l0229
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
l0223:
	move.b	-(a3),-(a1)
	dbf	d3,l0223
	bra	l020f
l0224:
	moveq	#0,d1
	move.b	(a3),d1
l0225:
	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	l0228
l0226:
	add.b	d7,d7
	beq.s	l0227
	addx.w	d0,d0
	dbf	d1,l0226
	rts

l0227:
	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,l0226
	rts

l0228:
	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	l0226
	rts

l0229:
	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	l0225
	tst.b	d6
	beq.s	l022c
	move.w	d0,d4
	andi.w	#$fff0,d4
	andi.w	#$f,d0
	beq.s	l022b
	lsr.w	#1,d0
	beq.s	l022a
	roxr.b	#1,d7
	bcc.s	l022b
	move.b	d7,(a0)+
	moveq	#$80,d7
	bra.s	l022b
l022a:
	moveq	#2,d1
	bsr.s	l0225
	add.w	d0,d0
	or.w	d4,d0
	bra.s	l022c
l022b:
	lea	4(a6),a3
	or.b	0(a3,d0.w),d4
	move.w	d4,d0
l022c:
	add.w	18(a4),d0
	rts

	dc.b	$00,$03,$00,$04,$00,$05,$00,$07
	dc.b	$00,$08,$00,$09,$00,$0a,$00,$0b
	dc.b	$00,$0c,$ff,$f0,$00,$00,$00,' '
	dc.b	$00,'`',$01,'`',$03,'`',$07,'`'
	dc.b	$0f,'`',$1f,'`'
l022d:
	dcb.w	457,0

; -----------------------------------------------------------------------------
FN_replace_blocks:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#3,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	move.l	d3,d1
	bsr	honesty_check
	move.l	d3,d0
	bsr	honesty_check
	movea.l	d3,a0
	cmpi.l	#$3031973,(a0)+
	bne.s	l0245
	moveq	#7,d4
	bra.s	l0246
l0245:
	cmpi.l	#$2528e54,-4(a0)
	bne	l001a
	moveq	#8,d4
l0246:
	moveq	#0,d2
	movem.w	(a0)+,d2-d3
	addq.w	#2,d2
	lsr.w	#1,d2
	lsr.w	#1,d3
	mulu	d3,d2
	subq.w	#1,d2
	lsl.w	d4,d0
	lsl.w	d4,d1
l0247:
	move.w	(a0)+,d3
	cmp.w	d3,d0
	bne.s	l0248
	move.w	d1,-2(a0)
l0248:
	dbf	d2,l0247
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_dload:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmp.w	#4,d0
	bne	l0018
	bsr	honesty_check
	move.l	d3,d0
	bsr	honesty_check
	move.l	d3,d1
	bsr	honesty_check
	movea.l	d3,a4
	bsr	honesty_check
	move.l	a3,-(a7)
	movea.l	d3,a3
	move.l	d0,d4
	move.l	d1,d3
	moveq	#0,d6
	clr.w	-(a7)
	move.l	a3,-(a7)
	move.w	#$3d,-(a7)		;fopen
	trap	#1
	addq.l	#8,a7
	move.w	d0,d7
	move.l	d0,d6
	cmpi.w	#0,d0
	blt	l0230
	clr.w	-(a7)
	move.w	d7,-(a7)
	move.l	d3,-(a7)
	move.w	#$42,-(a7)		;fseek
	trap	#1
	lea	10(a7),a7
	move.l	d0,d6
	cmpi.w	#0,d0
	blt	l022f
	move.l	a4,-(a7)
	move.l	d4,-(a7)
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)		;fread
	trap	#1
	lea	12(a7),a7
	move.l	d0,d6
l022f:
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)		;fclose
	trap	#1
	addq.l	#4,a7
l0230:
	moveq	#0,d2
	moveq	#0,d3
	move.l	d6,d3
	movea.l	(a7)+,a3
	movea.l	RETURN,a0
	jmp	(a0)

; -----------------------------------------------------------------------------
FN_display_pc1:
; -----------------------------------------------------------------------------	
	move.l	(a7)+,RETURN
	cmp.w	#2,d0
	bne	l0018
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	bsr	honesty_check
	move.l	d3,l025b
	bsr	honesty_check
	move.l	d3,l025a
	movea.l	l025a(pc),a0
	movea.l	l025b(pc),a1
	lea	2(a0),a3
	move.l	a3,$45a.w
	movea.l	a1,a3
	lea	34(a0),a0
	move.w	#$c7,d4
l0239:
	moveq	#3,d3
l023a:
	lea	l0243(pc),a1
	bsr.s	l023b
	bsr.s	l0241
	addq.w	#2,a3
	dbf	d3,l023a
	lea	152(a3),a3
	dbf	d4,l0239
	lea	l0259(pc),a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)
l023b:
	movem.l	a1-a2/d1,-(a7)
	movea.l	a1,a2
	lea	40(a2),a2
l023c:
	moveq	#0,d1
	move.b	(a0)+,d1
	bmi.s	l023e
l023d:
	move.b	(a0)+,(a1)+
	dbf	d1,l023d
	cmpa.l	a2,a1
	blt.s	l023c
	bra.s	l0240
l023e:
	neg.b	d1
	move.b	(a0)+,d0
l023f:
	move.b	d0,(a1)+
	dbf	d1,l023f
	cmpa.l	a2,a1
	blt.s	l023c
l0240:
	movem.l	(a7)+,a1-a2/d1
	rts

l0241:
	movem.l	a0-a3/d0,-(a7)
	lea	l0243(pc),a0
	moveq	#$13,d0
l0242:
	move.w	(a0)+,(a3)+
	addq.w	#6,a3
	dbf	d0,l0242
	movem.l	(a7)+,a0-a3/d0
	rts

l0243:
	dcb.w	20,0

; -----------------------------------------------------------------------------
FN_dsave:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	cmpi.w	#4,d0
	bne	l0018
	bsr	honesty_check
	move.l	d3,d0
	bsr	honesty_check
	move.l	d3,d1
	bsr	honesty_check
	movea.l	d3,a4
	bsr	honesty_check
	move.l	a3,-(a7)
	movea.l	d3,a3
	move.l	d0,d4
	move.l	d1,d3
	move.w	#$2f,-(a7)		;fgetdta
	trap	#1
	addq.l	#2,a7
	lea	l0236(pc),a0
	move.l	d0,(a0)
	pea	l0237(pc)
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
	beq.s	l0232
	clr.w	-(a7)
	move.l	a3,-(a7)
	move.w	#$3c,-(a7)		;fcreate
	trap	#1
	addq.l	#8,a7
	bra.s	l0233
l0232:
	clr.w	-(a7)
	move.l	a3,-(a7)
	move.w	#$3d,-(a7)		;fopen
	trap	#1
	addq.l	#8,a7
l0233:
	move.w	d0,d7
	move.l	d0,d6
	cmpi.w	#0,d0
	blt.s	l0235
	clr.w	-(a7)
	move.w	d7,-(a7)
	move.l	d3,-(a7)
	move.w	#$42,-(a7)		;fseek
	trap	#1
	lea	10(a7),a7
	move.l	d0,d6
	cmpi.w	#0,d0
	blt.s	l0234
	move.l	a4,-(a7)
	move.l	d4,-(a7)
	move.w	d7,-(a7)
	move.w	#$40,-(a7)		;fwrite
	trap	#1
	lea	12(a7),a7
	move.l	d0,d6
l0234:
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)		;fclose
	trap	#1
	addq.l	#4,a7
l0235:
	lea	l0236(pc),a0
	move.l	(a0),-(a7)
	move.w	#$1a,-(a7)		;dsetdta
	trap	#1
	addq.l	#6,a7
	moveq	#0,d2
	moveq	#0,d3
	move.l	d6,d3
	movea.l	(a7)+,a3
	movea.l	RETURN,a0
	jmp	(a0)
l0236:
	dcb.w	2,0
l0237:
	dcb.w	23,0

; -----------------------------------------------------------------------------
FN_honesty:
; -----------------------------------------------------------------------------
	move.l	(a7)+,RETURN
	lea	l025a,a0
	movem.l	a1-a6/d5-d6,-(a0)
	movem.l	a0/d7,-(a7)
	movea.l	#l024a,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l024b,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l024c,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l024d,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l024e,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l024f,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0250,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0251,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0252,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0253,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0254,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	move.l	#2,d0
	moveq	#4,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0255,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	move.l	#1,d0
	moveq	#4,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0256,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0257,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0015,a0
	moveq	#1,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	movem.l	a0/d7,-(a7)
	movea.l	#l0258,a0
	moveq	#$12,d7
	trap	#3
	movem.l	(a7)+,a0/d7
	lea	l0259,a0
	movem.l	(a0)+,a1-a6/d5-d6
	movea.l	RETURN,a0
	jmp	(a0)
	
l024a:
	dc.b	$0c,$1e,$00
l024b:
	dc.b	'To regist'
	dc.b	'er for M'
	dc.b	'issing L'
	dc.b	'ink, sen'
	dc.b	'd',$00
l024c:
	dc.b	$9c,'10.00 ('
	dc.b	'Ten poun'
	dc.b	'ds sterl'
	dc.b	'ing) to:'
	dc.b	$00,$00
l024d:
	dc.b	'Top Notc'
	dc.b	'h (TML d'
	dc.b	'ept.)',$00
l024e:
	dc.b	'PO BOX 1'
	dc.b	'083',$00
l024f:
	dc.b	'GLASGOW',$00
l0250:
	dc.b	'SCOTLAND'
	dc.b	$00,$00
l0251:
	dc.b	'G14 9DG',$00
l0252:
	dc.b	'If you a'
	dc.b	're outsi'
	dc.b	'de Europ'
	dc.b	'e, pleas'
	dc.b	'e',$00
l0253:
	dc.b	'enclose '
	dc.b	'an extra'
	dc.b	' ',$9c,'1.50 f'
	dc.b	'or P&P',$00,$00
l0254:
	dc.b	'Make che'
	dc.b	'ques, et'
	dc.b	'c, payab'
	dc.b	'le to:',$00,$00
l0255:
	dc.b	'Colin A '
	dc.b	'Watt & B'
	dc.b	'illy All'
	dc.b	'an',$00,$00
l0256:
	dc.b	$15,'This ve'
	dc.b	'rsion is'
	dc.b	' for reg'
	dc.b	'istrees '
	dc.b	'only and'
	dc.b	$00,$00
l0257:
	dc.b	'is defin'
	dc.b	'atley NO'
	dc.b	'T public'
	dc.b	' domain.'
	dc.b	$12,$00
l0258:
	dc.b	'V 2.0 (C'
	dc.b	')1993 To'
	dc.b	'p Notch',$00
l0259:
	dcb.w	16,0
l025a:
	dcb.w	2,0
l025b:
	dcb.w	2,0
l025c:
	dcb.w	2,0
l025d:
	dcb.w	2,0
l025e:
	dcb.w	2,0
l025f:
	dcb.w	2,0
l0260:
	dcb.w	2,0
l0261:
	dcb.w	2,0
l0262:
	dc.b	$ff,$ff,$ff,$ff,$ff,$f0,$03,$fc
	dc.b	$ff,$ff,$ff,$ff,$ff,$fc,$03,$fc
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$03,$fc
	dc.b	$ff,$ff,$ff,$ff,$ff,$ff,$83,$fc
	dcb.w	2,0
	dc.b	$ff,$ff,$c3,$fc,$00,$00,$00,$00
	dc.b	$ff,$ff,$e3,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$ff,$f3,$fc,$00,$0f,$f0,$00
	dc.b	$ff,'?',$fb,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$0f,$ff,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$03,$ff,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$01,$ff,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$ff,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$7f,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,'?',$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,'?',$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$1f,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$1f,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$0f,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$0f,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$07,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$07,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$07,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$03,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$03,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$03,$fc,$00,$0f,$f0,$00
	dc.b	$ff,$00,$03,$fc,$00,$00,$00,$00
	dcb.w	3,0
	dc.b	$00,$01,$00,$00,$00,$00,$00,$00
	dc.b	$00,$00,$00,$08,'SPRM'
	dc.b	'AXNB',$00,$00,$01,$00
	dc.b	$00,$88,'VERSIO'
	dc.b	'N$',$00,$03,$c4,'4'

global_scanline_table:
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

	dcb.w	2,0

EXIT:

