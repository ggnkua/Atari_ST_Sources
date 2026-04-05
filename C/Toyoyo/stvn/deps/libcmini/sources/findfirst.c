/*
 * findfirst.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <errno.h>
#include <mint/osbind.h>
#include "lib.h"


int findfirst(const char* filename, struct ffblk* ffblk, int attrib)
{
	_DTA* dta;
    long rc;

    dta = Fgetdta();

    // struct ffblk is identical to _DTA
	Fsetdta(ffblk);
	rc = Fsfirst(filename, attrib);

	Fsetdta(dta);

    if (rc < 0)
    {
        __set_errno(-rc);
		return -1;
	}

	return 0;
}
