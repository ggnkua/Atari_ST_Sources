*
*	DRAW.S
*
*
	.include	"equates.s"
*
	.text
*
*
*
*  Same as DaveDraw in parameters except this is for the library window
LibraryDraw:
	movem.l	a0-a6/d0-d7,-(sp)
	lea	wstruct+lxoffset,a5
	move.l	library,a4		;s_form is in a4
	bra	LibDrawi
*
*	
*  Same as DaveButton except this is for the Library window
*
LibButton:
	bclr.b	#1,BUT_STATE+1
	bne	get_brush
	bclr.b	#0,BUT_STATE+1
	bne	get_brush
nolfbut:
	rts
*
*  get a brush from the library
*
get_brush:
	lea	wstruct,a5
	move.l	mouseptr,a0		;get mouse ptr
	movem.w	(a0),d0-d1		;d0 = xpos, d1 = ypos
*
	sub.w	lx(a5),d0
	add.w	lxoffset(a5),d0		;adjust for library world co-ords
	sub.w	ly(a5),d1
	add.w	lyoffset(a5),d1
*
*  Search the libblock for the object
*   whose rectangle falls within the mouse position
*
	cmp.w	l_wid(a5),d0	;are we right of the library world?
	bge	get_bshx	;br if so
	cmp.w	l_hite(a5),d1
	bge	get_bshx	;br if below world
*
	move.l	liblkptr,a0		;get pointer to end +1
	move.l	#libblock,a1		; & ptr to beginning
	lea	bshblock,a2
	bra	freci
floop:
	move.w	-(a0),d3	;get vpos
	move.w	-(a0),d2	;hpos
	subq.l	#2,a0		;skip special effects
	move.w	-(a0),d4	;brush #
*
	cmp.w	d0,d2		;are we entirely to left?
	bgt	freci		;br if so
*
	cmp.w	d1,d3		;are we entirely above?
	bgt	freci		;br if yes
*
*  we may have found our boy--check width & height
*
*	move.w	d4,curbrush	;save in case it gets interesting
*
	lsl.w	#4,d4		;get offset into bshblock
	move.w	(a2,d4.w),d5	;get width
	move.w	2(a2,d4.w),d6	; & height
	add.w	d2,d5
	add.w	d3,d6
*
	cmp.w	d0,d5
	ble	freci
*
	cmp.w	d1,d6
	ble	freci		;br if outside rect
*
*  we're inside a rectangle--so select this guy!!
*
	move.l	8(a2,d4.w),a1	;get id string
	lsr.w	#4,d4
	move.w	d4,curbrush	;save this brush #
*
	lea	brshfile,a0
	move.l	a0,-(sp)
strcopy0:
	move.b	(a1)+,d6
	move.b	d6,(a0)+
	cmpi.b	#" ",d6
	bhi	strcopy0
	clr.b	-(a0)
*
	move.l	(sp)+,a0
	move.w	#LIBRARY,d0
	bsr	DaveInfo	;put object on info bar
*
	bsr	Back2G
	rts			;exit
*
*
*
freci:
	cmp.l	a0,a1
	bcs	floop
*
*   failed to find library item--exit without change
*
*
get_bshx:
	rts
*
*
*
*******************************************************8
*
*   We're dealing with four coordinate systems here:
*
*  Screen - the physical hardware monitor
*  Form	  - the large virtual canvas viewed thru the Window
*  World  - same as Form, except when smaller than window work area
*  Window - the viewing area (window work area)
*
*	xoffset,yoffset   = offset into Form of top/left Window
*	wx,wy 		  = offset into Screen of top/left Window
*
* a0- pointer to a structure of screen co-ordinates
*
* int g_x
* int g_y
* int g_w
* int g_h
*
DaveDraw:
*
*
*  We may need to BLT a World rectangle & up to two "no-man's land"
*    rectangles (if the World is smaller than the Form).  The two
*    are called "bottom" and "right" and are drawn with
*    a checkered pattern.
*
*
	movem.l	a0-a6/d0-d7,-(sp)
	lea	wstruct+xoffset,a5
	move.l	world,a4		;s_form is in a4
*
LibDrawi:
	movem.w	(a0),d0-d3	;get x,y,w,h in d0,d1,d2 & d3
*
	move.w	d2,d4
	beq	noDraw		;exit if null width
	move.w	d3,d5
	beq	noDraw		;exit if null height
*
	add.w	d0,d4		;check screen right edge clip
	subq.w	#1,d4
	sub.w	form_width,d4
	ble	screxok
	sub.w	d4,d2		;adjust width for screen
screxok:
	add.w	d1,d5		;check screen bottom edge clip
	subq.w	#1,d5
	sub.w	form_height,d5
	ble	screyok
	sub.w	d5,d3		;adjust height for screen
screyok:
	bra	DaveDok
*
*  Exit if we can't do this draw
*
noDraw:
	movem.l	(sp)+,a0-a6/d0-d7
	rts			;exit if either width or height =0
*
*
WindRefresh:
	movem.l	a0-a6/d0-d7,-(sp)
	lea	wstruct+xoffset,a5	;a5 -> window structure variables
	move.l	world,a4		;s_form is in a4
	bra	windr
*
brushpat:
	movem.l	a0-a6/d0-d7,-(sp)
	lea	wstruct+xoffset,a5	;a5 -> window structure variables
	move.l	world,a4		;s_form is in a4
	movem.w	bsh_x,d0-d3	;get x,y,w,h in d0,d1,d2 & d3
*
*   clip for window work area
*
windr:
	movem.w	wx(a5),d4-d7
*
	add.w	d4,d6
	subq.w	#1,d6
	cmp.w	form_width,d6	;is window wider than the screen?
	ble	winxok
	move.w	form_width,d6	;if so, just clip to screen
