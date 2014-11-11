/*
 * iso9660.c - gestion des systèmes de fichiers ISO 9660
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

#define _ISO9660_C_

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>

#include "iso9660.h"
#include "dir.h"
#include "misc.h"

#ifdef __GNUC__
/* Librairies C standard */
# include <unistd.h>
# include <sys/types.h>
# include <sys/stat.h>
# include <fcntl.h>
#else
#endif

#define LEVELS 8   /* profondeur max pour les répertoires */

typedef int (* read_step)( IsoGenerator * gen, void * buf, long * count );

/*
 * Structures ISO 9660
 */

/* Mot en little endian */
struct iso_le_word
{
  unsigned char lsb;
  unsigned char msb;
};

/* Mot en big endian */
struct iso_be_word
{
  unsigned char msb;
  unsigned char lsb;
};

/* Mot double en little endian */
struct iso_le_dword
{
  unsigned char lsb;
  unsigned char tmsb;
  unsigned char smsb;
  unsigned char msb;
};

/* Mot double en big endian */
struct iso_be_dword
{
  unsigned char msb;
  unsigned char smsb;
  unsigned char tmsb;
  unsigned char lsb;
};

/* Mot en both endian */
struct iso_word
{
  struct iso_le_word little;
  struct iso_be_word big;
};

/* Mot double en both endian */
struct iso_dword
{
  struct iso_le_dword little;
  struct iso_be_dword big;
};

struct iso_datetime
{
  char year[4];
  char month[2];
  char day[2];
  char hour[2];
  char minute[2];
  char second[2];
  char hundredths[2];
  signed char gmt_offset;
};

/* Structure du Primary Volume Descriptor */
struct iso_pvd
{
  char header[8];
  char system_id[32];
  char volume_id[32];
  char zero1[8];
  struct iso_dword sector_count;
  char zero2[32];
  struct iso_word volume_set_size;      /* 1 */
  struct iso_word volume_sequence_number; /* 1 */
  struct iso_word sector_size;          /* 2048 */
  struct iso_dword path_table_length;   /* octets */
  struct iso_le_dword flept_first_sector;
  struct iso_le_dword slept_first_sector;   /* 0 */
  struct iso_be_dword fbept_first_sector;
  struct iso_be_dword sbept_first_sector;   /* 0 */
  char root_dr[34];
  char volume_set_id[128];
  char publisher_id[128];
  char preparer_id[128];
  char application_id[128];
  char copyright_file_id[37];
  char abstract_file_id[37];
  char bibliographical_file_id[37];
  struct iso_datetime volume_creation_date;
  struct iso_datetime most_recent_modification_date;
  struct iso_datetime expiration_date;
  struct iso_datetime effective_date;
  char one;                             /* 1 */
  char zero3;
  char reserved[512];
  char zero4[653];
};

/* structure générique pour une entrée de répertoire */
struct dir_entry
{
  long name;
  long iso_name;
  struct fileattr attr;

  /* Taille du fichier ou du répertoire en blocs */
  long blocks;
  /* Position absolue du fichier */
  long offset;

  /* Données spécifiques à un répertoire */
  int rec_num;    /* Numéro dans la path table */
  struct dir_entry * parent;     /* répertoire parent */
  long count;     /* Nombre de fichiers et sous-répertoires */
  long sub;       /* premier élément du sous répertoire (offset, pas index!) */
};

struct iso_generator
{
  struct
  {
    int joliet       : 1;
    int rock_ridge   : 1;

    int filler       : 14;
  } conf;

  /* ino_t * hardlinks_list; */
  char * string_buf;
  long string_buflen;
  struct dir_entry * entries[LEVELS];  /* entrées, pour les 8 niveaux de réps */
  long count[LEVELS]; /* compteurs d'entrées pour les 8 niveaux */

  struct dir_entry root;
  char * le_path_table;
  char * be_path_table;
  long path_table_length;
  long path_table_length_bytes;
  long full_length;

  int blocksize;
  long location;
  long sys_id;
  long vol_id;
  long vs_id;
  long pb_id;
  long pr_id;
  long ap_id;

