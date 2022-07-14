/*
 * Modified for the FreeMiNT USB subsystem by David Galvez. 2010 - 2015
 * Modified for Atari by Didier Mequignon 2009
 *	
 * (C) Copyright 2001
 * Denis Peter, MPL AG Switzerland
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 *
 * Note: Part of this code has been derived from linux
 *
 */

#ifndef _USB_H_
#define _USB_H_

#include "usb_defs.h"

/* Everything is arbitrary */
#define USB_ALTSETTINGALLOC		4
#define USB_MAXALTSETTING		128	/* Hard limit */

#if !defined(USB_MAX_DEVICE)
#define USB_MAX_DEVICE			32
#endif
#define USB_MAXCONFIG			8
#define USB_MAXINTERFACES		8
#define USB_MAXENDPOINTS		16
#define USB_MAXCHILDREN			8	/* This is arbitrary */
#define USB_MAX_HUB			16

#define USB_CNTL_TIMEOUT 		100	/* 100ms timeout */
#define USB_BUFSIZ			512

#if !defined(USB_CONFIG_BUFFER_SIZE)
#define USB_CONFIG_BUFFER_SIZE 65536
#endif

/*
 * This is the timeout to allow for submitting a message in ms.
 * We allow more time for a BULK device to react - some are slow.
 */
#define USB_TIMEOUT_MS(pipe) (usb_pipebulk(pipe) ? 5000 : 1000)

/* String descriptor */
struct usb_string_descriptor
{
	unsigned char	bLength;
	unsigned char	bDescriptorType;
	unsigned short	wData[1];
} __attribute__ ((packed));

/* device request (setup) */
struct devrequest
{
	unsigned char	requesttype;
	unsigned char	request;
	unsigned short	value;
	unsigned short	index;
	unsigned short	length;
} __attribute__ ((packed));

/* All standard descriptors have these 2 fields in common */
struct usb_descriptor_header
{
	unsigned char	bLength;
	unsigned char	bDescriptorType;
} __attribute__ ((packed));

/* Device descriptor */
struct usb_device_descriptor
{
	unsigned char	bLength;
	unsigned char	bDescriptorType;
	unsigned short	bcdUSB;
	unsigned char	bDeviceClass;
	unsigned char	bDeviceSubClass;
	unsigned char	bDeviceProtocol;
	unsigned char	bMaxPacketSize0;
	unsigned short	idVendor;
	unsigned short	idProduct;
	unsigned short	bcdDevice;
	unsigned char	iManufacturer;
	unsigned char	iProduct;
	unsigned char	iSerialNumber;
	unsigned char	bNumConfigurations;
} __attribute__ ((packed));

/* Endpoint descriptor */
struct usb_endpoint_descriptor
{
	unsigned char	bLength;
	unsigned char	bDescriptorType;
	unsigned char	bEndpointAddress;
	unsigned char	bmAttributes;
	unsigned short	wMaxPacketSize;
	unsigned char	bInterval;
	unsigned char	bRefresh;
	unsigned char	bSynchAddress;
} __attribute__ ((packed)) __attribute__ ((aligned(2)));

/* Interface descriptor */
struct usb_interface_descriptor
{
	unsigned char	bLength;
	unsigned char	bDescriptorType;
	unsigned char	bInterfaceNumber;
	unsigned char	bAlternateSetting;
	unsigned char	bNumEndpoints;
	unsigned char	bInterfaceClass;
	unsigned char	bInterfaceSubClass;
	unsigned char	bInterfaceProtocol;
	unsigned char	iInterface;
} __attribute__ ((packed));

/* USB_DT_SS_ENDPOINT_COMP: SuperSpeed Endpoint Companion descriptor */
struct usb_ss_ep_comp_descriptor {
	unsigned char  bLength;
	unsigned char bDescriptorType;

	unsigned char  bMaxBurst;
	unsigned char  bmAttributes;
	unsigned short wBytesPerInterval;
} __attribute__ ((packed));

#define USB_DT_SS_EP_COMP_SIZE 		6

struct usb_interface {
	struct usb_interface_descriptor desc;
	struct uddif *driver;
	unsigned char	no_of_ep;
	unsigned char	num_altsetting;
	unsigned char	act_altsetting;

