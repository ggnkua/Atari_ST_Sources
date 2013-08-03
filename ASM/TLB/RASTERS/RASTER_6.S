; rasters, scrolls, starfields and other things...

; mfp section from ST NEWS 4.3 by Stefan Posthuma
; adapted by Camy Maertens (Budgie UK)
; starfield by Gary Wheaton & The Shapeshifters
; text scroll by Damon Barwin, Omensoft and co
; font by unknown (fontish)
;  
; before compiling change path if necessary

	bra	start

pic_name	dc.b "a:\rasters\queen5.pi1",0
font_name 	dc.b "a:\fonts\fontish",0
		even


start	clr.l   -(sp)		supervisor mode on
	move.w  #$20,-(sp)
	trap    #1
	move.l  d0,savereg
	
	move.l	$44e,a0		current physbase
	sub.l	#$2000,a0	go back a bit because our 50-60 hz...
	move.l	a0,physbase	..trick would push us into rom
	move.l	a0,a7		temporary stack

	move.l  #moff,-(sp)	mouse off
	clr.w   -(sp)
	move.w  #25,-(sp)
	trap    #14
	addq.l  #8,sp
	dc.w    $a00a

	move.w  #4,-(sp)		get resolution        
	trap    #14
	addq.l  #2,sp
	move.w  d0,oldrez		and save it
	move.l  $44e,oldscr
	move.l  physbase,screen

	movem.l $ffff8240.w,d0-d7	save colors...
	movem.l d0-d7,oldpal		..quickly

	move.w  #0,-(sp)		set low res
	move.l  screen(pc),-(sp)	phys	
	move.l  screen(pc),-(sp)	log
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp

	bra	nopic	 in this example, we don't want any degas pic

* load a degas picture at a specific address 
	move.w	#0,-(sp)
	move.l	#pic_name,-(sp)	open file	
	move.w	#$3D,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle

	move.l	screen,d0	load direct to current screen
	sub.l	#34,d0
	sub.l	#1*160,d0	hide the palette data
	move.l	d0,-(sp) 
	move.l	#34,-(A7)	read it
	move.w	handle,-(A7)
	move.w	#$3F,-(A7)
	trap	#1
	adda.l	#12,A7

	move.l	screen,d0	load direct to current screen
	add.l	#40*160,d0	push the picture 40 lines DOWN
;				inside the bottom border!
	move.l	d0,-(sp) 
	move.l	#32000,-(A7)	read picture
	move.w	handle,-(A7)
	move.w	#$3F,-(A7)
	trap	#1
	adda.l	#12,A7

	move.w 	handle,-(SP)
	move.w 	#$3E,-(SP)
	trap 	#1		close file
	addq.l 	#4,SP


nopic
	move.l	screen,a0
	sub.l	#44,a0		get a random palette as no pic is loaded
	lea	palette,a1	destination
	move.l	#16-1,d0
paloop	move.w	(a0)+,(a1)+	save it
	dbra	d0,paloop


	move.l	#font_name,-(A7)	open fontish c/set
	move.w	#$3D,-(A7)
	trap	#1
	move.w	d0,handle
	move.l	#font,-(A7)	load it here (end of this prog)
	move.l	#1953,-(A7)	1953 bytes
	move.w	handle,-(A7)
	move.w	#$3f,-(a7)	read file
	trap	#1
	adda.l	#$c,A7	
	move.w 	handle,-(a7)
	move.w 	#$3e,-(a7)
	trap 	#1		close file
	addq.l 	#4,a7	

	move.l	screen,d5
	add.l	#38*160+158,d5	line of scroll number 1
	move.l	d5,line_one	
	move.w	#1,speed
	move.l	#text_1,text_address	budgie message in scroll variable


	move.l	#scroll,a5	enable scroll interrupt	
	bsr	enable_vbi

	bsr	reset		enable reset routine

hi	bsr     hblon		enable my MFP interrupts#

*------------------------------------------------
get	
	bsr	getkey
	cmp.b	#$01,d0		esc
	beq	quit
	bsr	stary		star field at 50 hz
	bra	get
*-------------------------------------------------
getkey	
	move.w  #$ff,-(sp)	
	move.w	#6,-(sp)
	trap    #1
	addq.l  #4,sp
	swap	d0
	rts
