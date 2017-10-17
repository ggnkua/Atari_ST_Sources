/*
 * (C) Copyright 2001
 * Denis Peter, MPL AG Switzerland
 *
 * Most of this source has been derived from the Linux USB
 * project.
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 *
 */

#include "config.h"
#include <stdarg.h>
#include "usb.h"

#undef RESET_START_STOP_CMDS
#undef CONFIG_USB_STORAGE

#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)

#ifdef CONFIG_USB_STORAGE
extern int usb_stor_curr_dev; /* current device */
#endif

#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
extern long pxCurrentTCB, tid_TOS;
// #define info(format, arg...) do { if(pxCurrentTCB == tid_TOS) kprint(format, ## arg); else board_printf(format, ## arg); } while(0)
#else
#define info(format, arg...) kprint(format, ## arg)
#endif

#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)

typedef struct
{
    int dest;
    void (*func)(char);
    char *loc;
} PRINTK_INFO;

#define DEST_CONSOLE    (1)
#define DEST_STRING     (2)

extern int printk(PRINTK_INFO *info, const char *fmt, va_list ap);

static void info(const char *const fmt, ...)
{
	va_list ap;
	PRINTK_INFO info;
	static char buf[1024];
	info.dest = DEST_STRING;
	info.loc = buf;
	va_start(ap, fmt);
	printk(&info, fmt, ap);
	*info.loc = '\0';
	if(pxCurrentTCB == tid_TOS)
		kprint(buf);
	else
		board_printf(buf);
	va_end(ap);
}

#endif /* defined(COLDFIRE) && defined(NETWORK) && defined(LWIP) */

/* some display routines (info command) */
char *usb_get_class_desc(unsigned char dclass)
{
	switch (dclass)
	{
		case USB_CLASS_PER_INTERFACE: return "See Interface";
		case USB_CLASS_AUDIO: return "Audio";
		case USB_CLASS_COMM: return "Communication";
		case USB_CLASS_HID: return "Human Interface";
		case USB_CLASS_PRINTER: return "Printer";
		case USB_CLASS_MASS_STORAGE: return "Mass Storage";
		case USB_CLASS_HUB: return "Hub";
		case USB_CLASS_DATA: return "CDC Data";
		case USB_CLASS_VENDOR_SPEC: return "Vendor specific";
		default: return "";
	}
}

void usb_display_class_sub(unsigned char dclass, unsigned char subclass, unsigned char proto)
{
	switch(dclass)
	{
		case USB_CLASS_PER_INTERFACE:
			info("See Interface");
			break;
		case USB_CLASS_HID:
			info("Human Interface, Subclass: ");
			switch(subclass)
			{
				case USB_SUB_HID_NONE: info("None"); break;
				case USB_SUB_HID_BOOT:
					info("Boot ");
					switch(proto)
					{
						case USB_PROT_HID_NONE: info("None"); break;
						case USB_PROT_HID_KEYBOARD: info("Keyboard"); break;
						case USB_PROT_HID_MOUSE: info("Mouse"); break;
						default: info("reserved"); break;
					}
					break;
				default: info("reserved"); break;
			}
			break;
		case USB_CLASS_MASS_STORAGE:
			info("Mass Storage, ");
			switch(subclass)
			{
				case US_SC_RBC: info("RBC "); break;
				case US_SC_8020: info("SFF-8020i (ATAPI)"); break;
				case US_SC_QIC: info("QIC-157 (Tape)"); break;
				case US_SC_UFI: info("UFI"); break;
				case US_SC_8070: info("SFF-8070"); break;
				case US_SC_SCSI: info("Transp. SCSI"); break;
				default: info("reserved"); break;
			}
			info(", ");
			switch (proto)
			{
				case US_PR_CB: info("Command/Bulk"); break;
				case US_PR_CBI: info("Command/Bulk/Int"); break;
				case US_PR_BULK: info("Bulk only"); break;
				default: info("reserved"); break;
			}
			break;
		default: info("%s", usb_get_class_desc(dclass)); break;
	}
}

void usb_display_string(struct usb_device *dev, int index)
{
	char buffer[256];
	if(index != 0)
	{
		if(usb_string(dev, index, &buffer[0], 256) > 0)
			info("String: \"%s\"", buffer);
	}
}

