/* $Id: gcc.h,v 1.1 92/04/01 18:27:59 pete Exp $ */

/* this file contains forward and external function declarations */

/* forward declarations */
#if defined( _MSDOS )
void *xmalloc( ), *xrealloc( );
#else
int xmalloc( );
#endif

void perror_with_name( );
void pfatal_with_name( );
void perror_exec( );
#ifdef HAVE_VPRINTF
int fatal( );
#else
void fatal( );
#endif

void error( );
void give_switch( );


/* externally declared functions */
extern void extend_argv( );
extern void free( );
extern int unlink( );
extern int access( );
extern char* mktemp( );
extern int pipe( );
extern int vfork( );
extern int close( );
extern int dup( );
extern int wait( );

#ifndef __TURBOC__
extern int getpid( );
extern int kill( );
#endif
