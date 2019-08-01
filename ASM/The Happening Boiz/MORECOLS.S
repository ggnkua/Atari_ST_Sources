
        bra     start

pic_name        dc.b "\data\happ.pi1",0
font_name       dc.b "\data\happen.fon",0
                even

start   clr.l   -(sp)           supervisor mode on
        move.w  #$20,-(sp)
        trap    #1
        move.l  d0,savereg
        
        move.l  $44e,a0         current physbase
        sub.l   #$2000,a0       go back a bit because our 50-60 hz...
        move.l  a0,physbase     ..trick would push us into rom

        lea     stack,a7        stack needed

        move.l  #moff,-(sp)     mouse off
        clr.w   -(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        dc.w    $a00a

        move.w  #4,-(sp)                get resolution        
        trap    #14
        addq.l  #2,sp
        move.w  d0,oldrez               and save it
        move.l  $44e,oldscr
        move.l  physbase,screen

        movem.l $ffff8240.w,d0-d7       save colors...
        movem.l d0-d7,oldpal            ..quickly

        move.w  #0,-(sp)                set low res
        move.l  screen(pc),-(sp)        phys    
        move.l  screen(pc),-(sp)        log
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

*       bra     hi                      avoid loading degas pic

* load a degas picture at a specific address 
        move.w  #0,-(sp)
        move.l  #pic_name,-(sp) open file       
        move.w  #$3D,-(sp)
        trap    #1
        addq.l  #8,sp
        move.w  d0,handle

        move.l  screen,d0       load direct to current screen
        sub.l   #34,d0
        sub.l   #1*160,d0       hide the palette data
        move.l  d0,-(sp) 
        move.l  #34,-(A7)       read it
        move.w  handle,-(A7)
        move.w  #$3F,-(A7)
        trap    #1
        adda.l  #12,A7

        move.l  screen,d0       load direct to current screen
        add.l   #0*160,d0      push the picture 40 lines DOWN
;                               inside the bottom border!
        move.l  d0,-(sp) 
        move.l  #32000,-(A7)    read picture
        move.w  handle,-(A7)
        move.w  #$3F,-(A7)
        trap    #1
        adda.l  #12,A7

        move.w  handle,-(SP)
        move.w  #$3E,-(SP)
        trap    #1              close file
        addq.l  #4,SP

        move.l  screen,a0
        sub.l   #192,a0         locate palette's origin
        lea     palette,a1      destination
        move.l  #16-1,d0
paloop  move.w  (a0)+,(a1)+     save it
        dbra    d0,paloop

        move.l  #font_name,-(A7)        open fontish c/set
        move.w  #$3D,-(A7)
        trap    #1
        move.w  d0,handle
        move.l  #font,-(A7)     load it here (end of this prog)
        move.l  #1953,-(A7)     1953 bytes
        move.w  handle,-(A7)
        move.w  #$3f,-(a7)      read file
        trap    #1
        adda.l  #$c,A7  
        move.w  handle,-(a7)
        move.w  #$3e,-(a7)
        trap    #1              close file
        addq.l  #4,a7 

        move.l  screen,d5
        add.l   #103*160+158,d5  line of scroll number 1
        move.l  d5,line_one     
        move.w  #1,speed
        move.l  #text_1,text_address    budgie message in scroll variable

        move.l  #scroll,a5      enable scroll interrupt 
        bsr     enable_vbi



*-----------------------------------------------

        bsr     hblon           enable my interrupts#
	MOVE.L #VBI,$4de
*------------------------------------------------
*------------------------------------------------
get     
        bsr     getkey
        cmp.b   #$61,d0         esc
        beq     quit

        bra     get
*-------------------------------------------------
getkey  
        move.w  #$ff,-(sp)      
        move.w  #6,-(sp)
        trap    #1
        addq.l  #4,sp
        swap    d0
        rts
*------------------------------------------------
quit
        move.l  #scroll,a5      cut out message scroll
        bsr     disable_vbi



        bsr     hbloff          disable MFP interrupts

        movem.l oldpal,d0-d7    old colors back
        movem.l d0-d7,$ffff8240.w
        move.w  oldrez,-(sp)    old resolution back
        move.l  oldscr,-(sp)
        move.l  oldscr,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        move.l  #mon,-(sp)      mouse on
        clr.w   -(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        dc.w    $a009

        move.l  savereg,-(sp)   leave supervisor
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp

        clr.w   -(sp)           quit
        trap    #1



*------------------------------------------------
        move.l  #scroll,a5      enable scroll interrupt 
        bsr     disable_vbi
        bsr     hbloff          disable interrupts

        movem.l oldpal,d0-d7    old colors back
        movem.l d0-d7,$ffff8240.w
        move.w  oldrez,-(sp)    old resolution back
        move.l  oldscr,-(sp)
        move.l  oldscr,-(sp)
        move.w  #5,-(sp)
        trap    #14
        add.l   #12,sp

        move.l  #mon,-(sp)      mouse on
        clr.w   -(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp
        dc.w    $a009

        move.l  savereg,-(sp)   leave supervisor
        move.w  #$20,-(sp)
        trap    #1
        addq.l  #6,sp

        clr.w   -(sp)           sayonara!
        trap    #1

oldrez:         dc.w    0
oldscr:         dc.l    0
savereg:        dc.l    0
screen:         dc.l    0
oldpal:         ds.w    16
mon:            dc.b    $08
moff:           dc.b    $12

                even

*-------------------------------------------------------

; see the article for comments about these addresses

hblon   move.l  $120,oldtb      save old timer B vector
        move.l  $70,old4        save old vb vector
        move.l  $70,new4b+2     now, new vb routine will jump to
;                               old one afterwards
        move.b  $fffffa07,old07 timer B enable
        move.b  $fffffa09,old09 timer C enable
        move.b  $fffffa0f,old0f timer B in-service
        move.b  $fffffa11,old11 timer C in-service
        move.b  $fffffa1b,old1b timer B control
        and.b   #$df,$fffa09    disable timer C
        and.b   #$fe,$fffa07    disable timer B 
        move.l  #newtb1,$120    new timer B vector
        move.l  #new4,$70       new vb vector
        or.b    #1,$fffffa07    enable timer B
        or.b    #1,$fffffa13    set timer B mask
        rts

hbloff  move.w  sr,-(sp)
        move.w  #$2700,sr       cut out all interrupts
        move.b  old07(pc),$fffffa07 restore all old vectors
        move.b  old09(pc),$fffffa09
        move.b  old0f(pc),$fffffa0f
        move.b  old11(pc),$fffffa11
        move.b  old1b(pc),$fffffa1b
        move.l  oldtb,$120
        move.l  old4,$70
        move.w  (sp)+,sr
        rts

old4:           dc.l    0
oldtb:          dc.l    0
old07:          dc.b    0
old09:          dc.b    0
old0f:          dc.b    0
old11:          dc.b    0
old1b:          dc.b    0

        even

; This is the new VBL handler
new4    clr.b   $fffffa1b.w     disable timer B
        move.b  #1,$fffffa21   first raster 36 lines away
        move.b  #8,$fffffa1b    enable timer B
        move.w  #$000,$ff8240   initial border (black)
        move.l  #newtb1,$120    timer B vector
new4b   jmp     $12345678       pass ontrol to OLD vb vector

newtb1  clr.b   $fffffa1b.w     timer stop
        movem.l d0-d7/a0-a1,-(sp)  save from corruption
        move.w  #$fa21,a1       timer B data register (ie scanline!)
        move.b  #40,(a1)        next interrupt at 22+36= line 58
        move.l  #newtb2,$120    set new timer B vector
        move.b  #8,$fffffa1b.w  allow timer B again

        moveq.w #48-1,d2        number of colors in table
; change above figure to 48 and we'll get 48 lines with different
; colors BUT, next interrupt further down will be unstable..
        move.l  #pal1,a0        pal1: color table
; I am now randomly modifying A0 to point ANYWHERE in memory
        move.l  $466,d3         random value
        lsl.l   #1,d3           make it even
        move.l  #pal3,a0           point to it
        add.l   #100,a0          add 22 words

; we can now clearly see these 22 lines grouped at the top of picture
; from line 36 onwards (22 different random colors)

loop    move.b  (a1),d0         get value of timer B
wait    cmp.b   (a1),d0         wait one scanline !
        beq     wait
        move.w  -(a0),$ff8240   use those randoms colors (backwards)

;       move.w  (a0)+,d1
;       move.w  d1,$ff8240      set colors
;       move.w  d1,$ff8242
;       move.w  d1,$ff8244
;       move.w  d1,$ff8246
;       move.w  d1,$ff8248
;       move.w  d1,$ff824a
;       move.w  d1,$ff824c
;       move.w  d1,$ff824e
        dbra    d2,loop

        movem.l palette,d1-d7/a0
loopx   move.b  (a1),d0         more waiting for...
waitx   cmp.b   (a1),d0         ... next scanline
        beq     waitx
        movem.l d1-d7/a0,$ff8240
                
        movem.l (sp)+,d0-d7/a0-a1
        bclr    #0,$fffffa0f.w  end of interrupt
        rte

newtb2  clr.b   $fffffa1b.w     timer stop
        movem.l d0-d7/a0-a1,-(sp)
        move.w  #$fa21,a1
        move.b  #76,(a1)        next interrupt at 22+36+76= line 134
        move.l  #newtb3,$120
        move.b  #8,$fffffa1b.w

; now follows the second lot of lines from location 58 to 80
        move.w  #50-1,d1        raster is 22 scanlines deep
        move.l  #pal3,d2         get a random number
        lsl.l   #1,d2           make sure it's even
        move.l  #pal3,a0           that's where we'll get our colors from!
loop2   move.b  (a1),d0
wait2   cmp.b   (a1),d0         see if scanline has moved on
        beq     wait2
        move.w  (a0)+,$ff8240   now use those totally random colors
        dbra    d1,loop2
*--------------------------


        movem.l palette,d1-d7/a0        restore original palette
        move.b  (a1),d0
waity   cmp.b   (a1),d0
        beq     waity
        movem.l d1-d7/a0,$ff8240
                
        movem.l (sp)+,d0-d7/a0-a1
        bclr    #0,$fffffa0f.w  end of interrupt
        rte

newtb3  clr.b   $fffffa1b.w     timer stop
        movem.l d0-d7/a0-a1,-(sp)
        move.w  #$fa21,a1
        move.b  #64,(a1)        next interrupt 134+64=198 (kill border)
; the above figure is critical. It must add up to line 198
; less and bottom border doesn't open. More and we go over the top
        move.l  #killborder,$120
        move.b  #8,$fffffa1b.w

; now we have the third group of colors, again random
        move.w  #21-1,d1        number of scanlines wanted
        move.l  #pal2,a0        where colors are stored
loop3   move.b  (a1),d0
wait3   cmp.b   (a1),d0
        beq     wait3
        move.w  (a0)+,$ff8242           the Budgie logo this time
        dbra    d1,loop3

        movem.l palette,d1-d7/a0        again restore original palette
        move.b  (a1),d0
waitz   cmp.b   (a1),d0
        beq     waitz
        movem.l d1-d7/a0,$ff8240
                
        movem.l (sp)+,d0-d7/a0-a1
        bclr    #0,$fffffa0f.w  end of interrupt
        rte

killborder
        clr.b   $fffffa1b.w     timer stop
*       bra     bill            jumping to bill will skip the 50-60 hz bit
        movem.l d0-d1/a0-a1,-(sp)
        move.w  #$fa21,a1
        move.b  #0,(a1) changing this number had little effect
        move.b  #8,$fffffa1b.w  this line is essential

        move.b  (a1),d0
wait4   cmp.b   (a1),d0         wait last scanline
        beq     wait4           
        clr.b   $ffff820a.w     60 Hz
        moveq   #4,d0
nopi2   nop                     wait a while
        dbf     d0,nopi2
        move.b  #2,$ffff820a.w  50 Hz
        movem.l (sp)+,d0-d1/a0-a1 
bill      
        bclr    #0,$fffffa0f.w  end of interrupt
        rte                     final exit 

*------------------------------------------

pal1    dc.w    $100,$200,$300,$400,$500,$600,$700,$701
        dc.w    $702,$703,$704,$705,$706,$707,$717,$727
        dc.w    $737,$747,$757,$767,$777,$767,$757,$747
        dc.w    $001,$002,$003,$004,$005,$006,$007,$107
        dc.w    $207,$307,$407,$507,$607,$707,$717,$727
        dc.w    $737,$747,$757,$767,$777,$776,$775,$774        
pal2    dc.w    $010,$020,$030,$040,$050,$060,$070,$071
        dc.w    $072,$073,$074,$075,$076,$077,$177,$277
        dc.w    $377,$477,$577,$677,$777,$666,$555,$444
pal3    dc.w    $001,$002,$003,$004,$005,$006,$007,$107
        dc.w    $207,$307,$407,$507,$607,$707,$706,$705
        dc.w    $704,$703,$702,$701,$700,$710,$720,$730
        dc.w    $740,$750,$760,$770,$670,$570,$470,$370
        dc.w    $270,$170,$070,$060,$050,$040,$030,$020
        dc.w    $010,$000,$001,$002,$003,$004,$005,$006
        
palette         ds.w    32
                ds.w    310

stack           dc.l    0
physbase        dc.l    0
screen_0        dc.l    0
handle          dc.w    0

        even
*----------------
*       SET a Sequence of VBI routines  [ C.Maertens ] 20/9/87
* Each routine has to be enabled or disabled separately
* Address of routine expected in A5
* first available slot is usually the second one, first being gem
* move.l #myroutine,$4d2 also does the same job
* see example of TWO vbi's at once in Operation Angelica
enable_vbi
        movem.l a0-a5,-(sp)
        move.l  $456,a0
enab1   tst.l   (a0)            is is nought? (free)
        beq     enab2
        adda.l  #4,a0
        bra     enab1
enab2   move.l  a5,(a0)         slot in this routine
        movem.l (sp)+,a0-a5
        rts
*------------
disable_vbi
        movem.l d0/a0-a5,-(sp)  a5 holds address of routine
        move.l  $456,a0
disab1  cmp.l   (a0),a5         contents of $456 same as routine?
        beq     disab2
disab3  adda.w  #4,a0           try next one
        bra     disab1
disab2  move.l  #0,(a0)         switch it off
        movem.l (sp)+,d0/a0-a5
        rts
*---------------------------
* message scroller ONE
scroll
        tst.w   vvar1
        bne     tscr18
        cmpi.w  #16,vvar2
        bls.s   tscr6
        clr.w   vvar2
tscr3   movea.l text_address,a0 scroll variable (holds address of text)
        moveq   #0,d0
        move.b  (a0)+,d0
        cmpi.b  #$ff,d0         end of main message?
        beq     tscr11
     
tscr4   move.l  a0,text_address
        cmp.b   #$20,d0
        ble     tscr12
tscr5   subi.b  #$20,d0
        lea     font,a1         where font is loaded
        lsl.l   #5,d0
        adda.l  d0,a1
        lea     workspace,a2
        move.l  (a1)+,(a2)+
        move.l  (a1)+,(a2)+
        move.l  (a1)+,(a2)+
        move.l  (a1)+,(a2)+
        move.l  (a1)+,(a2)+
        move.l  (a1)+,(a2)+
        move.l  (a1)+,(a2)+
        move.l  (a1)+,(a2)+
tscr6   move.w  speed,d0
tscr7   
        move.l  screen,d7
        add.l   #128*160,d7             line of scroll number 2
        move.l  d7,old_screen_pos
        move.l  d7,a2  
        lea     workspace,a1
        moveq   #15,d1
tscr8   lsl     (a1)+
        roxl    $98(a2)
        roxl    $90(a2)
        roxl    $88(a2)
        roxl    $80(a2)
        roxl    $78(a2)
        roxl    $70(a2)
        roxl    $68(a2)
        roxl    $60(a2)
        roxl    $58(a2)
        roxl    $50(a2)
        roxl    $48(a2)
        roxl    $40(a2)
        roxl    $38(a2)
        roxl    $30(a2)
        roxl    $28(a2)
        roxl    $20(a2)
        roxl    $18(a2)
        roxl    $10(a2)
        roxl    8(a2)
        roxl    (a2)
        adda.l  #$a0,a2
        dbf     d1,tscr8
        addq.w  #1,vvar2
        dbf     d0,tscr7
tscr9   move.l  old_screen_pos,a0 
        movea.l line_one,a1     the message at the top
	adda.l  #2,a1
        moveq   #$f,d0
tscr10  
        move.w  (a0),(a1)
        move.w  8(a0),8(a1)
        move.w  $10(a0),$10(a1)
        move.w  $18(a0),$18(a1)
        move.w  $20(a0),$20(a1)
        move.w  $28(a0),$28(a1)
        move.w  $30(a0),$30(a1)
        move.w  $38(a0),$38(a1)
        move.w  $40(a0),$40(a1)
        move.w  $48(a0),$48(a1)
        move.w  $50(a0),$50(a1)
        move.w  $58(a0),$58(a1)
        move.w  $60(a0),$60(a1)
        move.w  $68(a0),$68(a1)
        move.w  $70(a0),$70(a1)
        move.w  $78(a0),$78(a1)
        move.w  $80(a0),$80(a1)
        move.w  $88(a0),$88(a1)
        move.w  $90(a0),$90(a1)
        move.w  $98(a0),$98(a1)
        adda.l  #$a0,a0
        adda.l  #$a0,a1
        dbf     d0,tscr10
        rts
tscr11  lea     text_1,a0       at end of main message, we come..
        move.b  #32,d0          ..here again
        bra     tscr4

tscr12  cmp.b   #1,d0           speeds 1 slow  4 fast  5 stop
        beq     tscr13
        cmp.b   #2,d0
        beq     tscr14
        cmp.b   #3,d0
        beq     tscr15
        cmp.b   #4,d0
        beq     tscr16
        cmp.b   #5,d0
        beq     tscr17
        bra     tscr5
tscr13  move.w  #0,speed
        bra     tscr3
tscr14  move.w  #1,speed
        bra     tscr3
tscr15  move.w  #2,speed
        bra     tscr3
tscr16  move.w  #5,speed
        bra     tscr3
tscr17  move.w  #50,vvar1
        move.w  #16,vvar2
        bra     tscr18
tscr18  subi.w  #1,vvar1
        bra     tscr9


* TEXT FOR MESSAGE *
* speed: 1 to 4 (slow-fast)  5 is stop    255 is end
text_1  
        dc.b    3," HELLO AND WELCOME TO EDDIES DEMO........ PRODUCED"
	dc.b	3," USING THE ODD ROUTINE FROM GARY WHEATON AND THE SHAPESHIFTERS ( WHAT NICE GUY'S )"
	DC.B	3," I HAVE CREATED THIS DEMO ENTITLED 'MORE COLOURS THAN YOURS' DEMO (TO SHOW IAN I CAN PRODUCE SOMETHING IN 68000 ASWELL."
	DC.B	3," LOOK AT THE TOP, AT LEAST 100 COLOURS !!!!!!, PLUS THE BOIZ LOGO,"
	DC.B	3," AND THE GREEN SCROLLY TEXT !!!!. AND FOR YOUR PLEASURE AND FOR MY EGO "
	DC.B	3," I HAVE ADDED A SHORT TUNE (THE TUNE FROM GALAXIA) WITH SPECTRUM ANALYSER........"
	DC.B	3," NOW HERE ARE THE GREETINGS.... HI TO CAMY, GARY, SIMON AT BUDGIE UK, I MUST ALSO SAY HI TO"
	DC.B	3," MANIKIN, SAMMY JOE AND SPAZ OF THE LOST BOYS ( GITS! HOW COME YOU CAN DO ALL THOSE FLASH DEMOS !!!)"
	DC.B	3," ...WELL.... ITS  8 MINUTES PAST 11 (PM) ON MONDAY 14 MAY 1990 AND I MUST GO TO BED !.....SEE YOU LATER"
	DC.B	3," ..............GONE YET?"
	DC.B	3," ......BYE,BYE.........."
	dc.b 	3," A BOIZ PRODUCTION",5
	DC.B	3,"                 "
	DC.B	3," COPYRIGHT 1990 THE HAPPENING BOIZ AND BUDGIE UK"
	DC.B	3,"                 "
	DC.B	3," ...HERE COMES THE NEWS !!!!"
	dc.b	3,"                       "
        DC.B    255
        even

vvar1           ds.w    1
vvar2           ds.w    1
text_address    ds.l    6
workspace       ds.l    8       temp storage for character
speed           ds.w    1

line_one        ds.l    1
old_screen_pos  dc.l    0
                ds.w    8

font            ds.b    2192    c/set is physically loaded HERE


                ds.w    24      spare


*---------------------------
* star field  (Gary Wheaton / Shapeshifters)



* STARFIELD [Gary Wheaton  October 88 ]
* PLOTTER & GET POINT [ G.Wheaton. ]
* with a dual screen, the problem is unplotting the correct screen
* This routine plots a number of dots (stars) on the screen,
* then replaces those dots with black,
* then moves them about when joystick is moved
* as used in Zenith and Ace invaders

starfield
	MOVE	$FF8240,bcka
	MOVE	#0,$ff8240
	BRA	STARa
*	at this point Gary has a trap call (joy vector)
JOYa	DC.W	0
HJTBa	DC.B	0,0,0,0,1,1,1,0,-1,-1,-1
VJTBa	DC.B	0,-1,1,0,0,-1,1,0,0,-1,1




STARa	MOVE.L 	#HTABa,A4

*	bsr	vtsync
	CLR.L	D0
	MOVE	JOYa,A0
	MOVE.B	(A0),D0
*	move.b	joyport1,d0
	CLR	D4
	CLR	D6
	MOVE.B	HJTBa(PC,D0),D4 		\HZ
	MOVE.B	VJTBa(PC,D0),D6 		\VT

LP0a	MOVE.B 	#0,D5		this must be the unplot
	MOVE 	(A4),D0
	MOVE.B 	91(A4),D1
	BSR	CPLOTTa
	MOVE	180(A4),D0
	CMP.B	#10,D4
	BGT	OKa
	move.b	#2,d4	test only
	CMP.B	#0,D4
	BEQ	OK1a
	BMI	RIGHTa 
	SUB	D0,(A4)
	BPL	OK1a
	MOVE 	#320,(A4)
	MOVE.B	91(A4),D1 
	ROL.B	#1,D1       	RANDOMIZE VERT A BIT
	MOVE.B 	D1,91(A4) 
	BRA	OK1a
RIGHTa	ADD	D0,(A4)
        CMP	#320,(A4)
	BLT OK1a
	CLR (A4)
				*\SHOULD RAND HERE ALSO
OK1a	CMP.B #0,D6
	BEQ OKa
	BPL UPa
	SUB D0,90(A4)
	BPL OK2a 
	MOVE #199,90(A4)
	BRA OK2a

UPa	ADD	D0,90(A4)
	CMP	#200,90(A4)
	BLT	OK2a
	CLR	90(A4)
OK2a
OKa	MOVE.B 	91(A4),D1  	\V
	MOVE 	(A4),D0
	MOVE.B 	D1,D5
	BSR 	CPLOTTa
	SUB.L 	#2,A4
	CMP.L 	#TRa,A4
	BGT 	LP0a
*	dbra	d7,stara
SM	
*	DC.W	$A009       	SHOW MOUSE
	MOVE	bcka,$FF8240
	RTS			exit (bombs quite ok) should call trap
bcka	dc.w 0
*-----------
CPLOTTa 	AND.L 	#15,D5		color
	AND 	#255,D1		x
	CMP 	#320,D0		y
	BLT 	PLOa   
	RTS
PLOa 	MOVE 	D0,D3
	LSR.W 	#3,D0
	MOVE 	D0,D2
	AND 	#7,D3
	AND 	#1,D0
	AND	#65534,D2
	ASL  	#2,D2
	ADD 	D2,D0
	MULU 	#160,D1
	ADD.W 	D1,D0
	MOVE.L	a6,a0 work_screen,a0 $44E,A0 MOVE.L #ZZ,A0 (zz=physbase)
	ADD.L  	D0,A0
	MOVE.L 	A0,A1
	MOVE.B 	TBLa(PC,D3),D0 \GET MASK

  
PLOKa	AND.B 	D0,(A0) \C.0:PL.X,Y
	AND.B 	D0,2(A0) \
	AND.B 	D0,4(A0)
     	AND.B 	D0,6(A0)
	
	CMP.B 	#0,D5   \COLOR TO PLOT
	BNE 	COLOa      \IF>0 THEN PLOT
	RTS           \ELSE RTS 
*---------

*       \COLOR 0 MASKS
tbla     DC.B    127,255-64,223,239
        DC.B    247,251,253,254  
COLOa    EOR.B   #255,D0     \REVERSE BIT PATTN
        ASL     #2,D5         \COL*4
        MOVE.L  #XGOTOa,A0
        ADD.W   D5,A0
        MOVE.L  (A0),A0
        JMP     (A0)           \GOTO COLOR
C15a     OR.B    D0,6(A1)  \COLOR 15
C14a     OR.B    D0,2(A1)
C10a     OR.B    D0,(A1)
C2a      OR.B    D0,4(A1)
        RTS
*----------
C3a      OR.B    D0,4(A1)   
C1a      OR.B    D0,6(A1)   \COLOR 1 ENTRY
        RTS
C5a      OR.B    D0,2(A1)
        OR.B    D0,6(A1)
        RTS
C7a      OR.B    D0,6(A1)
C6a      OR.B    D0,4(A1)
C4a      OR.B    D0,2(A1)
        RTS
C11a     OR.B    D0,4(A1)
C9a      OR.B    D0,6(A1)
C8a      OR.B    D0,(A1)
        RTS
C13a     OR.B    D0,6(A1)
C12a     OR.B    D0,(A1)
        OR.B    D0,2(A1) 
        RTS
C16a     RTS
*         \ JSR TABLE interesting way
XGOTOa   DC.L    C1a,C1a,C2a,C3a,C4a,C5a,C6a,C7a,C8a
        DC.L    C9a,C10a,C11a,C12a,C13a,C14a,C15a,C16a



*       \\\\\23
* across *
TRa
        DC.W    0,20,30,120,319,200,230,290
        DC.W    80,140,134,180,240,290,199
        DC.W    50,95,130,180,234,256,300

        DC.W    8,16,23,30,40,48,54,62,78,83
        DC.W    100,105,115,123,134,140,150
        DC.W    156,160,170,178,1,1

* down *        Y pos of stars
HTABa    DC.W    172

        DC.W    160,170,180,166,172,174,183
        DC.W    185,192,169,163,195,192,147
        dc.w    184,172,173,186,152,167,163,181,191,199,156
        dc.w    171,189,154,154,108,155
        DC.W    169,159,158,169,147,170,176
        DC.W    183,154,165,176,197,168
* speed *
        DC.W    1,4,1,3,1,6,2,1,3,1,4,3,1,1,2
        DC.W    1,5,1,1,1,1,1,1
        DC.W    1,1,2,1,3,2,4,1,4,1,1,3,1,5,6
        DC.W    2,6,1,2,1,1,5,1

*--------------------------
* max.s  oct 89  music from Galaxia
; this is Gary Wheaton music driver
; the tune will play during the vertical blank.
; the slot chosen in the v/b queue is fairly high up
; which means that it is immune from interference
; this code is copyright Gary Wheaton  Aug 1989
; Gary Wheaton and the Shapeshifters are members
; of the Budgie UK group.
; Budgie UK Licenceware: the fairer face of PD

* LA.S   Oct 89

 MOVE.L A7,A5
 MOVE.L 4(A5),A5
 MOVE.L $C(A5),D0
 ADD.L $14(A5),D0
 ADD.L $1C(A5),D0
 ADD.L #$1100,D0
 MOVE.L A5,D1
 ADD.L D0,D1
 AND.L #-2,D1
 MOVE.L D1,A7
 MOVE.L D0,-(SP)
 MOVE.L A5,-(SP)
 MOVE.W D0,-(SP)
 MOVE.W #$4A,-(SP) ; Setblock.
 TRAP #1
 ADD.L #12,SP
;
 CLR.L -(SP)       ; Enter supervisor mode.
 MOVE.W #$20,-(SP) ; Super.
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L D0,SUPER   ; Save old status.

	movem.l	$ff8240,d0-d7 save palette
	movem.l	d0-d7,palette



 move #$700,$ff8240+20

 move.b #7,sl
 move.b #%11111000,sd

 move.l $44e,a0
 add.l #160*200,a0
 move.l a0,screen


	clr.l	$200
	not.l	$200		on/off switch
	bclr 	#0,$484		no keyclick
	bclr 	#1,$484		no repeat key

	dc.w	$a000
	MOVEA.L	8(A0),A0
	CLR.W	(A0)
	DC.W	$A00A		hidemouse



	MOVE.L #VBI,$4de	further down the queue to avoid gem etc.


getrez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,res

setlowrez
	CLR.W	-(A7)		0=low res
	MOVE.L	$44e,-(A7)	-1=ignore physbase
	MOVE.L	$44e,-(A7)	-1=ignore logbase
	MOVE.W	#5,-(A7)
	TRAP	#14		
	LEA	$0C(A7),A7	






res	dc.w 	0
***
skreen	dc.w 0

 move #$5,$ff8240+20

 move.l $44e,a0
 add.l #160*169,a0
 move.l a0,skreen


;1 VIBRATO		256
;2 WARBUP		512
;3 DRUM			768
;4 HOLD			1024
;5 WARBHOLD		1280
;6 WARBDWN		1536
;7 SLIDE UP WITH WARB   1792
;8 SLIDE UP           	2048
;9			2304
;10			2560

e equ 2
J EQU 8
I EQU 4
H EQU 2
T EQU 1
A EQU 2
Q EQU 8
Z EQU 2
f EQU 8
C EQU 1


SL EQU $FF8800
SD EQU $FF8802
 move.b #7,sl
 move.b #%11111000,sd

****


VBI  movem.l d0-d7/a0-a6,-(sp)

	lea	$fffc00,a1		acia
	cmp.b	#$61,2(a1)		undo
	beq	end_it
	cmp.b	#$62,2(a1)		help
	beq	on_off

	lea	$200,a0
	tst.l	(a0)
	beq	quiet

 	move.b #7,sl
	move.b #%11111000,sd		mixer

	LEA TAB,A3
 MOVE.L UPTO,A2
 MOVE CUNT,D3
 MOVE.B 33(A2),D4
SSU SUBQ.W #1,D3
 BPL.S PART1
 MOVE.L #1,PNT0
 MOVE.L #1,PNT1
 MOVE.L #1,PNT2
 MOVE.L #1,PNT3
 MOVE.L #1,PNT4
 MOVE.L #$8000000,SL

 ADD.L #36,a2
 CMP.L #CHAN0,A2
 BNE.S LLA
 LEA DOTH,A2
LLA
 MOVE 34(A2),D3
 MOVE.B 33(A2),D4
PART1
 CLR.B D2
 BTST #1,D4
 BEQ.S W1
 MOVE.L (A2),A1
 MOVE.L 4(A2),A0
 BSR CHAN0
W1 BTST #2,D4
 BEQ.S W2
 MOVE.L 8(A2),A1
 MOVE.L 12(A2),A0
 BSR CHAN0
W2 MOVEQ.B #1,D2
 BTST #3,D4
 BEQ.S W3
 MOVE.L 16(A2),A1
 MOVE.L 20(A2),A0
 BSR CHAN0
W3 BTST #4,D4
 BEQ.S W4
 MOVE.L 24(A2),A1
 MOVE.L 28(A2),A0
 BSR CHAN0
W4 MOVE.L A2,UPTO
 MOVE D3,CUNT

 BSR SHOWBAR

 	movem.l (sp)+,d0-d7/a0-a6 
	rts

end_it
	bclr	#6,$fffa11	acknowledge key press interrupt
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#%11111111,2(a0)
	move.l	#0,$4de		end interrupt
	movem.l (sp)+,d0-d7/a0-a6
 	rts
on_off	bclr	#6,$fffa11	
	not.l	$200		toggle on/off
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#%11111111,2(a0)
	movem.l (sp)+,d0-d7/a0-a6
 	rts

quiet	movem.l (sp)+,d0-d7/a0-a6
	rts
	even




 DC.B " (C) G.WHEATON.  45 GOLDRILL AVE BOLTON. LANCS, U.K. "



UPTO DC.L EE-36
CUNT DC.W 0
 EVEN
;\\RUNNING ORDER SEQUENCE
EE
DOTH

 DC.L PNT4,cow1
 DC.L PNT0,cow1
 DC.L PNT2,null y2
 DC.L PNT3,sdum DRSM
 DC.B 0,%00011100
 DC.W 511

 DC.L PNT4,YI
 DC.L PNT1,cow1
 DC.L PNT2,y2
 DC.L PNT3,DRSM
 DC.B 0,%00011110
 DC.W 511

 DC.L PNT4,Y3
 DC.L PNT1,Y2
 DC.L PNT2,YI
 DC.L PNT3,DRSM
 DC.B 2,%00111110
 DC.W 1023

 DC.L PNT4,Y3
 DC.L PNT1,Y3+4
 DC.L PNT2,Y3+8
 DC.L PNT3,DRMM
 DC.B 1,%00001110
 DC.W 1023

 DC.L PNT4,YI
 DC.L PNT1,YI+8
 DC.L PNT2,YI
 DC.L PNT3,SDUM
 DC.B 2,%00011110
 DC.W 511


 DC.L PNT4,Y2
 DC.L PNT1,Y2+8
 DC.L PNT2,RF2 Y2
 DC.L PNT3,SDUM
 DC.B 2,%00111110
 DC.W 1023

;EE
;DOTH
 DC.L PNT4,T2
 DC.L PNT0,RF2
 DC.L PNT2,t2+4
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 511

 DC.L PNT0,T2
 DC.L PNT4,RF3
 DC.L PNT2,t2d
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 511+511




;part 2
 DC.L PNT4,rigel
 DC.L PNT1,bas
 DC.L PNT2,DRIFT
 DC.L PNT3,DRYM
 DC.B 1,%00111110
 DC.W 127

 DC.L PNT4,raz1
 DC.L PNT1,t2
 DC.L PNT2,t2
 DC.L PNT3,DRSM
 DC.B 1,%00011110
 DC.W 511


 DC.L PNT4,RAZ
 DC.L PNT1,RAZ2
 DC.L PNT2,NULL 
 DC.L PNT3,SDUM
 DC.B 1,%000011110
 DC.W 511

 DC.L PNT1,RAZ  TOM
 DC.L PNT4,TOM  2
 DC.L PNT2,T2
 DC.L PNT3,DRSM
 DC.B 2,%00011110
 DC.W 511


 DC.L PNT4,T2
 DC.L PNT1,no2
 DC.L PNT2,T2
 DC.L PNT3,DRMM
 DC.B 2,%00011110
 DC.W 1023

 DC.L PNT4,BAS
 DC.L PNT1,bas1
 DC.L PNT2,BAS
 DC.L PNT3,DRMM
 DC.B 2,%00011110
 DC.W 127

 DC.L PNT4,DL
 DC.L PNT1,GL
 DC.L PNT2,FL
 DC.L PNT3,DRMM
 DC.B 2,%00001110
 DC.W 255

 DC.L PNT4,YI
 DC.L PNT1,cow
 DC.L PNT2,y2
 DC.L PNT3,DRSM
 DC.B 0,%00011110
 DC.W 2047


 DC.L PNT4,rf2
 DC.L PNT0,cow
 DC.L PNT2,cow+4
 DC.L PNT3,DRSM
 DC.B 0,%00011110
 DC.W 511

CHAN0
;\\\\\\\\\\\\\\\\\\\\\\
 MOVE (A1),D0
 ADD D0,A0
 MOVE.L (A0),D1  ;GET NOTE 0 & DURATION
 MOVE.B 13(A1),D5
 EXT.W D5
 SWAP D1
 ADD D5,D1
 SWAP D1
 CMP #$FFFF,D1
 BNE CON2
 CLR (A1)        ;RESET TO START
 SUB D0,A0
 MOVE.L (A0),D1
CON2
 SUBQ.B #1,3(A1)    ;NP0
 BNE STILLON
 MOVE.L D1,6(A1) ;TMP0  \D1.W IS DURATION
 MOVE.L D1,20(A1);TEMP  HOLD NOTE
 MOVE.B 26(A1),4(A1)   ;VOL0
 MOVE D1,2(A1)   ;NP0  \SET NEW DURATION
 ADDQ.W #4,(A1)        ; & INC POINTER
STILLON
;\\VOLUME
RFF
;\\\\\\\\\EFFECTS\\\\\\\\\\
NV0 
 MOVE.B 2(A1),D0
 CMP.B #4,D0
 BNE DOIT
 ADDQ.B #1,4(A1)
 RTS
DOIT 

DZZ
 MOVE.B #7,SL
 MOVE.B #%11111000,SD
 BRA.S FCC
EFCT

 DC.L FINK,VIB,WARB,DRUM,FINK,WB1,WRP,SLW
 DC.L SLR,HOLD,TWERP,SLR1,inup,HOLDLOW,Half

FCC
 AND.L #15,D0
 ASL #2,D0
 MOVE.L EFCT(PC,D0),A0
 JSR (A0)

MAZ ADDQ.B #1,4(A1)          ;VOL0
 MOVE.B 11(A1),SL
 MOVE.B 21(A1),SD   ;TMP0+1
 MOVE.B 12(A1),SL
 MOVE.B 20(A1),SD   ;TMP0
 CLR D0
 MOVE.B 4(A1),D0
 MOVE.B 10(A1),SL
 MOVE.B 28(A1,D0),D2    ;VOL0
 MOVE.B D2,SD

;----------------BAR CHART SET
 MOVE 20(A1),D1
 AND #255,D1
 LSR #2,D1
 
 CMP #40,D1
 BLT.S DXIT
 SUB #40,D1 
DXIT OR.B D2,(A3,D1)      ;BAR TABLE

FINK RTS

;-------EFFECTS ROUTINES--------
;1-256---DELAYED--VIBRATO-------
VV EOR.B #1,MC
 BEQ.S SDC
VIB CMP.B #8,4(A1)
 BLT SDC
 SUB.B #1,24(A1)
 BNE SDC
 MOVE.B 25(A1),24(A1)
 MOVE 16(A1),D1
 ADD D1,18(A1)
 MOVE 14(A1),D1
 CMP 18(A1),D1
 BLT.S RIST
KJ NEG D1
 CMP 18(A1),D1
 BGT.S RIST
SAZ MOVE 6(A1),D1
 ADD 18(A1),D1
 MOVE D1,20(A1)
SDC RTS
RIST NEG 16(A1)
 BRA.S SAZ
;2-512------WARB DW-----------
WARB
 EOR.B #1,MIN
 BEQ SAX
 SUBQ.B #1,4(A1)
SAX ASL 20(A1)
 CMP #460,20(A1)
 BLT.S PLOP
 MOVE 6(A1),20(A1)
PLOP BRA.S VV
;RTS


;3--768--------DRUM-----------
DRUM 

 SUBQ.B #4,19(A1)
 MOVE.B #7,SL
 MOVE.B #%11011000,SD
 MOVE.B #6,SL
 MOVE.B 19(A1),SD
 MOVE.B #5,SL
 MOVE.B 32(A2),SD
 MOVE.B #4,SL
 MOVE.B 19(A1),D0
 ASL.B #5,D0
 MOVE.B D0,SD
JUNK RTS

;-4--------DRUM OFF

;5--1280--WARB CONSTANT VOLUME
WB1 MOVE.B #5,4(A1)
 BRA.S SAX

;6--1536-----WARB UP---------
WRP 
 MOVE.B #17,4(A1)
SDX LSR 20(A1)
 CMP #35,20(A1)
 BGT PLAP
 MOVE 6(A1),20(A1)
PLAP BRA VV ;RTS

;7--1792---SLIDE-UP--WARBLE
SLW CMP.B #9,4(A1)
 BLT.S WRP
 ADDQ.W #2,6(A1)
 BRA.S WRP

;--2048---SLIDE UP CONST VOL 
SLR 
 CLR.B 4(A1)
 ADDq.W #6,20(A1)
 RTS

YIN DC.B 0,0
;9--2304-------HOLD-------------
HOLD MOVE.B #29,4(A1)
 RTS

;10--2560---HIGH NOTE WARB------
TWERP 
 MOVE.B #17,4(A1)
 LSR 20(A1)
 CMP #8,20(A1)
 BGT TETSYFLY
 MOVE 6(A1),20(A1)
TETSYFLY BRA VV 

;11-------2816 SLIDE UP WITH ADSR
SLR1
 SUBQ.W #6,20(A1)
 RTS

;12-------3072  inc up
inup
 sub.b #1,nije
 bne.s pod
 sub.w #4,6(a1)
 move.b #5,nije
 sub.b #6,4(a1)
pod bra wrp rts

;13-------3328--HOLD VOL LOW
HOLDLOW
 MOVE.B #32,4(A1)
 RTS 

;1--------3584 half adsr
half
 ADD.B #50,nije+1
 bCC.s aslef
 subq.b #1,4(a1)
aslef rts


nije dc.b 1,0

;\\\\\\\\\\\\\\DATAS\\\\\\\\\\\\\\\
;\\NOTE 1ST WORD. DURATION 2ND WORD
;\\\LEAD
PNT0 DC.W 0
NP0 DC.W 1
 DC.W 0
 DC.L 0
 DC.B 9,2,3
 DC.B 1      ;ADD TO NOTE
 DC.W 144      ;VIB LIMIT
 DC.W 72      ;16(A1)  ADD
 DC.W 0      ;VIB 18(A1)
 DC.L 0      ;TMP NOTE 20(A1)
 DC.B 1,1    ;VIB RATE 24(A1)
 DC.B 0,0    ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,15,14,14,13
 REPT  40
 DC.B 12
 ENDR


 EVEN
;\\\MIDDLE
PNT1 DC.W 0
 DC.W 1       ;EFFECT & DURATION 2(A1)
 DC.B 0,0
 DC.L 0
 DC.B 9,2,3
 DC.B 1       ;ADD  13(A1)
 DC.W 6       ;VIB LIMIT
 DC.W 2       ;VIB ADD 16(A1)
 DC.W 0       ;VIB 18(A1)
 DC.L 0       ;TEMP NOTE 20(A1)
 DC.B 1,1     ;VIB RATE  24)A1)
 DC.B 0,0     ;INITIAL VOL
;ADSR  28(A1)
 DC.B 15,14,9,13,12,14,14,13,12,12
 DC.B 12,12,12,12

 REPT 190
 DC.B 10
 ENDR

 EVEN
;\\\BASS
PNT2 DC.W 0
 DC.W 1          ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,4,5     ;10(A1) VOL REG
 DC.B 2          ;ADD TO NOTE 13(A1)
 DC.W 6          ;VIB LIMIT
 DC.W 2          ;VIBRATO ADD 16(A1)
 DC.W 2       ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 2,2        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
ADSR
 DC.B 15,15,14,14,14,13,13,13,13,13
 DC.B 13,13,12,12,11,11,10,10,10,9
 DC.B 8,7,6,5,4,3,4,2

 REPT 180
 DC.B 3
 ENDR

 EVEN
PNT3 DC.W 0
NP3 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0          ;6
 DC.B 10,6,11    ;10(A1) VOL REG
 DC.B -1         ;ADD  13(A1)
 DC.W 10         ;VIB LIMIT
 DC.W 4          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)
 DC.B 15,15,15,14,13,12
 DC.B 11,11,11,11,10
 DC.B 11,11,11,11,10
 

 EVEN
