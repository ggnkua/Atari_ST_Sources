****************************
*  Equates for VME10       *
****************************
vme10		.equ	0	; for selecting VME10 specific software
v_pl_dspl	.equ	$10000	; # of bytes between VME10 video planes
pattern		.equ	1	; for selecting software which applies
*				; a pattern to the source
rev_vid		.equ	1	; for selecting reverse video BLITS

	.globl	_COPY_RFM
	.globl	_CLIP,_XMN_CLIP,_YMN_CLIP,_XMX_CLIP,_YMX_CLIP,_COPYTRAN,_patptr
	.globl	_multifill
	.globl	_v_planes,_v_lin_wr,_v_bas_ad
	.globl	_CONTRL,_INTIN,_PTSIN
	.globl	_DEV_TAB,_MAP_COL
	
	.globl	bit_blt

*
*
* title:
*	
*	copy_rfm
*
* purpose:
*
*	bitblt operation using 1 of 16 logical operations. device dependent
*	format only.
*
* creation date:
*
*	01-nov-84
*
* latest update:
*
*	21-feb-85
*
*
*

*	MEMORY FORM DEFINITION BLOCK (MFDB) OFFSETS

MF_BAS_AD	equ	00	; memory form base address (0: physical device)
MF_WD_PIX	equ	04	; form width in pixels ( form width in words /16)
MF_HT_PIX	equ	06	; form height in pixels
MF_WD_WRD	equ	08	; form width in words
MF_FORMAT	equ	10	; form format flag (0:device specific 1:standard)
MF_PLANES	equ	12	; number of memory planes

*	CONTRL ARRAY OFFSETS

C_MFDB_S	equ	14	; pointer to source MFDB
C_MFDB_D	equ	18	; pointer to destination MFDB

*	INTIN ARRAY OFFSETS

I_LOG_OP	equ	00	; logic operation code
I_COL_1		equ	02
I_COL_0		equ	04

*	PTSIN ARRAY OFFSET

P_XMIN_S	equ	00	; x-coordinate of upper left of source rectangle
P_YMIN_S	equ	02	; y-coordinate of upper left of source rectangle
P_XMAX_S	equ	04	; x-coordinate of lower right of source rectangle
P_YMAX_S	equ	06	; y-coordinate of lower right of source rectangle

P_XMIN_D	equ	08	; x-coordinate of upper left of destination rectangle
P_YMIN_D	equ	10	; y-coordinate of upper left of destination rectangle
P_XMAX_D	equ	12	; x-coordinate of lower right of destination rectangle
P_YMAX_D	equ	14	; y-coordinate of lower right of destination rectangle


*       FRAME PARAMETERS

B_WD		equ	-76	; width of block in pixels			    +00
B_HT		equ	-74	; height of block in pixels			    +02 

PLANE_CT	equ	-72	; number of consequitive planes to blt		    +04

FG_COL		equ	-70	; foreground color (logic op table index:hi bit)    +06
BG_COL		equ	-68	; background color (logic op table index:lo bit)    +08
OP_TAB		equ	-66	; logic ops for all fore and background combos	    +10
S_XMIN		equ	-62	; minimum X: source				    +14
S_YMIN		equ	-60	; minimum Y: source				    +16
S_FORM		equ	-58	; source form base address			    +18

ifne vme10
S_NXWD		equ	-54	; offset to next word in line  (in bytes)	    +22
S_NXLN		equ	-52	; offset to next line in plane (in bytes)	    +24
S_NXPL		equ	-50	; offset to next plane from start of current plane  +26
endc

ifeq vme10
S_NXLN		equ	-54	; offset to next line in plane (in bytes)	    +22
S_NXPL		equ	-52	; offset to next plane from start of current plane  +24
endc

D_XMIN		equ	-48	; minimum X: destination			    +28
D_YMIN		equ	-46	; minimum Y: destination			    +30
D_FORM		equ	-44	; destination form base address			    +32

ifne vme10
D_NXWD		equ	-40	; offset to next word in line  (in bytes)	    +36
D_NXLN		equ	-38	; offset to next line in plane (in bytes)	    +38
D_NXPL		equ	-36	; offset to next plane from start of current plane  +40
endc

ifeq vme10
D_NXLN		equ	-40	; offset to next line in plane (in bytes)	    +36
D_NXPL		equ	-38	; offset to next plane from start of current plane  +38
endc

