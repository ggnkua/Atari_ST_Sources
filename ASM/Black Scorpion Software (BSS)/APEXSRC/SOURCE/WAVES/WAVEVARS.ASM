;***********************************************************************
; Variable Space
;***********************************************************************

;-----------------------------------------------------------------------
; X mem vars
;-----------------------------------------------------------------------

; Internal X memory

	org	x:0

; System control vars

DAMPEN		ds	1
REACT		ds	1
MAX		ds	1
INTERPOLATE	ds	1
BITS		ds	1
CLEARVELOCITY	ds	1
COLOURLOOKUP	ds	1
HARDEDGES	ds	1

; Grid pointers

height1ptr	ds	1
velocity1ptr	ds	1
height2ptr	ds	1
velocity2ptr	ds	1

; Current position

POS	dc	10,5
	dc	20,10
	dc	30,15
	dc	40,20
	dc	50,25
	dc	10,25
	dc	20,20
	dc	30,15
	dc	40,10
	dc	50,5
	dc	10,25
	dc	20,25
	dc	30,25
	dc	40,25
	dc	50,25
	dc	10,35
	dc	20,35
	dc	30,35
	dc	40,35
	dc	50,35
INC	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
	dc	1,1
AMP
;	dc	255,255,255,255,255,255,255,255,255,255
	dc	255*32767,255*32767,255*32767,255*32767,255*32767,255*32767,
	dc	255*32767,255*32767,255*32767,255*32767,255*32767,255*32767,255*32767
INCNUM	dc	0
INCLIST	dc	1,2,3,2,1,3,2,3,2,1,2,3,2,2,1,1,2,2,1,3,2,2,1,-1
;	1,1,1,0,1,0,0,0,1,1,0,0,1,0,1,1,0,1,0,1,1,0,1,0,-1

; External X memory

	org	x:$400

; Height grids
; Each has a spare line above and below, to stop external influences.

h1	ds	width+2
height1	ds	(width+2)*(height+1)	; extra lines for output interpolation and edge crap
h2	ds	width+2
height2	ds	(width+2)*(height+1)
	ds	width+2

; Interpolation output buffers
; These are used to expand the grid into when outputting in INTERPOLATED mode.

line1	ds	width*4
;line2	ds	width*4
line3	ds	width*4
;line4	ds	width*4
line5	ds	width*4
	ds	1		; extra word for interpolation overflow (!)

palette
	ds	256

;-----------------------------------------------------------------------
; Y mem vars
;-----------------------------------------------------------------------

; External Y memory

	org	y:$800

; Velocity grids
; Each has a spare line above and below, to stop external influences.

v1		ds	width+2
velocity1	ds	(width+2)*(height+4)
v2		ds	width+2
velocity2	ds	(width+2)*(height+4)

; Image memory
; This is used when in IMAGE mode to hold the image to lighten/darken
; with the waves' heights.

image
;		ds	width*height

;-----------------------------------------------------------------------
; L mem vars
;-----------------------------------------------------------------------

	org	l:0
