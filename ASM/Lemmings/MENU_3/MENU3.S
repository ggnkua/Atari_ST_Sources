* 16 Colour Font Menu by TERMINATOR *

		move.l	4(a7),a3
		move.l	$c(a3),d0
		add.l	$14(a3),d0
		move.l	d0,-(sp)
		move.l	a3,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	$c(a7),sp
	
		move.l	a7,save_stk
		move.l	#my_stack,a7
		move.l	#stk_store,a0
		move.l	save_stk,a1
		sub.l	#160,a1
		move.l	#80,d0
saveit		move.l	(a1)+,(a0)+	
		dbra	d0,saveit	

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,oldstack
		
		opt	o+,w-
		
		move	#2,-(sp)
		trap	#14
		addq.l	#2,sp
		
		sub.l	#$10000,d0
		move.l	d0,screen	

		move.w	#4,-(sp)
		trap	#14
		addq.l	#2,sp
		move.w	d0,res		

		movem.l	$ff8240,d0-d7
		movem.l	d0-d7,oldpal	

		move.b	#$12,$ffffc02
	
		move.w	#0,-(sp)
		move.l	screen,-(sp)
		move.l	screen,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp

		move.l	#15,d0
		movea.l	#$ff8240,a0
black		move.w	#0,(a0)+
		dbf	d0,black

		movea.l	#table,a0
		moveq.l	#1,d0	
table1		addq.b	#1,d0
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		cmp.b	#134,d0	
		bne.s	table1
		move.l	#134,d0	
table2		subq.b	#1,d0
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		cmp.b	#1,d0	
		bne.s	table2
		move.l	#1,d0	
table3		addq.b	#1,d0
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		cmp.b	#179,d0	
		bne.s	table3
		move.l	#179,d0
table4		subq.b	#1,d0
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		cmp.b	#44,d0
		bne.s	table4
		move.l	#44,d0
table5		addq.b	#1,d0
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		cmp.b	#179,d0
		bne.s	table5
		move.l	#179,d0
table6		subq.b	#1,d0
		move.b	d0,(a0)+
		move.b	d0,(a0)+
		cmp.b	#1,d0
		bne.s	table6	
		move.b	#$ff,(a0)+

		lea	picture+2,a0
		lea	$ff8240,a1
		move.w	#15,d0
setpal1		move.w	(a0)+,(a1)+
		dbra	d0,setpal1
	
		move.l	$44e,a0
		move.l	#picture+34,a1
		move.w	#15999,d0
drawscreen	move.w	(a1)+,(a0)+
		dbra	d0,drawscreen
	
		move.l	#1,d0		
		jsr	music
 		move.l	#music+4,$4de
	
		jsr	hblon
	
		clr.b	$fffc02	
	
		lea	scrolltext,a0
		move.b	(a0)+,d0
		move.l	a0,store
	
mainloop	move.w	#37,-(sp)
		trap	#14
		addq.l	#2,sp
		jsr	scroll
	
key		clr.b	$fffc02
		cmp.b	#$02,$fffc02	
		beq	qut
		cmp.b	#$03,$fffc02	
		beq	qut
		cmp.b	#$04,$fffc02	
		beq	qut
		cmp.b	#$05,$fffc02	
		beq	qut
		bra	mainloop

qut		move.b	$fffc02,keypr
		move.w	#1,-(sp)
		trap	#1
		addq.l	#2,sp
		jsr	hbloff

the_end		move.l	#stk_store,a0
		move.l	save_stk,a1
		sub.l	#160,a1
		move.l	#80,d0
unsave		move.l	(a0)+,(a1)+
		dbra	d0,unsave	
		move.b	#$8,$fffffc02
		movem.l	oldpal,d0-d7
		movem.l	d0-d7,$ff8240	
		clr.l	$4de		
		move.l	#$8080000,$ff8820
		move.l	#$9090000,$ff8820
		move.l	#$a0a0000,$ff8820
		move.l	#$707ffff,$ff8820
		move.w	res,-(sp)
		move.l	screen,-(sp)
		move.l	screen,-(sp)
		move.w	#5,-(sp)
		trap	#14
		add.l	#12,sp
		move.l	oldstack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		cmp.b	#$05,keypr	
		beq	out
		moveq	#0,d0
		move.b	keypr,d0
		subq.b	#2,d0
		mulu	#4,d0
		lea	filenames,a0
		add.l	d0,a0
		pea	env
		pea	com
		move.l	(a0),-(sp)
		move.w	#0,-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		add.l	#16,sp
	
out		clr.w	-(sp)
		trap	#1

hblon		move.l  $120,oldtb	
		move.l  $70,old4	
		move.l  $70,new4b+2	
		move.b  $fffffa07,old07	
		move.b  $fffffa09,old09	
		move.b  $fffffa0f,old0f	
		move.b  $fffffa11,old11	
		move.b  $fffffa1b,old1b	
		and.b   #$df,$fffa09	
		and.b   #$fe,$fffa07	
		move.l  #moving_bar,$120
		move.l  #new4,$70	
		or.b    #1,$fffffa07	
		or.b    #1,$fffffa13	
		rts

