*	#include <stdio.h>
*	
*	char *strchr(string, symbol)
*		register char *string;
*		register char symbol;
*	/*
*	 *	Return a pointer to the first occurance of <symbol> in <string>.
*	 *	NULL is returned if <symbol> is not found.
*	 */
*		{
*		do
*			{
*			if(*string == symbol)
*				return(string);
*			}
*			while(*string++);
*		return(NULL);
*		}

.text
.globl _strchr
_strchr:
	move.l	4(a7),a0
	move.w	8(a7),d0
strchr1:
	cmp.b	(a0),d0
	bne	strchr2
	move.l	a0,d0
	rts
strchr2:
	tst.b	(a0)+
	bne	strchr1
	clr.l	d0
	rts
