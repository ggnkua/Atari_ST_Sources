*	char *memmove(dest, source, len)
*		register char *dest;
*		register char *source;
*		register unsigned int len;
*	/*
*	 *	Copies the <source> block to the <dest>.  <len> bytes are
*	 *	always copied.  No terminator is added to <dest>.  A pointer
*	 *	to <dest> is returned.  Overlapping blocks ARE copied safely.
*	 */
*		{
*		register char *p = dest;
*	
*		if(source < dest)
*			{
*			dest += len;
*			source += len;
*			while(len--)
*				*--dest = *--source;
*			}
*		else
*			{
*			while(len--)
*				*dest++ = *source++;
*			}
*		return(p);
*		}

.text
.globl _memmove
_memmove:
	clr.l	d0
	move.w	12(a7),d0	; number of bytes
memmove0:
	move.l	4(a7),a1	; destination
	move.l	8(a7),a0	; source
	cmp.l	a0,a1		; check copy direction
	bls	memmove4
	add.l	d0,a0		; move pointers to end
	add.l	d0,a1
	bra	memmove2
memmove1:
	move.b	-(a0),-(a1)	; (s < d) copy loop
memmove2:
	dbra	d0,memmove1
	bra	memmove5
memmove3:
	move.b	(a0)+,(a1)+	; (s >= d) copy loop
memmove4:
	dbra	d0,memmove3
memmove5:
	move.l	4(a7),d0	; return destination pointer
	rts
