/*
 * Utility functions for Teradesk. Copyright 1993, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <tos.h>
#include <stddef.h>
#include <library.h>
#include <system.h>

#undef p_cookie
#define p_cookie	( * (COOKIE **) 0x5A0L )

void cookie_reset( void );

long o_resvalid;
void (*o_resvector)( void );

void jmpa6( void ) 0x4ED6;

static void cookie_reset( void )
{
	p_cookie = NULL;
	resvector = o_resvector;
	resvalid = o_resvalid;
	jmpa6();
}

#if _MINT_
extern int have_ssystem;
#endif

long find_cookie( long name )		/* HR 151102: return cookie value or -1 */
{
	COOKIE *cookie;
#if _MINT_
	if (have_ssystem)
		Ssystem(S_GETCOOKIE, name, (long) &name);
	else
#endif
	{
		void *old_stack;
	
		old_stack = (void *)Super(NULL);
	
		if ((cookie = p_cookie) != NULL)
		{
			while ((cookie->name != 0) && (cookie->name != name))
				cookie++;
			if (cookie->name == 0L)
				name = -1;
			else
				name = cookie->value;
		}
	
		Super(old_stack);
	}
	return name;
}

/* install_cookie is not used by Teradesk */
/* r = -1 : fout,
   r =  0 : geen fout,
   r =  1 : nieuw cookie geinstalleerd, reset vast,
   r =  2 : nieuw cookie geinstalleerd, niet reset vast. */

int install_cookie( long name,long value,COOKIE *buffer,long l )
{
	void *stack;
	int r,i,j;
	COOKIE *cookie;

	stack = (void *)Super(NULL);

	if ((cookie = p_cookie) != NULL)
	{
		i = 0;

		while (cookie[i].name != 0L)
			i++;

		if (cookie[i].value > (i + 1))
			{
			cookie[i+1] = cookie[i];
			cookie[i].name = name;
			cookie[i].value = value;

			r = 0;
		}
		else
		{
			if ((l <= cookie[i].value) || (buffer == NULL))
				r = -1;
			else
			{
				int e;		/* HR 151102: reserve 'end' for lamgiage */

				e = (int)cookie[i].value - 1;

				for(j = 0;j < e;j++)
					buffer[j] = cookie[j];

				p_cookie = buffer;

				cookie[i].name = name;
				cookie[i].value = value;
				cookie[i+1].name = 0L;
				cookie[i+1].value = l;

				r = 1;
			}
		}
	}
	else
	{
		if ((l < 2) || (buffer == NULL))	/* cookie te klein */
			r = -1;
		else
		{
			o_resvalid = resvalid;
			o_resvector = resvector;
			resvalid = 0x31415926L;
			resvector = cookie_reset;

			p_cookie = buffer;

			buffer[0].name = name;
			buffer[0].value = value;
			buffer[1].name = 0L;
			buffer[1].value = l;

			r = 1;
		}
	}

	Super(stack);

	return r;
}
