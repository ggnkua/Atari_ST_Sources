/*
 * atoi.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <string.h>
#include <stdlib.h>

#define ISSPACE(c)  (((c) == ' ') || ((c) == '\t') || ((c == '\n')) || ((c) == '\r') || ((c) == '\v'))
#define ISDIGIT(c)	((unsigned char)(c) >= '0' && (unsigned char)(c) <= '9')

int atoi(const char *c)
{
	int value = 0;
	int negative = 0;

	while (ISSPACE(*c))
		c++;

	if (*c == '+')
	{
		c++;
	} else if (*c == '-')
	{
		negative = 1;
		c++;
	}

	while (ISDIGIT(*c))
	{
		value *= 10;
		value += *c - '0';
		c++;
	}

	if (negative)
	{
		value = -value;
	}

	return value;
}

#if !(defined(__MSHORT__) || defined(__PUREC__) || defined(__AHCC__))
long atol(const char *c) __attribute__((alias("atoi")));
#endif
