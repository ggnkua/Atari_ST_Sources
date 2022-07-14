/*
 * USB keyboard driver
 *
 * Copyright (C) 2018 by Christian Zietz
 *
 * LED support by Claude Labelle
 *
 * TOS 1.x detection by Roger Burrows
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See /COPYING.GPL for details.
 */
#include "../../../global.h"

#include "../../../usb.h"
#include "../../../usb_api.h"

#include <mint/sysvars.h>   /* OSHEADER */
#define sysbase	((OSHEADER **)0x4f2L)
#define Kbstate() *p_kbshift

#ifdef TOSONLY
#define MSG_VERSION "TOS DRIVERS"
#else
#define MSG_VERSION "FreeMiNT DRIVERS"
#endif

#define MSG_BUILDDATE	__DATE__

#ifdef TOSONLY
#define MSG_BOOT	\
		"\r\n\033p USB keyboard class driver " MSG_VERSION " \033q\r\n"
#define MSG_GREET	\
		"By Christian Zietz.\r\n" \
		"Compiled " MSG_BUILDDATE ".\r\n"
#else
#define MSG_BOOT	\
		"\033p USB keyboard class driver " MSG_VERSION " \033q\r\n"
#define MSG_GREET	\
		"By Christian Zietz.\r\n" \
		"Compiled " MSG_BUILDDATE ".\r\n\r\n"
#endif

#define COOKIE_KINJ (0x4B494E4A)

/****************************************************************************/
/*
 * BEGIN kernel interface
 */

#ifndef TOSONLY
struct kentry *kentry;

void kbd_poll_thread (void *);
void kbd_poll (PROC * proc, long dummy);
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

void *iokbd;
char *p_kbshift;
void _cdecl send_data (long func, long iorec, long data);
void _cdecl fake_hwint(void);

struct usb_module_api *api;

void kbd_int (void);
static void set_led (long);
static long get_capslock_state(void);
static long p_kbshift_init(void);

long kbd_entry = 0;

/*
 * END kernel interface
 */
/****************************************************************************/

/*
 * USB device interface
 */

static long kbd_ioctl (struct uddif *, short, long);
static long kbd_disconnect (struct usb_device *dev);
static long kbd_probe (struct usb_device *dev, unsigned int ifnum);

static unsigned int if_no;
static long led_state;				/* caps lock LED state */
static char lname[] = "USB keyboard class driver\0";

static struct uddif kbd_uif = {
	0,                          /* *next */
	USB_API_VERSION,            /* API */
	USB_DEVICE,                 /* class */
	lname,                      /* lname */
	"keyboard",                 /* name */
	0,                          /* unit */
	0,                          /* flags */
	kbd_probe,                  /* probe */
	kbd_disconnect,             /* disconnect */
	0,                          /* resrvd1 */
	kbd_ioctl,                  /* ioctl */
	0,                          /* resrvd2 */
};

struct kbd_report
{
	unsigned char mod;
	unsigned char reserved;
	unsigned char keys[6];
};

struct kbd_data
{
	struct usb_device *pusb_dev;/* this usb_device */
	unsigned char ep_in;        /* in endpoint */
	unsigned char ep_out;       /* out ....... */
	unsigned char ep_int;       /* interrupt . */
	long *irq_handle;           /* for USB int requests */
	unsigned long irqpipe;      /* pipe for release_irq */
	unsigned long outpipe;      /* pipe for output */
	unsigned char irqmaxp;      /* max packed for irq Pipe */
	unsigned char irqinterval;  /* Intervall for IRQ Pipe */
	struct kbd_report olddata;
	struct kbd_report newdata;
};

static struct kbd_data kbd_data;

/*
 * --- Inteface functions
 * --------------------------------------------------
 */

static long _cdecl
kbd_ioctl (struct uddif *u, short cmd, long arg)
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
kbd_disconnect (struct usb_device *dev)
{
	if (dev == kbd_data.pusb_dev)
	{
		kbd_data.pusb_dev = NULL;
#ifndef TOSONLY
		wake (WAIT_Q, (long) &kbd_poll_thread);
#endif
	}

	return 0;
}

static long
usb_kbd_irq (struct usb_device *dev)
{
	return 0;
}

#define SEND_SCAN(x) send_data(kbd_entry, (long)iokbd, (x)) /* assumes TOS >= 2 */

static void
handle_modifiers(unsigned char val, unsigned char offset)
{
	static long old_capslock_state = 0L;

	if ((val & 1) || (val & 0x10)) /* Left or right control */
		SEND_SCAN(0x1d + offset);

	if (val & 2) /* Left shift */
		SEND_SCAN(0x2a + offset);

	if (val & 0x20) /* Right shift */
		SEND_SCAN(0x36 + offset);

	if (val & 4) /* Left alt */
		SEND_SCAN(0x38 + offset);

	if (val & 0x40) /* Right Alt (Alt Gr), assign to Caps Lock */
	{
		if (offset == 0x00)
			old_capslock_state = get_capslock_state();
		if (old_capslock_state == 0L)
		{
				SEND_SCAN(0x3a + 0x00);
				SEND_SCAN(0x3a + 0x80);
		}
	}
}

/*
 * Key mappings below are for US keyboard.
 * For notes on other languages mappings, refer to
 * the HID Usage Tables 1.12 document at
 * https://www.usb.org/sites/default/files/documents/hut1_12v2.pdf
 */
static unsigned char
translate_key(unsigned char usbkey)
{
	switch (usbkey)
	{
	case 0x04: return 0x1e; // A
	case 0x05: return 0x30; // B
	case 0x06: return 0x2e; // C
	case 0x07: return 0x20; // D
	case 0x08: return 0x12; // E
	case 0x09: return 0x21; // F
	case 0x0a: return 0x22; // G
	case 0x0b: return 0x23; // H
	case 0x0c: return 0x17; // I
	case 0x0d: return 0x24; // J
	case 0x0e: return 0x25; // K
	case 0x0f: return 0x26; // L
	case 0x10: return 0x32; // M
	case 0x11: return 0x31; // N
	case 0x12: return 0x18; // O
	case 0x13: return 0x19; // P
	case 0x14: return 0x10; // Q
	case 0x15: return 0x13; // R
	case 0x16: return 0x1f; // S
	case 0x17: return 0x14; // T
	case 0x18: return 0x16; // U
	case 0x19: return 0x2f; // V
	case 0x1a: return 0x11; // W
	case 0x1b: return 0x2d; // X
	case 0x1c: return 0x15; // Y
	case 0x1d: return 0x2c; // Z
	case 0x1e: return 0x02; // 1
	case 0x1f: return 0x03; // 2
	case 0x20: return 0x04; // 3
	case 0x21: return 0x05; // 4
	case 0x22: return 0x06; // 5
	case 0x23: return 0x07; // 6
	case 0x24: return 0x08; // 7
	case 0x25: return 0x09; // 8
	case 0x26: return 0x0a; // 9
	case 0x27: return 0x0b; // 0
	case 0x28: return 0x1c; // Return
	case 0x29: return 0x01; // ESC
	case 0x2a: return 0x0e; // Backspace
	case 0x2b: return 0x0f; // TAB
	case 0x2c: return 0x39; // Space
	case 0x2d: return 0x0c; // - and _
	case 0x2e: return 0x0d; // = and +
	case 0x2f: return 0x1a; // [ and {
	case 0x30: return 0x1b; // ] and }
	case 0x31: return 0x2b; // \ and |
	case 0x32: return 0x2b; // Non-US # and ~
	case 0x33: return 0x27; // ; and :
	case 0x34: return 0x28; // ' and "
	case 0x35: return 0x29; // ` and ~
	case 0x36: return 0x33; // ,
	case 0x37: return 0x34; // .
	case 0x38: return 0x35; // / and ?
	case 0x39: return 0x3a; // Caps-Lock
	case 0x3a: return 0x3b; // F1
	case 0x3b: return 0x3c; // F2
	case 0x3c: return 0x3d; // F3
	case 0x3d: return 0x3e; // F4
	case 0x3e: return 0x3f; // F5
	case 0x3f: return 0x40; // F6
	case 0x40: return 0x41; // F7
	case 0x41: return 0x42; // F8
	case 0x42: return 0x43; // F9
	case 0x43: return 0x44; // F10
	case 0x44: return 0x62; // F11 -> Help
	case 0x45: return 0x61; // F12 -> Undo
	case 0x47: return 0x63; // Scroll Lock -> KP (
	case 0x48: return 0x64; // Pause -> KP )
	case 0x49: return 0x52; // Insert
	case 0x4a: return 0x47; // Home -> ClrHome
	case 0x4c: return 0x53; // Delete

	case 0x4f: return 0x4d; // Right arrow
	case 0x50: return 0x4b; // Left arrow
	case 0x51: return 0x50; // Down arrow
	case 0x52: return 0x48; // Up arrow

	case 0x54: return 0x65; // Keypad /
	case 0x55: return 0x66; // Keypad *
	case 0x56: return 0x4a; // Keypad -
	case 0x57: return 0x4e; // Keypad +
	case 0x58: return 0x72; // Keypad Enter
	case 0x59: return 0x6d; // Keypad 1
	case 0x5a: return 0x6e; // Keypad 2
	case 0x5b: return 0x6f; // Keypad 3
	case 0x5c: return 0x6a; // Keypad 4
	case 0x5d: return 0x6b; // Keypad 5
	case 0x5e: return 0x6c; // Keypad 6
	case 0x5f: return 0x67; // Keypad 7
	case 0x60: return 0x68; // Keypad 8
	case 0x61: return 0x69; // Keypad 9
	case 0x62: return 0x70; // Keypad 0
	case 0x63: return 0x71; // Keypad .
	case 0x64: return 0x60; // Non-US \ and |

	default:
		return 0;
	}
}

void
kbd_int (void)
{
	int i, j;
	long actlen = 0;
	long r;
	unsigned char temp, temp2 = 0;
	static long capslock_interval = 0L; /* time interval between CAPS LOCK state check (in 40ms slices) */
	static int skip_cycle = 0; /* call half the time to save CPU time (normally called each 20ms, now 40ms) */
	long capslock_state;

	if (kbd_data.pusb_dev == NULL)
		return;

	skip_cycle = skip_cycle?0:1;
	if (skip_cycle)
		return;

	/* Synchronize caps lock state with caps lock LED, every second, in case another keyboard changed the state */
	if (capslock_interval < 25L)
	{
		capslock_interval++;
	}
	else
	{
		capslock_state = get_capslock_state();
		if (capslock_state == 0L && led_state == 1L)
			set_led(0L);
		else if (capslock_state == 1L && led_state == 0L)
			set_led(1L);
		capslock_interval = 0L;
	}

	r = usb_bulk_msg (kbd_data.pusb_dev,
					  kbd_data.irqpipe,
					  &kbd_data.newdata,
					  kbd_data.irqmaxp > 8 ? 8 : kbd_data.irqmaxp,
					  &actlen, USB_CNTL_TIMEOUT * 5, 1);

	if ((r != 0) || (actlen < 3) || (actlen > 8))
	{
		return;
	}

	for (i = actlen; i < 8; i++)
	{
		/* will also zero mod and reserved fields if required */
		kbd_data.newdata.keys[i-2] = 0;
	}

	/* Handle modifier keys first */
	DEBUG(("m: %02x", kbd_data.newdata.mod));
	/* Newly released modifiers */
	temp = (kbd_data.olddata.mod ^ kbd_data.newdata.mod) & kbd_data.olddata.mod;
	handle_modifiers(temp, 0x80);
	/* Newly pressed modifiers */
	temp = (kbd_data.olddata.mod ^ kbd_data.newdata.mod) & kbd_data.newdata.mod;
	handle_modifiers(temp, 0x00);

	/* Check for released keys */
	for (i=0; i<sizeof(kbd_data.olddata.keys); i++) {

		temp = kbd_data.olddata.keys[i];
		if (!temp)
			continue;

		for (j=0; j<sizeof(kbd_data.newdata.keys); j++) {
			if (kbd_data.newdata.keys[j] == temp)
				break;
		}

		/* Key from olddata not found in newdata =>  handle release */
		if (j == sizeof(kbd_data.newdata.keys)) {
			switch(temp)
			{
				case 0x4d :			// End
					SEND_SCAN(0x47 + 0x80); // Home release
					SEND_SCAN(0x2a + 0x80);	// Shift release
					break;
				case 0x4b :			// Page Up
					SEND_SCAN(0x48 + 0x80); // Arrow Up release
					SEND_SCAN(0x2a + 0x80);	// Shift release
					break;
				case 0x4e :			// Page Down
					SEND_SCAN(0x50 + 0x80); // Arrow Down release
					SEND_SCAN(0x2a + 0x80);	// Shift release
					break;
				case 0x46 :			// Print Screen
					SEND_SCAN(0x62 + 0x80); // Help release
					SEND_SCAN(0x38 + 0x80);	// Alt release
					break;
				default :
					temp2 = translate_key(temp);
					if (temp2)
						SEND_SCAN(temp2 + 0x80);
					break;
			}
		}
	}

	/* Check for pressed keys */
	for (i=0; i<sizeof(kbd_data.newdata.keys); i++) {

		temp = kbd_data.newdata.keys[i];
		if (!temp)
			continue;

		for (j=0; j<sizeof(kbd_data.olddata.keys); j++) {
			if (kbd_data.olddata.keys[j] == temp)
				break;
		}

		/* Key from newdata not found in olddata =>  handle press */
		if (j == sizeof(kbd_data.olddata.keys)) {
			DEBUG(("p: %02x -> %02x", temp, temp2));
			/* Special cases */
			switch(temp)
			{
				case 0x4d : 			// End
					SEND_SCAN(0x2a);	// Shift press
					SEND_SCAN(0x47); 	// Home
					break;
				case 0x4b : 			// Page Up
					SEND_SCAN(0x2a);	// Shift press
					SEND_SCAN(0x48); 	// Arrow Up
					break;
				case 0x4e :			// Page Down
					SEND_SCAN(0x2a);	// Shift press
					SEND_SCAN(0x50); 	// Arrow Down
					break;
				case 0x46 :			// Print Screen
					SEND_SCAN(0x38);	// Alt press
					SEND_SCAN(0x62); 	// Help Down
					break;
				case 0x39 :			// Caps Lock
					set_led(led_state?0L:1L);
				default:
					temp2 = translate_key(temp);
					if (temp2)
						SEND_SCAN(temp2);
					break;
			}
		}
	}

	fake_hwint();
	kbd_data.olddata = kbd_data.newdata;
}

/* Set Caps Lock LED */
#define CAPS_LOCK 0x02
static void
set_led (long state)
{
	long rc;
	unsigned char led_keys = (state)?CAPS_LOCK:0;

	rc = usb_control_msg(kbd_data.pusb_dev, usb_sndctrlpipe(kbd_data.pusb_dev, 0),
					USB_REQ_SET_REPORT,
					USB_TYPE_CLASS | USB_RECIP_INTERFACE,
					0x0200, if_no, &led_keys, 1, USB_CNTL_TIMEOUT * 5);

	if (rc != -1L)
		led_state = state;
}

/* Returns 1 if engaged */
static long get_capslock_state(void)
{
	if (Kbstate() & 0x10L)
		return 1L;
	else
		return 0L;
}

#ifndef TOSONLY
void
kbd_poll (PROC * proc, long dummy)
{
	wake (WAIT_Q, (long) &kbd_poll_thread);
}

void
kbd_poll_thread (void *dummy)
{
	p_setpriority(0,0,-20);

	while (kbd_data.pusb_dev)
	{
		kbd_int ();
		addroottimeout (20, kbd_poll, 0);
		sleep (WAIT_Q, (long) &kbd_poll_thread);
	}

	kthread_exit (0);
}
#endif

/*******************************************************************************
 *
 *
 */
