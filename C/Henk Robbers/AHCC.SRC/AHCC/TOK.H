/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * tok.h
 */

/* Preconceptual phase characters (as used in tok_next ev )
   before matchop() eg ATARI ST/TT physical characterset			*/

#define DECIMALP	'.'
#define LONGTOK		'l'
#define LongTok		'L'
#define REALTOK		'f'
#define RealTok		'F'
#define UNSTOK		'u'
#define LETTERNL	'n'
#define NEWLINE		'\n'
#define PCEOT		0x1a
#define NLSTRING	"\n"
#define LETTERALRM	'a'
#define ALARM		'\a'
#define LETTERBS	'b'
#define BACKSPACE	'\b'
#define LETTERHT	't'
#define HORTAB		'\t'
#define LETTERCRT	'r'
#define CARRETURN	'\r'
#define LETTERFF	'f'
#define FORMFEED	'\f'
#define LETTERVT	'v'
#define VERTAB		'\v'
#define DIGITNAUGHT	'0'
#define DIGITSEVEN	'7'
#define DIGITNINE	'9'
#define DIGITTEN	'a'
#define DIGITFIFTEEN 'f'
#define HEXPREF		'x'
#define OCTALPREF	'0'
#define LSTRINGTOK	'<'
#define RSTRINGTOK	'>'
#define PLUSSIGN	'+'
#define MINUSSIGN   '-'
#define	EXPONENT	'E'
#define Exponent	'e'

#define PREPWARN    '#'
#define NOTOK -1

extern LEX_RECORD * cur_LEX;

#define tok_is(tok) (curtok->token eq tok)
#define tok_ne(tok) (curtok->token ne tok)

IpV 	tok_next,
		tok_prep;
void	tok_to_nl	(bool);
void	kw_tok		(XP);
char	ishexa		(short);
char	is_escape	(short);
