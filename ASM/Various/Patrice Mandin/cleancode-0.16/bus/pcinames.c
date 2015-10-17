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

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

#include <mint/errno.h>

/*--- Defines ---*/

#define PCI_IDS_FILE "pci.ids"

/*--- Constants ---*/

static const char *default_vendorname="Unknown vendor";
static const char *default_devicename="Unknown device";

static const char *default_classname="Unknown class";
static const char *default_subclassname="Unknown subclass";
static const char *default_progifname="Unknown progif";

/*--- Variables ---*/

/*--- Functions prototypes ---*/

static char *load_ids(char *filename, int *length);
static int htoi(char car);

static int search_vendor(char *buffer, int length, unsigned short vendorid);
static int search_device(char *buffer, int length, int position, unsigned short deviceid);
static int search_subdevice(char *buffer, int length, int position, unsigned short subvendorid, unsigned short subdeviceid);

static int search_class(char *buffer, int length, unsigned char classid);
static int search_subclass(char *buffer, int length, int position, unsigned char subclassid);
static int search_progif(char *buffer, int length, int position, unsigned char progifid);

/*--- Functions ---*/

static int htoi(char car)
{
	if ((car>='A') && (car<='F')) {
		car=car-'A'+10;
	} else if ((car>='a') && (car<='f')) {
		car=car-'a'+10;
	} else {
		car=car-'0';
	}

	return car;
}

static char *load_ids(char *filename, int *length)
{
	int handle;
	char *buffer;

	/* Load file */
	handle = open(filename, O_RDONLY);
	if (handle<0) {
		fprintf(stderr, "Unable to open %s\n", filename);	
		return NULL;
	}

	*length = lseek(handle, 0, SEEK_END);
	lseek(handle, 0, SEEK_SET); 	

	buffer = (char *)malloc(*length);
	if (buffer==NULL) {
		fprintf(stderr, "Unable to allocate %d bytes\n", length);
		return NULL;
	}

	read(handle, buffer, *length);
	close(handle);

	return buffer;
}

static int search_vendor(char *buffer, int length, unsigned short vendorid)
{
	int position;
	unsigned short cur_vendorid;

	position=0;
	while (position<length) {
		/* Next line ? */
		if (buffer[position]=='\n') {
			position++;
			continue;
		}

		/* Commentary ? skip to next line */
		if (buffer[position]=='#') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		/* Class name ? stop */
		if ((buffer[position]=='C') && (buffer[position+1]==' ')) {
			return -1;
		}

		/* Device ID or subdevice/subvendor ID ? skip to next line */
		if (buffer[position]=='\t') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		/* We are on a vendor ID */
		cur_vendorid=htoi(buffer[position++])<<12;
		cur_vendorid|=htoi(buffer[position++])<<8;
		cur_vendorid|=htoi(buffer[position++])<<4;
		cur_vendorid|=htoi(buffer[position++])<<0;

		/* The list is sorted, have we gone to far ? */
		if (cur_vendorid > vendorid) {
			return -1;
		}

		/* skip spaces */
		while (buffer[position]==' ') {
			position++;
		}

		/* Have we found it ? */
		if (cur_vendorid == vendorid) {
			return position;
		}

		/* Go to end of line */
		while (buffer[position]!='\n') {
			position++;
		}
		position++;
	}

	return -1;
}

static int search_device(char *buffer, int length, int position, unsigned short deviceid)
{
	unsigned short cur_deviceid;

	/* position points to current vendor name, go to next line */
	while (buffer[position]!='\n') {
		position++;
	}
	position++;

	while (position<length) {
		/* Next line ? */
		if (buffer[position]=='\n') {
			position++;
			continue;
		}

		/* Commentary ? skip to next line */
		if (buffer[position]=='#') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		/* Class name ? stop */
		if ((buffer[position]=='C') && (buffer[position+1]==' ')) {
			return -1;
		}

		/* Vendor ID ? stop */
		if (buffer[position]!='\t') {
			return -1;
		}

		/* Subvendor/subdevice ID ? skip to next line */
		if (buffer[position+1]=='\t') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		position++;

		/* We are on a device ID */
		cur_deviceid=htoi(buffer[position++])<<12;
		cur_deviceid|=htoi(buffer[position++])<<8;
		cur_deviceid|=htoi(buffer[position++])<<4;
		cur_deviceid|=htoi(buffer[position++])<<0;

		/* The list is sorted, have we gone to far ? */
		if (cur_deviceid > deviceid) {
			return -1;
		}

		/* skip spaces */
		while (buffer[position]==' ') {
			position++;
		}

		/* Have we found it ? */
		if (cur_deviceid == deviceid) {
			return position;
		}

		/* Go to end of line */
		while (buffer[position]!='\n') {
			position++;
		}
		position++;
	}

	return -1;
}