*------------------------------------------------
quit
	move.l	#scroll,a5	cut out message scroll
	bsr	disable_vbi


	bsr     hbloff		disable MFP interrupts

	movem.l oldpal,d0-d7	old colors back
	movem.l d0-d7,$ffff8240.w
	move.w  oldrez,-(sp)	old resolution back
	move.l  oldscr,-(sp)
	move.l  oldscr,-(sp)
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp

	move.l  #mon,-(sp)	mouse on
	clr.w   -(sp)
	move.w  #25,-(sp)
	trap    #14
	addq.l  #8,sp
	dc.w    $a009

	move.l  savereg,-(sp)	leave supervisor
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp

	clr.w   -(sp)		quit
	trap    #1

oldrez	dc.w    0
oldscr	dc.l    0
savereg	dc.l    0
screen	dc.l    0
oldpal	ds.w    16
mon	dc.b    8
moff	dc.b    18

                even

*-------------------------------------------------------

; see the article for comments about these addresses

hblon	move.l  $120,oldtb	save old timer B vector
	move.l  $70,old4	save old vb vector
	move.l  $70,new4b+2	now, new vb routine will jump to
;				old one afterwards
	move.b  $fffffa07,old07	timer B enable
	move.b  $fffffa09,old09	timer C enable
	move.b  $fffffa0f,old0f	timer B in-service
	move.b  $fffffa11,old11	timer C in-service
	move.b  $fffffa1b,old1b	timer B control
	and.b   #$df,$fffa09	disable timer C
	and.b   #$fe,$fffa07	disable timer B 
	move.l  #newtb1,$120	new timer B vector
	move.l  #new4,$70	new vb vector
	or.b    #1,$fffffa07	enable timer B
	or.b    #1,$fffffa13	set timer B mask
	rts

hbloff	move.w  sr,-(sp)
	move.w  #$2700,sr	cut out all interrupts
	move.b  old07(pc),$fffffa07 restore all old vectors
	move.b  old09(pc),$fffffa09
	move.b  old0f(pc),$fffffa0f
	move.b  old11(pc),$fffffa11
	move.b  old1b(pc),$fffffa1b
	move.l  oldtb,$120
	move.l  old4,$70
	move.w  (sp)+,sr
	rts

old4	dc.l    0
oldtb	dc.l    0
old07	dc.b    0
old09	dc.b    0
old0f	dc.b    0
old11	dc.b    0
old1b	dc.b    0
	even
*------------

; This is the new VBL handler
new4	clr.b   $fffffa1b.w	disable timer B
	move.b  #36,$fffffa21	first raster 36 lines away
	move.b  #8,$fffffa1b	enable timer B
	move.w  #$327,$ff8240	initial border (beige)
	move.l  #newtb1,$120	timer B vector
new4b	jmp     $12345678	pass ontrol to OLD vb vector

newtb1	clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)  save from corruption
	move.w  #$fa21,a1	timer B data register (ie scanline!)
	move.b	#22,(a1)	put 22 in it : second interrupt at line 58
	move.l  #newtb2,$120	set new timer B vector
	move.b  #8,$fffffa1b.w	allow timer B again

	moveq.w #22-1,d2	number of colors in table
; change above figure to 48 and we'll get 48 lines with different
; colors BUT, next interrupt further down will be unstable..
	move.l  #pal1,a0 	pal1: color table
; I am now randomly modifying A0 to point ANYWHERE in memory
	move.l	$466,d3		random value
	lsl.l	#1,d3		make it even
	move.l	d3,a0		point to it
;	add.l	#44,a0		add 22 words

; we can now clearly see these 22 lines grouped at the top of picture
; from line 36 onwards (22 different random colors)

loop	move.b  (a1),d0		get value of timer B
wait	cmp.b   (a1),d0		wait one scanline !
	beq     wait
	move.w  -(a0),$ff8242 	use those randoms colors (backwards)

;	move.w  (a0)+,d1
;	move.w	d1,$ff8240	set colors
;	move.w	d1,$ff8242
;	move.w	d1,$ff8244
;	move.w	d1,$ff8246
;	move.w	d1,$ff8248
;	move.w	d1,$ff824a
;	move.w	d1,$ff824c
;	move.w	d1,$ff824e
	dbra    d2,loop

	movem.l	palette,d1-d7/a0
