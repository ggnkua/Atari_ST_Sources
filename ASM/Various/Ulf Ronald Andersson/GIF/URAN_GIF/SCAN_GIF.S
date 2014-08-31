;----------------------------------------------------------------------------
;File name:	SCAN_GIF.S		Revision date:	1995.06.24
;Creator:	Ulf Ronald Andersson	Creation date:	1995.06.23
;(c)1992 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;File purpose:	Code library for GIF reading
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	SCAN_GIF_defined
SCAN_GIF_defined	set	1
;
;----------------------------------------------------------------------------
	include	URAn_DOS.S
	include	head_GIF.S
;----------------------------------------------------------------------------
;
;	The following illustrates the general file layout of .GIF files,
;	and shows which routine to use for scanning each part:
;
;	File sequences:      spec:  Contents:		Routine:    Effect:
;
; +-----------------------+
; | +-------------------+ |
; | |   GIF Signature   | |  (req)  'GIF87a'		scan_MAGIC  compare
; | +-------------------+ |
; | +-------------------+ |
; | | Screen Descriptor | |  (req)  7 bytes, last = 00	scan_SD     Expand
; | +-------------------+ |
; | +-------------------+ |
; | | Global Color Map  | |  (opt)  3*2^bits bytes	scan_CM     Read
; | +-------------------+ |
; | +-------------------+ |
; | | Extension Block   | |  (opt)  '!' + variant size	scan_ID     Ignore
; | +-------------------+ |
;  - - - - - - - - - - - -
; | +-------------------+ |
; | |  Image Descriptor | |  (opt)  ',' + 9 bytes	scan_ID     Expand
; | +-------------------+ |
; | +-------------------+ |
; | |  Local Color Map  | |  (opt)			scan_CM     Read
; | +-------------------+ |
; | +-------------------+ |
; | |    Raster Data    | |  (req)	 read_raster in other lib   Load
; | +-------------------+ |
;  - - - - - - - - - - - -
; |     GIF Terminator    |  (req)	 read_raster in other lib   Terminate
; +-----------------------+
;
;----------------------------------------------------------------------------
;Start of:	'scan_MAGIC'
;----------------------------------------------------------------------------
;int scan_MAGIC (infile_h, parse_s)
;int	infile_h;
;char   *parse_s;
;
;read chars from file "infile_h" and look for string "parse_s" from
;current file position. return negative at first mismatch, else return zero.
;
scan_MAGIC:
	movem.l	d3/a3,-(sp)
	move	d0,d3
	move.l	a0,a3
.loop:
	clr.l	d0
	tst.b	(a3)
	beq.s	.exit
	gemdos	Fread,d3,#1,.scan_bf(pc)
	tst.l	d0
	ble.s	.read_error
	move.b	.scan_bf(pc),d0
	cmp.b	(a3)+,d0
	beq.s	.loop
.range_error:
	moveq	#E_RANGE,d0
	bra.s	.exit
;
.read_error:
	moveq	#E_RANGE,d0
.exit:
	movem.l	(sp)+,d3/a3
	rts
;
.scan_bf:
	ds.b	2
