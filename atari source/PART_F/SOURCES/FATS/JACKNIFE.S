*
*   Jimmy's Jack knife routines
*
*
	globl	ant_splat
	globl	jack_knife
	globl	jack_mask
*
	globl	cpy_nxln
	globl	vdicall,contrl,ptsin,intin,jackmode,killclip


*  offsets into line A bit blt block

BLT_OFF		equ	000

B_WD		equ	000+BLT_OFF
B_HT		equ	002+BLT_OFF
PLANES		equ	004+BLT_OFF
FG_COL		equ	006+BLT_OFF
BG_COL		equ	008+BLT_OFF
OP_TAB		equ	010+BLT_OFF
S_XMIN		equ	014+BLT_OFF
S_YMIN		equ	016+BLT_OFF
S_FORM		equ	018+BLT_OFF
S_NXWD		equ	022+BLT_OFF
S_NXLN		equ	024+BLT_OFF
S_NXPL		equ	026+BLT_OFF
D_XMIN		equ	028+BLT_OFF
D_YMIN		equ	030+BLT_OFF
D_FORM		equ	032+BLT_OFF
D_NXWD		equ	036+BLT_OFF
D_NXLN		equ	038+BLT_OFF
D_NXPL		equ	040+BLT_OFF
P_ADDR		equ	042+BLT_OFF
P_NXLN		equ	046+BLT_OFF
P_NXPL		equ	048+BLT_OFF
P_MASK		equ	050+BLT_OFF

BLT_LEN		equ	076


*  offsets into local variable block

JACK_OFF	equ	000

VTX_CNT		equ	000+JACK_OFF
VTX_ADDR	equ	002+JACK_OFF
VTX_XMIN	equ	006+JACK_OFF
VTX_YMIN	equ	008+JACK_OFF
VTX_XMAX	equ	010+JACK_OFF
VTX_YMAX	equ	012+JACK_OFF
SRC_ADDR	equ	014+JACK_OFF
B32_ADDR	equ	018+JACK_OFF
B08_ADDR	equ	022+JACK_OFF
VBAS_OLD	equ	026+JACK_OFF

JACK_LEN	equ	030

*  offsets into line A variables list

DEV_XMAX	equ	-692
DEV_YMAX	equ	-690
BYTES_LIN	equ	-002
V_PLANES	equ	 000
V_LIN_WR	equ	 002
CONTRL		equ	 004
PTSIN		equ	 012
COLBIT0		equ 	 024
LNMASK		equ	 034
WMODE		equ	 036
X1		equ	 038
Y1		equ	 040
X2		equ	 042
Y2		equ	 044
PATPTR		equ	 046
PATMSK		equ	 050
MFILL		equ	 052
CLIP		equ	 054
XMINCL		equ	 056
YMINCL		equ	 058
XMAXCL		equ	 060
YMAXCL		equ	 062



*  line A routine op codes

LINEA_INIT	equ	$A000
LINEDRAW	equ	$A003
BITBLT		equ	$A007
POLYFILL	equ	$A006

*  bios equates

EXBIOS		equ	14
LOGBASE		equ	03		; get logical screen base
SETSCREEN	equ	05		; set screen parameters



	
jack_mask:

*  iN:
*	a0	points to source form
*	a1	points to 32k buffer
*	a2	points to  8k buffer
*
*	d4	Xmin
*	d5	Ymin
*	d6	Xmax
*	d7	Ymax


	lea	jack_block(pc),a5	; a5 -> local variables

	move.l	a0,SRC_ADDR(a5)
	move.l	a1,B32_ADDR(a5)
	move.l	a2,B08_ADDR(a5)

	move.w	d4,VTX_XMIN(a5)
	move.w	d5,VTX_YMIN(a5)
	move.w	d6,VTX_XMAX(a5)
	move.w	d7,VTX_YMAX(a5)
*
*  fill 8320-byte mask buffer with ones
*
	moveq.l	#-1,d1			; fill mask buffer with ones
	move.w	#519,d0
	move.l	a2,a1			; a1 -> destination buffer (8k)

