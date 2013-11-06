; STFM Pro-Tracker Replay by Wizzcat/Delta Force

; Savagely ripped from an old PHF intro by Grz  21/5/04


MVOL	EQU $60				; >= $40 ($60 recommended)
FREQ	EQU 3				; 0=6.144, 1=8.192, 2=12.288
					; 3=16.384
	IFEQ FREQ
A_DATA	EQU 40				; 6.144
D_DATA	EQU 164
PARTS	EQU 3-1
LEN	EQU 41
INC	EQU $02469BC0			; 3579546/6144*65536
	ELSEIF
	IFEQ FREQ-1
A_DATA	EQU 30				; 8.192
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 41
INC	EQU $01B4F4D0			; 3579546/8192*65536
	ELSEIF
	IFEQ FREQ-2
A_DATA	EQU 20				; 12.288
D_DATA	EQU 82
PARTS	EQU 6-1
LEN	EQU 41
INC	EQU $01234DE0			; 3579546/12288*65536
	ELSEIF
	IFEQ FREQ-3
A_DATA	EQU 15				; 16.384
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 82
INC	EQU $00DA7A68			; 3579546/16384*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC

;------------------------------- Cut here ------------------------------;
;		    Rout to test replay. May omitted.			;

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,oldsp

	bsr.s	muson			; Install music


waitspc	cmpi.b	#$39,$FFFFFC02.w
	bne.s	waitspc

quit	bsr	musoff			; Restore system completely
	
	move.l	oldsp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp

	clr.w	-(sp)
	trap	#1

;------------------------------- Cut here ------------------------------;

;---------------------------------------------------- Interrupts on/off --
muson	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables
	bsr	clearym			; Clear soundchip registers

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move	#$2700,sr

	move.l	$FFFFFA06.w,s06		; Save MFP registers
	move.l	$FFFFFA12.w,s12
	move.b	$FFFFFA1D.w,s1d

	move.l	#$FF20FF10,$FFFFFA06.w	; Timer A & D on
	move.l	#$FF20FF10,$FFFFFA12.w

	bclr	#3,$FFFFFA17.w		; Autovectors

	clr.b	$FFFFFA19.w
	clr.b	$FFFFFA1D.w

	move.b	#A_DATA,$FFFFFA1F.w
	move.b	#D_DATA,$FFFFFA25.w

	move.b	#2,$FFFFFA19.w
	move.b	#$06,$FFFFFA1D.w

	move.l	$0110.w,oldtimd
	move.l	$0134.w,oldtima
	move.l	#timerd,$0110.w
	move.l	#playvec,$0134.w

	lea	sample1(pc),a6

	move	#$2500,sr
	rts


musoff	move	#$2700,sr

	move.l	oldtimd(pc),$0110.w	; Restore vectors
	move.l	oldtima(pc),$0134.w

	move.l	s06(pc),$FFFFFA06.w
	move.l	s12(pc),$FFFFFA12.w
	move.b	s1d(pc),$FFFFFA1D.w

	bset	#3,$FFFFFA17.w		; Softvectors

	move	#$2300,sr
	bsr	ym			; Clear soundchip registers
	rts



	even

chanafreq	dc.l	0
s12	DC.L 0
s1d	DC.B 0
s06	DC.L 0
	EVEN

oldtimd	DC.L 0
oldtima	DC.L 0

;-------------------------------------------- Clear soundchip registers --
clearym	move	#$2700,sr

	moveq	#$0A,d0
._1	move.b	d0,$FFFF8800.w
	clr.b	$FFFF8802.w
	dbra	d0,._1			; Clear soundchip registers
	clr.b	$FFFF8800.w
	clr.b	$FFFF8802.w
	move.b	#7,$FFFF8800.w
	move.b	#$FF,$FFFF8802.w

	rts

