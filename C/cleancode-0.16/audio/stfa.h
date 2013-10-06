/*
	STFA control structure

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

#ifndef _STFA_H
#define _STFA_H

/*--- Defines ---*/

#define C_STFA	0x53544641L	/* Sound treiber für atari (seb/The removers) */

/*--- Types ---*/

typedef struct {
	unsigned short sound_enable;
	unsigned short sound_control;
	unsigned short sound_output;
	unsigned long sound_start;
	unsigned long sound_current;
	unsigned long sound_end;
	unsigned short version;
	void *old_vbl;
	void *old_timera;
	unsigned long old_mfp_status;
	void *new_vbl;
	void *drivers_list;
	void *play_stop;
	unsigned short frequency;
	void *set_frequency;
	
	unsigned short frequency_threshold;
	unsigned short custom_freq_table;
	unsigned short stfa_on_off;
	void *new_drivers_list;
	unsigned short old_bit_2_of_cookie_snd;
	unsigned short stfa_it;
} STFA_control __attribute__((packed));

#endif /* _STFA_H */
