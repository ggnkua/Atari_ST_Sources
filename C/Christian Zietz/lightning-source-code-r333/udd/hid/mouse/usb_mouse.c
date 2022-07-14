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

#include "../hid-common/hid.h"
#include "../hid-common/hidparse.h"

#include <mint/sysvars.h>   /* OSHEADER */

#ifdef TOSONLY
#define MSG_VERSION "TOS DRIVERS"
#else
#define MSG_VERSION "FreeMiNT DRIVERS"
#endif

#define MSG_BUILDDATE	__DATE__

#ifdef TOSONLY
#define MSG_BOOT	\
		"\r\n\033p USB mouse class driver " MSG_VERSION " \033q\r\n"
#define MSG_GREET	\
		"Ported, mixed and shaken by Alan Hourihane.\r\n" \
		"Compiled " MSG_BUILDDATE ".\r\n"
#else
#define MSG_BOOT	\
		"\033p USB mouse class driver " MSG_VERSION " \033q\r\n"

#define MSG_GREET	\
		"Ported, mixed and shaken by Alan Hourihane.\r\n" \
		"Compiled " MSG_BUILDDATE ".\r\n\r\n"
#endif

#define WHEELMOUSE
#define MAX_WHEEL_INTERVAL	10
#define CPU_SAVER_INTERVAL	3
#define MAX_KEYPRESSES		6

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
int isHddriverModule(void); /* in entry.S */

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

struct mse_info
{
	long buttons;
	long x, y;
	long wheel;
	long ac_pan;
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
	long old_buttons;
	long old_ac_pan;
	struct mse_info new;
};

enum hid_data_type {
	HID_BUTTONS = 0,
	HID_X,
	HID_Y,
	HID_WHEEL,
	HID_AC_PAN,
	HID_MAX_USAGES
};

/* Array of extract bits, one per usage needed */
static struct extract_bits usages[HID_MAX_USAGES];
static struct mse_data mse_data;
static int hid_mode = 0;

/*
 * --- Interface functions
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

/* Parse the HID report descriptor of a mouse and initialize
 * internal data structures.
 * Inputs:
 *   buff: Buffer that contains the HID report descriptor.
 *   len: Length of the descriptor.
 * Returns:
 *   TRUE/FALSE depending on whether the descriptor could be
 *   successfully parsed.
 */
static long hid_parser_mouse(unsigned char* buff, long len)
{
	struct HID_PARSER parser;
	struct HID_DATA data;
	struct HID_NODE usage;

	memset(usages, 0, sizeof(struct extract_bits) * HID_MAX_USAGES);

	/* Sanity check. */
	if ((buff == NULL) || (len <= 0)) {
		return 0L;
	}

	parser.report_desc = buff;
	parser.report_desc_size = len;

	/* Find buttons */
	DEBUG(("\r\nBUTTONS"));
	memset(&data, 0, sizeof(struct HID_DATA));
	usage.u_page = U_PAGE_BUTTON;
	usage.usage = 0;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Number of buttons: %d", (int)parser.report_count));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_BUTTONS], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
	} else {
		DEBUG(("Buttons not found."));
	}

	/* Find x */
	DEBUG(("\r\nX"));
	memset(&data, 0, sizeof(struct HID_DATA));
	usage.u_page = U_PAGE_DESKTOP;
	usage.usage = USAGE_X;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_X], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
	} else {
		DEBUG(("X not found."));
	}

	/* Find y */
	DEBUG(("\r\nY"));
	memset(&data, 0, sizeof(struct HID_DATA));
	usage.u_page = U_PAGE_DESKTOP;
	usage.usage = USAGE_Y;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_Y], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
	} else {
		DEBUG(("Y not found."));
	}

	/* Find wheel */
	DEBUG(("\r\nWHEEL"));
	memset(&data, 0, sizeof(struct HID_DATA));
	usage.u_page = U_PAGE_DESKTOP;
	usage.usage = USAGE_WHEEL;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_WHEEL], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
	} else {
		DEBUG(("wheel not found."));
	}

	/* Find ac (application control) pan */
	DEBUG(("\r\nAC PAN"));
	memset(&data, 0, sizeof(struct HID_DATA));
	usage.u_page = U_PAGE_CONSUMER;
	usage.usage = USAGE_AC_PAN;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_AC_PAN], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
	} else {
		DEBUG(("ac pan not found."));
	}

	/* Mouse needs at least x, y and buttons to be usable. */
	if (usages[HID_BUTTONS].mask && usages[HID_X].mask && usages[HID_Y].mask) {
		return 1L;
	} else {
		return 0L;
	}
}