PNT4 DC.W 0
NP4 DC.W 1      ;2(A1) DURATION
 DC.B 0,0        ;4(A1)
 DC.L 0
 DC.B 8,0,1      ;10(A1) VOL REG
 DC.B 0          ;ADD 13(A1)
 DC.W 5          ;VIB LIMIT
 DC.W 7          ;VIBRATO ADD 16(A1)
 DC.W 0          ;VIB 18(A1)
 DC.L 0          ;TMP NOTE 20(A1)
 DC.B 1,1        ;VIB RATE
 DC.B 0,0        ;INITIAL VOL 26(A1)
;\ADSR  28(A1)

 DC.B 15,15,15,14,14,14,13,13
 REPT 32
 DC.B 13
 ENDR

 REPT 32
 DC.B 12
 ENDR

 REPT 32
 DC.B 11
 ENDR

 REPT 32
 DC.B 9
 ENDR

 REPT 32
 DC.B 8
 ENDR

 REPT 64
 DC.B 7
 ENDR

 EVEN
TE2 DC.W 2,3





MIN DC.B 0,0
MC DC.B 0,0
;-----------MUSIC DATA
Y3 
 DC.W 144*H,64+1536,121*H,64+1536
 DC.W 108*H,64+1536,96*H,32+1536
 DC.W 108*H,16+1536,96*H,16+1536

 DC.W 144*T,64+1536,121*T,64+1536
 DC.W 108*T,64+1536,96*T,32+1536
 DC.W 108*T,16+1536,96*T,16+1536

 DC.W 144/2,64+2560,121/2,64+2560
 DC.W 108/2,64+2560,96/2,32+2560
 DC.W 108/2,16+2560,96/2,16+2560

 DC.W 144*H,64+1536,121*H,64+1536
 DC.W 108*H,64+1536,96*H,64+1792
 DC.W 108*H,16+1536,96*H,16+1536
 DC.W $FFFF,$FFFF



