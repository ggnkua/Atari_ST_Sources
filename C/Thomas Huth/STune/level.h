/**
 * STune - The battle for Aratis
 * level.h : Structures and defines that describe a level file.
 * Copyright (C) 2003 Matthias Alles, Thomas Huth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#ifndef STUNE_LEVEL_H
#define STUNE_LEVEL_H

#define LVLVERSION  0x0082

typedef struct
{
  unsigned char typ;
  unsigned char art;
  unsigned char xpos;
  unsigned char ypos;
  unsigned char ges;
  unsigned char dummy;
}LEVEL_EINTRAG;

/*
typ: 0 = building (see also the enumeration in "STUNEDEF.H")
     1 = unit (see also the enumaration in "STUNEDEF.H")
*/


/* header for the level files */

typedef struct
{
  long hmagic;             /* header magic, must be 'STUN' */
  short version;           /* for checking the version - e.g. 0x0123 is version 1.23 */
  short headlen;           /* length of the header */
  long id;                 /* Level-ID - To prevent cheating ;-) */
  short flags;             /* Unused at the moment */
  short lvltyp;            /* 0=Single-Player, 1=Multiplayer, 2=User-build */
  short techlevel;         /* The technology level */
  short r_wdth, r_hght;    /* with and height of the level */
  unsigned short geld[2];  /* money for the player and opponent */
  short ext1, ext2;        /* for future extensions */
  char einh[20];           /* buildable units (Nr=Art) */
  char gebs[16];           /* buildable buildings (Nr=Art) */
  short anz_obj;           /* number of objects (see above) */
} LEVEL_HEADER;

/* Level-header + Spielfeld  + n*Level-Eintr„ge = Leveldatei */

#endif /* STUNE_LEVEL_H */
