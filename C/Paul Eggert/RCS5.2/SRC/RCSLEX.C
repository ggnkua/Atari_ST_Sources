/*
 *                     RCS file input
 */
/*********************************************************************************
 *                     Lexical Analysis.
 *                     hashtable, Lexinit, nextlex, getlex, getkey,
 *                     getid, getnum, readstring, printstring, savestring,
 *                     checkid, fatserror, error, faterror, warn, diagnose
 *                     Testprogram: define LEXDB
 *********************************************************************************
 */

/* Copyright (C) 1982, 1988, 1989 Walter Tichy
   Copyright 1990 by Paul Eggert
   Distributed under license by the Free Software Foundation, Inc.

This file is part of RCS.

RCS is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

RCS is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with RCS; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

Report problems and direct all questions to:

    rcs-bugs@cs.purdue.edu

*/



/* $Log: rcslex.c,v $
 * Revision 5.6  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.5  90/12/04  05:18:47  eggert
 * checked in with -k by apratt at 91.01.10.13.15.22.
 * 
 * Revision 5.5  1990/12/04  05:18:47  eggert
 * Use -I for prompts and -q for diagnostics.
 *
 * Revision 5.4  1990/11/19  20:05:28  hammer
 * no longer gives warning about unknown keywords if -q is specified
 *
 * Revision 5.3  1990/11/01  05:03:48  eggert
 * When ignoring unknown phrases, copy them to the output RCS file.
 *
 * Revision 5.2  1990/09/04  08:02:27  eggert
 * Count RCS lines better.
 *
 * Revision 5.1  1990/08/29  07:14:03  eggert
 * Work around buggy compilers with defective argument promotion.
 *
 * Revision 5.0  1990/08/22  08:12:55  eggert
 * Remove compile-time limits; use malloc instead.
 * Report errno-related errors with perror().
 * Ansify and Posixate.  Add support for ISO 8859.
 * Use better hash function.
 *
 * Revision 4.6  89/05/01  15:13:07  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.5  88/08/28  15:01:12  eggert
 * Don't loop when writing error messages to a full filesystem.
 * Flush stderr/stdout when mixing output.
 * Yield exit status compatible with diff(1).
 * Shrink stdio code size; allow cc -R; remove lint.
 * 
 * Revision 4.4  87/12/18  11:44:47  narten
 * fixed to use "varargs" in "fprintf"; this is required if it is to
 * work on a SPARC machine such as a Sun-4
 * 
 * Revision 4.3  87/10/18  10:37:18  narten
 * Updating version numbers. Changes relative to 1.1 actually relative
 * to version 4.1
 * 
 * Revision 1.3  87/09/24  14:00:17  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 1.2  87/03/27  14:22:33  jenkins
 * Port to suns
 * 
 * Revision 4.1  83/03/25  18:12:51  wft
 * Only changed $Header to $Id.
 * 
 * Revision 3.3  82/12/10  16:22:37  wft
 * Improved error messages, changed exit status on error to 1.
 *
 * Revision 3.2  82/11/28  21:27:10  wft
 * Renamed ctab to map and included EOFILE; ctab is now a macro in rcsbase.h.
 * Added fflsbuf(), fputs(), and fprintf(), which abort the RCS operations
 * properly in case there is an IO-error (e.g., file system full).
 *
 * Revision 3.1  82/10/11  19:43:56  wft
 * removed unused label out:;
 * made sure all calls to getc() return into an integer, not a char.
 */


/*
#define LEXDB
*/
/* version LEXDB is for testing the lexical analyzer. The testprogram
 * reads a stream of lexemes, enters the revision numbers into the
 * hashtable, and prints the recognized tokens. Keywords are recognized
 * as identifiers.
 */



#include "rcsbase.h"

libId(lexId, "$Id: rcslex.c,v 5.6 1991/01/30 14:21:32 apratt Exp $")

static struct hshentry *nexthsh;  /*pointer to next hash entry, set by lookup*/

enum tokens     nexttok;    /*next token, set by nextlex                    */

int             hshenter;   /*if true, next suitable lexeme will be entered */
                            /*into the symbol table. Handle with care.      */
int             nextc;      /*next input character, initialized by Lexinit  */

