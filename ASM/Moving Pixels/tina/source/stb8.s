offset:		equ	5900400
volume:		equ	$0070
slength:	equ	11800800
maxframes:	equ	731
                                                                                                                                                                                                                                                         
* BLiTTER BASE ADDRESS

blitter         equ     $FF8A00

* BLiTTER REGISTER OFFSETS

halftone        equ     0
src_xinc        equ     32
src_yinc        equ     34
src_addr        equ     36
endmask1        equ     40
endmask2        equ     42
endmask3        equ     44
dst_xinc        equ     46
dst_yinc        equ     48
dst_addr        equ     50
x_count         equ     54
y_count         equ     56
hop             equ     58
op              equ     59
line_num        equ     60
skew            equ     61
vbl_vec:	equ	$70

vertflag:	equ	$0100
stmodes:	equ	$0080
overscan:	equ	$0040
pal:		equ	$0020
vga:		equ	$0010
tv:		equ	$0000

col80:		equ	$0008
col40:		equ	$0000
numcols:	equ	$0007

bps16:		equ	4
bps8:		equ	3
bps4:		equ	2
bps2:		equ	1
bps1:		equ	0
mybit:		equ	%0000001000000000


fw:	equ	172
fh:	equ	144
sw:	equ	384
sh:	equ	480
*****************************************************************
*	Falcon Slide Demo.					*
*	Version 1.0						*
*****************************************************************
	include	'fequates.s'
start:
	move.l	4(a7),a3		base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp

	clr.l	-(sp)		;as usual the first thing to
	move.w	#$20,-(sp)	;do is go into supervisor mode
	trap	#1
	addq.l	#6,sp
	move.l	d0,savesp

	bsr	putrout
	bsr	putvbl
	bsr	puttime

	bsr	setupsound
	bsr	setupscreen
	bsr	dologo
	bsr	openfile
	bsr	clearscreens
	move.l	#0,frame
	move.l	#effect5,whicheffect
	bsr	startsound
mainloop:
	bsr	getframe
	move.l	whicheffect,a0
	jsr	(a0)
	tst.w	syncmode
	bpl	notlast
	addq.l	#1,frame
	cmpi.l	#maxframes,frame
	blt.s	notlast
	bsr	dologo
	move.l	#0,frame
notlast:
	tst.w	ddl
	bmi	nol
	bsr	dologo
	bsr	startsound
	move.l	#0,frame
	move.w	#-1,ddl
nol:
	bsr	keyboard
	bra	mainloop


swapnshow:
	move.l	viewscreen1,d0
	move.l	viewscreen2,viewscreen1
	move.l	d0,viewscreen2
*	move.w	#37,-(sp)
*	trap	#14
*	addq.l	#2,sp

waitvbl:
	move.w	#1,vblflag
wvbloop:
	tst.w	vblflag
	bpl	wvbloop

*	move.b	viewscreen1+1,$ff8205
*	move.b	viewscreen1+2,$ff8207
*	move.b	viewscreen1+3,$ff8209
*	rts
	move.l	viewscreen1,d0
	move.l	d0,d1
	move.l	d1,d2
	lsr.l	#8,d0
	lsr.l	#8,d0
	move.w	d0,vid_bh
	lsr.l	#8,d1
	and.l	#$000000ff,d1
	move.w	d1,vid_bm
	and.l	#$000000ff,d2
	move.w	d2,vid_bl
	rts

*********************************************************
*	Simple normal size blit in exact screen centre	*
*********************************************************
effect1:
	move.w	#-1,expansion
	move.l	#(sw/2)-(fw/2),blitx
	move.l	#(sh/2)-(fh/2),blity
	bsr	 putpic
	bsr	swapnshow
	rts
*********************************************************
*	Simple double size blit in exact screen centre	*
*********************************************************
effect2:
	move.w	#1,expansion
	move.l	#(sw/2)-((fw*2)/2),blitx
	move.l	#(sh/2)-((fh*2)/2),blity
	bsr	 putpic
	bsr	swapnshow
	rts
