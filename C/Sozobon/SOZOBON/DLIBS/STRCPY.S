*	char *strcpy(dest, source)
*		register char *dest, *source;
*		{
*		register char *p = dest;
*	
*		while(*dest++ = *source++)
*			;
*		return(p);
*		}

.text
.globl _strcpy
_strcpy:
	move.l	4(a7),a1	; destination
	move.l	8(a7),a0	; source
	clr.l	d0
strcpy1:
	move.b	(a0)+,(a1)+	; copy byte
	bne	strcpy1		; loop, unless byte was zero
	move.l	4(a7),d0	; return destination pointer
	rts
