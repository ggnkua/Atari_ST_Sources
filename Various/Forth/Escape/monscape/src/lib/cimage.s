|
| Stretch byte buffer by 2x using linear interpolation
|

| ( buffer nbytes -- ) stretch wrapping byte buffer by factor 2
CODE_XT clinear2x
	move.l d4,d0 ; POPD  | d0: number of bytes in buffer
	move.l d4,a0         | a0: buffer to stretch
	bsr    _clinear2x_wrapped
	POPD
	NEXT
_clinear2x_wrapped:
	movem.l d0-d2/a0-a1,-(sp)
	moveq   #0,d2
	move.b  (a0),d2            | d2: take first byte as avg init value
	bra.s   _clinear2x
_clinear2x_clamped:
	movem.l d0-d2/a0-a1,-(sp)
	moveq   #0,d2
	move.b  -1(a0,d0.l),d2     | d2: take last byte as avg init value
_clinear2x:
	move.l  a0,a1
	lea     (a0,d0.l*2),a1     | a1: destination pointer
	lea     (a0,d0.l),a0       | a0: source pointer
	lsr.l   #2,d0              | compensate .REP 4
	subq.l  #1,d0              | d0: loop count
	blt.s   2f
	moveq   #0,d1
1:
	.REP 4
	move.b  -(a0),d1
	add.w   d1,d2              | calculate avg of two neighbors
	lsr.w   #1,d2
	move.b  d2,-(a1)
	move.b  d1,-(a1)
	move.b  d1,d2
	.ENDR
	dbf     d0,1b
2:	movem.l (sp)+,d0-d2/a0-a1
	rts

DENTRIES clinear2x


|
| Stretch byte buffer by 2x using weighted sampled interpolation
|

| ( buffer nbytes -- )
CODE_XT csmooth2x
	move.l d4,d0 ; POPD  | d0: number of bytes in buffer
	move.l d4,a0         | a0: buffer to stretch
	bsr    _csmooth2x
	POPD
	NEXT
|
| The result is calculated using the sample value v1, v2, v3, and v4. Sample
| v1 is taken from the current source pointer, v2 is next of v1, v3 and v4
| follow. Initially v1 points to the last buffer element. Given that the buffer
| wraps, the initial values of v2, v3, and v4 come from the start of the buffer.
|
_csmooth2x:
	movem.l d0-d5/a0-a1,-(sp)
	moveq   #0,d2
	moveq   #0,d3
	moveq   #0,d4
	move.b   (a0),d2        | d2: v2
	move.b  1(a0),d3        | d3: v3
	move.b  2(a0),d4        | d4: v3

	move.l  a0,a1
	lea     (a0,d0.l*2),a1  | a1: destination pointer
	lea     (a0,d0.l),a0    | a0: source pointer
	subq.l  #1,d0           | d0: loop count
	blt.s   2f
1:	                        | d2: v2
	moveq   #0,d1
	move.b  -(a0),d1        | d1: v1

.MACRO ADD_D5	regs:vararg
	.IRP    reg \regs
	add.l   \reg,d5
	.ENDR
.ENDM
	moveq   #0,d5
	ADD_D5  d1   d2 d2 d2   d3 d3 d3 d3 d3 d3 d3 d3 d3 d3 d3   d4
	lsr.l   #4,d5
	move.b  d5,-(a1)

	moveq   #0,d5
	ADD_D5  d1   d2 d2 d2 d2 d2 d2 d2 d2 d2 d2 d2   d3 d3 d3   d4
	lsr.l   #4,d5
	move.b  d5,-(a1)

	move.l  d3,d4  | v3 -> v4
	move.l  d2,d3  | v2 -> v3
	move.l  d1,d2  | v1 -> v2

	dbf     d0,1b
2:
	movem.l (sp)+,d0-d5/a0-a1
	rts

DENTRIES csmooth2x


|
| Smoothen byte buffer by averaging neighboring bytes
|

| ( buffer nbytes -- )
CODE_XT csmooth
	move.l d4,d0 ; POPD  | d0: number of bytes in buffer
	move.l d4,a0         | a0: buffer to smoothen
	bsr.s  _csmooth
	POPD
	NEXT
