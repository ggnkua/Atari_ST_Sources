*	char *lmemcpy(dest, source, len)
*		register char *dest;
*		register char *source;
*		register unsigned long len;
* 06.05.90 Jan Bolt

.text
.globl _lmemcpy
_lmemcpy:
	move.l	4(sp),a1		; dest
	move.l	8(sp),a0		; source
	move.l	12(sp),d1 	; len
	beq		lmemcpy9		; done
	move.l	a1,d0
	move.l	a0,d2		; test alignment
	eor.l	d2,d0		; of dest & source
	btst 	#0,d0
	bne		lmemcpy7		; different
	btst 	#0,d2
	beq		lmemcpy0		; both even
	move.b	(a0)+,(a1)+	; copy first byte
	subq.l	#1,d1		; and reduce count
lmemcpy0:
	move.l	d1,d2		; save full count value
	lsr.l	#1,d1		; convert to word count
	move.w	d1,d0		; # of extra words to copy
	swap 	d1			; # of 64Kword blocks to copy
	bra		lmemcpy2
lmemcpy1:
	move.w	(a0)+,(a1)+	; extra bytes copy loop
lmemcpy2:
	dbra 	d0,lmemcpy1
	bra		lmemcpy6
lmemcpy3:
	move.l	#$2000,d0 	; 64Kwords = 8K * 4long count
	bra		lmemcpy5
lmemcpy4:
	move.l	(a0)+,(a1)+	; 64Kword copy loop
	move.l	(a0)+,(a1)+	; 4 longs at a time
	move.l	(a0)+,(a1)+	; or, 16 word at a time
	move.l	(a0)+,(a1)+	; or, 32 bytes at a time
lmemcpy5:
	dbra 	d0,lmemcpy4
lmemcpy6:
	dbra 	d1,lmemcpy3
	btst 	#0,d2		; extra odd byte to copy?
	beq		lmemcpy12
	move.b	(a0)+,(a1)+	; copy last byte
	bra		lmemcpy12
lmemcpy7:
	move.l	d1,d0
	and.w	#$7,d0		; bytes to copy
	lsr.l	#3,d1		; / 8
	move.w	d1,d2		; 8b blocks to copy
	swap 	d1			; 512kb blocks to copy
	bra		lmemcpy9
lmemcpy8:
	move.b	(a0)+,(a1)+
lmemcpy9:
	dbra 	d0,lmemcpy8	; copy bytes
	bra		lmemcpy11
lmemcpy10:
	move.b	(a0)+,(a1)+	; copy 8 bytes
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
lmemcpy11:
	dbra 	d2,lmemcpy10
	dbra 	d1,lmemcpy10
lmemcpy12:
	move.l	4(sp),d0		; return dest
	rts