winxok:
	addq.w	#1,d6

	add.w	d5,d7
	subq.w	#1,d7
	cmp.w	form_height,d7	;is window taller than the screen?
	ble	winyok
	move.w	form_height,d7	;if so, just clip to screen
winyok:
	addq.w	#1,d7
*
*  check left clip
*
	cmp.w	d4,d0
	bge	bp0
	sub.w	d4,d0
	add.w	d0,d2
	move.w	d4,d0
bp0:
*
*  check top clip
*
	cmp.w	d5,d1
	bge	bp1
	sub.w	d5,d1
	add.w	d1,d3
	move.w	d5,d1
bp1:
*
*  check right clip
*
	move.w	d0,d4
	add.w	d2,d4
	cmp.w	d4,d6
	bge	bp2
	sub.w	d4,d6
	add.w	d6,d2
bp2:
*
*  check bottom clip
*
	move.w	d1,d5
	add.w	d3,d5
	cmp.w	d5,d7
	bge	bp3
	sub.w	d5,d7
	add.w	d7,d3
bp3:
*
*
DaveDok:
*
*   d0 = screen xmin
*   d1 = screen ymin
*   d2 = block width
*   d3 = block height
*
*  it is assumed that these values form a rectangle that
*  fits entirely within the work area of the window
*
*   Set-up DST bLT to Screen
*
	lea	bitblock,a6
*
	move.w	w_wid(a5),d4		;compute our form wrap
	addi.w	#15,d4
	andi.w	#$fff0,d4
	lsr.w	#1,d4
	move.w	d4,s_nxln(a6)
*
	lea	oldphyz,a1		;get screen characteristics
	lea	d_form(a6),a2
	moveq	#4,d7
scrndata:
	move.w	(a1)+,(a2)+
	dbra	d7,scrndata
*
	move.w	d0,d4		;screen x_min to d4
	sub.w	wx(a5),d4	;adjust for window
	add.w	xoffset(a5),d4	;adjust to get World form x_min
*
	move.w	d1,d5		;screen y_min to d5
	sub.w	wy(a5),d5	;adjust for window
	add.w	yoffset(a5),d5	;adjust to get World form y_min
*
	cmp.w	w_wid(a5),d4	;are we to right of World?
	bcc	nowrld		;br if do right no-man's
*
	cmp.w	w_hite(a5),d5	;are we below World?
	bcc	nowrld		;br if so
*
*  We know our first BLT must come from the world
*
	move.l	#$03030303,op_tab(a6)
*
	move.l	a4,s_form(a6)	;world/library SRC form
	move.w	#8,s_nxwd(a6)
	move.w	#2,s_nxpl(a6)
*
	move.w	d0,d_xmin(a6)
	move.w	d1,d_ymin(a6)
*
	move.w	d4,s_xmin(a6)
	move.w	d5,s_ymin(a6)
*
	move.w	w_wid(a5),d6
	sub.w	d4,d6
	cmp.w	d2,d6
	bcs	needrt
	move.w	d2,d6
needrt:
	move.w	d6,b_width(a6)
*
	move.w	w_hite(a5),d7
	sub.w	d5,d7
	cmp.w	d3,d7
	bcs	needbt
	move.w	d3,d7
needbt:
	move.w	d7,b_height(a6)
*
	move.w	#$4,plane_ct(a6)
	clr.l	p_addr(a6)
	movem.l	d0-d7/a5-a6,-(sp)
	.dc.w	bitblt
	movem.l	(sp)+,d0-d7/a5-a6
*
*
*
nomans:
	cmp.w	d6,d2		;worlds' width BLT was d6
	beq	chkbot		;br if no right fill needed
*
* do right no-man's
*
	move.w	d2,b_width(a6)
	sub.w	d6,b_width(a6)
	add.w	d0,d6	
	move.w	d6,d_xmin(a6)
	move.w	d3,b_height(a6)
	bsr	patfill			;fill right noman's block
*
chkbot:
	sub.w	d7,d3		;check if any bottom to do
	beq	nobot
	move.w	d3,b_height(a6)
	move.w	d2,b_width(a6)
	add.w	d7,d1
dofinal:
	move.w	d0,d_xmin(a6)
	move.w	d1,d_ymin(a6)
	bsr	patfill
nobot:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
nowrld:
	move.w	d2,b_width(a6)
	move.w	d3,b_height(a6)
	bra	dofinal
*
*
*   Fill pattern--it is assumed that a6 -> bitblock
* 		  and that DST x,y,w,h are set
*
patfill:
	movem.l	d0-d7/a5-a6,-(sp)

	move.w	#200,d1
	move.l	oldphyz,a0
	move.w	scr_nxln,d0
	cmpi.w	#320,d0			;it it TT?
	bne	patf1			;br if not
	move.w	#480,d1
patf1:	
	mulu	d1,d0
	add.l	d0,a0
	move.w	#$ffff,(a0)		;get a word of $ffff
	move.l	a0,s_form(a6)		; from above the screen
*
	move.l	#$000c030f,op_tab(a6)
	clr.w	s_xmin(a6)
	clr.w	s_ymin(a6)
	clr.w	s_nxwd(a6)
	clr.w	s_nxln(a6)
	clr.w	s_nxpl(a6)
*
	move.l	#checked,p_addr(a6)
	move.w	#2,p_nxln(a6)
	move.w	#0,p_nxpl(a6)
	move.w	#2,p_mask(a6)
*
	move.w	#15,fg_col(a6)		;just use color #15
	move.w	#0,bg_col(a6)

	move.w	#4,plane_ct(a6)
	.dc.w	bitblt
	movem.l	(sp)+,d0-d7/a5-a6
	rts
*
*
all_ones:
	.dc.w	$ffff
checked:
	.dc.w	%0101010101010101
	.dc.w	%1010101010101010