static long
kbd_probe (struct usb_device *dev, unsigned int ifnum)
{
	struct usb_interface *iface;
	struct usb_endpoint_descriptor *ep_desc;

	/*
	 * Only one keyboard at time
	 */
	if (kbd_data.pusb_dev)
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
	if_no = ifnum;
	if (!iface)
	{
		return -1;
	}
	if (iface->desc.bInterfaceClass != USB_CLASS_HID && (iface->desc.bInterfaceSubClass != USB_SUB_HID_BOOT))
	{
		return -1;
	}
	if (iface->desc.bInterfaceProtocol != 1)
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
		kbd_data.ep_int =
			ep_desc->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK;
		kbd_data.irqinterval = ep_desc->bInterval;
	}
	else
	{
		return -1;
	}

	kbd_data.pusb_dev = dev;

	kbd_data.irqinterval =
		(kbd_data.irqinterval > 0) ? kbd_data.irqinterval : 255;
	kbd_data.irqpipe =
		usb_rcvintpipe (kbd_data.pusb_dev, (long) kbd_data.ep_int);
	kbd_data.irqmaxp = usb_maxpacket (dev, kbd_data.irqpipe);
	dev->irq_handle = usb_kbd_irq;
	memset (&kbd_data.newdata, 0, sizeof(kbd_data.newdata));
	memset (&kbd_data.olddata, 0, sizeof(kbd_data.olddata));

	usb_set_idle (dev, iface->desc.bInterfaceNumber, 0, 0);	/* report
								 * infinite
								 */
	usb_set_protocol(dev, iface->desc.bInterfaceNumber, 0); /* boot */
	set_led(0L);

#ifndef TOSONLY
	long r = kthread_create (get_curproc (), kbd_poll_thread, NULL, NULL,
							 "keyboardpoll");

	if (r)
	{
		return -1;
	}
#endif

	return 0;
}

static long
p_kbshift_init(void)
{
	OSHEADER *os_header = (*sysbase)->os_beg;

	if (os_header->os_version == 0x0100)
		p_kbshift = (char *)0xe1bL;
	else
		p_kbshift = (char *)(os_header->pkbshift);

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
	unsigned short tosversion;

#ifndef TOSONLY
	kentry = k;
	api = uapi;

	if (check_kentry_version ())
		return -1;
#endif

	c_conws (MSG_BOOT);
	c_conws (MSG_GREET);
	DEBUG (("%s: enter init", __FILE__));

	/*
	 * This driver uses the extended KBDVECS structure, if available.
	 * Since it's undocumented (though present in TOS2/3/4), there is no
	 * Atari-specified method to determine if it is available.  We use
	 * the version in the OSHEADER structure to discriminate.
	 * Note that EmuTOS will always support the extended KBDVECS structure.
	 */
	tosversion = get_tos_version();
	if (tosversion < 0x0200)
	{
		if (!getcookie(COOKIE_KINJ, &kbd_entry)) {
			c_conws ("With TOS 1.x KBDINJ.PRG is required!\r\n");
			return -1;
		}
	}
	else
	{
		long* vector = (long *) b_kbdvbase ();
		kbd_entry = vector[-1];
	}

#ifdef TOSONLY
	/*
	 * GET _USB COOKIE to REGISTER
	 */
	if (!getcookie (_USB, (long *)&api))
	{
		(void) Cconws ("KEYBOARD failed to get _USB cookie\r\n");
		return -1;
	}
#endif

	ret = udd_register (&kbd_uif);

	if (ret)
	{
		DEBUG (("%s: udd register failed!", __FILE__));
		return 1;
	}

	DEBUG (("%s: udd register ok", __FILE__));

	iokbd = (void *) b_uiorec (1);

	b_supexec(p_kbshift_init, 0L, 0L, 0L, 0L, 0L);
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
	c_conws ("USB keyboard driver installed");
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
