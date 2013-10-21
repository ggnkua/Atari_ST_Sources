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

#ifndef _XA_RSRC_H_
#define _XA_RSRC_H_

void *    LoadResources(XA_CLIENT *client, char *fname, RSHDR *rshdr, G_i designWidth, G_i designHeight);
void      FreeResources(XA_CLIENT *client, AESPB *pb);
OBJECT *  ResourceTree   (RSHDR *base, int num);
#if 0
char *    ResourceString (RSHDR *base, int num);
void *    ResourceImage  (RSHDR *base, int num);
OBJECT *  ResourceObject (RSHDR *base, int num);
TEDINFO * ResourceTedinfo(RSHDR *base, int num);
BITBLK *  ResourceBitblk (RSHDR *base, int num);
ICONBLK * ResourceIconblk(RSHDR *base, int num);
char **   ResourceFrstr  (RSHDR *base, int num);
void **   ResourceFrimg  (RSHDR *base, int num);
#endif
void      obfix(OBJECT *tree, int object);

#endif
