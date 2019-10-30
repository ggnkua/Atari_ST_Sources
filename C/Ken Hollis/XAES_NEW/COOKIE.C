/********************************************************************
 *																1.01*
 *	XAES: Cookie Management											*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	Christian Grunenberg's original cookiejar routines were buggy	*
 *	as hell.  These were his originals.  I have yet to change it so	*
 *	'add' cookie works.  For now, get cookie routines work fine...	*
 *																	*
 ********************************************************************/

#include <stddef.h>
#include <tos.h>
#include "xaes.h"

/*
 *	This returns the base address of the cookie jar
 */
GLOBAL long *get_cookiejar(void)
{
	register long old_stack, *jar;

	old_stack = (long) Super(0L);
	jar = *((long **) 0x5A0L);
	Super((long *) old_stack);
	return(jar);
}

/*
 *	This creates a cookie ID and returns it in the cookie value.
 */
GLOBAL void create_cookie(COOKIE *cookie, long id, long value)
{
	*((long *) cookie)++ = id;
	*((long *) cookie) = value;
}

/*
 *	This searches for a cookie with the 'id' name, and it returns
 *	the value (via address, how sweet) of the cookie jar as a nice
 *	typedef.
 */
GLOBAL COOKIE *find_cookie(long id)
{
	long *jar;

	if (((long *)jar = get_cookiejar()) == 0)
		return(0);

	while(*jar) {
		if(*jar == id) return((COOKIE *)jar);
		jar += 2;
	}

	return(0);
}

/*
 *	Creates a new cookie jar entry
 */
GLOBAL int new_cookie(COOKIE *ent)
{
	register long *cookiejar = get_cookiejar();
	register int act_row = 0;

	if (cookiejar) {
		while(*cookiejar) {
			cookiejar += 2;
			act_row++;
		}

		if (act_row < cookiejar[1]) {
			cookiejar[2] = cookiejar[0];
			cookiejar[3] = cookiejar[1];

			*cookiejar++ = *((long *) ent)++;
			*cookiejar = *((long *) ent);
			return(TRUE);
		}
	}
	return(FALSE);
}

/*
 *	This searches for a cookie and makes sure it exists.
 */
GLOBAL BOOL get_cookie (long cookie, long *value)
{
	register long *cookiejar = get_cookiejar();
	
	if (cookiejar)
	{
		while (*cookiejar)
		{
			if (*cookiejar==cookie)
			{
				if (value)
					*value = *++cookiejar;
				return(TRUE);
			}
			cookiejar += 2;
		}
	}
	return(FALSE);
}

/*
 *	This is a little simpler version of the routine above stated.
 */
GLOBAL int locate_cookie(long cookie)
{
	if ((find_cookie(cookie)) != NULL)
		return TRUE;
	else
		return FALSE;
}

/*
 *	This allows you to eat a cookie from the cookie jar.
 */
GLOBAL void remove_cookie(long cookie_id)
{
	register long *cookiejar = get_cookiejar();

	if (cookiejar) {
		while (*cookiejar && cookiejar[1]!=cookie_id)
			cookiejar += 2;

		if (*cookiejar)
			do {
				*cookiejar++ = cookiejar[2];
				*cookiejar = cookiejar[2];
			} while(*cookiejar);
	}
}

/*
 *	This moves the address of the entire cookie jar to another
 *	address that you hopefully mallocated, and reserved.
 */
GLOBAL void move_cookiejar(long *dest, long size)
{
	register long old_stack, *cookiejar, *dest_cop;

	old_stack = (long) Super(0L);
	cookiejar = *((long **) 0x5A0L);

	if (cookiejar) {
		dest_cop = dest;

		do {
			*dest++ = *cookiejar++;
			*dest++ = *cookiejar++;
		} while (*cookiejar);

		*dest++ = *cookiejar;
		*dest = size;

		cookiejar = (long *) 0x5A0L;
		*cookiejar = (long) dest_cop;
	}

	Super((long *) old_stack);
}

/*
 *	This returns the size of the cookie jar.
 */
GLOBAL long cookie_size()
{
	register long *cookiejar = get_cookiejar();

	if (cookiejar) {
		while(*cookiejar) cookiejar += 2;
		return(*++cookiejar);
	}

	return(0);
}
