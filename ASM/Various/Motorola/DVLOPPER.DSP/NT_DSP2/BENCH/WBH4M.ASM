;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
;
wbh4m	macro	points
wbh4m	ident	1,0
;
; Blackman-Harris 4 Term Minimum Sidelobe Window
;
; Macro Call - wbh4m   points
;
;	points - number of points (1 - 65536)
;
; Latest revision -  4-Feb-87
; Tested and verified - 4-Feb-87
;
_pi	equ	3.141592654
inc1	equ	2.0*_pi/@cvf(points)
w0	equ	0.35875
w1	equ	0.48829
w2	equ	0.14128
w3	equ	0.01168

angle	set	0.0
	dup	points
	dc	w0-w1*@cos(angle)+w2*@cos(2.0*angle)-w3*@cos(3.0*angle)
angle	set	angle+inc1
	endm

	endm	;end of window macro
