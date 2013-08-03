*---include6.s ----- obsolete or seldom used
* include 6 * not included automatically
* routines must be pulled using  F3-Alt I
* BIN_DEC   DEC_BIN  Peter Hibbs
* COLOR CYCLING
* WHEATON NESSAGE SCROLLER
* BINASCII  BINHEX
* POPPLE VERTICAL SCREEN SCROLLER
* GARROCH RANDOM
* REVEAL_ALL
* REVEAL_BIT
* SPARKS SCREN FILL
* CAMY'S SIMPLE SPRITE
* GRAY'S STARFIELD
* COLLISION DETECTION
* POPPLE'S LEFT/RIGHT SCROLL
* MARVEY'S FLIP
* PIXEL PLOT (Chris Skellern)
* KEYBOARD BUFFER
*----------------------------------------------------
* bin_dec  [ Peter Hibbs Aug 89 ]
* enter with d0.l as a binary value
* exit with d0.w holding ascii character in low byte
bin_dec	movem.l	d0-d2/a0,-(sp)
	tst.l	d0
	beq	bd5		display answer as 0
	move.l	d0,d2
	move.l	#10-1,d1	loop  notice the L
	move.l	#dtable-4,a0	look up table
bd1	adda.l	#4,a0		next table entry
	move.w	#"0"-1,d0	ascii 0 less 1
bd2	addq	#1,d0		inc ascii value
	sub.l	(a0),d2		value power of 10
	bcc	bd2		repeat till underflow
	add.l	(a0),d2		restore last value
	cmp.b	#"0",d0
	bne	bd3
	btst	#31,d1		flag
	beq	bd4
bd3	bset	#31,d1		set flag
	bsr	output_char
bd4	dbra	d1,bd1		repeat till done
bd6	movem.l	(sp)+,d0-d2/a0
	rts
bd5	move.w	#'0',d0
	bsr	output_char
	bra	bd6

output_char
	movem.l	a0-a2/d0-d2,-(sp)
	move.w	d0,-(sp)	push character
	move.w	#2,-(sp)
	trap	#1		display character at cursor
	addq.l	#4,sp
	movem.l	(sp)+,a0-a2/d0-d2
	rts

dtable	dc.l	1000000000,100000000,10000000,1000000,100000,10000
	dc.l	1000,100,10,1

* dec_bin  entry a0 points to decimal value in ram
* mustn't start with a nought
*          exit d0.l value in binary
dec_bin	movem.l	d1/a0-a1,-(sp)
db1	add.l	#1,a0		next address
	bsr	number_check
	bcc	db1		yes. repeat
	sub.l	#1,a0
	lea	dtable+36,a1	point to last entry
	clr.l	d0
db2	clr.l	d1
	move.b	(a0),d1		fetch number
	sub.b	#"0"+1,d1	set up repeats
db3	add.l	(a1),d0		add decimal power
	dbra	d1,db3
	sub.l	#1,a0		next decimal power
	sub.l	#4,a1	next table entry
	bsr	number_check	outside limits?
	bcc	db2		no. repeat
	movem.l	(sp)+,d1/a0-a1
	rts
* tst (a0) for numerical value in ascii (0-9)
* entry a0 points to ram address holding character
* exit: carry set to 1      if out of range 
*       carry cleared to 0  if numeric value (48-57)
number_check
	cmp.b	#48,(a0)	ascii for 0
	bcs	nchk1		return if (a0) < '0'
	cmp.b	#'9'+1,(a0)	check if above 9 (ascii 58)
	eor	#1,ccr		invert carry flag!
nchk1	rts
* extraordinary use of carry to determine a range!
* the cmp.b #'9' is merely used to force a status read
*-----------------------------------------------------
	
*   	Color Cycling   [ Camy Maertens ] 18 Sept 87
* enter with 3 color numbers in D1,D2,D3 (W) ex: 0 to 30
* and delay in D4 (L)  ex:MOVE.L #1000,D4 (average)
* note: double the numbers ie color 3 is entered as six
* word boundary reason. Not quite working
cycling	
	MOVEM.L	D4-D6/A0-A3,-(SP)
	clr.l	d6
	lea	$ff8240,a0
	lea	0(a0,d1),a1
	lea	0(a0,d2),a2
	lea	0(a0,d3),a3
	MOVE.L	#2,D5   	(3 loops)