ym	move.b	#$00,songpos
	move.w	#$06,speed
	move.w	#$00,counter
	move.b	#$00,break
	move.w	#$00,pattpos
	;move.w	#$00,dmacon
	move.w	#$00,aud1vol
	move.w	#$00,aud2vol
	move.w	#$00,aud3vol
	move.w	#$00,aud4vol
	move.w	#$01,voice1
	move.w	#$02,voice2
	move.w	#$04,voice3
	move.w	#$08,voice4

	moveq	#$0A,d0
._1	move.b	d0,$FFFF8800.w
	clr.b	$FFFF8802.w
	dbra	d0,._1			; Clear soundchip registers
	clr.b	$FFFF8800.w
	clr.b	$FFFF8802.w
	move.b	#7,$FFFF8800.w
	move.b	#$FF,$FFFF8802.w

	rts


;----------------------------------------------- Calculate volume table --
vol	moveq	#64,d0
	lea	vtabend(pc),a0

.ploop	move.w	#255,d1
.mloop	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume
	add.b	#$80,d2
	move.b	d2,-(a0)
	dbra	d1,.mloop
	dbra	d0,.ploop

	rts

vtab	DS.B 65*256
vtabend

;-------------------------------------------- Calculate increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	DS.L $30
stab	DS.L $03A0-$30
stabend
;---------------------------------------------------- Samplecalculating --
timerd	movea.l	samp1(pc),a6

	move	#$2500,sr
	movem.l	d0-d4/a0-a4,-(sp)

	subq.w	#1,count
	bpl.s	.nomus

	move.w	#PARTS,count
	bsr	music

.nomus	move.l	samp2(pc),d0
	move.l	samp1(pc),samp2
	move.l	d0,samp1

	lea	itab(pc),a2
	lea	vtab(pc),a4
	moveq	#0,d1

v1	movea.l	wiz1lc(pc),a0

	move.w	wiz1pos(pc),d1
	move.w	wiz1frc(pc),d0

	move.w	aud1per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud1vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	REPT LEN
	add.w	d2,d0
	addx.w	d3,d1
	move.b	0(a0,d1.l),d4
	move.b	0(a1,d4.w),d4
	move.w	d4,(a3)+
	ENDR

	cmp.l	wiz1len(pc),d1
	blt.s	.ok1
	sub.w	wiz1rpt(pc),d1

.ok1	move.w	d1,wiz1pos
	move.w	d0,wiz1frc


v2	movea.l	wiz2lc(pc),a0

	move.w	wiz2pos(pc),d1
	move.w	wiz2frc(pc),d0

	move.w	aud2per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud2vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr	v234

	cmp.l	wiz2len(pc),d1
	blt.s	.ok2
	sub.w	wiz2rpt(pc),d1

.ok2	move.w	d1,wiz2pos
	move.w	d0,wiz2frc


v3	movea.l	wiz3lc(pc),a0

	move.w	wiz3pos(pc),d1
	move.w	wiz3frc(pc),d0

	move.w	aud3per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud3vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr.s	v234

	cmp.l	wiz3len(pc),d1
	blt.s	.ok3
	sub.w	wiz3rpt(pc),d1

.ok3	move.w	d1,wiz3pos
	move.w	d0,wiz3frc


v4	movea.l	wiz4lc(pc),a0

	move.w	wiz4pos(pc),d1
	move.w	wiz4frc(pc),d0

	move.w	aud4per(pc),d4
	add.w	d4,d4
	add.w	d4,d4
	move.w	0(a2,d4.w),d3
	move.w	2(a2,d4.w),d2

	move.w	aud4vol(pc),d4
	asl.w	#8,d4
	lea	0(a4,d4.w),a1

	moveq	#0,d4
	movea.l	samp1(pc),a3

	bsr.s	v234

	cmp.l	wiz4len(pc),d1
	blt.s	.ok4
	sub.w	wiz4rpt(pc),d1

.ok4	move.w	d1,wiz4pos
	move.w	d0,wiz4frc


	movem.l	(sp)+,d0-d4/a0-a4
	rte

v234	REPT LEN
	add.w	d2,d0
	addx.w	d3,d1
	move.b	0(a0,d1.l),d4
	move.b	0(a1,d4.w),d4
	add.w	d4,(a3)+
	ENDR

	rts