static inline char clip_to_s8(long v)
{
	if (v > 127L) {
		return 127;
	} else if (v < -128L) {
		return -128;
	} else {
		return (char)v;
	}
}

/*
 * Wireless mice using MosArt Semiconductor chips are strange: They unconditionally
 * NAK every second USB transaction. They do this under Windows, too, so it's not
 * a driver issue. Furthermore, they seem to have a FIFO. Even after the user stops
 * moving the mouse, the cursor continues to move while the FIFO is being emptied.
 * This results in a perceived lagging/trailing of the mouse cursor.
 * To empty the FIFO quicker, the driver polls a MosArt mouse up to *four* times
 * during a single call. Two of these polls are NAKed, see above.
 * Because this takes additional CPU time, this "hack" is only enabled when the
 * MosArt vendor ID is detected.
 */
#define USB_VID_MOSART (0x062a)
int mosart_hack = 0;

void
mouse_int (void)
{
	long mouse_change = 0, wheel_change = 0, ac_pan_change = 0;
	static long wheel_interval = 0; /* time interval between wheel reports (each 20ms) */
	static long cpu_saver_interval = 0; /* time interval between wheel reports (each 20ms) */
	static long cpu_saver = 1; /* boolean, is cpu saver on */
	long actlen = 0;
	long r;
	static unsigned char data[8];

	if (mse_data.pusb_dev == NULL)
		return;

	/* CPU saver: Call less often usb_bulk_msg() when report is identical to last report */
	if (cpu_saver_interval < CPU_SAVER_INTERVAL)
	{
		cpu_saver_interval++;
		if (cpu_saver)
			return;
	}
	else
	{
		cpu_saver_interval = 0;
		if (! cpu_saver)
			cpu_saver = 1;
	}

	if (wheel_interval < MAX_WHEEL_INTERVAL)
		wheel_interval++;

	/* See above for an explanation of 'mosart_hack'. */
	int k;
	for(k=0; k<=mosart_hack; k++) {
		r = usb_bulk_msg (mse_data.pusb_dev,
						  mse_data.irqpipe,
						  data,
						  mse_data.irqmaxp > 8 ? 8 : mse_data.irqmaxp,
						  &actlen, USB_CNTL_TIMEOUT * 5, 1);

		/* actlen is actual length of the mouse report */

		if (mosart_hack && ((r != 0) || (actlen < 3)))
		{
			/* Retry NAKed transaction on MosArt mouse. */
			r = usb_bulk_msg (mse_data.pusb_dev,
							  mse_data.irqpipe,
							  data,
							  mse_data.irqmaxp > 8 ? 8 : mse_data.irqmaxp,
							  &actlen, USB_CNTL_TIMEOUT * 5, 1);
		}
		if ((r != 0) || (actlen < 3))
		{
			return;
		}


		if (hid_mode) {
			mse_data.new.buttons = hid_get_data(data, &usages[HID_BUTTONS]);
			mse_data.new.x = hid_get_data(data, &usages[HID_X]);
			mse_data.new.y = hid_get_data(data, &usages[HID_Y]);
			mse_data.new.wheel = hid_get_data(data, &usages[HID_WHEEL]);
			mse_data.new.ac_pan = hid_get_data(data, &usages[HID_AC_PAN]);
		} else {
			/* Boot mode with fixed data format */
			mse_data.new.buttons = data[0];
			mse_data.new.x = (signed char)data[1];
			mse_data.new.y = (signed char)data[2];
			mse_data.new.wheel = (actlen > 3)?(signed char)data[3]:0;
			mse_data.new.ac_pan = 0;
		}

		/* Buttons change */
		if (mse_data.new.buttons != mse_data.old_buttons)
			mouse_change = 1;

		/* x,y change */
		if (mse_data.new.x != 0 || mse_data.new.y != 0) {
			mouse_change = 1;
			DEBUG(("Report 8 bytes: 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x X = %ld Y = %ld",
				   data[0],
				   data[1],
				   data[2],
				   data[3],
				   data[4],
				   data[5],
				   data[6],
				   data[7],
				   mse_data.new.x,
				   mse_data.new.y));
		}

		/* Wheel change */
		if (mse_data.new.wheel != 0)
			wheel_change = 1;

		/* AC Pan change */
		if (mse_data.new.ac_pan != mse_data.old_ac_pan)
			ac_pan_change = 1;

		if (mouse_change)
		{
			char buttons, old_buttons;

			(void) buttons;
			(void) old_buttons;

			buttons = (char)mse_data.new.buttons;
			old_buttons = (char)mse_data.old_buttons;
			mouse_packet[0] =
				((buttons & 1) << 1) +
				((buttons & 2) >> 1) + 0xF8;
			mouse_packet[1] = clip_to_s8(mse_data.new.x);
			mouse_packet[2] = clip_to_s8(mse_data.new.y);

			if ((buttons & 4) && ! (old_buttons & 4)) /* 3rd button */
				usb_kbd_send_code (0x72, 0x0D); /* Numpad ENTER press */
			else if (! (buttons & 4) && (old_buttons & 4))
				usb_kbd_send_code (0xF2, 0x0D); /* Numpad ENTER release */

			if ((buttons & 8) && ! (old_buttons & 8))	/* 4th button = Page DOWN */
			{
				usb_kbd_send_code(0x2a, 0);		/* Shift press */
				usb_kbd_send_code(0x50, 0);		/* Arrow Down press */
			}
			else if (! (buttons & 8) && (old_buttons & 8))
			{
				usb_kbd_send_code(0x50 + 0x80, 0);	/* Arrow Down release */
				usb_kbd_send_code(0x2a + 0x80, 0);	/* Shift release */
			}

			if ((buttons & 16) && ! (old_buttons & 16))	/* 5th button = Page UP */
			{
				usb_kbd_send_code(0x2a, 0);		/* Shift press */
				usb_kbd_send_code(0x48, 0);		/* Arrow Up press */
			}
			else if (! (buttons & 16) && (old_buttons & 16))
			{
				usb_kbd_send_code(0x48 + 0x80, 0);	/* Arrow Up release */
				usb_kbd_send_code(0x2a + 0x80, 0);	/* Shift release */
			}
		}

	#ifdef WHEELMOUSE
		if (wheel_change)
		{
			char wheel;
			short i, no_of_keypresses;

			(void) wheel;

			wheel = mse_data.new.wheel;
			no_of_keypresses = (MAX_WHEEL_INTERVAL - wheel_interval + 1) * wheel;
			no_of_keypresses = (no_of_keypresses < 0)? -no_of_keypresses:no_of_keypresses;
			no_of_keypresses = (no_of_keypresses > MAX_KEYPRESSES)? MAX_KEYPRESSES:no_of_keypresses;
			for (i = 0; i < no_of_keypresses; i++)
			{
				if (wheel > 0)
				{
					usb_kbd_send_code (0x48, 0); //UP press
					usb_kbd_send_code (0xC8, 0); //UP release
				}
				else if (wheel < 0)
				{
					usb_kbd_send_code (0x50, 0); //DOWN press
					usb_kbd_send_code (0xD0, 0); //DOWN release
				}
			}
			wheel_interval = 0;
		}
		if (ac_pan_change)
		{
			char ac_pan, old_ac_pan;

			(void) ac_pan;
			(void) old_ac_pan;

			ac_pan = mse_data.new.ac_pan;
			old_ac_pan = mse_data.old_ac_pan;

			if (old_ac_pan < 0)
				usb_kbd_send_code (0xCB, 0); /* Arrow Left release */
			else if (old_ac_pan > 0)
				usb_kbd_send_code (0xCD, 0); /* Arrow Right release */

			if (ac_pan > 0)
				usb_kbd_send_code (0x4D, 0); /* Arrow Right press */
			else if (ac_pan < 0)
				usb_kbd_send_code (0x4B, 0); /* Arrow Left press */

		}
	#endif
		if (mouse_change || wheel_change || ac_pan_change)
		{
			fake_hwint();
			cpu_saver = 0;
			cpu_saver_interval = 0;
		}
		if (mouse_change)
		{
			send_packet (vector->mousevec, mouse_packet, mouse_packet + 3);
			mse_data.old_buttons = mse_data.new.buttons;
		}
		if (ac_pan_change)
			mse_data.old_ac_pan = mse_data.new.ac_pan;
	}
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

	/* BEGIN report descriptor dump */
	/* TO DO, if 0
	c_conws("HID report\r\n");
	unsigned char hid_report[4096];
	int fp;
	long len = 0L, ret = 0L;
	len = hid_get_report_desc_len(dev, ifnum);
	hex_long(len);
	if (len > 0L) {
		ret = hid_get_report_desc(dev, ifnum, hid_report, len);
		if (ret != -1L) {
			fp = (int) Fcreate("report.bin", 0);
			Fwrite(fp, len, hid_report);
			Fclose(fp);
		}
	}
	*/
	/* END report descriptor dump */

	long hid_report_desc_len;
	unsigned char *hid_report_desc_buf;

	hid_mode = 0;
	hid_report_desc_len = hid_get_report_desc_len(dev, ifnum);
	if (hid_report_desc_len > 0) {
		hid_report_desc_buf = (unsigned char*)kmalloc(hid_report_desc_len);
		if (hid_report_desc_buf != NULL) {
			long act_len = hid_get_report_desc(dev, ifnum, hid_report_desc_buf, hid_report_desc_len);
			hid_mode = hid_parser_mouse(hid_report_desc_buf, act_len)?1:0;
			kfree(hid_report_desc_buf);
		} else {
			DEBUG(("mouse_probe: kmalloc %ld failed", hid_report_desc_len));
		}
	}
	DEBUG(("mouse_probe: hid_mode is %d", hid_mode));

	mse_data.pusb_dev = dev;

	mse_data.irqinterval =
		(mse_data.irqinterval > 0) ? mse_data.irqinterval : 255;
	mse_data.irqpipe =
		usb_rcvintpipe (mse_data.pusb_dev, (long) mse_data.ep_int);
	mse_data.irqmaxp = usb_maxpacket (dev, mse_data.irqpipe);
	dev->irq_handle = usb_mouse_irq;
	mse_data.old_buttons = 0L;
	mse_data.old_ac_pan = 0L;
	memset (&mse_data.new, 0, sizeof(mse_data.new));

	usb_set_idle (dev, iface->desc.bInterfaceNumber, 0, 0);     /* report infinite */

	usb_set_protocol(dev, iface->desc.bInterfaceNumber, hid_mode); // report/HID or boot

	/* See above for an explanation of 'mosart_hack'. */
	if (dev->descriptor.idVendor == USB_VID_MOSART)
	{
		DEBUG(("mouse_probe: MosArt hack enabled"));
		mosart_hack = 1;
	}
	else
	{
		mosart_hack = 0;
	}

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
		if (Super((void *)1L) == 0L)
			ret = Super(0L);
		else
			ret = 0;
		old_ikbd_int = (void *) *(volatile unsigned long *) 0x400;
		*(volatile unsigned long *) 0x400 = (unsigned long) interrupt_ikbd;
		if (ret)
			SuperToUser((void *)ret);
	}
#endif
	c_conws ("USB mouse driver installed");

	/* terminate and stay resident */
	if (isHddriverModule()) {
		c_conws(" as HDDRIVER module.\r\n");
		return 0;
	} else {
		c_conws(".\r\n");
		Ptermres(_PgmSize, 0);
	}
#endif

	return 0;
}
