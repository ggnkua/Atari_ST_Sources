/* This file is part of the AHCC C Library.

   The AHCC C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
*/

#define __MINT__

#include <prelude.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <tos.h>
#include <errno.h>
#include <basepage.h>
#include <ext.h>

/* change the directory and (possibly) the drive. */

short chdir(const char *dir)
{
	int r;
	int drive = -1;

	if (dir[1] eq ':')
	{
		drive = Dgetdrv();
		Dsetdrv(toupper(dir[0]) - 'A');
		dir += 2;
	}

	if (*dir)
	{
		r = Dsetpath(dir);
		if (r)
			r = -1, errno = ENOENT;
	}

	if (drive ne -1)
		Dsetdrv(drive);

	return r;
}

size_t coreleft(void)
{
	size_t m = (size_t)Malloc(-1L) - 8;
	if (m < 0) m = 0;
	return m;
}

short findfirst(const char *fn, struct ffblk *fb, short attrib)
{
	short i;
	DTA *dta = Fgetdta();
	Fsetdta((DTA *)fb);
	i = Fsfirst(fn, attrib & 0xff);
	Fsetdta(dta);
	if (i)
		i = -1, errno = ENOENT;
	return i;
}

short findnext(struct ffblk *fb)
{
	short i;
	DTA *dta = Fgetdta();
	Fsetdta((DTA *)fb);
	i = Fsnext();
	Fsetdta(dta);
	if (i)
		i = -1, errno = ENMFILE;
	return i;
}

short getch(void)
{
	long c;
	static union
	{
		long scancode;
		struct
		{
			short sc, co;
		} sc_co;
	} last = {0};

	if (last.sc_co.sc eq 0)
	{
		c = Cnecin();
		if ((short)c)
			last.scancode = c;
		return c;
	}
	else
		return last.sc_co.sc = 0;
}

short getche(void)
{
	return Cconin();
}

short getcurdir(short drive, char *path)
{
	short r = Dgetpath(path, drive);
	return r < 0 ? -1 : r;
}

char * getcwd(char *buf, short size)
{
	char path[256];
	if (size <= 0 or size > 256) size = 256;
	if (buf eq nil)
		buf = malloc(size);
	size--;
	if (buf)
	{
		path[1] = ':';
		path[0] = Dgetdrv() + 'A';
		Dgetpath(&path[2], 0);
		if (path[2] eq 0)
			path[2] = '\\', path[3] = 0;
		strncpy(buf, path, size);
		buf[size] = 0;
	}
	return buf;
}

void getdfree(short drive, struct dfree *df)
{
	static DISKINFO di;
	if (Dfree(&di, drive) >= 0)
	{
		df->df_avail = di.b_free;
		df->df_total = di.b_total;
		df->df_bsec  = di.b_secsiz;
		df->df_sclus = di.b_clsiz;
	}
	else
		(int)df->df_sclus = -1;
}

long filelength(short handle)
{
	long offset, r = Fseek(0, handle, SEEK_CUR);
	if (r >= 0)
	{
		offset = Fseek(0, handle, SEEK_END);
		if (offset >= 0)
		{
			r = Fseek(r, handle, SEEK_SET);
			if (r >= 0)
				return offset;
		}
	}

	return errno = EBADF, -1;
}

short getdisk(void)
{
	return Dgetdrv();
}

short setdisk(short drive)
{
	ulong drm = Dsetdrv(drive);
	short count = 0;
	while (drm)
		count += drm&1, drm >>=1;
	return count;
}

/* Beware! bits are numbered 15-0, Not 0-15 !!!! */
typedef union
{
	ushort d;
	struct
	{
		ubits year : 7;
		ubits month: 4;
		ubits day  : 5;
	} dd;
} Tdate;

void getdate(struct date *dr)
{
	Tdate ud;
	ud.d = Tgetdate();

	dr->da_year = ud.dd.year + 1980;
	dr->da_mon  = ud.dd.month;
	dr->da_day  = ud.dd.day;
}

void setdate(struct date *dr)
{
	Tdate ud;
	ud.dd.year  = dr->da_year >= 1980 ? dr->da_year - 1980 : 0;
	ud.dd.month = dr->da_mon  ne 0 and dr->da_mon <= 12 ? dr->da_mon : 1;
	ud.dd.day   = dr->da_day;

	Tsetdate(ud.d);
}

typedef union
{
	ushort t;
	struct
	{
		ubits hour    : 5;
		ubits minutes : 6;
		ubits seconds : 5;
	} tt;
} Ttime;

void gettime(struct time *tr)
{
	Ttime ut;
	ut.t = Tgettime();

	tr->hour = ut.tt.hour;
	tr->min  = ut.tt.minutes;
	tr->sec  = ut.tt.seconds*2;
	tr->hund = 0;
}

void settime(struct time *tr)
{
	Ttime ut;
	ut.tt.hour    = tr->hour <= 23 ? tr->hour  : 0;
	ut.tt.minutes = tr->min  <= 59 ? tr->min   : 0;
	ut.tt.seconds = tr->sec  <= 29 ? tr->sec/2 : 0;
	Tsettime(ut.t);
}

short kbhit(void)
{
	return Cconis();
}

short putch(short c)
{
	Cconout(c);
	return c;
}

static
short Ftime(short handle, struct ftime *ft, short wr)
{
	if (Fdatime((DOSTIME *)ft, handle, wr) > 0) return 0;
	else return errno = EBADF, -1;
}
short setftime(short handle, struct ftime *ft)
{
	return Ftime(handle, ft, 1);
}

