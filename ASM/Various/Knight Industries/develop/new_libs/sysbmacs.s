*****************************
*		  *
* System  Macro definitions *
*		  *
*****************************


; Find cookie

get_cookie	MACRO
	move.l	#\1,d3
	bsr	cookie_search
	ENDM

; display a dialog

displayDialog	MACRO
	move.w	\1,d0
	move.w	\2,d1
	move.l	\3,a0
	jsr	findDialogSpace
	jsr	createDialogWindow
	ENDM

; copy a string

stringCopy	MACRO
	move.l	\1,a0
	move.l	\2,a1
	jsr	copyString
	ENDM

; find string length

stringLength	MACRO
	move.l	\1,a0
	moveq.w	#0,d1
	jsr	lengthString
	ENDM

; truncate a string

stringTruncate	MACRO
	move.l	\1,a0
	move.b	\2,d0
	bsr	truncateString
	ENDM

; locate value in a string

stringLocate	MACRO
	move.l	\1,a0
	move.b	\2,d0
	bsr	locateString
	ENDM

; convert string to value (long)

val	MACRO
	move.l	\1,a0
	jsr	valueString
	ENDM

; convert value to string (long)

str	MACRO
	move.l	\1,d0
	move.l	\2,a0
	jsr	valueToString
	ENDM