/*
	Copyright 1983
	Alcyon Corporation
	8716 Production Ave.
	San Diego, Ca. 92121
*/

char *version = "@(#)nm.c	1.7    6/9/84";

/* cc nm.c v7getchd.c v7getarhd.c v7libget.c -lC -o nm.pdp at ALCYON */

#include <stdio.h>

#ifdef DECC
#		include "Icout"
#		include "Isendc68"
#		define DEFPROG	"c.out"
#else
#	ifdef VERSADOS
#		include <a.out.h>
#		include <ar68.h>
#		define DEFPROG	"a.out"
#	else 
#		ifdef DRI
#			include "aout.h"
#			include "ar68.h"
#			define DEFPROG	"c.out"
#			define fopen	fopenb
			FILE *fopen();
#		else
#			include <c68/a.out.h>
#			include <c68/ar68.h>
#			define DEFPROG	"c.out"
#		endif
#	endif
#endif

FILE *ifp;
char *iam;
char *ifilname;
long offset;
int exact;
int mode;

main(argc,argv)
char **argv;
{
	register char *p;
	unsigned short magic;
	char outbuf1[BUFSIZ];

#ifndef DRI
	setbuf(stdout,outbuf1);
#endif

#ifdef DRI
	if (fileargs(&argc, &argv)) {
		printf("Out of memory reading arguments\n");
		exit(1);
	}
#endif

#ifndef CPM
	iam = *argv;
#else
	iam = "nm68";
#endif

	while( --argc && (*(p = *++argv) == '-' || *p == '+') ) {
		if( *p == '+' ) {
			exact = 1;
			mode = S_DEFINED;
		}
		while( *++p ) {
			switch (*p) {
			case 'f': 
				mode |= S_FILE;
				break;
			case 'e': 
				mode |= S_ABS;
				break;
			case 'g': 
				mode |= S_GLOBAL;
				break;
			case 'q':
				mode |= S_REG;
				break;
			case 'x':
				mode |= S_EXTERNAL;
				break;
			case 'd':
				mode |= S_DATA;
				break;
			case 't':
				mode |= S_TEXT;
				break;
			case 'b':
				mode |= S_BSS;
				break;
			case 'a':
				mode &= ~(S_TEXT|S_DATA|S_BSS);
				break;
			default :
				printf("%s: nonexistent option %c\n",iam,*p);
				printf("usage: %s [-egqxdtbaf] [file...]\n",iam);
				exit(1);
			}
		}
	}

	if( argc == 0 ) {
#ifdef DRI
		printf("%s: no file list\n", iam);
		printf("usage: %s [-egqxdtbaf] [file...]\n",iam);
		exit(1);
#else
		if( openfile(DEFPROG) == 0 )
			exit(1);
		prtsym();
		exit(0);
#endif
	}

	/*	process each file - ignore options in parameter list	*/

	while( argc-- ) {
		if( openfile(*argv++) == 0 )
			continue;
		offset = 0;
		lgetw(&magic,ifp);			/* get magic number */
		if( magic == LIBMAGIC || magic == LIBRMAGIC ) {	/* library (archive) */
			dolib(magic,ifp);
			continue;
		}
#ifndef PDP11
		fseek(ifp, 0L, 0);		/* put the magic number back */
#else
		fclose(ifp);
		openfile(*(argv-1));
#endif
		prtsym();			/* check for a.out format and print symbols */
		fclose(ifp);
	}
	exit(0);
}

prtsym()		/* print all symbols for current object file */
{
	register long symsize, len;
	register char *p;
	register int i, c, first;
	register struct exec2 *hp;
	int flags;
	long value;
	struct exec2 couthd;
	char symbol[20];

	hp = &couthd;
	if( readhdr(hp) == 0 )
		return;						/* not a.out format */
	len = hp->a_text+hp->a_data;
	if( hp->a_magic != E_MAGIC2 )
		len += HDSIZE;
	else
		len += HDSIZ2;
	if( fseek(ifp,len+offset,0) == EOF )
		return;
	for( first = 0, symsize = hp->a_syms; symsize > 0; symsize -= S_SYMSIZ ) {
		for( p = symbol, i = S_SYMLEN; --i != -1; ) {
			if( (c = getc(ifp)) > 0 )
				*p++ = c;
			else
				*p = '\0';
		}
		*p = '\0';
		lgetw(&flags,ifp);
		lgetl(&value,ifp);
		if( mode == 0 || accept(flags) ) {
			if( first++ == 0 )
				printf("%s:\n",ifilname);
			printf("\t%-8s %8lx",symbol,value);
			prtflags(flags);
		}
	}
}

accept(f)
int f;
{
	if( exact )
		return( f == mode );
	return( (f&mode) );
}

prtflags(f)
register int f;
{
	if( f&S_ABS )
		printf(" equ");
	if( f&S_GLOBAL )
		printf(" global");
	if( f&S_REG )
		printf(" reg");
	if( f&S_EXTERNAL )
		printf(" external");
	if( f&S_FILE)
		printf(" filename");
	if( f&S_DATA )
		printf(" data");
	else if( f&S_TEXT )
		printf(" text");
	else if( f&S_BSS )
		printf(" bss");
	else if( f&S_DEFINED )
		printf(" abs");
	else
		printf(" %x",f);
	putchar('\n');
}

openfile(ap)
register char *ap;
{
	if( (ifp = fopen(ap,"r")) == NULL ) {
		printf("%s: no such file '%s'\n",iam, ap);
		return(0);
	}
	ifilname = ap;	/* point to current file name for error msgs */
	return(1);
}

readhdr(hp)
register struct exec2 *hp;
{
	if( getchd(ifp,hp) != 0 ) {
		printf("%s: error reading %s\n",iam,ifilname);
		return(0);
	}

	if( hp->a_magic	< E_MAGIC || hp->a_magic > E_4KMAGIC ) {
		printf("%s: file format error: %s 0x%x\n",iam,ifilname,hp->a_magic);
		return(0);
	}
	return(1);
}

dolib(magic,fp)
unsigned short magic;
register FILE *fp;
{
	register struct libhdr *lp;
	struct libhdr libhd;

	lp = &libhd;
	offset = 2;
	if( magic == LIBRMAGIC ) {
		getarhd(fp,lp);
		offset += LIBHDSIZE+lp->lfsize;	/* skip symbol table */
		fseek(fp, offset, 0);
	}
	while( getarhd(fp, lp) != EOF && *lp->lfname != 0 ) {
		offset += LIBHDSIZE;
		ifilname = lp->lfname;
		prtsym();		/* check for a.out format and print symbols */
		offset += lp->lfsize;
		fseek(fp, offset, 0);
	}
	fclose(fp);
}
