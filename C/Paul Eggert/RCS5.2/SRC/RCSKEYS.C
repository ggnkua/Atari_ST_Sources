/*
 *                     RCS keyword table and match operation
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



/* $Log: rcskeys.c,v $
 * Revision 5.1  1991/01/30  14:21:32  apratt
 * CI with RCS version 5
 *
 * Revision 5.0  90/08/22  08:12:54  eggert
 * checked in with -k by apratt at 91.01.10.13.15.22.
 * 
 * Revision 5.0  1990/08/22  08:12:54  eggert
 * Add -k.  Ansify and Posixate.
 *
 * Revision 4.3  89/05/01  15:13:02  narten
 * changed copyright header to reflect current distribution rules
 * 
 * Revision 4.2  87/10/18  10:36:33  narten
 * Updating version numbers. Changes relative to 1.1 actuallyt
 * relative to 4.1
 * 
 * Revision 1.2  87/09/24  14:00:10  narten
 * Sources now pass through lint (if you ignore printf/sprintf/fprintf 
 * warnings)
 * 
 * Revision 4.1  83/05/04  10:06:53  wft
 * Initial revision.
 * 
 */


#include "rcsbase.h"

libId(keysId, "$Id: rcskeys.c,v 5.1 1991/01/30 14:21:32 apratt Exp $")


const char *const Keyword[] = {
    /* This must be in the same order as rcsbase.h's enum markers type. */
	nil,
	AUTHOR, DATE, HEADER, IDH,
	LOCKER, LOG, RCSFILE, REVISION, SOURCE, STATE,
};



	enum markers
trymatch(string)
	const char *string;
/* function: Checks whether string starts with a keyword followed
 * by a KDELIM or a VDELIM.
 * If successful, returns the appropriate marker, otherwise Nomatch.
 */
{
        register int j;
	register const char *p, *s;
	for (j = sizeof(Keyword)/sizeof(*Keyword);  (--j);  ) {
		/* try next keyword */
		p = Keyword[j];
		s = string;
		while (*p++ == *s++) {
			if (!*p)
			    switch (*s) {
				case KDELIM:
				case VDELIM:
				    return (enum markers)j;
				default:
				    return Nomatch;
			    }
		}
        }
        return(Nomatch);
}