  /* valeurs de séquencement */
  time_t creation_time;
  long seq;         /* compteur de séquence multi-usage */
  long file_seq;    /* nombre de blocs restant à lire dans le fichier */
  long file_entry;  /* n° d'entrée dans le niveau (parcours en largeur) */
  int file_level;   /* niveau de rép. du fichier qu'on est en train de lire */
  union
  {
    struct
    {
      int fd;       /* id du fichier ouvert avec open() */
    } file;
    struct
    {
      char * buffer;  /* buffer contenant le répertoire */
      char * position;
    } dir;
  } t;
  
  read_step next;
};


#define VBLK_GRANULARITY 0x8000L /* granularité des tailles de blocs */
/* ajoute <size> octets nuls au bloc alloué. si *blk_ptr est NULL, on alloue
 * un premier bloc.
 * Renvoie un offset à partir du buffer.
 * [ on suppose ici que sizeof( void * ) == sizeof( long ) ]
 */
static long vblk_inc_size( void ** blk_ptr, long * blk_size, long size )
{
  char * buf;
  long block_size, full_size, new_size;
  buf = *blk_ptr;
  block_size = ( buf ? *blk_size : 0 );
  new_size = block_size + size;
  full_size = (block_size + (VBLK_GRANULARITY - 1)) & -VBLK_GRANULARITY;
  if( new_size > full_size )
  {
    /* char * buf2 = buf; */
    full_size += VBLK_GRANULARITY;
    buf = xrealloc( buf, full_size );
    /* printf( "buf = %p => %p, full_size = %ld\n", buf2, buf, full_size ); */
    *blk_ptr = buf;
  }
  *blk_size = new_size;
  return block_size;
}

/* Copie une chaîne pour l'iso_generator <gen> */
static long alloc_string( IsoGenerator * gen, const char * str )
{
  char * new;
  long ret;
  ret = vblk_inc_size( (void**)&gen->string_buf, &gen->string_buflen,
      strlen( str ) + 1 );
  new = gen->string_buf + ret;
  strcpy( new, str );
  return ret;
}

/*
 * Fonctions internes
 */
static void iso_set_le_word( struct iso_le_word * adr, short value )
{
  adr->lsb = value;
  adr->msb = value>>8;
}

static void iso_set_be_word( struct iso_be_word * adr, short value )
{
  adr->lsb = value;
  adr->msb = value>>8;
}

static void iso_set_word( struct iso_word * adr, short value )
{
  iso_set_le_word( &adr->little, value );
  iso_set_be_word( &adr->big, value );
}

static void iso_set_le_dword( struct iso_le_dword * adr, long value )
{
  adr->lsb = value;
  value >>= 8;
  adr->tmsb = value;
  value >>= 8;
  adr->smsb = value;
  value >>= 8;
  adr->msb = value;
}

static void iso_set_be_dword( struct iso_be_dword * adr, long value )
{
  adr->lsb = value;
  value >>= 8;
  adr->tmsb = value;
  value >>= 8;
  adr->smsb = value;
  value >>= 8;
  adr->msb = value;
}

static void iso_set_dword( struct iso_dword * adr, long value )
{
  iso_set_le_dword( &adr->little, value );
  iso_set_be_dword( &adr->big, value );
}

static void iso_set_datetime( struct iso_datetime * dt, int year, int month,
    int day, int hour, int minute, int second, int hundredths,
    signed int gmt_offset )
{
  char buf[8];
  sprintf( buf, "%04d", year + 1900 );
  memcpy( &dt->year, buf, 4 );
  sprintf( buf, "%02d", month + 1 );
  memcpy( &dt->month, buf, 2 );
  sprintf( buf, "%02d", day );
  memcpy( &dt->day, buf, 2 );
  sprintf( buf, "%02d", hour );
  memcpy( &dt->hour, buf, 2 );
  sprintf( buf, "%02d", minute );
  memcpy( &dt->minute, buf, 2 );
  sprintf( buf, "%02d", second );
  memcpy( &dt->second, buf, 2 );
  sprintf( buf, "%02d", hundredths );
  memcpy( &dt->hundredths, buf, 2 );
  sprintf( buf, "%02d", gmt_offset / 900 );
  memcpy( &dt->gmt_offset, buf, 2 );
}

