#include "lib.h"

/* With GCC 4, zero initialised data ends up in the BSS. We don't want
 * that to happen for _stksiz so we declare it to MINKEEP which is what
 * 0L really is (see crtinit.c).
 *
 * was 
 *
 * long _stksize = 0L; 
 *
 * I actually like this better too, as I can see how much stack really is
 * being defined by mintlib.
 *
 * Alternatively, compile this with the -fno-zero-initialized-in-bss in
 * GCC 4 and set it back to the way it was, but that will stop GCC 2.x
 * compiling this code.
 */
long _stksize = MINKEEP;
