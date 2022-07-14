|
| d1: left position
| d2: right position
| d3: number of values to gather
| d7: 0xff00ff, expected by _tex_at_xy
| a1: height map, adjusted for signed indexed access
| a2: destination tline
| a3: destination hline
| a5: texture map, adjusted for signed indexed access
| a6: mul8x8tab, adjusted for signed indexed access
|
_voxel_samplemaps:
	| check if maximum resolution is reached

	cmp.w   #2,d3
	blt     _voxel_samplemaps_fill  | maximum resolution reached

	| subdivide line into left and right part

	move.l  d2,d4             | compute midpoint of left and right position
	sub.l   d1,d4
	asr.w   #1,d4
	add.w   d1,d4
	swap    d1
	swap    d4
	asr.w   #1,d4
	add.w   d1,d4
	swap    d1
	swap    d4                | d4: midpoint

	move.l  d3,d0
	lsr.w   #1,d0             | d0: number of values to gather for left side
	sub.l   d0,d3             | d3: number of values to gather for right side

	| recurse into left side

	movem.l d0-d4/a2-a3,-(sp)
	move.l  d0,d3
	move.l  d4,d2
	bsr.s   _voxel_samplemaps
	movem.l (sp)+,d0-d4/a2-a3

	| recurse into right side

	add.l   d0,a2             | a2: right portion of tline
	add.l   d0,a3             | a3: right portion of hline
	move.l  d4,d1             | d1: midpoint as left position
	bra.s   _voxel_samplemaps | tail recursion

_voxel_samplemaps_done:
	rts

_voxel_samplemaps_fill:
	tst.w   d3                | skip if no value is needed
	ble.s   _voxel_samplemaps_done

	move.l  d1,d5             | d5: position

	| fetch texture value of left position
	move.l  a5,a0
	bsr.s   _voxel_tex_at_xy  | d4: texture value
	move.b  d4,(a2)+          | populate tline buffer

	| fetch height value of left position
	move.l  a1,a0
	bsr.s   _voxel_tex_at_xy  | d4: texture value
	move.b  d4,(a3)+          | populate hline buffer
	rts

_voxel_tex_at_xy:
	TEX_AT_XY
	rts


|
| Calculate column gradients for a z level
|
| a0: y buffer of current z level
| a1: y buffer of previous z level
| a2: color buffer of current z level
| a3: color buffer of previous z level
| a4: buffer with gradient values
| a5: div8x8tab, adjusted for signed indexed access
|
_voxel_calc_gradients:
	move.w  #160-1,d7
1:
	moveq  #0,d3
	moveq  #0,d6      | d6.l: no gradient by default

	moveq  #0,d0
	move.b (a0)+,d0   | d1.w: current y
	moveq  #0,d1
	move.b (a1)+,d1   | d1.w: previous y

	sub.w  d0,d1      | d1.w: dy
	ble.b  2f         | dy must be positive

	moveq  #0,d2
	move.b (a2),d2    | d2.w: current color
	moveq  #0,d3
	move.b (a3),d3    | d3.w: previous color

	cmp.w  d2,d3
	blt    _voxel_calc_negative_gradient

	sub.w  d2,d3           | d3.w: color difference (dc)
	lsl.w  #8,d1
	move.b d3,d1
	move.w (a5,d1.w*2),d3  | d3.w: (dc*256)/dy
	lsr.w  #6,d3           | keep two bits as fractional part
	move.w d3,d0
	and.w  #3,d0
	move.l _voxel_gradient_fractionals(pc,d0.w*4),d6
	lsr.w  #2,d3
	.REP   4               | add integer part to each gradient value
	add.b  d3,d6
	rol.l  #8,d6
	.ENDR
	bra.s  2f

_voxel_calc_negative_gradient:
	sub.l d3,d2
	lsl.w  #8,d1
	move.b d2,d1
	move.w (a5,d1.w*2),d2  | d2.w: (dc*256)/dy
	lsr.w  #8,d2
	.REP   4               | subtract integer part to each gradient value
	sub.b d2,d6
	rol.l  #8,d6
	.ENDR
2:
	move.l d6,(a4)+        | store gradient values
	addq.l #1,a2
	addq.l #1,a3

	dbf     d7,1b
	rts

