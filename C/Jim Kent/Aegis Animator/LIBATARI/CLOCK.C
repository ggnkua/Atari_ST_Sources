
overlay "timer"

#include <osbind.h>

#define WORD int

static long
time_peek()
{
return(*((long *)0x4ba));
}


extern WORD *s1, *s2, *cscreen;

static long
beam_peeka()
{
return( *((unsigned char *)0xff8205));
}

static long
beam_peekb()
{
return( *((unsigned char *)0xff8207));
}

static long
beam_peekc()
{
return( *((unsigned char *)0xff8209));
}

static long last_time;

wait_beam()
{
long beam;

for (;;)
	{
	beam = (Supexec(beam_peeka)<<16) + (Supexec(beam_peekb)<<8) +
		Supexec(beam_peekc);
	/* if beam still in cscreen */
	if ( beam >= (long)cscreen && beam <= (long)cscreen + 32000)
		{
		if ( beam - (long)cscreen > 6000)
			break;
		}
	else
		break;
	}

}

long
real_time(beam)
long *beam;
{
static long time = 0;
register long new_time;

new_time = Supexec(time_peek);
time += new_time - last_time;
last_time = new_time;
return(time);
}

stop_time()
{
}

start_time()
{
last_time = Supexec(time_peek);
}

wait(time)
int time;
{
int i;

i = 55;
while (--time >= 0)
	i = i*i;
}

waits()
{
wait(1);
}

