/*
 * TAO.H - Fonctions de gestion du mode TAO
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

#ifndef _TAO_H_
#define _TAO_H_

enum track_type { ISO_FILE, ISO_GEN, AUDIO };

struct tao_track
{
  enum track_type type;
  int blocksize;
  long blocks;
  union
  {
    struct
    {
      char * name;
      int handle;
    } file;
    struct
    {
      IsoGenerator * gen;
    } ig;
  } spec;
};

enum to_type { TAO_CDR, TAO_FILE };

struct tao_ostream
{
  enum to_type type;
  union
  {
    struct
    {
      struct device * dev;
    } cdr;
    struct
    {
      int fd;
    } file;
  } t;
};

struct tao_track * tao_track_new_ig( const char * path, int blocksize );
struct tao_track * tao_track_new_iso( const char * filename, int blocksize );
void tao_track_dispose( struct tao_track * track );

struct tao_ostream * tao_open( struct device_info * info );
struct tao_ostream * tao_open_file( const char * filename );
void tao_close( struct tao_ostream * stream );
int tao_pipe( struct tao_track **in, int track_count, struct tao_ostream *out );

#endif

