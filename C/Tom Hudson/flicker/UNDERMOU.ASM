
; :ts=10

	public _cscreen
	public _mouse_x
	public _mouse_y

	;save_m()	save underneath mouse
	public _save_m
_save_m	
	move.w	#15,d1	;line count
	move.b	d1,mouse_saved	; set flag that says it's saved
	move.l	#undermouse,a1	; point a1 to save buffer
	move.w	_mouse_y,d0	; get y coordinate
	sub.w	#8,d0	; adjust for hot spot
	bge	yposi	; start clipping ... at least it's positive
	cmp.w	#-16,d0	; is it completely above screen?
	bls	clipout
	add.w	d0,d1	; y negative a little, makes less than 16 lines...
	move.w	#0,d0	; and after clipping start at 0
	bra	yaddr	; and go calculate
yposi	cmp.w	#200,d0	; totally below screen?
	bge	clipout
	move.w	d0,d2
	sub.w	#200-16,d2  ; # of lines off bottom of screen in d2
	bls	yaddr	; if negative or zero don't have to clip
	sub.w	d2,d1	; ready to draw a few less lines
yaddr	move.w	d1,lines	; save line count for restore
	move.l	_cscreen,a0
	lsl.w	#5,d0
	adda.w	d0,a0
	lsl.w	#2,d0	
	adda.w	d0,a0	; a0 = cscreen + 160*y
	move.w	_mouse_x,d0	; get x coordinate
	sub.w	#8,d0	; adjust for hot spot
	bge	xposi	; x is positive at least
	cmp.w	#-16,d0	; if negative is it offscreen entirely?
	bls	clipout	
	bra 	leftedge 
xposi	cmp.w	#320,d0	; is it offscreen to right?
	bge	clipout
	cmp.w	#320-16,d0 ; partially right clipped?
	bls	add_xadd
	bra	rightedge	
add_xadd	and.w	#$fff0,d0	
	lsr.w	#1,d0
	adda.w	d0,a0	; point a0 to the right word even ... 
	move.l	a0,firstword	; save the address for restore
	clr.b	one_word		; hey, we're doing two words

s2loop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	adda.w	#160-16,a0
	dbra	d1,s2loop
	rts

rightedge adda.w	#160-8,a0 ; we're in the last word of this line
leftedge	move.b	d1,one_word	; just doing one word
	move.l	a0,firstword	; save the address for restore
s1loop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	adda.w	#160-8,a0
	dbra	d1,s1loop
	rts

clipout	clr.b	mouse_saved
	rts

	;restore_m() restore underneath mouse
	public _restore_m
_restore_m
	tst.b	mouse_saved
	beq	restored
	move.l	#undermouse,a0
	move.l	firstword,a1
	move.w	lines,d1
	tst.b	one_word
	beq	r2loop
r1loop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	adda.w	#160-8,a1
	dbra	d1,r1loop
	bra	restored
r2loop	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	adda.w	#160-16,a1
	dbra	d1,r2loop
restored	clr.b	mouse_saved
	rts





	bss	mouse_saved,1	; flag if mouse buffer saved
	bss	one_word,1	; just one word/line saved?
	bss	lines,2		; # of lines-1 saved
	bss	firstword,4	; screen address of first word saved
	bss	undermouse,4*4*16	; buffer to save under cursor