*********************************************************
*	Simple half size blit in exact screen centre	*
*********************************************************
effect3:
	move.w	#0,expansion
	move.l	#(sw/2)-((fw/2)/2),blitx
	move.l	#(sh/2)-((fh/2)/2),blity
	bsr	 putpic
	bsr	swapnshow
	rts
*********************************************************
*	4 normal blits					*
*********************************************************
effect4:
	move.w	#-1,expansion
	move.l	#(sw/2)-((fw*2)/2),blitx
	move.l	#(sh/2)-((fh*2)/2),blity
	bsr	 putpic
	move.l	#((sw/2)-((fw*2)/2))+fw,blitx
	move.l	#((sh/2)-((fh*2)/2)),blity
	bsr	 putpic
	move.l	#((sw/2)-((fw*2)/2)),blitx
	move.l	#((sh/2)-((fh*2)/2))+fh,blity
	bsr	 putpic
	move.l	#((sw/2)-((fw*2)/2))+fw,blitx
	move.l	#((sh/2)-((fh*2)/2))+fh,blity
	bsr	 putpic
	bsr	swapnshow
	rts
*********************************************************
*	central normal and rotating half		*
*********************************************************
effect5:
	move.w	#-1,expansion
	move.l	#(sw/2)-(fw/2),blitx
	move.l	#(sh/2)-(fh/2),blity
	bsr	 putpic

	move.w	#0,expansion
	lea	smallist,a0
	move.l	number,d0
	asl.l	#3,d0
	move.l	(a0,d0),blitx
	move.l	4(a0,d0),blity
	bsr	 putpic
	addq.l	#1,number
	cmpi.l	#12,number
	blt	.skip
	move.l	#0,number
.skip:
	move.w	#1,vblflag
.wvbloop:
	tst.w	vblflag
	bpl	.wvbloop
	move.l	viewscreen2,d0
	move.l	d0,d1
	move.l	d1,d2
	lsr.l	#8,d0
	lsr.l	#8,d0
	move.w	d0,vid_bh
	lsr.l	#8,d1
	and.l	#$000000ff,d1
	move.w	d1,vid_bm
	and.l	#$000000ff,d2
	move.w	d2,vid_bl

	rts
tempx:		equ	((sw/2)-(fw/2))
tempy:		equ	(sh/2)-(fh/2)

smallist:
	dc.l	tempx-(fw/2),tempy-(fh/2)
	dc.l	tempx,tempy-(fh/2)
	dc.l	tempx+(fw/2),tempy-(fh/2)
	dc.l	tempx+((fw/2)*2),tempy-(fh/2)

	dc.l	tempx+((fw/2)*2),tempy
	dc.l	tempx+((fw/2)*2),tempy+(fh/2)
	dc.l	tempx+((fw/2)*2),tempy+((fh/2)*2)

	dc.l	tempx+(fw/2),tempy+((fh/2)*2)
	dc.l	tempx,tempy+((fh/2)*2)
	dc.l	tempx-(fw/2),tempy+((fh/2)*2)

	dc.l	tempx-(fw/2),tempy+(fh/2)
	dc.l	tempx-(fw/2),tempy

	dc.l	-1


number:	dc.l	0
*****************************************************************
*	Putpic, pass x and y in px,py and set expansion to 1	*
*	to blit the pic expanded or -1 to blit it normal or	*
*	0 to blit half size.					*
*****************************************************************
putpic:
	move.l	viewscreen2,a1
	moveq	#9,d2
	move.l	blity,d0
	move.l	d0,d1
	asl.l	d2,d0
	add.l	d0,a1
	asl.l	#8,d1
	add.l	d1,a1
	move.l	blitx,d0
	add.l	d0,d0
	add.l	d0,a1
	lea	thepic,a0
	tst.w	expansion
	bgt	expandblit
	bmi	singleblit

*****************************************************************
*	This will take the 180*144 image in a0 and blit it	*
*	half size to the address in a1				*
*****************************************************************
halfblit:
	lea	blitter,a6