Y2D DC.W 2,6
Y2
 DC.W 144*Q,8,72*Q,8,144*Q,8,72*Q,8
 DC.W 144*Q,8,72*Q,8,144*Q,8,72*Q,8

 DC.W 121*Q,16,121*Q,16,121*Q,16,121*Q,16

 DC.W 108*Q,8,217*Q,8,108*Q,8,217*Q,8
 DC.W 108*Q,8,53*Q,8,108*Q,8,53*Q,8
 
 DC.W 108*Q,16,108*Q,16,108*Q,32+2048
 DC.W $FFFF,$FFFF
  

YI
 DC.W 144*Q,8,144*Q,8,72*Q,8
 DC.W 144*Q,8,144*Q,8
 DC.W 144*Q,8,144*Q,8,72*Q,8

 DC.W 121*Q,8,121*Q,8,60*Q,8
 DC.W 121*Q,8,121*Q,8
 DC.W 121*Q,8,121*Q,8,60*Q,8

 DC.W 108*Q,8,108*Q,8,53*Q,8
 DC.W 108*Q,8,108*Q,8
 DC.W 108*Q,8,108*Q,8,53*Q,8

 DC.W 108*Q,8,108*Q,8,53*Q,8
 DC.W 108*Q,8,108*Q,8
 DC.W 108*Q,8,108*Q,8,53*Q,8

 DC.W $FFFF,$FFFF


