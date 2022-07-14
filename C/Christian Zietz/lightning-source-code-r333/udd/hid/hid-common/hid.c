/*
 * USB HID descriptor routines
 *
 * Copyright (C) 2019 by Christian Zietz
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See /COPYING.GPL for details.
 */

#include "../../../global.h"

#include "../../../usb.h"
#include "../../../usb_api.h"
#include "mint/endian.h"

#include "hid.h"
#include "hidparse.h"

/* --- Local defines to be moved into usb*.h later --- */


/* --- Internal functions and variables ---*/
extern struct usb_module_api *api;

static inline void* internal_malloc(unsigned long size)
{
	return (void*)kmalloc(size);
}

static inline void internal_free(void *p)
{
	if (p != NULL)
		kfree(p);
}

/* Populated from HID report descriptor. */
/*
static struct extract_bits ext_buttons = {0};
static struct extract_bits ext_x = {0};
static struct extract_bits ext_y = {0};
static struct extract_bits ext_wheel = {0};
 */

/* --- Public functions --- */

/* Retrieve configuration descriptor and parse it to find the
 * length of a HID report descriptor, if any.
 * Inputs:
 *   dev: Pointer to the USB device structure.
 *   ifnum: Number of the interface. (Devices may have multiple interfaces.)
 * Returns:
 *   Length of the HID report descriptor in bytes.
 *   0 if there is no descriptor.
 *   <0 in case of error.
 */
long hid_get_report_desc_len(struct usb_device *dev, unsigned int ifnum)
{
	long report_desc_len;
	long result;
	unsigned char* config_buf;
	struct usb_descriptor_header* desc_head;
	unsigned int curr_if;
	long index;

	/* Non-existing interface number. */
	if (ifnum >= dev->config.no_of_if) {
		return -1L;
	}

	/* Not a HID class interface. */
	if (dev->config.if_desc[ifnum].desc.bInterfaceClass != USB_CLASS_HID) {
		return 0L;
	}

	/* Get configuration descriptor. */
	config_buf = internal_malloc(dev->config.desc.wTotalLength);
	if (config_buf == NULL) {
		DEBUG(("hid_get_report_desc_len: kmalloc failed"));
		return -1L;
	}

	result = usb_get_descriptor(dev, USB_DT_CONFIG, 0, config_buf, dev->config.desc.wTotalLength);
	if (result < 0) {
		DEBUG(("hid_get_report_desc_len: unable to get descriptor, error %lx",
			dev->status));
		internal_free(config_buf);
		return -1L;
	}

	/* Parse configuration descriptor, looking for HID descriptor. */
	index = dev->config.desc.bLength;
	report_desc_len = 0;
	curr_if = 0;
	while (index + 1 < result) {
		desc_head = (struct usb_descriptor_header*)(&config_buf[index]);

		DEBUG(("hid_get_report_desc_len: l=%d, t=%x", desc_head->bLength, desc_head->bDescriptorType));
		if (desc_head->bLength == 0) {
			/* Found an erroneous descriptor. */
			break;
		}

		if (desc_head->bDescriptorType == USB_DT_INTERFACE) {
			/* Found an interface descriptor: note it's number. */
			curr_if = ((struct usb_interface_descriptor *)desc_head)->bInterfaceNumber;
		}

		if ((desc_head->bDescriptorType == USB_DT_HID) && (curr_if == ifnum)) {
			/* Found a HID for the requested interface. */
			if (((struct usb_class_hid_descriptor*)desc_head)->bbDescriptorType0 == USB_DT_REPORT) {
				report_desc_len = le2cpu16(((struct usb_class_hid_descriptor*)desc_head)->wDescriptorLength0);
				break; /* No point in search further. */
			}
		}

		index += (long)(desc_head->bLength);
	}

	DEBUG(("hid_get_report_desc_len: returns %ld", report_desc_len));
	internal_free(config_buf);
	return report_desc_len;
}

/* Retrieve HID report descriptor from device.
 * Inputs:
 *   dev: Pointer to the USB device structure.
 *   ifnum: Number of the interface. (Devices may have multiple interfaces.)
 *   buff: Buffer that received the HID report descriptor.
 *   len: Length of the buffer.
 * Returns:
 *   Length of the HID report descriptor actually read.
 *   <0 in case of error.
 */
long hid_get_report_desc(struct usb_device *dev, unsigned int ifnum, unsigned char* buff, long len)
{
	long result;

	/* Non-existing interface number. */
	if (ifnum >= dev->config.no_of_if) {
		return -1L;
	}

	/* Sanity check. */
	if ((buff == NULL) || (len <= 0)) {
		return -1L;
	}

	result = usb_get_class_descriptor(dev, ifnum, USB_DT_REPORT, 0, buff, len);
	DEBUG(("hid_get_report_desc: returns %ld", result));
	return result;
}

/* Get a data item from HID report.
 * Input:
 *   report: Buffer containing the report.
 *   type: Type of data (buttons, x, y, wheel), see hid.h.
 * Returns:
 *   Data from report, 0 in case of failure.
 */
long hid_get_data(unsigned char* report, struct extract_bits *ext)
{
	long value;
	unsigned char *p;
	int k;

	/*
	switch (type) {
		case HID_BUTTONS:
			ext = &ext_buttons;
			break;
		case HID_X:
			ext = &ext_x;
			break;
		case HID_Y:
			ext = &ext_y;
			break;
		case HID_WHEEL:
			ext = &ext_wheel;
			break;
		default:
			return 0L;
	}
	*/

	/* Not present? */
	if (ext->mask == 0UL)
	{
		return 0L;
	}

	/* Check Report ID if used. */
	if (ext->report_id_used) {
		if (report[0] == ext->report_id) {
			report++; /* Skip ID */
		} else {
			return 0L; /* Wrong report ID */
		}
	}

	/* Copy data, little to big endian */
	value = 0L;
	p = ((unsigned char *)&value) + sizeof(value);
	for (k = ext->start_byte; k<= ext->end_byte; k++) {
		*(--p) = report[k];
	}

	/* Shift and mask value */
	value >>= ext->shift;
	value &= ext->mask;

	/* Sign extend */
	if (value & ext->sign_ext)
	{
		value |= ext->sign_ext;
	}

	return value;
}

void fill_extract_bits(struct extract_bits *ext, unsigned int offset, unsigned int len, unsigned int is_signed, unsigned char report_id_used, unsigned char report_id)
{
	ext->start_byte = offset / 8;
	ext->end_byte   = (offset+len) / 8;
	ext->shift      = offset % 8;
	ext->mask       = (1UL << len) - 1;
	if (is_signed) {
		ext->sign_ext = ~(ext->mask >> 1);
	} else {
		ext->sign_ext = 0UL;
	}
	ext->report_id_used = report_id_used;
	ext->report_id = report_id;
}
