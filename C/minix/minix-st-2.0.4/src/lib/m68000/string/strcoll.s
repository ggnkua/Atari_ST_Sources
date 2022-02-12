#
/* strcoll.s
 *
 *	int strcoll(s1, s2)
 *	char *s1;
 *	char *s2;
 *
 * Compares the strings s1 and s2 in light of the current locale setting
 * WARNING: This is a bogus implementation, since I have no idea what
 *          ANSI is prattling about with respect to locale.
 */
	.sect .text;.sect .rom;.sect .data;.sect .bss


	.define _strcoll

	.sect .text
_strcoll:
	link	a6,#0
	move.l	12(a6),-(sp)
	move.l	8(a6),-(sp)
	jsr	_strcmp
	add.l	#8,sp
	unlk	a6
	rts

