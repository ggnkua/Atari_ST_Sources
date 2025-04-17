/*
 *                     RCS file comparison
 */
/*****************************************************************************
 *                       rcsfcmp()
 *                       Testprogram: define FCMPTEST
 *****************************************************************************
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





/* $Log: rcsfcmp.c,v $
 * Revision 5.6  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.5  90/11/27  09:26:05  eggert
 * checked in with -k by apratt at 91.01.10.13.15.12.
 * 
 * Revision 5.5  1990/11/27  09:26:05  eggert
 * Fix comment leader bug.
 *
 * Revision 5.4  1990/11/01  05:03:42  eggert
 * Permit arbitrary data in logs and comment leaders.
 *
 * Revision 5.3  1990/09/11  02:41:15  eggert
 * Don't ignore differences inside keyword strings if -ko is set.
 *
 * Revision 5.1  1990/08/29  07:13:58  eggert
 * Clean old log messages too.
 *
 * Revision 5.0  1990/08/22  08:12:49  eggert
 * Don't append "checked in with -k by " log to logs,
 * so that checking in a program with -k doesn't change it.
 * Ansify and Posixate.  Remove lint.
 *
 * Revision 4.5  89/05/01  15:12:42  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.4  88/08/09  19:12:50  eggert
 * Shrink stdio code size.
 * 
 * Revision 4.3  87/12/18  11:40:02  narten
 * lint cleanups (Guy Harris)
 * 
 * Revision 4.2  87/10/18  10:33:06  narten
 * updting version number. Changes relative to 1.1 actually relative to 
 * 4.1
 * 
 * Revision 1.2  87/03/27  14:22:19  jenkins
 * Port to suns
 * 
 * Revision 4.1  83/05/10  16:24:04  wft
 * Marker matching now uses trymatch(). Marker pattern is now
 * checked precisely.
 * 
 * Revision 3.1  82/12/04  13:21:40  wft
 * Initial revision.
 *
 */

/*
#define FCMPTEST
*/
/* Testprogram; prints out whether two files are identical,
 * except for keywords
 */

#include  "rcsbase.h"

libId(fcmpId, "$Id: rcsfcmp.c,v 5.6 1991/01/30 14:21:32 apratt Exp $")


	int
rcsfcmp(xfname,uxfname,delta)
	const char *xfname, *uxfname;
	const struct hshentry *delta;
