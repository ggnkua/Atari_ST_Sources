/*
 * $Id: cookie.c pdonze Exp $
 * 
 * TOS.LIB - (c) 1998 - 2006 Philipp Donze
 *
 * A replacement for PureC PCTOSLIB.LIB
 *
 * This file is part of TOS.LIB and contains the implementation of cookie
 * handling functions. Using the Ssystem call if available.
 *
 * TOS.LIB is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * TOS.LIB is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with the GNU C Library; see the file COPYING.LIB.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#include <tos.h>
#include <sysvars.h>
#include <cookie.h>

#define	NULL	((void*)0L)
#define	TRUE	1
#define	FALSE	0

static short has_ssystem = -1;

static long __init_cookie(void)
{
	return (long)(*_p_cookies);
}

short Getcookie(long cookie, long *value)
{
	/* Check for Ssystem if not done yet */
	if (has_ssystem < 0)
		has_ssystem = Ssystem(-1, 0, 0) == 0;

	/* Use Ssystem if available... */
	if (has_ssystem > 0)
	{
		long r, val=-42;

		r = Ssystem(S_GETCOOKIE, cookie, (long)&val);
		/*
		 * Backward compatibility for MiNT 1.14.7:
		 * Ssystems() returns cookie value and ignores arg2!!
		 */
		if (r != -1 && val == -42)				
			val = r;
		if (!r)
		{
			if (value)
				*value = val;
			return C_FOUND;
		}
		else
		{
			if (value)
				*value = 0L;
			return C_NOTFOUND;
		}
	}
	else
	{
		/* Check get address of cookie jar */
		long *jar = (long *)Supexec(__init_cookie);
		
		if(jar == NULL)
			return C_JARNOTINSTALLED;
		
		do
		{
			if (jar[0] == cookie)			/* check if cookie already exists */
			{
				if (value)
					*value = jar[1];		/* extract value */

				return C_FOUND;				/* Return success */
			}
			else
				jar = &(jar[2]);			/* continue search... */
		}while(jar[-2]);					/* ... up to end of cookie list */

		return C_NOTFOUND;					/* Inform user about failure */
	}
}

short Setcookie(long cookie, long value)
{
	/* Check for Ssystem if not done yet */
	if (has_ssystem < 0)
		has_ssystem = Ssystem(-1, 0, 0) == 0;
	
	/* Use Ssystem if available... */
	if (has_ssystem > 0)
	{
		long r;
		r = Ssystem(S_SETCOOKIE, cookie, value);
		if (!r)
			return C_OK;
		else
			return C_NOTFOUND;
	}
	else
	{
		short count = 0;
		
		/* Check get address of cookie jar */
		long *jar = (long *)Supexec(__init_cookie);
		
		if(jar == NULL)
			return C_JARNOTINSTALLED;
		
		do
		{
			count++;						/* count number of cookies */
			if(jar[0] == cookie)			/* check if cookie already exists */
			{
				jar[1] = value;
				return C_OK;
			}
			else
				jar = &(jar[2]);			/* continue search... */
		}while(jar[-2]);					/* ... up to end of cookie list */

		if(jar[-1]>count)					/* check if there is enought space */
		{
			jar[0] = 0;						/* Move empty cookie,,,*/
			jar[1] = jar[-1];				/* ... including value */
			jar[-2] = cookie;				/* Set our own cookie... */
			jar[-1] = value;				/* ... and value */
			return C_OK;					/* Return successful addition */
		}
		else
			return C_JARFULL;				/* Inform user about missing space */
	}
}

short Removecookie(long cookie)
{
	/* Check for Ssystem if not done yet */
	if (has_ssystem < 0)
		has_ssystem = Ssystem(-1, 0, 0) == 0;
	
	/* Use Ssystem if available... */
	if (has_ssystem > 0)
	{
		long r;
		r = Ssystem(S_DELCOOKIE, cookie, (long)NULL);
		if (!r)
			return C_OK;
		else
			return C_NOTFOUND;
	}
	else
	{
		/* Check get address of cookie jar */
		long *jar = (long *)Supexec(__init_cookie);
		
		if(jar == NULL)
			return C_JARNOTINSTALLED;
		
		do
		{
			if (jar[0] == cookie)			/* Check if it's our cookie */
			{
				do
				{
					jar[0] = jar[2];		/* Move all cookies 1 entry up... */
					jar[1] = jar[3];
					jar = &(jar[2]);		/* Next cookie */
				}while(jar[-2]);			/* Up to the end of the list */
				return C_OK;				/* Return successful remove */
			}
			else
				jar = &(jar[2]);			/* continue search... */
		}while(jar[-2]);					/* Up to the end of the list */

		return C_NOTFOUND;					/* Inform user about failure */
	}
}
