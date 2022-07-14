/*
 * USB mouse driver
 *
 * Copyright (C) 2014 by Alan Hourihane
 *
 * USB keyboard send code by Roger Burrows and Christian Zietz
 *
 * Wheel mouse support by Claude Labelle
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See /COPYING.GPL for details.
 */
#include "../../../global.h"

#include "../../../usb.h"
#include "../../../usb_api.h"

#include <mint/sysvars.h>   /* OSHEADER */

#ifdef TOSONLY
#define MSG_VERSION "TOS DRIVERS"
#else
#define MSG_VERSION "FreeMiNT DRIVERS"
#endif

#define MSG_BUILDDATE	__DATE__

#define MSG_BOOT	\
	"\033p USB mouse class driver " MSG_VERSION " \033q\r\n"

#define MSG_GREET	\
	"Ported, mixed and shaken by Alan Hourihane.\r\n" \
	"Compiled " MSG_BUILDDATE ".\r\n\r\n"

#define WHEELMOUSE
#define MAX_WHEEL_INTERVAL 10

/****************************************************************************/
/*
 * BEGIN kernel interface 
 */

#ifndef TOSONLY
struct kentry *kentry;

void mouse_poll_thread (void *);
void mouse_poll (PROC * proc, long dummy);
#else
extern unsigned long _PgmSize;

/*
 * old handler 
 */
extern void (*old_ikbd_int) (void);

/*
 * interrupt wrapper routine 
 */
extern void interrupt_ikbd (void);
#endif

struct kbdvbase
{
	long midivec;
	long vkbderr;
	long vmiderr;
	long statvec;
	long mousevec;
	long clockvec;
	long joyvec;
	long midisys;
	long ikbdsys;
	short drvstat;			/* Non-zero if a packet is currently
							 * transmitted. */
};
typedef struct kbdvbase KBDVEC;

typedef struct {
	unsigned char *buf;         /* input buffer */
	short size;                 /* buffer size */
	volatile short head;        /* head index */
	volatile short tail;        /* tail index */
	short low;                  /* low water mark */
	short high;                 /* high water mark */
} IOREC;

KBDVEC *vector;
IOREC *iokbd;
unsigned char *conterm_ptr;
unsigned char *shifty_ptr;
void (*usb_kbd_send_code)(unsigned short x, char ascii);

static char mouse_packet[6];

/*
 * the following functions are defined in mouse_int.S
 */
void _cdecl send_packet (long func, char *buf, char *bufend);
void _cdecl fake_hwint(void);
void _cdecl send_data (long func, long iorec, long data);

struct usb_module_api *api;

void mouse_int (void);

/*
 * END kernel interface 
 */
/****************************************************************************/

/*
 * USB device interface
 */

static long mouse_ioctl (struct uddif *, short, long);
static long mouse_disconnect (struct usb_device *dev);
static long mouse_probe (struct usb_device *dev, unsigned int ifnum);

static char lname[] = "USB mouse class driver\0";

static struct uddif mouse_uif = {
	0,                          /* *next */
	USB_API_VERSION,            /* API */
	USB_DEVICE,                 /* class */
	lname,                      /* lname */
	"mouse",                    /* name */
	0,                          /* unit */
	0,                          /* flags */
	mouse_probe,                /* probe */
	mouse_disconnect,           /* disconnect */
	0,                          /* resrvd1 */
	mouse_ioctl,                /* ioctl */
	0,                          /* resrvd2 */
};

struct mse_data
{
	struct usb_device *pusb_dev;        /* this usb_device */
	unsigned char ep_in;        /* in endpoint */
	unsigned char ep_out;       /* out ....... */
	unsigned char ep_int;       /* interrupt . */
	long *irq_handle;            /* for USB int requests */
	unsigned long irqpipe;      /* pipe for release_irq */
	unsigned char irqmaxp;      /* max packed for irq Pipe */
	unsigned char irqinterval;  /* Intervall for IRQ Pipe */
	char data[8];
	char new[8];
};

