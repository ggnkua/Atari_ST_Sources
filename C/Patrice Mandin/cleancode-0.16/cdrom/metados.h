/*
	Metados

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

#ifndef _METADOS_H
#define _METADOS_H

#include <mint/falcon.h>	/* for trap_14_xxx macros */

/*--- Types ---*/

typedef struct {
	unsigned long drives_map;
	char *version;
	unsigned long dummy[2];		
} metainit_t;

typedef struct {
	char *name;
	unsigned long dummy[3];
} metaopen_t;

/*--- Functions prototypes ---*/

#define Minit(buffer)	\
	(void)trap_14_wl((short)0x30,(long)buffer)
#define Mopen(drive,buffer)	\
	(long)trap_14_wwl((short)0x31,(short)drive,(long)buffer)
#define Mclose(drive)	\
	(void)trap_14_ww((short)0x32,(short)drive)
#define Mread(drive,buffer,first_block, nb_blocks)	\
	(long)trap_14_wwllw((short)0x33,(short)drive,(long)buffer,(long)first_block,(short)nb_blocks)
#define Mwrite(drive,buffer,first_block, nb_blocks)	\
	(long)trap_14_wwllw((short)0x34,(short)drive,(long)buffer,(long)first_block,(short)nb_blocks)

/* FIXME: these following bindings are wrong, need Metados documentation */

#define Mseek(void)	\
	(void)trap_14_w((short)0x35)
#define Mstatus(void)	\
	(void)trap_14_w((short)0x36)

#define CDread_aud(void)	\
	(long)trap_14_w((short)0x3a)
#define CDstart_aud(void)	\
	(long)trap_14_w((short)0x3b)
#define CDstop_aud(void)	\
	(long)trap_14_w((short)0x3c)
#define CDset_songtime(void)	\
	(long)trap_14_w((short)0x3d)
#define CDget_toc(void)	\
	(long)trap_14_w((short)0x3e)
#define CDdisc_info(void)	\
	(long)trap_14_w((short)0x3f)

#endif /* _METADOS_H */
