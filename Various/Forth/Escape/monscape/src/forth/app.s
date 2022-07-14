
| xorshift128
CODE_XT random
	lea     _xorshift128_state,a0
	movem.l (a0),d0-d3
	move.l  d0, 4(a0)
	move.l  d1, 8(a0)
	move.l  d2,12(a0)
	move.l  d3,  (a0)
	move.l  d3,d1
	moveq.l #11,d2
	lsl.l   d2,d1
	eor.l   d1,d3
	move.l  d3,d1
	moveq.l #9,d2
	lsr.l   d2,d1
	eor.l   d1,d3
	move.l  d0,d1
	moveq.l #19,d2
	lsr.l   d2,d1
	eor.l   d1,d0
	eor.l   d3,d0
	move.l  d0,(a0)
	PUSHD   d0
	NEXT

_xorshift128_state: dc.l 0x1234abcd,0x2345bcde,0x3456cdef,0x4567defa

DENTRIES random


|
| Sanitize and compute line parameters. Lines are drawn from left to right.
|
| a0: screen base address -> address of first pixel
| a1:                     -> line step in bytes
| d0: x1                  -> bit mask of first pixel
| d1: y1                  -> changed
| d2: x2                  -> abs(dx)
| d3: y2                  -> abs(dy)
|
_prepare_line:
	cmp.l   d0,d2           | ensure that p1.x <= p2.x
	bgt     1f
	exg     d0,d2
	exg     d1,d3
1:
	move.l  #1280/8,d7      | line length in bytes
	muls.l  d1,d7           | add y offset to start addr
	adda.l  d7,a0

	sub.l   d0,d2           | d2: dx

	move.l  #1280/8,d7      | d7: line step
	sub.l   d1,d3           | d3: dy
	bge     1f
	neg.l   d7
	neg.l   d3              | d3: abs(dy)
1:
	move.l  d0,d1
	lsr.l   #4,d0
	lea     (a0,d0.l*2),a0  | add x offset to start addr

	not.l   d1
	andi.l  #0xf,d1
	moveq.l #1,d0
	lsl.l   d1,d0           | d0: bit mask of current pixel

	move.l  d7,a1           | a1: line step in bytes
	rts

.macro LINE BITOP CMPOP
	cmp.l   d2,d3
	bgt     3f              | dy > dx -> steep line

	| flat line

	move.l  d2,d7           | d7: loop counter
	move.l  d2,d1
	lsr.l   #1,d1           | d1: running value

2:	| flat x loop

	\BITOP  d0,(a0)         | set pixel
	ror.w   #1,d0           | advance pixel bit mask and address
	\CMPOP  1f
	addq.l  #2,a0
1:
	sub.l   d3,d1           | decrease running value by dy
	dblt    d7,2b
	adda.l  a1,a0           | y step if running value becomes negative
	add.l   d2,d1           | replenish running value by dx
	tst.w   d7
	dblt    d7,2b           | continue flat x loop
	rts

3:	| steep line

	move.l  d3,d7           | d7: loop counter
	move.l  d3,d1
	lsr.l   #1,d1           | d1: running value

2:	| steep y loop

	\BITOP  d0,(a0)         | set pixel
	adda.l  a1,a0           | advance y

	sub.l   d2,d1           | decrease running value by dx
	dblt    d7,2b
	add.l   d3,d1           | replenish running value by dy
	ror.w   #1,d0           | advance pixel bit mask and address
	\CMPOP  1f
	addq.l  #2,a0
1:
	tst.w   d7
	dblt    d7,2b           | continue steep y loop
	rts
.endm

_blackline:
	bsr     _prepare_line
	LINE    or.w bge

_whiteline:
	bsr     _prepare_line
	not.w   d0
	LINE    and.w blt

.macro POP_LINE_ARGS_FROM_STACK
	move.l d4,d3 ; POPD
	move.l d4,d2 ; POPD
	move.l d4,d1 ; POPD
	move.l d4,d0 ; POPD
	move.l d4,a0 ; POPD
.endm

| ( base x1 y1 x2 y2 )
CODE_XT blackline
	POP_LINE_ARGS_FROM_STACK
	bsr    _blackline
	NEXT


| ( base x1 y1 x2 y2 )
CODE_XT whiteline
	POP_LINE_ARGS_FROM_STACK
	bsr    _whiteline
	NEXT

DENTRIES blackline whiteline