unsigned long	rcsline;    /*current line-number of input		    */
int             nerror;     /*counter for errors                            */
int             quietflag;  /*indicates quiet mode                          */
FILE *          finptr;     /*input file descriptor                         */

FILE *          frewrite;   /*file descriptor for echoing input             */

FILE *		foutptr;	    /* copy of frewrite, but NULL to suppress echo  */

static struct buf tokbuf;   /* token buffer				    */

const char *    NextString; /* next token				    */

/*
 * Our hash algorithm is h[0] = 0, h[i+1] = 4*h[i] + c,
 * so hshsize should be odd.
 * See B J McKenzie, R Harries & T Bell, Selecting a hashing algorithm,
 * Software--practice & experience 20, 2 (Feb 1990), 209-224.
 */
#ifndef hshsize
#	define hshsize 511
#endif

static struct hshentry *hshtab[hshsize]; /*hashtable			    */

static int ignored_phrases; /* have we ignored phrases in this RCS file? */

    void
warnignore()
{
    if (! (ignored_phrases|quietflag)) {
	ignored_phrases = true;
	warn("Unknown phrases like `%s ...;' are in the RCS file.", NextString);
    }
}



	static void
lookup(str)
	const char *str;
/* Function: Looks up the character string pointed to by str in the
 * hashtable. If the string is not present, a new entry for it is created.
 * In any case, the address of the corresponding hashtable entry is placed
 * into nexthsh.
 */
{
	register unsigned ihash;  /* index into hashtable */
	register const char *sp;
	register struct hshentry *n, **p;

        /* calculate hash code */
	sp = str;
        ihash = 0;
	while (*sp)
		ihash  =  (ihash<<2) + *sp++;
	ihash %= hshsize;

	for (p = &hshtab[ihash];  ;  p = &n->nexthsh)
		if (!(n = *p)) {
			/* empty slot found */
			*p = n = ftalloc(struct hshentry);
			n->num = fstrsave(str);
			n->nexthsh = nil;
#			ifdef LEXDB
				VOID printf("\nEntered: %s at %u ", str, ihash);
#			endif
			break;
		} else if (strcmp(str, n->num) == 0)
			/* match found */
			break;
	nexthsh = n;
	NextString = n->num;
}






	void
Lexinit()
/* Function: Initialization of lexical analyzer:
 * initializes the hashtable,
 * initializes nextc, nexttok if finptr != NULL
 */
{       register int            c;

	for (c = hshsize;  0 <= --c;  ) {
		hshtab[c] = nil;
        }

	hshenter=true; rcsline=1; nerror=0;
	ignored_phrases = false;
	bufrealloc(&tokbuf, 2);
        if (finptr) {
		GETC(finptr,foutptr,c);
		nextc = c; /*initial character*/
		nexttok = DELIM;  /* anything but EOFILE */
                nextlex();            /*initial token*/
        } else {
                nextc = '\0';
                nexttok=EOFILE;
        }
}


	static exiting void
unexpectedEOF()
{
	fatserror("unexpected EOF");
}







	void
nextlex()

/* Function: Reads the next token and sets nexttok to the next token code.
 * Only if hshenter is set, a revision number is entered into the
 * hashtable and a pointer to it is placed into nexthsh.
 * This is useful for avoiding that dates are placed into the hashtable.
 * For ID's and NUM's, NextString is set to the character string.
 * Assumption: nextc contains the next character.
 */
{       register c;
	register FILE * fin, * frew;
        register char * sp;
	const char *lim;
        register enum tokens d;

	if (nexttok == EOFILE)
		unexpectedEOF();
	fin=finptr; frew=foutptr;

	for (;;) switch ((nexttok=ctab[nextc])) {

	default:
		fatserror("unknown character `%c'", nextc);
		/*NOTREACHED*/

        case NEWLN:
		++rcsline;
#               ifdef LEXDB
		afputc('\n',stdout);
#               endif
                /* Note: falls into next case */

        case SPACE:
		GETC(fin,frew,c);
		nextc = c;
		continue;

        case EOFILE:
                return;

        case DIGIT:
		sp = tokbuf.string;
		lim = sp + tokbuf.size;
                *sp++ = nextc;
		for (;;) {
			GETC(fin,frew,c);
			if ((d=ctab[c])!=DIGIT && d!=PERIOD)
				break;
                        *sp++ = c;         /* 1.2. and 1.2 are different */
			if (lim <= sp)
				sp = bufenlarge(&tokbuf, &lim);
                }
		*sp = 0;
                nextc = c;
		if (hshenter)
			lookup(tokbuf.string);
		else
			NextString = fstrsave(tokbuf.string);
                nexttok = NUM;
                return;


        case LETTER:
	case Letter:
		sp = tokbuf.string;
		lim = sp + tokbuf.size;
                *sp++ = nextc;
		for (;;) {
			GETC(fin,frew,c);
			if ((d=ctab[c])!=LETTER && d!=Letter && d!=DIGIT && d!=IDCHAR)
				break;
                        *sp++ = c;
			if (lim <= sp)
				sp = bufenlarge(&tokbuf, &lim);
                }
		*sp = 0;
                nextc = c;
		NextString = fstrsave(tokbuf.string);
                nexttok = ID;  /* may be ID or keyword */
                return;

        case SBEGIN: /* long string */
                nexttok = STRING;
                /* note: only the initial SBEGIN has been read*/
                /* read the string, and reset nextc afterwards*/
                return;

	case COLON:
	case SEMI:
		GETC(fin,frew,c);
		nextc = c;
                return;
        }
}


