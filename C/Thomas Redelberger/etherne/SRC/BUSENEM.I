*********************************************************************************
* Bus access macros for Milan for register base hardware on the ISA bus		*
* This hardware supports all(?) NE2000 (clone) cards				*
*										*
*	Copyright 2002 Mariusz Buras, Dr. Thomas Redelberger			*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
* processor registers are used as follows:					*
*										*
*	a5:	will point to ISA_BASE+NE_IO_BASE	; do not change it!	*
*	a6:	will be used temporarily					*
*										*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: busenem.i 1.1 2002/06/08 16:26:52 Thomas Exp Thomas $
*

*
* manifest constants
*

BUGGY_HW	EQU	1		; if defined enables code to handle buggy hardware

*
* hardware addresses
*

ISA_BASE	EQU	$80000000	; ISA base address for Milan
NE_IO_BASE	EQU	$300		; if your card is somewhere else change it.

*
* macros
*

lockBUS		MACRO
		moveq	#-1,d0			; preset error code
		tas	DVS+lcl_irqlock		; check for race about Cartrige Port and
		bne	.doNothing		; if somebody owns the bus we quit
		ENDM


lockBUSWait	MACRO
* there should be a timeout based on _hz_200 (and then branch to .doNothing)

.lt1\@		tas	DVS+lcl_irqlock		; check for race about Cartrige Port and
		beq.b	.lc1\@			; if somebody owns the bus we *wait*

		bsr	_appl_yield		; wait
		bra.b	.lt1\@

.lc1\@						; proceed
		ENDM


unlockBUS	MACRO
		sf	DVS+lcl_irqlock		; let other tasks access this device
		ENDM


unlockBUSWait	MACRO
		sf	DVS+lcl_irqlock		; let other tasks access this device
		ENDM


RxBUS		EQUR	d6			; unused here
RyBUS		EQUR	d7			; unused here
RcBUS		EQUR	a5
RdBUS		EQUR	a6			; used temporarily


ldBUSRegs	MACRO				; for faster access to hardware
		lea	ISA_BASE+NE_IO_BASE,RcBUS
		ENDM


putBUS		MACRO
		move.b	\1,(\2)^3(RcBUS)
		ENDM


putMore		MACRO
		move.b	\1,(\2)^3(RcBUS)
		ENDM


putBUSi		MACRO
		putBUS	#\1,\2
		ENDM


getBUS		MACRO
		move.b	(\1)^3(RcBUS),\2
		ENDM


getMore		MACRO
		move.b	(\1)^3(RcBUS),\2
		ENDM

*
* macro to deselect an interface
*
deselBUS	MACRO
* empty as the Milan ISA bus does not need deselecting
		ENDM



******** RAM2NE *****************************************************************
* This is a macro for speed
* put # of bytes in register arg2 to NE from location pointed to by arg1.
*
* in:	arg1	address register source address
*	arg2	data register (w) # of bytes to put; must not be d0!
*
* both registers plus d0 get destroyed.
* Assembler inst. REPT does not work inside a macro, we repeate explicitly
	
RAM2NE		MACRO
		ext.l	\2			; clear upper word
		ble	.doNothing\@		; nothing to do?

		lea	(NE_DATAPORT)^3(RcBUS),RdBUS

* put the packet; optimized for speed, we do 8 bytes at once
		ror.l	#3,\2			; store remainder in upper word
		bra.b	.Rb1\@

.Rt1\@		move.b	(\1)+,(RdBUS)
		move.b	(\1)+,(RdBUS)
		move.b	(\1)+,(RdBUS)
		move.b	(\1)+,(RdBUS)
		move.b	(\1)+,(RdBUS)
		move.b	(\1)+,(RdBUS)
		move.b	(\1)+,(RdBUS)
		move.b	(\1)+,(RdBUS)
.Rb1\@		dbra	\2,.Rt1\@

		clr.w	\2			; prepare for remainder
		rol.l	#3,\2			; restore remainder bits
		bra.b	.Rb2\@

.Rt2\@		move.b	(\1)+,(RdBUS)		; put the remaining bytes
.Rb2\@		dbra	\2,.Rt2\@

.doNothing\@
		ENDM



******** NE2RAM *****************************************************************
* This is a macro for speed
* get # of bytes in register arg2 to RAM location pointed to by arg1.
*
* in:	arg1	address register destination address
*	arg2	data register (w) # of bytes to get
*
* both registers get destroyed.
* Assembler inst. REPT does not work inside a macro, we repeate explicitly

NE2RAM		MACRO
		lea	(NE_DATAPORT)^3(RcBUS),RdBUS	; register to point to data bus
		ext.l	\2			; clear upper word
		ble.b	.doNothing\@		; nothing to do?

* get the Packet; optimized for speed, we do 8 bytes at once.
		ror.l	#3,\2			; store remainder in upper word
		bra.b	.Nb1\@

.Nt1\@		move.b	(RdBUS),(\1)+
		move.b	(RdBUS),(\1)+
		move.b	(RdBUS),(\1)+
		move.b	(RdBUS),(\1)+
		move.b	(RdBUS),(\1)+
		move.b	(RdBUS),(\1)+
		move.b	(RdBUS),(\1)+
		move.b	(RdBUS),(\1)+
.Nb1\@		dbra	\2,.Nt1\@

		clr.w	\2				; prepare for remainder
* rol.l #2 instead of #3 because we write TWO bytes in a loop iteration not a byte
* thus the lowest significant bit (which shall be 0 anyway) is not used
		rol.l	#2,\2				; restore remainder bits
		bra.b	.Nb2\@

.Nt2\@		move.b	(RdBUS),(\1)+
		move.b	(RdBUS),(\1)+
.Nb2\@		dbra	\2,.Nt2\@

.doNothing\@
		ENDM



*********************************************************************************

