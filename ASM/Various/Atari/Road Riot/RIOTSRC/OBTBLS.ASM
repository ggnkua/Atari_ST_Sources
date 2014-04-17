		TTL	'Object setup data base'

SYSID		EQU	1	* VMS = 0, ARIUM = 1

		IFEQ	SYSID
		INCLUDE	'inc:hrdwmap.i'
		ENDC

		IFNE	SYSID
		INCLUDE	prog/inc/hrdwmap.i
		ENDC

		IFEQ	EDIT_ON
PAGE1		EQU	$2000
PAGE2		EQU	$4000
PAGE3		EQU	$6000
		ENDC

		IFNE	EDIT_ON
PAGE1		EQU	$0000
PAGE2		EQU	$0000
PAGE3		EQU	$0000
		ENDC

NULL		EQU	0
NULLIST		EQU	$FF
ENDLIST		EQU	$80

		PAGE
		SECTION	13
*
* Object world tables - pointers to each world's object data list
*
		XREF	w1,w2,w3,w4
		XREF	w5,w6,w7,w8
		XREF	w9,w10,w11,w12

		XDEF	strip_tbl,MAX_WORLD,MAX_TRK,LAST_TRK,strip_end
strip_tbl:	DC.L	w1,w2+PAGE2,w3+PAGE1,w4-PAGE1
		DC.L	w5+PAGE1,w6-PAGE1,w7-PAGE2,w8-PAGE1
		DC.L	w9-PAGE1,w10-PAGE2,w11-PAGE3,w12-PAGE2

strip_end	EQU	*

LAST_TRK	EQU	(*-strip_tbl)/4
MAX_TRK		EQU	(*-strip_tbl)/4
MAX_WORLD	EQU	(*-strip_tbl)/4

		END