loopx	move.b	(a1),d0		more waiting for...
waitx	cmp.b	(a1),d0		... next scanline
	beq	waitx
	movem.l	d1-d7/a0,$ff8240
                
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte

newtb2	clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #76,(a1)	third one will be at line 58+40=98
	move.l  #newtb3,$120
	move.b  #8,$fffffa1b.w

; now follows the second lot of lines from location 58 to 80
	move.w  #22-1,d1	raster is 22 scanlines deep
	move.l	$466,d2		get a random number
	lsl.l	#1,d2		make sure it's even
	move.l  d2,a0		that's where we'll get our colors from!
loop2	move.b  (a1),d0
wait2	cmp.b   (a1),d0		see if scanline has moved on
	beq     wait2
	move.w  (a0)+,$ff8240   now use those totally random colors
	dbra    d1,loop2

	movem.l	palette,d1-d7/a0	restore original palette
	move.b	(a1),d0
waity	cmp.b	(a1),d0
	beq	waity
	movem.l	d1-d7/a0,$ff8240
                
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte

newtb3	clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #64,(a1)	kill border at line 199 (101+98)
	move.l  #killborder,$120
	move.b  #8,$fffffa1b.w

; now we have the third group of colors, again random
	move.w  #21-1,d1	number of scanlines wanted
	move.l  #pal1,a0	where colors are stored
loop3	move.b  (a1),d0
wait3	cmp.b   (a1),d0
	beq     wait3
	move.w  (a0)+,$ff8240	
	dbra    d1,loop3

	movem.l	palette,d1-d7/a0	again restore original palette
	move.b	(a1),d0
waitz	cmp.b	(a1),d0
	beq	waitz
	movem.l	d1-d7/a0,$ff8240
                
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte

killborder
	clr.b   $fffffa1b.w	timer stop
*	bra	bill		jumping to bill will skip the 50-60 hz bit
	movem.l d0-d1/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #140,(a1)	changing this number had little effect
	move.b  #8,$fffffa1b.w	this line is essential

	move.b  (a1),d0
wait4	cmp.b   (a1),d0		wait last scanline
	beq     wait4		
	clr.b   $ffff820a.w	60 Hz
	moveq   #3,d0		used to be 4. Now 3 for STE.
nopi2	nop			wait a while
	dbf     d0,nopi2
	move.b  #2,$ffff820a.w	50 Hz
	movem.l (sp)+,d0-d1/a0-a1 
bill      
	bclr    #0,$fffffa0f.w	end of interrupt
	rte			final exit 

*------------------------------------------

pal1	dc.w    $026,$237,$247,$257,$256,$255,$254,$162
	dc.w	$560,$653,$750,$740,$730,$600,$530,$600
	dc.w	$730,$740,$750,$760,$653,$560,$162,$254
 	
palette		ds.w	32
		ds.w	10

physbase	dc.l	0
screen_0	dc.l	0
handle		dc.w	0

		ds.w	48

	even


*----------------
*	SET a Sequence of VBI routines  [ C.Maertens ] 20/9/87
* Each routine has to be enabled or disabled separately
* Address of routine expected in A5
* first available slot is usually the second one, first being gem
* move.l #myroutine,$4d2 also does the same job
* see example of TWO vbi's at once in Operation Angelica
enable_vbi
	movem.l	a0-a5,-(sp)
	move.l	$456,a0
enab1	tst.l	(a0)		is is nought? (free)
	beq	enab2
	adda.l	#4,a0
	bra	enab1
enab2	move.l	a5,(a0)		slot in this routine
	movem.l	(sp)+,a0-a5
	rts
*------------
disable_vbi
	movem.l	d0/a0-a5,-(sp)	a5 holds address of routine
	move.l	$456,a0
disab1	cmp.l	(a0),a5		contents of $456 same as routine?
	beq	disab2
disab3	adda.w	#4,a0		try next one
	bra	disab1
disab2	move.l	#0,(a0)		switch it off
	movem.l	(sp)+,d0/a0-a5
	rts
*---------------------------
* star field  (Gary Wheaton / Shapeshifters)

