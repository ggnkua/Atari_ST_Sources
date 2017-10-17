/*
 *
 * Most of this source has been derived from the Linux USB
 * project:
 * (C) Copyright Linus Torvalds 1999
 * (C) Copyright Johannes Erdfelt 1999-2001
 * (C) Copyright Andreas Gal 1999
 * (C) Copyright Gregory P. Smith 1999
 * (C) Copyright Deti Fliegl 1999 (new USB architecture)
 * (C) Copyright Randy Dunlap 2000
 * (C) Copyright David Brownell 2000 (kernel hotplug, usb_device_id)
 * (C) Copyright Yggdrasil Computing, Inc. 2000
 *     (usb_device_id matching changes by Adam J. Richter)
 *
 * Adapted for U-Boot:
 * (C) Copyright 2001 Denis Peter, MPL AG Switzerland
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

/*
 * How it works:
 *
 * Since this is a bootloader, the devices will not be automatic
 * (re)configured on hotplug, but after a restart of the USB the
 * device should work.
 *
 * For each transfer (except "Interrupt") we wait for completion.
 */

#include "config.h"
#include "usb.h"

#if defined(COLDFIRE) && defined(NETWORK) && defined(LWIP)
#include "../freertos/FreeRTOS.h"
#include "../freertos/task.h"
#include "../freertos/queue.h"
#include "../freertos/semphr.h"
#define USB_POLL_HUB
#ifdef CONFIG_USB_STORAGE
extern int usb_stor_curr_dev;
extern unsigned long usb_1st_disk_drive;
#endif
#endif

#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)

#undef USB_DEBUG

#ifdef	USB_DEBUG
#define	USB_PRINTF(fmt, args...)	board_printf(fmt , ##args)
#else
#define USB_PRINTF(fmt, args...)
#endif

#define USB_BUFSIZ	512

struct hci {
	/* ------- common part -------- */
	long handle;              /* PCI BIOS */
	const struct pci_device_id *ent;
	int usbnum;
  /* ---- end of common part ---- */
};

extern void udelay(long usec);

static struct usb_device *usb_dev; 
static int bus_index;
static int dev_index[USB_MAX_BUS];
static struct hci *controller_priv[USB_MAX_BUS];
#ifdef USB_POLL_HUB
xQueueHandle queue_poll_hub;
#endif
static int asynch_allowed;
static struct devrequest *setup_packet;

char usb_started; /* flag for the started/stopped USB status */

/**********************************************************************
 * some forward declerations...
 */
void usb_scan_devices(void *priv);

int usb_hub_probe(struct usb_device *dev, int ifnum);
void usb_hub_reset(int index_bus);
static int hub_port_reset(struct usb_device *dev, int port, unsigned short *portstat);

/***********************************************************************
 * wait_ms
 */
inline void wait_ms(unsigned long ms)
{
	while(ms-- > 0)
		udelay(1000);
}

/***************************************************************************
 * Init USB Device
 */
int usb_init(long handle, const struct pci_device_id *ent)
{
	void *priv;
	int res = 0;
	if(bus_index >= USB_MAX_BUS)
		return(-1);
	dev_index[bus_index] = 0;
	asynch_allowed = 1;
	if(handle && (ent != NULL))
	{
		if(usb_mem_init())
		{
			usb_started = 0;
			return -1; /* out of memoy */
		}
		if(usb_dev == NULL)
			usb_dev = (struct usb_device *)usb_malloc(sizeof(struct usb_device) * USB_MAX_BUS * USB_MAX_DEVICE);
		if(usb_dev == NULL)
		{
			usb_started = 0;
			return -1; /* out of memoy */
		}
	}
	else /* restart */
	{
		int i;
		res = 0;
		for(i = 0; i < USB_MAX_BUS; i++)
		{
			if(controller_priv[i] != NULL)
			{
				long handle = controller_priv[i]->handle;
				if(handle)
					res |= usb_init(handle, NULL);
			}
		}
		return res;
	}
	usb_hub_reset(bus_index);
	/* init low_level USB */
	Cconws("USB: ");
	switch(ent->class)
	{
#ifdef CONFIG_USB_UHCI
		case PCI_CLASS_SERIAL_USB_UHCI:
			res = uhci_usb_lowlevel_init(handle, ent, &priv);
			break;
#endif
#ifdef CONFIG_USB_OHCI
		case PCI_CLASS_SERIAL_USB_OHCI:
			res = ohci_usb_lowlevel_init(handle, ent, &priv);
			break;
#endif
#ifdef CONFIG_USB_EHCI
		case PCI_CLASS_SERIAL_USB_EHCI:
			res = ehci_usb_lowlevel_init(handle, ent, &priv);
			break;
#endif
		default: res = -1; break;
	}
	if(!res)
	{
		/* if lowlevel init is OK, scan the bus for devices
		 * i.e. search HUBs and configure them */
		if(setup_packet == NULL)
			setup_packet = (void *)usb_malloc(sizeof(struct devrequest));
		if(setup_packet == NULL)
		{
			usb_started = 0;
			return -1; /* out of memoy */
		}
		Cconws("Scanning bus for devices... ");
		controller_priv[bus_index] = (struct hci *)priv;
		controller_priv[bus_index]->usbnum = bus_index;
		usb_scan_devices(priv);
		bus_index++;
		usb_started = 1;
		return 0;
	}
	else
	{
		Cconws("Error, couldn't init Lowlevel part\r\n");
		usb_started = 0;
		return -1;
	}
}

/******************************************************************************
 * Stop USB this stops the LowLevel Part and deregisters USB devices.
 */
int usb_stop(void)
{
	int i, res = 0;
	if(usb_started)
	{
		asynch_allowed = 1;
		usb_started = 0;
		usb_hub_reset(bus_index);
		usb_free(setup_packet);
		for(i = 0; i < USB_MAX_BUS; i++)
		{
			struct hci *priv = controller_priv[i];
			if(priv != NULL)
			{
				switch(priv->ent->class)
				{
#ifdef CONFIG_USB_UHCI
					case PCI_CLASS_SERIAL_USB_UHCI:
						res |= uhci_usb_lowlevel_stop(priv);
						break;
#endif
#ifdef CONFIG_USB_OHCI
					case PCI_CLASS_SERIAL_USB_OHCI:
						res |= ohci_usb_lowlevel_stop(priv);
						break;
#endif
#ifdef CONFIG_USB_EHCI
					case PCI_CLASS_SERIAL_USB_EHCI:
						res |= ehci_usb_lowlevel_stop(priv);
						break;
#endif
				}
			}
		}
		bus_index = 0;
		usb_mem_stop();
	}
	return res;
}

#ifdef CONFIG_USB_INTERRUPT_POLLING

void usb_event_poll(int interrupt)
{
#ifdef CONFIG_USB_UHCI
	uhci_usb_event_poll(interrupt);
#endif
#ifdef CONFIG_USB_OHCI
	ohci_usb_event_poll(interrupt);
#endif
#ifdef CONFIG_USB_EHCI
	ehci_usb_event_poll(interrupt);
#endif
}

#else /* !CONFIG_USB_INTERRUPT_POLLING */

void usb_enable_interrupt(int enable)
{
#ifdef CONFIG_USB_UHCI
	uhci_usb_enable_interrupt(enable);
#endif
#ifdef CONFIG_USB_OHCI
	ohci_usb_enable_interrupt(enable);
#endif
#ifdef CONFIG_USB_EHCI
	ehci_usb_enable_interrupt(enable);
#endif
}

#endif /* CONFIG_USB_INTERRUPT_POLLING */

/*
 * disables the asynch behaviour of the control message. This is used for data
 * transfers that uses the exclusiv access to the control and bulk messages.
 */