ones_loop:

	move.l	d1,(a2)+
	move.l	d1,(a2)+
	move.l	d1,(a2)+
	move.l	d1,(a2)+
	dbra	d0,ones_loop

	bsr	xfrm_421		; transform 4 plane src to 1 plane mask

	tst.w	jackmode
	bne	go_home

	move.w	#LOGBASE,-(sp)
	trap	#EXBIOS
	move.l	d0,VBAS_OLD(a5)		; save old logical base
	addq.l	#2,sp			; clean up the stack	

	dc.w	LINEA_INIT
	move.l	a0,a4			; a4 -> vdi variable block

	bsr	jack_opaque		; make the opaque mask
	bra	clean_up		; restore old variables





	
jack_knife:

*  iN:
*	a0	points to source form (screen)
*	a1	points to 32k buffer
*	a2	points to  8k buffer
*	a3	points to point list (in vdi format)
*
*	d0	number of verticies in point list
*
* ouT:
*
*	rectanglE enclosinG originaL regioN outlinE	
*
*	d4	Xmin
*	d5	Ymin
*	d6	Xmax
*	d7	Ymax



		lea	jack_block(pc),a5	; a5 -> local variables

		move.w	d0,VTX_CNT(a5)
		move.l	a0,SRC_ADDR(a5)
		move.l	a1,B32_ADDR(a5)
		move.l	a2,B08_ADDR(a5)
		move.l	a3,VTX_ADDR(a5)


*   determine minimum and maximum of source jacknife region


		move.w	(a3)+,d4	; d4 <- Xmin seed
		move.w	d4,d6		; d6 <- Xmax seed
		move.w	(a3)+,d5	; d5 <- Ymin seed
		move.w	d5,d7		; d7 <- Ymax seed
		dbra	d0,test_counter
		rts

test_x:		move.w	(a3)+,d3	; d3 <- new X

test_xmin:	cmp.w	d3,d4		; test for new Xmin
		ble.s	test_xmax

		move.w	d3,d4		; d4 <- new Xmin
		bra.s	test_y		; skip Xmax test

test_xmax:	cmp.w	d3,d6		; test for new Xmax
		bge.s	test_y

		move.w	d3,d6		; d6 <- new Xmax

test_y:		move.w	(a3)+,d3	; d3 <- new Y

test_ymin:	cmp.w	d3,d5		; test for new Ymin
		ble.s	test_ymax

		move.w	d3,d5		; d5 <- new Ymin
		bra.s	test_counter	; skip Ymax test

test_ymax:	cmp.w	d3,d7		; test for new Ymax
		bge.s	test_counter

		move.w	d3,d7		; d7 <- new Ymax

test_counter:	dbra	d0,test_x

		move.w	d4,VTX_XMIN(a5)
		move.w	d5,VTX_YMIN(a5)
		move.w	d6,VTX_XMAX(a5)
		move.w	d7,VTX_YMAX(a5)


		bsr	xfrm_421	; transform 4 plane src to 1 plane mask


*
*  fill 8320-byte mask buffer with ones
*

		move.l	B08_ADDR(a5),a2
		moveq.l	#-1,d6
		move.w	#519,d7

clr8000:	move.l	d6,(a2)+
		move.l	d6,(a2)+
		move.l	d6,(a2)+
		move.l	d6,(a2)+
		dbra	d7,clr8000


*   Use the vertex list to build a 1 plane mask in the 8k buffer

		move.w	#LOGBASE,-(sp)
		trap	#EXBIOS
		move.l	d0,VBAS_OLD(a5)		; save old logical base
		addq.l	#2,sp			; clean up the stack	


		moveq.l	#-1,d0
		move.w	d0,-(sp)
		move.l	d0,-(sp)
		move.l	B08_ADDR(a5),-(sp)	; a1 -> logical screen
		move.w	#SETSCREEN,-(sp)
		trap	#EXBIOS
		add.w	#12,sp

		dc.w	LINEA_INIT
		move.l	a0,a4			; a4 -> line A variables

		lea	VTX_CNT-2(a5),a0	; CONTRL[1] <- # of points
		move.l	a0,CONTRL(a4)
		move.l	VTX_ADDR(a5),PTSIN(a4)	; PTSIN  -> point array
		clr.w	COLBIT0(a4)		; fill with zeros
		clr.w	WMODE(a4)		; replace mode
		move.l	#all_ones,PATPTR(a4)	; have to point to some pattern
		clr.w	PATMSK(a4)		; one word long
		clr.w	MFILL(a4)		; single plane
		clr.w	CLIP(a4)		; no need to clip
