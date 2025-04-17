/*
 *                     RCS revision generation
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



/* $Log: rcsgen.c,v $
 * Revision 5.7  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.6  90/12/27  19:54:26  eggert
 * checked in with -k by apratt at 91.01.10.13.15.18.
 * 
 * Revision 5.6  1990/12/27  19:54:26  eggert
 * Fix bug: rcs -t inserted \n, making RCS file grow.
 *
 * Revision 5.5  1990/12/04  05:18:45  eggert
 * Use -I for prompts and -q for diagnostics.
 *
 * Revision 5.4  1990/11/01  05:03:47  eggert
 * Add -I and new -t behavior.  Permit arbitrary data in logs.
 *
 * Revision 5.3  1990/09/21  06:12:43  hammer
 * made putdesc() treat stdin the same whether or not it was from a terminal
 * by making it recognize that a single '.' was then end of the
 * description always
 *
 * Revision 5.2  1990/09/04  08:02:25  eggert
 * Fix `co -p1.1 -ko' bug.  Standardize yes-or-no procedure.
 *
 * Revision 5.1  1990/08/29  07:14:01  eggert
 * Clean old log messages too.
 *
 * Revision 5.0  1990/08/22  08:12:52  eggert
 * Remove compile-time limits; use malloc instead.
 * Ansify and Posixate.
 *
 * Revision 4.7  89/05/01  15:12:49  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.6  88/08/28  14:59:10  eggert
 * Shrink stdio code size; allow cc -R; remove lint; isatty() -> ttystdin()
 * 
 * Revision 4.5  87/12/18  11:43:25  narten
 * additional lint cleanups, and a bug fix from the 4.3BSD version that
 * keeps "ci" from sticking a '\377' into the description if you run it
 * with a zero-length file as the description. (Guy Harris)
 * 
 * Revision 4.4  87/10/18  10:35:10  narten
 * Updating version numbers. Changes relative to 1.1 actually relative to
 * 4.2
 * 
 * Revision 1.3  87/09/24  13:59:51  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 1.2  87/03/27  14:22:27  jenkins
 * Port to suns
 * 
 * Revision 4.2  83/12/02  23:01:39  wft
 * merged 4.1 and 3.3.1.1 (clearerr(stdin)).
 * 
 * Revision 4.1  83/05/10  16:03:33  wft
 * Changed putamin() to abort if trying to reread redirected stdin.
 * Fixed getdesc() to output a prompt on initial newline.
 * 
 * Revision 3.3.1.1  83/10/19  04:21:51  lepreau
 * Added clearerr(stdin) for re-reading description from stdin.
 * 
 * Revision 3.3  82/11/28  21:36:49  wft
 * 4.2 prerelease
 * 
 * Revision 3.3  82/11/28  21:36:49  wft
 * Replaced ferror() followed by fclose() with ffclose().
 * Putdesc() now suppresses the prompts if stdin
 * is not a terminal. A pointer to the current log message is now
 * inserted into the corresponding delta, rather than leaving it in a
 * global variable.
 *
 * Revision 3.2  82/10/18  21:11:26  wft
 * I added checks for write errors during editing, and improved
 * the prompt on putdesc().
 *
 * Revision 3.1  82/10/13  15:55:09  wft
 * corrected type of variables assigned to by getc (char --> int)
 */




#include "rcsbase.h"

libId(genId, "$Id: rcsgen.c,v 5.7 1991/01/30 14:21:32 apratt Exp $")

int interactiveflag;  /* Should we act as if stdin is a tty?  */
struct cbuf curlogmsg;  /* buffer for current log message */
struct buf curlogbuf;  /* same, including allocated but unused bytes */

enum stringwork {copy, edit, expand, edit_expand };

static void scandeltatext P((struct hshentry*,enum stringwork));




	const char *
buildrevision(deltas, target, tostdout, expandflag)
	const struct hshentries *deltas;
	struct hshentry *target;
	int tostdout;
	int expandflag;
/* Function: Generates the revision given by target
 * by retrieving all deltas given by parameter deltas and combining them.
 * If tostdout is set, the revision is printed on the standard output,
 * otherwise written into a temporary file.
 * Temporary files are put into tmp unless the caller has already set up
 * the temp file directory by invoking initeditfiles(), which sets fcopy.
 * if expandflag is set, keyword expansion is performed.
 * Returns nil on errors, the name of the file with the revision otherwise.
 *
 * Algorithm: Copy initial revision unchanged.  Then edit all revisions but
 * the last one into it, alternating input and output files (resultfile and
 * editfile). The last revision is then edited in, performing simultaneous
 * keyword substitution (this saves one extra pass).
 * All this simplifies if only one revision needs to be generated,
 * or no keyword expansion is necessary, or if output goes to stdout.
 */
{
	static const char nonnil[] = ""; /* some char* value that isn't nil */

	if (deltas->first == target) {
                /* only latest revision to generate */
		if (tostdout) {
                        fcopy=stdout;
			scandeltatext(target, expandflag?expand:copy);
			return nonnil;
                } else {
			if (!fcopy)
				inittmpeditfiles();
                        scandeltatext(target,expandflag?expand:copy);
                        ffclose(fcopy);
                        return(resultfile);
                }
        } else {
                /* several revisions to generate */
		if (!fcopy)
			inittmpeditfiles();
                /* write initial revision into fcopy, no keyword expansion */
		scandeltatext(deltas->first, copy);
		while ((deltas=deltas->rest)->rest) {
                        /* do all deltas except last one */
			scandeltatext(deltas->first, edit);
                }
		if (expandflag | tostdout) {
                        /* first, get to beginning of file*/
			finishedit((struct hshentry *)nil);
			swapeditfiles(tostdout);
                }
		scandeltatext(deltas->first, expandflag ? edit_expand : edit);
		finishedit(expandflag ? deltas->first : (struct hshentry*)nil);
		if (tostdout)
			return nonnil;
		ffclose(fcopy);
		return resultfile;
        }
}



	static void
