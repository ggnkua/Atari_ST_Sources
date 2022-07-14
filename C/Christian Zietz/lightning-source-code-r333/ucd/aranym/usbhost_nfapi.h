/*
 * Aranym USB (virtual) Controller Driver.
 *
 * Copyright (c) 2012-2014 David Galvez.
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */

#ifndef _USBHOST_NFAPI_H
#define _USBHOST_NFAPI_H

/* if you change anything in the enum {} below you have to increase 
   this NFUSBHOST_NFAPI_VERSION!
*/
#define USBHOST_NFAPI_VERSION	0x00000004

enum {
	GET_VERSION = 0,	/* no parameters, return NFAPI_VERSION in d0 */
	USBHOST_INTLEVEL,
	USBHOST_RH_PORT_STATUS,
	USBHOST_LOWLEVEL_INIT,
	USBHOST_LOWLEVEL_STOP,
	USBHOST_SUBMIT_CONTROL_MSG,
	USBHOST_SUBMIT_INT_MSG,
	USBHOST_SUBMIT_BULK_MSG
};

#define USBHOST(a)	(nfUsbHostID + a)

#endif /* _USBHOST_NFAPI_H */
