/*
 * (C) Copyright 2001
 * Denis Peter, MPL AG Switzerland
 *
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

#include <mint/osbind.h>
#include <mint/sysvars.h>
#include <stdlib.h>
#include <string.h>
#include "pcixbios.h"
#include "mod_devicetable.h"
#include "pci_ids.h"
#include "part.h"

#ifdef PCI_XBIOS

#define in8(addr)		fast_read_mem_byte(usb_handle,addr)
#define in16r(addr)		fast_read_mem_word(usb_handle,addr)
#define in32r(addr)		fast_read_mem_longword(usb_handle,addr)
#define out8(addr,val)	write_mem_byte(usb_handle,addr,val)
#define out16r(addr,val)	write_mem_word(usb_handle,addr,val)
#define out32r(addr,val)	write_mem_longword(usb_handle,addr,val)

#else /* !PCI_XBIOS */

extern long *tab_funcs_pci;

#define in8(addr)		Fast_read_mem_byte(usb_handle,addr)
#define in16r(addr)		Fast_read_mem_word(usb_handle,addr)
#define in32r(addr)		Fast_read_mem_longword(usb_handle,addr)
#define out8(addr,val)	Write_mem_byte(usb_handle,addr,val)
#define out16r(addr,val)	Write_mem_word(usb_handle,addr,val)
#define out32r(addr,val)	Write_mem_longword(usb_handle,addr,val)

#endif /* PCI_XBIOS */

#define __u8 unsigned char
#define __u16 unsigned short
#define __u32 unsigned long
#define u8 unsigned char
#define u16 unsigned short
#define u32 unsigned long
#define uint8_t unsigned char
#define uint32_t unsigned long
#define uint16_t unsigned short

extern void kprint(const char *fmt, ...);
extern int sprintD(char *s, const char *fmt, ...);
#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
extern void board_printf(const char *fmt, ...);
#else
#define board_printf kprint
#endif

#include "usb_defs.h"

/* Everything is aribtrary */
#define USB_ALTSETTINGALLOC		4
#define USB_MAXALTSETTING		128	/* Hard limit */

#define USB_MAX_BUS           3
#define USB_MAX_DEVICE       16
#define USB_MAXCONFIG         8
#define USB_MAXINTERFACES     8
#define USB_MAXENDPOINTS     16
#define USB_MAXCHILDREN       8	/* This is arbitrary */
#define USB_MAX_HUB          16

#define USB_CNTL_TIMEOUT 100 /* 100ms timeout */

/* String descriptor */
struct usb_string_descriptor {
	unsigned char	bLength;
	unsigned char	bDescriptorType;
	unsigned short	wData[1];
} __attribute__ ((packed));

/* device request (setup) */
struct devrequest {
	unsigned char	requesttype;
	unsigned char	request;
	unsigned short	value;
	unsigned short	index;
	unsigned short	length;
} __attribute__ ((packed));

/* All standard descriptors have these 2 fields in common */
struct usb_descriptor_header {
	unsigned char	bLength;
	unsigned char	bDescriptorType;
} __attribute__ ((packed));

/* Device descriptor */
struct usb_device_descriptor {
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
struct usb_endpoint_descriptor {
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
struct usb_interface_descriptor {
	unsigned char	bLength;
	unsigned char	bDescriptorType;
	unsigned char	bInterfaceNumber;
	unsigned char	bAlternateSetting;
	unsigned char	bNumEndpoints;
	unsigned char	bInterfaceClass;
	unsigned char	bInterfaceSubClass;
	unsigned char	bInterfaceProtocol;
	unsigned char	iInterface;

	unsigned char	no_of_ep;
	unsigned char	num_altsetting;
	unsigned char	act_altsetting;

	struct usb_endpoint_descriptor ep_desc[USB_MAXENDPOINTS];
} __attribute__ ((packed));


/* Configuration descriptor information.. */
struct usb_config_descriptor {
	unsigned char	bLength;
	unsigned char	bDescriptorType;
	unsigned short	wTotalLength;
	unsigned char	bNumInterfaces;
	unsigned char	bConfigurationValue;
	unsigned char	iConfiguration;
	unsigned char	bmAttributes;
	unsigned char	MaxPower;

	unsigned char	no_of_if;	/* number of interfaces */
	struct usb_interface_descriptor if_desc[USB_MAXINTERFACES];
} __attribute__ ((packed));

enum {
	/* Maximum packet size; encoded as 0,1,2,3 = 8,16,32,64 */
	PACKET_SIZE_8   = 0,
	PACKET_SIZE_16  = 1,
	PACKET_SIZE_32  = 2,
	PACKET_SIZE_64  = 3,
};

struct usb_device {
	int	devnum;			/* Device number on USB bus */
	int	speed;			/* full/low/high */
	char mf[32];			/* manufacturer */
	char prod[32];		/* product */
	char serial[32];		/* serial number */

