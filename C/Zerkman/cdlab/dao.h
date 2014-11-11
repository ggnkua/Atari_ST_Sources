/*
 * DAO.H - Fonctions de gestion du mode DAO
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

/* Objet désignant une piste, ou une liste de pistes */

#ifndef __DAO_H__
#define __DAO_H__

#include "device.h"
#include "common.h"
#include "audio.h"

/* Structure de localisation de changement de piste/index */
struct index_position
{
  unsigned char session;   /* Numéro de session */
  unsigned char track;     /* Numéro de piste */
  unsigned char index;     /* Numéro d'index */
  unsigned char control;   /* Champ de contrôle */
  unsigned short blocksize; /* Taille d'un bloc */
  signed long offset;      /* Adresse absolue de l'index */
};

/* Structure de flags de stream DAO */
struct _dao_flags
{
  int audio_little_endian : 1;
  int dummy               : 15;
};

/* Structure header de fichier DAO */
struct dao_file_header
{
  unsigned short version;
  int header_size;            /* Taille du header complet */
  int toc_size;               /* Taille de la TOC étendue */
  int index_count;            /* Nombre d'entrées dans la table des index */
  struct _dao_flags flags;    /* Configs générales */
};

/* Structure de lecture DAO */
struct idao_stream
{
  unsigned short type;        /* Type du stream */
    #define TST_FILE  1         /* Fichier */
    #define TST_CD    2         /* CD */
    #define TST_AUDIO 3         /* Séquence de fichiers audio */
  struct _dao_flags flags;    /* Configs générales */
  struct ext_toc toc;         /* Toc étendue du CD */
  union
  {
    struct
    {
      int handle;             /* Handle du fichier */
      int header_size;        /* Taille du header */
      unsigned long position; /* Position courante dans la piste courante */
    } file;
    struct
    {
      struct device * dev;    /* Device */
      unsigned short flags;   /* Config */
#define CDFLG_EJECT 0x0001    /* On éjecte à la fermeture */
      unsigned char context[8]; /* Density code, taille d'un secteur 
                                   avant l'ouverture */
    } cd;
    struct
    {
      int count;              /* Nombre de fichiers audio */
      int current;            /* Numéro du fichier actuel */
      struct audio_entry * entry; /* liste des entrées */
      struct audio_stream * stream; /* Flux audio de la piste actuelle */
    } audio;
  } spec;
  struct index_position * index;
  int index_count;        /* Nombre d'index dans le support source */
};

/* Structure d'écriture DAO */
struct odao_stream
{
  unsigned short type;        /* Type du stream */
    #define TST_FILE 1          /* Fichier */
    #define TST_CD 2            /* CD */
  unsigned short blocksize;   /* Taille de bloc actuelle */
  struct _dao_flags flags;    /* Configs générales */
  union
  {
    struct
    {
      int handle;             /* Handle du fichier */
    } file;
    struct
    {
      unsigned short flags;   /* Config */
#define CDFLG_EJECT 0x0001    /* On éjecte à la fermeture */
      struct device * dev;    /* Device final de destination */
      unsigned char context[8]; /* Density code, taille d'un secteur 
                                   avant l'ouverture */
    } cd;
  } spec;
};

extern unsigned char toc_buf[ 110*16 ];

/* Prototypes */

struct idao_stream * idao_open_file( char * filename );
struct idao_stream * idao_open_cd( struct device_info * info );
struct idao_stream * idao_open_audio( struct audio_entry * entry, int entry_count );
struct odao_stream * odao_open_file( char * filename );
struct odao_stream * odao_open_cd( struct device_info * info );
int idao_close( struct idao_stream * stream );
int odao_close( struct odao_stream * stream );
int dao_pipe_read( struct idao_stream * in, long offset, long len,
                   unsigned char * read_buf, int audio );
int dao_pipe( const char * copy_msg, struct idao_stream * in, struct odao_stream * out );

#endif

