; unbanked picture version.. made it! close call though!
; pic: 124x59 (y)
; buf: 160x100 = 160x50 (top) (y) + 160x50 (btm) (x)

get:	MACRO
	jclr	#0,X:<<$FFE9,*
	movep	X:<<$FFEB,\1
	ENDM

send:	MACRO
	jclr	#1,X:<<$FFE9,*
	movep	\1,X:<<$FFEB
	ENDM

		org	x:0
xoff:		ds	1
yoff:		ds	1
top_border:	ds	1
topl_border:	ds	1
btmu_border:	ds	1
btm_border:	ds	1
top_lines:	ds	1
btm_lines:	ds	1
picadr:		ds	1
left_border:	ds	1
mid_pixels:	ds	1
right_border:	ds	1
stride:		ds	1					; for pic! (w=124)
screenstride:	ds	1					; for screenbuffer! (w=160)
pal_offset:	ds	1
steps:		ds	160
ysteps:		ds	100
xbuf:		ds	8000
		ds	256					; 0 words (for fading)
pal:		ds	256
end_x_mem:

		org	y:0
pic:		ds	124*59
ybuf:		ds	8000
end_y_mem:
; just enuff mem left.. ayee!

	org	p:0
	jmp	<start

	org	p:$40
start:	jsr	<getPic
loop:	jsr	<getControl
	jsr	<copyPic
	jsr	<blur
	jsr	<addPic
	jsr	<paintLut
	jmp	<loop

; Copy picture to buffer and blanks the borders.
; Quite complex shit due to split dst buffers.
copyPic:move			x:<picadr,r4
	move			x:<top_border,b
	clr	a		x:<stride,n4
	tst	b		#ybuf,r0
	jeq	<_topborder_loop
	do	b,_topborder_loop
	move					a,y:(r0)+
_topborder_loop:

	move			x:<top_lines,b
	tst	b
	jeq	<_top_loop
	do	b,_top_loop

	clr	a		x:<xoff,b
	tst	b
	jle	<_topleft_loop
	do	b,_topleft_loop
	move					a,y:(r0)+
_topleft_loop:

	move			x:<mid_pixels,b
	tst	b
	jeq	<_toppic_loop
	do	b,_toppic_loop
	move					y:(r4)+,b
	move					b,y:(r0)+
_toppic_loop:

	move			x:<right_border,b
	tst	b		(r4)+n4
	jeq	<_topright_loop
	do	b,_topright_loop
	move					a,y:(r0)+
_topright_loop:

	nop
_top_loop:

	move			x:<topl_border,b
	tst	b
	jeq	<_toplborder_loop
	do	b1,_toplborder_loop
	move					a,y:(r0)+
_toplborder_loop:

; bottom half..
	clr	a		x:<btmu_border,b
	tst	b		#xbuf,r0
	jeq	<_btmuborder_loop
	do	b,_btmuborder_loop
	move			a,x:(r0)+
_btmuborder_loop:

	move			x:<btm_lines,a
	tst	a				y:(r4)+,b
	jeq	<_btm_loop
	do	a,_btm_loop

	move			x:<xoff,a
	tst	a
	jle	<_btmleft_loop
	clr	a
	do	x:<xoff,_btmleft_loop
	move			a,x:(r0)+
_btmleft_loop:

	move			x:<mid_pixels,a
	tst	a
	jeq	<_btmpic_loop
	do	a,_btmpic_loop
	move			b,x:(r0)+	y:(r4)+,b
_btmpic_loop:

	move			x:<right_border,a
	move			(r4)+n4
	tst	a				y:-(r4),b
	jeq	<_btmright_loop
	clr	a
	do	x:<right_border,_btmright_loop
	move			a,x:(r0)+
_btmright_loop:

	move			(r4)+
_btm_loop:

; bottom border..
	move			x:<btm_border,b
	tst	b
	jeq	<_btmborder_loop
	do	b,_btmborder_loop
	move			a,x:(r0)+
