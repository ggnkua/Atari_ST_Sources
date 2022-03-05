#include <stdio.h>
#include <string.h>
#include <ctype.h>

/*
 * note:  For strict ANSI conformance, these functions need overflow
 *	  checking and should set errno.
 */

static char numstr[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";

long strtol(number, nptr, base)
	register char *number;
	char **nptr;
	int base;
	{
	char digits[38];
	register long n = 0, neg = 0, lbase = ((long) base);
	register char *p;

	strcpy(digits, numstr);
	while(isspace(*number))
		++number;
	if(*number == '-')
		{
		neg = 1;
		++number;
		}
	else if(*number == '+')
		++number;
	if(lbase == 0)
		{
		if(*number == '0')
			{
			++number;
			if(toupper(*number) == 'X')
				{
				++number;
				lbase = 16;
				}
			else
				lbase = 8;
			}
		}
	else if((lbase == 16)
	     && (number[0] == '0')
	     && (toupper(number[1]) == 'X'))
			number += 2;
	digits[base] = '\0';
	while(p = strchr(digits, toupper(*number)))
		{
		++number;
		n = (n * lbase) + ((long) (p - digits));
		}
	if(nptr)
		*nptr = number;
	return(neg ? -n : n);
	}

unsigned long strtoul(number, nptr, base)
	register char *number;
	char **nptr;
	int base;
	{
	char digits[38];
	register unsigned long n = 0;
	register long lbase = ((long) base);
	register char *p;

	strcpy(digits, numstr);
	while(isspace(*number))
		++number;
	if(lbase == 0)
		{
		if(*number == '0')
			{
			++number;
			if(toupper(*number) == 'X')
				{
				++number;
				lbase = 16;
				}
			else
				lbase = 8;
			}
		}
	else if((lbase == 16)
	     && (number[0] == '0')
	     && (toupper(number[1]) == 'X'))
			number += 2;
	digits[base] = '\0';
	while(p = strchr(digits, toupper(*number)))
		{
		n = (n * lbase) + ((long) (p - digits));
		++number;
		}
	if(nptr)
		*nptr = number;
	return(n);
	}
