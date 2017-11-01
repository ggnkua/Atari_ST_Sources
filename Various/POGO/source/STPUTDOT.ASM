
	dseg
	public _cscreen
	public _bitmasks
	public _in_graphics

	cseg

	;getdot(x, y)
	;	return color in cscreen at x,y
	public _getdot
	public getdot
_getdot	move.w	4(sp),d0
	move.w	6(sp),d1
getdot	move.l	_cscreen,a0 
	lsl.w	#5,d1
	adda.w	d1,a0
	add.w	d1,d1
	add.w	d1,d1
	adda.w	d1,a0	;effectively multiply y coordinate by 160 = 128+32
	move.w	d0,d1	;copy of x coordinate in d1
	and.w	#$fff0,d1	
	lsr.w	#1,d1
	adda	d1,a0	; point a0 to the right word even ... 
	move.l	#_bitmasks,a1
	and.w	#$000f,d0	; find place in word
	add.w	d0,d0	;convert to word index
	move.w	0(a1,d0.w),d1	;  now have mask in d1
	clr.w	d0	; start out color 0
	move.w	(a0)+,d2
	and.w	d1,d2
	beq	not1
	or.w	#1,d0
not1	move.w	(a0)+,d2
	and.w	d1,d2
	beq	not2
	or.w	#2,d0
not2	move.w	(a0)+,d2
	and.w	d1,d2
	beq	not4
	or.w	#4,d0
not4	move.w	(a0)+,d2
	and.w	d1,d2
	beq	not8
	or.w	#8,d0
not8	rts


	;	putdot(x, y, color)
	;		fast one dot on screen
	public _putdot
_putdot
	move.w	6(sp),d0	; get y coordinate
	bmi		putdotz
	cmp.w	#200,d0
	bge		putdotz
	move.l	_cscreen,a0
	lsl.w	#5,d0
	adda.w	d0,a0
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a0	; effectively multiply y coordinate by 160 = 128+32
	move.w	4(sp),d0	; get x coordinate
	bmi		putdotz
	cmp.w	#320,d0
	bge		putdotz
	move.w	d0,d1
	and.w	#$fff0,d1	
	lsr.w	#1,d1
	adda	d1,a0	; point a0 to the right word even ... 
	move.l	#_bitmasks,a1
	and.w	#$000f,d0	; find place in word
	add.w	d0,d0	;convert to word index
	move.w	0(a1,d0.w),d0	;  now have mask in word
	move.w	8(sp),d1	; get color parameter
	and.w	#15,d1		; make sure it's a legal value
	add.w	d1,d1
	add.w	d1,d1		;convert to pointer value
	move.l	#dots,a1
	move.l	0(a1,d1.w),a1	; get rest of routine for this color
	jmp		(a1)
putdotz	rts


dot0:	
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	rts

dot1: 
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	rts

dot2: 
	or.w	d0,2(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,4(a0)
	and.w	d0,6(a0)
	rts

dot3:
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	rts

dot4:
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	addq	#4,a0
	and.w	d0,(a0)
	rts

dot5:
	or.w	d0,(a0)
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,6(a0)
	rts

dot6:
	or.w	d0,2(a0)
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,6(a0)
	rts

dot7:
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	rts

dot8:	
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)
	rts

dot9: 
	or.w	d0,(a0)+
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	rts

dota: 
	or.w	d0,2(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	and.w	d0,4(a0)
	rts

dotb:
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,2(a0)
	not.w	d0
	and.w	d0,(a0)
	rts

dotc:
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts

dotd:
	or.w	d0,(a0)
	or.w	d0,4(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,2(a0)
	rts

dote:
	or.w	d0,2(a0)
	or.w	d0,4(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,(a0)
	rts

dotf:
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)
	rts


	dseg
dots dc.l 	dot0,dot1,dot2,dot3,dot4,dot5,dot6,dot7
	dc.l	dot8,dot9,dota,dotb,dotc,dotd,dote,dotf


