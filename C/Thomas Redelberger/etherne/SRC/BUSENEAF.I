*********************************************************************************
* Bus access macros for ST/TT ACSI bus for register base hardware		*
* Version for my ACSI-NE2000 interface hardware in fast mode for newer		*
* NE2000 clones									*
*										*
*	Copyright 2002 Dr. Thomas Redelberger					*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
* processor registers are used as follows:					*
*	d0:	as ACSI is w. and you mostly need b. d0 stores intermediate	*
*	d6.w:	will contain $88;	do not change it!			*
*	d7.w:	will contain $8a;	do not change it!			*
*										*
*	a5:	will point to dmamodus;	do not change it!			*
*	a6:	will point to diskctl;	do not change it!			*
*										*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*										*
*********************************************************************************
* $Id: buseneaf.i 1.3 2002/06/08 16:26:52 Thomas Exp Thomas $
*

*
* manifest constants
*

TheACh		EQU	$60		; ACSI channel of NE hardware (=3)
NilACh		EQU	0		; inactive ACSI channel used to deselect the
					; ACSI/ISA hardware
BUGGY_HW	EQU	1		; if defined enables code to handle buggy hardware

*
* hardware addresses
*

gpip		EQU	$fffffa01	; (b) 68901 input register (unused)

diskctl		EQU	$ffff8604	; (w) disk controller data access
dmamodus	EQU	$ffff8606	; (w) DMA mode control
dmahigh		EQU	$ffff8609	; (b) DMA base address high (unused)
dmamid		EQU	$ffff860b	; (b) DMA base address medium (unused)
dmalow		EQU	$ffff860d	; (b) DMA base address low (unused)


*
* addresses of system variables
*

flock		EQU	$43e		; (w) semaphor to lock floppy usage of DMA


*
* macros
*

lockBUS		MACRO
		moveq	#-1,d0			; preset error code
		tas	flock\w			; check for race about ACSI bus and
		bne	.doNothing		; if somebody owns the bus we quit
		tas	flock+1\w		; Holzauge: we do *both* bytes
		bne	.doNothing
		ENDM

lockBUSWait	MACRO
* more elegant would be to wait for the bus (e.g. dma_begin in MagiC)
* there should be a timeout based on _hz_200 (and then branch to .doNothing)

.lt1\@		tas	flock\w			; check for race about ACSI bus and
		bne.b	.lwait\@		; if somebody owns the bus we *wait*
		tas	flock+1\w		; Holzauge: we do *both* bytes
		beq.b	.lc1\@

.lwait\@	bsr	_appl_yield		; wait
		bra.b	.lt1\@

.lc1\@						; proceed
		ENDM


unlockBUS	MACRO
		clr.w	flock\w			; let other tasks access ACSI bus
		ENDM

unlockBUSWait	MACRO
* we should relinquish the bus (e.g. dma_end in MagiC)
		clr.w	flock\w			; let other tasks access ACSI bus
		ENDM


RcBUS		EQUR	a5
RdBUS		EQUR	a6
Ra1l		EQUR	d6
RxBUS		EQUR	d6			; synonym for Ra1l in NE.S
Ra1h		EQUR	d7
RyBUS		EQUR	d7			; synonym for Ra1h in NE.S


ldBUSRegs	MACRO				; for faster access to hardware
		lea	dmamodus\\w,RcBUS	; two slashes because \w would be the 33th macro argument
		lea	diskctl\\w,RdBUS
* what has to be written to dmamodus before and after to write a byte with A1=low
		move	#%010001000,Ra1l	; =$088 A1=0 R_W=1
		move	#%010001010,Ra1h	; =$08a A1=1 R_W=1
;			  ||  || |
;			  ||  || A1
;			  ||  |0=flop, 1=DMA
;			  ||  0=flop,DMA, 1=SecCntReg
;			  |0=DMA enable, 1=DMA disable
;			  0=R_W=1 (read), 1=R_W=0 (write)
; R_W is only effective in DMA mode. Otherwise state of R_W line reflects direction of move.w
		ENDM


putBUS		MACRO
		move	Ra1l,(RcBUS)		; A1 gets low
		move	#TheACh+\2,(RdBUS)	; set register selection via ACSI channel
		move	Ra1h,(RcBUS)		; A1 gets high again
		move	\1,(RdBUS)		; write to register
		ENDM


putMore		MACRO
		move	\1,(RdBUS)		; write to register
		ENDM


putBUSi		MACRO
		putBUS	#\1,\2
		ENDM


