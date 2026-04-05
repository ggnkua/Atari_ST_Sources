/*
 * getdfree.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <mint/osbind.h>


void
getdfree(unsigned char drive, struct dfree* dtable)
{
    // struct dfree is identical to _DISKINFO

    if (Dfree(dtable, (short)drive) < 0) {
		dtable->df_sclus = -1;
	}
}