c_cyc1	MOVE.w	(A1),d6  	temp store
	MOVE.w	(A3),(A1)
	MOVE.w	(A2),(A3)
	MOVE.w	d6,(A2)
c_cyc2	dbra	d4,c_cyc2	delay
	move.l	$466,d0
wait_cc	cmp.l	$466,d0		wait vt sync
	beq	wait_cc
	DBRA	D5,c_cyc1
	MOVEM.L (SP)+,D4-D6/A0-A3
	RTS
*------------
*	COLOR CYCLING	Jan 1988
* Degas holds its info as follows:
* 32042 right boundary  32024 left boundary  (0-15)
* 32058 cycling speed (0-128)  speed=(128-cycling speed)*90
* direction 32050  0 left  1 off  2 right

* This routine cycles the first six colors
col_cycling
	movem.l	d0-d7,-(sp)
	clr.l	d0
	move.l	#5,d3		counter
colcyc1	move.w	$ff824a,d0
	move.w	$ff8248,$ff824a
	move.w	$ff8246,$ff8248
	move.w	$ff8244,$ff8246
	move.w	$ff8242,$ff8244
	move.w	$ff8240,$ff8242
	move.w	d0,$ff8240
	wait	4
	dbra	d3,colcyc1
	movem.l	(sp)+,d0-d7
	rts
*-----------
* Wheaton scroll  [Gary Wheaton  September 22 1988]
* this one scrolls a message right to left at the bottom of screen
* provided a degas file called 'alphabet.pi1' has first been loaded
* to use, just jsr garycode
wheaton_scroll
garycode
	move.l	$466,d7
.wait	cmp.l	$466,d7
	beq	.wait
	MOVE 	#24,D2		24
	move.l	$44e,a1
	add.l	lin,a1
	ADD.L 	#160,A1

.lp	MOVE.L 	A1,A0 		\SCROLL SCREEN BYTES
	MOVE 	#19,D1		19

.p2	MOVE.B 	-1(A0),D0
	MOVE.B 	D0,D3
	LSR.B 	#4,D0
	CMP 	#18,D1
	BEQ 	.ms
	OR.B 	D0,-8(A0)
.ms	ASL.B 	#4,D3
	MOVE.B 	D3,-1(A0)
	MOVE.B 	(A0),D0
	MOVE.B 	D0,D3
	LSR.B 	#4,D0
	OR.B 	D0,-1(A0)
	ASL.B 	#4,D3
	MOVE.B 	D3,(A0)

	ADD.L 	#8,A0
	DBRA	D1,.p2
.op	ADD.L 	#160,A1
	DBRA 	D2,.lp
	MOVE.L 	#TXT,A0		get start of text in file 'text.s'
	EOR.B 	#1,MPP
	BNE.S 	OKK
	ADD 	#1,PPIX
	CMP 	#4,PPIX
	BNE.S 	OKK
	ADD 	#1,INDX
	MOVE	#0,PPIX

OKK 	ADD 	INDX,A0
	MOVE.B 	(A0),D0  	character to print
	CMP.B 	#0,D0
	BNE.S 	FGH 
	
	MOVE 	#0,INDX		reset scroll on 0
fgh	cmp.b	#32,d0
	bne	.g
	move.b	#91,d0		space, just after Z
.g	SUB 	#65,D0		a= ascii 65
	MOVE 	PPIX,D1
	AND 	#1,D1
	MOVE 	PPIX,D2
	AND 	#65534,D2
	ASL 	#2,D2
	ASL 	#4,D0
	ADD 	D1,D0
	ADD 	D2,D0
sdf	DIVU 	#160,D0		\GET CHR FROM DEGAS SCREEN
	MOVE 	D0,D1
	MULU 	#50,D1

	MOVE.L 	D0,DDD
	CLR.L 	D0
	MOVE 	DDD,D0
	MULU 	#160,D1
	MOVE.L 	alpha_ptr,a4 
	adda.w	#34,a4
	ADD 	D0,A4
	ADD 	D1,A4
	move.l	$44e,a0
	add.l	lin,a0
	add.l	#152,a0
	add.l	#160,a0
	MOVE 	#151,D6

