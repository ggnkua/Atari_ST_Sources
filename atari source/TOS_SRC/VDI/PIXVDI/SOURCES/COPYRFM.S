*********************************  mouse.s  ***********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/copyrfm.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/29 11:50:53 $     $Locker:  $
* =============================================================================
*
* $Log:	copyrfm.s,v $
* Revision 3.2  91/07/29  11:50:53  lozben
* Fixed some bugs.
* 
* Revision 3.1  91/02/08  16:44:24  lozben
* Adjusted the code to work with multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:06:41  lozben
* New generation VDI
* 
* Revision 2.3  90/02/16  12:22:10  lozben
* Fixed some of the code so that it can be assembled with mas.
* 
* Revision 2.2  89/05/19  17:42:02  lozben
* Fixed the setup to check for 8 planes as well as 4, 2, and 1.
* 
* Revision 2.1  89/02/21  17:18:45  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************

.include		"lineaequ.s"

	.globl	_COPY_RFM

*
*
* title:	copy_rfm
*
* purpose:	bitblt operation using 1 of 16 logical operations.
*		device dependent format only.
*
* author:	jim eisenstein
*
*	MEMORY FORM DEFINITION BLOCK (MFDB) OFFSETS

MF_BAS_AD	equ	00	; memory form base address (0: physical device)
MF_WD_PIX	equ	04	; form width in pixels (form width in wrds /16)
MF_HT_PIX	equ	06	; form height in pixels
MF_WD_WRD	equ	08	; form width in words
MF_FORMAT	equ	10	; form format flag (0:device specific 1:stndrd)
MF_PLANES	equ	12	; number of memory planes

*	CONTRL ARRAY OFFSETS

C_MFDB_S	equ	14	; pointer to source MFDB
C_MFDB_D	equ	18	; pointer to destination MFDB

*	INTIN ARRAY OFFSETS

I_LOG_OP	equ	00	; logic operation code
I_COL_1		equ	02
I_COL_0		equ	04

*	PTSIN ARRAY OFFSET

P_XMIN_S	equ	00	; x-coordinate of upper left of src rectangle
P_YMIN_S	equ	02	; y-coordinate of upper left of src rectangle
P_XMAX_S	equ	04	; x-coordinate of lower right of src rectangle
P_YMAX_S	equ	06	; y-coordinate of lower right of src rectangle

P_XMIN_D	equ	08	; x-coordinate of upper left of dest rectangle
P_YMIN_D	equ	10	; y-coordinate of upper left of dest rectangle
P_XMAX_D	equ	12	; x-coordinate of lower right of dest rectangle
P_YMAX_D	equ	14	; y-coordinate of lower right of dest rectangle


*       FRAME PARAMETERS

B_WD		equ	-76	; width of block in pixels		    +00
B_HT		equ	-74	; height of block in pixels		    +02 

PLANE_CT	equ	-72	; number of consequitive planes to blt	    +04

FG_COL		equ	-70	; fg color (logic op table index:hi bit)    +06
BG_COL		equ	-68	; bg color (logic op table index:lo bit)    +08
OP_TAB		equ	-66	; logic ops for all fg and bg combos	    +10
S_XMIN		equ	-62	; minimum X: source			    +14
S_YMIN		equ	-60	; minimum Y: source			    +16
S_FORM		equ	-58	; source form base address		    +18
S_NXWD		equ	-54	; offset to next word in line  (in bytes)   +22
S_NXLN		equ	-52	; offset to next line in plane (in bytes)   +24
S_NXPL		equ	-50	; off to nxt plane from strt of cur plane   +26

D_XMIN		equ	-48	; minimum X: destination		    +28
D_YMIN		equ	-46	; minimum Y: destination		    +30
D_FORM		equ	-44	; destination form base address		    +32
D_NXWD		equ	-40	; offset to next word in line  (in bytes)   +36
D_NXLN		equ	-38	; offset to next line in plane (in bytes)   +38
D_NXPL		equ	-36	; offs to nxt plane from strt of cur plane  +40

P_ADDR		equ	-34	; address of pattern buffer  (0:no pattern) +42
P_NXLN		equ	-30	; offset to next line in pattern (in bytes) +46
P_NXPL		equ	-28	; offset to nxt plane in pattern (in bytes) +48
P_MASK		equ	-26	; pattern index mask			    +50

