/*
	Copyright 1982, 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca. 92121
*/

char *version = "@(#)size.c	1.3    11/21/83";

#include <stdio.h>

#ifdef DRI
#	include "cout.h"
#	define DEF_FILE "c.out"
#	define fopen	fopenb
	extern FILE *fopen();
#else
#	ifndef MC68000
#		include <c68/cout.h>
#		define DEF_FILE "c.out"
#	else
#		include <cout.h>
#		define DEF_FILE "a.out"
#	endif
#endif

struct hdr2 couthd;
int fflag, err;
char *calledby;

main(argc,argv)
int argc;
char **argv;
{
	register char *p;

#ifdef DRI
	if (fileargs(&argc, &argv)) {
		printf("Out of memory reading arguments\n");
		exit(-1);
	}
#endif

#ifdef CPM
	calledby = "size68";
	argv++;
#else
	calledby = *argv++;
#endif
	for( ; argc > 1; argc--, argv++ ) {
		p = *argv;
		if( *p++ != '-' )
			break;
		for( ; *p != '\0'; p++ ) {
			switch( *p ) {

			case 'f':
				fflag++;
				break;

			default:
				printf("%s: bad flag %c\n",calledby,*p);
				printf("usage: %s [-f] [files]\n",calledby);
				exit(-1);
			}
		}
	}
	if( argc <= 1 )
#ifdef DRI
		printf("usage: %s [-f] [files]\n",calledby);
#else
		dofile(DEF_FILE);
#endif
	else {
		while( --argc > 0 )
			dofile(*argv++);
	}
	exit(err);
}

dofile(fn)
char *fn;
{
	register struct hdr2 *hd;
	register FILE *ifp;
	register char *p;
	register long l;

	hd = &couthd;
	if( (ifp = fopen(fn,"r")) == NULL ) {
		printf("%s: unable to open %s\n",calledby,fn);
		err++;
		return;
	}
	if ( getchd(ifp,&couthd) == -1) {
		printf("%s: read error on %s\n",calledby,fn);
		err++;
		fclose(ifp);
		return;
	}
	printf("%s:",fn);
	switch( hd->ch_magic ) {
		case EX_MAGIC:
			p = "(relocatable)";
			break;
		case EX_ABMAGIC:
			p = "(stand alone)";
			break;
		case EX_2KSTXT:
#ifdef DRI
			p = "(krunched)";
#else
			p = "(2k shared text)";
#endif
			break;
		case EX_IDMAGIC:
			p = "(I/D split)";
			break;
		case EX_4KSTXT:
			p = "(4k shared text)";
			break;
		default:
			printf(" not c.out format\n");
			fclose(ifp);
			return;
	}
	l = hd->ch_tsize+hd->ch_dsize+hd->ch_bsize;
	printf("%s%ld+%ld+%ld=%ld (%lx)",p,hd->ch_tsize,hd->ch_dsize,hd->ch_bsize,l,l);
	if( fflag )
		printf(" symbol=%ld",hd->ch_ssize);
	if( hd->ch_stksize || fflag )
		printf(" stack=%ld",hd->ch_stksize);
#ifndef DRI
	if( hd->ch_entry < 0 || fflag )
		printf(" break=%ld",-hd->ch_entry);
#endif
	if( fflag ) {
		if( hd->ch_rlbflg == 0 )
			printf(" (bits)");
		else
			printf(" (nobits)");
	}
	putchar('\n');
	fclose(ifp);
}