KLP  	MOVE.B 	(A4),D0
	CMP.B 	#0,MPP	
	BNE 	WES
	LSR.B 	#4,D0
	BRA 	DFV
WES 	AND.B 	#15,D0

DFV 	OR.B 	D0,(A0)
P3	ADD.L	 #160,A0
	ADD.L 	#320,A4
	ADD 	#2,D6
	CMP 	#200,D6
	BLT 	KLP
	RTS 

DDD 	DC.L 	0
MPX 	DC.B 	0,0
MPP 	DC.B 	0,1
VT 	DC.W 	0
INDX 	DC.W 	0
PPIX	DC.W 	0
txt	dc.b	"hello",0

lin		dc.l	16000
alpha_ptr	dc.l 0
alphabetfile	dc.b "alphabet.pi1"
	even

*----------
binascii
	movea.l	#string+16,a0  16
	moveq	#15,d0    15
	move.b	#'0',d1
	move.w	number,d2     l
binas1	move.b	d1,-(a0)
	ror.w	#1,d2     w
	bcc.s	binas2
	addi.b	#1,(a0)
binas2	dbra	d0,binas1
	rts
string	dc.b 	16
number	dc.l	0
*----------------
* binhex- binary to ASCII hex
* Enter with:
* d0=binary (long)
* a0=output buffer (8 bytes)
binhex
	movem.l	d0-d2/a1,-(sp)
	lea.l	hextab,a1
	adda.l	#8,a0
	move.l	#7,d1
hexlp1	move.l	d0,d2
	andi.l	#15,d2
	move.b	0(a1,d2.l),-(a0)
	lsr.l	#4,d0
	dbra	d1,hexlp1
	movem.l	(sp)+,d0-d2/a1
	rts
hextab  dc.b    '0123456789abcdef'
        even
*------------
*  vertical screen scroll *   POPPLE
* Whole screen 1 pixel UP. (12 times in this example) 1 plane only.
		
vert	movem.l	a0-a3,-(sp)
	move.l	$44e,a0	; put screen end in a0
	add	#480,a0		[see below]
	lea.l	320(a0),a1	; find pixel above a0
	move.l	#11,d1		number of scrolls up (1 pixel a time)
;				12 * 2 = 24 lines to go handle	
	move.l	a0,a2		; save a0, screen end
	move.l	a1,a3		; save a1, point above a0
vloop2
	move.l	a2,a0		; reset screen end
	move.l	a3,a1		; reset point above screen end
	move.l	#3900,d0	; 8k of long words, do 32k screen
vloop
	move.w	(a1),(a0)	; decrement and move contents
	addq	#8,a0
	addq	#8,a1
; alternatively move.w (a1)+,(a0)+ 4 times and no addq
; all 4 planes will go up but not so smooth
	
	dbra	d0,vloop	; loop repeat 3900 times
	dbra	d1,vloop2	; loop number of screen lines to shift
	
	movem.l	(sp)+,a0-a3
	rts
* [ we start with 480/320/11 normal speed normal spacing
* 480/160/22 is slower. same spacing
* 480/480/7 is faster  same spacing
* 480/480/15 is as fast, larger spacing
* 480/960/7 is very fast
* 480/1120 catches a lines  480/1280 catches 2 and so on. no good
*]

*------------
* returns random number in D0
* note: preserve any active D0 prior to calling 
* ex: bsr random  and.w #127,d0
randm
	move.l	rnd1,d0		$462,d0
	lsl.l	#1,d0
	btst	#23,d0	
	bne.s	rndh
	btst	#1,d0
	bne.s	rndl
	rts
rndh	btst	#1,d0
	bne	rndhl
