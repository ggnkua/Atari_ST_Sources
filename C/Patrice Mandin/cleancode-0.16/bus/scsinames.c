/*
	SCSI vendor/product names

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

/*--- Constants ---*/

static char *scsi_devtype_names[13]={
	"Direct-access",
	"Sequential-access",
	"Printer",
	"Processor",
	"Write-once",
	"CD-ROM",
	"Scanner",
	"Optical memory",
	"Medium-changer",
	"Communications",
	"Graphic arts pre-press",
	"Reserved",
	"Unknown"
};

/*--- Functions ---*/

char *scsi_devicetype_getname(int devtype)
{
	devtype &= ((1<<5)-1);

	if (devtype<0x0a) {
		return scsi_devtype_names[devtype];
	} else if (devtype<0x0c) {
		return scsi_devtype_names[0x0a];
	} else if (devtype<0x1f) {
		return scsi_devtype_names[0x0b];
	}

	return scsi_devtype_names[0x0c];
}
