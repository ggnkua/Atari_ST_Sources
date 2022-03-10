/*
 * $Header: arcdos.c,v 1.8 88/08/01 15:07:15 hyc Exp $
 */

/*
 * ARC - Archive utility - ARCDOS
 * 
 * Version 1.44, created on 07/25/86 at 14:17:38
 * 
 * (C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED
 * 
 * By:  Thom Henderson
 * 
 * Description: This file contains certain DOS level routines that assist in
 * doing fancy things with an archive, primarily reading and setting the date
 * and time last modified.
 * 
 * These are, by nature, system dependant functions.  But they are also, by
 * nature, very expendable.
 * 
 * Language: Computer Innovations Optimizing C86
 */
#include <stdio.h>
#include "arc.h"

#if	MSDOS
#include "fileio2.h"		/* needed for filehand */
#endif

#if	UNIX
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>

#ifndef hpux
struct timeval {	/* man page said <sys/types.h>, but it */
	long tv_sec;	/* really seems to be in <sys/time.h>, */
	long tv_usec;	/* but why bother... */
};
#endif
#endif

#if	GEMDOS
#include <osbind.h>
#endif

#ifndef __STDC__
char	*strcpy(), *strcat(), *malloc();
#endif

void
getstamp(f, date, time)		/* get a file's date/time stamp */
#if	!MTS
	FILE           *f;	/* file to get stamp from */
#else
	char           *f;	/* filename "" "" */
#endif
	unsigned short   *date, *time;	/* storage for the stamp */
{
#if	MSDOS
	struct {
		int             ax, bx, cx, dx, si, di, ds, es;
	}               reg;

	reg.ax = 0x5700;	/* get date/time */
	reg.bx = filehand(f);	/* file handle */
	if (sysint21(&reg, &reg) & 1)	/* DOS call */
		printf("Get timestamp fail (%d)\n", reg.ax);

	*date = reg.dx;		/* save date/time */
	*time = reg.cx;
#endif
#if	GEMDOS
	int	fd, ret[2];

	fd = fileno(f);
	Fdatime(ret, fd, 0);
	*date = ret[1];
	*time = ret[0];
#endif
#if	UNIX
	struct stat	buf;
	struct tm	*localtime(), *t;

	fstat(fileno(f), &buf);
	t=localtime(&(buf.st_mtime));
	*date = (unsigned short) (((t->tm_year - 80) << 9) +
				((t->tm_mon + 1) << 5) + t->tm_mday);
	*time = (unsigned short) ((t->tm_hour << 11) +
				(t->tm_min << 5) + t->tm_sec / 2);
#endif
#if	MTS
	fortran         timein(),
#if	USEGFINFO
	                gfinfo();
#else
	                fileinfo();
#endif
	int             stclk[2];
	char            name[24];
	struct bigtime {
		int             greg;
		int             year;
		int             mon;
		int             day;
		int             hour;
		int             min;
		int             sec;
		int             usec;
		int             week;
		int             toff;
		int             tzn1;
		int             tzn2;
	}               tvec;
#if	USEGFINFO
	static int      gfflag = 0x0009, gfdummy[2] = {
						       0, 0
	};
	int             gfcinfo[18];
#else
	static int      cattype = 2;
#endif

	strcpy(name, f);
	strcat(name, " ");
#if	USEGFINFO
	gfcinfo[0] = 18;
	gfinfo(name, name, &gfflag, gfcinfo, gfdummy, gfdummy);
	timein("*IBM MICROSECONDS*", &gfcinfo[16], &tvec);
#else
	fileinfo(name, &cattype, "CILCCT  ", stclk);
	timein("*IBM MICROSECONDS*", stclk, &tvec);
#endif

	*date = (unsigned short) (((tvec.year - 1980) << 9) + ((tvec.mon) << 5) + tvec.day);
	*time = (unsigned short) ((tvec.hour << 11) + (tvec.min << 5) + tvec.sec / 2);
#endif
}

void
setstamp(f, date, time)		/* set a file's date/time stamp */
	char           *f;	/* filename to stamp */
	unsigned short    date, time;	/* desired date, time */
{
#if	MSDOS
	FILE	*ff;
	struct {
		int             ax, bx, cx, dx, si, di, ds, es;
	}               reg;

	ff = fopen(f, "w+");	/* How else can I get a handle? */

	reg.ax = 0x5701;	/* set date/time */
	reg.bx = filehand(f);	/* file handle */
	reg.cx = time;		/* desired time */
	reg.dx = date;		/* desired date */
	if (sysint21(&reg, &reg) & 1)	/* DOS call */
		printf("Set timestamp fail (%d)\n", reg.ax);
	fclose(ff);
#endif
#if	GEMDOS
	int	fd, set[2];

	fd = Fopen(f, 0);
	set[0] = time;
	set[1] = date;
	Fdatime(set, fd, 1);
	Fclose(fd);
#endif
#if	UNIX
	struct tm	tm;
	struct timeval  tvp[2];
	int	utimes();
#ifdef MINIX
	long	mktime();
#else
	long	tmclock();
#endif

	tm.tm_sec = (time & 31) * 2;
	tm.tm_min = (time >> 5) & 63;
	tm.tm_hour = (time >> 11);
	tm.tm_mday = date & 31;
	tm.tm_mon = ((date >> 5) & 15) - 1;
	tm.tm_year = (date >> 9) + 80;
#ifdef MINIX
	tvp[0].tv_sec = mktime(&tm);
#else
	tvp[0].tv_sec = tmclock(&tm);
#endif
	tvp[1].tv_sec = tvp[0].tv_sec;
	tvp[0].tv_usec = tvp[1].tv_usec = 0L;
	utimes(f, tvp); 

#endif
}

#if	MSDOS
int
filehand(stream)		/* find handle on a file */
	struct bufstr  *stream;	/* file to grab onto */
{
	return stream->bufhand;	/* return DOS 2.0 file handle */
}
#endif

#if	UNIX
int
izadir(filename)		/* Is filename a directory? */
	char           *filename;
{
	struct stat     buf;

	if (stat(filename, &buf) != 0)
		return (0);	/* Ignore if stat fails since */
	else
		return (buf.st_mode & S_IFDIR);	/* bad files trapped later */
}
#endif
