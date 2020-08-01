*
* Definition of a macro to define the words header
*
* started: JPS, 8feb93
*


.DATA

__headerroot: dc.l 0
.SET __successor__,__headerroot


MACRO HEADER name, prt
.DATA 
			dc.l	(name-sys-of)
__&name:	dc.l	(__successor__-datas)
			ASCIIL	prt
.EVEN
.SET __successor__, __&name
ENDM 

* these values have to be edited in equ.s
*headsize		EQU	8
*cfaoffset 		EQU 0
*lfaoffset		EQU 4
*nameoffset		EQU 8




* the last two lines define a pointer to zero, which 
* indicates the end of the list
*of equ $8000
*sys:
*datas:
*test:
*HEADER test, 'TEST', 123
*test1:
*HEADER test1, 'TEST1', 456


* definition of USER-variables
.SET __curoffset, 0	

MACRO USERVAR name, val
t&name:		dc.l	val	
o&name		EQU	__curoffset
.SET __curoffset, (__curoffset+4)
ENDM
 