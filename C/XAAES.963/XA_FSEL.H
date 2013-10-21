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

#ifndef _XA_FSEL_H_
#define _XA_FSEL_H_

enum
{
	DP_NOTRUNC,
	DP_AUTOTRUNC,
	DP_DOSTRUNC,
	DP_SENITIVE   = 0,
	DP_NOSENSITIVE,
	DP_SAVE_ONLY,
	DP_TRUNC      = 5,
	DP_CASE
};

enum
{
	S_IFCHR = 0x2000,
	S_IFDIR = 0x4000,
	S_IFREG = 0x8000,
	S_IFIFO = 0xA000,
	S_IMEM  = 0xC000,
	S_IFLNK = 0xE000
};

typedef struct 
{
    G_u mode;
    long index;
    G_i dev,
        reserved1,
        nlink,
        uid,
        gid;
    long size,
         blksize,
         nblocks;
    G_i mtime,
        mdate,
        atime,
        adate,
        ctime,
        cdate;
    G_u attr;
    G_i reserved2;
    long reserved3;
    long reserved4;
} XATTR;

#define slash '/'
#define sslash "/"
#define bslash '\\'
#define sbslash "\\"

#define DRV_MAX ('z'-('a'-1) + '9'-('0'-1))

/* HR 060202: char *file */
void open_fileselector(LOCK lock, XA_CLIENT *client, char *path, char *file, char *title, fsel_handler *s, fsel_handler *c);
void init_fsel(void);
void close_fileselector(LOCK lock);		/* HR 121102 */
#endif