rndl	addq.l	#1,d0
rndhl	rts
*----------------------		
* 	Reveal D0 through D7 in Decimal [ Camy Maertens ]
* replaced by reveal_regs in include1
reveal_all
	move.l	d0,-(sp)		modified march 89
	move.l	d7,-(sp)		save originals
	move.l	d6,-(sp)
	move.l	d5,-(sp) 	
	move.l	d4,-(sp)
	move.l	d3,-(sp)
	move.l	d2,-(sp) 	
	move.l	d1,-(sp)
	move.l	d0,-(sp)
	print	cursor12
	lea	errbuf(PC),A0
	move.l	(sp)+,d0		retrieve d0
	bsr	bindec
	bsr	printline
	print	space
	move.l	(sp)+,d0		retrieve d1
	LEA	errbuf(PC),A0
	BSR	bindec
	BSR	printline
	print	space
	move.l	(sp)+,d0		retrieve d2
	LEA	errbuf(PC),A0
	BSR	bindec
	BSR	printline
	print	space
	move.l	(sp)+,d0		retrieve d3
	LEA	errbuf(PC),A0
	BSR	bindec
	BSR	printline
	print	cursor13
	move.l	(sp)+,d0		retrieve d4
	LEA	errbuf(PC),A0
	BSR	bindec
	BSR	printline
	print	space
	move.l	(sp)+,d0		retrieve d5
	LEA	errbuf(PC),A0
	BSR	bindec
	BSR	printline
	print	space
	move.l	(sp)+,d0		retrieve d6
	LEA	errbuf(PC),A0
	BSR	bindec
	BSR	printline
	print	space
	move.l	(sp)+,d0		retrieve d7
	LEA	errbuf(PC),A0
	BSR	bindec
	BSR	printline
	move.l	(sp)+,d0		final retrieve (march 89)
	RTS
cursor12  DC.B	27,"Y",42,32,0
cursor13  DC.B	27,"Y",44,32,0
*---------------------------

* 	REVEAL BIT
* enter with the Long Word to be revealed in D0
* if a carriage return is required, move.w #1,line_down
reveal_bit 
	MOVEM.L	D0-D7/A0-A6,-(SP) 
	move.l	d0,d7
	lea	line_down(pc),a0
	cmp.w	#0,(a0)
	beq	rev6
	print	linedown_1
rev6	print	c_r
rev6a	MOVE.W	#31,D5
rev2	BTST	d5,d7
	BEQ	rev4
	bra	rev3
rev8	CMP.W	#24,D5
	BEQ	rev7
	CMP.W	#16,D5
	BEQ	rev7
	CMP.W	#8,D5
	BEQ	rev7
rev5	DBRA	D5,rev2
	bra	rev1
	print	c_r
	DBRA	D5,rev1
rev1	BSR	getkey
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
rev3	LEA	one_bit(PC),A0
	BSR	printline
	BRA	rev8
rev4	LEA	nought_bit(PC),A0
	BSR	printline
	BRA	rev8
rev7	LEA	space(PC),A0
	BSR	printline
	BRA	rev5
c_r		DC.B	13,0  was " ",13,0
l_f		DC.B	10,0
space		DC.B	" ",0
line_down 	DC.B	0
linedown_1 	DC.B	" ",13,10,0
one_bit		DC.B	"1",0
nought_bit	 DC.B	"0",0
	EVEN
*-------------
* Routine to fill screen with block pointed to by a0
* Malcolm Sparks  May 1989 

scr_fill
	move.l	a0,a6		Get block address
	movem.l	(a6),d0-d7/a0-a5	Move data into register block
	move.l	logical_screen,a6	
	add	#32000,a6	Blitting goes backwards
;				No 68000 option to post-increment
	
;	571*14 + 6 fills up the whole screen

	REPT	571		Repeats faster than DBRA constructs
	movem.l	d0-d7/a0-a5,-(a6)	Blit on
	ENDR
	movem.l	d0-d5,-(a6)	
	rts			Return to main program
*----------
* how to display a 16*16 sprite [ Camy ]
* quick version
* spr_screen expected in A0
action    
	ADDA.L	#114,A0
	LEA	a_buffer(PC),A2
	MOVE.L	new_pos,A1
	MOVE.L	old_pos,A3
	MOVE.W	#13,D3		height
