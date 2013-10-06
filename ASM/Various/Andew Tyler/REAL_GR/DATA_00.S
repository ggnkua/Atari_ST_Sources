* * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Copyright A.Tyler 1991 data_00.s                      *
*		     The data file                      *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* A list of the Line A variables offsets.
* Their meanings are given in Appendix 5.
fg_bp1	equ	24
fg_bp2	equ	26
fg_bp3	equ	28
fg_bp4	equ	30
wrt_mod	equ	36
x1	equ	38
y1	equ	40
x2	equ	42
patptr	equ	46
patmsk	equ	50
multifil	equ	52

* and the routine names
init	equ	$a000
hline	equ	$a004
* The fill pattern for the $a004 routine 
fill:
	dc.w	%1111111111111111
	dc.w	%1010101010101010
	dc.w	%1001100110011001
	dc.w	%1111111111111111
