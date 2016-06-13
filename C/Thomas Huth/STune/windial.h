/**
 * STune - The battle for Aratis
 * windial.h : Header for windial.c.
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


/* Prototypen: */
int wdial_init(OBJECT *tree, char *title, short drawnow);
void wdial_close(int dwhndl, OBJECT *tree);
void wdial_redraw(int dwhndl, OBJECT *tree, GRECT *redrwrect);
short wdial_formdo(int dwhndl, OBJECT *tree, short strt_fld, void (*msghndl)(int msgbf[]), long msec, void (*tmrhndlr)());
int wdial_popup(OBJECT *ptree, short *pitem, short popupx, short popupy, void (*msghndlr)(int msgbf[]), long msec, void (*tmrhndlr)());
#ifdef __TURBOC__
int rc_intersect(GRECT *r1, GRECT *r2);
#endif

extern GRECT fsdlgclip[4];
extern short modaldlgflag;