*
*
*
*   Create a lightened brush from the curbrush one, derived or not.
*
*
bsh_alt:
	movem.l	a0-a6/d0-d7,-(sp)
	addq.w	#1,maxderivd	;increase derived brush count
*
	lea	bshblock,a2	;get base of brush block
	move.l	a2,a0
	move.l	a2,a1
	move.w	curbrush,d0
	move.w	d0,d7		;save in temp
	move.w	maxderivd,d1
	lsl.w	#4,d0
	lsl.w	#4,d1
	adda.w	d0,a0
	adda.w	d1,a1
	moveq	#7,d2
bsh_a0:
	move.w	(a0)+,(a1)+	;copy the intrinsic data to derived
	dbra	d2,bsh_a0
*
	move.l	derblkend,a3	;get next derived block opening
	move.l	a3,8(a2,d1.w)	;put in brush ID_string
*
	move.l	dstrngend,a4	;get next avail string copy region
	move.l	a4,(a3)+	;save string base ptr
*
	move.l	8(a2,d0.w),a5	;get id_string of src intrinsic/derived
	cmp.w	maxintrins,d7	;is SRC derived?
	bls	bsh_a10		;br if intrinsic
*
	subq.w	#1,maxderivd	;eliminate this new derived brush
	bra	bsh_ai		;exit
*
*
bsh_a10:
	move.b	#"A",(a4)+	;indicate "Hflip"
	move.b	#"l",(a4)+
	move.b	#"t",(a4)+
	move.b	#">",(a4)+
*
bsh_a0x:
	move.b	(a5)+,d7
	move.b	d7,(a4)+
	cmpi.b	#" ",d7
	bhi	bsh_a0x
	clr.b	-(a4)
	addq.l	#1,a4
	move.l	a4,dstrngend	;Malloc this string
*
*  Now let's work on the derived block entry
*
	clr.w	(a3)+		;count (-1) has just one entry
	move.w	curbrush,(a3)+	;which intrinsic brush
	move.w	#Alternate,(a3)+	;Hflip effect
	clr.l	(a3)+		;no h/v-offset
	clr.l	(a3)+		;no width/height
	move.l	a3,derblkend	;Malloc this block entry
*
*  End derived block entry build
*
*
	move.l	4(a2,d0.w),a0	;get intrinsic graphics ptr
	move.l	derivdend,a1	; & new derived graphics ptr
	move.l	a1,4(a2,d1.w)	;save to new brush block
*
	move.w	14(a2,d0.w),d3	;get s_nxln
	lsr.w	#1,d3
	move.w	#%0101010101010101,d6
	move.w	2(a2,d0.w),d4	;get b_height
*
	subq.w	#1,d3
	subq.w	#1,d4
alinelp:
	move.w	d3,d5
alinelp1:
	move.w	(a0)+,d7
	and.w	d6,d7
	move.w	d7,(a1)+
	dbra	d5,alinelp1
	rol.w	#1,d6
	dbra	d4,alinelp	
*	
*
*  Now build mask
*
	move.l	derivdend,a0	; & new derived graphics ptr
	move.w	curbrush,d7
	lsl.w	#4,d7
	move.w	14(a2,d7.w),d0		;get s_nxln
	lsr.w	#2,d0			;d0 = offset to plane #1
	move.w	d0,d5
	lsr.w	#1,d5
	subq.w	#1,d5			;d5 = # of words in line (-1)
*
	move.w	d0,d1
	add.w	d1,d1			;d1 = offset to plane #2
	move.w	d1,d2
	add.w	d0,d2			;d2 = offset to plane #3
	move.w	2(a2,d7.w),d3		;get form height
	bra	bsh_a8i
bsh_a81:
	move.w	d5,d6
bsh_a82:
	move.w	(a0,d2.w),d4
	or.w	(a0,d1.w),d4
	or.w	(a0,d0.w),d4
	or.w	(a0)+,d4
	move.w	d4,(a1)+
	dbra	d6,bsh_a82	
	adda.w	d2,a0
bsh_a8i:
	dbra	d3,bsh_a81
	move.l	a1,derivdend
*
*   Mask is built
*
bsh_ai:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
**********************************************************
*
*   Create an HFLIP'd brush from the curbrush one, derived or not.
*
*
bsh_hflip:
	movem.l	a0-a6/d0-d7,-(sp)
	addq.w	#1,maxderivd	;increase derived brush count
*
	lea	bshblock,a2	;get base of brush block
	move.l	a2,a0
	move.l	a2,a1
	move.w	curbrush,d0
	move.w	d0,d7		;save in temp
	move.w	maxderivd,d1
	lsl.w	#4,d0
	lsl.w	#4,d1
	adda.w	d0,a0
	adda.w	d1,a1
	moveq	#7,d2
bsh_h0:
	move.w	(a0)+,(a1)+	;copy the intrinsic data to derived
	dbra	d2,bsh_h0
*
	move.l	derblkend,a3	;get next derived block opening
	move.l	a3,8(a2,d1.w)	;put in brush ID_string
*
	move.l	dstrngend,a4	;get next avail string copy region
	move.l	a4,(a3)+	;save string base ptr
*
	move.l	8(a2,d0.w),a5	;get id_string of src intrinsic/derived
	cmp.w	maxintrins,d7	;is SRC derived?
	bls	bsh_h10		;br if intrinsic
*
	move.l	(a5),a5		;get derived string
*
*  We could be derived from Vflip or HVflip but not Hflip
*
	move.l	a5,a6
bsh_bsck:
	move.b	(a6)+,d7
	cmpi.b	#" ",d7
	bls	bsh_h10		;br if not derived from flipping
	cmpi.b	#">",d7		;">" means we're a previous flip
	bne	bsh_bsck
*
	sub.l	a5,a6		;are we "Vflip"
	cmp.w	#6,a6
	beq	bsh_bsck1	;br if so--just add "H"