getBUS		MACRO
		move	Ra1l,(RcBUS)		; A1 gets low
		move	#TheACh+\1,(RdBUS)	; set register selection via ACSI channel
		move	Ra1h,(RcBUS)		; A1 gets high again
		move	(RdBUS),\2		; read from register
		ENDM


getMore		MACRO				; arg 1 is not used!
		move	(RdBUS),\2		; read from register
		ENDM

*
* macro to deselect an interface by selecting ACSI device 0 
*
deselBUS	MACRO
		move	Ra1l,(RcBUS)		; A1 gets low
		move	#NilACh,(RdBUS)	; select unused ACSI channel to deselect The device
		move	Ra1h,(RcBUS)		; A1 gets hi again
		move	#$80,(RcBUS)		; prepare ACSI bus for floppy
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
		subq.w	#2,\2			; first two puts are outside loop
		ble.b	.doNothing\@		; nothing to do?
		move.b	(\1)+,d0
		putBUS	d0,NE_DATAPORT		; this sets the NE IO address
		move.b	(\1)+,d0
		putMore	d0,NE_DATAPORT

* put the packet; optimized for speed, we do 8 bytes at once
		ror.l	#3,\2			; store remainder in upper word
		bra.b	.Rb1\@

.Rt1\@		move.b	(\1)+,d0		; a fool designed word access to ACSI port
		putMore	d0,NE_DATAPORT		; that prevents that we do the faster
		move.b	(\1)+,d0		; putMore (\1)+,NE_DATAPORT
		putMore	d0,NE_DATAPORT
		move.b	(\1)+,d0
		putMore	d0,NE_DATAPORT
		move.b	(\1)+,d0
		putMore	d0,NE_DATAPORT
		move.b	(\1)+,d0
		putMore	d0,NE_DATAPORT
		move.b	(\1)+,d0
		putMore	d0,NE_DATAPORT
		move.b	(\1)+,d0
		putMore	d0,NE_DATAPORT
		move.b	(\1)+,d0
		putMore	d0,NE_DATAPORT
.Rb1\@		dbra	\2,.Rt1\@

		clr.w	\2			; prepare for remainder
		rol.l	#3,\2			; restore remainder bits
		bra.b	.Rb2\@

.Rt2\@		move.b	(\1)+,d0
		putMore	d0,NE_DATAPORT		; put the remaining bytes
.Rb2\@		dbra	\2,.Rt2\@

.doNothing\@
		ENDM



******** NE2RAM *****************************************************************
* This is a macro for speed
* get # of bytes in register arg2 to RAM location pointed to by arg1.
*
* in:	arg1	address register destination address
*	arg2	data register (w) # of bytes to get; must not be d0!
*
* both registers plus d0 get destroyed.
* Assembler inst. REPT does not work inside a macro, we repeate explicitly

NE2RAM		MACRO
		ext.l	\2			; clear upper word
		subq.w	#2,\2			; first two gets are outside loop
		ble.b	.doNothing\@		; nothing to do?
		getBUS	NE_DATAPORT,d0		; this sets the NE IO address
		move.b	d0,(\1)+
		getMore	NE_DATAPORT,d0
		move.b	d0,(\1)+

* get the Packet; optimized for speed, we do 8 bytes at once.
		ror.l	#3,\2			; store remainder in upper word
		bra.b	.Nb1\@

.Nt1\@		getMore	NE_DATAPORT,d0		; a fool designed word access to ACSI port
		move.b	d0,(\1)+		; that prevents that we do a faster
		getMore	NE_DATAPORT,d0		; getMore NE_DATAPORT,(\1)+
		move.b	d0,(\1)+
		getMore	NE_DATAPORT,d0
		move.b	d0,(\1)+
		getMore	NE_DATAPORT,d0
		move.b	d0,(\1)+
		getMore	NE_DATAPORT,d0
		move.b	d0,(\1)+
		getMore	NE_DATAPORT,d0
		move.b	d0,(\1)+
		getMore	NE_DATAPORT,d0
		move.b	d0,(\1)+
		getMore	NE_DATAPORT,d0
		move.b	d0,(\1)+
.Nb1\@		dbra	\2,.Nt1\@

		clr.w	\2				; prepare for remainder
		rol.l	#3,\2				; restore remainder bits
		bra.b	.Nb2\@

.Nt2\@		getMore	NE_DATAPORT,d0			; get the remaining bytes
		move.b	d0,(\1)+
.Nb2\@		dbra	\2,.Nt2\@

.doNothing\@
		ENDM



*********************************************************************************
