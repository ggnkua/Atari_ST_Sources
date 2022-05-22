*
* TRIG.S
*
*	@sin
*	 Returns the sine of an angle.
* In	 d0.w=angle in degrees with six decimal bits (0-23039)
* Out	 d1.w=sin(angle), a word with one sign bit and 15 decimal bits.
*	 (destroys d0/a0)
*
*	@cos
*	 Returns the cosine of an angle.
* In	 d0.w=angle in degrees with six decimal bits (0-23039)
* Out	 d1.w=sin(angle), a word with one sign bit and 15 decimal bits.
*	 (destroys d0/a0)
*


@cos	move.l	#sintab,a0
	lsr	#4,d0
	cmp	#270*4,d0
	blt	.add90
	sub	#270*4,d0
	bra	.done
.add90	add	#90*4,d0
.done	lsl	#1,d0
	move	0(a0,d0.w),d1
	rts


@sin	move.l	#sintab,a0
	lsr	#4,d0
	lsl	#1,d0
	move	0(a0,d0.w),d1
	rts


sintab	incbin	sintab.inl		A 1440 entries large sine table


