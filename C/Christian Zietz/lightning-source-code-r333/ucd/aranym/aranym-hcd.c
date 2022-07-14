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

/*--- Debug section ---*/

#if 0
# define DEV_DEBUG	1
#endif

/*--- Includes ---*/
#include "mint/arch/nf_ops.h"
#include "mint/dcntl.h"

#ifndef TOSONLY
#include "mint/mint.h"
#include "libkern/libkern.h"
#endif

#include "../../global.h"

#include "aranym.h"
#include "usbhost_nfapi.h"

#include "../../usb.h"
#include "../../usb_api.h"

/*--- Defines ---*/
#define VER_MAJOR	0
#define VER_MINOR	2
#define VER_STATUS	

#ifdef TOSONLY
#define MSG_VERSION    "TOS"
#else
#define MSG_VERSION    "FreeMiNT"
#endif

#define MSG_BUILDDATE	__DATE__

#define MSG_BOOT	\
	"\033pAranym USB controller driver " MSG_VERSION " \033q\r\n"

#define MSG_GREET	\
	"(c) 2012-2014 by David Galvez.\r\n" \
	"Compiled " MSG_BUILDDATE ".\r\n\r\n"

/*--- Global variables ---*/

static const char hcd_name[] = "aranym-hcd";
static char lname[] = "Aranym USB driver\0";

/* BEGIN kernel interface */

#ifndef TOSONLY
struct kentry	*kentry;
struct kentry	*kentry;
#else
extern unsigned long _PgmSize;
#endif
struct usb_module_api *api;

/* END kernel interface */

static struct usb_device *root_hub_dev = NULL;
unsigned long rh_port_status[NUMBER_OF_PORTS]; 


/*--- Function prototypes ---*/

/*--- Interrupt ---*/

/* old handler */
extern void (*old_interrupt)(void);

/* interrupt wrapper routine */
void my_interrupt (void);

/* interrupt handling - bottom half */
void _cdecl 	nfusb_interrupt	(void);

long		submit_bulk_msg		(struct usb_device *, unsigned long , void *, long, long, unsigned long);
long		submit_control_msg	(struct usb_device *, unsigned long, void *,
					 long, struct devrequest *);
long		submit_int_msg		(struct usb_device *, unsigned long, void *, long, long);

/* USB controller interface */
static long _cdecl	aranym_open		(struct ucdif *);
static long _cdecl	aranym_close		(struct ucdif *);
static long _cdecl	aranym_ioctl		(struct ucdif *, short, long);


static struct ucdif aranym_uif = 
{
	0,			/* *next */
	USB_API_VERSION,	/* API */
	USB_CONTRLL,		/* class */
	lname,			/* lname */
	"aranym",		/* name */
	0,			/* unit */
	0,			/* flags */
	aranym_open,		/* open */
	aranym_close,		/* close */
	0,			/* resrvd1 */
	aranym_ioctl,		/* ioctl */
	0,			/* resrvd2 */
};


/* Native features */
static unsigned long nfUsbHostID;
long __CDECL (*nf_call)(long id, ...) = 0UL;
#ifdef TOSONLY
struct nf_ops *nf_init(void);
#endif


/*--- Functions ---*/

static inline unsigned long
get_nfapi_version()
{
#ifdef TOSONLY
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
#endif
	return nf_call(USBHOST(GET_VERSION));
#ifdef TOSONLY
	if (oldmode) SuperToUser(oldmode);
#endif
}


static inline unsigned long
get_int_level()
{
#ifdef TOSONLY
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
#endif
	return nf_call(USBHOST(USBHOST_INTLEVEL));
#ifdef TOSONLY
	if (oldmode) SuperToUser(oldmode);
#endif
}


static inline unsigned long
get_rh_port_status(unsigned long *rhportstatus)
{
#ifdef TOSONLY
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
#endif
	return nf_call(USBHOST(USBHOST_RH_PORT_STATUS), rh_port_status);
#ifdef TOSONLY
	if (oldmode) SuperToUser(oldmode);
#endif
}


/* --- Transfer functions -------------------------------------------------- */

long
submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		   long len, long interval)
{
	DEBUG(("dev=0x%ld pipe=%lx buf=0x%lx size=%ld int=%ld",
	       dev->devnum, pipe, (unsigned long)buffer, len, interval));
	
	long r;
#ifdef TOSONLY
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
#endif
	r = nf_call(USBHOST(USBHOST_SUBMIT_INT_MSG), pipe, buffer, len, interval);
#ifdef TOSONLY
	if (oldmode) SuperToUser(oldmode);
#endif
	if(r >= 0) {
		dev->status = 0;
		dev->act_len = r;
		return 0;
	}

	return -1;
}


long
submit_control_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		       long len, struct devrequest *setup)
{
	long r;
#ifdef TOSONLY
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
#endif
	r = nf_call(USBHOST(USBHOST_SUBMIT_CONTROL_MSG), pipe, buffer, len, setup);
#ifdef TOSONLY
	if (oldmode) SuperToUser(oldmode);
#endif
	if(r >= 0) {
		dev->status = 0;
		dev->act_len = r;
		return 0;
	}

	return -1;
}


long
submit_bulk_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
		    long len, long flags, unsigned long timeout)
{
	long r;
#ifdef TOSONLY
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
#endif
	r = nf_call(USBHOST(USBHOST_SUBMIT_BULK_MSG), pipe, buffer, len, flags, timeout);
#ifdef TOSONLY
	if (oldmode) SuperToUser(oldmode);
#endif
	if(r >= 0) {
		dev->status = 0;
		dev->act_len = r;
		return 0;
	}

	return -1;
}


/* --- Interrupt functions ----------------------------------------------------- */

