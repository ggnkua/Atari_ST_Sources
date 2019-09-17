;=========================================================================
; CICON_24() is a function to draw G_CICON objects, even if the machine
; it is running on has no capabillities for this. (AES version <3.30)
; Machines with AES-version <3.30 normally can't load resource files
; which contain color-icons. To be able to use those, first transform
; the resource with XRSCFIX().
;
; CICON_24(), unlike DRAWCICN() cannot be called directly from GfA, but
; gets called by AES, every time it sees a G_PROGDEF object in the resource.
; Therefore, after loading a resource containing G_CICON objects, change
; these objects into G_PROGDEFs and have their OB_SPEC point (indirectly)
; at this routine. Use xrsc_cicon2progdef() for this.
; Also, unlike DRAWCICN() this function doesn't draw ALL the object states
; but leaves a flag in d0 behind for AES to take care of. It does however
; draw the object in SELECTED state according to the setting in config&
; and also draws the object in DISABLED state, when config& tells it to
; do so in a fashion not possible by the AES.
;
; Parameter config& (found at INLINE_address+8):
;	bit 0: 0 --> draw selected icons that have no sel_data
;		   by darkening the surface (like Interface)
;                1 --> draw selected icons that have no sel_data
;                      by inverting the colors
;         bit 1: 0 --> draw disabled icons by greying off the
;                      objects rectangle in graphmode 2 (like Interface)
;		   (this always affects the whole square)
;		   If this state is chosen, CICON_24() lets AES
;		   take care of greying the surface.
;                1 --> draw disabled icons by greying off the
;                      objects rectangle in graphmode 4 (this lightens
;                      the shape of the icon only, when its background
;                      is either white or filled with pattern 2, style 4,
;                      like the monochrome desktop)
;
; To help make this listing readable, I use some EQU's. The ones
; only valid for this program are stated below, the ones I use more
; often are in separate files. (OB_VARS.EQU and GRAPHMOD.EQU)
;
; This function was written in DEVPAC 3 assembler to produce an
; Atari Executable file (CICON_24.PRG) of 1162 bytes.
; Stripping off the first 28 bytes will leave you with the CICON_24.INL
; used in the XRSC+ listing. (1134 bytes)
;
; (c) Theo Ros for Ictari	02/05/97
; 
;=========================================================================

; offsets for VDI-parameterblock

CONTRL		equ	0
INTIN		equ	4
PTSIN		equ	8
INTOUT		equ	12
PTSOUT		equ	16

I_TXTLEN		equ	12	; normal icon textlength
I_XTXTLEN		equ	32767	; maximum textlength

monoblklen	equ	34+4+I_TXTLEN
sel_data		equ	10
next_res		equ	18

	INCLUDE OB_VARS.EQU
	INCLUDE GRAPHMOD.EQU

;=========================================================================
; The program starts after this parameterblock
;=========================================================================
		
	Section	Text

; First there's the parameters (first 10 bytes if the INLINE'd
; routine). The drawing routine itself starts at INLINE_address+10.

vdipb		dc.l	'VDIp'
workstation	dc.w	0
planes		dc.w	1
config		dc.w	0


;=========================================================================
; get variables from the ub_parameterblock
;=========================================================================

cicon_24:	move.l	4(sp),d0		; parameterblock
	movem.l	d1-d7/a0-a6,-(sp)
	movea.l	d0,a6	
	lea	obstat(pc),a1	; save OB_STATE
	move.w	pb_currstate(a6),(a1)
	movem.w	pb_x(a6),d1-d4	; x,y,w and h
	add.w	d1,d3
	subq.w	#1,d3		; becomes x,y,x2 en y2
	add.w	d2,d4
	subq.w	#1,d4
	lea	obrect(pc),a1
	movem.w	d1-d4,(a1)
	movea.l	pb_parm(a6),a1	; old OB_SPEC --> monoblk%

	
;=========================================================================
; start working on the color-icon
;=========================================================================
	
cicon:	movea.l	vdipb(pc),a5	; get VDI parameterblock
	lea	colors(pc),a3
	move.b	ib_colors(a1),d5
	lsr.w	#4,d5
	andi.w	#$f,d5
	move.w	d5,(a3)
	move.b	ib_colors(a1),d5
	andi.w	#$f,d5		; mask_color
	move.w	d5,2(a3)
	
	moveq.l	#0,d3
	add.w	ib_xicon(a1),d1	; +xoffset
	add.w	ib_yicon(a1),d2
	movem.w	ib_wicon(a1),d3-d4	; w and h of ICON 
	move.l	d3,d5
	addi.w	#15,d5
	lsr.w	#4,d5
	lea	smfdb(pc),a4
	movem.w	d3-d5,4(a4)	; put w and h in source mfdb
