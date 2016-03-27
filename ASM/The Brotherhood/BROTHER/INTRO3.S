d************************************************************************
*                         TTTTT H   H EEEEE                            *
*                           T   H   H E                                *
*                           T   HHHHH EEEEE                            *
*                           T   H   H E                                *
*                           T   H   H EEEEE                            *
*								       *
* BBBBB  RRRR   OOOOO TTTTT H   H EEEEE RRRR  H   H OOOOO OOOOO DDD    *
* B    B R   R  O   O   T   H   H E     R   R H   H O   O O   O D  D   *
* BBBBBB RRRRR  O   O   T   HHHHH EEEEE RRRRR HHHHH O   O O   O D   D  *
* B    B R R    O   O   T   H   H E     R R   H   H O   O O   O D  D   *
* BBBBB  R  R   OOOOO   T   H   H EEEEE R  R  H   H OOOOO OOOOO DDD    *
*                                                                      *
*                                INTRO                                 *
*               		VERSION 12                             *
*                      						       *
************************************************************************
*  NICE INTRO MADE BY -T.W.N.- OF THE BROTHERHOOD ON  06/02/91         *
*  COOL GRAPHIXX BY -T.C.D.-   USES MAD MAX MUSIC DRIVER               *
************************************************************************
*  THIS INTRO CONTAINS  THE FOLLOWING THINGS :-			       *
*  NO TOP BORDER						       *
*  NO BOTTOM BORDER                                                    *
*  4 SETS OF VU METERS                                                 *
*  32 COLOUR PICTURE                                                   *
*  LOTSA RASTERS                                                       *
*  16*16 PIXEL ONE BIT PLANE SCROLLING MESSAGE                         *
*  10 WAVEFORMS FOR SCROLLER                                           *
*  7 SPEEDS FOR SCROLLER                                               *
*  PAUSE ON SCROLLER                                                   *
*  GRAPHIXXX IN FRONT OF THE SCROLLER AND VU METERS                    *
*  3 BAR VU METERS						       *
*  MORE STABLE RASTERS WHEN KEYS ARE PRESSED			       *
*  PICTURE ON RESET WHICH CAN BE MADE TO DISAPPAER AFTER ANOTHER RESET *
*  MUCH CLEARER LISTING WITH MORE DOCUMENTION                          *
*  10 MUSIX ON THE F-KEYS  					       *
************************************************************************
* all incbins ,waveforms and scrolltext at section data label	       *
* number of tunes at new_mus label				       *
************************************************************************
	bra	start
****************
* ALL EQUATES  *
****************
SReg equ $ff8800  			* SOUND CHIP ADDRESS
*****************
* PROGRAM START *
*****************
start	clr.l   -(sp)		supervisor mode on
	move.w  #$20,-(sp)
	trap    #1
	move.l  d0,savereg
	
	move.l	$44e,a0		current physbase
	sub.l	#80*160,a0	go back a bit because our 50-60 hz...
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
*************************************************************************
*1st  palette for piccy until rasters start		        *
*************************************************************************
	MOVE.w  #$0000,$ff8240     TOP PALETTE
	move.w  #$0123,$ff8242    
	move.w  #$0124,$ff8244
	move.w  #$0134,$ff8246
	move.w  #$0234,$ff8248
	move.w  #$0235,$ff824a
	move.w  #$0245,$ff824c
	move.w  #$0345,$ff824e
	move.w  #$0346,$ff8250
	move.w  #$0356,$ff8252
	move.w  #$0456,$ff8254
	move.w  #$0457,$ff8256
	move.w  #$0557,$ff8258
	move.w  #$0567,$ff825a
	move.w  #$0677,$ff825c
	move.w  #$0777,$ff825e
* COPY a degas picture at a specific address 
	move.l	screen,a1	COPY direct to current screen
	sub.l	#34,a1
	sub.l	#1*160,a1	hide the palette data
	move.l	screen,a1	load direct to current screen
;				inside the bottom border!
* copy piccy to screen
	lea             piccy,a0
	ADD.L           #34,A0
	move.w          #$7d00,d0
put_pic	move.b          (a0)+,(a1)+
	dbra            d0,put_pic
	movem.l	$ff8240,d1-d7/a0      SAVE PALETTE
	movem.l	d1-d7/a0,palette1
