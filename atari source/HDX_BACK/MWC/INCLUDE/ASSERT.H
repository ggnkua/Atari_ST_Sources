/*
 * assert.h -- assertion verifier to test changes to code.
 *
 * Copyright (c) 1981-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

#if NDEBUG
#define	assert(p)
#else
#define	assert(p)	if(!(p)){printf("%s: %d: assert(%s) failed.\n",\
			    __FILE__, __LINE__, #p);exit(1);}
#endif

/* End of assert.h */
