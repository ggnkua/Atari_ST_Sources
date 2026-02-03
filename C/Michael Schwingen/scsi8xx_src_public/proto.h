/***************************************************************************
 *   Copyright (C) 1998-1999 Michael Schwingen                             *
 *   michael@schwingen.org                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.           *
 ***************************************************************************/
#ifndef _PROTO_H
#define _PROTO_H

#include <portab.h>

#define DB_COMMAND 0x01
#define DB_SCATTER 0x02
#define DB_SCRIPT  0x04
#define DB_SD      0x08
#define DB_DATA    0x10

/* scsidrv.c */
extern LONG sd_init(void);
extern void post_busreset(void);

/* main.c */
extern long DoCommand(UBYTE id, UBYTE *command, UBYTE *data, ULONG data_len, ULONG to);

/* delay.c */
extern void mydelay(int);

/* printf.c */
extern void serprintf(const char*,...);
extern void bprintf(const char*,...);
extern void dprintf(UWORD,const char*,...);
extern void check_debug(void);

/* cookie.s */
extern int Install_SCSI(UWORD cookie_size);

extern UWORD scsi_scan_mask;
extern UBYTE my_scsi_id;

#endif
