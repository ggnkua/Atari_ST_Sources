/**
 * STune - The battle for Aratis
 * me_gemft.h : Header file for me_gemft.c
 * Copyright (C) 2003 Matthias Alles
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

void normalize_popups(unsigned short);
void popup_kaserne(void);
void popup_fabrik_kl(void);
void popup_fabrik_gr(void);
void popup_bauanlage(void);
void set_mouse(unsigned short, unsigned short);
void set_enable(void);
void techlev2popups(int tlvl);
void changemouseform(int newform);

extern OBJECT *gebpopobj;
extern OBJECT *kaspopobj;
extern OBJECT *klfpopobj;
extern OBJECT *grfpopobj;