_btmborder_loop:
	rts

; Add picture to buffer keeping the borders in mind.
; Quite complex shit due to split dst buffers.
; Major headache bonus due to amped intensities + load/store.
addPic:	move			x:<picadr,r4
	move			#ybuf,r0
	move			x:<top_border,n0
	move			x:<stride,n4
	move			(r0)+n0
	move			x:<left_border,n0
	move			x:<top_lines,b
	move			#>4,y0
	tst	b		(r0)+n0
	jeq	<_top_loop
	do	b,_top_loop

	move			x:<mid_pixels,b
	tst	b				y:(r4)+,x0
	jeq	<_toppic_loop
	do	b,_toppic_loop
	move					y:(r0),a0
	mac	y0,x0,a				y:(r4)+,x0
	move					a0,y:(r0)+
_toppic_loop:

	move			x:<screenstride,n0
	move			(r4)+n4
	move			(r0)+n0
	move			(r4)-
_top_loop:

; btm
	move			x:<btmu_border,n0
	move			#xbuf,r0
	move			x:<btm_lines,a
	tst	a		(r0)+n0
	move			x:<left_border,n0
	nop
	move			(r0)+n0
	jeq	<_btm_loop
	do	a,_btm_loop

	move			x:<mid_pixels,a
	tst	a				y:(r4)+,x0
	jeq	<_btmpic_loop
	do	a,_btmpic_loop
	move			x:(r0),a0
	mac	y0,x0,a				y:(r4)+,x0
	move			a0,x:(r0)+
_btmpic_loop:

	move			x:<screenstride,n0
	move			(r4)+n4
	move			(r0)+n0
	move			(r4)-
_btm_loop:
	rts

; Radial blur the buffer up.
; Does five layers, more is senseless.
blur:	move	#2*16777216/3,x0
	jsr	<addZoomedLayer
	move	#4*16777216/5,x0
	jsr	<addZoomedLayer
	move	#8*16777216/9,x0
	jsr	<addZoomedLayer
	move	#16*16777216/17,x0
	jsr	<addZoomedLayer
	move	#32*16777216/33,x0
	jsr	<addZoomedLayer
	rts

; Now feedback a zoomed layer to the buffer..
; INPUT:
; x0= scale
addZoomedLayer:
	move			x0,a
	lsr	a		#160,y0
	tfr	y0,a		a1,x1
	mac	-x1,y0,a
	lsr	a		#<steps,r0
; precalc x steps
	clr	b		#>$F00000,a0
	move			x0,b0
	do	#160,_preloop
	add	b,a		a,x:(r0)+
_preloop:

; precalc y steps (top)
;	move			#ysteps,r0

; put y offset in a1
	move			x0,a
	lsr	a		#100,y0
	tfr	y0,a		a1,x1
	mac	-x1,y0,a
	asr	a		#<50,n0				; a1= y offset
; top
	do	#50,_preloop_yt
	add	b,a		a,x:(r0)+
_preloop_yt:
; btm
	move			(r0)+n0
	do	#50,_preloop_yb
	add	b,a		a,x:-(r0)
_preloop_yb:
; top
	clr	b		#ysteps,r0
	move			#ybuf,b0
	move			#160/2,y0
	do	#50,_preloop_yt2
	tfr	b,a		x:(r0),x1
	mac	x1,y0,a
	move			a0,x:(r0)+
_preloop_yt2:
; btm
	move			#xbuf-160*50,b0
	do	#50,_preloop_yb2
	tfr	b,a		x:(r0),x1
	mac	x1,y0,a
	move			a0,x:(r0)+
_preloop_yb2:

; now actually blur it, using the steptables.
; top
	move			#<80,n0
	move			#ybuf,r2
	move			#ysteps,r3
	move			#<80,n2

	do	#50,_toploop	
	move			#<steps,r0
	move			x:(r3)+,r1
	move			x:(r0)+,n1

	do	#80,_tleftloop
	move					y:(r2),a
	move					y:(r1+n1),x0
	add	x0,a		x:(r0)+,n1
	move					a,y:(r2)+