stary
	MOVE #0,d7	loop (looks essentials...)

        MOVE #34,-(SP)
        TRAP #14
        ADD.L #2,SP 
	move	#3563,d0
        ADD #61,D0
        MOVE D0,JOY

        BRA STAR
JOY     DC.W 0
HJTB    DC.B 0,0,0,0,1,1,1,0,-1,-1,-1
VJTB    DC.B 0,-1,1,0,0,-1,1,0,0,-1,1

STAR	MOVE.L 	#HTAB,A4

WAITVB  MOVE #37,-(SP)
        TRAP #14
        ADDQ.L #2,SP
        CLR.L D0
        
        MOVE JOY,A0
        CLR D0
        MOVE.B (A0),D0
        CLR D4
        CLR D6
        MOVE.B HJTB(PC,D0),D4 \HZ
        MOVE.B VJTB(PC,D0),D6 \VT

LP0	MOVE.B 	#0,D5
	MOVE 	(A4),D0
	MOVE.B 	91(A4),D1
	BSR	CPLOTT

	
        MOVE 180(A4),D0
        CMP.B #10,D4
        BGT OK
        CMP.B #0,D4
        BEQ OK1
        BMI RIGHT 
	SUB D0,(A4)
        BPL OK1
        MOVE 	#320,(A4)
 
        MOVE.B 91(A4),D1  \
        ROL.B #1,D1       \RANDOMIZE VERT A BIT
	MOVE.B 	D1,91(A4) \
        BRA OK1

RIGHT   ADD D0,(A4)
        CMP #320,(A4)
        BLT OK1
        CLR (A4)
                          *\SHOULD RAND HERE ALSO
OK1     CMP.B #0,D6
        BEQ OK
        BPL UP
        SUB D0,90(A4)
        BPL OK2 
        MOVE #199,90(A4)
        BRA OK2

UP      ADD D0,90(A4)
        CMP #200,90(A4)
        BLT OK2
        CLR 90(A4)
OK2
OK	MOVE.B 	91(A4),D1  \V
	MOVE 	(A4),D0
	MOVE.B 	D1,D5
	BSR 	CPLOTT

	SUB.L 	#2,A4
	CMP.L 	#TR,A4
	BGT 	LP0
	dbra	d7,STAR
	
SM      RTS	
*-----------
CPLOTT 	AND.L 	#15,D5
	AND 	#255,D1
	CMP 	#320,D0
	BLT 	PLO   
	RTS
PLO 	MOVE 	D0,D3
	LSR.W 	#3,D0
	MOVE 	D0,D2
	AND 	#7,D3
	AND 	#1,D0
	AND 	#65534,D2
	ASL  	#2,D2
	ADD 	D2,D0
	MULU 	#160,D1
	ADD.W 	D1,D0
	MOVE.L	$44E,A0		
	ADD.L  	D0,A0
	MOVE.L 	A0,A1
	MOVE.B 	tbl(PC,D3),D0 \GET MASK

  
PLOK	AND.B 	D0,(A0) \C.0:PL.X,Y
	AND.B 	D0,2(A0) \
	AND.B 	D0,4(A0)
     	AND.B 	D0,6(A0)
	
	CMP.B 	#0,D5   \COLOR TO PLOT
	BNE 	COLO      \IF>0 THEN PLOT
	RTS           \ELSE RTS 
*---------
*       \COLOR 0 MASKS
tbl	DC.B 	127,255-64,223,239
	DC.B 	247,251,253,254  
COLO 	EOR.B 	#255,D0     \REVERSE BIT PATTN
	ASL 	#2,D5         \COL*4
	MOVE.L 	#XGOTO,A0
	ADD.W 	D5,A0
	MOVE.L 	(A0),A0
	JMP 	(A0)           \GOTO COLOR
C15 	OR.B 	D0,6(A1)  \COLOR 15
C14 	OR.B 	D0,2(A1)
C10 	OR.B 	D0,(A1)
C2  	OR.B 	D0,4(A1)
	RTS
*----------
C3 	OR.B 	D0,4(A1)   
C1 	OR.B 	D0,6(A1)   \COLOR 1 ENTRY
	RTS
C5 	OR.B 	D0,2(A1)
	OR.B 	D0,6(A1)
	RTS
