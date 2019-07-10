/*
 * browser.h -- defines some structures used by the file browser
 *
 * 91Jan24 AA	Created.
 */

#ifndef _BROWSER_H
#define _BROWSER_H

#include "dirlist.h"

/* #undef BROWSER */		/* disable the browser */
#define BROWSER	/* enable the browser */

#ifdef BROWSER

typedef struct _browser_entry {
	long br_size;
	char br_name[14];
	struct date_t br_date;
	int br_room;
} brList;

struct _browse {
	brList *list;	/* points to an array of filenames */
	int count;	/* how many are in the array */
	int numalloc;	/* how many array slots are allocated */
	int limit;	/* total of file sizes in browser */
	int user;	/* logindex of user who created this list */
} ;

extern struct _browse	browse;		/* main browse list */

#endif BROWSER

#endif _BROWSER_H
