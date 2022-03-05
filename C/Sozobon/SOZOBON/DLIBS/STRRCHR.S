*	#include <stdio.h>
*	
*	char *strrchr(string, symbol)
*		register char *string;
*		register char symbol;
*	/*
*	 *	Return a pointer to the last occurance of <symbol> in <string>.
*	 *	NULL is returned if <symbol> is not found.
*	 */
*		{
*		register char *p = string;
*	
*		while(*string++)
*			;
*		do
*			{
*			if(*--string == symbol)
*				return(string);
*			}
*			while(string != p);
*		return(NULL);
*		}

.text
.globl _strrchr
_strrchr:
	move.l	4(a7),a0
	move.w	8(a7),d0
	move.l	a0,a1
strrchr1:
	tst.b	(a0)+
	bne	strrchr1
strrchr2:
	cmp.b	-(a0),d0
	bne	strrchr3
	move.l	a0,d0
	rts
strrchr3:
	cmp.l	a0,a1
	bne	strrchr2
	clr.l	d0
	rts