*
	move.w	cpy_nxln,d0
	lsr.w	#2,d0
*
*		moveq.l	#40,d0			; 40 bytes per line
*
		move.w	d0,V_LIN_WR(a4)
		move.w	d0,BYTES_LIN(a4)
		move.w	#1,V_PLANES(a4)		; 1 plane

		move.w	VTX_YMIN(a5),d0
		move.w	VTX_YMAX(a5),d7
		sub.w	d0,d7			; d7 <- row counter
		move.w	d0,Y1(a4)		; Y1 <- current Y

poly_loop:	dc.w	POLYFILL

		addq.w	#1,Y1(a4)		; next Y
		dbra	d7,poly_loop



*  put in the outline

		move.w	VTX_CNT(a5),d7
		move.l	VTX_ADDR(a5),a3
		clr.w	COLBIT0(a4)		; fill with zeros
		clr.w	WMODE(a4)		; replace mode
		move.w	#-1,LNMASK(a4)		; solid pattern
		bra.s	line_enter
		
line_loop:	move.l	(a3)+,X1(a4)
		move.l	 (a3),X2(a4)

		dc.w	LINEDRAW
line_enter:
		dbra	d7,line_loop



*   logically OR the source mask (32k buffer) into poly mask (8k buffer)

		lea	x1a1_block(pc),a6
		
		move.l	B32_ADDR(a5),S_FORM(a6)
		move.l	B08_ADDR(a5),D_FORM(a6)

		move.w	VTX_XMIN(a5),d4
		move.w	VTX_YMIN(a5),d5
		move.w	VTX_XMAX(a5),d6
		move.w	VTX_YMAX(a5),d7

		move.w	d4,S_XMIN(a6)
		move.w	d4,D_XMIN(a6)
		move.w	d5,S_YMIN(a6)
		move.w	d5,D_YMIN(a6)

		sub.w	d4,d6
		addq.w	#1,d6
		move.w	d6,B_WD(a6)
		sub.w	d5,d7
		addq.w	#1,d7
		move.w	d7,B_HT(a6)

		move.w	#1,PLANES(a6)
*
	move.w	cpy_nxln,d7
	lsr.w	#2,d7
	move.w	d7,S_NXLN(a6)
	move.w	d7,D_NXLN(a6)
*
		dc.w	BITBLT


		tst.w	jackmode
		bne.s	transparent

		bsr	jack_opaque

transparent:


*   Bring the original source back into the 32k buffer

		lea	x424_block(pc),a6
		
		move.l	SRC_ADDR(a5),S_FORM(a6)
		move.l	B32_ADDR(a5),D_FORM(a6)

		move.w	VTX_XMIN(a5),d4
		move.w	VTX_YMIN(a5),d5
		move.w	VTX_XMAX(a5),d6
		move.w	VTX_YMAX(a5),d7

		move.w	d4,S_XMIN(a6)
		move.w	d4,D_XMIN(a6)
		move.w	d5,S_YMIN(a6)
		move.w	d5,D_YMIN(a6)

		sub.w	d4,d6
		addq.w	#1,d6
		move.w	d6,B_WD(a6)
		sub.w	d5,d7
		addq.w	#1,d7
		move.w	d7,B_HT(a6)

		move.w	#4,PLANES(a6)
*
	move.w	cpy_nxln,d7
	move.w	d7,S_NXLN(a6)
	move.w	d7,D_NXLN(a6)
*
		dc.w	BITBLT
		
jim4:

*   mask out extraneous stuff in the 32k buffer

		lea	x1a4_block(pc),a6
		
		move.l	B08_ADDR(a5),S_FORM(a6)
		move.l	B32_ADDR(a5),D_FORM(a6)

		move.w	VTX_XMIN(a5),d4
		move.w	VTX_YMIN(a5),d5
		move.w	VTX_XMAX(a5),d6
		move.w	VTX_YMAX(a5),d7

		move.w	d4,S_XMIN(a6)
		move.w	d4,D_XMIN(a6)
		move.w	d5,S_YMIN(a6)
		move.w	d5,D_YMIN(a6)

		sub.w	d4,d6
		addq.w	#1,d6
		move.w	d6,B_WD(a6)
		sub.w	d5,d7
		addq.w	#1,d7
		move.w	d7,B_HT(a6)

		move.w	#4,PLANES(a6)
