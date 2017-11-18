
		globl	_NEW_BUT,_BUT_ADDR,_BUT_STATE

*	The true button state is saved  and the Left button
*	flag is passed back to the AES mouse button interrupt routine. 
*
*  in:
*	_BUT_ADDR contains the address of the AES interrupt routine
*	that deals with mouse buttons.
*
* out:
*	_BUT_STATE contains the actual mouse button state prior to testing
*	to be read by the calling program.
*
*	There is probably more information in the other registers,
*	perhaps last state ,double click, etc. ??

_NEW_BUT:	tst	d0
		beq	place
		move.w	d0,_BUT_STATE
		move.w	#1,d0			; always return left button
place:		move.l	_BUT_ADDR,-(sp)
		rts				; jmp to AES subroutine


_BUT_ADDR:	ds.l	1
_BUT_STATE:	ds.w	1

