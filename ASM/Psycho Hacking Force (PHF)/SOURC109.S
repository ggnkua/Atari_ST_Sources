; SOURCE INTRO

; Coded: 17-18 April 1992

; Credits >

; Main Coding ( Rasters/Stars/Zak Bars )........Grazey
; Neo Graphix...................................Grazey
; Movep Scroll Code.............................Tony B
; Zak...........................................Chris Mad of Ghost
; Zak Ripping/Relocation........................Grazey
; Menu Compiling................................Mug UK! ( The easy part! )

; The P.H.F. Are:

; Cal ( Amiga Coder )

; Grazey ( C64/ST Coder,GFX )

; Johnny 99 ( ST/Amiga Coder )


; Set Tabs to 8

; Sorry for not documenting this source but I have n't the time.

; If you want to use it on another menu then it should be easy to
; change the music,logo/raster/font colours etc.

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
		
	opt	x-		; Fuck you ripper
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


;d	LEA	music,A0
;	LEA	$67daa,A1
;	MOVE.L	#musend-music,D0
;.loop	MOVE.B	(A0)+,(A1)+
;	sub.l	#1,d0
;	bne	.loop
;	jsr	$67daa

	moveq	#1,d0
	jsr	music

	movem.l $ffff8240.w,d0-d7	
	movem.l d0-d7,oldpal		

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
	move.l	#table2,a4
	add	#8,a4
	move.l	a4,scpt2
	move.l	#table3,a4
	add	#8,a4
	move.l	a4,scpt3

	move.l	screen,a0
	add	#160*31,a0
	add.w	#8,a0
	move.l	a0,scrpt

       	bsr     hblon		

	lea	pic+128,a0
	move.l	screen,a1
	add.l	#480,a1
	move.w	#160*100,d1
putpic	move.w	(a0)+,(a1)+
	dbra	d1,putpic
	


get	move.b	$ffffc02,d0
	cmp.b	#$39,d0		space		; Temporary!
	beq	yehh

	cmp.b	#$3b,d0		;F1
	bne	.l1
	move.l	#game1,filename
	bra	yehh

.l1	cmp.b	#$3c,d0		;F2
	bne	.l2
	move.l	#game2,filename
	bra	yehh

.l2	cmp.b	#$3d,d0		;F3
	bne	.l3
	move.l	#game3,filename
	bra	yehh

.l3	cmp.b	#$3e,d0		;F4
	bne	.l4
	move.l	#game4,filename
	bra	yehh

.l4	cmp.b	#$3f,d0		;F5
	bne	.l5
	move.l	#game5,filename
	bra	yehh

.l5	add.l	#1,timer

	cmp.l	#500,timer
	bne	.loop	
	move.l	#1,timer
	move.l	logpt,a0
	cmp.l	#$ff,(a0)
	bgt	.ll
	move.l	#pallog,logpt
	move.l	logpt,a0
.ll	move.l	(a0),logpal
	add.l	#4,logpt
.loop	bra	doline
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
        move.l  $70,new4b+2
	move.b  $fffffa07,old07
	move.b  $fffffa09,old09
	move.b  $fffffa0f,old0f
	move.b  $fffffa11,old11
	move.b  $fffffa1b,old1b
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
	move.b  old07,$fffffa07
	move.b  old09,$fffffa09
	move.b  old0f,$fffffa0f
	move.b  old11,$fffffa11
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
	move.w	#$707,$ff8242	;Bar colours
	move.w	#$700,$ff8244
	move.w	#$007,$ff8246
	move.w	#$070,$ff8248
	move.w	#$077,$ff824a
	move.w	#$770,$ff824c
	move.w	#$740,$ff824e
	move.w	#$704,$ff8250
	movem.l d0-a6,-(sp)			 
	jsr	music+8		;Zak
	jsr	scroll		;Movep
	jsr	killstars	;Stars
	jsr	updatexpos
	jsr	plotstars
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
.loop	movem.l (sp)+,d0-a6			
new4b:  jmp     $12345678


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
		move.b	#21,(a0)	 
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
                move.l  #killbord,$120
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



; ZAK BARS CODED BY GRAZEY, 3 PLANE MULTI FREQ

; DON'T TRY TRACING THROUGH THIS CODE, IT'LL ONLY DRIVE YOU CRAZY

doline	lea	$ffff8800,a1

	move.b	#0,(a1)		
	clr	d0
	move.b	(a1),d0
	move.b	#8,(a1)		* register 8
	clr	d1
	move.b	(a1),d1

	bsr	draw1

	move.b	#2,(a1)		
	clr	d0
	move.b	(a1),d0
	move.b	#9,(a1)		* register 8
	clr	d1
	move.b	(a1),d1

	bsr	draw

	move.b	#4,(a1)		* register 10
	clr	d0
	move.b	(a1),d0
	move.b	#10,(a1)	
	clr	d1
	move.b	(a1),d1
	bsr	draw2

	move.b	#6,(a1)		* register 10
	clr	d0
	move.b	(a1),d0
	move.b	#10,(a1)	
	clr	d1
	move.b	(a1),d1
	bsr	draw
	bsr	decr
	bra	drawit

draw	move.l	#table1,a4
	asl	#1,d0
	add.w	d0,a4	
	and.w	#255-16,d1
	move.w	d1,(a4)
	rts

draw1	move.l	#table2,a4
	asl	#1,d0
	add.w	d0,a4	
	and.w	#255-16,d1
	move.w	d1,(a4)
	rts

draw2	move.l	#table3,a4
	asl	#1,d0
	add.w	d0,a4	
	and.w	#255-16,d1
	move.w	d1,(a4)
	rts

decr	move.w	#254,d1
	move.l	#table1,a4
.loop	cmp.w	#0,(a4)
	beq	.jump
	sub.w	#1,(a4)
.jump	add.w	#2,a4
	dbra	d1,.loop

decr2	move.w	#254,d1
	move.l	#table2,a4
.loop	cmp.w	#0,(a4)
	beq	.jump
	sub.w	#1,(a4)
.jump	add.w	#2,a4
	dbra	d1,.loop

decr3	move.w	#254,d1
	move.l	#table3,a4
.loop	cmp.w	#0,(a4)
	beq	.jump
	sub.w	#1,(a4)
.jump	add.w	#2,a4
	dbra	d1,.loop
	rts

drawit	clr	d2		;I've just copied the 3 routs for speed purposes
	clr	d7
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

.l3	cmp.w	#31,d0		;I've shortened their height to 32
	ble	.l4
	move.w	#31,d0
.l4	move	#31,d1
	sub	d0,d1
	cmp	#0,d0
	beq	.l5

.l6	move.b	#126,(a0)		;Change '126' for widths
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

drawi2	clr	d2
	clr	d7
	move	#39,d7
	move.l	scpt2,a4
	move.w	#2,d2

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

.l3	cmp.w	#31,d0		;I've shortened their height to 32
	ble	.l4
	move.w	#31,d0
.l4	move	#31,d1
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


drawi3	clr	d2
	clr	d7
	move	#39,d7
	move.l	scpt3,a4
	move.w	#0,d2

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

.l3	cmp.w	#31,d0		;I've shortened their height to 32
	ble	.l4
	move.w	#31,d0
.l4	move	#31,d1
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
	bra	get


killbord
        clr.b   $fffa1b
        bclr.b  #0,$fffffa0f.w
        move.w  #$2200,sr
        move.l  #kill2,$120
        move.b  #1,$fffa21
        move.b  #8,$fffa1b
        st      lb
.loop   tst.b   lb
        bne.s   .loop
        rte
        
kill2
        clr.b   $fffa1b
        move.l  d0,-(sp)
        move.w  #$26,d0
.lp1    dbf     d0,.lp1
        move.b  #0,$ffff820a.w
        move.w  #$1,d0
.loop   dbf     d0,.loop
        move.b  #2,$ffff820a.w
        move.l  #kill3,$120
        move.w  #31,d0
.do     dbf     d0,.do
        move.b  #1,$fffa21
        move.b  #8,$fffa1b
        sf      lb
        bclr.b  #0,$fffffa0f.w
        move.l  (sp)+,d0
        rte
        
kill3	movem.l d0/a0/a1,-(a7)
        clr.b   $fffa1b
        rept    62
        nop
        endr
	move.w	#$765,$ff8242	;Font pal
	move.w	#$654,$ff8244
	move.w	#$543,$ff8246
	move.w	#$432,$ff8248
	move.w	#$321,$ff824a
	move.w	#$210,$ff824c
	move.w	#$005,$ff824e
	move.w	#0,$ff8240
        sf      lb
        bclr.b  #0,$fffffa0f.w
        movem.l (a7)+,d0/a0/a1
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