.waitblit:
	btst	#7,line_num(a6)
	bne	.waitblit
	move.l	a0,src_addr(a6)
	move.l	a1,dst_addr(a6)
	move.w	#4,src_xinc(a6)
	move.w	#2,dst_xinc(a6)
	move.w	#fw/2,x_count(a6)
	move.w	#fh/2,y_count(a6)
	move.w	#fw*2,src_yinc(a6)
	move.w	#(sw*2)-(fw-2),dst_yinc(a6)
	move.w	#-1,endmask1(a6)
	move.w	#-1,endmask2(a6)
	move.w	#-1,endmask3(a6)
	move.b	#$3,op(a6)
	move.b	#2,hop(a6)
	move.b	#%10000000,skew(a6)
*	bset	#6,line_num(a6)
	bset	#7,line_num(a6)
.nhogwait:
	bset.b	#7,line_num(a6)
	bne	.nhogwait
	rts

*****************************************************************
*	This will take the 180*144 image in a0 and blit it	*
*	straight to the address in a1				*
*****************************************************************
singleblit:
	lea	blitter,a6
.waitblit:
	btst	#7,line_num(a6)
	bne	.waitblit
	move.l	a0,src_addr(a6)
	move.l	a1,dst_addr(a6)
	move.w	#2,src_xinc(a6)
	move.w	#2,dst_xinc(a6)
	move.w	#fw,x_count(a6)
	move.w	#fh,y_count(a6)
	move.w	#0,src_yinc(a6)
	move.w	#(sw*2)-(fw*2)+2,dst_yinc(a6)
	move.w	#-1,endmask1(a6)
	move.w	#-1,endmask2(a6)
	move.w	#-1,endmask3(a6)
	move.b	#$3,op(a6)
	move.b	#2,hop(a6)
	move.b	#%10000000,skew(a6)
*	bset	#6,line_num(a6)
	bset	#7,line_num(a6)
.nhogwait:
	bset.b	#7,line_num(a6)
	bne	.nhogwait
	rts

*****************************************************************
*	This will take the 180*144 image in a0 and blit it	*
*	expanded by 4 to the address in a1			*
*****************************************************************
expandblit:
	lea	blitter,a6
.waitblit:
	btst	#7,line_num(a6)
	bne	.waitblit
	move.l	a0,src_addr(a6)
	move.l	a1,dst_addr(a6)
	move.w	#2,src_xinc(a6)
	move.w	#4,dst_xinc(a6)
	move.w	#fw,x_count(a6)
	move.w	#fh,y_count(a6)
	move.w	#0,src_yinc(a6)
	move.w	#(sw*2)+(sw-(fw*2))*2+4,dst_yinc(a6)
	move.w	#-1,endmask1(a6)
	move.w	#-1,endmask2(a6)
	move.w	#-1,endmask3(a6)
	move.b	#$3,op(a6)
	move.b	#2,hop(a6)
	move.b	#%10000000,skew(a6)
*	bset	#6,line_num(a6)
	bset	#7,line_num(a6)
.nhogwait:
	bset.b	#7,line_num(a6)
	bne	.nhogwait
expand1:
	lea	(sw*2)(a1),a2
.waitblit:
	btst	#7,line_num(a6)
	bne	.waitblit
	move.l	a0,src_addr(a6)
	move.l	a2,dst_addr(a6)
	move.w	#fw,x_count(a6)
	move.w	#fh,y_count(a6)
	move.w	#0,src_yinc(a6)
	move.w	#(sw*2)+(sw-(fw*2))*2+4,dst_yinc(a6)
	move.w	#2,src_xinc(a6)
	move.w	#4,dst_xinc(a6)
	move.b	#%10000000,skew(a6)
*	bset	#6,line_num(a6)
	bset	#7,line_num(a6)
.nhogwait:
	bset.b	#7,line_num(a6)
	bne	.nhogwait
expand2:
	lea	2(a1),a2
.waitblit:
	btst	#7,line_num(a6)
	bne	.waitblit
	move.l	a1,src_addr(a6)
	move.l	a2,dst_addr(a6)
	move.w	#fw,x_count(a6)
	move.w	#fh*2,y_count(a6)
	move.w	#4,src_xinc(a6)
	move.w	#4,dst_xinc(a6)
	move.w	#(sw-(fw*2))*2+4,src_yinc(a6)
	move.w	#(sw-(fw*2))*2+4,dst_yinc(a6)
	move.b	#%00000000,skew(a6)