int pci_device_getname(
	unsigned short vendorid,
	char *vendorname,
	int vendorname_maxlen,
	unsigned short deviceid,
	char *devicename,
	int devicename_maxlen
)
{
	char *buffer;
	int length, maxlen, vendor_position, device_position;
	int src_pos,dst_pos;

	buffer = load_ids(PCI_IDS_FILE, &length);
	if (buffer==NULL) {
		fprintf(stderr, "Can not load " PCI_IDS_FILE "\n");
		return -ENOSYS;
	}

	strncpy(vendorname, default_vendorname, vendorname_maxlen);
	vendorname[vendorname_maxlen-1]='\0';
	strncpy(devicename, default_devicename, devicename_maxlen);
	devicename[devicename_maxlen-1]='\0';

	/*--- Search the vendor ---*/
	vendor_position=search_vendor(buffer,length,vendorid);
	if (vendor_position<0) {
		free(buffer);
		return 0;
	}

	/* Recopy till end of line */
	memset(vendorname,0, vendorname_maxlen);
	src_pos=vendor_position;
	dst_pos=0;
	while ((buffer[src_pos]!='\0') && (buffer[src_pos]!='\n') && (dst_pos<vendorname_maxlen-1)) {
		vendorname[dst_pos++]=buffer[src_pos++];
	}

	/*--- Search the device ---*/
	if (deviceid==0xffff) {
		free(buffer);
		return 0;
	}

	device_position=search_device(buffer,length,vendor_position,deviceid);
	if (device_position<0) {
		free(buffer);
		return 0;
	}

	/* Recopy till end of line */
	memset(devicename,0, devicename_maxlen);
	src_pos=device_position;
	dst_pos=0;
	while ((buffer[src_pos]!='\0') && (buffer[src_pos]!='\n') && (dst_pos<devicename_maxlen-1)) {
		devicename[dst_pos++]=buffer[src_pos++];
	}

	free(buffer);
	return 0;
}

static int search_class(char *buffer, int length, unsigned char classid)
{
	int position;
	unsigned short cur_classid;

	position=0;
	while (position<length) {
		/* Next line ? */
		if (buffer[position]=='\n') {
			position++;
			continue;
		}

		/* Commentary ? skip to next line */
		if (buffer[position]=='#') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		/* Not a class name ? skip to next line */
		if (buffer[position]!='C') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		if (buffer[position+1]!=' ') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		/* Skip space */
		position+=2;

		/* We are on a class ID */
		cur_classid=htoi(buffer[position++])<<4;
		cur_classid|=htoi(buffer[position++]);

		/* The list is sorted, have we gone to far ? */
		if (cur_classid > classid) {
			return -1;
		}

		/* skip spaces */
		while (buffer[position]==' ') {
			position++;
		}

		/* Have we found it ? */
		if (cur_classid == classid) {
			return position;
		}

		/* Go to end of line */
		while (buffer[position]!='\n') {
			position++;
		}
		position++;
	}

	return -1;
}

static int search_subclass(char *buffer, int length, int position, unsigned char subclassid)
{
	unsigned short cur_subclassid;

	/* position points to current class name, go to next line */
	while (buffer[position]!='\n') {
		position++;
	}
	position++;

	while (position<length) {
		/* Next line ? */
		if (buffer[position]=='\n') {
			position++;
			continue;
		}

		/* Commentary ? skip to next line */
		if (buffer[position]=='#') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		/* Class name ? stop */
		if (buffer[position]=='C') {
			return -1;
		}

		/* ProgIf name ? skip to next line */
		if (buffer[position]=='\t') {
			if (buffer[position+1]=='\t') {
				while (buffer[position]!='\n') {
					position++;
				}
				position++;
				continue;
			}
		}

		/* Skip tab */
		position+=1;

		/* We are on a subclass ID */
		cur_subclassid=htoi(buffer[position++])<<4;
		cur_subclassid|=htoi(buffer[position++]);

		/* The list is sorted, have we gone to far ? */
		if (cur_subclassid > subclassid) {
			return -1;
		}

		/* skip spaces */
		while (buffer[position]==' ') {
			position++;
		}

		/* Have we found it ? */
		if (cur_subclassid == subclassid) {
			return position;
		}

		/* Go to end of line */
		while (buffer[position]!='\n') {
			position++;
		}
		position++;
	}

	return -1;
}