******************************************************************************************************
	MOVE.w  #$000,$ff8240    SECOND PALETTE
	move.w  #$777,$ff8242    
	move.w  #$000,$ff8244
	move.w  #$000,$ff8246
	move.w  #$000,$ff8248
	move.w  #$000,$ff824a
	move.w  #$000,$ff824c
	move.w  #$000,$ff824e
	move.w  #$400,$ff8250
	move.w  #$666,$ff8252
	move.w  #$555,$ff8254
	move.w  #$444,$ff8256
	move.w  #$333,$ff8258
	move.w  #$222,$ff825a
	move.w  #$111,$ff825c
	move.w  #$777,$ff825e
	movem.l	$ff8240,d1-d7/a0      SAVE PALETTE
	movem.l	d1-d7/a0,palette2
******************************************************************************************************
	lea	font+2,a0
	lea	$ff8240,a1
	move.w	#15,d0		; 16 colours
	
setpal	move.w	(a0),d1
	move.w	(a1),(a0)+
	move.w	d1,(a1)+
	dbra	d0,setpal



	movem.l	$ff8240,d1-d7/a0
	movem.l	d1-d7/a0,palette3   SAVE PALETTE
	movem.l (sp)+,d0-d7/a0-a1	
*******************************************************************
* reset palette
	MOVE.w  #$000,$ff8240    reset PALETTE
	move.w  #$777,$ff8242    
	move.w  #$000,$ff8244
	move.w  #$000,$ff8246
	move.w  #$000,$ff8248
	move.w  #$000,$ff824a
	move.w  #$000,$ff824c
	move.w  #$000,$ff824e
	move.w  #$400,$ff8250
	move.w  #$666,$ff8252
	move.w  #$555,$ff8254
	move.w  #$444,$ff8256
	move.w  #$333,$ff8258
	move.w  #$222,$ff825a
	move.w  #$111,$ff825c
	move.w  #$777,$ff825e
	movem.l	$ff8240,d1-d7/a0      SAVE PALETTE
	movem.l	d1-d7/a0,resetpal
*********************************************************
	       move.l		tune_no,d0    MUSIC ON
		jsr		music
		move.l		#music+8,$4de
*******************************************************************
	move.l	#TEXT,TEXT_POINT  Message in scroll variable
	move.l	#scroll,a5	enable scroll interrupt	
	bsr	enable_vbi

	bsr	reset		enable reset routine

hi	bsr     hblon		enable my MFP interrupts

*------------------------------------------------
get	bra get
*------------------------------------------------
* gives computer something to do when vbi is running
*-------------------------------------------------
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

	clr.l		$4de
	clr.l		$4d6
	clr.l		$4da
	clr.l		$4d2
	PEA		stopm_d      *MUSIC OFF
	MOVE.W		#$20,-(A7)
	TRAP		#14
	ADDQ.L		#6,A7
	bset		#5,$fffa09
	move.l  savereg,-(sp)	leave supervisor
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp

	clr.w   -(sp)		quit
	trap    #1

screen	dc.l    0            SCREEN POINTER
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
	move.l  #newtb3,$120	new timer B vector
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

old07	dc.b    0        * OLD MFP POINTERS
old09	dc.b    0        *
old0f	dc.b    0        *
old11	dc.b    0        *
old1b	dc.b    0        *
	even
*------------

; This is the new VBL handler
new4	
vbl       movem.l	d0-d7/a0-a6,-(a7)   *REMOVE THE TOP BORDER
		move		sr,-(a7)
		move		#$2700,sr
		move.l	#$588,d0
vblwait	dbf		d0,vblwait
		clr.b 	$ffff820a			60Hz
		moveq 	#3,d0
nopi3	nop
		dbf 		d0,nopi3		
		move.b 	#2,$ffff820a		50Hz
		move.w	(a7)+,sr
**************************************		
* top border rout
****************************************
	clr.b   $fffffa1b.w	disable timer B
	move.b  #10,$fffffa21	first raster 10 lines away
	move.b  #8,$fffffa1b	enable timer B
	movem.l d0-d7/a0-a1,-(sp)
	movem.l	palette1,d1-d7/a0
	movem.l	d1-d7/a0,$ff8240
	movem.l (sp)+,d0-d7/a0-a1
	move.l  #bar1,$120	timer B vector
**************************************************************
new_mus		moveq		#0,d0
		move.b		$fffc02,d0   read keyboard
		cmp.b		#$3b,d0      not one of the f-keys
		blt.s		no_go
********** change the range below from #$44,do to other if less than 10 tunes used
********** i.e lower number by 1 for each tune less !!
		cmp.b		#$44,d0      not one of the f-keys
		bgt.s		no_go
		move.l		tune_no,d1
		sub.b		#$3a,d0   make into tune number
		cmp.b		d1,d0     same tune
		beq.s		no_go     yes same tune 
		cmp.b		#0,d0
		beq.s		no_go

		move.l		d0,tune_no

		move.l		tune_no,d0
		jsr		music
		move.l		#music+8,$4de