*
*  we must be "HVflip"
*
	addq.l	#1,a5		;get rid of "H"
	bra	bsh_h0x	
bsh_bsck1:
	move.b	#"H",(a4)+
	bra	bsh_h0x
bsh_h10:
	move.b	#"H",(a4)+	;indicate "Hflip"
	move.b	#"f",(a4)+
	move.b	#"l",(a4)+
	move.b	#"i",(a4)+
	move.b	#"p",(a4)+
	move.b	#">",(a4)+
*
bsh_h0x:
	move.b	(a5)+,d7
	move.b	d7,(a4)+
	cmpi.b	#" ",d7
	bhi	bsh_h0x
	clr.b	-(a4)
	addq.l	#1,a4
	move.l	a4,dstrngend	;Malloc this string
*
*  Now let's work on the derived block entry
*
	clr.w	(a3)+		;count (-1) has just one entry
	move.w	curbrush,(a3)+	;which intrinsic brush
	move.w	#Hflip,(a3)+	;Hflip effect
	clr.l	(a3)+		;no h/v-offset
	clr.l	(a3)+		;no width/height
	move.l	a3,derblkend	;Malloc this block entry
*
*  End derived block entry build
*
*
	move.l	4(a2,d0.w),a0	;get intrinsic graphics ptr
	move.l	derivdend,a1	; & new derived graphics ptr
	move.l	a1,4(a2,d1.w)	;save to new brush block
*
	movea.w	(a2,d0.w),a3	;save b_width in lo word of a3
*
	lea	grafbsh,a1	;use intermediate for hlip build
*
	move.w	14(a2,d0.w),d3	;get s_nxln
	move.w	d3,d7
	lsr.w	#2,d3
	move.w	2(a2,d0.w),d4	;get b_height
	mulu	d4,d7		;d7 = # bytes in graphics form
	lsl.w	#2,d4		;* planes for plane-lines
	subq.w	#1,d4		;-1
*
	moveq	#0,d6

	adda.w	d3,a0		;start at end of 1st plane's line (+1)
	move.w	d3,d0
	subq.w	#1,d0
	add.w	d3,d3
bsh_h3:
	move.w	d0,d1
bsh_h2:
	moveq	#0,d5
	move.b	-(a0),d6
	bpl	bsh_h1
	andi.w	#$7f,d6
	moveq	#1,d5
bsh_h1:
	or.b	fliptab(pc,d6.w),d5
	move.b	d5,(a1)+
	dbra	d1,bsh_h2
*	
	adda.w	d3,a0
	dbra	d4,bsh_h3		
*
	bra	bsh_h4		;skip over this table
	
fliptab:	
	.dc.b	$00,$80,$40,$C0,$20,$A0,$60,$E0
	.dc.b	$10,$90,$50,$D0,$30,$B0,$70,$F0
*
	.dc.b	$08,$88,$48,$C8,$28,$A8,$68,$E8
	.dc.b	$18,$98,$58,$D8,$38,$B8,$78,$F8
*
	.dc.b	$04,$84,$44,$C4,$24,$A4,$64,$E4
	.dc.b	$14,$94,$54,$D4,$34,$B4,$74,$F4
*
	.dc.b	$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC
	.dc.b	$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
*
	.dc.b	$02,$82,$42,$C2,$22,$A2,$62,$E2
	.dc.b	$12,$92,$52,$D2,$32,$B2,$72,$F2
*
	.dc.b	$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA
	.dc.b	$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
*
	.dc.b	$06,$86,$46,$C6,$26,$A6,$66,$E6
	.dc.b	$16,$96,$56,$D6,$36,$B6,$76,$F6
*
	.dc.b	$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE
	.dc.b	$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
*
*   Now left justify
*
bsh_h4:
	lsr.w	#1,d7		;d7 = # of words in form
	subq.w	#1,d7
*
	lea	grafbsh,a0	;get ptr to intermediate buffer
	move.l	derivdend,a1	; & new derived graphics ptr
*
	move.l	a3,d0		;b_width in d0.w
	neg.w	d0
	andi.w	#$f,d0		;get amount to shift left
	beq	bsh_h5		;br if no shifting (just copy)
bsh_h6:
	move.l	(a0),d1
	addq.l	#2,a0
	lsl.l	d0,d1
	swap	d1
	move.w	d1,(a1)+
	dbra	d7,bsh_h6
	bra	bsh_h7
bsh_h5:
	move.w	(a0)+,(a1)+	;just copy if no left shift
	dbra	d7,bsh_h5
bsh_h7:
*
*  Now build mask
*
	move.l	derivdend,a0	; & new derived graphics ptr
	move.w	curbrush,d7
	lsl.w	#4,d7
	move.w	14(a2,d7.w),d0		;get s_nxln
	lsr.w	#2,d0			;d0 = offset to plane #1
	move.w	d0,d5
	lsr.w	#1,d5
	subq.w	#1,d5			;d5 = # of words in line (-1)
*
	move.w	d0,d1
	add.w	d1,d1			;d1 = offset to plane #2
	move.w	d1,d2
	add.w	d0,d2			;d2 = offset to plane #3
	move.w	2(a2,d7.w),d3		;get form height
	bra	bsh_h8i
bsh_h81:
	move.w	d5,d6
bsh_h82:
	move.w	(a0,d2.w),d4
	or.w	(a0,d1.w),d4
	or.w	(a0,d0.w),d4
	or.w	(a0)+,d4
	move.w	d4,(a1)+
	dbra	d6,bsh_h82	
	adda.w	d2,a0
bsh_h8i:
	dbra	d3,bsh_h81
	move.l	a1,derivdend
