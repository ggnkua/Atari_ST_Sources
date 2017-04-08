/*
 *   Header file for making the STinG header files work 
 *      with various compilers.
 *
 *   Just  #include "portab.h"  before #include'ing the 
 *      other header files ...
 *
 */

#ifndef __PUREC__

#ifdef LATTICE
#define  cdecl  __stdargs
#else
#define  cdecl
#endif

#endif
