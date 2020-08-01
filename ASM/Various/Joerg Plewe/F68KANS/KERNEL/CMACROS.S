*
* Definition of macros used in code
*
* started: JPS, 8feb93
*



* USEROffset
MACRO USERO varname,reg
	move.l		d5,reg
	addi.l		#o&varname,reg
ENDM


* usage: e.g increasing SPAN:
;	USERO span,d0
;	addq.l #1,0(a3,d0.l)





*
* Definition of a header preceeding the code of 
* each Forth-word 
*

MACRO CHEAD lname, propbits
.CODE
* VIEW information

	dc.l 	0
	
* compiler information

	dc.b 	(x&lname - lname) / 2
	dc.b	propbits

ENDM

cheadsize		EQU 6


* example:
*	CHEAD recurse, 2
*	recurse:	
*			dc.l 7
*			dc.l 8
*			dc.l 9
*	xrecurse:	rts

