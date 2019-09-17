*
* EXIT.S
*
*	@exitifspace  macro
*	 branches to exit if space has been pressed
*	 (destroys nothing)
*


@exitifspace	macro
		cmp.b	#$39,$fffffc02.w
		beq	exit
		endm


