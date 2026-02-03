#include <ctype.h>

#undef	toupper /* note that in gcc we have a safe version of these, */
#undef  tolower	/* but its better to leave these as routines in case */
		/* some code uses these as function pointers --  i   */
		/* have seen code that does.			     */

int toupper(c)
	int c;
	{
	return(islower(c) ? (c ^ 0x20) : (c));
	}

int tolower(c)
	int c;
	{
	return(isupper(c) ? (c ^ 0x20) : (c));
	}
