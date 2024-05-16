linlog	ident	1,1
;
; This program, originally available on the Motorola DSP bulletin board,
; is provided under a DISCLAIMER OF WARRANTY available from Motorola DSP
; Operation, 6501 William Cannon Drive, West, Austin, Texas  78735-8598.
;
;
; Linear PCM to Companded CODEC Data Conversion Macros
;
; These macros convert 13 bit, linear fractional data into 8 bit companded
; data suitable for transmission to CODEC D/A converters used in
; telecommunications applications.  Four companded formats are
; supported for the Motorola MC14400 CODEC series and similar devices.
;
; Macro Calls:		linsm -	linear to sign magnitude conversion
;				with mu-law companding.
;			linmu -	linear to mu-law companded conversion
;				without zero code suppression.
;			lind3d4 - linear to mu-law companded conversion
;				with D3/D4 format zero code suppression.
;			linal -	linear to a-law companded conversion
;				with CCITT (G7.12) format.
;
;			No macro arguments are required.  However, these
;		   	macros assume that the scaling modes are off
;			(S1=0, S0=0).
;
; Input data is a 56 bit number in accumulator a.  Although any 56 bit
; number may be used, the 13 bit linear fraction is assumed to be in
; the most significant bits of a1.  Values outside this fractional range
; are automatically converted to a maximum positive or negative companded
; value (dynamic range limiting).
;
; Output data is in the 8 most significant bits of a1.  The 16 LSB's
; of a1 are zero.
;
;  -------------------------------------------------------
; | Sign |    Chord Number    |       Step Number         |
; | Bit  |                    |                           |
; |__23__|__22_____21_____20__|__19_____18_____17_____16__|
;
; Alters Data ALU Registers
;       x1      x0
;       a2      a1      a0      a
;       b2      b1      b0      b
;
; Alters Address Registers
;       r0
;
; Alters Program Control Registers
;       pc      sr
;
; Uses 0 locations on System Stack
;
; Latest Revision - August 17, 1988
; Tested and verified - August 17, 1988
;
; linsm - linear to sign magnitude conversion
;
linsm	macro
_bias	equ	$008400			;absolute bias = 33
;
	tfr	a,b	a,a		;save input sign, limit input data
	abs	a	#_bias,x0	;form input magnitude, get bias
	add	x0,a	#7,r0		;add bias to magnitude, get chord bar
	move		a,a		;limit again
	tst	a			;set CCR for norm instruction
	rep	#7			;find chord number by normalizing
	norm	r0,a			; biased magnitude to get step number
	asl	a			;isolate step number
	asl	a	b,b		;limit input again
	neg	b	r0,a2		;invert sign bit, get chord number
	asr	a			;combine chord and step
	asr	a
	asr	a
	asl	b			;get sign bit
	ror	a	#<$ff,x0	;combine sign, chord and step
	and	x0,a			;clear 16 LSB's
	endm
;
; linmu - linear to mu-law conversion
;
linmu	macro
_bias	equ	$008400			;absolute bias = 33
;
	tfr	a,b	a,a		;save input sign, limit input data
	abs	a	#_bias,x0	;form input magnitude, get bias
	add	x0,a	#7,r0		;add bias to magnitude, get chord bar
	move		a,a		;limit again
	tst	a			;set CCR for norm instruction
	rep	#7			;find chord number by normalizing
	norm	r0,a			; biased magnitude to get step number
	asl	a			;isolate step number
	asl	a	b,b		;limit input again
	neg	b	r0,a2		;invert sign bit, get chord number
	asr	a			;combine chord and step
	asr	a
	asr	a
	not	a			;invert 7 LSB's for mu-law
	asl	b			;get sign bit
	ror	a	#<$ff,x0	;combine sign, chord and step
	and	x0,a			;clear 16 LSB's
	endm
;
; lind3d4 - linear to mu-law conversion with zero code suppression
;
lind3d4	macro
_bias	equ	$008400			;absolute bias = 33
;
	tfr	a,b	a,a		;save input sign, limit input data
	abs	a	#_bias,x0	;form input magnitude, get bias
	add	x0,a	#7,r0		;add bias to magnitude, get chord bar
	move		a,a		;limit again
	tst	a			;set CCR for norm instruction
	rep	#7			;find chord number by normalizing
	norm	r0,a			; biased magnitude to get step number
	asl	a			;isolate step number
	asl	a	b,b		;limit input again
	neg	b	r0,a2		;invert sign bit, get chord number
	asr	a			;combine chord and step
	asr	a
	asr	a
	not	a			;invert 7 LSB's for mu-law
	asl	b			;get sign bit
	ror	a	#<$ff,x0	;combine sign, chord and step
	and	x0,a	#<$02,x0	;clear 16 LSB's
	teq	x0,a			;suppress zero code
	endm
;
; linal - linear to a-law conversion
;
linal	macro
	tfr	a,b	a,a		;save input sign, limit input data
	move		#1,a0		;force to non-zero value
	abs	a	#7,r0		;form input magnitude, get chord bar
	rep	#6			;find chord number by normalizing
	norm	r0,a			; magnitude to get step number
	jnr	<_ok			;jump if normalized
	move		(r0)-		;adjust for chord zero
_ok	asl	a			;isolate step number
	asl	a	b,b		;limit input again
	neg	b	r0,a2		;invert sign bit, get chord number
	asr	a			;combine chord and step
	asr	a
	asr	a
	asl	b			;get sign bit
	ror	a	#<$ff,x0	;combine sign, chord and step
	and	x0,a	#<$55,x0	;clear 16 LSB's
	eor	x0,a			;invert odd bits for a-law
	endm
