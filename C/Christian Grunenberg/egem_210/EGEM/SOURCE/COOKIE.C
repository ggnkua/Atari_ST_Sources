
#include <string.h>
#include "e_gem.h"

static 	long *get_cookiejar(void);

void create_cookie (COOKIE *cookie, long id, long value)
{
	*((long *) cookie)++ = id;
	*((long *) cookie)++ = value;
}

boolean	new_cookie (COOKIE *entry)
{
	reg long *cookiejar = get_cookiejar();
	reg int  act_row = 0;
	
	if (cookiejar)
	{		
		while (*cookiejar)
		{
			cookiejar+=2;
			act_row++;
		}
		
		if (act_row < cookiejar[1])
		{
			cookiejar[2] = cookiejar[0];
			cookiejar[3] = cookiejar[1];
			
			*cookiejar++ = *((long *) entry)++;
			*cookiejar++ = *((long *) entry)++;
			return(TRUE);
		}
	}
	return(FALSE);
}

boolean	get_cookie (long cookie, long *value)
{
	reg long *cookiejar = get_cookiejar();
	
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

void remove_cookie (long cookie_id)
{
	reg long *cookiejar = get_cookiejar();
	
	if (cookiejar)
	{	
		while (*cookiejar && *cookiejar!=cookie_id)
			cookiejar += 2;
		
		if (*cookiejar)
		{
			do
			{
				*cookiejar++ = cookiejar[2];
				*cookiejar++ = cookiejar[2];
			} while (*cookiejar);
		}
	}
}

void move_cookiejar (long *dest, long size)
{
	reg long old_stack,*cookiejar,*dest_cop=dest;
	
	old_stack = Super (NULL);
	cookiejar = *((long **) 0x5a0l);

	if (cookiejar)
		do
		{
			*dest++ = *cookiejar++;
			*dest++ = *cookiejar++;
		} while (*cookiejar);

	*dest++ = 0;
	*dest	= size;
		
	cookiejar = (long *) 0x5a0l;
	*cookiejar = (long) dest_cop;

	Super ((void *) old_stack);
}

long cookie_size()
{
	reg long *cookiejar = get_cookiejar();
	
	if (cookiejar)
	{
		while (*cookiejar)
			cookiejar+=2;
		return(*++cookiejar);
	}
	return(0);
}

static long *get_cookiejar()
{
	reg long old_stack,*jar;
	
	old_stack = Super (NULL);
	jar = *((long **) 0x5a0l);
	Super ((void *) old_stack);
	return (jar);
}
