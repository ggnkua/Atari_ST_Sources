	bra	start
loaddeg 
	move.w 	#$2,-(sp)	Open file 'filename'
	pea 	filename
	move.w 	#$3d,-(sp)
	trap 	#1
	addq.l 	#8,sp
	tst.l	d0
	bmi 	error
	move 	d0,handle
	
	move.l 	#34,noread	Read first 34 bytes = palette
	move.l	#degcols,buffer
	jsr	readdat

	move.l 	#colours,-(sp)  Set palette(+2 cause 1st 2 bytes=screen res)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp	

	clr.l	d5
	clr.l	d6
	move.w	#0,count	Clear counters
	move.w	#0,plane
	move.w	#0,linno

	move.l	#data,buffer	Read correct no of bytes for file
	move.l	#50000,noread
	jsr 	readdat		Read the data

	move.w 	handle,-(sp)	Close file
	move.w	#$3E,-(sp)
	trap	#1
	addq.l	#4,sp

* For this decompacting bit, a5 holds the screen location throughout,
* a6 holds the location in the data,d6 holds the control byte,
* and d4 holds the data itself.

	move.l 	#data,a6	A6 points to data
linloop	bsr 	screenpoint	Find initial screen mem loc->a5
	move.b	(a6),d6		Move control byte into d6
	cmp.b	#128,d6
	beq	add1		Ignore it if control=128
	bmi	literal		Branch if control<128
	bgt	copy		Branch if control>128

add1	addq.b	#1,d6		Add 1 if =128 and continue.

return	cmpi.w	#160,count	If Count>160,plane is finished
	blt	notincplane
	move.w	#0,count	Clear count
	addq.w	#2,plane	Move to next plane
notincplane
	cmpi.w	#6,plane	If plane>6,whole line is finished
	ble	pastplane
	move.w	#0,count	Clear count
	move.w	#0,plane	Clear plane
	addq.w	#1,linno	Add 1 to line number
pastplane
	cmp	#200,linno	If line>200, picture is finished
	blt	linloop		If it's not, carry on
	bra 	finished

*Literal copies the next (d6+1) bytes as they come in the file

literal	addq.b	#1,d6	You have to bloody well add 1 to control byte!!!
	move.l	#0,d4	Clear all of d4
litloop	jsr	findscreen	Find current screen address->a5
	move.b	1(a6),d4	Move data into d4(+1 cause (a6) contains control still)
	move.b	d4,(a5)		Move data onto screen
	jsr 	inccnt		Increment Count
	addq.l	#1,a6		Add 1 to data pointer
	cmp	#1,d6		If you've reached 1 in loop, finish early
	dbeq 	d6,litloop	Do this loop d6 times
	addq.l	#1,a6		Add 1 to a6 for the next control byte
	bra 	return		Go home

*Copy copies the next byte (256-d6) times

copy	sub.w	d6,var256	}Subtract control from
	move.w	var256,d6	}256
	move.w	#256,var256	Put 256 back where it came from
	move.b	1(a6),d4	Move data to be repeated into d4
coploop	jsr	findscreen	Find current screen address->a5
	move.b	d4,(a5)		Move data onto screen
	jsr 	inccnt		Increment Count
	dbra	d6,coploop	Do it d6 times
	addq.l	#2,a6		Move a6 to next Control byte
	bra	return		Go home

*Findscreen works out memory location for next byte to be poked
 
findscreen
	move.l	screen,a5	Base screen
	add.w	count,a5	Add byte count
	add.w	plane,a5	Add plane number
	move.w	linno,d3		add (160*line number)cause 160 bytes per line
	mulu.w	#160,d3
	add.l	d3,a5
	rts

*Increment count like 0,1,7,8,15,16,23,24 etc ad nauseum

inccnt	addq.w	#1,count
	move.w	count,d0
	btst	#0,d0
	bne	even
	addq.w	#6,count
even	rts
	
screenpoint
	move.l	screen,a5	A5 points to screen
	add.w	plane,a5	Add plane offset to a5
	add.w	count,a5	Add byte offset to a5
	clr.l	d6
	clr.l	d4
	
	rts

readdat	move.l 	buffer,-(sp)	Read data
	move.l	noread,-(sp)
	move.w	handle,-(sp)
	move.w	#$3F,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi error
	rts

error
finished
	rts


buffer		ds.l	1
noread		ds.l	1
registers	ds.l	16	
filename 	dc.b 	"a:\champs\title",0  pc1
filelength	ds.l	1
linno		ds.w	1
plane		ds.w	1
count		ds.w	1
var256		dc.w	256

	bra	start
