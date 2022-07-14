/*
 * Aranym USB (virtual) Controller Driver.
 *
 * Copyright (c) 2012 David Galvez.
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */

#ifndef _ARANYM_H
#define _ARANYM_H

/*--- Includes ---*/

/* --- USB HUB constants -------------------- */

/* destination of request */
#define RH_INTERFACE               0x01
#define RH_ENDPOINT                0x02
#define RH_OTHER                   0x03

#define RH_CLASS                   0x20
#define RH_VENDOR                  0x40

/* Requests: bRequest << 8 | bmRequestType */
#define RH_GET_STATUS           0x0080
#define RH_CLEAR_FEATURE        0x0100
#define RH_SET_FEATURE          0x0300
#define RH_SET_ADDRESS          0x0500
#define RH_GET_DESCRIPTOR       0x0680
#define RH_SET_DESCRIPTOR       0x0700
#define RH_GET_CONFIGURATION    0x0880
#define RH_SET_CONFIGURATION    0x0900
#define RH_GET_STATE            0x0280
#define RH_GET_INTERFACE        0x0A80
#define RH_SET_INTERFACE        0x0B00
#define RH_SYNC_FRAME           0x0C80
/* Our Vendor Specific Request */
#define RH_SET_EP               0x2000

/* Hub port features */
#define RH_PORT_CONNECTION         0x00
#define RH_PORT_ENABLE             0x01
#define RH_PORT_SUSPEND            0x02
#define RH_PORT_OVER_CURRENT       0x03
#define RH_PORT_RESET              0x04
#define RH_PORT_POWER              0x08
#define RH_PORT_LOW_SPEED          0x09

#define RH_C_PORT_CONNECTION       0x10
#define RH_C_PORT_ENABLE           0x11
#define RH_C_PORT_SUSPEND          0x12
#define RH_C_PORT_OVER_CURRENT     0x13
#define RH_C_PORT_RESET            0x14

/* HcRhPortStatus */
#define		RH_PS_CCS	(1UL << 0)	/* current connect status */
#define		RH_PS_PES	(1UL << 1)	/* port enable status */
#define		RH_PS_PSS	(1UL << 2)	/* port suspend status */
#define		RH_PS_POCI	(1UL << 3)	/* port over current indicator */
#define		RH_PS_PRS	(1UL << 4)	/* port reset status */
#define		RH_PS_PPS	(1UL << 8)	/* port power status */
#define		RH_PS_LSDA	(1UL << 9)	/* low:1 speed device attached */
#define		RH_PS_FSDA	(1UL << 10)	/* full:0 high:1 speed device attached */
#define		RH_PS_CSC	(1UL << 16)	/* connect status change */
#define		RH_PS_PESC	(1UL << 17)	/* port enable status change */
#define		RH_PS_PSSC	(1UL << 18)	/* port suspend statuschange */
#define		RH_PS_OCIC	(1UL << 19)	/* over current indicatorchange */
#define		RH_PS_PRSC	(1UL << 20)	/* port reset status change */


/* Hub features */
#define RH_C_HUB_LOCAL_POWER       0x00
#define RH_C_HUB_OVER_CURRENT      0x01

#define RH_DEVICE_REMOTE_WAKEUP    0x00
#define RH_ENDPOINT_STALL          0x01

#define RH_ACK                     0x01
#define RH_REQ_ERR                 -1
#define RH_NACK                    0x00

#define NUMBER_OF_PORTS		2


/*--- Types ---*/

typedef struct {
	unsigned char port_number;
	unsigned char device_index;
	long interface;
	unsigned short busy;
	unsigned short wPortStatus;
	unsigned short wPortChange;
} port_t;

typedef struct {
	port_t port[NUMBER_OF_PORTS];
	unsigned char number_of_roothub;
} roothub_t;


/*--- Low level API functions that need to be supported ---*/
/*

	int usb_lowlevel_init(void *ucd_priv)

	int usb_lowlevel_stop(void *ucd_priv)

	int submit_int_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
			   long len, int interval)

	int submit_control_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
			       long len, struct devrequest *setup)

	int submit_bulk_msg(struct usb_device *dev, unsigned long pipe, void *buffer,
			    long len, long flags, unsigned long timeout)
*/

#endif /* _ARANYM_H */
