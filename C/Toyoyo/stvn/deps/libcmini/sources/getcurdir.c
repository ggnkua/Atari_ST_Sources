/*
 * getcurdir.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <mint/osbind.h>


int
getcurdir(int drive, char* path)
{
	int ret = Dgetpath(path, drive);

	if (ret < 0) {
		ret = -1;
	}

	return ret;
}
