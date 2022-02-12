#
/* strerror.s
 *
 *	char *strerror(errnum)
 *	int errnum;
 *
 * Map error number to descriptive string.
 * This version is obviously somewhat Unix-specific.
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.sect .data
.extern __sys_nerr, __sys_errlist
_unknown:
	.asciz	'unknown error'

	.define _strerror

	.sect .text
_strerror:
	link	a6,#0
#ifdef __MLONG__
	move.l	8(a6),d1	/* get errnum */
#else
	move.w	8(a6),d1	/* get errnum */
#endif /* __MLONG__ */
	ble	I1_3		/* errnum <= 0 ? unknown error ! */
	cmp	__sys_nerr,d1
	bge	I1_3		/* errnum >= sys_nerr ? unknown error ! */
	ext.l	d1
	asl.l	#2,d1		/* errnum *= sizeof( char * ) */
	lea	__sys_errlist,a0
	add.l	d1,a0
	move.l	(a0),d0		/* return ptr to error message */
	bra	I1_1
I1_3:
	move.l	#_unknown,d0	/* return "unknown error" */
I1_1:
	unlk	a6
	rts


