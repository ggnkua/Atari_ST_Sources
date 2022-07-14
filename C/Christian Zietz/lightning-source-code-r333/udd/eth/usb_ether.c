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

#if 0
# define DEV_DEBUG	1
#endif

#include "usbnet.h"
#ifndef TOSONLY
#include "mint/mint.h"
#else
#include "gem.h"
#endif
#include "../../global.h"
#include "../../usb.h"
#include "../../usb_api.h"


typedef struct
{
	unsigned long  name;
	unsigned long  val;
} COOKIE;

#define COOKIEBASE (*(COOKIE **)0x5a0)

#define MSG_VERSION     "0.1"
#define MSG_BUILDDATE   __DATE__

#define MSG_BOOT	\
		"\033p USB ethernet class driver " MSG_VERSION " \033q\r\n"

#define MSG_GREET	   \
		"Ported, mixed and shaken by Alan Hourihane.\r\n" \
		"Compiled " MSG_BUILDDATE ".\r\n\r\n"

#define MSG_FAILURE	 \
		"\7\r\nSorry, failed!\r\n\r\n"

char *drv_version = MSG_VERSION;


/*
 * USB device interface
 */

static long ethernet_probe		(struct usb_device *dev, unsigned int ifnum);
static long ethernet_disconnect		(struct usb_device *dev);
static long ethernet_ioctl		(struct uddif *, short, long);

static char lname[] = "USB ethernet class driver\0";

static struct uddif eth_uif = 
{
	0,			/* *next */
	USB_API_VERSION,	/* API */
	USB_DEVICE,		/* class */
	lname,			/* lname */
	"eth",			/* name */
	0,			/* unit */
	0,			/* flags */
	ethernet_probe,		/* probe */
	ethernet_disconnect,	/* disconnect */
	0,			/* resrvd1 */
	ethernet_ioctl,		/* ioctl */
	0,			/* resrvd2 */
};

/****************************************************************************/
/* BEGIN kernel interface */

struct kentry   *kentry;
struct usb_module_api   *api;
struct usb_netapi *usbNetAPI = NULL;

/* END kernel interface */
/****************************************************************************/

#include "usb_ether.h"

static struct ueth_data *usb_eth;

#ifdef TOSONLY
/*
 * For USB ethernet devices.
 */
#define MAX_USB_ETHERNET_DEVICES 4

static long usb_eth_register(struct usb_eth_prob_dev *ethdev)
{
	long i;

	for (i = 0; i < usbNetAPI->numDevices; i++) {
		if (!usbNetAPI->usbnet[i].before_probe) {
			usbNetAPI->usbnet[i] = *ethdev;

			return 0;
		}
	}

	return -1;
}

static void usb_eth_deregister(long i)
{
	memset(&usbNetAPI->usbnet[i], 0, sizeof(struct usb_eth_prob_dev));
}
#endif

/*
 * Given a USB device, ask each driver if it can support it, and attach it
 * to the first driver that says 'yes'
 */
static long probe_valid_drivers(struct usb_device *dev, unsigned int ifnum)
{
	long j, devid;
	long numDevices = usbNetAPI->numDevices;

	for (j = 0; j < numDevices; j++) {
		if (usb_eth[j].pusb_dev == NULL)
			break;
	}

	devid = j;

	for (j = 0; j < numDevices; j++) {
		if (!usbNetAPI->usbnet[j].before_probe ||
			!usbNetAPI->usbnet[j].probe ||
			!usbNetAPI->usbnet[j].get_info)
			continue;

		usbNetAPI->usbnet[j].before_probe(api);

		if (!usbNetAPI->usbnet[j].probe(dev, ifnum, &usb_eth[devid]))
			continue;
		/*
		 * ok, it is a supported eth device. Get info and fill it in
		 */
		if (usbNetAPI->usbnet[j].get_info(dev, &usb_eth[devid], &usb_eth[devid].eth_dev)) {
			return 0;
		}
	}
	return -1;
}

static long _cdecl
ethernet_ioctl (struct uddif *u, short cmd, long arg)
{
	return E_OK;
}

