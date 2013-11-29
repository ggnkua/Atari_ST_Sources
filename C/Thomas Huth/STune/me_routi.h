/**
 * STune - The battle for Aratis
 * me_routi.h : Header file for me_routi.c
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

extern unsigned short einh_verl[2];
extern unsigned short geb_verl[2];
extern unsigned long saft_ges[2];
extern int saft;

unsigned short id_suchen(unsigned short,unsigned short,unsigned short);
unsigned short einheit_initialisieren(unsigned short,unsigned short,unsigned short);
unsigned short nummer_ermitteln(unsigned short, unsigned short, unsigned short);
void abarbeiten(void);
void geklickt(unsigned short, unsigned short, unsigned int, unsigned int);
void bewegung(unsigned short, unsigned short, unsigned short, short);
void angriff(unsigned short, unsigned short, unsigned short, short);
void angriffe_abschalten(unsigned short,unsigned short);
unsigned short id_suchen_einh(unsigned short,unsigned short,unsigned short);
void einheit_entfernen(unsigned short);
unsigned short nummer_ermitteln2(unsigned short, unsigned short);
void neu_zeichnen(unsigned short);
void y_switchen(signed short ,unsigned short);
void y_berechnen(unsigned short);
void abarbeiten(void);
signed short getmax(signed short, signed short);
void ausrichten(unsigned short,unsigned short);
unsigned short in_reichweite(unsigned short, unsigned short, unsigned short);
void neu_suchen(unsigned short, unsigned short);
void ausrichten_fuer_schiessen(unsigned short,unsigned short);
void schiessen(unsigned short);
int platz_testen(unsigned short, unsigned short, unsigned short, unsigned short);
void patr_wachen(unsigned short);
unsigned short setze_freigaben(unsigned short);
void feld_reservieren(unsigned short);
void rueckkehr(unsigned short);
void flugbahn_berechnen(unsigned short);
void zur_reperatur(unsigned short, unsigned short);

