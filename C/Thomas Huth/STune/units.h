/**
 * STune - The battle for Aratis
 * units.h : Header file for units.c.
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

void einheiten_definieren(void);
void ausrzahl_definieren(void);
void set_einheit(unsigned short, unsigned short, unsigned short, unsigned short, short);
void saft_suchen(unsigned short);
void sammler_inhalt(unsigned short);
void einheiten_selektieren(int,int,int,int);
void einheit_selektiert(unsigned short);


extern TECHNOLOGIE tech_level[10];
