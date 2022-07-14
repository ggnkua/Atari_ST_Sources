/*	HID parser
 *
 *	This file is distributed under the GPL, version 2 or at your
 *	 option any later version.	See /COPYING.GPL for details.
 *
 *				 Author: Benjamin David Lunt
 *						 Forever Young Software
 *						 Copyright 1984-2014
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


#include "../../../global.h"
#include "mint/endian.h"

#include "hidparse.h"

#if 0
BOOL hid_parse_report(const bit8u *rep, const bit16u len) {

	struct HID_PARSER parser;
	struct HID_DATA data;
	BOOL ret;

reset_parser(&parser);
	parser.report_desc = rep;
	parser.report_desc_size = len;

	ret = hid_parse(&parser, &data);
	while (ret)
	ret = hid_parse(&parser, &data);

	return TRUE;
}
#endif

const char item_size[4] = { 0, 1, 2, 4 };

void reset_parser(struct HID_PARSER *parser) {
	parser->pos = 0;
	parser->count = 0;
	parser->cnt_object = 0;
	parser->cnt_report = 0;

	parser->usage_size = 0;
	parser->usage_min = -1;
	parser->usage_max = -1;
	memset(parser->usage_table, 0, sizeof(struct HID_NODE) * USAGE_TAB_SIZE);

	memset(parser->offset_table, 255, MAX_REPORT * 3);
	memset(&parser->data, 0, sizeof(struct HID_DATA));
}

static bit8u *get_report_offset(struct HID_PARSER *parser, const bit8u report_id, const bit8u report_type) {

	bit16u pos=0;
	while ((pos < MAX_REPORT) && (parser->offset_table[pos][0] != 255)) {
		if ((parser->offset_table[pos][0] == report_id) && (parser->offset_table[pos][1] == report_type))
			return &parser->offset_table[pos][2];
		pos++;
	}
	if (pos < MAX_REPORT) {
		/* Increment Report count */
		parser->cnt_report++;
		parser->offset_table[pos][0] = report_id;
		parser->offset_table[pos][1] = report_type;
		parser->offset_table[pos][2] = 0;
		return &parser->offset_table[pos][2];
	}
	return NULL;
}

static bit32s format_value(bit32s value, bit8u size) {
	if (size == 1)
		value = (bit32s) (bit8s) value;
	else if (size == 2)
		value = (bit32s) (bit16s) value;
	return value;
}

