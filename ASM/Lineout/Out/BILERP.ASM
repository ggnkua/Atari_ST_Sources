; bilinear rotozoom (palette based)
;
; we have to keep the texture in dsp ram for speed
; this causes a problem, namely saving ram (for soundmixer)
; we can choose:
;
; a) 64*64 texture
; b) 128*128 texture, banked x:even,y:odd
; c) 128*128 texture, interleaved (2 texels in 1 word)
;
; a) might look crappy, but is simple and fast
; b) looks good, but is somewhat slower <-
; c) looks good (as b), but is slowest
;
; i chose to dump the concept of wrapping.. tough luck, but faster.
; seems to work now.. reasonable speed.
; one problem: you need to pack the pixels into words to kill as much
; cpu handshakes as possible.. this might require some minor unrolling..
;
; update: fixed all the shit.. i think it's still slow due to banking..
;
; update: sending two pixels in one transfers speeds it up.
;
; update: speeded up lots, cos we keep vars in internal x/y mem.

DOUBLE:	=	1						; send two pixels per transfer?

get:	MACRO
	jclr	#0,X:<<$FFE9,*
	movep	X:<<$FFEB,\1
	ENDM

send:	MACRO
	jclr	#1,X:<<$FFE9,*
	movep	\1,X:<<$FFEB
	ENDM

	org	p:0
	jmp	<start

	org	p:$40

start:	jsr	<init

_loop:	jsr	<getVectors
	jsr	<paint
	jmp	<_loop

getVectors:
	move	#uv_table,r0
	do	#3,_loop
	get	x:(r0)
	get	y:(r0)+
_loop:
	IFNE	0
	move	#$000100,x0
	move	#$3FFF00,x1
	move	x1,x:<uv_start
	move	x1,y:<uv_start
	clr	a
	move	x0,x:<uv_xstep
	move	a,y:<uv_xstep
	move	a,x:<uv_ystep
	move	x0,y:<uv_ystep
	ENDC

	rts

paint:
	IFNE	DOUBLE

	move			#$FFEB,r1
	move			#<texturesize,r2
	move			#<texturemask,r3
	move			#<uv_xstep,r4
	move			#<1,n4
	move			#<uv_x,r5
	move			#<1,n5
	move			#<scalar,r6
	move			#<128/2,n0
	move			l:<uv_start,a
	move			a,l:(r5+n5)
	movec	#128*128/2-1,m0
	move					y:(r2),y1	; y1=texturesize

	do	#100,_yloop
; calc start (u,v)
; a1=u, a0=v
	move			a,l:(r5)
	move					y:(r5),y0	; y0=v

	do	#80,_xloop
; 1: calc texture coordinates (u,v) 30 cycles..
; a1=u, a0=v, y0=texturesize, y1=v
	mpy	y0,y1,b		l:(r3),x			; b=offset=u*texturesize, x1=width, x0=mask
	move			#<0,b0
	and	x0,b		l:(r5),y			; kill frag_u, y1=u, y0=v
	mac	y1,x1,b		l:(r4),x			; b=offset, x1=u_step, x0=v_step
	add	x,a		x:(r6),x0			; a1=u[n+1], a0=v[n+1], x0=scalar
	mpy	x0,y0,a		a,l:(r5)
	bclr	#23,a0
	mpy	x0,y1,a		a0,y1				; y1=v_frac
	bclr	#23,a0
	lsr	b		a0,y0				; y0=u_frac
	move			b1,r0				; r0=textureoffset (assuming texturestart=0!)

; 2: bilinear interpolation..
; two bank version..
; y0=u_frac, y1=v_frac
; r0:texture, n0=texturewidth
	jcs	<_odd						; Was it even?

; nice.. this one cannot wrap in u-dir ;) v-dir can be done with m0.. 20 cycles
_even:	move			x:(r0+n0),x0			; x0=hlb
	move			x:(r0),b			; b=hlt
	mac	+y1,x0,b	b,x0		y:(r0),a	; b=v_frac*hlb+hlt, x0=hlt, a=hrt
	macr	-y1,x0,b			y:(r0+n0),x0	; b=hl=v_frac*(hlb-hlt)+hlt, x0=hrb
	mac	+y1,x0,a	a,x0				; a=v_frac*hrb+hrt, x0=hrt
	macr	-y1,x0,a	b,x0				; a=hr=v_frac*(hrb-hrt)+hrt, x0=hl
	mac	-y0,x0,b	a,x0		y:(r2),y1	; b=u_frac*hr+hl, x0=hl, y1=texturesize
	macr	+y0,x0,b	l:(r5),a			; b=h=u_frac*(hr-hl)+hl, a=uv_x
	jmp	<_next	