.a2	MOVE.W	#3,D4		width  16-1
.a3	MOVE.L	(A2),(A3)+ 	RESTORE
	MOVE.L	(A1),(A2)+	SAVE TARGET
	MOVE.L	(A0)+,(A1)+	PRINT
	DBRA	D4,.a3
	ADD.W	#144,A0
	ADD.W	#144,A1
	ADD.W	#144,A3
	DBRA	D3,.a2
	RTS
old_pos	DS.L 1
new_pos	DS.L 1
a_buffer	DS.W 200
*------------
spriteroutine 
* (used by drawinvader) restores background OK
* expects sprite buffer in A2 and
* degas data in A0, newpos (target) in A1
* and oldpos (current) in A3
* sprite is assumed to be 16 * 16
	MOVE.W	#15,D3		height
.a2	MOVE.W	#7,D4		width  16-1
.a3	MOVE.w	(A2)+,(A3)+	restore
	DBRA	D4,.a3
	ADD.W	#144,A3
	DBRA	D3,.a2
	add.w	#-256,a2
	MOVE.W	#15,D3
.a5	MOVE.W	#7,D4
.a6	MOVE.w	(a1),(a2)+ 	save target
	MOVE.w	(A0)+,(a1)+ 	print to screen
	DBRA	D4,.a6
	ADD.W	#144,A0
	ADD.W	#144,A1
	DBRA	D3,.a5
	rts
*------------
* this one is used by Deflector and co, 
* 
sprout2    
	MOVE.W	#6,D3		height   
.a2	MOVE.W	#7,D4		width  16-1
.a3	move.w	#0,(a3)+ 		keep it black
;;	MOVE.w	(A2)+,(A3)+ 	restore
	DBRA	D4,.a3
	ADD.W	#144,A3
	DBRA	D3,.a2
	MOVE.W	#6,D3
.a5	MOVE.W	#7,D4
.a6	MOVE.w	(A1),(A2)+ 	save target
	MOVE.w	(A0)+,(A1)+ 	print to screen
	DBRA	D4,.a6
	ADD.W	#144,A0
	ADD.W	#144,A1
	DBRA	D3,.a5
	RTS
*------------
* Universal Collision Detect  [ Camy Maertens Oct 87 ]
* Initially all objects are 8 by 8
collision_detect
	MOVE.W D4,D5	
	ADD.W #8,D5 	
	MOVE.W D6,D7
	ADD.W #8,D7	
	MOVE.W D0,D1
	ADD.W #8,D1	
	MOVE.W D2,D3
	ADD.W #12,D3	was 14, but down to 12
	CMP.W D7,D2	top cc /bottom c
	BGT no_hit
	CMP.W D6,D3	top c /bottom cc
	BMI no_hit
	CMP.W D5,D0	top aa /bottom a
	BGT no_hit
	CMP.W D4,D1	top a /bottom aa
	BMI no_hit
	bset #0,collision
	rts
no_hit	bclr #0,collision
	RTS
collision DC.W 0
*--------------
* this one, quite by accident, was perfect to detect two sprites:
* ball and bat  both 16*8, both moved by si's routines (L coord)
* routine expects loose sprite (ball) x in d4  y in d6
* joystick/defender x (horiz) in d0 and y (altitude) in d2
detect
	MOVE.l D4,D5	d4 is BALL x   horizontal left	
	ADD.l #8,D5	d5 is BALL xx  horizontal right 	
	MOVE.l D6,D7	d6 is BALL y   altitude top 
	ADD.l #8,D7	d7 is BALL yy  altitude bottom	
	MOVE.l D0,D1	d0 is JOY x    horizontal left
	ADD.l #8,D1	d1 is JOY xx   horizontal right
	MOVE.l D2,D3	d2 is JOY y    altitude top
	ADD.l #10,D3	d3 is JOY yy   altitude bottom	
	CMP.l D7,D2	top cc /bottom c
	BGT no_hitt
	CMP.l D6,D3	top c/bottom cc
	BMI no_hitt
	CMP.l D5,D0	top aa /bottom a
	BGT no_hitt
	CMP.l D4,D1	top a /bottom aa
	BMI no_hitt
	bset #0,collision
	rts
