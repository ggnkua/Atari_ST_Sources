; Frequency Zak Bars - Coded by Grazey of The P.H.F.

; The program reads the frequency and volume of each note.

; The frequency determines the position the volume is
; poked ( C64 coding rubbing off there! ) in the table.

; eg If The volume was 15 and the frequency was 87 then the
; value 15 would be placed in position 87 of the table.

; The routine reads the first four values of the table, adds them together
; and then draws a bar of that height to the left of the screen. It then
; gets the next four values and moves 8 pixels along the screen and again
; draws a bar and so on.

; If ya have any difficulties then just drop me a line :

;	Grazey,
;	32 Dundee Street,
;	Kingston Upon Hull,
;	East YORKSHIRE ( hey Mat enough of the 4 YORKSHIRE men knocking! )
;	HU5 3TX.

; Big Hi to everyone we know on C64/ST/Miggy and also to Stefan Posthuma 
; whose great coding articles for ST-NEWS inspired me to learn 68000.

; The P.H.F. Are:

; Cal ( Amiga Coder )
; Grazey ( Commodore 64/ST Coder,GFX )
; Johnny 99 ( ST/Amiga Coder )


; Set Tabs to 8

rascol	equ	$ff8242		; Try changing to $ff8240

	opt	x-		; Ha Ha ripper
	clr.l   -(sp)		
	move.w  #$20,-(sp)
	trap    #1
	move.l  d0,savereg
	move.l  #$70000,a7

	move.l  #moff,-(sp)	
	clr.w   -(sp)
	move.w  #25,-(sp)
	trap    #14
	addq.l  #8,sp
	dc.w    $a00a
	move.w  #4,-(sp)	        
	trap    #14
        addq.l  #2,sp	
	move.w  d0,oldrez

	move.l	$44e,screen		
	move.l 	$44e,oldscr

relo	LEA	zak,A0		;Relocate zak to 70be8
	LEA	$70be8,A1
	MOVE.L	#zakend-zak,D0
.loop	MOVE.B	(A0)+,(A1)+
	DBF	D0,.loop
	move.l	#1,d0		;Tune 0-1
	jsr	$70bea		;Initialise

	movem.l $ffff8240.w,d0-d7	
	movem.l d0-d7,oldpal		

	move.w  #0,-(sp)		
	move.l  screen,-(sp)		
	move.l  screen,-(sp)	
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp

	move.l	screen,a0	;clear screen
	move.w	#160*200,d0
clg	clr.w	(a0)+
	dbra	d0,clg

	move.l	#table1,a4
	add	#8,a4
	move.l	a4,scpt		;I skip the first few notes

	move.l	screen,a0	;Position of bars
	add	#160*65,a0
	add.w	#8,a0
	move.l	a0,scrpt

        bsr     hblon		

	move.l	#text,-(sp)	;Display text
	move.w	#$9,-(sp)
	trap	#1
	addq.l	#6,sp

get	move.b	$ffffc02,d0
	beq	get

	cmp.b	#$39,d0		;space		
	beq	yehh

	cmp.b	#$3b,d0		;F1
	bne	.jump1
	move.l	#1,d0		
	jsr	$70bea
	bsr	clearbars

.jump1	cmp.b	#$3c,d0		;F2
	bne	.jump2
	move.l	#0,d0		
	jsr	$70bea
	bsr	clearbars

.jump2	bra	get

yehh	bsr     hbloff		
        movem.l oldpal,d0-d7	
	movem.l d0-d7,$ffff8240.w
	move.w  oldrez,-(sp)	
	move.l  oldscr,-(sp)
	move.l  oldscr,-(sp)
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp

	move.l #$08080000,$ff8800	;Clear yammy		
	move.l #$09090000,$ff8800		
	move.l #$0a0a0000,$ff8800		

	move.l  #mon,-(sp)	
	clr.w   -(sp)
	move.w  #25,-(sp)
	trap    #14
	addq.l  #8,sp


	dc.w    $a009
	move.l  savereg,-(sp)	
	move.w  #$20,-(sp)
	trap    #1
	addq.l  #6,sp
	clr.w   -(sp)		; Ugh! Back to GEM
        trap    #1