no_go		
ReadMusicVol:                       *READ SOUND CHIP VOLUME
	MOVE.B	#8,SReg
	MOVEQ	#0,D0
	MOVE.B	SReg,D0
	MOVE.B	#9,SReg
	MOVEQ	#0,D1
	MOVE.B	SReg,D1
	MOVE.B	#10,SReg
	MOVEQ	#0,D2
	MOVE.B	SReg,D2
************************************************
* colour bar vu meters			       *
************************************************
************************************************
* voice 1				       *
************************************************
* work out volume
	cmp.b #0,d0
	beq   palt1a
	cmp.b #1,d0
	beq   palt2a
	cmp.b #2,d0
	beq   palt3a
	cmp.b #3,d0
	beq   palt4a
	cmp.b #4,d0
	beq   palt5a
	cmp.b #5,d0
	beq   palt6a
	cmp.b #6,d0
	beq   palt7a
	cmp.b #7,d0
	beq   palt8a
	cmp.b #8,d0
	beq   palt9a
	cmp.b #9,d0
	beq   palt10a
	cmp.b #10,d0
	beq   palt11a
	cmp.b #11,d0
	beq   palt12a
	cmp.b #12,d0
	beq   palt13a
	cmp.b #13,d0
	beq   palt14a
	bra   palt15a
*********************************
* change colours below to what you like but only change last 3 number	
*******************************
* change colour in variable
*******************************
palt1a  move.w #$0000,palta
	bra all_done
*******************************
palt2a  move.w #$0110,palta
	bra all_done
*******************************
palt3a  move.w #$0220,palta
	bra all_done
*******************************
palt4a  move.w #$0330,palta
	bra all_done
*******************************
palt5a  move.w #$0440,palta
	bra all_done
*******************************
palt6a  move.w #$0550,palta
	bra all_done
*******************************
palt7a  move.w #$0660,palta
	bra all_done
*******************************
palt8a  move.w #$0770,palta
	bra all_done
*******************************
palt9a  move.w #$0670,palta
	bra all_done
*******************************
palt10a move.w #$0570,palta
	bra all_done
*******************************
palt11a move.w #$0470,palta
	bra all_done
*******************************
palt12a move.w #$0370,palta
	bra all_done
*******************************
palt13a move.w #$0270,palta
	bra all_done
*******************************
palt14a move.w #$0170,palta
	bra all_done
*******************************
palt15a move.w #$0070,palta
*******************************
all_done
************************************************
* voice 2				       *
************************************************
* work out volume
	cmp.b #0,d1
	beq   palt1b
	cmp.b #1,d1
 	beq   palt2b
	cmp.b #2,d1
	beq   palt3b
	cmp.b #3,d1
	beq   palt4b
	cmp.b #4,d1
	beq   palt5b
	cmp.b #5,d1
	beq   palt6b
	cmp.b #6,d1
	beq   palt7b
	cmp.b #7,d1
	beq   palt8b
	cmp.b #8,d1
	beq   palt9b
	cmp.b #9,d1
	beq   palt10b
	cmp.b #10,d1
	beq   palt11b
	cmp.b #11,d1
	beq   palt12b
	cmp.b #12,d1
	beq   palt13b
	cmp.b #13,d1
	beq   palt14b
	bra   palt15b
*********************************
* change colours below to what you like but only change last 3 number	
*******************************
* change colour in variable
*******************************
palt1b  move.w #$0000,paltb
	bra all_done1
*******************************
palt2b  move.w #$0011,paltb
	bra all_done1
*******************************
palt3b  move.w #$0022,paltb
	bra all_done1
*******************************
palt4b  move.w #$0033,paltb
	bra all_done1
*******************************
palt5b  move.w #$0044,paltb
	bra all_done1
*******************************
palt6b  move.w #$0055,paltb
	bra all_done1
*******************************
palt7b  move.w #$0066,paltb
	bra all_done1
*******************************
palt8b  move.w #$0077,paltb
	bra all_done1
*******************************
palt9b  move.w #$0067,paltb
	bra all_done1
*******************************
palt10b move.w #$0057,paltb
	bra all_done1
*******************************
palt11b move.w #$0047,paltb
	bra all_done1
*******************************
palt12b move.w #$0037,paltb
	bra all_done1
*******************************
palt13b move.w #$0027,paltb
	bra all_done1