no_hitt	bclr #0,collision
	RTS
*--------------------------

* Fast horizontal Screen flip - Low res only.
* left becomes right/ right becomes left
* Marvey Mills - 03/01/88
* Example in SHELL.S  (press G)
*
* IN: address of screen to be flipped in A0
* All other registers unaffected.
* example: move.l $44e,a0  bsr f_flip  (example in Final Lap)
f_flip
	movem.l	a1/d0-d4,-(sp)	;save the reggies
	move.l	a0,a1	;setup pointer to second block
	add.l	#152,a1	;a1 now points to last block of line 
	move.w	#199,d1	;200 lines to flip
flipline
	move.w	#9,d2	;setup loop count for block flip
flipblok
	move.w	(a0),d3	;plane 1 word flip routine
	move.w	(a1),d4	;and bit reversals in Dx registers
	lsr.w	#1,d4	;for greater speed
	move.w	#15,d0	;setup bit reverse loop
shftlp1
	roxl.w	#1,d3	;flip bits in data registers
	roxr.w	#1,d4	;for greater speed
	dbra	d0,shftlp1	;til all done
	move.w	d3,(a0)	;save out to memory
	move.w	d4,(a1)
	move.w	2(a0),d3	;plane 2 word flip
	move.w	2(a1),d4
	lsr.w	#1,d4
	move.w	#15,d0
shftlp2
	roxl.w	#1,d3
	roxr.w	#1,d4
	dbra	d0,shftlp2
	move.w	d3,2(a0)
	move.w	d4,2(a1)
	move.w	4(a0),d3	;plane 3 word flip
	move.w	4(a1),d4
	lsr.w	#1,d4
	move.w	#15,d0
shftlp3
	roxl.w	#1,d3
	roxr.w	#1,d4
	dbra	d0,shftlp3
	move.w	d3,4(a0)
	move.w	d4,4(a1)
	move.w	6(a0),d3	;plane 4 word flip
	move.w	6(a1),d4
	lsr.w	#1,d4
	move.w	#15,d0
shftlp4
	roxl.w	#1,d3
	roxr.w	#1,d4
	dbra	d0,shftlp4
	move.w	d3,6(a0)
	move.w	d4,6(a1)
	addq.l	#8,a0	;block done- bump to next block
	subq.l	#8,a1
	dbra	d2,flipblok	;all blocks done?
	add.l	#80,a0		;yes - bump to next line
	add.l	#240,a1
	dbra	d1,flipline	;all lines done?
	movem.l	(sp)+,a1/d0-d4	;yep - restore reggies
	rts
* ex: move.l $44e,a0   jsr f_flip
*--------------------------------

* STARFIELD [Gary Wheaton  October 88 ]
* PLOTTER & GET POINT [ G.Wheaton. ]
* with a dual screen, the problem is unplotting the correct screen
* This routine plots a number of dots (stars) on the screen,
* then replaces those dots with black,
* then moves them about when joystick is moved
* as used in Zenith and Ace invaders

starfield
	MOVE	$FF8240,bck
	MOVE	#0,$ff8240
	BRA	STAR
*	at this point Gary has a trap call (joy vector)
JOY	DC.W	0
HJTB	DC.B	0,0,0,0,1,1,1,0,-1,-1,-1
VJTB	DC.B	0,-1,1,0,0,-1,1,0,0,-1,1

STAR	MOVE.L 	#HTAB,A4

*	bsr	vtsync
	CLR.L	D0
	MOVE	JOY,A0
	MOVE.B	(A0),D0
	move.b	joyport1,d0
	CLR	D4
	CLR	D6
	MOVE.B	HJTB(PC,D0),D4 		\HZ
	MOVE.B	VJTB(PC,D0),D6 		\VT

LP0	MOVE.B 	#0,D5		this must be the unplot
	MOVE 	(A4),D0
	MOVE.B 	91(A4),D1
	BSR	CPLOTT
	MOVE	180(A4),D0
	CMP.B	#10,D4
	BGT	OK
	move.b	#2,d4	test only
	CMP.B	#0,D4
	BEQ	OK1
	BMI	RIGHT 
	SUB	D0,(A4)
	BPL	OK1
	MOVE 	#320,(A4)
	MOVE.B	91(A4),D1 
	ROL.B	#1,D1       	RANDOMIZE VERT A BIT
	MOVE.B 	D1,91(A4) 
	BRA	OK1
RIGHT	ADD	D0,(A4)
        CMP	#320,(A4)
	BLT OK1
	CLR (A4)
				*\SHOULD RAND HERE ALSO
OK1	CMP.B #0,D6
	BEQ OK
	BPL UP
	SUB D0,90(A4)
	BPL OK2 
	MOVE #199,90(A4)
	BRA OK2

UP	ADD	D0,90(A4)
	CMP	#200,90(A4)
	BLT	OK2
	CLR	90(A4)
OK2
OK	MOVE.B 	91(A4),D1  	\V
	MOVE 	(A4),D0
	MOVE.B 	D1,D5
	BSR 	CPLOTT
	SUB.L 	#2,A4
	CMP.L 	#TR,A4
	BGT 	LP0
*	dbra	d7,star
SM	
*	DC.W	$A009       	SHOW MOUSE
	MOVE	bck,$FF8240
	RTS			exit (bombs quite ok) should call trap
bck	dc.w 0
*-----------
CPLOTT 	AND.L 	#15,D5		color
	AND 	#255,D1		x
	CMP 	#320,D0		y
	BLT 	PLO   
	RTS
PLO 	MOVE 	D0,D3
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
	MOVE.B 	TBL(PC,D3),D0 \GET MASK

  
PLOK	AND.B 	D0,(A0) \C.0:PL.X,Y
	AND.B 	D0,2(A0) \
	AND.B 	D0,4(A0)
     	AND.B 	D0,6(A0)
	
	CMP.B 	#0,D5   \COLOR TO PLOT
	BNE 	COLO      \IF>0 THEN PLOT
	RTS           \ELSE RTS 
*---------
*       \COLOR 0 MASKS
tbl	DC.B 	127,255-64,223,239
	DC.B 	247,251,253,254  
COLO 	EOR.B 	#255,D0     \REVERSE BIT PATTN
	ASL 	#2,D5         \COL*4
	MOVE.L 	#XGOTO,A0
	ADD.W 	D5,A0
	MOVE.L 	(A0),A0
	JMP 	(A0)           \GOTO COLOR
C15 	OR.B 	D0,6(A1)  \COLOR 15
C14 	OR.B 	D0,2(A1)
C10 	OR.B 	D0,(A1)
C2  	OR.B 	D0,4(A1)
	RTS
*----------
C3 	OR.B 	D0,4(A1)   
C1 	OR.B 	D0,6(A1)   \COLOR 1 ENTRY
	RTS
C5 	OR.B 	D0,2(A1)
	OR.B 	D0,6(A1)
	RTS
C7 	OR.B 	D0,6(A1)
C6 	OR.B 	D0,4(A1)
C4 	OR.B 	D0,2(A1)
	RTS
C11 	OR.B 	D0,4(A1)
C9 	OR.B 	D0,6(A1)
C8 	OR.B 	D0,(A1)
	RTS
C13 	OR.B 	D0,6(A1)
C12 	OR.B 	D0,(A1)
	OR.B 	D0,2(A1) 
	RTS
C16 	RTS
*         \ JSR TABLE interesting way
XGOTO 	DC.L 	C1,C1,C2,C3,C4,C5,C6,C7,C8
	DC.L 	C9,C10,C11,C12,C13,C14,C15,C16
*	\\\\\23
TR
	DC.W 	0,20,30,120,319,200,230,290
	DC.W 	80,140,134,180,240,290,199
	DC.W 	50,95,130,180,234,256,300

	DC.W 	8,16,23,30,40,48,54,62,78,83
	DC.W 	100,105,115,123,134,140,150
	DC.W 	156,160,170,178,188,198