static void iso_set_datetime_from_time_t(
    struct iso_datetime * dt, time_t t )
{
  struct tm * tm;
  tm = gmtime( &t );
  iso_set_datetime( dt, tm->tm_year, tm->tm_mon, tm->tm_mday, tm->tm_hour,
      tm->tm_min, tm->tm_sec, 0, 0 );
}

static void iso_set_dir_datetime( char * buf, time_t t )
{
  struct tm * tm;
  tm = gmtime( &t );
  buf[ 0 ] = tm->tm_year;
  buf[ 1 ] = tm->tm_mon + 1;
  buf[ 2 ] = tm->tm_mday;
  buf[ 3 ] = tm->tm_hour;
  buf[ 4 ] = tm->tm_min;
  buf[ 5 ] = tm->tm_sec;
  /* buf[ 6 ] = tm->tm_gmtoff/900; */
}

static char * endswith( const char * str, const char * pattern )
{
  char * pos = strstr( str, pattern );
  if( pos && pos == (str + strlen( str ) - strlen( pattern )) )
    return pos;
  else
    return NULL;
}

static void iso_format_name( char * str, int size )
{
  int i;
  char c;
  for( i = 0; i < size; i++ )
  {
    c = str[ i ];
    if( (c>='0' && c<='9') || (c>='A' && c<='Z') || (c>='a' && c<='z') )
      str[ i ] = toupper( c );
    else
      str[ i ] = '_';
  }
}

static void mangle( IsoGenerator * gen, struct dir_entry * entry )
{
  char buf[ 16 ];
  const char * ext, * fullname, * str;
  char * pos;
  int namelength, extlength, length;

  str = gen->string_buf;
  fullname = str + entry->name;
  if( (pos=endswith( fullname, ".tar.gz" )) != NULL )
    ext = "tgz";
  else if( (pos=endswith( fullname, ".tar.bz2" )) != NULL )
    ext = "tz2";
  else
  {
    pos = strrchr( fullname, '.' );
    if( pos == fullname )
      pos = NULL;
    if( pos )
      ext = pos + 1;
  }
  if( pos )
  {
    namelength = (int)(pos - (char*)fullname);
    if( namelength > 8 )
      namelength = 8;
    strncpy( buf, fullname, namelength );
    iso_format_name( buf, namelength );
    buf[ namelength ] = '.';
    extlength = (int)strlen( ext );
    if( extlength > 3 )
      extlength = 3;
    pos = buf + namelength + 1;
    memcpy( pos, ext, extlength );
    iso_format_name( pos, extlength );
    length = namelength + extlength + 1;
  }
  else
  {
    namelength = (int)strlen( fullname );
    if( namelength > 8 )
      namelength = 8;
    memcpy( buf, fullname, namelength );
    iso_format_name( buf, namelength );
    length = namelength;
  }
  buf[ length ] = '\0';
  entry->iso_name = alloc_string( gen, buf );
}

static char * compare_buf;
static int compare_fullname( const void * i1, const void * i2 )
{
  return strcmp( compare_buf + ((const struct dir_entry *)i1)->name,
      compare_buf + ((const struct dir_entry *)i2)->name );
}

static int compare_isoname( const void * i1, const void * i2 )
{
  return strcmp( compare_buf + ((const struct dir_entry *)i1)->iso_name,
      compare_buf + ((const struct dir_entry *)i2)->iso_name );
}

/* Faire en sorte que les noms ISO des éléments du tableau soient uniques */
static void make_unique( struct dir_entry * tab, long count )
{
  char format[8];
  char num[8+1];
  long index, stop, stop2, i, neq, tmp, log;
  char * str = compare_buf;
  index = 0;
  stop = count - 1;
  while( index < stop )
  {
    if( !strcmp( str + tab[index].iso_name, str + tab[index+1].iso_name ) )
    {
      neq = 2;
      stop2 = count - index;
      while( neq < stop2 &&
          !strcmp( str + tab[index].iso_name, str + tab[index+neq].iso_name ) )
        neq++;
      neq--;  /* Nombre de valeurs égales - 1 (on ne gère pas la 1ere) */
      /* Calcul du log_10( neq ) */
      tmp = neq-1;
      log = 0;
      do
      {
        tmp /= 10;
        log++;
      }
      while( tmp );
      sprintf( format, "%%0%dd", log );
      for( i = 0; i < neq; i++ )
      {
        sprintf( num, format, i );
        memcpy( str + tab[index+i+1].iso_name+8-log, num, log );
      }
      index += neq + 1;
    }
    else
      index++;
  }
}