*******************************
palt14b move.w #$0017,paltb
	bra all_done1
*******************************
palt15b move.w #$0007,paltb
*******************************
all_done1
************************************************
* voice 3				       *
************************************************
* work out volume
	cmp.b #0,d2
	beq   palt1c
	cmp.b #1,d2
	beq   palt2c
	cmp.b #2,d2
	beq   palt3c
	cmp.b #3,d2
	beq   palt4c
	cmp.b #4,d2
	beq   palt5c
	cmp.b #5,d2
	beq   palt6c
	cmp.b #6,d2
	beq   palt7c
	cmp.b #7,d2
	beq   palt8c
	cmp.b #8,d2
	beq   palt9c
	cmp.b #9,d2
	beq   palt10c
	cmp.b #10,d2
	beq   palt11c
	cmp.b #11,d2
	beq   palt12c
	cmp.b #12,d2
	beq   palt13c
	cmp.b #13,d2
	beq   palt14c
	bra   palt15c
*********************************
* change colours below to what you like but only change last 3 number	
*******************************
* change colour in variable
*******************************
palt1c  move.w #$0000,paltc
	bra all_done2
*******************************
palt2c  move.w #$0101,paltc
	bra all_done2
*******************************
palt3c  move.w #$0202,paltc
	bra all_done2
*******************************
palt4c  move.w #$0303,paltc
	bra all_done2
*******************************
palt5c  move.w #$0404,paltc
	bra all_done2
*******************************
palt6c  move.w #$0505,paltc
	bra all_done2
*******************************
palt7c  move.w #$0606,paltc
	bra all_done2
*******************************
palt8c  move.w #$0707,paltc
	bra all_done2
*******************************
palt9c  move.w #$0706,paltc
	bra all_done2
*******************************
palt10c move.w #$0705,paltc
	bra all_done2
*******************************
palt11c move.w #$0704,paltc
	bra all_done2
*******************************
palt12c move.w #$0703,paltc
	bra all_done2
*******************************
palt13c move.w #$0702,paltc
	bra all_done2
*******************************
palt14c move.w #$0701,paltc
	bra all_done2
*******************************
palt15c move.w #$0700,paltc
*******************************
all_done2
****************************************************
	move.l screen,a0           *FIRST VU METER
	add.l #230*160,a0
	move.w #34,d3
	ADD.L #6,A0
	mulu #2,d0
clear1	clr.w  (a0)
	clr.w  32(a0)
	clr.w  104(a0)
	CLR.W  136(A0)
	sub.l #160,a0
	dbra d3,clear1
***************************************************
	add.l #34*160,a0
*************************************
	move.w #$ffff,d3
	add.b #1,d0
vu1     move.w d3,(a0)
	move.w d3,32(a0)
	move.w d3,104(a0)
	move.w d3,136(a0)
	sub.l #160,a0
	sub.b #1,d0
	cmp.b  #0,d0
	bne vu1
************************************************
	move.l screen,a0        * SECOND VU METER
	add.l #230*160,a0
	ADD.L #6,A0
	move.w #34,d3
	mulu #2,d1
clear2	clr.w  8(a0)
	clr.w  40(a0)
	clr.w  112(a0)
	CLR.W  144(A0)
	sub.l #160,a0
	dbra d3,clear2
***************************************************
	add.l #34*160,a0
*************************************
	move.w #$ffff,d3
	add.b #1,d1
vu2     move.w d3,8(a0)
	move.w d3,40(a0)
	move.w d3,112(a0)
	move.w d3,144(a0)
	sub.l #160,a0
	sub.b #1,d1
	cmp.b  #0,d1
	bne vu2
************************************************
	move.l screen,a0            *THRID VU METER
	add.l #230*160,a0
	move.w #34,d3
	ADD.L #6,A0
	mulu #2,d2
clear3	clr.w  16(a0)
	clr.w  48(a0)
	clr.w  120(a0)
	CLR.W  152(A0)
	sub.l #160,a0
	dbra d3,clear3
***************************************************
	add.l #34*160,a0
*************************************
	move.w #$ffff,d3
	add.b #1,d2
vu3     move.w d3,16(a0)
	move.w d3,48(a0)
	move.w d3,120(a0)
	move.w d3,152(a0)
	sub.l #160,a0
	sub.b #1,d2
	cmp.b  #0,d2
	bne vu3 
**********************************************
* check keyboard			     *
**********************************************
	cmp.b	#$39,$fffc02    check keyboard (scancodes)
        beq quit                yes
