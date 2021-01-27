/* Copyright (c) 2006 - present by H. Robbers Amsterdam.
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

/* hierarch.h	secure hierarchic name manipulation suite's definitions */

#ifndef HIERARCH_H
#define HIERARCH_H

#ifndef PRELUDE_H
#include <prelude.h>
#endif

#include <ext.h>

#define USE_HN 1
#define CC_PATH 1

enum
{
	STR_MAX	= 255,	/* you can produce longer strings by catenation */
	DIR_MAX = 127,  /* no confusion with ext.h */
};

typedef char
	MAX_str[STR_MAX+1],
	MAX_dir[DIR_MAX+1];

/* This is a 130 byte string:
"0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
We're all going MAD!!!!!
*/

/* make use of typechecking secure string routines */
typedef struct secure_dir
{
	MAX_dir s;
} S_path;

typedef union
{
	Cstr s;
	S_path *t;
} P_path;			/* controlled coercion */

typedef struct secure_string
{
	MAX_str s;
} S_string;

typedef union
{
	char *s;
	S_string *t;
} P_string;

enum			/* for inq_xfs */
{
	DP_NOTRUNC,
	DP_AUTOTRUNC,
	DP_DOSTRUNC,
	DP_SENSITIVE   = 0,
	DP_NOSENSITIVE,
	DP_SAVE_ONLY,
	DP_TRUNC      = 5,
	DP_CASE
};

typedef struct hpart
{
	struct hpart *next, *prior;
	bool dd;		/* part name is double dot */
	char *ext;		/* ptr to extension (if > xmax else part of name */
	char n[0];
} HN_PART;


typedef struct hierarchic_name
{
	bool csens;				/* case sensitivity: if false, make upper */
	char
	    vsep,				/* volume separator */
		sep,				/* part seperator / and \ are considered same */
	    esep,				/* extension separator or beginner */
		sepe,				/* extension ender or /0 */
	    xmax,				/* max for ext; if larger its part of name (->fn) */
	    drive;				/* drive number if single letter volume */
	HN_PART *volume;		/* anything befor ':' can be a drive letter or a volume label,
	                           but also a user name which scopes the hi_name in a user's filestore,
	                           or the *NIX's ~ */
	HN_PART *first, *last;	/* list of parts between sep's */
	HN_PART *fn;			/* anything after last sep */
} HI_NAME;

#define WM 255

typedef struct
{
	struct ffblk fb;
	long i;
	char dir[WM],fn[WM],slash[2];
	bool xfs,next,deep;
} FB;

HI_NAME *	hn_make	(Cstr f, Cstr sep, short xmax);
HI_NAME *	hn_copy	(HI_NAME *hn);
char *		hn_full	(HI_NAME *hp, char *out, Cstr sep, bool dd);
char *		hn_dir	(HI_NAME *hp, char *out, Cstr sep, bool dd);
void		hn_show	(HI_NAME *hn);
void		hn_free	(HI_NAME *hn);
bool		hn_chext(HI_NAME *hn, char *newx);
void		hn_dotdot		(char *out, Cstr sep, short xmax);
void		init_dir		(short, Cstr pr);
S_path		dir_plus_name	(S_path *pad, Cstr f);
char *	 	strslash		(Cstr s);
char *	 	strrslash		(Cstr s);
char *		getsuf			(char *);
short 		findsuf			(Cstr, Cstr);
char *		getfn			(char *fn);
S_path		DIR_suffix		(MAX_dir dir, char *s);
S_path		change_suffix	(S_path *f, char *suf);
char *		shchsuf			(char *f, char *suf, short all, short key);		/* suf incl '.' */
S_path		inspad			(S_path *fn, char *pn);
char *		delpad			(char *f, char *pad);
char *		delhelepad		(char *f);
void		convertslash	(char *name, char *new);
bool		inq_xfs			(Cstr pad, char *slash);
bool		same_path		(Cstr p1, Cstr p2);
void		DIRcpy			(S_path * dst, Cstr  src);
void		DIRcat			(S_path * dst, Cstr  src);
void		possibleslash	(char *s);

/* strmaxcpy is much better than strncpy if used for secure copying.
   it copies maximal UPTO l bytes and ALWAYS appends the only null character!!!.
   It also is a real string function, so it stops at the null character.
   strncpy must only be used for inserting 1 string into another.
*/
void		strmaxcpy		(char *d, Cstr s, short l);

extern
S_path ipath, idir, fsel, setfn, buffn;
#if CC_PATH
extern
S_path CC_path;
#endif
extern
char prg_name[];

extern
short drive;

long Aopendir(char *dir, FB *fb);
bool Areaddir(FB *fb);
void Aclosedir(FB *fb);


#endif		/* PATH_H */