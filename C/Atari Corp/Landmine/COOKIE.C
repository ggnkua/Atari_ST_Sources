/*
	Cookie search
	Copyright 1992 Atari Corporation
	STE TOS Release Notes 

	int getcookie(cookie, p_value)
	long cookie;
	long *p_value;

	Returns 0 if the 'cookie isn't found in the cookie jar.
	Returns nonzero if the 'cookie' is found, and places its value
	in the longword pointed to by p_value.  If p_value is NULL,
	doesn't put the value anywhere, but still returns the error code.
*/

#include <stdio.h>
#include <osbind.h>

int getcookie(cookie, p_value)
long cookie;
long *p_value;
{
	long oldssp;
	long *cookiejar;

	/* Get super mode if not already */
	if (Super(1L) == 0) oldssp = Super(0L);
	else oldssp = 0;

	cookiejar = *(long **)0x5A0;

	/* No jar found at all */
	if (cookiejar == NULL) {
		if (oldssp != 0) Super (oldssp);
		return 0;
	}

	/* use do/while here so you can match the zero entry itself */
	do {
		if (*cookiejar == cookie) {
			/* Found it */
			if (p_value != NULL) *p_value = *(cookiejar + 1);

			/* Back to use mode if necessary */
			if (oldssp != 0) Super (oldssp);

			/* Return nonzero for success */
			return 1;
		} else cookiejar += 2;
	} while (*cookiejar != 0);

	/* Failed to find it: back to use mode if necessary */
	if (oldssp != 0) Super (oldssp);

	/* Return 0 for failure */
	return 0;
}