***					    ***
***   these parameters are internally set   ***
***					    ***

P_INDX		equ	-24	; initial pattern index			    +52

S_ADDR		equ	-22	; initial source address 		    +54
S_XMAX		equ	-18	; maximum X: source			    +58
S_YMAX		equ	-16	; maximum Y: source			    +60

D_ADDR		equ	-14	; initial destination address		    +62
D_XMAX		equ	-10	; maximum X: destination		    +66
D_YMAX		equ	-08	; maximum Y: destination		    +68

INNER_CT	equ	-06	; blt inner loop initial count		    +70
DST_WR		equ	-04	; destination form wrap (in bytes)	    +72
SRC_WR		equ	-02	; source form wrap (in bytes)		    +74


FRAME_LEN	equ	 76

DEV_COL		equ	 26	; offset in _DEV_TAB to number of colors
PAT_FLAG	equ	  4	; flag:1 SRCE and PATTERN   flag:0 SOURCE only

_COPY_RFM:

	movem.l	d0-d7/a0-a5,-(sp)
	link	a6,#-FRAME_LEN

*   test for legal logic ops and set color (if op 16)

	move.l  _lineAVar,a1		; a1 -> linea var struct
	move.l	_INTIN(a1),a2		; a2 -> INTIN array
	move.w	I_LOG_OP(a2),d2		; d2 <- logic op #


*   pattern ?


	movea.l	#0,a3
	bclr	#PAT_FLAG,d2		; check pat flag and revert to log op #
	beq	no_pattern

	move.l	_patptr(a1),a3
	moveq	#0,d0			; next plane pattern offset default.
	tst.w	_multifill(a1)		; multi-plane pattern?
	beq	pat_parm		; no, set up the parameter.
	moveq	#32,d0			; yes, next plane pat offset = 32.

pat_parm:

	move.w	d0,P_NXPL(a6)
	move.w	#02,P_NXLN(a6)
	move.w	#$1E,P_MASK(a6)

no_pattern:

	move.l	a3,P_ADDR(a6)

*   setup planes for each MFDB

	move.l	_CONTRL(a1),a3		; a3 -> CONTRL array

	move.l	C_MFDB_S(a3),a5		; a5 -> source MFDB
	move.l	C_MFDB_D(a3),a4		; a4 -> destination MFDB


src_form:

	move.l	MF_BAS_AD(a5),d6	; if source is screen, use default
	bne	src_calc

	move.l	_v_bas_ad,d6
	move.w	_v_planes(a1),d0	; source form is screen
	move.w	_v_lin_wr(a1),d4
	bra	dst_form

src_calc:

	move.w	MF_PLANES(a5),d0	; d0 <- source plane count
	move.w	MF_WD_WRD(a5),d4
	add.w	d4,d4
	mulu	d0,d4			; d4 <- form wrap (in bytes)


dst_form:

	move.l	MF_BAS_AD(a4),d7	; if destination is screen, use default
	bne	dst_calc

	move.l	_v_bas_ad,d7
	move.w	_v_planes(a1),d1
	move.w	_v_lin_wr(a1),d5
	bra	compare

dst_calc:

	move.w	MF_PLANES(a4),d1	; d1 <- destination plane count
	move.w	MF_WD_WRD(a4),d5
	add.w	d5,d5
	mulu	d1,d5			; d5 <- form wrap (in bytes)


compare:

	move.w	d1,PLANE_CT(a6)		; save the total plane count
	add.w	d0,d0			; for dev dependent forms NXWD=2*planes
	move.w	d0,S_NXWD(a6)
	add.w	d1,d1
 	move.w	d1,D_NXWD(a6)

	move.w	d4,S_NXLN(a6)
	move.w	d5,D_NXLN(a6)
	move.l	d6,S_FORM(a6)
	move.l	d7,D_FORM(a6)

	moveq.l	#2,d4			; d4 <- next plane offset (source)
	moveq.l	#2,d5			; d5 <- next plane offset (destination)

	tst.w	_COPYTRAN(a1)
	beq	standard_ops



new_ops:

	cmp.w	#02,d0
	bne	bad_parameter		; source must be mono plane

	clr.w	d4			; use only the first plane for the src

	lea	_MAP_COL,a0

	move.w	I_COL_0(a2),d6		; d6 <- background color index
	cmp.w	DEV_COL+_DEV_TAB(a1),d6	; index in range ?
	bmi	col_0_ok

	moveq.l	#1,d6			; if out of range, revert to index 1

