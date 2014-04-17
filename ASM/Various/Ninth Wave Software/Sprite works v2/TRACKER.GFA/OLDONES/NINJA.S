; Ninja III ProReplayer v2.2/v3.42
;
; Hacked by MUG U.K(tm) from Star Replayer v3.42
;
; Done at The Lemmings 'Out In The Middle Of Nowhere' Party on 13/7/93
;
; This routine auto-detects Speed Packer 3  - Remove it if necessary
;
; v2.2 DOES NOT WORK ON FALCON whereas v3.42 works beautifully !!
;
; On my ST, at 21Khz and d1=0 and d2=0 there is *NO* processor time left !
; None whatsoever !!
;

	opt	o+,ow-,s-


fade_off	equ	1

super	clr.l	-(a7)		; set TAB to 8
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	move.l	$70.w,old_70
	
	move.b	$fffffa07.w,old_a07
	move.b	$fffffa09.w,old_a09
	move.b	$fffffa13.w,old_a13
	move.b	$fffffa15.w,old_a15

	lea	text(pc),a0	
	bsr	print
	bsr	mouseoff


start	bsr	play

wait	move.b	$fffc02,d0
try_sp	cmpi.b	#$39,d0
	bne.s	wait
;
; Fade out module option - set 'fade_off' = 1
;
	ifne	fade_off
	move.w	#3,replay+28

	move.w	#3000,d0
loop	rept	150
	nop
	endr
	dbf	d0,loop
	endc
	clr	replay+28
	
	bsr	stop
	bsr	mouseon

exit	move.b	old_a07,$fffffa07.w
	move.b	old_a09,$fffffa09.w
	move.b	old_a13,$fffffa13.w
	move.b	old_a15,$fffffa15.w

	move.l	old_70,$70.w
	move.l	#old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

; Values for registers:
; ---------------------
;
; D0 = 
;
; $1388 = 5.0Khz
; $2134 = 8.5 khz
; $2ee0 = 12 khz
; $36b0 = 15.0 khz
; $5208 = 21 khz maximum ???
;
; D1 = Sound Mode
;
; 0 = 7-bit replay (all volume changes)
; 1 = 8-bit replay (all volume changes)
; 2 = 8-bit replay (NO volume changes!)
; 3 = STE/TT replay (all volume changes)
; 4 = STE/TT replay (NO volume changes)
;
; D2 = number of the used tracks ? (1-4, 0 none) - CAN'T TRANSLATE line below!
; d2 = Nr. des wegzulassenden Tracks      (1-4 oder 0=keiner) nur bei ST-Mode
; -------------------------------------------
; Register Usage etc.
;
; ST  = Cannot use a5,a6,d7
; STE = All registers are available
;
; Other information
;
; ST  = uses Timer D & soundchip for replay
; STE = uses Microwire Dat & Mask, SMODCNTR, FRMBAS, FRMEND
;
; (more translation required!!)
;
; benutzte Timer und Hardware Register
; ST
;           Timer D / Sound Chip
;           MFP im AOI-Modus keine L”schung des Interrupt_in_Service_A/B
;           Register n”tig. bclr #4,$fffffa11.w z.B. fr Timer D
; STe
;           MicoWire Dat / MicroWire Mask / SMODCNTR
;           sowie natrlich FRMBAS / FRMEND
;  Steereereeoo & 12517 Hz sind fest eingestellt
; -------------------------------------------
; Useful offsets in the code
;
; replay + 12 = VU Meters, 4 words    ($00 - $3e) --> read only
; replay + 20 = Song position, 1 word ($00 - $77) --> read only
; replay + 22 = Pattern posit. 1 word ($00 - $3f) --> read only
; replay + 24 = 
; replay + 26 = 
; replay + 28 = Fade out volume (still needs switching off though!)
; 
; mod_player+24:  Abblendspeed (0=nicht abblenden, 1=schnell bis 10=langsam)
;                 (Wort) (read/write) (Handhabung siehe main)
; mod_player+26:  Basislautst„rke ($40=normal laut, $00=Stille) (Wort)
;                 (read/write)  (Handhabung siehe main)
;************************************


play	lea	music,a0
	bsr	unpack

	lea	music,a0
	bsr	print

;
; Start it Off
;
	lea	music,a0
	move.w	#$5208,d0			; Khz
	moveq.l	#0,d1			; volume variation ?
	moveq.l	#0,d2			; 

	jsr	replay
	clr.b	$fffffa07.w	; Timer B off ?
	clr.b	$fffffa09.w	; Timer C off ?
	move.l	#new_70,$70.w
	jsr	replay+4
	clr.w	replay+24
exitpl	rts

stop	bsr	replay+8
	rts

new_70	movem.l	a0-a4/d0-d6,-(sp)
 	move.w	#$700,$ffff8240.w
	jsr	replay+12
	move.w	#$777,$ffff8240.w
	movem.l	(sp)+,a0-a4/d0-d6
	rte

print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

mouseoff	move.b	#$12,$fffffc02.w
	rts

mouseon	move.b	#$08,$fffffc02.w
	rts

