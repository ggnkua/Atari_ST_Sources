/*
 * rename.c
 *
 *  Created on: 12.07.2017
 *      Author: og
 */

#include <stdio.h>
#include <mint/osbind.h>
#include "lib.h"

int rename(const char *oldname, const char *newname)
{
	int ret = Frename(0, oldname, newname);
	if (ret < 0)
	{
		__set_errno(-ret);
		return -1;
	}
	return 0;
}
