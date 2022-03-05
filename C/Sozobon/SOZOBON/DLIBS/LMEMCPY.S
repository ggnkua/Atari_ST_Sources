*	char *lmemcpy(dest, source, len)
*		register char *dest;
*		register char *source;
*		register unsigned long len;

.text
.globl _lmemcpy
_lmemcpy:
	move.l	4(a7),a1	; destination
	move.l	8(a7),a0	; source
	move.l	12(a7),d1	; number of bytes
	move.l	a1,d0
	btst	#0,d0		; odd alignment?
	beq	lmemcpy0
	move.b	(a0)+,(a1)+	; copy first byte
	subq.l	#1,d1		; and reduce count
lmemcpy0:
	move.l	d1,d2		; save full count value
	lsr.l	#1,d1		; convert to word count
	move.w	d1,d0		; # of extra words to copy
	swap	d1		; # of 64Kword blocks to copy
	bra	lmemcpy2
lmemcpy1:
	move.w	(a0)+,(a1)+	; extra bytes copy loop
lmemcpy2:
	dbra	d0,lmemcpy1
	bra	lmemcpy6
lmemcpy3:
	move.l	#$2000,d0	; 64Kwords = 8K * 4long count
	bra	lmemcpy5
lmemcpy4:
	move.l	(a0)+,(a1)+	; 64Kword copy loop
	move.l	(a0)+,(a1)+	; 4 longs at a time
	move.l	(a0)+,(a1)+	; or, 16 word at a time
	move.l	(a0)+,(a1)+	; or, 32 bytes at a time
lmemcpy5:
	dbra	d0,lmemcpy4
lmemcpy6:
	dbra	d1,lmemcpy3
	btst	#0,d2		; extra odd byte to copy?
	beq	lmemcpy7
	move.b	(a0)+,(a1)+	; copy last byte
lmemcpy7:
	move.l	4(a7),d0	; return destination pointer
	rts
