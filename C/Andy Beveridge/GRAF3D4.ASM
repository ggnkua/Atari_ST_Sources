*********************************************************
*		   3D ON THE ATARI ST			*
*  This demonstration of raw 68000 power was written	*
*  for no particular reason other than my own amusal.	*
*  Let's see how it compares with the 8 bit version.	*
*  It doesn't do anything particularly clever although	*
*  it does make very good use of the 68000 multiply	*
*  instruction and indexed + offset adressing modes.	*
*    Now, if only we had hardware line-drawing!!!	*
*							*
*   By Andy Beveridge	 30/3/86 (Easter, so day off.)  *
*							*
*********************************************************

* conditional assembly flags

perspective	equ	1	;make this zero if you don't want perspective

* Assembled using the Metacomco Macro Assembler on an Atari ST.
* If you use any other assembler (you wouldn't would you ?),
* you may need to change the format of the macro definitions.

* When the program is running, use the cursor-pad keys
*
*	left arrow, right arrow	-	Y axis rotation velocity
*	up arrow  , down arrow	-	X axis
*	insert    , clr/home	-	Z axis
*			ESC	-	exit to desktop (or wherever)
* 		any other key	-	stops spinning.

* I could have inserted appropriate xbios calls ( vsync() )
* or used screen flipping to give nice flicker-free motion.
* BUT I didn't, because :-
*
* 1) I like the way the lines shimmer when they're stationary.
* 2) I wanted it to run flat out. (Although it could be made faster still
*	by using custom line drawing routines). Maybe I can convince the
*	world to stop programming in C. Assembler is the way to go!
*	I suppose C does have it's uses it's nice for accessing GEM
*	(should you want to) and it's o.k. for building lookup tables.
*	As for BCPL, you may as well program in Assembler. BCPL seems
*	not much different to using Assembler with a decent comprehensive
*	operating system and subroutine library. And it's a lot slower.
*	(don't tell anyone at Metacomco I said that). I suppose there
*	is that point about portability though. What about a STANDARD
*	assembler library for the machine independant bits, after all
*	that's all BCPL is (to me anyway).
*	An ANSI standard assembler library - I wonder ?

* THE LINE-A VARIABLES (as offsets from base pointer)
* usually accessed as  name(a0)
 
v_planes	equ	0	;No of video planes
v_lin_wr	equ	2	;No of bytes per video line
contrl		equ	4	;long pointer to CONTRL array
intin		equ	8	;long pointer to INTIN array
ptsin		equ	12	;pointer to PTSIN array
intout		equ	16	;pointer to INTOUT array
ptsout		equ	20	;pointer to PTSOUT array
colbit0		equ	24	;current color bit-plane 0 value
colbit1		equ	26	; ditto for bit plane 1
colbit2		equ	28	;bit plane 2
colbit3		equ	30	;bit plane 3
lstlin		equ	32	;"set this to -1 and forget it."?!
ln_mask		equ	34	;line style word
wrt_mode	equ	36	;writing mode (see doc.)
x1		equ	38	;x1 co-ordinate
y1		equ	40	;y1 co-ordinate
x2		equ	42	;x2 co-ordinate
y2		equ	44	;y2 co-ordinate
patptr		equ	46	;long pointer to current fill pattern
patmsk		equ	50	;word fill pattern mask
multifill	equ	52	;multi plane fill flag (1 => multi plane)
clip		equ	54	;clipping flag (0 => no clipping)
xmn_clip	equ	56	;XMIN clipping value
ymn_clip	equ	58	;YMIN clipping value
xmx_clip	equ	60	;XMAX clipping value
ymx_clip	equ	62	;YMAX clipping value
xacc_dda	equ	64	;accum for textblt x dda (set to $8000 before textblt)
dda_inc		equ	66	;fractional amount to scale up or down (see doc)
t_sclsts	equ	68	;scale direction flag (0 => down)
mono_status	equ	70	;(see doc)
sourcex		equ	72	;x co-ord of character in font form
sourcey		equ	74	;y co-ord  บบ
destx		equ	76	;x of char on screen
desty		equ	78	;y of char on screen
delx		equ	80	;width of character
dely		equ	82	;height of character
fbase		equ	84	;ptr to start of font data
fwidth		equ	88	;width of font form
style		equ	90	;textblt special effects flags
litemask	equ	92	;the mask to usee in lightening the text
skewmask	equ	94	;mask to use in skewing the text
weight		equ	96	;width to thicken text by
r_off		equ	98	;offset above char baseline when skewing
l_off		equ	100	;offset below  บบ
scale		equ	102	;scaling flag
chup		equ	104	;char rotation vector (see doc)
text_fg		equ	106	;text foreground color
scrtchp		equ	108	;ptr to start of text special effects buffer
scrpt2		equ	112	;word offset of scaling buffer in above buffer
text_bg		equ	114	;text background color
copytran	equ	116	;copy raster form type-flag (see doc)


* line "A" opcodes follow...

init		equ	$a000	;initialise line "A"
putpix		equ	$a001	;plot a single pixel
getpix		equ	$a002	;get a single pixel
line		equ	$a003	;plot a line x1,y1 to x2,y2
hline		equ	$a004	;horizontal line x1,y1 to x2,y1
frect		equ	$a005	;filled rectangle x1,y1 ; x2,y2 (tl;br)
fpol		equ	$a006	;1 scan line of filled polygon (points on PTSIN)
bitblt		equ	$a007	;bit block transfer
textblt		equ	$a008	;text block transfer of 1 character
showmouse	equ	$a009	;show the mouse
hidemouse	equ	$a00a	;hide the mouse
tranmouse	equ	$a00b	;transform the mouse
unsprite	equ	$a00c	;undraw previous sprite
dosprite	equ	$a00d	;draw a sprite
copyrast	equ	$a00e	;copy raster form from source to dest.
seedfill	equ	$a00f	;seed fill an area

* This assembler really should have an ILLEGAL instruction
* but it hasn't so I'll have to define my own.

illegal		macro
		dc.w	$4afc
		endm

* some BIOS macro's to make the code clearer
* and just for example's sake.

* device numbers for following macro's
parallel	equ	0	;'printer' port
serial		equ	1	;serial RS-232
console		equ	2	;console (screen/keyboard)
midi		equ	3	;midi serial line
ikbd		equ	4	;intelligent kbd serial line

*	bconstat( dev ) - check device input status
* returns 0 in d0 if no chars available (-1 if chars available)
bconstat	macro
		move.w	\1,-(sp)	;push device number
		move.w	#1,-(sp)	;push code for bconstat()
		trap	#13		;call bios
		addq.l	#4,sp		;fix stack pointer
		endm

* bconin( dev ) - get char from device
* returns character in d0.w & if kbd, scancode in top word.
bconin		macro
		move.w	\1,-(sp)	;push device number
		move.w	#2,-(sp)	;push code for bconin()
		trap	#13		;call bios
		addq.l	#4,sp		;fix stack pointer
		endm

* key scancodes :-

scanleft	equ	$4b
scanright	equ	$4d
scanup		equ	$48
scandown	equ	$50
scanins		equ	$52
scanclr		equ	$47
scans		equ	$1f

* centre of screen :-

cx		equ	320
cy		equ	200


*********************************************************
*		THIS IS IT - THE PROGRAM :-		*
*********************************************************

start		dc.w	init		;initialise the line-a
		move.l	a0,varsav	;make a backup copy
		moveq	#-1,d0
		move.w	d0,lstlin(a0)	;set once & forget it.
		move.w	d0,ln_mask(a0)	;set for solid linestyle
		moveq	#0,d0
		move.w	d0,wrt_mode(a0)
		move.w	d0,patmsk(a0)	;no pattern mask
		move.w	d0,clip(a0)		;clipping off
		move.w	d0,multifill(a0)	;fill pattern is one line

		move.w	d0,colbit3(a0)	;set foreground color to black
		move.w	d0,colbit2(a0)
		move.w	d0,colbit1(a0)
		move.w	#1,colbit0(a0)	; i.e. 0001 binary

cls		move.l	#filpat,patptr(a0)	;set-up solid fill pattern
		move.w	#1,x1(a0)		;area to fill
		move.w	#1,y1(a0)		; 1,1,638,398
		move.w	#638,x2(a0)		; = nearly full screen
		move.w	#398,y2(a0)
		dc.w	frect		;line-A fill rectangle opcode

* check here for keypress

mainloop	move.w	xv,d3		;get z axis rot velocity to d3
		move.w	yv,d4		;etc
		move.w	zv,d5

		bconstat #console	;anything in key buffer ?
		tst.w	d0		;look at what came back		
		beq.l	nokeys		;skip next bit if no keys (zero)

keypressed	bconin	#console	;get that key
		swap	d0		;swap so we can get scancode

		cmp.w	#scanleft,d0	;left arrow => increase Y velocity
		bne.s	notleft
left		cmp.w	#8,d4
		bgt	nokeys		;it's gone as far as it's going
		addq.w	#1,d4		;else increment it
		bra.s	nomore

notleft		cmp.w	#scanright,d0	;right arrow => decrease Y velocity
		bne.s	notright
		cmp.w	#-8,d4
		blt.s	nokeys		;skip if gone too far
		subq.w	#1,d4		;else increment it
		bra.s	nomore

notright	cmp.w	#scandown,d0	;down arrow => increase X velocity
		bne.s	notdown
		cmp.w	#8,d3
		bgt.s	nokeys
		addq.w	#1,d3
		bra.s	nomore

notdown		cmp.w	#scanup,d0	;up arrow => decrease X velocity
		bne.s	notup
		cmp.w	#-8,d3
		blt.s	nokeys
		subq.w	#1,d3
		bra.s	nomore

notup		cmp.w	#scanins,d0	;insert => increase Z velocity
		bne.s	notins
		cmp.w	#8,d5
		bgt.s	nokeys
		addq.w	#1,d5
		bra.s	nomore

notins		cmp.w	#scanclr,d0	;clr/home => decrease Y velocity
		bne.s	notclr
		cmp.w	#-8,d5
		blt.s	nokeys
		subq.w	#1,d5
		bra.s	nomore

notclr		cmp.w	#scans,d0
		bne.s	nots
		not.w	syncflag	;flip the sync mode flag
		bra.s	nomore

nots		subq.w	#1,d0		;it's last one. This is faster.
		bne.s	stopit		;if scancode wasn't 1 (ESC)
		move.w	d0,-(sp)	;push code for 'terminate process' (0)
		trap	#1		;call GEMDOS
		illegal			;won't get this far

stopit		moveq	#0,d3		;any other key stops it spinning
		moveq	#0,d4
		moveq	#0,d5

nomore		move.w	d3,xv
		move.w	d4,yv
		move.w	d5,zv
nokeys		move.w	#$00ff,d0
		add.w	d3,xang
		and.w	d0,xang
		add.w	d4,yang
		and.w	d0,yang
		add.w	d5,zang
		and.w	d0,zang

spinit		lea	sintab,a0
		lea	coords,a1
		lea	newco,a2
		lea	oldco,a3

		move.w	(a1)+,d5	;get count of No of points to transform
muloop		move.w	(a1)+,d0	; get next x
		move.w	(a1)+,d1	; get next y
		move.w	(a1)+,d2	; get next z

		move.l	(a2),(a3)+	;copy 3 words from newco to old
		move.w	4(a2),(a3)+	;auto inc'ing as we go

* Here comes 3 matrix multiplies, spinning the axes separately is
* faster than working out the product matrix & transforming with that.
* No, of course it doesn't look much like a matrix multiply, won't
* catch me wasting time with all those checks for zero - unless
* somemone brings out a chip with a MATMULS instruction.

* FIRST SPIN Z AXIS
doz		move.w	zang,d7		;get Z axis rotation angle (0-255)
* do trig with lookup tables
		move.b	 0(a0,d7.w),d6	;fast sine theta
		move.b	64(a0,d7.w),d7	;and cosine too
		ext.w	d6
		ext.w	d7		;need them as words for mult
		move.w	d0,d3		; copy the ones we need twice
		move.w	d1,d4		; so we don't have to get them again
		muls	d7,d0		; x.cos
		muls	d6,d4		; y.sin
		sub.w	d4,d0		; x.cos - y.sin
		asr.w	#7,d0		;new x --> d0. Scale cos fixed point.
		muls	d6,d3		; x.sin
		muls	d7,d1		; y.cos
		add.w	d3,d1		; x.sin + y.cos
		asr.w	#7,d1		;new y --> d1

* THEN SPIN X AXIS
dox		move.w	xang,d7		;get theta
		move.b	 0(a0,d7.w),d6	;sine theta
		move.b	64(a0,d7.w),d7	;cosine theta
		ext.w	d6
		ext.w	d7		;extend them to 16 bits
		move.w	d1,d3		;copy y
		move.w	d2,d4		;copy z
		muls	d7,d1		; y.cos
		muls	d6,d4		; z.sin
		sub.w	d4,d1		; y.cos - z.sin
		asr.w	#7,d1		;new y --> d1
		muls	d6,d3		; y.sin
		muls	d7,d2		; z.cos
		add.w	d3,d2		; y.sin + z.cos
		asr.w	#7,d2		;new z --> d2

* AND FINALLY Y AXIS
doy		move.w	yang,d7		;get theta
		move.b	 0(a0,d7.w),d6	;sine theta
		move.b	64(a0,d7.w),d7	;cosine theta
		ext.w	d6
		ext.w	d7		;extend them to 16 bits
		move.w	d0,d3		;copy x
		move.w	d2,d4		;copy z
		muls	d7,d0		; x.cos
		muls	d6,d4		; z.sin
		add.w	d4,d0		; x.cos + y.sin
		asr.w	#7,d0		;new x --> d0
		muls	d6,d3		; x.sin
		muls	d7,d2		; z.cos
		sub.w	d3,d2		; z.cos - x.sin
		asr.w	#7,d2		;new z --> d2

		IFNE	perspective	;assemble if symbol non zero.

horizon		equ	1024		;perspective horizon distance
* I'm sure there's a faster way of doing this, but for now...
		moveq	#10,d4		;shift count to divide by horizon
		move.w	#horizon-128,d3
		sub.w	d2,d3		;d3 = persp - (distance away)
		muls	d3,d0
		asr.l	d4,d0		;re-scale x (divide by horizon)
		muls	d3,d1
		asr.l	d4,d1		;re-scale y

		ENDC

		add.w	#cx,d0		;add offset for centre of screen
		add.w	#cy,d1		; ditto for vertical.

update		move.w	d0,(a2)+	;copy new x to newco array
		move.w	d1,(a2)+	; and new y
		move.w	d2,(a2)+	; and new z too.

		dbf	d5,muloop	;loop until done all points in image

syncwait	tst.w	syncflag	;check flag to see if syncing on
		beq.s	undraw		;no, so draw right away.
		move.w	#37,-(sp)	;push code for vsync()
		trap	#14		;XBIOS
		addq.l	#2,sp		;tidy up the stack

undraw		move.l	varsav,a5	;get the line-A vars base pointer
		lea	oldco,a3	;point a3 at array of old points
		lea	order,a4	;point a4 at line-list
		move.w	#1,colbit0(a5)	;set color to 1 (BLACK)
		move.w	(a4)+,d4	; get count of No of lines to draw - 1
udloop		move.w	(a4)+,d5	; get index ( point No * 6 )
		move.l	0(a3,d5.w),x1(a5)	;set x1 & y1 in one go
		move.w	(a4)+,d5	; and next index (other end of line)
		move.l	0(a3,d5.w),x2(a5)	;set x2 & y2
		dc.w	line		; draw line
		dbf	d4,udloop

redraw		lea	newco,a3	;point a3 at array of new points
		lea	order,a4	;point a4 at line-list
		clr.w	colbit0(a5)	;set color to 0 (WHITE)
		move.w	(a4)+,d4	; get count of No of lines to draw - 1
drawloop	move.w	(a4)+,d5	; get index ( point No * 6 )
		move.l	0(a3,d5.w),x1(a5)	;set x1 & y1 in one go
		move.w	(a4)+,d5	; and next index (other end of line)
		move.l	0(a3,d5.w),x2(a5)	;set x2 & y2
		dc.w	line		; draw line
		dbf	d4,drawloop

		bra	mainloop	;go spin it some more.

* some 'big-computer' people would insist on having a data section directive
* here but personally I can't see the point unless there's memory management
* so, just to let them know I left it out on purpose.
*
*		data
*
* p.s. if you leave it out you can fetch your data with PC relative addressing
*      but if you put it in, you have to use long absolute.

syncflag	dc.w	0

varsav		dc.l	0

filpat		dc.w	-1	;fill pattern for line-A (solid)

zang		dc.w	0	; Z axis rotation angle
xang		dc.w	0	; X axis rotation angle
yang		dc.w	0	; Y axis rotation angle

zv		dc.w	4	; Z axis rotational velocity
xv		dc.w	4	; X axis rotational velocity
yv		dc.w	4	; Y axis rotational velocity

* Signed, prescaled (* 127) sine/cosine look-up tables. 360 degrees = 255
* + 64 extra entries for cosine table (start 64 further into table )
* Built using a small C program to save typing.

sintab
	dc.b	$00,$03,$06,$09,$0C,$0F,$12,$15	;   0 to   7
	dc.b	$18,$1B,$1E,$21,$24,$27,$2A,$2D	;   8 to  15
	dc.b	$30,$33,$36,$39,$3B,$3E,$41,$43	;  16 to  23
	dc.b	$46,$49,$4B,$4E,$50,$52,$55,$57	;  24 to  31
	dc.b	$59,$5B,$5E,$60,$62,$64,$66,$67	;  32 to  39
	dc.b	$69,$6B,$6C,$6E,$70,$71,$72,$74	;  40 to  47
	dc.b	$75,$76,$77,$78,$79,$7A,$7B,$7B	;  48 to  55
	dc.b	$7C,$7D,$7D,$7E,$7E,$7E,$7E,$7E	;  56 to  63
	dc.b	$7E,$7E,$7E,$7E,$7E,$7E,$7D,$7D	;  64 to  71
	dc.b	$7C,$7B,$7B,$7A,$79,$78,$77,$76	;  72 to  79
	dc.b	$75,$74,$72,$71,$70,$6E,$6C,$6B	;  80 to  87
	dc.b	$69,$67,$66,$64,$62,$60,$5E,$5B	;  88 to  95
	dc.b	$59,$57,$55,$52,$50,$4E,$4B,$49	;  96 to 103
	dc.b	$46,$43,$41,$3E,$3B,$39,$36,$33	; 104 to 111
	dc.b	$30,$2D,$2A,$27,$24,$21,$1E,$1B	; 112 to 119
	dc.b	$18,$15,$12,$0F,$0C,$09,$06,$03	; 120 to 127
	dc.b	$00,$FD,$FA,$F7,$F4,$F1,$EE,$EB	; 128 to 135
	dc.b	$E8,$E5,$E2,$DF,$DC,$D9,$D6,$D3	; 136 to 143
	dc.b	$D0,$CD,$CA,$C7,$C5,$C2,$BF,$BD	; 144 to 151
	dc.b	$BA,$B7,$B5,$B2,$B0,$AE,$AB,$A9	; 152 to 159
	dc.b	$A7,$A5,$A2,$A0,$9E,$9C,$9A,$99	; 160 to 167
	dc.b	$97,$95,$94,$92,$90,$8F,$8E,$8C	; 168 to 175
	dc.b	$8B,$8A,$89,$88,$87,$86,$85,$85	; 176 to 183
	dc.b	$84,$83,$83,$82,$82,$82,$82,$82	; 184 to 191
	dc.b	$82,$82,$82,$82,$82,$82,$83,$83	; 192 to 199
	dc.b	$84,$85,$85,$86,$87,$88,$89,$8A	; 200 to 207
	dc.b	$8B,$8C,$8E,$8F,$90,$92,$94,$95	; 208 to 215
	dc.b	$97,$99,$9A,$9C,$9E,$A0,$A2,$A5	; 216 to 223
	dc.b	$A7,$A9,$AB,$AE,$B0,$B2,$B5,$B7	; 224 to 231
	dc.b	$BA,$BD,$BF,$C2,$C5,$C7,$CA,$CD	; 232 to 239
	dc.b	$D0,$D3,$D6,$D9,$DC,$DF,$E2,$E5	; 240 to 247
	dc.b	$E8,$EB,$EE,$F1,$F4,$F7,$FA,$FD	; 248 to 255
	dc.b	$00,$03,$06,$09,$0C,$0F,$12,$15	; 256 to 263
	dc.b	$18,$1B,$1E,$21,$24,$27,$2A,$2D	; 264 to 271
	dc.b	$30,$33,$36,$39,$3B,$3E,$41,$43	; 272 to 279
	dc.b	$46,$49,$4B,$4E,$50,$52,$55,$57	; 280 to 287
	dc.b	$59,$5B,$5E,$60,$62,$64,$66,$67	; 288 to 295
	dc.b	$69,$6B,$6C,$6E,$70,$71,$72,$74	; 296 to 303
	dc.b	$75,$76,$77,$78,$79,$7A,$7B,$7B	; 304 to 311
	dc.b	$7C,$7D,$7D,$7E,$7E,$7E,$7E,$7E	; 312 to 319


* data to do with the 3D image follows :-

* Definition of object - x,y,z co-ordinates of 3D image to rotate

coords	dc.w	 13-1		;No of points to work on minus 1
	dc.w	-64,-64,-64	;6 bytes per point
	dc.w	 64,-64,-64	; but I'll use auto inc wherever poss
	dc.w	 64,64,-64	; to save having to multiply by 6
	dc.w	-64,64,-64	; to get an index.
	dc.w	-64,-64,64
	dc.w	 64,-64,64
	dc.w	 64,64,64
	dc.w	-64,64,64

	dc.w	-44,44,-44
	dc.w	-44,-44,-44
	dc.w	  0,20,-44
	dc.w	 44,-44,-44
	dc.w	 44,44,-44

* this table shows which points to put lines between
* doing the index multiply ( *6 ) now saves time later.

order	dc.w	16-1		; No of lines to draw minus one
* CUBE
	dc.w	0*6,1*6		; join point 0 to 1
	dc.w	1*6,2*6		; 1 to 2
	dc.w	2*6,3*6		; 2 to 3
	dc.w	3*6,0*6		; 3 to 0
	dc.w	4*6,5*6		; 4 to 5
	dc.w	5*6,6*6		; 5 to 6
	dc.w	6*6,7*6		; 6 to 7
	dc.w	7*6,4*6		; 7 to 4
	dc.w	0*6,4*6		; 0 to 4
	dc.w	1*6,5*6		; 1 to 5
	dc.w	2*6,6*6		; 2 to 6
	dc.w	3*6,7*6		; 3 to 7
* M
	dc.w	8*6,9*6		; 8 to 9
	dc.w	9*6,10*6	; 9 to 10
	dc.w	10*6,11*6	; 10 to 11
	dc.w	11*6,12*6	; 11 to 12

* reserve 39 words for old points array for undraw

oldco	dcb.w	39,0	;make sure this block is harmless on first loop.
			;cos it'll still get un-drawn.

* and another 39 for new points array for next re-draw

newco	ds.w	39

	end
