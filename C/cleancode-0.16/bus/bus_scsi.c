/*
	SCSIDRV demo program

	Copyright (C) 2002	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <stdio.h>
#include <string.h>

#include <mint/osbind.h>
#include <mint/cookie.h>

#include "param.h"
#include "endian.h"

#include "scsidrv.h"
#include "scsi.h"
#include "scsinames.h"

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/*--- Variables ---*/

/*--- Functions prototypes ---*/

void DemoScsiLoop(void);
void ListBusses(void);
void ListDevices(unsigned short busno);
void PrintDeviceInfo(unsigned short busno, scsi_long64_t *scsi_id);

void DemoLoop(void);

/*--- Functions ---*/

int main(int argc, char **argv)
{
	unsigned long cookie_scsi;

	PAR_TestRedirect(argc, argv);
	if (output_to_file) {
		PAR_RedirectStdout();
	}

	fprintf(output_handle, "SCSI cookie: ");
	if (Getcookie(C_SCSI, &cookie_scsi) != C_FOUND) {
		fprintf(output_handle, "non present\n");
		cookie_scsi = 0;
	} else {
		fprintf(output_handle, "present\n");
	}

	DemoScsiLoop();

	if (!output_to_file) {
		DemoLoop();
	} else {
		fclose(output_handle);
	}
}

/*--- Little demo loop ---*/

void DemoLoop(void)
{
	unsigned long key_pressed;
	unsigned char scancode;

	printf("Press ESC to quit\n");

	key_pressed = scancode = 0;
	while (scancode != SCANCODE_ESC) {

		/* Read key pressed, if needed */
		if (Cconis()) {
			key_pressed = Cnecin();
			scancode = (key_pressed >>16) & 0xff;

			/* Wait key release */
			while (Cconis()!=0) { }
		}
	}
}

/*--- Display infos ---*/

void DemoScsiLoop(void)
{
	unsigned short version;

	if (scsidrv_init()<0) {
		fprintf(output_handle, "Can not initialize SCSIdrv library\n");
		return;
	}

	version=scsidrv_get_version();	
	fprintf(output_handle, "Version: %02x.%02x\n",(version>>8) & 0xff,version & 0xff);

	ListBusses();
}

void ListBusses(void)
{
	scsi_businfo_t businfo;
	int what;
	long result;
		
	fprintf(output_handle, "Bus list:\n");
	what=SCSIDRV_INQUIRE_FIRST;
	for(;;) {
		result=scsidrv_inquire_scsi(what, &businfo);
		if (result<0) {
			break;
		}

		businfo.busname[19]='\0';
		fprintf(output_handle, " Name: %s\n", businfo.busname);
		fprintf(output_handle, "  Number: %d\n", businfo.busno);
		fprintf(output_handle, "  Features:");
		if (businfo.features == 0) {
			fprintf(output_handle, " <None>");
		} else {
			if (businfo.features & SCSIDRV_ARBIT) {
				fprintf(output_handle, " Arbitration");
			}
			if (businfo.features & SCSIDRV_ALLCMDS) {
				fprintf(output_handle, " All-commands");
			}
			if (businfo.features & SCSIDRV_TARGETCTL) {
				fprintf(output_handle, " Target-control");
			}
			if (businfo.features & SCSIDRV_TARGET) {
				fprintf(output_handle, " Target");
			}
			if (businfo.features & SCSIDRV_DISCONNECT) {
				fprintf(output_handle, " Disconnect");
			}
			if (businfo.features & SCSIDRV_SCATTER) {
				fprintf(output_handle, " Scatter-gather");
			}
		}
		fprintf(output_handle, "\n  Max tranfer length (in bytes): %d\n", businfo.maxlen);

		ListDevices(businfo.busno);

		what=SCSIDRV_INQUIRE_NEXT;
	}
}

