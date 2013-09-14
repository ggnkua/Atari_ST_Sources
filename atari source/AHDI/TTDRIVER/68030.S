	.macro	movecd0vbr
	dc.w	$4E7B
	dc.w	$0801
	.endm

	.macro	movecvbrd0
	dc.w	$4E7A
	dc.w	$0801
	.endm

	.macro	movecacrd0
	dc.w	$4E7A
	dc.w	$0002
	.endm

	.macro	moved0cacr
	dc.w	$4E7B
	dc.w	$0002
	.endm

; unsigned long multiply immediate producing a word in specified register
	.macro	mululwi	val,dstreg
	dc.w	$4C3C
	dc.w	\dstreg << 12
	dc.l	\val
	.endm

; unsigned long divide 32/32 -> 32r:32q
	.macro	divulr	eareg,regr,regq
	dc.w	$4C40+\eareg	; divu.l d?,
	dc.w	(\regq << 12)+\regr
	.endm
