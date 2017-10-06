*	char *memset(dest, data, len)
*		register char *dest;
*		register char data;
*		register unsigned int len;
*	/*
*	 *	Fill <dest> will <len> bytes of <data>.  A pointer to <dest>
*	 *	is returned.
*	 */
*		{
*		register char *p = dest;
*	
*		while(len--)
*			*dest++ = data;
*		return(p);
*		}

.text
.globl _memset
_memset:
	move.l	4(a7),a0	* destination
	move.w	8(a7),d0	* fill data
	move.w	10(a7),d1	* number of bytes
	bra	memset2
memset1:
	move.b	d0,(a0)+	* fill loop
memset2:
	dbra	d1,memset1
	move.l	4(a7),d0	* return destination pointer
	rts
