/*
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
#include "usb.h"

#undef USB_MOUSE_DEBUG

#if defined(CONFIG_USB_UHCI) || defined(CONFIG_USB_OHCI) || defined(CONFIG_USB_EHCI)
#ifdef CONFIG_USB_MOUSE

#ifdef	USB_MOUSE_DEBUG
#define	USB_MOUSE_PRINTF(fmt,args...)	board_printf(fmt ,##args)
#else
#define USB_MOUSE_PRINTF(fmt,args...)
#endif

extern void ltoa(char *buf, long n, unsigned long base);
extern void call_mousevec(unsigned char *data, void (**mousevec)(void *));
extern void call_ikbdvec(unsigned char code, _IOREC *iorec, void (**ikbdvec)());
extern int asm_set_ipl(int level);

static unsigned char *new;
static unsigned char old[8];
static int mouse_installed;

extern void (**mousevec)(void *);
extern _IOREC *iorec;
extern void (**ikbdvec)();

/* forward declaration */
static int usb_mouse_probe(struct usb_device *dev, unsigned int ifnum);

/* deregistering the mouse */
int usb_mouse_deregister(struct usb_device *dev)
{
	dev->irq_handle = NULL;
	if(new != NULL)
	{
		usb_free(new);
		new = NULL;
	}
	mouse_installed = 0;
	USB_MOUSE_PRINTF("USB MOUSE deregister\r\n");
	return 1;
}

/* registering the mouse */
int usb_mouse_register(struct usb_device *dev)
{
	if(!mouse_installed && (dev->devnum != -1) && (usb_mouse_probe(dev, 0) == 1))
	{ /* Ok, we found a mouse */
		USB_MOUSE_PRINTF("USB MOUSE found (USB: %d, devnum: %d)\r\n", dev->usbnum, dev->devnum);
		mouse_installed = 1;
		dev->deregister = usb_mouse_deregister;
		return 1;
	}
	/* no USB Mouse found */
	return -1;
}

/* search for mouse and register it if found */
int drv_usb_mouse_init(void)
{
	int i, j;
	if(mouse_installed)
		return -1;
	/* scan all USB Devices */
	for(j = 0; j < USB_MAX_BUS; j++)
	{
		for(i = 0; i < USB_MAX_DEVICE; i++)
		{
			struct usb_device *dev = usb_get_dev_index(i, j); /* get device */
			if(dev == NULL)
				break;
			if(usb_mouse_register(dev) > 0)
				return 1;
		}
	}
	/* no USB Mouse found */
	return -1;
}

/**************************************************************************
 * Low Level drivers
 */
static void usb_kbd_send_code(unsigned char code)
{
	if((iorec != NULL) && (ikbdvec != NULL))
		call_ikbdvec(code, iorec, ikbdvec);
}

/* Interrupt service routine */
static int usb_mouse_irq(struct usb_device *dev)
{
#ifdef CONFIG_USB_INTERRUPT_POLLING
	int level;
#endif
	int i, change = 0;
	if((dev->irq_status != 0) || (dev->irq_act_len < 3) || (dev->irq_act_len > 8))
	{
		USB_MOUSE_PRINTF("USB MOUSE error %lX, len %d\r\n", dev->irq_status, dev->irq_act_len);
		return 1;
	}
	for(i = 0; i < dev->irq_act_len; i++)
	{
		if(new[i] != old[i])
		{
			change = 1;
			break;
		}
	}
	if(change)
	{
		char wheel = 0, buttons, old_buttons;
		USB_MOUSE_PRINTF("USB MOUSE len:%d %02X %02X %02X %02X %02X %02X\r\n", dev->irq_act_len, new[0], new[1], new[2], new[3], new[4], new[5]);
#ifdef CONFIG_USB_INTERRUPT_POLLING
		level = asm_set_ipl(7); /* mask interrupts */
#endif
		if((dev->irq_act_len >= 6) && (new[0] == 1)) /* report-ID */
		{
			buttons = new[1];
			old_buttons = old[1];
			new[0] = ((new[1] & 1) << 1) + ((new[1] & 2) >> 1) + 0xF8;
			new[1] = new[2];
			new[2] = new[3];
			wheel = new[4];
		}
		else /* boot report */
		{
			buttons = new[0];
			old_buttons = old[0];
			new[0] = ((new[0] & 1) << 1) + ((new[0] & 2) >> 1) + 0xF8;
			if(dev->irq_act_len >= 3)
				wheel = new[3];
		}
		if((buttons ^ old_buttons) & 4) /* 3rd button */
		{
		  if(buttons & 4)
		  {
				usb_kbd_send_code(0x72); /* ENTER */
				usb_kbd_send_code(0xF2);
			}
		}
		if(wheel != 0) /* actually like Eiffel */
		{
#define REPEAT_WHEEL 3
			int i;
			if(wheel > 0)
			{
				for(i = 0; i < REPEAT_WHEEL; i++)
				{
					usb_kbd_send_code(0x48); /* UP */
					usb_kbd_send_code(0xC8);
				}
			}
			else
			{
				for(i = 0; i < REPEAT_WHEEL; i++)
				{
					usb_kbd_send_code(0x50); /* DOWN */
					usb_kbd_send_code(0xD0);
				}
			}
		}
		if(mousevec != NULL)
			call_mousevec(new, mousevec);
#ifdef CONFIG_USB_INTERRUPT_POLLING
		asm_set_ipl(level);
#endif
		old[0] = new[0];
		old[1] = new[1];
		old[2] = new[2];
		old[3] = new[3];
		old[4] = new[4];
		old[5] = new[5];
	}
	return 1; /* install IRQ Handler again */
}

/* probes the USB device dev for mouse type */
static int usb_mouse_probe(struct usb_device *dev, unsigned int ifnum)
{
	struct usb_interface_descriptor *iface;
	struct usb_endpoint_descriptor *ep;
	int pipe, maxp;
	if(dev->descriptor.bNumConfigurations != 1)
		return 0;
	iface = &dev->config.if_desc[ifnum];
	if(iface->bInterfaceClass != 3)
		return 0;
	if(iface->bInterfaceSubClass != 1)
		return 0;
	if(iface->bInterfaceProtocol != 2)
		return 0;
	if(iface->bNumEndpoints != 1)
		return 0;
	ep = &iface->ep_desc[0];
	if(!(ep->bEndpointAddress & 0x80))
		return 0;
	if((ep->bmAttributes & 3) != 3)
		return 0;
	new = (unsigned char *)usb_malloc(8);
	if(new == NULL)
		return 0;
	USB_MOUSE_PRINTF("USB MOUSE found set protocol...\r\n");
	/* ok, we found a USB Mouse, install it */
	pipe = usb_rcvintpipe(dev, ep->bEndpointAddress);
	maxp = usb_maxpacket(dev, pipe);
//	if(maxp < 6)
//		usb_set_protocol(dev, iface->bInterfaceNumber, 0); /* boot */
//	else
	usb_set_protocol(dev, iface->bInterfaceNumber, 1); /* report */
	USB_MOUSE_PRINTF("USB MOUSE found set idle...\r\n");
	usb_set_idle(dev, iface->bInterfaceNumber, 0, 0); /* report infinite */
	memset(&new[0], 0, 8);
	memset(&old[0], 0, 8);
	dev->irq_handle = usb_mouse_irq;
	USB_MOUSE_PRINTF("USB MOUSE enable interrupt pipe (maxp: %d)...\r\n", maxp);
	usb_submit_int_msg(dev, pipe, &new[0], maxp > 8 ? 8 : maxp, ep->bInterval);
	return 1;
}

#endif /* CONFIG_USB_MOUSE */
#endif /* CONFIG_USB_UHCI || CONFIG_USB_OHCI || CONFIG_USB_EHCI */
