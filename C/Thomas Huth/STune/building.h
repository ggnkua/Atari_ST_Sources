/**
 * STune - The battle for Aratis
 * building.h : Header file for building.c
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

void gebaeude_definieren(void);
void setgebaeude(unsigned short gart, short gxp, short gyp, short ggesng);
void neu_zeichnen(unsigned short);
void gebaeude_infiltriert(unsigned short);
void gebaeude_entfernen(unsigned short);
void gebaeude_angriff(unsigned short, signed int, signed int);
unsigned short in_reichweite_geb(unsigned short, unsigned short);
void center_bauanlage(short redraw);