**********************************************
* end of vbi rout			     *
**********************************************
.LOOP	BTST	#1,$FFFC00      used to stop pressing a key fucking 
	BEQ	.LOOP		up the rasters
	MOVE.B	#$11,$FFFC02
**********************************************
	movem.l (sp)+,d0-d7/a0-a6
new4b		
		jmp     $12345678	pass ontrol to OLD vb vector
******************************************
* hbl					 *
******************************************
* colour bars vu meter 1
bar1
	 clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #9,(a1)	*CHANGE COLOUR PALETTE
	move.l  #clearbars1,$120
	move.b  #8,$fffffa1b.w
loop7	move.b  (a1),d0
wait7	cmp.b   (a1),d0
	beq     wait7
	move.w  palta,$ff8240
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte
**********************************************
* palette 1 back
clearbars1
        clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #9,(a1)	*CHANGE COLOUR PALETTE
	move.l  #bars2,$120
	move.b  #8,$fffffa1b.w
	movem.l	palette1,d1-d7/a0
loop8	move.b  (a1),d0
wait8	cmp.b   (a1),d0
	beq     wait8
	movem.l	d1-d7/a0,$ff8240
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte
******************************************************
* colour bars vu meter 2
bars2
	 clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #9,(a1)	*CHANGE COLOUR PALETTE
	move.l  #clearbars2,$120
	move.b  #8,$fffffa1b.w
loop9	move.b  (a1),d0
wait9	cmp.b   (a1),d0
	beq     wait9
	move.w  paltb,$ff8240
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte
***********************************************************
* palette 1 back
clearbars2        clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #9,(a1)	*CHANGE COLOUR PALETTE
	move.l  #bars3,$120
	move.b  #8,$fffffa1b.w
	movem.l	palette1,d1-d7/a0
loop10	move.b  (a1),d0
wait10	cmp.b   (a1),d0
	beq     wait10
	movem.l	d1-d7/a0,$ff8240
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte
*********************************************************
* colour bars vu meter 3
bars3
	 clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #9,(a1)	*CHANGE COLOUR PALETTE
	move.l  #clearbars3,$120
	move.b  #8,$fffffa1b.w
loop11	move.b  (a1),d0
wait11	cmp.b   (a1),d0
	beq     wait11
	move.w  paltc,$ff8240
.LOOP	BTST	#1,$FFFC00      used to stop pressing a key fucking 
	BEQ	.LOOP		up the rasters
	MOVE.B	#$13,$FFFC02
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte
*********************************************************
* palette 1 back
clearbars3        clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #27,(a1)	*CHANGE COLOUR PALETTE
	move.l  #newpal,$120
	move.b  #8,$fffffa1b.w
	movem.l	palette1,d1-d7/a0
loop12	move.b  (a1),d0
wait12	cmp.b   (a1),d0
	beq     wait12
	movem.l	d1-d7/a0,$ff8240
.LOOP	BTST	#1,$FFFC00      used to stop pressing a key fucking 
	BEQ	.LOOP		up the rasters
	MOVE.B	#$13,$FFFC02
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte
*****************************************************
newpal  clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #117,(a1)	*CHANGE COLOUR PALETTE
	move.l  #newtb3,$120
	move.b  #8,$fffffa1b.w
	movem.l	palette2,d1-d7/a0
loop1	move.b  (a1),d0
wait1	cmp.b   (a1),d0
	beq     wait1
	movem.l	d1-d7/a0,$ff8240
.LOOP	BTST	#1,$FFFC00      used to stop pressing a key fucking 
	BEQ	.LOOP		up the rasters
	MOVE.B	#$13,$FFFC02
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte
**********************************************************
newtb3	clr.b   $fffffa1b.w	timer stop
	movem.l d0-d7/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #29,(a1)	kill border at line 228 this must add up to 228 so if you change the one above change this so it = 228
	move.l  #killborder,$120
	move.b  #8,$fffffa1b.w
	movem.l	palette3,d1-d7/a0
loop6	move.b  (a1),d0
wait6	cmp.b   (a1),d0
	beq     wait6
	movem.l	d1-d7/a0,$ff8240
; now we have the third group of colors, again random :below change number of scan lines of rasters
*	move.w  #28-1,d1	number of scanlines wanted
*	MOVE.L  #PAL3,A2
*	move.l  #pal1,a0	where colors are stored
*loop3	move.b  (a1),d0
*wait3	cmp.b   (a1),d0
*	beq     wait3
*	move.w  (a0)+,$ff8240	
*	MOVE.W  (A2)+,$FF8250
*	dbra    d1,loop3
	movem.l (sp)+,d0-d7/a0-a1
	bclr    #0,$fffffa0f.w	end of interrupt
	rte