DRMM
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024

 dc.w 31,8+768
 DC.W 0,8+1024
 

 dc.w 18,2+768
 DC.W 0,6+1024
 dc.w 14,2+768
 DC.W 0,6+1024
 dc.w 10,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024
 dc.w 8,1+768
 DC.W 0,7+1024

 dc.w 31,10+768
 DC.W 0,6+1024

 DC.W 0,16+1024

 DC.W $FFFF,$FFFF

 


SDUM
 DC.W 0,16+1024
 dc.w 16,8+768
 DC.W 0,8+1024
 DC.W $FFFF,$FFFF



DRSM
 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,4+1024
 DC.W 2,2+768
 DC.W 0,6+1024


 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,12+1024

 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,12+1024

 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,12+1024


 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,4+1024
 DC.W 2,2+768
 DC.W 0,6+1024


 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,12+1024


 DC.W 0,16+1024
 dc.w 8,4+768
 DC.W 0,4+1024
 dc.w 4,6+768
 DC.W 0,6+1024

 DC.W 0,12+1024
 dc.w 31,4+768
 DC.W 0,12+1024

 DC.W $FFFF,$FFFF



SLOG
 DC.W 72,255+512
 DC.W $FFFF,$FFFF


T2D DC.W 2,1
T2
 DC.W 144*Q,8,72*Q,8,144*Q,8,72*Q,8+2816
 DC.W 144*Q,8,72*Q,8,144*Q,8,72*Q,8 +2816

 DC.W 121*Q,8,60*Q,8,121*Q,8,60*Q,8+2816
 DC.W 121*Q,8,60*Q,8,121*Q,8,60*Q,8 +2816

 DC.W 217*Q,8,108*Q,8,217*Q,8,108*Q,8+2816
 DC.W 217*Q,8,108*Q,8,217*Q,8,108*Q,8 +2816
 
 DC.W 108*Q,8,53*Q,8,108*Q,8,53*Q,8+2816
 DC.W 108*Q,8,53*Q,8,108*Q,8,53*Q,8 +2816
 DC.W $FFFF,$FFFF