BOOL hid_parse(struct HID_PARSER *parser, struct HID_DATA *data) {
	BOOL found = FALSE;
	static unsigned space_cnt = 0;
	static BOOL did_collection = FALSE;
	int t;

	while (!found && (parser->pos < parser->report_desc_size)) {
		/* Get new parser->item if current parser->count is empty */
		if (parser->count == 0) {
			DEBUG(("\n %02X ", parser->report_desc[parser->pos]));
			parser->item = parser->report_desc[parser->pos++];
			parser->value = 0;
			memcpy(&parser->value, &parser->report_desc[parser->pos], item_size[parser->item & SIZE_MASK]);
			parser->value = le2cpu32(parser->value);
			for (t=0; t<4; t++) {
			if (t < item_size[parser->item & SIZE_MASK])
				DEBUG(("%02X ", parser->report_desc[parser->pos + t]));
			else
				DEBUG(("	 "));
			}
			/* Pos on next item */
			parser->pos += item_size[parser->item & SIZE_MASK];
		}

		if (!(((parser->item & ITEM_MASK) == ITEM_FEATURE) || ((parser->item & ITEM_MASK) == ITEM_INPUT) || ((parser->item & ITEM_MASK) == ITEM_OUTPUT)))
			did_collection = FALSE;

		switch (parser->item & ITEM_MASK) {
			case ITEM_UPAGE:
				/* Copy upage in usage stack */
				parser->u_page = (bit16u) parser->value;
				DEBUG(("%sUsage Page (%s)", spaces(space_cnt), hid_print_usage_type(parser->u_page)));
			break;

			case ITEM_USAGE:
				/* Copy global or local u_page if any, in usage stack */
				if ((parser->item & SIZE_MASK) > 2)
					parser->usage_table[parser->usage_size].u_page = (bit16u) (parser->value >> 16);
				else
					parser->usage_table[parser->usage_size].u_page = parser->u_page;

				/* Copy Usage in Usage stack */
				parser->usage_table[parser->usage_size].usage = (bit16u) (parser->value & 0xFFFF);
				DEBUG(("%sUsage (%s)", spaces(space_cnt), hid_print_usage(parser->u_page, (bit16u) (parser->value & 0xFFFF))));

				/* Increment Usage stack size */
				parser->usage_size++;
			break;

			case ITEM_USAGE_MIN:
				/* Copy global or local u_page if any, in usage stack */
				if ((parser->item & SIZE_MASK) > 2)
					parser->usage_table[parser->usage_size].u_page = (bit16u) (parser->value >> 16);
				else
					parser->usage_table[parser->usage_size].u_page = parser->u_page;

				/* TODO: is usage_min and max done this way, and are they bit32s or smaller? */
				parser->usage_min = format_value(parser->value, item_size[parser->item & SIZE_MASK]);
				DEBUG(("%sUsage min (%li)", spaces(space_cnt), parser->usage_min));
			break;

			case ITEM_USAGE_MAX:
				/* Copy global or local u_page if any, in usage stack */
				if ((parser->item & SIZE_MASK) > 2)
					parser->usage_table[parser->usage_size].u_page = (bit16u) (parser->value >> 16);
				else
					parser->usage_table[parser->usage_size].u_page = parser->u_page;

				parser->usage_max = format_value(parser->value, item_size[parser->item & SIZE_MASK]);
				DEBUG(("%sUsage max (%li)", spaces(space_cnt), parser->usage_max));
			break;

			case ITEM_COLLECTION:
				/* Get UPage/Usage from usage_table and store them in parser->Data.Path */
				parser->data.path.node[parser->data.path.size].u_page = parser->usage_table[0].u_page;
				parser->data.path.node[parser->data.path.size].usage = parser->usage_table[0].usage;
				parser->data.path.size++;

				/* Unstack u_page/Usage from usage_table (never remove the last) */
				if (parser->usage_size > 0) {
					bit8u ii=0;
					while (ii < parser->usage_size) {
						parser->usage_table[ii].usage = parser->usage_table[ii+1].usage;
						parser->usage_table[ii].u_page = parser->usage_table[ii+1].u_page;
						ii++;
					}
					/* Remove Usage */
					parser->usage_size--;
				}

				/* Get Index if any */
				if (parser->value >= 0x80) {
					parser->data.path.node[parser->data.path.size].u_page = 0xFF;
					parser->data.path.node[parser->data.path.size].usage = (bit16u) (parser->value & 0x7F);
					parser->data.path.size++;
				}

				DEBUG(("%sCollection (%s)", spaces(space_cnt), hid_print_collection(parser->value)));
				space_cnt += 2;
			break;

			case ITEM_END_COLLECTION:
				parser->data.path.size--;
				/* Remove Index if any */
				if (parser->data.path.node[parser->data.path.size].u_page == 0xFF)
					parser->data.path.size--;

				if (space_cnt >= 2) space_cnt -= 2;
				DEBUG(("%sEnd Collection", spaces(space_cnt)));
			break;

			case ITEM_FEATURE:
			case ITEM_INPUT:
			case ITEM_OUTPUT:
				/* An object was found */
				found = TRUE;

				/* Increment object count */
				parser->cnt_object++;

				/* Get new parser->Count from global value */
				if (parser->count == 0)
					parser->count = parser->report_count;

				/* Get u_page/Usage from usage_table and store them in parser->Data.Path */
				parser->data.path.node[parser->data.path.size].u_page = parser->usage_table[0].u_page;
				parser->data.path.node[parser->data.path.size].usage = parser->usage_table[0].usage;
				parser->data.path.size++;

				/* Unstack u_page/Usage from usage_table (never remove the last) */
				if (parser->usage_size > 0) {
					bit8u ii = 0;
					while (ii < parser->usage_size) {
						parser->usage_table[ii].u_page = parser->usage_table[ii+1].u_page;
						parser->usage_table[ii].usage = parser->usage_table[ii+1].usage;
						ii++;
					}
					/* Remove Usage */
					parser->usage_size--;
				}

				/* Copy data type */
				parser->data.type = (bit8u) (parser->item & ITEM_MASK);

				/* Copy data attribute */
				parser->data.attribute = (bit8u) parser->value;

				/* Store offset */
				parser->data.offset = *get_report_offset(parser, parser->data.report_id, (bit8u) (parser->item & ITEM_MASK));

				/* copy to data */
				memcpy(data, &parser->data, sizeof(struct HID_DATA));

				/* Increment Report Offset */
				*get_report_offset(parser, parser->data.report_id, (bit8u) (parser->item & ITEM_MASK)) += parser->data.size;

				/* Remove path last node */
				parser->data.path.size--;

				/* Decrement count */
				parser->count--;

				if (!did_collection) {
					if ((parser->item & ITEM_MASK) == ITEM_FEATURE)
						DEBUG(("%sFeature ", spaces(space_cnt)));
					if ((parser->item & ITEM_MASK) == ITEM_INPUT)
						DEBUG(("%sInput ", spaces(space_cnt)));
					if ((parser->item & ITEM_MASK) == ITEM_OUTPUT)
						DEBUG(("%sOutput ", spaces(space_cnt)));
					DEBUG(("(%s,%s,%s,%s,%s,%s,%s,%s)", !(parser->value & (1<<0)) ? "Data"	 : "Cons",
													 !(parser->value & (1<<1)) ? "Array"	: "Var",
													 !(parser->value & (1<<2)) ? "Abs"		: "Rel",
													 !(parser->value & (1<<3)) ? "NoW"		: "Wrap",
													 !(parser->value & (1<<4)) ? "Lin"		: "NonLin",
													 !(parser->value & (1<<5)) ? "PState" : "NoPre",
													 !(parser->value & (1<<6)) ? "NoNull" : "Null",
													 !(parser->value & (1<<8)) ? "Bit"		: "Buff"));
					did_collection = TRUE;
				}
			break;

			case ITEM_REP_ID:
				parser->data.report_id = (bit8u) parser->value;
				parser->data.report_id_used = 1;
				DEBUG(("%sreport ID (%i)", spaces(space_cnt), (bit8u) parser->value));
			break;

			case ITEM_REP_SIZE:
				parser->data.size = (bit8u) parser->value;
				DEBUG(("%sreport size (%i)", spaces(space_cnt), parser->data.size));
			break;

			case ITEM_REP_COUNT:
				parser->report_count = (bit8u) parser->value;
				DEBUG(("%sreport count (%i)", spaces(space_cnt), parser->report_count));
			break;

			case ITEM_UNIT_EXP:
				parser->data.unit_exp = (bit8s) parser->value;
					/* convert 4 bits signed value to 8 bits signed value */
				if (parser->data.unit_exp > 7)
					parser->data.unit_exp |= 0xF0;
				DEBUG(("%sUnit Exp (%i)", spaces(space_cnt), parser->data.unit_exp));
			break;

			case ITEM_UNIT:
				parser->data.unit = parser->value;
				if (parser->data.unit == 0)
					DEBUG(("%sUnit (none)", spaces(space_cnt)));
				else
					DEBUG(("%sUnit (0x%02lX)", spaces(space_cnt), parser->data.unit));
			break;

			case ITEM_LOG_MIN:
				parser->data.log_min = format_value(parser->value, item_size[parser->item & SIZE_MASK]);
				DEBUG(("%sLogical Min (%li)", spaces(space_cnt), parser->data.log_min));
			break;

			case ITEM_LOG_MAX:
				parser->data.log_max = format_value(parser->value, item_size[parser->item & SIZE_MASK]);
				DEBUG(("%sLogical Max (%li)", spaces(space_cnt), parser->data.log_max));
			break;

			case ITEM_PHY_MIN:
				parser->data.phy_min = format_value(parser->value, item_size[parser->item & SIZE_MASK]);
				DEBUG(("%sPhysical Min (%li)", spaces(space_cnt), parser->data.phy_min));
			break;

			case ITEM_PHY_MAX:
				parser->data.phy_max = format_value(parser->value, item_size[parser->item & SIZE_MASK]);
				DEBUG(("%sPhysical Max (%li)", spaces(space_cnt), parser->data.phy_max));
			break;

			default:
				DEBUG(("\n Found unknown item 0x%02X", (parser->item & ITEM_MASK)));
		}
	}

	return found;
}

