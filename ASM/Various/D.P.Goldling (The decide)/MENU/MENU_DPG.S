***************************************************************************
* SIMPLE MENU, WRITTEN FOR ICTARI USER GROUP, AS A USEFULL (HOPEFULLY)    *
* LEARNING AID. WRITTEN BY D.GOLDING USING DEVPAC 3 MARCH '93. THIS CODE  *
* IS COMMENTED IN MOST PLACES, SO SHOULD BE EASY TO FOLLOW.	DPG'93    *
*************************************************************************** 		

section text
	move.l	a7,a5				Reserve memory for the	
	move.l	4(a5),a5			programs that we want to
	move.l	$c(a5),d0			load. Otherwise, this
	add.l	$14(a5),d0			menu will take up most of
	add.l	$1c(a5),d0			the free ram.This is the
	add.l	#$500,d0			standard procedure and is
	move.l	d0,d1				found in most books/source
	add.l	a5,d1				etc.
	and.l	#-2,d1
	move.l	d1,a7
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move	#$4a,-(sp)	
	trap	#1
	lea	12(sp),sp
main	
	pea	0			clear stack		
	move.w	#$20,-(sp)		set up supervisor mode
	trap	#1			call gemdos
	lea	6(sp),sp		adjust stack	
	move.l	d0,save_stk		save old stack
	dc.w	$a00a			hide off
	bclr	#0,$484.w		turn off keyboard click
	movem.l	$fff8240,d0-d7		save old pallette
	movem.l	d0-d7,spal		in 'spal'
	move	#4,-(sp)		get current res
	trap	#14			call xbios
	lea	2(sp),sp		adjust stack
	move	d0,res			save in in 'res'
	move	#2,-(sp)		get physical screen address	
	trap	#14			call xbios	
	lea	2(sp),sp		adjust stack
	move.l	d0,phys			save in it 'phys'
	move.b	#$12,$fffc02		disable mouse
	move	#0,-(sp)		low res
	pea	-1			leave phys 
	pea	-1			leave logical
	move	#5,-(sp)		set screen using above param's
	trap	#14			call xbios
	lea	12(sp),sp		adjust stack
getlog	move	#3,-(sp)		Get new screen address
	trap	#14			call xbios
	lea	2(sp),sp		adjust stack
	move.l	d0,screen		put address into 'screen'
	move.l	screen,initscreen	and initscreen, for later code
degas	movem.l	pic+2,d0-d7		get piccys pallette
	movem.l	d0-d7,$fff8240		install into registars
	move.l	#$f7d00-1,d0		
	move.l	#pic+34,a0		piccy info
	move.l	#$f8000,a1		screen info
p	move.b	(a0)+,(a1)+		copy piccy to screen
	dbf	d0,p			do, until finished
	moveq	#1,d0			select a tune
	jsr	music			initialise
	move.l	$70.w,oldvbl		save old v blank
	move.l	#vbl,$70.w		install new vbl rout
	clr.w	wfnc			clear video flag
	move.l	#text,scrtext		put scrolly message into 'scrtext'
	bsr	restex			and also registar A1, for a pointer
	add.l	#184*160,screen		pos of scrolltext (184 lines down)
	move.b	Initspeed,speed		set speed of scroller (how long to 
	move.b	speed,VblCnt		wait before a vbl)
loop	bsr	scrlet			do the scroll text
	move	#$ff,-(sp)		test keyboard
	move	#6,-(sp)  		it would waste time testing every
	trap	#1			key, in a main loop, so we test 
	lea	4(sp),sp		the keyboard first. if no keys got
	tst	d0			pressed then we loop.
	beq	loop			no keys then loop
	swap	d0			a key was pressed
	cmp.b	#$39,d0			was it space ?	
	beq	exit			if it was then exit
	cmp.b	#$02,d0			KEY 1
	beq	l_prg1			yes - load program 1
	cmp.b	#$03,d0			KEY 2
	beq	l_prg2			;yes - load program 2
	cmp.b	#$04,d0			KEY 3
	beq	l_prg3			yes - load program 3
	bra	loop			no need to check other keys,so loop
		
