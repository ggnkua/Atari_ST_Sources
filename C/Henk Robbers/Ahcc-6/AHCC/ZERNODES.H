/* Copyright (c) 1990 - present by H. Robbers.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * zernodes.h
 *
 * The fastest way to get zeros in nodes
 */

#define XD sizeof(XNODE)

static
node_zero zerXnode
{
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
#if XD > 28
	zeroize(xp);
#if XD > 32
	zeroize(xp);
#if XD > 36
	zeroize(xp);
#if XD > 40
	zeroize(xp);
#if XD > 44
	zeroize(xp);
#if XD > 48
	zeroize(xp);
#if XD > 52
	zeroize(xp);
#if XD > 56
	zeroize(xp);
#if XD > 60
	zeroize(xp);
#if XD > 64
	zeroize(xp);
#if XD > 68
	zeroize(xp);
#if XD > 72
	zeroize(xp);
#if XD > 76
	zeroize(xp);
#if XD > 80
	zeroize(xp);
#if XD > 84
	zeroize(xp);
#if XD > 88
	zeroize(xp);
#if XD > 92
	zeroize(xp);
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
}

#define ND sizeof(NODE)

static
node_zero zerEnode
{
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
#if ND > 44
	zeroize(xp);
#if ND > 48
	zeroize(xp);
#if ND > 52
	zeroize(xp);
#if ND > 56
	zeroize(xp);
#if ND > 60
	zeroize(xp);
#if ND > 64
	zeroize(xp);
#if ND > 68
	zeroize(xp);
#if ND > 72
	zeroize(xp);
#if ND > 76
	zeroize(xp);
#if ND > 80
	zeroize(xp);
#if ND > 84
	zeroize(xp);
#if ND > 88
	zeroize(xp);
#if ND > 92
	zeroize(xp);
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
}

#define VD sizeof(VNODE)

static
node_zero zerVnode
{
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
#if VD > 20
	zeroize(xp);
#if VD > 24
	zeroize(xp);
#if VD > 28
	zeroize(xp);
#if VD > 32
	zeroize(xp);
#if VD > 36
	zeroize(xp);
#if VD > 40
	zeroize(xp);
#if VD > 44
	zeroize(xp);
#if VD > 48
	zeroize(xp);
#if VD > 52
	zeroize(xp);
#if VD > 56
	zeroize(xp);
#if VD > 60
	zeroize(xp);
#if VD > 64
	zeroize(xp);
#if VD > 68
	zeroize(xp);
#if VD > 72
	zeroize(xp);
#if VD > 76
	zeroize(xp);
#if VD > 80
	zeroize(xp);
#if VD > 84
	zeroize(xp);
#if VD > 88
	zeroize(xp);
#if VD > 92
	zeroize(xp);
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
}

#define TD sizeof(TNODE)

static
node_zero zerTnode
{
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
#if TD > 44
	zeroize(xp);
#if TD > 48
	zeroize(xp);
#if TD > 52
	zeroize(xp);
#if TD > 56
	zeroize(xp);
#if TD > 60
	zeroize(xp);
#if TD > 64
	zeroize(xp);
#if TD > 68
	zeroize(xp);
#if TD > 72
	zeroize(xp);
#if TD > 76
	zeroize(xp);
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
}

static
node_zero zerInode
{
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
#if sizeof(INODE) > 32
	zeroize(xp);
#if sizeof(INODE) > 36
	zeroize(xp);
#if sizeof(INODE) > 40
	zeroize(xp);
#if sizeof(INODE) > 44
	zeroize(xp);
#if sizeof(INODE) > 48
	zeroize(xp);
#if sizeof(INODE) > 52
	zeroize(xp);
#if sizeof(INODE) > 56
	zeroize(xp);
#if sizeof(INODE) > 60
	zeroize(xp);
#if sizeof(INODE) > 64
	zeroize(xp);
#if sizeof(INODE) > 68
	zeroize(xp);
#if sizeof(INODE) > 72
	zeroize(xp);
#if sizeof(INODE) > 76
	zeroize(xp);
#if sizeof(INODE) > 80
	zeroize(xp);
#if sizeof(INODE) > 84
	zeroize(xp);
#if sizeof(INODE) > 88
	zeroize(xp);
#if sizeof(INODE) > 92
	zeroize(xp);
#if sizeof(INODE) > 96
	zeroize(xp);
#if sizeof(INODE) > 100
	zeroize(xp);
#if sizeof(INODE) > 105
	zeroize(xp);
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
}

static
node_zero zerBnode
{
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
	zeroize(xp);
#if sizeof(BNODE) > 44
	zeroize(xp);
#if sizeof(BNODE) > 48
	zeroize(xp);
#if sizeof(BNODE) > 52
	zeroize(xp);
#if sizeof(BNODE) > 56
	zeroize(xp);
#if sizeof(BNODE) > 60
	zeroize(xp);
#if sizeof(BNODE) > 64
	zeroize(xp);
#if sizeof(BNODE) > 68
	zeroize(xp);
#if sizeof(BNODE) > 72
	zeroize(xp);
#if sizeof(BNODE) > 76
	zeroize(xp);
#if sizeof(BNODE) > 80
	zeroize(xp);
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
}