*	bset	#6,line_num(a6)
	bset	#7,line_num(a6)
.nhogwait:
	bset.b	#7,line_num(a6)
	bne	.nhogwait
	rts



printtime:
	move.l	time,d0
	moveq	#10,d1
	moveq	#0,d2
	moveq	#0,d3
	bsr	prtnum
	rts
printframes:
	move.l	frames,d0
	moveq	#10,d1
	moveq	#0,d2
	moveq	#1,d3
	bsr	prtnum

	move.l	time,d1
	divu	#200,d1
	move.l	frames,d0
	divu	d1,d0
	and.l	#$0000ffff,d0
	moveq	#10,d1
	moveq	#0,d2
	moveq	#2,d3
	bsr	prtnum

	rts

handle:	dc.w	0
fname:
	dc.b	'cmovie.dat',0
	even

openfile:
	move.w	#0,-(sp)
	move.l	#fname,-(sp)
	move.w	#$3D,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle
	rts

getframe:
	move.l	frame,d0
	mulu.l	#(fw*fh*2),d0
	move.w	#0,-(sp)
	move.w	handle,-(sp)	;lseek the fpointer to correct file
	move.l	d0,-(sp)	
	move.w	#$42,-(sp)
	trap	#1
	add.l	#10,sp


	pea	thepic
	move.l	#(fw*fh*2),-(sp)
	move.w	handle,-(sp)	;and read it in
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	rts

delayticks:
	move.l	$4ba,d1
dltl:
	move.l	$4ba,d2
	sub.l	d1,d2
	cmp.l	d0,d2
	blt	dltl
	rts

dologo:
	bsr	clearscreens
	move.l	viewscreen1,d0
	move.l	d0,d1
	move.l	d1,d2
	lsr.l	#8,d0
	lsr.l	#8,d0
	move.w	d0,vid_bh
	lsr.l	#8,d1
	and.l	#$000000ff,d1
	move.w	d1,vid_bm
	and.l	#$000000ff,d2
	move.w	d2,vid_bl
	lea	mylogo,a0
	move.l	viewscreen1,a1
	jsr	ice_unpack

	move.w	#500,d0
	bsr	delayticks
	bsr	clearscreens
	rts
dohelp:
	move.l	viewscreen1,d0
	move.l	d0,d1
	move.l	d1,d2
	lsr.l	#8,d0
	lsr.l	#8,d0
	move.w	d0,vid_bh
	lsr.l	#8,d1
	and.l	#$000000ff,d1
	move.w	d1,vid_bm
	and.l	#$000000ff,d2
	move.w	d2,vid_bl

*	bsr	clearscreens
	lea	helpimg,a0
	move.l	viewscreen1,a1
	jsr	ice_unpack


	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp

	bsr	clearscreens
	rts

;********************************************* Unpackroutine von ICE-PACK
; assemble with Devpac or any other Assembler
; length of this unpacking routine: 294 bytes
;  a0 = address of packed data
;  a1 = address of unpacked data
ice_unpack:
	movem.l d0-a6,-(sp)
	bsr	ice04
	cmpi.l	#'Ice!',d0		; Is file packed?
	bne	ice03			; no, leave this routine
	bsr	ice04
	lea	-8(a0,d0.l),a5
	bsr	ice04
*	move.l	d0,(sp)
	movea.l a1,a4
	movea.l a1,a6
	adda.l	d0,a6
	movea.l a6,a3
	move.b	-(a5),d7
	bsr	ice06
ice03:
	movem.l (sp)+,d0-a6
	rts
ice04:	moveq	#3,d1
ice05:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,ice05
	rts
ice06:	bsr	ice0a
	bcc	ice09
	moveq	#0,d1
	bsr	ice0a
	bcc	ice08
	lea	ice17(pc),a1
	moveq	#4,d3
ice07:	move.l	-(a1),d0
	bsr	ice0c
	swap	d0
	cmp.w	d0,d1
	dbne	d3,ice07
	add.l	20(a1),d1