********************************************************************
killborder
	clr.b   $fffffa1b.w	timer stop
	movem.l d0-d1/a0-a1,-(sp)
	move.w  #$fa21,a1
	move.b  #140,(a1)	changing this number had little effect
	move.b  #8,$fffffa1b.w	this line is essential
***********************
* REMOVE BOTTOM BORDER*
***********************
	move.b  (a1),d0
wait4	cmp.b   (a1),d0		wait last scanline
	beq     wait4	
	clr.b   $ffff820a.w	60 Hz
	moveq   #4,d0
nopi2	nop			wait a while
	dbf     d0,nopi2
	move.b  #2,$ffff820a.w	50 Hz
*	move.w  #40-1,d1	number of scanlines wanted
*	MOVE.L  #PAL2,A2
*	move.l  #pal4,a0	where colors are stored
*loop5	move.b  (a1),d0
*wait5	cmp.b   (a1),d0
*	beq     wait5
*	move.l  (a0)+,$ff8240	
*	MOVE.l  (A2)+,$FF8250
*	dbra    d1,loop5
	movem.l (sp)+,d0-d1/a0-a1 
bill      
	bclr    #0,$fffffa0f.w	end of interrupt
		stop		#$2300			;stabalizes top border
	rte			final exit 

*------------------------------------------



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


* THIS JUMPS TO RESETA WHEN THE RESET BUTTON IS PRESSED *
* (Damon Barwin)
*add or remove * in front of the two move.l'sto disable the reset screen
reset
	move.l	#$31415926,$426	validate reset
	move.l	#reseta,$42a	point to reset routine
	rts

* this is the reset routine
reseta
	move.w	#$2700,sr	disable all interrupts
	clr.l	$426		disable reset effect
*remove * above if you want to reset the computer after the reset screen or add one if it's not INFRONT of the command above
	bset	#1,$fff820a	50 hz
* COPY a degas picture at a specific address 
	move.l	screen,a1	COPY direct to current screen
	ADD.L           #34,A0
	sub.l	#1*160,a1	hide the palette data
	move.l	screen,a1	load direct to current screen
* copy piccy to screen
	lea             resetpiccy,a0
	sub.l #34,a1
	move.w          #$7d00,d0
put_pic3	move.b          (a0)+,(a1)+
	dbra            d0,put_pic3
**************************************
* set palette
	lea     resetpal,a0
	MOVE.L	(A0),$ff8240
	MOVE.L	4(A0),$ff8244
	MOVE.L	8(A0),$ff8248
	MOVE.L	$10(A0),$ff824c
	MOVE.L	$14(A0),$ff8250
	MOVE.L	$18(A0),$ff8254
	move.l  $1c(a0),$ff8258
	move.l  $1c(a0),$ff825c
stoped  bra stoped
**------------------------------
* message scroller
scroll          
	movem.l d0-d7/a0-a6,-(sp) 
	move.b  half_done,d0
	cmpi.b #0,d0          half done ?
	bne do_half       no
	move.b #11,half_done     do half next time
	movea.l	TEXT_POINT,a0	scroll variable (holds address of text)
	moveq	#0,d0
	move.b	(a0)+,d0
	cmpi.b	#$ff,d0     255?
	beq	WRAP        then go to wrap
DO_IT	move.l	a0,TEXT_POINT
	subi.b	#32,d0     
	lea font,a1
	add.l #34,a1
	cmpi.b  #49,d0       go to 3rd line
	bgt     next_line1    yes
offseter
	cmpi.b  #39,d0      go to 2nd line
	bgt     next_line2      yes
offseter1
	cmpi.b  #29,d0       go to 3rd line
	bgt     next_line3    yes
offseter2
	cmpi.b  #19,d0      go to 2nd line
	bgt     next_line4      yes
offseter3
	cmpi.b  #9,d0       go to 3rd line
	bgt     next_line5    yes
	clr.l d1
offseter4
	MULU    #16,D0       make into  screen offset 
	move.l  d0,half_set
	move.l  d1,half_off
	add.l d1,a1
	ADD.L D0,A1

* a1 new data pointer
scroller moveA.l          screen,a0
	ADD.L #230*160,A0
