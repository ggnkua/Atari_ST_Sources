*
* __ /\\\\\\\\____/\\\\\\\\__________
* \__\///////\\\_ /\\\/////__________\
*  \__ /\\\_\/\\\_\/\\\_ /\\\_________\
*   \__\///__\/\\\_\/\\\_\///_ Digital \
*    \__ /\\\\\\\\__\//\\\\\\\\_ Destiny\
*     \__\////////____\////////__________\
*
*	stdlib.s - standard macro library
*

	include	"include.s"

Powerup	macro
	move.l	a7,spsave
	Super	0.w
	lea	sspsave(pc),a0
	move.l	d0,(a0)
	move.l	(mfp+6).w,mfpsave
	move.l	$70.w,vblsave
	move.l	$118.w,keysave
	lea	8.w,a0
	lea	oldexc(pc),a1
	moveq	#7,d0
.10	move.l	(a0),(a1)+
	ifeq	debug
	move.l	#bomb_disposal,(a0)+
	else
	addq.l	#4,a0
	endc
	dbra	d0,.10
.20	move	#-1,-(a7)		; wait shift mode
	move	#11,-(a7)
	trap	#13
	tst	d0
	addq.l	#4,a7
	bne.s	.20
	Vsetmode #-1
	move	d0,oldmode
	endm

Powerdown macro
	move.l	mfpsave,(mfp+6).w
	move.l	keysave,$118.w
	move.l	vblsave,$70.w
	move	#$8,d0			mouse back to relative mode
	bsr	w_ikbd
	move	#$7,d0			buttons back to normal
	bsr	w_ikbd
	move	#$0,d0
	bsr	w_ikbd
	lea	8.w,a0
	lea	oldexc(pc),a1
	moveq	#7,d0
.10	move.l	(a1)+,(a0)+
	dbra	d0,.10
	Vsetmode oldmode(pc)
*	move	#$26b,VSS.w
	move.l	sspsave(pc),a0
	Super	(a0)
	Pterm	#0
	endm

PrintW	macro
	section	data
\@	dc.b	\1,0
	section	text
	pea	\@(pc)
	move	#9,-(a7)
	trap	#1
	addq	#6,a7
	move	\2,d7
	bsr	hexword
	endm

begin	bra	_stdlibend

	section	bss
spsave	ds.l	1
sspsave	ds.l	1
oldmode	ds	1
vblsave	ds.l	1
keysave	ds.l	1
mfpsave	ds.l	1
oldexc	ds.l	8
	section	text

bomb_disposal
	movem.l	d0-d7/a0-a7,-(a7)
	move.l	mfpsave,(mfp+6).w
	move.l	keysave,$118.w
	move.l	vblsave,$70.w
	move	#$8,d0			mouse back to relative mode
	bsr	w_ikbd
	move	#$7,d0			buttons back to normal
	bsr	w_ikbd
	move	#$0,d0
	bsr	w_ikbd
	lea	8.w,a0
	lea	oldexc(pc),a1
	moveq	#7,d0
.10	move.l	(a1)+,(a0)+
	dbra	d0,.10
	Vsetmode oldmode(pc)
	move	#$26b,VSS.w
	moveq	#"0",d5
	moveq	#7,d4
.gpregs	move.b	d5,_dregno
	move.b	d5,_aregno
	addq	#1,d5
	Cconws	_dreg
	move.l	(a7)+,d7
	bsr	hexlong
	Cconws	_areg
	move.l	28(a7),d7
	bsr	hexlong
	dbra	d4,.gpregs
	lea	32(a7),a7
	Cconws	_sr
	move	(a7)+,d7
	bsr	hexword
	Cconws	_pc1
	move.l	(a7)+,d7
	bsr	hexlong
	Cconws	_pc2
	sub.l	#begin,d7
	bsr	hexlong
	Super	(a0)
	move.l	spsave(pc),a7
	Cconin
	Pterm	#0
_dreg	dc.b	10,13,9,"d"
_dregno	dc.b	0
_colon	dc.b	": ",0
_areg	dc.b	9,"a"
_aregno	dc.b	0
	dc.b	": ",0
