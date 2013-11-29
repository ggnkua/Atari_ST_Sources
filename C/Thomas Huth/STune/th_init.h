/**
 * STune - The battle for Aratis
 * th_init.h : Header file for th_init.c.
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

#ifndef _TH_INIT_H
#define _TH_INIT_H

int xgetcookie(unsigned long cookie, unsigned long *value);
int appl_xgetinfo(int type, int *o1, int *o2, int *o3, int *o4);
int initGEM(void);
void exitGEM(void);
int open_window(void);
void close_window(void);
long initgraf(void);
int load_rsc(char *lang);

#endif