****************************************
	rept 30
	movem.l 8(a0),d0-d7/a2-a5
	movem.l d0-d7/a2-a5,(a0)
	movem.l 56(a0),d0-d7/a2-a6
	movem.l d0-d7/a2-a6,48(a0)
	movem.l 108(a0),d0-d7/a2-a6
	movem.l d0-d7/a2-a6,100(a0)
	movem.l (a1),d0-d1
	movem.l d0-d1,152(A0)
	add.l #160,a0
	ADD.L #160,A1
	endr
	movem.l (sp)+,d0-d7/a0-a6 
	rts                              *END OF SCROLLER CODE
WRAP    LEA TEXT,A0            move text start to text_point
	MOVE.B #32,D0
	BRA DO_IT
next_line1  
	move.l #160*155,d1       set to line 6
	bra offseter4
next_line2  
	move.l #160*124,d1       set to line 5
	bra offseter4
next_line3  
	move.l #160*93,d1       set to line 4
	bra offseter4
next_line4  
	move.l #160*62,d1       set to line 3
	bra offseter4
next_line5   
	move.l #160*31,d1       set to line 2
	bra offseter4
******
do_half
	clr.b  half_done
	move.l   half_set,d0
	move.l   half_off,d1
	LEA font,A1       where font is stored
	ADD.L #34,A1        jump passed pal info
	add.l d0,a1
	add.l #8,a1
	add.l d1,a1
	bra scroller
**********************************************
* section data                               *
**********************************************
section data
* TEXT FOR MAIN SCROLLER CHANGE AS NEEDED
* speed: 1 to 4 (slow-fast)  5 is stop    255 is end
* WAVEFORMS 6 TO 15 
* LEAVE ABOUT 20 SPACES WHEN YOU CHANGE WAVEFORM
TEXT
	DC.B    " THIS IS NOTHING PERSONAL WITH MENU 9 .............. THIS IS   D  .  V  .  D  TALKIN' NOW SO LISTEN UP !!!"
	DC.B    "     THIS IS A HISTORICAL MOMENT FOR N.P   BECAUSE IT IS A 32 BY 32 FONT AND A BRAND NEW LOGO !!!!!!!!         "
	DC.B    "I HAVE SOME PERSONAL GREETZ TO GIVE OUT NOW SO KEEP ON LISTENING           *WILD ONE*           *DESTROYA*         *STEILER*          *SMILEY RILEY*              *SONNY JIM*             *LAMPWICK*           "
	DC.B    "  *PAUL R*             *PETER C*            *JONNY B*           *HIPPO*            *MATT S*              *CHRIS*                         NOW FOR THE USUAL GREETZ                 AUTOMATION    " 
	DC.B    "MEDWAY BOYS     EMPIRE       WYRD MAJIK     NEW ORDER     LOST BOYS      POMPEY PIRATES     SOL     ULM      UNION                AND MANY MANY MORE WONDERFUL ST *LAMERS*   OPPPPPSSSSSSS   I MEAN  LOVERS !!!!!!!" 
	DC.B    "    FUTURE PLANS FOR N.P MENU'S :-          MENU 10 WILL BE FANDABULOUS WITH A MESSAGE FROM ALL THE MEMBERS     *DVD*     *WILD ONE*     *DESTROYA*    AND MAYBE ANOTHER !!!!!            WE ARE HOPING TO START "
	DC.B    "HACKING SOON AND 1,2 OR 3 JOBS ON OUR MENU'S SO THERES NO MESSIN' WITH THE DESKTOP !!!!!!!          THERE WILL BE A HIDDEN DOC ON THIS MENU SO LOOK OUT FOR IT...........             THIS IS PROBABLY THE BIGGEST AND THE BEST MENU SO FAR"  "
	DC.B    " AND IT ALL COMES FROM NOTHING PERSONAL 'THE MENUS OF THE FUTURE'             WE ARE HOPING TO GET A NEW MEMBER SOON, WHO CAN CODE WELL SO KEEP YA FINGERS CROSSED             IF YOU DO UNCOVER MY HIDDEN DOC THEN PLEASE GIVE ME A BELL "
	DC.B    "AND YOU COULD BE PART OF NOTHING PERSONAL ...........                "
	dc.b	$ff			end
	even