void usb_disable_asynch(int disable)
{
#if 0 // #ifndef CONFIG_USB_INTERRUPT_POLLING
	if(!asynch_allowed && !disable)
	{
		USB_PRINTF("Enable interrupts\r\n");
		usb_enable_interrupt(1);
	}
	else if(asynch_allowed && disable)
	{
		USB_PRINTF("Disable interrupts\r\n");
		usb_enable_interrupt(0);
	}
#endif	
	asynch_allowed = !disable;
}

/*-------------------------------------------------------------------
 * Message wrappers.
 *
 */

/*
 * submits an Interrupt Message
 */
int usb_submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer, int transfer_len, int interval)
{
	struct hci *priv = (struct hci *)dev->priv_hcd;
	switch(priv->ent->class)
	{
#ifdef CONFIG_USB_UHCI
		case PCI_CLASS_SERIAL_USB_UHCI:
			return uhci_submit_int_msg(dev, pipe, buffer, transfer_len, interval);
#endif
#ifdef CONFIG_USB_OHCI
		case PCI_CLASS_SERIAL_USB_OHCI:
			return ohci_submit_int_msg(dev, pipe, buffer, transfer_len, interval);
#endif
#ifdef CONFIG_USB_EHCI
		case PCI_CLASS_SERIAL_USB_EHCI:
			return ehci_submit_int_msg(dev, pipe, buffer, transfer_len, interval);
#endif
		default:
			return -1;
	}
}

/*
 * submits a control message and waits for comletion (at least timeout * 1ms)
 * If timeout is 0, we don't wait for completion (used as example to set and
 * clear keyboards LEDs). For data transfers, (storage transfers) we don't
 * allow control messages with 0 timeout, by previousely resetting the flag
 * asynch_allowed (usb_disable_asynch(1)).
 * returns the transfered length if OK or -1 if error. The transfered length
 * and the current status are stored in the dev->act_len and dev->status.
 */
int usb_control_msg(struct usb_device *dev, unsigned int pipe,
			unsigned char request, unsigned char requesttype,
			unsigned short value, unsigned short index,
			void *data, unsigned short size, int timeout)
{
	struct hci *priv = (struct hci *)dev->priv_hcd;
	if((timeout == 0) && (!asynch_allowed))
	{
		/* request for a asynch control pipe is not allowed */
		return -1;
	}
	/* set setup command */
	setup_packet->requesttype = requesttype;
	setup_packet->request = request;
	setup_packet->value = cpu_to_le16(value);
	setup_packet->index = cpu_to_le16(index);
	setup_packet->length = cpu_to_le16(size);
	USB_PRINTF("usb_control_msg: request: 0x%X, requesttype: 0x%X, value 0x%X index 0x%X length 0x%X\r\n", request, requesttype, value, index, size);
	switch(priv->ent->class)
	{
#ifdef CONFIG_USB_UHCI
		case PCI_CLASS_SERIAL_USB_UHCI:
			dev->status = USB_ST_NOT_PROC; /* not yet processed */
			uhci_submit_control_msg(dev, pipe, data, size, setup_packet);
			break;
#endif
#ifdef CONFIG_USB_OHCI
		case PCI_CLASS_SERIAL_USB_OHCI:
			dev->status = USB_ST_NOT_PROC; /* not yet processed */
			ohci_submit_control_msg(dev, pipe, data, size, setup_packet);
			break;
#endif
#ifdef CONFIG_USB_EHCI
		case PCI_CLASS_SERIAL_USB_EHCI:
			dev->status = USB_ST_NOT_PROC; /* not yet processed */
			ehci_submit_control_msg(dev, pipe, data, size, setup_packet);
			break;
#endif
		default:
			return -1;
	}
	if(timeout == 0)
		return (int)size;
	if(dev->status != 0)
	{
		/*
		 * Let's wait a while for the timeout to elapse.
		 * It has no real use, but it keeps the interface happy.
		 */
		wait_ms(timeout);
		return -1;
	}
	return dev->act_len;
}

/*-------------------------------------------------------------------
 * submits bulk message, and waits for completion. returns 0 if Ok or
 * -1 if Error.
 * synchronous behavior
 */
int usb_bulk_msg(struct usb_device *dev, unsigned int pipe, void *data, int len, int *actual_length, int timeout)
{
	struct hci *priv = (struct hci *)dev->priv_hcd;
	if(len < 0)
		return -1;
	switch(priv->ent->class)
	{
#ifdef CONFIG_USB_UHCI
		case PCI_CLASS_SERIAL_USB_UHCI:
			dev->status = USB_ST_NOT_PROC; /* not yet processed */
			uhci_submit_bulk_msg(dev, pipe, data, len);
			break;
#endif
#ifdef CONFIG_USB_OHCI
		case PCI_CLASS_SERIAL_USB_OHCI:
			dev->status = USB_ST_NOT_PROC; /* not yet processed */
			ohci_submit_bulk_msg(dev, pipe, data, len);
			break;
#endif
#ifdef CONFIG_USB_EHCI
		case PCI_CLASS_SERIAL_USB_EHCI:
			dev->status = USB_ST_NOT_PROC; /* not yet processed */
			ehci_submit_bulk_msg(dev, pipe, data, len);
			break;
#endif
		default:
			return -1;
	}
	while(timeout--)
	{
		if(!((volatile unsigned long)dev->status & USB_ST_NOT_PROC))
			break;
		wait_ms(1);
	}
	*actual_length = dev->act_len;
	if(dev->status == 0)
		return 0;
	else
		return -1;
}


/*-------------------------------------------------------------------
 * Max Packet stuff
 */

/*
 * returns the max packet size, depending on the pipe direction and
 * the configurations values
 */
int usb_maxpacket(struct usb_device *dev, unsigned long pipe)
{
	/* direction is out -> use emaxpacket out */
	if((pipe & USB_DIR_IN) == 0)
		return dev->epmaxpacketout[((pipe>>15) & 0xf)];
	else
		return dev->epmaxpacketin[((pipe>>15) & 0xf)];
}

/* The routine usb_set_maxpacket_ep() is extracted from the loop of routine
 * usb_set_maxpacket(), because the optimizer of GCC 4.x chokes on this routine
 * when it is inlined in 1 single routine. What happens is that the register r3
 * is used as loop-count 'i', but gets overwritten later on.
 * This is clearly a compiler bug, but it is easier to workaround it here than
 * to update the compiler (Occurs with at least several GCC 4.{1,2},x
 * CodeSourcery compilers like e.g. 2007q3, 2008q1, 2008q3 lite editions on ARM)
 */
static void __attribute__((noinline))usb_set_maxpacket_ep(struct usb_device *dev, struct usb_endpoint_descriptor *ep)
{
	int b;
	b = ep->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK;
	if((ep->bmAttributes & USB_ENDPOINT_XFERTYPE_MASK) == USB_ENDPOINT_XFER_CONTROL)
	{
		/* Control => bidirectional */
		dev->epmaxpacketout[b] = ep->wMaxPacketSize;
		dev->epmaxpacketin[b] = ep->wMaxPacketSize;
		USB_PRINTF("##Control EP epmaxpacketout/in[%d] = %d\r\n", b, dev->epmaxpacketin[b]);
	}
	else
	{
		if((ep->bEndpointAddress & 0x80) == 0)
		{
			/* OUT Endpoint */
			if(ep->wMaxPacketSize > dev->epmaxpacketout[b])
			{
				dev->epmaxpacketout[b] = ep->wMaxPacketSize;
				USB_PRINTF("##EP epmaxpacketout[%d] = %d\r\n", b, dev->epmaxpacketout[b]);
			}
		}
		else
		{
			/* IN Endpoint */
			if(ep->wMaxPacketSize > dev->epmaxpacketin[b])
			{
				dev->epmaxpacketin[b] = ep->wMaxPacketSize;
				USB_PRINTF("##EP epmaxpacketin[%d] = %d\r\n", b, dev->epmaxpacketin[b]);
			}
		} /* if out */
	} /* if control */
}

/*
 * set the max packed value of all endpoints in the given configuration
 */
