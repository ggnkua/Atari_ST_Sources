/*
 * Utility functions for Teradesk. Copyright 1993, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <tos.h>
#include <system.h>
#include <stddef.h>
#include <boolean.h>

int get_tosversion( void )
{
	void *stack;
	int version;

	stack = (void *)Super(NULL);
	version = _sysbase->os_version;
	Super(stack);
	return version;
}

boolean tos1_4( void )
{
	return (get_tosversion() >= 0x104) ? TRUE : FALSE;
}

boolean tos2_0( void )
{
	return (get_tosversion() >= 0x200) ? TRUE : FALSE;
}
