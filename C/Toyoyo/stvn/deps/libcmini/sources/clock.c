#include <time.h>
#include <mint/osbind.h>

#define _hz_200                ((volatile unsigned long *) 0x4baL)


static long get_clock(void)
{
	return *_hz_200;
}


clock_t clock(void)
{
	return Supexec(get_clock);
}

