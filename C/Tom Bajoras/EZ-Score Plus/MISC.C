#include <stdio.h>
#include <osbind.h>

int errno;	/* UNIX error global */
long _seed;	/* random number variable */

_blockmv()
/* 
    Block move routine. Address of block to move from goes in A1. Destination
    address goes in A0. D0 contains the number of words to move minus 1.
    Contents of A1 are not changed. Contents of A0 and D0 are destroyed.
*/
{
#ifndef LINT
    asm {
		move.l	A1, -(A7)			; save A1
	lp:	move	(A1)+, (A0)+
		dbf		D0, lp
		move.l	(A7)+, A1			;restore A1
    }
#endif
}

_blockcmp()
/* 
    Block compare routine. Addresses of blocks are in A0 and A1.
*/
{
#ifndef LINT
    asm {
		move.l	A1, -(A7)			; save A1
	lp:	cmpm	(A1)+, (A0)+
		dbne	D0, lp
		move.l	(A7)+, A1			;restore A1
    }
#endif
}

long _newptr(size)
long size;
{
	return Malloc(size);
}

_disposptr(ptr)
char *ptr;
{
	return Mfree(ptr);
}


/******************************************************************************/
/**** Defnitions that make links possible but really to need be written for ST*/
/******************************************************************************/