ice08:	move.b	-(a5),-(a6)
	dbra	d1,ice08
ice09:	cmpa.l	a4,a6
	bgt	ice0f
	rts
ice0a:	add.b	d7,d7
	bne	ice0b
	move.b	-(a5),d7
	addx.b	d7,d7
ice0b:	rts
ice0c:	moveq	#0,d1
ice0d:	add.b	d7,d7
	bne	ice0e
	move.b	-(a5),d7
	addx.b	d7,d7
ice0e:	addx.w	d1,d1
	dbra	d0,ice0d
	rts
ice0f:	lea	ice18(pc),a1
	moveq	#3,d2
ice10:	bsr	ice0a
	dbcc	d2,ice10
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi	ice11
	bsr	ice0c
ice11:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq	ice13
	lea	ice19(pc),a1
	moveq	#1,d2
ice12:	bsr	ice0a
	dbcc	d2,ice12
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr	ice0c
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl	ice15
	sub.w	d4,d1
	bra	ice15
ice13:	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr	ice0a
	bcc	ice14
	moveq	#8,d0
	moveq	#$3f,d2
ice14:	bsr	ice0c
	add.w	d2,d1
ice15:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
ice16:	move.b	-(a1),-(a6)
	dbra	d4,ice16
	bra	ice06

	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
ice17:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
ice18:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
ice19:	DC.B $0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B $00,$1f


	even



*****************************************
*	number in d0.l			*
*	d1.l is base			*
*	d2,x cursor			*
*	d3,y cursor			*
*****************************************
prtnum:
	movem.l	d0/d1,-(sp)
	lea	posstring,a0
	add.w	#32,d3
	move.b	d3,2(a0)	
	add.w	#32,d2
	move.b	d2,3(a0)
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0/d1

	lea	linebuffer,a0
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
loop1:
	divu	d1,d0
	swap	d0
	addi	#'0',d0
	cmpi.w	#'9',d0
	ble.s	ok
	addq.w	#7,d0
ok:
	move.b	d0,-(a0)
	clr	d0
	swap	d0
	bne	loop1
loop2:
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

clearnums:
	lea	clearstring,a0
	add.w	#32,d3
	move.b	d3,2(a0)	
*	move.b	d3,10(a0)	
	add.w	#32,d2
	move.b	d2,3(a0)
*	move.b	d2,11(a0)	
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
linebuffer:
	ds.l	5
digits:
	dc.b	0
posstring:	dc.b	27,'Y',0,0,0,0
clearstring:	dc.b	27,'Y',0,0,'   ',0,0
	even
syncmode:	dc.w	1

waitkey:
	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	rts
keyboard:
	move.w	#$ff,-(sp)
	move.w	#$6,-(sp)
	trap	#1
	addq.l	#4,sp
	tst.l	d0
	beq	keyback
	swap	d0

	cmp.b	#16,d0		*space
	beq	exit		*yes/no
	cmpi.b	#$39,d0
	beq	pause
plus:
	cmpi.b	#$4e,d0
	bne	minus
	add.l	#180*144*2,whichpic
	rts
minus:
	cmpi.b	#$4a,d0
	bne	skey
	sub.l	#180*144*2,whichpic
	rts
skey:
	cmpi.b	#$1f,d0
	bne	rkey
	neg.w	syncmode
	rts
rkey:
	cmpi.b	#$13,d0
	bne	helpkey
	bsr	startsound
	move.l	#0,frame
	rts
helpkey:
	cmpi.b	#$62,d0
	bne	f1
	bsr	dohelp
	move.l	#0,frame
	rts

f1:
	cmpi.b	#$3b,d0
	bne	f2
	bsr	clearscreens
	move.l	#effect1,whicheffect
	rts
f2:
	cmpi.b	#$3c,d0
	bne	f3
	bsr	clearscreens
	move.l	#effect2,whicheffect
	rts
f3:
	cmpi.b	#$3d,d0
	bne	f4
	bsr	clearscreens
	move.l	#effect3,whicheffect
	rts
