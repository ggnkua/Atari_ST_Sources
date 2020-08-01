/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	sttok.h
 *
 *	statement keyword tokens
 */

#ifndef ENUMS
#define K_GOTO		'a'
#define K_RETURN	'b'
#define K_BREAK		'c'
#define K_CONTINUE	'd'

#define K_IF		'e'
#define K_ELSE		'f'
#define K_FOR		'g'
#define K_DO		'h'
#define K_WHILE		'i'
#define K_SWITCH	'j'

#define K_CASE		'k'
#define K_DEFAULT	'l'
#define K_ASM		'm'

#define K_SIZEOF	'n'

#else
enum {
	K_GOTO = 'a', K_RETURN, K_BREAK, K_CONTINUE,
	K_IF, K_ELSE, K_FOR, K_DO, K_WHILE, K_SWITCH,
	K_CASE, K_DEFAULT, K_ASM,
	K_SIZEOF,
};
#endif
