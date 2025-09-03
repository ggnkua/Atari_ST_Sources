*	char *bzero(dest, len)
*		register char *dest;
*		register unsigned int len;
* 100690 modified by Jan Bolt

.text
.globl _bzero
_bzero:
	move.l	4(a7),a0	; destination
	clr.l	d1
	move.w	8(a7),d1	; number of bytes
	move.l	a0,d0
	btst #0,d0		; odd alignment?
	beq	bzero0
	clr.b	(a0)+		; zero first byte
	subq.l	#1,d1		; and reduce count
bzero0:
	move.l	d1,d2		; save full count value
	lsr.l	#1,d1		; convert to word count
	bra	bzero2
bzero1:
	clr.w	(a0)+		; word zero loop
bzero2:
	dbra d1,bzero1
	btst #0,d2		; extra odd byte to copy?
	beq	bzero3
	clr.b	(a0)+		; zero last byte
bzero3:
	move.l	4(a7),d0	; return destination pointer
	rts