hblon  	move.w  #$2700,sr
	move.l  $120,oldtb
        move.l  $70,oldvbl
	move.b  $fffffa07,old07
	move.b  $fffffa09,old09
	move.b  $fffffa0f,old0f
	move.b  $fffffa11,old11
	move.b  $fffffa1b,old1b
	and.b   #$df,$fffa09
	and.b   #$fe,$fffa07 
	move.l  #grz,$70
	move.l	#tb1,$120
	or.b    #1,$fffffa07
	or.b    #1,$fffffa13
	move.w  #$2300,sr
	rts



hbloff	move.w  sr,-(sp)
	move.w  #$2700,sr
	move.b  old07,$fffffa07
	move.b  old09,$fffffa09
	move.b  old0f,$fffffa0f
	move.b  old11,$fffffa11
	move.b  old1b,$fffffa1b
	move.l  oldtb,$120
	move.l  oldvbl,$70
	clr.l	$4de
	clr.l	$4e2
	move.w  (sp)+,sr
	rts

clearbars
	move.l	screen,a0	
	move.w	#160*66,d0
.local	clr.w	(a0)+
	dbra	d0,.local
	rts


grz	move.w	#$0,$ff8240
	clr.b   $fffffa1b.w
	move.b  #3,$fffffa21	
	move.l  #tb1,$120	
	move.b  #8,$fffffa1b
	movem.l d0-a6,-(sp)			 
	jsr	$70bee			;Call Zak
	bsr	doline
.loop	movem.l (sp)+,d0-a6			
	move.l	oldvbl,-(sp)
	rts

;Rasters

tb1    		move.w	#$777,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb2,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb2    		move.w	#$766,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb3,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb3    		move.w	#$755,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb4,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb4    		move.w	#$744,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb5,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb5    		move.w	#$733,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb6,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb6    		move.w	#$722,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb7,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb7    		move.w	#$711,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb8,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb8    		move.w	#$700,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb9,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb9    		move.w	#$710,rascol
		clr.b   $fffffa1b.w      
                move.l  #tba,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tba    		move.w	#$720,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbb,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbb    		move.w	#$730,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbc,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbc    		move.w	#$740,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbd,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbd    		move.w	#$750,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbe,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbe    		move.w	#$760,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbf,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbf    		move.w	#$770,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbg,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbg    		move.w	#$670,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbh,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbh    		move.w	#$570,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbi,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbi    		move.w	#$470,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbj,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbj    		move.w	#$270,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbk,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbk    		move.w	#$070,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbl,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbl    		move.w	#$070,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbm,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbm    		move.w	#$270,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbn,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbn    		move.w	#$370,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbo,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbo    		move.w	#$470,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbp,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbp    		move.w	#$570,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbq,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbq    		move.w	#$670,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbr,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbr    		move.w	#$770,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbs,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbs    		move.w	#$760,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbt,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbt    		move.w	#$750,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbu,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbu    		move.w	#$740,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbv,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbv    		move.w	#$730,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbw,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbw    		move.w	#$720,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbx,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbx    		move.w	#$710,rascol
		clr.b   $fffffa1b.w      
                move.l  #tby,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tby    		move.w	#$700,rascol
		clr.b   $fffffa1b.w      
                move.l  #tbz,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tbz    		move.w	#$711,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb11,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb11    	move.w	#$722,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb12,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb12    	move.w	#$733,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb13,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb13    	move.w	#$744,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb14,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb14    	move.w	#$755,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb15,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb15    	move.w	#$766,rascol
		clr.b   $fffffa1b.w      
                move.l  #tb16,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte
tb16    	move.w	#$777,rascol
		clr.b   $fffffa1b.w      
                move.l  #last,$120
                move.b  #8,$fffffa1b.w
                bclr    #0,$fffffa0f.w   
                rte

last            move.w	#$0,rascol
		clr.b   $fffffa1b.w      
                bclr.b  #0,$fffffa0f.w   
                rte


; ZAK BARS CODED BY GRAZEY, 1 PLANE MULTI FREQ

; CHECK OUT A FUTURE SOURCE MENU FOR AN EXAMPLE OF 3 PLANE FREQ BARS!!

