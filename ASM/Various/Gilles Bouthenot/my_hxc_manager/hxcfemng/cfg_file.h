#ifndef __CFG_FILE_H__
#define __CFG_FILE_H__
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


typedef struct cfgfile_
{
	char signature[16]; /* "HXCFECFGV1.0" */
	unsigned char step_sound;         /* 0x00 -> off 0xFF->on */
	unsigned char ihm_sound;          /* 0x00 -> off 0xFF->on */
	unsigned char back_light_tmr;     /* 0x00 always off, 0xFF always on, other -> on x second */
	unsigned char standby_tmr;        /* 0xFF disable, other -> on x second */
	unsigned char disable_drive_select;
	unsigned char buzzer_duty_cycle; /* 0x00 <> 0x80 */
	unsigned char number_of_slot;
	unsigned char slot_index;
	unsigned short update_cnt;
	unsigned char load_last_floppy;
	unsigned char buzzer_step_duration;  /* 0xD8 <> 0xFF */
	unsigned char lcd_scroll_speed;
	unsigned char startup_mode;
	unsigned char enable_drive_b;
}  __attribute__ ((__packed__)) cfgfile;



/* unsigned char get_device_parameters(struct DirectoryEntry *pDirEnt); */
/*void update_cfgfile_parameters(struct DirectoryEntry *pDirEnt,unsigned char slot_index); */



struct ShortDirectoryEntry {
	unsigned char name[12];
	unsigned char attributes;
/*	unsigned long firstCluster;*/
	unsigned char firstCluster_b1;
	unsigned char firstCluster_b2;
	unsigned char firstCluster_b3;
	unsigned char firstCluster_b4;
/*	unsigned long size;*/
	unsigned char size_b1;
	unsigned char size_b2;
	unsigned char size_b3;
	unsigned char size_b4;
	unsigned char longName[17];	/* boolean */
}  __attribute__ ((__packed__));

extern struct DirectoryEntry directoryEntry;


typedef struct disk_in_drive_
{
	struct ShortDirectoryEntry DirEnt;
	unsigned char numberoftrack;
	unsigned char numberofside;
	unsigned short rpm;
	unsigned short bitrate;
	unsigned short tracklistoffset;
}  __attribute__ ((__packed__)) disk_in_drive;
#endif
