/**
 * STune - The battle for Aratis
 * stunedef.h : Core definitions
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

#ifndef STUNEDEF_H
#define STUNEDEF_H

/* Fensterelemente: */
#define WINDOWGADGETS (VSLIDE|HSLIDE|UPARROW|DNARROW|LFARROW|RTARROW|FULLER|SIZER|CLOSER|MOVER|NAME)
#define MWIGADGETS (CLOSER|MOVER|NAME)
/* Pixelhîhe der Informationszeile: */
#define INFHEIGHT 71

/* Spielfeldstruktur: */
typedef struct
{
 unsigned bitdummy:10;
 unsigned begehbar:1;
 unsigned erforscht:1;              /* 1=schon erforscht; 0=unerforscht */
 unsigned befahrbar:1;              /* 1=Befahrbares Feld; 0=unbefahrbar */
 unsigned besetzt:1;                /* 1=besetzt(siehe folg. Bits); 0=freies Feld */
 unsigned besetzertyp:1;            /* 1=Einheit; 0=GebÑude */
 unsigned gesinnung:1;              /* 1=Gegner; 0=Spieler */
 unsigned char ertrag;                 /* Menge des zu Erntenden */
 unsigned char feldtyp;             /* Bodentyp */
 unsigned char nr;                  /* Nr der Einheit/des GebÑudes auf dem Feld */
 unsigned char dummy;
} SPIELFELD;

/* Spielfiguren: */
typedef struct
{
 unsigned short xpos, ypos;          /* Position */
 unsigned short altxpos,altypos;
 unsigned short neuxpos,neuypos;
 unsigned short xpospatr,ypospatr;    /* xpospatr bei geschossen: von wem initialisiert (G/E) */
 unsigned short xkoor,ykoor;          /* Koordinaten in Pixel */
 unsigned short altesx, altesy;       /* Vorherige Koordinaten in Pixel */
 unsigned short status;
 unsigned short art;                 /* Typ der Einheit */
 signed int zustand;                 /* Zustand bei Einheit - Feuerkraft des Geschosses */
 unsigned short xziel, yziel;         /* Angiffs-/Bewegungsziel */
 signed short schrittx,schritty;
 signed short nochschrx,nochschry;
 unsigned short zielobj;
 unsigned short wie_weit;            /* fÅr's Aufladen, Sammeln, ... */
 unsigned short ausrichtung;
 unsigned short ausrziel;
 unsigned short zielart;
 unsigned short gesinnung;
 unsigned short ID;
 unsigned short verbund;
} EINHEIT;

/* GebÑude: */
typedef struct
{
 unsigned short xpos, ypos;          /* Position */
 unsigned short art;                 /* Typ des GebÑudes */
 signed int zustand;
 unsigned short status;              /* Bauen, Angriff, Reparieren,... */
 unsigned short zielnr;              /* fÅr GeschÅtztÅrme ... */
 signed short energie;               /* Verbrauch < 0 , Produktion >0 */
 unsigned short wie_weit;
 unsigned short bauprodukt;
 unsigned short gesinnung;           /* 1=Gegner, 0=Spieler  */
 unsigned short befahrbar;           /* Raffinerie, Werkstatt, ... */
 unsigned short ID;                  /* Idendifikation(das wievielte/mit welchem soll gebaut werden) */
} GEBAEUDE;

/* Status fuer Einheiten */
#define WACHEN      1
#define ANGR        2
#define BEWEG       4
#define AUSRICHTUNG 8
#define SAMMELN     16
#define REPERATUR   32
#define NOCHM_BERE  64
#define BEWEG_ABGE  128
#define LOESCHEN    256
#define NOCH_ANGR   512   /* fÅr geschosse, wenn ziel bereits zerstîrt */
#define ZIEL_IN_BEW 1024
#define STOP        2048  /* fÅr Sammler, bei zerstîrter Raff. */
#define IN_WERKST   4096
#define UEBERROLLEN 8192
#define K_FREIGABE_N 16384  /* fÅr Einheiten, die dem öberrollen gerade so entkommen */
#define K_FREIGABE_A 32768U
#define PATROLIE     2048  /* Doppelbelegung, da Sammler nicht auf Patr. gehen kann */


/* Status fÅr GebÑude */
#define REPE         1
#define ANGRIFF      2
#define WACHE        4
#define BAUEN        8
#define PAUSE       16

typedef struct
{
 unsigned short kosten;
 unsigned short zustandspunkte;
 signed short energiebedarf;
 unsigned short befahrbar;
 unsigned short begehbar;
 unsigned short groesse;
 unsigned short prioritaet;
 unsigned short rweite;
}GEB_D;

#define GEB_ANZAHL  13      /* Anzahl der verschiedenen GebÑude */

#define BAUANLAGE   0
#define KRAFTWERK   1
#define RAFFINERIE  2
#define RADAR       3
#define KASERNE     4
#define FABRIK_KL   5
#define MG_TURM     6
#define WERKSTATT   7
#define RK_TURM     8
#define FABRIK_GR   9
#define SANDSACK   10
#define MAUER      11
#define INFRATURM  12       /* Turm, der Infraschall produziert (7Hz)
                              ( sorgt dafÅr, dass sich Innereien kaputt reiben)*/

typedef struct
{
 unsigned short zustandspunkte;
 unsigned short geschwindigkeit;
 unsigned short ausrgeschw;
 unsigned short schiessgeschw;
 unsigned short kosten;
 unsigned short feuerkraft;
 unsigned short reichweite;
 unsigned short befahrbar;
}EIN_D;

#define TRUPPE        0
#define TRUPPEN       1
#define QUAD          2
#define BEKEHRER      3
#define BAZOOKA       4
#define GRENADIER     5
#define FLAMMENWERFER 6
#define TRIKE         7
#define PANZER_L      10
#define RAKETENWERFER 11
#define PANZER_S      12
#define SAMMLER       13
#define LASERFAHRZEUG 14
#define INFRATANK     15
#define FLAMMENTANK   16
#define GRANATE       20
#define RAKETE        21
#define LASER         22
#define SCHALL        23
#define FLAMME        24

typedef struct
{
 signed short x;
 signed short y;
} AUS;

typedef struct
{
  unsigned short art;
  unsigned short xpos;
  unsigned short ypos;
} COMP_GEB;


typedef struct
{
  unsigned short kas[7];
  unsigned short klf[6];
  unsigned short grf[6];
  unsigned short bau[15];
} TECHNOLOGIE;


typedef struct
{
  unsigned short art;
  unsigned short xkoor;
  unsigned short ykoor;
  unsigned short wie_weit;
} ANIM;


typedef struct
{
  unsigned short art;
  unsigned short aktion;
  unsigned long timer_nr;
  unsigned short nr;
  unsigned short xpos,ypos;
  unsigned short flag;
  unsigned short objekt;
/* char text[16];*/                 /* 30 Bytes */
}TRANSMIT;

typedef struct
{
  short type; /* 0=Daten, 1=Okay, 2=Abbruch */
  char playername[12];
  short einh;
  short techlvl;
  short credits;
  short stpkte;
  char lvl[14];
}NET_INIT;

typedef struct
{
  char name[12];
  short level;
  unsigned short punkte;
} HIGH_SCORE;


#ifndef FALSE
#define FALSE 0
#define TRUE  1
#endif

#ifndef NULL
#define NULL ((void *)0)
#endif

#endif /* STUNEDEF_H */