static long scandir( IsoGenerator * gen, const char * dir, int level )
{
  char buf[ NAME_MAX + 1 ];
  struct fileinfo fi;
  struct dir_entry * i, * prem;
  long offset, count, k, c;
  int blocksize;
  long array_size;
  int error;

  /* Teste si l'on a parcouru la profondeur max */
  if( level == LEVELS )
    return -1;

  blocksize = gen->blocksize;
  offset = gen->count[ level ];
  array_size = offset * sizeof( struct dir_entry );
  count = 0;
  error = dir_read_first( dir, &fi );
  while( !error )
  {
    if( strcmp( fi.name, "." ) && strcmp( fi.name, ".." ) )
    {
      i = (struct dir_entry *)
          (vblk_inc_size( (void**)&gen->entries[ level ], &array_size,
          sizeof( struct dir_entry ) ) + (char*)gen->entries[ level ]);
      i->name = alloc_string( gen, fi.name );
      i->attr = fi.attr;
      i->blocks = ( fi.attr.size + blocksize - 1 ) / blocksize;
      mangle( gen, i );
      count++;
    }
    error = dir_read_next( &fi );
  }

  gen->count[ level ] = offset + count;
  prem = gen->entries[ level ] + offset;

  compare_buf = gen->string_buf;
  /* Triage des entrées selon le nom long */
  qsort( prem, count, sizeof( struct dir_entry ), compare_fullname );
  /* Traitement des noms de fichiers identiques */
  make_unique( prem, count );
  /* Triage des entrées selon le nom court */
  qsort( prem, count, sizeof( struct dir_entry ), compare_isoname );

  /* Parcours des sous-répertoires (impérativement après les tris) */
  i = prem;
  for( k = 0; k < count; k++ )
  {
    if( i->attr.type == 'd' )
    {
      sprintf( buf, "%s" DIR_SEPARATOR "%s", dir, gen->string_buf + i->name );
      c = scandir( gen, buf, level + 1 );
      if( c < 0 )
        return c;
      i->count = c;
      i->sub = (gen->count[level + 1] - i->count) * sizeof( struct dir_entry );
    }
    i++;
  }
  return count;
}

static long calc_dir_blocks( IsoGenerator * ig, struct dir_entry * j, long max )
{
  long blocks, k;
  int fullness, namesize;
  blocks = 1;
  fullness = 34*2;  /* les 2 premiers répertoires "." et ".." */
  for( k = 0; k < max; k++ )
  {
    namesize = 33 + (int)strlen( ig->string_buf + j->iso_name );
    if( j->attr.type != 'd' )
      namesize += 2;      /* ";1" */
    namesize = (namesize+1) & -2;
    fullness += namesize;
    if( fullness > ig->blocksize )
    {
      blocks ++;
      fullness = namesize;
    }
    j++;
  }
  return blocks;
}

static void set_path_table_record( char ** lept, char ** bept, long * offset,
    const struct dir_entry * entry, const char * str )
{
  char * l = *lept, * b = *bept;
  int n;
  if( entry->name < 0 )
    /* racine */
    n = 1;
  else
  {
    n = (int)strlen( str + entry->iso_name );
    memcpy( l + 8, str + entry->iso_name, n );
    memcpy( b + 8, str + entry->iso_name, n );
  }
  l[ 0 ] = n;
  b[ 0 ] = n;
  iso_set_le_dword( (struct iso_le_dword *) (l + 2), *offset );
  iso_set_be_dword( (struct iso_be_dword *) (b + 2), *offset );
  iso_set_le_word( (struct iso_le_word *) (l + 6), entry->parent->rec_num );
  iso_set_be_word( (struct iso_be_word *) (b + 6), entry->parent->rec_num );
  n = (n+8+1) & -2;
  *offset += entry->blocks;
  *lept += n;
  *bept += n;
}

/* calcul de la taille des répertoires en secteurs, ainsi que de la structure
 * de la path table. Puis, génère les path tables
 */
