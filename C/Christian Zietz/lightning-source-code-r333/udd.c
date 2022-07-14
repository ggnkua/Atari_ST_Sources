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

#include "global.h"
#include "usb.h"
#include "usb_api.h"


struct uddif *alluddifs = NULL;

extern struct usb_device usb_dev[USB_MAX_DEVICE];
extern struct usb_module_api usb_api;

long udd_register(struct uddif *a);
long udd_unregister(struct uddif *a);

/*
 * Called by udd upon init to register itself
 */
long
udd_register(struct uddif *a)
{
	struct uddif *list = alluddifs;
	long i;

	if (a->api_version != usb_api.api_version) {
		c_conws("API Mismatch\r\n");
		return -1;
	}

	while (list)
	{
		if (!strncmp(a->name, list->name, UDD_NAMSIZ))
		{
			c_conws("Driver already installed\r\n");
			return -1;
		}
		list = list->next;
	}

	DEBUG(("udd_register: Registered device %s (%s)", a->name, a->lname));

	a->next = alluddifs;
	alluddifs = a;

	for (i = 0; i < USB_MAX_DEVICE; i++) {
		usb_find_interface_driver(&usb_dev[i], 0);
	}

	return 0;
}

/*
 * Called by udd upon unloading to unregister itself
 */

long
udd_unregister(struct uddif *a)
{
	struct uddif **list = &alluddifs;

	while (*list)
	{
		if (a == *list)
		{
			*list = a->next;
			break;
		}
		list = &((*list)->next);
	}

	return -1L;
}