P_ADDR		equ	-34	; address of pattern buffer   (0:no pattern)	    +42
P_NXLN		equ	-30	; offset to next line in pattern  (in bytes)	    +46
P_NXPL		equ	-28	; offset to next plane in pattern (in bytes)	    +48
P_MASK		equ	-26	; pattern index mask				    +50

***					    ***
***   these parameters are internally set   ***
***					    ***

P_INDX		equ	-24	; initial pattern index				    +52

S_ADDR		equ	-22	; initial source address 			    +54
S_XMAX		equ	-18	; maximum X: source				    +58
S_YMAX		equ	-16	; maximum Y: source				    +60

D_ADDR		equ	-14	; initial destination address			    +62
D_XMAX		equ	-10	; maximum X: destination			    +66
D_YMAX		equ	-08	; maximum Y: destination			    +68

INNER_CT	equ	-06	; blt inner loop initial count			    +70
DST_WR		equ	-04	; destination form wrap (in bytes)		    +72
SRC_WR		equ	-02	; source form wrap (in bytes)			    +74


FRAME_LEN	equ	 76

DEV_COL		equ	 26	; offset in _DEV_TAB to number of colors
PAT_FLAG	equ	  4	; flag:1 SOURCE and PATTERN   flag:0 SOURCE only
mode05		.equ	  5	; write mode #5 (D' = D) => do nothing
mode15		.equ	 15	; maximum write mode opcode

_COPY_RFM:

	movem.l	d4-d7/a4-a5,-(sp)
	link	a6,#-FRAME_LEN

*   test for legal logic ops and set color (if op 16)

	move.l	_INTIN,a2		; a2 -> INTIN array
	move.w	I_LOG_OP(a2),d2		; d2 <- logic op #
	blt.w	bad_parameter		; for a negative write mode operand
	clr.l	a3			; No pattern selected

ifeq	pattern
	bclr	#PAT_FLAG,d2		; check the pattern flag and revert to log op #
	beq	no_pattern

	move.l	_patptr,a3
	moveq	#0,d0			; next plane pattern offset default.
	tst.w	_multifill		; multi-plane pattern?
	beq	pat_parm		; no, set up the parameter.
	moveq	#32,d0			; yes, next plane pat offset = 32.

pat_parm:
	move.w	d0,P_NXPL(a6)
	
	move.w	#02,P_NXLN(a6)
	move.w	#$F,P_MASK(a6)
endc

no_pattern:
	cmpi.w	#mode15,d2		; is user write mode valid?
	bgt.w	bad_parameter		; branch if high
	cmpi.w	#mode05,d2		; is d'=d if yes this is noop
	beq.w	nop_exit
	move.l	a3,P_ADDR(a6)

*   setup planes for each MFDB

	move.l	_CONTRL,a3		; a3 -> CONTRL array

	move.l	C_MFDB_S(a3),a5		; a5 -> source MFDB
	move.l	C_MFDB_D(a3),a4		; a4 -> destination MFDB


src_form:

	move.l	MF_BAS_AD(a5),d6	; if source is screen, use default

	bgt.b	src_calc		; for a positive source address
	blt.w	bad_parameter		; for a negative source address

	move.l	_v_bas_ad,d6
	move.w	_v_planes,d0		; source form is screen
	move.w	_v_lin_wr,d4
ifeq vme10
	move.l	#v_pl_dspl,S_NXPL(a6)	; set # bytes between source planes
endc
	bra	dst_form

ifne vme10
src_calc:
	move.w	MF_PLANES(a5),d0	; d0 <- source plane count
	move.w	MF_WD_WRD(a5),d4
	add.w	d4,d4
	mulu	d0,d4			; d4 <- form wrap (in bytes)
endc
ifeq vme10
src_calc:
	move.w	MF_PLANES(a5),d0	; d0 <- source plane count
	ble.w	bad_parameter		; pl. count must be a positive integer
	move.w	MF_WD_WRD(a5),d4        ; get # of words in source form line
	ble.w	bad_parameter		; must be a positive integer
	add.w	d4,d4			; get # of bytes in source form line
	clr.l	S_NXPL(a6)		; set # bytes between source planes
endc

dst_form:
	move.l	MF_BAS_AD(a4),d7	; if destination is screen, use default

	bgt.b	dst_calc		; for a positive destination address
	blt.w	bad_parameter		; for a negative destination address

	move.l	_v_bas_ad,d7
	move.w	_v_planes,d1
	move.w	_v_lin_wr,d5
