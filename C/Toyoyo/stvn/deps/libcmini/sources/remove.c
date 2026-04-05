/*
 * remove.c
 *
 *  Created on: 12.07.2017
 *      Author: og
 */


#include <errno.h>
#include <stdio.h>
#include <mint/osbind.h>
#include "lib.h"

int remove(const char *filename)
{
	int ret = Ddelete(filename);

	if (ret == -ENOTDIR)
	{
		ret = Fdelete(filename);
	}
	if (ret < 0)
	{
		__set_errno(-ret);
		return -1;
	}
	return 0;
}
