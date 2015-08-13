/* (C) Dr. Thomas Redelberger, Dec 1999 */
/* Sting Access */
/*
$Id: lnk2stng.c 1.1 1999/12/30 12:55:34 Thomas Exp Thomas $
*/


#define NULL ((void*) 0)	/* usually in stdio.h and/or stdlib.h */

#include <string.h>
#include <tos.h>
#include "transprt.h"





/************************************************************************************************/
/************************************************************************************************/

static long getStingCookie (void)
{
	long  *p;

	for (p = * (long **) 0x5a0L; *p ; p += 2)
		if (*p == 'STiK')
			return *++p;

	return 0L;
}	/* getStingCookie */



/************************************************************************************************/
/************************************************************************************************/

TPL *tpl;				/* extern in transport.h */

int link2Sting(void)
{
	DRV_LIST *sting_drivers;

	if ( (sting_drivers = (DRV_LIST*) Supexec(getStingCookie)) == NULL )
		return -1;

	if (strcmp (sting_drivers->magic, MAGIC) != 0)
		return -1;

	if ( (tpl = (TPL*) (*sting_drivers->get_dftab) (TRANSPORT_DRIVER)) == NULL)
		return -1;

	return 0;	/* OK */
}	/* link2Sting */

