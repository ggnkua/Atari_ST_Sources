#ifndef ASSERT_H
#define	ASSERT_H

#ifdef NDEBUG
#define	assert(cond)
#else
static char __AssertFmt[] = "assert failed in '%s' at line %d.\n";
#define	assert(cond)	if(!(cond)) \
 { fprintf(stderr, __AssertFmt, __FILE__, __LINE__); exit(-1); }
#endif

#endif ASSERT_H
