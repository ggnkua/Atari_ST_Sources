/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include "xa_types.h"

/* This module is taken from Stephen Sowerby's AGiLE Library */
/* HR: now use the Mintleb Getcookie (for Ssystem) */

/*
 *	GetCookie : Get a cookie with a given code
 *		code = code to look for
 *		value = address of where to store cookie value if found
 *		Return = Success of finding the required cookie
 */
short GetCookie(long code, long *value)
{
	long *cookie;
	void *ssp;

	ssp = (void*)Super(0L);
	cookie = *((long **)0x5a0);
	Super(ssp);
	while (*cookie)	/* Keep going until we get the terminator cookie */
	{
		if (*cookie == code)	/* We've found the cookie, get value and return success */
		{
			*value = cookie[1];		
			return TRUE;
		}
		cookie += 2;
	}
	return FALSE;
}
