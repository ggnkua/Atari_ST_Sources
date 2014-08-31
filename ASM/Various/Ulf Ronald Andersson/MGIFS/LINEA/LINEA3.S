*
*	linea3 - draw line
*
*	synopsis:
*
*	void linea3 (struct line_a *ptr, x1, y1, x2, y2, mode, mask, opt);
*
*	uses line A to draw a line from x1,y1 to x2,y2.
*

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

	unlk	a6

	rts

	.end