#if 0
BOOL find_object(struct HID_PARSER *parser, struct HID_DATA *data) {
	struct HID_DATA found_data;
	reset_parser(parser);
	while (hid_parse(parser, &found_data)) {
		if ((data->path.size > 0) && (found_data.type == data->type) &&
			memcmp(found_data.path.node, data->path.node, (data->path.size) * sizeof(struct HID_NODE)) == 0) {
			memcpy(data, &found_data, sizeof(struct HID_DATA));
			return TRUE;
		}
		/* Found by ReportID/Offset */
		/*
		 else if ((found_data.report_id == data->report_id) && (found_data.type == data->type) && (found_data.offset == data->offset)) {
		 memcpy(data, &found_data, sizeof(struct HID_DATA));
		 return TRUE;
		 }*/
	}
	return FALSE;
}
#endif

BOOL find_usage(struct HID_PARSER *parser, struct HID_NODE *node, struct HID_DATA *data) {
	struct HID_DATA found_data;
	reset_parser(parser);
	while (hid_parse(parser, &found_data)) {
		if (found_data.type == ITEM_INPUT &&
			memcmp(&found_data.path.node[found_data.path.size - 1], node, sizeof(struct HID_NODE)) == 0) {
			memcpy(data, &found_data, sizeof(struct HID_DATA));
			return TRUE;
		}
	}
	return FALSE;
}

