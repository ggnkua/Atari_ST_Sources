#
/* strstr.s
 *
 *	char *strstr(s, wanted)
 *	_CONST char *s;
 *	_CONST char *wanted;
 *
 * find first occurrence of wanted in s
 * returns found string, or NULL if none
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strstr

	.sect .text
_strstr:
	link	a6,#0
	movem.l	d6/d7/a5/a4,-(sp)
	move.l	8(a6),a5	/* get s */
	move.l	12(a6),a4	/* get wanted */
	move.b	(a4),d6		/* get wanted[0] */
	beq	I1_3		/* wanted[0] == EOS ? */
	move.l	a4,-(sp)
	jsr	_strlen
	add.l	#4,sp
	move.w	d0,d7		/* len = strlen( s ) */
I1_8:
	move.b	(a5)+,d0
	beq	I1_5		/* *s++ == EOS ? */
	cmp.b	d6,d0
	bne	I1_8		/* *s != wanted[0] */
	move.l	a5,a0
	sub.l	#1,a0		/* s is one to far */
	move.w	d7,-(sp)
	move.l	a4,-(sp)
	move.l	a0,-(sp)
	jsr	_strncmp	/* stnmp( s, wanted, len ) */
	lea	10(sp),sp
	tst	d0
	bne	I1_8		/* equal ? no */
	sub.l	#1,a5		/* s is one to far */
I1_3:
	move.l	a5,d0		/* return s */
	bra	I1_1
I1_5:
	move.l	#0,d0		/* return NULL */
I1_1:
	movem.l	(sp)+,d6/d7/a5/a4
	unlk	a6
	rts
	