void usb_display_desc(struct usb_device *dev)
{
	if(dev->descriptor.bDescriptorType == USB_DT_DEVICE)
	{
		info("%d: %s,  USB Revision %x.%x\r\n", dev->devnum, usb_get_class_desc(dev->config.if_desc[0].bInterfaceClass), (dev->descriptor.bcdUSB>>8) & 0xff, dev->descriptor.bcdUSB & 0xff);
		if(strlen(dev->mf) || strlen(dev->prod) || strlen(dev->serial))
			info(" - %s %s %s\r\n", dev->mf, dev->prod, dev->serial);
		if(dev->descriptor.bDeviceClass)
		{
			info(" - Class: ");
			usb_display_class_sub(dev->descriptor.bDeviceClass, dev->descriptor.bDeviceSubClass, dev->descriptor.bDeviceProtocol);
			info("\r\n");
		}
		else
			info(" - Class: (from Interface) %s\r\n", usb_get_class_desc(dev->config.if_desc[0].bInterfaceClass));
		info(" - PacketSize: %d  Configurations: %d\r\n",
			dev->descriptor.bMaxPacketSize0,
			dev->descriptor.bNumConfigurations);
		info(" - Vendor: 0x%04x  Product 0x%04x Version %d.%d\r\n", dev->descriptor.idVendor, dev->descriptor.idProduct, (dev->descriptor.bcdDevice>>8) & 0xff, dev->descriptor.bcdDevice & 0xff);
	}
}

void usb_display_conf_desc(struct usb_config_descriptor *config, struct usb_device *dev)
{
	info("   Configuration: %d\r\n", config->bConfigurationValue);
	info("   - Interfaces: %d %s%s%dmA\r\n", config->bNumInterfaces, (config->bmAttributes & 0x40) ? "Self Powered " : "Bus Powered ", (config->bmAttributes & 0x20) ? "Remote Wakeup " : "", config->MaxPower*2);
	if(config->iConfiguration)
	{
		info("   - ");
		usb_display_string(dev, config->iConfiguration);
		info("\r\n");
	}
}

void usb_display_if_desc(struct usb_interface_descriptor *ifdesc, struct usb_device *dev)
{
	info("     Interface: %d\r\n", ifdesc->bInterfaceNumber);
	info("     - Alternate Setting %d, Endpoints: %d\r\n", ifdesc->bAlternateSetting, ifdesc->bNumEndpoints);
	info("     - Class ");
	usb_display_class_sub(ifdesc->bInterfaceClass, ifdesc->bInterfaceSubClass, ifdesc->bInterfaceProtocol);
	info("\r\n");
	if(ifdesc->iInterface)
	{
		info("     - ");
		usb_display_string(dev, ifdesc->iInterface);
		info("\r\n");
	}
}

void usb_display_ep_desc(struct usb_endpoint_descriptor *epdesc)
{
	info("     - Endpoint %d %s ", epdesc->bEndpointAddress & 0xf, (epdesc->bEndpointAddress & 0x80) ? "In" : "Out");
	switch((epdesc->bmAttributes & 0x03))
	{
		case 0: info("Control"); break;
		case 1: info("Isochronous"); break;
		case 2: info("Bulk"); break;
		case 3: info("Interrupt"); break;
	}
	info(" MaxPacket %d", epdesc->wMaxPacketSize);
	if((epdesc->bmAttributes & 0x03) == 0x3)
		info(" Interval %dms", epdesc->bInterval);
	info("\r\n");
}

/* main routine to diasplay the configs, interfaces and endpoints */
void usb_display_config(struct usb_device *dev)
{
	struct usb_config_descriptor *config;
	struct usb_interface_descriptor *ifdesc;
	struct usb_endpoint_descriptor *epdesc;
	int i, ii;
	config = &dev->config;
	usb_display_conf_desc(config, dev);
	for(i = 0; i < config->no_of_if; i++)
	{
		ifdesc = &config->if_desc[i];
		usb_display_if_desc(ifdesc, dev);
		for(ii = 0; ii < ifdesc->no_of_ep; ii++)
		{
			epdesc = &ifdesc->ep_desc[ii];
			usb_display_ep_desc(epdesc);
		}
	}
	info("\r\n");
}