	struct usb_endpoint_descriptor ep_desc[USB_MAXENDPOINTS];
	/*
	 * Super Speed Device will have Super Speed Endpoint
	 * Companion Descriptor  (section 9.6.7 of usb 3.0 spec)
	 * Revision 1.0 June 6th 2011
	 */
	struct usb_ss_ep_comp_descriptor ss_ep_comp_desc[USB_MAXENDPOINTS];
};

/* Configuration descriptor information.. */
struct usb_config_descriptor
{
	unsigned char	bLength;
	unsigned char	bDescriptorType;
	unsigned short	wTotalLength;
	unsigned char	bNumInterfaces;
	unsigned char	bConfigurationValue;
	unsigned char	iConfiguration;
	unsigned char	bmAttributes;
	unsigned char	bMaxPower;
} __attribute__ ((packed));

struct usb_config {
	struct usb_config_descriptor desc;

	unsigned char	no_of_if;	/* number of interfaces */
	struct usb_interface if_desc[USB_MAXINTERFACES];
};

enum {
	/* Maximum packet size; encoded as 0,1,2,3 = 8,16,32,64 */
	PACKET_SIZE_8   = 0,
	PACKET_SIZE_16  = 1,
	PACKET_SIZE_32  = 2,
	PACKET_SIZE_64  = 3,
};

struct usb_device;

struct usb_device
{
	long	devnum;			/* Device number on USB bus */
	long	speed;			/* full/low/high */
	char	mf[32];			/* manufacturer */
	char	prod[32];		/* product */
	char	serial[32];		/* serial number */

	/* Maximum packet size; one of: PACKET_SIZE_* */
	long maxpacketsize;
	/* one bit for each endpoint ([0] = IN, [1] = OUT) */
	unsigned long toggle[2];
	/* endpoint halts; one bit per endpoint # & direction;
	 * [0] = IN, [1] = OUT
	 */
	unsigned long halted[2];
	long epmaxpacketin[16];			/* INput endpoint specific maximums */
	long epmaxpacketout[16];		/* OUTput endpoint specific maximums */

	long configno;					/* selected config number */
	struct usb_device_descriptor descriptor; 	/* Device Descriptor */
	struct usb_config config; 		/* config descriptor */

	long have_langid;		/* whether string_langid is valid yet */
	long string_langid;		/* language ID for strings */
	long (*irq_handle)(struct usb_device *dev);
	unsigned long irq_status;
	long irq_act_len;		/* transfered bytes */
	void *privptr;			/* usually (and currently only) the hub pointer */
	/*
	 * Child devices -  if this is a hub device
	 * Each instance needs its own set of data structures.
	 */
	unsigned long status;
	long act_len;			/* transfered bytes */
	long maxchild;			/* Number of ports if hub */
	long portnr;
	struct usb_device *parent;
	struct usb_device *children[USB_MAXCHILDREN];

	struct ucdif *controller;

};

/* Defines */
#define USB_UHCI_VEND_ID		0x8086
#define USB_UHCI_DEV_ID		0x7112

/* low level functions */
long 		usb_lowlevel_init		(void *ucd_priv);
long 		usb_lowlevel_stop		(void *ucd_priv);

/* routines */
void		usb_main		(void);
void 		usb_init		(void); /* initialize the USB Controller */
void 		usb_stop		(void); /* stop the USB Controller */


long		usb_set_protocol	(struct usb_device *dev, long ifnum, long protocol);
long 		usb_set_idle		(struct usb_device *dev, long ifnum, long duration,
						long report_id);
long 		usb_control_msg		(struct usb_device *dev, unsigned long pipe,
					unsigned char request, unsigned char requesttype,
					unsigned short value, unsigned short idx,
					void *data, unsigned short size, long timeout);

/* Used by drivers to early abort bulk messages. */
#define USB_BULK_FLAG_EARLY_TIMEOUT	1

long 		usb_bulk_msg		(struct usb_device *dev, unsigned long pipe,
					void *data, long len, long *actual_length, long timeout,
					long flags);
long 		usb_submit_int_msg	(struct usb_device *dev, unsigned long pipe,
					void *buffer, long transfer_len, long interval);
