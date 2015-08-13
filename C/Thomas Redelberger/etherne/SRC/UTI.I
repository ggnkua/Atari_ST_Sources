*********************************************************************************
* Helper Macros for ST assembler programming					*
*	Copyright 2001 Dr. Thomas Redelberger					*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: uti.i 1.2 2002/06/08 16:26:52 Thomas Exp Thomas $
*

*
* external references
*
		XREF	prntStr		; CDECL (); debugging
		XREF	prntLong	; CDECL (); "
		XREF	prntWord	; CDECL (); "
		XREF	prntByte	; CDECL (); "
		XREF	prntSR		; CDECL (); "

*
* macros
*

Alloc		MACRO			; allocate a number of bytes on stack
		IFLE	\1-8
		subq.l	#\1,sp
		ELSEIF
		lea	-\1(sp),sp
		ENDC
		ENDM

deAlloc		MACRO			; pop a number of bytes from stack
		IFLE	\1-8
		addq.l	#\1,sp
		ELSEIF
		lea	\1(sp),sp
		ENDC
		ENDM


mtst		MACRO			; bit test using a bit mask (masks taken from C code)
		IFNE	\1&$0001
		btst	#0,\2
		ENDC
		IFNE	\1&$0002
		btst	#1,\2
		ENDC
		IFNE	\1&$0004
		btst	#2,\2
		ENDC
		IFNE	\1&$0008
		btst	#3,\2
		ENDC
		IFNE	\1&$0010
		btst	#4,\2
		ENDC
		IFNE	\1&$0020
		btst	#5,\2
		ENDC
		IFNE	\1&$0040
		btst	#6,\2
		ENDC
		IFNE	\1&$0080
		btst	#7,\2
		ENDC
		IFNE	\1&$0100
		btst	#8,\2
		ENDC
		IFNE	\1&$0200
		btst	#9,\2
		ENDC
		IFNE	\1&$0400
		btst	#10,\2
		ENDC
		IFNE	\1&$0800
		btst	#11,\2
		ENDC
		IFNE	\1&$1000
		btst	#12,\2
		ENDC
		IFNE	\1&$2000
		btst	#13,\2
		ENDC
		IFNE	\1&$4000
		btst	#14,\2
		ENDC
		IFNE	\1&$8000
		btst	#15,\2
		ENDC
		ENDM


**** debugging macros ***********************************************************

* sounds the bell

myPling		MACRO
		move	#$0700,-(sp)		; string BELL\0
		pea	(sp)			; arg: address to this string
		bsr	prntStr
		addq.l	#6,sp			; pop arg and string
		ENDM

* polls if a key was pressed
*	d0 =  0 no key pressed
*	d0 = -1 key pressed
*	
PollKey		MACRO
		movem.l	d1-d2/a0-a2,-(sp)
		move.l	#$00010002,-(sp)	; bconstat (1) con (2)
		trap	#13
		addq.l	#4,sp
		movem.l	(sp)+,d1-d2/a0-a2
		ENDM

* waits for a key pressed
*	bits 0-7 ACSII
*	bits 16-23 scan code
*	bits 24-31 value of Kbshift()
WaitKey		MACRO
		movem.l	d1-d2/a0-a2,-(sp)
		move.l	#$00020002,-(sp)	; bconin (2) con (2)
		trap	#13
		addq.l	#4,sp
		movem.l	(sp)+,d1-d2/a0-a2
		ENDM


PrA		MACRO
		pea	.mess\@(pc)
		bsr	prntStr
		addq.l	#4,sp
		bra.b	.cont\@
.mess\@		DC.B	\1,0
		EVEN
.cont\@
		ENDM


PrS		MACRO
		pea	\1
		bsr	prntStr
		addq.l	#4,sp
		ENDM


PrL		MACRO
		move.l	\1,-(sp)
		bsr	prntLong
		addq.l	#4,sp
		ENDM


PrW		MACRO
		move.w	\1,-(sp)
		bsr	prntWord
		addq.l	#2,sp
		ENDM


PrB		MACRO
		move.b	\1,-(sp)	; the 68K pushes an extra align byte
		bsr	prntByte
		addq.l	#2,sp		; the 68K pushes an extra align byte
		ENDM


*********************************************************************************