*
*   Mask is built
*
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
**********************************************************
*
*   Create a VFLIP'd brush from the curbrush one, derivded or not.
*
*
*  it is assumed that an hlipped brush is not already on the
*   derived brush list
*
bsh_vflip:
	movem.l	a0-a6/d0-d7,-(sp)
	addq.w	#1,maxderivd	;increase derived brush count
*
	lea	bshblock,a2	;get base of brush block
	move.l	a2,a0
	move.l	a2,a1
	move.w	curbrush,d0
	move.w	d0,d7
	move.w	maxderivd,d1
	lsl.w	#4,d0
	lsl.w	#4,d1
	adda.w	d0,a0
	adda.w	d1,a1
	moveq	#7,d2
bsh_v0:
	move.w	(a0)+,(a1)+	;copy the intrinsic data to derived
	dbra	d2,bsh_v0
*
*
	move.l	derblkend,a3	;get next derived block opening
	move.l	a3,8(a2,d1.w)	;put in brush ID_string
*
	move.l	dstrngend,a4	;get next avail string copy region
	move.l	a4,(a3)+	;save string base ptr
*
	move.l	8(a2,d0.w),a5	;get id_string of src intrinsic/derived
	cmp.w	maxintrins,d7	;is SRC derived?
	bls	bsh_v10		;br if intrinsic
*
	move.l	(a5),a5		;get derived string
*
*  We could be derived from Hflip or HVflip but not Vflip
*
	move.l	a5,a6
bsh_bsck2:
	move.b	(a6)+,d7
	cmpi.b	#" ",d7
	bls	bsh_v10		;br if not derived from flipping
	cmpi.b	#">",d7		;">" means we're a previous flip
	bne	bsh_bsck2
*
	sub.l	a5,a6		;are we "Hflip"
	cmpa.w	#6,a6
	beq	bsh_bsck3	;br if so--just add "V"
*
*  we must be "HVflip"
*
	addq.l	#2,a5		;get rid of "V" in "HV" by skipping both
	move.b	#"H",(a4)+	; & adding "H"
	bra	bsh_v0x	
bsh_bsck3:
	addq.l	#1,a5
	move.b	#"H",(a4)+
	move.b	#"V",(a4)+
	bra	bsh_v0x
bsh_v10:
	move.b	#"V",(a4)+	;indicate "Vflip"
	move.b	#"f",(a4)+
	move.b	#"l",(a4)+
	move.b	#"i",(a4)+
	move.b	#"p",(a4)+
	move.b	#">",(a4)+
bsh_v0x:
	move.b	(a5)+,d7
	move.b	d7,(a4)+
	cmpi.b	#" ",d7
	bhi	bsh_v0x
	clr.b	-(a4)
	addq.l	#1,a4
	move.l	a4,dstrngend	;Malloc this string
*
*  Now let's work on the derived block entry
*
	clr.w	(a3)+		;count (-1) has just one entry
	move.w	curbrush,(a3)+	;which intrinsic brush
	move.w	#Vflip,(a3)+	;Vflip effect
	clr.l	(a3)+		;no h/v-offset
	clr.l	(a3)+		;no width/height
	move.l	a3,derblkend	;Malloc this block entry
*
*  End derived block entry build
*
*
	move.l	4(a2,d0.w),a0	;get intrinsic graphics ptr
	move.l	derivdend,a1	; & new derived graphics ptr
	move.l	a1,4(a2,d1.w)	;save to new brush block
*
	movea.w	(a2,d0.w),a3	;save b_width in lo word of a3
*
	move.w	14(a2,d0.w),d3	;get s_nxln
	move.w	d3,d7
	move.w	2(a2,d0.w),d4	;get b_height
	subq.w	#1,d4
	mulu	d4,d7		;d7 = offset to beginning of last line
	adda.l	d7,a0		;a0 -> beg of last line of intrinsic src
*
	move.w	d3,d7
	add.w	d3,d3
	lsr.w	#2,d7		;d7 = # of long words in a line
	subq.w	#1,d7
*
bsh_v1:
	move.w	d7,d0
bsh_v2:
	move.l	(a0)+,(a1)+
	dbra	d0,bsh_v2
	suba.w	d3,a0		;back-up 2 lines
	dbra	d4,bsh_v1
*
*  Now build mask
*
	move.l	derivdend,a0	; & new derived graphics ptr
	move.w	curbrush,d7
	lsl.w	#4,d7
	move.w	14(a2,d7.w),d0		;get s_nxln
	lsr.w	#2,d0			;d0 = offset to plane #1
	move.w	d0,d5
	lsr.w	#1,d5
	subq.w	#1,d5			;d5 = # of words in line (-1)
*
	move.w	d0,d1
	add.w	d1,d1			;d1 = offset to plane #2
	move.w	d1,d2
	add.w	d0,d2			;d2 = offset to plane #3
	move.w	2(a2,d7.w),d3		;get form height
	bra	bsh_v8i
bsh_v81:
	move.w	d5,d6
bsh_v82:
	move.w	(a0,d2.w),d4
	or.w	(a0,d1.w),d4
	or.w	(a0,d0.w),d4
	or.w	(a0)+,d4
	move.w	d4,(a1)+
	dbra	d6,bsh_v82	
	adda.w	d2,a0
bsh_v8i:
	dbra	d3,bsh_v81
	move.l	a1,derivdend
*
*   Mask is built
*
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
*
*
*
*    Ctrl-Key stuff..
*
*	When some control codes come in, call Cary to do
*
CaryKey:
	tst.w	d4
	beq	Caryx		;exit if no key to worry about

	move.l	a5,-(sp)	;call this after "getmouse"
	lea	ctrlist,a5
KeyLp:
	cmp.w	(a5)+,d4
	beq	KeyGot
	cmpa.l	#ctrliste,a5
	bcs	KeyLp
Caryxx:
	move.l	(sp)+,a5
Caryx:
	rts
