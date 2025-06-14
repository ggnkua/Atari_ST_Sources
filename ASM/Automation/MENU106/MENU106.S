		
;
;Super low border bouncy scroller
;      by Sub Humans In Turkey
;
;
vsync	equ 	$25
superx	equ	38
xbtimer	equ	31
jenabin	equ	27
jdisint	equ	26
c_conin	equ	1
c_conis	equ	11
vbl.vec	equ	$70
hbl.vec	equ	$120
tmrb.ctl equ 	$fffa1b
tmrb.dat equ 	$fffa21
mfp.ier	equ	$fffa07
mfp.imr	equ	$fffa13
;
;Go into supervisor mode for rest of program.
;Call main.program
;
;

	MOVE.L	A7,A5
	MOVE.L	$4(A5),A5
	MOVE.L	#$800,D0
	MOVE.L	D0,-(A7)
	MOVE.L	A5,-(A7)
	MOVE.W	#0,-(A7)
	MOVE.W	#$4A,-(A7)
	TRAP	#$01
	ADD.L	#12,A7

	lea	$50000,a0		;CLEAR REGS
	move.w	#$20,d0
cloop1	clr.l	(a0)+
	dbf	d0,cloop1
	movem.l	$50000,d0-d7/a0-a6
	move.l	superflg,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq	#6,a7
	move.l	#$80000,a7
	
	bsr	mainprog
	
	move.b	sd0,d0
	cmp.b	#$31,d0
	beq.s	doone
	cmp.b	#$32,d0
	beq.s	dotwo
	
doone	lea	file1,a5
	bra.s	normal
	
dotwo	lea	file2,a5
	lea	fold1,a4
		
dofold	move.l	a4,-(a7)
	move.w	#$3b,-(a7)
	trap	#$01
	addq.l	#6,a7
	
normal	move.l	a5,fadd+2

	clr.l	$60000
	clr.w	-(sp)
	pea	$60000
	pea	$60000
fadd	move.l	#$ffffffff,-(sp)
	move.l	#$4b0000,-(sp)
	trap	#1
	
	clr.l	-(a7)
	trap	#$01
	
file1	dc.b	"rvfhonda.law",0
file2	dc.b	"tom.ozz",0
	
fold1	dc.b	"tom_n_je.rry",0

superflg		dc.l	0


;
;main program start
;
;
;
mainprog
	pea 	disablemouse(pc)    	;disable mouse
	move.w	#0,-(sp)		;
	move.w	#25,-(sp)		;
	trap	#14			;
	addq.l	#8,a7			;
	
	move.w	#4,-(sp)		;store current rez
	trap	#14			;
	add.w	#2,sp			;
	move.w	d0,cur_rez		;
	
	move.b	#0,$ff8260		;set low rez
	
	move.l	#$ff8240,a0		;save current colours
	lea	sav_cols(pc),a1		;
	move.w	#7,d0			;
.coloop	move.l	(a0)+,(a1)+		;
	dbf	d0,.coloop		;

	move.l	$462,d0			;wait on vblank
.wait	cmp.l	$462,d0			;
	beq.s	.wait			;

	move.l	scrbase,$45e		;set screen address $76000
	
	bsr	flip_screen		;to $76000

	bsr	fix_text		;modify ascii codes to suit
					;character set ,only capital
					;A-Z,0-9,.!"*()-,?
	move.l	$462,d0			;wait on vblank
.wait2	cmp.l	$462,d0			;
	beq.s	.wait2			;

	bsr	enable.lowborder	;init HBL & VBL routines
	
	move.l	#$5,d0
	bsr	music
	
	move.l	#text,textptr		;set ptr to text
	
	move.l	a0,a1			;blank low border
	move.l	scrbase,a1
	add.l	#197*160,a1	;
	move	#50*40,d0		;
.loop1	clr.l	(a1)+			;
	dbf	d0,.loop1		;
	
	bra main.loop			;Go main loop
