/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
	Falcon XBIOS bindings
*/

#ifndef _F_XBIOS_H_
#define _F_XBIOS_H_

#ifndef VgetMonitor
short VgetMonitor(void);
#pragma inline d0=VgetMonitor() {"3F3C00594E4E4FEF0002";}
#endif

/* Craig's special VsetScreen() binding */
#ifndef CGVsetScreen
short CGVsetScreen(short);
#pragma inline d0=CGVsetScreen(d0) {"3F003F3C00033F3CFFFF3F3CFFFF3F3C00054E4E4FEF000E";}
#endif

#endif

