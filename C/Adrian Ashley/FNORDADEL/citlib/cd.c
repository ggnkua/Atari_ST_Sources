/*
 * cd.c
 *
 * 90Aug27 AA	Split from libdep.c
 */

#include <osbind.h>

#define ENOERR	 0		/* the anti-error	*/
#define ENODSK	-1		/* no disk		*/
#define ENODIR	-2		/* no directory		*/

int
cd(path)
char path[];
{
    if (path[1] == ':' ) {
	if (Dsetdrv(toupper(*path) - 'A') == 0)
	    return ENODSK;
	path += 2;
    }
    if (path[0] == 0)			/* nothing == root directory.	*/
	path = "\\";
    if (Dsetpath(path) != 0)		/* we are on the appropriate	*/
	return ENODIR;			/* disk now...			*/
    return ENOERR;
}