_tleftloop:

	move			(r0)-
	move			(r0)+n0				; r0: end of line
	move			(r2)+n2				; r2: end of line
	move			x:-(r0),n1

	do	#80,_trightloop
	move					y:-(r2),a
	move					y:(r1+n1),x0
	add	x0,a		x:-(r0),n1
	move					a,y:(r2)
_trightloop:

	move			(r2)+n2				; r2: end of line
_toploop:

; btm
	move			#xbuf+49*160,r2
	move			#<80,n2

	do	#50,_btmloop	
	move			#<steps,r0
	move			x:(r3)+,r1
	move			x:(r0)+,n1

	do	#80,_bleftloop
	move			x:(r2),a
	move			x:(r1+n1),x0
	add	x0,a		x:(r0)+,n1
	move			a,x:(r2)+
_bleftloop:

	move			(r0)-
	move			(r0)+n0				; r0: end of line
	move			(r2)+n2				; r2: end of line
	move			x:-(r0),n1

	do	#80,_brightloop
	move			x:-(r2),a
	move			x:(r1+n1),x0
	add	x0,a		x:-(r0),n1
	move			a,x:(r2)
_brightloop:

	move			(r2)-n2
	move			(r2)-n2
	move			(r2)-n2
_btmloop:

	rts

	IFNE	0
; generic feedback scaler
	move			x:(r0)+,n1

; 8 cycles, do we need it any faster at all?
	move			x:(r2),a
	move			x:(r1+n1),x0
	add	x0,a		x:(r0)+,n1
	move			a,x:(r2)+

; specific feedback scaler: 1.5
	move			#<-2,n2
	move			x:(r2)+,a

; 16 for 3, so.. 4.6667 cycles, godallmighty!
	move			x:(r1)+,x0
	add	x0,a		x:(r2)-,b
	move			x:(r1)+,x0
	add	x0,b		a,x:(r2)+
	move			b,x:(r2)+
	move			x:(r2)+,b
	add	x0,b		x:(r2)+,a
	move			b,x:(r2+n2)

; 1.25, 28/5=5.6 cycles, still quite fast.
	move			x:(r1)+,x0

	move			x:(r2),a
	add	x0,a		x:(r1)+,x0
	move			a,x:(r2)+
	move			x:(r2),a
	add	x0,a		x:(r1)+,x0
	move			a,x:(r2)+
	move			x:(r2),a
	add	x0,a		x:(r1)+,x0
	move			a,x:(r2)+
	move			x:(r2)+,b
	add	x0,b		x:(r1)+,x0
	move			x:(r2)-,a
	add	x0,a		b,x:(r2)+
	move			a,x:(r2)+

; here it gets nasty.. it needs to fit into 80. but 9 doesn't very well.
; so we get nasty tails..

; 1.125, hhmm loop gets quite big here.. would be 6 cycles..
; so.. we use a 'do'.. (6+8*6+6)/9=60/9=6.66667 cycles
	move			x:(r1)+,x0

	do	#8,_loop
	move			x:(r2)+,a
	add	x0,a		x:(r1)+,x0
	move			a,x:(r2)+
_loop:	move			x:(r2)+,a
	add	x0,a
	move			a,x:(r2)+
	ENDC

; Send the pixels to the host.
paintLut:
	move			#>8000,x1
	move			#>$7FFFFF/40,y1
	move			#pal,r2
	move			x:<pal_offset,n2
	move			#xbuf,r1
	move			#ybuf,r0
	move			(r2)-n2
	do	x1,_tloop
	move					y:(r0)+,x0
	mpyr	y1,x0,a
	move			a1,n2
	send	x:(r2+n2)
