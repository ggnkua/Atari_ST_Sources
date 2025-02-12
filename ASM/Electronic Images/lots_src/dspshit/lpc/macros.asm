;***************************************************************
;* MACROS.ASM -- General Purpose Macros 		       *
;*							       *
;* Copyright (C) 1990-1992  by Alef Null. All rights reserved. *
;* Author(s): Jarkko Vuori, OH2LNS			       *
;* Modification(s):					       *
;***************************************************************

;********************
;*  Useful macros   *
;********************

; macro for immediate move
movi	macro	data,dest
	move		    #data,a1
	move		    a1,dest
	endm
movib	macro	data,dest
	move		    #data,b1
	move		    b1,dest
	endm


;********************
;*    Global LPC    *
;* codec parameters *
;********************

N	equ	240				    ; window size
M	equ	160				    ; frame size
P	equ	10				    ; number of LPC coefficients
voiced	equ	6				    ; confidence threshold for voicing
boost	equ	3				    ; gain boosting for unvoiced sounds
monopit equ	70				    ; constant pitch in monotonic mode
filter	equ	79				    ; filter lenght for Gold-Rabiner low-pass
poly	equ	$10800				    ; random number generator polynomial (x^17 + x^12 + 1)

whisper equ	0				    ; whisper mode flag bit
silence equ	1				    ; silence flag bit
loopb	equ	2				    ; loopback mode flag bit
monot	equ	3				    ; monotone mode flag bit
ipolate equ	8				    ; interpolate flag (for synthesis part only)
