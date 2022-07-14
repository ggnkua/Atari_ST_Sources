/*
 * USB tablet driver
 *
 * Copyright (C) 2019 by Claude Labelle
 *
 * USB keyboard send code by Roger Burrows and Christian Zietz
 *
 * based on USB mouse driver by Alan Hourihane
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See /COPYING.GPL for details.
 */
#include "../../../global.h"
#include <gem.h>

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
		"\r\n\033p USB tablet class driver " MSG_VERSION " \033q\r\n"
#define MSG_GREET	\
		"by Claude Labelle.\r\n" \
		"Compiled " MSG_BUILDDATE ".\r\n"
#else
#define MSG_BOOT	\
		"\033p USB tablet class driver " MSG_VERSION " \033q\r\n"
#define MSG_GREET	\
		"by Claude Labelle.\r\n" \
		"Compiled " MSG_BUILDDATE ".\r\n\r\n"
#endif

/* tablet product (model) */
#define PROD_DEFAULT		0
#define PROD_PF1209		1

/****************************************************************************/
/*
 * BEGIN kernel interface
 */

#ifndef TOSONLY
struct kentry *kentry;

void tablet_poll_thread (void *);
void tablet_poll (PROC * proc, long dummy);
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
VdiHdl vdi_handle;

static char mouse_packet[6];

/*
 * the following functions are defined in tablet_int.S
 */
void _cdecl send_packet (long func, char *buf, char *bufend);
void _cdecl fake_hwint(void);
void _cdecl send_data (long func, long iorec, long data);

struct usb_module_api *api;

void tablet_int (void);

/*
 * END kernel interface
 */
/****************************************************************************/

/*
 * USB device interface
 */

static long tablet_ioctl (struct uddif *, short, long);
static long tablet_disconnect (struct usb_device *dev);
static long tablet_probe (struct usb_device *dev, unsigned int ifnum);

static char lname[] = "USB tablet class driver\0";

static struct uddif tablet_uif = {
	0,					/* *next */
	USB_API_VERSION,			/* API */
	USB_DEVICE,				/* class */
	lname,					/* lname */
	"tablet",				/* name */
	0,					/* unit */
	0,					/* flags */
	tablet_probe,				/* probe */
	tablet_disconnect,			/* disconnect */
	0,					/* resrvd1 */
	tablet_ioctl,				/* ioctl */
	0,					/* resrvd2 */
};

struct tblt_info
{
	long tip, barrel;			/* tip and barrel switch, assigned to left and right mouse buttons */
	long sec_barrel;			/* secondary barrel switch, assigned to UNDO */
	long in_range;
	long x, y;
	long pressure;
	long function_keys;
};

struct tblt_data
{
	struct usb_device *pusb_dev;		/* this usb_device */
	unsigned char product;			/* type of tablet */
	unsigned char ep_int;			/* interrupt endpoint */
	long *irq_handle;			/* for USB int requests */
	unsigned long irqpipe;			/* pipe for release_irq */
	unsigned char irqmaxp;			/* max packed for irq Pipe */
	unsigned char irqinterval;		/* Intervall for IRQ Pipe */
	struct tblt_info old;
	struct tblt_info new;
	long tablet_w;
	long tablet_h;
	long max_pressure;
};


enum hid_data_type {
	HID_TIP_SWITCH = 0,
	HID_BARREL_SWITCH,
	HID_SEC_BARREL_SWITCH,
	HID_IN_RANGE,
	HID_X,
	HID_Y,
	HID_FUNCTION_KEYS,
	HID_TIP_PRESSURE,
	HID_MAX_USAGES
};


/* Array of extract bits, one per usage needed */
static struct extract_bits usages[HID_MAX_USAGES];
static struct tblt_data tblt_data;

/* Screen size */
static long screen_w = 0L, screen_h = 0L;

/* Scale of screen vs tablet resolution */
static long scale_w, scale_h;

/*
 * --- Interface functions
 * --------------------------------------------------
 */

