/*
 * atof.c
 *
 *  Created on: 10.07.2017
 *      Author: og
 */

#include <stdlib.h>


double
atof(const char* c)
{
	return strtod(c, NULL);
}