static inline char *portspeed(int speed)
{
	if(speed == USB_SPEED_HIGH)
		return "480 Mb/s";
	else if(speed == USB_SPEED_LOW)
		return "1.5 Mb/s";
	else
		return "12 Mb/s";
}

/* shows the device tree recursively */
void usb_show_tree_graph(struct usb_device *dev, char *pre)
{
	int i, index;
	int has_child, last_child, port;
	index = strlen(pre);
	info(" %s", pre);
	/* check if the device has connected children */
	has_child = 0;
	for(i = 0; i < dev->maxchild; i++)
	{
		if(dev->children[i] != NULL)
			has_child = 1;
	}
	/* check if we are the last one */
	last_child = 1;
	if(dev->parent != NULL)
	{
		for(i = 0; i < dev->parent->maxchild; i++)
		{
			/* search for children */
			if(dev->parent->children[i] == dev)
			{
				/* found our pointer, see if we have a little sister */
				port = i;
				while(i++ < dev->parent->maxchild)
				{
					if(dev->parent->children[i] != NULL)
					{
						/* found a sister */
						last_child = 0;
						break;
					} /* if */
				} /* while */
			} /* device found */
		} /* for all children of the parent */
		info("\b+-");
		/* correct last child */
		if(last_child)
			pre[index-1] = ' ';
	} /* if not root hub */
	else
		info(" ");
	info("%d ", dev->devnum);
	pre[index++] = ' ';
	pre[index++] = has_child ? '|' : ' ';
	pre[index] = 0;
	info(" %s (%s, %dmA)\r\n", usb_get_class_desc(dev->config.if_desc[0].bInterfaceClass), portspeed(dev->speed), dev->config.MaxPower * 2);
	if(strlen(dev->mf) || strlen(dev->prod) || strlen(dev->serial))
		info(" %s  %s %s %s\r\n", pre, dev->mf, dev->prod, dev->serial);
	info(" %s\r\n", pre);
	if(dev->maxchild > 0)
	{
		for(i = 0; i < dev->maxchild; i++)
		{
			if(dev->children[i] != NULL)
			{
				usb_show_tree_graph(dev->children[i], pre);
				pre[index] = 0;
			}
		}
	}
}

/* main routine for the tree command */
void usb_show_tree(struct usb_device *dev)
{
	char preamble[32];
	memset(preamble, 0, 32);
	usb_show_tree_graph(dev, &preamble[0]);
}

/******************************************************************************
 * usb command intepreter
 */
