.MACRO TEX_AT_XY
	| a0: texture base, adjusted for signed index access
	| d5: position in yy.vv.xx.uu format
	| a6: 8x8 bit multiplication table
	| d7: 0xff00ff mask to select position components
	|
	| -> d4: value
	|
	| modifies d1 d2 d3 d4
	|
	| When addressing (a0,d1.w), d1 is taken as signed value whereas
	| the given position in d1.w is unsigned. Adjust texture base address
	| and y position to compensate.

	| combine 8-bit x and y values to 16-bit texture offset
	move.l  d5,d2          | d2:    y0   v    x0   u
	rol.w   #8,d2          | d2:    y0   v    u    x0
	and.w   d7,d2          | d2:    y0   v    _    x0
	move.l  d5,d1          | d1:    y0   v    x0   u
	swap    d1             | d1:    x0   u    y0   v
	sub.w   #0x8000,d1     | compensate for signed indexed addressing
	move.b  d2,d1          | d1.w:  y0   x0

	| fetch four texture values t00, t10, t11, t01
	move.b (a0,d1.w),d3    | d3:    ?    ?    ?    t00
	lsl.w  #8,d3           | d3:    ?    ?    t00  _
	add.b  #1,d1           | d1.w:  y0   x1
	move.b (a0,d1.w),d3    | d3:    ?    ?    t00  t10
	swap   d3              | d3:    t00  t10  ?    ?
	add.w  #0x100,d1       | d1.w:  y1   x1
	move.b (a0,d1.w),d3    | d3:    t00  t10  ?    t11
	lsl.w  #8,d3           | d3:    t00  t10  t11  ?
	sub.b  #1,d1           | d1.w:  y1   x0
	move.b (a0,d1.w),d3    | d3:    t00  t10  t11  t01
	rol.w  #8,d3           | d3:    t00  t10  t01  t11

	move.w d5,d1           | d1.b:                 u
	lsl.w  #8,d1           | d1.w:            u    _
	move.b d3,d1           | d1.w:            u    t11
	move.w (a6,d1.w*2),d2  | d2.w:              u*t11
	swap   d2              | d2.w:    u*t11   ?    ?
	swap   d3              | d3.l:  t01  t11  t00  t10
	move.b d3,d1
	move.w (a6,d1.w*2),d2  | d2.l     u*t11     u*t10
	swap   d2              | d2.l     u*t10     u*t11

	not.w  d1              | d1.w            (1-u) ?
	ror.l  #8,d3           | d3.l:  t10  t01  t11  t00
	move.b d3,d1           | d1.w            (1-u) t00
	move.w (a6,d1.w*2),d4  | d4.w            (1-u)*t00
	swap   d4              | d4.l  (1-u)*t100 ?    ?
	swap   d3              | d3.l   t11  t00  t10  t01
	move.b d3,d1           | d1.w            (1-u) t01
	move.w (a6,d1.w*2),d4  | d4.w  (1-u)*t100 (1-u)*t01

	add.l d2,d4            | d4.l: (1-u)*t00+u*t10  (1-u)*t01+u*t11
	lsr.l #8,d4

	move.l d5,d1
	ror.l  #8,d1           | d1.w:  v   ?
	move.b d4,d1           | d1.w:  v   (1-u)*t01+u*t11
	move.w (a6,d1.w*2),d2  | d2.w:     v*(1-u)*t01+u*t11
	swap   d4              | d4.l: (1-u)*t01+u*t11  (1-u)*t00+u*t10
	not.w  d1              | d1.w:  (1-v)   ?
	move.b d4,d1           | d1.w:  (1-v)  (1-u)*t00+u*t10
	move.w (a6,d1.w*2),d4  | d4.w   (1-v)*(1-u)*t00+u*t10

	add.w d2,d4
	lsr.w #8,d4
	ext.l d4
.ENDM

_tex_at_xy:
	TEX_AT_XY
	rts


| ( position texture mul8x8tab -- value )
CODE_XT tex_at_xy
	move.l   d4,a1 ; POPD     | a1: mul8x8tab
	move.l   d4,a0 ; POPD     | a0: texture
	move.l   d4,d0            | d0: position
	move.l   #0xff00ff,d7     | d7: mask to select position components
	lea      0x8000(a0),a0
	movem.l  d5/a6,-(sp)
	move.l   d0,d5
	move.l   a1,a6            | a6: mul8x8tab
	lea      0x10000(a6),a6   | adjust for signed indexed access
	bsr      _tex_at_xy
	movem.l  (sp)+,d5/a6
	NEXT

DENTRY "tex@xy" tex_at_xy

| vim: set ts=16:
