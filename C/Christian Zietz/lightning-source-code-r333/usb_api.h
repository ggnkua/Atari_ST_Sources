/*
 * FreeMiNT USB subsystem by David Galvez. 2010 - 2015
 *
 * This file is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#ifndef _usb_api_h
#define _usb_api_h

#include "usb.h"
#include "hub.h"

/*
 * USB API VERSION. ALL MODULES COMPILED WITH THIS, SO MUST MATCH !
 */
#define USB_API_VERSION 4

/*
 * UCD - USB Controller Driver.
 */
#define UCD_OPEN	1
#define UCD_NAMSIZ	16	/* maximum ucd name len */

#define USB_CONTRLL	0

/*
 * ioctl opcodes
 */
#define LOWLEVEL_INIT		(('U'<< 8) | 0)
#define LOWLEVEL_STOP		(('U'<< 8) | 1)
#define SUBMIT_CONTROL_MSG	(('U'<< 8) | 2)
#define SUBMIT_BULK_MSG		(('U'<< 8) | 3)
#define SUBMIT_INT_MSG		(('U'<< 8) | 4)

struct bulk_msg
{
	struct usb_device	*dev;
	unsigned long		pipe;
	void				*data;
	long				len;
	long				flags;
	unsigned long		timeout;
};

struct control_msg
{
	struct usb_device 	*dev;
	unsigned long 		pipe;
	unsigned short 		value;
	void 			*data;
	unsigned short 		size;
	struct devrequest	*setup;
};

struct int_msg
{
	struct usb_device 	*dev;
	unsigned long 		pipe;
	void 			*buffer;
	long 			transfer_len;
	long 			interval;
};

struct ucdif
{
	struct ucdif	*next;

	long		api_version;

	long		class;
	char		*lname;
	char		name[UCD_NAMSIZ];
	short		unit;

	unsigned short	flags;

	long		(*open)		(struct ucdif *);
	long		(*close)	(struct ucdif *);
	long		resrvd1;	/* (*output)  */
	long		(*ioctl)	(struct ucdif *, short cmd, long arg);
	long		resrvd2;	/* (*timeout) */
	long		*ucd_priv;	/* host controller driver private data */
};


/*
 * UDD - USB Device Driver.
 */
#define UDD_OPEN	1
#define UDD_NAMSIZ	16	/* maximum ucd name len */

#define USB_DEVICE	0

struct uddif
{
	struct uddif	*next;

	long		api_version;

	long		class;
	char		*lname;
	char		name[UDD_NAMSIZ];
	short		unit;

	unsigned short	flags;

	long		(*probe)	(struct usb_device *, unsigned int ifnum);
	long		(*disconnect)	(struct usb_device *);
	long		resrvd1;	/* (*output)  */
	long		(*ioctl)	(struct uddif *, short cmd, long arg);
	long		resrvd2;	/* (*timeout) */
};

struct usb_module_api
{
	/* versioning */
	long 				api_version;
	long				max_devices;
	long				max_hubs;

//	short				(*getfreeunit)		(char *);
	long			_cdecl	(*udd_register)		(struct uddif *);
	long			_cdecl	(*udd_unregister)	(struct uddif *);
	long			_cdecl	(*ucd_register)		(struct ucdif *, struct usb_device **);
	long			_cdecl	(*ucd_unregister)	(struct ucdif *);

	void			_cdecl	(*usb_rh_wakeup)	(struct ucdif *);
	long			_cdecl	(*usb_hub_events)	(struct usb_hub_device *dev);
	long			_cdecl	(*usb_set_protocol)	(struct usb_device *dev, long ifnum, long protocol);
	long			_cdecl	(*usb_set_idle)		(struct usb_device *dev, long ifnum, long duration,
								long report_id);
	struct usb_device *	_cdecl	(*usb_get_dev_index)	(long idx);
	struct usb_hub_device *	_cdecl	(*usb_get_hub_index)	(long idx);
	long 			_cdecl	(*usb_control_msg)	(struct usb_device *dev, unsigned long pipe,
								unsigned char request, unsigned char requesttype,
								unsigned short value, unsigned short idx,
								void *data, unsigned short size, long timeout);
	long			_cdecl	(*usb_bulk_msg)		(struct usb_device *dev, unsigned long pipe,
								void *data, long len, long *actual_length, long timeout, long flags);
	long 			_cdecl	(*usb_submit_int_msg)	(struct usb_device *dev, unsigned long pipe,
								void *buffer, long transfer_len, long interval);
	long 			_cdecl	(*usb_disable_asynch)	(long disable);
	long			_cdecl	(*usb_maxpacket)	(struct usb_device *dev, unsigned long pipe);
	long			_cdecl	(*usb_get_configuration_no)	(struct usb_device *dev, long cfgno);
	long			_cdecl	(*usb_get_report)	(struct usb_device *dev, long ifnum, unsigned char type,
								unsigned char id, void *buf, long size);
	long 			_cdecl	(*usb_get_class_descriptor)	(struct usb_device *dev, long ifnum,
									unsigned char type, unsigned char id, void *buf,
									long size);
	long 			_cdecl	(*usb_clear_halt)	(struct usb_device *dev, long pipe);
	long 			_cdecl	(*usb_string)		(struct usb_device *dev, long idx, char *buf, long size);
	long 			_cdecl	(*usb_set_interface)	(struct usb_device *dev, long interface, long alternate);
	long			_cdecl	(*usb_parse_config)	(struct usb_device *dev, unsigned char *buffer, long cfgno);
	long 			_cdecl	(*usb_set_maxpacket)	(struct usb_device *dev);
	long 			_cdecl	(*usb_get_descriptor)	(struct usb_device *dev, unsigned char type,
								unsigned char idx, void *buf, long size);
	long 			_cdecl	(*usb_set_address)	(struct usb_device *dev);
	long 			_cdecl	(*usb_set_configuration)(struct usb_device *dev, long configuration);
	long 			_cdecl	(*usb_get_string)	(struct usb_device *dev, unsigned short langid,
			   					unsigned char idx, void *buf, long size);
	struct usb_device *	_cdecl	(*usb_alloc_new_device) (void *controller);
	long 			_cdecl	(*usb_new_device)	(struct usb_device *dev);
	
	/* For now we leave this hub specific stuff out of the api */
//	long 			_cdecl	(*usb_get_hub_descriptor)	(struct usb_device *dev, void *data, long size);
//	long 			_cdecl	(*usb_clear_port_feature)	(struct usb_device *dev, long port, long feature);
//	long 			_cdecl	(*usb_get_hub_status)	(struct usb_device *dev, void *data);
//	long 			_cdecl	(*usb_set_port_feature)	(struct usb_device *dev, long port, long feature);
//	long 			_cdecl	(*usb_get_port_status)	(struct usb_device *dev, long port, void *data);
//	struct usb_hub_device *	_cdecl	(*usb_hub_allocate)	(void);
//	void 			_cdecl	(*usb_hub_port_connect_change)	(struct usb_device *dev, long port);
//	long 			_cdecl	(*usb_hub_configure)	(struct usb_device *dev);
};

#ifndef MAINUSB
#define	udd_register 		(*api->udd_register)
#define	udd_unregister 		(*api->udd_unregister)
#define	ucd_register 		(*api->ucd_register)
#define	ucd_unregister 		(*api->ucd_unregister)
//#define	fname 			(*api->fname)

#define usb_rh_wakeup		(*api->usb_rh_wakeup)
#define usb_hub_events		(*api->usb_hub_events)
#define	usb_set_protocol 	(*api->usb_set_protocol)
#define	usb_set_idle 		(*api->usb_set_idle)
#define	usb_get_dev_index 	(*api->usb_get_dev_index)
#define	usb_get_hub_index 	(*api->usb_get_hub_index)
#define	usb_control_msg 	(*api->usb_control_msg)
#define	usb_bulk_msg 		(*api->usb_bulk_msg)
#define	usb_submit_int_msg 	(*api->usb_submit_int_msg)
#define	usb_disable_asynch 	(*api->usb_disable_asynch)
#define	usb_maxpacket 		(*api->usb_maxpacket)
#define	usb_get_configuration_no 	(*api->usb_get_configuration_no)
#define	usb_get_report 		(*api->usb_get_report)
#define	usb_get_class_descriptor 	(*api->usb_get_class_descriptor)
#define	usb_clear_halt 		(*api->usb_clear_halt)
#define	usb_string 		(*api->usb_string)
#define	usb_set_interface 	(*api->usb_set_interface)
#define	usb_parse_config 	(*api->usb_parse_config)
#define	usb_set_maxpacket 	(*api->usb_set_maxpacket)
#define	usb_get_descriptor 	(*api->usb_get_descriptor)
#define	usb_set_address 	(*api->usb_set_address)
#define	usb_set_configuration 	(*api->usb_set_configuration)
#define	usb_get_string 		(*api->usb_get_string)
#define	usb_alloc_new_device 	(*api->usb_alloc_new_device)
#define	usb_new_device 		(*api->usb_new_device)

/* For now we leave this hub specific
 * stuff out of the api.
 */	
//#define	usb_get_hub_descriptor 	(*api->usb_get_hub_descriptor)
//#define	usb_clear_port_feature 	(*api->usb_clear_port_feature)
//#define	usb_clear_hub_feature 	(*api->usb_clear_hub_feature)
//#define	usb_get_hub_status 	(*api->usb_get_hub_status)
//#define	usb_set_port_feature 	(*api->usb_set_port_feature)
//#define	usb_get_port_status 	(*api->usb_get_port_status)
//#define	usb_hub_allocate 	(*api->usb_hub_allocate)
//#define	usb_hub_port_connect_change 	(*api->usb_hub_port_connect_change)
//#define	usb_hub_configure 	(*api->usb_hub_configure)	
#endif

#endif /* usb_api_h */
