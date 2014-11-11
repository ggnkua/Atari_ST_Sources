/*
 * dir.c - gestion de répertoires, indépendamment du système
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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#ifdef __LINUX__
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <dirent.h>
#endif

#ifdef __TOS__
#include <tos.h>
#endif

#include "dir.h"

int domain;
char currentpath[ NAME_MAX + 1 ];
const DTA * dta;


/* Fonction d'initialisation des fonctions de répertoires */
int dir_init( void )
{
  Pdomain( 1 );
  domain = Pdomain( -1 );
  dta = Fgetdta();
  return 0;
}

static time_t dttott( unsigned int time, unsigned int date )
{
  struct tm t;
  t.tm_sec = (time & 0x1f) << 1;
  time >>= 5;
  t.tm_min = time & 0x3f;
  t.tm_hour = time >> 6;
  t.tm_mday = date & 0x1f;
  date >>= 5;
  t.tm_mon = (date & 0xf) - 1;
  t.tm_year = (date >> 4) + 80;
  t.tm_wday = 0;
  t.tm_yday = 0;
  t.tm_isdst = 0;
  return mktime( &t );
}

static void fill_fileinfo( struct fileinfo * info )
{
  time_t ftime;
  const DTA * d = dta;

  ftime = dttott( d->d_time, d->d_date );

  info->name = d->d_fname;
  info->attr.type = 'f';
  if( d->d_attrib & FA_SUBDIR )
    info->attr.type = 'd';
  info->attr.mode = 0555;
  info->attr.uid = 0;
  info->attr.gid = 0;
  info->attr.size = d->d_length;
  info->attr.atime = ftime;
  info->attr.mtime = ftime;
  info->attr.ctime = ftime;
}

int dir_read_first( const char * path, struct fileinfo * info )
{
  int ret;

  sprintf( currentpath, "%s\\*.*", path );

  ret = Fsfirst( currentpath, FA_HIDDEN | FA_SYSTEM | FA_SUBDIR );
  if( !ret )
    fill_fileinfo( info );
  return ret;
}

int dir_read_next( struct fileinfo * info )
{
  int ret = Fsnext();
  if( !ret )
    fill_fileinfo( info );
  return ret;
}

/* Fonction de test, on la virera après */

/*
int main( void )
{
  struct fileinfo info;
  int err;
  dir_init();
  err = dir_read_first( "D:", &info );
  while( !err )
  {
    printf( "%c:%s\n", info.attr.type, info.name );
    err = dir_read_next( &info );
  }
  return 0;
}
*/







/********************************************************************************/
/********************************************************************************/
/********************************************************************************/
/********************************************************************************/
/********************************************************************************/

#if 0
#ifdef __TOS__
union
{
  struct
  {
    int first_one;
  } normal;
  struct
  {
    long dirhandle;
    const char * path;
  } ext;
} domain;
#else
DIR * dir;
const char * dir_path;
#endif

struct fileinfo info;


const struct fileinfo * dir_first( const char * path )
{
#ifdef __TOS__
  char buf[ NAME_MAX + 1 ];
  if( dir.domain )
  {
    domain.ext.dirhandle = Dopendir( path );
    domain.ext.path = path;
  }
  else
  {
    sprintf( buf, "%s\\*.*", path );
  sqdksjlkjdlkdlkdlkjdlkjhlfhlfsqfchsfhsfhlsfhsfhlfkfhlsfhlflksfkflkflshkj
    if( Fsfirst( 
  }
#else
  dir = opendir( path );
  if( !dir )
  {
    perror( path );
    abort();
  }
  dir_path = path;
#endif
}

const struct fileinfo * dir_next( void )
{
  char buf[ NAME_MAX + 1 ];
  char type;
  static struct fileinfo fi;
  struct stat st;
  struct dirent * entry;
  entry = readdir( d->dir );
  if( entry )
  {
    fi.name = entry->d_name;
    sprintf( buf, "%s/%s", d->path, fi.name );
    lstat( buf, &st );
    fi.attr.mode = st.st_mode & 0xffff;
    fi.attr.uid = st.st_uid;
    fi.attr.gid = st.st_gid;
    fi.attr.size = st.st_size;
    fi.attr.atime = st.st_atime;
    fi.attr.mtime = st.st_mtime;
    fi.attr.ctime = st.st_ctime;
    type = 'f';
    if( S_ISBLK( st.st_mode ) )
      type = 'b';
    if( S_ISCHR( st.st_mode ) )
      type = 'c';
    if( S_ISDIR( st.st_mode ) )
      type = 'd';
    if( S_ISLNK( st.st_mode ) )
      type = 'l';
    if( S_ISFIFO( st.st_mode ) )
      type = 'p';
    if( S_ISSOCK( st.st_mode ) )
      type = 's';
    fi.attr.type = type;
    return &fi;
  }
  else
    return NULL;
}

void dir_delete( Dir * d )
{
  closedir( d->dir );
  free( d );
}

#endif
