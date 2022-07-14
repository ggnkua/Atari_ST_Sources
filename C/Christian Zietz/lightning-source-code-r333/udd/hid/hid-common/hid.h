/*
 * USB HID descriptor routines
 *
 * Copyright (C) 2019 by Christian Zietz
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See /COPYING.GPL for details.
 */

#ifndef _HID_H_
#define _HID_H_

/* Usage pages */
#define U_PAGE_UNDEFINED	0x00
#define U_PAGE_DESKTOP		0x01
#define U_PAGE_SIMULATION	0x02
#define U_PAGE_VR			0x03
#define U_PAGE_SPORT		0x04
#define U_PAGE_GAME			0x05
#define U_PAGE_DEVICE		0x06
#define U_PAGE_KEYBOARD		0x07
#define U_PAGE_LED			0x08
#define U_PAGE_BUTTON		0x09
#define U_PAGE_ORDINAL		0x0A
#define U_PAGE_TELEPHONY	0x0B
#define U_PAGE_CONSUMER		0x0C
#define U_PAGE_DIGITIZER	0x0D

/* Desktop usage */
#define USAGE_UNDEFINED		0x00
#define USAGE_POINTER		0x01
#define USAGE_MOUSE			0x02
#define USAGE_JOYSTICK		0x04
#define USAGE_GAME_PAD		0x05
#define USAGE_KEYBOARD		0x06
#define USAGE_KEYPAD		0x07
#define USAGE_X				0x30
#define USAGE_Y				0x31
#define USAGE_Z				0x32
#define USAGE_SLIDER		0x36
#define USAGE_DIAL			0x37
#define USAGE_WHEEL			0x38
#define USAGE_HAT_SWITCH	0x39
#define USAGE_AC_PAN		0x238

/* Digitizer usage */
#define USAGE_TIP_PRESSURE	0x30
#define USAGE_IN_RANGE		0x32
#define USAGE_QUALITY		0x36
#define USAGE_FUNCTION_KEYS	0x39
#define USAGE_TIP_SWITCH	0x42
#define USAGE_BARREL_SWITCH	0x44
#define USAGE_ERASER		0x45

struct usb_class_hid_descriptor {
	unsigned char	bLength;
	unsigned char	bbDescriptorType;
	unsigned short	bbcdCDC;
	unsigned char	bbCountryCode;
	unsigned char	bbNumDescriptors;	/* assumed 0x01 */
	unsigned char	bbDescriptorType0;
	unsigned short	wDescriptorLength0;
	/* optional descriptors are not supported. */
} __attribute__((packed));

/* Precalculated values for easier bit extraction. */
struct extract_bits {
	unsigned short start_byte; /* first byte to copy */
	unsigned short end_byte;   /* last byte to copy */
	unsigned short shift;      /* right shift amount */
	unsigned long mask;        /* AND mask *after* shift */
	unsigned long sign_ext;    /* mask for sign extension */
	unsigned char report_id_used;
	unsigned char report_id;
};

long hid_get_report_desc_len(struct usb_device *dev, unsigned int ifnum);
long hid_get_report_desc(struct usb_device *dev, unsigned int ifnum, unsigned char* buff, long len);
long hid_get_data(unsigned char* report, struct extract_bits *ext);
void fill_extract_bits(struct extract_bits *ext, unsigned int offset, unsigned int len, unsigned int is_signed, unsigned char report_id_used, unsigned char report_id);

#endif