| ( addr count value )
CODE_XT fillcells
	move.l  d4,d0 ; POPD   | d0: value
	move.l  d4,d7 ; POPD   | d7: count
	move.l  d4,a2 ; POPD   | a2: start addr
	lea (a2,d7.l*4),a2     | a2: end addr

	| clear long-wise to 32-longs boundary

	move.w  d7,d1
	andi.w  #0x1f,d1
	subq.w  #1,d1          | d1: loop counter
	blt     1f
2:	move.l  d0,-(a2)
	dbf     d1,2b
1:
	| clear blocks of 32 long words

	lsr.w   #5,d7
	subq.w  #1,d7          | d7: loop counter
	bge     1f
	NEXT
1:
	move.l  d5,a3          | save data stack position

	move.l  d0,d1
	move.l  d0,d2
	move.l  d0,d3
	move.l  d0,d4
	move.l  d0,d5
	move.l  d0,a0
	move.l  d0,a1
1:
	.rep 4
	movem.l d0-d5/a0-a1,-(a2)
	.endr
	dbf     d7,1b

	move.l  a3,d5          | restore data stack position
	NEXT

DENTRIES fillcells


| ( chunky mono height dithertab -- ) convert 160x120 chunky buffer to 1280x960 monochrome screen
CODE_XT c2m8x8
	move.l  d4,a2 ; POPD    | a2: dither table (8*256 bytes, 8 lines, 256 shade values per line)
	move.l  d4,d7 ; POPD    | d7: height
	move.l  d4,a1 ; POPD    | a1: dst screen
	move.l  d4,a0 ; POPD    | a0: src chunky buffer

	movem.l  d0-a6,-(sp)

	moveq.l  #0,d0
	move.l   #0xff00ff,d2
	moveq.l  #0,d4          | d4: tracks offset to dither-table line

	subq.w   #1,d7          | d7: y-loop counter
3:
	move.w   #8-1,d6        | d6: dither line counter 0..7
2:
	lea      (a2,d4.l),a3   | a3: dither table line
	move.l   a0,a4

	move.w   #(160/16)-1,d5
1:
	.REP 4
	move.l   (a4)+,d0        | d0: c3.c2.c1.c0
	move.l   d0,d1           | d1: c3.c2.c1.c0
	ror.l    #8,d0           | d0: c0.c3.c2.c1
	and.l    d2,d1           | d1: __.c2.__.c0
	and.l    d2,d0           | d0: __.c3.__.c1
	move.b   (a3,d1.w),d3    | d3: __.__.__.m0
	ror.l    #8,d3           | d3: m0.__.__.__
	move.b   (a3,d0.w),d3    | d3: m0.__.__.m1
	ror.l    #8,d3           | d3: m1.m0.__.__
	swap     d1              | d1: __.c0.__.c2
	move.b   (a3,d1.w),d3    | d3: m1.m0.__.m2
	swap     d0              | d0: __.c1.__.c3
	ror.l    #8,d3           | d3: m2.m1.m0.__
	move.b   (a3,d0.w),d3    | d3: m2.m1.m0.m3
	ror.l    #8,d3           | d3: m3.m2.m1.m0
	move.l   d3,(a1)+
	.ENDR

	dbf      d5,1b

	add.l    #0x100,d4       | advance dither-table line
	and.l    #0x700,d4
	dbf      d6,2b

	lea      160(a0),a0
	dbf      d7,3b

	movem.l  (sp)+,d0-a6
	NEXT

DENTRIES c2m8x8

|
| Interlaced c2m conversion, process only one fourth of the screen.
|
| The phase value (0..3) defines which part is converted.
|

| ( phase chunky mono height dithertab -- )
CODE_XT c2m8x8i4
	move.l  d4,a2 ; POPD    | a2: dither table (8*256 bytes, 8 lines, 256 shade values per line)
	move.l  d4,d7 ; POPD    | d7: screen height
	move.l  d4,a1 ; POPD    | a1: dst screen
	move.l  d4,a0 ; POPD    | a0: src chunky buffer
	move.l  d4,d1 ; POPD    | d1: phase

	movem.l d0-a6,-(sp)

	move.l  #0xff00ff,d2
	moveq.l #0,d4          | d4: tracks offset to dither-table line

	subq.w  #1,d7          | d7: y-loop counter
3:
	move.w  #8-1,d6        | d6: dither line counter 0..7
2:
	lea     (a0,d1.l*4),a4
	lea     (a1,d1.l*4),a6
	lea     (a2,d4.l),a3    | a3: dither table line

	move.l  d1,-(sp)        | save phase value
	move.w  #5-1,d5
