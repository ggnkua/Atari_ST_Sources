*************************************************
*						*
* int blktst(ptr,val,count);			*
* long *ptr, val;				*
* long count;					*
*						*
* 'count' is the number of BYTES in the buffer.	*
* Returns TRUE if each longword in the block	*
* equals 'val' or FALSE if there are any other	*
* values there.					*
* non-0 : match;	0: don't match;		*
*						*
*************************************************

_blktst::
	move.l	4(sp),a0	; a0 := start of buffer
	move.l	8(sp),d0	; d0 := value to compare against
	move.l	$c(sp),d1	; d1 := number of bytes
	lsr.l	#2,d1		; d1 := number of longs
	swap	d1
	move.w	d1,d2		; d2 := hi word of d1
	swap	d1

	cmp.w	d0,d0		; make sure EQ before starting the loop.
	bra.s	.end


.loop:	cmp.l	(a0)+,d0
.end:	dbne	d1,.loop
	dbne	d2,.loop

	seq.b	d0		; ccr is still 'eq' if last long == val,
	and.w	#$1,d0		; so this sets d0 as advertised.
	rts			; (boy, talk about short & sweet!)