;
;Path data for text bouncing.
;On speed 1 it follows exact path.
;On speed 2 & 3 it uses every second step.
;
bounce	dc.w	219,217,215,213,211,210,209,208,207
	dc.w	206,205,204,203,202,201,201,200
	dc.w	200,200,199,199,199,200,200,200,201
	dc.w	201,202,203,204,205,206,207,208
	dc.w	209,210,211,213,215,217,219
	even
	
main.loop
;	move.w	#$333,$ff8240		;uncomment to see amount
					;of time left in VBL
					
	move.l	$462,d0			;wait VBL
.lll	cmp.l	$462,d0			;
	beq.s	.lll			;
	
;	move.w	#0,$ff8240		;uncomment also as above

	move.w	bounce_ctr,d6		;position in bounce table
	and.w	#$7e,d6			;return to start if past end
	move.w	bounce(pc,d6.w),d1	;move value to print routine
	move.w	bounce_speed,d6		;add current speed (1 or 2)
	add.w	d6,bounce_ctr		;increment pos in table
	cmp.w	#80,bounce_ctr		;if less than 80 do not
	ble	.next			;reset pos
	move.w #0,bounce_ctr		;
	
.next	moveq	#12,d7			;number of chars to print
	move.l	scrbase,a0
	sub.l	#10,a0		;
	move.w	textpix,d2		;
	move.l	#charset,a1		;start of charset
	move.l	textptr,a2		;pointer within charset
.putchrlp
	tst.b	(a2)			;end of text ?
	bne.s	.skip1			;
	move.l	#text,a2		;yes - reset to start
	
.skip1	clr.l	d0			
	move.b	(a2)+,d0		;check for small chars
	cmp.b	#73,d0			;Char I
	bne	.one			;
	move.w	#24,spacer		;  allow 24 pixels wide
	bra	.three			;
.one	cmp.b	#92,d0			;Char 1
	bne	.two			;
	move.w	#24,spacer		;  allow 24 pixels wide
	bra	.three			;
.two	move.w	#32,spacer		;otherwise 32 pixels

.three	sub.w	#64,d0			;ascii code - 64
	bcc.s	.skip3			;
	clr.l	d0			;
	
.skip3	movem.l	d1-d2/d7/a0-a2,-(sp)	;preserve registers
	bsr	put.char		;print character
	movem.l	(sp)+,d1-d2/d7/a0-a2	;restore registers
	
	add	spacer,d2		;add on char length
	dbf	d7,.putchrlp		;round until chars = 12
	
	move.l	textptr,a3		;check for special chars
	move.b	(a3),d6			;in text.
	cmp.w	#110,d6			;bounce current text
	beq	.spec1			;
	cmp.w	#111,d6			;load next file (ask EGB)
	bne	.skip_adder		;
	move.w	textpix,d2		;pixel position of char
	sub.w	scroll_speed,d2		;pixel pos - scroll speed
	bra	.fix			;go fix
.spec1	move.w	#0,scroll_speed		;stop scrolling for while
	sub.w	#1,adder		;loop 100 times
	bpl	.skip_adder		;while plus
	move.w	#100,adder		;reset to 100
	move.w	old_speed,scroll_speed	;restore old speed
	move.w	textpix,d2		;restore pix pos
	sub.w	scroll_speed,d2		;minus scroll
	bra	.fix			;go fix
.skip_adder
	move.w	textpix,d2		;pix pos
	sub.w	scroll_speed,d2		;minus scroll
	bcc	.nofix			;no carry no fix
	
.fix	move.l	textptr,a0		;check for small chars		
	move.b	(a0),d6			;again to repair proportional
	cmp.b	#73,d6			;spacing
	bne	.four			;
	move.w	#24,spacer2		;
	bra	.six			;
.four	cmp.b	#92,d6			;
	bne	.five			;
	move.w	#24,spacer2		;
	bra	.six			;