_voxel_gradient_fractionals:
	dc.l 0x00000000
	dc.l 0x01000000
	dc.l 0x00010001
	dc.l 0x01010100

|
| Render one z level
|
| d3: mask to apply to column height, to suppress column interpolation
| a0: buffer with y values
| a1: buffer with texture values
| a2: buffer with y-max values
| a3: screen
| a4: buffer with gradient values
|
_voxel_renderline:
	lea     _mul160tab,a5  | a5: mul160 table
	move.l  #160,d5        | d5: line length in bytes
	move.w  #160-1,d7
2:
	swap    d7

	moveq.l #0,d4
	move.b  (a0)+,d4       | d4.w: y position
	moveq.l #0,d6
	move.b  (a2),d6        | d6.w: y-max value

	cmp.w  d6,d4
	bcc.s  _renderline_next_column

	move.b d4,(a2)         | update y max for this x position

	sub.w  d4,d6           | d6.w: y-loop counter
	ble.s  _renderline_next_column

	move.w (a5,d4.w*2),d4  | d4.w: y*160
	lea    (a3,d4.w),a6    | a6: start of column in chunky buffer
	move.b (a1),d4         | d4.b: color value

	and.b  d3,d6           | apply hmask for achive lines variation
	cmp.b  #1,d6
	bgt.s  _renderline_interpolate_column
3:
	move.b d4,(a6)         | set pixel in chunky buffer
	add.w  d5,a6
	dbf    d6,3b

_renderline_next_column:

	addq.l #4,a4
	addq.l #1,a3
	addq.l #1,a2
	addq.l #1,a1

	swap   d7
	dbf    d7,2b
	rts

_renderline_interpolate_column:

	|
	| Paint interpolated column of up to 32 lines.
	| The instructions for each line take 6 bytes.
	|

	and.w  d3,d6           | d6.w: limited max column size
	swap   d3              | keep hmask in upper word

	| place gradient ascents g0..g3 into registers d0..d3
	move.l (a4),d1         | d1.l:  g3 g2 g1 g0
	move.b d1,d0           | d0.b:  g0
	swap   d1              | d1.l:  g1 g0 g3 g2
	move.b d1,d2           | d2.b:  g2
	lsr.l  #8,d1           | d1.l:  _  g1 g0 g3
	move.b d1,d3           | d3.b:  g3
	swap   d1              | d1.b:  g1

	| compute jump offset into instruction sequence
	move.w d6,d7
	lsl.w  #1,d7
	add.w  d7,d6           | d6.w: 3*height
	neg.w  d6              | d6.w: -3*height
	jmp    _rendercolumn_end-6(pc,d6.w*2)

	.REP   8
	move.b d4,(a6)         | color value to chunky buffer
	add.w  d5,a6           | next line
	add.b  d0,d4           | apply gradient to color value
	move.b d4,(a6)
	add.w  d5,a6
	add.b  d1,d4
	move.b d4,(a6)
	add.w  d5,a6
	add.b  d2,d4
	move.b d4,(a6)
	add.w  d5,a6
	add.b  d3,d4
	.ENDR
_rendercolumn_end:
	swap d3                | restore hmask in upper word
	bra    _renderline_next_column

_mul160tab:
V = 0
	.REP 256
	dc.w V
	V = V + 160
	.ENDR


|
| Voxel context data structure
|

OFFSET = 0
CELLS  VIEWPOS LDIR RDIR TMAP HMAP LSIGHT RSIGHT
CELLS  ZINDEX TLINE PTLINE HLINE YCLIP YLINE PYLINE
CELLS  GLINE H2Y MUL8x8 DIV8x8 SCREEN ZSTEPS LOD HMASK