static void gen_path_tables( IsoGenerator * ig )
{
  long table_length, next_offset;
  int namesize;
  int blocksize = ig->blocksize;
  long k, max;
  int level, record;
  struct dir_entry * i, * j, * end;
  const char * str;
  char * lept, * bept;

  str = ig->string_buf;
  level = 0;
  record = 1;
  table_length = 10;  /* inclusion du root directory */
  j = &ig->root;
  j->parent = j;
  j->rec_num = 1;
  j->count = ig->count[ 0 ];
  j->blocks = calc_dir_blocks( ig, ig->entries[0], j->count );
  j->name = -1;
  j->attr.type = 'd';
  j->attr.mtime = ig->creation_time;

  while( level < LEVELS && (k = ig->count[ level ]) != 0 )
  {
    i = ig->entries[ level ];
    end = i + k;
    while( i < end )
    {
      if( i->attr.type == 'd' )
      {
        record ++;
        i->rec_num = record;
        if( level == 0 )
          i->parent = &ig->root;
        namesize = 8 + (int)strlen( str + i->iso_name );
        table_length += (namesize+1) & -2;

        j = (struct dir_entry*)((char*)(ig->entries[ level+1 ]) + i->sub);
        max = i->count;
        i->blocks = calc_dir_blocks( ig, j, max );
        while( max-- )
        {
          j->parent = i;
          j++;
        }
      }
      i++;
    }
    level ++;
  }
  ig->path_table_length_bytes = table_length;
  table_length = (table_length + blocksize - 1) / blocksize;
  lept = xmalloc( table_length * blocksize );
  bept = xmalloc( table_length * blocksize );
  next_offset = 16 + (ig->conf.joliet ? 3 : 2) + table_length * 2;
  ig->root.offset = next_offset;
  ig->path_table_length = table_length;
  ig->le_path_table = lept;
  ig->be_path_table = bept;

  /* remplissage de la path table et calcul des offsets de répertoires */
  set_path_table_record( &lept, &bept, &next_offset, &ig->root, str );
  level = 0;
  while( level < LEVELS && (k = ig->count[ level ]) != 0 )
  {
    i = ig->entries[ level++ ];
    end = i + k;
    while( i < end )
    {
      if( i->attr.type == 'd' )
      {
        i->offset = next_offset;
        set_path_table_record( &lept, &bept, &next_offset, i, str );
      }
      i++;
    }
  }

  /* calcul des offsets de fichiers */
  level = 0;
  while( level < LEVELS && (k = ig->count[ level ]) != 0 )
  {
    i = ig->entries[ level++ ];
    end = i + k;
    while( i < end )
    {
      if( i->attr.type != 'd' )
      {
        i->offset = (i->blocks ? next_offset : 0);
        next_offset += i->blocks;
      }
      i++;
    }
  }
  /* Taille totale de l'image en blocs */
  ig->full_length = next_offset;
}

/* remplissage d'un directory record, avec gestion des trous en fin de bloc */
static void iso_set_dir_entry( char ** begin, const struct dir_entry * entry,
    int blocksize, const char * iso_name, int * fullness )
{
  int recordlength;
  int namelength;
  int rem_size = *fullness;
  char * buf = *begin;
  namelength = (int)strlen( iso_name );
  if( namelength == 0 )
    /* cas du répertoire '.' */
    namelength = 1;
  recordlength = 33 + namelength;
  if( recordlength % 2 )
    recordlength ++;
  if( recordlength > rem_size )
  {
    /* taille du record plus grande que la taille restante -> nouveau bloc */
    buf += rem_size;
    rem_size = blocksize;
  }
  buf[ 0 ] = recordlength;
  buf[ 1 ] = 0;
  iso_set_dword( (struct iso_dword *) (buf + 2), entry->offset );
  iso_set_dword( (struct iso_dword *) (buf + 10),
      (entry->attr.type == 'd' ? entry->blocks * blocksize :
       entry->attr.size) );
  iso_set_dir_datetime( buf + 18, entry->attr.mtime );
  buf[ 25 ] = entry->attr.type == 'd' ? 2 : 0;
  buf[ 26 ] = 0;
  buf[ 27 ] = 0;
  iso_set_word( (struct iso_word *) (buf + 28), 1 );
  buf[ 32 ] = namelength;
  memcpy( buf + 33, iso_name, namelength );
  if( (namelength % 2) == 0 )
    buf[ 33 + namelength ] = 0;
  *fullness = rem_size - recordlength;
  *begin = buf + recordlength;
}