_csmooth:
	movem.l d0-d6/a0,-(sp)
	moveq   #0,d2
	moveq   #0,d3
	moveq   #0,d4
	move.b   (a0),d2        | d2: v2
	move.b  1(a0),d3        | d3: v3
	move.b  2(a0),d4        | d3: v4

	move.l  d2,d5           | prepare sliding average value
	add.w   d3,d5
	add.w   d4,d5           | d5: sliding average

	lea     (a0,d0.l),a0    | a0: start at the end of the buffer

	subq.l  #1,d0           | d0: loop count
	blt.s   2f
1:
	moveq   #0,d1
	move.b  -(a0),d1        | d1: v1
	add.l   d1,d5           | d5: 4 * average of four cells

	move.w  d5,d6
	lsr.w   #2,d6
	move.b  d6,(a0)         | write back average of four cells

	sub.w   d4,d5           | remove v4 from sliding average

	move.b  d3,d4           | v3 -> v4
	move.b  d2,d3           | v2 -> v3
	move.b  d1,d2           | v1 -> v2

	dbf     d0,1b
2:	movem.l (sp)+,d0-d6/a0
	rts

DENTRIES csmooth


|
| Rotate square byte image counter-clock-wise by 90 degrees
|

| ( image asize isize ) rotate asize area of an image with isize
CODE_XT cimagerotl
	move.l  d4,d0 ; POPD   | d0: image size
	move.l  d4,d1 ; POPD   | d1: size of area to rotate
	move.l  d4,a0          | a0: image

	movem.l a4-a6,-(sp)
	bsr.s   _cimage_rotl
	movem.l (sp)+,a4-a6
	POPD
	NEXT

_cimage_rotl_done:
	rts

_cimage_rotl:
	                         | a0: image
	                         | d0: image size (line width)
	subq.l  #1,d1            | d1: distance to other corner
	move.l  d1,d3
	subq.l  #1,d3            | d3: loop count
	blt.s   _cimage_rotl_done

	move.l  a0,a1            | a1: pointer to upper left corner (ul)
	lea     (a0,d1.l),a2     | a2: pointer to upper right corner (ur)
	move.l  d0,d2
	mulu.l  d1,d2
	lea     (a0,d2.l),a3     | a3: pointer to lower left corner (ll)
	lea     (a3,d1.l),a4     | a4: pointer to lower right corner (lr)
1:
	move.b  (a1),d2          | d2: _  _  _  ul
	rol.l   #8,d2
	move.b  (a2),d2          | d2: _  _  ul ur
	rol.l   #8,d2
	move.b  (a3),d2          | d2: _  ul ur ll
	rol.l   #8,d2
	move.b  (a4),d2          | d2: ul ur ll lr
	move.b  d2,(a2)          | lower right -> upper right
	ror.l   #8,d2            | d2:    ul ur ll
	move.b  d2,(a4)          | lower left -> lower right
	ror.l   #8,d2            | d2:       ul ur
	move.b  d2,(a1)          | upper right -> upper left
	ror.l   #8,d2            | d2:          ul
	move.b  d2,(a3)          | upper left -> lower left

	addq.l  #1,a1
	add.l   d0,a2
	sub.l   d0,a3
	subq.l  #1,a4

	dbf     d3,1b

	lea     1(a0,d0.l),a0    | continue with next-inner rect
	subq.l  #1,d1
	bra.s   _cimage_rotl

DENTRIES cimagerotl


| ( buffer fromsize tosize -- ) splice small square image into larger one
CODE_XT csplice
	move.l d4,d1 ; POPD  | d1: designated image size
	move.l d4,d0 ; POPD  | d0: original image size
	move.l d4,a0         | a0: image

	move.l d0,d2
	mulu.w d1,d2
move.w d2,d7
	sub.w  d1,d2
	add.w  d0,d2
	lea    (a0,d2.w),a1  | a1: points after last pixel of spliced image

	move.l d0,d2
	mulu.w d2,d2
	lea    (a0,d2.w),a0  | a0: points after last pixel of original image

	move.l d0,d3
	subq.l #1,d3         | d3: count used as start for x and y loops

	move.w d3,d7         | d7: y-loop count