C7 	OR.B 	D0,6(A1)
C6 	OR.B 	D0,4(A1)
C4 	OR.B 	D0,2(A1)
	RTS
C11 	OR.B 	D0,4(A1)
C9 	OR.B 	D0,6(A1)
C8 	OR.B 	D0,(A1)
	RTS
C13 	OR.B 	D0,6(A1)
C12 	OR.B 	D0,(A1)
	OR.B 	D0,2(A1) 
	RTS
C16 	RTS
*         \ JSR TABLE interesting way
XGOTO 	DC.L 	C1,C1,C2,C3,C4,C5,C6,C7,C8
	DC.L 	C9,C10,C11,C12,C13,C14,C15,C16



*	\\\\\23
* across *
TR
	DC.W 	0,20,30,120,319,200,230,290
	DC.W 	80,140,134,180,240,290,199
	DC.W 	50,95,130,180,234,256,300

	DC.W 	8,16,23,30,40,48,54,62,78,83
	DC.W 	100,105,115,123,134,140,150
	DC.W 	156,160,170,178,1,1

* down *	Y pos of stars
HTAB 	DC.W 	1

	DC.W 	160,170,180,166,172,174,87
	DC.W 	110,110,120,122,124,126,128
	dc.w	130,132,134,136,91,92,94,97,100,101,103
	dc.w	80,100,85,104,108,109
	DC.W 	126,127,158,169,140,131,132
	DC.W 	143,134,165,136,157,168
* speed *
	DC.W 	1,2,3,2,4,6,1,2,3,1,3,1,2,5,4
	DC.W 	1,2,3,6,4,2,5,2
	DC.W 	2,1,6,4,2,1,4,6,3,3,2,5,4,1,5
	DC.W 	6,2,3,1,2,3,3,3
*--------------------------

* THIS JUMPS TO RESETA WHEN THE RESET BUTTON IS PRESSED *
* (Damon Barwin)
reset
	move.l	#$31415926,$426	validate reset
	move.l	#reseta,$42a	point to reset routine
	rts

* this is the reset routine
reseta
	move.l	screen,d0
	sub.l	#$18000,d0
	move.l	d0,a7  		some free stack needed 
	move.w	#$2300,sr	disable some interrupts
	clr.l	$426		disable reset effect
	bset	#1,$fff820a	50 hz
	move.l	screen,line_one	default screen preferably default screen else crash
	move.l	#text_9,text_address	quit message to scroll 
	move.w	#$0,-(A7)
	move.l	screen,-(A7)	reset screen to default
	move.l	screen,-(A7)
	move.w	#5,-(A7)
	trap	#14
	add.l	#12,A7
	move.l	#press,-(a7)	press rest etc...
	move.w	#$9,-(a7)	print text
	trap	#1
	addq.l	#6,a7		
	bra	get

press	dc.b	10,10,10,10,10,10,10,10
	dc.b	"  PLEASE PRESS THE RESET BUTTON AGAIN",10,13,13,13,13,0
	even
text_9	
	dc.b	4,"    BUDGIE UK    ",5
	dc.b	4,"                 "
	DC.B	3," THE FAIRER FACE ",5
	dc.b	4,"                 "
	dc.b	3,"   OF  PD !      ",5
	DC.B    4,"  ALL   AUTHORS  "
	dc.b	4,"RECEIVE ROYALTIES",5
	dc.b	4,"                 "
	dc.b	3,"SEE YOU AGAIN ...",5
	dc.b	4,"..    SOON       ",5
	dc.b	3,"                 ",5
	dc.b	$fe		end of reset message
	even
*------------------------------
* message scroller
scroll
	tst.w	vvar1
	bne	tscr18
	cmpi.w	#16,vvar2
	bls.s	tscr6
	clr.w	vvar2
tscr3	movea.l	text_address,a0	scroll variable (holds address of text)
	moveq	#0,d0
	move.b	(a0)+,d0
	cmpi.b	#$ff,d0		end of main message?
	beq	tscr11
	cmpi.b	#$fe,d0		end of reset message?
	beq	tscr11a
tscr4	move.l	a0,text_address
	cmp.b	#$20,d0
	ble	tscr12
