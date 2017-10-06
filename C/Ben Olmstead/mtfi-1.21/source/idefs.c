/**********************************************************************/
/* MTFI 1.21: idefs.c												  */
/*																	  */
/*     This code is Copyright 1998 Ben Olmstead.  Distribute according */
/* to the GNU Copyleft (see the file COPYING in the archive from which */
/* this file was pulled).  Considering the coding standards that the FSF */
/* demands for anything written for them, this probably is making them */
/* have fits, but then, FSF code looks like trash, even if it is easy to */
/* understand.															*/


#include <time.h>
#include "mtfi.h"
#include "idefs.h"

/**********************************************************************/
int absd( struct thread **t, fdat c, struct fmach *funge )       /* X */
{
  unsigned short j;
#ifdef TRACE
  pstr( out, "absd( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = funge->dim; j > 0; j-- )
    ( **t ).delta[j - 1] = pop( &( **t ).s );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int ad96( struct thread **t, fdat c, struct fmach *funge )     /* + */
  {
# ifdef TRACE
    pstr( out, "ad96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    if ( !push( pop( &funge->s ) + pop( &funge->s ), &funge->s ) )
      return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int addn( struct thread **t, fdat c, struct fmach *funge )       /* + */
{
#ifdef TRACE
  pstr( out, "addn( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( !push( pop( &( **t ).s ) + pop( &( **t ).s ), &( **t ).s ) )
    return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#if MAXDIM >= 3
  int asct( struct thread **t, fdat c, struct fmach *funge )     /* U */
  {
# if MAXDIM >= 4
      unsigned i;
# endif
# ifdef TRACE
    pstr( out, "asct( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).delta[0] = ( **t ).delta[1] = 0;
    ( **t ).delta[2] = 1;
# if MAXDIM >= 4
      for ( i = 3; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
# endif
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int chrm( struct thread **t, fdat c, struct fmach *funge )       /* ' */
{
#ifdef TRACE
  pstr( out, "chrm( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).mode = 3;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int clst( struct thread **t, fdat c, struct fmach *funge )       /* n */
{
#ifdef TRACE
  pstr( out, "clst( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  destroystack( &( **t ).s );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int cm96( struct thread **t, fdat c, struct fmach *funge )     /* ' */
  {
# ifdef TRACE
    pstr( out, "cm96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).mode = 2;
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int comm( struct thread **t, fdat c, struct fmach *funge )       /* ; */
{
#ifdef TRACE
  pstr( out, "comm( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).mode = 4;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks--;
  return ( 1 );
}

/**********************************************************************/
#if MAXDIM >= 3
  int dest( struct thread **t, fdat c, struct fmach *funge )     /* D */
  {
# if MAXDIM >= 4
      unsigned i;
# endif
# ifdef TRACE
    pstr( out, "dest( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).delta[0] = ( **t ).delta[1] = 0;
    ( **t ).delta[2] = -1;
# if MAXDIM >= 4
      for ( i = 3; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
# endif
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int divn( struct thread **t, fdat c, struct fmach *funge )       /* / */
{
  fdat i;
#ifdef TRACE
  pstr( out, "divn( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  i = pop( &( **t ).s );
  if ( i == 0 )
  {
    i = pop( &( **t ).s );
    if ( i < 0 ) i = FDATMIN; else if ( i > 0 ) i = FDATMAX;
  }
  else
  {
    i = pop( &( **t ).s ) / i;
  }
  if ( !push( i, &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int du96( struct thread **t, fdat c, struct fmach *funge )     /* : */
  {
    fdat i;
# ifdef TRACE
    pstr( out, "du96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i = pop( &funge->s );
    if ( !push( i, &funge->s ) ) return ( 0 );
    if ( !push( i, &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int dupl( struct thread **t, fdat c, struct fmach *funge )       /* : */
{
  fdat i;
#ifdef TRACE
  pstr( out, "dupl( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  i = pop( &( **t ).s );
  if ( !push( i, &( **t ).s ) ) return ( 0 );
  if ( !push( i, &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int dv96( struct thread **t, fdat c, struct fmach *funge )     /* / */
  {
    fdat i;
# ifdef TRACE
    pstr( out, "dv96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i = pop( &funge->s );
    if ( i == 0 )
    {
      i = pop( &funge->s );
      if ( i < 0 ) i = FDATMIN; else if ( i > 0 ) i = FDATMAX;
    }
    else
    {
      i = pop( &funge->s ) / i;
    }
    if ( !push( i, &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int east( struct thread **t, fdat c, struct fmach *funge )       /* > */
{
#if MAXDIM >= 2
    unsigned i;
#endif
#ifdef TRACE
  pstr( out, "east( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).delta[0] = 1;
#if MAXDIM >= 2
    for ( i = 1; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
#endif
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int endp( struct thread **t, fdat c, struct fmach *funge )       /* E */
{
  struct thread *s = funge->t, *r;
#ifdef TRACE
  pstr( out, "endp( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  funge->rval = pop( &( **t ).s );
  while ( s != NULL ) { r = s; s = s->next; destroythread( r, NULL ); }
  *t = NULL;
  return ( 1 );
}

/**********************************************************************/
int file( struct thread **t, fdat c, struct fmach *funge )       /* F */
{
  fdat j;
  unsigned i;
#ifdef TRACE
  pstr( out, "file( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  j = pop( &( **t ).s );
  if ( j == 0 )
  {
    if ( ( **t ).inputn[0] ) closef( ( **t ).inputf );
    for ( i = 0; i < PATH_MAX; i++ )
    {
      ( **t ).inputn[i] = pop( &( **t ).s );
      if ( !( **t ).inputn[i] ) break;
    }
    if ( i == PATH_MAX )
    {
      ( **t ).inputn[i] = '\0';
      while ( pop( &( **t ).s ) );
    }
    if ( ( **t ).inputn[0] )
    {
      ( **t ).inputf = openf( ( **t ).inputn, ( **t ).iom ? "rb" :
        "r" );
      if ( ( **t ).inputf == FUFNOTOPEN )
      {
        ( **t ).inputf = in;
        destroythread( *t, funge );
      }
    }
    if ( !push( 1, &( **t ).s ) ) return ( 0 );
  }
  else if ( j == 1 )
  {
    if ( ( **t ).outputn[0] ) closef( ( **t ).outputf );
    for ( i = 0; i < PATH_MAX; i++ )
    {
      ( **t ).outputn[i] = pop( &( **t ).s );
      if ( !( **t ).outputn[i] ) break;
    }
    if ( i == PATH_MAX )
    {
      ( **t ).outputn[i] = '\0';
      while ( pop( &( **t ).s ) );
    }
    if ( ( **t ).outputn[0] )
    {
      ( **t ).outputf = openf( ( **t ).outputn, ( **t ).iom ? "wb" :
        "w" );
      if ( ( **t ).outputf == FUFNOTOPEN )
      {
        ( **t ).outputf = out;
        destroythread( *t, funge );
      }
    }
    if ( !push( 1, &( **t ).s ) ) return ( 0 );
  }
  else
  {
    while ( pop( &( **t ).s ) );
    if ( !push( 0, &( **t ).s ) ) return ( 0 );
  }
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int ga96( struct thread **t, fdat c, struct fmach *funge )     /* g */
  {
    fdat i[MAXDIM] = { 0, 0 };
    unsigned short j;
# ifdef TRACE
    pstr( out, "ga96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    for ( j = funge->dim; j > 0; j-- )
      i[j - 1] = pop( &funge->s );
    if ( !push( get( i, funge ), &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int geta( struct thread **t, fdat c, struct fmach *funge )       /* g */
{
  fdat i[MAXDIM] = { 0, 0 };
  unsigned short j;
#ifdef TRACE
  pstr( out, "geta( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = funge->dim; j > 0; j-- )
    i[j - 1] = pop( &( **t ).s ) + ( **t ).base[j - 1];
  if ( !push( get( i, funge ), &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int getr( struct thread **t, fdat c, struct fmach *funge )       /* G */
{
  fdat i[MAXDIM];
  unsigned short j;
#ifdef TRACE
  pstr( out, "getr( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = funge->dim; j > 0; j-- )
    i[j - 1] = pop( &( **t ).s ) + ( **t ).coord[j - 1];
  if ( !push( get( i, funge ), &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int gr96( struct thread **t, fdat c, struct fmach *funge )     /* G */
  {
    fdat i[MAXDIM];
    unsigned short j;
# ifdef TRACE
    pstr( out, "gr96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
#endif
    for ( j = funge->dim; j > 0; j-- )
      i[j - 1] = pop( &funge->s ) + ( **t ).coord[j - 1];
    if ( !push( get( i, funge ), &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int gret( struct thread **t, fdat c, struct fmach *funge )       /* ` */
{
  fdat i;
#ifdef TRACE
  pstr( out, "gret( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  i = pop( &( **t ).s );
  if ( !push( pop( &( **t ).s ) > i, &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int gt96( struct thread **t, fdat c, struct fmach *funge )     /* ` */
  {
    fdat i;
# ifdef TRACE
    pstr( out, "gt96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i = pop( &funge->s );
    if ( !push( pop( &funge->s ) > i, &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int hd96( struct thread **t, fdat c, struct fmach *funge )     /* h */
  {
# ifdef TRACE
    pstr( out, "hd96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).hdelta = pop( &funge->s );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int hi96( struct thread **t, fdat c, struct fmach *funge )     /* _ */
  {
    unsigned short i;
# ifdef TRACE
    pstr( out, "hi96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).delta[0] = ( pop( &funge->s ) ? -1 : 1 );
    for ( i = 1; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int hzif( struct thread **t, fdat c, struct fmach *funge )       /* _ */
{
#if MAXDIM >= 2
  unsigned short i;
#endif
#ifdef TRACE
  pstr( out, "hzif( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).delta[0] = ( pop( &( **t ).s ) ? -1 : 1 );
#if MAXDIM >= 2
  for ( i = 1; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
#endif
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int ic96( struct thread **t, fdat c, struct fmach *funge )     /* ~ */
  {
# if '\n' != '\x0a'
    fdat i;
# endif
# ifdef TRACE
    pstr( out, "ic96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
# if '\n' != '\x0a'
    i = readc( ( **t ).inputf );
    if ( i == '\n' ) i = '\x0a';
    if ( !push( i, &funge->s ) ) return ( 0 );
# else
    if ( !push( readc( ( **t ).inputf ), &funge->s ) ) return ( 0 );
# endif
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int ichr( struct thread **t, fdat c, struct fmach *funge )       /* ~ */
{
#if '\n' != '\x0a'
  fdat i;
#endif
#ifdef TRACE
  pstr( out, "ichr( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
#if '\n' != '\x0a'
  i = readc( ( **t ).inputf );
  if ( i == '\n' ) i = '\x0a';
  if ( !push( i, &( **t ).s ) ) return ( 0 );
#else
  if ( !push( readc( ( **t ).inputf ), &( **t ).s ) ) return ( 0 );
#endif
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int im96( struct thread **t, fdat c, struct fmach *funge )     /* i */
  {
# ifdef TRACE
    pstr( out, "im96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    funge->s.writed = funge->s.readd = !funge->s.writed;
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int in96( struct thread **t, fdat c, struct fmach *funge )     /* & */
  {
# ifdef TRACE
    pstr( out, "in96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    if ( !push( readn( ( **t ).inputf ), &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int inum( struct thread **t, fdat c, struct fmach *funge )       /* & */
{
#ifdef TRACE
  pstr( out, "inum( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( !push( readn( ( **t ).inputf ), &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int invm( struct thread **t, fdat c, struct fmach *funge )       /* i */
{
#ifdef TRACE
  pstr( out, "invm( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).s.writed = !( **t ).s.writed;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int jmpz( struct thread **t, fdat c, struct fmach *funge )       /* z */
{
  unsigned j;
#ifdef TRACE
  pstr( out, "jmpz( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = funge->dim; j > 0; j-- )
    ( **t ).coord[j - 1] += pop( &( **t ).s );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int jump( struct thread **t, fdat c, struct fmach *funge )       /* J */
{
  unsigned j;
#ifdef TRACE
  pstr( out, "jump( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = funge->dim; j > 0; j-- )
    ( **t ).coord[j - 1] += pop( &( **t ).s );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int kill( struct thread **t, fdat c, struct fmach *funge )       /* @ */
{
#ifdef TRACE
  pstr( out, "kill( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  destroythread( *t, funge );
  *t = NULL;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int lg96( struct thread **t, fdat c, struct fmach *funge )     /* ( */
  {
    fdat i[MAXDIM] = { 0, 0 };
# ifdef TRACE
    pstr( out, "lg96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i[0] = ( **t ).delta[1] + ( **t ).coord[0];
    i[1] = -( **t ).delta[0] + ( **t ).coord[1];
    if ( !push( get( i, funge ), &funge->s ) ) return ( 0 );
    if ( ( **t ).swim )
      if ( !put( ')', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int lget( struct thread **t, fdat c, struct fmach *funge )     /* ( */
  {
    fdat i[MAXDIM] = { 0, 0 };
# if MAXDIM >= 3
      unsigned short j;
# endif
# ifdef TRACE
    pstr( out, "lget( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i[0] = ( **t ).delta[1] + ( **t ).coord[0];
    i[1] = -( **t ).delta[0] + ( **t ).coord[1];
# if MAXDIM >= 3
      for ( j = 2; j < funge->dim; j++ )
        i[j] = ( **t ).delta[j] + ( **t ).coord[j];
# endif
    if ( !push( get( i, funge ), &( **t ).s ) ) return ( 0 );
    if ( ( **t ).swim )
      if ( !put( ')', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int ln96( struct thread **t, fdat c, struct fmach *funge )     /* ! */
  {
# ifdef TRACE
    pstr( out, "ln96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    if ( !push( !pop( &funge->s ), &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int lnot( struct thread **t, fdat c, struct fmach *funge )       /* ! */
{
#ifdef TRACE
  pstr( out, "lnot( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( !push( !pop( &( **t ).s ), &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int lp96( struct thread **t, fdat c, struct fmach *funge )     /* { */
  {
    fdat i[MAXDIM];
# ifdef TRACE
    pstr( out, "lp96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i[0] = ( **t ).delta[1] + ( **t ).coord[0];
    i[1] = -( **t ).delta[0] + ( **t ).coord[1];
    if ( !put( pop( &funge->s ), i, funge ) ) return ( 0 );
    if ( ( **t ).swim )
      if ( !put( '}', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int lput( struct thread **t, fdat c, struct fmach *funge )     /* { */
  {
    fdat i[MAXDIM];
# if MAXDIM >= 3
      unsigned short j;
# endif
# ifdef TRACE
    pstr( out, "lput( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i[0] = ( **t ).delta[1] + ( **t ).coord[0];
    i[1] = -( **t ).delta[0] + ( **t ).coord[1];
# if MAXDIM >= 3
      for ( j = 2; j < funge->dim; j++ )
        i[j] = ( **t ).delta[j] + ( **t ).coord[j];
# endif
    if ( !put( pop( &( **t ).s ), i, funge ) ) return ( 0 );
    if ( ( **t ).swim )
      if ( !put( '}', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int md96( struct thread **t, fdat c, struct fmach *funge )     /* % */
  {
    fdat i;
# ifdef TRACE
    pstr( out, "md96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i = pop( &funge->s );
    if ( i == 0 )
    {
      pop( &funge->s );
    }
    else
    {
      i = pop( &funge->s ) % i;
    }
    if ( !push( i, &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int ml96( struct thread **t, fdat c, struct fmach *funge )     /* * */
  {
# ifdef TRACE
    pstr( out, "ml96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    if ( !push( pop( &funge->s ) * pop( &funge->s ), &funge->s ) )
      return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int modn( struct thread **t, fdat c, struct fmach *funge )       /* % */
{
  fdat i;
#ifdef TRACE
  pstr( out, "modn( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  i = pop( &( **t ).s );
  if ( i == 0 )
  {
    pop( &( **t ).s );
  }
  else
  {
    i = pop( &( **t ).s ) % i;
  }
  if ( !push( i, &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int muln( struct thread **t, fdat c, struct fmach *funge )       /* * */
{
#ifdef TRACE
  pstr( out, "muln( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( !push( pop( &( **t ).s ) * pop( &( **t ).s ), &( **t ).s ) )
    return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int newt( struct thread **t, fdat c, struct fmach *funge )      /* T */
{
  struct thread *s, *z;
  struct stacknode *u, *v, *w;
  unsigned i;
#ifdef TRACE
  pstr( out, "newt( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  s = newthread( funge->dim );
  if ( s == NULL )
  {
    pestr( "insufficient memory\n" );
    return ( 0 );
  }
  z = *t;
  while ( z->next != NULL ) z = z->next;
  s->prev = z->prev;
  s->next = z;
  if ( z->prev == NULL ) funge->t = s; else z->prev->next = s;
  z->prev = s;
  u = z->s.apex;
  while ( u != NULL )
  {
    if ( u->above == NULL )
    {
      v = (struct stacknode*)malloc( sizeof(struct stacknode) );
      if ( v == NULL )
      {
        pestr( "insufficient memory\n" );
        return ( 0 );
      }
      v->above = NULL;
      s->s.apex = v;
    }
    else
    {
      v->below = (struct stacknode*)malloc( sizeof(struct stacknode) );
      if ( v->below == NULL )
      {
        pestr( "insufficient memory\n" );
        return ( 0 );
      }
      v->below->above = v;
      v = v->below;
    }
    for ( i = 0; i < STACKSIZE; i++ ) v->data[i] = u->data[i];
    v->top = u->top;
    v->bot = u->bot;
    u = u->below;
  }
  v->below = NULL;
  s->s.base = v;
  s->s.readd = z->s.readd;
  s->s.writed = z->s.writed;
  s->mode = z->mode;
  s->swim = z->swim;
  s->ticks = z->ticks + 1;
  s->inputn[0] = s->outputn[0] = '\0';
  s->iom = z->iom;
  s->inputf = in;
  s->outputf = out;
  if ( funge->dim == 0 ) funge->dim = 2;
  for ( i = 0; i < funge->dim; i++ )
  {
    s->base[i] = z->base[i];
    s->delta[i] = -z->delta[i];
  }
  movewithwrap( *t, 1, funge );
  movewithwrap( s, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int nop0( struct thread **t, fdat c, struct fmach *funge )       /*   */
{
#ifdef TRACE
  pstr( out, "nop0( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  movewithwrap( *t, 1, funge );
  return ( 1 );
}

/**********************************************************************/
int nop1( struct thread **t, fdat c, struct fmach *funge )       /* o */
{
#ifdef TRACE
  pstr( out, "nop1( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int norm( struct thread **t, fdat c, struct fmach *funge )    /* "";; */
{
#ifdef TRACE
  pstr( out, "norm( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).mode = 0;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#if MAXDIM >= 2
  int nort( struct thread **t, fdat c, struct fmach *funge )     /* ^ */
  {
# if MAXDIM >= 3
      unsigned i;
# endif
# ifdef TRACE
    pstr( out, "nort( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).delta[0] = 0;
    ( **t ).delta[1] = -1;
# if MAXDIM >= 3
      for ( i = 2; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
# endif
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int oc96( struct thread **t, fdat c, struct fmach *funge )     /* , */
  {
    char n;
# ifdef TRACE
    pstr( out, "oc96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    n = pop( &funge->s );
# if '\n' != '\x0a'
    if ( n == '\x0a' ) n = '\n';
# endif
    pchr( ( **t ).outputf, n );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int ochr( struct thread **t, fdat c, struct fmach *funge )       /* , */
{
  char n;
#ifdef TRACE
  pstr( out, "ochr( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  n = pop( &( **t ).s );
#if '\n' != '\x0a'
  if ( n == '\x0a' ) n = '\n';
#endif
  pchr( ( **t ).outputf, n );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int on96( struct thread **t, fdat c, struct fmach *funge )     /* . */
  {
# ifdef TRACE
    pstr( out, "on96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    pnum( ( **t ).outputf, pop( &funge->s ) );
    pstr( ( **t ).outputf, " " );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int onum( struct thread **t, fdat c, struct fmach *funge )       /* . */
{
#ifdef TRACE
  pstr( out, "onum( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  pnum( ( **t ).outputf, pop( &( **t ).s ) );
  pstr( ( **t ).outputf, " " );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int pa96( struct thread **t, fdat c, struct fmach *funge )     /* p */
  {
    fdat i[MAXDIM];
    unsigned short j;
# ifdef TRACE
    pstr( out, "pa96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    for ( j = funge->dim; j > 0; j-- )
      i[j - 1] = pop( &funge->s ) + ( **t ).base[j - 1];
    if ( !put( pop( &funge->s ), i, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int pc96( struct thread **t, fdat c, struct fmach *funge )     /* ' */
  {
# ifdef TRACE
    pstr( out, "pc96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    if ( !push( c, &funge->s ) ) return ( 0 );
    ( **t ).mode = 0;
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int pn96( struct thread **t, fdat c, struct fmach *funge )   /* 0-9 */
  {
# ifdef TRACE
    pstr( out, "pn96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    if ( !push( c - '0', &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int po96( struct thread **t, fdat c, struct fmach *funge )     /* $ */
  {
# ifdef TRACE
    pstr( out, "po96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    pop( &funge->s );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int popn( struct thread **t, fdat c, struct fmach *funge )       /* $ */
{
#ifdef TRACE
  pstr( out, "popn( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  pop( &( **t ).s );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#if MAXDIM >= 3
  int ppif( struct thread **t, fdat c, struct fmach *funge )     /* H */
  {
# if MAXDIM >= 4
    unsigned short i;
# endif
# ifdef TRACE
    pstr( out, "ppif( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).delta[0] = ( **t ).delta[1] = 0;
    ( **t ).delta[2] = ( pop( &( **t ).s ) ? 1 : -1 );
# if MAXDIM >= 4
      for ( i = 3; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
# endif
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int pr96( struct thread **t, fdat c, struct fmach *funge )     /* P */
  {
    fdat i[MAXDIM];
    unsigned short j;
# ifdef TRACE
    pstr( out, "pr96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    for ( j = funge->dim; j > 0; j-- )
      i[j - 1] = pop( &funge->s ) + ( **t ).coord[j - 1];
    if ( !put( pop( &funge->s ), i, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int ps96( struct thread **t, fdat c, struct fmach *funge )     /* " */
  {
# ifdef TRACE
    pstr( out, "ps96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    if ( !push( c, &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int pshc( struct thread **t, fdat c, struct fmach *funge )       /* ' */
{
#ifdef TRACE
  pstr( out, "pshc( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( !push( c, &( **t ).s ) ) return ( 0 );
  ( **t ).mode = 0;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int pshd( struct thread **t, fdat c, struct fmach *funge )       /* Y */
{
  unsigned j;
#ifdef TRACE
  pstr( out, "pshd( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = 0; j < funge->dim; j++ )
    if ( !push( ( **t ).delta[j], &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int pshn( struct thread **t, fdat c, struct fmach *funge )     /* 0-9 */
{
#ifdef TRACE
  pstr( out, "pshn( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( !push( c - '0', &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int pshs( struct thread **t, fdat c, struct fmach *funge )       /* " */
{
#ifdef TRACE
  pstr( out, "pshs( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( !push( c, &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int pshx( struct thread **t, fdat c, struct fmach *funge )     /* a-f */
{
#ifdef TRACE
  pstr( out, "pshx( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( !push( c - 'a' + 10, &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
/* Exactly the same as puta, but truncates the value to a char--used  */
/* for backwards compatibility with Befunge-93 Befungespace.          */
int pt93( struct thread **t, fdat c, struct fmach *funge )       /* p */
{
  fdat i[MAXDIM];
  unsigned short j;
  char z;
#ifdef TRACE
  pstr( out, "pt93( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = funge->dim; j > 0; j-- )
    i[j - 1] = pop( &( **t ).s ) + ( **t ).base[j - 1];
  z = pop( &( **t ).s );
  if ( !put( z, i, funge ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int pu96( struct thread **t, fdat c, struct fmach *funge )     /* " */
  {
# ifdef TRACE
    pstr( out, "pu96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    if ( !push( funge->udefpsh[c], &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int puta( struct thread **t, fdat c, struct fmach *funge )       /* p */
{
  fdat i[MAXDIM];
  unsigned short j;
#ifdef TRACE
  pstr( out, "puta( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = funge->dim; j > 0; j-- )
    i[j - 1] = pop( &( **t ).s ) + ( **t ).base[j - 1];
  if ( !put( pop( &( **t ).s ), i, funge ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int putr( struct thread **t, fdat c, struct fmach *funge )       /* P */
{
  fdat i[MAXDIM];
  unsigned short j;
#ifdef TRACE
  pstr( out, "putr( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = funge->dim; j > 0; j-- )
    i[j - 1] = pop( &( **t ).s ) + ( **t ).coord[j - 1];
  if ( !put( pop( &( **t ).s ), i, funge ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int quem( struct thread **t, fdat c, struct fmach *funge )       /* q */
{
#ifdef TRACE
  pstr( out, "quem( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).s.readd = !( **t ).s.readd;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int repo( struct thread **t, fdat c, struct fmach *funge )       /* R */
{
  unsigned j;
  fdat i[MAXDIM];
  fdat k[MAXDIM];
#ifdef TRACE
  pstr( out, "repo( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = funge->dim; j > 0; j-- ) k[j - 1] = pop( &( **t ).s );
  for ( j = funge->dim; j > 0; j-- ) i[j - 1] = pop( &( **t ).s );
  for ( j = 0; j < funge->dim; j++ )
    if( !push( ( **t ).coord[j], &( **t ).s ) ) return ( 0 );
  for ( j = 0; j < funge->dim; j++ )
    if( !push( ( **t ).base[j], &( **t ).s ) ) return ( 0 );
  for ( j = 0; j < funge->dim; j++ ) ( **t ).coord[j] = i[j];
  for ( j = 0; j < funge->dim; j++ ) ( **t ).base[j] = k[j];
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int revr( struct thread **t, fdat c, struct fmach *funge )       /* A */
{
  unsigned i;
#ifdef TRACE
  pstr( out, "revr( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( i = 0; i < funge->dim; i++ ) ( **t ).delta[i] *= -1;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int rg96( struct thread **t, fdat c, struct fmach *funge )     /* ) */
  {
    fdat i[MAXDIM];
# ifdef TRACE
    pstr( out, "rg96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i[0] = -( **t ).delta[1] + ( **t ).coord[0];
    i[1] = ( **t ).delta[0] + ( **t ).coord[1];
    if ( !push( get( i, funge ), &funge->s ) ) return ( 0 );
    if ( ( **t ).swim )
      if ( !put( '(', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int rget( struct thread **t, fdat c, struct fmach *funge )     /* ) */
  {
    fdat i[MAXDIM];
# if MAXDIM >= 3
    unsigned short j;
# endif
# ifdef TRACE
    pstr( out, "rget( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i[0] = -( **t ).delta[1] + ( **t ).coord[0];
    i[1] = ( **t ).delta[0] + ( **t ).coord[1];
# if MAXDIM >= 3
    for ( j = 2; j < funge->dim; j++ )
      i[j] = ( **t ).delta[j] + ( **t ).coord[j];
# endif
    if ( !push( get( i, funge ), &( **t ).s ) ) return ( 0 );
    if ( ( **t ).swim )
      if ( !put( '(', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int rndd( struct thread **t, fdat c, struct fmach *funge )       /* ? */
{
  unsigned short i;
#ifdef TRACE
  pstr( out, "rndd( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( i = 0; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
  ( **t ).delta[( r() % funge->dim )] = ( r() & ( r() % sizeof(short) )
    ) ? 1 : -1;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int roll( struct thread **t, fdat c, struct fmach *funge )       /* r */
{
  fdat n;
  fdat i;
  unsigned char wd, rd;
#ifdef TRACE
  pstr( out, "roll( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  wd = ( **t ).s.writed;
  rd = ( **t ).s.readd;
  n = pop( &( **t ).s );
  if ( n < 0 )
  {
    n = -n;
    ( **t ).s.writed = 1;
    ( **t ).s.readd = 0;
  }
  else
  {
    ( **t ).s.writed = 0;
    ( **t ).s.readd = 1;
  }
  for ( i = 0; i < n; i++ )
    if ( !push( pop( &( **t ).s ), &( **t ).s ) ) return ( 0 );
  ( **t ).s.writed = wd;
  ( **t ).s.readd = rd;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int rp96( struct thread **t, fdat c, struct fmach *funge )     /* } */
  {
    fdat i[MAXDIM];
# ifdef TRACE
    pstr( out, "rp96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i[0] = -( **t ).delta[1] + ( **t ).coord[0];
    i[1] = ( **t ).delta[0] + ( **t ).coord[1];
    if ( !put( pop( &funge->s ), i, funge ) ) return ( 0 );
    if ( ( **t ).swim )
      if ( !put( '}', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int rput( struct thread **t, fdat c, struct fmach *funge )     /* } */
  {
    fdat i[MAXDIM];
# if MAXDIM >= 3
    unsigned short j;
# endif
# ifdef TRACE
    pstr( out, "rput( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i[0] = -( **t ).delta[1] + ( **t ).coord[0];
    i[1] = ( **t ).delta[0] + ( **t ).coord[1];
# if MAXDIM >= 3
      for ( j = 2; j < funge->dim; j++ )
        i[j] = ( **t ).delta[j] + ( **t ).coord[j];
# endif
    if ( !put( pop( &( **t ).s ), i, funge ) ) return ( 0 );
    if ( ( **t ).swim )
      if ( !put( '}', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#ifdef BEFUNGE96
  int sb96( struct thread **t, fdat c, struct fmach *funge )     /* - */
  {
    fdat i;
# ifdef TRACE
    pstr( out, "sb96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i = pop( &funge->s );
    if ( !push( pop( &funge->s ) - i, &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int sbsm( struct thread **t, fdat c, struct fmach *funge )       /*   */
{
#ifdef TRACE
  pstr( out, "sbsm( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( !push( ' ', &( **t ).s ) ) return ( 0 );
  ( **t ).mode = 2;
  movewithwrap( *t, 1, funge );
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int sk96( struct thread **t, fdat c, struct fmach *funge )     /* j */
  {
# ifdef TRACE
    pstr( out, "sk96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    movewithwrap( *t, 1 + pop( &funge->s ), funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int skip( struct thread **t, fdat c, struct fmach *funge )       /* # */
{
#ifdef TRACE
  pstr( out, "skip( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  movewithwrap( *t, 2, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int skpn( struct thread **t, fdat c, struct fmach *funge )       /* j */
{
#ifdef TRACE
  pstr( out, "skpn( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  movewithwrap( *t, 1 + pop( &( **t ).s ), funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#if MAXDIM >= 2
  int sout( struct thread **t, fdat c, struct fmach *funge )     /* v */
  {
# if MAXDIM >= 3
    unsigned i;
# endif
# ifdef TRACE
    pstr( out, "sout( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).delta[0] = 0;
    ( **t ).delta[1] = 1;
# if MAXDIM >= 3
    for ( i = 2; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
# endif
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int strm( struct thread **t, fdat c, struct fmach *funge )       /* " */
{
#ifdef TRACE
  pstr( out, "strm( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).mode = 1;
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int subn( struct thread **t, fdat c, struct fmach *funge )       /* - */
{
  fdat i;
#ifdef TRACE
  pstr( out, "subn( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  i = pop( &( **t ).s );
  if ( !push( pop( &( **t ).s ) - i, &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int sw96( struct thread **t, fdat c, struct fmach *funge )     /* \ */
  {
    fdat i, j;
# ifdef TRACE
    pstr( out, "sw96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i = pop( &funge->s );
    j = pop( &funge->s );
    if ( !push( i, &funge->s ) ) return ( 0 );
    if ( !push( j, &funge->s ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int swap( struct thread **t, fdat c, struct fmach *funge )       /* \ */
{
  fdat i, j;
#ifdef TRACE
  pstr( out, "swap( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  i = pop( &( **t ).s );
  j = pop( &( **t ).s );
  if ( !push( i, &( **t ).s ) ) return ( 0 );
  if ( !push( j, &( **t ).s ) ) return ( 0 );
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#if MAXDIM >= 2
  int swim( struct thread **t, fdat c, struct fmach *funge )     /* s */
  {
# ifdef TRACE
    pstr( out, "swim( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).swim = !( **t ).swim;
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int swit( struct thread **t, fdat c, struct fmach *funge )     /* w */
  {
    fdat j, k;
# ifdef TRACE
    pstr( out, "swit( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    j = pop( &( **t ).s );
    k = pop( &( **t ).s );
    if ( j > k ) return ( trnl( t, c, funge ) );
    if ( j < k ) return ( trnl( t, c, funge ) );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int test( struct thread **t, fdat c, struct fmach *funge )     /* V */
  {
    fdat j;
# ifdef TRACE
    pstr( out, "test( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    j = pop( &( **t ).s );
    if ( j < 127 && j > 31 && funge->iset[0][j - 31] != NULL )
      return ( sout( t, c, funge ) );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int tiqm( struct thread **t, fdat c, struct fmach *funge )     /* Q */
  {
#  ifdef TRACE
    pstr( out, "tiqm( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    if ( ( **t ).s.readd && ( **t ).s.writed )
      return ( revr( t, c, funge ) );
    if ( ( **t ).s.readd ) return ( trnl( t, c, funge ) );
    if ( ( **t ).s.writed ) return ( trnr( t, c, funge ) );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int trnl( struct thread **t, fdat c, struct fmach *funge )     /* [ */
  {
    fdat i;
# ifdef TRACE
    pstr( out, "trnl( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i = ( **t ).delta[1];
    ( **t ).delta[1] = -( **t ).delta[0];
    ( **t ).delta[0] = i;
    if ( ( **t ).swim )
      if ( !put( ']', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int trnr( struct thread **t, fdat c, struct fmach *funge )     /* ] */
  {
    fdat i;
# ifdef TRACE
    pstr( out, "trnr( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    i = -( **t ).delta[1];
    ( **t ).delta[1] = ( **t ).delta[0];
    ( **t ).delta[0] = i;
    if ( ( **t ).swim )
      if ( !put( '[', ( **t ).coord, funge ) ) return ( 0 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int ussm( struct thread **t, fdat c, struct fmach *funge )       /*   */
{
#ifdef TRACE
  pstr( out, "ussm( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).mode = 1;
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
#ifdef BEFUNGE96
  int vi96( struct thread **t, fdat c, struct fmach *funge )     /* | */
  {
# ifdef TRACE
    pstr( out, "vi96( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).delta[0] = 0;
    ( **t ).delta[1] = ( pop( &funge->s ) ? -1 : 1 );
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
#if MAXDIM >= 2
  int vtif( struct thread **t, fdat c, struct fmach *funge )     /* | */
  {
# if MAXDIM >= 3
      unsigned short i;
# endif
# ifdef TRACE
    pstr( out, "vtif( struct thread **t=" );
    pnum( out, (fdat)( t ) );
    pstr( out, ", fdat c=" );
    pnum( out, c );
    pstr( out, ", struct fmach *funge=" );
    pnum( out, (fdat)( funge ) );
    pstr( out, " );\n" );
# endif
    ( **t ).delta[0] = 0;
    ( **t ).delta[1] = ( pop( &( **t ).s ) ? -1 : 1 );
# if MAXDIM >= 3
      for ( i = 2; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
# endif
    movewithwrap( *t, 1, funge );
    ( **t ).ticks++;
    return ( 1 );
  }
#endif

/**********************************************************************/
int west( struct thread **t, fdat c, struct fmach *funge )       /* < */
{
#if MAXDIM >= 2
  unsigned i;
#endif
#ifdef TRACE
  pstr( out, "west( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  ( **t ).delta[0] = -1;
#if MAXDIM >= 2
  for ( i = 1; i < funge->dim; i++ ) ( **t ).delta[i] = 0;
#endif
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}

/**********************************************************************/
int ybsc( struct thread **t, fdat c, struct fmach *funge )       /* y */
{
  fdat j;
  int i = 0;
  time_t r;
  struct tm *tim;
  struct stacknode *s = ( **t ).s.apex;
#ifdef TRACE
  pstr( out, "ybsc( struct thread **t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat c=" );
  pnum( out, c );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  switch ( pop( &( **t ).s ) )
  {
    case 0: if ( !push( ( **t ).id, &( **t ).s ) ) return ( 0 ); break;
    case 1:
      while ( s != NULL ) i += s->top - s->bot + 1, s = s->below;
      if ( !push( i, &( **t ).s ) ) return ( 0 );
      break;
    case 2:
      for ( i = 0; i < funge->dim; i++ )
        if ( !push( ( **t ).coord[i], &( **t ).s ) ) return ( 0 );
      break;
    case 3:
      for ( i = 0; i < funge->dim; i++ )
        if ( !push( ( **t ).delta[i], &( **t ).s ) ) return ( 0 );
      break;
    case 4:
      for ( i = 0; i < funge->dim; i++ )
        if ( !push( ( **t ).base[i], &( **t ).s ) ) return ( 0 );
      break;
    case 5:
      if ( !push( !( **t ).iom, &( **t ).s ) ) return ( 0 );
      ( **t ).iom = !( **t ).iom;
      break;
    case 6:
      time( &r );
      tim = localtime( &r );
      if ( !push( tim->tm_year, &( **t ).s ) ) return ( 0 );
      if ( !push( tim->tm_mon, &( **t ).s ) ) return ( 0 );
      if ( !push( tim->tm_mday, &( **t ).s ) ) return ( 0 );
      if ( !push( tim->tm_hour, &( **t ).s ) ) return ( 0 );
      if ( !push( tim->tm_min, &( **t ).s ) ) return ( 0 );
      if ( !push( tim->tm_sec, &( **t ).s ) ) return ( 0 );
      break;
    default: break;
  }
  movewithwrap( *t, 1, funge );
  ( **t ).ticks++;
  return ( 1 );
}


