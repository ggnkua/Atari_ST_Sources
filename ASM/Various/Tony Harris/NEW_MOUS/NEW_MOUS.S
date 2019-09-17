;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;									;
;	Change Mouse using the A_line					;
;									;
;	by Tony Harris							;
;	17/07/95							;
;									;
;	using DEVPAC 2							;
;									;
;	Set Tabs to 8							;
;									;
;	To call, simply pass the new mouse data to CHANGE_MOUSE		;
;	ie.								;
;		CHANGE_MOUSE	mouse_data				;
;									;
;	It will save and restore the d0-2/a0-2 registers		;
;									;
;	Remember that the macro CHANGE_MOUSE needs the NEW_MOUSE	;
;	routine.							;
;									;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	opt	x+			xtended debug

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

intin		equ	8
init_a		equ	$a000
transmouse	equ	$a00b
show_mouse	equ	$a009

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MACROS

change_mouse	macro
	movem.l	d0-2/a0-4,-(sp)
	lea	\1,a3
	jsr	new_mouse			new mouse routine
	movem.l	(sp)+,d0-2/a0-4
	endm

; the only parameter for this macro is the required mouse data

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

os_call	macro
	move.w	#\1,-(sp)			op code
	trap	#\2				trap number
	lea	\3(sp),sp			number to correct stack
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

program_start

	pea	mouse_text
	os_call	9,1,6				print message

	change_mouse	mouse_data

	os_call	1,1,2				wait for key press

	clr.l	-(sp)
	os_call	$4c,1,0				clean exit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

new_mouse
	dc.w	init_a				init a line
	move.l	intin(a0),a4
	move.w	#0,6(a4)
	move.w	#1,8(a4)
	add.l	#10,a4
	rept	16
	move.l	(a3)+,(a4)+			create new pointer
	endr
	dc.w	transmouse			do it !
	dc.w	init_a
	dc.w	show_mouse			now show it
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	section data

mouse_text

	dc.b	27,'H'
	dc.b	'     A_LINE MOUSE CHANGE',10,10,13
	dc.b	'!!! PRESS ANY KEY TO EXIT !!!',0
	even
	
mouse_data

	dc.w	%0000000000000000
	dc.w	%1111111111111111
	dc.w	%1111111111111110
	dc.w	%1111111111111100
	dc.w	%1111111111111000
	dc.w	%1111111111110000
	dc.w	%1111111111110000
	dc.w	%1111111111111000
	dc.w	%1111111111111100
	dc.w	%1111111111111110
	dc.w	%1111110111111110
	dc.w	%1111100011111100
	dc.w	%1111000001111000
	dc.w	%1110000000110000
	dc.w	%1100000000000000
	dc.w	%0000000000000000

mouse_mask

	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000001
	dc.w	%0000000000000011
	dc.w	%0000000000000111
	dc.w	%0000000000001110
	dc.w	%0000000000000110
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000000000000000
	dc.w	%0000001000000001
	dc.w	%0000011100000011
	dc.w	%0000111000000111
	dc.w	%0001110000001110
	dc.w	%0011100000001100
	dc.w	%1110000000000000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
