/*
 *  libshare: a dirty patch to make LDG compiled against mintlib shareable
 *
 *  by Arnaud BERCEGEAY (Feb 2004)
 */

#include <stdlib.h>
#include <malloc.h>
#include <unistd.h>
#include "lib.h"
#include "libshare.h"

void libshare_dummy( void);

/* libshare_dummy: 
 * this is a dummy function that shall never be called.
 * the aim of that function is to make a link between this object file
 * and all other objects files of libshare, so that the functions from
 * libshare replace those from mintlib
 */
void 
libshare_dummy( void)
{
	(void)malloc(0);
	free(0);
	(void)realloc(0,0);
	(void)calloc(0,0);
	(void)sbrk(0);
	(void)chdir(0);
}

/* libshare_init:
 * initialise some mintlib/libshare stuff
 * this function must be called only once when the LDG is loaded
 */
void __CDECL
libshare_init( void)
{
	static int init=0;
	
	if (init) return;
	
	/* open stdin/out/err ? */
	/* TODO */
	
	/* the lib is now initialised */
	init=1;
}

/* libshare_exit
 * this function shall be called before being free-ed
 * ie in the "exit" callback function of the LDG
 */
void __CDECL
libshare_exit( void)
{
	/* */
}
