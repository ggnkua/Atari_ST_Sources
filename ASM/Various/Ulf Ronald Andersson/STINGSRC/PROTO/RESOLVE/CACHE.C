/*----------------------------------------------------------------------------*/
/* File name:	CACHE.C							Revision date:	1998.01.19	  */
/* Authors:		Peter Rottengatter  &			Creation date:	1997.04.09	  */
/*				Ronald Andersson											  */
/*----------------------------------------------------------------------------*/
/* Purpose:		DNS Cache functions											  */
/*----------------------------------------------------------------------------*/

#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <sting\transprt.h>
#include <sting\resolve.h>


void	wait_flag (int16 *semaphore);
void	rel_flag (int16 *semaphore);

char *	Ca_first_dom(void);
char *	Ca_next_dom(void);
char *	Ca_curr_dom(void);
uint32	Ca_curr_IP(void);

int16	load_cache (void);
int16	save_cache (void);
void	erase_cache (void);
void	clean_up (void);
int16	query_name (char *name, char *real, uint32 *IP_list, int16 size);
int16	query_IP (uint32 addr, char *real, uint32 *IP_list, int16 size);
void	update_cache (char *name, uint32 addr, uint32 ttl, int16 type);
int16	compare (char *first, char *second);


extern	char  *c_file;

CACHE	*cache_root = NULL;
int16	cache_num = 0, sema_cache = 0;
CACHE	*scan_c_p = NULL;
DNAME	*scan_d_p = NULL;
/*----------------------------------------------------------------------------*/

char *	Ca_first_dom(void)
{	scan_c_p = cache_root;
	scan_d_p = NULL;
	if	(scan_c_p)
		return (scan_c_p->real.name);
	return (NULL);
}	/* ends function Ca_first_dom */

/*----------------------------------------------------------------------------*/

char *	Ca_next_dom(void)
{	if	(scan_c_p)
	{	if	(scan_d_p)
			scan_d_p = scan_d_p->next;	/* next alias */
		else
			scan_d_p = scan_c_p->alias;	/* first alias */
		if	(scan_d_p)
			return (scan_d_p->name);
		scan_c_p = scan_c_p->next;
		if	(scan_c_p)
			return (scan_c_p->real.name);
	}
	return (NULL);
}	/* ends function Ca_next_dom */

/*----------------------------------------------------------------------------*/

char *	Ca_curr_dom(void)
{	if	(scan_d_p)
		return (scan_d_p->name);
	if	(scan_c_p)
		return (scan_c_p->real.name);
	return (NULL);
}	/* ends function Ca_curr_dom */

/*----------------------------------------------------------------------------*/

uint32	Ca_curr_IP(void)
{	if	(scan_c_p)
		return (scan_c_p->IP_address);
	return (0L);
}	/* ends function Ca_curr_IP */

/*----------------------------------------------------------------------------*/

int16	load_cache()

{	CACHE	*c_walk, **c_prev;
	DNAME	*d_walk, **d_prev;
	char	*n_walk;
	long	error;
	int		handle, cf, af;

	if ((error = Fopen (c_file, FO_RW)) < 0)
		return (-1);

	handle = (int) error;

	if	(cache_root)
		erase_cache();

	wait_flag (& sema_cache);

	c_prev = & cache_root;

	af = 0;
	do
	{	*c_prev = NULL;
		if (af == 1)
			break;
		cf = 1;

		if ((c_walk = KRmalloc (sizeof (CACHE))) == NULL)
			break;
		if	( (Fread (handle, sizeof (CACHE), c_walk) != sizeof (CACHE))
			|| ((n_walk = KRmalloc (c_walk->real.length + 1)) == NULL)
			)
			goto bk_c_walk;

		if ( (Fread (handle, c_walk->real.length, n_walk) != c_walk->real.length)
			||  (	(is_domname (n_walk, c_walk->real.length)==NULL)
				&&	(is_dip(n_walk) == NULL)
				)
			)
		{	KRfree (n_walk);
bk_c_walk:	KRfree (c_walk);
			break;
		}
		*(n_walk + c_walk->real.length) = '\0';
		c_walk->real.name = n_walk;

		*c_prev = c_walk;   c_prev = & c_walk->next;
		cache_num++;

		for (d_prev = & c_walk->alias, af = 0; *d_prev != NULL;)
		{	*d_prev = NULL;
			af = 1;

			if ((d_walk = KRmalloc (sizeof (DNAME))) == NULL)
				break;
			if	( (Fread (handle, sizeof (DNAME), d_walk) != sizeof (DNAME))
				||  ((n_walk = KRmalloc (d_walk->length + 1)) == NULL)
				)
				goto bk_d_walk;

			if ( (Fread (handle, d_walk->length, n_walk) != d_walk->length)
				||  (	(is_domname (n_walk, d_walk->length)==NULL)
					&&	(is_dip(n_walk) == NULL)
					)
				)
			{	KRfree (n_walk);
bk_d_walk:		KRfree (d_walk);
				break;
			}
			*(n_walk + d_walk->length) = '\0';
			d_walk->name = n_walk;

			*d_prev = d_walk;   d_prev = & d_walk->next;
			af = 0;
		}
		cf = 0;
	} while (*c_prev != NULL);

	clean_up();
	rel_flag (& sema_cache);
	Fclose (handle);
	scan_c_p = cache_root;
	scan_d_p = NULL;
	return ((cf == 1) ? -1 : 0);

}	/* ends function load_cache */

