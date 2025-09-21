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
 * Plug-compatible replacement for getopt() for parsing tar-like
 * arguments.  If the first argument begins with "-", it uses getopt;
 * otherwise, it uses the old rules used by tar, dump, and ps.
 *
 * Written 25 August 1985 by John Gilmore (ihnp4!hoptoad!gnu)
 *
 * @(#)getoldopt.c 1.4 2/4/86 - gnu
 */

#include <stdio.h>


int
getoldopt(argc, argv, optstring)
	int	argc;
	char	**argv;
	char	*optstring;
{
	extern char	*optarg;	/* Points to next arg */
	extern int	optind;		/* Global argv index */
	static char	*key;		/* Points to next keyletter */
	static char	use_getopt;	/* !=0 if argv[1][0] was '-' */
	extern char	*index();
	char		c;
	char		*place;

	optarg = NULL;
	
	if (key == NULL) {		/* First time */
		if (argc < 2) return EOF;
		key = argv[1];
		if (*key == '-')
			use_getopt++;
		else
			optind = 2;
	}

	if (use_getopt)
		return getopt(argc, argv, optstring);

	c = *key++;
	if (c == '\0') {
		key--;
		return EOF;
	}
	place = index(optstring, c);

	if (place == NULL || c == ':') {
		msg("unknown option %c", c);
		return('?');
	}

	place++;
	if (*place == ':') {
		if (optind < argc) {
			optarg = argv[optind];
			optind++;
		} else {
			msg("%c argument missing", c);
			return('?');
		}
	}

	return(c);
}
