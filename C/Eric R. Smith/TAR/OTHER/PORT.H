/*

	Copyright (C) 1988 Free Software Foundation

GNU tar is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY.  No author or distributor accepts responsibility to anyone
for the consequences of using it or for whether it serves any
particular purpose or works at all, unless he says so in writing.
Refer to the GNU tar General Public License for full details.

Everyone is granted permission to copy, modify and redistribute GNU tar,
but only under the conditions described in the GNU tar General Public
License.  A copy of this license is supposed to have been given to you
along with GNU tar so you can know your rights and responsibilities.  It
should be in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.

In other words, go ahead and share GNU tar, but don't try to stop
anyone else from sharing it farther.  Help stamp out software hoarding!
*/
/*
 * Portability declarations for tar.
 *
 * @(#)port.h 1.3	87/11/11	by John Gilmore, 1986
 */

/*
 * Everybody does wait() differently.  There seem to be no definitions
 * for this in V7 (e.g. you are supposed to shift and mask things out
 * using constant shifts and masks.)  So fuck 'em all -- my own non
 * standard but portable macros.  Don't change to a "union wait"
 * based approach -- the ordering of the elements of the struct 
 * depends on the byte-sex of the machine.  Foo!
 */
#define	TERM_SIGNAL(status)	((status) & 0x7F)
#define TERM_COREDUMP(status)	(((status) & 0x80) != 0)
#define TERM_VALUE(status)	((status) >> 8)

#ifdef	MSDOS
/* missing things from sys/stat.h */
#ifndef atarist
#define	S_ISUID		0
#define	S_ISGID		0
#endif
#define	S_ISVTX		0

/* device stuff */
#define	makedev(ma, mi)		((ma << 8) | mi)
#define	major(dev)		(dev)
#define	minor(dev)		(dev)
#endif	/* MSDOS */

#ifdef atarist
#define MAXNAMLEN 64
#endif