long 		usb_disable_asynch	(long disable);
long 		usb_maxpacket		(struct usb_device *dev, unsigned long pipe);
long 		usb_get_configuration_no(struct usb_device *dev, long cfgno);
long 		usb_get_report		(struct usb_device *dev, long ifnum, unsigned char type,
					unsigned char id, void *buf, long size);
long 		usb_get_class_descriptor(struct usb_device *dev, long ifnum,
					unsigned char type, unsigned char id, void *buf,
					long size);
long 		usb_clear_halt		(struct usb_device *dev, long pipe);
long 		usb_string		(struct usb_device *dev, long idx, char *buf, long size);
long 		usb_set_interface	(struct usb_device *dev, long interface, long alternate);
struct usb_device *	usb_get_dev_index	(long idx);
long 		usb_parse_config	(struct usb_device *dev, unsigned char *buffer, long cfgno);
long 		usb_set_maxpacket	(struct usb_device *dev);
long 		usb_get_descriptor	(struct usb_device *dev, unsigned char type,
					unsigned char idx, void *buf, long size);
long 		usb_set_address		(struct usb_device *dev);
long 		usb_set_configuration	(struct usb_device *dev, long configuration);
long 		usb_get_string		(struct usb_device *dev, unsigned short langid,
		   			unsigned char idx, void *buf, long size);
struct usb_device *	usb_alloc_new_device(void *controller);
void		usb_free_device		(long idx);
long 		usb_new_device		(struct usb_device *dev);
void		usb_disconnect		(struct usb_device *pdev);
//inline void wait_ms(unsigned long ms);
long		usb_find_interface_driver(struct usb_device *dev, unsigned ifnum);

/* big endian -> little endian conversion */
/* some CPUs are already little endian e.g. the ARM920T */
#define __swap_16(x) \
	({ unsigned short x_ = (unsigned short)x; \
	 (unsigned short)( \
		((x_ & 0x00FFU) << 8) | ((x_ & 0xFF00U) >> 8)); \
	})
#define __swap_32(x) \
	({ unsigned long x_ = (unsigned long)x; \
	 (unsigned long)( \
		((x_ & 0x000000FFUL) << 24) | \
		((x_ & 0x0000FF00UL) <<	 8) | \
		((x_ & 0x00FF0000UL) >>	 8) | \
		((x_ & 0xFF000000UL) >> 24)); \
	})

#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
# define swap_16(x) (x)
# define swap_32(x) (x)
#else
# define swap_16(x) __swap_16(x)
# define swap_32(x) __swap_32(x)
#endif

/*
 * Calling this entity a "pipe" is glorifying it. A USB pipe
 * is something embarrassingly simple: it basically consists
 * of the following information:
 *  - device number (7 bits)
 *  - endpoint number (4 bits)
 *  - current Data0/1 state (1 bit)
 *  - direction (1 bit)
 *  - speed (2 bits)
 *  - max packet size (2 bits: 8, 16, 32 or 64)
 *  - pipe type (2 bits: control, interrupt, bulk, isochronous)
 *
 * That's 18 bits. Really. Nothing more. And the USB people have
 * documented these eighteen bits as some kind of glorious
 * virtual data structure.
 *
 * Let's not fall in that trap. We'll just encode it as a simple
 * unsigned int. The encoding is:
 *
 *  - max size:		bits 0-1	(00 = 8, 01 = 16, 10 = 32, 11 = 64)
 *  - direction:	bit 7		(0 = Host-to-Device [Out],
 *					(1 = Device-to-Host [In])
 *  - device:		bits 8-14
 *  - endpoint:		bits 15-18
 *  - Data0/1:		bit 19
 *  - speed:		bit 26		(0 = Full, 1 = Low Speed, 2 = High)
 *  - pipe type:	bits 30-31	(00 = isochronous, 01 = interrupt,
 *					 10 = control, 11 = bulk)
 *
 * Why? Because it's arbitrary, and whatever encoding we select is really
 * up to us. This one happens to share a lot of bit positions with the UHCI
 * specification, so that much of the uhci driver can just mask the bits
 * appropriately.
 */
