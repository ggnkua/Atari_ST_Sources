#include <stddef.h>
#include <mint/osbind.h>
#include <mint/cookie.h>

int Getcookie(long cookie, long *p_value)
{
	long *cookiejar;

	cookiejar = (long *)Setexc(0x5a0 / 4, (void (*)(void))-1);
	if (p_value != NULL)
		*p_value = 0;
	if (cookiejar == NULL)
		return C_NOTFOUND;

	/* Use do/while here so you can match the zero entry itself */
	do
	{
		if (*cookiejar == cookie)
		{
			/* found it! */
			if (p_value != NULL)
				*p_value = *(cookiejar + 1);

			/* return nonzero for success */
			return C_FOUND;
		}
		cookiejar += 2;
	} while (*cookiejar != 0);

	/* return C_NOTFOUND (failed ) */
	return C_NOTFOUND;
}