	/* Maximum packet size; one of: PACKET_SIZE_* */
	int maxpacketsize;
	/* one bit for each endpoint ([0] = IN, [1] = OUT) */
	unsigned int toggle[2];
	/* endpoint halts; one bit per endpoint # & direction;
	 * [0] = IN, [1] = OUT
	 */
	unsigned int halted[2];
	int epmaxpacketin[16];		/* INput endpoint specific maximums */
	int epmaxpacketout[16];		/* OUTput endpoint specific maximums */

	int configno;			/* selected config number */
	struct usb_device_descriptor descriptor; /* Device Descriptor */
	struct usb_config_descriptor config; /* config descriptor */

	int have_langid;		/* whether string_langid is valid yet */
	int string_langid;		/* language ID for strings */
	int (*irq_handle)(struct usb_device *dev);
	unsigned long irq_status;
	int irq_act_len;		/* transfered bytes */
	void *privptr;
	/*
	 * Child devices -  if this is a hub device
	 * Each instance needs its own set of data structures.
	 */
	unsigned long status;
	int act_len;			/* transfered bytes */
	int maxchild;			/* Number of ports if hub */
	int portnr;
	struct usb_device *parent;
	struct usb_device *children[USB_MAXCHILDREN];
	void *priv_hcd;
	int (*deregister)(struct usb_device *dev);

	struct usb_hub_device *hub;
	int usbnum;
};

/**********************************************************************
 * this is how the lowlevel part communicate with the outer world
 */

#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)

#ifdef CONFIG_USB_UHCI
int uhci_usb_lowlevel_init(long handle, const struct pci_device_id *ent, void **priv);
int uhci_usb_lowlevel_stop(void *priv);
int uhci_submit_bulk_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len);
int uhci_submit_control_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len, struct devrequest *setup);
int uhci_submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len, int interval);
#ifdef CONFIG_USB_INTERRUPT_POLLING
void uhci_usb_event_poll(int interrupt);
#else
void uhci_usb_enable_interrupt(int enable);
#endif /* CONFIG_USB_INTERRUPT_POLLING */
#endif /* CONFIG_USB_UHCI */

#ifdef CONFIG_USB_OHCI
int ohci_usb_lowlevel_init(long handle, const struct pci_device_id *ent, void **priv);
int ohci_usb_lowlevel_stop(void *priv);
int ohci_submit_bulk_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len);
int ohci_submit_control_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len, struct devrequest *setup);
int ohci_submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len, int interval);
#ifdef CONFIG_USB_INTERRUPT_POLLING
void ohci_usb_event_poll(int interrupt);
#else
void ohci_usb_enable_interrupt(int enable);
#endif /* CONFIG_USB_INTERRUPT_POLLING */
#endif /* CONFIG_USB_OHCI */

#ifdef CONFIG_USB_EHCI
int ehci_usb_lowlevel_init(long handle, const struct pci_device_id *ent, void **priv);
int ehci_usb_lowlevel_stop(void *priv);
int ehci_submit_bulk_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len);
int ehci_submit_control_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len, struct devrequest *setup);
int ehci_submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len, int interval);
#ifdef CONFIG_USB_INTERRUPT_POLLING
void ehci_usb_event_poll(int interrupt);
#else
void ehci_usb_enable_interrupt(int enable);
#endif /* CONFIG_USB_INTERRUPT_POLLING */
#endif /* CONFIG_USB_EHCI */

#else
#error USB Lowlevel not defined
#endif /* defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI) */

#ifdef CONFIG_USB_INTERRUPT_POLLING
void usb_event_poll(int interrupt);
#else
void usb_enable_interrupt(int enable);
#endif /* CONFIG_USB_INTERRUPT_POLLING */

#ifdef CONFIG_USB_STORAGE
#define USB_MAX_STOR_DEV 5
block_dev_desc_t *usb_stor_get_dev(int index);
int usb_stor_scan(void);
int usb_stor_info(void);
int usb_stor_register(struct usb_device *dev);
int usb_stor_deregister(struct usb_device *dev);
#endif

#ifdef CONFIG_USB_KEYBOARD
int drv_usb_kbd_init(void);
int usb_kbd_register(struct usb_device *dev);
int usb_kbd_deregister(struct usb_device *dev);
#endif

#ifdef CONFIG_USB_MOUSE
int drv_usb_mouse_init(void);
int usb_mouse_register(struct usb_device *dev);
int usb_mouse_deregister(struct usb_device *dev);
#endif

extern char usb_error_str[256];

