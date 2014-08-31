	;	:ts = 10		make z editor give me 10 for tabstop

	public _zoomtab		; lookup table for zoom in another file 

	;zoom(source, dest, x, y)
	;	routine to do a 4x blow up of the source onto the dest.
	;	The dest is assumed to be 32K.  The source is also 32K
	;	However I zoom starting at the position x,y ...

	public _zoom
_zoom
	move.l	4(sp),a0	; source in a0
	move.l	8(sp),a1	; dest in a1
	move.w	12(sp),d0	; x in d0
	move.w	14(sp),d1	; y in d1
	movem.l	a2/d2/d3,-(sp)	; sorry got to trash some registers
	mulu	#160,d1		; convert y to line offset
	add.l	d1,a0
	and.w	#$fff0,d0	; just word-alligned source please !
	lsr.w	#1,d0		; convert it from pixels to bytes
	add.w	d0,a0		; a0 now has first word of dest to zoom!
	move.l	#_zoomtab,a2    ; keep pointer to lookup table in register
	move.w	#49,d2		; dbra counter = YMAX/2 - 1
zline
	move.w	#4,d3		; word counter
zword
	move.w	#0,d0
	move.b	(a0)+,d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+0+0+0(a1)
	move.w	d1,1*160+0+0+0(a1)
	move.w	d1,2*160+0+0+0(a1)
	move.w	d1,3*160+0+0+0(a1)
	swap	d1
	move.w	d1,0*160+0+0+8(a1)
	move.w	d1,1*160+0+0+8(a1)
	move.w	d1,2*160+0+0+8(a1)
	move.w	d1,3*160+0+0+8(a1)

	move.w	#0,d0
	move.b	(a0)+,d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+0+16+0(a1)
	move.w	d1,1*160+0+16+0(a1)
	move.w	d1,2*160+0+16+0(a1)
	move.w	d1,3*160+0+16+0(a1)
	swap	d1
	move.w	d1,0*160+0+16+8(a1)
	move.w	d1,1*160+0+16+8(a1)
	move.w	d1,2*160+0+16+8(a1)
	move.w	d1,3*160+0+16+8(a1)

	move.w	#0,d0
	move.b	(a0)+,d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+2+0+0(a1)
	move.w	d1,1*160+2+0+0(a1)
	move.w	d1,2*160+2+0+0(a1)
	move.w	d1,3*160+2+0+0(a1)
	swap	d1
	move.w	d1,0*160+2+0+8(a1)
	move.w	d1,1*160+2+0+8(a1)
	move.w	d1,2*160+2+0+8(a1)
	move.w	d1,3*160+2+0+8(a1)

	move.w	#0,d0
	move.b	(a0)+,d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+2+16+0(a1)
	move.w	d1,1*160+2+16+0(a1)
	move.w	d1,2*160+2+16+0(a1)
	move.w	d1,3*160+2+16+0(a1)
	swap	d1
	move.w	d1,0*160+2+16+8(a1)
	move.w	d1,1*160+2+16+8(a1)
	move.w	d1,2*160+2+16+8(a1)
	move.w	d1,3*160+2+16+8(a1)

	move.w	#0,d0
	move.b	(a0)+,d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+4+0+0(a1)
	move.w	d1,1*160+4+0+0(a1)
	move.w	d1,2*160+4+0+0(a1)
	move.w	d1,3*160+4+0+0(a1)
	swap	d1
	move.w	d1,0*160+4+0+8(a1)
	move.w	d1,1*160+4+0+8(a1)
	move.w	d1,2*160+4+0+8(a1)
	move.w	d1,3*160+4+0+8(a1)

	move.w	#0,d0
	move.b	(a0)+,d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+4+16+0(a1)
	move.w	d1,1*160+4+16+0(a1)
	move.w	d1,2*160+4+16+0(a1)
	move.w	d1,3*160+4+16+0(a1)
	swap	d1
	move.w	d1,0*160+4+16+8(a1)
	move.w	d1,1*160+4+16+8(a1)
	move.w	d1,2*160+4+16+8(a1)
	move.w	d1,3*160+4+16+8(a1)

	move.w	#0,d0
	move.b	(a0)+,d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+6+0+0(a1)
	move.w	d1,1*160+6+0+0(a1)
	move.w	d1,2*160+6+0+0(a1)
	move.w	d1,3*160+6+0+0(a1)
	swap	d1
	move.w	d1,0*160+6+0+8(a1)
	move.w	d1,1*160+6+0+8(a1)
	move.w	d1,2*160+6+0+8(a1)
	move.w	d1,3*160+6+0+8(a1)

	move.w	#0,d0
	move.b	(a0)+,d0
	lsl.w	#2,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+6+16+0(a1)
	move.w	d1,1*160+6+16+0(a1)
	move.w	d1,2*160+6+16+0(a1)
	move.w	d1,3*160+6+16+0(a1)
	swap	d1
	move.w	d1,0*160+6+16+8(a1)
	move.w	d1,1*160+6+16+8(a1)
	move.w	d1,2*160+6+16+8(a1)
	move.w	d1,3*160+6+16+8(a1)

	adda.w	#32,a1		
	dbra	d3,zword

	adda.w	#120,a0	; skip over to next line of source
	adda.w	#160*3,a1 ; skip 3 lines of dest
	dbra	d2,zline

	movem.l	(sp)+,d2/d3/a2
	rts