monolen:	add.w	d5,d5		; byte_width*height
	mulu	d4,d5		; d5=monolen%
		
	subq.w	#1,d3		; icon w and h-1
	subq.w	#1,d4
	lea	coords(pc),a3
	movem.w	d1-d4,(a3)	; iconXY,W-1 and H-1 in coords

	lea	monoblklen(a1,d5),a2	; calc ciconblk%
	lea	0(a2,d5),a2		; + monolen% (data)
	moveq	#0,d0		; flag if match found
	move.l	34(a1),d7		; n_res
while_res:
	tst.l	d7
	beq.s	do_icon
	move.w	(a2),d4
	cmp.w	planes(pc),d4  	; compare number of bitplanes
	bne.s	wend_res		; noo match, try next res
	
	moveq	#1,d0		; set flag
	bra.s	do_icon
		
wend_res:	move.l	next_res(a2),d7	; next_res

	move.l	d5,d3		; calc colorlen%
	mulu	d4,d3	
	add.l	d5,d3		; in d3: colorlen%+monolen%
	tst.l	sel_data(a2)	; sel_data?
	beq.s	adjust
	lea	0(a2,d3),a2
adjust:	lea	22(a2,d3),a2
	bra.s	while_res
	
do_icon:	move.w	obstat(pc),d7	; status
	tst.w	d0		; found something?
	beq.s	do_mono		; no, use mono icon
	lea	2(a2),a6		; a6=bestdata%
	moveq	#S_OR_D,d6	; vro_mode 7
	btst.l	#0,d7		; selected?
	beq.s	set_cmask
	tst.l	sel_data(a2)	; sel_data?
	beq.s	mode_6
	lea	sel_data(a2),a6
	bra.s	set_cmask

mode_6:	moveq	#S_XOR_D,d6	; vro_mode 6
	bsr	col_swap
set_cmask:
	lea	4(a6),a3		; bestmask%=bestdata%+4
	bra.s	draw_icon	

do_mono:	movea.l	a1,a3		; bestmask%=monoblk%
	lea	4(a3),a6		; besticon%=monoblk%+4
	moveq	#1,d4		; number of colors to blit
	btst.l	#0,d7		; selected?
	beq.s	draw_icon
	bsr	col_swap

draw_icon:
	move.l	(a3),(a4)		; address of bitmap in smfdb
	move.l	#1,10(a4)		; fd_stand (0) and planes (1)
	clr.l	20(a4)		; screen in dmfdb
	bsr	vrt_blit		; blit mask
	move.l	(a6),(a4)		; address of data in mfdb
	move.w	d4,12(a4)		; and number of bitplanes
	tst.w	d0		; found a match?
	bne.s	blit_color
	bsr	col_swap
	bsr	vrt_blit		; blit mono data
	bsr	col_swap
	bra.s	draw_text
	
blit_color:
	btst.l	#0,d7		; selected?
	beq.s	blit_cicon
	cmpi.w	#S_XOR_D,d6	; vro_mode=6? (XOR; no sel_data found)
	bne.s	mode_7
	move.w	config(pc),d0
	andi.w	#1,d0		; BTST(config,0)=0?
	bne.s	blit_cicon	; no, invert selected icon
	moveq	#S_OR_D,d6	; selected=DARKEN (like Interface)
	moveq	#MD_ERASE,d0	; graphmode 4
	bsr	graphmode
	bsr	deffill_024
	lea	coords(pc),a2
	movem.w	(a2),d0-d3
	add.w	d0,d2		; --> X2
	add.w	d1,d3		; --> Y2
	bsr	rect
	bra.s	blit_cicon
	
mode_7:	bsr	col_swap
	
blit_cicon:
	bsr	vro_blit

;=========================================================================
; the icon is on screen, now do the text
;=========================================================================
		
draw_text:
	moveq	#MD_TRANS,d0	; graphmode 2
	bsr	graphmode
	bsr	set_text		; do all text settings for 
	move.b	ib_char(a1),d0	; icon_text
	beq.s	chk_string
	cmpi.b	#' ',d0
	beq.s	chk_string
	andi.w	#$ff,d0
	movea.l	INTIN(a5),a2
	move.w	d0,(a2)
	lea	coords(pc),a2
	movem.w	(a2),d0-d1	; icon x and y
	add.w	ib_xchar(a1),d0
	add.w	ib_ychar(a1),d1
	moveq	#1,d3
	bsr	write_text
chk_string:
	movea.l	ib_ptext(a1),a0	; LONG{monoblk%+8}
	tst.l	(a0)
	beq.s	chk_xtext
	moveq	#I_TXTLEN-1,d2	; read maximum of 12 characters
	bra.s	write_itxt