HTAB 	DC.W 	1
	DC.W 	0,20,30,120,119,100,130,190
	DC.W 	80,140,134,180,140,190,199
	DC.W 	50,95,130,180,134,156,10
	DC.W 	8,16,23,30,40,48,54,62,78,83
	DC.W 	100,105,115,123,134,140,150
	DC.W 	156,160,170,178,188,198

	DC.W 	1,2,3,2,1,6,2,2,3,2,4,1,2,5,4
	DC.W 	1,2,1,6,4,2,2,2
	DC.W 	2,1,6,4,2,1,3,4,3,5,2,2,1,1,2
	DC.W 	1,2,3,1,2,3,1,1
*---------------

* lateral scroll  [ Gareth Pople Nov 1988 ] [ 1 plane only ]
* if more planes need to be scrolled, see example in Final Lap	
* needed: a1 (L) position say 24000   d1 (L) height (1 to 200) 
*  d3 (L) pixels to move (1 to 8)
scroll_left		
	move.l	$44e,a0
	add.l	a1,a0		ex: 16000 (half way down)
.lines	move.l	#0,a1		; reset line pointer far left
	add.l	#160,a0		; add 160  lines pointer
	move.l 	#19,d7		; do 20 lots of 4 words 
.line	move	(a0,a1),d2
	swap	d2	
	move	8(a0,a1),d2	
	rol.l	d3,d2 		was #4,d2 (pixels to scroll)	
	swap	d2	
	move	d2,(a0,a1)
		
	add.l	#8,a1
	dbra	d7,.line
	dbra	d1,.lines
	rts

scroll_right
	move.l	$44e,a0
	add.l	a1,a0		ex: 16000 (half way down)
.lines	move.l	#160,a1		; reset line pointer far right
	add.l	#160,a0		; add 160  lines pointer (no change)
	move.l 	#19,d7		; do 20 lots of 4 words 
.line	move	8(a0,a1),d2
	swap	d2	
	move	0(a0,a1),d2	
	ror.l	d3,d2 		ror instead of rol
	swap	d2	
	move	d2,8(a0,a1)
		
	add.l	#-8,a1		go backwards towards the left
	dbra	d7,.line
	dbra	d1,.lines
	rts
*----------------------
*R69
*plot a single pixel onto screen
*enter with a0=scrn_address
*  d1/d2=x/y values and d5.b =colour
plot_pix move.w d2,d4
	lsl.w #7,d2
	lsl.w #5,d4
	add.w d2,d4
	move.w d1,d2
	andi.w #$fff0,d2
	lsr.w #1,d2
	add.w d2,d4
	ext.l d4
	adda.l d4,a0
	andi.l #$f,d1
	andi.l #$f,d5
	bne.s not_rdz
col_zero move.l #$7fff7fff,d2
	ror.l d1,d2
	and.l d2,(a0)+
	and.l d2,(a0)
	bra ex_rdraw
not_rdz	lea pix_pdat(pc),a2
	lsl.w #3,d5
	adda.l d5,a2
	move.l (a2)+,d0
	move.l (a2)+,d2
	move.l #$7fff7fff,d3
	lsr.l d1,d0
	lsr.l d1,d2
	ror.l d1,d3
	and.l d3,(a0)
	or.l d0,(a0)+
	and.l d3,(a0)
	or.l d2,(a0)
ex_rdraw rts  
pix_pdat dc.w 0,0,0,0
	dc.w $8000,$0,$0,$0
	dc.w 0,$8000,0,0
	dc.w $8000,$8000,0,0
	dc.w 0,0,$8000,0
	dc.w $8000,0,$8000,0
	dc.w 0,$8000,$8000,0
	dc.w $8000,$8000,$8000,0
	dc.w 0,0,0,$8000
	dc.w $8000,0,0,$8000
	dc.w 0,$8000,0,$8000
	dc.w $8000,$8000,0,$8000
	dc.w 0,0,$8000,$8000
	dc.w $8000,0,$8000,$8000
	dc.w $0,$8000,$8000,$8000
	dc.w $8000,$8000,$8000,$8000 
	even     
*---------------
	lea	3086,a4
	move.w  3510,d1  
	move.w	0(a4,d1),d0
	ext.l	d0		pad leading word with noughts
	bindec	d0,16		convert binary to hex ascii	
	printat	15,9,2,a0	let's see it
	RTS
*----------
   
