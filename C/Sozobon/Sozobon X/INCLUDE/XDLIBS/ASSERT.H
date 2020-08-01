/* 
 * @(#)assert.h XdLibs, SozobonX
 * 
 * 
 */

#ifndef _ASSERT_H
#define	_ASSERT_H

#ifdef NDEBUG
#define	assert(cond)
#else
#include <stdio.h>
static char __AssertFmt[] = "assert failed in '%s' at line %d.\n";
#define	assert(cond)	if(!(cond)) \
 { fprintf(stderr, __AssertFmt, __FILE__, __LINE__); exit(-1); }
#endif /* NDEBUG */

#endif 	/* _ASSERT_H	*/
