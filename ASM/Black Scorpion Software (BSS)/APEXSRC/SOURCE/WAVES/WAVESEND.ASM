;-----------------------------------------------------------------------
; Call the correct routine to send output to CPU
; INTERPOLATE : 0 = send 80*60, 1 = send 320*240 interpolated
;-----------------------------------------------------------------------

OutputGrid:

	move	x:INTERPOLATE,a
	tst	a
	jne	_interpolate
_normal
	jsr	SendNormal
	jmp	_sent
_interpolate
	jsr	SendInterpolate
_sent
	rts

;-----------------------------------------------------------------------
; Send output to CPU
; NORMAL version - sends 80*60 grid 'as is'
;-----------------------------------------------------------------------

SendNormal
	move	x:COLOURLOOKUP,a
	tst	a
	jne	_lookup
_normal
	move	#1.0/32768.0,y0
	move	x:height2ptr,r0
	do	#height,_SENDYnormal
	nop
	do	#width,_SENDXnormal

	move	x:(r0)+,x0
	mpy	x0,y0,a
	dspwrite	a1

_SENDXnormal
	nop
_SENDYnormal
	nop
	rts

_lookup
	move	x:height2ptr,r0
	move	#palette,r1
	do	#height,_SENDYlookup
	nop
	do	#width,_SENDXlookup

	move	x:(r0)+,n1
	dspwrite	x:(r1+n1)

_SENDXlookup
	nop
_SENDYlookup
	nop
	rts

;-----------------------------------------------------------------------
; Send output to CPU
; INTERPOLATIVE version - sends 320*240 interpolated grid
;
; This routine is quite a bit more complex than the basic send routine.
; It uses a 5 line buffer (320*5) to expand lines into.
;
; The routine first generates a line into the bottom line buffer (from
; the first interpolated line, if that makes sense). It then goes into
; a loop which copies the bottom line to the top, generates a new bottom
; line, and then fills in the 3 middle lines. This is repeated until
; the grid has been sent. The first 4 lines of each buffer are sent during
; each loop, which leaves only one 'hanging' line at the end, which will
; be sent by itself.
;
; The 5 line buffer is in X memory.
;-----------------------------------------------------------------------

SendInterpolate

	move	#line5,r1		; Get address of bottom buffer line in r1
	move	x:height2ptr,r0		; Get 1st grid line in r0 (new grid from 2nd pointer)
	nop
	move	(r0)+			; Skip in to first real pixel

	jsr	HorzInterpolate		; Interpolate this 1st line horizontally into buffer line 5

; DO for all grid rows

	do	#height,_YLOOP

	move	#line5,r1		; Copy line 5 to line 1
	move	#line1,r2
	jsr	CopyLine

	move	r0,a			; Move onto next line in grid
	move	#>width+2,b
	add	b,a
	move	a,r0

	move	#line5,r1		; Work on line 5 (new line 5)

	jsr	HorzInterpolate		; Interpolate horizontally into buffer to gen new line 5

	move	#line1,r1		; Create line 3 by interpolating pixels in lines 1 and 5
	move	#line5,r2
	move	#line3,r3
	jsr	VertInterpolate

;	move	#line1,r1		; Create line 2 by interpolating pixels in lines 1 and 3
;	move	#line3,r2
;	move	#line2,r3
;	jsr	VertInterpolate

;	move	#line3,r1		; Create line 4 by interpolating pixels in lines 3 and 5
;	move	#line5,r2
;	move	#line4,r3
;	jsr	VertInterpolate

	move	#line1,r1		; Send the 4 lines
	jsr	Send4Lines

_YLOOP

	rts

;-----------------------------------------------------------------------
; Horizontal interpolation routine
; IN : r0 = grid row, r1 = buffer line to fill
;-----------------------------------------------------------------------

HorzInterpolate

	move	r0,r2		; Duplicate pointers (so as not to wreck them)
	move	r1,r3

; DO for each pixel in grid row

	move	x:(r2)+,x0		; get 1st pixel
	do	#width,_XLOOP

	move	x:(r2)+,x1		; next pixel
	move	x0,x:(r3)+		; output 1st pixel as is

	move	x0,a
	move	x1,b
	add	a,b
	asr	b			; middle pixel
	move	b1,y0			; store in y0

	add	a,b
	asr	b			; left middle pixel
	move	b1,x:(r3)+		; output it

	move	y0,x:(r3)+		; output middle pixel

	move	y0,a
	move	x1,b
	add	a,b
	asr	b			; right middle pixel
	move	b1,x:(r3)+		; output it

	move	x1,x0			; Make 1st pixel (x0) equal this one (x1)
	
_XLOOP

	move	x1,x:(r3)		; Output last pixel

	rts

;-----------------------------------------------------------------------
; Vertical interpolation routine
; This scans along two buffer lines, and puts the interpolated value
; into a third line.
; IN: r1,r2 = source lines, r3 = dest line
;-----------------------------------------------------------------------

VertInterpolate
	do	#width*4,_XLOOP
	move	x:(r1)+,a
	move	x:(r2)+,b
	add	a,b
	asr	b
	move	b,x:(r3)+
_XLOOP
	nop
	rts

;-----------------------------------------------------------------------
; Send 4 lines from line buffers over the host port
; IN: r1 = first line buffer address
;-----------------------------------------------------------------------

Send4Lines
;	move	#1.0/32768.0,y0
;	do	#width*2*2,_SENDLOOP1
;	move	x:(r1)+,x0
;	mpy	x0,y0,a	(r1)+
;	dspwrite	a1
;_SENDLOOP1

	move	x:COLOURLOOKUP,a
	tst	a
	jne	_lookup
_normal
	move	#1.0/32768.0,y0
	do	#width*2,_SENDLOOP1normal
	move	x:(r1)+,x0
	mpy	x0,y0,a	(r1)+
	dspwrite	a1
_SENDLOOP1normal
;	move	#width*4,n1
;	nop
;	move	(r1)+n1
	do	#width*2,_SENDLOOP2normal
	move	x:(r1)+,x0
	mpy	x0,y0,a	(r1)+
	dspwrite	a1
_SENDLOOP2normal

	nop
	rts

_lookup
	move	#1.0/32768.0,y0
	move	#>palette,r2
	do	#width*2,_SENDLOOP1lookup
	move	x:(r1)+,x0
	mpy	x0,y0,a	(r1)+
	move	a1,n2
	nop
	dspwrite	x:(r2+n2)
_SENDLOOP1lookup
;	move	#width*4,n1
;	nop
;	move	(r1)+n1
	do	#width*2,_SENDLOOP2lookup
	move	x:(r1)+,x0
	mpy	x0,y0,a	(r1)+
	move	a1,n2
	nop
	dspwrite	x:(r2+n2)
_SENDLOOP2lookup

	nop
	rts

;-----------------------------------------------------------------------
; Copy a buffer line to another line
; IN : r1 = source line, r2 = dest line
;-----------------------------------------------------------------------

CopyLine
	do	#width*4,_XLOOP
	move	x:(r1)+,x0
	move	x0,x:(r2)+
_XLOOP
	nop
	rts
