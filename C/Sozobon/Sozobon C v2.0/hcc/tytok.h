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
 *	tytok.h
 *
 *	keyword token values
 */

#ifndef ENUMS
#define K_EXTERN	'A'
#define K_AUTO		'B'
#define K_REGISTER	'C'
#define K_TYPEDEF	'D'
#define K_STATIC	'E'

#define ENUM_SC		K_STATIC+1	/* storage class for enum item */
#define HERE_SC		K_STATIC+2	/* storage class for glb def */
#define FIRST_SC	K_EXTERN
#define LAST_SC		K_STATIC

#define T_UCHAR		'F'
#define T_ULONG		'G'

#define K_LONG		'H'
#define K_SHORT		'I'
#define K_UNSIGNED	'J'

#define K_INT		'K'
#define K_CHAR		'L'
#define K_FLOAT		'M'
#define K_DOUBLE	'N'
#define K_VOID		'O'

#define FIRST_BAS	T_UCHAR
#define LAST_BAS	K_VOID

#define K_UNION		'P'
#define K_ENUM		'Q'
#define K_STRUCT	'R'
#else
#define FIRST_SC	K_EXTERN
#define LAST_SC		K_STATIC
#define FIRST_BAS	T_UCHAR
#define LAST_BAS	K_VOID
enum {
	K_EXTERN = 'A', K_AUTO, K_REGISTER, K_TYPEDEF, K_STATIC,
	ENUM_SC, HERE_SC,
	T_UCHAR, T_ULONG,
	K_LONG, K_SHORT, K_UNSIGNED,
	K_INT, K_CHAR, K_FLOAT, K_DOUBLE, K_VOID,
	K_UNION, K_ENUM, K_STRUCT
};
#endif
