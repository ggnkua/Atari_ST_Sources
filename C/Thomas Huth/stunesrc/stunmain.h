/**
 * STune - The battle for Aratis
 * stunmain.h : Header file for stunmain.c
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

#ifndef _STUNEMAIN_H
#define _STUNEMAIN_H

#include "stunedef.h"
#include "stunegem.h"

void timer_fun(void);
void debug_on_key(void);

extern int ap_id;
extern int vhndl;
extern int deskx, desky, deskw, deskh;
extern int scrwidth, scrheight;
extern int wihndl;
extern int mwihndl;
extern GRECT wi;
extern GRECT mwi;
extern int mausx, mausy, mausk, klicks;
extern int kstate, key;
extern int msgbuf[8];
extern int winfokus;
extern short rwx, rwy;
extern short rww, rwh, r_width, r_height;
extern int statusypos;
extern char stunepath[];
extern char levelpath[];
extern char levelname[];
extern char levelinfo[];
extern char savename[];
extern char *lvldescription;
extern char *langstr;
extern int endeflag;
extern int exitflag;
extern int radarflag;
extern int netflag;
extern int in_game_flag;
extern int gamespeed;
extern int geb_gebaut;
extern int level_done;
extern short ak_nr,ak_art;
extern unsigned short ak_einh[10];
extern unsigned short groups[5][10];
extern unsigned int knete[2];
extern char moneystr[];
extern SPIELFELD sfeld[128][128];
extern EINHEIT einheiten[256];
extern GEBAEUDE geb[100];
extern GEB_D gebaeude_typ[];
extern EIN_D einheit_typ[];
extern AUS ausrzahl[8];
extern unsigned short llgeb,lleinh;
extern signed int energie;
/* extern unsigned int saft; */
extern COMP_GEB geblist[15];
extern unsigned long timer_counter;
extern short techlevelnr;
extern short level;
extern short spielart;
extern int nethandle;
extern TRANSMIT trans;
extern char p1name[], p2name[];
extern char net_msg[40];
extern short startzeit;

#endif /* _STUNMAIN_H */
