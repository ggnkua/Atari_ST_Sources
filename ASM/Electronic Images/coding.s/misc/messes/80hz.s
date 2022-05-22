; Little program to set 80hz...
; Griff '93
; or 62hz 640*480
; or 80hz 640*360
		output c:\auto\80hz.prg

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

; Falcon video register equates

vwrap           EQU $FFFF8210
_spshift        EQU $FFFF8266
hht             EQU $FFFF8282
hbb             EQU $FFFF8284
hbe             EQU $FFFF8286
hdb             EQU $FFFF8288
hde             EQU $FFFF828A
hss             EQU $FFFF828C
hfs             EQU $FFFF828E
hee             EQU $FFFF8290
vft             EQU $FFFF82A2
vbb             EQU $FFFF82A4
vbe             EQU $FFFF82A6
vdb             EQU $FFFF82A8
vde             EQU $FFFF82AA
vss             EQU $FFFF82AC
vco             EQU $FFFF82C2


scr_height	EQU 180

doit	macro
	MOVE.W #(scr_height*2)+42,(vft).w
	MOVE.W #(scr_height*2)+42-5,(vss).w
	move.w #24+4,(vdb.w).w	; display start
	move.w #24,(vbe.w).w	; border start
	move.w #(scr_height*2)+24+4,(vde.w).w	; display end
	move.w #(scr_height*2)+24+4+4,(vbb.w).w	; border end.
	endm

