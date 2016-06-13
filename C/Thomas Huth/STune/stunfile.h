/**
 * STune - The battle for Aratis
 * stunfile.h : Header file for stunfile.c.
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

int fileselect(char *pathnname, char *mask, char *boxtitle);
int loadlevel(char *fname, int type);
int saveoptions(void);
int loadoptions(void);
int loadhighscore(void);
int savehighscore(void);
int loadinfofile(char *fname);
int loadgame(void);
int savegame(void);

extern HIGH_SCORE hs[10];
extern OBJECT *highdlg;