_sr	dc.b	10,13,9,"sr: ",0
_pc1	dc.b	10,13,9,"pc: ",0
_pc2	dc.b	" = begin + ",0
	even

w_ikbd	btst.b	#1,keyctl.w
	beq.s	w_ikbd
	move.b	d0,keybd.w
	rts

hexbyte	swap	d7
	rol.l	#8,d7
	moveq	#1,d6
	bsr.s	hexit
	rts

hexword	swap	d7
	moveq	#3,d6
	bsr.s	hexit
	rts

hexlong	moveq	#7,d6
	bsr.s	hexit
	rts

hexit	clr	-(a7)
	move	#2,-(a7)
.loop	rol.l	#4,d7
	move	d7,d0
	and	#$f,d0
	move.b	.hexdigit(pc,d0),d0
	move	d0,2(a7)
	trap	#1
	dbra	d6,.loop
	addq	#4,a7
	rts
.hexdigit	dc.b	"0123456789ABCDEF"

_vbl	addq	#1,signal
	rte

_keyvbl	movem.l	d1-d2/a1-a2,-(a7)
	addq	#1,signal
	lea	kbuffer(pc),a1
	move.b	-16(a1),d1
	beq.s	.exit
	tst.b	-8(a1)
	beq.s	.exit
	subq	#1,-10(a1)
	bpl.s	.exit
	move	-12(a1),-10(a1)
	lea	kmap(pc),a2
	tst.b	inkey+$2a(pc)
	bne.s	.shf1
	tst.b	inkey+$36(pc)
	beq.s	.shf2
.shf1	lea	shfmap(pc),a2
.shf2	cmp	#kblength,-2(a1)
	beq.s	.exit
	move.b	(a2,d1),d2
	tst.b	-7(a1)
	beq.s	.caps2
	cmp.b	#"A",d2
	blo.s	.caps2
	cmp.b	#"z",d2
	bhi.s	.caps2
	cmp.b	#"Z",d2
	bls.s	.caps1
	cmp.b	#"a",d2
	blo.s	.caps2
.caps1	eor	#$20,d2
.caps2	addq	#1,-2(a1)
	move	-4(a1),d1
	move.b	d2,(a1,d1)
	addq	#1,d1
	and	#kblength-1,d1
	move	d1,-4(a1)
.exit	movem.l	(a7)+,a1-a2/d1-d2
	rte

_key	movem	d0-d2,-(a7)
	movem.l	a0-a2,-(a7)
.10	move.b	midictl.w,d0
	lea	_rdmidi(pc),a0
	bsr.s	.20
	move.b	keyctl.w,d0
	lea	_rdikbd(pc),a0
	bsr.s	.20
	btst	#4,gpip.w
	beq.s	.10
	movem.l	(a7)+,a0-a2
	movem	(a7)+,d0-d2
	bclr	#6,isrb.w
	rte
.20	btst	#7,d0
	beq	.40
	btst	#0,d0
	beq.s	.30
	jsr	(a0)
.30	and.b	#$20,d0
	beq.s	.40
	jsr	(a0)
.40	rts

_rdmidi	movem.l	d0-d7/a0-a6,-(a7)
	move.b	midi.w,d0
	movem.l	(a7)+,d0-d7/a0-a6
	rts

_packet	move.l	-6(a1),a2
	subq	#1,d1
	move	d1,-2(a1)
	beq.s	.copy
	move.b	keybd.w,d1
	move.b	d1,(a2)+
	move.l	a2,-6(a1)
	rts
.copy	move	-8(a1),d1
	subq	#2,d1
	lea	packet(pc),a2
	move.l	-12(a1),a1
.next	move.b	(a2)+,(a1)+
	dbra	d1,.next
	move.b	keybd.w,d1
	move.b	d1,(a1)+
	rts

_mouse	move	#5,-2(a1)
	move	#5,-8(a1)
	lea	mbuttons(pc),a2
	move.l	a2,-12(a1)
	lea	packet(pc),a2
	move.l	a2,-6(a1)
	rts
