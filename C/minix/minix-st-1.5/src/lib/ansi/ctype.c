/*  ctype.c - this is the table used in ctype.h  */

#include <lib.h>
#include <ctype.h>

unsigned char __tmp;		/* temporary for 'tolower' and 'toupper' */
unsigned char __ctype[] = {
	 0,			/* isxxx(EOF) is legal for EOF -1 */
/* 000-007 */	_C,	_C,	_C,	_C,	_C,	_C,	_C,	_C,
/* 010-017 */	_C,	_S|_C,	_S|_C,	_S|_C,	_S|_C,	_S|_C,	_C,	_C,
/* 020-027 */	_C,	_C,	_C,	_C,	_C,	_C,	_C,	_C,
/* 030-037 */	_C,	_C,	_C,	_C,	_C,	_C,	_C,	_C,
/* 040-047 */	_S|_SP,	_P,	_P,	_P,	_P,	_P,	_P,	_P,
/* 050-057 */	_P,	_P,	_P,	_P,	_P,	_P,	_P,	_P,
/* 060-067 */	_N,	_N,	_N,	_N,	_N,	_N,	_N,	_N,
/* 070-077 */	_N,	_N,	_P,	_P,	_P,	_P,	_P,	_P,
/* 100-107 */	_P,	_U|_X,	_U|_X,	_U|_X,	_U|_X,	_U|_X,	_U|_X,	_U,
/* 110-117 */	_U,	_U,	_U,	_U,	_U,	_U,	_U,	_U,
/* 120-127 */	_U,	_U,	_U,	_U,	_U,	_U,	_U,	_U,
/* 130-137 */	_U,	_U,	_U,	_P,	_P,	_P,	_P,	_P,
/* 140-147 */	_P,	_L|_X,	_L|_X,	_L|_X,	_L|_X,	_L|_X,	_L|_X,	_L,
/* 150-157 */	_L,	_L,	_L,	_L,	_L,	_L,	_L,	_L,
/* 160-167 */	_L,	_L,	_L,	_L,	_L,	_L,	_L,	_L,
/* 170-177 */	_L,	_L,	_L,	_P,	_P,	_P,	_P,	_C,

/* The standard specifies that the argument is an unsigned char, so the
 * values from 0200 to 0377 must be included.
 */
/* 200- */  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
/* 240- */  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
/* 300- */  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
/* 340- */  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
};