static struct mse_data mse_data;

/*
 * --- Inteface functions
 * -------------------------------------------------- 
 */

static long _cdecl
mouse_ioctl (struct uddif *u, short cmd, long arg)
{
	return E_OK;
}

/*
 * ------------------------------------------------------------------------- 
 */

/*******************************************************************************
 * 
 * 
 */
static long
mouse_disconnect (struct usb_device *dev)
{
	if (dev == mse_data.pusb_dev)
	{
		mse_data.pusb_dev = NULL;
#ifndef TOSONLY
		wake (WAIT_Q, (long) &mouse_poll_thread);
#endif
	}

	return 0;
}

static long
usb_mouse_irq (struct usb_device *dev)
{
	return 0;
}

/*
 * we prefer to pass the keyboard data to the operating system by
 * calling the function pointed to by the long immediately before the
 * standard KBDVECS structure.  this ensures the data is treated
 * exactly the same as if it came from the ikbd.
 */
static void send_via_kbdvecs(unsigned short scancode, char ascii)
{
	long *vecptr = (long *)vector;
	send_data(vecptr[-1], (long)iokbd, scancode);
}

/*
 * under TOS1, this pointer is not available, so we use the alternate
 * method of stuffing characters into the keyboard buffer.
 *
 * Note that this does not provide exactly the same functionality:
 * for example, alt+scroll-wheel moves the mouse pointer under TOS2
 * but not under TOS1.
 */
static void send_via_buffer(unsigned short scancode, char ascii)
{
	unsigned long keycode;
	short tail;
	if (scancode & 0x80)    /* key release not relevant for buffer stuffing */
		return;

	keycode = (unsigned long)scancode << 16 | ascii;

	/* insert the shift key status if required */
	if (*conterm_ptr & 0x08)
		keycode |= (unsigned long)(*shifty_ptr) << 24;

	DEBUG(("send_via_buffer: pushing value 0x%08lx", keycode));

	tail = iokbd->tail + 4;
	if (tail >= iokbd->size)    /* handle wrap */
		tail = 0;

	if (tail == iokbd->head)    /* iorec full */
		return;

	*(unsigned long *)(iokbd->buf + tail) = keycode;
	iokbd->tail = tail;
}