_tloop:	do	x1,_bloop
	move			x:(r1)+,x0
	mpyr	y1,x0,a
	move			a1,n2
	send	x:(r2+n2)
_bloop:	rts

;---------------------------------------------------------------------------
; Can be in external P (beware of overlap!)
; best place in high x.. < $3000

getPic:
; Clear sub_palette.
	clr	a		#pal-256,r0
	do	#256,_clearloop
	move			a,x:(r0)+
_clearloop:
	
; Get palette.
	do	#256,_palloop
	get	x:(r0)+
_palloop:

; Get pic.
	move			#<pic,r0
	move			#124*59,x0
	do	x0,_loop
	get	y:(r0)+
_loop:	rts

getControl:
; Get palette offset..
	get	x:pal_offset
; Get (x,y) offset and calculate border offsets and such.
	get	x:xoff					; 0..36
	get	b					; 0..41
; top logo line = max(0,-yoff)
	move			#<0,x1
	neg	b		b,x:<yoff
	tmi	x1,b
	move			b,x0
	move			#<pic,a0
	move			#124/2,y0
	mac	x0,y0,a		x:<yoff,b
	clr	a		a0,x:<picadr
; top_border = min[50,max(0,yoff)]
	tst	b		#<50,a1
	tmi	x1,b
	cmp	a,b
	tge	a,b
	move			b,x:<top_border
; topl_border = min[50,max(0,41-yoff-50)]
	clr	a		x:<yoff,b
	neg	b		#<9,a1
	sub	a,b		#<50,a1
	tmi	x1,b
	cmp	a,b
	tge	a,b
	move			b,x:<topl_border
; top_lines = 50-top_border-topl_border (haha, easy)
	sub	b,a		x:<top_border,b
	sub	b,a		x:<yoff,b
	clr	a		a,x:<top_lines
; btmu_border = min[50,max(0,yoff-50)]
	move			#<50,a1
	sub	a,b
	tmi	x1,b
	cmp	a,b
	tge	a,b
	move			b,x:<btmu_border
; btm_border = min[50,max(0,41-yoff)]
	move			x:<yoff,x0
	clr	b		#<41,a1
	sub	x0,a		#<50,b1
	tmi	x1,a
	cmp	b,a
	tge	b,a
	move			a,x:<btm_border
; btm_lines = 50-btm_border-btmu_border (easy again)
	sub	a,b		x:<btmu_border,a
	sub	a,b
	move			b,x:<btm_lines

; Calculate size of blocks..
	move			#<top_border,r0
	move			#160/2,x1
	move			x:(r0),x0
	move			#<1,n0
	do	#4,_mulloop
	mpy	x0,x1,a		x:(r0+n0),x0
	move			a0,x:(r0)+
_mulloop:

; horizontal segment stuff..
	move			#<0,x1
; left_border = min[160,max(0,xoff)]
	move			x:<xoff,b
	tst	b		#>160,a
	tmi	x1,b
	cmp	a,b
	tgt	a,b
	move			b,x:<left_border
; right = min[160,max(0,36-xoff)
	clr	b		x:<xoff,x0
	move			#<36,b1
	sub	x0,b
	tmi	x1,b
	cmp	a,b						; b=mid+right
	tgt	a,b
	move			b,x:<right_border
; mid = 160-left_border-right_border
	sub	b,a		x:<left_border,b
	sub	b,a		x:<xoff,b
	neg	b		a,x:<mid_pixels	
; left logo offset = max(0,-xoff)
	tmi	x1,b
	move			x:<picadr,a
	add	b,a		#>36,x0
	move			a,x:<picadr
; stride = max(0,xoff-36) + logo_xoff
	move			x:<xoff,a
	sub	x0,a
	tmi	x1,a
	add	b,a		x:<left_border,b
	move			a,x:<stride
; screenstride = left_border+right_border
	move			x:<right_border,x0
	add	x0,b
	move			b,x:<screenstride
	rts