static int iso_read_nothing( IsoGenerator * gen, void * buf, long * count )
{
  printf( "problem (iso_read_nothing)\n" );
  *count = 0;
  return 0;
}

static int iso_read_files( IsoGenerator * gen, void * buf, long * count )
{
  const char * names[ 64 ];
  char pathname[ 256 ];
  char * dest;
  const struct dir_entry * i, * j;
  const char *str;
  int fd;
  int level, k, blocksize;
  long entry, file_seq, n, m;

  if( gen->seq == 0 )
  {
    /* premier appel de la fonction, il faut initialiser tout ça */
    gen->seq = 1;     /* seq est fixé à une constante non nulle */
    level = 0;
    entry = -1;       /* pour se caler à 0 à la première incrémentation */
    file_seq = 0;
  }
  else
  {
    level = gen->file_level;
    entry = gen->file_entry;
    file_seq = gen->file_seq;
  }

  if( file_seq == 0 )
  {
    /* Ouverture d'un nouveau fichier */
    do
    {
      entry ++;
      if( entry == gen->count[ level ] )
      {
        level ++;
        entry = 0;
        if( level >= LEVELS || gen->count[ level ] == 0 )
        {
          /* C'est la fin de la lecture des répertoires */
          gen->seq = 0;
          gen->next = iso_read_nothing;
          goto okay;
        }
      }
    } while( gen->entries[ level ][ entry ].attr.type != 'f' );
    i = &gen->entries[ level ][ entry ];
    file_seq = gen->entries[ level ][ entry ].attr.size;

    /* Recherche du chemin absolu du fichier */
    str = gen->string_buf;
    j = i;
    for( k = level; k >= 0; k -- )
    {
      names[ k ] = str + j->name;
      j = j->parent;
    }
    strcpy( pathname, str + gen->location );
    dest = pathname + strlen( pathname );
    for( k = 0; k <= level; k ++ )
    {
      sprintf( dest, DIR_SEPARATOR "%s", names[ k ] );
      dest += strlen( dest );
    }

    fd = open( pathname, O_RDONLY );
    gen->t.file.fd = fd;
  }
  else
    fd = gen->t.file.fd;

  blocksize = gen->blocksize;
  n = *count * blocksize;
  if( n > file_seq )
    n = file_seq;
  read( fd, buf, n );
  if( ( file_seq -= n ) == 0 )
  {
    close( fd );
    m = n + blocksize - 1;
    m -= m % blocksize;
    memset( ((char*)buf) + n, 0, m - n );
  }

  gen->file_seq = file_seq;
  gen->file_level = level;
  gen->file_entry = entry;
  *count -= ((n + blocksize - 1) / blocksize);

okay:
  return 0;
}