f4:
	cmpi.b	#$3e,d0
	bne	f5
	bsr	clearscreens
	move.l	#effect4,whicheffect
	rts
f5:
	cmpi.b	#$3f,d0
	bne	uparrow
	bsr	clearscreens
	move.l	#effect5,whicheffect
	rts
uparrow:
	cmpi.b	#$50,d0
	bne	downarrow
	add.w	#$0010,mastervol
	cmpi.w	#$00f0,mastervol
	ble	.vok
	move.w	#$00f0,mastervol
.vok
	bsr	setvol
	rts
downarrow:
	cmpi.b	#$48,d0
	bne	keyback
	sub.w	#$0010,mastervol
	cmpi.w	#$0010,mastervol
	bge	.vok
	move.w	#$0010,mastervol
.vok
	bsr	setvol
	rts
keyback:
	rts

pause:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts


clearscreens:
	lea	blitter,a6
.waitblit:
	btst	#7,line_num(a6)
	bne	.waitblit

	move.l	viewscreen1,a0
	move.l	viewscreen2,a1
	move.l	a0,dst_addr(a6)
	move.w	#2,dst_xinc(a6)
	move.w	#2,dst_yinc(a6)
	move.w	#384,x_count(a6)
	move.w	#480,y_count(a6)
	move.w	#-1,endmask1(a6)
 	move.w	#-1,endmask2(a6)
	move.w	#-1,endmask3(a6)
	move.b	#0,skew(a6)
	move.b	#$0,op(a6)
	move.b	#2,hop(a6)
	bset	#6,line_num(a6)
	bset	#7,line_num(a6)
nextscreen:
.waitblit:
	btst	#7,line_num(a6)
	bne	.waitblit
	move.l	a1,dst_addr(a6)
	move.w	#2,dst_xinc(a6)
	move.w	#2,dst_yinc(a6)
	move.w	#384,x_count(a6)
	move.w	#480,y_count(a6)
	bset	#6,line_num(a6)
	bset	#7,line_num(a6)
	rts



putpoint:
	movem.l	d0/d1/a0,-(sp)
	moveq	#0,d0
	move.l	d0,d1
	move.w	pixelx,d0
	add.l	d0,d0
	move.w	pixely,d1
	mulu	#sw*2,d1
	add.l	d1,d0
	move.l	viewscreen1,a0
	add.l	d0,a0
	move.w	color,(a0)
	movem.l	(sp)+,d0/d1/a0
	rts



buttondat:	dc.w	0
mx:		dc.w	0
my:	dc.w	0
*************puts my mouse interupt in***************** 
putrout:move.w  #34,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,a0
	move.l	16(a0),oldmouse
        move.l  #myrout,16(a0)
        rts
lastb:		dc.w	-1
mousehasgoneup:	dc.w	0

**************my ubeut mouse interupt*******************
myrout:
	movem.l	d0-d2/a0-a1,-(sp)
	moveq	#0,d0	
	move.b	(a0),d0
	cmpi.b	#$fa,d0
	bne	myr1
	move.w	#1,buttondat
	bra	myrxy
myr1:
	cmpi.b	#$f9,d0
	bne	myr2
	move.w	#2,buttondat
	bra	myrxy
myr2:
	cmpi.b	#$fb,d0
	bne	myr3
	move.w	#3,buttondat
	bra	myrxy
myr3:
	move.w	#1,mousehasgoneup
	move.w	#0,buttondat
myrxy:
	moveq	#0,d0
	move.b	1(a0),d0
	ext.w	d0
	moveq	#0,d1
	move.b	2(a0),d1
	ext.w	d1
	add.w	d0,mx
	add.w	d1,my
*	sub.w	d1,my2
myr4:	move.w	mx,d0
	move.w	my,d1
	bsr	extra
	move.w	d0,mx
	move.w	d1,my
	movem.l	(sp)+,d0-d2/a0-a1
	rts

extra:  cmpi.w	#mminx,d0
        bge	extra1
        move.w	#mminx,d0
        bra	extra2
extra1: cmpi.w   #mmaxx,d0
        ble	extra2
        move.w  #mmaxx,d0
