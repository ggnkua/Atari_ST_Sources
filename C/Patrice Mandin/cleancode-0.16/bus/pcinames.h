/*
	PCI devices/classes names

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#ifndef _PCINAMES_H
#define _PCINAMES_H

/*--- Defines ---*/

/*--- Functions prototypes ---*/

/*
	The functions return <0 if can not load 'pci.ids' file
	or 0 (even in the case where names have not been found)
*/

int pci_device_getname(
	unsigned short vendorid,	/* Vendor ID of device */
	char *vendorname,			/* Buffer of vendorname_maxlen chars, which */
	int vendorname_maxlen,		/*  will be fullfilled with vendor name, if found */
	unsigned short deviceid,	/* Device ID of device */
	char *devicename,			/* Buffer of devicename_maxlen chars, which */
	int devicename_maxlen		/*  will be fullfilled with device name, if found */
);

int pci_class_getname(
	unsigned long classcode,	/* Classcode ID (24 bits value) */
	char *classname,			/* Buffer of classname_maxlen chars, which */
	int classname_maxlen,		/*  will be fullfilled with class name, if found */
	char *subclassname,			/* Buffer of subclassname_maxlen chars, which */
	int subclassname_maxlen,	/*  will be fullfilled with subclass name, if found */
	char *progifname,			/* Buffer of progifname_maxlen chars, which */
	int progifname_maxlen		/*  will be fullfilled with progif name, if found */
);

int pci_subdevice_getname(
	unsigned short vendorid,	/* Vendor ID of device */
	unsigned short deviceid,	/* Device ID of device */
	unsigned short subvendorid,	/* Subvendor ID of device */
	char *vendorname,			/* Buffer of vendorname_maxlen chars, which */
	int vendorname_maxlen,		/*  will be fullfilled with vendor name, if found */
	unsigned short subdeviceid,	/* Subdevice ID of device */
	char *devicename,			/* Buffer of devicename_maxlen chars, which */
	int devicename_maxlen		/*  will be fullfilled with device name, if found */
);

#endif /* _PCINAMES_H */