/* Function: compares the files xfname and uxfname. Returns true
 * if xfname has the same contents as uxfname, while disregarding
 * keyword values. For the LOG-keyword, rcsfcmp skips the log message
 * given by the parameter delta in xfname. Thus, rcsfcmp returns true
 * if xfname contains the same as uxfname, with the keywords expanded.
 * Implementation: character-by-character comparison until $ is found.
 * If a $ is found, read in the marker keywords; if they are real keywords
 * and identical, read in keyword value. If value is terminated properly,
 * disregard it and optionally skip log message; otherwise, compare value.
 */
{
    register int xc,uxc;
    char xkeyword[keylength+2],   uxkeyword[keylength+2];
    int eqkeyvals;
    register FILE * xfp, * uxfp;
    register int delimiter;
    register char * tp;
    register const char *sp;
    int result;
    enum markers match1,match2;

    errno = 0;
    if (!(xfp=fopen(sp=xfname,"r")) || !(errno=0, uxfp=fopen(sp=uxfname,"r"))) {
       efaterror(sp);
    }
    result=false;
    delimiter = Expand==OLD_EXPAND ? EOF : KDELIM;
    xc=getc(xfp); uxc=getc(uxfp);
    while( xc == uxc) { /* comparison loop */
        if (xc==EOF) { /* finished; everything is the same*/
            result=true;
            break;
        }
	if (xc != delimiter) {
            /* get the next characters */
            xc=getc(xfp); uxc=getc(uxfp);
        } else {
            /* try to get both keywords */
            tp = xkeyword;
            while( (xc=getc(xfp))!=EOF && (tp< xkeyword+keylength) && (xc!='\n')
                   && (xc!=KDELIM) && (xc!=VDELIM))
                *tp++ = xc;
	    *tp++ = xc;  /* add closing K/VDELIM */
            *tp='\0';
            tp = uxkeyword;
            while( (uxc=getc(uxfp))!=EOF && (tp< uxkeyword+keylength) && (uxc!='\n')
                   && (uxc!=KDELIM) && (uxc!=VDELIM))
                *tp++ = uxc;
	    *tp++ = xc;  /* add closing K/VDELIM */
            *tp='\0';
	    /* Now we have 2 keywords, or something that looks like it. */
	    match1 = trymatch(xkeyword);
	    match2 = trymatch(uxkeyword);
	    if (match1 != match2) break; /* not identical */
#ifdef FCMPTEST
	    VOID printf("found potential keywords %s and %s\n",xkeyword,uxkeyword);
#endif

	    if (match1 == Nomatch) {
		/* not a keyword pattern, but could still be identical */
		if (strcmp(xkeyword,uxkeyword)==0)
		     continue;
		else break;
	    }
#ifdef FCMPTEST
	    VOID printf("found common keyword %s\n",xkeyword);
#endif
	    eqkeyvals = 1;
	    for (;;) {
		if (xc==uxc) {
		    if (xc==KDELIM)
			break;
		} else {
		    eqkeyvals = 0;
		    if (xc==KDELIM) {
			while (uxc!=KDELIM && uxc!='\n' && uxc!=EOF)
			    uxc = getc(uxfp);
			break;
		    }
		    if (uxc==KDELIM) {
			while (xc!=KDELIM && xc!='\n' && xc!=EOF)
			    xc = getc(xfp);
			break;
		    }
		}
		if (xc=='\n' || uxc=='\n' || xc==EOF || uxc==EOF)
		    break;
		xc = getc(xfp);
		uxc = getc(uxfp);
	    }
	    if (xc!=uxc) break; /* not the same */
	    if (xc==KDELIM) {
		xc=getc(xfp); uxc=getc(uxfp); /* skip closing KDELIM */
		/* if the keyword is LOG, also skip the log message in xfp*/
		if (match1==Log) {
		    /* first, compute the number of line feeds in log msg */
		    unsigned lncnt;
		    size_t ls, ccnt;
		    lncnt = 3;
		    sp = delta->log.string;
		    ls = delta->log.size;
		    if (sizeof(ciklog)-1<=ls && !strncmp(sp,ciklog,sizeof(ciklog)-1))
			continue; /* this log message wasn't inserted */
		    while (ls--) if (*sp++=='\n') lncnt++;
		    while(xc!=EOF) {
			if (xc=='\n')
			    if(--lncnt==0) break;
			xc=getc(xfp);
		    }
		    /* skip last comment leader */
		    /* Can't just skip another line here, because there may be */
		    /* additional characters on the line (after the Log....$)  */
		    for (ccnt=Comment.size; ccnt--; ) {
			xc=getc(xfp);
			if(xc=='\n') break;
			/* reads to the end of the comment leader or '\n',     */
			/* whatever comes first. This is because some editors  */
			/* strip off trailing blanks from a leader like " * ". */
		    }
		}
	    } else {
		/* both end in the same character, but not a KDELIM */
		/* must compare string values.*/
#ifdef FCMPTEST
		VOID printf("non-terminated keywords %s, potentially different values\n",xkeyword);
#endif
		if (!eqkeyvals) break;
            }
        }
    }
    ffclose(xfp); ffclose(uxfp);
    return result;
}



#ifdef FCMPTEST

const char cmdid[] = "rcsfcmp";

main(argc, argv)
int  argc; char  *argv[];
/* first argument: comment leader; 2nd: log message, 3rd: expanded file,
 * 4th: unexpanded file
 */
{       struct hshentry delta;

	Comment.string = argv[1];
	Comment.size = strlen(argv[1]);
	delta.log.string = argv[2];
	delta.log.size = strlen(argv[2]);
        if (rcsfcmp(argv[3],argv[4],&delta))
                VOID printf("files are the same\n");
        else    VOID printf("files are different\n");
}
#endif