col_0_ok:

	add.w	d6,d6			; d6 <- offset into color map
	move.w	(a0,d6.w),d6		; d6 <- background color

	move.w	I_COL_1(a2),d7		; d7 <- foreground color index
	cmp.w	DEV_COL+_DEV_TAB(a1),d7	; index in range ?
	bmi	col_1_ok

	moveq.l	#1,d7			; if out of range, revert to index 1

col_1_ok:	

	add.w	d7,d7			; d7 <- offset into color map
	move.w	(a0,d7.w),d7		; d7 <- foreground color

	cmp.w	#01,d2
	beq	replace_mode
	cmp.w	#02,d2
	beq	transparent_mode
	cmp.w	#03,d2
	beq	xor_mode
	cmp.w	#04,d2
	bne	bad_parameter


inverse_transparent_mode:

	move.b	#01,OP_TAB+00(a6)	; fg:0 bg:0  D' <- S and D
	move.b	#13,OP_TAB+01(a6)	; fg:0 bg:1  D' <- [not S] or D
	clr.w	FG_COL(a6)		; were only interested in one color
	move.w	d6,BG_COL(a6)		; save the color of interest

	cmp.w	#PIXPACKED,form_id(a1)	; see if we're in px packed
	bne	the_clipper
	move.b	#13,OP_TAB+00(a6)	; (NOT S) OR D
	move.w	d7,FG_COL(a6)
	bra	the_clipper

transparent_mode:

	move.b	#04,OP_TAB+00(a6)	; fg:0 bg:0  D' <- [not S] and D
	move.b	#07,OP_TAB+02(a6)	; fg:1 bg:0  D' <- S or D
	clr.w	BG_COL(a6)		; were only interested in one color
	move.w	d7,FG_COL(a6)		; save the color of interest

	cmp.w	#PIXPACKED,form_id(a1)	; see if we're in px packed
	bne	the_clipper
	move.b	#7,OP_TAB+00(a6)	; S OR D
	move.w	d6,BG_COL(a6)
	bra	the_clipper


replace_mode:

	move.w	d6,BG_COL(a6)		; save fore and background colors
	move.w	d7,FG_COL(a6)

	move.b	#00,OP_TAB+00(a6)	; fg:0 bg:0  D' <- 0
	move.b	#12,OP_TAB+01(a6)	; fg:0 bg:1  D' <- not S
	move.b	#03,OP_TAB+02(a6)	; fg:1 bg:0  D' <- S
	move.b	#15,OP_TAB+03(a6)	; fg:1 bg:1  D' <- 1

	cmp.w	#PIXPACKED,form_id(a1)	; see if we're in px packed
	bne	the_clipper
	move.b	#3,OP_TAB+00(a6)	; S
	bra	the_clipper


xor_mode:

	clr.w	BG_COL(a6)
	clr.w	FG_COL(a6)

	move.b	#06,OP_TAB+00(a6)	; fg:0 bg:0  D' <- S xor D

	bra	the_clipper



*   do the standard logic operations

standard_ops:

	cmp.w	#16,d2			; test validity of logic op code
	bcc	bad_parameter	

	cmp.w	d0,d1
	bne	bad_parameter		; planes must be equal in number

	clr.w	BG_COL(a6)		; bg:0 & fg:0 => only first OP_TAB
	clr.w	FG_COL(a6)		; entry will be referenced

	move.b	d2,OP_TAB+00(a6)	; fg:0 bg:0



the_clipper:

	move.w	d4,S_NXPL(a6)		; save inter plane value
	move.w	d5,D_NXPL(a6)

*   stoke up the stack frame

	move.l	_PTSIN(a1),a2		; a2 -> PTSIN array

	tst.w	_CLIP(a1)
	beq	dont_clip		; if clipping disabled, skip the clip

	tst.l	MF_BAS_AD(a4)		; if dst isn't screen, don't clip
	beq	clip_it