; beware.. this one has no wrapping in u-direction.. 18 cycles
_odd:	move					y:(r0+n0),x0	; x0=hlb
	move					y:(r0)+,b	; b=hlt
	move			b,x1
	mac	+y1,x0,b	x:(r0),a			; b=v_frac*hlb+hlt, x0=hlt, a=hrt
	macr	-y1,x1,b	x:(r0+n0),x0			; b=hl=v_frac*(hlb-hlt)+hlt, x0=hrb
	mac	+y1,x0,a	a,x0				; a=v_frac*hrb+hrt, x0=hrt
	macr	-y1,x0,a	b,x0				; a=hr=v_frac*(hrb-hrt)+hrt, x0=hl
	mac	-y0,x0,b	a,x0		y:(r2),y1	; b=u_frac*hr+hl, x0=hl, y1=texturesize
	macr	+y0,x0,b	l:(r5),a			; b=h=u_frac*(hr-hl)+hl, a=uv_x

_next:	move			b,x:(r2)	y:(r5),y0	; Store texturepixel, y0=v

; 1: calc texture coordinates (u,v) 30 cycles..
; a1=u, a0=v, y0=texturesize, y1=v
	mpy	y0,y1,b		l:(r3),x			; b=offset=u*texturesize, x1=width, x0=mask
	move			#<0,b0
	and	x0,b		l:(r5),y			; kill frag_u, y1=u, y0=v
	mac	y1,x1,b		l:(r4),x			; b=offset, x1=u_step, x0=v_step
	add	x,a		x:(r6),x0			; a1=u[n+1], a0=v[n+1], x0=scalar
	mpy	x0,y0,a		a,l:(r5)
	bclr	#23,a0
	mpy	x0,y1,a		a0,y1				; y1=v_frac
	bclr	#23,a0
	lsr	b		a0,y0				; y0=u_frac
	move			b1,r0				; r0=textureoffset (assuming texturestart=0!)

; 2: bilinear interpolation..
; two bank version..
; y0=u_frac, y1=v_frac
; r0:texture, n0=texturewidth
	jcs	<_odd2						; Was it even?

; nice.. this one cannot wrap in u-dir ;) v-dir can be done with m0.. 20 cycles
_even2:	move			x:(r0+n0),x0			; x0=hlb
	move			x:(r0),b			; b=hlt
	mac	+y1,x0,b	b,x0		y:(r0),a	; b=v_frac*hlb+hlt, x0=hlt, a=hrt
	macr	-y1,x0,b			y:(r0+n0),x0	; b=hl=v_frac*(hlb-hlt)+hlt, x0=hrb
	mac	+y1,x0,a	a,x0				; a=v_frac*hrb+hrt, x0=hrt
	macr	-y1,x0,a	b,x0				; a=hr=v_frac*(hrb-hrt)+hrt, x0=hl
	mac	-y0,x0,b	a,x0		y:(r2),y1	; b=u_frac*hr+hl, x0=hl, y1=texturesize
	macr	+y0,x0,b	x:(r2),x0	y:(r6),y0	; b=h=u_frac*(hr-hl)+hl, x0=prv. pix, y0=scalar
	jmp	<_next2

; beware.. this one has no wrapping in u-direction.. 18 cycles
_odd2:	move					y:(r0+n0),x0	; x0=hlb
	move					y:(r0)+,b	; b=hlt
	move			b,x1
	mac	+y1,x0,b	x:(r0),a			; b=v_frac*hlb+hlt, x0=hlt, a=hrt
	macr	-y1,x1,b	x:(r0+n0),x0			; b=hl=v_frac*(hlb-hlt)+hlt, x0=hrb
	mac	+y1,x0,a	a,x0				; a=v_frac*hrb+hrt, x0=hrt
	macr	-y1,x0,a	b,x0				; a=hr=v_frac*(hrb-hrt)+hrt, x0=hl
	mac	-y0,x0,b	a,x0		y:(r2),y1	; b=u_frac*hr+hl, x0=hl, y1=texturesize
	macr	+y0,x0,b	x:(r2),x0	y:(r6),y0	; b=h=u_frac*(hr-hl)+hl, x0=prv. pix, y0=scalar

_next2:	mpy	x0,y0,a						; a0=c1<<8
	move			a0,y0				; y0=c1<<8
	add	y0,b		l:(r5),a			; b=c1<<8+c2, a=uv_x
	jclr	#1,x:<<$FFE9,*
	move			b,x:(r1)	y:(r5),y0	; Send two pixels to host, y0=v
_xloop:	

	ELSE
