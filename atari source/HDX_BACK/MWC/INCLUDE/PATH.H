/*
 * path.h -- information for path lookup
 *
 * Copyright (c) 1987, Mark Williams Company, Chicago.
 * This file and its contents may not be copied or distributed
 * without permission.
 *
 * Violators will be towed at own expense.
 */

/*
 * path() takes a path search list, a file name, and an access mode,
 * and then searches each directory named in the search list
 * for a file with the given name and access mode.
 * The constructed path name, which is kept in a static buffer,
 * is returned on success.  path() returns NULL if either pointer
 * argument is NULL, or if the search failed.
 */

#include <access.h>
#if COHERENT
#define PATHSEP		'/'			/* Path name separator */
#define	PATHSEPSTRING	"/"
#define LISTSEP		':'			/* Search list separator */
#define DEFPATH		":/bin:/usr/bin"	/* Default path */
#define DEFLIBPATH	"/lib:/usr/lib"		/* Default lib path */
#define DEFSHELL	"sh"			/* Default shell name */
#endif
#if GEMDOS
#define PATHSEP		'\\'
#define	PATHSEPSTRING	"\\"
#define LISTSEP		','
#define DEFPATH		",\\bin,\\usr\\bin"
#define DEFLIBPATH	"\\lib,,\\usr\\lib"
#define DEFSHELL	"msh.prg"
#endif
#if MSDOS
#define PATHSEP		'\\'
#define	PATHSEPSTRING	"\\"
#define LISTSEP		';'
#define DEFPATH		";\\bin;\\usr\\bin"
#define DEFLIBPATH	"\\lib;\\usr\\lib"
#define	DEFSHELL	"maybe next release"
#endif
#define MAXPATH	128		/* Size of static path name buffer */
extern char *path();		/* (char *path, *file; int mode) */