text	dc.b	$1b,"E"
	dc.b	"+---------------------------------+",13,10
	dc.b	"| Star Player Module Replay v3.42 |",13,10
	dc.b	"|                                 |",13,10
	dc.b	"| Coded by: Ninja III/Independent |",13,10
	dc.b	"+---------------------------------+",13,10,10
	dc.b	"Ripped by MUG U.K",$bf,13,10,10
	dc.b	"Space to exit.",13,10,10
	dc.b	27,"pModule Name:",27,"q ",0
	even

old_sp	ds.l	1
old_70	ds.l	1
old_a07	ds.b	1
old_a09	ds.b	1
old_a13	ds.b	1
old_a15	ds.b	1
	even

* UNPACK source for SPACKERv3	(C)THE FIREHAWKS'92
* -------------------------------------------------
* in	a0: even address start packed block
* out	d0: original length or 0 if not SPv3 packed
* =================================================
* Use AUTO_SP3.PRG for multiblk packed files

unpack:	moveq	#0,d0
	movem.l	d0-a6,-(sp)
	lea	sp3_53(pc),a6
	movea.l	a0,a1
	cmpi.l	#'SPv3',(a1)+
	bne.s	sp3_02
	tst.w	(a1)
	bne.s	sp3_02
	move.l	(a1)+,d5
	move.l	(a1)+,d0
	move.l	(a1)+,(sp)
	movea.l	a0,a2
	adda.l	d0,a0
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	move.l	-(a0),-(a1)
	adda.l	(sp),a1
	lea	sp3_58-sp3_53(a6),a3
	moveq	#128-1,d0
sp3_01:	move.l	(a2)+,(a3)+
	dbf	d0,sp3_01
	suba.l	a2,a3
	move.l	a3,-(sp)
	bsr.s	sp3_03
	bsr	sp3_21
	move.b	-(a0),d0
	adda.l	(sp)+,a0
	move.b	d0,(a0)+
	lea	sp3_58-sp3_53(a6),a2
	bsr	sp3_22
	bsr	sp3_15
sp3_02:	movem.l	(sp)+,d0-a6
	rts
sp3_03:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_04
	move.w	$FFFF8240.W,2(a6)
	btst	#1,$FFFF8260.W
	bne.s	sp3_04
	swap	d5
sp3_04:	clr.w	d5
	move.w	-(a0),d6
	lea	sp3_54-sp3_53(a6),a3
	move.b	d6,(a3)+
	moveq	#1,d3
	moveq	#6,d4
sp3_05:	cmp.b	d6,d3
	bne.s	sp3_06
	addq.w	#2,d3
sp3_06:	move.b	d3,(a3)+
	addq.w	#2,d3
	dbf	d4,sp3_05
	moveq	#$10,d4
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),(a3)+
	move.b	d4,(a3)+
	move.b	-(a0),d4
	move.w	d4,(a6)
	lea	sp3_57-sp3_53(a6),a5
	move.b	-(a0),d4
	lea	1(a5,d4.w),a3
sp3_07:	move.b	-(a0),-(a3)
	dbf	d4,sp3_07
	move.b	-(a0),-(a3)
	beq.s	sp3_08
	suba.w	d4,a0
sp3_08:	moveq	#0,d2
	move.b	-(a0),d2
	move.w	d2,d3
	move.b	-(a0),d7
sp3_09:	bsr.s	sp3_10
	bsr.s	sp3_10
	dbf	d2,sp3_09
	rts
sp3_10:	not.w	d4
	add.b	d7,d7
	bne.s	sp3_11
	move.b	-(a0),d7
	addx.b	d7,d7
sp3_11:	bcs.s	sp3_12
	move.w	d2,d0
	subq.w	#1,d3
	sub.w	d3,d0
	add.w	d0,d0
	add.w	d4,d0
	add.w	d0,d0
	neg.w	d0
	move.w	d0,-(a3)
	rts
sp3_12:	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	beq.s	sp3_13
	move.b	d0,-(a3)
	moveq	#2,d1
	bsr	sp3_44
	add.w	d0,d0
	move.b	d0,-(a3)
	rts
sp3_13:	moveq	#2,d1
	bsr	sp3_44
	move.w	sp3_55-sp3_53(a6),d1
	add.w	d0,d0
	beq.s	sp3_14
	move.w	sp3_55+2-sp3_53(a6),d1
sp3_14:	or.w	d1,d0
	move.w	d0,-(a3)
	rts
sp3_15:	move.w	SR,d1
	andi.w	#$2000,d1
	beq.s	sp3_16
	move.w	2(a6),$FFFF8240.W
sp3_16:	tst.w	d6
	bpl.s	sp3_20
	movea.l	a1,a2
	movea.l	a1,a3
	adda.l	4(sp),a3
sp3_17:	moveq	#3,d6
sp3_18:	move.w	(a2)+,d0
	moveq	#3,d5
sp3_19:	add.w	d0,d0
	addx.w	d1,d1
	add.w	d0,d0
	addx.w	d2,d2
	add.w	d0,d0
	addx.w	d3,d3
	add.w	d0,d0
	addx.w	d4,d4
	dbf	d5,sp3_19
	dbf	d6,sp3_18
	cmpa.l	a2,a3
	blt.s	sp3_20
	movem.w	d1-d4,-8(a2)
	cmpa.l	a2,a3
	bne.s	sp3_17
