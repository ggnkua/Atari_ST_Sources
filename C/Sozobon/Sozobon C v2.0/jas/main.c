
/*
 * Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Joseph M Treat
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

/*
 * Version 1.1 contains fixes for referencing the usc = calld ccr registers
 * and not exiting if the -V switch is specified. format specifications for 
 * move sr, ?? and usp moves were incorrect -- fixed. added aliasing for 
 * immediate operations to sr and ccr.
 *
 * Version 1.2 contains changes for minix: input compatibility with ack, 
 * including short absolute addressing mode and explicit pc-relative addressing
 * mode involving text labels, and smarter use of memory.
 */

#include "jas.h"

#define VERSION	2
#define RELEASE 0

jmp_buf err_buf;

extern int sawerror; 

char *ofile = (char *) 0;
char *ifile = (char *) 0;
int Optimize = 1;
int Lflag = 0;
int flag8 = 0;
extern FILE *yyin;

main(argc,argv)
	int argc;
	char *argv[];
{
	extern FILE *freopen();

	if ( setjmp( err_buf ) ) {
		unlink( ofile );
		exit( 1 );
	}

	setflags( argc, argv );

	if ( freopen( ifile, "r", stdin ) == (FILE *) NULL )
		error( 0, "can't open source file for reading" );

#if defined(MINIX) || defined(UNIXHOST)
	if ( freopen( ofile, "w", stdout ) == (FILE *) NULL )
		error( 0, "can't open object file for writing" );
#else
	if ( freopen( ofile, "bw", stdout ) == (FILE *) NULL )
		error( 0, "can't open object file for writing" );
#endif

	yyin = stdin;

	aspass1();

	if ( sawerror )
		unlink( ofile );

	exit( sawerror );
}

setflags(ac,av)
	int ac;
	char *av[];
{
	int errflag = 0, i;
	int Vflag = 0;

	for ( i = 1; i < ac; i++ ) {
		if ( *av[i] == '-' ) {
			switch ( av[i][1] ) {
			case 'o':
				ofile = av[++i];
				break;
			case 'N':
				Optimize = 0;
				break;
			case 'V':
				Vflag = 1;
				break;
			case 'L':
				Lflag = 1;
				if ( av[i][2] )
					Lflag = av[i][2] - '0';
				break;
			case 's':
				i++;
			case 'l':
			case 'u':
				break;
			case '8':
				flag8 = 1;
				break;
			default:
				errflag = 1;
				break;
			}
		} else if (! ifile ) {
			ifile = av[i];
		} else {
			errflag = 1;
		}
	}

	if ( Vflag ) {
		fprintf( stderr, "Sozobon Assembler, Version %d.%d\n",
							VERSION, RELEASE );
		fprintf( stderr, "Copyright (c) 1988,1991 by Sozobon, Limited\n" );
	}

	if (! ifile)
		errflag = 1;

	if ( errflag ) {
		fprintf( stderr, "usage: as [-N] source [-o object]\n" );
		exit( 1 );
	}

	if (! ofile ) {
		char buf[32];
		char *ip, *op;

		for ( op = buf, ip = ifile; *op++ = *ip; ip++ ) {
			if ( *ip == '/' )
				op = buf;
		}

		if ( op[-2] == 's' && op[-3] == '.' ) {
			op[-2] = 'o';
		} else {
			fprintf(stderr, "usage: as [-N] source [-o object]\n" );
			exit( 1 );
		}
		ofile = STRCPY(buf);
	}
}

error(n, s)
	int n;
	char *s;
{
	warn( n, s );
	longjmp( err_buf, 1 );
}

warn(n, s)
	int n;
	char *s;
{
	fprintf(stderr,"jas: ");
	if ( n )
		fprintf(stderr,"line %d: ", n);
	fprintf(stderr,"( %s )\n", s);
	sawerror = 1;
}

char *
allocate(size)
	unsigned size;
{
	register char *loc;
	extern char *calloc();

	loc = calloc( size, 1 );
#ifdef MEM_DEBUG
	fprintf( stderr, "alloc(%u bytes) => %lx\n", size, loc );
#endif
	if ( loc ) {
		return loc;
	}
	error( 0, "out of memory" );
	return (char *) NULL;
}

char *
myreallocate(ptr, size)
	char *ptr;
	unsigned size;
{
	register char *loc;
	extern char *realloc();

	loc = realloc( ptr, size );
	if ( loc ) {
		return loc;
	}
	error( 0, "out of memory" );
	return (char *) NULL;
}

output( buffer, size, nitems )
	char *buffer;
	int size, nitems; 
{
	if ( fwrite( buffer, size, nitems, stdout ) != nitems )
		error( 0, "trouble writing object file" );
}

#ifdef free
#	undef free
#endif

my_free( x )
	char *x;
{
#ifdef MEM_DEBUG
fprintf( stderr, "free( %lx )\n", x );
#endif
	free( x );
}