static int iso_read_dirs( IsoGenerator * gen, void * buf, long * count )
{
  char strbuf[16];
  const struct dir_entry * i, * j;
  int level;
  long file_seq;
  long k, n;
  long entry, bytes;
  char * pos, *ptr;
  const char * str;
  int fullness, blocksize;

  entry = 0; /* pour faire plaisir au compilateur */
  if( gen->seq == 0 )
  {
    /* premier appel de la fonction, il faut générer le root directory */
    gen->seq = 1;     /* seq est fixé à une constante non nulle */
    level = -1;
    file_seq = 0;
    /* entry n'est pas utilisé pour le root directory */
  }
  else
  {
    level = gen->file_level;
    entry = gen->file_entry;
    file_seq = gen->file_seq;
  }

  if( file_seq == 0 )
  {
    /* Ouverture d'un nouveau dossier, on alloue un buffer et on le remplit */
    if( level < 0 )
    {
      /* cas spécial du root directory */
      i = &gen->root;
      file_seq = gen->root.blocks;
    }
    else
    {
      /* recherche du premier directory à partir de la position suivante,
       * avec détection du dernier directory
       */
      do
      {
        entry ++;
        if( entry == gen->count[ level ] )
        {
          level ++;
          entry = 0;
          if( level >= LEVELS || gen->count[ level ] == 0 )
          {
            /* C'est la fin de la lecture des répertoires */
            gen->seq = 0;
            gen->next = iso_read_files;
            goto okay;
          }
        }
      } while( gen->entries[ level ][ entry ].attr.type != 'd' );
      i = &gen->entries[ level ][ entry ];
      file_seq = gen->entries[ level ][ entry ].blocks;
    }
    blocksize = gen->blocksize;
    pos = xmalloc( blocksize * file_seq );
    gen->t.dir.buffer = pos;
    /* Il ne reste plus qu'à générer le directory en question */
    j = (struct dir_entry*)((char*)(gen->entries[ level+1 ]) + i->sub);
    n = i->count;

    /* On commence par les répertoires '.' et '..' */
    ptr = pos;
    fullness = blocksize;
    iso_set_dir_entry( &ptr, i, blocksize, "\0", &fullness );
    iso_set_dir_entry( &ptr, i->parent, blocksize, "\1", &fullness );

    /* on continue avec les autres répertoires */
    str = gen->string_buf;
    for( k = 0; k < n; k++ )
    {
      if( j->attr.type == 'd' )
        iso_set_dir_entry( &ptr, j, blocksize, str + j->iso_name, &fullness );
      else
      {
        sprintf( strbuf, "%s;1", str + j->iso_name );
        iso_set_dir_entry( &ptr, j, blocksize, strbuf, &fullness );
      }
      j++;
    }

    if( level < 0 )
    {
      /* on force les prochaines valeurs, si on était en train de traiter le
       * root directory */
      entry = -1;   /* de sorte qu'à la 1ere incrémentation ça fasse zéro */
      level = 0;
    }
  }
  else
  {
    pos = gen->t.dir.position;
  }
  /* Ici le dossier est ouvert, et on "lit" le contenu (simple copie mémoire)*/

  n = *count;
  if( n > file_seq )
    n = file_seq;
  bytes = gen->blocksize * n;
  memcpy( buf, pos, bytes );
  file_seq -= n;
  pos += bytes;
  if( file_seq == 0 )
    free( gen->t.dir.buffer );
  gen->t.dir.position = pos;
  gen->file_seq = file_seq;
  gen->file_level = level;
  gen->file_entry = entry;
  *count -= n;

okay:
  return 0;
}

static int iso_read_pt( IsoGenerator * gen, void * buf, long * count,
    const char * path_table, read_step next, long next_seq )
{
  long offset;
  long n = *count;
  if( n > gen->seq )
    n = gen->seq;
  *count -= n;
  offset = (gen->path_table_length - gen->seq) * gen->blocksize;
  memcpy( buf, path_table + offset, gen->blocksize * n );
  if( ! ( gen->seq -= n ) )
  {
    gen->next = next;
    gen->seq = next_seq;
  }
  return 0;
}

static int iso_read_bept( IsoGenerator * gen, void * buf, long * count )
{
  return iso_read_pt( gen, buf, count, gen->be_path_table, iso_read_dirs, 0 );
}

static int iso_read_lept( IsoGenerator * gen, void * buf, long * count )
{
  return iso_read_pt( gen, buf, count, gen->le_path_table, iso_read_bept,
      gen->path_table_length );
}

static void fill_name( char * dest, const char * str, int len )
{
  int rest;
  int str_len;

  strncpy( dest, str, len );
  str_len = (int)strlen( str );
  rest = len - str_len;
  if( rest )
    memset( dest + str_len, ' ', rest );
}

static int iso_read_vdst( IsoGenerator * gen, void * buf, long * count )
{
  memcpy( buf, "\377CD001\1", 8 );
  memset( ((char*)buf) + 8, 0, gen->blocksize - 8 );
  *count -= 1;
  gen->seq = gen->path_table_length;
  gen->next = iso_read_lept;
  return 0;
}

static int iso_read_svd( IsoGenerator * gen, void * buf, long * count )
{
  *count -= 1;
  gen->next = iso_read_vdst;
  return 0;
}