hbloff		move.w 	sr,-(sp)
		move.w  #$2700,sr	
		move.b  old07(pc),$fffffa07 
		move.b  old09(pc),$fffffa09
		move.b  old0f(pc),$fffffa0f
		move.b  old11(pc),$fffffa11
		move.b  old1b(pc),$fffffa1b
		move.l  oldtb,$120
		move.l  old4,$70
		move.w  (sp)+,sr
		rts

old4:           dc.l    	0
oldtb:          dc.l    	0
old07:          dc.b    	0
old09:          dc.b    	0
old0f:          dc.b    	0
old11:          dc.b    	0
old1b:          dc.b    	0
		even
		
new4		clr.b   	$fffffa1b.w	
		movem.l	a0-a6/d0-d7,-(sp)
		movea.l	tabpos,a0
		cmp.b	#$ff,(a0)
		bne.s	next
		move.l	#table,a0
	
next		move.l	(a0)+,d0
		move.b  d0,$fffffa21	
		move.b  #8,$fffffa1b	
		move.l  #moving_bar,$120
		move.l	a0,tabpos
		move.b	-(a0),d0
		move.l	#199,d1
		sub.b	d0,d1
		move.b	d1,rastpos	
		lea	picture+2,a0
		lea	$ff8240,a1
		move.w	#15,d0
setcol1		move.w	(a0)+,(a1)+
		dbra	d0,setcol1
		movem.l	(sp)+,a0-a6/d0-d7

new4b		jmp    	$12345678

moving_bar	clr.b   $fffffa1b.w	
		movem.l d0-d7/a0-a6,-(sp)
		move.w  #$fa21,a1
		move.b	rastpos,(a1)
		move.b  #8,$fffffa1b.w	
		move.l	#killborder,$120
		move.l	#raster,a0
		move.l	#20-1,d1
loop		move.b  (a1),d0
wait4		cmp.b   (a1),d0		
		beq     wait4	
		move.w	(a0)+,$ff8240
		dbf	d1,loop
end		movem.l (sp)+,d0-d7/a0-a6 
		bclr    #0,$fffffa0f.w
		rte			 

killborder	clr.b   $fffffa1b.w	
		movem.l	d0-d1/a0-a1,-(sp)
		move.w 	#$fa21,a1
		move.b	#0,(a1)
		move.b 	#8,$fffffa1b.w	
		move.b 	(a1),d0
waitl		cmp.b  	(a1),d0		
		beq    	waitl	
		clr.b  	$ffff820a.w	
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b 	#2,$ffff820a.w
		lea	font+2,a0
		lea	$ff8240,a1
		move.w	#15,d0
oldpalet		move.w	(a0)+,(a1)+
		dbra	d0,oldpalet
		movem.l	(sp)+,d0-d1/a0-a1 
		bclr   	#0,$fffffa0f.w
		rte
		
trans		macro
		movep.l	\1(a0),d0
		movep.l	d0,\1-7(a0)
		movep.l	\1+1(a0),d0
		movep.l	d0,\1(a0)
		endm
		
trans1		macro
		movep.l	\1(a1),d0
		movep.l	d0,\1-7(a1)
		movep.l	\1+1(a1),d0
		movep.l	d0,\1(a1)
		endm
		
scroll		bsr	do_scroll
		addq.b 	#1,count1
		cmp.b 	#4,count1
		beq 	nextlet
		rts
nextlet		clr.b	count1
movlet		move.l	store,a0
		move.b	(a0)+,d0
		cmp.b 	#$ff,d0
		beq	wrap
		move.l	a0,store
		sub.b	#32,d0
_z		cmp.b	#53,d0
		blt	_t
		sub.b	#53,d0
		asl	d0
		asl	d0
		asl	d0
		asl	d0
		add.l	#160*128,d0
		bra	out1
_t		cmp.b	#43,d0
		blt	_j
		sub.b	#43,d0
		asl	d0
		asl	d0
		asl	d0
		asl	d0
		add.l	#160*96,d0
		bra	out1
_j		cmp.b	#33,d0
		blt	_9
		sub.b	#33,d0
		asl	d0
		asl	d0
		asl	d0
		asl	d0
		add.l	#160*64,d0
		bra	out1
_9		cmp.b	#16,d0
		blt	_bracket
		sub.b	#16,d0
		asl	d0
		asl	d0
		asl	d0
		asl	d0
		add.l	#160*32,d0
		bra	out1
_bracket	cmp.b	#0,d0
		blt	_rubbish
		asl	d0
		asl	d0
		asl	d0
		asl	d0
		bra	out1
_rubbish	clr.l	d0
out1		lea	font+34,a0
		add.l	d0,a0		
		lea 	data+$9000,a1
		move.w	#32,d0
