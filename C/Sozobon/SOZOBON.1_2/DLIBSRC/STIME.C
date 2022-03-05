#include <time.h>
#include <errno.h>

extern	long	gemdos(), xbios();

time_t mktime(time)
	register struct tm *time;
	{
	register time_t t = 0L;

	t |= (time->tm_hour) & 0x1F;
	t <<= 6;
	t |= (time->tm_min) & 0x3F;
	t <<= 5;
	t |= (time->tm_sec >> 1) & 0x1F;
	t <<= 7;
	t |= (time->tm_year - 80) & 0x7F;
	t <<= 4;
	t |= (time->tm_mon + 1) & 0x0F;
	t <<= 5;
	t |= (time->tm_mday) & 0x1F;
	return(t);
	}

void stime(rawtime)
	time_t *rawtime;
	{
	time_t t = *rawtime;
	register int *tp = (int *) &t, tt;

	gemdos(0x2D, (tt = tp[0]));	/* set time from high word */
	gemdos(0x2B, (tp[0] = tp[1]));	/* set date from low word */
	tp[1] = tt;			/* finish swapping words */
	xbios(22, rawtime);		/* set keyboard clock also */
	}

int utime(pathname, rawtime)
	char *pathname;
	register time_t *rawtime;
	{
	register int h;
	time_t raw;

	if(!rawtime)
		{
		rawtime = &raw;					/* current */
		time(rawtime);					/*  time   */
		}
	if((h = ((int) gemdos(0x3D, pathname, 2))) < 0)		/* open */
		return(errno = h);				/* FAILURE */
	gemdos(0x57, rawtime, h, 1);				/* timestamp */
	h = ((int) gemdos(0x3E, h));				/* close */
	return(errno = h);
	}
