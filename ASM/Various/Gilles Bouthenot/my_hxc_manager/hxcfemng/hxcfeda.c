/*
//
// Copyright (C) 2009, 2010, 2011 Jean-Francois DEL NERO
//
// This file is part of the HxCFloppyEmulator file selector.
//
// HxCFloppyEmulator file selector may be used and distributed without restriction
// provided that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// HxCFloppyEmulator file selector is free software; you can redistribute it
// and/or modify  it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// HxCFloppyEmulator file selector is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//   See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with HxCFloppyEmulator file selector; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//
*/

// This file contains HxC Floppy Emulator Direct Access functions
// string "hxc_"


#include <stdio.h>
#include <string.h>
#include <mint/osbind.h>

#include "assembly.h"
#include "atari_hw.h"
#include "fectrl.h"
#include "gui_utils.h"
#include "screen.h"


static unsigned long _last_setlbabase;
static unsigned char _isEmulator;


typedef struct _direct_access_status_sector_
{
	char DAHEADERSIGNATURE[8];
	char FIRMWAREVERSION[12];
	unsigned long lba_base;
	unsigned char cmd_cnt;
	unsigned char read_cnt;
	unsigned char write_cnt;
	unsigned char last_cmd_status;
}  __attribute__ ((__packed__)) _direct_access_status_sector;


typedef struct _direct_access_cmd_sector_
{
	char DAHEADERSIGNATURE[8];
	unsigned char cmd_code;
	unsigned char parameter_0;
	unsigned char parameter_1;
	unsigned char parameter_2;
	unsigned char parameter_3;
	unsigned char parameter_4;
	unsigned char parameter_5;
	unsigned char parameter_6;
	unsigned char parameter_7;
	unsigned char cmd_checksum;
}  __attribute__ ((__packed__)) _direct_access_cmd_sector;



void _setlbabase(unsigned long lba)
{
	unsigned char sector[512];
	int ret;
	_direct_access_cmd_sector * dacs;

	dacs=(_direct_access_cmd_sector  *)sector;

	memsetword(&sector, 0, 512/2);

	sprintf(dacs->DAHEADERSIGNATURE,"HxCFEDA");
	dacs->cmd_code=1;
	dacs->parameter_0=(lba>>0)&0xFF;
	dacs->parameter_1=(lba>>8)&0xFF;
	dacs->parameter_2=(lba>>16)&0xFF;
	dacs->parameter_3=(lba>>24)&0xFF;
	dacs->parameter_4=0xA5;

	ret=writesector( 0,(unsigned char *)&sector);
	if(!ret) {
		fatal("Write CTRL error");
	}
}




/**
 * Init the hardware
 * Display Firmware version
 * @return 0 on failure, 1 on success
 */
void _hxc_media_init()
{
	unsigned char sector[512];
	_direct_access_status_sector * dass;

	_last_setlbabase=0xFFFFF000;
	if (!readsector(0,(unsigned char*)&sector,1)) {
		fatal("Floppy Access error");
	}

	dass=(_direct_access_status_sector *)sector;
	if(strcmp(dass->DAHEADERSIGNATURE,"HxCFEDA")) {
		fatal("HxC Floppy Emulator not found");
	}

	gui_printf(0,0,SCR_YRESOL-30,"Firmware %s" ,dass->FIRMWAREVERSION);

	dass= (_direct_access_status_sector *)sector;
	_last_setlbabase=0;
	_setlbabase(_last_setlbabase);
}








/**
 * Callback function
 */
int hxc_media_read(unsigned long sector, unsigned char *buffer)
{
	_direct_access_status_sector * dass;

	dass= (_direct_access_status_sector *)buffer;

	gui_more_busy();

	if (_isEmulator) {
		Rwabs(0, buffer, 1, sector, 0);
	} else {
		do {
			if((sector-_last_setlbabase)>=8) {
				_setlbabase(sector);
			}

			if(!readsector(0,buffer,0)) {
				error("Read error");
			}
			_last_setlbabase=L_INDIAN(dass->lba_base);

			/* gui_printf(0,0,0,"BA: %08X %08X" ,L_INDIAN(dass->lba_base),sector);*/
		} while((sector-L_INDIAN(dass->lba_base))>=8);

		if(!readsector((sector-_last_setlbabase)+1,buffer,0)) {
			//gui_printf(0, 0, 0, "fsector=%d", (sector-_last_setlbabase)+1));
			fatal("Read error");
		}
	}

	gui_less_busy();

	return 1;
}

/**
 * Callback function
 */
int hxc_media_write(unsigned long sector, unsigned char *buffer)
{
	gui_more_busy();

	if (_isEmulator) {
		Rwabs(1, buffer, 1, sector, 0);
	} else {
		if((sector-_last_setlbabase)>=8) {
			_last_setlbabase=sector;
			_setlbabase(sector);
		}

		if(!writesector((sector-_last_setlbabase)+1,buffer)) {
			fatal("Write sector error");
		}
	}

	gui_less_busy();

	return 1;
}



void hxc_enterModule(unsigned char bootdev)
{
	_isEmulator = emulatordetect();

	if (!_isEmulator) {
		init_atari_fdc(bootdev);

		_hxc_media_init();
	}
}