chk_xtext:
	cmpi.l	#'XTXT',4(a0)
	bne	chk_state		; no text
	movea.l	8(a0),a0
	move.w	#I_XTXTLEN-1,d2	; maxlength
write_itxt:
	movem.l	d2/a0,-(sp)	; save maxlen & textaddress
	lea	colors(pc),a2	; first draw the background
	move.w	2(a2),d0		; use mask_color for rectangle
	bsr	fill_color
	moveq	#1,d0		; massive
	bsr	fill_pattern
	moveq	#8,d0
	bsr	fill_style
	lea	obrect(pc),a2
	movem.w	(a2),d0-d1	; SCREEN x and y of object
	add.w	ib_xtext(a1),d0
	add.w	ib_ytext(a1),d1	
	movem.w	ib_wtext(a1),d2-d3
	add.w	d0,d2
	add.w	d1,d3		; y2 and x2
	subq.w	#1,d2
	subq.w	#1,d3
	bsr	rect
	movem.l	(sp)+,d2/a0	; maxlen & textaddress
	
	movea.l	INTIN(a5),a2	; write text in INTIN
	moveq	#0,d3		; return textlength in d3
	moveq	#0,d1
nextbyte:	move.b	(a0)+,d1
	beq.s	calcxy
	addq.w	#1,d3
	move.w	d1,(a2)+
	dbra	d2,nextbyte	; in d2 maxlength-1

calcxy:	move.w	d3,d5		; textlength
	mulu	#6,d5		; becomes width in pixels
	movem.w	ib_wtext(a1),d0-d1	; w and h of text
	sub.w	d5,d0
	lsr.w	#1,d0		; center text
	add.w	ib_xtext(a1),d0	; using the 6x6 font
	subq	#6,d1
	lsr.w	#1,d1
	add.w	ib_ytext(a1),d1
	lea	obrect(pc),a2
	
	add.w	(a2),d0		; add SCREEN x and y of object
	add.w	2(a2),d1		; --> centered icontext
	bsr	write_text

;=========================================================================
; text also complete, now check possible OB_STATE's
; Because CICON_24() gets called by the AES, it can leave a bitmap
; in d0 for AES to take care of. This bitmaps affects all states, except
; SELECTED, but since that state is already drawn, we don't have to worry
; about it. There is one special case the AES can't handle: the DISABLED
; state when config& bit 1 is set, because this means to draw in an AES-
; unlike fashion.
; All bits left ON in d0 are states that will be handled by AES.
;
; remember: text is set in small font, textcolor is iconcolor
;           graphic mode is transparent
;	  in obrect are the screen coordinates of the object
;           in d7 the objects state (same as obstat(pc))
;=========================================================================

chk_state:
	bclr	#0,d7		; first switch SELECTED state off
	btst.l	#3,d7		; now check DISABLED
	beq.s	exit		; ready
	move.w	config(pc),d0
	andi.w	#2,d0		; BTST(config,1)=0?
	beq.s	exit		; yes, les AES do it..
	bclr	#3,d7		; switch DISABLED off, cause we're
				; drawing it..
	moveq	#MD_ERASE,d0	; disable SHAPE only, when
	bsr	graphmode		; background is either white or 
	bsr	deffill_024	; filled with pattern 2, style 4
	lea	obrect(pc),a2
	movem.w	(a2),d0-d3
	bsr	rect

exit:	move.w	d7,d0		; modified 'left to do' OB_STATE
	movem.l	(sp)+,d1-d7/a0-a6
	rts

;=========================================================================
; subroutines
;=========================================================================

col_swap: lea	colors(pc),a2
	move.w	(a2),-(sp)
	move.w	2(a2),(a2)	; swap icon_color,mask_color
	move.w	(sp)+,2(a2)
	rts
	
write_text:
	movea.l	PTSIN(a5),a2
	movem.w	d0-d1,(a2)	; x and y of text
	lea	v_gtext(pc),a0	; in a0: contrl(0),(1) and (3)
	move.w	d3,4(a0)		; textlength
	bra	do_vdi
	
set_text:	movea.l	INTIN(a5),a2
	move.w	#1,(a2)		; set standard system font
	lea	vst_font(pc),a0
	bsr	do_vdi
	
	movea.l	INTIN(a5),a2
	move.l	#5,(a2)		; use left/top alignment
	lea	vst_alignment(pc),a0
	bsr	do_vdi

	movea.l	INTIN(a5),a2
	clr.w	(a2)		; no special effects
	lea	vst_effects(pc),a0
	bsr	do_vdi
	
	movea.l	INTIN(a5),a2
	clr.w	(a2)		; at a normal angle
	lea	vst_rotation(pc),a0
	bsr	do_vdi

	moveq	#4,d0		; use 6x6 font
	bsr.s	text_height
	
	lea	colors(pc),a0
	move.w	(a0),d0		; textcolor=iconcolor
	;falls through to subroutine text_color
	