sp3_20:	rts
sp3_21:	move.b	-(a0),-(a1)
sp3_22:	swap	d5
;	beq.s	sp3_23

	eori.w	#$777,$ffff8240.w
;	move.w	d5,$FFFF8240.W

sp3_23:	lea	sp3_56+2-sp3_53(a6),a3
	cmpa.l	a0,a2
	blt.s	sp3_25
	rts
sp3_24:	adda.w	d3,a3
sp3_25:	add.b	d7,d7
	bcc.s	sp3_28
	beq.s	sp3_27
sp3_26:	move.w	(a3),d3
	bmi.s	sp3_24
	bra.s	sp3_29
sp3_27:	move.b	-(a0),d7
	addx.b	d7,d7
	bcs.s	sp3_26
sp3_28:	move.w	-(a3),d3
	bmi.s	sp3_24
sp3_29:	ext.w	d3
	jmp	sp3_30(pc,d3.w)
sp3_30:	bra.s	sp3_30
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_41
	bra.s	sp3_37
	bra.s	sp3_36
	bra.s	sp3_32
	bra.s	sp3_33
	bra.s	sp3_31
	bra.s	sp3_34
	bra.s	sp3_21
sp3_31:	move.b	(a5),-(a1)
	bra.s	sp3_22
sp3_32:	bsr.s	sp3_43
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_33:	bsr.s	sp3_43
	add.w	(a6),d0
	move.b	1(a5,d0.w),-(a1)
	bra.s	sp3_22
sp3_34:	moveq	#3,d1
	bsr.s	sp3_44
	lsr.w	#1,d0
	bcc.s	sp3_35
	not.w	d0
sp3_35:	move.b	(a1),d1
	add.w	d0,d1
	move.b	d1,-(a1)
	bra.s	sp3_22
sp3_36:	lea	sp3_52-2-sp3_53(a6),a4
	bsr.s	sp3_48
	addi.w	#16,d0
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
	move.b	-(a3),-(a1)
	bra	sp3_22
sp3_37:	moveq	#3,d1
	bsr.s	sp3_44
	tst.w	d0
	beq.s	sp3_38
	addq.w	#5,d0
	bra.s	sp3_40
sp3_38:	move.b	-(a0),d0
	beq.s	sp3_39
	addi.w	#20,d0
	bra.s	sp3_40
sp3_39:	moveq	#13,d1
	bsr.s	sp3_44
	addi.w	#276,d0
sp3_40:	move.w	d0,d3
	add.w	d3,d3
sp3_41:	lea	sp3_52-sp3_53(a6),a4
	bsr.s	sp3_48
	lsr.w	#1,d3
	lea	1(a1,d0.w),a3
	move.b	-(a3),-(a1)
sp3_42:	move.b	-(a3),-(a1)
	dbf	d3,sp3_42
	bra	sp3_22
sp3_43:	moveq	#0,d1
	move.b	(a3),d1
sp3_44:	moveq	#0,d0
	cmpi.w	#7,d1
	bpl.s	sp3_47
sp3_45:	add.b	d7,d7
	beq.s	sp3_46
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_46:	move.b	-(a0),d7
	addx.b	d7,d7
	addx.w	d0,d0
	dbf	d1,sp3_45
	rts
sp3_47:	move.b	-(a0),d0
	subq.w	#8,d1
	bpl.s	sp3_45
	rts
sp3_48:	moveq	#0,d1
	move.b	(a3),d1
	adda.w	d1,a4
	move.w	(a4),d1
	bsr.s	sp3_44
	tst.b	d6
	beq.s	sp3_51
	move.w	d0,d4
	andi.w	#$FFF0,d4
	andi.w	#$000F,d0
	beq.s	sp3_50
	lsr.w	#1,d0
	beq.s	sp3_49
	roxr.b	#1,d7
	bcc.s	sp3_50
	move.b	d7,(a0)+
	moveq	#-128,d7
	bra.s	sp3_50
sp3_49:	moveq	#2,d1
	bsr.s	sp3_44
	add.w	d0,d0
	or.w	d4,d0
	bra.s	sp3_51
sp3_50:	lea	sp3_54-sp3_53(a6),a3
	or.b	(a3,d0.w),d4
	move.w	d4,d0
sp3_51:	add.w	18(a4),d0
	rts

	DC.W	3
sp3_52:	DC.W	4,5,7,8,9,10,11,12
	DC.W	-16
	DC.W	0,32,96,352,864,1888,3936,8032

sp3_53:	DS.L	1
sp3_54:	DS.B	8
sp3_55:	DS.W	2*64
sp3_56:	DS.W	2
	DS.B	1
sp3_57:	DS.B	1
	DS.B	2*64
sp3_58:	DS.B	512

;
; NINJA3.BIN = v2.2
; NINJA342.BIN = v3.2
;
replay	incbin	'ninja342.bin'
	even

	section	data

music	incbin	'c:\*.mod',0
m_end	even