/* Create various pipes... */
#define create_pipe(dev,endpoint) \
		(((dev)->devnum << 8) | (endpoint << 15) | \
		((dev)->speed << 26) | (dev)->maxpacketsize)
#define default_pipe(dev) ((dev)->speed << 26)

#define usb_sndctrlpipe(dev, endpoint)	((PIPE_CONTROL << 30) | \
					 create_pipe(dev, endpoint))
#define usb_rcvctrlpipe(dev, endpoint)	((PIPE_CONTROL << 30) | \
					 create_pipe(dev, endpoint) | \
					 USB_DIR_IN)
#define usb_sndisocpipe(dev, endpoint)	((PIPE_ISOCHRONOUS << 30) | \
					 create_pipe(dev, endpoint))
#define usb_rcvisocpipe(dev, endpoint)	((PIPE_ISOCHRONOUS << 30) | \
					 create_pipe(dev, endpoint) | \
					 USB_DIR_IN)
#define usb_sndbulkpipe(dev, endpoint)	((PIPE_BULK << 30) | \
					 create_pipe(dev, endpoint))
#define usb_rcvbulkpipe(dev, endpoint)	((PIPE_BULK << 30) | \
					 create_pipe(dev, endpoint) | \
					 USB_DIR_IN)
#define usb_sndintpipe(dev, endpoint)	((PIPE_INTERRUPT << 30) | \
					 create_pipe(dev, endpoint))
#define usb_rcvintpipe(dev, endpoint)	((PIPE_INTERRUPT << 30) | \
					 create_pipe(dev, endpoint) | \
					 USB_DIR_IN)
#define usb_snddefctrl(dev)		((PIPE_CONTROL << 30) | \
					 default_pipe(dev))
#define usb_rcvdefctrl(dev)		((PIPE_CONTROL << 30) | \
					 default_pipe(dev) | \
					 USB_DIR_IN)

/* The D0/D1 toggle bits */
#define usb_gettoggle(dev, ep, out) (((dev)->toggle[out] >> ep) & 1)
#define usb_dotoggle(dev, ep, out)  ((dev)->toggle[out] ^= (1 << ep))
#define usb_settoggle(dev, ep, out, bit) ((dev)->toggle[out] = \
						((dev)->toggle[out] & \
						 ~(1 << ep)) | ((bit) << ep))

/* Endpoint halt control/status */
#define usb_endpoint_out(ep_dir)	(((ep_dir >> 7) & 1) ^ 1)
#define usb_endpoint_halt(dev, ep, out) ((dev)->halted[out] |= (1 << (ep)))
#define usb_endpoint_running(dev, ep, out) ((dev)->halted[out] &= ~(1 << (ep)))
#define usb_endpoint_halted(dev, ep, out) ((dev)->halted[out] & (1 << (ep)))

#define usb_packetid(pipe)	(((pipe) & USB_DIR_IN) ? USB_PID_IN : \
				 USB_PID_OUT)

#define usb_pipeout(pipe)	((((pipe) >> 7) & 1UL) ^ 1)
#define usb_pipein(pipe)	(((pipe) >> 7) & 1UL)
#define usb_pipedevice(pipe)	(((pipe) >> 8) & 0x7fUL)
#define usb_pipe_endpdev(pipe)	(((pipe) >> 8) & 0x7ffUL)
#define usb_pipeendpoint(pipe)	(((pipe) >> 15) & 0xfUL)
#define usb_pipedata(pipe)	(((pipe) >> 19) & 1UL)
#define usb_pipespeed(pipe)	(((pipe) >> 26) & 3UL)
#define usb_pipeslow(pipe)	(usb_pipespeed(pipe) == USB_SPEED_LOW)
#define usb_pipetype(pipe)	(((pipe) >> 30) & 3UL)
#define usb_pipeisoc(pipe)	(usb_pipetype((pipe)) == PIPE_ISOCHRONOUS)
#define usb_pipeint(pipe)	(usb_pipetype((pipe)) == PIPE_INTERRUPT)
#define usb_pipecontrol(pipe)	(usb_pipetype((pipe)) == PIPE_CONTROL)
#define usb_pipebulk(pipe)	(usb_pipetype((pipe)) == PIPE_BULK)


#endif /*_USB_H_ */