.five	move.w	#32,spacer2		;
.six	add.w	spacer2,d2		;

	add.w	#1,a0   		;add 1 to text pos
	tst.b	(a0)			;test
	bne.s	.skip2			;is it end
	move.l	#text,a0		;yes - reset text to start
.skip2	move.l	a0,textptr		;no - move new pointer
.nofix	move.w	d2,textpix		;ok where it is

.getkey	move.w #$ff,-(sp)		;check keyboard
	move.w #6,-(sp)			;
	trap #1				;
	add.w #4,a7			;
	tst.w d0			;anything happening ?
	beq main.loop
	cmp.b #$30,d0
	beq	tog_hz
	cmp.b	#$31,d0
	blt	main.loop
	cmp.b	#$32,d0
	bgt	main.loop
	move.b	d0,sd0
	
.exit	bsr	disable.lowborder	;kill lowborder
	pea	enablemouse(pc)		;feed mouse
	move.w	#1,-(sp)		;
	move.w	#25,-(sp)		;
	trap	#14			;
	addq.l	#8,a7			;
	
	move.l	$462,d0			;wait VBL
.wait	cmp.l	$462,d0			;
	beq.s	.wait			;
	
	move.l	#0,$45e			;reset screen ptr

	move.b	hz50_60,$ffff820a		;set hertz rate
		
	clr.w	-(sp)		;reset rez
	move.l	#$78000,-(sp)		;restore normal screen
	move.l	#$78000,-(sp)		;
	move.w	#5,-(sp)		;
	trap	#14			;
	add.w	#12,sp			;
	
	lea	screen+$22,a0
	lea	$78000,a1
	move.w	#$1f3f,d0
picloop1	move.l	(a0)+,(a1)+
	dbf	d0,picloop1
	RTS

tog_hz	lea	old_colour,a0
tog_hz2	eor.w	#$111,(a0)+
	eor.b	#2,hz50_60
	bra.w	main.loop

hz50_60	dc.b	2
sd0	dc.b	0

	even


