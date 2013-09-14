
		.globl	BUT_OR, BADDR, BSTATE, BREAL


*	The right and left buttons are ORed together as the Left button
*	flag and passed to the AES mouse button interrupt routine. 
*
*  in:
*	_BUT_ADDR contains the address of the AES interrupt routine
*	that deals with mouse buttons.
*
* out:
*	_BUT_STATE contains the actual mouse button state prior to ORing

		.text

BUT_OR:
		and.w	#$FFFF,d0
		tst     d0
		move.w  d0,BREAL
		beq	place
  		move.w	d0,BSTATE
		move.w	#1,d0
		
place:
;		move.l	BADDR,-(sp)
		rts				; jmp to AES subroutine

; The move.l BADDR should be in there, but in this case, it
; prevents a fall through to the AES 
                .bss

		.even

BADDR:		.ds.l	1
BSTATE:		.ds.w	1
BREAL:		.ds.w	1