int getlex(token)
enum tokens token;
/* Function: Checks if nexttok is the same as token. If so,
 * advances the input by calling nextlex and returns true.
 * otherwise returns false.
 * Doesn't work for strings and keywords; loses the character string for ids.
 */
{
        if (nexttok==token) {
                nextlex();
                return(true);
        } else  return(false);
}

	int
getkeyopt(key)
	const char *key;
/* Function: If the current token is a keyword identical to key,
 * advances the input by calling nextlex and returns true;
 * otherwise returns false.
 */
{
	if (nexttok==ID  &&  strcmp(key,NextString) == 0) {
		 /* match found */
		 ffree1(NextString);
		 nextlex();
		 return(true);
        }
        return(false);
}

	void
getkey(key)
	const char *key;
/* Check that the current input token is a keyword identical to key,
 * and advance the input by calling nextlex.
 */
{
	if (!getkeyopt(key))
		fatserror("missing '%s' keyword", key);
}

	void
getkeystring(key)
	const char *key;
/* Check that the current input token is a keyword identical to key,
 * and advance the input by calling nextlex; then look ahead for a string.
 */
{
	getkey(key);
	if (nexttok != STRING)
		fatserror("missing string after '%s' keyword", key);
}


	const char *
getid()
/* Function: Checks if nexttok is an identifier. If so,
 * advances the input by calling nextlex and returns a pointer
 * to the identifier; otherwise returns nil.
 * Treats keywords as identifiers.
 */
{
	register const char *name;
        if (nexttok==ID) {
                name = NextString;
                nextlex();
                return name;
        } else  return nil;
}


struct hshentry * getnum()
/* Function: Checks if nexttok is a number. If so,
 * advances the input by calling nextlex and returns a pointer
 * to the hashtable entry. Otherwise returns nil.
 * Doesn't work if hshenter is false.
 */
{
        register struct hshentry * num;
        if (nexttok==NUM) {
                num=nexthsh;
                nextlex();
                return num;
        } else  return nil;
}

	struct cbuf
getphrases(key)
	const char *key;