/* memory */
void *usb_malloc(long amount);
int usb_free(void *addr);
int usb_mem_init(void);
void usb_mem_stop(void);

/* routines */
int usb_init(long handle, const struct pci_device_id *ent); /* initialize the USB Controller */
int usb_stop(void); /* stop the USB Controller */

int usb_set_protocol(struct usb_device *dev, int ifnum, int protocol);
int usb_set_idle(struct usb_device *dev, int ifnum, int duration, int report_id);
struct usb_device *usb_get_dev_index(int index, int bus);
int usb_control_msg(struct usb_device *dev, unsigned int pipe, unsigned char request, unsigned char requesttype, unsigned short value, 
 unsigned short index, void *data, unsigned short size, int timeout);
int usb_bulk_msg(struct usb_device *dev, unsigned int pipe, void *data, int len, int *actual_length, int timeout);
int usb_submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len, int interval);
void usb_disable_asynch(int disable);
int usb_maxpacket(struct usb_device *dev, unsigned long pipe);
inline void wait_ms(unsigned long ms);
int usb_get_configuration_no(struct usb_device *dev, unsigned char *buffer, int cfgno);
int usb_get_report(struct usb_device *dev, int ifnum, unsigned char type, unsigned char id, void *buf, int size);
int usb_get_class_descriptor(struct usb_device *dev, int ifnum, unsigned char type, unsigned char id, void *buf, int size);
int usb_clear_halt(struct usb_device *dev, int pipe);
int usb_string(struct usb_device *dev, int index, char *buf, size_t size);
int usb_set_interface(struct usb_device *dev, int interface, int alternate);

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

#define swap_16(x) __swap_16(x)
#define swap_32(x) __swap_32(x)

extern unsigned short swap_short(unsigned short val);
extern unsigned long swap_long(unsigned long val);

#define le16_to_cpu cpu_to_le16
#define le32_to_cpu cpu_to_le32
#define cpu_to_be32(a) a 

static inline unsigned short cpu_to_le16(unsigned short val)
{
	return(swap_short(val));
}
static inline unsigned long cpu_to_le32(unsigned long val)
{
	return(swap_long(val));
}

static inline void le16_to_cpus(unsigned short *val)
{
	*val = le16_to_cpu(*val);
}
static inline void le32_to_cpus(unsigned long *val)
{
	*val = le32_to_cpu(*val);
}

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

#define usb_pipeout(pipe)	((((pipe) >> 7) & 1) ^ 1)
#define usb_pipein(pipe)	(((pipe) >> 7) & 1)
#define usb_pipedevice(pipe)	(((pipe) >> 8) & 0x7f)
#define usb_pipe_endpdev(pipe)	(((pipe) >> 8) & 0x7ff)
#define usb_pipeendpoint(pipe)	(((pipe) >> 15) & 0xf)
#define usb_pipedata(pipe)	(((pipe) >> 19) & 1)
#define usb_pipespeed(pipe)	(((pipe) >> 26) & 3)
#define usb_pipeslow(pipe)	(usb_pipespeed(pipe) == USB_SPEED_LOW)
#define usb_pipetype(pipe)	(((pipe) >> 30) & 3)
#define usb_pipeisoc(pipe)	(usb_pipetype((pipe)) == PIPE_ISOCHRONOUS)
#define usb_pipeint(pipe)	(usb_pipetype((pipe)) == PIPE_INTERRUPT)
#define usb_pipecontrol(pipe)	(usb_pipetype((pipe)) == PIPE_CONTROL)
#define usb_pipebulk(pipe)	(usb_pipetype((pipe)) == PIPE_BULK)


/*************************************************************************
 * Hub Stuff
 */
struct usb_port_status {
	unsigned short wPortStatus;
	unsigned short wPortChange;
} __attribute__ ((packed));

struct usb_hub_status {
	unsigned short wHubStatus;
	unsigned short wHubChange;
} __attribute__ ((packed));


/* Hub descriptor */
struct usb_hub_descriptor {
	unsigned char  bLength;
	unsigned char  bDescriptorType;
	unsigned char  bNbrPorts;
	unsigned short wHubCharacteristics;
	unsigned char  bPwrOn2PwrGood;
	unsigned char  bHubContrCurrent;
	unsigned char  DeviceRemovable[(USB_MAXCHILDREN+1+7)/8];
	unsigned char  PortPowerCtrlMask[(USB_MAXCHILDREN+1+7)/8];
	/* DeviceRemovable and PortPwrCtrlMask want to be variable-length
	   bitmaps that hold max 255 entries. (bit0 is ignored) */
} __attribute__ ((packed));


struct usb_hub_device {
	struct usb_device *pusb_dev;
	struct usb_hub_descriptor desc;
};

#endif /*_USB_H_ */