tscr5	subi.b	#$20,d0
	lea	font,a1		where font is loaded
	lsl.l	#5,d0
	adda.l	d0,a1
	lea	workspace,a2
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
tscr6	move.w	speed,d0
tscr7	
	move.l	screen,d7
	add.l	#202*160,d7		line of scroll number 2
	move.l	d7,old_screen_pos
	move.l	d7,a2  
	lea	workspace,a1
	moveq	#15,d1
tscr8	lsl	(a1)+
	roxl	$98(a2)
	roxl	$90(a2)
	roxl	$88(a2)
	roxl	$80(a2)
	roxl	$78(a2)
	roxl	$70(a2)
	roxl	$68(a2)
	roxl	$60(a2)
	roxl	$58(a2)
	roxl	$50(a2)
	roxl	$48(a2)
	roxl	$40(a2)
	roxl	$38(a2)
	roxl	$30(a2)
	roxl	$28(a2)
	roxl	$20(a2)
	roxl	$18(a2)
	roxl	$10(a2)
	roxl	8(a2)
	roxl	(a2)
	adda.l	#$a0,a2
	dbf	d1,tscr8
	addq.w	#1,vvar2
	dbf	d0,tscr7
tscr9	move.l	old_screen_pos,a0 
	movea.l	line_one,a1	the message at the top
	adda.l	#2,a1
	moveq	#$f,d0
tscr10	
	move.w	(a0),(a1)
	move.w	8(a0),8(a1)
	move.w	$10(a0),$10(a1)
	move.w	$18(a0),$18(a1)
	move.w	$20(a0),$20(a1)
	move.w	$28(a0),$28(a1)
	move.w	$30(a0),$30(a1)
	move.w	$38(a0),$38(a1)
	move.w	$40(a0),$40(a1)
	move.w	$48(a0),$48(a1)
	move.w	$50(a0),$50(a1)
	move.w	$58(a0),$58(a1)
	move.w	$60(a0),$60(a1)
	move.w	$68(a0),$68(a1)
	move.w	$70(a0),$70(a1)
	move.w	$78(a0),$78(a1)
	move.w	$80(a0),$80(a1)
	move.w	$88(a0),$88(a1)
	move.w	$90(a0),$90(a1)
	move.w	$98(a0),$98(a1)
	adda.l	#$a0,a0
	adda.l	#$a0,a1
	dbf	d0,tscr10
	rts
tscr11	lea	text_1,a0	at end of main message, we come..
	move.b	#32,d0		..here again
	bra	tscr4
tscr11a	lea	text_9,a0	at end of reset message, we come..
	move.b	#32,d0		..here
	bra	tscr4
tscr12	cmp.b	#1,d0		speeds 1 slow  4 fast  5 stop
	beq	tscr13
	cmp.b	#2,d0
	beq	tscr14
	cmp.b	#3,d0
	beq	tscr15
	cmp.b	#4,d0
	beq	tscr16
	cmp.b	#5,d0
	beq	tscr17
	bra	tscr5
tscr13	move.w	#0,speed
	bra	tscr3
tscr14	move.w	#1,speed
	bra	tscr3
tscr15	move.w	#2,speed
	bra	tscr3
tscr16	move.w	#5,speed
	bra	tscr3
tscr17	move.w	#50,vvar1
	move.w	#16,vvar2
	bra	tscr18
tscr18	subi.w	#1,vvar1
	bra	tscr9

* TEXT FOR MESSAGE *
* speed: 1 to 4 (slow-fast)  5 is stop    255 is end
text_1	
	dc.b	4,"    BUDGIE UK    ",5
	dc.b	4,"                 "
	DC.B	3,"   LICENCEWARE   ",5
	dc.b	4,"                 "
	dc.b	3,"  35  TITLES !   ",5
	DC.B    4,"  ESC  TO  QUIT  ",5
	dc.b	4,"                 ",5
	DC.B    4,"  HELP: MUSIC    ",5
	dc.b	4,"     ON / OFF    ",5
	dc.b	1,"...RESET  QUIT ..",5
	dc.b	255			end
	even

vvar1		ds.w	1
vvar2		ds.w	1
text_address	ds.l	6
workspace	ds.l	8	temp storage for character
speed		ds.w	1

line_one	ds.l	1
old_screen_pos  dc.l 	0
		ds.w	8

font		ds.b	2192  	c/set is physically loaded HERE
		ds.w	24	spare