exit	clr.l	d1			clear the registars
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	adda.l	#$7d00,a0		do a fast 'clear screen'
cls	movem.l	d1-d7,-(a0)
	dbf	d0,cls
	movem.l	d1-d6,-(a0)
	move.l	oldvbl,$70.w		reset oldvbl
	move.l	res,-(sp)		reset old res
	move.l	phys,-(sp)		reset old phys
	pea	-1			never changed logic, so leave it
	move	#5,-(sp)		set screen to above params.
	trap	#14			call xbios
	lea	12(sp),sp		adjust stack
	movem.l	spal,d0-d7		reset old pallette
	movem.l	d0-d7,$fff8240  	   "          "
	move.b	#$8,$fffc02		en-able the mouse
	bset	#0,$484.w		turn on the key click
	moveq	#0,d0			turn off the music
	jsr	music			   "          "
	move.l	#0,$4d6.w		   "          "
	dc.w	$a009			show mouse
	move.l	save_stk,-(sp)		reset old stack
	move.w	#$20,-(sp)		user mode	
	trap	#1			call gemdos
	lea	6(sp),sp		adjust stack
	clr.l	-(sp)			and quit
        trap	#1			call gemdos
vbl	movem.l	d0-d5/a0-a1,-(sp)	save registers
	move	#$777,$fffff8242.w	make font 'white'
	jsr	music+8			play music
	move.w	#1,wfnc			set video flag
	movem.l	(sp)+,d0-d5/a0-a1	return registers
	rte				end of vbl
* SCROLLER
restex	move.l	scrtext,a1
	clr	d0
	rts
resetx	bsr restex
scrlet	clr.l	d0			clear d0
	move.b	(a1)+,d0		move our char from a1 to d0
	move.l	a1,textptr		put char into a pointer
	cmp.b	#$ff,d0			at end of the message ?
	beq	resetx			
	cmp.b	#0,d0			
	beq	scrlet			yes, so start again
letter	movea.l	screen,a1		address of screen into a1
	lea	fontdat,a0		address of font into a0
	subi.l	#32,d0			start of char's, 32, i.e. space
	lsl	#5,d0			
	adda.l	d0,a0
	move.l	a1,savea1
	lea	build,a1
let	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.b	#$10,d5
wvbl	subi.b	#1,VblCnt
	tst.b	VblCnt
	bne	draw
wait	cmp.w	#1,wfnc
	bne	wait
	clr.w	wfnc
	move.b	speed,VblCnt
draw	lea	build,a0
	move	#16,d2
	move.l	savea1,d3
nxtline	movea.l	d3,a1
	lsl	(a0)+		
	roxl	152(a1)
	roxl	144(a1)
	roxl	136(a1)
	roxl	128(a1)
	roxl	120(a1)
	roxl	112(a1)
	roxl	104(a1)
	roxl	96(a1)
	roxl	88(a1)
	roxl	80(a1)
	roxl	72(a1)
	roxl	64(a1)
	roxl	56(a1)
	roxl	48(a1)
	roxl	40(a1)
	roxl	32(a1)
	roxl	24(a1)
	roxl	16(a1)
	roxl	8(a1)
	roxl	(a1)
	addi.l	#$a0,d3
	subq.b	#1,d2
	cmp.b	#0,d2
	bne	nxtline
	subq.b	#1,d5
	cmp.b	#0,d5
	bne	wvbl
	move.l	textptr,a1
	rts