ifeq vme10
	move.l	#v_pl_dspl,D_NXPL(a6)	; set # bytes between dest. planes
endc
	bra	compare

ifne vme10
dst_calc:
	move.w	MF_PLANES(a4),d1	; d1 <- destination plane count
	move.w	MF_WD_WRD(a4),d5
	add.w	d5,d5
	mulu	d1,d5			; d5 <- form wrap (in bytes)
endc
ifeq vme10
dst_calc:
	move.w	MF_PLANES(a4),d1	; d1 <- destination plane count
	ble.w	bad_parameter		; pl. count must be a positive integer
        move.w	MF_WD_WRD(a4),d5        ; get # of words in dest. form line
	ble.w	bad_parameter		; must be a positive integer
	add.w	d5,d5			; get # of bytes in dest. form line
	clr.l	D_NXPL(a6)		; set # bytes between dest. planes
endc

ifne vme10
compare:
	moveq.l	#%10110,d3		; only 4,2, and 1 are valid (destination)
	btst	d1,d3			; 
	beq	bad_parameter		; 
endc
ifeq vme10
compare:
	andi.w	#%0011,d1		; valid dest. plane count is 1,2, or 3
	beq.w	bad_parameter		; for invalid dest. plane count
endc

	move.w	d1,PLANE_CT(a6)		; save the total plane count

ifne vme10
	add.w	d0,d0			; for device dependent forms NXWD=2*planes
	move.w	d0,S_NXWD(a6)
	add.w	d1,d1
 	move.w	d1,D_NXWD(a6)
endc

	move.w	d4,S_NXLN(a6)
	move.w	d5,D_NXLN(a6)

	andi.b	#$fe,d6			; force least significant bit to zero
	move.l	d6,S_FORM(a6)		; source form addr. is now word aligned
	andi.b	#$fe,d7			; force least significant bit to zero
	move.l	d7,D_FORM(a6)		; dest. form addr. is now word aligned

ifne vme10
	moveq.l	#2,d4			; d4 <- next plane offset (source)
	moveq.l	#2,d5			; d5 <- next plane offset (destination)
endc
	tst.w	_COPYTRAN
	beq	standard_blt_ops
*
*  COPY RASTER TRANSPARENT - This function copies a monochrome raster area
*  from source form to a color area. A writing mode and color indices for
*  both 0's and 1's are specified in the INTIN array.
*
ifne vme10
tran_blt_ops:
	cmpi.w	#02,d0
endc
ifeq vme10
tran_blt_ops:
	cmpi.w	#01,d0			; is source area one plane?
endc
	bne	bad_parameter		; source must be mono plane

	clr.w	d4			; use only the first plane for the source

	lea	_MAP_COL,a0

	move.w	I_COL_0(a2),d6		; d6 <- background color index
	cmp.w	_DEV_TAB+DEV_COL,d6	; index in range ?
	bmi	col_0_ok

	moveq.l	#1,d6			; if out of range, revert to index 1

col_0_ok:

	add.w	d6,d6			; d6 <- offset into color map
	move.w	(a0,d6.w),d6		; d6 <- background color

	move.w	I_COL_1(a2),d7		; d7 <- foreground color index
	cmp.w	_DEV_TAB+DEV_COL,d7	; index in range ?
	bmi	col_1_ok

	moveq.l	#1,d7			; if out of range, revert to index 1

col_1_ok:	

	add.w	d7,d7			; d7 <- offset into color map
	move.w	(a0,d7.w),d7		; d7 <- foreground color

	cmpi.w	#01,d2
	beq.b	replace_mode
	cmpi.w	#02,d2
	beq.b	transparent_mode
	cmpi.w	#03,d2
	beq.b	xor_mode
	cmpi.w	#04,d2
	bne.w	bad_parameter

inverse_transparent_mode:
	move.b	#01,OP_TAB+00(a6)	; fg:0 bg:0  D' <- S and D
	move.b	#13,OP_TAB+01(a6)	; fg:0 bg:1  D' <- [not S] or D
	clr.w	FG_COL(a6)		; were only interested in one color
	move.w	d6,BG_COL(a6)		; save the color of interest
	bra	the_clipper

