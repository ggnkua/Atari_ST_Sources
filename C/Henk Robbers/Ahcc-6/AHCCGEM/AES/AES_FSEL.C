/* This file is part of the AHCC GEM Library.

   The AHCC GEM Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC GEM Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.

   Copyright (c) 2008 by Henk Robbers @ Amsterdam.
*/

#include "aespb.h"

short G_decl fsel_input(char *path,char *sel,short *button)
{
	short io[2];
	void *ai[3];
	SETACTL(90,0,2,2,0);

	ai[0]=path;
	ai[1]=sel;
	G_trap(c,pglob,0L,io,ai,0L);
	if (button) *button=io[1];
	return io[0];
}

short G_decl fsel_exinput(char *path,char *sel,short *button,char *label)
{
	short io[2];
	void *ai[3];
	SETACTL(91,0,2,3,0);

	ai[0]=path;
	ai[1]=sel;
	ai[2]=label;
	G_trap(c,pglob,0L,io,ai,0L);
	if (button) *button=io[1];
	return io[0];
}

#if SMURF
/*
 * Ein alternatives Binding fr fsel_exinput() (Die Funktionsnummer ist
 * identisch!), das die bergabe der Callback-Adresse erlaubt. Andere
 * Fileselectoren sollten den berzhligen Parameter einfach ignorieren.
 */
short G_decl fsel_boxinput(char *path, char *sel, short *button, char *label, void *callback)
{
	short io[2];
	void *ai[4];
	SETACTL(91,0,2,4,0);

	ai[0]=path;
	ai[1]=sel;
	ai[2]=label;
	ai[3]=callback;
	G_trap(c,pglob,0L,io,ai,0L);
	if (button) *button=io[1];
	return io[0];
}
#endif
