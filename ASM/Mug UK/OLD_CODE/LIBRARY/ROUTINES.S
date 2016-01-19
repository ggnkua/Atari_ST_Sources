;******************************************************************
; ROUTINES.S is a collection of handy 68000 Macros.	      *
; -------------------------------------------------	      *
;						      * 
; I have compiled this collection from many sources & contacts.   *
; There are even some that I've written  !!!		      *
; They are really easy to use - once you know how !!	      *
;						      *
; For use by: Mike Mee/MUG U.K/EQQYFUMP/Slasher Bog	      *
;******************************************************************
;
; Current Macros available:
; -------------------------
;
; clon	cloff	repon	repoff	st_pal	rs_pal	new_pal
; pen	border	ink	coal	home	cls	ping
; print	cursor	vsync	getrez	mode	flash	wait
; getkey	silence	super(j)	user(j)	bios	xbios	h_reset
; venitian	mouse_off	mouse_on	super	user
;
; CLON/OFF - Use: clon/cloff as appropriate (turns keyboard click on/off)
;
cloff	macro
	bclr	#0,$484
	endm

clon	macro
	bset	#0,$484	
	endm
;
; REPON/OFF - Use: repon/off as approriate (turns keyboard repeat on/off)
;
repoff	macro
	bclr	#1,$484
	endm

repon	macro
	bset	#1,$484	
	endm
;
; ST_PAL - Use st_pal (stores current palette in a buffer)
;
st_pal	macro
	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,old_pal
	endm
old_pal	ds.w	16
;
; RS_PAL - Use rs_pal (restores palette from buffer)
;
rs_pal	macro
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ff8240
	endm
;
; NEW_PAL - Use: new_pal xxxx (xxx = table of 16 words for new palette)
;
new_pal	macro	\1
	movem.l	\1,d0-d7
	movem.l	d0-d7,$ff8240
	endm
;
; PEN - Use: pen $777 - white text
;
pen	macro	\1
	move.w	#\1,$ff825e
	ink	15
	endm
;
; BORDER - Use: border $700 - red border
;
border	macro	\1
	move.w	#\1,$ff8240
	endm
;
; INK - Use: ink xx (0-15) - all printing uses colour xx from now on
;
ink	macro	\1
	move.b	#\1,pr_ink+2	the ink
	lea	pr_ink,a0
	jsr	printline		print it
*	home			necessary to activate it
	endm
pr_ink	dc.b 27,"b",15,0
	even		
;
; COAL - Use: coal (sets all palette to black)
;
coal	macro
	movem.l	allblacks(pc),d0-d7		
	movem.l	d0-d7,$ff8240
	endm	
allblacks	ds.w 	16
;
; HOME - Use: home (sets cursor back to home position)
;
home	macro	\1
	move.l	#pr_home,a0
	jsr	printline
	endm
pr_home	dc.b 27,"H",0
	even
;
; CLS - Use: cls (just clears screen)
;
cls	macro	\1
	move.l	#clsd,a0
	jsr	printline
	endm
clsd	dc.b	27,69,0
;
; PING - Use: ping (sounds the bell)
;
ping	macro	\1
	move.l	#bell,a0
	jsr	printline
	endm
bell	dc.b	7,0
;
; PRINT - Use: print message
;	     message dc.b "Hello World",13,10,0
;
print	macro	\1
	move.l	#\1,a0
	jsr	printline
	endm
;
; PRINTLINE - Do not use directly, is called by above routines
;
printline movem.l	d0-d3/a0-a3,-(sp)
	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts
;
; CURSOR - Use: cursor x
; x = 0 - off     1 - on     2 - flash     3 - steady
;
cursor	macro	\1
	move.w	#\1,-(a7)
	move.w	#21,-(a7)
	trap	#14
	addq.l	#4,a7
	endm
;
; VSYNC - Use: vsync (d0 corrupted - save if necessary)
;
vsync	macro
	move.l	$466,d0
waitv\@	cmp.l	$466,d0
	beq	waitv\@
	endm
;
; GETREZ - Use: getrez - 'rez' holds current resolution
;
getrez	macro
	move.w	#4,-(sp)	;get screen resolution into D0
	trap	#14
	addq.l	#2,sp
	move.l	d0,rez
	endm
rez	ds.l	1
;
; MODE - Use: Mode xx (where xx=0 for LOW & xx=1 for MEDIUM)
;
mode	macro	\1
	move.l	#\1,d0
	cmp.l	#1,d0
	beq	med\@
	tst.l	d0
	beq	low\@
	bra	v\@		if not 0 or 1, ignore	
low\@	jsr	setlowrez
	bra	v\@
med\@	jsr	setmedrez
v\@	vsync
	endm

setlowrez
	clr.w	-(a7)	; 0 = low res
	move.l	#-1,-(a7)	;-1 = ignore physbase
	move.l	#-1,-(a7)	;-1 = ignore logbase
	move.w	#5,-(a7)
	trap	#14		
	lea	$0c(a7),a7	
	rts