*
	move.w	cpy_nxln,d7
	move.w	d7,D_NXLN(a6)
	lsr.w	#2,d7
	move.w	d7,S_NXLN(a6)
*
		dc.w	BITBLT



*   clean up and go home

clean_up:	moveq.l	#-1,d0
		move.w	d0,-(sp)
		move.l	d0,-(sp)
		move.l	VBAS_OLD(a5),-(sp)	; restore logical screen
		move.w	#SETSCREEN,-(sp)
		trap	#EXBIOS
		add.w	#12,sp

		clr.w	CLIP(a4)
		move.w	#160,d0			; 160 bytes per line
		move.w	d0,V_LIN_WR(a4)
		move.w	d0,BYTES_LIN(a4)
		move.w	#4,V_PLANES(a4)		; 4 planes

go_home:	move.w	VTX_XMIN(a5),d4
		move.w	VTX_YMIN(a5),d5
		move.w	VTX_XMAX(a5),d6
		move.w	VTX_YMAX(a5),d7

		rts






xfrm_421:

*   Transform 4 plane source to single plane destination in the 32k buffer.
*   transfer the first plane logically inverted. Logically NOT AND the
*   remaining source planes to the same destination plane. this results in
*   a mask where color 0 maps to 1 while colors 1 thru 15 map to 0

		lea	x421_block(pc),a6
		
		move.l	a0,S_FORM(a6)		; source 32k
		move.l	a1,D_FORM(a6)		; destination 32k

		move.w	d4,S_XMIN(a6)
		move.w	d4,D_XMIN(a6)
		move.w	d5,S_YMIN(a6)
		move.w	d5,D_YMIN(a6)

		sub.w	d4,d6
		addq.w	#1,d6
		move.w	d6,B_WD(a6)
		sub.w	d5,d7
		addq.w	#1,d7
		move.w	d7,B_HT(a6)

		clr.w	   FG_COL(a6)
		move.w	#1,BG_COL(a6)
		move.w	#4,PLANES(a6)
*
	move.w	cpy_nxln,d7
	move.w	d7,S_NXLN(a6)
	lsr.w	#2,d7
	move.w	d7,D_NXLN(a6)
*
		dc.w	BITBLT
*

		rts



jack_opaque:

*   fill first 9024 bytes of big buffer (32k) with 1's

		move.l	B32_ADDR(a5),a2
		moveq.l	#-1,d6
		move.w	#563,d7

clr8496:	move.l	d6,(a2)+
		move.l	d6,(a2)+
		move.l	d6,(a2)+
		move.l	d6,(a2)+
		dbra	d7,clr8496


*   move the transparent mask to (1,1) in the 32k buffer

		lea	x121_block(pc),a6
		
		move.l	B08_ADDR(a5),S_FORM(a6)
		move.l	B32_ADDR(a5),D_FORM(a6)

		move.w	VTX_XMIN(a5),d4
		move.w	VTX_YMIN(a5),d5
		move.w	VTX_XMAX(a5),d6
		move.w	VTX_YMAX(a5),d7

		move.w	d4,S_XMIN(a6)
		move.w	d5,S_YMIN(a6)

		sub.w	d4,d6
		addq.w	#1,d6
		move.w	d6,B_WD(a6)
		sub.w	d5,d7
		addq.w	#1,d7
		move.w	d7,B_HT(a6)

		move.w	#1,PLANES(a6)
*
	move.w	cpy_nxln,d7
	lsr.w	#2,d7
	move.w	d7,S_NXLN(a6)
	addq.w	#2,d7
	move.w	d7,D_NXLN(a6)
*
	move.w	d7,-(sp)
		dc.w	BITBLT

*   use seed fill to isolate wholey enclosed interior regions

		moveq.l	#-1,d0
		move.w	d0,-(sp)
		move.l	d0,-(sp)
		move.l	B32_ADDR(a5),-(sp)	; set logical screen
		move.w	#SETSCREEN,-(sp)
		trap	#EXBIOS
		add.w	#12,sp
*
	move.w	(sp)+,d7
