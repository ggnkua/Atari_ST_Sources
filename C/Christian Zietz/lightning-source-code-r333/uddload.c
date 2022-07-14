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

#ifndef TOSONLY
#include "global.h"
#include "uddload.h"
#include "usb.h"
#include "usb_api.h"

#include "mint/basepage.h"

extern Path start_path;
static char no_reason[] = "Nothing";

static long
udd_init(long initfunc(struct kentry *, struct usb_module_api *a, long arg, long reason), struct kentry *k, struct usb_module_api *a, long arg, long reason)
{
	return (*initfunc)(k,a,arg,reason);
}

extern struct usb_module_api usb_api;

static long
load_udd(struct basepage *b, const char *name, short *class, short *subclass)
{
	void *initfunc = (void *)b->p_tbase;
	long r;
	char *reason = no_reason;

	DEBUG(("load_udd: enter (0x%lx, %s)", (unsigned long)b, name));
	DEBUG(("load_udd: init 0x%lx, size %li", (unsigned long)initfunc, (b->p_tlen + b->p_dlen + b->p_blen)));
	DEBUG(("load_udd: '%s' - text=%lx, data=%lx, bss=%lx", name, b->p_tbase, b->p_dbase, b->p_bbase));

	/* pass a pointer to the drivers file name on to the
	 * driver.
	 */
	*class = MODCLASS_KMDEF;
	*subclass = 2;

	r = udd_init(initfunc, KENTRY, &usb_api, 0, (long)&reason);
	if (r == -1L)
		DEBUG(("load_udd: module '%s' says '%s'", name, reason));
	return r;
}

void
udd_load(bool first)
{

	if (first)
		c_conws("Loading USB device modules:\r\n");
	load_modules(start_path, ".udd", load_udd);
	DEBUG(("udd_load: done"));
}
#endif