/*----------------------------------------------------------------------------*/

int16	save_cache()

{	CACHE	*walk;
	DNAME	*alias;
	long	error;
	int		handle;

	if ((error = Fcreate (c_file, 0)) < 0)
		return (-1);

	handle = (int) error;
	wait_flag (& sema_cache);

	for (walk = cache_root; walk; walk = walk->next)
	{	if (Fwrite (handle, sizeof (CACHE), walk) != sizeof (CACHE))
			break;
		if (Fwrite (handle, walk->real.length, walk->real.name) != walk->real.length)
			break;
		for (alias = walk->alias; alias; alias = alias->next)
		{	if (Fwrite (handle, sizeof (DNAME), alias) != sizeof (DNAME))
				break;
			if (Fwrite (handle, alias->length, alias->name) != alias->length)
				break;
		}
		if (alias)   break;
	}
	rel_flag (& sema_cache);
	Fclose (handle);
	return ((walk != NULL) ? -1 : 0);

}	/* ends function save_cache */

/*----------------------------------------------------------------------------*/

void	erase_cache(void)

{	CACHE	*walk, *c_tmp;
	DNAME	*alias, *d_tmp;

	wait_flag (& sema_cache);

	for (walk = cache_root; walk;)
	{	for (alias = walk->alias; alias;)
		{	d_tmp = alias->next;
			KRfree(alias->name);
			KRfree(alias);
			alias = d_tmp;
		}
		c_tmp = walk->next;
		KRfree(walk->real.name);
		KRfree(walk);
		walk = c_tmp;
	}
	cache_root = scan_c_p = (CACHE *) (scan_d_p = NULL);
	cache_num = 0;

	rel_flag (& sema_cache);
}	/* ends function erase_cache */

/*----------------------------------------------------------------------------*/

void	clean_up()

{	CACHE	*c_walk, **c_prev, **crush;
	DNAME	*d_walk, **d_prev, *temp;
	uint32	now, ago;
	int16	max_number, chg_flag = 0;

	now = time (NULL);

	for (c_walk = *(c_prev = & cache_root); c_walk; c_walk = *c_prev)
	{	if (c_walk->real.expiry < now  &&  c_walk->real.expiry != 0L)
		{ 
			for (d_walk = c_walk->alias; d_walk; d_walk = temp)
			{
				temp = d_walk->next;
				KRfree (d_walk->name);   KRfree (d_walk);
			}
			*c_prev = c_walk->next;
			--cache_num;
			KRfree (c_walk->real.name);   KRfree (c_walk);
			chg_flag++;
		}
		else
		{	for (d_walk = *(d_prev = & c_walk->alias); d_walk; d_walk = *d_prev)
			{	if (d_walk->expiry < now  &&  c_walk->real.expiry != 0L)
				{	*d_prev = d_walk->next;
					KRfree (d_walk->name);
					KRfree (d_walk);
					chg_flag++;
				}
				else
				{
					d_prev = & d_walk->next;
				}
			}
			c_prev = & c_walk->next;
		}
	}

	if ((max_number = atoi (getvstr ("DNS_CACHE"))) < 5)
		max_number = 32;

	while (cache_num > max_number)
	{	ago = now;
		for (c_walk = *(c_prev = & cache_root); c_walk; c_walk = *c_prev)
		{	if (c_walk->used < ago)
			{	crush = c_prev;
				ago = c_walk->used;
			}
			c_prev = & c_walk->next;
		}
		c_walk = *crush;
		--cache_num;
		for (d_walk = c_walk->alias; d_walk; d_walk = temp)
		{	temp = d_walk->next;
			KRfree (d_walk->name);
			KRfree (d_walk);
		}
		*crush = c_walk->next;
		KRfree (c_walk->real.name);
		KRfree (c_walk);
		chg_flag++;
	}
	if (chg_flag)
	{	scan_c_p = cache_root;
		scan_d_p = NULL;
	}
}	/* ends function cleanup */

/*----------------------------------------------------------------------------*/

int16	query_name (name, real, IP_list, size)

char	*name, *real;
uint32	*IP_list;
int16	size;

