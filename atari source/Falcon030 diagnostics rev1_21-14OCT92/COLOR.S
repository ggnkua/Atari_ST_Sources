	.include hardware
	.include defs
	.include nvram

	.globl colortst,resdsp,savdsp
*
*	Color register test
*	13 July 89: tacked on scrolling test

	.text
	.extern colortst
coldel	equ	30

*	Display colors from 16 palette registers
*	All registers are displayed side by side, the width of the screen.
*	Horizontal blank interrupt changes the color every line, so the 
*	effect is horizontal bands of color across the screen.
*	This routine writes a pattern through display memory to select each
*	palette register, from left to right, 0-15, on each line.
*	

colortst:

*	The screen is 320 pixels across by 200 pixels down.
*	Each line displays palette registers 0-15 (16 16 pixel characters
*	across the screen, with an additional 4 characters of register 0
*	preceding.
*	So a line looks like this:
*	reg 0, reg 0, reg 0, reg 0, reg 0, reg 1, reg 2, reg 3  reg 4,  reg 5...
*	0000   0000   0000   0000   0000   1000   0100   1100   0010    1010
*	where 0=word all 0's, 1=word all 1's

*	Write 200 lines into display memory
	move.b	v_shf_mod,d0
	andi.b	#3,d0
	cmpi.b	#2,d0
	bne.s	wcolor

*	skip it if hi-res mode
	lea	nocolor,a5
	bsr	dspmsg
	rts
	
wcolor:	move.w	palette,colsav	;save color to restore later
	
	movea.l	#$20000,a0
color0:	clr.l	(a0)+		;clear display
	cmpa.l	#$28000,a0
	bne.s	color0

	movea.l	#$20000,a0	;display at $20000
	move.l	#199,d0
	moveq	#0,d1		;index thru memory

*	Write a line, 16 characters=16 registers
scrnln:	moveq	#1,d2		;register count
	add.l	#40,d1		;start at 5 char. * 4 words * 2 byte/word

*	Write 4 words in a character, for each of 16 registers
color16:
	clr.l	d3		;word counter (0-3)
*	Check if word is 0 or 1's
tstwrd:	btst	d3,d2		;test (d3) bit of d2 (register 1-15)	
	beq.s	nxtwrd
	move.w	#$ffff,0(a0,d1)	;set all bits in this word
nxtwrd:	addq	#2,d1		;next word
	addq	#1,d3		;next bit to test
	cmpi.b	#4,d3		;4 bits tested?
	bne.s	tstwrd

*	Advance to next character (4 words)
	addq	#1,d2		;next register
	cmpi	#16,d2
	bne.s	color16		;until 16 registers on the screen	
		
	dbra	d0,scrnln	;until 200 lines written

	bsr	savdsp

*	Set new screen memory
	move.b	#$2,v_bas_h
	clr.b	v_bas_m

	move	#0,v_shf_mod	;low res

*	Enable horizontal and vertical blank interrupts
	move.l	$70,vecsav
	move.l	$120,vecsav+4
	move.l	#vblank,$70

	movea.l	#mfp,a0	
	clr.b	iera(a0)	;disable all a interrupts
	move.b	#$40,ierb(a0)	
	move.b	#2,tbdr(a0)	;set to interrupt every 2nd input event
	move.b	#8,tbcr(a0)	;put timer B in event count mode	

	move.l	#chblank,$120
	moveq	#8,d0		;hblank
	bsr	enabint		;enable MFP	

	move.w	#$2200,sr	;allow Vblank interrupt
	clr	colors		;set screen number
	
.if 	prod=0
*	Wait for end--key (single pass) or elapsed time.
	move.b	consol,d0
	andi.b	#$38,d0		;mask multiple test modes	
	bne.s	cdelay		;br if not single pass
.endif

ckeywt:	bsr	conin
	cmpi	#' ',d0
	bne.s	ckeywt

	add	#1,colors	;inc screen number
	cmp	#2,colors	;all done?
	bne.s	ckeywt		;show new screen

	bra.s	cret
	
*	Delay a while 
cdelay:	move	#500,d1
cdel0:	bsr	wait
	dbra	d1,cdel0

*	clean up and return
cret:
	move.w	#$2400,sr
	moveq	#8,d0
	bsr	disint
	bsr	setdsp
	move.l	vecsav,$70
	move.l	vecsav+4,$120

*	do scrolling tests
	bsr	scroll
	bset	#autoky,consol	;bypass next consol-in test
	rts

********************************
*	color test subroutines

*-------------------------------
*	save video base address, palette
savdsp:	clr.l	v_bas_sv
	move.b	v_bas_h,d0
	lsl	#8,d0
	move.b	v_bas_m,d0
	lsl.l	#8,d0
	move.b	v_bas_l,d0
	move.l	d0,v_bas_sv
	move	palette,colsav
	rts

*-------------------------------
*	restore video base address, palette, video mode
resdsp: move	#1,lcount
	move	sr,d6
	move	#$2200,sr
resds0:	cmp.b	#0,lcount
	bne	resds0
	move.b	#1,v_shf_mod
	move.b	v_bas_sv+1,v_bas_h
	move.b	v_bas_sv+2,v_bas_m
	move.b	v_bas_sv+3,v_bas_l
	move	colsav,palette
	move	#$666,palette+6 
	move	d6,sr
	rts
	

***********************************************************************
*	Horizontal blank handler (display enable)
*	This routine used by color test	
*	Display red, green, blue, white, wait for keystroke,
*	then display cyan, magenta, yellow, white.
*	Interrupt occurs every two scan lines
*	There are 68 color changes.
chblank:
	movem.l	d0-d1/a0,-(a7)

	cmpi.b	#68,lcount	;end of screen?
	bgt.s	chbquit		;do nothing

	cmpi.b	#0,lcount	;start of screen?
	bne.s	colset

*	top of display
	clr.b	collin
	
*	Set new colors into palette
colset:	moveq	#coldel,d0	;delay to get off screen
colst0:
	dbra	d0,colst0

	move.l	#coltb0,a0
	cmp	#0,colors	;which screen?
	beq.s	allcol
	move.l	#coltb1,a0
allcol:	moveq	#0,d0
	move.b	collin,d0
	move	0(a0,d0),d1	;get color
	move.l	#palette,a0
*	as fast as possible, write palettes
	move	d1,(a0)+	;put color in palettes
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	move	d1,(a0)+	
	
	addq.b	#2,collin	;increment color index		

chbquit:
	movea.l	#mfp,a0
	bclr	#0,isra(a0)	;clear in-service
	addq.b	#1,lcount	;scan line count
	movem.l	(a7)+,d0-d1/a0
	rte

	.data

*	pick up color for current line here
coltb0:	dc.w	$000,$000,$800,$100,$900,$200,$a00,$300,$b00 ;red
	dc.w	$400,$c00,$500,$d00,$600,$e00,$700,$f00
	dc.w	$000,$000,$080,$010,$090,$020,$0a0,$030,$0b0 ;green
	dc.w	$040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0
	dc.w	$000,$000,$008,$001,$009,$002,$00a,$003,$00b ;blue
	dc.w	$004,$00c,$005,$00d,$006,$00e,$007,$00f
	dc.w	$000,$000,$888,$111,$999,$222,$aaa,$333,$bbb ;white
	dc.w	$444,$ccc,$555,$ddd,$666,$eee,$777,$fff,$000

coltb1:	dc.w	$000,$000,$088,$011,$099,$022,$0aa,$033,$0bb ;cyan
	dc.w	$044,$0cc,$055,$0dd,$066,$0ee,$077,$0ff
	dc.w	$000,$000,$880,$110,$990,$220,$aa0,$330,$bb0 ;magenta
	dc.w	$440,$cc0,$550,$dd0,$660,$ee0,$770,$ff0
	dc.w	$000,$000,$808,$101,$909,$202,$a0a,$303,$b0b ;yellow
	dc.w	$404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
	dc.w	$000,$000,$888,$111,$999,$222,$aaa,$333,$bbb ;white
	dc.w	$444,$ccc,$555,$ddd,$666,$eee,$777,$fff,$000

*	.data	; RWS 09APR92

nocolor: dc.b	'No color--Monochrome monitor',eot