********************
* FILE LOADING BIT *
********************
load	moveq	#0,d0			turn off music
	jsr	music
	move.l	#0,$4d6.w
	move.l	oldvbl,$70.w		reset old vbl
	dc.w	$a009			bring mouse back
	move.b	#$8,$fffc02		re-enable the mouse
	bset	#0,$484.w		turn on keyboard click
	movem.l	spal,d0-d7		restore the original pallete
	movem.l	d0-d7,$ff8240	
	move	res,-(sp)		push old res
	move.l	phys,-(sp)		and old physical screen
	pea	-1			didn't change logical so leave it
	move	#5,-(sp)		set screen to above param's
	trap	#14			call xbios	
	lea	12(sp),sp		tidy stack 
	move.l	save_stk,-(sp)		reset old stack
	move.w	#$20,-(sp)		user mode
	trap	#1			call gemdos
	lea	6(sp),sp		adjust stack
	pea	env			push enviroment string (null)
	pea	com			push command line string (null)
	move.l	launch,-(sp)		put name of file onto the stack
	move	#0,-(sp)		load & execute file (on the stack)
	move	#$4b,-(sp)		command
	trap	#1			call gemdos
	lea	16(sp),sp		adjust stack	
	clr	-(sp)			if we get this far then something
	trap	#1			is wrong ! So quit

text	dc.b	"HI, IT'S THE DEICIDE HERE WITH A SIMPLE MENU, THAT I HAVE CODED FOR THE ICTARI USER GROUP. AFTER SEEING A REQUEST ON THE FIRST ISSUE OF "
	dc.b	"THE ICTARI DISK MAG, I DECIDED TO WRITE A SIMPLE MENU THAT WOULD HOPEFULLY BE A USEFUL LEARNING AID (WELL TO SOME PEOPLE, ANYWAY). THIS MENU DOES NOT "
	dc.b	"FEATURE ANYTHING YOU'D CONSIDER MIND BLOWING CODE, I'VE KEPT IT QUITE SIMPLE, SO IT'S EASIER TO UNDERSTAND. YOU SHOULD FIND THE FULL SOURCE "
	dc.b	"CODE ON THE DISK, WHICH IS COMMENTED THROUGHOUT, SO YOU SHOULDN'T HAVE TOO MUCH TROUBLE WORKING OUT HOW IT'S DONE. THERE MAY BE SOME OTHER FILES "
	dc.b	"I HAVE WRITTEN, INCLUDING MY FIRST EVER DOC DISPLAYER, WHICH CONTAINS USEFUL INFORMATION, CONTAINED IN THE DOC'S. IF YOU HAVE ANY PROBLEMS WITH ANY OF "
	dc.b	"MY SOURCE, THEN PLEASE WRITE TO ME, AT THE ADDRESS GIVEN IN THE DOC DISPLAYER                          ........WRAP........                                 "                  
	dc.b	$ff
l_prg1	move.l	#proga,launch		put program 1 into "launch"
	bra	load			load what's in "launch"
l_prg2	move.l	#progb,launch
	bra	load
l_prg3	move.l	#progc,launch
	bra	load

fontdat	incbin	fontish			our font-from Budgie
pic	incbin	piccy.pi1		our menu piccy
music	incbin	madmax40.mus  		j. hoppel (alias mad max) music	
	
proga	dc.b	'genst2.PRG',0,0	program name of 1st proggy
	even
progb	dc.b	'PVKILL.PRG',0,0	name of 2nd
	even
progc	dc.b	'FCOPYPRO.PRG',0,0	and 3rd
	even
Initspeed	dc.b	6		speed of scroller-works by delaying 
	even				the vbl

oldvbl		ds.l	1
wfnc		ds.w	1
save_stk	ds.l	1
build		ds.l	8
savea1		ds.l	1
screen		ds.l	1
initscreen	ds.l	1
VblCnt		ds.b	1
speed		ds.b	1
scrtext		ds.l	1
textptr		ds.l	1
res		dc.w	0
spal		ds.w	16
launch	dc.l	0	
com	dc.b	0
	even
env	dc.b	0
	even	
phys	dc.l	0





	