rigel 
 dc.w 144,128+3072
 DC.W $FFFF,$FFFF


TOM DC.W 2,64*4+3328
 DC.W 144*C,64+512,121*C,64+512,108*C,128+512


NO2 
 DC.W 108*e,8+256,91*e,8+256,96*e,8+256,102*e,8+256
 DC.W 108*e,8+256,217*e,8+256,204*e,8,102*e,8+256
 DC.W 193*e,8+256,96*e,8+256,204*e,8+256,102*e,8+256
 DC.W 108*e,8+256,217*e,8+256,193*e,8+256,96*e,8+256
 dc.w 2,128
 DC.W $FFFF,$FFFF


DRYM
 DC.W 12,4+768,8,4+768
 DC.W $FFFF,$FFFF

BAS1 DC.W 0,5
bas dc.w 144*f,8,72*f,8,128*f,8,64*f,8
    dc.w 121*f,8,60*f,8,114*f,8,57*f,8
    dc.w 108*f,8,53*f,8
    dc.w 96*f,8,47*f,8,91*f,8,45*f,8
    dc.w 81*f,8,81*f,2,40*f,8

NULL DC.W 2,128
 DC.W $FFFF,$FFFF

RF2 DC.W 0,255+3328,0,192+3328
 DC.W 144*2,16+512,144,16+512,72,32+512
 DC.W $FFFF,$FFFF