void ListDevices(unsigned short busno)
{
	scsi_devinfo_t devinfo;
	int what, devno;
	long result;
		
	what=SCSIDRV_INQUIRE_FIRST;
	devno=0;
	for(;;) {
		result=scsidrv_inquire_bus(what, busno, &devinfo);
		if (result<0) {
			break;
		}

		fprintf(output_handle, "  Device %d:\n", devno);
		fprintf(output_handle, "   ID: 0x%08x:%08x\n", devinfo.scsi_id.high, devinfo.scsi_id.low);

		PrintDeviceInfo(busno, &devinfo.scsi_id);

		what=SCSIDRV_INQUIRE_NEXT;
		devno++;
	}
}

void PrintDeviceInfo(unsigned short busno, scsi_long64_t *scsi_id)
{
	long result;
	scsi_device_t device;
	scsi_inquire_data_t inqdata;
	char *devtype_name;
	int i, names_found;
	char vendorname[64];
	char productname[64];

	result=scsidrv_open(busno, scsi_id, &(device.maxlen));
	if (result<0) {
		fprintf(output_handle, "   Can not open device: error=0x%08x\n", result);
		return;
	}

	device.handle=(unsigned short *)result;
	device.timeout = 5;
	device.control = 0;

	fprintf(output_handle, "   Device opened: Handle=0x%04x, Maxlen=%d\n", *(device.handle), device.maxlen);
	
	for (device.lun=0; device.lun<8; device.lun++) {
		fprintf(output_handle, "   Lun %d:\n");

		memset(&inqdata, 0, sizeof(inqdata));

		/* Query infos */
		result = scsi_Inquiry(&device, &inqdata, sizeof(inqdata), 0, 0);
		if (result<0) {
			fprintf(output_handle, "    Can not Inquiry() lun %d: error=0x%08x\n", device.lun, result);
			continue;
		}

		devtype_name = scsi_devicetype_getname(inqdata.periph & ((1<<5)-1));

		fprintf(output_handle, "    Qualifier=%d, Device type=%d (%s device)\n",
			inqdata.periph>>5,
			inqdata.periph & ((1<<5)-1),
			devtype_name
		);
		fprintf(output_handle, "    Removable=%d, Modifier=%d\n",
			(inqdata.rmb>>7) & 1,
			inqdata.rmb & ((1<<7)-1)
		);
		fprintf(output_handle, "    ISO=%d, ECMA=%d, ANSI-approved=%d\n",
			(inqdata.version>>6) & 3,
			(inqdata.version>>3) & 7,
			(inqdata.version>>0) & 7
		);
		fprintf(output_handle, "    AENC=%d, TrmIOP=%d, Response data format=%d\n",
			(inqdata.misc1>>7) & 1,
			(inqdata.misc1>>6) & 1,
			(inqdata.misc1>>0) & 15
		);
		fprintf(output_handle, "    Additional length=%d\n",
			inqdata.addlen
		);

		fprintf(output_handle, "    RelAdr=%d, WBus32=%d, WBus16=%d, Sync=%d, Linked=%d, CmdQue=%d, SftRe=%d\n",
			(inqdata.misc2>>7) & 1,
			(inqdata.misc2>>6) & 1,
			(inqdata.misc2>>5) & 1,
			(inqdata.misc2>>4) & 1,
			(inqdata.misc2>>3) & 1,
			(inqdata.misc2>>1) & 1,
			(inqdata.misc2>>0) & 1
		);

		fprintf(output_handle, "    Vendor ID: ");
		for (i=0; i<8; i++) {
			if (inqdata.vendor[i]==0) {
				if (i==0) {
					fprintf(output_handle, "<empty>");
				}
				break;
			}
			fprintf(output_handle, "%c", inqdata.vendor[i]);
		}

		fprintf(output_handle, "\n    Product ID: ");
		for (i=0; i<16; i++) {
			if (inqdata.product[i]==0) {
				if (i==0) {
					fprintf(output_handle, "<empty>");
				}
				break;
			}
			fprintf(output_handle, "%c", inqdata.product[i]);
		}

		fprintf(output_handle, "\n    Revision: 0x%08x\n", GET_BE_LONG_S(inqdata, rev));
	}

	scsidrv_close(device.handle);
}