***************************************************************
**************************************************************
incbins
***************************************************************
font		incbin     "A:\redzone.pi1"       *FONT FILE
****
tune_no         dc.l  1 	    *TUNE NUMBER THAT IS PLAYED
****
music           incbin  a:\MUS6              *MUSIC FILE
****
piccy	incbin "A:\WILL.pi1"     change to your piccys name
****
bottompiccy  incbin "a:\brother.pi1"    *BOTTOM BORDER PICCY
****
resetpiccy   incbin  "a:\a.pi1"          *reset piccy
*****************************************************************
*raster bars data       					*
* ONLY CHANGE LAST THREE NUMBERS AND LEAVE THE FIRST AS 0      	*
* FOR STE 							*
* ALL COLOUR REGS ARE 1 WORD WIDE 				*
* PAL2 AND PAL4 USE LONGWORDS FOR SPEED SO LEAVE THE FIRST AND  *
* FIFTH NUMBERS AS 0						*
******************************************************************
*BACKGROUND IN MAIN SCREEN                                       *
******************************************************************
pal1	
	dc.w    $0000,$0001,$0002,$0003,$0004,$0005,$0006,$0007
	dc.w    $0107,$0207,$0307,$0407,$0507,$0607,$0707,$0706
	dc.w    $0705,$0704,$0703,$0702,$0701,$0700,$0710,$0720
	dc.w    $0730,$0740,$0750,$0760
*********************************************************************
* SCROLER AND VU METER IN BOTTOM BORDER                             *
*********************************************************************
PAL2 
        dc.l    $00770707,$00670717,$00570727,$00470737,$00270747,$00170757,$00070777,$01070777
        dc.l    $02070777,$03070777,$04070777,$05070777,$06070777,$07070777,$07060677,$07050577
        dc.l    $07040477,$07030377,$07020277,$07010177,$07000077,$07100077,$07200077,$07300077
        dc.l    $07400077,$07500077,$07600077,$07700077,$06700077,$05700077,$04700077,$03700077
        dc.l    $02700070,$01700070,$00700070,$00600070,$00500070,$00400070,$00300070,$00200070
**********************************************************************
* VU METERS IN MAIN SCREEN                                           *
**********************************************************************
PAL3            
	DC.W    $0000,$0100,$0200,$0300,$0400,$0500,$0600,$0700
	DC.W    $0710,$0720,$0730,$0740,$0750,$0760,$0770,$0670
	DC.W    $0570,$0470,$0370,$0270,$0170,$0070,$0071,$0072
	DC.W    $0073,$0074,$0075,$0076
*********************************************************************
*BACK GROUND IN BOTTOM BORDER
pal4    dc.l    $07700770,$06700670,$05700570,$04700470,$03700370,$02700270,$01700170,$00700070
        dc.l    $01710770,$02720770,$03730770,$04740770,$05750770,$06760770,$07770670,$06770570
        dc.l    $05770470,$04770370,$03770270,$02770170,$01770070,$00770070,$00670070,$00660070
        dc.l    $00560070,$00550070,$00450070,$00440070,$00340070,$00330070,$00230070,$00220070
        dc.l    $00120070,$00110070,$00010070,$00000070,$00000070,$00000070,$00000070,$00000070
********************************************************************
*above colours used in raster  bars change them to what you like   *
********************************************************************
********************************************************************
* RESET SCROLLTEXT						   *
********************************************************************
text_9	DC.B "    YOU PRESSED RESET                             STRANGE PERSON !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!           "
	dc.b	$fe		end of reset message
	even

******************************************************************
* PROGRAM VARIABLES DO NOT CHANGE !!!!!!!!!!!			 *
******************************************************************
old_screen_pos  dc.l 	0       
oldrez	dc.w    0          OLD SCREEN REZ
oldscr	dc.l    0          OLD SCREEN POINTER
savereg	dc.l    0
mon	dc.b    8          TURN MOUSE ON
moff	dc.b    18         TURN MOUSE OFF
stopm_d		dc.b		7,$FF,6,0,8,0,9,0,$A,0   STOP MUSIC
	even
old4	dc.l    0           OLD VBI POINTER
oldtb	dc.l    0           OLD HBL POINTER
physbase	dc.l	0   PHYSBASE
screen_0	dc.l	0   
********************************
* section bss		       *
********************************
section bss
half_set		ds.l	1      FOR SCROLLER
half_off                ds.l    1
half_done		ds.w	1      FOR SCROLLER
TEXT_POINT	ds.l	6      TEXT POINTER
oldpal	ds.w    16              OLD COLOUR PALETTE
palette1	ds.w	32     NEW PALETTE 1
palette2	ds.w	32     NEW PALETTE 2
palette3        ds.w    32     NEW PALETTE 3
resetpal        ds.w    32     reset palette
wave            ds.l    50     WAVEFORM POINTER
palta           ds.w    1      colour vu meter 1 
paltb           ds.w    1      colour vu meter 2 
paltc           ds.w    1      colour vu meter 3 