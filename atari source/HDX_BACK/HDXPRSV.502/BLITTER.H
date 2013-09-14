;+
;  Oct 22 1990	ml.	Created this.
;-

; BLiTTER base address

bBLiTTER	equ	$ff8a00

; BLiTTER register offsets

SRCXINC		equ	$20	; SouRCe X INCrement
SRCYINC		equ	$22	; SouRCe Y INCrement
SRCADDR		equ	$24	; SouRCe ADDRess
ENDMASK1	equ	$28	; ENDMASK 1
ENDMASK2	equ	$2a	; ENDMASK 2
ENDMASK3	equ	$2c	; ENDMASK 3
DESTXINC	equ	$2e	; DESTination X INCrement
DESTYINC	equ	$30	; DESTination Y INCrement
DESTADDR	equ	$32	; DESTination ADDRess
XCNT		equ	$36	; X CouNT
YCNT		equ	$38	; Y CouNT
HOP		equ	$3a	; Halftone OPerations
OP		equ	$3b	; logic OPerations
BUSY		equ	$3c	; register that has the BUSY bit
SKEW		equ	$3d	; SKEW

