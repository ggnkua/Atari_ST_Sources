* memcpy by David Brooks  1/23/89
*        changed to move in 8-byte blocks and shortened slightly
*	 by Dale Schumacher and John Stanley  3/18/89
*
*	char *memcpy(dest, source, len)
*		char *dest		at 4(sp)
*		char *source		at 8(sp)
*		unsigned int len	at 12(sp)
*
* This is generally optimized around the commonest case (even alignment,
* more than 8 bytes) but the time savings and space cost are minimal.
* Also, we avoid using "btst #n,dn" because of a bug in the Sozobon
* assembler.

.text
.globl _memcpy
_memcpy:
	lea	12(a7),a2	; Point to argument list
	move.w	(a2),d2		; d2 = len
	move.l	-(a2),a0	; a0 = source
	move.l	-(a2),a1	; a1 = dest
	move.l	a1,d0		; d0 = dest, ready to return

	move.l	a0,d1		; Check for odd/even alignment
	add.w	a1,d1		; This is really eor.w on the lsb.  Really.
	asr.w	#1,d1		; Get lsb into C.  If it's 1, alignment is off.
	bcs	memcpy5		; Go do it slowly

	move.l	a0,d1		; Check for initial odd byte
	asr.w	#1,d1		; Get lsb
	bcc	memcpy1
	subq.w	#1,d2		; Move initial byte
	bcs	memcpy6		;  (unless d2 was 0).  We could use dbra here,
	move.b	(a0)+,(a1)+	;   but that would have been bigger.
memcpy1:
	moveq.l	#7,d1		; Split into a 8-byte block count and remainder
	and.w	d2,d1
	lsr.w	#3,d2
	bra	memcpy3		; Enter loop.  Note d2 could equal 0.
memcpy2:
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
memcpy3:
	dbra	d2,memcpy2
	move.w	d1,d2		; Move remainder count to loop control
	bra	memcpy5		; Enter final loop.  Again d2 could equal 0.
memcpy4:
	move.b	(a0)+,(a1)+	; Handle the odd/even aligned case
memcpy5:
	dbra	d2,memcpy4
memcpy6:
	rts			; All done.