/* Get a series of phrases that do not start with KEY, yield resulting buffer.
 * Stop when the next phrase starts with a token that is not an identifier,
 * or is KEY.
 * Assume foutptr == NULL.
 */
{
    register FILE *fin;
    register int c;
    register char *p;
    const char *lim;
    register const char *ki, *kn;
    struct cbuf r;
    struct buf b;

    if (nexttok!=ID  ||  strcmp(NextString,key) == 0) {
	r.string = 0;
	r.size = 0;
	return r;
    } else {
	warnignore();
	fin = finptr;
	bufautobegin(&b);
	bufscpy(&b, NextString);
	ffree1(NextString);
	p = b.string + strlen(b.string);
	lim = b.string + b.size;
	c = nextc;
	for (;;) {
	    for (;;) {
		if (lim <= p)
		    p = bufenlarge(&b, &lim);
		*p++ = c;
		switch (ctab[c]) {
		    default:
			fatserror("unknown character `%c'", c);
			/*NOTREACHED*/
		    case EOFILE:
			unexpectedEOF();
			/*NOTREACHED*/
		    case NEWLN:
			++rcsline;
			/* fall into */
		    case COLON: case DIGIT: case LETTER: case Letter:
		    case PERIOD: case SPACE:
			c = getc(fin);
			continue;
		    case SBEGIN: /* long string */
			for (;;) {
			    for (;;) {
				c = getc(fin);
				if (lim <= p)
				    p = bufenlarge(&b, &lim);
				*p++ = c;
				switch (c) {
				    case EOF:
					unexpectedEOF();
					/*NOTREACHED*/
				    case '\n':
					++rcsline;
					/* fall into */
				    default:
					continue;
				    case SDELIM:
					break;
				}
				break;
			    }
			    c = getc(fin);
			    if (c != SDELIM)
				break;
			    if (lim <= p)
				p = bufenlarge(&b, &lim);
			    *p++ = c;
			}
			continue;
		    case SEMI:
			c = getc(fin);
			if (ctab[c] == NEWLN) {
			    ++rcsline;
			    if (lim <= p)
				p = bufenlarge(&b, &lim);
			    *p++ = c;
			    c = getc(fin);
			}
			for (;; c = getc(fin)) {
			    switch (ctab[c]) {
				case NEWLN: ++rcsline; continue;
				case SPACE: continue;
				default: break;
			    }
			    break;
			}
			break;
		}
		break;
	    }
	    switch (ctab[c]) {
		case LETTER:
		case Letter:
		    for (kn = key;  c && *kn==c;  kn++)
			if ((c = getc(fin)) == EOF)
			    unexpectedEOF();
		    if (!*kn)
			switch (ctab[c]) {
			    case DIGIT: case LETTER: case Letter:
				break;
			    default:
				nextc = c;
				NextString = fstrsave(key);
				nexttok = ID;
				goto returnit;
			}
		    for (ki=key; ki<kn; ) {
			if (lim <= p)
			    p = bufenlarge(&b, &lim);
			*p++ = *ki++;
		    }
		    break;
		default:
		    nextc = c;
		    nextlex();
		    goto returnit;
	    }
	}

    returnit:
	/*
	 * Do the following instead of bufautoend(&b),
	 * because the buffer must survive until we are done with the file.
	 */
	r.size = p - b.string;
	r.string = (char*)fremember(testrealloc((malloc_type)b.string, r.size));
	return r;
    }
}


	void
readstring()
/* skip over characters until terminating single SDELIM        */
/* If foutptr is set, copy every character read to foutptr.    */
/* Does not advance nextlex at the end.                        */
{       register c;
	register FILE * fin,  * frew;
	fin=finptr; frew=foutptr;
	if (frew) {
		/* Copy string verbatim to foutptr.  */
                while ((c=getc(fin)) != EOF) {
			aputc(c,frew);
			switch (c) {
			    case '\n':
				++rcsline;
				break;
			    case SDELIM:
				if ((c=getc(fin)) == EOF) {
					nextc=c;
					return;
				}
				aputc(c,frew);
				if (c != SDELIM) {
                                        /* end of string */
                                        nextc=c;
                                        return;
                                }
				break;
                        }
                }
        } else {
                /* skip string */
                while ((c=getc(fin)) != EOF) {
			switch (c) {
			    case '\n':
				++rcsline;
				break;
			    case SDELIM:
                                if ((c=getc(fin)) != SDELIM) {
                                        /* end of string */
                                        nextc=c;
                                        return;
                                }
				break;
                        }
                }
        }
	unterminatedString();
}


	void
printstring()
/* Function: copy a string to stdout, until terminated with a single SDELIM.
 * Does not advance nextlex at the end.
 */
{
        register c;
	register FILE *fin, *fout;
	fin=finptr;
	fout = stdout;
	while ((c=getc(fin)) != EOF) {
		switch (c) {
		    case '\n':
			++rcsline;
			break;
		    case SDELIM:
			if ((c=getc(fin)) != SDELIM) {
                                /* end of string */
                                nextc=c;
                                return;
                        }
			break;
                }
		aputc(c,fout);
        }
	unterminatedString();
}



	struct cbuf
savestring(target)
	struct buf *target;
