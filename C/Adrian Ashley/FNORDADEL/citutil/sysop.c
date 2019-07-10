/*
 * sysop:  attach a background citadel to the console
 *
 * written 9-Feb-88 by David Parsons
 */
#include <stdio.h>
#include <osbind.h>

main()
{
    FILE *fopen(), *lock;
    register c;
    char *activep;

#if 0
    Fdelete("citadel.lck");		/* WHY?!?!?!  RWH 91Aug09 */
#endif
    if (lock=fopen("citadel.lck","rb")) {
	fscanf(lock,"%lx", &activep);
	fclose(lock);
	fprintf(stderr, "Citadel attached -- type ^Z to detach.\n");
	*activep = 1;
	while (*activep)
	    ;
	fprintf(stderr, "Bye...\n");
    }
    else
	fprintf(stderr, "Citadel is not running.\n");
}
