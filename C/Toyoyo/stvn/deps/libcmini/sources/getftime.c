/*
 * getftime.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <errno.h>
#include <mint/osbind.h>
#include "lib.h"


int getftime(int handle, struct ftime* ftimep)
{
	if (handle < 0 || Fseek(0, handle, SEEK_CUR) < 0)
    {
        __set_errno(EBADF);
		return -1;
	}

    Fdatime(ftimep, handle, 0);

	return 0;
}
