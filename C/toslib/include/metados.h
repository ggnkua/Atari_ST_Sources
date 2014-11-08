/*
 * $Id: metados.h pdonze Exp $
 * 
 * TOS.LIB - (c) 1998 - 2006 Philipp Donze
 *
 * A replacement for PureC PCTOSLIB.LIB
 *
 * This file is part of TOS.LIB and contains Meta DOS prototypes and structures.
 *
 * TOS.LIB is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * TOS.LIB is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with the GNU C Library; see the file COPYING.LIB.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef _METADOS_H
# define _METADOS_H

typedef struct
{
   unsigned char disctype;
   unsigned char firsttrack, lasttrack, curtrack;
   unsigned char relposz, relposm, relposs, relposf;
   unsigned char absposz, absposm, absposs, absposf;
   unsigned char endposz, endposm, endposs, endposf;
   unsigned char index, res[3];
   unsigned long reserved[123];
} CD_DISC_INFO;

typedef struct
{
   unsigned char trackno;
   unsigned char minute;
   unsigned char second;
   unsigned char frame;
} CD_TOC_ENTRY;

typedef struct
{
   char *mdr_name;
   long reserved[3];
} META_DRVINFO;

typedef struct
{
   unsigned long  drivemap;   /* bitmap indicating Meta-DOS drives */
   char  *version;            /* Meta-DOS name and version string */
   long  reserved[2];         /* reserved */
} METAINFO;

void Metainit(METAINFO *buffer);
long Metaopen(short drive, META_DRVINFO *buffer);
long Metaclose(short drive);
long Metaread(short drive, void *buffer, long blockno, short count);
long Metawrite(short drive, void *buffer, long blockno, short count);
long Metastatus(short drive, void *buffer);
long Metaioctl(short drive, long magic, short opcode, void *buffer);
long Metastartaudio(short drive, short flag, unsigned char *bytearray);
long Metastopaudio(short drive);
long Metasetsongtime(short drive, short repeat, long starttime, long endtime);
long Metagettoc(short drive, short flag, CD_TOC_ENTRY *buffer);
long Metadiscinfo(short drive, CD_DISC_INFO *p);

#endif      /* _METADOS_H */