_joystick
	move	#2,-2(a1)
	move	#2,-8(a1)
	lea	joy0(pc),a2
	move.l	a2,-12(a1)
	lea	packet(pc),a2
	move.l	a2,-6(a1)
	rts
_rdikbd	lea	inkey(pc),a1
	move	-2(a1),d1
	bne.s	_packet
	clr	d1
	move.b	keybd.w,d1
	cmp.b	#$f7,d1
	beq.s	_mouse
	cmp.b	#$fd,d1
	beq.s	_joystick
	tst.b	d1
	bmi.s	.rel
.press	st	(a1,d1)
	lea	kmap(pc),a2
	tst.b	$2a(a1)
	bne.s	.shf1
	tst.b	$36(a1)
	beq.s	.shf2
.shf1	lea	shfmap(pc),a2
.shf2	lea	kbuffer(pc),a1
	cmp	#kblength,-2(a1)
	beq.s	.exit
	move.b	(a2,d1),d2
	cmp.b	#5,d2
	blo.s	.exit
	beq.s	.caps3
	tst.b	-7(a1)
	beq.s	.caps2
	cmp.b	#"A",d2
	blo.s	.caps2
	cmp.b	#"z",d2
	bhi.s	.caps2
	cmp.b	#"Z",d2
	bls.s	.caps1
	cmp.b	#"a",d2
	blo.s	.caps2
.caps1	eor	#$20,d2
.caps2	move.b	d1,-16(a1)
	addq	#1,-2(a1)
	move	-4(a1),d1
	move.b	d2,(a1,d1)
	addq	#1,d1
	and	#kblength-1,d1
	move	d1,-4(a1)
	move	-14(a1),-10(a1)
	rts
.rel	sf	-$80(a1,d1)
	and	#$7f,d1
	lea	lastkeypress(pc),a1
	cmp.b	(a1),d1
	bne.s	.exit
	clr.b	(a1)
.exit	rts
.caps3	eor.b	#$ff,-7(a1)
	rts

kblength	equ	32

signal		ds.l	1
copytoptr	dc.l	0
packetlen	dc	0
packetptr	dc.l	0
packetctr	dc	0
inkey		ds.b	128
		dc.b	0
mbuttons	dc.b	0
mcoordX		dc	0
mcoordY		dc	0
joy0		dc.b	0
joy1		dc.b	0
packet		ds	4
lastkeypress	dc	0
keyrepeatdelay	dc	20
keyrepeatrate	dc	0
keyrepeatcount	dc	0
keyrepeat	dc.b	$ff
capslock	dc.b	0
kbtail		dc	0
kbhead		dc	0
kbcontents	dc	0
kbuffer		ds.b	kblength

kmap	dc.b	0,27,"1234567890-=",8
	dc.b	9,"qwertyuiop[]",13
	dc.b	4,"asdfghjkl;'`",1,"#"
	dc.b	"zxcvbnm,./",2,"\"
	dc.b	3,32,5
	dc.b	$c1,$c2,$c3,$c4,$c5,$c6,$c7,$c8,$c9,$ca
	dc.b	0,0,0,18,0,"-",16,0,17,"+",0,19
	dc.b	0,0,128,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"\",0,0,"()/*7894561230.",13

shfmap	dc.b	0,27,"!""œ$%^&*()_+",8
	dc.b	9,"QWERTYUIOP{}",13
	dc.b	4,"ASDFGHJKL:@_",1,"~"
	dc.b	"ZXCVBNM<>?",2,"|"
	dc.b	3,32,5
	dc.b	$cb,$cc,$cd,$ce,$cf,$d0,$d1,$d2,$d3,$d4
	dc.b	0,0,0,22,0,"-",20,0,21,"+",0,23
	dc.b	0,0,128,0,0,0,0,0,0,0,0,0,0,0,0
	dc.b	"|",0,0,"()/*7894561230.",13

	even
_stdlibend
