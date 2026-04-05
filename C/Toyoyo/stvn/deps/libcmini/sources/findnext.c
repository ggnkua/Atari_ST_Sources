/*
 * findnext.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <errno.h>
#include <mint/osbind.h>
#include "lib.h"


int findnext(struct ffblk* ffblk)
{
	_DTA* dta;
	int rc;

    dta = Fgetdta();

	// struct ffblk is identical to _DTA
	Fsetdta(ffblk);
    rc = Fsnext();

	Fsetdta(dta);

    if (rc < 0)
    {
        __set_errno(-rc);
		return -1;
	}

	return 0;
}