text_color:
	movea.l	INTIN(a5),a2
	move.w	d0,(a2)		
	lea	vst_color(pc),a0
	bra	do_vdi
	
text_height:
	movea.l	INTIN(a5),a2
	move.w	d0,(a2)		; pointheight 4=icon
	lea	vst_point(pc),a0	;             6=color (8x8)
	bra	do_vdi		;            13=monochrome (8x16)
	
blit_params:
	lea	coords(pc),a2
	movem.w	(a2),d0-d3	; icon x,y,w and h
	movea.l	PTSIN(a5),a2
	clr.l	(a2)
	movem.w	d2-d3,4(a2)
	add.w	d0,d2
	add.w	d1,d3
	movem.w	d0-d3,8(a2)
	movea.l	CONTRL(a5),a2
	move.l	a4,14(a2)
	lea	dmfdb(pc),a4
	move.l	a4,18(a2)
	rts

vrt_blit:	movem.l	d0-d2/a0-a4,-(sp)	; MONO data to n planes
	lea	colors(pc),a0
	movea.l	INTIN(a5),a2
	move.w	#2,(a2)+		; transparent
	move.w	2(a0),(a2)+	; maskcolor
	move.w	(a0),(a2)		; iconcolor
	bsr.s	blit_params
	lea	vrt_cpyfm(pc),a0
	bsr	do_vdi
	movem.l	(sp)+,d0-d2/a0-a4
	rts
	
vro_blit:	movem.l	d0-d2/a0-a4,-(sp)	; nr of planes MUST match here
	movea.l	INTIN(a5),a2
	move.w	d6,(a2)
	bsr.s	blit_params
	lea	vro_cpyfm(pc),a0
	bsr	do_vdi
	movem.l	(sp)+,d0-d2/a0-a4
	rts

graphmode:
	movea.l	INTIN(a5),a2
	move.w	d0,(a2)
	lea	vswr_mode(pc),a0
	bra	do_vdi

fill_color:	
	movea.l	INTIN(a5),a2
	move.w	d0,(a2)
	lea	vsf_fill_color(pc),a0
	bra	do_vdi

fill_pattern:
	movea.l	INTIN(a5),a2
	move.w	d0,(a2)
	lea	vsf_interior(pc),a0
	bra	do_vdi
	
deffill_024:
	moveq	#0,d0
	bsr.s	fill_color
	moveq	#2,d0
	bsr.s	fill_pattern
	moveq	#4,d0
	;falls through to subroutine fill_style
	
fill_style:
	movea.l	INTIN(a5),a2
	move.w	d0,(a2)
	lea	vsf_style(pc),a0
	bra.s	do_vdi

rect:	movea.l	PTSIN(a5),a2
	movem.w	d0-d3,(a2)
	lea	vr_recfl(pc),a0	; faster than v_bar() with
	; falls through to do_vdi	; BOUNDARY 0

do_vdi:
	movea.l	CONTRL(a5),a2
	movem.w	(a0),d0-d2
	movem.w	d0-d1,(a2)	; control(0) and (1)
	move.w	d2,6(a2)		; control(3)
	clr.w	10(a2)		; control(5) is unused
	move.w	workstation(pc),12(a2)
	move.l	a5,d1
	move.w	#$73,d0
	trap	#2
	rts	

	even
	
; routine uses this space to store things
obstat:		ds.w	1
obrect:		ds.w	4
colors:		ds.w	2
coords:		ds.w	4

; control codes for VDI
v_gtext:		dc.w	8,1,0
vst_effects:	dc.w	106,0,1
vst_alignment:	dc.w	39,0,2
vst_font:		dc.w	21,0,1
vst_rotation:	dc.w	13,0,1
vst_point:	dc.w	107,0,1
vst_color:	dc.w	22,0,1
vswr_mode:	dc.w	32,0,1
vsf_fill_color:	dc.w	25,0,1
vsf_interior:	dc.w	23,0,1
vsf_style:	dc.w	24,0,1
vr_recfl:		dc.w	114,2,0
vrt_cpyfm:	dc.w	121,4,3
vro_cpyfm:	dc.w	109,4,1

; memory form definition blocks for blitting
smfdb:	dc.w	0,0,0,0,0,0,0,0,0,0
dmfdb:	dc.w	0,0,0,0,0,0,0,0,0,0
