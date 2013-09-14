
	globl	_scanner


*  scan_region(fdb, sx, sy, sh, &rxmin, &rymin, &rxmax)
*
*  iN:	long	fdb		pointer to Form Definition Block
*	int	sx,sy		position to start search
*	int	sh		height of rectangle being searched for
*
* oUT:		d0.w		0:    no more rectangles
*				else: rectangle data good
*	int	rxmin, rymin	position of rectangle upper left corner
*		rxmax		position of rectangle right side
*
*
*	Form Definition Block
*
*	long	BASE		base address of memory form
*	int	FORM_WD		width of form in bytes
*	int	FORM_HT		height of form in pixels
*	int	B_XMIN		Xmin of bounding rectangle
*	int	B_YMIN		Ymin of bounding rectangle
*	int	B_XMAX		Xmax of bounding rectangle
*	int	B_YMAX		Xmax of bounding rectangle

WS	equ	20

FDB	equ	WS+04
SX	equ	WS+08
SY	equ	WS+10
SH	equ	WS+12
RXMIN	equ	WS+14
RYMIN	equ	WS+18
RXMAX	equ	WS+22

BASE	equ	00
FORM_WD	equ	04
FORM_HT	equ	06
B_XMIN	equ	08
B_YMIN	equ	10
B_XMAX	equ	12
B_YMAX	equ	14


_scanner:

	movem.l	d3-d7,-(sp)

	move.l	FDB(sp),a2	; a2 -> form definition block
	move.w	B_XMIN(a2),d0	; d0 <- minimum X search position
	move.w	SX(sp),d3	; d3 <- current X search position
	cmp.w	d0,d3		; clip if neccessary
	bcc	.1

	move.w	d0,d3

.1:	move.w	SY(sp),d5	; d5 <- current Y search position
	move.w	SH(sp),d6
	subq.w	#1,d6		; d6 <- dbra height count

	move.w	FORM_WD(a2),d1	; d1 <- offset to next line
	move.w	d5,d0
	mulu	d1,d0		; d0 <- offset to (0,SY)

	move.l	BASE(a2),a0	; a0 -> base of memory form
	add.l	d0,a0		; a0 -> (0,SY)
	move.w	d3,d0		; d0 <- SX
	lsr.w	#4,d0
	add.w	d0,d0		; d0 <- offset to word containing (SX,0)
	add.w	d0,a0		; a0 -> beginning of search (sx,sy)

	move.w	d3,d2
	not.w	d2
	and.w	#15,d2		; d2 -> bit within word where search begins

	move.w	B_XMAX(a2),d4	; d4 <- maximum X of bounding rectangle
	cmp.w	d4,d3		; if SX is beyond right border,
	bhi	.eol		; go to next line


*	find inscribed rectangle Xmin

.100:	move.l	a0,a1
	move.w	(a0)+,d0		; d0 <- data from 1st row
	move.w	d6,d7			; d7 <- height counter

.200:	and.w	(a1),d0			; d0 <- compressed column
	add.w	d1,a1
	dbra	d7,.200

.300:	btst.l	d2,d0
	bne	.xmin

	cmp.w	d4,d3
	bcc	.eol

	addq.w	#1,d3
	dbra	d2,.300

	moveq.l	#15,d2
	bra	.100	


.eol:	add.w	SH(sp),d5		; d5 <- newY := oldY + search height
	move.w	B_YMAX(a2),d7		; d7 <- bounding rectangle Ymax
	sub.w	d6,d7			; d7 <- maximum newY
	cmp.w	d7,d5			; if new Y is greater than maximum ...
	bls	.cont			; search terminates

	clr.w	d0			; no more rectangles
	bra	.end			; clean up and leave

.cont:	move.w	d5,d7
	mulu	d1,d7			; d7 <- offset to (0,newY)
	move.l	BASE(a2),a0
	add.l	d7,a0			; a0 -> (0,newY)

	move.w	B_XMIN(a2),d3		; d3 <- initial search X

	move.w	d3,d2
	not.w	d2
	and.w	#15,d2			; d2 -> initial intra-word bit

	move.w	d3,d7
	lsr.w	#4,d7
	add.w	d7,d7
	add.w	d7,a0			; a0 -> (B_XMIN, Ynew)

	move.w	B_XMAX(a2),d4		; d4 <- Xmax for bounding region
	bra	.100


.xmin:	move.l	RXMIN(sp),a1
	move.w	d3,(a1)			; save RX
	move.l	RYMIN(sp),a1
	move.w	d5,(a1)			; save RY


*	is Xmax in same word as Xmin ?


.400:	btst.l	d2,d0
	beq	.xmax

	cmp.w	d4,d3
	bcc	.xmax

	addq.w	#1,d3
	dbra	d2,.400	


*	search for Xmax in folowing words

.500:	move.l	a0,a1
	move.w	(a0)+,d0		; d0 <- data from 1st row
	moveq.l	#15,d2			; d2 -> hi bit in word
	move.w	d6,d7			; d7 <- height counter

.600:	and.w	(a1),d0			; d0 <- compressed column
	add.w	d1,a1
	dbra	d7,.600

.700:	btst.l	d2,d0
	beq	.xmax

	addq.w	#1,d3
	cmp.w	d4,d3
	bhi	.xmax

	dbra	d2,.700
	bra	.500	


.xmax:	move.l	RXMAX(sp),a1
	subq.w	#1,d3
	move.w	d3,(a1)
	st	d0			; data is good

.end:	movem.l	(sp)+,d3-d7
	rts