int usb_set_maxpacket(struct usb_device *dev)
{
	int i, ii;
	for(i = 0; i < dev->config.bNumInterfaces; i++)
		for(ii = 0; ii < dev->config.if_desc[i].bNumEndpoints; ii++)
			usb_set_maxpacket_ep(dev,&dev->config.if_desc[i].ep_desc[ii]);
	return 0;
}

/*******************************************************************************
 * Parse the config, located in buffer, and fills the dev->config structure.
 * Note that all little/big endian swapping are done automatically.
 */
int usb_parse_config(struct usb_device *dev, unsigned char *buffer, int cfgno)
{
	struct usb_descriptor_header *head;
	int index, ifno, epno, curr_if_num;
	int i;
	unsigned char *ch;
	ifno = -1;
	epno = -1;
	curr_if_num = -1;
	dev->configno = cfgno;
	head = (struct usb_descriptor_header *)&buffer[0];
	if(head->bDescriptorType != USB_DT_CONFIG)
	{
		board_printf(" ERROR: NOT USB_CONFIG_DESC %x\r\n", head->bDescriptorType);
		return -1;
	}
	memcpy(&dev->config, buffer, buffer[0]);
	le16_to_cpus(&(dev->config.wTotalLength));
	dev->config.no_of_if = 0;
	index = dev->config.bLength;
	/* Ok the first entry must be a configuration entry,
	 * now process the others */
	head = (struct usb_descriptor_header *) &buffer[index];
	while(index + 1 < dev->config.wTotalLength)
	{
		switch (head->bDescriptorType)
		{
			case USB_DT_INTERFACE:
				if(((struct usb_interface_descriptor *)&buffer[index])->bInterfaceNumber != curr_if_num)
				{
					/* this is a new interface, copy new desc */
					ifno = dev->config.no_of_if;
					dev->config.no_of_if++;
					memcpy(&dev->config.if_desc[ifno], &buffer[index], buffer[index]);
					dev->config.if_desc[ifno].no_of_ep = 0;
					dev->config.if_desc[ifno].num_altsetting = 1;
					curr_if_num = dev->config.if_desc[ifno].bInterfaceNumber;
				}
				else
				{
					/* found alternate setting for the interface */
					dev->config.if_desc[ifno].num_altsetting++;
				}
				break;
			case USB_DT_ENDPOINT:
				epno = dev->config.if_desc[ifno].no_of_ep;
				/* found an endpoint */
				dev->config.if_desc[ifno].no_of_ep++;
				memcpy(&dev->config.if_desc[ifno].ep_desc[epno], &buffer[index], buffer[index]);
				le16_to_cpus(&(dev->config.if_desc[ifno].ep_desc[epno].wMaxPacketSize));
				USB_PRINTF("if %d, ep %d\r\n", ifno, epno);
				break;
			default:
				if(head->bLength == 0)
					return 1;
				USB_PRINTF("unknown Description Type : %x\r\n", head->bDescriptorType);
				{
					ch = (unsigned char *)head;
					for (i = 0; i < head->bLength; i++)
						USB_PRINTF(" %02X", *ch++);
					USB_PRINTF("\r\n");
				}
				break;
		}
		index += head->bLength;
		head = (struct usb_descriptor_header *)&buffer[index];
	}
	return 1;
}

/***********************************************************************
 * Clears an endpoint
 * endp: endpoint number in bits 0-3;
 * direction flag in bit 7 (1 = IN, 0 = OUT)
 */
int usb_clear_halt(struct usb_device *dev, int pipe)
{
	int result;
	int endp = usb_pipeendpoint(pipe)|(usb_pipein(pipe)<<7);
	result = usb_control_msg(dev, usb_sndctrlpipe(dev, 0),
				 USB_REQ_CLEAR_FEATURE, USB_RECIP_ENDPOINT, 0, endp, NULL, 0, USB_CNTL_TIMEOUT * 3);
	/* don't clear if failed */
	if(result < 0)
		return result;
	/*
	 * NOTE: we do not get status and verify reset was successful
	 * as some devices are reported to lock up upon this check..
	 */
	usb_endpoint_running(dev, usb_pipeendpoint(pipe), usb_pipeout(pipe));
	/* toggle is reset on clear */
	usb_settoggle(dev, usb_pipeendpoint(pipe), usb_pipeout(pipe), 0);
	return 0;
}

/**********************************************************************
 * get_descriptor type
 */
int usb_get_descriptor(struct usb_device *dev, unsigned char type, unsigned char index, void *buf, int size)
{
	int res;
	res = usb_control_msg(dev, usb_rcvctrlpipe(dev, 0),
			USB_REQ_GET_DESCRIPTOR, USB_DIR_IN, (type << 8) + index, 0, buf, size, USB_CNTL_TIMEOUT);
	return res;
}

/**********************************************************************
 * gets configuration cfgno and store it in the buffer
 */
int usb_get_configuration_no(struct usb_device *dev, unsigned char *buffer, int cfgno)
{
	int result;
	unsigned int tmp;
	struct usb_config_descriptor *config;
	config = (struct usb_config_descriptor *)&buffer[0];
	result = usb_get_descriptor(dev, USB_DT_CONFIG, cfgno, buffer, 9);
	if(result < 9)
	{
		if(result < 0)
			board_printf("unable to get descriptor, error %lX\r\n", dev->status);
		else
			board_printf("config descriptor too short (expected %i, got %i)\n", 9, result);
		return -1;
	}
	tmp = le16_to_cpu(config->wTotalLength);
	if(tmp > USB_BUFSIZ)
	{
		USB_PRINTF("usb_get_configuration_no: failed to get descriptor - too long: %d\r\n", tmp);
		return -1;
	}
	result = usb_get_descriptor(dev, USB_DT_CONFIG, cfgno, buffer, tmp);
	USB_PRINTF("get_conf_no %d Result %d, wLength %d\r\n", cfgno, result, tmp);
	return result;
}

/********************************************************************
 * set address of a device to the value in dev->devnum.
 * This can only be done by addressing the device via the default address (0)
 */
int usb_set_address(struct usb_device *dev)
{
	int res;
	USB_PRINTF("set address %d\r\n", dev->devnum);
	res = usb_control_msg(dev, usb_snddefctrl(dev), USB_REQ_SET_ADDRESS, 0, (dev->devnum), 0, NULL, 0, USB_CNTL_TIMEOUT);
	return res;
}

/********************************************************************
 * set interface number to interface
 */
int usb_set_interface(struct usb_device *dev, int interface, int alternate)
{
	struct usb_interface_descriptor *if_face = NULL;
	int ret, i;
	for(i = 0; i < dev->config.bNumInterfaces; i++)
	{
		if(dev->config.if_desc[i].bInterfaceNumber == interface)
		{
			if_face = &dev->config.if_desc[i];
			break;
		}
	}
	if(!if_face)
	{
		board_printf("selecting invalid interface %d", interface);
		return -1;
	}
	/*
	 * We should return now for devices with only one alternate setting.
	 * According to 9.4.10 of the Universal Serial Bus Specification
	 * Revision 2.0 such devices can return with a STALL. This results in
	 * some USB sticks timeouting during initialization and then being
	 * unusable in U-Boot.
	 */
	if(if_face->num_altsetting == 1)
		return 0;
	ret = usb_control_msg(dev, usb_sndctrlpipe(dev, 0),
				USB_REQ_SET_INTERFACE, USB_RECIP_INTERFACE, alternate, interface, NULL, 0, USB_CNTL_TIMEOUT * 5);
	if(ret < 0)
		return ret;
	return 0;
}

/********************************************************************
 * set configuration number to configuration
 */