static int iso_read_pvd( IsoGenerator * gen, void * buf, long * count )
{
  struct iso_pvd * pvd = buf;
  const char * str = gen->string_buf;
  char * root;
  int dummy = 2048;
  int after_header = 16 + (gen->conf.joliet ? 3 : 2);

  memset( buf, 0, gen->blocksize );
  memcpy( pvd->header, "\1CD001\1", 8 );
  fill_name( pvd->system_id, str + gen->sys_id, 32 );
  fill_name( pvd->volume_id, str + gen->vol_id, 32 );
  iso_set_dword( &pvd->sector_count, gen->full_length );
  iso_set_word( &pvd->volume_set_size, 1 );
  iso_set_word( &pvd->volume_sequence_number, 1 );
  iso_set_word( &pvd->sector_size, gen->blocksize );
  iso_set_dword( &pvd->path_table_length, gen->path_table_length_bytes );
  iso_set_le_dword( &pvd->flept_first_sector, after_header );
  iso_set_be_dword( &pvd->fbept_first_sector,
      after_header + gen->path_table_length );
  root = pvd->root_dr;
  iso_set_dir_entry( &root, &gen->root, gen->blocksize, "\0", &dummy );
  fill_name( pvd->volume_set_id, str + gen->vs_id, 128 );
  fill_name( pvd->publisher_id, str + gen->pb_id, 128 );
  fill_name( pvd->preparer_id, str + gen->pr_id, 128 );
  fill_name( pvd->application_id, str + gen->ap_id, 128 );
  iso_set_datetime_from_time_t( &pvd->volume_creation_date,gen->creation_time );
  memcpy( &pvd->most_recent_modification_date,
      &pvd->volume_creation_date, sizeof( struct iso_datetime ) );
  memcpy( &pvd->effective_date, &pvd->volume_creation_date,
      sizeof( struct iso_datetime ) );
  *count -= 1;
  pvd->one = 1;
  gen->next = gen->conf.joliet ? iso_read_svd : iso_read_vdst;
  return 0;
}

static int iso_read_first( IsoGenerator * gen, void * buf, long * count )
{
  long n = *count;
  if( n > gen->seq )
    n = gen->seq;
  memset( buf, 0, gen->blocksize * n );
  if( ! ( gen->seq -= n ) )
    gen->next = iso_read_pvd;
  *count -= n;
  return 0;
}

/*
 * Fonctions exportées
 */

IsoGenerator * iso_new( const char * dir, const char * sys_id, const char *
    vol_id, const char * vs_id, const char * pb_id, const char * pr_id, const
    char * ap_id, int blocksize )
{
  long c;
  int i;
  IsoGenerator * ig = xmalloc( sizeof( IsoGenerator ) );

  ig->location = alloc_string( ig, dir );
  ig->blocksize = blocksize;
  ig->creation_time = time( NULL );
  ig->sys_id = alloc_string( ig, sys_id );
  ig->vol_id = alloc_string( ig, vol_id );
  ig->vs_id = alloc_string( ig, vs_id );
  ig->pb_id = alloc_string( ig, pb_id );
  ig->pr_id = alloc_string( ig, pr_id );
  ig->ap_id = alloc_string( ig, ap_id );

  dir_init();
  c = scandir( ig, dir, 0 );
  if( c < 0 )
  {
    free( ig->string_buf );
    for( i = 0; i < LEVELS; i++ )
      if( ig->entries[i] )
        free( ig->entries[i] );
    free( ig );
    ig = NULL;
  }
  else
  {
    gen_path_tables( ig );

    ig->next = iso_read_first;
    ig->seq = 16;
  }
  return ig;
}

void iso_delete( IsoGenerator * ig )
{
  int i;
  free( ig->be_path_table );
  free( ig->le_path_table );
  if( ig->string_buf )
    free( ig->string_buf );
  for( i = 0; i < LEVELS; i++ )
    if( ig->entries[i] )
      free( ig->entries[i] );
  free( ig );
}

long iso_blocks( IsoGenerator * ig )
{
  return ig->full_length;
}

int iso_read( IsoGenerator * gen, void * buf, long nblocks )
{
  int ret;
  long n;
  do
  {
    n = nblocks;
    ret = gen->next( gen, buf, &nblocks );
    (char*)buf += gen->blocksize * ( n - nblocks );
  } while( nblocks && !ret );
  return ret;
}