void
mouse_int (void)
{
	long mouse_change = 0, wheel_change = 0;
	static long wheel_interval = 0; //time interval between wheel reports (each 20ms)
	long actlen = 0;
	long r;

	if (mse_data.pusb_dev == NULL)
		return;

	if (wheel_interval < MAX_WHEEL_INTERVAL)
		wheel_interval++;

#if 0
	usb_submit_int_msg (mse_data.pusb_dev,
						mse_data.irqpipe,
						mse_data.data,
						mse_data.irqmaxp > 8 ? 8 : mse_data.irqmaxp,
						USB_CNTL_TIMEOUT * 5);
#else
	r = usb_bulk_msg (mse_data.pusb_dev,
					  mse_data.irqpipe,
					  mse_data.new,
					  mse_data.irqmaxp > 8 ? 8 : mse_data.irqmaxp,
					  &actlen, USB_CNTL_TIMEOUT * 5, 1);

	/* actlen is actual length of the mouse report */

	if ((r != 0) || (actlen < 3))
	{
		return;
	}

	/* Buttons change */
	if (mse_data.new[0] != mse_data.data[0])
		mouse_change = 1;

	/* x,y change */
	if (mse_data.new[1] != 0 || mse_data.new[2] != 0)
		mouse_change = 1;

	/* if there is a 4th byte, it must be z (scroll wheel) */
	if (actlen > 3)
	{
		if (mse_data.new[3] != 0)
			wheel_change = 1;
	}

	if (mouse_change)
	{
		char buttons, old_buttons;

		(void) buttons;
		(void) old_buttons;

		buttons = mse_data.new[0];
		old_buttons = mse_data.data[0];
		mouse_packet[0] =
			((buttons & 1) << 1) +
			((buttons & 2) >> 1) + 0xF8;
		mouse_packet[1] = mse_data.new[1];
		mouse_packet[2] = mse_data.new[2];

		if ((buttons & 4) && ! (old_buttons & 4)) /* 3rd button */
			usb_kbd_send_code (0x72, 0x0D); /* Numpad ENTER press */
		else if (! (buttons & 4) && (old_buttons & 4))
			usb_kbd_send_code (0xF2, 0x0D); /* Numpad ENTER release */
	}

#ifdef WHEELMOUSE
	if (wheel_change)
	{
		char wheel;
		short i, j;

		(void) wheel;

		wheel = mse_data.new[3];
		for (j = 0; j < (MAX_WHEEL_INTERVAL - wheel_interval + 1); j++)
		{
			if (wheel > 0)
			{
				for (i = 0; i < wheel; i++)
				{
					usb_kbd_send_code (0x48, 0); //UP press
					usb_kbd_send_code (0xC8, 0); //UP release
				}
			}
			else if (wheel < 0)
			{
				for (i = 0; i > wheel; i--)
				{
					usb_kbd_send_code (0x50, 0); //DOWN press
					usb_kbd_send_code (0xD0, 0); //DOWN release
				}
			}
		}
		wheel_interval = 0;
	}
#endif
	if (mouse_change || wheel_change)
		fake_hwint();
	if (mouse_change)
	{
		send_packet (vector->mousevec, mouse_packet, mouse_packet + 3);
		mse_data.data[0] = mse_data.new[0];
	}
#endif
}

#ifndef TOSONLY
void
mouse_poll (PROC * proc, long dummy)
{
	wake (WAIT_Q, (long) &mouse_poll_thread);
}

void
mouse_poll_thread (void *dummy)
{
	p_setpriority(0,0,-20);

	while (mse_data.pusb_dev)
	{
		mouse_int ();
		addroottimeout (20, mouse_poll, 0);
		sleep (WAIT_Q, (long) &mouse_poll_thread);
	}

	kthread_exit (0);
}
#endif

/*******************************************************************************
 * 
 * 
 */
static long
mouse_probe (struct usb_device *dev, unsigned int ifnum)
{
	struct usb_interface *iface;
	struct usb_endpoint_descriptor *ep_desc;

	/*
	 * Only one mouse at a time
	 */
	if (mse_data.pusb_dev)
	{
		return -1;
	}

	if (dev == NULL)
	{
		return -1;
	}

	usb_disable_asynch (1);     /* asynch transfer not allowed */

	/*
	 * let's examine the device now 
	 */
	iface = &dev->config.if_desc[ifnum];
	if (!iface)
	{
		return -1;
	}
	if (iface->desc.bInterfaceClass != USB_CLASS_HID && (iface->desc.bInterfaceSubClass != USB_SUB_HID_BOOT))
	{
		return -1;
	}

	if (iface->desc.bInterfaceProtocol != 2)
	{
		return -1;
	}

	if (iface->desc.bNumEndpoints != 1)
	{
		return -1;
	}

	ep_desc = &iface->ep_desc[0];
	if (!ep_desc)
	{
		return -1;
	}

	if ((ep_desc->bmAttributes &
		 USB_ENDPOINT_XFERTYPE_MASK) == USB_ENDPOINT_XFER_INT)
	{
		mse_data.ep_int =
			ep_desc->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK;
		mse_data.irqinterval = ep_desc->bInterval;
	}
	else
	{
		return -1;
	}

	mse_data.pusb_dev = dev;

	mse_data.irqinterval =
		(mse_data.irqinterval > 0) ? mse_data.irqinterval : 255;
	mse_data.irqpipe =
		usb_rcvintpipe (mse_data.pusb_dev, (long) mse_data.ep_int);
	mse_data.irqmaxp = usb_maxpacket (dev, mse_data.irqpipe);
	dev->irq_handle = usb_mouse_irq;
	memset (&mse_data.data, 0, sizeof(mse_data.data));
	memset (&mse_data.new, 0, sizeof(mse_data.new));

	usb_set_idle (dev, iface->desc.bInterfaceNumber, 0, 0);     /* report infinite */

	/* will need to parse the HID Report Descriptor for the report protocol to work
	 * because the mouse HID report fields don't necessarily match those in the boot report.
	 */
	/*
	if (iface->desc.bInterfaceClass == USB_CLASS_HID)
		usb_set_protocol (dev, iface->desc.bInterfaceNumber, 1); //report
	else
	*/
		usb_set_protocol(dev, iface->desc.bInterfaceNumber, 0); //boot

#ifndef TOSONLY
	long r = kthread_create (get_curproc (), mouse_poll_thread, NULL, NULL,
							 "mousepoll");

	if (r)
	{
		return -1;
	}
#endif
	return 0;
}