RF3 DC.W 0,255+3328,0,192+3328
 DC.W 144*2,16+512,144,16+512,72,255+512
 DC.W $FFFF,$FFFF



RAZ2 DC.W 0,2 
raz 
 dc.w 36*q,24+1536,2,8+3328
 dc.w 36*q,24+1536,2,8+3328
 dc.w 2,128+64+3328

 dc.w 36*q,24+1536,2,8+3328
 dc.w 36*q,24+1536,2,8+3328
 dc.w 2,128+3328

 DC.W 144*2,16+2304,144,16+2304,72,24+2304,0,8
 DC.W $FFFF,$FFFF

RAZ1 
 dc.w 36*q,24+1536,2,8+3328
 dc.w 36*q,24+1536,2,8+3328
 dc.w 2,128+64+3328

 dc.w 36*q,24+1536,2,8+3328
 dc.w 36*q,24+1536,2,8+3328
 dc.w 2,255+3328

 DC.W $FFFF,$FFFF

cow
 dc.w 96,4,2,4+2304
 dc.w 144,4,2,4+2304
 dc.w 36,4,2,4+2304
 dc.w 72,4,2,4+2304
 dc.w 47,4,2,4+2304
 dc.w 60,4,2,4+2304
 DC.W $FFFF,$FFFF

