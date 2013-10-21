/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* config data local to bootup & config. */

typedef struct lconfig
{
	Path widg_name,
	     rsc_name;
	unsigned
		  long mint,
		  falcon;		  /* cookies & cookie values */
	int   modecode,
	      double_click_time,		/* Double click timing */
		  direct_call;        /* Flag for enabling of direct call */
	bool  havemode,
	      oldcnf,
	      booting;
} LCFG;

extern
LCFG lcfg;

extern
Path Aes_home_path;

extern
OPT local_options;

extern long loghandle;
extern int err;

void SCL(LOCK lock, int co, char *name, char *full, char *txt);
char *xa_find(char *fn);