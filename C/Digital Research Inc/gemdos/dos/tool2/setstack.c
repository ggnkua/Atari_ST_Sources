/*
	Copyright 1982
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca.  92121
*/

/* set the stack size for a c.out format file */

char *version = "@(#)setstack.c	1.3    12/9/83";

#ifndef MC68000
#	include <c68/a.out.h>
#else
#	include <a.out.h>
#endif

main(argc,argv)
int argc;
char **argv;
{
	register int fd;
	register char *file, *calledby;
	register struct exec2 *hd;
	struct exec2 couthd;

#ifdef PDP11
	register int stksize, brksize;
#	define atol(x)	atoi(x)
#else
	register long stksize, brksize;
	long atol();
#endif

	calledby = *argv++;
	brksize = 0;
	hd = &couthd;
	if( *argv == 0 )
		goto usage;
	file = *argv++;
	if( *argv == 0 )
		goto usage;
	if( (stksize = atol(*argv++)) < 0 ) {
		printf("%s: bad stack size\n",calledby);
		goto usage;
	}
	if( *argv ) {
		if( (brksize = atol(*argv)) < 0 ) {
			printf("%s: bad break size\n",calledby);
usage:
			printf("usage: %s filename stksize [brksize]\n",calledby);
			exit(1);
		}
	}
	if( (fd = open(file,2)) == -1 ) {
		printf("%s: can't open %s\n",calledby,file);
		exit(1);
	}
	if(fdgetchd(fd,hd) != 0) {
		printf("%s: can't read %s\n",calledby,file);
		exit(1);
	}
	brksize = (brksize+1023)&(~1023);	/* round to 1K boundary */
	stksize = (stksize+1023)&(~1023);	/* round to 1K boundary */

	if( hd->a_magic < E_MAGIC || hd->a_magic > E_4KMAGIC ) {
		printf("%s: %s not c.out format\n",calledby,file);
		exit(1);
	}
	hd->a_stksize = stksize;
	hd->a_entry = -brksize;
#ifdef PDP11
	seek(fd,0,0);
#else
	lseek(fd,0L,0);
#endif
	if(fdputchd(fd,hd) != 0) {
		printf("%s: can't write %s\n",calledby,file);
		exit(1);
	}
	exit(0);
}
