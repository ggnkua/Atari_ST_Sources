/*
 *	Prototypes and the like for functions that may be used anywhere.
 *
 *	10/22/93, kay roemer.
 */

#ifndef _UTIL_H
#define _UTIL_H

#define ALIGN2(x)	(((x) + 1) & ~1)
#define ALIGN4(x)	(((x) + 3) & ~3)

#define MIN(x,y)	((x) < (y) ? (x) : (y))
#define MAX(x,y)	((x) > (y) ? (x) : (y))

extern void	spl (short);
extern short	spl7 (void);

#endif /* _UTIL_H */