font_name 	dc.b "a:\champs\fontish",0
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
	cmp.w	#3,d0
	beq	highres
	move.l  $44e,oldscr
	move.l  physbase,screen

	movem.l $ffff8240.w,d0-d7	save colors...
	movem.l d0-d7,oldpal		..quickly

	move.l	#scrbuf,d0
	add.l	#256,d0
	and.l	#$ffff00,d0

	move.l	d0,a0
	move.l	#8000,d1
cls1	clr.l	(a0)+
	dbra	d1,cls1

	move.w  #0,-(sp)		set low res
	move.l  d0,-(sp)	phys	
	move.l  screen(pc),-(sp)	log
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp


	move.l	screen,a0
	move.l	#10000,d0
cls	clr.l	(a0)+
	dbra	d0,cls


	bsr	music
	bsr	loaddeg

	move.w  #-1,-(sp)		set low res
	move.l  screen(pc),-(sp)	phys	
	move.l  screen(pc),-(sp)	log
	move.w  #5,-(sp)
	trap    #14
	add.l   #12,sp
	

	lea	colours,a0
	lea	palette,a1	set up palette
	
	move.l	#16-1,d0
paloop	move.w	(a0)+,(a1)+	
	dbra	d0,paloop
	movem.l colours,d0-d7	
	movem.l d0-d7,$ffff8240.w


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

	move.l	#text_1,text_address
	move.l	#scroll,a5	enable scroll interrupt	
	bsr	enable_vbi


hi	bsr     hblon		enable MFP interrupts

*------------------------------------------------
get	
	bsr	getkey
	tst.b	d0
	bne	quit
	bra	get
*-------------------------------------------------
roller
	move.w	pal1,d0
	move.w	#66,d1
	lea	pal1,a0
	lea	pal1+2,a1
rollcj	move.w	(a1)+,(a0)+
	dbra	d1,rollcj
	move.w	d0,pal1+130
	rts
*------------------------------------------------
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
	move.l	#0,$4de
	lea	$ff8800,a0
	move.b	#7,(a0)
	move.b	#255,2(a0)
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
highres
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
silence	dc.b	6,0,7,255,8,0,9,0,10,0,255,0

                even

*-------------------------------------------------------

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
	move.l  #killborder,$120	new timer B vector
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
	move.b  #199,$fffffa21	first raster 199 lines away
	move.b  #8,$fffffa1b	enable timer B
	move.l  #killborder,$120	timer B vector
new4b	jmp     $12345678	pass ontrol to OLD vb vector


killborder
	clr.b   $fffffa1b.w	timer stop
	movem.l d0-d4/a0-a3,-(sp)
	move.w  #$fa21,a1
	move.b  #140,(a1)	changing this number had little effect
	move.b  #8,$fffffa1b.w	this line is essential

	move.b  (a1),d0
wait4	cmp.b   (a1),d0		wait last scanline
	beq     wait4		
	clr.b   $ffff820a.w	60 Hz
	moveq   #3,d0
nopi2	nop			wait a while
	dbf     d0,nopi2
	move.b  #2,$ffff820a.w	50 Hz


	moveq.w #44-1,d2	number of colors in table
	move.l  #pal1,a2 	pal1: color table
	move.l	#pal2,a0
	move.l	#pal3,a3
	move.l	$ff8240,d3
loop
	move.w	(a3)+,d4
	bne	notblack
	move.w	(a2)+,d4
	bra	black
notblack
	add.l	#2,a2
black


	move.b  (a1),d0		get value of timer B
wait	cmp.b   (a1),d0		wait one scanline !
	beq     wait
	move.w	d4,$ff8240
	move.w  (a0)+,$ff8242 	
	dbra    d2,loop
	move.l	d3,$ff8240


	movem.l (sp)+,d0-d4/a0-a3
bill      
	bclr    #0,$fffffa0f.w	end of interrupt
	rte			final exit 

*------------------------------------------

pal1	
	dc.w    $000,$002,$004,$005,$006,$007,$007,$006,$005,$004,$002
	dc.w    $000,$020,$040,$050,$060,$070,$070,$060,$050,$040,$020
	dc.w    $000,$200,$400,$500,$600,$700,$700,$600,$500,$400,$200
	dc.w    $000,$022,$044,$055,$066,$077,$077,$066,$055,$044,$022
	dc.w    $000,$220,$440,$550,$660,$770,$770,$660,$550,$440,$220
	dc.w    $000,$202,$404,$505,$606,$707,$707,$606,$505,$404,$202

pal2
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$111
	dc.w	$111,$222,$222,$333,$444,$555,$666,$777,$666,$555,$444
	dc.w	$333,$222,$222,$111,$111,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000



pal3	
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$002,$002
	dc.w	$003,$003,$004,$004,$005,$005,$006,$007,$006,$005,$005
	dc.w	$004,$004,$003,$003,$002,$002,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

