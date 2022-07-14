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
#include "hub.h"
#include "usb_api.h"

struct ucdif *allucdifs = NULL;
extern struct usb_module_api usb_api;

long ucd_register(struct ucdif *a, struct usb_device **dev);
long ucd_unregister(struct ucdif *a);

/*
 * Called by ucd upon init to register itself
 */
long
ucd_register(struct ucdif *a, struct usb_device **dev)
{
	struct ucdif *list = allucdifs;
	struct usb_device *hub;
	long result;

	if (a->api_version != usb_api.api_version) {
		c_conws("API Mismatch\r\n");
		return -1;
	}

	while (list)
	{
		if (!strncmp(a->name, list->name, UCD_NAMSIZ))
		{
			/* FIXME - more than one controller ??? */
			c_conws("Driver already installed\r\n");
			return -1;
		}
		list = list->next;
	}

	DEBUG(("ucd_register: Registered device %s (%s)", a->name, a->lname));

	result = (*a->open)(a);
	if (result)
	{
		DEBUG(("ucd_open: Cannot open USB host driver %s%d", a->name, a->unit));
		return -1;
	}

		result = (*a->ioctl)(a, LOWLEVEL_INIT, 0);
		if (result)
		{
			DEBUG (("%s: ucd low level init failed!", __FILE__));
			return -1;
	}

	hub = usb_alloc_new_device(a);
	if (!hub) 
	{
		return -1;
	}

	/* Give the host controller driver it's USB device struct */
	*dev = hub;
	
	if (usb_new_device(hub)) 
	{
		/* Something went wrong, clear device */
		usb_free_device(hub->devnum);
		return -1;
	}

	a->next = allucdifs;
	allucdifs = a;

	usb_hub_init(hub);
	
	return 0;
}

/*
 * Called by ucd upon unloading to unregister itself
 */

long
ucd_unregister(struct ucdif *a)
{
	struct ucdif **list = &allucdifs;

	(*a->ioctl)(a, LOWLEVEL_STOP, 0);
	(*a->close)(a);

	while (*list)
	{
		if (a == *list)
		{
			*list = a->next;
			return E_OK;
		}
		list = &((*list)->next);
	}
	return -1L;
}