music	incbin	"d:\musichak.mug\kidney.thk\kidney1.thk"
musend	even
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
	dc.b	"WELCOME TO THE SOURCE MENU 109 !!  QUICK CREDITS FOR THIS MENU "
	dc.b	"MUST ZOOM ALONG TO:   CODING BY GRAZEY (OF THE PHF)    SOURCE LOGO BY "
	dc.b	"GRAZEY (OF THE PHF)    MENU COMPILING BY MUG U.K (OF THE SOURCE)    "
	dc.b	"MUSIC BY THE HEAVY KILLERS (FROM THE KIDNEY BEAN DEMO) AND THIS BANAL "
	dc.b	"SCROLLTEXT WHICH YOU ARE READING WAS TYPED OUT BY MUG U.K (WHEN THEY WERE "
	dc.b	"PLENTY OF OTHER JOBS TO BE DONE, BUT I HAD TO GET THIS MENU READY FOR "
	dc.b	"DISTRIBUTION TOMORROW !!).     "

	dc.b	"NOT MUCH DEMOS-WISE ON THIS DISK AS THERE IS ONLY THE ONE BIG DEMO AND A LITTLE DEMO-ETTE BY ME !!  "
	dc.b	"THERE WAS SUPPOSED TO BE A LINK-FILED VERSION OF THE 'NOVASOUND' DEMO, BUT I COULDN'T GET THE DAMN "
	dc.b	"LINK-FILE ROUTINE TO WORK WITH THIS DEMO (OR IS THAT VICE VERSA !!).  ANYWAY "
	dc.b	"I GAVE UP IN THE END AND JUST DID A 'TRAP #1' VERSION INSTEAD !!    "
	dc.b	"THE OTHER DEMO IS A SOUNDTRACKER ONE THAT I'VE HAD LYING ON MY HARD-DRIVE FOR A "
	dc.b	"WHILE WAITING FOR A SUITABLE SOURCE DISK TO FIT IT ONTO.  THE MODULE IS ONE FOR ALL "
	dc.b	"YOU METAL-MERCHANTS OUT THERE AND IT CAME FROM AN ANCIENT AMIGA DEMO I FOUND LYING AROUND "
	dc.b	"IN MY MATES COMPUTER SHOP !!  ONE QUICK PORT TO AN ST-FORMATTED DISK, ASSEMBLE THE ROUTINE "
	dc.b	"(INCLUDING THE PICTURE FROM THE SAME AMIGA DEMO), PACK IT AND SHOVE IT ON A DISK !! "
	dc.b	"THE TUNE IS QUITE A LONG ONE AND IT MAKES A CHANGE FROM THE USUAL CRAP THAT SOUNDTRACKER "
	dc.b	"MODULES CONSIST OF (EG. NO 'AH YEAH' TYPE SAMPLES !!).  ANYWAY, I LIKE IT SO I PUT IT OUT AS "
	dc.b	"A WEE DEMO SO LOAD IT UP OUT OF INTEREST AND LEAVE IT PLAYING IF YOU LIKE IT.  THE DEMO ITSELF "
	dc.b	"WILL PERFORM A HARDWARE RESET IF YOU PRESS SPACE TO QUIT !!    "
	
	DC.B	"THE OTHER TWO ITEMS OF INTEREST ARE TWO LITTLE GAMES THAT I FOUND LYING AROUND, "
	DC.B	"SO I PACKED THEM BOTH AND PUT A TRAINER VERSION ONTO 'ROCKFALL' SO THAT YOU CAN "
	DC.B	"PLAY THE WHOLE GAME WITHOUT DYING !!  "
	
	DC.B	"THE REST OF THIS DISK IS TAKEN UP WITH A LOAD OF MUSIC HACKS THAT I HAVE DONE OVER "
	DC.B	"THE LAST FEW MONTHS.  THE MUSIC ON THE DISK ARE FROM THE 'JUST BUGGIN' DEMO BY ACF, "
	DC.B	"THE 'KIDNEY BEAN' DEMO BY THK, SOME MUSIC BY ALASTAIR BRIMBLE (COMPOSER FOR 'CODEMASTERS') "
	DC.B	"AND SOME MUSIC FROM A FINNISH SOUNDCHIP TRACKER WHICH I "
	DC.B	"WAS GIVEN BY SLASHER BOG OF SPECIAL FX (I ALSO FOUND A DEMO REGARDS THIS TRACKER ON AN "
	DC.B	"ANIMAL MINE DISK AND SHOVED THAT INTO THE SELF-EXTRACTING ARCHIVE !!).  "
	DC.B	"IN TOTAL THERE ARE 48 FILES OF MUSIC AND SOME OF THEM HAVE 7-8 DIFFERENT TUNES IN THEM, SO "
	DC.B	"THEY SHOULD KEEP THE MENU MAKERS OF THIS WORLD HAPPY BECAUSE FOR ONCE THEY DON'T HAVE TO USE "
	DC.B	"MAD MAX MUSIC !!         "

	DC.B	"SEEING AS THIS SCROLLER IS A QUICKLY MADE UP ONE, I CANNOT BE BOTHERED DOING THE REAMS "
	DC.B	"AND REAMS OF GREETINGS THAT I SHOULD DO, BUT IF YOU ARE A GREETINGS FANATIC, THEN GET HOLD OF "
	DC.B	"THE SOURCE MENU 107 (WHICH I ALSO COMPILED) AND SEE IF YOU ARE IN THERE !!    "
	
	DC.B	"THIS IS THE END OF THE SHORTEST SCROLLER THAT I HAVE EVER WRITTEN FOR A SOURCE MENU, SO I SUGGEST "
	DC.B	"YOU RUN ONE OF THE TWO DEMOS, PLAY ONE OF THE TWO GAMES, OR EXTRACT THE TON OF MUSIC THAT IS ON THE DISK !!  "

	DC.B	"IT'S GOODBYE FOR NOW, BUT I'LL BE BACK ..............   "

	DC.B	"WARPING SCROLLER BACK TO THE BEGINNING                 "
	
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
physbase	dc.l	0
whs		dc.l	0
whp		dc.l	0
old4:           dc.l    0
oldtb:          dc.l    0
old07:          dc.b    0
old09:          dc.b    0
old0f:          dc.b    0
old11:          dc.b    0
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
game1		dc.b	'novasoun.mug',0
game2	        dc.b    '',0   
game3	        dc.b    'rockfall\rockfall.prg',0   
game4		dc.b	'',0
game5		dc.b	'thrash.mug',0
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
table2	ds.w	400
table3	ds.w	400