*		moveq.l	#42,d0			; 42 bytes per line
		move.w	d7,V_LIN_WR(a4)
		move.w	d7,BYTES_LIN(a4)
		move.w	#1,V_PLANES(a4)		; 1 plane

		move.w	#322,DEV_XMAX(a4)
		move.w	#322,DEV_YMAX(a4)

		lea	contrl,a0		; set clipping rectangle
		move.w	#129,(a0)+
		move.w	#002,(a0)+
		addq.l	#2,a0
		move.w	#001,(a0)

		move.w	#-1,intin

		lea	ptsin,a0
		clr.l	(a0)+			; upper left (0,0)

		move.w	VTX_XMAX(a5),d6
		move.w	VTX_YMAX(a5),d7
		sub.w	VTX_XMIN(a5),d6		; d6 <- dX
		sub.w	VTX_YMIN(a5),d7		; d7 <- dY
		addq.w	#2,d6
		move.w	d6,(a0)+		; lower right (B_WD+1,B_HT+1)
		addq.w	#2,d7
		move.w	d7,(a0)
		jsr	vdicall

		lea	contrl,a0
		move.w	#025,(a0)+
		clr.w	(a0)+
		move.w	#001,(a0)+

		clr.w	intin			; color 0 (logical=physical)
		jsr	vdicall

		lea	contrl,a0
		move.w	#103,(a0)+		; do vdi contour fill
		moveq.l	#1,d0
		move.w	d0,(a0)+
		addq.w	#2,a0
		move.w	d0,(a0)

		move.w	#-1,intin		; fill seed color
		clr.l	ptsin			; start at (0,0)
		jsr	vdicall

		move.w	#319,DEV_XMAX(a4)	; restore parameters
		move.w	#199,DEV_YMAX(a4)

		jsr	killclip		; restore clipping boundry


*   XOR the new mask back (32k) into the 8k buffer

		lea	x1x1_block(pc),a6

		move.l	B32_ADDR(a5),S_FORM(a6)
		move.l	B08_ADDR(a5),D_FORM(a6)

		move.w	VTX_XMIN(a5),d4
		move.w	VTX_YMIN(a5),d5
		move.w	VTX_XMAX(a5),d6
		move.w	VTX_YMAX(a5),d7

		move.w	d4,D_XMIN(a6)
		move.w	d5,D_YMIN(a6)

		sub.w	d4,d6
		addq.w	#1,d6
		move.w	d6,B_WD(a6)
		sub.w	d5,d7
		addq.w	#1,d7
		move.w	d7,B_HT(a6)

		move.w	#1,PLANES(a6)
*
	move.w	cpy_nxln,d7
	lsr.w	#2,d7
	move.w	d7,D_NXLN(a6)
	addq.w	#2,d7
	move.w	d7,S_NXLN(a6)
*

		dc.w	BITBLT

		rts



*******************************************************************************
*
*  iN:
*	a0	points to edge mask form	(0:transparent 1:crawling ants)
*	a1	points to dst form
*	a2	points to 16 word ant pattern
*	a4	mask form width (bytes)
*	a5	dst  from width  (bytes)
*
*	d0	Xmin
*	d1	Ymin
*	d2	Xmax
*	d3	Ymax
*
*
* NOTE:
*	edge mask always starts at (16 + X mod 16, 2)
*
*******************************************************************************


ant_splat:

	move.w	a4,d7

	add.w	d7,d7			; <dave> always use 3rd row
*dave	mulu	d1,d7			; d7 <- offset to 1st line of mask

	adda.w	d7,a0			; a0 -> beginning of 1st line of mask

	move.w	a5,d7
	mulu	d1,d7			; d7 <- offset to 1st line of dst
	add.l	d7,a1			; a1 -> beginning of 1st line of dst

	and.w	#$FFF0,d0		; clamp to word boundry
	lsr.w	#1,d0			; d0 <- offset to 1st word of dst
	add.w	d0,a1			; a1 -> 1st word of dst

*dave	lsr.w	#2,d0			; d0 <- offset to 1st word of mask
*dave	add.w	d0,a0			; a0 -> 1st word of mask
	addq.l	#2,a0			; <dave> always 1 word from left

