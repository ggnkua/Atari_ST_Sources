*******************************  blastman.s  **********************************
*
* $Revision: 3.3 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/blastman.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/02/13 17:51:35 $     $Locker:  $
* =============================================================================
*
* $Log:	blastman.s,v $
* Revision 3.3  91/02/13  17:51:35  lozben
* Entered line ".globl KG_BLT" at the top of the file.
* 
* Revision 3.2  91/02/12  16:00:06  lozben
* Forgot to include the file "lineaequ.s".
* 
* Revision 3.1  91/01/23  12:36:15  lozben
* All the linea vars are now referenced off a linea struct pointer.
* 
* Revision 3.0  91/01/03  15:06:17  lozben
* New generation VDI
* 
*******************************************************************************

.include	"lineaequ.s"

B_WD		equ	-76	; width of block in pixels
B_HT		equ	-74	; height of block in pixels

S_XMIN		equ	-62	; minimum X: source
S_YMIN		equ	-60	; minimum Y: source
D_XMIN		equ	-48	; minimum X: destination
D_YMIN		equ	-46	; minimum Y: destination
S_XMAX		equ	-18	; maximum X: source	
S_YMAX		equ	-16	; maximum Y: source	
D_XMAX		equ	-10	; maximum X: destination
D_YMAX		equ	-08	; maximum Y: destination

FRAME_LEN	equ	 76

	.globl	KG_BLT

	.text

*  in:
*	a6.l	points to 76 byte parameter block
KG_BLT:

	add.w	#FRAME_LEN,a6		; a6 -> top of frame

	move.w	S_XMIN(a6),d0		; d0 <- X min SRC
	move.w	S_YMIN(a6),d5		; d5 <- future home of Y max SRC
	move.w	D_XMIN(a6),d2		; d2 <- X min DST
	move.w	D_YMIN(a6),d7		; d7 <- future home of Y max DST
	move.w	d0,d4			; d4 <- future home of X max SRC
	move.w	d2,d6			; d6 <- future home of X max DST

	move.w	B_HT(a6),d1
	subq.w	#1,d1

	add.w	d1,d5			; d5 <- Y max source
	add.w	d1,d7			; d7 <- Y max destination

	move.w	B_WD(a6),d1
	subq.w	#1,d1

	add.w	d1,d4			; d4 <- X max source
	add.w	d1,d6			; d6 <- X max destination

	move.w	d4,S_XMAX(a6)
	move.w	d5,S_YMAX(a6)
	move.w	d6,D_XMAX(a6)
	move.w	d7,D_YMAX(a6)

        move.l  _lineAVar,a5            ; a5 -> linea var struct
	move.l	V_ROUTINES(a5),a5	; a5 -> routines vector list
	move.l	V_BLAST(a5),a5		; a5 -> desired version of blast_man
	jmp	(a5)			; routine ("blast_man" uses BLASTER)

	.end