flip_points
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,39
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,39
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,39
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,39,19
	dc.b	00,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,39,19
	dc.b	00,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,39,29,19
	dc.b	09,00,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,39,34,29,24,19
	dc.b	14,09,04,00,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,39,36,34,31,29,24,19
	dc.b	14,09,07,04,02,00,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,39,36,34,31,29,26,24,21,19
	dc.b	17,14,12,09,07,04,02,00,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,39,36
	dc.b	35,34,32,31,29,27,26,24,21,19
	dc.b	17,14,12,11,09,07,06,04,03,02
	dc.b	00,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,39,38,36,35,34,32
	dc.b	31,29,28,27,26,24,22,21,20,19
	dc.b	18,17,15,14,12,11,10,09,08,07
	dc.b	06,04,03,02,00,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,39,38,36,35,34,32
	dc.b	31,29,28,27,26,24,22,21,20,19
	dc.b	18,17,15,14,12,11,10,09,08,07
	dc.b	06,04,03,02,00,41,41,41,41,41
	dc.b	40
	dc.b	39,38,37,36,35,34,33,32,31,30
	dc.b	29,28,27,26,25,24,23,22,21,20
	dc.b	19,18,17,16,15,14,13,12,11,10
	dc.b	09,08,07,06,05,04,03,02,01,00
	dc.b	40
	dc.b	39,38,37,36,35,34,33,32,31,30
	dc.b	29,28,27,26,25,24,23,22,21,20
	dc.b	19,18,17,16,15,14,13,12,11,10
	dc.b	09,08,07,06,05,04,03,02,01,00
	dc.b	40
	dc.b	39,38,37,36,35,34,33,32,31,30
	dc.b	29,28,27,26,25,24,23,22,21,20
	dc.b	19,18,17,16,15,14,13,12,11,10
	dc.b	09,08,07,06,05,04,03,02,01,00
	dc.b	40
	dc.b	39,38,37,36,35,34,33,32,31,30
	dc.b	29,28,27,26,25,24,23,22,21,20
	dc.b	19,18,17,16,15,14,13,12,11,10
	dc.b	09,08,07,06,05,04,03,02,01,00
	dc.b	40
	dc.b	41,41,41,41,39,38,36,35,34,32
	dc.b	31,29,28,27,26,24,22,21,20,19
	dc.b	18,17,15,14,12,11,10,09,08,07
	dc.b	06,04,03,02,00,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,39,38,36,35,34,32
	dc.b	31,29,28,27,26,24,22,21,20,19
	dc.b	18,17,15,14,12,11,10,09,08,07
	dc.b	06,04,03,02,00,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,39,36
	dc.b	35,34,32,31,29,27,26,24,21,19
	dc.b	17,14,12,11,09,07,06,04,03,02
	dc.b	00,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,39,36,34,31,29,26,24,21,19
	dc.b	17,14,12,09,07,04,02,00,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,39,36,34,31,29,24,19
	dc.b	14,09,07,04,02,00,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,39,34,29,24,19
	dc.b	14,09,04,00,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,39,29,19
	dc.b	09,00,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,39,19
	dc.b	00,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,39,19
	dc.b	00,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,39
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,39
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,39
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	39,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	39,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,00
	dc.b	19,39,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,00
	dc.b	19,39,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,00,09
	dc.b	19,29,39,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,41,41,00,04,09,14
	dc.b	19,24,29,34,39,41,41,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,41,41,00,02,04,07,09,14
	dc.b	19,24,29,31,34,36,39,41,41,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	41,41,00,02,04,07,09,12,14,17
	dc.b	19,21,24,26,29,31,34,36,39,41
	dc.b	41,41,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,41,41,41,41,00
	dc.b	02,03,04,06,07,09,11,12,14,17
	dc.b	19,21,24,26,27,29,31,32,34,35
	dc.b	36,39,41,41,41,41,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,00,02,03,04,06
	dc.b	07,08,09,10,11,12,14,15,17,18
	dc.b	19,20,21,22,24,26,27,28,29,31
	dc.b	32,34,35,36,38,39,41,41,41,41
	dc.b	40
	dc.b	41,41,41,41,41,00,02,03,04,06
	dc.b	07,08,09,10,11,12,14,15,17,18
	dc.b	19,20,21,22,24,26,27,28,29,31
	dc.b	32,34,35,36,38,39,41,41,41,41
	dc.b	40
	dc.b	00,01,02,03,04,05,06,07,08,09
	dc.b	10,11,12,13,14,15,16,17,18,19
	dc.b	20,21,22,23,24,25,26,27,28,29
	dc.b	30,31,32,33,34,35,36,37,38,39
	dc.b	40
	dc.b	00,01,02,03,04,05,06,07,08,09
	dc.b	10,11,12,13,14,15,16,17,18,19
	dc.b	20,21,22,23,24,25,26,27,28,29
	dc.b	30,31,32,33,34,35,36,37,38,39
	dc.b	40
	dc.b	00,01,02,03,04,05,06,07,08,09
	dc.b	10,11,12,13,14,15,16,17,18,19
	dc.b	20,21,22,23,24,25,26,27,28,29
	dc.b	30,31,32,33,34,35,36,37,38,39
	dc.b	40

flip_table	
	dc.b	00,10,20,30,40

	even

flip_screen
	movem.l	a0-a6/d0-d7,-(a7)
	move.l	scrbase,a1
	move.w	#7999,d0
.loop	clr.l	(a1)+ 
	dbf d0,.loop
	lea	screen+2(pc),a0
	moveq	#7,d0
	move.w	#$8240,a1
	lea	old_colour(pc),a2
.lp1	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.lp1
	move.w	$ff8242,col2

	move.w	#0,d3
	move.w	#0,d4
	lea	flip_points,a6
	lea	flip_table,a4
