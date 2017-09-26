/*
	XHDI demo program

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

#include "xhdi.h"
#include "param.h"

/*--- Defines ---*/

#define SCANCODE_ESC	0x01

/*--- Variables ---*/

unsigned long cookie_xhdi;

/*--- Functions prototypes ---*/

void DemoLoop(void);

/*--- Functions ---*/

int main(int argc, char **argv)
{
	PAR_TestRedirect(argc, argv);
	if (output_to_file) {
		PAR_RedirectStdout();
	}

	fprintf(output_handle, "XHDI cookie: ");
	if (Getcookie(C_XHDI, &cookie_xhdi) != C_FOUND) {
		fprintf(output_handle, "non present\n");
		cookie_xhdi = 0;
	} else {
		fprintf(output_handle, "present\n");
	}
	if (cookie_xhdi) {
		unsigned short xhdi_version;
		unsigned long xhdi_drives;
		unsigned short major,minor;
		unsigned char name[512], version[16],company[24], partid[4];
		unsigned long blocksize,device_flags,startblock,partlength;
		int i;
		
		/* version */
		xhdi_version = XHGetVersion();
		fprintf(output_handle, "Version: %2x.%02x\n", (xhdi_version>>8) & 0xff, xhdi_version & 0xff);

		/* drives */
		xhdi_drives = XHDrvMap();		
		fprintf(output_handle, "Drives handled by XHDI: 0x%08x\n ", xhdi_drives);
		for (i=0; i<32; i++) {
			if (xhdi_drives & (1<<i)) {
				fprintf(output_handle, "%c", 'A'+i);
			}
		}		

		/* infos */
		fprintf(output_handle, "\nInformations about drives:\n");
		for (i=0; i<32; i++) {
			if (!(xhdi_drives & (1<<i)))
				continue;

			fprintf(output_handle, " Drive %c:\n",'A'+i);

			/* Driver for this device */
			if (XHInqDriver(i,name,version,company,NULL,NULL)<0) {
				fprintf(output_handle, "  Error reading driver infos for this device\n");
				continue;
			}
			fprintf(output_handle, "  Driver infos:\n");
			fprintf(output_handle, "   Name: %s\n",name);
			fprintf(output_handle, "   Version: %s\n",version);
			fprintf(output_handle, "   Company: %s\n",company);

			/* Infos for this partition on this device */
			if (XHInqDev(i,&major,&minor,&startblock,NULL)<0) {
				fprintf(output_handle, "  Error reading device infos\n");
				continue;
			}

			fprintf(output_handle, "  Device infos:\n");
			fprintf(output_handle, "   Major %d, minor %d\n",major,minor);
			fprintf(output_handle, "   Bus type: ");
			if (major<8) {
				fprintf(output_handle, "ACSI\n");
			} else if (major<16) {
				fprintf(output_handle, "SCSI\n");
			} else if (major<18) {
				fprintf(output_handle, "IDE0\n");
			} else if (major<20) {
				fprintf(output_handle, "IDE1\n");
			} else if (major<24) {
				fprintf(output_handle, "IDE\n");
			} else {
				fprintf(output_handle, "Unknown\n");
			}
			if (major<20) {
				fprintf(output_handle, "   LUN: %d\n",minor);
			}
			fprintf(output_handle, "   Partition start (in sectors): 0x%08x\n",startblock);

			/* Info for this device */
			if (XHInqTarget(major,minor,&blocksize,&device_flags,name)<0) {
				fprintf(output_handle, "  Error reading target infos\n");
				continue;
			}

			fprintf(output_handle, "  Target infos:\n");
			fprintf(output_handle, "   Name: %s\n",name);
			fprintf(output_handle, "   Block size: %d\n",blocksize);
			fprintf(output_handle, "   Device capabilities:");
			if (device_flags & (1<<XH_TARGET_STOPPABLE)) {
				fprintf(output_handle, " stoppable");
			}
			if (device_flags & (1<<XH_TARGET_REMOVABLE)) {
				fprintf(output_handle, " removable");
			}
			if (device_flags & (1<<XH_TARGET_LOCKABLE)) {
				fprintf(output_handle, " lockable");
			}
			if (device_flags & (1<<XH_TARGET_EJECTABLE)) {
				fprintf(output_handle, " ejectable");
			}
			fprintf(output_handle, "\n   Device state:");
			if (device_flags & (1<<XH_TARGET_LOCKED)) {
				fprintf(output_handle, " locked");
			}
			if (device_flags & (1<<XH_TARGET_STOPPED)) {
				fprintf(output_handle, " stopped");
			}
			if (device_flags & (1<<XH_TARGET_RESERVED)) {
				fprintf(output_handle, " reserved");
			}
			fprintf(output_handle, "\n");

			/* More infos about the partition */
			if (xhdi_version>=0x0110) {
				if (XHInqDev2(i,&major,&minor,&startblock,NULL,&partlength,partid)<0) {
					fprintf(output_handle, "  Error reading device infos\n");
					continue;
				}

				fprintf(output_handle, "  Partition infos:\n");
				fprintf(output_handle, "   Start (in sectors): 0x%08x\n",startblock);
				fprintf(output_handle, "   Length (in sectors): 0x%08x\n",partlength);
				fprintf(output_handle, "   Length (in Mbytes): %d\n",(partlength*blocksize)>>20);
				fprintf(output_handle, "   Type:");
				if (partid[0]==0) {
					if (partid[1]=='D') {
						fprintf(output_handle, " PC: 0x%02x\n",partid[2]);
					} else {
						fprintf(output_handle, " Unknown\n");
					}
				} else {
					fprintf(output_handle, " Atari: %s\n",partid);
				}
			}
		}
	}

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