; old version.. one at at time.....
	move			#$FFEB,r1
	move			#<texturesize,r2
	move			#<texturemask,r3
	move			#<uv_xstep,r4
	move			#<1,n4
	move			#<uv_x,r5
	move			#<1,n5
	move			#<scalar,r6
	move			#<128/2,n0
	move			l:<uv_start,a
	move			a,l:(r5+n5)
	movec	#128*128/2-1,m0
	move					y:(r2),y0	; y0=texturesize
	move					y:(r5),y1	; y1=v

	do	#100,_yloop
; calc start (u,v)
; a1=u, a0=v
	move			a,l:(r5)


	do	#160,_xloop
; 1: calc texture coordinates (u,v) 30 cycles..
; a1=u, a0=v, y0=texturesize, y1=v
	mpy	y0,y1,b		l:(r3),x			; b=offset=u*texturesize, x1=width, x0=mask
	move			#<0,b0
	and	x0,b		l:(r5),y			; kill frag_u, y1=u, y0=v
	mac	y1,x1,b		l:(r4),x			; b=offset, x1=u_step, x0=v_step
	add	x,a				y:(r6),x0	; a1=u[n+1], a0=v[n+1], x0=scalar
	mpy	x0,y0,a		a,l:(r5)
	bclr	#23,a0
	mpy	x0,y1,a		a0,y1				; y1=v_frac
	bclr	#23,a0
	lsr	b		a0,y0				; y0=u_frac
	move			b1,r0				; r0=textureoffset (assuming texturestart=0!)

; 2: bilinear interpolation..
; two bank version..
; y0=u_frac, y1=v_frac
; r0:texture, n0=texturewidth
	jcs	<_odd						; Was it even?

; nice.. this one cannot wrap in u-dir ;) v-dir can be done with m0.. 20 cycles
_even:	move			x:(r0+n0),x0			; x0=hlb
	move			x:(r0),b			; b=hlt
	mac	+y1,x0,b	b,x0		y:(r0),a	; b=v_frac*hlb+hlt, x0=hlt, a=hrt
	macr	-y1,x0,b			y:(r0+n0),x0	; b=hl=v_frac*(hlb-hlt)+hlt, x0=hrb
	mac	+y1,x0,a	a,x0				; a=v_frac*hrb+hrt, x0=hrt
	macr	-y1,x0,a	b,x0				; a=hr=v_frac*(hrb-hrt)+hrt, x0=hl
	mac	-y0,x0,b	a,x0		y:(r2),y1	; b=u_frac*hr+hl, x0=hl
	macr	+y0,x0,b	l:(r5),a			; b=h=u_frac*(hr-hl)+hl, a=uv_x
	jmp	<_next	

; beware.. this one has no wrapping in u-direction.. 18 cycles
_odd:	move					y:(r0+n0),x0	; x0=hlb
	move					y:(r0)+,b	; b=hlt
	move			b,x1
	mac	+y1,x0,b	x:(r0),a			; b=v_frac*hlb+hlt, x0=hlt, a=hrt
	macr	-y1,x1,b	x:(r0+n0),x0			; b=hl=v_frac*(hlb-hlt)+hlt, x0=hrb
	mac	+y1,x0,a	a,x0				; a=v_frac*hrb+hrt, x0=hrt
	macr	-y1,x0,a	b,x0				; a=hr=v_frac*(hrb-hrt)+hrt, x0=hl
	mac	-y0,x0,b	a,x0		y:(r2),y1	; b=u_frac*hr+hl, x0=hl
	macr	+y0,x0,b	l:(r5),a			; b=h=u_frac*(hr-hl)+hl, a=uv_x

_next:	jclr	#1,x:<<$FFE9,*
	move			b,x:(r1)	y:(r5),y0
_xloop:	

	ENDC

; increment start (u,v)
	move			l:(r5+n5),a
	move			l:(r4+n4),x
	add	x,a
	move			a,l:(r5+n5)
_yloop:	rts


; Store texture.
init:	move			#128*128/2,x0
	move			#>texture,r0
	do	x0,_loop
	get	x:(r0)
	get	y:(r0)+
_loop:	rts

		org	x:0
texturemask:	dc	128						; texturewidth
uv_table:
uv_xstep:	ds	1						; u_xstep
uv_ystep:	ds	1						; u_ystep
uv_start:	ds	1						; u_start
uv_x:		ds	1						; u_x
uv_y:		ds	1						; u_y

prv_pixel:	ds	1
scalar:		dc	128/2						; scalar for (u,v) fractions
		ds	1

texture:	ds	128*128/2

		org	y:0
		dc	$003F80						; texture v_mask

		ds	1						; v_xstep
		ds	1						; v_ystep
		ds	1						; v_start
		ds	1						; v_x
		ds	1						; v_y

texturesize:	dc	128*128
		dc	$000080						; <<8 scalar for pixel multiplex
		ds	1

		ds	128*128/2					; texture