dont_clip:

	move.w	P_XMIN_S(a2),d0
	move.w	P_YMIN_S(a2),d1
	move.w	P_XMIN_D(a2),d2
	move.w	P_YMIN_D(a2),d3

	move.w	d0,S_XMIN(a6)
	move.w	d1,S_YMIN(a6)
	move.w	d2,D_XMIN(a6)
	move.w	d3,D_YMIN(a6)

	move.w	P_XMAX_S(a2),d4
	move.w	P_YMAX_S(a2),d5

	move.w	d4,d6
	sub.w	d0,d6
	addq.w	#1,d6
	move.w	d6,B_WD(a6)

	move.w	d5,d7
	sub.w	d1,d7
	addq.w	#1,d7
	move.w	d7,B_HT(a6)

	move.w	P_XMAX_D(a2),d6
	move.w	P_YMAX_D(a2),d7

	bra	max_save


clip_it:	

***   clip Xmin source and destination to window

	move.w	P_XMIN_S(a2),d0
	move.w	P_XMIN_D(a2),d2
	move.w	_XMN_CLIP(a1),d4

	cmp.w	d4,d2			; Xmin dst < Xmin clip => clip Xmin dst
	bge	xmin_clipped		; Xmin dst > Xmin clip => branch

	exg	d4,d2			; d2 <- Xmin dst = Xmin clip
	sub.w	d2,d4			; d4 <- -(amount clipped in x)
	sub.w	d4,d0			; d0 <- adjusted Xmin src

xmin_clipped:

	move.w	d0,S_XMIN(a6)		; d0 <- clipped Xmin source
	move.w	d2,D_XMIN(a6)		; d2 <- clipped Xmin destination


***   clip Xmax destination to window

	move.w	P_XMAX_S(a2),d6
	sub.w	d0,d6			; d6 <- Dx Source
	add.w	d2,d6			; d6 <- Xmax destination

	move.w	_XMX_CLIP(a1),d4

	cmp.w	d4,d6			; Xmax dst > Xmax clip => clip Xmax dst
	ble	xmax_clipped		; Xmax dst < Xmax clip => branch

	exg	d4,d6			; d6 <- Xmax dst = Xmax clip

xmax_clipped:


***   clip Ymin source and destination to window

	move.w	P_YMIN_S(a2),d1
	move.w	P_YMIN_D(a2),d3
	move.w	_YMN_CLIP(a1),d4

	cmp.w	d4,d3			; Ymin dst < Ymin clip => clip Ymin
	bge	ymin_clipped

	exg	d4,d3			; d1 <- Ymin dest = Ymin clip
	sub.w	d3,d4			; d4 <- -(amount clipped in Y)
	sub.w	d4,d1			; d0 <- adjusted source Ymin 

ymin_clipped:

	move.w	d1,S_YMIN(a6)
	move.w	d3,D_YMIN(a6)


*** clip Ymax destination to window

	move.w	P_YMAX_S(a2),d7
	sub.w	d1,d7			; d7 <- Dy Source
	add.w	d3,d7			; d7 <- Ymax destination

	move.w	_YMX_CLIP(a1),d4

	cmp.w	d4,d7			; is Ymax dest > Ymax clip => clip Ymax
	ble	ymax_clipped

	exg	d4,d7			; d7 <- Ymax dest = Ymax clip

ymax_clipped:


*   match source and destination rectangles

	move.w	d6,d4
	sub.w	d2,d4			; d4 <- Dx 

	move.w	d4,B_WD(a6)
	addq.w	#1,B_WD(a6)		; block width
	ble	bad_parameter		; quit if clipped to null

	add.w	d0,d4			; d4 <- Xmax Source


	move.w	d7,d5
	sub.w	d3,d5			; d5 <- Dy 

	move.w	d5,B_HT(a6)
	addq.w	#1,B_HT(a6)		; block height
	ble	bad_parameter

	add.w	d1,d5			; d5 <- Ymax Source


max_save:

*   save all max parameters

	move.w	d4,S_XMAX(a6)
	move.w	d5,S_YMAX(a6)
	move.w	d6,D_XMAX(a6)
	move.w	d7,D_YMAX(a6)

	move.l	V_ROUTINES(a1),a5	; a5 -> routines vector list
	move.l	V_BLAST(a5),a5		; a5 -> desired version of blast_man
	jsr	(a5)			; routine ("blast_man" uses BLASTER)

bad_parameter:

	move.l  _lineAVar,a1		; a1 -> linea var struct
	move.l	_CONTRL(a1),a0
	clr.w	4(a0)			; number of output verticies
	clr.w	8(a0)			; length of intout array

	unlk	a6
	movem.l	(sp)+,d0-d7/a0-a5
	rts
