#ifndef ASSERT_H
#define	ASSERT_H

#ifdef NDEBUG

#define	assert(cond)

#else

#ifdef __LINE__

static char __AssertFmt[] = "assert failed in '%s' at line %d.\n";
#define	assert(cond)	if(!(cond)) \
 { fprintf(stderr, __AssertFmt, __FILE__, __LINE__); exit(-1); } else

#else

static char __AssertMsg[] = "assert failure!\n";
#define	assert(cond)	if(!(cond)) \
 { fputs(__AssertMsg, stderr); exit(-1); } else

#endif __LINE__

#endif NDEBUG

#endif ASSERT_H
