#include <minix/config.h>
#if ( CHIP == M68000 )
/* memmove.s
 *
 *	void *memmove(s1, s2, n)
 *	void *s1;
 *	void *s2;
 *	size_t n;
 *
 * Moves a block of memory (safely).
 * Calls memcpy(), so memcpy() had better be safe.
 * Henry Spencer's routine is fine.
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _memmove

	.sect .text
_memmove:
	link	a6,#0
	move.w	16(a6),-(sp)
	move.l	12(a6),-(sp)
	move.l	8(a6),-(sp)
	jsr	_memcpy
	lea	10(sp),sp
	unlk	a6
	rts
#endif