| ( voxelctx -- )
CODE_XT voxelzline
	movem.l d5-d6/a4-a6,-(sp) | save forth registers
	move.l d4,a6              | a6: voxel context

	|
	| Swap current and previous line buffers
	|

	move.l  TLINE(a6),d0
	move.l  PTLINE(a6),TLINE(a6)
	move.l  d0,PTLINE(a6)

	move.l  YLINE(a6),d0
	move.l  PYLINE(a6),YLINE(a6)
	move.l  d0,PYLINE(a6)

	|
	| Sample texture and height maps
	|

	move.l  a6,-(sp)
	move.l  ZINDEX(a6),d0     | d0: current z-line index
	move.l  LSIGHT(a6),a0
	move.l  (a0,d0.l*4),d1    | d1: left position
	move.l  RSIGHT(a6),a0
	move.l  (a0,d0.l*4),d2    | d2: right position
	move.l  LOD(a6),d0        | d0: level of detail
	move.l  #160,d3
	lsr.l   d0,d3             | d3: number of values to gather
	move.l  #0xff00ff,d7      | d7: mask as expected by _tex_at_xy
	move.l  TMAP(a6),a0       | a0: texture map
	move.l  HMAP(a6),a1       | a1: height map
	move.l  TLINE(a6),a2      | a2: texture line buffer
	move.l  HLINE(a6),a3      | a3: height line buffer
	move.l  TMAP(a6),a5       | a5: texture map
	move.l  MUL8x8(a6),a6     | a6: mul8x8tab
	bsr     _voxel_samplemaps
	move.l  (sp)+,a6

	move.l  LOD(a6),d7        | d7: level of detail
	move.l  #160,d3
	lsr.l   d7,d3             | d3: number of values in buffer
	subq.l  #1,d7             | d7: loop count
	blt     1f
2:	move.l  d3,d0
	move.l  TLINE(a6),a0
	bsr     _clinear2x_clamped
	move.l  d3,d0
	move.l  HLINE(a6),a0
	bsr     _clinear2x_clamped
	add.l   d3,d3             | buffer size doubles in each iteration
	dbf     d7,2b
1:

	|
	| Convert height values to screen y values
	|

	move.l  HLINE(a6),a0      | a0: source buffer
	move.l  YLINE(a6),a1      | a1: destination buffer
	move.l  H2Y(a6),a2
	move.l  ZINDEX(a6),d0     | d0: current z-line index
	lsl.l   #8,d0
	add.l   d0,a2             | a2: 256-byte look-up table
	bsr     _mapb2b_160

	|
	| Calculate gradients for column interpolation
	|

	tst.l   HMASK(a6)
	beq     1f                | skip if columns are not filled
	move.l  a6,-(sp)
	move.l  YLINE(a6),a0      | a0: y buffer of current z level
	move.l  PYLINE(a6),a1     | a1: y buffer of previous z level
	move.l  TLINE(a6),a2      | a2: color buffer of current z level
	move.l  PTLINE(a6),a3     | a3: color buffer of previous z level
	move.l  GLINE(a6),a4      | a4: buffer with gradient values
	move.l  DIV8x8(a6),a5     | a5: div8x8tab
	bsr     _voxel_calc_gradients
	move.l  (sp)+,a6
1:

	|
	| Render z line into chunky buffer
	|

	move.l  a6,-(sp)
	move.l  HMASK(a6),d3      | d3: mask to limit max column height
	move.l  YLINE(a6),a0      | a0: buffer with y values
	move.l  TLINE(a6),a1      | a1: buffer with texture values
	move.l  YCLIP(a6),a2      | a2: buffer with y-max values
	move.l  SCREEN(a6),a3     | a3: screen
	move.l  GLINE(a6),a4      | a4: buffer with gradient values
	bsr     _voxel_renderline
	move.l  (sp)+,a6

	movem.l (sp)+,d5-d6/a4-a6 | restore forth registers
	POPD
	NEXT

DENTRIES voxelzline


| ( voxelctx -- ) fill left and right sight-line buffers
CODE_XT walksightlines
	move.l d4,a0              | a0: voxel context
	move.l LDIR(a0),d1
	move.l RDIR(a0),d2
	move.l LSIGHT(a0),a1
	move.l RSIGHT(a0),a2
	move.l VIEWPOS(a0),d3     | d3: lsight position
	move.l VIEWPOS(a0),d4     | d4: rsight position
	move.l ZSTEPS(a0),d7
	subq.l #1,d7
1:
	| advance left sight line position
	add.w  d1,d3 ;  swap d1 ;  swap d3
	add.w  d1,d3 ;  swap d1 ;  swap d3

	| advance right sight line position
	add.w  d2,d4 ;  swap d2 ;  swap d4
	add.w  d2,d4 ;  swap d2 ;  swap d4

	move.l d3,(a1)+
	move.l d4,(a2)+

	dbf    d7,1b
	POPD
	NEXT

DENTRIES walksightlines

| vim: set ts=16:
