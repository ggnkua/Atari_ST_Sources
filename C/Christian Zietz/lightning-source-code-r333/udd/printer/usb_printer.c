/*
 * USB printer driver
 *
 * Copyright (C) 2018 by Claude Labelle
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See /COPYING.GPL for details.
 *
 * Thanks to:
 * For development assistance: Roger Burrows, David Galvez, Thorsten Otto
 * For thorough testing: Kroll
 * For idea of parallel port capture: simonsunnyboy
 */
#include "usb_printer.h"
#include "../../global.h"

#include "../../usb.h"
#include "../../usb_api.h"

#ifdef TOSONLY
#define MSG_VERSION "TOS DRIVERS"
#else
#define MSG_VERSION "FreeMiNT DRIVERS"
#endif

#define MSG_BUILDDATE	__DATE__

#ifdef TOSONLY
#define MSG_BOOT	\
		"\r\n\033p USB printer class driver " MSG_VERSION " \033q\r\n"
#define MSG_GREET	\
		"by Claude Labelle.\r\n" \
		"Compiled " MSG_BUILDDATE ".\r\n"
#else
#define MSG_BOOT	\
		"\033p USB printer class driver " MSG_VERSION " \033q\r\n"
#define MSG_GREET	\
		"by Claude Labelle.\r\n" \
		"Compiled " MSG_BUILDDATE ".\r\n\r\n"
#endif

//#define TEST
//#define DEBUGTOS

/****************************************************************************/
/*
 * BEGIN kernel interface
 */

#ifndef TOSONLY
struct kentry *kentry;
#else
extern unsigned long _PgmSize;
int isHddriverModule(void); /* in entry.S */
#endif

struct usb_module_api *api;

#define BCOSTAT0 ((volatile unsigned long *)0x55eL)
#define BCONOUT0 ((volatile unsigned long *)0x57eL)

volatile unsigned long original_bcostat;
volatile unsigned long original_bconout;

static long printer_bcostat(ushort dev);
static long printer_bconout(ushort dev, ushort ch);

/*
 * END kernel interface
 */
/****************************************************************************/

/*
 * USB device interface
 */
#define TRANSFER_SIZE	1024
static long printer_transfer(long);
long printer_reset(void);
long printer_status(void);

static long printer_ioctl (struct uddif *, short, long);
static long printer_disconnect (struct usb_device *dev);
static long printer_probe (struct usb_device *dev, unsigned int ifnum);

static char lname[] = "USB printer class driver\0";

static struct uddif printer_uif = {
	0,                          /* *next */
	USB_API_VERSION,            /* API */
	USB_DEVICE,                 /* class */
	lname,                      /* lname */
	"printer",                    /* name */
	0,                          /* unit */
	0,                          /* flags */
	printer_probe,                /* probe */
	printer_disconnect,           /* disconnect */
	0,                          /* resrvd1 */
	printer_ioctl,                /* ioctl */
	0,                          /* resrvd2 */
};

struct prn_data
{
	struct usb_device *pusb_dev;	/* this usb_device */
	unsigned int if_no;				/* interface number */
	unsigned char ep_out;			/* endpoint out */
	unsigned long bulk_out_pipe;	/* pipe for sending data to printer */
	unsigned char max_packet_size;	/* max packet for pipe */
	unsigned char protocol;
	char buf[TRANSFER_SIZE];			/* buffer for the print data */
};

static struct prn_data prn_data;

/*
 * -------------------------------------------------------------------------
 */

/* returns -1 if successful and 0 if not */
static long
printer_bcostat(ushort dev)
{
#ifdef TEST
	Bconout(2, 'R');
	return -1L;
#endif
	//if (prn_data.pusb_dev && prn_data.pusb_dev->status == 0)
	if (prn_data.pusb_dev)
		return -1L;
	else
		return 0L;
}

/*
 * with EOJ detection
 * should it return void or long? answer: long
 * note that it returns -1 if successful and 0 if not, contrary to Compendium
 * this is for Cprnout() to work
*/
static long
printer_bconout(ushort dev, ushort ch)
{
	long chunk_len = TRANSFER_SIZE;
	static int i = 0;
	static int type = TYPE_UNKNOWN;
	static char last9[10] = "         ";
	static int jpg_count = 0; //to count jpg codes, some jpg files may have several
	/* unsigned char c1 = (ch>>8); */
	unsigned char c2 = (ch&0xff);
	prn_data.buf[i++] = c2;

	/* Remember last 9 characters */
	register char *c0 = last9;
	register char *c1 = &last9[1];
	*c0++ = *c1++;
	*c0++ = *c1++;
	*c0++ = *c1++;
	*c0++ = *c1++;
	*c0++ = *c1++;
	*c0++ = *c1++;
	*c0++ = *c1++;
	*c0++ = *c1++;
	*c0 = c2;
	
	/* Detect end of job according to type (text, PJL, PCL, PDF, JPG) */
	switch(c2)
	{
		case 0x0C : //Form Feed (text)
			if (type == TYPE_UNKNOWN)
			{
				chunk_len = i;
#ifdef TEST
				Bconout(2, 't');
#endif
			}
			break;
		case 0x1B : //Escape (PCL)
			if (type == TYPE_UNKNOWN)
				type = TYPE_PCL;
			break;
		case 'X' : //PJL
			if (strncmp(last9, PJL_CODE, 9) == 0L)
			{
				if (type == TYPE_PJL)
				{
					chunk_len = i;
#ifdef TEST
					Bconout(2, 'j');
#endif
					type = TYPE_UNKNOWN;
				}else if (type == TYPE_UNKNOWN || type == TYPE_PCL)
				{
					type = TYPE_PJL;
				}
			}
			break;
		case 'E' : //Reset (PCL)
			if (last9[7] == 0x1B && type == TYPE_PCL)
			{
				chunk_len = i;
#ifdef TEST
				Bconout(2, 'c');
#endif
				type = TYPE_UNKNOWN;
			}
			break;
		case '-' : //PDF
			if (strncmp(&last9[4], PDF_CODE, 5) == 0L && type == TYPE_UNKNOWN)
				type = TYPE_PDF;
			break;
		case 'F' : //PDF eof
			if (strncmp(&last9[4], PDF_CODE_EOF, 5) == 0L && type == TYPE_PDF)
			{
				chunk_len = i;
#ifdef TEST
				Bconout(2, 'f');
#endif
				type = TYPE_UNKNOWN;
			}
			break;
		case 0xFF : //JPG
			if (strncmp(&last9[6], JPG_CODE, 3) == 0L)
			{
				if (type == TYPE_UNKNOWN)
					type = TYPE_JPG;
				jpg_count++;
			}
			break;
		case 0xD9 : //JPG eof
			if (strncmp(&last9[7], JPG_CODE_EOF, 2) == 0L  && type == TYPE_JPG)
			{
				jpg_count--;
				if (jpg_count == 0)
				{
					chunk_len = i;
#ifdef TEST
					Bconout(2, 'g');
#endif
					type = TYPE_UNKNOWN;
				}
			}
			break;
		default:
			break;
	}

#ifdef TEST
	if (i == chunk_len)
	{
		i = 0;
	}
	return -1L;
#endif

	if (i == chunk_len)
	{
		i = 0;
		return (printer_transfer(chunk_len));
	}
	else
	{
		return -1L;
	}
}

/* 0 if error, -1 if successful */
static long
printer_transfer(long xfer_len)
{
	long act_len = 0L;
	long maxtry = 25L;
	long stat = 0L;
	char *buf_ptr = prn_data.buf;
#ifdef DEBUGTOS
	static long xfer_no = 0L;
	xfer_no++;
#endif

	if (! prn_data.pusb_dev)
		return 0L;

	do
	{
		usb_bulk_msg (prn_data.pusb_dev,
					  prn_data.bulk_out_pipe,
					  buf_ptr,
					  xfer_len,
					  &act_len, // actual length of data transferred
					  60000L, 0); // 60 seconds timeout
		if (prn_data.pusb_dev->status != 0)
		{
#ifdef DEBUGTOS
			c_conws("\r\n xfer_no: ");
			hex_long(xfer_no);
			c_conws(", device status: ");
			hex_long(prn_data.pusb_dev->status);
			c_conws(", xfer_len: ");
			hex_long(xfer_len);
			c_conws(", act_len:");
			hex_long(act_len);
			c_conws(", try:");
			hex_long(25L - maxtry);
#endif
			/* Note, do not reset printer on every error */
			if (prn_data.pusb_dev->status & USB_ST_BUF_ERR)
			{
				stat = prn_data.pusb_dev->status;
				printer_reset();
				prn_data.pusb_dev->status = stat;
				if(xfer_len == act_len)
				{
					DEBUG(("bulk transferred with error %lx, but data ok", prn_data.pusb_dev->status));
					return -1L;
				}
				else
				{
					return 0L;
				}
			}
			/* if we stall, we need to clear it before we go on */
			if (prn_data.pusb_dev->status & USB_ST_STALLED)
			{
				DEBUG(("stalled ->clearing endpoint halt for pipe 0x%lx", prn_data.bulk_out_pipe));
				stat = prn_data.pusb_dev->status;
				printer_reset();
				usb_clear_halt(prn_data.pusb_dev, prn_data.bulk_out_pipe);
				prn_data.pusb_dev->status = stat;
				if(xfer_len == act_len)
				{
					DEBUG(("bulk transferred with error %lx, but data ok", prn_data.pusb_dev->status));
					return -1L;
				}
				else
					return 0L;
			}
			if (prn_data.pusb_dev->status & USB_ST_NAK_REC)
			{
				DEBUG(("Device NAKed bulk_msg"));
				return 0L;
			}
			DEBUG(("bulk transferred with error"));
			if (xfer_len == act_len)
			{
				DEBUG((" %lx, but data ok", prn_data.pusb_dev->status));
				return -1L;
			}
			/* if our try counter reaches 0, bail out */
			DEBUG((" %lx, data %ld", prn_data.pusb_dev->status, act_len));
			if(!maxtry--)
				return 0L;
		}
		/* update to show what data was transferred */
		if (act_len < 0 || act_len > xfer_len)
			act_len = 0; // in case printer reports impossible value
		xfer_len -= act_len;
		buf_ptr += act_len;
	}
	while(xfer_len);
	return -1L;
}