*
*   We got one on the list
*
KeyGot:	
	movem.l	a0-a6/d0-d7,-(sp)
	bsr	pastund
	bsr	bsh2curs	;put the system mouse at about the brush
	move.w	d4,d0
	bsr	Check_Keyboard
*
	move.l	mouseptr,a0
*	move.l	#$00800080,(a0)	;restore our mouse relative
	move.l	relcentx,(a0)
*
	bsr	clipinit	;re-adjust our clip rectangle
*
	movem.w	mousex,d0-d1
	bsr	rebrush
	movem.w	d0-d1,mousex
*	
	lea	bshblock,a1
	move.w	curbrush,d0
	lsl.w	#4,d0
	move.l	4(a1,d0.w),a3
	move.l	a3,a0
	adda.w	12(a1,d0.w),a0
*
	movem.w	bsh_x,d0-d4
	bsr	rebrush		;clip brush to new motion bounds
	movem.w	d0-d4,bsh_x

	bsr	bdisplay	
	movem.l	(sp)+,a0-a6/d0-d7
	bra	Caryxx
*
*
***************************************
*
*  Entry: d0, d1 = hpos/vpos of brush
*
*  Exit: d0, d1 = hpos/vpos of brush clipped to new Mclpxmn etc.
*
rebrush:
*
*  force new brush to fit on possibly new window
*
	cmp.w	Mclpxmn,d0	;
	bge	KeyGot0	
	move.w	Mclpxmn,d0
KeyGot0:
	cmp.w	Mclpymn,d1
	bge	KeyGot1
	move.w	Mclpymn,d1
KeyGot1:
	cmp.w	Mclpxmx,d0	;
	blt	KeyGot2	
	move.w	Mclpxmx,d0
	subq.w	#1,d0
KeyGot2:
	cmp.w	Mclpymx,d1
	blt	KeyGot3
	move.w	Mclpymx,d1
	subq.w	#1,d1
KeyGot3:
	rts

*		
ctrlist:
	.dc.w	CTRL_UP		;up arrow
	.dc.w	CTRL_DWN	;down arrow
	.dc.w	CTRL_LF		;left arrow
	.dc.w	CTRL_RT		;right arrow
*
	.dc.w	CTRL_P		;load palette
	.dc.w	CTRL_W		;clear world
	.dc.w	CTRL_F		;clear floor
	.dc.w	CTRL_N		;tile floor normal
	.dc.w	CTRL_Z		;set window (LYNX)
	.dc.w	CTRL_X		;set window (WORLD)
	.dc.w	CTRL_Q		;quit
ctrliste:
*
*
*
*
**********************************************
*
*   Build subdivided tiles from a supertile..
*
*  Here, we add subtiles to the "intrinsic" list
*
*  Entry:
*	a0-> next intrinsic graphics build area for subtiles
*
*	maxintrins - largest # of brush read in
*	maxbrshwid - width of widest brush read in
*	intrinscnt - total # of brushes read in
*
*  
*  Exit:
*	a0 -> updated for end of graphics added
*
*	maxintrins - updated for subtiles
*	maxbrshwid - updated
*	intrinscnt - updated
*
SubTile:
	tst.w	blistexist	;was BRUSH.LST read in?
	beq	subte		;br if not
	tst.w	intrinscnt	;check for no brushes read in
	beq	subte		;br if none
*
*  Else, we may have user-defined subdivided tiles
*
	move.w	maxintrins,maxderivd	;temporarily use maxderived
*	
	lea	bshblock,a2
	moveq	#0,d7		;start with first intrinsic brush
subtlp:
	lsl.w	#4,d7
	tst.w	(a2,d7.w)	;is it real?
	beq	subti		;br if not
*
*  got an intrinsic brush
*
	move.l	8(a2,d7.w),a1	;id string
	lea	brshfile,a3
subt0:
	move.b	(a1)+,d6
	cmpi.b	#"<",d6		;subtile article?
	beq	subt1		;got a subtile string
	move.b	d6,(a3)+
	cmpi.b	#" ",d6
	bhi	subt0
	bra	subti		;exit if no subtiles on this brush
*
*  We have a subtile string..
*
subt1:
	clr.b	-1(a1)		;kill the "<" in the intrinsic string
	moveq.l	#0,d0
*
	lea	subtilnm,a4	;get base of subtile data block
	move.l	d0,(a4)+
	move.l	d0,(a4)+
	move.l	d0,(a4)+	;clear all 7 variables
	move.w	d0,(a4)+
	suba.w	#14,a4
*
	moveq	#6,d1		;go for all seven
ncrunch1:
	moveq	#0,d0
ncrunch:
	moveq	#0,d2
	move.b	(a1)+,d2
	cmpi.b	#",",d2
	beq	ncrunch0
	cmpi.b	#" ",d2
	bls	ncrunch2
	subi.b	#"0",d2
	mulu	#10,d0
	add.w	d2,d0
	bra	ncrunch	
ncrunch0:
	move.w	d0,(a4)+
	dbra	d1,ncrunch1			
	bra	ncrunch3
ncrunch2:
	move.w	d0,(a4)+
ncrunch3:
*
*  got subtile params from user string
*
	lea	subtilnm,a4		;a4 -> subtile struct
*
*			+0 start count
*			+2 horz offset
*			+4 vert offset
*			+6 width
*			+8 height
*		       +10 row count
*		       +12 column count
*
*
	lea	subTblt,a6
*
	move.l	#$03030303,op_tab(a6)
*
	move.l	4(a2,d7.w),s_form(a6)
	move.w	14(a2,d7.w),d0
	move.w	d0,s_nxln(a6)
	lsr.w	#2,d0
	move.w	d0,s_nxpl(a6)
