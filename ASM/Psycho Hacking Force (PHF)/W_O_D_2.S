; SOURCE INTRO V1.1

; Totally bastardised to work with f**king Mad Max's shitty digi routine!

; Coded: 17-18 April 1992

; Mods : 3rd May 1992 ( While celebrating the fact that Hull City have
;                       survived in division 3 ! )

; Credits >

; Main Coding ( Rasters/Stars/Zak Bars )........Grazey
; Neo Graphix...................................Grazey
; Movep Scroll Code.............................Tony B
; Zak...........................................Mad Max Of Tex
; Zak Ripping...................................Grazey
; Menu Compiling................................Mug UK! ( The easy part! )

; The P.H.F. Are:

; Cal ( Amiga Coder )

; Grazey ( C64/ST Coder,GFX )

; Johnny 99 ( ST/Amiga Coder )


; Set Tabs to 8

; Sorry for not documenting this source but I have n't the time.

; If you want to use it on another menu then it should be easy to
; change the music,logo/raster/font colours etc.

	opt	x-
num	equ	47
delay	equ	150

_movep:	macro
	movep.l	\1(a0),d0
	movep.l	d0,\1-7(a0)
	movep.l	\1+1(a0),d0
	movep.l	d0,\1(a0)
	endm

start   move.l	4(a7),a3		; Start of Memory to save
	move.l	#$100,-(sp)		; 100 bytes,200 Nybbles
	move.l	a3,-(sp)		
	clr.w	-(sp)
	move.w	#$4a,-(sp)		; Save 100bytes
	trap	#1			; release memory
	add.l	#12,sp
		
	clr.l   -(sp)		
	move.w  #$20,-(sp)
	trap    #1
	move.l  d0,savereg
	move.l  #$70000,a7

	move.w	#6,-(sp)	;Flicker!!!!
	move.w	#26,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#5,-(sp)
	move.w	#26,-(sp)
	trap	#14
	addq.l	#4,sp		;What Flicker?

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

	move.l	#fpal,palpt
	move.l	#black,logpal
	move.l	#pallog,logpt
	
	move.l	$44e,a0		
	sub.l	#$2000,a0	

	move.l	a0,physbase	
	move.l	a0,a7		

	move.l 	$44e,oldscr
	move.l 	physbase,screen
	move.l	screen,a0
	add.l	#160*203,a0
	move.l	a0,sscreen

	movem.l $ffff8240.w,d0-d7	
	movem.l d0-d7,oldpal		

	move.l	#0,$ff8240	
	move.l	#0,$ff8244	
	move.l	#0,$ff8248	
	move.l	#0,$ff824c	
	move.l	#0,$ff8250	
	move.l	#0,$ff8254	
	move.l	#$7440744,$ff8258	
	move.l	#$7440744,$ff825c	

	bsr	hblon

	move.l	#1,d1
	move.l	#1,d0
	lea	data,a0
	jsr	driver

	move.w  #0,-(sp)		
	move.l  screen,-(sp)		
	move.l  screen,-(sp)	
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp


	lea	text,a0	
	move.l	a0,scrolline
	jsr	nextlet		

	move.l	screen,a0
	move.w	#160*250,d0
clg	clr.w	(a0)+
	dbra	d0,clg

	move.l	#table1,a4
	add	#8,a4
	move.l	a4,scpt

	move.l	screen,a0
	add	#160*31,a0
	add.w	#8,a0
	move.l	a0,scrpt

	lea	pic+128,a0
	move.l	screen,a1
	add.l	#480,a1
	move.w	#160*100,d1
putpic	move.w	(a0)+,(a1)+
	dbra	d1,putpic

	bsr	hblon1

	


get	cmp.b	#$39,$fffffc02	;space	temporary!
	beq	yehh

	cmp.b	#$3b,$fffffc02		;F1
	bne	.l1
	move.l	#game1,filename
	bra	yehh

.l1	cmp.b	#$3c,$fffffc02		;F2
	bne	.l2
	move.l	#game2,filename
	bra	yehh

.l2	cmp.b	#$3d,$fffffc02		;F3	;Just add more of these
	bne	.l3				;subroutines if use
	move.l	#game3,filename			;more options
	bra	yehh

