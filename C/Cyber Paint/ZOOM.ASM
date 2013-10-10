	;	:ts = 10		make z editor give me 10 for tabstop

	dseg
	public _zoomtab		; lookup table for zoom in another file 
	public	_got_blitter

	cseg
	;public _zoomblit
	public zoom_return

	;zoom_line(saddr, daddr, zoomx, zoomy);
	public _zoom_line
_zoom_line
	movem.l	a2/d2/d3,-(sp)	; sorry got to trash some registers
	move.l	12+4(sp),a0	; source in a0
	move.l	12+8(sp),a1	; dest in a1
	move.w	12+12(sp),d0	; x in d0
	move.w	12+14(sp),d1	; y in d1
	mulu	#160,d1		; convert y to line offset
	add.l	d1,a0
	and.w	#$fff0,d0	; just word-alligned source please !
	lsr.w	#1,d0		; convert it from pixels to bytes
	add.w	d0,a0		; a0 now has first word of dest to zoom!
	move.l	#_zoomtab,a2    ; keep pointer to lookup table in register
	move.w	#4,d3		; word counter
zlword
	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+0+0+0(a1)
	swap	d1
	move.w	d1,0*160+0+0+8(a1)

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+0+16+0(a1)
	swap	d1
	move.w	d1,0*160+0+16+8(a1)

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+2+0+0(a1)
	swap	d1
	move.w	d1,0*160+2+0+8(a1)

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+2+16+0(a1)
	swap	d1
	move.w	d1,0*160+2+16+8(a1)

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+4+0+0(a1)
	swap	d1
	move.w	d1,0*160+4+0+8(a1)

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+4+16+0(a1)
	swap	d1
	move.w	d1,0*160+4+16+8(a1)

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+6+0+0(a1)
	swap	d1
	move.w	d1,0*160+6+0+8(a1)

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a2,d0.w),d1	; preswapped long-word in d1
	move.w	d1,0*160+6+16+0(a1)
	swap	d1
	move.w	d1,0*160+6+16+8(a1)

	adda.w	#32,a1		
	dbra	d3,zlword

	movem.l	(sp)+,d2/d3/a2
	rts

	public _zoom_lines
_zoom_lines
	movem.l	a2/d2/d3,-(sp)	; sorry got to trash some registers
	move.w	12+16(sp),d2	; #lines-1 in d2
	sub.w	#1,d2
	beq	zoom_return
	bra zoom

	;zoom(source, dest, x, y)
	;	routine to do a 4x blow up of the source onto the dest.
	;	The dest is assumed to be 32K.  The source is also 32K
	;	However I zoom starting at the position x,y ...

	public _zoom
_zoom
	movem.l	a2/d2/d3,-(sp)	; sorry got to trash some registers
	move.w	#49,d2		; dbra counter = YMAX/2 - 1
zoom
	move.l	12+4(sp),a0	; source in a0
	move.l	12+8(sp),a1	; dest in a1
	move.w	12+12(sp),d0	; x in d0
	move.w	12+14(sp),d1	; y in d1
	mulu	#160,d1		; convert y to line offset
	add.l	d1,a0
	and.w	#$fff0,d0	; just word-alligned source please !
	lsr.w	#1,d0		; convert it from pixels to bytes
	add.w	d0,a0		; a0 now has first word of dest to zoom!
	;tst.w	_got_blitter
	;beq		zoom68000

	;jmp		_zoomblit
zoom68000	; sigh - got to do it with the processor
	move.l	#_zoomtab,a2    ; keep pointer to lookup table in register
zline
	move.w	#4,d3		; word counter
zword
	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
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

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
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

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
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

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
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

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
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

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
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

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
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

	clr.w	d0
	move.b	(a0)+,d0
	add.w	d0,d0
	add.w	d0,d0
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

zoom_return
	movem.l	(sp)+,d2/d3/a2
	rts
