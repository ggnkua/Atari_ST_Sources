*
* these line A routines are used by mgif. line drawing can be done in
* a zillion ways. this way is 1) easiest for me, 2) not portable to the TT.
* to rewrite line drawing, it is probably not too tough to put pixels
* representing the line into a screen image just by calculating the pixel
* in the screen and ORing a bit there. i chose the line A route since
* 1) i have used it for years and have code laying around, 2) mgif is
* pretty much hardwired to 640x400 monoscreens anyway.
*
* C bindings for line A init ($A000) and line draw ($A003) are included here.
* i use Alcyon as68, but other assemblers should work as well.
*


*****************************************************************************
*	linea0 - return long pointer to line A struct
*
*	synopsis:
*
*	ptr = (struct line_a *) linea0 ();
*****************************************************************************


	.globl	_linea0


	.text

_linea0:
	link	a6,#0			* stack frame
	movem.l	a0-a2,-(a7)		* save regs we clobber (except d0)

	dc.w	$A000			* do it...

* pointer to struct now in d0 and a0. a1 -> array of font headers, a2 -> array
* of linea functions

	movem.l	(a7)+,a0-a2		* restore regs
	unlk	a6			* fix stack frame

	rts				* d0 is pointer







*****************************************************************************
*	linea3 - draw line
*
*	synopsis:
*
*	void linea3 (struct line_a *ptr, int x1, int y1, int x2, int y2,
*		int mode, int mask, int opt);
*
*	uses line A to draw a line from x1,y1 to x2,y2. mode is write mode
*	(0=replace,1=transparent,2=XOR,3=reverse transparent). mask is
*	line mask (like VDI polyline, i think, 0xFFFF for solid, 0x5555 for
*	dash, etc). opt is for last pixel draw (0=draw it, !0=no draw). opt
*	is needed for connected lines in XOR mode, etc.
*****************************************************************************

* linea struct offsets:

CBIT0=24
CBIT1=26
CBIT2=28
CBIT3=30
LSTLIN=32
LNMASK=34
WMODE=36
X1=38
Y1=40
X2=42
Y2=44


* args:  (wrt stack frame ptr a6)

ptr=8
x_1=12
y_1=14
x_2=16
y_2=18
mode=20
mask=22
opt=24



	.globl	_linea3


	.text

_linea3:
	link	a6,#0
	movem.l	a1-a2,-(a7)		* ***JRK Seems these are clobbered

	move.l	ptr(a6),a0		* line A init (a0 -> structure)

	move.w	#1,CBIT0(a0)		* plane 0 (all)
	move.w	#1,CBIT1(a0)		* plane 1 (color only)
	move.w	#1,CBIT2(a0)		* plane 2 (lo res only)
	move.w	#1,CBIT3(a0)		* plane 3 (lo res only)
	move.w	opt(a6),LSTLIN(a0)	* draw last pixel of line?
	move.w	mask(a6),LNMASK(a0)	* line mask (solid=FFFF)
	move.w	mode(a6),WMODE(a0)	* write mode (replace=0)
	move.l	x_1(a6),X1(a0)		* coord of points
	move.l	x_2(a6),X2(a0)

	dc.w	$A003			* draw line

	movem.l	(a7)+,a1-a2		* ***JRK Who else?
	unlk	a6

	rts

	.end

