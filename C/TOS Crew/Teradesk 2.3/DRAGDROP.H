/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *                                     2003 H. Robbers
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

#ifndef DRAGDROP_H

int
ddcreate(
	int dpid, int spid, int winid, int msx, int msy, int kstate, char exts[] );

int
ddstry(int fd, char *ext, char *name, long size);

void
ddclose(int fd);

#endif