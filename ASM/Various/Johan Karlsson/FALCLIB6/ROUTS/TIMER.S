*
* TIMER.S
*
*	@colour[value.l]  macro
*	 sets backround colour to value. Supervisor only!
*	 (destroys nothing)
*


@colour		macro
		move.l	\1,$ffff9800.w
		endm
		