static int search_progif(char *buffer, int length, int position, unsigned char progifid)
{
	unsigned short cur_progifid;

	/* position points to current subclass name, go to next line */
	while (buffer[position]!='\n') {
		position++;
	}
	position++;

	while (position<length) {
		/* Next line ? */
		if (buffer[position]=='\n') {
			position++;
			continue;
		}

		/* Commentary ? skip to next line */
		if (buffer[position]=='#') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		/* Class name ? stop */
		if (buffer[position]=='C') {
			return -1;
		}

		/* Subclass name ? stop */
		if (buffer[position]=='\t') {
			if (buffer[position+1]!='\t') {
				return -1;
			}
		}

		/* Skip tabs */
		position+=2;

		/* We are on a progif ID */
		cur_progifid=htoi(buffer[position++])<<4;
		cur_progifid|=htoi(buffer[position++]);

		/* The list is sorted, have we gone to far ? */
		if (cur_progifid > progifid) {
			return -1;
		}

		/* skip spaces */
		while (buffer[position]==' ') {
			position++;
		}

		/* Have we found it ? */
		if (cur_progifid == progifid) {
			return position;
		}

		/* Go to end of line */
		while (buffer[position]!='\n') {
			position++;
		}
		position++;
	}

	return -1;
}

int pci_class_getname(
	unsigned long classcode,
	char *classname,
	int classname_maxlen,
	char *subclassname,
	int subclassname_maxlen,
	char *progifname,
	int progifname_maxlen
)
{
	char *buffer;
	int length;
	int maxlen, class_position, subclass_position, progif_position;
	int src_pos,dst_pos;

	buffer = load_ids(PCI_IDS_FILE, &length);
	if (buffer==NULL) {
		fprintf(stderr, "Can not load " PCI_IDS_FILE "\n");
		return -ENOSYS;
	}

	strncpy(classname, default_classname, classname_maxlen);
	classname[classname_maxlen-1]='\0';
	strncpy(subclassname, default_subclassname, subclassname_maxlen);
	subclassname[subclassname_maxlen-1]='\0';
	strncpy(progifname, default_progifname, progifname_maxlen);
	progifname[progifname_maxlen-1]='\0';

	/*--- Search the class ---*/
	class_position=search_class(buffer,length,(classcode>>16) & 0xff);
	if (class_position<0) {
		free(buffer);
		return 0;
	}

	/* Recopy till end of line */
	memset(classname,0, classname_maxlen);
	src_pos=class_position;
	dst_pos=0;
	while ((buffer[src_pos]!='\0') && (buffer[src_pos]!='\n') && (dst_pos<classname_maxlen-1)) {
		classname[dst_pos++]=buffer[src_pos++];
	}

	/*--- Search the subclass ---*/
	subclass_position=search_subclass(buffer,length,class_position,(classcode>>8) & 0xff);
	if (subclass_position<0) {
		free(buffer);
		return 0;
	}

	/* Recopy till end of line */
	memset(subclassname,0, subclassname_maxlen);
	src_pos=subclass_position;
	dst_pos=0;
	while ((buffer[src_pos]!='\0') && (buffer[src_pos]!='\n') && (dst_pos<subclassname_maxlen-1)) {
		subclassname[dst_pos++]=buffer[src_pos++];
	}

	/*--- Search the progif ---*/
	progif_position=search_progif(buffer,length,subclass_position,classcode & 0xff);
	if (progif_position<0) {
		free(buffer);
		return 0;
	}

	/* Recopy till end of line */
	memset(progifname,0, progifname_maxlen);
	src_pos=progif_position;
	dst_pos=0;
	while ((buffer[src_pos]!='\0') && (buffer[src_pos]!='\n') && (dst_pos<progifname_maxlen-1)) {
		progifname[dst_pos++]=buffer[src_pos++];
	}

	free(buffer);
	return 0;
}

