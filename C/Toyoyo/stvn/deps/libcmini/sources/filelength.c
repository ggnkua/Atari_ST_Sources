/*
 * filelength.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <errno.h>
#include <mint/osbind.h>
#include "lib.h"


long filelength(int handle)
{
	long ret;
	long pos;

    pos = Fseek(0, handle, SEEK_CUR);

	if (pos < 0)
    {
        __set_errno(-pos);
		return -1;
	}

    ret = Fseek(0, handle, SEEK_END);

    if (ret < 0)
    {
        __set_errno(-ret);
        return -1;
    }

    Fseek(pos, handle, SEEK_SET);

	return ret;
}
