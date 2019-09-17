* Tests two AES rectangles to see if they are identical
* ENTRY     a0 contains address of array of one rectangle
*           a1 contains address of array of second rectangle
*           (can use the macro rc_equal to load a0 and a1)
* EXIT      If the rectangles were identical d0.w = 0
*           If the rectangles are not identical d0.w = -1
*           Neither rectangle is changed

rc_equal	macro	rectangle 1,rectangle 2
	lea	\1,a0
	lea	\2,a1
	bsr	rc_equ.sr
	endm

* example of array of 4 words describing AES rectangle
clp_x	ds.w	1	* clip rectangle
clp_y	ds.w	1	*
clp_w	ds.w	1	*
clp_h	ds.w	1	*

rc_equ.sr	move.l	(a0)+,d0	get xy array1
	sub.l	(a1)+,d0	compare with xy array2
	bne	rc_not_equ
	move.l	(a0),d0	get wh array1
	sub.l	(a1),d0	compare with wh array2
	bne	rc_not_equ
	rts		d0 is 0
rc_not_equ	move.w    #-1,d0           flag not equal
	rts