static int search_subdevice(char *buffer, int length, int position, unsigned short subvendorid, unsigned short subdeviceid)
{
	unsigned short cur_subdeviceid, cur_subvendorid;

	/* position points to current device name, go to next line */
	while (buffer[position]!='\n') {
		position++;
	}
	position++;

	while (position<length) {
		/* Next line ? */
		if (buffer[position]=='\n') {
			position++;
			continue;
		}

		/* Commentary ? skip to next line */
		if (buffer[position]=='#') {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		/* Class name ? stop */
		if ((buffer[position]=='C') && (buffer[position+1]==' ')) {
			return -1;
		}

		/* Vendor ID ? stop */
		if (buffer[position]!='\t') {
			return -1;
		}

		/* Device ID ? stop */
		if ((buffer[position]=='\t') && (buffer[position+1]!='\t')) {
			return -1;
		}

		/* Skip tabs */
		position+=2;

		/* Compare subvendor */
		cur_subvendorid=htoi(buffer[position++])<<12;
		cur_subvendorid|=htoi(buffer[position++])<<8;
		cur_subvendorid|=htoi(buffer[position++])<<4;
		cur_subvendorid|=htoi(buffer[position++])<<0;

		/* The list is sorted, have we gone to far ? */
		if (cur_subvendorid > subvendorid) {
			return -1;
		}

		/* Not our subvendor ? skip to next line */
		if (cur_subvendorid != subvendorid) {
			while (buffer[position]!='\n') {
				position++;
			}
			position++;
			continue;
		}

		/* We are on a subdevice ID */
		position++;
		cur_subdeviceid=htoi(buffer[position++])<<12;
		cur_subdeviceid|=htoi(buffer[position++])<<8;
		cur_subdeviceid|=htoi(buffer[position++])<<4;
		cur_subdeviceid|=htoi(buffer[position++])<<0;

		/* The list is sorted, have we gone to far ? */
		if (cur_subdeviceid > subdeviceid) {
			return -1;
		}

		/* skip spaces */
		while (buffer[position]==' ') {
			position++;
		}

		/* Have we found it ? */
		if (cur_subdeviceid == subdeviceid) {
			return position;
		}

		/* Go to end of line */
		while (buffer[position]!='\n') {
			position++;
		}
		position++;
	}

	return -1;
}

int pci_subdevice_getname(
	unsigned short vendorid,	/* Vendor ID of device */
	unsigned short deviceid,	/* Device ID of device */
	unsigned short subvendorid,	/* Subvendor ID of device */
	char *vendorname,			/* Buffer of vendorname_maxlen chars, which */
	int vendorname_maxlen,		/*  will be fullfilled with vendor name, if found */
	unsigned short subdeviceid,	/* Subdevice ID of device */
	char *devicename,			/* Buffer of devicename_maxlen chars, which */
	int devicename_maxlen		/*  will be fullfilled with device name, if found */
)
{
	char *buffer;
	int length, maxlen, vendor_position, device_position;
	int subvendor_position, subdevice_position;
	int src_pos,dst_pos;

	buffer = load_ids(PCI_IDS_FILE, &length);
	if (buffer==NULL) {
		fprintf(stderr, "Can not load " PCI_IDS_FILE "\n");
		return -ENOSYS;
	}

	strncpy(vendorname, default_vendorname, vendorname_maxlen);
	vendorname[vendorname_maxlen-1]='\0';
	strncpy(devicename, default_devicename, devicename_maxlen);
	devicename[devicename_maxlen-1]='\0';

	/*--- Search the subvendor ---*/
	subvendor_position=search_vendor(buffer,length,subvendorid);
	if (subvendor_position>=0) {
		/* Recopy till end of line */
		memset(vendorname,0, vendorname_maxlen);
		src_pos=subvendor_position;
		dst_pos=0;
		while ((buffer[src_pos]!='\0') && (buffer[src_pos]!='\n') && (dst_pos<vendorname_maxlen-1)) {
			vendorname[dst_pos++]=buffer[src_pos++];
		}
	}

	/*--- Search the vendor ---*/
	vendor_position=search_vendor(buffer,length,vendorid);
	if (vendor_position<0) {
		free(buffer);
		return 0;
	}

	/*--- Search the device ---*/
	device_position=search_device(buffer,length,vendor_position,deviceid);
	if (device_position<0) {
		free(buffer);
		return 0;
	}

	/*--- Search the subdevice ---*/
	subdevice_position=search_subdevice(buffer,length,device_position,subvendorid,subdeviceid);
	if (subdevice_position<0) {
		free(buffer);
		return 0;
	}

	/* Recopy till end of line */
	memset(devicename,0, devicename_maxlen);
	src_pos=subdevice_position;
	dst_pos=0;
	while ((buffer[src_pos]!='\0') && (buffer[src_pos]!='\n') && (dst_pos<devicename_maxlen-1)) {
		devicename[dst_pos++]=buffer[src_pos++];
	}

	free(buffer);
	return 0;
}