.start2 bsr	swap_screen
	lea	screen+$22(pc),a0
	move.l	scrbase,a1
	move.b	00(a4,d3.w),d6
	divu	#10,d6
	move.w	d6,d7
	swap	d6
	mulu	#16,d6
	mulu	#6400,d7
	add.l	d6,a1
	add.l	d7,a1
	add.l	d6,a0
	add.l	d7,a0
	move.l	a0,sc_source
	move.l	a1,sc_dest
	move.w	#41,d1
.draw	move.l	sc_dest,a1
	bsr	draw_loop
	dbf d1,.draw
	move.w	#0,d4
	lea	flip_points,a6
	add.w	#1,d3
	cmp.w	#5,d3
	bne	.start2
	movem.l	(a7)+,a0-a6/d0-d7
	rts

swap_screen
	move.l	$462,d0			;wait VBL
.wait	cmp.l	$462,d0			;
	beq.s	.wait			;
	move.l	scrbase,tempbase
	move.l	oldbase,scrbase
	move.l	tempbase,scrbase
	move.l	scrbase,$45e		;set screen address 
	rts
	
draw_loop
	bsr 	wait2
	move.l	sc_source,a0
	add.l	d4,a6
	clr.l	d5
	move.b	(a6),d5
	cmp.w	#40,d5
	beq	.exit
	cmp.w	#41,d5
	beq	.clear_line
	mulu	#160,d5
	add.l	d5,a0
	rept	10
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
	bra	.next_line
.clear_line
	rept 10
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	endr
.next_line
	move.l	#1,d4
;	add.l	#144,a1
	bra	draw_loop
.exit	rts

wait2	move.w	#400,d0
.wait2	dbf d0,.wait2
	rts




;**************
;print character routine
;**************
; Enter with
;	d0	= char number
;	d1	= vert pos
;	d2	= horiz pos
;	a0	= screen base
;	a1	= character set base
put.char
	move.w	d2,d3
	mulu	#156,d0
	add.l	d0,a1
	mulu	#160,d1
	add.l	d1,a0
	move.l	d2,d0
	lsr	#1,d2
	and.w	#$f8,d2
	add.w	d2,a0		Screen address
	and.w	#15,d0		Amount to rotate

	moveq	#-1,d6		Create rotate mask
	lsr.l	d0,d6
	move.l	d6,d7
	swap	d7
	not.w	d7
	
	cmp.w	#32,d3
	bcc.s	.noclip1
	and.l	#$ffff,d6
	cmp.w	#16,d3
	bcc.s	.noclip1
	clr.w	d6
.noclip1
	sub.w 	#320,d3
	bcs.s	.noclip4
	clr.l	d7
	sub.w	#16,d3
	bcs.s	.noclip4
	clr.w	d6
	sub.w	#16,d3
	bcs.s	.noclip4
	clr.l	d6
.noclip4
	moveq	#38,d3
.loop
	move.l	(a1)+,d1
	ror.l	d0,d1
	move.l	d1,d2
	swap	d2
	and.l	d6,d1
	and.w	d7,d2
	or.w	d1,8(a0)
	or.w	d2,16(a0)
.skip	swap	d1
	or.w	d1,(a0)
	add	#160,a0
	dbf	d3,.loop
	rts

;*****************
;
;sort out incoming text
;
;*****************

fix_text
	move.l a0,-(sp)
	move.l d1,-(sp)
	lea text(pc),a0
fix.loop
	move.b (a0),d1
space	cmp.w #32,d1
	bne comma
	bra nchar
comma	cmp.w #44,d1
	bne aster
	move.b #104,(a0)
	bra nchar
aster	cmp.w #42,d1
	bne dash
	move.b #107,(a0)
	bra nchar
dash	cmp.w #45,d1
	bne quote
	move.b #108,(a0)
	bra nchar
quote	cmp.w #34,d1
	bne point
	move.b #109,(a0)
	bra nchar
point	cmp.w #46,d1
	bne excla
	move.b #103,(a0)
	bra nchar
excla	cmp.w #33,d1
	bne quest
	move.b #101,(a0)
	bra nchar
quest	cmp.w #63,d1
	bne leftb
	move.b #102,(a0)
	bra nchar
leftb	cmp.w #40,d1
	bne rightb
	move.b #105,(a0)
	bra nchar
rightb	cmp.w #41,d1
	bne nums
	move.b #106,(a0)
	bra nchar
nums	cmp.w #57,d1
	bgt spec1
	add.w #43,d1
	move.b d1,(a0)
spec1	cmp.w #125,d1
	bne spec2
	move.b #110,(a0)
	bra nchar
spec2	cmp.w #123,d1
	bne nchar
	move.b #111,(a0)
	bra nchar
nchar	cmp.w #126,d1
	beq exitch
	add.l #1,a0
	bra fix.loop
exitch	move.b #32,(a0)
	move.l (sp)+,d1
	move.l (sp)+,a0
	rts


;******************
; pass screen base in d1
enable.lowborder
	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.l	#$fffa00,a0		Preserve and set IMR and IER
	movep.w	7(a0),d0
	move.w	d0,lb.old.ier
	movep.w	$13(a0),d0
	move.w	d0,lb.old.imr
	move.w	#$140,d0
	movep.w	d0,7(a0)
	movep.w	d0,$13(a0)
	move.l	#service.one,hbl.vec	Set up hbl vector
	move.l	vbl.vec,lb.old.vbl	Preserve old vbl vector
	move.l	#vsync.serv,vbl.vec
	move.l	$44e,lb.old.vbase	Preserve old base
	move.b	$ff8260,lb.old.vmode	Preserve old mode
	rte				Restores sr as well!
disable.lowborder
	move.l	#$fffa00,a0
	move.w	lb.old.ier,d0
	movep.w	d0,7(a0)
	move.w	lb.old.imr,d0
	movep.w	d0,$13(a0)
	move.l	lb.old.vbase,$45e
	move.b	lb.old.vmode,$ff8260
	move.l	lb.old.vbl,vbl.vec
	rts
vsync.serv
	movem.l	a0/a1/d2-d3,-(sp)
	bsr	music+$e
	move.w	#$2200,sr
	clr.b	tmrb.ctl
	move.l	#service.one,hbl.vec
	move.b	#198,tmrb.dat
	move.b	#8,tmrb.ctl
	lea	old_colour(pc),a0
	move.w	#$8240,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	move.l	scrbase,a1
	add.l	#200*160,a1
	moveq	#0,d2
	move.l	backgnd,d3
	rept	4*20
	clr.l	(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd2,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	move.l	backgnd3,d3
	rept	20
	move.l	d3,(a1)+
	move.l	d2,(a1)+
	endr
	ror.w	backgnd
	ror.w	backgnd+2
	rol.w	backgnd2
	rol.w	backgnd2+2
	rol.w	backgnd3
	rol.w	backgnd3+2
	movem.l	(sp)+,a0/a1/d2-d3
	move.l	lb.old.vbl,-(sp)
	rts
service.one
	clr.b	tmrb.ctl
	bclr.b	#0,$fffa0f
	move.w	#$2200,sr
	move.l	#service.two,hbl.vec
	move.b	#1,tmrb.dat
	move.b	#8,tmrb.ctl
	move.l	barcolour,$ff8242
	move.l	barcolour+4,$ff8246
	st	lb.semaphore
.loop	tst.b	lb.semaphore
	bne.s	.loop
	rte
	
service.two
	clr.b	tmrb.ctl
	move.l	d0,-(sp)
	move.w	#$26,d0
.lp1	dbf	d0,.lp1
	move.b	#0,$ff820a
	move.w	#$1,d0
.loop	dbf	d0,.loop
	move.b	#2,$ff820a
	move.w	#0,$ff8240
	sf	lb.semaphore
	move.l	#service.three,hbl.vec
	move.b	#8,tmrb.ctl
	bclr.b	#0,$fffa0f
	move.l	(sp)+,d0
	rte
service.three
	clr.b	tmrb.ctl
	movem.l	d0/a0,-(sp)
	move.w	colourptr,d0
	and.w 	#$3e,d0
	move.w	#$8250,a0
	move.w	colourtable(pc,d0.w),d0
	rept	4
	move.w	d0,(a0)+
	endr
	add.w	#4,colourptr
	bclr.b	#0,$fffa0f
	move.b	#8,tmrb.ctl
	movem.l	(sp)+,d0/a0
	rte
	
	even
barcolour
	dc.w	$116,$336,$446,$556
colourtable
	dc.w $071
	dc.w $060
	dc.w $160
	dc.w $260
	dc.w $360
	dc.w $460
	dc.w $560
	dc.w $660
	dc.w $650
	dc.w $640
	dc.w $630
	dc.w $620
	dc.w $610
	dc.w $600
	dc.w $603
	dc.w $713
	dc.w $704
	dc.w $607
	dc.w $617
	dc.w $627
	dc.w $637
	dc.w $647
	dc.w $657
	dc.w $667
	dc.w $567
	dc.w $467
	dc.w $367
	dc.w $267
	dc.w $167
	dc.w $067
	dc.w $066
	dc.w $176

;   } text    = pause

text	DC.B	'     AUTOMATION }   DISK 106       '
	DC.B	'WELL HERE WE ARE AGAIN.      SOME OF YOU MAY HAVE SEEN A SMALLER'
	DC.B	' VERSION OF RVF HONDA, BUT DO NOT BE TRICKED FOR THOSE VERSIONS'
	DC.B	' HAVE HAD THE EXTRA BITS YOU GET IN 1 MEG REMOVED, NICE MOVE GUYS!        '
	DC.B	'ANYWAY OUR VERSION IS    100 PERCENT!        THANX TO THE SUB HUMANS IN TURKEY FOR THIS CUTE SCROLLER'
	DC.B	'    WHAT DO YOU ALL THINK OF OUR NEW GRAFIX MAN, PRETTY FAB GRAFIX, DONT YOU THINK?        MORE FROM HIM SOON       '
	DC.B	'  TIME TO GO,    LOADS OF GREETINGS ON 107,   HONEST!              ~',0
	even
	
disablemouse 	dc.b	$12
enablemouse  	dc.b	$80,$01
lb.old.vbase	dc.l	0
lb.old.vbl	dc.l	0
lb.old.ier	dc.w	0
lb.old.imr	dc.w	0
lb.old.vmode	dc.b	0
lb.semaphore	dc.b	0
scr_name	dc.b	'EGB.NEO',0
	even
old_colour	ds.l	8
scrbase		dc.l	$76000
oldbase		dc.l	$6A000
sc_source	dc.l	0
sc_dest		dc.l	0
tempbase	dc.l	0
textptr		dc.l	0
textpix		dc.w	0
backgnd		dc.w	%0000001111000000
		dc.w	%0000111111110000
backgnd2	dc.w		%0000001111000000
		dc.w	%0000111111110000
backgnd3	dc.w		%0000000000000000
		dc.w	%0000000000000000
colourptr	dc.w	0	
col2		dc.w	0
old_speed	dc.w	4
new_speed	dc.w	0
scroll_speed	dc.w	4
bounce_ctr	dc.w	0
bounce_speed	dc.w	2
adder		dc.w	100
tptr		dc.w	1
height		dc.w	205
spacer		dc.w	32
spacer2		dc.w	32
sav_cols	ds.w	16
cur_rez		dc.w	0
stack		ds.b	512
music	incbin	platoon.mus
screen	incbin	menu106.pi1
charset
	rept 156
	dc.b 0
	endr
	incbin	chars2.bin
	rept 312
	dc.b 0
	endr
		