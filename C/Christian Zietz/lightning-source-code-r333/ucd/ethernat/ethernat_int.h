/*
 * Ethernat USB driver for FreeMiNT.
 * Modified for USB by David Galvez. 2010 - 2011
 *
 * This file belongs to FreeMiNT. It's not in the original MiNT 1.12
 * distribution. See the file CHANGES for a detailed log of changes.
 *
 * Copyright (c) 2007 Henrik Gilda
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef _ethernat_int_h
#define _ethernat_int_h

#ifdef TOSONLY
#define MINT_INT_OFF
#define MINT_INT_ON
#define TOS_INT_OFF		unsigned long oldmode = (Super(1L) ? 0L: Super(0L)); \
				set_int_lvl6();
#define TOS_INT_ON		set_old_int_lvl(); \
				if (oldmode) SuperToUser(oldmode);
#else
#define MINT_INT_OFF		set_int_lvl6()
#define MINT_INT_ON		set_old_int_lvl()
#define TOS_INT_OFF
#define TOS_INT_ON
#endif

// old handler
extern void (*old_int)(void);

// interrupt wrapper routine
void interrupt(void);
void hook_reset_vector(void);

void set_old_int_lvl(void);
void set_int_lvl6(void);

/* 
 * To know if the EtherNat is present through the bus error
 */
void ethernat_probe_asm(void);
void ethernat_probe_c(void);

void fake_ikbd_int(void);

#endif // _ethernat_int_h