transparent_mode:
	move.b	#04,OP_TAB+00(a6)	; fg:0 bg:0  D' <- [not S] and D
	move.b	#07,OP_TAB+02(a6)	; fg:1 bg:0  D' <- S or D
	clr.w	BG_COL(a6)		; were only interested in one color
	move.w	d7,FG_COL(a6)		; save the color of interest
	bra	the_clipper

replace_mode:
	move.w	d6,BG_COL(a6)		; save fore and background colors
	move.w	d7,FG_COL(a6)
	move.b	#00,OP_TAB+00(a6)	; fg:0 bg:0  D' <- 0
	move.b	#12,OP_TAB+01(a6)	; fg:0 bg:1  D' <- not S
	move.b	#03,OP_TAB+02(a6)	; fg:1 bg:0  D' <- S
	move.b	#15,OP_TAB+03(a6)	; fg:1 bg:1  D' <- 1
	bra	the_clipper

xor_mode:
	clr.w	BG_COL(a6)
	clr.w	FG_COL(a6)
	move.b	#06,OP_TAB+00(a6)	; fg:0 bg:0  D' <- S xor D
	bra	the_clipper
*
*  COPY RASTER OPAQUE - This function copies a rectangular raster area
*  from source form to destination form using the logic operation 
*  specified by the application.
*
*   do the standard logic operations
*
standard_blt_ops:
	cmp.w	d0,d1
	bne	bad_parameter		; planes must be equal in number
	clr.w	BG_COL(a6)		; bg:0 & fg:0 => only first OP_TAB
	clr.w	FG_COL(a6)		; entry will be referenced

	move.b	d2,OP_TAB+00(a6)	; fg:0 bg:0

ifne vme10	
the_clipper:
	move.w	d4,S_NXPL(a6)		; save inter plane value
	move.w	d5,D_NXPL(a6)
*   stoke up the stack frame
	move.l	_PTSIN,a2		; a2 -> PTSIN array
endc
ifeq vme10
the_clipper:
*   stoke up the stack frame
	move.l	_PTSIN,a2		; a2 -> PTSIN array
endc
	tst.w	_CLIP
	beq	dont_clip		; if clipping is disabled, skip the clip

	tst.l	MF_BAS_AD(a4)		; if destination isn't screen, don't clip
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
	move.w	_XMN_CLIP,d4

	cmp.w	d4,d2			; Xmin dest < Xmin clip => clip Xmin dest
	bcc	xmin_clipped		; Xmin dest > Xmin clip => branch

	exg	d4,d2			; d2 <- Xmin dest = Xmin clip
	sub.w	d2,d4			; d4 <- -(amount clipped in x)
	sub.w	d4,d0			; d0 <- adjusted Xmin src

xmin_clipped:

	move.w	d0,S_XMIN(a6)		; d0 <- clipped Xmin source
	move.w	d2,D_XMIN(a6)		; d2 <- clipped Xmin destination


***   clip Xmax destination to window

	move.w	P_XMAX_S(a2),d6
	sub.w	d0,d6			; d6 <- Dx Source
	add.w	d2,d6			; d6 <- Xmax destination

	move.w	_XMX_CLIP,d4

	cmp.w	d4,d6			; Xmax dest > Xmax clip => clip Xmax dest
	bls	xmax_clipped		; Xmax dest < Xmax clip => branch

	exg	d4,d6			; d6 <- Xmax dest = Xmax clip

xmax_clipped:


***   clip Ymin source and destination to window

	move.w	P_YMIN_S(a2),d1
	move.w	P_YMIN_D(a2),d3
	move.w	_YMN_CLIP,d4

	cmp.w	d4,d3			; Ymin dest < Ymin clip => clip Ymin
	bcc	ymin_clipped

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

	move.w	_YMX_CLIP,d4

	cmp.w	d4,d7			; is Ymax dest > Ymax clip => clip Ymax
	bls	ymax_clipped

	exg	d4,d7			; d7 <- Ymax dest = Ymax clip

ymax_clipped:


*   match source and destination rectangles

	move.w	d6,d4
	sub.w	d2,d4			; d4 <- Dx 

	move.w	d4,B_WD(a6)
	addq.w	#1,B_WD(a6)		; block width
	ble	bad_parameter		; quit if block has been entirely clipped

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

	bsr	bit_blt

nop_exit:
bad_parameter:
	unlk	a6
	movem.l	(sp)+,d4-d7/a4-a5
	rts
	.end