2:
	move.l a0,a2         | a2: source
	move.l a1,a3         | a3: destination

	move.w d3,d2         | d2: x-loop count
1:
	move.b  -(a2),-(a3)
	dbf     d2,1b

	sub.l   d0,a0
	sub.l   d1,a1
	dbf     d7,2b

	POPD
	NEXT

DENTRIES csplice


| ( buffer nbytes -- min max ) return min/max range of the values present in the buffer
CODE_XT cvrange
	move.l d4,d0 ; POPD  | d0: number of bytes
	move.l d4,a0 ; POPD  | a0: buffer
	moveq  #0,d1         | d1: current max value
	moveq  #0,d2
	move.b #0xff,d2      | d2: current min value
	moveq  #0,d3
	subq.l #1,d0
	blt.s  1f
2:
	move.b (a0)+,d3
	cmp.w  d1,d3
	ble    3f
	move.w d3,d1         | d1: updated max
3:
	cmp.w  d2,d3
	bge    3f
	move.w d3,d2         | d2: updated min
3:
	dbf    d0,2b
1:
	PUSHD  d2
	PUSHD  d1
	NEXT

DENTRIES cvrange


| ( buffer nbytes value -- ) add value to each element of the buffer )
CODE_XT cbufvplus
	move.l d4,d0 ; POPD  | d0: value to add
	move.l d4,d1 ; POPD  | d1: number of bytes
	move.l d4,a0         | a0: buffer
	subq.l #1,d1
	blt.s  1f
2:	moveq  #0,d2
	move.b (a0),d2
	add.l  d0,d2
	bge    3f
	moveq  #0,d2
3:	cmp.w  #0xff,d2
	ble    3f
	move.w #0xff,d2
3:	move.b d2,(a0)+
	dbf    d1,2b
1:	POPD
	NEXT

DENTRY "cbufv+" cbufvplus


| ( source buffer nbytes -- ) add the elements of two buffers, clamp result
CODE_XT cbufplus
	move.l d4,d0 ; POPD  | d0: number of bytes
	move.l d4,a1 ; POPD  | a1: destination buffer
	move.l d4,a0         | a0: source buffer
	moveq  #0,d2
	subq.l #1,d1
	blt.s  1f
2:
	move.b (a0)+,d2
	moveq  #0,d3
	move.b (a1),d3
	add.w  d2,d3
	cmp.w  #0xff,d3
	ble    3f
	move.w #0xff,d3
3:	move.b d3,(a1)+
	dbf    d1,2b
1:	POPD
	NEXT

DENTRY "cbuf+" cbufplus


| ( buffer nbytes value -- )
CODE_XT cbufvrshift
	move.l d4,d0 ; POPD  | d0: value to add
	move.l d4,d1 ; POPD  | d1: number of bytes
	move.l d4,a0         | a0: buffer
	subq.l #1,d1
	blt.s  1f
2:	move.b (a0),d2
	lsr.b  d0,d2
	move.b d2,(a0)+
	dbf    d1,2b
1:	POPD
	NEXT

DENTRIES cbufvrshift


| ( source mask buffer nbytes -- ) copy source to buffer while applying the mask
CODE_XT cbufmask
	move.l d4,d0 ; POPD  | d0: number of bytes
	move.l d4,a2 ; POPD  | a2: destination buffer
	move.l d4,a1 ; POPD  | a1: mask buffer
	move.l d4,a0         | a0: source buffer
	lsr.l  #2,d0
	subq.l #1,d0
3:
	move.l (a1),d2       | quickly walk over empty mask areas
	bne    2f
	addq.l #4,a0
	addq.l #4,a1
	addq.l #4,a2
	dbf    d0,3b
	POPD
	NEXT

2:	                     | handle 4 four bytes individually
	.REP 4
	move.b (a1)+,d2
	beq    1f
	move.b (a0),(a2)
1:	addq.l #1,a0
	addq.l #1,a2
	.ENDR

	dbf    d0,3b
	POPD
	NEXT

2:

DENTRIES cbufmask

| vim: set ts=16:
