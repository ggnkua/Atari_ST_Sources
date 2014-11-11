/*
 * DEVICE.H - Gestion de l'objet Device
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

#ifndef __DEVICE_H__
#define __DEVICE_H__

#include <io.h>

struct device_id
{
  char vend_id[ 8 + 1 ];
  char prod_id[ 16 + 1 ];
  char revision_level[ 4 + 1 ];
  char revision_date[ 8 + 1 ];
};

struct device_settings
{
  struct device_id dev_id;

  unsigned short flags;       /* Flags en tout genre */
#define DSF_AUD_LITTLE_ENDIAN 0x0001    /* Mode little-endian en lecture audio */
#define DSF_IS_WRITER         0x0002    /* C'est un graveur */
#define DSF_SUP_SAO_WR        0x0004    /* Le graveur supporte le mode SAO (MMC) */
#define DSF_SUP_RAW_WR        0x0008    /* Le graveur supporte le mode RAW (MMC) */
#define DSF_WRITE_CDRW        0x0010    /* Le graveur est un CD-RW */
#define DSF_READ_CDRW         0x0020    /* Le lecteur lit les CD-RW */
#define DSF_USE_MS10          0x0040    /* Le lecteur ne supporte pas le Mode Select 6 */
#define DSF_SUP_DAO_WR        0x0080    /* Le graveur supporte le DAO */
#define DSF_IS_MMC            0x0100    /* Le lecteur est un MMC */
#define DSF_PREF_RAW          0x8000    /* Utiliser le mode RAW de préférence au SAO */

  int write_mode;             /* mode en écriture */
#define WT_AUTODETECT -1 /* Type de graveur à déterminer */
#define WT_NONE 0      /* L'appreil n'est pas un graveur */
#define WT_PHILIPS 1   /* Graveur compatible Philips */
#define WT_TEAC 2      /* Graveur compatible TEAC */
#define WT_MMC 3       /* Graveur compatible MMC SCSI-3 avec mode TAO uniquement */

  int audio_mode;             /* Mode pour le dump audio */
#define AM_AUTODETECT -1 /* Lecture audio à déterminer */
#define AM_NONE 0      /* Lecture audio non supportée */
#define AM_CDROM 1     /* Lecture en mode CD-Rom classique */
#define AM_TOSHIBA 2   /* Lecture en mode Toshiba */
#define AM_TEAC 3      /* Lecture avec la commande TEAC READ-CDDA */
#define AM_MMC 4       /* Lecture avec la commande MMC READ-CD */

  unsigned int max_read_speed;  /* Vitesse de lecture maxi */
  unsigned int max_write_speed; /* Vitesse de gravage maxi (si c'est un graveur) */
};

struct device
{
  short * Handle;           /* handle scsi lib */
  short Lun;                /* unité logique (généralement 0) */
  unsigned long DmaLen;     /* Longueur maxi de lecture */
  unsigned short type;      /* Type de device */

  struct device_settings * sets; /* Paramètres du device */

  unsigned int status;      /* Mode de travail de l'appareil */
#define ST_AUDIO 1          /* Mode lecture audio */
 
  unsigned char write_speed;   /* Vitesse d'écriture actuelle */
  unsigned char dummy_write;   /* Mode simulation de gravage */

  unsigned char density;   /* Code de densité actuel */
  unsigned long BlockSize; /* Taille actuelle d'un secteur */

  /*unsigned char context[8]; /* Density code, taille d'un secteur 
                              avant l'ouverture */
};

struct device_info
{
  char desc[80];                /* Description du device */
  int id;                       /* ID du périphérique */
  unsigned short bus_no;        /* Bus correspondant */
  struct device_settings * sets;  /* Paramètres de l'unité */
  struct device_info * next;    /* Pointeur vers le device suivant */
};

#define MAX_DEV_SETS 16   /* Nombre maxi de paramètres de devices enregistrés */
extern int dev_sets;      /* Nombre de paramètres de devices enregistrés */
extern struct device_settings dev_set[ MAX_DEV_SETS ];

extern struct device * current_device;
extern struct device_info * first_dev;

struct device * open_device( int id, unsigned short bus_no );
int close_device( struct device * dev );
void use_device( struct device * dev );
int first_device( struct device_info * info );
int next_device( struct device_info * info );
struct device_info * get_device_list( int verbose );
void free_device_list( struct device_info * first );

#endif