l13C690	move.l	#$100,d5
	addi.l	#l13CA90,d5
	subi.l	#l13C690,d5
	pea	int_text(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7
	move.w	#$59,-(a7)
	trap	#14
	addq.w	#2,a7
	btst	#0,d0
	beq	is_wrong_mon
	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	move.l	d0,2(a7)
	move.l	$88.w,l13C712
	move.l	#l13C716,$88.w
	move.l	$B8.w,l13C832
	move.l	#l13C836,$B8.w
	trap	#1
	addq.w	#6,a7
	clr.w	-(a7)
	move.l	d5,-(a7)
	move.w	#$31,-(a7)
	trap	#1

is_wrong_mon	pea	wrong_mon(pc)
		move.w	#9,-(a7)
		trap	#1
		addq.w	#6,a7
		clr.w	-(a7)
		trap	#1

; New trap #2

	DC.L 	"XBRA"
	DC.L	"74HZ"
l13C712	ori.b	#0,d0
l13C716	cmp.w	#$73,d0
	beq.s	l13C724
l13C71C	move.l	l13C712,-(a7)
	rts
l13C724	movea.l	d1,a0
	movea.l	(a0),a1
	cmpi.w	#1,(a1)
	bne	l13C71C
	movea.l	4(a0),a1
	cmpi.w	#$B,(a1)
	bcc	l13C71C
	move.l	a0,-(a7)
	tst.w	$59E.w
	beq	l13C748
	clr.w	-(a7)
l13C748	pea	l13C756(pc)
	move	sr,-(a7)
	move.l	l13C712,-(a7)
	rts
l13C756	move.w	$184C,d0
	bsr	l13C956
	movea.l	(a7)+,a0
	movea.l	$C(a0),a1
	move.w	d1,(a1)			; width - 1
	subi.w	#1,(a1)
	move.w	scr_lines(pc),2(a1)
	subi.w	#1,2(a1)		; height - 1
	moveq	#1,d0
	lsl.w	d2,d0
	move.w	d0,$1A(a1)		; colours?
	bsr	l13C99E
	move.w	$184C.w,-(a7)
	move.w	#$58,-(a7)
	trap	#14
	addq.l	#4,a7
	cmpi.w	#scr_height,scr_lines
	beq.s	l13C7A6
	cmpi.w	#scr_height*2,scr_lines
	bne.s	l13C7B2
l13C7A6	doit
l13C7B2	rte

; New trap #14 (xbios)

	DC.L "XBRA"
	DC.L	"74HZ"
l13C832	ori.b	#0,d0
l13C836	move.l	usp,a0
	btst	#5,(a7)
	beq	l13C850
	lea	6(a7),a0
	tst.w	$59E.w
	beq	l13C850
	lea	8(a7),a0
l13C850	move.w	(a0),d0
	cmpi.w	#5,d0
	bhi	l13C864
	bcs	l13C89E
	lea	l13C8A6(pc),a1
	bra.s	l13C882
l13C864	cmpi.w	#$58,d0
	bcs	l13C89E
	bhi	l13C876
	lea	l13C936(pc),a1
	bra.s	l13C882
l13C876	cmpi.w	#$5B,d0
	bne	l13C89E
	lea	l13CA06(pc),a1
l13C882	move.l	$C(a0),-(a7)
	move.l	8(a0),-(a7)
	move.l	4(a0),-(a7)
	move.l	(a0),-(a7)
	tst.w	$59E.w
	beq	l13C89A
	clr.w	-(a7)
l13C89A	pea	(a1)
	move	sr,-(a7)
l13C89E	move.l	l13C832,-(a7)
	rts

; xbios(5) - set screen
; return size of screen. (returns d0.l)

l13C8A6	move.w	$C(a7),d0
	movea.l	6(a7),a1
	movea.l	2(a7),a0
	cmpi.w	#3,$A(a7)
	bne	l13C924
	bmi	l13C91E
	tst.w	d0
	bmi.s	l13C91E
	bsr	l13C956
	move.w	d2,d0
	mulu.w	d1,d0
	mulu.w	scr_lines,d0
	lsr.l	#3,d0
	move.l	d0,l13CA20
	bsr	l13C99E
	move.w	$C(a7),d0
	move.w	d0,-(a7)
	move.w	#$58,-(a7)
	trap	#14
	addq.l	#4,a7
	doit
	move.l	l13CA20,-(a7)
	move.w	#$15,-(a7)
	trap	#1
	addq.l	#6,a7
	movea.l	d0,a0
	move.w	#$FFFF,-(a7)
	move.w	#$FFFF,-(a7)
	pea	(a0)
	pea	(a0)
	move.w	#5,-(a7)
	trap	#14
	lea	$E(a7),a7
l13C91E	lea	$10(a7),a7
	rte
l13C924	
	doit
	lea	$10(a7),a7
	rte
l13C936	move.w	2(a7),d0
	bmi.s	l13C94A
	bsr	l13C956
	bsr	l13C99E
	lea	$10(a7),a7
	rte
l13C94A	move.w	$184C,d0
	lea	$10(a7),a7
	rte 
l13C956	move.l	#$280,d1
	move.w	#scr_height,d2
	btst	#7,d0
	beq.s	l13C96A
	move.w	#$C8,d2
l13C96A	btst	#8,d0		; interlace
	beq.s	l13C972
	lsl.w	#1,d2
l13C972	move.w	d2,scr_lines
	btst	#3,d0		; 80 col?
	bne.s	l13C982
	move.w	#$140,d1
l13C982	btst	#6,d0		; overscan ?
	beq.s	l13C990
	mulu.w	#$C,d1		; * 1.2
	divu.w	#$A,d1		;
l13C990	andi.l	#7,d0		; (d1 = x width)
	moveq	#2,d2
	lsl.w	d0,d2
	lsr.w	#1,d2		; (no. of planes?)
	rts

l13C99E	movem.l	d1-d2,-(a7)
	nop
	dc.w	$A000
	movem.l	(a7)+,d1-d2
	movea.l	d0,a0
	move.w	d1,-$2B4(a0)
	subi.w	#1,-$2B4(a0)
	move.w	d1,-$C(a0)
	move.w	d2,(a0)
	move.w	scr_lines(pc),-$2B2(a0)
	subi.w	#1,-$2B2(a0)
	move.w	scr_lines(pc),-4(a0)
	move.w	d1,d0
	lsr.w	#3,d0
	subq.w	#1,d0
	move.w	d0,-$2C(a0)
	mulu.w	d1,d2
	move.w	-$2E(a0),d0
	move.w	scr_lines(pc),d1
	ext.l	d1
	divs.w	d0,d1
	subi.w	#1,d1
	move.w	d1,-$2A(a0)
	lsr.w	#3,d2
	move.w	d2,-2(a0)
	move.w	d2,2(a0)
	muls.w	d0,d2
	move.w	d2,-$28(a0)
	rts

; xbios($5b)
; return size of screen. (returns d0.l)

l13CA06	move.w	2(a7),d0
	bsr	l13C956
	move.w	d2,d0
	mulu.w	d1,d0
	mulu.w	scr_lines(pc),d0
	lsr.l	#3,d0
	lea	$10(a7),a7
	rte
l13CA20		DC.L 0
scr_lines	DC.W 0

int_text	DC.B 	10,13,10,13
		DC.B	"'Max Hz' By Griff!",10,13
		DC.B 	"Warning: This program can damage your monitor",10,13
		DC.B 	10,13,0
wrong_mon	DC.B	"Sorry, not on a VGA...",10,13,0
		even

l13CA90