static long init_shifty_ptr(void)
{
	OSHEADER *os_header;

	/* following is the official Atari-documented method for getting this ptr */
	os_header = (OSHEADER *)0x4f2;
	if (os_header->os_version == 0x0100)
		shifty_ptr = (unsigned char *)0xe1b;
	else
		shifty_ptr = (unsigned char *)*os_header->pkbshift;

	return 0L;
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
	long ret;
	unsigned short gemdos;

#ifndef TOSONLY
	kentry = k;
	api = uapi;

	if (check_kentry_version ())
		return -1;
#endif

	c_conws (MSG_BOOT);
	c_conws (MSG_GREET);
	DEBUG (("%s: enter init", __FILE__));

#ifdef TOSONLY
	/*
	 * GET _USB COOKIE to REGISTER 
	 */
	if (!getcookie (_USB, (long *)&api))
	{
		(void) Cconws ("MOUSE failed to get _USB cookie\r\n");
		return -1;
	}
#endif

	ret = udd_register (&mouse_uif);

	if (ret)
	{
		DEBUG (("%s: udd register failed!", __FILE__));
		return 1;
	}

	DEBUG (("%s: udd register ok", __FILE__));

	vector = (KBDVEC *)b_kbdvbase();
	iokbd = (IOREC *)b_uiorec(1);
	conterm_ptr = (unsigned char *) 0x484;
	b_supexec(init_shifty_ptr, 0L, 0L, 0L, 0L, 0L);

	/*
	 * This driver uses the extended KBDVECS structure, if available.
	 * Since it's undocumented (though present in TOS2/3/4), there is no
	 * Atari-specified method to determine if it is available.  We use
	 * the GEMDOS version reported by Sversion() to discriminate:
	 *  . TOS 1 (which does not have it) reports versions < 0x0019
	 *  . TOS 2/3/4, MagiC, and EmuTOS (which all have it) report versions >= 0x0019
	 */
	gemdos = s_version();
	gemdos = (gemdos>>8) | (gemdos<<8); /* major|minor */
	usb_kbd_send_code = (gemdos >= 0x0019) ? send_via_kbdvecs : send_via_buffer;
	iokbd = (void *)b_uiorec(1);

#ifdef TOSONLY
#if 0
	old_ikbd_int = Setexc (0x114/4, (long) interrupt_ikbd);
#else
	{
		ret = Super (0L);
		old_ikbd_int = (void *) *(volatile unsigned long *) 0x400;
		*(volatile unsigned long *) 0x400 = (unsigned long) interrupt_ikbd;
		SuperToUser (ret);
	}
#endif
	c_conws ("USB mouse driver installed.\r\n");

	Ptermres (_PgmSize, 0);
#endif

	return 0;
}