/* Copies a string terminated with SDELIM from file finptr to buffer target.
 * Double SDELIM is replaced with SDELIM.
 * If foutptr is set, the string is also copied unchanged to foutptr.
 * Does not advance nextlex at the end.
 * Yield a copy of *TARGET, except with exact length.
 */
{
        register c;
	register FILE * fin, * frew;
	register char *tp;
	const char *lim;
	struct cbuf r;

	fin=finptr; frew=foutptr;
	tp = target->string;  lim = tp + target->size;
	for (;;) {
		GETC(fin,frew,c);
		switch (c) {
		    case '\n':
			++rcsline;
			break;
		    case SDELIM:
			GETC(fin,frew,c);
			if (c != SDELIM) {
                                /* end of string */
                                nextc=c;
				r.string = target->string;
				r.size = tp - r.string;
				return r;
                        }
			break;
		    case EOF:
			unterminatedString();
                }
		if (tp == lim)
			tp = bufenlarge(target, &lim);
		*tp++ = c;
        }
}


	char *
checkid(id, delimiter)
	register char *id;
	int delimiter;
/*   Function:  check whether the string starting at id is an   */
/*		identifier and return a pointer to the delimiter*/
/*		after the identifier.  White space, delim and 0 */
/*              are legal delimiters.  Aborts the program if not*/
/*              a legal identifier. Useful for checking commands*/
/*		If !delim, the only delimiter is 0.		*/
{
        register enum  tokens  d;
        register char    *temp;
        register char    c,tc;
	register char delim = delimiter;

	temp = id;
	if ((d = ctab[(unsigned char)(c = *id)])==LETTER || d==Letter) {
	    while ((d = ctab[(unsigned char)(c = *++id)])==LETTER
		|| d==Letter || d==DIGIT || d==IDCHAR
	    )
		;
	    if (c  &&  (!delim || c!=delim && c!=' ' && c!='\t' && c!='\n')) {
                /* append \0 to end of id before error message */
                tc = c;
                while( (c=(*++id))!=' ' && c!='\t' && c!='\n' && c!='\0' && c!=delim) ;
                *id = '\0';
		faterror("invalid character %c in identifier `%s'",tc,temp);
	    }
        } else {
            /* append \0 to end of id before error message */
            while( (c=(*++id))!=' ' && c!='\t' && c!='\n' && c!='\0' && c!=delim) ;
            *id = '\0';
	    faterror("identifier `%s' doesn't start with letter", temp);
        }
	return id;
}

	void
checksid(id)
	register char *id;
/* Check whether the string ID is an identifier.  */
{
	VOID checkid(id, 0);
}


	exiting void
IOerror()
{
	static looping;
	if (looping)
		exiterr();
	looping = true;
	faterror("input/output error; is the file system full?");
}

void eflush() { if (fflush(stderr) == EOF) IOerror(); }
void oflush() { if (fflush(stdout) == EOF) IOerror(); }

exiting void unterminatedString() { fatserror("unterminated string"); }

	static exiting void
fatcleanup(already_newline)
	int already_newline;
{
	VOID fprintf(stderr, already_newline+"\n%s aborted\n", cmdid);
	exiterr();
}

static void errsay() { oflush(); aprintf(stderr,"%s error: ",cmdid); nerror++; }
static void fatsay() { oflush(); VOID fprintf(stderr,"%s error: ",cmdid); }

void eerror(n) const char *n; { errsay(); perror(n); eflush(); }
exiting void efaterror(n) const char *n; { fatsay(); perror(n); fatcleanup(true); }

#if has_prototypes
	void
error(const char *format,...)
#else
	/*VARARGS1*/ void error(format, va_alist) const char *format; va_dcl
#endif
/* non-fatal error */
{
	va_list args;
	errsay();
	vararg_start(args, format);
	fvfprintf(stderr, format, args);
	va_end(args);
	afputc('\n',stderr);
	eflush();
}

#if has_prototypes
	exiting void
fatserror(const char *format,...)
#else
	/*VARARGS1*/ exiting void
	fatserror(format, va_alist) const char *format; va_dcl
#endif
/* fatal syntax error */
{
	va_list args;
	oflush();
	VOID fprintf(stderr, "%s: %s:%lu: ", cmdid, RCSfilename, rcsline);
	vararg_start(args, format);
	fvfprintf(stderr, format, args);
	va_end(args);
	fatcleanup(false);
}

