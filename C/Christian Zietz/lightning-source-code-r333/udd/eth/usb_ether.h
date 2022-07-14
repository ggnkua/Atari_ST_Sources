/*
 * Modified for the FreeMiNT USB subsystem by Alan Hourihane 2014.
 *
 * Copyright (c) 2011 The Chromium OS Authors.
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#ifndef __USB_ETHER_H__
#define __USB_ETHER_H__

#define eth_device netif
#include "../../../../sockets/inet4/if.h"

struct ueth_data {
	/* eth info */
	struct eth_device eth_dev;		/* used with eth_register */
	int phy_id;						/* mii phy id */

	/* usb info */
	struct usb_device *pusb_dev;	/* this usb_device */
	unsigned char	ifnum;			/* interface number */
	unsigned char	ep_in;			/* in endpoint */
	unsigned char	ep_out;			/* out ....... */
	unsigned char	ep_int;			/* interrupt . */
	unsigned char	subclass;		/* as in overview */
	unsigned char	protocol;		/* .............. */
	unsigned char	irqinterval;	/* Intervall for IRQ Pipe */

	/* driver private */
	void *dev_priv;
};

#endif /* __USB_ETHER_H__ */
