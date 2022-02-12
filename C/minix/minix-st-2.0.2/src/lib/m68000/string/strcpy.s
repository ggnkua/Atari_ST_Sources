#
/* strcpy.s
 *
 *	char *strcpy(dst, src)
 *	char *dst;
 *	_CONST char *src;
 *
 * copy string src to dst
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strcpy

	.sect .text
_strcpy:
	move.l	4(sp),a0	! get dst
	move.l	a0,d0		! return dst
	move.l	8(sp),a1	! get src
I1_3:
	move.b	(a1)+,(a0)+
	bne	I1_3		! EOS of src reached ?

	rts

