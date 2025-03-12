*--------------------------------------------------------------------------*
* Useful macros for the debugger controlling interface for HiSoft's Devpac
* assembler.
*
* 		Copyright 1993 Andrew L. Younger ( Black Scorpion Software )
*--------------------------------------------------------------------------*

*--------------------------------------------------------------------------*
* long SetBreak(char *addr_string, short breaktype, long counter,
*		    char *expr_string)
*--------------------------------------------------------------------------*
BREAKLock:	 equ	%00010000
BREAKSimple: equ	1
BREAKCounter:equ	2
BREAKExpress:equ	3
BREAKCntExpr:equ	4
*--------------------------------------------------------------------------*
SetBreak:	MACRO	 ; \1=addr.l, \2=breaktype.w, \3=counter.l, \4=expr.l
		pea		.expr\@	; expr
		pea		\3		; counter
		move.w	#\2,-(sp)	; type
		pea		.addr\@	; address
		move.w	#32000,-(sp)
		trap		#14
		lea		16(sp),sp
		DATA
.addr\@:	dc.b		\1,0
.expr\@:	dc.b		\4,0
		TEXT
		ENDM

*--------------------------------------------------------------------------*
* void SetWatch(char *addr_string, short type)
*--------------------------------------------------------------------------*
WATCHPointer:equ	%10000000
WATCHByte:	 equ	1
WATCHWord:	 equ	2
WATCHLong:	 equ	3
WATCHText:	 equ	4
*--------------------------------------------------------------------------*
SetWatch:	MACRO	 ; \1=addr_string.l, \2=type.w
		move.w	#\2,-(sp)	; type
		pea		.addr\@	; addr string
		move.w	#32001,-(sp)
		trap		#14
		addq.l	#8,sp
		DATA
.addr\@:	dc.b		\1,0
		TEXT
		ENDM