static long _cdecl
tablet_ioctl (struct uddif *u, short cmd, long arg)
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
tablet_disconnect (struct usb_device *dev)
{
	if (dev == tblt_data.pusb_dev)
	{
		tblt_data.pusb_dev = NULL;
#ifndef TOSONLY
		wake (WAIT_Q, (long) &tablet_poll_thread);
#endif
	}

	return 0;
}

static long
usb_tablet_irq (struct usb_device *dev)
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
 * for example, alt+scroll-wheel moves the tablet pointer under TOS2
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

/* Parse the HID report descriptor of a tablet and initialize
 * internal data structures.
 * Inputs:
 *   buff: Buffer that contains the HID report descriptor.
 *   len: Length of the descriptor.
 * Returns:
 *   TRUE/FALSE depending on whether the descriptor could be
 *   successfully parsed.
 */
static long hid_parser_tablet(unsigned char* buff, long len)
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

	/* Find tip switch */
	DEBUG(("\r\nTIP SWITCH"));
	memset(&data, 0, sizeof(struct HID_DATA));
	/* Generic tablet as per example in USB HID Usage Tables v.1.12 document at usb.org */
	usage.u_page = U_PAGE_DIGITIZER;
	usage.usage = USAGE_TIP_SWITCH;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_TIP_SWITCH], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
	}
	else
	{
		/* Wacom Intuos S */
		memset(&data, 0, sizeof(struct HID_DATA));
		usage.u_page = 0xFF0D;
		usage.usage = USAGE_TIP_SWITCH;
		if (find_usage(&parser, &usage, &data)) {
			DEBUG(("Logical min: %ld", (long)data.log_min));
			DEBUG(("Logical max: %ld", (long)data.log_max));
			DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
			DEBUG(("Data size in bits: 0x%02x", (int)data.size));

			fill_extract_bits(&usages[HID_TIP_SWITCH], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
		} else {
			DEBUG(("Tip switch not found."));
			return 0L;
		}
	}

	/* Find barrel switch */
	DEBUG(("\r\nBARREL SWITCH"));
	memset(&data, 0, sizeof(struct HID_DATA));
	/* Generic tablet as per example in USB HID Usage Tables v.1.12 document at usb.org */
	usage.u_page = U_PAGE_DIGITIZER;
	usage.usage = USAGE_BARREL_SWITCH;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_BARREL_SWITCH], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
	}
	else
	{
		/* Wacom Intuos S */
		memset(&data, 0, sizeof(struct HID_DATA));
		usage.u_page = 0xFF0D;
		usage.usage = USAGE_BARREL_SWITCH;
		if (find_usage(&parser, &usage, &data)) {
			DEBUG(("Logical min: %ld", (long)data.log_min));
			DEBUG(("Logical max: %ld", (long)data.log_max));
			DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
			DEBUG(("Data size in bits: 0x%02x", (int)data.size));
			DEBUG(("Report ID: 0x%02x", (int)data.report_id));
			DEBUG(("Report ID Used: 0x%02x", (int)data.report_id_used));

			fill_extract_bits(&usages[HID_BARREL_SWITCH], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
		} else {
			DEBUG(("Barrel switch not found."));
		}
	}

	/* Find secondary barrel switch (eraser) */
	DEBUG(("\r\nSECONDARY BARREL SWITCH"));
	memset(&data, 0, sizeof(struct HID_DATA));
	/* Generic tablet as per example in USB HID Usage Tables v.1.12 document at usb.org */
	usage.u_page = U_PAGE_DIGITIZER;
	usage.usage = USAGE_ERASER;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_SEC_BARREL_SWITCH], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
	}
	else
	{
		/* Wacom Intuos S */
		memset(&data, 0, sizeof(struct HID_DATA));
		usage.u_page = 0xFF0D;
		usage.usage = 0x5A;
		if (find_usage(&parser, &usage, &data)) {
			DEBUG(("Logical min: %ld", (long)data.log_min));
			DEBUG(("Logical max: %ld", (long)data.log_max));
			DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
			DEBUG(("Data size in bits: 0x%02x", (int)data.size));
			DEBUG(("Report ID: 0x%02x", (int)data.report_id));
			DEBUG(("Report ID Used: 0x%02x", (int)data.report_id_used));

			fill_extract_bits(&usages[HID_SEC_BARREL_SWITCH], data.offset,
					  data.size * parser.report_count, FALSE,
					  data.report_id_used, data.report_id);
		} else {
			DEBUG(("Secondary barrel switch not found."));
		}
	}

	/* Find stylus in-range boolean */
	DEBUG(("\r\nIN RANGE"));
	memset(&data, 0, sizeof(struct HID_DATA));
	/* Generic tablet as per example in USB HID Usage Tables v.1.12 document at usb.org */
	usage.u_page = U_PAGE_DIGITIZER;
	usage.usage = USAGE_IN_RANGE;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_IN_RANGE], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
	}
	else
	{
		/* Wacom Intuos S */
		memset(&data, 0, sizeof(struct HID_DATA));
		usage.u_page = 0xFF0D;
		usage.usage = USAGE_IN_RANGE;
		if (find_usage(&parser, &usage, &data)) {
			DEBUG(("Logical min: %ld", (long)data.log_min));
			DEBUG(("Logical max: %ld", (long)data.log_max));
			DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
			DEBUG(("Data size in bits: 0x%02x", (int)data.size));
			DEBUG(("Report ID: 0x%02x", (int)data.report_id));
			DEBUG(("Report ID Used: 0x%02x", (int)data.report_id_used));

			fill_extract_bits(&usages[HID_IN_RANGE], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
		} else {
			DEBUG(("In Range not found."));
		}
	}

	/* Find x */
	DEBUG(("\r\nX"));
	memset(&data, 0, sizeof(struct HID_DATA));
	/* Generic tablet as per example in USB HID Usage Tables v.1.12 document at usb.org */
	usage.u_page = U_PAGE_DESKTOP;
	usage.usage = USAGE_X;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_X], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
		tblt_data.tablet_w = (long) data.log_max;
	}
	else
	{
		/* Wacom Intuos S */
		memset(&data, 0, sizeof(struct HID_DATA));
		usage.u_page = 0xFF0D;
		usage.usage = 0x130;
		if (find_usage(&parser, &usage, &data)) {
			DEBUG(("Logical min: %ld", (long)data.log_min));
			DEBUG(("Logical max: %ld", (long)data.log_max));
			DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
			DEBUG(("Data size in bits: 0x%02x", (int)data.size));

			fill_extract_bits(&usages[HID_X], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
			tblt_data.tablet_w = (long) data.log_max;
		} else {
			DEBUG(("X not found."));
			return 0L;
		}
	}

	/* Find y */
	DEBUG(("\r\nY"));
	memset(&data, 0, sizeof(struct HID_DATA));
	/* Generic tablet as per example in USB HID Usage Tables v.1.12 document at usb.org */
	usage.u_page = U_PAGE_DESKTOP;
	usage.usage = USAGE_Y;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_Y], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
		tblt_data.tablet_h = (long) data.log_max;
	}
	else
	{
		/* Wacom Intuos S */
		memset(&data, 0, sizeof(struct HID_DATA));
		usage.u_page = 0xFF0D;
		usage.usage = 0x131;
		if (find_usage(&parser, &usage, &data)) {
			DEBUG(("Logical min: %ld", (long)data.log_min));
			DEBUG(("Logical max: %ld", (long)data.log_max));
			DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
			DEBUG(("Data size in bits: 0x%02x", (int)data.size));

			fill_extract_bits(&usages[HID_Y], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
			tblt_data.tablet_h = (long) data.log_max;
		} else {
			DEBUG(("Y not found."));
			return 0L;
		}
	}

	/* Find function keys */
	DEBUG(("\r\nFUNCTION KEYS"));
	memset(&data, 0, sizeof(struct HID_DATA));
	/* Generic tablet as per example in USB HID Usage Tables v.1.12 document at usb.org */
	usage.u_page = U_PAGE_DIGITIZER;
	usage.usage = USAGE_FUNCTION_KEYS;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Number of function keys: %d", (int)parser.report_count));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));

		fill_extract_bits(&usages[HID_FUNCTION_KEYS], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
	}
	else
	{
		/* Wacom Intuos S */
		memset(&data, 0, sizeof(struct HID_DATA));
		usage.u_page = 0xFF0D;
		usage.usage = 0x910;
		if (find_usage(&parser, &usage, &data)) {
			DEBUG(("Number of function keys: %d", (int)parser.report_count));
			DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
			DEBUG(("Data size in bits: 0x%02x", (int)data.size));

			fill_extract_bits(&usages[HID_FUNCTION_KEYS], data.offset, data.size * parser.report_count, FALSE, data.report_id_used, data.report_id);
		} else {
			DEBUG(("Function keys not found."));
		}
	}

	/* Find tip pressure */
	DEBUG(("\r\nTIP PRESSURE"));
	memset(&data, 0, sizeof(struct HID_DATA));
	/* Generic tablet as per example in USB HID Usage Tables v.1.12 document at usb.org */
	usage.u_page = U_PAGE_DIGITIZER;
	usage.usage = USAGE_TIP_PRESSURE;
	if (find_usage(&parser, &usage, &data)) {
		DEBUG(("Logical min: %ld", (long)data.log_min));
		DEBUG(("Logical max: %ld", (long)data.log_max));
		DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
		DEBUG(("Data size in bits: 0x%02x", (int)data.size));
		
		fill_extract_bits(&usages[HID_TIP_PRESSURE], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
		tblt_data.max_pressure = (long) data.log_max;
	}
	else
	{
		/* Wacom Intuos S */
		memset(&data, 0, sizeof(struct HID_DATA));
		usage.u_page = 0xFF0D;
		usage.usage = USAGE_TIP_PRESSURE;
		if (find_usage(&parser, &usage, &data)) {
			DEBUG(("Logical min: %ld", (long)data.log_min));
			DEBUG(("Logical max: %ld", (long)data.log_max));
			DEBUG(("Data offset in bits: 0x%02x", (int)data.offset));
			DEBUG(("Data size in bits: 0x%02x", (int)data.size));
			
			fill_extract_bits(&usages[HID_TIP_PRESSURE], data.offset, data.size, data.log_min < 0, data.report_id_used, data.report_id);
			tblt_data.max_pressure = (long) data.log_max;
		} else {
			DEBUG(("Tip pressure not found."));
		}
	}

	/* PF1209 adjustments */
	if (tblt_data.product == PROD_PF1209)
	{
		usages[HID_TIP_SWITCH].report_id = usages[HID_BARREL_SWITCH].report_id
						 = usages[HID_SEC_BARREL_SWITCH].report_id
						 = usages[HID_X].report_id = usages[HID_Y].report_id
						 = usages[HID_TIP_PRESSURE].report_id = 0x09;
		tblt_data.tablet_h = 32767L;
		tblt_data.tablet_w = 32767L;
	}

	return 1L;
}

static void
send_mouse_packets(long tip, long barrel, long x, long y)
{
	register char byte_tip, byte_barrel, byte_x, byte_y;

	byte_tip = (char) tip;
	byte_barrel = (char) barrel;
	mouse_packet[0] = ((byte_tip & 1) << 1) + (byte_barrel & 1) + 0xF8;

	do
	{
		byte_x = (x < 0)?MAX(x, -128):MIN(x, 127);
		byte_y = (y < 0)?MAX(y, -128):MIN(y, 127);
		mouse_packet[1] = byte_x;
		mouse_packet[2] = byte_y;
		fake_hwint();
		send_packet (vector->mousevec, mouse_packet, mouse_packet + 3);
		x -= byte_x;
		y -= byte_y;
	} while (x != 0 || y != 0);
}

static void
get_rez()
{
	/* Get screen size */
	VdiHdl handle = vdi_handle;
	short work_in[11], work_out[57];
	int i;

	for (i = 0 ; i < 10 ; work_in[i++] = 1)
		;
	work_in[10] = 2;
	v_opnvwk(work_in, &handle, work_out);
	if (handle)
	{
		screen_w = (long)work_out[0] + 1L;
		screen_h = (long)work_out[1] + 1L;
		v_clsvwk(handle);
	}
}

void
tablet_int (void)
{
	long actlen = 0;
	long r;
	static unsigned char data[64];
	static long track_x = 0L;
	static long track_y = 0L;
	static int tip_pressure_recognition = 0;

	if (tblt_data.pusb_dev == NULL)
		return;

	r = usb_bulk_msg (tblt_data.pusb_dev,
					  tblt_data.irqpipe,
					  data,
					  tblt_data.irqmaxp > 64 ? 64 : tblt_data.irqmaxp,
					  &actlen, USB_CNTL_TIMEOUT * 5, 1);

	if (r != 0)
	{
		return;
	}

	if (usages[HID_TIP_SWITCH].report_id_used && usages[HID_TIP_SWITCH].report_id == data[0])
	{
		tblt_data.new.tip = hid_get_data(data, &usages[HID_TIP_SWITCH]);
		tblt_data.new.barrel = hid_get_data(data, &usages[HID_BARREL_SWITCH]);
		tblt_data.new.sec_barrel = hid_get_data(data, &usages[HID_SEC_BARREL_SWITCH]);
		tblt_data.new.in_range = (tblt_data.product == PROD_PF1209)
					  ? 1L : hid_get_data(data, &usages[HID_IN_RANGE]);
		tblt_data.new.x = hid_get_data(data, &usages[HID_X]);
		tblt_data.new.y = hid_get_data(data, &usages[HID_Y]);
		tblt_data.new.pressure = hid_get_data(data, &usages[HID_TIP_PRESSURE]);

		if (tblt_data.new.in_range)
		{
			/* Stylus enters in range of tablet */
			if (!tblt_data.old.in_range)
			{
				if (screen_w <= 0L || screen_h <= 0L)
				{
					get_rez();
					if (screen_w <= 0L || screen_h <= 0L)
						return;
					scale_w = MAX(1, tblt_data.tablet_w / screen_w);
					scale_h = MAX(1, tblt_data.tablet_h / screen_h);
				}

				send_mouse_packets(0, 0, -screen_w, -screen_h);
				track_x = track_y = 0L;
			}
			/* convert absolute coordinates to relative reporting mode */
			long rel_x, rel_y;

			(void) rel_x;
			(void) rel_y;

			rel_x = (tblt_data.new.x - track_x) / scale_w;
			rel_y = (tblt_data.new.y - track_y) / scale_h;

			/* send mouse packet only if button change or movement */
			if (tblt_data.new.tip != tblt_data.old.tip ||
				tblt_data.new.barrel != tblt_data.old.barrel ||
				rel_x != 0L || rel_y != 0L)
			{
				send_mouse_packets(tblt_data.new.tip, tblt_data.new.barrel, rel_x, rel_y);
			}

			track_x += rel_x * scale_w;
			track_y += rel_y * scale_h;

			/* secondary barrel switch, assign to UNDO key */
			if ((tblt_data.new.sec_barrel) && ! (tblt_data.old.sec_barrel))
				usb_kbd_send_code (0x61, 0); /* Undo press */
			else if (! (tblt_data.new.sec_barrel) && (tblt_data.old.sec_barrel))
				usb_kbd_send_code (0x61 + 0x80, 0); /* Undo release */
			
			/* tip pressure, convert to CTRL-1 to CTRL-9 for Vision */
			if (tip_pressure_recognition)
			{
				static long old_ctrl_value = 0;
				static unsigned short scancode = 0;
				long ctrl_value = MIN(9, tblt_data.new.pressure * 9L / tblt_data.max_pressure);
				if (ctrl_value != old_ctrl_value && scancode == 0)
				{
					scancode = (ctrl_value == 0L)?0x0b : 0x01 + (unsigned short) ctrl_value;
					usb_kbd_send_code(0x1d, 0);		/* Ctrl press */;
					usb_kbd_send_code(scancode, 0);
					old_ctrl_value = ctrl_value;
				}
				else if (scancode)
				{
					usb_kbd_send_code(scancode + 0x80, 0);
					usb_kbd_send_code(0x1d + 0x80, 0);		/* Ctrl release */;
					scancode = 0;
				}
			}
		}
	}
	else if (usages[HID_FUNCTION_KEYS].report_id_used && usages[HID_FUNCTION_KEYS].report_id == data[0])
	{
		/* When the stylus report is received, the function keys report is not. To receive the report, we must move the stylus out of range. */
		tblt_data.new.function_keys = hid_get_data(data, &usages[HID_FUNCTION_KEYS]);

		/* Function key 0 assigned to ESC, 1 inactive, 2 to toggle tip pressure recognition, 3 assigned to get_rez(),  */
		if ((tblt_data.new.function_keys & 1) && ! (tblt_data.old.function_keys & 1))
		{
			usb_kbd_send_code (0x01, 0); /* ESC press */
			usb_kbd_send_code (0x01 + 0x80, 0); /* ESC release */
		}
		
		if ((tblt_data.new.function_keys & 4) && ! (tblt_data.old.function_keys & 4))
		{
			tip_pressure_recognition = ! tip_pressure_recognition;
			c_conout(7); /* ping */
		}

		if ((tblt_data.new.function_keys & 8) && ! (tblt_data.old.function_keys & 8))
		{
			get_rez();
			if (screen_w != 0L && screen_h != 0L)
			{
				scale_w = tblt_data.tablet_w / screen_w;
				scale_h = tblt_data.tablet_h / screen_h;
			}
		}
	}

	tblt_data.old = tblt_data.new;


/* Failed attempts of absolute reporting mode */

#if 0
		/* Absolute reporting mode according to Compute's. No reaction */
		ushort x, y;

		mouse_packet[0] = 0xF7; /* absolute mouse position */
		int tip_change, barrel_change;
		/* < 0: pressed, > 0 released */
		tip_change = memcmp(&tblt_data.old.tip, &tblt_data.new.tip, sizeof(tblt_data.new.tip));
		barrel_change = memcmp(&tblt_data.old.barrel, &tblt_data.new.barrel, sizeof(tblt_data.new.barrel));

		mouse_packet[1] = (barrel_change < 0)?1:0;
		mouse_packet[1] += (barrel_change > 0)?2:0;
		mouse_packet[1] += (tip_change < 0)?4:0;
		mouse_packet[1] += (tip_change > 0)?8:0;

		/* Test Degas Elite at 640 x 400 vs 15199 x 9499, divide by 23.75 */
		x = (ushort) (tblt_data.new.x / 23L);
		y = (ushort) (tblt_data.new.y / 23L);
		mouse_packet[2] = (uchar) (x>>8);
		mouse_packet[3] = (uchar) (x&0xFF);
		mouse_packet[4] = (uchar) (y>>8);
		mouse_packet[5] = (uchar) (y&0xFF);

		tos_printmsg("0x%02x 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x", mouse_packet[0],
					 mouse_packet[1],
					 mouse_packet[2],
					 mouse_packet[3],
					 mouse_packet[4],
					 mouse_packet[5]);

		/* sending packet doesn't work, no mouse reaction. */
		fake_hwint();
		send_packet (vector->mousevec, mouse_packet, mouse_packet + 6);
		
#endif
#if 0
		/* Absolute reporting mode according to Compendium. No reaction */
		int word_x, word_y;
		mouse_packet[0] = 0xF7; /* absolute mouse position */
		word_x = (int) (float) (tblt_data.new.x / 23.75);
		word_y = (int) (float) (tblt_data.new.y / 23.75);
		
		if (word_x == 639)
			tos_printmsg("x=639");
		if (word_y == 399)
			tos_printmsg("y=399");

		mouse_packet[1] = (word_x>>8);
		mouse_packet[2] = (word_x&0xFF);
		mouse_packet[3] = (word_y>>8);
		mouse_packet[4] = (word_y&0xFF);
		fake_hwint();
		send_packet (vector->mousevec, mouse_packet, mouse_packet + 5);
#endif
}

#ifndef TOSONLY
void
tablet_poll (PROC * proc, long dummy)
{
	wake (WAIT_Q, (long) &tablet_poll_thread);
}

void
tablet_poll_thread (void *dummy)
{
	p_setpriority(0,0,-20);

	while (tblt_data.pusb_dev)
	{
		tablet_int ();
		addroottimeout (20, tablet_poll, 0);
		sleep (WAIT_Q, (long) &tablet_poll_thread);
	}

	kthread_exit (0);
}
#endif

/*******************************************************************************
 *
 *
 */
static long
tablet_probe (struct usb_device *dev, unsigned int ifnum)
{
	struct usb_interface *iface;
	struct usb_endpoint_descriptor *ep_desc;

	/*
	 * Only one tablet at a time
	 */
	if (tblt_data.pusb_dev)
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
	if (iface->desc.bInterfaceClass != USB_CLASS_HID && iface->desc.bInterfaceSubClass != 0)
	{
		return -1;
	}

	if (iface->desc.bNumEndpoints < 1)
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
		tblt_data.ep_int =
			ep_desc->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK;
		tblt_data.irqinterval = ep_desc->bInterval;
	}
	else
	{
		return -1;
	}

#if 0
	/* BEGIN report descriptor dump */
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
	return -1;
	/* END report descriptor dump */
#endif

	long hid_report_desc_len;
	unsigned char *hid_report_desc_buf;
	tblt_data.product = (strncmp(dev->prod, "Tablet PF1209", 13) == 0)?PROD_PF1209:PROD_DEFAULT;

	hid_report_desc_len = hid_get_report_desc_len(dev, ifnum);
	if (hid_report_desc_len > 0) {
		hid_report_desc_buf = (unsigned char*)kmalloc(hid_report_desc_len);
		if (hid_report_desc_buf != NULL) {
			long act_len = hid_get_report_desc(dev, ifnum, hid_report_desc_buf, hid_report_desc_len);
			if (! hid_parser_tablet(hid_report_desc_buf, act_len)) {
				kfree(hid_report_desc_buf);
				return -1;
			}
			kfree(hid_report_desc_buf);
		} else {
			DEBUG(("tablet_probe: kmalloc %ld failed", hid_report_desc_len));
		}
	}

	tblt_data.pusb_dev = dev;
	tblt_data.irqinterval = (tblt_data.irqinterval > 0) ? tblt_data.irqinterval : 255;
	tblt_data.irqpipe =
		usb_rcvintpipe (tblt_data.pusb_dev, (long) tblt_data.ep_int);
	tblt_data.irqmaxp = usb_maxpacket (dev, tblt_data.irqpipe);
	dev->irq_handle = usb_tablet_irq;
	memset (&tblt_data.new, 0, sizeof(tblt_data.new));
	memset (&tblt_data.old, 0, sizeof(tblt_data.old));

	usb_set_idle (dev, iface->desc.bInterfaceNumber, 0, 0);     /* report infinite */

#ifndef TOSONLY
	long r = kthread_create (get_curproc (), tablet_poll_thread, NULL, NULL,
							 "tabletpoll");

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
	short dummy;

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
		(void) Cconws ("tablet failed to get _USB cookie\r\n");
		return -1;
	}
#endif

	ret = udd_register (&tablet_uif);

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
	vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);

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
	c_conws ("USB tablet driver installed");

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