int uif_cmd_usb(int argc, char **argv)
{
	int i;
	struct usb_device *dev = NULL;
#ifdef CONFIG_USB_STORAGE
	block_dev_desc_t *stor_dev;
#endif
#ifdef RESET_START_STOP_CMDS 
	extern char usb_started;
	if((strncmp(argv[1], "reset", 5) == 0) || (strncmp(argv[1], "start", 5) == 0))
	{
		usb_stop();
		info("(Re)start USB...\r\n");
		i = usb_init(0, NULL);
#ifdef CONFIG_USB_STORAGE
		/* try to recognize storage devices immediately */
		if(i >= 0)
			usb_stor_curr_dev = usb_stor_scan();
#endif /* CONFIG_USB_STORAGE */
		return 0;
	}
	if(strncmp(argv[1], "stop", 4) == 0)
	{
#ifdef CONFIG_USB_KEYBOARD
		if(argc == 2)
		{
			if(usb_kbd_deregister() != 0)
			{
				info("USB not stopped: usbkbd still using USB\r\n");
				return 1;
			}
		}
		else /* forced stop, switch console in to serial */
			usb_kbd_deregister();
#endif /* CONFIG_USB_KEYBOARD */
		info("stopping USB..\r\n");
		usb_stop();
		return 0;
	}
	if(!usb_started)
	{
		info("USB is stopped. Please issue 'usb start' first.\r\n");
		return 1;
	}
#endif /* RESET_START_STOP_CMDS */
	if(strncmp(argv[1], "tree", 4) == 0)
	{
		info("\r\nUSB Device Tree:\r\n");
		for(i = 0; i < USB_MAX_BUS; i++)
		{
			struct usb_device *dev = usb_get_dev_index(0, i);
			if(dev == NULL)
				break;
			info(" USB controller %d:\r\n", i);
			usb_show_tree(dev);
		}
		return 0;
	}
	if(strncmp(argv[1], "inf", 3) == 0)
	{
		int b, d;
		if(argc == 2)
		{
			for(b = 0; b < USB_MAX_BUS; b++)
			{
				for(d = 0; d < USB_MAX_DEVICE; d++)
				{
					dev = usb_get_dev_index(d, b);
					if(dev == NULL)
						break;
					if(!d)
						info("USB controller %d:\r\n\n", b);
					usb_display_desc(dev);
					usb_display_config(dev);
				}
			}
			return 0;
		}
		else
		{
			int d;
			i = strtoul(argv[2], NULL, 16);
			info("config for device %d\r\n", i);
			for(d = 0; d < USB_MAX_DEVICE; d++)
			{
				dev = usb_get_dev_index(d, 0);
				if(dev == NULL)
					break;
				if(dev->devnum == i)
					break;
			}
			if(dev == NULL)
			{
				info("*** NO Device avaiable ***\r\n");
				return 0;
			}
			else
			{
				usb_display_desc(dev);
				usb_display_config(dev);
			}
		}
		return 0;
	}
#ifdef CONFIG_USB_STORAGE
	if(strncmp(argv[1], "stor", 4) == 0)
		return usb_stor_info();
	if(strcmp(argv[1], "read") == 0)
	{
		if(usb_stor_curr_dev < 0)
		{
			info("no current device selected\r\n");
			return 1;
		}
		if(argc == 5)
		{
			unsigned long addr = strtoul(argv[2], NULL, 16);
			unsigned long blk  = strtoul(argv[3], NULL, 16);
			unsigned long cnt  = strtoul(argv[4], NULL, 16);
			unsigned long n;
			info("\r\nUSB read: device %d block # %ld, count %ld ... ", usb_stor_curr_dev, blk, cnt);
			stor_dev = usb_stor_get_dev(usb_stor_curr_dev);
			n = stor_dev->block_read(usb_stor_curr_dev, blk, cnt, (unsigned long *)addr);
			info("%ld blocks read: %s\r\n", n, (n == cnt) ? "OK" : "ERROR");
			if(n == cnt)
				return 0;
			return 1;
		}
	}
	if(strncmp(argv[1], "dev", 3) == 0)
	{
		if(argc == 3)
		{
			int dev = (int)strtoul(argv[2], NULL, 10);
			info("\r\nUSB device %d: ", dev);
			if(dev >= USB_MAX_STOR_DEV)
			{
				info("unknown device\r\n");
				return 1;
			}
			info("\r\n    Device %d: ", dev);
			stor_dev = usb_stor_get_dev(dev);
			dev_print(stor_dev);
			if(stor_dev->type == DEV_TYPE_UNKNOWN)
				return 1;
			usb_stor_curr_dev = dev;
			info("... is now current device\r\n");
			return 0;
		}
		else
		{
			info("\r\nUSB device %d: ", usb_stor_curr_dev);
			stor_dev = usb_stor_get_dev(usb_stor_curr_dev);
			dev_print(stor_dev);
			if(stor_dev->type == DEV_TYPE_UNKNOWN)
				return 1;
			return 0;
		}
		return 0;
	}
	info(
#ifdef RESET_START_STOP_CMDS
	 "usb reset - reset (rescan) USB controller\r\n"
	 "usb stop [f]  - stop USB [f]=force stop\r\n"
#endif
	 "usb tree  - show USB device tree\r\n"
	 "usb info [dev] - show available USB devices\r\n"
	 "usb storage  - show details of USB storage devices\r\n"
	 "usb dev [dev] - show or set current USB storage device\r\n"
	 "usb read addr blk# cnt - read `cnt' blocks starting at block `blk#'\r\n"
	 "    to memory address `addr'\r\n");
#else /* !CONFIG_USB_STORAGE */	
	info(
#ifdef RESET_START_STOP_CMDS
	 "usb reset - reset (rescan) USB controller\r\n"
	 "usb stop [f]  - stop USB [f]=force stop\r\n"
#endif
	 "usb tree  - show USB device tree\r\n"
	 "usb info [dev] - show available USB devices\r\n");
#endif /* CONFIG_USB_STORAGE */
	return 1;
}

#endif /* CONFIG_USB_UHCI || CONFIG_USB_OHCI || CONFIG_USB_EHCI */