{	CACHE	*walk;
	DNAME  *alias;
	int16  length, count = 0, alias_flag = TRUE;

	wait_flag (& sema_cache);

	clean_up();
	length = strlen (name);

	for (walk = cache_root; walk && count < size; walk = walk->next)
	{	if (walk->real.length == length && compare(walk->real.name, name) == 0)
		{	IP_list[count++] = walk->IP_address;
			alias_flag = 0;
			strcpy (real, walk->real.name);
			walk->used = time (NULL);
			continue;
		}
		for (alias = walk->alias; alias && count < size; alias = alias->next)
		{	if (alias->length == length && compare(alias->name, name) == 0)
			{	IP_list[count++] = walk->IP_address;
				if	(alias_flag)
					strcpy (real, walk->real.name);
				walk->used = time (NULL);
				break;
			}
		}	/* ends inner for loop */
	}	/* ends outer for loop */
	rel_flag (& sema_cache);
	return (count);
}	/* ends function query_name */

/*----------------------------------------------------------------------------*/

int16  query_IP (addr, real, IP_list, size)

char    *real;
uint32  addr, *IP_list;
int16   size;

{	CACHE  *walk;
	int16  found = 0;

	wait_flag (& sema_cache);
	clean_up();

	for (walk = cache_root; walk; walk = walk->next)
	{	if (walk->IP_address == addr)
		{	if (size)
				*IP_list = addr;
			strcpy (real, walk->real.name);		found = 1;
			walk->used = time (NULL);
			break;
		}
	}

	rel_flag (& sema_cache);
	return (found);
}	/* ends function query_IP */

/*----------------------------------------------------------------------------*/

void	update_cache (name, addr, ttl, type)
char	*name;
uint32	addr, ttl;
int16	type;
{	CACHE   *walk;
	DNAME   *alias;
	uint32  now, expiry;
	int16   length;

	wait_flag (& sema_cache);

	if	(ttl != 0x87654321L)
		expiry = (now = time (NULL)) + ttl;
	else
	{	now = time (NULL);
		expiry = 0;	/* infinite */
	}
	length = strlen (name);

	if	(type == DNS_A)		/* update DNS_A entry */
	{	walk = cache_root;
		while
		(	walk &&
			(	walk->real.length != length
			||	compare(walk->real.name, name) != 0
			||	walk->IP_address != addr
			||  walk->real.type != type
			)
		)	walk = walk->next;
		if (walk == NULL)
		{	if ((walk = KRmalloc (sizeof (CACHE))) == NULL)
			{	rel_flag (& sema_cache);
				return;
			}
			if ((walk->real.name = KRmalloc (length + 1)) == NULL)
			{	KRfree (walk);
				rel_flag (& sema_cache);
				return;
			}
			strcpy (walk->real.name, name);
			walk->real.length = length;
			walk->real.type = type;
			walk->real.next = walk->alias = NULL;
			cache_num++;
			walk->next = cache_root;   cache_root = walk;
			walk->IP_address = addr;
		}
		walk->real.expiry = expiry;
	}
	else					/* update non-DNS_A entry (alias) */
	{	for ( walk = cache_root; walk; walk = walk->next )
		{	if	( walk->IP_address == addr )
			{	if	(	walk->real.length == length
					&&	compare(walk->real.name, name) == 0
					)
				{	walk->real.expiry = expiry;
					break;
				}
				alias = walk->alias;
				while
				(	alias &&
					(	alias->length != length
					||	compare (alias->name, name) != 0
					)
				)	alias = alias->next;
				if	(alias == NULL)
				{	if	((alias = KRmalloc (sizeof (DNAME))) == NULL)
					{	rel_flag (& sema_cache);
						return;
					}
					if	((alias->name = KRmalloc (length + 1)) == NULL)
					{	KRfree (alias);
						rel_flag (& sema_cache);
						return;
					}
					strcpy (alias->name, name);
					alias->length = length;   alias->type = type;
					alias->expiry = expiry;
					alias->next = walk->alias;   walk->alias = alias;
				}	/* ends if */
				break;
			}	/* ends if */
		}	/* ends outer loop */
	}	/* ends if */
	if	(walk)
		walk->used = now;
	clean_up();

	rel_flag (& sema_cache);

	if (strcmp (getvstr ("DNS_SAVE"), "1") == 0 || strcmp (getvstr ("DNS_SAVE"), "TRUE") == 0)
		save_cache();
}	/* ends function update_cache */

/*----------------------------------------------------------------------------*/

int16  compare (first, second)

char  *first, *second;

{	char	one, two;

	while (*first != '\0' && *second != '\0') {
		one = *first++;
		two = *second++;
		if (one >= 'a' && one <= 'z')   one -= 'a' - 'A';
		if (two >= 'a' && two <= 'z')   two -= 'a' - 'A';
		if (one != two)   return (1);
	}
	return (0);
}	/* ends function compare */

/*----------------------------------------------------------------------------*/
/* End of file:	CACHE.C														  */
/*----------------------------------------------------------------------------*/