.l3	add.l	#1,timer
	movem.l	d0-a7,junk		;slooows it down a wee bit
	movem.l	d0-a7,junk
	movem.l	d0-a7,junk
	movem.l	d0-a7,junk
	cmp.l	#26500,timer
	bne	get
	move.l	#1,timer
	move.l	logpt,a0
	cmp.l	#$ff,(a0)
	bgt	.ll
	move.l	#pallog,logpt
	move.l	logpt,a0
.ll	move.l	(a0),logpal
	add.l	#4,logpt
	bra	get

yehh	bsr     hbloff		

	move.w	#6,-(sp)	;What Flicker ?
	move.w	#27,-(sp)
	trap	#14
	addq.l	#4,sp

	move.w	#5,-(sp)
	move.w	#27,-(sp)
	trap	#14
	addq.l	#4,sp		;Flicker!!!

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

	pea     env_str                 ; Run program
        pea     cmd_str
        move.l	filename,-(sp)
        move.w  #0,-(sp)
        move.w  #$4b,-(sp)
        trap    #1
        add.l   #14,sp

	clr.w   -(sp)		; Ugh! Back to GEM
        move.w  #$4c,-(sp)
        trap    #1

hblon:  move.w  #$2700,sr
	move.l  $120,oldtb
        move.l  $70,old4
	move.b  $fffffa07,old07
	move.b  $fffffa09,old09
	move.b  $fffffa0b,old0b
	move.b  $fffffa0d,old0d
	move.b  $fffffa0f,old0f
	move.b  $fffffa11,old11
	move.b  $fffffa13,old13
	move.b  $fffffa15,old15
	move.b  $fffffa17,old17
	move.b  $fffffa19,old19
	move.b  $fffffa19,old19
	move.l  $110,old110
	move.w  #$2300,sr
	rts

hblon1: move.w  #$2700,sr
	move.b	#$40,$fffffa17
	and.b   #$df,$fffa09
	and.b   #$fe,$fffa07 
	move.l  #new4,$70
	move.l	#tb1,$120
	or.b    #1,$fffffa07
	or.b    #1,$fffffa13
	move.w  #$2300,sr
	rts


hbloff:	move.w  sr,-(sp)
	move.w  #$2700,sr
	move.l	old110,$110.w
	move.b  old07,$fffffa07
	move.b  old09,$fffffa09
	move.b  old0b,$fffffa0b
	move.b  old0d,$fffffa0d
	move.b  old0f,$fffffa0f
	move.b  old11,$fffffa11
	move.b  old13,$fffffa13
	move.b  old15,$fffffa15
	move.b  old17,$fffffa17
	move.b  old19,$fffffa19
	move.b  old1b,$fffffa1b
	move.l  oldtb,$120
	move.l  old4,$70
	clr.l	$4de
	clr.l	$4e2
	move.w  (sp)+,sr
	rts


new4	clr.b   $fffffa1b.w
	move.b  #1,$fffffa21	
	move.l  #tb1,$120	
	move.b  #8,$fffffa1b
	move.w	#$006,$ff8248	;Bar colour
	jsr	scroll		;Movep
	jsr	killstars	;Stars
	jsr	updatexpos
	jsr	plotstars
	jsr	getvol
	jsr	doline
	add.l	#1,coun
	cmp.l	#2,coun
	bne	.loop
	move.l	#0,coun
	add.l	#2,palpt
	move.l	#endpal,a0
	move.l	palpt,a1
	cmp.l	a0,a1
	bne	.loop
	move.l	#fpal,palpt
.loop	jsr	driver+8
	rte


tb1:    	move.l 	a0,-(sp)
        	move.l  palpt,a0       
        	move.w  2(a0),$ff8240
		clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#20,(a0)	 
                move.l  #tb2,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte


tb2             move.l 	a0,-(sp)
         	move.l  palpt,a0       
		move.w	4(a0),$ff8240
		clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#10,(a0)	 
                move.l  #tb3,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb3:         	move.l	a0,-(sp)
                move.l  palpt,a0       
                move.w  6(a0),$ff8240
		clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#8,(a0)	 
                move.l  #tb4,$120
                move.b  #8,$fffffa1b.w
                move.l (sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte


tb4             move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  8(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#7,(a0)	 
                move.l  #tb5,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb5             move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  10(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#6,(a0)	 
                move.l  #tb6,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb6             move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  12(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#5,(a0)	 
                move.l  #tb7,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb7             move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  14(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#4,(a0)	 
                move.l  #tb8,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb8             move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  16(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#3,(a0)	 
                move.l  #tb9,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb9             move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  18(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#2,(a0)	 
                move.l  #tb10,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb10            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  20(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#1,(a0)	 
                move.l  #tb11,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb11            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  22(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#1,(a0)	 
                move.l  #mid,$120
                move.b  #8,$fffffa1b.w
		move.l  logpal,a0		;Logo colours
		add.w	#2,a0
        	move.w  (a0)+,$ff8242
        	move.w  (a0)+,$ff8244
        	move.w  (a0)+,$ff8246
        	move.w  (a0)+,$ff8248
        	move.w  (a0)+,$ff824a
        	move.w  (a0)+,$ff824c
        	move.w  (a0)+,$ff824e
        	move.w  (a0)+,$ff8250
        	move.w  (a0)+,$ff8252
        	move.w  (a0)+,$ff8254
        	move.w  (a0)+,$ff8256
        	move.w  (a0)+,$ff8258
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

mid             move.l 	a0,-(sp)
                move.w  #$0,$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#59,(a0)	 
                move.l  #tb12,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb12            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  22(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#1,(a0)	 
                move.l  #tb13,$120
        	move.w  #$333,$ff8242		;Star Colours (3-plane)
        	move.w  #$555,$ff8244
        	move.w  #$777,$ff8248
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb13            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  20(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#1,(a0)	 
                move.l  #tb14,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb14            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  18(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#2,(a0)	 
                move.l  #tb15,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb15            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  16(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#3,(a0)	 
                move.l  #tb16,$120
                move.b  #8,$fffffa1b.w
		move.l	#$777,$ff824e
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb16            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  14(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#4,(a0)	 
                move.l  #tb17,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb17            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  12(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#5,(a0)	 
                move.l  #tb18,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb18            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  10(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#6,(a0)	 
                move.l  #tb19,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb19            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  8(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#7,(a0)	 
                move.l  #tb20,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb20            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  6(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#8,(a0)	 
                move.l  #tb21,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb21            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  4(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#12,(a0)	 
                move.l  #tb22,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte

tb22            move.l 	a0,-(sp)
                move.l  palpt,a0       
                move.w  2(a0),$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#22,(a0)	 
                move.l  #tb23,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte


tb23            move.l 	a0,-(sp)
                move.w  #$0,$ff8240
         	clr.b   $fffffa1b.w      
                move.w  #$fa21,a0
		move.b	#1,(a0)	 
                move.l  #killit,$120
                move.b  #8,$fffffa1b.w
                move.l 	(sp)+,a0
                bclr    #0,$fffffa0f.w   
                rte


newtb2	    	move.w	#0,$ff8240
		clr.b   $fffffa1b.w      
                movem.l d0-d1/a0-a1,-(sp)
                move.w  #$fa21,a1
                move.b  #200,(a1)
                move.b  #8,$fffffa1b.w
                movem.l (sp)+,d0-d1/a0-a1       
                bclr    #0,$fffffa0f.w   
                rte


getvol	move.w	sr,-(A7) 
	ori	#$700,sr 
	lea	$ffff8800.W,a0 

	move.b	#$0,(a0) 
	moveq	#$0,d0
	move.b	(a0),d0
	move.b	#$8,(a0) 
	moveq	#$0,d1
	move.b	(a0),d1
	btst	#4,d1
	bne	.loop1
	move.b	#10,d1

.loop1	move.b	#$2,(a0) 
	moveq	#$0,d2
	move.b	(a0),d2
	move.b	#$9,(a0) 
	moveq	#$0,d3
	move.b	(a0),d3 
	btst	#4,d3
	bne	.loop2
.loop2	move.b	#10,d3


	move.b	#$4,(a0) 
	moveq	#$0,d4
	move.b	(a0),d4 
	move.b	#$a,(a0) 
	moveq	#$0,d5
	move.b	(a0),d5 
	btst	#4,d5
	bne	.loop3
	move.b	#10,d5
.loop3	rte


***	BARS
doline	bsr	draw1
	bsr	draw2
	bsr	draw3
dol4	bsr	decr
	bsr	drawit
	rts

 
draw1	move.l	#table1,a4
	asl	#1,d0			* Double to get on word
	add	d0,a4			* Add to table beggining
	move	d1,(a4)			* Store in table
.ddd	rts


draw2	move.l	#table1,a4
	asl	#1,d2			* Double to get on word
	add	d2,a4			* Add to table beggining
	move	d3,(a4)			* Store in table
.ddd	rts


draw3	move.l	#table1,a4
	asl	#1,d4			* Double to get on word
	add	d4,a4			* Add to table beggining
	move	d5,(a4)			* Store in table
.ddd	rts


decr	move.w	#254,d1
	move.l	#table1,a4
.loop	cmp.w	#0,(a4)
	beq	.jump
	sub.w	#1,(a4)
.jump	add.w	#2,a4
	dbra	d1,.loop
	rts


drawit	clr.l	d2		;I've just copied the 3 routs for speed purposes
	clr.l	d7
	clr.l	d0
	move	#39,d7
	move.l	scpt,a4
	move.w	#4,d2

.loop	move.l	scrpt,a0
	add	d2,a0
	move.l	a0,a2
	add	#160,a2

	move	(a4)+,d0
	add	(a4)+,d0
	add	(a4)+,d0
	add	(a4)+,d0

	cmp.w	#1,d0
	beq	.l2
	cmp.w	#0,d0
	beq	.l7
	bra	.l3

.l2	add.w	#7,d1
	bra	.l5

.l3	cmp.w	#26,d0		;I've shortened their height to 32
	ble	.l4
	move.w	#26,d0
.l4	move	#26,d1
	sub	d0,d1
	cmp	#0,d0
	beq	.l5

.l6	move.b	#126,(a0)
	move.b	#126,(a2)
	sub	#160,a0
	add	#160,a2
	dbra	d0,.l6

.l5	clr.b	(a0)
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

killit 	clr.b 	$fffffa1b.w			;Original code by STefan Posthuma of ST-NEWS
	move.w	#$765,$ff8242	;Font pal
	move.w	#$654,$ff8244
	move.w	#$543,$ff8246
	move.w	#$432,$ff8248
	move.w	#$321,$ff824a
	move.w	#$210,$ff824c
	move.w	#$005,$ff824e
	move.w	#0,$ff8240
        movem.l a0/d0,-(a7)
        move.w 	#$fa21,a0                   
        move.b 	#200,(a0)
        move.b 	#8,$fffffa1b.w
        move.b 	(a0),d0
.loop   cmp.b 	(a0),d0                      
        beq 	.loop
        clr.b 	$ffff820A.W                  
        moveq.w #3,D0
.loop2  nop                                
        dbf 	d0,.loop2
        move.b 	#2,$FFFF820A.w              
        movem.l (a7)+,a0/d0
        bclr 	#0,$fffffa0f.w
        rte



plotstars
mainloop
	move.l	#0,d6
	lea	stars,a1
	move	#2,d7
nxpl
	move	#num/3,d3

qq
	move.l	screen,a2
	move	(a1),d2		x n y pos
	move	2(a1),d1
	move.l	screen,a2

	move	d1,d5

	mulu	#160,d1
	and	#$fff0,d2
	lsr	d2
	add	d1,d2
	add	d2,a2

	move	(a1),d1
	and	#$f,d1
	neg	d1
	add	#15,d1


	move	(a2),d2		* Plane 1
	or	2(a2),d2	* Plane 2
	or	4(a2),d2	* Plane 3
	or	6(a2),d2	* Plane 4
	btst	d1,d2		* Any set ?
	bne	zeen2
	MOVE	#0,4(A1)


	move	(a2,d6),d2
	bset	d1,d2
	move	d2,(a2,d6)

	BRA	PPOO
zeen2	MOVE	#-1,4(A1)

PPOO	ADD.L	#6,A1
	dbra	d3,qq
	add	#2,d6
	dbra	d7,nxpl
	rts

killstars


	lea	stars,a1
	move	#num,d3

qqqq
	move.l	screen,a2
	move	(a1),d2		x n y pos
	move	2(a1),d1
	move	d1,d5

	mulu	#160,d1
	and	#$fff0,d2
	lsr	d2
	add	d1,d2
	add	d2,a2

	move	(a1),d1
	and	#$f,d1
	neg	d1
	add	#15,d1
	; d1 is the pixel to check
	MOVE	4(A1),D2
	CMP	#0,D2
	Bne	zeen
	move	0(a2),d2
	bclr	d1,d2
	move	d2,0(a2)

	move	2(a2),d2
	bclr	d1,d2
	move	d2,2(a2)

	move	4(a2),d2
	bclr	d1,d2
	move	d2,4(a2)

	move	6(a2),d2
	bclr	d1,d2
	move	d2,6(a2)

zeen	add.l	#6,a1
	dbra	d3,qqqq
	rts

	
; before this delete stars

updatexpos
	clr	d1
	lea	stars,a1
	move.l	#num/3,d2
updatex
	move	(a1),d1
	sub	#3,d1
	bmi	resetxpos
	move	d1,(a1)
	bra	nxtonex
resetxpos
	move	#319,(a1)
nxtonex
	addq.l	#6,a1
	dbra	d2,updatex
	
	move.l	#num/3,d2

updatex2
	move	(a1),d1
	sub	#5,d1
	bmi	resetxpos2
	move	d1,(a1)
	bra	nxtonex2
resetxpos2
	move	#319,(a1)
nxtonex2
	addq.l	#6,a1
	dbra	d2,updatex2


	move.l	#num/3,d2
updatex3
	move	(a1),d1
	sub	#7,d1
	bmi	resetxpos3
	move	d1,(a1)
	bra	nxtonex3
resetxpos3
	move	#319,(a1)
nxtonex3
	addq.l	#6,a1
	dbra	d2,updatex3
	rts
	*********************************************



star1a
s	ds.w	num	


stars	
	dc.w	100,150,0
	dc.w	50,150,0
	dc.w	23,143,0
	dc.w	76,174,0
	dc.w	234,145,0
	dc.w	34,175,0
	dc.w	23,190,0
	dc.w	46,178,0
	dc.w	56,165,0
	dc.w	223,195,0
	dc.w	139,185,0
	dc.w	175,145,0

	dc.w	87,170,0
	dc.w	194,148,0
	dc.w	159,196,0
	dc.w	12,155,0
	dc.w	300,183,0
	dc.w	273,145,0
	dc.w	201,133,0
	dc.w	113,167,0
	dc.w	189,174,0
	dc.w	245,184,0
	dc.w	54,142,0
	dc.w	25,159,0

	dc.w	187,160,0
	dc.w	294,158,0
	dc.w	059,196,0
	dc.w	112,145,0
	dc.w	001,193,0
	dc.w	313,135,0
	dc.w	301,143,0
	dc.w	213,177,0
	dc.w	289,174,0
	dc.w	315,192,0
	dc.w	154,182,0
	dc.w	125,159,0	;36

	dc.w	054,145,0
	dc.w	154,164,0
	dc.w	254,178,0
	dc.w	089,185,0
	dc.w	189,194,0
	dc.w	289,148,0
	dc.w	004,176,0
	dc.w	104,164,0
	dc.w	204,181,0
	dc.w	304,159,0
	dc.w	199,166,0
	dc.w	299,193,0	;48

fpal	dcb.w	54,$0
	dc.w	$1,$1,$1,$2,$2,$3,$4,$5,$6,$7,$117,$227,$337,$447,$557,$667,$777,$667,$557,$447,$337,$227,$117,$7,$6,$5,$4,$3,$2,$2,$1,$1,$1
	dcb.w	delay,$0
	dc.w	$100,$100,$100,$200,$200,$300,$400,$500,$600,$700,$711,$722,$733,$744,$755,$766
	dc.w	$777,$766,$755,$744,$733,$722,$711,$700,$600,$500,$400,$300,$200,$200,$100,$100,$100
	dcb.w	delay,$0
	dc.w	$1,$1,$1,$2,$2,$3,$4,$5,$6,$7,$107,$207,$307,$407,$507,$607,$707,$706,$705,$704,$703,$702,$701,$700,$710,$720
	DC.W	$730,$740,$750,$760,$770,$670,$570,$470,$370,$270,$170,$070,$071,$072,$073,$074,$075,$076,$077,$067
	DC.W	$057,$047,$037,$027,$017,$7,$6,$5,$4,$3,$2,$2,$1,$1,$1
	dcb.w	delay,$0
	dc.w	$10,$20,$30,$40,$50,$60,$70,$170,$270,$370,$470,$570,$670,$770,$771,$772,$773,$774,$775,$776,$767,$757,$747,$737,$727,$717
	dc.w	$707,$617,$527,$437,$347,$257,$167,$077,$166,$255,$344,$433,$522,$611,$700,$711,$722,$733,$744,$755,$766,$777,$666,$555
	dc.w	$444,$333,$222,$111
	dcb.w	delay,$0
	dc.w	$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222,$111
black	dcb.w	delay,$0
	dc.w	$001,$012,$123,$234,$345,$456,$567,$677,$777,$765,$654,$543,$432,$321,$210,$100,$010,$021,$132,$243,$354,$465,$576,$677,$777
	dc.w	$776,$775,$774,$773,$772,$771,$770,$660,$550,$440,$330,$220,$110 


endpal
	dcb.w	20,$0
	even
driver	incbin	"d:\musichak.mug\jochen\digi_mus\w_o_d_ii\driver.mus"
data	incbin	"d:\musichak.mug\jochen\digi_mus\w_o_d_ii\wodlev2.mus"
pic	incbin	"sour*.neo"
font	incbin	"*.fon"
	even


scroll:	movem.l	d0-d1/a0-a1,-(sp)
	tst.b	times		; scrolled a letter yet?
	bne.s	.ok		; no!
	bsr	nextlet
.ok:	move.l	sscreen,a0
	move.l	fptr(pc),a1
	moveq	#24,d1
.here
	movep.l	1(a0),d0
	movep.l	d0,(a0)
	_movep	8
	_movep	16
	_movep	24
	_movep	32
	_movep	40
	_movep	48
	_movep	56
	_movep	64
	_movep	72
	_movep	80
	_movep	88
	_movep	96
	_movep	104
	_movep	112
	_movep	120
	_movep	128
	_movep	136
	_movep	144
	_movep	152
	move.l	(a1),d0
	movep.l	d0,153(a0)
	lea	160(a0),a0
	lea	16(a1),a1
	dbra	d1,.here
	addq.l	#4,fptr
	subq.b	#1,times
	movem.l	(sp)+,d0-d1/a0-a1
	rts

; movep byte scroller routines !
nextlet:	movem.l	d0/a0,-(sp)	; next letter routine
movelet:	move.l	scrolline(pc),a0	; address of next letter
	addq.l	#1,scrolline	; pointer to next letter
	clr.l	d0
	move.b	(a0),d0		; get char from text
	cmpi.b	#$ff,d0		; end of scroll
	bne.s	go_go
	lea	text(pc),a0	; scroll text start
	move.l	a0,scrolline	; address of letter
	move.b	(a0),d0		; get letter
go_go:	sub.l	#32,d0		; calculate font pointer
	mulu	#400,d0
	lea	font(pc),a0
	adda.l	d0,a0
	move.l	a0,fptr		; store font pointer
	move.b	#4,times
	movem.l	(sp)+,d0/a0
	rts

	

	DATA
text:	dc.b	"                                          "
	dc.b	"     INTRO FOR THE SOURCE         YO MUG!  I KNOCKED UP THIS INTRO IN TWO DAYS!   IT'S NOT BRAIN BLASTING BRILLIANT"
	DC.B	"  BUT I JUST CONCOCKTED IT TOGETHER WITH SOME BITS OF MY CODE WHICH I HAD LYING AROUND"
	DC.B	"  CREDS GO TO     ALL MAJOR CODING BY GRAZEY     SCROLL CODE BY TONY B. OF UNT      NEOCHROME GRAPHIX BY GRAZEY"
	DC.B	"    FONT BY KNIGHTHAWKS ( AMIGA )      ZAK BY CHRIS MAD OF GHOST      ZAK RIPPING AND RELOCATING BY GRAZEY    "
	DC.B	"       DON'T FORGET TO SEND ME THE MENU YOU USE IT ON!   "
	DC.B	"     ANYWAY I MUST DASH NOW AS I'M DRIVING TO NOTTINGHAM IN ABOUT 10 MINUTES   SEE YA!               "
	dc.b	$ff

;Palette of SOURCE2.NEO: Saved by NEOchrome V2.10 by Chaos, Inc.
pal1		dc.w	$0000,$0322,$0534,$0755,$0644,$0423,$0533,$0323
		dc.w	$0322,$0422,$0433,$0766,$0200,$0407,$0707,$0F02

;Palette of SOURCE2.NEO: Saved by NEOchrome V2.10 by Chaos, Inc.
pal2		dc.w	$0000,$0232,$0454,$0575,$0464,$0343,$0353,$0232
		dc.w	$0232,$0242,$0343,$0676,$0020,$0407,$0707,$0F02

;Palette of SOURCE2.NEO: Saved by NEOchrome V2.10 by Chaos, Inc.
pal3		dc.w	$0000,$0222,$0545,$0757,$0646,$0444,$0535,$0333
		dc.w	$0323,$0424,$0434,$0767,$0002,$0407,$0707,$0F02

;Palette of SOURCE2.NEO: Saved by NEOchrome V2.10 by Chaos, Inc.
pal4		dc.w	$0000,$0223,$0445,$0775,$0664,$0334,$0553,$0333
		dc.w	$0332,$0442,$0443,$0776,$0002,$0407,$0707,$0F02

;Palette of SOURCE2.NEO: Saved by NEOchrome V2.10 by Chaos, Inc.
pal5		dc.w	$0000,$0200,$0733,$0722,$0700,$0700,$0500,$0500
		dc.w	$0300,$0400,$0334,$0766,$0002,$0407,$0707,$0F02
pallog		dc.l	pic+4,black,pal1,black,pal2,black,pal3,black,pal4,black,pal5,black,$ff
oldrez:         dc.w    0
oldscr:         dc.l    0
savereg:        dc.l    0
screen:         dc.l    0
oldpal:         ds.w    16
scpt3		dc.l	1
scpt2		dc.l	1
palpt		dc.l	0
sscreen 	dc.l    1
xpos		dc.w	0 
ypos		dc.w	0
sav_cols        ds.w    16
lb    		dc.b    0
        even
sav_484         dc.w    0
save_118        dc.l    0
freq1		dc.l	0
freq2		dc.l	0
freq3		dc.l	0
vol3		dc.l	0
vol2		dc.l	0
vol1		dc.l	0
physbase	dc.l	0
whs		dc.l	0
whp		dc.l	0
old4:           dc.l    0
oldtb:          dc.l    0
old110:         dc.l    0
old07:          dc.b    0
old09:          dc.b    0
old0b:          dc.b    0
old0d:          dc.b    0
old0f:          dc.b    0
old11:          dc.b    0
old13:          dc.b    0
old15:          dc.b    0
old17:          dc.b    0
old19:          dc.b    0
old1b:          dc.b    0
logpal		dc.l	0
palette		ds.w	32
scpt		dc.l	1
logpt		dc.l	0
timer		dc.l	0
scrpt		dc.l	1
face		dc.l	0
coun		dc.l	0
colcnt		dc.l	0
whend		dc.l	0
whpal		dc.l	0
mon:            dc.b    $08
moff:           dc.b    $12
game1		dc.b	'a:\hithere.mug',0
game2	        dc.b    'a:\hullcity.grz',0   
game3	        dc.b    'a:\thephf.grz',0   
env_str:        dc.b    0,0
cmd_str:        dc.b    0,0
		even
filename	dc.l	0
		ds.w	100
	BSS
fptr:	ds.l	1
scrolline:ds.l	1
times:	ds.b	1

table1	ds.w	400
junk