/*
 * reset printer. Returns -1 if error.
 * The following printer-specific defines should eventually be in usb_defs.h
 */
#define USB_REQ_GET_PORT_STATUS		0x01
#define USB_REQ_SOFT_RESET			0x02
long
printer_reset (void)
{
	usb_disable_asynch(0); //allows use of 0 timeout instead of USB_CNTL_TIMEOUT * 5
	long rc = usb_control_msg(prn_data.pusb_dev, usb_sndctrlpipe(prn_data.pusb_dev, 0),
							  USB_REQ_SOFT_RESET,
							  USB_TYPE_CLASS | USB_RECIP_INTERFACE,
							  0, prn_data.if_no, NULL, 0, 0);
	usb_disable_asynch(1);

#ifdef DEBUGTOS
	if (rc == -1)
		c_conws ("\r\n printer reset error. ");
#endif

	return rc;
}

/* gets the printer status. Returns the status or -1 if error */
long
printer_status (void)
{
	if (prn_data.protocol == 1 || prn_data.protocol == 2)
	{
		unsigned char status;
		long rc = usb_control_msg(prn_data.pusb_dev, usb_rcvctrlpipe(prn_data.pusb_dev, 0),
								  USB_REQ_GET_PORT_STATUS,
								  USB_TYPE_CLASS | USB_RECIP_INTERFACE,
								  0, prn_data.if_no, &status, 1, USB_CNTL_TIMEOUT * 5);
		if (rc == -1L)
			return -1L;
#ifdef DEBUGTOS
		c_conws ("\r\n Printer status: 0x"); //was 0x18 on xerox 6022 (online & no error)
		hex_byte(status);
#endif
		return (long) status;
	}

	return -1L; //will need to handle protocol 3 eventually
}

/*
 * --- Interface functions
 * --------------------------------------------------
 */

static long _cdecl
printer_ioctl (struct uddif *u, short cmd, long arg)
{
	return E_OK;
}

/*******************************************************************************
 *
 *
 */
static long
printer_disconnect (struct usb_device *dev)
{
	if (dev == prn_data.pusb_dev)
	{
		prn_data.pusb_dev = NULL;
		/* Restablish original bcostat/bconout to allow printing to parallel port. */
#ifdef TOSONLY
		long ret;
		if (Super((void *)1L) == 0L)
			ret = Super(0L);
		else
			ret = 0;
#endif
		*BCOSTAT0 = original_bcostat;
		*BCONOUT0 = original_bconout;
#ifdef TOSONLY
		if (ret)
			SuperToUser((void *)ret);
#endif
	}

	return 0;
}

/*******************************************************************************
 *
 *
 */

static long
printer_probe (struct usb_device *dev, unsigned int ifnum)
{
	struct usb_interface *iface;
	struct usb_endpoint_descriptor *ep_desc;
	short i;

	/*
	 * Only one printer at a time
	 */
	if (prn_data.pusb_dev)
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
#ifdef DEBUGTOS
	c_conws ("\r\ndev device class should be 0: ");
	hex_byte(dev->descriptor.bDeviceClass);
#endif

	iface = &dev->config.if_desc[ifnum];
	if (!iface)
	{
		return -1;
	}

	/* SubClass 1 is Printer, does not exist in usb_defs.h */
#ifdef DEBUGTOS
	c_conws ("\r\n interface subclass should be 1: ");
	hex_byte(iface->desc.bInterfaceSubClass);
#endif
	if (iface->desc.bInterfaceClass != USB_CLASS_PRINTER || (iface->desc.bInterfaceSubClass != 1))
	{
		return -1;
	}

	/* Protocol code. Should be 1 to 3, one in each interface supported by the printer. */
#ifdef DEBUGTOS
	c_conws ("\r\n protocol: ");
	hex_byte(iface->desc.bInterfaceProtocol);
#endif

	/*
	 We can have many endpoints, depending on protocol:
	 1: bulk-out endpoint to send data, and default control endpoint to receive status
	 2: bulk-out endpoint to send data, and bulk-in control endpoint to receive status
	 3: bulk-out endpoint to send data, and bulk-in control endpoint to receive status, and data will be transferred to and from, using 1284.4 protocol.

	 Enumerate endpoints. ep_desc is endpoint_descriptor.
	 We just care about the bulk-out endpoint, to which we will write data
	*/
	short found_endpoint = 0;
	for (i = 0; i < iface->desc.bNumEndpoints; i++) {
		ep_desc = &iface->ep_desc[i];
#ifdef DEBUGTOS
		c_conws("\r\n Found Endpoint ");
#endif
		if ((ep_desc->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) == USB_ENDPOINT_XFER_BULK) {
#ifdef DEBUGTOS
			c_conws(" of type bulk ");
#endif
			if (ep_desc->bEndpointAddress & USB_DIR_IN) {
#ifdef DEBUGTOS
				c_conws(" in.");
#endif
			}
			else {
#ifdef DEBUGTOS
				c_conws(" out.");
#endif
				prn_data.ep_out = ep_desc->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK;
				found_endpoint = 1;
			}
		}else {
#ifdef DEBUGTOS
			c_conws(" of other type.");
#endif
		}
	}

	if (! found_endpoint)
	{
		return -1;
	}

	prn_data.pusb_dev = dev;
	prn_data.if_no = ifnum;
	prn_data.protocol = iface->desc.bInterfaceProtocol;
	prn_data.bulk_out_pipe =
		usb_sndbulkpipe (prn_data.pusb_dev, (long) prn_data.ep_out);
	prn_data.max_packet_size = usb_maxpacket (prn_data.pusb_dev, prn_data.bulk_out_pipe);
#ifdef DEBUGTOS
	c_conws ("\r\n max packet size: 0x");
	hex_byte(prn_data.max_packet_size);
#endif

	/* Substitute bcostat and bconout with our own functions */
	/* to intercept all parallel port traffic and direct it to USB printer */
#ifdef TOSONLY
	long ret;
	if (Super((void *)1L) == 0L)
		ret = Super(0L);
	else
		ret = 0;
#endif
	original_bcostat = *BCOSTAT0;
	original_bconout = *BCONOUT0;
	*BCOSTAT0 = (long) printer_bcostat;
	*BCONOUT0 = (long) printer_bconout;
#ifdef TOSONLY
	if (ret)
		SuperToUser((void *)ret);
#endif
#ifdef DEBUGTOS
	c_conws ("\r\n test of printer reset... ");
	if (printer_reset() == -1L)
		c_conws ("\r\n printer reset error");
	else
		c_conws ("\r\n printer reset OK");
	c_conws ("\r\n printer probe successful. ");
	long status;
	status = printer_status();
	c_conws ("\r\n printer status: ");
	if (ret != -1L)
	{
		c_conws(status&PRINTER_NO_ERROR?"No error; ":"Error; ");
		c_conws(status&PRINTER_PAPER_EMPTY?"Paper empty; ":"Paper loaded; ");
		c_conws(status&PRINTER_ONLINE?"Online.":"Offline.");
	} else {
		c_conws("could not get status");
	}
	c_conws ("\r\n press a key... \r\n");
	Cconin();
#endif
	printer_reset();
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
	long ret;

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
		(void) Cconws ("PRINTER failed to get _USB cookie\r\n");
		return -1;
	}

#ifdef TEST
	if (Super((void *)1L) == 0L)
		ret = Super(0L);
	else
		ret = 0;
	*BCOSTAT0 = (long) printer_bcostat;
	*BCONOUT0 = (long) printer_bconout;
	if (ret)
		SuperToUser((void *)ret);
#endif

#endif
	/* setup_printer_module_api(); */
	ret = udd_register (&printer_uif);

	if (ret)
	{
		DEBUG (("%s: udd register failed!", __FILE__));
		return 1;
	}

	DEBUG (("%s: udd register ok", __FILE__));

#ifdef TOSONLY
	c_conws ("USB printer driver installed");
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
