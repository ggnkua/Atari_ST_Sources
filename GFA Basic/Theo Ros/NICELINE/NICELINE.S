; ===================================================================
; NICELINE() is a function to draw nicer menulines than Gem does.
; It uses GLOBAL words at niceline%+6 and niceline%+8 as patterns
; for drawing the lines. It also has space for two color BYTES at
; niceline%+10 and niceline%+11, the function uses if the object
; to be drawn has no LOCAL colors set in the high byte of it's
; OB_STATE word.
; See the NICELINE.GFA listing to find out how it all works.
;
; NICELINE() was written in Devpac 3 assembler to produce an
; Atari Executable file NICELINE.PRG of 334 bytes. Stripping off
; the first 28 bytes leaves you with NICELINE.INL of 306 bytes.
;
; (c) Theo Ros  05/05/97
; ===================================================================

; offsets from pointer VDI-parameterblok
CONTRL	equ	0
INTIN	equ	4
PTSIN	equ	8
INTOUT	equ	12
PTSOUT	equ	16

; normally I'd use INCLUDE OB_VARS.EQU for this, but to
; give you the full listing, here some more equ's:
; (you can find the OB_VARS.EQU file on an earlier ICTARI
; disk as part of the XRSC binding)

pb_tree		equ	0	; objecttree
pb_obj		equ	4	; object
pb_prevstate	equ	6	; previous OB_STATE
pb_currstate	equ	8	; current OB_STATE
pb_x		equ	10	; OB_X
pb_y		equ	12	; OB_Y
pb_w		equ	14	; OB_W
pb_h		equ	16	; OB_H
pb_xc		equ	18	; clip x
pb_yc		equ	20	; clip y
pb_wc		equ	22	; clip w
pb_hc		equ	24	; clip h
pb_parm		equ	26	; LONG: parameter = old OB_SPEC
 
	
	Section	Text

; ===================================================================
; these variables need to be filled in by your program first.
; use function nice_init() for this or simply call nice_on(),
; which takes care of everything.
; ===================================================================

vdipb		dc.l	'VDIp'
workstation	dc.w	0
lineshape1:	dc.w	$5555	; preset dotted lines
lineshape2:	dc.w	$aaaa
globalcol1:	dc.b	1	; both in black
globalcol2:	dc.b	1

; ===================================================================
; this is where the function starts, at niceline%+12
; ===================================================================

niceline:
	move.l	4(sp),d0
	movem.l	d1-d5/a0-a6,-(sp)
	movea.l	d0,a6
	movea.l	vdipb(pc),a5
	lea	coords(pc),a4
	
	movem.w	pb_x(a6),d0-d3	; read objx,y,w en h
	add.w	d0,d2		; w becomes x2
	subq.w	#1,d2
	lsr.w	#1,d3		; h/2
	add.w	d3,d1		; y+h/2
	subq.w	#1,d1
	move.w	d1,d3
	movem.w	d0-d3,(a4)	; save coordinates
	
	movea.l	INTIN(a5),a1
	clr.l	(a1)		; line_ends normal
	lea	vsl_ends(pc),a0
	bsr	do_vdi
	
	movea.l	PTSIN(a5),a1	; NOT INTIN !!!!!
	move.w	#1,(a1)		; line_thickness 1
	lea	vsl_width(pc),a0	; otherwise no style...
	bsr	do_vdi
	
	move.w	lineshape1(pc),d4	; parameter topline	
	beq.s	nice2		; no 1st line to draw?
	move.b	pb_currstate(a6),d5	; high_byte: use LOCAL colors?
	beq.s	global1
	lsr.w	#4,d5		; color line 1
	bra.s	draw1
global1:	move.b	globalcol1(pc),d5
draw1:	andi.w	#$f,d5
	beq.s	nice2		; no 1st line
	bsr.s	set_line
	movem.w	(a4),d0-d3
	bsr.s	line
	
nice2:	move.w	lineshape2(pc),d4	; parameter bottomline	
	beq.s	nice_end		; no 2nd line to draw?
	move.b	pb_currstate(a6),d5	; high_byte: use LOCAL colors?
	bne.s	draw2	
	move.b	globalcol2(pc),d5	; no, use GLOBAL
draw2:	andi.w	#$f,d5
	beq.s	nice_end		; no 2nd line
	bsr.s	set_line
	movem.w	(a4),d0-d3
	addq.w	#1,d1
	addq.w	#1,d3
	bsr.s	line
nice_end:
	move.w	pb_currstate(a6),d0	; leave bitmap for AES to draw
	andi.l	#%110110,d0	; if set in objects OB_STATE: 
	movem.l	(sp)+,d1-d5/a0-a6	; CROSSED,CHECKED
	rts			; OUTLINED, SHADOWED

; ===================================================================
; subroutines
; ===================================================================
	
	
line:	movea.l	PTSIN(a5),a1
	movem.w	d0-d3,(a1)
	lea	v_pline(pc),a0
	bra.s	do_vdi

set_line:	movea.l	INTIN(a5),a1	; first set the color from d5
	move.w	d5,(a1)
	lea	vsl_color(pc),a0
	bsr.s	do_vdi
	
	cmpi.w	#6,d4		; then set the line style
	bhi.s	set_ustyle
	tst.w	d4
	bpl.s	set_type
	neg.w	d4
set_ustyle:
	movea.l	INTIN(a5),a1
	move.w	d4,(a1)
	lea	vsl_udsty(pc),a0
	bsr.s	do_vdi
	moveq	#7,d4		; user defined
set_type:
	movea.l	INTIN(a5),a1
	move.w	d4,(a1)
	lea	vsl_type(pc),a0
	
do_vdi:
	movea.l	CONTRL(a5),a1
	move.l	(a0)+,(a1)	; control (0) en (1)
	move.w	(a0),6(a1)	; control (3)
	clr.w	10(a1)		; control (5)
	move.w	workstation(pc),12(a1)
	move.l	a5,d1
	move.w	#$73,d0
	trap	#2
	rts	

; ===================================================================
; storage and function opcodes
; ===================================================================

coords:		ds.w	4

v_pline:		dc.w	6,2,0
vsl_type:		dc.w	15,0,1
vsl_width:	dc.w	16,1,0
vsl_color:	dc.w	17,0,1
vsl_ends:		dc.w	108,0,2
vsl_udsty:	dc.w	113,0,1