#if has_prototypes
	exiting void
faterror(const char *format,...)
#else
	/*VARARGS1*/ exiting void faterror(format, va_alist)
	const char *format; va_dcl
#endif
/* fatal error, terminates program after cleanup */
{
	va_list args;
	fatsay();
	vararg_start(args, format);
	fvfprintf(stderr, format, args);
	va_end(args);
	fatcleanup(false);
}

#if has_prototypes
	void
warn(const char *format,...)
#else
	/*VARARGS1*/ void warn(format, va_alist) const char *format; va_dcl
#endif
/* prints a warning message */
{
	va_list args;
	oflush();
	aprintf(stderr,"%s warning: ",cmdid);
	vararg_start(args, format);
	fvfprintf(stderr, format, args);
	va_end(args);
	afputc('\n',stderr);
	eflush();
}

	void
redefined(c)
	int c;
{
	warn("redefinition of -%c option", c);
}

#if has_prototypes
	void
diagnose(const char *format,...)
#else
	/*VARARGS1*/ void diagnose(format, va_alist) const char *format; va_dcl
#endif
/* prints a diagnostic message */
/* Unlike the other routines, it does not append a newline. */
/* This lets some callers suppress the newline, and is faster */
/* in implementations that flush stderr just at the end of each printf. */
{
	va_list args;
        if (!quietflag) {
		oflush();
		vararg_start(args, format);
		fvfprintf(stderr, format, args);
		va_end(args);
		eflush();
        }
}



	void
afputc(c, f)
/* Function: afputc(c,f) acts like aputc(c,f), but is smaller and slower.
 */
	int c;
	register FILE *f;
{
	aputc(c,f);
}


	void
aputs(s, iop)
	const char *s;
	FILE *iop;
/* Function: Put string s on file iop, abort on error.
 */
{
	if (fputs(s, iop) == EOF)
		IOerror();
}



	void
#if has_prototypes
fvfprintf(FILE *stream, const char *format, va_list args)
#else
	fvfprintf(stream,format,args) FILE *stream; char *format; va_list args;
#endif
/* like vfprintf, except abort program on error */
{
#if has_vfprintf
	if (vfprintf(stream, format, args) == EOF)
#else
	_doprnt(format, args, stream);
	if (ferror(stream))
#endif
		IOerror();
}

#if has_prototypes
	void
aprintf(FILE *iop, const char *fmt, ...)
#else
	/*VARARGS2*/ void
aprintf(iop, fmt, va_alist)
FILE *iop;
const char *fmt;
va_dcl
#endif
/* Function: formatted output. Same as fprintf in stdio,
 * but aborts program on error
 */
{
	va_list ap;
	vararg_start(ap, fmt);
	fvfprintf(iop, fmt, ap);
	va_end(ap);
}



#ifdef LEXDB
/* test program reading a stream of lexemes and printing the tokens.
 */



	int
main(argc,argv)
int argc; char * argv[];
{
        cmdid="lextest";
        if (argc<2) {
		aputs("No input file\n",stderr);
		exitmain(EXIT_FAILURE);
        }
        if ((finptr=fopen(argv[1], "r")) == NULL) {
		faterror("can't open input file %s",argv[1]);
        }
        Lexinit();
        while (nexttok != EOFILE) {
        switch (nexttok) {

        case ID:
                VOID printf("ID: %s",NextString);
                break;

        case NUM:
		if (hshenter)
                   VOID printf("NUM: %s, index: %d",nexthsh->num, nexthsh-hshtab);
                else
                   VOID printf("NUM, unentered: %s",NextString);
                hshenter = !hshenter; /*alternate between dates and numbers*/
                break;

        case COLON:
                VOID printf("COLON"); break;

        case SEMI:
                VOID printf("SEMI"); break;

        case STRING:
                readstring();
                VOID printf("STRING"); break;

        case UNKN:
                VOID printf("UNKN"); break;

        default:
                VOID printf("DEFAULT"); break;
        }
        VOID printf(" | ");
        nextlex();
        }
        VOID printf("\nEnd of lexical analyzer test\n");
	exitmain(EXIT_SUCCESS);
}

exiting void exiterr() { _exit(EXIT_FAILURE); }


#endif
