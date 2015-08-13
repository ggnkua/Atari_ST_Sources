head	1.1;
access;
symbols
	TRLPR10B:1.1
	TRLPR09B:1.1;
locks; strict;
comment	@ * @;


1.1
date	99.03.08.21.21.46;	author Thomas;	state Exp;
branches;
next	;


desc
@Source code of auxiliary module for lpr.ttp: Sting access
@


1.1
log
@Initial revision
@
text
@#define NULL ((void*) 0)	/* usually in stdio.h and/or stdlib.h */

#include <string.h>
#include <tos.h>
#include "transprt.h"


/* These definitions are necessary.  transprt.h has external
 * declarations for them.
 */
DRV_LIST *drivers = (DRV_LIST *)NULL;
TPL *tpl = (TPL *)NULL;



/* Put 'STIK' cookie value into drivers */

typedef struct {
    long cktag;
    long ckvalue;
} ck_entry;


static long init_drivers(void)
{
	long i = 0;
	ck_entry *jar = *((ck_entry **) 0x5a0);

	while (jar[i].cktag) {
		if (!strncmp((char *)&jar[i].cktag, CJTAG, 4)) {
			drivers = (DRV_LIST *)jar[i].ckvalue;
			return 0;
		}
		++i;
	}
	return 0;	/* Pointless return value...	*/
}



int initialise(void)
{
	Supexec(init_drivers);

	/* See if we got a value	*/

	if (drivers == (DRV_LIST *)NULL) {
		Cconws("Error: STinG is not loaded\n");
		return FALSE;
	}

	/* Check Magic number	*/

	if (strcmp(MAGIC, drivers->magic)) {
		Cconws("Error: STinG magic string doesn't match\n");
		return FALSE;
	}

	/* OK, now we can get the address of the "TRANSPORT" layer
	 * driver.  If this seems unnecessarily complicated, it's
	 * because I tried to create today, what I would like to
	 * use later on.  In future, there will be multiple
	 * drivers accessible via this method.  With luck, your
	 * code will still work with future versions of my software.
	 */

	tpl = (TPL *)get_dftab(TRANSPORT_DRIVER);

	if (tpl == (TPL *)NULL) {
		Cconws("Error: STing transport layer *not* loaded\n");
		return FALSE;
	}
#ifdef DEBUG
	Cconws("Transport layer loaded, author ");
	Cconws(tpl->author);
	Cconws(", version ");
	Cconws(tpl->version);
	Cconws("\r\n");
#endif
	return TRUE;
}
@
