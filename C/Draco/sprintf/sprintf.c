#include <stdio.h>
#include <basepage.h>
#include <errno.h>
#include <stdarg.h>

long
slb_init(void)
{
	return 0L;
}

void
slb_sprintf(BASEPAGE *base, long fn, short nargs, ... )
{
	long args[18];
	va_list *ap;
	short x;

	if (nargs < 2)
		return;

	va_start(ap, nargs);
	for (x = 0; x < nargs; x++)
		args[x] = va_arg(ap, long)
	va_end(ap);
	
	sprintf((char *)args[0], (char *)args[1], \
		args[2], args[3], args[4], args[5], \
		args[6], args[7], args[8], args[9], \
		args[10], args[11], args[12], args[13], \
		args[14], args[15], args[16], args[17]);
}
