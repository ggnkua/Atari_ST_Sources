/*
 * iso9660.h - gestion des systèmes de fichiers ISO 9660
 *
 * Copyright 2004 Francois Galea
 *
 * This file is part of CDLab.
 *
 * CDLab is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * CDLab is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */


#ifndef _ISO9660_H_
#define _ISO9660_H_

#ifdef _ISO9660_C_
typedef struct iso_generator IsoGenerator;
#else
typedef void IsoGenerator;
#endif

IsoGenerator * iso_new( const char * dir, const char * sys_id, const char *
    vol_id, const char * vs_id, const char * pb_id, const char * pr_id, const
    char * ap_id, int blocksize );
void iso_delete( IsoGenerator * ig );
long iso_blocks( IsoGenerator * ig );
int iso_read( IsoGenerator * gen, void * buf, long nblocks );

#endif
