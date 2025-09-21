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
 * Look up user and/or group names.
 *
 * This file should be modified for non-unix systems to do something
 * reasonable.
 *
 * @(#)names.c 1.3 10/30/87 - gnu
 */ 
#ifdef atarist
#include <types.h>
#else
#include <sys/types.h>
#endif

#include "tar.h"

extern	char	*strncpy();

#ifndef NONAMES
/* Whole module goes away if NONAMES defined.  Otherwise... */
#include <pwd.h>
#include <grp.h>

static int	saveuid = -993;
static char	saveuname[TUNMLEN];
static int	my_uid = -993;

static int	savegid = -993;
static char	savegname[TGNMLEN];
static int	my_gid = -993;

#define myuid	( my_uid < 0? (my_uid = getuid()): my_uid )
#define	mygid	( my_gid < 0? (my_gid = getgid()): my_gid )

/*
 * Look up a user or group name from a uid/gid, maintaining a cache.
 * FIXME, for now it's a one-entry cache.
 * FIXME2, the "-993" is to reduce the chance of a hit on the first lookup.
 *
 * This is ifdef'd because on Suns, it drags in about 38K of "yellow
 * pages" code, roughly doubling the program size.  Thanks guys.
 */
void
finduname(uname, uid)
	char	uname[TUNMLEN];
	int	uid;
{
	struct passwd	*pw;
	extern struct passwd *getpwuid ();

	if (uid != saveuid) {
		saveuid = uid;
		saveuname[0] = '\0';
		pw = getpwuid(uid); 
		if (pw) 
			strncpy(saveuname, pw->pw_name, TUNMLEN);
	}
	strncpy(uname, saveuname, TUNMLEN);
}

int
finduid(uname)
	char	uname[TUNMLEN];
{
	struct passwd	*pw;
	extern struct passwd *getpwnam();

	if (uname[0] != saveuname[0]	/* Quick test w/o proc call */
	    || 0!=strncmp(uname, saveuname, TUNMLEN)) {
		strncpy(saveuname, uname, TUNMLEN);
		pw = getpwnam(uname); 
		if (pw) {
			saveuid = pw->pw_uid;
		} else {
			saveuid = myuid;
		}
	}
	return saveuid;
}


void
findgname(gname, gid)
	char	gname[TGNMLEN];
	int	gid;
{
	struct group	*gr;
	extern struct group *getgrgid ();

	if (gid != savegid) {
		savegid = gid;
		savegname[0] = '\0';
		(void)setgrent();
		gr = getgrgid(gid); 
		if (gr) 
			strncpy(savegname, gr->gr_name, TGNMLEN);
	}
	(void) strncpy(gname, savegname, TGNMLEN);
}


int
findgid(gname)
	char	gname[TUNMLEN];
{
	struct group	*gr;
	extern struct group *getgrnam();

	if (gname[0] != savegname[0]	/* Quick test w/o proc call */
	    || 0!=strncmp(gname, savegname, TUNMLEN)) {
		strncpy(savegname, gname, TUNMLEN);
		gr = getgrnam(gname); 
		if (gr) {
			savegid = gr->gr_gid;
		} else {
			savegid = mygid;
		}
	}
	return savegid;
}
#endif