;-------------------------------------------- Hardware-registers & data --
count	DC.W PARTS

wiz1lc	DC.L sample1
wiz1len	DC.L 320
wiz1rpt	DC.W 320
wiz1pos	DC.W 0
wiz1frc	DC.W 0

wiz2lc	DC.L sample1
wiz2len	DC.L 320
wiz2rpt	DC.W 320
wiz2pos	DC.W 0
wiz2frc	DC.W 0

wiz3lc	DC.L sample1
wiz3len	DC.L 320
wiz3rpt	DC.W 320
wiz3pos	DC.W 0
wiz3frc	DC.W 0

wiz4lc	DC.L sample1
wiz4len	DC.L 320
wiz4rpt	DC.W 320
wiz4pos	DC.W 0
wiz4frc	DC.W 0

aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3

aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3

aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3

aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0

dmactrl	DC.W 0
dummy	DC.L 0

samp1	DC.L sample1
samp2	DC.L sample2

sample1	REPT LEN
	DC.W $0200
	ENDR

sample2	REPT LEN
	DC.W $0200
	ENDR

;--------------------------------------------------- Playback-interrupt --
playvec	move.w	(a6)+,d7
	lsl.w	#4,d7
	movem.l	snd_tab(pc,d7.w),d5-d7
	movem.l	d5-d7,$FFFF8800.w
	rte