*
	moveq	#2,d0
	move.w	d0,d_nxwd(a6)
	move.w	d0,s_nxwd(a6)
	moveq	#0,d0
	move.l	d0,d_xmin(a6)	;d_xmin & d_ymin = 0
	movem.w	2(a4),d0-d1	;get start x, y
	movem.w	d0-d1,s_xmin(a6)
	movem.w	6(a4),d1-d2	;get width & height
	movem.w	d1-d2,b_width(a6)
*
	addi.w	#15,d1
	andi.w	#$FFF0,d1
	lsr.w	#1,d1
	move.w	d1,d_nxln(a6)
	mulu	d1,d2		;d2.l = DST graphic form size
	lsr.w	#2,d1
	move.w	d1,d_nxpl(a6)
	move.l	d2,d1
	lsr.w	#2,d1		;d1.l = DST mask form size
*
*  d0.w = s_xmin for start of each row
*  d1.l = DST mask size
*  d2.l = DST graphics size
*
	bra	stillp0i
stillp0:
	move.w	d0,s_xmin(a6)	;start a new row
	move.w	10(a4),d3	;row count
	bra	stilelpi
stilelp:
	move.w	maxderivd,d6		;advance "intrinsic"
	addq.w	#1,d6
	move.w	d6,maxderivd
	lsl.w	#4,d6
*
*   cop the palette
*
	add.w	d6,d6
	add.w	d7,d7
	moveq	#7,d5
	lea	palblock,a1
	move.l	a1,a5
	adda.w	d7,a1
	adda.w	d6,a5
	lsr.w	#1,d6
	lsr.w	#1,d7
palcop:
	move.l	(a1)+,(a5)+
	dbra	d5,palcop
*
	move.w	b_width(a6),(a2,d6.w)	;save width
	move.w	b_height(a6),2(a2,d6.w)	;save height
	move.l	a0,4(a2,d6.w)		;new graphics form
	move.l	a0,d_form(a6)
	adda.l	d2,a0			;a0 -> mask
	move.w	d2,12(a2,d6.w)		;save mask offset
	move.w	d_nxln(a6),14(a2,d6.w)	;save s_nxln
*
	move.l	a3,a1
	move.w	(a4),d0
	addq.w	#1,(a4)			;advance item count
	movem.l	d1-d3,-(sp)
	bsr	decitpad		;
	movem.l	(sp)+,d1-d3
	clr.b	(a1)
	move.l	dstrngend,a5
	move.l	a5,8(a2,d6.w)
	lea	brshfile,a1
fakicpy:
	move.b	(a1)+,(a5)+
	bne	fakicpy
	move.l	a5,dstrngend
*
	move.w	#4,plane_ct(a6)
	movem.l	a0-a6/d0-d7,-(sp)
	.dc.w	bitblt
	movem.l	(sp)+,a0-a6/d0-d7
*
*   Build mask
*
	move.l	4(a2,d7.w),a5
	adda.w	12(a2,d7.w),a5
	move.l	a5,s_form(a6)
	move.l	a0,d_form(a6)
	adda.l	d1,a0		;get next addr
*
	move.w	s_nxpl(a6),s_nxln(a6)
	move.w	d_nxpl(a6),d_nxln(a6)
*	
	move.w	#1,plane_ct(a6)
	movem.l	a0-a6/d0-d7,-(sp)
	.dc.w	bitblt
	movem.l	(sp)+,a0-a6/d0-d7
*
	move.l	4(a2,d7.w),s_form(a6)
*
	move.w	s_nxln(a6),d5
	lsl.w	#2,d5
	move.w	d5,s_nxln(a6)
*
	move.w	d_nxln(a6),d5
	lsl.w	#2,d5
	move.w	d5,d_nxln(a6)
*
	move.w	b_width(a6),d5
	add.w	d5,s_xmin(a6)
*
stilelpi:
	dbra	d3,stilelp
	
	move.w	b_height(a6),d5
	add.w	d5,s_ymin(a6)
stillp0i:
	sub.w	#1,12(a4)		;dec column count
	bpl	stillp0			;go for all 
*
*	Go on to next intrinsic brush
*	
subti:
	lsr.w	#4,d7
	addq.w	#1,d7
	cmp	maxintrins,d7
	bls	subtlp
	move.w	maxderivd,maxintrins
subte:
	rts
*
***********************************************
*
*  We're writing out the world--can we write out a tile world too?
*
*	A tile world can exist only if
*	 the following are true for each object in the world:
*
*		1. All objects are intrinsic
*		2. All objects have the same width & height
*		3. No object overlaps any other object
*		4. Each objects' horz & vert position has the same
*		   modulo with respect to its width & height
*
tilewrit:
	movem.l	a0-a6/d0-d7,-(sp)
	lea	worldblk,a0		;get start of objects in world
	move.l	wblkptr,a1		;get end
	cmp.l	a1,a0
	bcc	notwrit			;br if no tiles here, pal
*
	lea	bshblock,a2
	lea	grafbsh,a3		;use for tile grid buffer
*
	move.l	a3,a4			;fill undbuf with all $FFFF's
	move.w	#(maxBSHsize/4)-1,d0
	moveq	#-1,d1
ffitlp:
	move.l	d1,(a4)+
	dbra	d0,ffitlp
*
	move.w	(a0),d0		;get 1st brush #
	cmp.w	maxintrins,d0	;it must be intrinsic
	bhi	notwrit		;br if we can't write tile world
	lsl.w	#4,d0
	movem.w	(a2,d0.w),d1-d2	;get width & height
	lsr.w	#4,d0
	moveq	#0,d3
	move.w	wstruct+w_wid,d3	;get world width
	divu	d1,d3		;get # across
	moveq	#0,d4
	move.w	wstruct+w_hite,d4
	divu	d2,d4		;get # down
	movem.w	d3-d4,subtilnm	;save across & down in temp variables
*
	moveq	#0,d3
	moveq	#0,d4
	move.w	4(a0),d3	;get hpos
	move.w	6(a0),d4	;ypos
