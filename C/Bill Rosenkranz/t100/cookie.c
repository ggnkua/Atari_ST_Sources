/*
 *	cookie.c
 */

#ifndef lint
static char *rcsid_cookie_c = "$Id: cookie.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: cookie.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */

#include <stdlib.h>
#include <string.h>
#include <osbind.h>
#include <stdio.h>
#include "t100.h"

/* Most of the cookie code here by Eric R. Smith */


/*
 *	we use a union because most cookie tags are 4 ASCII characters,
 *	so it may be useful to sometimes think of them as strings. On the
 *	other hand, they *are* longwords, so we may want to access them
 *	that way, too
 */
union clong
{
	char    aschar[4];
	long    aslong;
};


/*
 *	a cookie consists of 2 longwords; a tag and a value. The tag is
 *	normally chosen to have some sort of significance when represented
 *	as 4 ascii characters (see the union definition above). What the
 *	value represents is dependent on the tag; it may be an address (for
 *	a TSR), or a version number (e.g. MiNT does this), or whatever (it
 *	may not even have a meaning).
 */
struct cookie
{
	union clong	tag;
	long		value;
};

typedef struct cookie   COOKIE;


/*
 *	A pointer to the cookie jar is found at 0x5a0. If there is no cookie
 *	jar installed, this pointer will be 0. The cookie jar itself is an
 *	array of cookies, with the last cookie having a "tag" of 0x00000000.
 *	(The value of this cookie is the number of slots left in the cookie
 *	jar.)
 */
#define CJAR		((COOKIE **) 0x5a0)




/*------------------------------*/
/*	getcookie		*/
/*------------------------------*/
long getcookie (char *cookieid)
{
	char    biscuit[5];
	long    retval = 0L;		/* failure to find cookie ret this */
	long    ssp;
	char   *p;
	COOKIE *cookie;



	/*
	 *   access the cookie jar in supervisor mode!
	 */
	ssp    = Super (0L);
	cookie = *CJAR;


	/*
	 *   the value at CJAR will be non-null ptr if there is a jar.
	 */
	if (cookie)
	{
		/*
		 *   traverse the list...
		 */
		while (cookie->tag.aslong != 0)
		{
			/*
			 *   poke the cookie tag into something we can touch
			 */
			p = cookie->tag.aschar;
			sprintf (biscuit, "%c%c%c%c%c%c",
#ifdef __GNUC__
				/* these should be int under ANSI C! */
				(int)(p[0]), (int)(p[1]), (int)(p[2]), (int)(p[3]), (int)('\000'));
#else
				p[0], p[1], p[2], p[3], '\000');
#endif


			/*
			 *   is this the cookie we seek?
			 */
			if (strncmp (cookieid, biscuit, 4) == 0)
			{
				/*
				 *   yes! quit looking...
				 */
				retval = (cookie->value);
				break;
			}

			/*
			 *   next cookie...
			 */
			cookie++;
		}
	}


	/*
	 *   reset to user mode before we bug out!
	 */
	ssp = Super (ssp);


	/*
	 *   return value of the cookie
	 */
	return (retval);
}
