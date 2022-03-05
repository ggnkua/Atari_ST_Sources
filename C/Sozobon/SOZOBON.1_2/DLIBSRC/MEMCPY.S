*	char *memcpy(dest, source, len)
*		register char *dest;
*		register char *source;
*		register unsigned int len;

.text
.globl _memcpy
_memcpy:
	move.l	4(a7),a1	; destination
	move.l	8(a7),a0	; source
	clr.l	d1
	move.l	12(a7),d1	; number of bytes
	move.l	a1,d0
	btst	#0,d0		; odd alignment?
	beq	memcpy0
	move.b	(a0)+,(a1)+	; copy first byte
	subq.l	#1,d1		; and reduce count
memcpy0:
	move.l	d1,d2		; save full count value
	lsr.l	#1,d1		; convert to word count
	bra	memcpy2
memcpy1:
	move.w	(a0)+,(a1)+	; word copy loop
memcpy2:
	dbra	d1,memcpy1
	btst	#0,d2		; extra odd byte to copy?
	beq	memcpy3
	move.b	(a0)+,(a1)+	; copy last byte
memcpy3:
	move.l	4(a7),d0	; return destination pointer
	rts
