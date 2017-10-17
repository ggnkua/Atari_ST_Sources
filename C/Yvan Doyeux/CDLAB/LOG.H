/*
 * ERROR.H - Gestion des erreurs SCSI
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

#ifndef __LOG_H__
#define __LOG_H__

#include "io.h"

void log_device_name( void );
void log_cmd( scsi_cmd * Cmd, int ret, int in );
/*void aff_sense( void );*/
int log_begin( void );
int log_end( void );
int set_logfile( const char * filename );
void log_write( const char * msg );
void log_printf( const char * format, ... );

#endif

