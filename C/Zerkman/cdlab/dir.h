/*
 * dir.h - gestion de répertoires, indépendamment du système
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

#ifndef _DIR_H_
#define _DIR_H_

#define NAME_MAX 255

#ifdef __TOS__
# define DIR_SEPARATOR "\\"
#else
# define DIR_SEPARATOR "/"
#endif

struct fileattr
{
  char type;            /* b, c, d, p, f, l, s */
  unsigned short mode;
  int uid;
  int gid;
  long size;
  time_t atime;
  time_t mtime;
  time_t ctime;
};

struct fileinfo
{
  const char * name;
  struct fileattr attr;
};


int dir_init( void );
int dir_read_first( const char * path, struct fileinfo * info );
int dir_read_next( struct fileinfo * info );

#endif
