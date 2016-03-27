*********NAME : A Miller B.Sc. Hons. C.S.D.C.




	move.l	4(a7),a3
	move.l	#mystack,a7
	move.l	$c(a3),d0
	add.l	$14(a3),d0
	add.l	$1c(a3),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp	; set up the stack

	move.l	#0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp	; free mem

	jsr	hblon		; activate the bottom border + scroller

	bclr #0,$484.w		; clear key click

	moveq #1,d0
	bsr music		; activate first tune

	dc.w	$a00a		; disable mouse

	move.w  #2,-(sp)
        trap    #14
        addq.l  #2,a7
        move.l  d0,xdummy	; find screen address

	move.b	#2,$ff820a	; 50 Hz

	move.l	#$ff8240,a1
	move.l	#FromScreen+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)	; set up colours for screen

	move.w	#0,-(sp)
	move.l	#$76000,-(sp)
	move.l	#$76000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp	; set up $76000 as top of screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;fall down routine
	move.l	#$76000,a1
	move.l	#FromScreen+34,a0
	move.l	#FromScreen+32034,a5
	move.l	#32000,d3
xfada	
	move.l	#1,d1
	move.w	d3,d2
	lea	0(a0,d3.w),a3
	lea	0(a1,d3.w),a4
BefGo
	addq.w	#1,d1
Go
	move.w	d1,d5

Loop001	cmpa.l	a3,a5
	blt	nocop
	move.w	#39,d4
Loop002	move.l	-(a3),-(a4)
	dbf	d4,Loop002
	bra	ssu
nocop	suba.l	#160,a4
ssu	cmpa.l	a4,a1
	bge	xfb10
	subq.w	#1,d5
	beq	BefGo
	adda.l	#160,a3
	bra	Loop001

xfb10
	movem.l	d0-d3/a0-a2,-(sp)
	move.w	#37,-(sp)
	trap	#14
	add.l	#2,a7
	movem.l	(sp)+,d0-d3/a0-a2
	sub.w	#160,d3
	bne	xfada
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

again:  move.l  #line,mespt	; message pointer to start of text

keyprs:	move.w	#7,-(sp)
	trap	#1
	lea	2(sp),sp	; wait for key

	cmp.b	#'1',d0
	beq	Run1
	cmp.b	#'2',d0
	beq	Run2
	cmp.b	#'3',d0
	beq	Run3
	cmp.b	#'*',d0
	beq	star
	cmp.b	#'0',d0
	beq	zero		; selection

aszdf	jmp	keyprs

music	INCBIN	'A:\G_FORCE\sowhat.mus'
	even

RunProg
	jsr	hbloff
	move.w	#0,-(sp)
	move.l	xdummy,-(sp)
	move.l	xdummy,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	move.b	(hertz),$ff820a
	move.l d5,-(sp)
	move.w #$3b,-(sp)
	trap #1
	addq.l #6,a7
	move.l #Empty,-(sp)
	move.l #Empty,-(sp)
	move.l d6,-(sp)
	move.w #0,-(sp)
	move.w #$4b,-(sp)
	trap #1
	lea 16(a7),a7

star:
	jsr	hbloff
	move.l	#$07770000,$ff8240
	move.l	#0,$ff8244
	clr.w	-(sp)
	trap	#1			; just for the testing exit

Run1:
	move.l	#Emp,d5
	move.l	#Prog1,d6
	bra	RunProg
Run2:
	move.l	#Emp,d5
	move.l	#Prog2,d6
	bra	RunProg
Run3:
	move.l	#Emp,d5
	move.l	#Prog3,d6
	bra	RunProg
zero:
	move.b	(hertz),d0
	tst	d0
	beq	hz50
	move.b	#0,(hertz)
	jmp	aszdf
hz50	move.b	#2,(hertz)
	jmp	aszdf		; toggle 50/60Hz

hblon:	move.l	$120,oldtb
	move.l	$70,old4
	move.l	$70,new4b+2
	move.b	$fffffa07,old07
	move.b	$fffffa09,old09
	and.b	#$df,$fffa09
	and.b	#$fe,$fffa07
	move.l	#killborder,$120
	move.l	#new4,$70
	or.b	#1,$fffffa07
	or.b	#1,$fffffa13
	rts			; starts the hb interupt

