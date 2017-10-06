/*
 * slb.h dated 99/08/15
 *
 * Author:
 * Thomas Binder
 * (gryf@hrzpub.tu-darmstadt.de)
 *
 * Purpose:
 * Structures and constants necessary for MagiC-style "share libraries".
 *
 * History:
 * 99/08/11-
 * 99/08/15: - Creation (Gryf)
 */

#ifndef _SLB_H
#define _SLB_H

typedef void *SHARED_LIB;
typedef long (*SLB_EXEC)(SHARED_LIB sl, long fn, short nargs, ...);

long Slbopen(char *name, char *path, long min_ver, SHARED_LIB *sl,
	SLB_EXEC *fn);
long Slbclose(SHARED_LIB sl);

#endif /* _SLB_H */

/* EOF */
