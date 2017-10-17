/*
 * Filename:     gs_func.h
 * Project:      GlueSTiK
 * 
 * Note:         Please send suggestions, patches or bug reports to me
 *               or the MiNT mailing list <mint@fishpool.com>.
 * 
 * Copying:      Copyright 1999 Frank Naumann <fnaumann@cs.uni-magdeburg.de>
 * 
 * Portions copyright 1997, 1998, 1999 Scott Bigham <dsb@cs.duke.edu>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifndef _gs_func_h
#define _gs_func_h

#include "gs.h"


typedef struct gs GS;
struct gs
{
	CIB	cib;		/* information needed by STiK */
	int	sock_fd;	/* The real socket */
#define GS_LISTENING	0x01	/* unconnected listen port */
#define GS_PEND_OPEN	0x02	/* waiting for connect() to complete */
#define GS_NOSOCKET	0x04	/* no socket on this connection */
	unsigned short flags;		/* What condition are we in? */
	char *pos_cache_read;
	char *end_cache_read;
#define GS_CACHE_SIZE 32768
	char cache_read[GS_CACHE_SIZE];
};


int	gs_xlate_error	(int, const char *);

int	gs_open		(void);
void	gs_close	(int);
GS *	gs_get		(int);
int	gs_accept	(int);
int	gs_establish	(int);
long	gs_connect	(int, uint32, int16, uint32, int16);
long	gs_udp_open	(int, uint32, int16);
long	gs_wait		(int, int);
long	gs_canread	(int);
long	gs_read_delim	(int, char *, int, char);
NDB *	gs_readndb	(int);
long	gs_write	(int, char *, long);
long	gs_read		(int, char *, long);
int	gs_resolve	(char *dn, char **rdn, uint32 *alist, int16 lsize);


#endif /* _gs_func_h */
