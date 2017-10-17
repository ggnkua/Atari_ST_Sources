/*
 * PREFS.H - Gestion des préférences
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

#ifndef __PREFS_H__
#define __PREFS_H__

struct pref_str
{
  /* Numéro de version du fichier */
  unsigned int version;
  /* Nombre de paramètres de devices enregistrés */
  unsigned int dev_sets;
  /* Offset vers le premier devset */
  unsigned int dev_set_offset;

  /* Infos d'enregistrement */
  struct _register
  {
    int ok;
    char name[ 24 ];
    char key[ 16 ];
  } reg;

  /* Préférences */
  struct _pref_flags
  {
    unsigned int bubble     : 2;
    unsigned int multitask  : 1;
    unsigned int ignore_err : 1;
    unsigned int log        : 1;
    unsigned int flushlog   : 1;
    unsigned int eject_src  : 1;
    unsigned int eject_dst  : 1;
    unsigned int zob        : 56;
  } pref_flags;
  int bubble_delay;    /* en 1/100 s */

  int retry_count;
  char log_file[256];
  int scsi_timeout;    /* en 1/200 s */

  /* Copie de CD */
  int write_speed;
  int source_id;
  int source_bus;
  int dest_id;
  int dest_bus;
  char source_file[256];
  char dest_file[256];
  char int_file[256];

  struct _copy_flags
  {
    unsigned int simul      : 1;
    unsigned int write_cd   : 1;
    unsigned int use_hd     : 1;
    unsigned int int_del    : 1;
    unsigned int zob        : 12;
  } copy_flags;

  /* Effacement de CD-RW */
  int erase_id;
  int erase_bus;
  int erase_method;

  /* Fenêtre d'info des devices */
  int dev_rd_id;
  int dev_rd_bus;
  int dev_wr_id;
  int dev_wr_bus;

  /* Lecture de TOC */
  char toc_file[256];
  char toc_dest[256];
  int dev_toc_id;
  int dev_toc_bus;
  int audio_format;

  /* Copie en TAO */
  int tao_write_speed;
  int tao_id;
  int tao_bus;
  char tao_src_file[256];
  char tao_dest_file[256];
  struct _tao_flags
  {
    unsigned int simul      : 1;
    unsigned int write_cd   : 1;
    unsigned int use_hd     : 1;
    unsigned int int_del    : 1;
    unsigned int zob        : 12;
  } tao_flags;

};

extern struct pref_str preferences;

void pref_load( void );
void pref_save( void );

void pref_open( void );

#endif

