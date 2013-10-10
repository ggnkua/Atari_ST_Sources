/**
 * STune - The battle for Aratis
 * th_graf.h : Header file for th_graf.c
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

extern int newpal[256][3];
extern MFDB scrnmfdb;
extern MFDB offscr;
extern MFDB bodenfdb;
extern MFDB einhfdb, einhmask;
extern MFDB panelfdb;
extern MFDB infogfxfdb;
extern char energiegfx[];
extern MFDB energiefdb;
extern int bipp;

extern char *gebname[];
extern char *einhname[];
extern int deskclip[4];
extern int windowsareopen;
extern int screen_opened;


void briefing(char *titel, char *btext);

void setpal(int palette[][3]);

void neuemeldung(char *text);
void meldungenabarbeiten(void);

void drawmap(short mox, short moy, short mow, short moh);
void drwmwind(GRECT *xywh);
void aktualize_status(int gbnr);
void aktualize_energie(void);
void rdr_map(int x, int y, int w, int h);
void rdr_infobar(void);
void rdr_health(void);
void infos_neu_zeichnen(int old_art, int old_nr);

void drawoffscr(short ox, short oy, short ow, short oh);
void drawscreen(int x, int y, int w, int h);
void drwindow(GRECT *xywh);
void drawsprites(void);

void togglefullscreen(int adjustwindows);
void adjust_fs_windows(void);