cow1
 dc.w 72,4,2,12+2304
 DC.W $FFFF,$FFFF



    
DRIFT DC.W 144/4,128+512,0,255+3328


DL DC.W 144*A,255+3584
FL DC.W 193*A,255+3584
GL DC.W 114*A,255+3584




TAB DS.B 64
DO DC.B 0,0


showbar 
;----make---BAR CHARTS
 move.l screen,a2 
 add.l #160*169,a2
 move #$7,$ff8240+20 
;------rout to show bars
 MOVEQ.W #39,D3
 moveq.w #7,d6
 moveq.b #%01111110,d7

MLP MOVE.L A2,A0

LP2 
 MOVE.B (A3)+,D1
 BEQ.S LP
 SUBQ.B #1,-1(A3)

 
lp	AND #30,D1 	
  	MOVEQ.W #15,d2
  	SUB D1,D2

LP1	clr.b 8(A0)
	clr.b 166(A0)
	lea 320(A0),a0
	DBRA D2,LP1

DID 	MOVE.B d7,8(A0)  
	MOVE.B d7,166(A0)  
	lea 320(A0),a0
 	DBRA D1,DID

 EOR #6,D6
 ADD.W D6,A2
 DBRA D3,MLP
DONT RTS
quiet_flag dc.w 0
super	dc.l 0
name	dc.b "budgii3.pi1",0
	even

