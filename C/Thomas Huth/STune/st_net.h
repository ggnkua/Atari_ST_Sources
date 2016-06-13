/**
 * STune - The battle for Aratis
 * st_net.h : Header file for st_net.c.
 * Copyright (C) 2003 Matthias Alles, Thomas Huth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#ifndef _ST_NET_H
#define _ST_NET_H

#define CLIENT 1
#define HOST   2
#define E_INIT 3

extern short netmode;

short net_open(char *hostname, int port);
short net_close(short cnhndl);
short net_write(short cn, void *buf, short len, short flag);
short net_read(short cn, void *blk, short len, short flag);
short init_network(void);
void set_tm_data(unsigned short, unsigned short, unsigned short, unsigned short,
                 unsigned short, unsigned short);
void to_do_list(TRANSMIT trans);

#endif
