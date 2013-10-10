/**
 * STune - The battle for Aratis
 * th_aesev.h : Header file for th_aesev.c.
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

void fm_error(char *msgtxt);
void setup_lang(void (*msghndlr)(int msg[]), long msec, void (*tmrhndlr)(void));
void setup_sound(void (*msghndlr)(int msg[]), long msec, void (*tmrhndlr)(void));
void setup_speed(void (*msghndlr)(int msg[]), long msec, void (*tmrhndlr)(void));
void setupdialog(void (*msghndlr)(int msg[]), long msec, void (*tmrhndlr)(void));
void reactmenu(void);
void setslidnmarker(short sldrflg, short oldx, short oldy);
void mesages(void);
void keyklicks(void);
void wdmsgs(int msgbf[]);
void enablemenu(short lflag);

extern OBJECT *menu;
extern OBJECT *speeddlg;
extern OBJECT *initdlg;
extern OBJECT *sounddlg;
extern OBJECT *langdlg;
extern OBJECT *strtdlg;
extern OBJECT *setupdlg;
extern OBJECT *netdia;
extern OBJECT *netinit;
extern OBJECT *netend;
extern OBJECT *netmsg;

extern char scrlsprflag;
extern char gclipflag;
extern char fullscrflag;