setmedrez
	move.w	#1,-(a7)	; 1 = medium resolution
	move.l	#-1,-(a7)	;-1 = ignore physbase
	move.l	#-1,-(a7)	;-1 = ignore logbase
	move.w	#5,-(a7)
	trap	#14		
	lea	$0c(a7),a7	
	rts
;
; FLASH - Use flash xx,yy - eg: 2,5  = 2 flashes lasting 5 vert. blnks
;			  1,10 = 1 long flash lasting 10 vert. blnks
;			  0,0  = ERROR - BOMB OUT !!
;
flash	macro	\2
	move.w	#\1,d7		loop: number of flashes
	sub.w	#1,d7
fl\@	not	$ff8240
	wait	\2		delay inside flash
	not	$ff8240
	wait	\2
	dbra	d7,fl\@
	endm
;
; WAIT - Use: wait 2 = 2/50ths second (wait 50 = 1 second if in 50hz)
;
wait	macro	\1
	movem.l	d5-d6,-(sp)
	move.w	#\1,d6
loop\@	move.l	$466,d5
same\@	cmp.l	$466,d5
	beq	same\@
	dbra	d6,loop\@
	movem.l	(sp)+,d5-d6
	endm
;
; GETKEY - Use:	getkey
;		swap	d0
;		cmp.l	#1,d0	= ESCAPE
getkey	macro
	movem.l	d1-d2/a0-a2,-(sp)
	move.w	#$07,-(sp)
	trap	#1
	addq.l	#2,sp
	andi.w	#$df,d0		force upper case
	movem.l	(sp)+,d1-d2/a0-a2
	endm
;
; SILENCE - Use silence (switches off all sound-channels)
;
silence	macro
	movem.l	d0/a0,-(sp)
	lea	$ff8800,a0
	move.b	#0,d0
lp\@	move.b	d0,(a0)
	move.b	#255,2(a0)
	add.b	#1,d0
	cmp.b	#16,d0
	bmi	lp\@
	movem.l	(sp)+,d0/a0
	endm
;
; Supervisor Mode - Use: jsr super
;
super	macro
	movem.l	d0-d5/a0-a5,-(sp)
	move.l	#$1,-(sp)  
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.l	-(sp)  		enter supervisor mode
	move.w	#32,-(sp) 
	trap	#1
	addq.l	#6,sp
	move.l	d0,savestk	save old stack pointer
	movem.l	(sp)+,d0-d5/a0-a5
	endm
		
savestk	ds.l	1
;
; User Mode - Use: jsr user	(uses 'savestk' as old address)
;
user	macro
	movem.l	d0-d5/a0-a5,-(sp) 
	move.l	savestk,-(sp) 	exit supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d5/a0-a5
	endm
;
; BIOS - Use: bios 10,2 (BIOS number & stack adjust value) 
;
bios	macro	\1,\2
	move.w	#\1,-(sp)
	trap	#13
	addq.l	#\2,sp
	endm
;
; XBIOS - Use: xbios 37,2 (as BIOS command)
;
xbios	macro	\1,\2
	move.w	#\1,-(sp)
	trap	#14
	add.l	#\2,sp
	endm
;
; Hard Reset - Use: h_reset
;
h_reset	macro
	move.l	#$752019f3,$420.w
	move.l	$4.w,a0
	jmp	(a0)
	endm
;
; Venitian Blind Fade Out - Use: venitian (fizzes out a low res screen)
;
venitian	macro
	move.l	$44e,a0
	add.l	#1600,a0
	move.l	a0,a3
	move.l	a0,a2
	move.l	a0,a1
	sub.l	#160,a0
	add.l	#160,a2
	move.l	#9,d2
lp2	move.l	#9,d1
lp1	move.l	#359,d0
lp	move.l	-(a0),-(a1)
	move.l	(a2)+,(A3)+
	dbra	d0,lp

	move.l	#39,d0
lp4	move.l	#0,-(a1)
	move.l	#0,(a3)+
	dbra	d0,lp4

	add.l	#4640,a0
	add.l	#4800,a1
	add.l	#1600,a3
	add.l	#1760,a2
	dbra	d1,lp1

	sub.l	#32000,a0
	sub.l	#32000,a1
	sub.l	#32000,a2
	sub.l	#32000,a3
	wait	2
	dbra	d2,lp2
	endm
;
; MOUSE_OFF - Use: mouse_off
;
mouse_off	macro
	pea	dis_mouse		;enable mouse
	move.w	#0,-(a7)
	move.w	#25,-(a7)
	trap	#14
	addq.l	#8,a7
	endm
	
dis_mouse	dc.b	$12
;
; MOUSE_ON - Use: mouse_on
;
mouse_on 	macro
	pea	ena_mouse		;disable mouse
	move.w	#1,-(sp)		
	move.w	#25,-(sp)		
	trap	#14		
	addq.l	#8,a7		
	endm
	
ena_mouse dc.b	$80,$01
 