degcols	dc.w	0
colours
	dc.w	$000
	dc.w	$700
	dc.w	$600
	dc.w	$400
	dc.w	$200
	dc.w	$007
	dc.w	$006
	dc.w	$004
	dc.w	$002
	dc.w	$740
	dc.w	$766
	dc.w	$557
	dc.w	$446
	dc.w	$335
	dc.w	$224
	dc.w	$777

 	
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
	add.l	#212*160,d7		line of scroll number 2
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
tscr9	
	bsr	roller
	rts
tscr11	lea	text_1,a0	at end of main message, we come..
	move.b	#32,d0		..here again
	bra	tscr4
tscr11a	lea	text_1,a0	at end of reset message, we come..
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

* call and execute next program

music
	move.l	#environment,-(sp)	call program one
	move.l	#environment,-(sp)
	pea	name1		
	move.w	#0,-(sp)	chain this routine
	move.w	#$4b,-(sp)	execute it
	trap	#1		
	adda.l	#$10,sp
	rts


environment
	dc.b	0,0,0,0,0,0 
name1	dc.b	"a:\champs\music",0
	even


* TEXT FOR MESSAGE *
* speed: 1 to 4 (slow-fast)  5 is stop    255 is end
text_1	
	dc.b	4,"    WELCOME..    ",5
	dc.b	4,"                 "
	DC.B	3,"THIS IS CJ OF THE ETERNAL CHAMPIONS HERE WITH THE "
	dc.b	  "INTRO FOR "
	DC.B	  "                 "
	DC.B	4,"    SPACE DUEL   ",5
	DC.B	4,"                 "
	DC.B	  "       AND       ",5
	DC.B	4,"                 "
	DC.B	  "  MANDELBOT SET  ",5
	DC.B	4,"                 "
	DC.B	3,"THESE PROGRAMS ARE DISTRIBUTED AS PART OF THE FABULOUS BUDGIE UK "
	DC.B	  "LICENCEWARE SCEME, THE GROUP THAT BRINGS ACTION AND "
	DC.B	  "ADVENTURE TO YOUR ST FOR LITTLE MORE THAN THE PRICE "
	DC.B	  "OF A BLANK DISK."
	DC.B	  "                 "
	DC.B	4,"      WOW !!     ",5
	DC.B	4,"                 "
	DC.B	3,"BOTH OF THESE PROGRAMS WERE WRITTEN IN FAST BASIC (WITH 68000 SUBROUTINES, "
	DC.B	  "WHERE NECESSARY).  I WILL TRY TO FIT THE SOURCE CODE FOR BOTH OF THEM ON TO THIS DISK "
	DC.B	  "AFTER I HAVE FINISHED TYPING THIS SCROLL TEXT."
	DC.B	  "                 "
	DC.B	  "THEY WERE WRITTEN BEFORE WE WROTE EXODUS (THE FABULOUS 8 DIRECTIONAL "
	DC.B	  "FAST ACTION 68000 ARCADE GAME BY THE ETERNAL CHAMPIONS !!!! (GO AND BUY IT NOW FROM "
	DC.B	  "YOUR FRIENDLY BUDGIE UK STOCKIST)).  THEY WHERE WRITTEN BY DAVE AND MYSELF WHILST WE "
	DC.B	  "WERE SUPPOSED TO BE GOING TO LECTURES AT NEWCASTLE UNIVERSITY,  BUT CODING WAS MUCH "
	DC.B	  "MORE FUN. "
	DC.B	  "                 "
	DC.B	4,"SPACE DUEL:      ",5
	DC.B	4,"                 "
	DC.B	3,"SPACE DUEL IS BASED ON A GAME THAT I USED TO PLAY WHEN I WAS YOUNGER ( I THINK IT WAS CALLED "
	DC.B	  "SPACE WAR BUT I AM NOT 100 PERCENT SURE).  SPACE DUEL RUNS IN HIGH OR MEDIUM RESOLUTION BUT "
	DC.B	  "IS MUCH BETTER IN HIGH RES SO IF YOU ARE THE LUCKY OWNER OF AN SM125, SM124 OR SOME MEGA "
	DC.B	  "EXPENSIVE MULTI-SYNC THEN PLUG IT IN AND GET BLASTING.  SPACE DUEL IS A TWO PLAYER GAME AND "
	DC.B	  "REQUIRES TWO JOYSTICKS TO PLAY.  EACH PLAY SELECTS THEIR RESPECTIVE SHIPS BEFORE BEING "
	DC.B	  "TRANSPORTED TO THE COMBAT ARENA WHERE THEY MUST BATTLE TO THE DEATH.  THE SUNS GRAVITATIONAL "
	DC.B	  "FIELD MAY HELP YOU ESCAPE YOUR ENEMY BUT BE CAREFUL FOR MANY A BRAVE PIOLT HAS LOST HIS LIFE "
	DC.B	  "IN THE SCORCHING FLAMES."
	DC.B      "                 "
	DC.B	4,"MANDELBROT SET:  ",5
	DC.B	4,"                 "
	DC.B	3,"*** THIS PROGRAM MUST BE RUN IN LOW RES *** "
	DC.B	  "                 "
	DC.B      "THERE IS A READ.ME FILE (MANDEL.DOC) ON THIS DISK THAT EXPLAINS ABOUT MANDELBROT SETS.  "
	DC.B	  "I WILL NOT ATTEMPT TO EXPLAIN THEM HERE BUT WILL GIVE YOU A SUMMARY."
	DC.B	  "                 "
	DC.B	4,"SUMMARY:         ",5
	DC.B	4,  "                 "
	DC.B	3,"MANDELBROT SETS ARE VERY COMPLEX BUT ARE VERY PRETTY, ALSO IF YOU TELL YOUR MATHS TEACHER "
	DC.B	  "ABOUT THEM HE/SHE WILL EITHER BE VERY IMPRESSED AND PUT YOU TO THE TOP OF THE CLASS OR "
	DC.B	  "WILL THINK THAT YOU ARE A RIGHT CREEPY LITTLE SWAT AND GIVE YOU EXTRA HOMEWORK."
	DC.B	  "                 "
	DC.B	4,"END OF SUMMARY   ",5
	DC.B	4,"                 "
	DC.B 	3,"NOW FOR THE GREETINGS:"
	DC.B	  "                 "
	DC.B	4,"HI TO:           ",5
	DC.B	4,"                 "
	DC.B	  "      GOTH       ",5
	DC.B	4,"                 "
	DC.B	4,"OF THE SHAPSHIFTERS"
	DC.B      "                 "
	DC.B	3,"THANKS FOR THE GREAT MUSIC"
	DC.B	  "                 "
	DC.B	4,"      CAMY       ",5
	DC.B	4,"                 "
	DC.B	3,"THE MAIN MAN AT BUDGIE UK WITHOUT WHOSE TIME AND EFFORT THESE GAMES WOULD NOT REACH YOU. "
	DC.B	3,"                 "
	DC.B	4,"   THANKS CAMY!  ",5
	DC.B	4,"                 "
	DC.B	4,"  THE LOST BOYS  ",5
	DC.B	4,"                 "
	DC.B	3,"GREAT DEMOS, WHEN IS MAGGIE3 COMING OUT?"
	DC.B	  "                 "
	DC.B	4,"     STUART      ",5
	DC.B	4,"                 "
	DC.B	3,"WHEN ARE YOU GOING TO START CODING AGAIN? "
	DC.B	  "                 "
	DC.B	4,"     STEVE       ",5
	DC.B	4,"                 "
	DC.B	3,"PLEASE WRITE TO ME AND LET ME KNOW WHAT YOU ARE DOING THESE DAYS."
	DC.B	  "                 "
	DC.B	4,"     E.O.G.      ",5
	DC.B	4,"                 "
	DC.B	4,"END OF GREETINGS!",5
	DC.B	  "                 "
	DC.B	3,"AS ALWAYS I WILL INCLUDE MY ADDRESS JUST IN CASE YOU WANT TO WRITE "
	DC.B	  "TO ME OR SEND ME SOME MONEY OR SOME BLANK DISKS."
	DC.B	  "                 "
	DC.B	4,"ADDRESS:         ",5
	DC.B	4,"                 "
	DC.B	4,"58 CHESTNUT AVE  ",5
	DC.B    4,"                 "
	DC.B	  "BILLERICAY       ",5
	DC.B	4,"                 ",3
	DC.B	  "ESSEX            ",5
	DC.B	4,"                 "
	DC.B	  "CM12 9JG         ",5
	DC.B	4,"                 "
	DC.B    3,"THANK YOU, WELL THAT ABOUT WRAPS IT UP SO ......"
	DC.B	  "                 "
	DC.B	4,"    LET'S WRAP   ",5
	DC.B	  ".............................................."
	DC.B	  ".............................................."
	DC.B	4,"                  "
	dc.b	255			end
	even

vvar1		ds.w	1
vvar2		ds.w	1
text_address	ds.l	6
workspace	ds.l	8	temp storage for character
speed		ds.w	1

bounce		dc.b	1
direction	dc.b	1
line_one	ds.l	1
old_screen_pos  dc.l 	0
		ds.w	8



scrbuf
font		ds.b	2192  	c/set is physically loaded HERE
		ds.b	32768-2192
data		ds.b	32000