static void
#ifdef TOSONLY
int_handle_tophalf(void)
#else
int_handle_tophalf (PROC *process, long arg)
#endif
{
	unsigned char i;

	get_rh_port_status(rh_port_status);

	for (i = 0; i < NUMBER_OF_PORTS; i++)
	{
		if (rh_port_status[i] & RH_PS_CSC)
		{
			usb_rh_wakeup(&aranym_uif);
		}
	}
}


void _cdecl
nfusb_interrupt(void)
{	
#ifdef TOSONLY
	int_handle_tophalf();
#else
	addroottimeout (0L, int_handle_tophalf, 0x1);
#endif
}


/* --- Interface functions -------------------------------------------------- */

static long _cdecl
aranym_open (struct ucdif *u)
{
	return E_OK;
}


static long _cdecl
aranym_close (struct ucdif *u)
{
	return E_OK;
}


static long _cdecl
aranym_ioctl (struct ucdif *u, short cmd, long arg)
{
	long ret = E_OK;

	switch (cmd)
	{
		case FS_INFO:
		{
			*(long *)arg = (((long)VER_MAJOR << 16) | VER_MINOR);
			break;
		}
		case LOWLEVEL_INIT :
		{
			ret = usb_lowlevel_init (u->ucd_priv);
			break;
		}
		case LOWLEVEL_STOP :
		{
			ret = usb_lowlevel_stop (u->ucd_priv);
			break;
		}
		case SUBMIT_CONTROL_MSG :
		{
			struct control_msg *ctrl_msg = (struct control_msg *)arg;
			
			ret = submit_control_msg (ctrl_msg->dev, ctrl_msg->pipe,
			 		    ctrl_msg->data, ctrl_msg->size, ctrl_msg->setup);	
			break;
		}
		case SUBMIT_BULK_MSG :
		{
			struct bulk_msg *bulk_msg = (struct bulk_msg *)arg;

			ret = submit_bulk_msg (bulk_msg->dev, bulk_msg->pipe,
				         bulk_msg->data, bulk_msg->len, bulk_msg->flags, bulk_msg->timeout);

			break;
		}
		case SUBMIT_INT_MSG :
		{
			struct int_msg *int_msg = (struct int_msg *)arg;

			ret = submit_int_msg(int_msg->dev, int_msg->pipe,
				       int_msg->buffer, int_msg->transfer_len, 
				       int_msg->interval);

			break;
		}
		default:
		{
			return ENOSYS;
		}
	}	
	return ret;
}


/* --- Init functions ------------------------------------------------------ */

long 
usb_lowlevel_init(void *dummy)
{
	int r;

	r = nf_call(USBHOST(USBHOST_LOWLEVEL_INIT));

	if (!r) 
		(void) c_conws("Aranym USB Controller Driver init \r\n");
	else
		(void) c_conws("Couldn't init aranym host chip emulator \r\n");

	return 0;
}


long 
usb_lowlevel_stop(void *dummy)
{
	int r;
#ifdef TOSONLY
	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
#endif
	r = nf_call(USBHOST(USBHOST_LOWLEVEL_STOP));
#ifdef TOSONLY
	if (oldmode) SuperToUser(oldmode);
#endif
	return r;
}


/* Entry function */
#ifdef TOSONLY
int init(int argc, char **argv, char **env);

int
init(int argc, char **argv, char **env)
#else
long _cdecl init (struct kentry *, struct usb_module_api *, char **);

long _cdecl
init(struct kentry *k, struct usb_module_api *uapi, char **reason)
#endif
{
	long ret;
	char message[100];
#ifndef TOSONLY
	kentry	= k;
	api	= uapi;

	if (check_kentry_version())
		return -1;
#else
	const struct nf_ops *nf_ops;

	unsigned long oldmode = (Super(1L) ? 0L: Super(0L));
	nf_ops = nf_init();
	if (oldmode) SuperToUser(oldmode);
	if (!nf_ops)
	{
		c_conws("Native Features not present on this system\r\n");
		return NULL;
	}
#endif
	/* get the USBHost NatFeat ID */
	nfUsbHostID = 0;

	if (nf_ops != NULL)
		nfUsbHostID = nf_ops->get_id("USBHOST");

	if ( nfUsbHostID == 0 ) {
		sprintf(message, 100 * sizeof(char), "%s not installed - NatFeat not found\n\r", lname);
		c_conws(message);
		return 1;
	}

	/* safe the nf_call pointer */
	nf_call = nf_ops->call;

	/* compare the version */
	if ( get_nfapi_version() != USBHOST_NFAPI_VERSION ) {
		sprintf(message, 100 * sizeof(char), "%s not installed - version mismatch: %ld != %d\n\r", hcd_name, get_nfapi_version(), USBHOST_NFAPI_VERSION);
		c_conws(message);
		return 1;
	}

	c_conws (MSG_BOOT);
	c_conws (MSG_GREET);
	DEBUG (("%s: enter init", __FILE__));

#ifdef TOSONLY
	/* Get USB cookie */
	if (!getcookie(_USB, (long *)&api))
	{
		(void)Cconws("NetUSBee failed to get _USB cookie\r\n");
		return -1;
	}
#endif
	ret = ucd_register(&aranym_uif, &root_hub_dev);
	if (ret)
	{
		DEBUG (("%s: ucd register failed!", __FILE__));
		return 1;
	}

	DEBUG (("%s: ucd register ok", __FILE__));

	/* Set handler and interrupt for Root Hub Status Change */
# define vector(x)      (x / 4)
	old_interrupt = (void(*)()) b_setexc(vector(0x60) + get_int_level(), (long) my_interrupt);

#ifdef TOSONLY
	c_conws("Aranym USB driver installed.\r\n");
	Ptermres(_PgmSize,0);
#endif
	
	return 0;
}