*dave	lsr.w	#1,d0			; d0 <- word offset to 1st word
	lsr.w	#3,d0			; <dave>

	lsr.w	#4,d2			; d2 <- word offset to last word
	sub.w	d0,d2			; d2 <- span -1
	move.w	d2,d0			; d0 <- dbra inner loop count

	addq.w	#1,d2			; d2 <- word span
	add.w	d2,d2			; d2 <- byte span
	sub.w	d2,a4			; a4 <- edge mask wrap value
	add.w	d2,d2			; adjust for 4 planes
	add.w	d2,d2
	sub.w	d2,a5			; a5 <- dst wrap value

	sub.w	d1,d3			; d3 <- outer loop counter (height -1)
	move.w	d0,d2			; d2 <- inner loop counter
	clr.w	d1			; d1 <- initial pattern pointer
	move.w	(a2),d5			; d5 <- initial pattern word


ant_loop:

	move.w	(a0)+,d7		; d7 <- primary ant mask
	beq.s	no_ants			; take a shortcut if no ants are around

	move.w	d7,d6			
	not.w	d7			; d7 <- edge mask inverted
	and.w	d5,d6			; d6 <- ants mask

	and.w	d7,(a1)			; D'  <- D  and [not Me]	plane 0
	or.w	d6,(a1)+		; D'' <- D' or Ma
	and.w	d7,(a1)			; D'  <- D  and [not Me]	plane 1
	or.w	d6,(a1)+		; D'' <- D' or Ma
	and.w	d7,(a1)			; D'  <- D  and [not Me]	plane 2
	or.w	d6,(a1)+		; D'' <- D' or Ma
	and.w	d7,(a1)			; D'  <- D  and [not Me]	plane 3
	or.w	d6,(a1)+		; D'' <- D' or Ma

	dbra	d2,ant_loop		; do next word on this line


	move.w	d0,d2			; reload the inner loop counter
	add.w	a4,a0			; a0 -> start of next mask line
	add.w	a5,a1			; a1 -> start of next dst line
	addq.w	#2,d1			; d1 <- next pattern word
	and.w	#$000E,d1		; d1 <- pattern offset (8 word wrap)
	move.w	0(a2,d1.w),d5		; d5 <- ant pattern for new line
	dbra	d3,ant_loop		; do new line

	rts


no_ants:

	addq.l	#8,a1			; a1 -> next word
	dbra	d2,ant_loop

	move.w	d0,d2			; reload the inner loop counter
	add.w	a4,a0			; a0 -> start of next mask line
	add.w	a5,a1			; a1 -> start of next dst line
	addq.w	#2,d1			; d1 <- next pattern word
	and.w	#$000E,d1		; d1 <- pattern offset (8 word wrap)
	move.w	0(a2,d1.w),d5		; d5 <- ant pattern for new line
	dbra	d3,ant_loop		; do new line

	rts






x421_block:	dc.w	0,0,4,0,1
		dc.l	$040C040C
		dc.w	0,0
		dc.l	0
		dc.w	8,160,2
		dc.w	0,0
		dc.l	0
		dc.w	2,040,0
		dc.l	0
*		ds.b	30
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0

x1x1_block:	dc.w	0,0,1,0,0
		dc.l	$06060606
		dc.w	1,1
		dc.l	0
		dc.w	2,042,0
		dc.w	0,0
		dc.l	0
		dc.w	2,040,0
		dc.l	0
*		ds.b	30
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0

x1a1_block:	dc.w	0,0,1,0,0
		dc.l	$07070707
		dc.w	0,0
		dc.l	0
		dc.w	2,040,0
		dc.w	0,0
		dc.l	0
		dc.w	2,040,0
		dc.l	0
*		ds.b	30
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0

x121_block:	dc.w	0,0,1,0,0
		dc.l	$03030303
		dc.w	0,0
		dc.l	0
		dc.w	2,040,0
		dc.w	1,1
		dc.l	0
		dc.w	2,042,0
		dc.l	0
*		ds.b	30
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0

x424_block:	dc.w	0,0,4,0,0
		dc.l	$03030303
		dc.w	0,0
		dc.l	0
		dc.w	8,160,2
		dc.w	0,0
		dc.l	0
		dc.w	8,160,2
		dc.l	0
*		ds.b	30
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0

x1a4_block:	dc.w	0,0,4,0,0
		dc.l	$04040404
		dc.w	0,0
		dc.l	0
		dc.w	2,40,0
		dc.w	0,0
		dc.l	0
		dc.w	8,160,2
		dc.l	0
*		ds.b	30
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0

all_ones:	dc.w	$FFFF

jack_block:
*		ds.b	30
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
	.dc.b	0,0,0,0,0,0,0,0,0,0