#ifdef DEV_DEBUG
char spaces_buff[33];

char *spaces(unsigned cnt) {
	/* just incase we have a bad descriptor that has many nested collections */
	cnt &= (32-1);

	memset(spaces_buff, ' ', 32);
	spaces_buff[cnt] = '\0';
	return spaces_buff;
}

#define MAX_STRING_LENGTH	64
/* Macro used to check that we don't go out of array's bounds */
#define USAGE_TYPE_STR_ARRAY_MEMBERS	(sizeof(usage_type_str)/MAX_STRING_LENGTH)

const char usage_type_str[][MAX_STRING_LENGTH] = {
	"Undefined", "Generic Desktop", "Simulation", "VR", "Sport", "Game",
	"Generic Device", "Keyboard/Keypad", "LEDs", "Button", "Ordinal", "Telephony", "Consumer", "Digitizer",
	"Reserved", "PID Page", "Unicode", "Reserved", "Reserved", "Reserved", "Alphanumeric Display",

	/* offset 0x15 */
	"Medical Insturments", "Monitor Pages", "Power Pages",

	"Bar Code Scanner page", "Scale page", "Magnetic Stripe Reading (MSR) Devices", "Reserved Point of Sale pages",
	"Camera Control Page" , "Arcade Page"
};

char usage_type_vendor_str[MAX_STRING_LENGTH];

