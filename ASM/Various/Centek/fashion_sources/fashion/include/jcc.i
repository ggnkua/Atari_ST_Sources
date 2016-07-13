	text
* Permet des saut conditionnel dans des routines

jeq	macro	; adresse
	bne.s	*+8
	jsr	\1
	endm
	*-------*
jne	macro	; adresse
	beq.s	*+8
	jsr	\1
	endm
	*-------*
jcc	macro	; adresse
	bcs.s	*+8
	jsr	\1
	endm
	*-------*
jcs	macro	; adresse
	bcc.s	*+8
	jsr	\1
	endm
	*-------*
jvc	macro	; adresse
	bvs.s	*+8
	jsr	\1
	endm
	*-------*
jvs	macro	; adresse
	bvc.s	*+8
	jsr	\1
	endm
	*-------*
jge	macro	; adresse
	blt.s	*+8
	jsr	\1
	endm
	*-------*
jgt	macro	; adresse
	ble.s	*+8
	jsr	\1
	endm
	*-------*
jhi	macro	; adresse
	bls.s	*+8
	jsr	\1
	endm
	*-------*
jle	macro	; adresse
	bgt.s	*+8
	jsr	\1
	endm
	*-------*
jls	macro	; adresse
	bhi.s	*+8
	jsr	\1
	endm
	*-------*
jlt	macro	; adresse
	bge.s	*+8
	jsr	\1
	endm
	*-------*
jmi	macro	; adresse
	bpl.s	*+8
	jsr	\1
	endm
	*-------*
jpl	macro	; adresse
	bmi.s	*+8
	jsr	\1
	endm
	*-------*

	move.w	#0,d0
	jne	yop
	nop
yop
	nop
	rts