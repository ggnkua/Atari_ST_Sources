/*
 * AUDIO.H - Fonctions d'interfaçage avec les fichiers audio
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

#ifndef __AUDIO_H__
#define __AUDIO_H__

typedef union
{
  unsigned long frequence;
  char          freq_replay;
} avr_freq_type;

struct avr_header
{
  unsigned long avr_id;
  char          name[8];
  short         num_voices;
  short         num_bits;
  short         signe;
  short         loop;
  short         midi;
  avr_freq_type freq_type;	
  unsigned long length;
  unsigned long beg_loop;
  unsigned long end_loop;
  char          reserved[26];
  char          user[64];
};

struct wave_header
{
  unsigned long  riff_id;
  unsigned long  riff_len;
  unsigned long  wave_id;
  unsigned long  fmt_id;
  unsigned long  fmt_size;
  unsigned short fmt_compression_code;
  unsigned short fmt_channels;
  unsigned long  fmt_freq;
  unsigned long  fmt_bytes_sec;
  unsigned short fmt_block_align;
  unsigned short fmt_num_bits;
  unsigned long  data_id;
  unsigned long  data_size;
};

/* Définition de la source d'une piste dans une image DAO de type "audio" */
struct audio_entry
{
  int type;              /* Type d'entrée audio */
    #define AET_FILE 1     /* Fichier audio (raw,wav,avr ou aiff) */
    #define AET_DAOIMG 2   /* Fichier image DAO */
    #define AET_CD 3       /* CD audio */
  /*long pause;            /* Nombre de blocs de pause */
  long zap_beg;          /* Nombre de blocs à zapper au début */
  long zap_end;          /* Nombre de blocs à zapper à la fin */
  union
  {
    struct
    {
      char   filename[256];  /* Chemin complet du fichier */
      int    little_endian;  /* 0 si big endian, sinon c'est du little */
      size_t header_size;    /* Taille du header à zapper */
    } file;
    struct
    {
      char   filename[256];  /* Chemin complet du fichier */
      int    track_no;       /* Numéro de la piste à ripper */
    } daoimg;
    struct
    {
      struct device_info * info; /* Informations du device */
      int track_no;          /* Numéro de la piste à ripper */
    } cd;
  } spec;
};

/* Structure de flux audio */

struct audio_stream
{
  int type;              /* Type de flux audio */
    #define AST_FILE 1     /* Fichier audio */
    #define AST_DAO  2     /* Flux DAO */
  long block_count;      /* Nombre de blocs */
  int little_endian;     /* 0 si big endian, sinon c'est du little */
  union
  {
    struct
    {
      char * filename;       /* Chemin complet du fichier */
      size_t header_size;    /* Taille du header à zapper */
    } file;
    struct
    {
      struct idao_stream * stream;
      long position;         /* Position sur le CD */
    } dao;
  } spec;
};

long audio_read( struct audio_stream * in, void * buffer, long nblocks );
struct audio_stream * audio_open( struct audio_entry * entry );
struct audio_stream * audio_reopen( struct audio_stream *in, struct audio_entry * entry );
int audio_close( struct audio_stream * stream );
int audio_gen_toc( struct ext_toc * toc, struct audio_entry * entry, int entry_count );
int gen_daoimg_entry( struct audio_entry * entry, char * filename, int track_no,
                      long zap_beg, long zap_end );
int gen_cd_entry( struct audio_entry * entry, struct device_info * info,
                  int track_no, long zap_beg, long zap_end );

#endif