1:
	.REP 2
	move.l  (a4),d0         | d0: c3.c2.c1.c0
	lea     16(a4),a4       | skip three longs
	move.l  d0,d1           | d1: c3.c2.c1.c0
	ror.l   #8,d0           | d0: c0.c3.c2.c1
	and.l   d2,d1           | d1: __.c2.__.c0
	and.l   d2,d0           | d0: __.c3.__.c1
	move.b  (a3,d1.w),d3    | d3: __.__.__.m0
	ror.l   #8,d3           | d3: m0.__.__.__
	move.b  (a3,d0.w),d3    | d3: m0.__.__.m1
	ror.l   #8,d3           | d3: m1.m0.__.__
	swap    d1              | d1: __.c0.__.c2
	move.b  (a3,d1.w),d3    | d3: m1.m0.__.m2
	swap    d0              | d0: __.c1.__.c3
	ror.l   #8,d3           | d3: m2.m1.m0.__
	move.b  (a3,d0.w),d3    | d3: m2.m1.m0.m3
	ror.l   #8,d3           | d3: m3.m2.m1.m0
	move.l  d3,(a6)
	lea     16(a6),a6       | skip three longs
	.ENDR

	dbf     d5,1b

	move.l  (sp)+,d1        | restore phase value
	add.l   #0x100,d4       | advance dither-table line
	and.l   #0x700,d4
	lea     160(a1),a1      | advance destination line
	move.l 1f(pc,d1.l*4),d1 | next phase on each y step
	dbf     d6,2b

	lea     160(a0),a0      | advance source line
	dbf     d7,3b

	movem.l (sp)+,d0-a6
	NEXT

1:	dc.l    2,3,1,0         | interlace phase transitions

DENTRIES c2m8x8i4


CODE_XT fromcacr
	movec cacr,d0
	PUSHD d0
	NEXT

CODE_XT tocacr
	movec d4,cacr
	POPD
	NEXT

DENTRY "cacr@" fromcacr
DENTRY "cacr!" tocacr


|
| Utility for generating differently shaded dithering bit patterns
|
| noisetab has 8 cells, the resulting bitmask has eight corresponding bits
|

| ( threshold noisetab -- bitmask )
CODE_XT bitpattern
	move.l  d4,a0 ; POPD    | a0: noise table
	move.l  d4,d0           | d0: threshold
	moveq.l #0,d4           | d4: hold result
	moveq.l #8-1,d7         | d7: loop count
2:	lsl.l   #1,d4
	move.l  (a0)+,d1        | d1: noise value
	cmp.l   d0,d1
	blt     1f
	or.l    #1,d4
1:	dbf     d7,2b
	NEXT

DENTRIES bitpattern


|
| Perform one of (0..127) fade-out phases
|
| Each entry of the fade table contains a 32-bit mask with one different bit set.
|

| ( phase dst fadetab -- )
CODE_XT fade2black
	move.l  d4,a0 ; POPD    | a0: fade table
	move.l  d4,a1 ; POPD    | a1: screen
	move.l  d4,d7 ; POPD    | d7: phase

.macro _fade2black_ADVANCE_Y            | used for each line
	moveq.l #27,d0
	add.l   d0,d7           | advance phase value
	lea     160(a1),a1      | next destination line
.endm
	movem.l d0-a6,-(sp)

	lea     0,a6            | a6: used to track odd/even line
	lsr.w   #1,d7           | phase bit for horizontal interlace
	bcs.s   1f
	lea     1,a6
1:
	move.w  #960/2,d6       | d6: y-loop counter

	lsr.w   #1,d7           | phase bit for vertical interlace
	bcs.s   2f              | skip first line if bit set

1:	| y loop

	move.w  d6,d0
	exg     d6,a6           | apply horizontal interlace
	lea     (a1,d6.w*4),a3

	move.w  d7,d4           | fetch masks from fade table
	lsr.w   #4,d0           | skew table access by y-loop count
	add.w   d0,d4
	and.w   #0x1f,d4
	lea     (a0,d4.w*4),a2
	movem.l (a2),d0-d5

	.IRP    reg  d5 d4 d0 d1 d5 d1 d0 d5 d2 d3 d1 d2 d0 d4 d1 d3 d5 d4 d3 d2
	or.l    \reg,(a3)
	addq.l  #8,a3
	.ENDR

	eor.b   #1,d6           | toggle even/odd for horizontal interlace
	exg     d6,a6

	_fade2black_ADVANCE_Y
2:	_fade2black_ADVANCE_Y   | skip one interlaced line

	dbf     d6,1b

	movem.l (sp)+,d0-a6
	NEXT


DENTRIES fade2black

| vim: set ts=16:
