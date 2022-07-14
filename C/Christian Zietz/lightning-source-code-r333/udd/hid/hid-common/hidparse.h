/*	HID parser
 *
 *	This file is distributed under the GPL, version 2 or at your
 *	 option any later version.	See /COPYING.GPL for details.
 *
 *						 Author: Benjamin David Lunt
 *										 Forever Young Software
 *										 Copyright 1984-2014
 *
 *	Modified by Claude Labelle for use in the FreeMiNT USB mouse and keyboard drivers.
 *
 *	The original code is available on a CD accompanying the book
 *	 "USB: The Universal Serial Bus" by Benjamin David Lunt, see
 *	 http://www.fysnet.net/the_universal_serial_bus.htm
 *
 *	Original USB specifications can be found at:
 *	 https://www.usb.org/documents?search=hid&items_per_page=50
 *
 *	This code is heavily based on the code found at www.usb.org under the HID
 *	 developers section.
 *
 */

#ifndef _HIDPARSE_H_

/* standard true and false */
#define TRUE	 1
#define FALSE	 0

/* size of memory operands */
typedef	signed char				BOOL;
typedef	signed char				bit8s;
typedef unsigned char			bit8u;
typedef	signed short			bit16s;
typedef unsigned short			bit16u;
typedef	signed long				bit32s;
typedef unsigned long			bit32u;

#define PATH_SIZE				10 		/* maximum depth for Path */
#define USAGE_TAB_SIZE			50 		/* Size of usage stack */
#define MAX_REPORT				300 	/* Including FEATURE, INPUT and OUTPUT */

#define SIZE_0					0x00
#define SIZE_1					0x01
#define SIZE_2					0x02
#define SIZE_4					0x03
#define SIZE_MASK				0x03


#define TYPE_MAIN				0x00
#define TYPE_GLOBAL				0x04
#define TYPE_LOCAL				0x08
#define TYPE_MASK				0xC0


#define ITEM_MASK				0xFC

#define ITEM_UPAGE				0x04
#define ITEM_USAGE				0x08	/* local item */
#define ITEM_LOG_MIN			0x14
#define ITEM_USAGE_MIN			0x18	/* local item */
#define ITEM_LOG_MAX			0x24
#define ITEM_USAGE_MAX			0x28	/* local item */
#define ITEM_PHY_MIN			0x34
#define ITEM_PHY_MAX			0x44
#define ITEM_UNIT_EXP			0x54
#define ITEM_UNIT				0x64
#define ITEM_REP_SIZE			0x74
#define ITEM_STRING				0x78	/* local item? */
#define ITEM_REP_ID				0x84
#define ITEM_REP_COUNT			0x94

#define ITEM_COLLECTION			0xA0
#define ITEM_END_COLLECTION		0xC0
#define ITEM_FEATURE			0xB0
#define ITEM_INPUT				0x80
#define ITEM_OUTPUT				0x90


/* Attribute Flags */
#define ATTR_DATA_CST			0x01
#define ATTR_NVOL_VOL			0x80

/* Describe a HID Path point */
struct HID_NODE {
	bit16u	 u_page;
	bit16u	 usage;
};

/* Describe a HID Path */
struct HID_PATH {
	bit8u			size;				/* HID Path size */
	struct HID_NODE node[PATH_SIZE];	/* HID Path */
};

/* Describe a HID Data with its location in report */
struct HID_DATA {
	bit32s			value;				/* HID Object Value */
	struct HID_PATH path;				/* HID Path */

	bit8u			report_id;			/* Report ID, (from incoming report) ??? */
	bit8u			report_id_used;		/* 0 = no report id byte, 1 = yes */
	bit8u			offset;				/* Offset of data in report */
	bit8u			size;				/* Size of data in bits */

	bit8u			type;				/* Type : FEATURE / INPUT / OUTPUT */
	bit8u			attribute;			/* Report field attribute (type of type above. 2 = data, variable, absolute, bitfield, etc.) */

	bit32u			unit;				/* HID Unit */
	bit8s			unit_exp;			/* Unit exponent */

	bit32s			log_min;			/* Logical Min */
	bit32s			log_max;			/* Logical Max */
	bit32s			phy_min;			/* Physical Min */
	bit32s			phy_max;			/* Physical Max */
};

struct HID_PARSER {
	const bit8u 	*report_desc;		/* Store Report Descriptor */
	bit16u			report_desc_size;	/* Size of Report Descriptor */
	bit16u			pos;				/* Store current pos in descriptor */
	bit8u			item;				/* Store current Item */
	bit32s			value;				/* Store current Value */

	struct HID_DATA data;				/* Store current environment */

	bit8u		 	offset_table[MAX_REPORT][3];	/* Store ID, type & offset of report */
	bit8u		 	report_count;		/* Store Report Count */
	bit8u		 	count;				/* Store local report count */

	bit16u	 		u_page;				/* Global UPage */
	struct HID_NODE usage_table[USAGE_TAB_SIZE]; 	/* Usage stack */
	bit8u			usage_size;			/* Design number of usage used */
	bit32s			usage_min;
	bit32s			usage_max;

	bit8u			cnt_object;			/* Count objects in Report Descriptor */
	bit8u			cnt_report;			/* Count reports in Report Descriptor */
};


BOOL hid_parse_report(const bit8u *, const bit16u);
BOOL hid_parse(struct HID_PARSER *, struct HID_DATA *);
void reset_parser(struct HID_PARSER *);
BOOL find_object(struct HID_PARSER *, struct HID_DATA *);
BOOL find_usage(struct HID_PARSER *, struct HID_NODE *, struct HID_DATA *);

/* helpers */
char *spaces(unsigned);
const char *hid_print_usage_type(unsigned);
const char *hid_print_usage(unsigned, unsigned);
const char *hid_print_collection(unsigned);

#endif