*
	divu	d2,d4
	move.w	d4,d5		;d5 = row #	
	mulu	subtilnm,d5	;d5 = index in undbuf to start of row
	swap	d4		;d4 = vert modulo
*
	divu	d1,d3
	add.w	d3,d5		;d5 = index into undbuf
	add.w	d5,d5		;d5 = word index
	swap	d3		;d3 = remainder will tell horz modulo
	move.w	d0,(a3,d5.w)	;save this tile
*
*   d0 = current brush #
*   d1 = tile width
*   d2 = tile height
*   d3 = horz position modulo
*   d4 = vert position modulo
*
	move.w	#1,brushnbr	;use this to count tiles
	bra	tilewlpi
tilewlp:
	move.w	(a0),d0		;get next brush #
	cmp.w	maxintrins,d0	;it must be intrinsic
	bhi	notwrit		;br if we can't write tile world
	lsl.w	#4,d0
	cmp.w	(a2,d0.w),d1	;same width?
	bne	notwrit		;exit if not
	cmp.w	2(a2,d0.w),d2	;same height?
	bne	notwrit		;exit if not
	lsr.w	#4,d0
*
	moveq	#0,d5
	moveq	#0,d6
	move.w	4(a0),d5	;get hpos
	move.w	6(a0),d6	;vpos
*
	divu	d2,d6		;vpos/tileheight
	move.w	d6,d7		;d7 = row #	
	mulu	subtilnm,d7	;d7 = index in undbuf to start of row
	swap	d6		;d6 = vert modulo
	cmp.w	d6,d4
	bne	notwrit		;exit if not same vert modulo
*
	divu	d1,d5
	add.w	d5,d7		;d7 = index into undbuf
	add.w	d7,d7		;d7 = word index
	swap	d5		;d5 = horz modulo
	cmp.w	d5,d3
	bne	notwrit		;exit if not same vert modulo
*
	move.w	d0,(a3,d7.w)	;save this tile
	addq.w	#1,brushnbr
tilewlpi:
	addq.l	#8,a0
	cmp.l	a1,a0
	bcs	tilewlp
*
*   We did all the objects
*
	move.w	brushnbr,d3
	cmpi.w	#2,d3		;need 2 or more tiles to write
	bcs	notwrit		;exit if not at least 2
*
	movem.w	subtilnm,d3-d4	;reget # tiles across & down
*
*   d1 = tile width (in pix)
*   d2 = tile height (in pix)
*   d3 = # tiles across
*   d4 = # tiles down
*
	movem.w	d1-d4,subtilnm
*
*
	move.l	#undbuf,undform	;we'll use this as a write buffer
*
	lea	world_ID,a0
	lea	brshfile,a1
ts_w:
	move.b	(a0)+,(a1)+
	bne	ts_w
	subq.l	#1,a1
	move.b	#"L",-(a1)
	move.b	#"I",-(a1)
	move.b	#"T",-(a1)
*
	clr.w	-(sp)
	pea	brshfile
	move.w	#$3c,-(sp)	;create .TIL file for write
	trap	#1
	addq.l	#8,sp
*
	move.w	d0,handle
	bpl	tilwrok
tilwrerr:
	movem.l	(sp)+,a0-a6/d0-d7
	moveq	#-1,d0
	addq.l	#4,sp
	rts
*
*  we have a good .TIL file to write to
*
tilwrok:
	lea	tilhead,a1
	bsr	strngout	;"World Tile Array"
*
	move.w	brushnbr,d0
	bsr	decout		;# of brushes
*
	lea	tilhead0,a1
	bsr	strngout
*
	move.w	brushnbr,d1
	move.w	subtilnm+4,d0
	mulu	subtilnm+6,d0
	move.w	d0,brushnbr
	sub.w	d1,d0
	bsr	decout
*
	lea	tilhead5,a1
	bsr	strngout
*
	move.w	subtilnm,d0	;get width
	bsr	decout
*
	lea	tilhead1,a1
	bsr	strngout
*
	move.w	subtilnm+2,d0	;get height
	bsr	decout
*
	lea	tilhead2,a1
	bsr	strngout
*
	move.w	subtilnm+4,d0	;across count
	bsr	decout
*
	lea	tilhead3,a1
	bsr	strngout
*
	move.w	subtilnm+6,d0	;down count
	bsr	decout
*
	lea	tilhead4,a1
	bsr	strngout
*
	lea	grafbsh,a0	;items are listed here
tilwrlp:
	moveq	#7,d6
	lea	tilcrlf,a1	;cr,lf,"	.word	"
	bsr	strngout
tilwrlp0:
	lea	brshfile,a3
	move.l	a3,a1
	lea	nulltile,a5	;assume a bad tile
*
	move.w	(a0)+,d0	;get next brush #
	bmi	tilwrx		;br if bad brush
*
	lsl.w	#4,d0
	move.l	8(a2,d0.w),a5
tilwrx:	
	move.b	(a5)+,d1
	move.b	d1,(a3)+
	cmpi.b	#" ",d1
	bhi	tilwrx
	clr.b	-(a3)
*
	bsr	strngout
*
	sub.w	#1,brushnbr
	beq	tilwdone
*
	tst.w	d6
	beq	tilwrxx
*
	move.b	#",",d0
	bsr	charwri
tilwrxx:
	dbra	d6,tilwrlp0
	bra	tilwrlp	
tilwdone:
*
*
	lea	undbuf,a0
	move.l	undform,d0
	sub.l	a0,d0
	beq	exactob
*
*  write out partial last buffer
*
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1		;write next buffer full of file
	adda.w	#12,sp
	cmp.l	-8(sp),d0
*
exactob:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			;close file
	addq.l	#4,sp
*
notwrit:
	movem.l	(sp)+,a0-a6/d0-d7
	rts
*
