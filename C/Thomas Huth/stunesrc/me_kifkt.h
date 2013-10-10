/**
 * STune - The battle for Aratis
 * me_kifkt.h : Header file for me_kifkt.c
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

void initialize_computer(void);
void gebaeude_wieder_aufbauen(unsigned short);
void einheit_in_verbund(unsigned short);
short int rnd(unsigned short int);
void einheit_wird_angegriffen(unsigned short, unsigned short);
void verbund_aufbrechen(unsigned short);
void abarbeiten_computer(void);


typedef struct
{
  unsigned short xpl;
  unsigned short ypl;
}BASIS_PLATZ;

typedef struct
{
  unsigned short xpl[3];
  unsigned short ypl[3];
  unsigned int erfolg;
}STRATEGIE;

typedef struct
{
  unsigned short nr[9];
  unsigned short status;
  unsigned int flags;     /* jede Einheit bekommt ein Flag, ob sie die Aktion beendet hat */
  unsigned short strategie;
  short target_destroyed;
  short anz_in_verb;
}VERBUND;

#define AUFBAU    1
#define ATTACK    2
#define MOVING    4
#define WAITING   8
#define FIGHTING 16

extern VERBUND compeinh[8];
extern STRATEGIE strat[3];
extern BASIS_PLATZ comp_basis, mensch_basis;
extern unsigned short anzahl_verbund;
extern unsigned int comp_bauspeed;
extern unsigned int phase;


#define DEFENSE1   1
#define DEFENSE2   2
#define BATTLE     3