int usb_set_configuration(struct usb_device *dev, int configuration)
{
	int res;
	USB_PRINTF("set configuration %d\r\n", configuration);
	/* set setup command */
	res = usb_control_msg(dev, usb_sndctrlpipe(dev, 0),
				USB_REQ_SET_CONFIGURATION, 0, configuration, 0, NULL, 0, USB_CNTL_TIMEOUT);
	if(res == 0)
	{
		dev->toggle[0] = 0;
		dev->toggle[1] = 0;
		return 0;
	}
	else
		return -1;
}

/********************************************************************
 * set protocol to protocol
 */
int usb_set_protocol(struct usb_device *dev, int ifnum, int protocol)
{
	return usb_control_msg(dev, usb_sndctrlpipe(dev, 0),
	 USB_REQ_SET_PROTOCOL, USB_TYPE_CLASS | USB_RECIP_INTERFACE,
	 protocol, ifnum, NULL, 0, USB_CNTL_TIMEOUT);
}

/********************************************************************
 * set idle
 */
int usb_set_idle(struct usb_device *dev, int ifnum, int duration, int report_id)
{
	return usb_control_msg(dev, usb_sndctrlpipe(dev, 0),
	 USB_REQ_SET_IDLE, USB_TYPE_CLASS | USB_RECIP_INTERFACE,
	 (duration << 8) | report_id, ifnum, NULL, 0, USB_CNTL_TIMEOUT);
}

/********************************************************************
 * get report
 */
int usb_get_report(struct usb_device *dev, int ifnum, unsigned char type,
		   unsigned char id, void *buf, int size)
{
	return usb_control_msg(dev, usb_rcvctrlpipe(dev, 0),
	 USB_REQ_GET_REPORT, USB_DIR_IN | USB_TYPE_CLASS | USB_RECIP_INTERFACE,
	 (type << 8) + id, ifnum, buf, size, USB_CNTL_TIMEOUT);
}

/********************************************************************
 * get class descriptor
 */
int usb_get_class_descriptor(struct usb_device *dev, int ifnum,
		unsigned char type, unsigned char id, void *buf, int size)
{
	return usb_control_msg(dev, usb_rcvctrlpipe(dev, 0),
		USB_REQ_GET_DESCRIPTOR, USB_RECIP_INTERFACE | USB_DIR_IN,
		(type << 8) + id, ifnum, buf, size, USB_CNTL_TIMEOUT);
}

/********************************************************************
 * get string index in buffer
 */
int usb_get_string(struct usb_device *dev, unsigned short langid, unsigned char index, void *buf, int size)
{
	int i;
	int result;
	for(i = 0; i < 3; ++i)
	{
		/* some devices are flaky */
		result = usb_control_msg(dev, usb_rcvctrlpipe(dev, 0), USB_REQ_GET_DESCRIPTOR, USB_DIR_IN,
		 (USB_DT_STRING << 8) + index, langid, buf, size, USB_CNTL_TIMEOUT);
		if(result > 0)
			break;
	}
	return result;
}

static void usb_try_string_workarounds(unsigned char *buf, int *length)
{
	int newlength, oldlength = *length;
	for(newlength = 2; newlength + 1 < oldlength; newlength += 2)
	{
		char c = buf[newlength];
		if((c < ' ') || (c >= 127) || buf[newlength + 1])
			break;
	}
	if(newlength > 2)
	{
		buf[0] = newlength;
		*length = newlength;
	}
}

static int usb_string_sub(struct usb_device *dev, unsigned int langid, unsigned int index, unsigned char *buf)
{
	int rc;
	/* Try to read the string descriptor by asking for the maximum
	 * possible number of bytes */
	rc = usb_get_string(dev, langid, index, buf, 255);
	/* If that failed try to read the descriptor length, then
	 * ask for just that many bytes */
	if(rc < 2)
	{
		rc = usb_get_string(dev, langid, index, buf, 2);
		if(rc == 2)
			rc = usb_get_string(dev, langid, index, buf, buf[0]);
	}
	if(rc >= 2)
	{
		if (!buf[0] && !buf[1])
			usb_try_string_workarounds(buf, &rc);
		/* There might be extra junk at the end of the descriptor */
		if (buf[0] < rc)
			rc = buf[0];
		rc = rc - (rc & 1); /* force a multiple of two */
	}
	if(rc < 2)
		rc = -1;
	return rc;
}

/********************************************************************
 * usb_string:
 * Get string index and translate it to ascii.
 * returns string length (> 0) or error (< 0)
 */
int usb_string(struct usb_device *dev, int index, char *buf, size_t size)
{
	unsigned char *tbuf;
	int err;
	unsigned int u, idx;
	if(size <= 0 || !buf || !index)
		return -1;
	buf[0] = 0;
	tbuf = (unsigned char *)usb_malloc(USB_BUFSIZ);
	if(tbuf == NULL)
	{
		USB_PRINTF("usb_string: malloc failure\r\n");
		return -1;
	}
	/* get langid for strings if it's not yet known */
	if(!dev->have_langid)
	{
		err = usb_string_sub(dev, 0, 0, tbuf);
		if(err < 0)
		{
			USB_PRINTF("error getting string descriptor 0 (error=%lx)\r\n", dev->status);
			usb_free(tbuf);
			return -1;
		}
		else if(tbuf[0] < 4)
		{
			USB_PRINTF("string descriptor 0 too short\r\n");
			usb_free(tbuf);
			return -1;
		}
		else
		{
			dev->have_langid = -1;
			dev->string_langid = tbuf[2] | (tbuf[3] << 8);
				/* always use the first langid listed */
			USB_PRINTF("USB device number %d default language ID 0x%x\r\n", dev->devnum, dev->string_langid);
		}
	}
	err = usb_string_sub(dev, dev->string_langid, index, tbuf);
	if(err < 0)
	{
		usb_free(tbuf);
		return err;
	}
	size--;		/* leave room for trailing NULL char in output buffer */
	for(idx = 0, u = 2; u < err; u += 2)
	{
		if(idx >= size)
			break;
		if(tbuf[u+1])			/* high byte */
			buf[idx++] = '?';  /* non-ASCII character */
		else
			buf[idx++] = tbuf[u];
	}
	buf[idx] = 0;
	err = idx;
	usb_free(tbuf);
	return err;
}

/********************************************************************
 * USB device handling:
 * the USB device are static allocated [USB_MAX_DEVICE].
 */

/*
 * Something got disconnected. Get rid of it, and all of its children.
 */
void usb_disconnect(struct usb_device **pdev)
{
	struct usb_device *dev = *pdev;
	if(dev != NULL)
	{
		int i;
		USB_PRINTF("USB %d disconnect on device %d\r\n", dev->parent->usbnum, dev->parent->devnum);
		USB_PRINTF("USB %d disconnected, device number %d\r\n", dev->usbnum, dev->devnum);
		if(dev->deregister != NULL)
			dev->deregister(dev);
		/* Free up all the children.. */
		for(i = 0; i < USB_MAXCHILDREN; i++)
		{
			if(dev->children[i] != NULL)
			{
				USB_PRINTF("USB %d, disconnect children %d\r\n", dev->usbnum, dev->children[i]->devnum);
				usb_disconnect(&dev->children[i]);
				dev->children[i] = NULL;
			}
		}
		/* Free up the device itself, including its device number */
		if(dev->devnum > 0)
		{
			dev_index[dev->usbnum]--;
			memset(dev, 0, sizeof(struct usb_device));
			dev->devnum = -1;
		}
		*pdev = NULL;
	}	
}

/* returns a pointer to the device with the index [index].
 * if the device is not assigned (dev->devnum==-1) returns NULL
 */
struct usb_device *usb_get_dev_index(int index, int index_bus)
{
	struct usb_device *dev;
	if((index_bus >= USB_MAX_BUS) || (index_bus < 0)
	 || (index >= USB_MAX_DEVICE) || (index < 0))
		return NULL;
	dev = &usb_dev[(index_bus * USB_MAX_DEVICE) + index];
	if((controller_priv[index_bus] == NULL) || (dev->devnum == -1))
		return NULL;
	return dev;
}

/* returns a pointer of a new device structure or NULL, if
 * no device struct is available
 */
struct usb_device *usb_alloc_new_device(int bus_index, void *priv)
{
	int i, index = dev_index[bus_index];
	struct usb_device *dev;
	USB_PRINTF("USB %d new device %d\r\n", bus_index, index); 
	if(index >= USB_MAX_DEVICE)
	{
		board_printf("ERROR, too many USB Devices, max=%d\r\n", USB_MAX_DEVICE);
		return NULL;
	}
	/* default Address is 0, real addresses start with 1 */
	dev = &usb_dev[(bus_index * USB_MAX_DEVICE) + index];
	dev->devnum = index + 1;
	dev->maxchild = 0;
	for(i = 0; i < USB_MAXCHILDREN; dev->children[i++] = NULL);
	dev->parent = NULL;
	dev->priv_hcd = priv;
	dev->usbnum = bus_index;
	dev_index[bus_index]++;
	return dev;
}

/*
 * By the time we get here, the device has gotten a new device ID
 * and is in the default state. We need to identify the thing and
 * get the ball rolling..
 *
 * Returns 0 for success, != 0 for error.
 */
int usb_new_device(struct usb_device *dev)
{
	int addr, err, tmp;
	unsigned char *tmpbuf;
#ifndef CONFIG_LEGACY_USB_INIT_SEQ
	struct usb_device_descriptor *desc;
	int port = -1;
	struct usb_device *parent = dev->parent;
	unsigned short portstatus;
#endif
	if(dev == NULL)
		return 1;
	/* We still haven't set the Address yet */
	addr = dev->devnum;
	dev->devnum = 0;
	tmpbuf = (unsigned char *)usb_malloc(USB_BUFSIZ);
	if(tmpbuf == NULL)
	{
		USB_PRINTF("usb_new_device: malloc failure\r\n");
		return 1;
	}
#ifdef CONFIG_LEGACY_USB_INIT_SEQ
	/* this is the old and known way of initializing devices, it is
	 * different than what Windows and Linux are doing. Windows and Linux
	 * both retrieve 64 bytes while reading the device descriptor
	 * Several USB stick devices report ERR: CTL_TIMEOUT, caused by an
	 * invalid header while reading 8 bytes as device descriptor. */
	dev->descriptor.bMaxPacketSize0 = 8;	    /* Start off at 8 bytes  */
	dev->maxpacketsize = PACKET_SIZE_8;
	dev->epmaxpacketin[0] = 8;
	dev->epmaxpacketout[0] = 8;
	err = usb_get_descriptor(dev, USB_DT_DEVICE, 0, &dev->descriptor, 8);
	if(err < 8)
	{
		board_printf("\r\nUSB device not responding, giving up (status=%lX)\r\n", dev->status);
		usb_free(tmpbuf);
		return 1;
	}
#else
	/* This is a Windows scheme of initialization sequence, with double
	 * reset of the device (Linux uses the same sequence)
	 * Some equipment is said to work only with such init sequence; this
	 * patch is based on the work by Alan Stern:
	 * http://sourceforge.net/mailarchive/forum.php?
	 * thread_id=5729457&forum_id=5398
	 */
	/* send 64-byte GET-DEVICE-DESCRIPTOR request.  Since the descriptor is
	 * only 18 bytes long, this will terminate with a short packet.  But if
	 * the maxpacket size is 8 or 16 the device may be waiting to transmit
	 * some more, or keeps on retransmitting the 8 byte header. */
	desc = (struct usb_device_descriptor *)tmpbuf;
	dev->descriptor.bMaxPacketSize0 = 64;	    /* Start off at 64 bytes  */
	/* Default to 64 byte max packet size */
	dev->maxpacketsize = PACKET_SIZE_64;
	dev->epmaxpacketin[0] = 64;
	dev->epmaxpacketout[0] = 64;
	err = usb_get_descriptor(dev, USB_DT_DEVICE, 0, desc, 64);
	if(err < 0)
	{
		USB_PRINTF("usb_new_device: usb_get_descriptor() failed\r\n");
		usb_free(tmpbuf);
		return 1;
	}
	dev->descriptor.bMaxPacketSize0 = desc->bMaxPacketSize0;
	/* find the port number we're at */
	if(parent)
	{
		int j;
		for(j = 0; j < parent->maxchild; j++)
		{
			if(parent->children[j] == dev)
			{
				port = j;
				break;
			}
		}
		if(port < 0)
		{
			board_printf("usb_new_device: cannot locate device's port.\r\n");
			usb_free(tmpbuf);
			return 1;
		}
		/* reset the port for the second time */
		err = hub_port_reset(dev->parent, port, &portstatus);
		if(err < 0)
		{
			board_printf("\r\nCouldn't reset port %i\r\n", port);
			usb_free(tmpbuf);
			return 1;
		}
	}
#endif
	dev->epmaxpacketin[0] = dev->descriptor.bMaxPacketSize0;
	dev->epmaxpacketout[0] = dev->descriptor.bMaxPacketSize0;
	switch (dev->descriptor.bMaxPacketSize0)
	{
		case 8: dev->maxpacketsize  = PACKET_SIZE_8; break;
		case 16: dev->maxpacketsize = PACKET_SIZE_16; break;
		case 32: dev->maxpacketsize = PACKET_SIZE_32; break;
		case 64: dev->maxpacketsize = PACKET_SIZE_64; break;
	}
	dev->devnum = addr;
	err = usb_set_address(dev); /* set address */
	if(err < 0)
	{
		board_printf("\r\nUSB device not accepting new address (error=%lX)\r\n", dev->status);
		usb_free(tmpbuf);
		return 1;
	}
	wait_ms(10);	/* Let the SET_ADDRESS settle */
	tmp = sizeof(dev->descriptor);
	err = usb_get_descriptor(dev, USB_DT_DEVICE, 0, &dev->descriptor, sizeof(dev->descriptor));
	if(err < tmp)
	{
		if(err < 0)
			board_printf("unable to get device descriptor (error=%d)\r\n", err);
		else
			board_printf("USB device descriptor short read (expected %i, got %i)\r\n", tmp, err);
		usb_free(tmpbuf);
		return 1;
	}
	/* correct le values */
	le16_to_cpus(&dev->descriptor.bcdUSB);
	le16_to_cpus(&dev->descriptor.idVendor);
	le16_to_cpus(&dev->descriptor.idProduct);
	le16_to_cpus(&dev->descriptor.bcdDevice);
	/* only support for one config for now */
	usb_get_configuration_no(dev, &tmpbuf[0], 0);
	usb_parse_config(dev, &tmpbuf[0], 0);
	usb_set_maxpacket(dev);
	/* we set the default configuration here */
	if(usb_set_configuration(dev, dev->config.bConfigurationValue))
	{
		board_printf("failed to set default configuration len %d, status %lX\r\n", dev->act_len, dev->status);
		usb_free(tmpbuf);
		return -1;
	}
	USB_PRINTF("new device strings: Mfr=%d, Product=%d, SerialNumber=%d\r\n",
		   dev->descriptor.iManufacturer, dev->descriptor.iProduct,
		   dev->descriptor.iSerialNumber);
	memset(dev->mf, 0, sizeof(dev->mf));
	memset(dev->prod, 0, sizeof(dev->prod));
	memset(dev->serial, 0, sizeof(dev->serial));
	if(dev->descriptor.iManufacturer)
		usb_string(dev, dev->descriptor.iManufacturer, dev->mf, sizeof(dev->mf));
	if(dev->descriptor.iProduct)
		usb_string(dev, dev->descriptor.iProduct, dev->prod, sizeof(dev->prod));
	if(dev->descriptor.iSerialNumber)
		usb_string(dev, dev->descriptor.iSerialNumber, dev->serial, sizeof(dev->serial));
	USB_PRINTF("Manufacturer %s\r\n", dev->mf);
	USB_PRINTF("Product      %s\r\n", dev->prod);
	USB_PRINTF("SerialNumber %s\r\n", dev->serial);
	/* now prode if the device is a hub */
	usb_hub_probe(dev, 0);
	usb_free(tmpbuf);
	return 0;
}

/* build device Tree  */
void usb_scan_devices(void *priv)
{
	int i;
	struct usb_device *dev;
	/* first make all devices unknown */
	for(i = 0; i < USB_MAX_DEVICE; i++)
	{
		memset(&usb_dev[(bus_index * USB_MAX_DEVICE) + i], 0, sizeof(struct usb_device));
		usb_dev[(bus_index * USB_MAX_DEVICE) + i].devnum = -1;
	}
	dev_index[bus_index] = 0;
	/* device 0 is always present (root hub, so let it analyze) */
	dev = usb_alloc_new_device(bus_index, priv);
	if(usb_new_device(dev))
	{
		Cconws("No USB Device found\r\n");
		USB_PRINTF("No USB Device found\r\n");
		if(dev != NULL)
			dev_index[bus_index]--;
	}
	else
	{
		kprint("%d USB Device(s) found\r\n", dev_index[bus_index]);
		USB_PRINTF("%d USB Device(s) found\r\n", dev_index[bus_index]);
	}
#ifndef USB_POLL_HUB
	/* insert "driver" if possible */
#ifdef CONFIG_USB_KEYBOARD
	if(drv_usb_kbd_init() < 0)
		USB_PRINTF("No USB keyboard found\r\n");	
	else
		Cconws("USB HID keyboard driver installed\r\n");
#endif /* CONFIG_USB_KEYBOARD */
#ifdef CONFIG_USB_MOUSE
	if(drv_usb_mouse_init() < 0)
		USB_PRINTF("No USB mouse found\r\n");	
	else
		Cconws("USB HID mouse driver installed\r\n");
#endif /* CONFIG_USB_MOUSE */
#endif
	USB_PRINTF("Scan end\r\n");
}

/****************************************************************************
 * HUB "Driver"
 * Probes device for being a hub and configurate it
 */

#undef USB_HUB_DEBUG

#ifdef USB_HUB_DEBUG
#ifdef COLDFIRE
#define	USB_HUB_PRINTF(fmt, args...)	board_printf(fmt , ##args)
#else
#define	USB_HUB_PRINTF(fmt, args...)	board_printf(fmt , ##args); Crawcin()
#endif /* COLDFIRE */
#else
#define USB_HUB_PRINTF(fmt, args...)
#endif

static struct usb_hub_device hub_dev[USB_MAX_BUS][USB_MAX_HUB];
static int usb_hub_index[USB_MAX_BUS];
char usb_error_str[256];

int usb_get_hub_descriptor(struct usb_device *dev, void *data, int size)
{
	return usb_control_msg(dev, usb_rcvctrlpipe(dev, 0),
	 USB_REQ_GET_DESCRIPTOR, USB_DIR_IN | USB_RT_HUB, USB_DT_HUB << 8, 0, data, size, USB_CNTL_TIMEOUT);
}

int usb_clear_hub_feature(struct usb_device *dev, int feature)
{
	return usb_control_msg(dev, usb_sndctrlpipe(dev, 0),
	 USB_REQ_CLEAR_FEATURE, USB_RT_HUB, feature, 0, NULL, 0, USB_CNTL_TIMEOUT);
}

int usb_clear_port_feature(struct usb_device *dev, int port, int feature)
{
	return usb_control_msg(dev, usb_sndctrlpipe(dev, 0),
	 USB_REQ_CLEAR_FEATURE, USB_RT_PORT, feature,	port, NULL, 0, USB_CNTL_TIMEOUT);
}

int usb_set_port_feature(struct usb_device *dev, int port, int feature)
{
	return usb_control_msg(dev, usb_sndctrlpipe(dev, 0),
	 USB_REQ_SET_FEATURE, USB_RT_PORT, feature,	port, NULL, 0, USB_CNTL_TIMEOUT);
}

int usb_get_hub_status(struct usb_device *dev, void *data)
{
	return usb_control_msg(dev, usb_rcvctrlpipe(dev, 0),
	 USB_REQ_GET_STATUS, USB_DIR_IN | USB_RT_HUB, 0, 0, data, sizeof(struct usb_hub_status), USB_CNTL_TIMEOUT);
}

int usb_get_port_status(struct usb_device *dev, int port, void *data)
{
	return usb_control_msg(dev, usb_rcvctrlpipe(dev, 0),
	 USB_REQ_GET_STATUS, USB_DIR_IN | USB_RT_PORT, 0, port, data, sizeof(struct usb_hub_status), USB_CNTL_TIMEOUT);
}

static void usb_hub_power_on(struct usb_hub_device *hub)
{
	int i;
	struct usb_device *dev;
	dev = hub->pusb_dev;
	/* Enable power to the ports */
	USB_HUB_PRINTF("enabling power on all ports\r\n");
	for (i = 0; i < dev->maxchild; i++)
	{
		usb_set_port_feature(dev, i + 1, USB_PORT_FEAT_POWER);
		USB_HUB_PRINTF("port %d returns %lX\r\n", i + 1, dev->status);
		wait_ms(hub->desc.bPwrOn2PwrGood * 2);
	}
}

void usb_hub_reset(int bus_index)
{
	usb_hub_index[bus_index] = 0;
}

struct usb_hub_device *usb_hub_allocate(void)
{
	if(usb_hub_index[bus_index] < USB_MAX_HUB)
		return &hub_dev[bus_index][usb_hub_index[bus_index]++];
	board_printf("ERROR: USB_MAX_HUB (%d) reached\r\n", USB_MAX_HUB);
	return NULL;
}

#define MAX_TRIES 5

static inline char *portspeed(int portstatus)
{
	if(portstatus & (1 << USB_PORT_FEAT_HIGHSPEED))
		return "480 Mb/s";
	else if(portstatus & (1 << USB_PORT_FEAT_LOWSPEED))
		return "1.5 Mb/s";
	else
		return "12 Mb/s";
}

static int hub_port_reset(struct usb_device *dev, int port, unsigned short *portstat)
{
	int tries;
	struct usb_port_status portsts;
	unsigned short portstatus, portchange;
	USB_HUB_PRINTF("hub_port_reset: resetting port %d...\r\n", port + 1);
	for(tries = 0; tries < MAX_TRIES; tries++)
	{
		usb_set_port_feature(dev, port + 1, USB_PORT_FEAT_RESET);
#ifdef USB_POLL_HUB
		vTaskDelay((200*configTICK_RATE_HZ)/1000);
#else
		wait_ms(200);
#endif
		if(usb_get_port_status(dev, port + 1, &portsts) < 0)
		{
			USB_HUB_PRINTF("get_port_status failed status %lX\r\n", dev->status);
			return -1;
		}
		portstatus = le16_to_cpu(portsts.wPortStatus);
		portchange = le16_to_cpu(portsts.wPortChange);
		USB_HUB_PRINTF("USB %d portstatus %x, change %x, %s\r\n", dev->usbnum, portstatus, portchange, portspeed(portstatus));
		USB_HUB_PRINTF("STAT_C_CONNECTION = %d STAT_CONNECTION = %d USB_PORT_STAT_ENABLE = %d\r\n",
		 (portchange & USB_PORT_STAT_C_CONNECTION) ? 1 : 0, (portstatus & USB_PORT_STAT_CONNECTION) ? 1 : 0, (portstatus & USB_PORT_STAT_ENABLE) ? 1 : 0);
		if((portchange & USB_PORT_STAT_C_CONNECTION) || !(portstatus & USB_PORT_STAT_CONNECTION))
			return -1;
		if(portstatus & USB_PORT_STAT_ENABLE)
			break;
#ifdef USB_POLL_HUB
		vTaskDelay((200*configTICK_RATE_HZ)/1000);
#else
		wait_ms(200);
#endif
	}
	if(tries == MAX_TRIES)
	{
		USB_HUB_PRINTF("USB %d, cannot enable port %i after %i retries, disabling port.\r\n", dev->usbnum, port + 1, MAX_TRIES);
		USB_HUB_PRINTF("Maybe the USB cable is bad?\r\n");
		return -1;
	}
	usb_clear_port_feature(dev, port + 1, USB_PORT_FEAT_C_RESET);
	*portstat = portstatus;
	return 0;
}

void usb_hub_port_connect_change(struct usb_device *dev, int port)
{
	struct usb_device *usb;
	struct usb_port_status portsts;
	unsigned short portstatus, portchange;
	/* Check status */
	if(usb_get_port_status(dev, port + 1, &portsts) < 0)
	{
		USB_HUB_PRINTF("USB %d get_port_status failed\r\n", dev->usbnum);
		return;
	}
	portstatus = le16_to_cpu(portsts.wPortStatus);
	portchange = le16_to_cpu(portsts.wPortChange);
	USB_HUB_PRINTF("USB %d, portstatus %x, change %x, %s\r\n", dev->usbnum, portstatus, portchange, portspeed(portstatus));
	/* Clear the connection change status */
	usb_clear_port_feature(dev, port + 1, USB_PORT_FEAT_C_CONNECTION);
	/* Disconnect any existing devices under this port */
	if(((!(portstatus & USB_PORT_STAT_CONNECTION))
	 && (!(portstatus & USB_PORT_STAT_ENABLE))) || (dev->children[port]))
	{
		USB_HUB_PRINTF("USB %d port %i disconnected\r\n", dev->usbnum, port + 1);
		usb_disconnect(&dev->children[port]);
		/* Return now if nothing is connected */
		if(!(portstatus & USB_PORT_STAT_CONNECTION))
			return;
	}
#ifdef USB_POLL_HUB
	vTaskDelay((200*configTICK_RATE_HZ)/1000);
#else
	wait_ms(200);
#endif
	/* Reset the port */
	if(hub_port_reset(dev, port, &portstatus) < 0)
	{
		board_printf("USB %d cannot reset port %i!?\r\n", dev->usbnum, port + 1);
		return;
	}
#ifdef USB_POLL_HUB
	vTaskDelay((200*configTICK_RATE_HZ)/1000);
#else
	wait_ms(200);
#endif
	/* Allocate a new device struct for it */
	usb = usb_alloc_new_device(dev->usbnum, dev->priv_hcd);
	if(portstatus & USB_PORT_STAT_HIGH_SPEED)
		usb->speed = USB_SPEED_HIGH;
	else if(portstatus & USB_PORT_STAT_LOW_SPEED)
		usb->speed = USB_SPEED_LOW;
	else
		usb->speed = USB_SPEED_FULL;
	dev->children[port] = usb;
	usb->parent = dev;
	/* Run it through the hoops (find a driver, etc) */
	if(usb_new_device(usb))
	{
		/* Woops, disable the port */
		USB_HUB_PRINTF("USB %d hub: disabling port %d\r\n", dev->usbnum, port + 1);
		usb_clear_port_feature(dev, port + 1, USB_PORT_FEAT_ENABLE);
	}
#ifdef USB_POLL_HUB
	else
	{
#ifdef CONFIG_USB_KEYBOARD
		usb_kbd_register(usb);
#endif /* CONFIG_USB_KEYBOARD */
#ifdef CONFIG_USB_MOUSE
		usb_mouse_register(usb);
#endif /* CONFIG_USB_MOUSE */
#ifdef CONFIG_USB_STORAGE
		usb_stor_register(usb);
#endif /* CONFIG_USB_STORAGE */
	}
#endif
}

static void usb_hub_events(struct usb_device *dev)
{
	int i;
	struct usb_hub_device *hub = dev->hub;
	if(hub == NULL)
		return;	
	for(i = 0; i < dev->maxchild; i++)
	{
		struct usb_port_status portsts;
		unsigned short portstatus, portchange;
		if(usb_get_port_status(dev, i + 1, &portsts) < 0)
		{
			USB_HUB_PRINTF("get_port_status failed\r\n");
			continue;
		}
		portstatus = le16_to_cpu(portsts.wPortStatus);
		portchange = le16_to_cpu(portsts.wPortChange);
//		USB_HUB_PRINTF("USB %d Port %d Status %X Change %X\r\n", dev->usbnum, i + 1, portstatus, portchange);
		if(portchange & USB_PORT_STAT_C_CONNECTION)
		{
			USB_HUB_PRINTF("USB %d port %d connection change\r\n", dev->usbnum, i + 1);
			usb_hub_port_connect_change(dev, i);
		}
		if(portchange & USB_PORT_STAT_C_ENABLE)
		{
			USB_HUB_PRINTF("USB %d port %d enable change, status %x\r\n", dev->usbnum, i + 1, portstatus);
			usb_clear_port_feature(dev, i + 1, USB_PORT_FEAT_C_ENABLE);
			/* EM interference sometimes causes bad shielded USB
			 * devices to be shutdown by the hub, this hack enables
			 * them again. Works at least with mouse driver */
			if(!(portstatus & USB_PORT_STAT_ENABLE) && (portstatus & USB_PORT_STAT_CONNECTION) && ((dev->children[i])))
			{
				USB_HUB_PRINTF("USB %d already running port %i disabled by hub (EMI?), re-enabling...\r\n", dev->usbnum, i + 1);
				usb_hub_port_connect_change(dev, i);
			}
		}
		if(portstatus & USB_PORT_STAT_SUSPEND)
		{
			USB_HUB_PRINTF("USB %d port %d suspend change\r\n", dev->usbnum, i + 1);
			usb_clear_port_feature(dev, i + 1, USB_PORT_FEAT_SUSPEND);
		}
		if(portchange & USB_PORT_STAT_C_OVERCURRENT)
		{
			USB_HUB_PRINTF("USB %d port %d over-current change\r\n", dev->usbnum, i + 1);
			usb_clear_port_feature(dev, i + 1, USB_PORT_FEAT_C_OVER_CURRENT);
			usb_hub_power_on(hub);
		}
		if(portchange & USB_PORT_STAT_C_RESET)
		{
			USB_HUB_PRINTF("USB %d port %d reset change\r\n", dev->usbnum, i + 1);
			usb_clear_port_feature(dev, i + 1, USB_PORT_FEAT_C_RESET);
		}
	} /* end for i all ports */
}

#ifdef USB_POLL_HUB
void usb_poll_hub_task(void *pvParameters)
{
	int index_bus = 0;
	portTickType timeout = configTICK_RATE_HZ/10;		
	if(pvParameters);
	while(1)
	{
		if(xQueueAltReceive(queue_poll_hub, &index_bus, timeout) == pdPASS)
		{
			if((index_bus >= 0) && (index_bus < USB_MAX_BUS) && (controller_priv[index_bus] != NULL))
			{
				USB_HUB_PRINTF("USB %d event change\r\n", index_bus);
#ifdef CONFIG_USB_INTERRUPT_POLLING
				*vblsem = 0;
#endif
				usb_hub_events(&usb_dev[index_bus * USB_MAX_DEVICE]);
#ifdef CONFIG_USB_INTERRUPT_POLLING
				*vblsem = 1;
#endif
			}
		}
		else /* timeout */
		{
			int i;
#ifdef CONFIG_USB_INTERRUPT_POLLING
			*vblsem = 0;
#endif
			for(i = 0; i < USB_MAX_BUS ; i++)
			{
				if(controller_priv[i] != NULL)
					usb_hub_events(&usb_dev[i * USB_MAX_DEVICE]);		
			}
#ifdef CONFIG_USB_INTERRUPT_POLLING
			*vblsem = 1;
#endif
		}
		timeout = portMAX_DELAY;
	}
}
#endif /* USB_POLL_HUB */

int usb_hub_configure(struct usb_device *dev)
{
	unsigned char *buffer, *bitmap;
	struct usb_hub_descriptor *descriptor;
	struct usb_hub_status *hubsts;
	int i;
	struct usb_hub_device *hub;
	/* "allocate" Hub device */
	hub = usb_hub_allocate();
	dev->hub = hub;
	if(hub == NULL)
		return -1;
	hub->pusb_dev = dev;
	buffer = (unsigned char *)usb_malloc(USB_BUFSIZ);
	if(buffer == NULL)
	{
		USB_HUB_PRINTF("usb_hub_configure: malloc failure\r\n");
		return -1;
	}
	/* Get the the hub descriptor */
	if(usb_get_hub_descriptor(dev, buffer, 4) < 0)
	{
		USB_HUB_PRINTF("usb_hub_configure: failed to get hub descriptor, giving up %lX\r\n", dev->status);
		usb_free(buffer);
		return -1;
	}
	USB_HUB_PRINTF("bLength:%02X bDescriptorType:%02X bNbrPorts:%02X\r\n", buffer[0], buffer[1], buffer[2]); 
	descriptor = (struct usb_hub_descriptor *)buffer;
	/* silence compiler warning if USB_BUFSIZ is > 256 [= sizeof(char)] */
	i = descriptor->bLength;
	if(i > USB_BUFSIZ)
	{
		USB_HUB_PRINTF("usb_hub_configure: failed to get hub descriptor - too long: %d\r\n", descriptor->bLength);
		usb_free(buffer);
		return -1;
	}
	if(usb_get_hub_descriptor(dev, buffer, descriptor->bLength) < 0)
	{
		USB_HUB_PRINTF("usb_hub_configure: failed to get hub descriptor 2nd giving up %lX\r\n", dev->status);
		usb_free(buffer);
		return -1;
	}
	memcpy((unsigned char *)&hub->desc, buffer, descriptor->bLength);
	/* adjust 16bit values */
	hub->desc.wHubCharacteristics = le16_to_cpu(descriptor->wHubCharacteristics);
	/* set the bitmap */
	bitmap = (unsigned char *)&hub->desc.DeviceRemovable[0];
	/* devices not removable by default */
	memset(bitmap, 0xff, (USB_MAXCHILDREN+1+7)/8);
	bitmap = (unsigned char *)&hub->desc.PortPowerCtrlMask[0];
	memset(bitmap, 0xff, (USB_MAXCHILDREN+1+7)/8); /* PowerMask = 1B */
	for(i = 0; i < ((hub->desc.bNbrPorts + 1 + 7)/8); i++)
		hub->desc.DeviceRemovable[i] = descriptor->DeviceRemovable[i];
	for(i = 0; i < ((hub->desc.bNbrPorts + 1 + 7)/8); i++)
		hub->desc.DeviceRemovable[i] = descriptor->PortPowerCtrlMask[i];
	dev->maxchild = descriptor->bNbrPorts;
	USB_HUB_PRINTF("USB %d, %d ports detected\r\n", dev->usbnum, dev->maxchild);
	if(dev->maxchild >= 10)
		 dev->maxchild = 10;
	switch(hub->desc.wHubCharacteristics & HUB_CHAR_LPSM)
	{
		case 0x00: USB_HUB_PRINTF("ganged power switching\r\n"); break;
		case 0x01: USB_HUB_PRINTF("individual port power switching\r\n"); break;
		case 0x02:
		case 0x03: USB_HUB_PRINTF("unknown reserved power switching mode\r\n"); break;
	}
	if(hub->desc.wHubCharacteristics & HUB_CHAR_COMPOUND)
	{
		USB_HUB_PRINTF("part of a compound device\r\n");
	}
	else
	{
		USB_HUB_PRINTF("standalone hub\r\n");
	}
	switch(hub->desc.wHubCharacteristics & HUB_CHAR_OCPM)
	{
		case 0x00: USB_HUB_PRINTF("global over-current protection\r\n"); break;
		case 0x08: USB_HUB_PRINTF("individual port over-current protection\r\n"); break;
		case 0x10:
		case 0x18: USB_HUB_PRINTF("no over-current protection\r\n"); break;
	}
	USB_HUB_PRINTF("power on to power good time: %dms\r\n", descriptor->bPwrOn2PwrGood * 2);
	USB_HUB_PRINTF("hub controller current requirement: %dmA\r\n", descriptor->bHubContrCurrent);
	for(i = 0; i < dev->maxchild; i++)
	{
		USB_HUB_PRINTF("USB %d port %d is%s removable\r\n", dev->usbnum, i + 1, hub->desc.DeviceRemovable[(i + 1) / 8] & (1 << ((i + 1) % 8)) ? " not" : "");
	}
	if(sizeof(struct usb_hub_status) > USB_BUFSIZ)
	{
		USB_HUB_PRINTF("usb_hub_configure: failed to get Status - too long: %d\r\n", descriptor->bLength);
		usb_free(buffer);
		return -1;
	}
	if(usb_get_hub_status(dev, buffer) < 0)
	{
		USB_HUB_PRINTF("usb_hub_configure: failed to get Status %lX\r\n", dev->status);
		usb_free(buffer);
		return -1;
	}
	hubsts = (struct usb_hub_status *)buffer;
	USB_HUB_PRINTF("get_hub_status returned status %X, change %X\r\n", le16_to_cpu(hubsts->wHubStatus), le16_to_cpu(hubsts->wHubChange));
	USB_HUB_PRINTF("local power source is %s\r\n", (le16_to_cpu(hubsts->wHubStatus) & HUB_STATUS_LOCAL_POWER) ? "lost (inactive)" : "good");
	USB_HUB_PRINTF("%sover-current condition exists\r\n", (le16_to_cpu(hubsts->wHubStatus) & HUB_STATUS_OVERCURRENT) ? "" : "no ");
	usb_hub_power_on(hub);
#ifdef USB_POLL_HUB
	if(queue_poll_hub == NULL)
	{
		queue_poll_hub = xQueueCreate(64, sizeof(int));
		if(queue_poll_hub != NULL)
		{
			/* Create poll/event task */
			if(xTaskCreate(usb_poll_hub_task, (void *)"USBHub", configMINIMAL_STACK_SIZE, NULL, 16, NULL) != pdPASS)
			{
				vQueueDelete(queue_poll_hub);
				queue_poll_hub = NULL;	
			}
		}
		vTaskDelay(configTICK_RATE_HZ);
	}
	if(queue_poll_hub == NULL)
#endif
		usb_hub_events(dev);
	usb_free(buffer);
	return 0;
}

int usb_hub_probe(struct usb_device *dev, int ifnum)
{
	struct usb_interface_descriptor *iface;
	struct usb_endpoint_descriptor *ep;
	int ret;
	iface = &dev->config.if_desc[ifnum];
	/* Is it a hub? */
	if(iface->bInterfaceClass != USB_CLASS_HUB)
		return 0;
	/* Some hubs have a subclass of 1, which AFAICT according to the */
	/*  specs is not defined, but it works */
	if((iface->bInterfaceSubClass != 0) && (iface->bInterfaceSubClass != 1))
		return 0;
	/* Multiple endpoints? What kind of mutant ninja-hub is this? */
	if(iface->bNumEndpoints != 1)
		return 0;
	ep = &iface->ep_desc[0];
	/* Output endpoint? Curiousier and curiousier.. */
	if(!(ep->bEndpointAddress & USB_DIR_IN))
		return 0;
	/* If it's not an interrupt endpoint, we'd better punt! */
	if((ep->bmAttributes & 3) != 3)
		return 0;
	/* We found a hub */
	USB_HUB_PRINTF("USB %d hub found\r\n", dev->usbnum);
	ret = usb_hub_configure(dev);
	return ret;
}

#endif /* CONFIG_USB_UHCI || CONFIG_USB_OHCI || CONFIG_USB_EHCI */

