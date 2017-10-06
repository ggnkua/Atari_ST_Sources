/**********************************************************************/
/* MTFI 1.21: mtfi.h

   This is a CORE file.  That means that it should not become necessary
   to edit it directly.

   This file includes iface.h automatically; iface.h should not be
   included separately.

     This code is Copyright 1998 Ben Olmstead.  Distribute according
   to the GNU Copyleft (see the file COPYING in the archive from which
   this file was pulled).  Considering the coding standards that the FSF
   demands for anything written for them, this probably is making them
   have fits, but then, FSF code looks like trash, even if it is easy to
   understand.
*/

#ifndef MTFI_H_INCLUDED
#define MTFI_H_INCLUDED

#include <limits.h>
#include <stdlib.h>
#include <time.h>

/* Another option is the use of long long as the fdat type.  This is */
/* not default because long long slows things down a *lot*.  Also,   */
/* FDATLONGLONG will use long long if it knows the compiler supports */
/* it; FORCEFDATLONGLONG should be used when the person compiling    */
/* knows more than this file.                                        */
#if ( defined(FDATLONGLONG) && defined(__GNUC__) &&\
  !defined(__STRICT_ANSI__) && !defined(_POSIX_SOURCE) ) ||\
  defined(FORCEFDATLONGLONG)
  typedef long long fdat;
# define FDATMAX LONG_LONG_MAX
# define FDATMIN LONG_LONG_MIN
#else
  typedef long fdat;
# define FDATMAX LONG_MAX
# define FDATMIN LONG_MIN
#endif

struct stacknode;      /* Declare these here in case iface.h contains */
struct stack;          /* prototypes which use them, but don't define */
struct space;          /* them until below, because their definitions */
struct thread;         /* use prototypes from iface.h */
struct fmach;
struct insset;

#include "iface.h"

#ifndef PATH_MAX                   /* Should work on MS-DOS and POSIX */
# define PATH_MAX 127
#endif

#ifndef SPACEHASHSIZE           /* The interface should be allowed to */
# define SPACEHASHSIZE 32     /* change the values below if necessary */
#endif
#ifndef STACKSIZE
# define STACKSIZE 252
#endif
#ifndef FUNGECACHESIZE
# define FUNGECACHESIZE 16
#endif
#ifndef MAXDIM
# define MAXDIM 5
#endif

#define TORUS 1
#define LAHEY 2

/* If you want to warn when you hit an unsupported instruction or     */
/* kill something or in any other way change the default instruction  */
/* to something other than o, this is where it is done.  Basically,   */
/* when step() encounters a NULL in the instruction table, it         */
/* executes {if(!NULLINS)return(0);}.  The easiest way to deal with   */
/* this is to leave it pointing to nop1, as below.                    */
#ifndef NULLINS
# define NULLINS nop1( th, x, funge )
#endif

/* MTFI's core can be used to interpret Core-Wars-style Befunge       */
/* Gladiators code.  If you need to change the character which fills  */
/* fungespace by default, this would be the place.  Note that if you  */
/* want to be able to do both BeGlad and normal Befunge in the same   */
/* interpreter (I wouldn't suggest this, except that if BeGlad is     */
/* ever specced then I will probably do it) you should change #define */
/* #DEFAULTSPACE to be a variable.                                    */
#ifndef DEFAULTSPACE
# define DEFAULTSPACE ' '
#endif

/* Each of the six structure types includes a place for interpreter-  */
/* specific members.  (Like MTFI's color member to thread, which is   */
/* used on color curses debugging screens.)                           */
struct stacknode
{
  struct stacknode *above;
  struct stacknode *below;
  signed short top;
  signed short bot;
  fdat data[STACKSIZE];
#ifdef STACKNODE_IFACE_ITEMS
    STACKNODE_IFACE_ITEMS
#endif
};

struct stack
{
  struct stacknode *apex;
  struct stacknode *base;
  unsigned char readd;
  unsigned char writed;
#ifdef STACK_IFACE_ITEMS
    STACK_IFACE_ITEMS
#endif
};

struct space
{
  fdat c;
  struct space *next;
#ifdef SPACE_IFACE_ITEMS
    SPACE_IFACE_ITEMS
#endif
};

struct thread
{
  struct stack s;
  unsigned long id;
  unsigned long ticks;
  fdat *coord;
  fdat *delta;
  fdat *base;
  FUF inputf;
  FUF outputf;
  struct thread *next;
  struct thread *prev;
  unsigned char iom;
  unsigned char mode;
  unsigned char swim;
  char inputn[PATH_MAX + 1];
  char outputn[PATH_MAX + 1];
#ifdef BEFUNGE96
  fdat hdelta;
#endif
#ifdef THREAD_IFACE_ITEMS
    THREAD_IFACE_ITEMS
#endif
};

struct fmach
{
#ifdef BEFUNGE96
  struct
  {
    fdat *dat;
    fdat block[MAXDIM];
  } cache[FUNGECACHESIZE];
  struct stack s;
  fdat udefpsh[256];
#endif
  fdat size[MAXDIM];
  fdat nsize[MAXDIM];
  fdat rval;
  unsigned long ticks;
  struct space *spacehash[SPACEHASHSIZE];
  struct thread *t;
  int (*(*iset)[96])( struct thread**, fdat, struct fmach* );
  unsigned char dim;
  unsigned char topo;
  unsigned char nextframe;
#ifdef FMACH_IFACE_ITEMS
    FMACH_IFACE_ITEMS
#endif
};

int mtfi( struct fmach* );
int put( fdat, fdat*, struct fmach* );
fdat get( fdat*, struct fmach* );
int push( fdat n, struct stack *s );
fdat pop( struct stack *s );
int step( struct thread**, struct fmach* );
void movewithwrap( struct thread*, fdat, struct fmach* );
struct fmach *newfmach();
struct thread *newthread( unsigned char );
void destroythread( struct thread*, struct fmach* );
void destroyfmach( struct fmach* );
void clearfmach( struct fmach* );
void destroystack( struct stack* );
void destroyspace( struct space*, int, int );
/**********************************************************************/
#endif /* MTFI_H_INCLUDED */