hbloff:	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.b	old07(pc),$fffffa07
	move.b	old09(pc),$fffffa09
	move.l	oldtb,$120
	move.l	old4,$70
	move.l	#$8080000,$ff8820
	move.l	#$9090000,$ff8820
	move.l	#$a0a0000,$ff8820
	move.l	#$707ffff,$ff8820
	move.w	(sp)+,sr
	rts			; stops the hb int + clear sound

new4:	movem.l	d0-a6,-(sp)
	bsr	(music+8)
	move.l	#$ff8240,a1
	move.l	#FromScreen+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	clr.b	$fffffa1b.w
	move.b	#199,$fffffa21
	move.b	#8,$fffffa1b
	move.l	#killborder,$120 ; sets up the bottom border

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;start of scroll routine

morepix:
	move.w	delcon,d0
	subq.w	#1,d0
	beq	mskro
	move.w	d0,delcon
	jmp	endskro
mskro	move.w	_left,d1
	dbf	d1,noneed
        move.l  mespt,a0
        clr.l   d0
	move.b  (a0)+,d0
	cmp.b	#254,d0
	bne	gstring
	move.b	(a0)+,d0
	move.w	d0,delcon
	move.l	a0,mespt
	jmp	morepix
gstring	cmp.b   #255,d0
        bne     trebx
	move.b	#'[',d0
	move.l	#line,a0

trebx:  cmp.b	#' ',d0
	bne	goony1
	move.b	#'[',d0

goony1	cmp.b	#'.',d0
	bne	goony2
	move.b	#'\',d0

goony2	cmp.b	#'!',d0
	bne	goony3
	move.b	#103,d0

goony3	cmp.b	#'(',d0
	bne	goony4
	move.b	#104,d0

goony4	cmp.b	#')',d0
	bne	goony5
	move.b	#105,d0

goony5	cmp.b	#',',d0
	bne	goony6
	move.b	#106,d0

goony6	cmp.b	#'"',d0
	bne	goony7
	move.b	#107,d0

goony7	cmp.b	#'?',d0
	bne	goony8
	move.b	#108,d0

goony8	cmp.b	#':',d0
	bne	goony9
	move.b	#109,d0

goony9	cmp.b	#'*',d0
	bne	goony10
	move.b	#109,d0

goony10	cmp.b	#'-',d0
	bne	goony11
	move.b	#110,d0

goony11	cmp.b	#'9',d0
	bgt	continue
	add.b	#93-"0",d0

continue:
	sub.b   #'A',d0
	divu	#10,d0
	move.l	d0,d1
        mulu    #160*32,d0
	swap	d1
	lsl	#4,d1
	add.w	d1,d0
        add.l   #ch+34,d0
	move.l	a0,mespt
        move.l  d0,a0
	move.l	#_blk,a1
	move.w	#31,d2
loup1	move.w	2(a0),128(a1)
	move.w	10(a0),130(a1)
	move.w	4(a0),256(a1)
	move.w	12(a0),258(a1)
	move.w	6(a0),384(a1)
	move.w	14(a0),386(a1)
	move.w	(a0),(a1)+
	move.w	8(a0),(a1)+
	add.l	#160,a0
	dbf	d2,loup1
	move.w	#3,d1
noneed:	move.w	d1,_left
	move.l	#_blk+3,a1
	sub.w	d1,a1
	move.l	#$76000+32160,a2
	move.w	#3,d0
nexbp	move.l	a2,a0
	lea	2(a2),a2
	move.w	#31,d1