extra2:	cmpi.w  #mminy,d1
        bge	extra3
        move.w  #mminy,d1
        bra	extra4
extra3: cmpi.w   #mmaxy,d1
        ble	extra4
        move.w  #mmaxy,d1
extra4:
        rts

mminx:	equ	0
mmaxx:	equ	384
mminy:	equ	0
mmaxy:	equ	480


putvbl:
	move.l	vbl_vec,vblt+2		;set up vbl handler
	move.l	vbl_vec,oldvblvec
	move.l	#vbl_handler,vbl_vec
	rts

halfframe:	dc.w	0
ddl:		dc.w	-1
vbl_handler:
*	move.b	currentscreen+1,$ff8205
*	move.b	currentscreen+2,$ff8207
*	move.b	currentscreen+3,$ff8209
*	subq.w	#1,halfframe
*	bpl.s	skipfa
*	tst.w	syncmode
*	bmi	skipfa
*	move.w	#1,halfframe
*	addq.l	#1,frame		;update current frame each
*	cmpi.l	#maxframes,frame
*	blt	skipfa
*	move.l	#0,frame
*	move.w	#1,ddl
skipfa:
	move.w	#-1,vblflag
vblt:
	jmp	$0.L




exit:
	move.l	save114,$114

	move.w  #34,-(sp)
        trap    #14
        addq.l  #2,sp
        move.l  d0,a0
	move.l	oldmouse,16(a0)

	move.w	#%0000000000000000,-(sp)	;stop the sound
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#$81,-(sp)		;unlock the sound system
	trap	#14
	addq.l	#2,sp

	tst.l	savemem1
	bmi	skipdm1
	move.l	savemem1,d0
	bsr	deallocate
skipdm1:
	tst.l	savemem2
	bmi	skipdm2
	move.l	savemem2,d0
	bsr	deallocate
skipdm2:
	tst.l	savemem3
	bmi	skipdm3
	move.l	savemem3,d0
	bsr	deallocate
skipdm3:

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	move.l	oldvblvec,vbl_vec


	move.w	savemode,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#-1,-(sp)
	move.l	savescreen,-(sp)
	move.l	savescreen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp


	move.l	savesp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

deallocate:
	move.l	d0,-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

clearmem:
	move.l	#(sw*sh),d0
	subq.l	#1,d0
	moveq	#0,d1
cml:
	move.w	d1,(a0)+
	subq.l	#1,d0
	bpl	cml
	rts

*********************************************************
*	One call does it all				*
*	Allocates memory for 3 screens 			*
*	targa load/hold area is internal.		*
*	Then sets all the hardware stuff to create	*
*	a 384*480 16bit screen				*
*********************************************************
setupscreen:
	move.l	#((sw*2)*sh)+4+((sw*2)*100),-(sp)	;thats 1 screen size
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bmi	exit
	move.l	d0,savemem1
	add.l	#4,d0
	and.l	#$fffffffc,d0
	move.l	d0,viewscreen1
	move.l	d0,a0
	bsr	clearmem

	move.l	#((sw*2)*sh)+4+((sw*2)*100),-(sp)	;thats 1 screen size
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bmi	exit
	move.l	d0,savemem2
	add.l	#4,d0
	and.l	#$fffffffc,d0
	move.l	d0,viewscreen2

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,savescreen

	move.w	#-1,-(sp)
	move.l	viewscreen1,-(sp)
	move.l	viewscreen1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#overscan|vertflag|col40|bps16,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,savemode

	move.l	#0,$ffff9800
	rts

