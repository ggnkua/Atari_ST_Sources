/**
 * STune - The battle for Aratis
 * th_musik.h : Header for th_musik.c.
 * Copyright (C) 2003 Thomas Huth
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

#ifndef _TH_MUSIK_H
#define _TH_MUSIK_H

#define S_ANGRIFF        0
#define S_EINH_BEREIT    1
#define S_LOW_ENERGY     2
#define S_EINSATZERFOLG  3
#define S_EINSATZ_FEHL   4
#define S_NO_FINANZ      5
#define S_KONSTR_OK      6
#define S_RADAR_AKTIV    7
#define S_RADAR_DEAKTIV  8
#define S_EINH_VERLOREN  9
#define S_MG            10
#define S_CLICK1        11
#define S_CLICK2        12
#define S_KAPUTT        13
#define S_GRANATE       14
#define S_MOEP          15
#define S_SCREAM        16

typedef struct
{
 char *name;
 short type;            /* 0=Immer im Speicher; 1=Muss erst nachgeladen werden */
 short playtype;        /* 0=Voicesample (->in Queue); sonst: GerÑuschsample, sofort spielen */
 void *start;           /* Anfangsadresse */
 void *end;             /* Endadresse */
 void *dosnd;           /* Alternativer DoSound */
 char *text;            /* Text fÅr das Infofenster */
} THSAMPLE;

extern THSAMPLE samples[];
extern short sndpsgflag;
extern short sndsamflag;
extern short sndvocflag;
extern short sndmodflag;
extern int ptyp;
extern short playflag;

int mod_init(void);
int mod_play(char *mname);
int mod_stop(void);
int initsamples(void);
void playsample(short snr);
void sam_abarbeiten(void);

#endif /* _TH_MUSIK_H */