short getftime(short handle, struct ftime *ft)
{
	return Ftime(handle, ft, 0);
}

#if 1
static
long __wait;

static
Supfunc __delay
{
	long l = __wait/5 + *(long *)1210L;
	while (*(long *)1210L < l);
	return 0;
}

void delay(unsigned long milliseconds)
{
	__wait = milliseconds;
	Supexec(__delay);
}
#endif

/*
 *	Suspend operation for <dt> seconds.  This is implemented as a
 *	start_timer()/time_since() tight loop waiting for the specified
 *	amount of time to pass.  In a multi-tasking environment, this
 *	function should be replaced by a call which will de-activate
 *	this task for a period of time, allowing other tasks to run.
 */
void sleep(unsigned short dt)
{
	clock_t t, tt;

	tt = ((clock_t) dt) * CLK_TCK;
	start_timer(&t);
	while(time_since(&t) < tt)
		;
}

/*
 *	Suspend operation for <dt> microseconds.  Works like sleep().
 */
void usleep(unsigned short dt)
{
	clock_t t, tt;

	tt = ((clock_t) dt) * (CLK_TCK / ((clock_t) 100));
	start_timer(&t);
	while(time_since(&t) < tt)
		;
}

short isatty(short handle)
{
	long r, l;
	l = Fseek(0, handle, SEEK_CUR);
	r = Fseek(1, handle, SEEK_SET);
	    Fseek(l, handle, SEEK_SET);
	return r eq 0;
}

#define Bclr(a,b) (a&=~(1<<b))
#define Bset(a,b) (a|=(1<<b))
#define Btst(a,b) (a&(1<<b))

static DTA _dta;			/* local DTA buffer */

short stat(const char *path, struct stat *s)
{
	short r, m, fh;
	DTA *save = Fgetdta();
	Fsetdta(&_dta);		/* to be filled by Fsfirst */
	r = Fsfirst(path, FA_DIREC|FA_ARCHIVE|FA_RDONLY);
	if (r eq 0)
	{
		if (path[1] eq ':')
			s->st_dev = tolower(path[0]) - 'a';
		else
			s->st_dev = Dgetdrv();

		s->st_rdev = s->st_dev;
		s->st_ino = 0;

		m = 0x100;
		if (Btst(_dta.d_attrib,4))
			m = 0x41c0;			/* --> 748 */
		else
		{
			Bset(m,15);
			if (Btst(_dta.d_attrib,0) eq 0)
				Bset(m,7);
			fh = Fopen(path, 0);
			if (fh >= 0)		/* --> 748 */
			{
				long r = Fread(fh, 2, &_dta);
				if (r eq 2 and *(short *)&_dta eq 0x601a)
					Bset(m,6);
				Fclose(fh);
			}
		}

		s->st_mode = m;
		s->st_nlink = 1;
		s->st_uid = 0;
		s->st_size = _dta.d_length;
		s->st_atime = ftimtosec((FTIME *)&_dta.d_time);
		s->st_mtime = s->st_atime;
		s->st_ctime = s->st_atime;

		Fsetdta(save);

		return 0;
	}

	return errno = ENOENT, -1;
}

short access(const char *name, short amode)
{
	DTA *_pdta;					/* pointer to old DTA */

	_pdta = Fgetdta();

	Fsetdta(&_dta);

	amode = (amode & 0x02) ne 0 ? 0x16 : 0x17;
	errno = Fsfirst(name, amode);

	Fsetdta(_pdta);

	return errno == 0;
}

long fsize(const char *name)
{
	if (access(name, 0x00))
		return _dta.d_length;

	return ERROR;
}

short fstat(short handle, struct stat *s )
{
	DOSTIME time;
	short m = 0;
	long l, cur;
	s->st_nlink = 1;
	if (isatty(handle))
	{
		s->st_size  = 0;
		s->st_atime = 0;
		s->st_mtime = 0;
		s->st_ctime = 0;
		s->st_mode  = 0;
		Bset(s->st_mode, 13);
		return 0;
	}

	Bset(m, 15);
	Bset(m, 8);
	Bset(m, 7);

	cur = Fseek(0, handle, SEEK_CUR);
	if (cur < 0)
		errno = EBADF;
	else
	{
		short b = 0;
		s->st_size = Fseek(0, handle, SEEK_END);
		Fseek(0, handle, SEEK_SET);
		l = Fread(handle, 2, (char *)&b);
		if (l < 0)
			errno = EBADF;
		else
		{
			if (b eq 0x601a)
				Bset(m,6);
			Fseek(0, handle, SEEK_SET);
			l = Fwrite(handle, 1, (char *)&b);
			if (l eq -36)
				Bclr(m,7);
			Fseek(cur, handle, SEEK_SET);
			Fdatime(&time, handle, 0);
			s->st_atime = ftimtosec((FTIME *)&time);
			s->st_mtime = s->st_atime;
			s->st_ctime = s->st_atime;
			s->st_mode  = m;
			return 0;
		}
	}

	return -1;
}

short chmod(const char *filename, short pmode)
{
	short rv;

	if ((rv = Fattrib(filename, 1, (pmode & 0x0F))) < 0)
		return errno = rv;
	return 0;
}

short getpid (void)
{
	short have_getpid = 1;

	if (have_getpid)
	{
		long r = Pgetpid ();
		if (r == -32)
			have_getpid = 0;
		else
			return r;
	}
	return ((long) _base) >> 8 ;
}
