/**********************************************************************/
/* MTFI 1.21: iface.h

 This file is a part of the INTERFACE.  That means that, if you want
 to port this program or write a new user interface, you SHOULD modify
 this file.  See below for how.

 This file contains the things which the interface needs to tell the
 core at compile time.  You can put declarations for interface-
 specific functions in this file without harm, but this isn't really
 the appropriate place.

 This file is automatically included at the appropriate place from
 mtfi.h; it should not be included seperately.  (Specifically, mtfi.h
 includes the file after it has declared all the structure types and
 defined fdat but before it has defined the structures.)

     This code is Copyright 1998 Ben Olmstead.  Distribute according
 to the GNU Copyleft (see the file COPYING in the archive from which
 this file was pulled).  Considering the coding standards that the FSF
 demands for anything written for them, this probably is making them
 have fits, but then, FSF code looks like trash, even if it is easy to
 understand.
*/

#ifndef IFACE_H_INCLUDED
#define IFACE_H_INCLUDED

#include <stdio.h>

/* This file is not consistent across different systems.  This should */
/* be the #include of the file which contains the declaration of      */
/* malloc().  On most systems, this should be either malloc.h, mem.h, */
/* or memory.h.                                                       */
#include <stdlib.h>

/* Use this to enable Befunge-96 support.                             */
#define BEFUNGE96

/* Note that any functions which must be specified by this file may   */
/* be implemented as macros without ill effect.                       */

/* The rand() function which comes with many C compilers is not very  */
/* good.  If you wish to write your own, do so.  Also note that you   */
/* have to call srand() or srandom() yourself in the interface.  Also */
/* note that the only place this is ever called in normal Funge is    */
/* from the ? instruction.                                            */
#define r() rand()

/* These are provided so that a) this can be ported without extreme   */
/* difficulty to windowing systems where standard keyboard i/o is not */
/* available, and b) so that writers of interactive debuggers don't   */
/* have to deal with these munging the screen up.  pnum() is what's   */
/* called when a number must be printed (it should *not* add a space  */
/* at the end of the number--the . instruction does this already.).   */
/* pchr() sends a character to a file/standard output.  It should be  */
/* capable of printing '\0'.  pstr() sends a string to a file/        */
/* standard output, no formatting.                                    */
/*                                                                    */
/* Also note that, unless TRACE or FUNGETRACE is defined, the only    */
/* places calls to these are made are the ., instructions.  pstr() is */
/* never called without TRACE or FUNGETRACE.  Note also that TRACE    */
/* and FUNGETRACE are meant for debugging the core.                   */
#define pnum( x, n ) fprintf( x, "%d", n ); fflush( x )
#define pchr( x, n ) putc( n, x ); fflush( x )
#define pstr( x, n ) fprintf( x, "%s", n ); fflush( x )

/* These two are the same as pnum() and pstr(), except that they      */
/* should go to the error stream.  These are called from quite a few  */
/* places in the core.                                                */
#define penum( n ) fprintf( stderr, "%d", n )
#define pestr( n ) fprintf( stderr, "%s", n )

/* Provided as hooks.  Should act exactly as fclose() and fopen() C   */
/* functions, but should return/accept the FUF type instead of FILE*. */
#define closef( f ) fclose( f )
#define openf( f, m ) fopen( f, m )

/* Value returned by readc() to indicate an end-of-file state.  This  */
/* should be an integer outside of the range of char.                 */
#define FUEOF 32767

/* Value returned by openf() to indicate failure.                     */
#define FUFNOTOPEN NULL

/* In case you aren't sending the standard input/output streams       */
/* directly to stdin/stdout, and/or FUF is not a FILE*.               */
#define out stdout
#define in stdin

/* Each of the six structures used by the core contains, in its       */
/* declaration, a place to allow the interface to insert custom       */
/* members.  For the time being, these values should not be pointers  */
/* to dynamically-allocated memory, since the various create() and    */
/* destroy() functions do not contain hooks to allow the interface to */
/* deal with such things.                                             */
#define THREAD_IFACE_ITEMS unsigned char color;

/* All of the compile-time options in mtfi.h may be overridden here.  */
#define MAXDIM 7

/* If you wish to monitor file i/o, and you have some custom type     */
/* you'd like to be used instead of FILE*, this is where you put it.  */
typedef FILE* FUF;

/* These two functions read a character or a number.  They are called */
/* only by ~ and &, respectively, in standard Funge.                  */
fdat readc( FILE* );
fdat readn( FILE* );

#endif /* IFACE_H_INCLUDED */