there		move.w	(a0),(a1)	
		move.w 	2(a0),2(a1)	
		move.w	4(a0),4(a1)	
		move.w	6(a0),6(a1)
		move.w	8(a0),8(a1)	
		move.w	10(a0),10(a1)
		move.w	12(a0),12(a1)	
		move.w	14(a0),14(a1)
		adda.l	#160,a1			
		adda.l	#160,a0
		dbra 	d0,there
		rts
do_scroll:    	
dosy	     	move.w #31,d2
	  	lea data+$9000,a1
	  	movea.l $44e,a0
	  	adda.l	#200*160,a0
dosy1:          movep.l	1(a0),d0
		movep.l	d0,(a0)
		trans	8
		trans	16
		trans	24
		trans	32
		trans	40
		trans	48
		trans	56
		trans	64
		trans	72
		trans	80
		trans	88
		trans	96
		trans	104
		trans	112
		trans	120
		trans	128
		trans	136
		trans	144
		trans	152
		movep.l	(a1),d0
		movep.l	d0,153(a0)
		trans1	0
		trans1	8
                adda.l  #160,a1 
                adda.l  #160,a0 	
                dbf 	d2,dosy1 	
              	rts             	
wrap 	      	move.b #32,d0
	      	lea scrolltext,a0
	      	move.l a0,store
	      	rts			 
table		ds.b	2000
tabpos		dc.l	table
raster		dc.w	$000,$000,$000,$000,$000,$000,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000
		dc.w	$000,$000,$000,$000,$000,$000
keypr		dc.w	0
env		dc.b	0
com		dc.b 	0
dregs		dc.l	10
aregs		dc.l	10
save_stk	dc.l	0
font		incbin	font.pi1
picture		incbin	menu3.pi1
music		incbin	awesome.smf
filenames	dc.l	file1,file2
		even
file1		dc.b	'a:\vroom.prg',0
        	even
file2		dc.b	'',0
		even
scrolltext	dc.b	"   THEYRE LEAN ... THEYRE MEAN ... AND THEYRE SUICIDAL ! ... WELCOME TO THE LEMMINGS MENU THREE ... "
		DC.B	"BROUGHT TO YOU IN TRUE LEMMINGS QUALITY ... ON THIS DISK WE HAVE TWO OF THE BEST MULTI PLAYER GAMES AVAILABLE ... VROOM AND MIDI MAZE ... "
		DC.B	"THE LEMMINGS NOW HAVE TWO NEW MEMBERS ... THEY ARE ... WARMGLOW VINDALOO AND CAPTAIN CLUCK ... BRINGING THE MEMBERS LIST TO ... DARK SORCERER (ME) ... INFO FREAKO ... WARMGLOW VINDALOO ... AND CAPTAIN CLUCK! ... "
		DC.B	"YOU MAY THINK THAT THE LEMMINGS HAVE A SLOW MENU PRODUCTION RATE ... THERE ARE THREE REASONS FOR THIS ... WE LIKE TO HAVE THE TOP QUALITY AND NICE LOOKING MENUS ... WE TEST THEM AS WELL AS POSSIBLE ... WE PUT ONLY GAMES WE"
		DC.B	" LIKE ON MENUS ... NO MATTER HOW OLD ... SO THERE YOU HAVE IT! ... BIG HOWDY DOODYS AND OTHER USELESS PHRASES GO TO ... "
		dc.b 	"...     HYSTERIA (ESPECIALLY NEUROMANCER) ... ADRENALIN" 
		DC.B	" ... THE WILD BOYS (ESPECIALLY SNAZ) ... INSANITY (ESPECIALLY ICEMAN) ... SYNCRO SYSTEMS ... THE MUTANT (CANT WAIT TO SEE THE NEW DEMO!)"
		dc.b    " ... CYNIX (ESPECIALLY SKYWALKER ... NICE CRACKS) ... GENESIS INC. (ESPECIALLY GOR) ... ELECTRONIC IMAGES ... BANANA MAN ... MR.PORNO ... AND ALL OTHER CONTACTS AND FRIENDS OF THE LEMMINGS ... "
		dc.b    "CREDITS FOR THIS MENU ARE AS FOLLOWS:         GRAFIX ... RIPPED FROM GRAND PRIX AND EDITED BY DARK SORCERER          COMPILATION ... DARK SORCERER " 
		dc.b    " MUSIC ... FROM AWESOME (TAKEN FROM THE BRILLIANT NOTER 2 DISK) ... NOW ITS TIME TO BURN YET MORE LATEX ... GUTENTAG! ...               "
		dc.b	" ",$ff
		even
a		dc.b	0
b		dc.b	0
c		dc.b	0
count1		dc.b	3
		even
store		ds.l	1
res		ds.w	1
rastpos		ds.b	1
oldpal		ds.w	16	
screen		ds.l	1
oldstack	ds.l	1
keybuff		ds.b	32
stk_store	ds.l	100
		ds.l	40
my_stack	ds.l	40
data