;
;----------------------------------------------------------------------------
;End of:	'scan_MAGIC'
;----------------------------------------------------------------------------
;Start of:	'scan_SD'
;----------------------------------------------------------------------------
;int scan_SD (infile_h, sd_p)
;int		infile_h;
;screen_t	*sd_p;
;
;	read logical screen descriptor (req'd)
;
;		bits
;	 7 6 5 4 3 2 1 0  Byte #
;	+---------------+
;	|		|  1
;	+-Screen Width -+	Raster width in pixels (LSB first)
;	|		|  2
;	+---------------+
;	|		|  3
;	+-Screen Height-+	Raster height in pixels (LSB first)
;	|		|  4
;	+-+-----+-+-----+	M = 1, Global color map follows Descriptor
;	|M|  cr |0|pixel|  5	cr+1 = # bits of color resolution
;	+-+-----+-+-----+	pixel+1 = # bits/pixel in image
;	|   background  |  6	background=Color index of screen background
;	+---------------+	     (color is defined from the Global color
;	|0 0 0 0 0 0 0 0|  7	      map or default map if none specified)
;	+---------------+
;
;
scan_SD:
	clr	scan_SD_f
	clr	scan_ID_f
	movem.l	d3/a3,-(sp)
	move	d0,d3		;d3 =  infile_h
	move.l	a0,a3		;a3 -> screen descriptor structure
	move.l	a0,scan_SD_p
	gemdos	Fread,d3,#7,.scan_bf(pc)
	cmp.l	#7,d0
	blt.s	.read_error
	lea	.scan_bf(pc),a0
	move	(a0)+,d0	;d0 = width
	ror	#8,d0		;swap bytes to INTEL order
	move	d0,(a3)+	;store GIF_sd_dx
	move	(a0)+,d0	;d0 = height
	ror	#8,d0		;swap bytes to INTEL order
	move	d0,(a3)+	;store GIF_sd_dy
	move.b	(a0)+,d0	;d0 =packed bits of _colors,_bits,_cr,_gcm
	btst	#3,d0
	bne.s	.range_error
	move	d0,d1
	and	#7,d1
	addq	#1,d1		;d1 = bits per pixel  (word)
	lsr.b	#4,d0
	move	d0,d2
	and	#7,d2
	addq	#1,d2		;d2 = colour resolution  (word)
	lsr.b	#3,d0
	move.b	d0,d3		;d3 = global colour map flag byte
	sne	scan_SD_f+1
	moveq	#1,d0
	asl	d1,d0		;d0 = number of colors in palette  (word)
	asl	#8,d3
	move.b	(a0)+,d3	;d3 = (_gcm << 8) + background color
	movem.w	d0-d3,(a3)	;store _colors,_bits,_cr,_gcm,_bgnd
	clr.l	d0
	tst.b	(a0)+		;byte 7 must be zero
	bne.s	.range_error
	st	scan_SD_f
	clr.l	d0
.exit:
	movem.l	(sp)+,d3/a3
	rts
;
.range_error:
	moveq	#E_RANGE,d0
	bra.s	.exit
;
.read_error:
	moveq	#E_READF,d0
	bra.s	.exit
;
.scan_bf:	ds.b	8
;
scan_SD_f:	dc.w	0	;0000: sd invalid  FFxx: sd OK  FFFF: gcm OK
scan_SD_p:	dc.l	0	;-> screen descriptor
scan_GCM_p:	dc.l	0	;-> global colour map
;
;----------------------------------------------------------------------------
;End of:	'scan_SD'
;----------------------------------------------------------------------------
;Start of:	'scan_CM'
;----------------------------------------------------------------------------
;long scan_CM (infile_h, colors, cmap)
;int		infile_h;
;int		colors;
;uchar_t	*cmap;
;
;	read a color map (optional)
;
;	      bits
;	 7 6 5 4 3 2 1 0  Byte #
;	+---------------+
;	| red intensity |  1	Red value for color index 0
;	+---------------+
;	|green intensity|  2	Green value for color index 0
;	+---------------+
;	| blue intensity|  3	Blue value for color index 0
;	+---------------+
;	| red intensity |  4	Red value for color index 1
;	+---------------+
;	|green intensity|  5	Green value for color index 1
;	+---------------+
;	| blue intensity|  6	Blue value for color index 1
;	+---------------+
;	:		:	(Continues for remaining colors)
;
scan_CM:
	movem.l	d3/a3,-(sp)
	move	d1,d3		;d3 =  colors
	move.l	a0,a3		;a3 -> cmap
	add	d3,d3
	add	d1,d3		;d3 =  colors * 3
	gemdos	Fread,d0,d3,(a3)
	sub.l	d3,d0
	bne.s	.read_error
	tst.b	scan_ID_f
	beq.s	.try_gcm
	tst.b	scan_ID_f+1
	beq.s	.try_gcm
	move.l	a3,scan_LCM_p
	bra.s	.exit
;
.try_gcm:
	tst.b	scan_SD_f
	beq.s	.exit
	tst.b	scan_SD_f+1
	beq.s	.exit
	move.l	a3,scan_GCM_p
	bra.s	.exit
;
;	
.read_error:
	clr	scan_ID_f
	clr	scan_SD_f
	moveq	#E_READF,d0
.exit:
	movem.l	(sp)+,d3/a3
	rts
;
;----------------------------------------------------------------------------
;End of:	'scan_CM'
;----------------------------------------------------------------------------
;Start of:	'scan_ID'
;----------------------------------------------------------------------------
;int scan_ID (infile_h, id_p)
;int		infile_h;
;image_t        *id_p;
;
;	read image descriptor (req'd)
;
;	      bits
;	 7 6 5 4 3 2 1 0  Byte #
;	+---------------+
;	|0 0 1 0 1 1 0 0|  1	',' - Image separator character
;	+---------------+
;	|		|  2	Start of image in pixels from the
;	+-  Image Left -+	left side of the screen (LSB first)
;	|		|  3
;	+---------------+
;	|		|  4
;	+-  Image Top  -+	Start of image in pixels from the
;	|		|  5	top of the screen (LSB first)
;	+---------------+
;	|		|  6
;	+- Image Width -+	Width of the image in pixels (LSB first)
;	|		|  7
;	+---------------+
;	|		|  8
;	+- Image Height-+	Height of the image in pixels (LSB first)
;	|		|  9
;	+-+-+-+-+-+-----+	M=0 - Use global color map, ignore 'pixel'
;	|M|I|0|0|0|pixel| 10	M=1 - Local color map follows, use 'pixel'
;	+-+-+-+-+-+-----+	I=0 - Image formatted in Sequential order
;				I=1 - Image formatted in Interlaced order
;				pixel+1 - # bits per pixel for this image
;
scan_ID:
	clr	scan_ID_f
	movem.l	d3/a3,-(sp)
	move	d0,d3		;d3 =  infile_h
	move.l	a0,a3		;a3 -> image descriptor structure
	move.l	a0,scan_ID_p
.loop:
	gemdos	Fread,d3,#1,.scan_bf(pc)
	tst.l	d0
	ble	.read_error
	move.b	.scan_bf(pc),d0	;d0 =  read byte
	cmp.b	#';',d0		;GIF terminator ?
	beq	.range_error
	cmp.b	#'!',d0		;GIF Extension Block ?
	bne.s	.try_image
	move	d3,d0		;d0 = infile_h
	bsr	skip_EB
.try_image:
	cmp.b	#',',.scan_bf	;GIF image descriptor ?  (that we're seeking)
	bne.s	.loop
	gemdos	Fread,d3,#9,.scan_bf(pc)
	cmp.l	#9,d0
	blt.s	.read_error
	lea	.scan_bf(pc),a0
	move	(a0)+,d0	;d0 = X pos of top left corner
	ror	#8,d0		;swap bytes to INTEL order
	move	d0,(a3)+	;store GIF_id_x
	move	(a0)+,d0	;d0 = Y pos of top left corner
	ror	#8,d0		;swap bytes to INTEL order
	move	d0,(a3)+	;store GIF_id_y
	move	(a0)+,d0	;d0 = width
	ror	#8,d0		;swap bytes to INTEL order
	move	d0,(a3)+	;store GIF_id_dx
	move	(a0)+,d0	;d0 = height
	ror	#8,d0		;swap bytes to INTEL order
	move	d0,(a3)+	;store GIF_id_dy
	move.b	(a0)+,d0	;d0 = packed _colors,_bits,_lcm,_lace
	move.b	d0,d1
	and	#7,d1		;d1 = bits per pixel  (word)
	clr	d2
	asl.b	#1,d0
	roxl	#1,d2		;d2 = _lcm
	sne	scan_ID_f+1
	bne.s	.keep_bits
	move.l	scan_SD_p(pc),a1
	move	GIF_sd_bits(a1),d1	;SD bits replace ID bits for gcm
.keep_bits:
	asl	#7,d2
	asl.b	#1,d0
	roxl	#1,d2		;d2 = (_lcm << 8) +_lace
	moveq	#1,d0
	asl	d1,d0		;d0 = number of colors in palette  (word)
	movem.w	d0-d2,(a3)	;store _colors,_bits,_lcm,_lace
	st	scan_ID_f
	clr.l	d0
	bra.s	.exit
;
.range_error:
	moveq	#E_RANGE,d0
	bra.s	.exit
;
.read_error:
	moveq	#E_READF,d0
.exit:
	movem.l	(sp)+,d3/a3
	rts
;
.scan_bf:
	ds.b	10
;
scan_ID_f:	dc.w	0	;0000: id invalid  FFxx: id OK  FFFF: lcm OK
scan_ID_p:	dc.l	0	;-> image descriptor
scan_LCM_p:	dc.l	0	;-> local colour map
;
;----------------------------------------------------------------------------
;End of:	'scan_ID'
;----------------------------------------------------------------------------
;Start of:	'skip_EB'
;----------------------------------------------------------------------------
;void skip_EB (infile_h)
;int	infile_h;
;
;	skips extension block
;
;	 7 6 5 4 3 2 1 0  Byte #
;	+---------------+
;	|0 0 1 0 0 0 0 1|  1	   '!' - GIF Extension Block Introducer
;	+---------------+
;	| function code |  2	   Extension function code (0 to 255)
;	+---------------+    ---+
;	|  byte count	|	|
;	+---------------+	|
;	:		:	+-- Repeated as many times as necessary
;	|func data bytes|	|
;	:		:	|
;	+---------------+    ---+
;	. . .	    . . .
;	+---------------+
;	|0 0 0 0 0 0 0 0|	zero byte count (terminates block)
;	+---------------+
;
skip_EB:
	movem.l	d3/d4/a3,-(sp)
	lea	-$100(sp),sp		;reserve buffer
	move	d0,d3			;d3 =  infile_h
	move.l	sp,a3			;a3 -> buffer
.loop:
	gemdos	Fread,d3,#2,(a3)	;read function & bytecount
	sub.l	#2,d0
	bne.s	.error
	clr.l	d4
	move.b	1(a3),d4
	beq.s	.exit
	gemdos	Fread,d3,d4,(a3)	;read function & bytecount
	sub.l	d4,d0
	beq.s	.loop
.error:
	moveq	#E_READF,d0
.exit:
	lea	$100(sp),sp
	movem.l	(sp)+,d3/d4/a3
	rts
;
;----------------------------------------------------------------------------
;End of:	'skip_EB'
;----------------------------------------------------------------------------
	endc	;SCAN_GIF_defined
;----------------------------------------------------------------------------
;End of file:	SCAN_GIF.S
;----------------------------------------------------------------------------