scandeltatext(delta,func)
struct hshentry * delta; enum stringwork func;
/* Function: Scans delta text nodes up to and including the one given
 * by delta. For the one given by delta, the log message is saved into
 * curlogmsg and the text is processed according to parameter func.
 * Assumes the initial lexeme must be read in first.
 * Does not advance nexttok after it is finished.
 */
{
	const struct hshentry *nextdelta;
	struct cbuf cb;

        for (;;) {
                nextlex();
                if (!(nextdelta=getnum())) {
		    fatserror("can't find delta for revision %s", delta->num);
                }
		getkeystring(Klog);
		if (delta==nextdelta) {
			cb = savestring(&curlogbuf);
			delta->log = curlogmsg =
				cleanlogmsg(curlogbuf.string, cb.size);
                } else {readstring();
                }
                nextlex();
		while (nexttok==ID && strcmp(NextString,Ktext)!=0)
			ignorephrase();
		getkeystring(Ktext);

		if (delta==nextdelta)
			break;
		readstring(); /* skip over it */

	}
	switch (func) {
		case copy: copystring(); break;
		case expand: xpandstring(delta); break;
		case edit: editstring((struct hshentry *)nil); break;
		case edit_expand: editstring(delta); break;
	}
}

	struct cbuf
cleanlogmsg(m, s)
	char *m;
	size_t s;
{
	register char *t = m;
	register const char *f = t;
	struct cbuf r;
	while (s) {
	    --s;
	    if ((*t++ = *f++) == '\n')
		while (m < --t)
		    if (t[-1]!=' ' && t[-1]!='\t') {
			*t++ = '\n';
			break;
		    }
	}
	while (m < t  &&  (t[-1]==' ' || t[-1]=='\t' || t[-1]=='\n'))
	    --t;
	r.string = m;
	r.size = t - m;
	return r;
}


int ttystdin()
{
	static int initialized;
	if (!initialized) {
		if (!interactiveflag)
			interactiveflag = isatty(STDIN_FILENO);
		initialized = true;
	}
	return interactiveflag;
}

	int
getcstdin()
{
	register int c = getchar();
	if (c == EOF) {
		if (ferror(stdin))
			IOerror();
		if (ttystdin()) {
			clearerr(stdin);
			afputc('\n',stderr);
		}
	}
	return c;
}

#if has_prototypes
	int
yesorno(int default_answer, const char *question, ...)
#else
		/*VARARGS2*/ int
	yesorno(default_answer, question, va_alist)
		int default_answer; const char *question; va_dcl
#endif
{
	va_list args;
	register int c, r;
	if (!quietflag && ttystdin()) {
		oflush();
		vararg_start(args, question);
		fvfprintf(stderr, question, args);
		va_end(args);
		eflush();
		r = c = getcstdin();
		while (c!='\n' && c!=EOF)
			c = getcstdin();
		if (r=='y' || r=='Y')
			return true;
		if (r=='n' || r=='N')
			return false;
	}
	return default_answer;
}


	void
putdesc(textflag, textfile)
	int textflag;
	const char *textfile;
/* Function: puts the descriptive text into file frewrite.
 * if finptr && !textflag, the text is copied from the old description.
 * Otherwise, if the textfile!=nil, the text is read from that
 * file, or from stdin, if textfile==nil.
 * A textfile with a leading '-' is treated as a string, not a file name.
 * If finptr, the old descriptive text is discarded.
 */
{       register FILE * txt; register int c, old1, old2;
	register FILE * frew;

	frew = frewrite;
	if (finptr && !textflag) {
                /* copy old description */
		aprintf(frew,"\n\n%s%c",Kdesc,nextc);
		foutptr = frewrite;
		getdesc(false);
        } else {
                /* get new description */
		if (finptr) {
                        /*skip old description*/
			foutptr = NULL;
			getdesc(false);
                }
		aprintf(frew,"\n\n%s\n%c",Kdesc,SDELIM);
                if (textfile) {
                        old1='\n';
                        /* copy textfile */
			txt = NULL;
			if (*textfile=='-' || (txt=fopen(textfile,"r"))) {
				while (txt ? (c=getc(txt))!=EOF : (c = *++textfile)) {
					if (c==SDELIM) afputc(c,frew); /*double up*/
					afputc(c,frew);
                                        old1=c;
                                }
				if (old1!='\n') afputc('\n',frew);
				if (txt) ffclose(txt);
				aprintf(frew, "%c\n", SDELIM);
				return;
                        } else {
				efaterror(textfile);
                        }
                }
                /* read text from stdin */
		if (feof(stdin))
		    faterror("can't reread redirected stdin for description; use -t-<description>");
		if (ttystdin())
		    aputs("enter description, terminated with single '.' or end of file:\nNOTE: This is NOT the log message!\n>> ",stderr);
		if ((old1=getcstdin()) != EOF) {
		     old2 = '\n';
		     for (;;) {
			    if (old1=='\n' && ttystdin())
				    aputs(">> ",stderr);
			    c = getcstdin();
                            if (c==EOF) {
				    afputc(old1,frew);
				    if (old1!='\n') afputc('\n',frew);
                                    break;
                            }
			    if (c=='\n' && old1=='.' && old2=='\n') {
                                    break;
                            }
			    if (old1==SDELIM) afputc(old1,frew); /* double up*/
			    afputc(old1,frew);
                            old2=old1;
                            old1=c;
                    } /* end for */
		}
		aprintf(frew, "%c\n", SDELIM);
        }
}
