#ifndef MOD_DEVICETABLE_H
#define MOD_DEVICETABLE_H

#define PCI_ANY_ID (~0)

struct pci_device_id {
	unsigned long vendor, device;		/* Vendor and device ID or PCI_ANY_ID*/
	unsigned long subvendor, subdevice;	/* Subsystem ID's or PCI_ANY_ID */
	unsigned long class, class_mask;	/* (class,subclass,prog-if) triplet */
	unsigned long driver_data;	/* Data private to the driver */
};

#define IEEE1394_MATCH_VENDOR_ID	0x0001
#define IEEE1394_MATCH_MODEL_ID		0x0002
#define IEEE1394_MATCH_SPECIFIER_ID	0x0004
#define IEEE1394_MATCH_VERSION		0x0008

struct ieee1394_device_id {
	unsigned long match_flags;
	unsigned long vendor_id;
	unsigned long model_id;
	unsigned long specifier_id;
	unsigned long version;
	unsigned long driver_data;
};

/*
 * Device table entry for "new style" table-driven USB drivers.
 * User mode code can read these tables to choose which modules to load.
 * Declare the table as a MODULE_DEVICE_TABLE.
 *
 * A probe() parameter will point to a matching entry from this table.
 * Use the driver_info field for each match to hold information tied
 * to that match:  device quirks, etc.
 *
 * Terminate the driver's table with an all-zeroes entry.
 * Use the flag values to control which fields are compared.
 */

/**
 * struct usb_device_id - identifies USB devices for probing and hotplugging
 * @match_flags: Bit mask controlling of the other fields are used to match
 *	against new devices.  Any field except for driver_info may be used,
 *	although some only make sense in conjunction with other fields.
 *	This is usually set by a USB_DEVICE_*() macro, which sets all
 *	other fields in this structure except for driver_info.
 * @idVendor: USB vendor ID for a device; numbers are assigned
 *	by the USB forum to its members.
 * @idProduct: Vendor-assigned product ID.
 * @bcdDevice_lo: Low end of range of vendor-assigned product version numbers.
 *	This is also used to identify individual product versions, for
 *	a range consisting of a single device.
 * @bcdDevice_hi: High end of version number range.  The range of product
 *	versions is inclusive.
 * @bDeviceClass: Class of device; numbers are assigned
 *	by the USB forum.  Products may choose to implement classes,
 *	or be vendor-specific.  Device classes specify behavior of all
 *	the interfaces on a devices.
 * @bDeviceSubClass: Subclass of device; associated with bDeviceClass.
 * @bDeviceProtocol: Protocol of device; associated with bDeviceClass.
 * @bInterfaceClass: Class of interface; numbers are assigned
 *	by the USB forum.  Products may choose to implement classes,
 *	or be vendor-specific.  Interface classes specify behavior only
 *	of a given interface; other interfaces may support other classes.
 * @bInterfaceSubClass: Subclass of interface; associated with bInterfaceClass.
 * @bInterfaceProtocol: Protocol of interface; associated with bInterfaceClass.
 * @driver_info: Holds information used by the driver.  Usually it holds
 *	a pointer to a descriptor understood by the driver, or perhaps
 *	device flags.
 *
 * In most cases, drivers will create a table of device IDs by using
 * USB_DEVICE(), or similar macros designed for that purpose.
 * They will then export it to userspace using MODULE_DEVICE_TABLE(),
 * and provide it to the USB core through their usb_driver structure.
 *
 * See the usb_match_id() function for information about how matches are
 * performed.  Briefly, you will normally use one of several macros to help
 * construct these entries.  Each entry you provide will either identify
 * one or more specific products, or will identify a class of products
 * which have agreed to behave the same.  You should put the more specific
 * matches towards the beginning of your table, so that driver_info can
 * record quirks of specific products.
 */
struct usb_device_id {
	/* which fields to match against? */
	unsigned short		match_flags;

	/* Used for product specific matches; range is inclusive */
	unsigned short		idVendor;
	unsigned short		idProduct;
	unsigned short		bcdDevice_lo;
	unsigned short		bcdDevice_hi;

	/* Used for device class matches */
	unsigned char		bDeviceClass;
	unsigned char		bDeviceSubClass;
	unsigned char		bDeviceProtocol;

	/* Used for interface class matches */
	unsigned char		bInterfaceClass;
	unsigned char		bInterfaceSubClass;
	unsigned char		bInterfaceProtocol;

	/* not matched against */
	unsigned long	driver_info;
};

/* Some useful macros to use to create struct usb_device_id */
#define USB_DEVICE_ID_MATCH_VENDOR		0x0001
#define USB_DEVICE_ID_MATCH_PRODUCT		0x0002
#define USB_DEVICE_ID_MATCH_DEV_LO		0x0004
#define USB_DEVICE_ID_MATCH_DEV_HI		0x0008
#define USB_DEVICE_ID_MATCH_DEV_CLASS		0x0010
#define USB_DEVICE_ID_MATCH_DEV_SUBCLASS	0x0020
#define USB_DEVICE_ID_MATCH_DEV_PROTOCOL	0x0040
#define USB_DEVICE_ID_MATCH_INT_CLASS		0x0080
#define USB_DEVICE_ID_MATCH_INT_SUBCLASS	0x0100
#define USB_DEVICE_ID_MATCH_INT_PROTOCOL	0x0200

/* s390 CCW devices */
struct ccw_device_id {
	unsigned short	match_flags;	/* which fields to match against */

	unsigned short	cu_type;	/* control unit type     */
	unsigned short	dev_type;	/* device type           */
	unsigned char	cu_model;	/* control unit model    */
	unsigned char	dev_model;	/* device model          */

	unsigned long driver_info;
};

#define CCW_DEVICE_ID_MATCH_CU_TYPE		0x01
#define CCW_DEVICE_ID_MATCH_CU_MODEL		0x02
#define CCW_DEVICE_ID_MATCH_DEVICE_TYPE		0x04
#define CCW_DEVICE_ID_MATCH_DEVICE_MODEL	0x08


#define PNP_ID_LEN	8
#define PNP_MAX_DEVICES	8

struct pnp_device_id {
	unsigned char id[PNP_ID_LEN];
	unsigned long driver_data;
};

struct pnp_card_device_id {
	unsigned char id[PNP_ID_LEN];
	unsigned long driver_data;
	struct {
		unsigned char id[PNP_ID_LEN];
	} devs[PNP_MAX_DEVICES];
};


#define SERIO_ANY	0xff

struct serio_device_id {
	unsigned char type;
	unsigned char extra;
	unsigned char id;
	unsigned char proto;
};


#endif /* MOD_DEVICETABLE_H */
