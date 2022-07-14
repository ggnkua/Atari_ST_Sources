/*
 * Modified for the FreeMiNT USB subsystem by David Galvez. 2010 - 2011
 * 
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *                                        2004 F.Naumann & O.Skancke
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <mint/cookie.h>
#include <mint/mintbind.h>
#include <mint/ssystem.h>
#include <signal.h>
#include <sys/fcntl.h>
#include <string.h>

/* KM_RUN */
#include "../../../mint/ioctl.h"

#define DEFAULT        "usb.km"

static void
my_strlcpy(char *dst, const char *src, size_t n)
{
	size_t org_n = n;

	if (n && --n)
	{
		do
		{
			if (!(*dst++ = *src++))
				break;
		}
		while (--n);

	}
	if (org_n && n == 0)
		*dst = '\0';
}

static void
my_strlcat(char *dst, const char *src, size_t n)
{
	if (!n)
		return;

	/* find end */
	while (n-- && *dst)
		dst++;

	/* copy over */
	if (n && --n)
	{
		do {
			if (!(*dst++ = *src++))
				break;
		}
		while (--n);

	}
	/* terminate */
	if (n == 0)
		*dst = '\0';
}

/*
 * - without an argument try to load usb.km from sysdir
 * - with argument:
 *   - without a path separator try to load this from sysdir
 *   - with path separator go to this dir and load the module
 *     from there
 */

int init(int argc, char **argv, char **env);

static void ignore(long sig)
{
	char sign[4];
	if( sig > 29 )
	{
		sign[0] = '3';
		sig -= 30;
	}
	else if( sig > 19 )
	{
		sign[0] = '2';
		sig -= 20;
	}
	else if( sig > 9 )
	{
		sign[0] = '1';
		sig -= 10;
	}
	else
		sign[0] = ' ';
	sign[1] = sig + '0';
	sign[2] = 0;
	(void) Cconws( "usb loader: SIGNAL ");
	(void) Cconws( sign );
	(void) Cconws( " ignored\r\n");
}

int
init(int argc, char **argv, char **env)
{
	char path[384];
	char *name = NULL;
	long fh, r = 1;
#ifndef __mcoldfire__
	long cpu;
#endif

	/*
	 *  Go into MiNT domain
	 */
	(void)Pdomain(1);

	(void)Cconws("usb loader starting...\r\n");

	/*
	 * first make sure we are on FreeMiNT's '/'
	 */
	Dsetdrv('u' - 'a');
	Dsetpath("/");

	/*
	 * now lookup FreeMiNT's sysdir
	 */
	fh = Fopen("/kern/sysdir", O_RDONLY);
	if (fh < 0)
	{
		(void)Cconws("usb loader: Fopen(\"/kern/sysdir\") failed!\r\n");
		goto error;
	}
	r = Fread((int)fh, sizeof(path), path);
	if (r <= 0)
	{
		(void)Cconws("usb loader: Fread(\"/kern/sysdir\") failed!\r\n");
		goto error;
	}
	if (r >= sizeof(path))
	{
		(void)Cconws("usb loader: buffer for Fread(\"/kern/sysdir\") too small!\r\n");
		goto error;
	}
	Fclose((int)fh);

	/* null terminate */
	path[r] = '\0';

	/* append usb subdir */
	my_strlcat(path, "usb\\", sizeof(path));

	if (argc > 1)
	{
		char *s = argv[1];
		char c;

		do
		{
			c = *s++;
			if (c == '\\' || c == '/')
				name = s - 1;
		}
		while (c);

		if (name)
		{
			*name++ = '\0';

			my_strlcpy(path, argv[1], sizeof(path));
			my_strlcat(path, "/", sizeof(path));
		}
		else
			name = argv[1];
	}

	/* change to the usb module directory */
	r = Dsetpath(path);
	if (r)
	{
		(void)Cconws("usb loader: No such directory: \"");
		(void)Cconws(path);
		(void)Cconws("\"\r\n");
		goto error;
	}

	/* get absolute path to this directory */
	r = Dgetpath(path, 0);
	if (r)
	{
		(void)Cconws("usb loader: Dgetpath() failed???\r\n");
		goto error;
	}

	if (name == NULL)
	{
		/* Try the legacy names first.
		 */
#ifdef __mcoldfire__
		name = "usbv4e.km";
#else
		r = Ssystem(S_GETCOOKIE, C__CPU, &cpu);
		if (r == 0)
		{
			switch(cpu)
			{
			case 30:
				name = "usb030.km";
			break;
			case 40:
				name = "usb040.km";
			break;
			case 60:
				name = "usb060.km";
			break;
			default:
				name = "usb000.km";
			}
		}
		else
		{
			(void)Cconws("CPU-cookie not found \r\n");
			name = "usb000.km";
		}
#endif
	}

	/* check if file exists */
	fh = Fopen(name, O_RDONLY);
#ifndef __mcoldfire__
	if (fh < 0 && (cpu == 30 || cpu == 40 || cpu == 60))
	{
		name = "usb02060.km";
		fh = Fopen(name, O_RDONLY);
	}
#endif
	if (fh < 0)
	{
		name = DEFAULT;
		fh = Fopen(name, O_RDONLY);
		if (fh < 0)
		{
			(void)Cconws("usb loader: No such file: \""DEFAULT"\"\r\n");
			goto error;
		}
	}
	Fclose((int)fh);

	/* append module name */
	my_strlcat(path, "\\", sizeof(path));
	my_strlcat(path, name, sizeof(path));

	(void)Cconws("Load kernel module: ");
	(void)Cconws(path);
	(void)Cconws("\r\n");

	fh = Fopen("/dev/km", O_RDONLY);
	if (fh < 0)
	{
		(void)Cconws("usb loader: no /dev/km, please update your kernel!\r\n");
		goto error;
	}
	/* if mint waits for usbloader it should not exit */
	Psignal( SIGINT, ignore );
	Psignal( SIGQUIT, ignore );
	Psignal( SIGSTOP, ignore );
	Psignal( SIGTSTP, ignore );
	Psignal( SIGTERM, ignore );
	//Psignal( SIGKILL, ignore );

	//Cconws( "usb loader: KM_RUN \r\n");
	//Cconin();
	r = Fcntl((int)fh, path, KM_RUN);
	//Cconws( "usb loader: KM_RUN done()\r\n");

	if (r)
	{
		(void)Cconws("usb loader: Fcntl(KM_RUN) failed!\r\n");
		goto error;
	}
#if 0
	(void) Cconws( "usb loader: KM_FREE\r\n");
	//Cconin();

	r = Fcntl((int)fh, path, KM_FREE);
	if( r )
	{
		char *p;
		for( p = path; *p; p++ );
		for( --p; p > path && !(*p == '/' || *p == '\\'); p-- );
		if( p > path )
		{
			p++;
			(void) Cconws( "usb loader: KM_FREE failed trying: '");
			(void) Cconws( p );
			(void) Cconws( "'..\r\n");
			r = Fcntl((int)fh, p, KM_FREE);
		}
		if( r )
		{
			char e[2];
			if( r < 0 )
				r = -r;
			e[0] = r + '0';
			e[1] = 0;
			(void) Cconws( "\r\nusb loader: KM_FREE failed: ");
			(void) Cconws( e );
			(void) Cconws( "\r\n");
			//Cconin();
		}
	}
#endif
	Fclose((int)fh);
	//Cconin();
	return r;

error:
	(void) Cconws("press any key to continue ...\r\n");
	(void) Cconin();
	return 1;
}