const char *hid_print_usage_type(unsigned type) {
	if (type > USAGE_TYPE_STR_ARRAY_MEMBERS)
		return "usage_type_str array index out of bounds";

	if (type <= 0x14)
		return usage_type_str[type];
	else if (type <= 0x3F)
		return usage_type_str[0x13];
	else if (type <= 0x40)
		return usage_type_str[0x15];
	else if (type <= 0x7F)
		return usage_type_str[0x13];
	else if (type <= 0x83)
		return usage_type_str[0x16];
	else if (type <= 0x87)
		return usage_type_str[0x17];
	else if (type <= 0x8B)
		return usage_type_str[0x13];
	else if (type <= 0x91)
		return usage_type_str[type - 24];
	else if (type <= 0xFEFF)
		return usage_type_str[0x13];
	else {
		/* 	sprintf(usage_type_vendor_str, "Vendor Defined: 0x%02X", type & 0x00FF);
			return usage_type_vendor_str; */
		return "Vendor Defined.";
	}
}

const char usage_str_page_1[][MAX_STRING_LENGTH] = {
	"Undefined", "Pointer", "Mouse", "Reserved", "Joystick", "Game Pad", "Keyboard", "Keypad", "Multi-axis Controller"
	"Tablet PC System Controls",

	"X", "Y", "Z", "Rx", "Ry", "Rz", "Slider", "Dial", "Wheel", "Hat switch", "Counted Buffer", "Byte Count", "Motion Wakeup",
	"Start", "Select", "Reserved", "Vx", "Vy", "Vz", "Vbrx", "Vbry", "Vbrz", "Vno", "Feature Notification",
	"Resolution Multiplier",

	"System Control", "System Power Down", "System Sleep", "System Wake Up", "System Context Menu", "System Main Menu",
	"System App Menu", "System Menu Help", "System Menu Exit", "System Menu Select", "System Menu Right", "System Menu Left",
	"System Menu Up", "System Menu Down", "System Cold Restart", "System Warm Restart", "D-pad Up", "D-pad Down",
	"D-pad Right", "D-pad Left", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "System Dock",
	"System Undock", "System Setup", "System Break", "System Debugger Break", "Application Break", "Application Debugger Break",
	"System Speaker Mute", "System Hibernate", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved", "Reserved",
	"System Display Invert", "System Display Internal", "System Display External", "System Display Both", "System Display Dual",
	"System Display Toggle Int/Ext", "System Display Swap", "Primary/Secondary", "System Display LCD Autoscale"
};

const char *hid_print_usage(unsigned page, unsigned type) {
	if (page >= 0xFF00)
		return "Vendor Defined";
	if (type > USAGE_TYPE_STR_ARRAY_MEMBERS)
		return "usage_type_str array index out of bounds";

	switch (page) {
		case 1:
			if (type <= 0x09)
				return usage_str_page_1[type];
			else if (type <= 0x2F)
				return usage_str_page_1[0x03];
			else if (type <= 0x48)
				return usage_str_page_1[type - 39];
			else if (type <= 0x7F)
				return usage_type_str[0x03];
			else if (type <= 0xB7)
				return usage_type_str[type - 39 - 55]; /* may be off by a few */
			else if (type <= 0xFFFF)
				return usage_type_str[0x03];
			else
				return " Error: type > 0xFFFF";
			break;

		default:
			return "Unsupported Usage Page";
	}
}

const char collection_str[][MAX_STRING_LENGTH] = {
	"Physical", "Application", "Logical", "Report", "Named Array", "Usage Switch", "Usage Modifier"
};

const char *hid_print_collection(unsigned val) {
	if (val <= 0x06)
		return collection_str[val];
	else if (val <= 0x7F)
		return "Reserved";
	else if (val <= 0xFF)
		return "Vendor-defined";
	else
		return "Error: val > 0xFF";
}
#endif