setupsound:
	move.l	#slength+4,-(sp)	;thats 1 screen size
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bmi	exit
	move.l	d0,savemem3
	add.l	#4,d0
	and.l	#$fffffffc,d0
	move.l	d0,savemem3

	move.w	#1,-(sp)
	move.l	#fnamesound,-(sp)	;read in the sound
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handles

	move.l	savemem3,-(sp)
	move.l	#slength,-(sp)
	move.w	handles,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	move.l	d0,howlong

	move.w	handles,-(sp)	;close the file
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	move.w	#$80,-(sp)		;lock the sound system
	trap	#14
	addq.l	#2,sp

	move.w	#1,-(sp)		;setmode 16bit Stereo
	move.w	#$84,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#0,-(sp)	;rectracks
	move.w	#1,-(sp)	;playtracks
	move.w	#$85,-(sp)	;set tracks
	trap	#14
	addq.l	#6,sp

	move.w	#1,-(sp)	;disable handshaking
	move.w	#3,-(sp)	;prescale
	move.w	#0,-(sp)	;srclk internal 25.175Mhz
	move.w	#8,-(sp)	;dst dac
	move.w	#0,-(sp)	;src dma playback
	move.w	#$8b,-(sp)	;devconnect
	trap	#14
	add.l	#12,sp

	move.l	savemem3,d0
	add.l	howlong,d0
	move.l	d0,-(sp)	;endaddress
	move.l	savemem3,d0
	add.l	#offset,d0
	move.l	d0,-(sp)	;start address
	move.w	#0,-(sp)	;playback
	move.w	#$83,-(sp)	;setbuffer
	trap	#14
	add.l	#12,sp
	move.w	#$0080,mastervol
	bsr	setvol
	rts

setvol:
	move.w	mastervol,-(sp)
	move.w	#0,-(sp)	;ltatten
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	mastervol,-(sp)
	move.w	#1,-(sp)	;rtatten
	move.w	#$82,-(sp)
	trap	#14
	addq.l	#6,sp
	rts


startsound:
	move.w	#%0000000000000000,-(sp)	;stop the sound
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#%0000000000000001,-(sp)	;play once
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp
	rts


puttime:
	move.l	$114,save114
	move.l	$114,my114drop+2
	move.l	#my114,$114
	rts

my114:
	move.w	d0,-(sp)
	move.b	c25,d0
	ror.b	#1,d0
	bpl	not25hz

	tst.w	syncmode
	bmi	not25hz
	addq.l	#1,frame		;update current frame each
	cmpi.l	#maxframes,frame
	blt	not25hz
	move.l	#0,frame
	move.w	#1,ddl
not25hz:
	move.b	d0,c25
	move.w	(sp)+,d0
my114drop:
	jmp	$0.L


c25:		dc.b	1
	even

viewscreen2:	dc.l	-1
viewscreen1:	dc.l	-1
savemem1:	dc.l	-1
savemem2:	dc.l	-1
savemem3:	dc.l	-1
howlong:	dc.l	0
handles:	dc.w	0
fnamesound:	dc.b	'SAMPLE.TRK'
	even

	section data
mylogo:
	incbin	'logo.img'
	even
helpimg:
	incbin	'fhelp.img'

	SECTION BSS
		ds.l	1000
mystack:	ds.w	1	;stacks go backwards
svft:	ds.w	1
svss:	ds.w	1
svbb:	ds.w	1
svbe:	ds.w	1
svdb:	ds.w	1
svde:	ds.w	1
shht:	ds.w	1
shss:	ds.w	1
shbb:	ds.w	1
shbe:	ds.w	1
shdb:	ds.w	1
shde:	ds.w	1
shfs:	ds.w	1
shee	ds.w	1
sst_shift:	ds.w	1
ssp_shift:	ds.w	1
svco:	ds.w	1
svwrap:	ds.w	1
svid_bh:	ds.w	1
svid_bm:	ds.w	1
svid_bl:	ds.w	1
savepal:	ds.w	16

dummy:		ds.w	1
color:		ds.w	1
pixelx:		ds.w	1
pixely:		ds.w	1
savesp:		ds.l	1
time:		ds.l	1
frames:		ds.l	1
blitx:		ds.l	1
blity:		ds.l	1
picsource:	ds.l	1
expansion:	ds.w	1
oldmouse:	ds.l	1
whichpic:	ds.l	1
frame:		ds.l	1
whicheffect:	ds.l	1
oldvblvec:	ds.l	1
vblflag:	ds.w	1
savescreen:	ds.l	1
savemode:	ds.w	1
save114:	ds.l	1
mastervol:	ds.w	1
bufferword:
	ds.w	1
	section bss
thepic:
	ds.b	fw*fh*2