doline	lea	$ffff8800,a1

	move.b	#0,(a1)			;Get vol Chan 1
	clr	d0
	move.b	(a1),d0			;Poke into d0
	move.b	#8,(a1)			;Get picth/freq	Chan 1
	clr	d1
	move.b	(a1),d1			;Poke into d1

	bsr	draw			;Put note in table

	move.b	#2,(a1)			;Same for Chan 2
	clr	d0
	move.b	(a1),d0
	move.b	#9,(a1)		
	clr	d1
	move.b	(a1),d1

	bsr	draw

	move.b	#4,(a1)			;and for Chan 3
	clr	d0
	move.b	(a1),d0
	move.b	#10,(a1)	
	clr	d1
	move.b	(a1),d1
	bsr	draw

	move.b	#6,(a1)			;Get Vol of Noise Gen.
	clr	d0
	move.b	(a1),d0
	move.b	#10,(a1)		;Use freq of Chan 3
	clr	d1
	move.b	(a1),d1
	bsr	draw

	bsr	decr			;Decrement all notes in table

	bsr	drawit			;Draw bars
	rts

draw	move.l	#table1,a4		
	asl	#1,d0			;Goto correct position in table
	add.w	d0,a4	
	and.w	#255-16,d1		;Cut off 16 values
	move.w	d1,(a4)			;Move volume into table
	rts

decr	move.w	#254,d1
	move.l	#table1,a4
.loop	cmp.w	#0,(a4)			;If 0 skip it
	beq	.jump
	sub.w	#1,(a4)			;Decrement current value
.jump	add.w	#2,a4
	dbra	d1,.loop
	rts

drawit	clr.l	d2		
	clr.l	d7
	move	#39,d7
	move.l	scpt,a4		; Table 
	move.w	#0,d2		; Which bit plane ?

.loop	move.l	scrpt,a0	; Position on screen
	add	d2,a0
	move.l	a0,a2
	add	#160,a2

	move	(a4)+,d0	;This simply adds the volumes of 4
	add	(a4)+,d0	;consecutive notes together so a
	add	(a4)+,d0	;bar can be between 0 and 64 lines
	add	(a4)+,d0	;high.

	cmp.w	#1,d0
	beq	.l2
	cmp.w	#0,d0
	beq	.l7
	bra	.l3

.l2	add.w	#8,d1
	bra	.l5

.l3	move	#64,d1
	sub	d0,d1
	cmp	#0,d0
	beq	.l5

.l6	move.b	#126,(a0)		;Change 126
	move.b	#126,(a2)		;to alter bar widths
	sub	#160,a0			;Draw bottom bars
	add	#160,a2			;repeat for top bars
	dbra	d0,.l6

.l5	clr.b	(a0)			;Clear 
	clr.b	(a2)
	sub	#160,a0
	add	#160,a2
	dbra	d1,.l5

.l7	move.l	a0,d0

	btst	#0,d0
	beq	.l8
	addq	#7,d2
	bra	.l9
.l8	addq	#1,d2
.l9	dbra	d7,.loop
	rts

; Scoop - That's The Way It Is  (EagleSoft Incorporated Light Intro)

; Composed By Jeroen Tel, Ex Member Of The Maniacs Of Noise
; Music Driver Coded By Charles Deenen Of The Maniacs Of Noise

; Converted To The ST By Jochen Hippel Of The Exceptions

; Ripped and Relocated to Hi-Ram From The Thalion Sound Demo
; by Grazey/PHF.

zak	incbin	"scoop.rel"
zakend	even
	even


oldrez         	dc.w    0
oldscr         	dc.l    0
savereg        	dc.l    0
screen         	dc.l    0
oldvbl         	dc.l    0
oldtb          	dc.l    0
old07          	dc.b    0
old09          	dc.b    0
old0f          	dc.b    0
old11          	dc.b    0
old1b          	dc.b    0
scpt		dc.l	1
scrpt		dc.l	1
mon		dc.b    $08
moff		dc.b    $12

text		dc.b	27,"E",27,"Y",49,32
		dc.b	"Frequency Bars.",13,10,13,10
		dc.b	"By Grazey From The P.H.F. Of Hull",13,10,13,10
		dc.b	"F1-F2 selects tunes.  Space Exits",0

	BSS
table1		ds.w	400
oldpal         ds.w    16