static long
ethernet_probe(struct usb_device *dev, unsigned int ifnum)
{
	int old_async;
	long r;

	if (dev == NULL)
		return -1;

	old_async = usb_disable_asynch(1); /* asynch transfer not allowed */

	/* find valid usb_ether driver for this device, if any */
	r = probe_valid_drivers(dev, ifnum);

	usb_disable_asynch(old_async); /* restore asynch value */

	DEBUG(("Ethernet Device(s) found"));

	return r;
}

static long
ethernet_disconnect(struct usb_device *dev)
{
	long i;

	ALERT(("USB Ethernet Device disconnected: (%ld) %s", dev->devnum, dev->prod));

	for (i = 0; i < usbNetAPI->numDevices; i++)
	{
		if (usb_eth[i].pusb_dev == dev) {
			usb_eth[i].pusb_dev = NULL;
			break;
		};
	}
	return 0;
}

#ifdef TOSONLY
int init (void);
int
init (void)
#else
long _cdecl init (struct kentry *, struct usb_module_api *, long, long);
long _cdecl
init (struct kentry *k, struct usb_module_api *uapi, long arg, long reason)
#endif
{
#ifndef TOSONLY
	COOKIE *cookie = COOKIEBASE;
#endif
	long ret;

#ifndef TOSONLY
	kentry	= k;
	api	= uapi;

	if (check_kentry_version())
		return -1;
#endif

	c_conws (MSG_BOOT);
	c_conws (MSG_GREET);
	DEBUG (("%s: enter init", __FILE__));

#ifdef TOSONLY
	/*
	 * GET _USB COOKIE to REGISTER 
	 */
	if (!getcookie(_USB, (long *)&api))
	{
		(void) Cconws ("ETH failed to get _USB cookie\r\n");
		return -1;
	}

 	/* Set the EUSB cookie so that USB ethernet devices can be probed. */
	usbNetAPI = (struct usb_netapi *)kmalloc(sizeof(struct usb_netapi));
	if (!usbNetAPI) {
		(void) Cconws ("Failed to alloc usbNetAPI\r\n");
		return -1;
	}
	memset(usbNetAPI, 0, sizeof(struct usb_netapi));

	usbNetAPI->majorVersion = 0;
	usbNetAPI->minorVersion = 0;
	usbNetAPI->numDevices = MAX_USB_ETHERNET_DEVICES;
	usbNetAPI->usb_eth_register = usb_eth_register;
	usbNetAPI->usb_eth_deregister = usb_eth_deregister;
	usbNetAPI->usbnet = (struct usb_eth_prob_dev *)kmalloc(usbNetAPI->numDevices * sizeof(struct usb_eth_prob_dev));
	if (!usbNetAPI->usbnet) {
		(void) Cconws ("Failed to alloc usbnet\r\n");
		return -1;
	}
	memset(usbNetAPI->usbnet, 0, usbNetAPI->numDevices * sizeof(struct usb_eth_prob_dev));

	setcookie(COOKIE_EUSB, (long)usbNetAPI);
#else
	/*
	 * Find EUSB cookie.
	 */
	if (cookie)
	{
		while (cookie->name)
		{
			if (cookie->name == COOKIE_EUSB) {
				usbNetAPI = (struct usb_netapi *)cookie->val;
				break;
			}
			cookie++;
		}
	}

	if (!usbNetAPI) {
		c_conws (MSG_FAILURE);
		return 1;
	}
#endif

	usb_eth = (struct ueth_data *) kmalloc(sizeof(struct ueth_data) * usbNetAPI->numDevices);
	if (!usb_eth) {
		c_conws (MSG_FAILURE);
		return 1;
	}

	memset(usb_eth, 0, sizeof(usb_eth));

	ret = udd_register(&eth_uif);
	if (ret)
	{
		c_conws (MSG_FAILURE);
		kfree(usb_eth);
		DEBUG (("%s: udd register failed!", __FILE__));
		return 1;
	}


	DEBUG (("%s: udd register ok", __FILE__));
	
	return 0;
}