nexln	move.b	1(a0),(a0)
	move.b	8(a0),1(a0)
	move.b	9(a0),8(a0)
	move.b	16(a0),9(a0)
	move.b	17(a0),16(a0)
	move.b	24(a0),17(a0)
	move.b	25(a0),24(a0)
	move.b	32(a0),25(a0)
	move.b	33(a0),32(a0)
	move.b	40(a0),33(a0)
	move.b	41(a0),40(a0)
	move.b	48(a0),41(a0)
	move.b	49(a0),48(a0)
	move.b	56(a0),49(a0)
	move.b	57(a0),56(a0)
	move.b	64(a0),57(a0)
	move.b	65(a0),64(a0)
	move.b	72(a0),65(a0)
	move.b	73(a0),72(a0)
	move.b	80(a0),73(a0)
	move.b	81(a0),80(a0)
	move.b	88(a0),81(a0)
	move.b	89(a0),88(a0)
	move.b	96(a0),89(a0)
	move.b	97(a0),96(a0)
	move.b	104(a0),97(a0)
	move.b	105(a0),104(a0)
	move.b	112(a0),105(a0)
	move.b	113(a0),112(a0)
	move.b	120(a0),113(a0)
	move.b	121(a0),120(a0)
	move.b	128(a0),121(a0)
	move.b	129(a0),128(a0)
	move.b	136(a0),129(a0)
	move.b	137(a0),136(a0)
	move.b	144(a0),137(a0)
	move.b	145(a0),144(a0)
	move.b	152(a0),145(a0)
	move.b	153(a0),152(a0)
	move.b	(a1),153(a0)
	lea	160(a0),a0
	lea	4(a1),a1
	dbf	d1,nexln
	dbf	d0,nexbp
endskro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end of scroll routine

	movem.l (sp)+,d0-a6
new4b:	jmp	0		; will be set up by prog

killborder
	movem.l	d0-d7/a0-a1,-(sp)
	move.w	#$fa21,a1
	clr.b	-6(a1)
	move.b	#200,(a1)
	move.b	#8,$fffffa1b.w
	move.b	(a1),d0
wait4:	cmp.b	(a1),d0
	beq	wait4
	clr.b	$ffff820a.w
	REPT	16
	nop
	ENDR
	move.b	#2,$ffff820a.w
	move.l	#$ff8240,a0
	move.b	(a1),d0		; bottom border now away
del	cmp.b	(a1),d0
	beq	del
	move.l	#ch+2,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,($ff8240)
	movem.l	(sp)+,d0-d7/a0-a1
	bclr	#0,$fffffa0f.w
	rte

_left	dc.w	0
_blk	ds.w	256
delcon	dc.w	2
mespt	dc.l	preline
xdummy	dc.l	0
old4	dc.l	0
oldtb	dc.l	0
old07	dc.b	0
old09	dc.b	0
preline	dc.b 254,255,254,100
line
 DC.B 'THIS IS VERY IMPORTANT SO PLEASE READ ALL THE TEXT.'
 dc.b '     THIS HAS BEEN WRITTEN FOR A 32 BY 32 FULL 16 COLOUR FONT'
 DC.B ' AND ONLY HAS THE LETTERS FOR A TO Z UPPER CASE ... 0123456789'
 DC.B '!(),"?-  AND NOTE THAT THE : AND THE * ARE THE SAME CHARACTER'
 DC.B ' STILL A BIT FAST FOR ME .. BUT WHO GIVES A SHIT '
 DC.B ' THIS SHOULD ARRIVE WITH A DISK OF FONTS BUT I DONT KNOW HOW'
 DC.B ' MANY THAT THIS WILL WORK WITH !!!'

 DC.B ' THANKS FOR READING THIS ..........  '
 DC.B ' G STRING ',254,200
 DC.B '   FROM   ',254,100
 DC.B '  G FORCE ',254,200
 DC.B '..........'
 DC.B '  OR ANDY ',254,100
 DC.B '................. RESTARTING MESSAGE .....     WARP     ',255

	ds.l	100
mystack	ds.l	1
ch
	EVEN
	INCBIN	'A:\g_force\a32.pi1'

FromScreen
	INCBIN	'A:\g_force\brat.PI1'

Emp	dc.b 'A:\',0
Empty	dc.b 0
Prog1	dc.b 'GARFIELD.PRG',0
Prog2	dc.b 'NIGHTDAW.PRG',0
Prog3	dc.b 'WICKED.PRG',0
hertz	dc.b	2