;--------------------------------------------- Sound data for soundchip --
snd_tab	REPT 384
	DC.L $08000F00,$09000A00,$0A000000,0
	ENDR

	DC.L $08000F00,$09000A00,$0A000000,0
	DC.L $08000F00,$09000A00,$0A000000,0
	DC.L $08000F00,$09000900,$0A000900,0
	DC.L $08000F00,$09000900,$0A000900,0
	DC.L $08000F00,$09000900,$0A000800,0
	DC.L $08000F00,$09000900,$0A000800,0
	DC.L $08000F00,$09000800,$0A000700,0
	DC.L $08000F00,$09000800,$0A000700,0
	DC.L $08000E00,$09000B00,$0A000D00,0
	DC.L $08000E00,$09000B00,$0A000D00,0
	DC.L $08000E00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000A00,$0A000D00,0
	DC.L $08000E00,$09000A00,$0A000D00,0
	DC.L $08000E00,$09000C00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000C00,0
	DC.L $08000E00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000D00,$0A000800,0
	DC.L $08000E00,$09000D00,$0A000800,0
	DC.L $08000E00,$09000D00,$0A000700,0
	DC.L $08000E00,$09000D00,$0A000700,0
	DC.L $08000E00,$09000D00,$0A000000,0
	DC.L $08000E00,$09000D00,$0A000000,0
	DC.L $08000B00,$09000E00,$0A000C00,0
	DC.L $08000B00,$09000E00,$0A000C00,0
	DC.L $08000E00,$09000B00,$0A000C00,0
	DC.L $08000E00,$09000B00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000B00,0
	DC.L $08000E00,$09000C00,$0A000B00,0
	DC.L $08000A00,$09000E00,$0A000C00,0
	DC.L $08000A00,$09000E00,$0A000C00,0
	DC.L $08000E00,$09000A00,$0A000C00,0
	DC.L $08000E00,$09000A00,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000A00,0
	DC.L $08000E00,$09000C00,$0A000A00,0
	DC.L $08000E00,$09000900,$0A000C00,0
	DC.L $08000E00,$09000900,$0A000C00,0
	DC.L $08000E00,$09000C00,$0A000900,0
	DC.L $08000E00,$09000C00,$0A000900,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000800,0
	DC.L $08000E00,$09000C00,$0A000700,0
	DC.L $08000E00,$09000C00,$0A000700,0
	DC.L $08000E00,$09000C00,$0A000600,0
	DC.L $08000E00,$09000C00,$0A000300,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000D00,$09000D00,$0A000B00,0
	DC.L $08000E00,$09000B00,$0A000A00,0
	DC.L $08000E00,$09000B00,$0A000A00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000C00,$0A000C00,0
	DC.L $08000D00,$09000D00,$0A000A00,0
	DC.L $08000D00,$09000D00,$0A000A00,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000E00,$09000B00,$0A000800,0
	DC.L $08000D00,$09000D00,$0A000900,0
	DC.L $08000D00,$09000D00,$0A000900,0
	DC.L $08000E00,$09000A00,$0A000900,0
	DC.L $08000E00,$09000A00,$0A000900,0
	DC.L $08000D00,$09000D00,$0A000800,0
	DC.L $08000D00,$09000D00,$0A000700,0
	DC.L $08000D00,$09000D00,$0A000600,0
	DC.L $08000D00,$09000D00,$0A000600,0
	DC.L $08000E00,$09000900,$0A000900,0
	DC.L $08000E00,$09000900,$0A000900,0
	DC.L $08000E00,$09000800,$0A000900,0
	DC.L $08000E00,$09000800,$0A000900,0
	DC.L $08000E00,$09000900,$0A000800,0
	DC.L $08000E00,$09000900,$0A000800,0
	DC.L $08000E00,$09000700,$0A000900,0
	DC.L $08000E00,$09000900,$0A000700,0
	DC.L $08000E00,$09000900,$0A000700,0
	DC.L $08000E00,$09000900,$0A000600,0
	DC.L $08000E00,$09000900,$0A000600,0
	DC.L $08000E00,$09000800,$0A000700,0
	DC.L $08000E00,$09000800,$0A000700,0
	DC.L $08000E00,$09000800,$0A000600,0
	DC.L $08000E00,$09000800,$0A000600,0
	DC.L $08000E00,$09000800,$0A000400,0
	DC.L $08000E00,$09000800,$0A000400,0
	DC.L $08000E00,$09000700,$0A000500,0
	DC.L $08000E00,$09000700,$0A000400,0
	DC.L $08000E00,$09000700,$0A000300,0
	DC.L $08000E00,$09000600,$0A000400,0
	DC.L $08000E00,$09000600,$0A000300,0
	DC.L $08000E00,$09000500,$0A000400,0
	DC.L $08000E00,$09000500,$0A000200,0
	DC.L $08000E00,$09000400,$0A000200,0
	DC.L $08000E00,$09000300,$0A000200,0
	DC.L $08000E00,$09000000,$0A000000,0
	DC.L $08000D00,$09000B00,$0A000A00,0
	DC.L $08000D00,$09000B00,$0A000A00,0
	DC.L $08000A00,$09000C00,$0A000C00,0
	DC.L $08000A00,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000A00,$0A000C00,0
	DC.L $08000D00,$09000900,$0A000B00,0
	DC.L $08000D00,$09000900,$0A000B00,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000A00,$0A000A00,0
	DC.L $08000D00,$09000A00,$0A000A00,0
	DC.L $08000900,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000C00,$09000C00,$0A000900,0
	DC.L $08000800,$09000C00,$0A000C00,0
	DC.L $08000800,$09000C00,$0A000C00,0
	DC.L $08000C00,$09000C00,$0A000800,0
	DC.L $08000C00,$09000C00,$0A000800,0
	DC.L $08000D00,$09000B00,$0A000400,0
	DC.L $08000D00,$09000B00,$0A000400,0
	DC.L $08000C00,$09000C00,$0A000700,0
	DC.L $08000C00,$09000C00,$0A000600,0
	DC.L $08000C00,$09000C00,$0A000600,0
	DC.L $08000C00,$09000C00,$0A000500,0
	DC.L $08000D00,$09000A00,$0A000700,0
	DC.L $08000D00,$09000A00,$0A000600,0
	DC.L $08000D00,$09000A00,$0A000600,0
	DC.L $08000D00,$09000A00,$0A000500,0
	DC.L $08000D00,$09000900,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000900,0
	DC.L $08000B00,$09000B00,$0A000B00,0
	DC.L $08000D00,$09000800,$0A000800,0
	DC.L $08000D00,$09000800,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000800,0
	DC.L $08000D00,$09000900,$0A000500,0
	DC.L $08000D00,$09000900,$0A000400,0
	DC.L $08000D00,$09000800,$0A000600,0
	DC.L $08000C00,$09000B00,$0A000700,0
	DC.L $08000D00,$09000700,$0A000700,0
	DC.L $08000C00,$09000B00,$0A000600,0
	DC.L $08000B00,$09000B00,$0A000A00,0
	DC.L $08000800,$09000A00,$0A000C00,0
	DC.L $08000C00,$09000B00,$0A000200,0
	DC.L $08000C00,$09000A00,$0A000800,0
	DC.L $08000C00,$09000B00,$0A000000,0
	DC.L $08000D00,$09000600,$0A000400,0
	DC.L $08000D00,$09000500,$0A000500,0
	DC.L $08000C00,$09000900,$0A000900,0
	DC.L $08000D00,$09000500,$0A000400,0
	DC.L $08000B00,$09000B00,$0A000900,0
	DC.L $08000D00,$09000400,$0A000300,0
	DC.L $08000B00,$09000A00,$0A000A00,0
	DC.L $08000C00,$09000A00,$0A000500,0
	DC.L $08000C00,$09000900,$0A000800,0
	DC.L $08000B00,$09000B00,$0A000800,0
	DC.L $08000C00,$09000A00,$0A000000,0
	DC.L $08000C00,$09000A00,$0A000000,0
	DC.L $08000C00,$09000900,$0A000700,0
	DC.L $08000B00,$09000B00,$0A000700,0
	DC.L $08000C00,$09000900,$0A000600,0
	DC.L $08000B00,$09000A00,$0A000900,0
	DC.L $08000B00,$09000B00,$0A000600,0
	DC.L $08000A00,$09000A00,$0A000A00,0
	DC.L $08000B00,$09000B00,$0A000500,0
	DC.L $08000B00,$09000A00,$0A000800,0
	DC.L $08000B00,$09000B00,$0A000200,0
	DC.L $08000C00,$09000700,$0A000700,0
	DC.L $08000C00,$09000800,$0A000400,0
	DC.L $08000C00,$09000700,$0A000600,0
	DC.L $08000B00,$09000900,$0A000900,0
	DC.L $08000A00,$09000A00,$0A000900,0
	DC.L $08000C00,$09000600,$0A000600,0
	DC.L $08000C00,$09000700,$0A000300,0
	DC.L $08000B00,$09000A00,$0A000500,0
	DC.L $08000B00,$09000900,$0A000800,0
	DC.L $08000B00,$09000A00,$0A000300,0
	DC.L $08000A00,$09000A00,$0A000800,0
	DC.L $08000B00,$09000A00,$0A000000,0
	DC.L $08000B00,$09000900,$0A000700,0
	DC.L $08000B00,$09000800,$0A000800,0
	DC.L $08000A00,$09000900,$0A000900,0
	DC.L $08000A00,$09000A00,$0A000700,0
	DC.L $08000C00,$09000100,$0A000100,0
	DC.L $08000A00,$09000A00,$0A000600,0
	DC.L $08000B00,$09000800,$0A000700,0
	DC.L $08000A00,$09000A00,$0A000500,0
	DC.L $08000A00,$09000900,$0A000800,0
	DC.L $08000A00,$09000A00,$0A000400,0
	DC.L $08000A00,$09000A00,$0A000300,0
	DC.L $08000A00,$09000A00,$0A000200,0
	DC.L $08000900,$09000900,$0A000900,0
	DC.L $08000A00,$09000800,$0A000800,0
	DC.L $08000B00,$09000800,$0A000100,0
	DC.L $08000A00,$09000900,$0A000600,0
	DC.L $08000B00,$09000700,$0A000400,0
	DC.L $08000A00,$09000900,$0A000500,0
	DC.L $08000900,$09000900,$0A000800,0
	DC.L $08000A00,$09000900,$0A000300,0
	DC.L $08000A00,$09000800,$0A000600,0
	DC.L $08000900,$09000900,$0A000700,0
	DC.L $08000A00,$09000900,$0A000000,0
	DC.L $08000900,$09000800,$0A000800,0
	DC.L $08000A00,$09000800,$0A000400,0
	DC.L $08000900,$09000900,$0A000600,0
	DC.L $08000A00,$09000800,$0A000100,0
	DC.L $08000900,$09000900,$0A000500,0
	DC.L $08000900,$09000800,$0A000700,0
	DC.L $08000800,$09000800,$0A000800,0
	DC.L $08000900,$09000800,$0A000600,0
	DC.L $08000900,$09000900,$0A000200,0
	DC.L $08000900,$09000700,$0A000700,0
	DC.L $08000900,$09000900,$0A000000,0
	DC.L $08000800,$09000800,$0A000700,0
	DC.L $08000900,$09000700,$0A000600,0
	DC.L $08000800,$09000800,$0A000600,0
	DC.L $08000900,$09000800,$0A000200,0
	DC.L $08000900,$09000600,$0A000600,0
	DC.L $08000800,$09000700,$0A000700,0
	DC.L $08000800,$09000800,$0A000400,0
	DC.L $08000800,$09000700,$0A000600,0
	DC.L $08000800,$09000800,$0A000200,0
	DC.L $08000700,$09000700,$0A000700,0
	DC.L $08000800,$09000600,$0A000600,0
	DC.L $08000800,$09000700,$0A000400,0
	DC.L $08000700,$09000700,$0A000600,0
	DC.L $08000800,$09000600,$0A000500,0
	DC.L $08000800,$09000600,$0A000400,0
	DC.L $08000700,$09000600,$0A000600,0
	DC.L $08000700,$09000700,$0A000400,0
	DC.L $08000800,$09000500,$0A000400,0
	DC.L $08000600,$09000600,$0A000600,0
	DC.L $08000700,$09000600,$0A000400,0
	DC.L $08000700,$09000500,$0A000500,0
	DC.L $08000600,$09000600,$0A000500,0
	DC.L $08000600,$09000600,$0A000400,0
	DC.L $08000600,$09000500,$0A000500,0
	DC.L $08000600,$09000600,$0A000200,0
	DC.L $08000600,$09000500,$0A000400,0
	DC.L $08000500,$09000500,$0A000500,0
	DC.L $08000600,$09000500,$0A000200,0
	DC.L $08000500,$09000500,$0A000400,0
	DC.L $08000500,$09000400,$0A000400,0
	DC.L $08000500,$09000500,$0A000200,0
	DC.L $08000400,$09000400,$0A000400,0
	DC.L $08000400,$09000400,$0A000300,0
	DC.L $08000400,$09000400,$0A000200,0
	DC.L $08000400,$09000300,$0A000300,0
	DC.L $08000300,$09000300,$0A000300,0
	DC.L $08000300,$09000300,$0A000200,0
	DC.L $08000300,$09000200,$0A000200,0
	DC.L $08000200,$09000200,$0A000200,0
	DC.L $08000200,$09000200,$0A000100,0
	DC.L $08000100,$09000100,$0A000100,0
	DC.L $08000200,$09000100,$0A000000,0
	DC.L $08000100,$09000100,$0A000000,0
	DC.L $08000100,$09000000,$0A000000,0
	DC.L $08000000,$09000000,$0A000000,0

	REPT 384
	DC.L $08000000,$09000000,$0A000000,0
	ENDR

;========================================================= EMULATOR END ==

prepare	lea	workspc,a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	lea	data(pc),a1
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	#workspc,a0
	bgt.s	.nospac

	rts

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	lea	data,a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loopd	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loopd
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	lea	data,a0
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	lea	data+$043C(pc),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1
	cmp.b	data+$03B6(pc),d1
	bne.s	endr
	move.b	data+$03B7(pc),songpos
endr	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3
	even

oldsp	dc.l	0
	even
data	incbin	a:\*.mod
	even
workspc	DS.W	1
	even


