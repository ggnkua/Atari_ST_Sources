******************************************************
*                                                    *
*      Line-A graphics bindings for Lattice C        *
*                                                    *
*                     by                             *
*                                                    *
*            Andy Beveridge    15/12/85              *
*                                                    *
* As an added bonus for anyone with ST Lattice C     *
* here is a set of bindings to some of the line-A    *
* graphics primitives. If all you want to do is plot *
* a few points, draw a few lines, GEM can be a real  *
* pain. These bindings will produce much less code   *
* and run a lot faster. They could be extended to    *
* include filled polygons, and seed fill.	     *
*                                                    *
*(See also the example programs BWDEMO.C & SPTEST.C) *
*                                                    *
******************************************************

* THE LINE-A VARIABLES (as offsets from base pointer)
* usually accessed as  name(a0)
 
v_planes	equ	0	;No of video planes
v_lin_wr	equ	2	;No of bytes per video line
contrl		equ	4	;long pointer to CONTRL array
intin		equ	8	;long pointer to INTIN array
ptsin		equ	12	;pointer to PTSIN array
intout		equ	16	;pointer to INTOUT array
ptsout		equ	20	;pointer to PTSOUT array
fgbp1		equ	24	;current color bit-plane 0 value
fgbp2		equ	26	; ditto for bit plane 1
fgbp3		equ	28	;bit plane 2
fgbp4		equ	30	;bit plane 3
lstlin		equ	32	;"set this to -1 and forget it."\!
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

* code proper starts here...
*
* some C bindings for the line-A interface
* so I don't have to use GEM just for simple graphics
*

	xdef	a_init,a_plot,a_point,a_line,a_color
	xdef	a_rectf,a_sprite,a_unspri

* INITIALISE THE LINE-A, get a pointer to line-A variables.
* MUST be called before using any of the other line-A functions.
*	LONG	a_init()   returns long pointer to line-A variables

a_init	move.l	a2,-(sp)		;save a2 on stack
	dc.w	init			;call line-A for init
	move.l	a0,varsav		;save line-A vars ptr
	move	#-1,lstlin(a0)
	move	#-1,ln_mask(a0)
	clr.w	wrt_mode(A0)
	move.l	(sp)+,a2		;pull a2 back off stack
	rts				;exit with varptr in d0

* PLOT A SINGLE PIXEL AT X,Y IN COLOR C
*	void	a_plot(x,y,c)

a_plot	move.l	a2,-(sp)	;save a2 on stack
	move.l	varsav,a0	;get pointer to line-A vars
	move.l	intin(a0),a1	;get pointer to start of INTIN array
	move	18(sp),(a1)	;move colour word to intin[0]
	move.l	ptsin(a0),a1	;get pointer to start of PTSIN array
	move	14(sp),2(a1)	;move y to ptsin[1]
	move	10(sp),(a1)	;move x to ptsin[0]
	dc.w	putpix
	move.l	(sp)+,a2	;restore a2 from stack
	
	rts

* GET COLOR OF PIXEL AT X,Y
*	word	a_point(x,y)

a_point	move.l	a2,-(sp)	;save a2 on stack
	move.l	varsav,a0	;as usual
	move.l	ptsin(a0),a1	;get ptr to PTSIN array
	move	14(sp),2(a1)	;ptsin[1] = y
	move	10(sp),(a1)	;ptsin[0] = x
	dc.w	getpix		;get pixel value to d0
	move.l	(sp)+,a2	;restore a2 from top of stack
	rts

* DRAW A STRAIGHT LINE BETWEEN TWO POINTS
*	void	a_line(x1,y1,x2,y2)

a_line	move.l	a2,-(sp)	;push a2 on stack
	move.l	varsav,a0
	move	22(sp),y2(a0)
	move	18(sp),x2(a0)
	move	14(sp),y1(a0)
	move	10(sp),x1(a0)
	dc.w	line
	move.l	(sp)+,a2	;pull a2 off stack
	rts

* SET COLOR INDEX FOR LINE & FILL OPERATIONS
*	void	a_color(n)  where n is 0 to 15

a_color
	move.l	varsav,a0
	clr.l	fgbp1(a0)	;clear planes 1 & 2
	clr.l	fgbp3(a0)	;clear planes 3 & 4
	move	6(sp),d0	;get new colour index from stack
	roxr.w	#1,d0		;move bit 0 into X
	roxl	fgbp1(a0)	;and move X into plane 1 colour
	roxr.w	#1,d0		;and now bit 1
	roxl	fgbp2(a0)	; etc...
	roxr.w	#1,d0
	roxl	fgbp3(a0)
	roxr.w	#1,d0
	roxl	fgbp4(a0)
	rts

* DRAW A FILLED RECTANGLE
*	void	a_rectf( x1, y1, x2, y2 )

a_rectf	move.l	a2,-(sp)	;save a2 on stack
	move.l	varsav,a0	;point a0 to line-A vars
	move	10(sp),x1(a0)	; 6 + 4(sp) = parm1
	move	14(sp),y1(a0)	; 6 + 8(sp) = parm2
	move	18(sp),x2(a0)	; 6 +12(sp) = parm3
	move	22(sp),y2(a0)	; 6 +16(sp) = parm4
	dc.w	frect		;do a line A 'draw rectangle'
	move.l	(sp)+,a2	;restore a2
	rts

* DRAW A SPRITE, saving the background in a buffer
*	void	a_sprite( x, y, sprdef, sprsav )	/* draw sprite */
*	WORD	x,y	co-ordinates of sprite hot-spot
*	WORD	*sprdef	   pointer to sprite definition block
*	WORD	*sprsav    pointer to sprite bg save block

a_sprite
	movem.l	a2/a6,-(sp)	;save some registers for C
	move.w	14(sp),d0	; equiv old  6(sp),d0    get X co
	move.w	18(sp),d1	; 10(sp),d0		 get Y co
	move.l	20(sp),a0	; 12(sp),d0	get pointer to definition
	move.l	24(sp),a2	; 16(sp),d0	get pointer to save block
	dc.w	dosprite	; line-A opcode to draw sprite
	movem.l	(sp)+,a2/a6	;restore registers for C
	rts			;and return to caller

* ERASE SPRITE BY REDRAWING SAVED BACKGROUND
*	void	a_unsprite( sprsav )	/* undraw sprite */

a_unspri			;cut name to 8 chars for linking to C
	movem.l	a2/a6,-(sp)	;save registers for C
	move.l	12(sp),a2	; 4(sp),a2	get pointer to save block
	dc.w	unsprite	; use line-A opcode to un-draw sprite
	movem.l	(sp)+,a2/a6	;restore C registers
	rts

varsav	dc.l	0		;storage space for varptr

	end

