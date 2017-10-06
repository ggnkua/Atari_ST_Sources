/**********************************************************************/
/* MTFI 1.21: mtfi.c

     This code is Copyright 1998 Ben Olmstead.  Distribute according
 to the GNU Copyleft (see the file COPYING in the archive from which
 this file was pulled).  Considering the coding standards that the FSF
 demands for anything written for them, this probably is making them
 have fits, but then, FSF code looks like trash, even if it is easy to
 understand.
*/

/**********************************************************************/
#include "mtfi.h"

#define abso( x ) ( x < 0 ? -x : x )
/**********************************************************************/
/* Note: although these probably shouldn't need to be changed, I will */
/* explain them anyway.  des[] is the size in any one dimension of    */
/* the data blocks.  For example, when one dimension is used, the     */
/* stored data blocks will be 4096 fdats, and when three dimensions   */
/* are in use, the stored data blocks will be 16x16x16 fdats.  dbs[]  */
/* is the total length, in fdats, of a data block.  I've optimized    */
/* both of these tables so that data is allocated in as close to 16k  */
/* blocks as possible without going over, assuming a 32-bit fdat.     */
/* Note also that if MAXDIM is ever put above 15 these need to be     */
/* lengthened.                                                        */
static const unsigned char des[] =
  { 0, 13, 6, 4, 3, 2, 2, 1, 1, 1, 1, 1, 1, 1, 0, 0 };

static const int dbs[] =
{
  0x0000, 0x1fff, 0x0fff, 0x0fff, 0x0fff, 0x03ff, 0x0fff, 0x007f,
  0x00ff, 0x01ff, 0x03ff, 0x07ff, 0x0fff, 0x1fff, 0x0000, 0x0000
};

/**********************************************************************/
struct fmach *newfmach()
{
  struct fmach *fm;
  long i, j;
#ifdef TRACE
  pstr( out, "newfmach();\n" );
#endif
  fm = (struct fmach*)malloc( sizeof(struct fmach) );
  if ( fm == NULL ) return ( fm );
  fm->dim = 2;
  fm->t = NULL;
  fm->iset = NULL;
  fm->ticks = 0;
  fm->rval = 0;
  for ( j = 0; j < SPACEHASHSIZE; j++ ) fm->spacehash[j] = NULL;
  for ( j = 0; j < MAXDIM; j++ ) fm->size[j] = 0, fm->nsize[j] = 0;
  for ( j = 0; j < FUNGECACHESIZE; j++ )
  {
    fm->cache[j].dat = NULL;
    for ( i = 0; i < MAXDIM; i++ ) fm->cache[j].block[i] = -1;
  }
  fm->nextframe = 0;
#ifdef BEFUNGE96
  fm->s.apex = fm->s.base = NULL;
  fm->s.readd = fm->s.writed = 0;
#endif
  return ( fm );
}

/**********************************************************************/
void destroyfmach( struct fmach *fm )
{
#ifdef TRACE
  pstr( out, "destroyfmach( struct fmach *fm=" );
  pnum( out, (fdat)( fm ) );
  pstr( out, " );\n" );
#endif
  clearfmach( fm );
  free( fm );
}
/**********************************************************************/
void clearfmach( struct fmach *fm )
{
  long i, j;
  struct thread *t = fm->t, *s;
#ifdef TRACE
  pstr( out, "clearfmach( struct fmach *fm=" );
  pnum( out, (fdat)( fm ) );
  pstr( out, " );\n" );
#endif
  while ( t != NULL ) { s = t; t = t->next; destroythread( s, NULL ); }
  if ( fm->iset != NULL ) free( fm->iset );
  for ( j = 0; j < SPACEHASHSIZE; j++ )
  {
    destroyspace( fm->spacehash[j], 1, fm->dim );
    fm->spacehash[j] = NULL;
  }
  fm->t = NULL;
  for ( j = 0; j < MAXDIM; j++ ) fm->size[j] = 0, fm->nsize[j] = 0;
  fm->iset = NULL;
  fm->ticks = 0;
  fm->dim = 0;
  fm->rval = 0;
  for ( j = 0; j < FUNGECACHESIZE; j++ )
  {
    fm->cache[j].dat = NULL;
    for ( i = 0; i < MAXDIM; i++ ) fm->cache[j].block[i] = -1;
  }
  fm->nextframe = 0;
#ifdef BEFUNGE96
  destroystack( &fm->s );
#endif
}
/**********************************************************************/
struct thread *newthread( unsigned char dim )
{
  static unsigned idc = 0;
  struct thread *th;
#ifdef TRACE
  pstr( out, "newthread( unsigned char dim=" );
  pnum( out, (fdat)( dim ) );
  pstr( out, " );\n" );
#endif
  th = (struct thread *)malloc( sizeof(struct thread) + 3 * dim * sizeof
    (fdat) );
  if ( th == NULL ) return ( th );
  th->coord = (fdat *)( th + 1 );
  th->delta = th->coord + dim;
  th->base = th->delta + dim;
  th->id = idc++;
#ifdef BEFUNGE96
  th->hdelta = 0;
#endif
  return ( th );
}

/**********************************************************************/
void destroythread( struct thread *th, struct fmach *funge )
{
#ifdef TRACE
  pstr( out, "destroythread( struct thread *th=" );
  pnum( out, (fdat)( th ) );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( th->next != NULL )
  {
    th->next->prev = th->prev;
  }
  if ( th->prev == NULL )
  {
    if ( funge != NULL ) funge->t = th->next;
  }
  else
  {
    th->prev->next = th->next;
  }
  destroystack( &th->s );
  if ( th->inputn[0] ) closef( th->inputf );
  if ( th->outputn[0] ) closef( th->outputf );
  free( th );
}

/**********************************************************************/
void destroystack( struct stack *st )
{
  struct stacknode *sn = st->apex, *sm;
#ifdef TRACE
  pstr( out, "destroystack( struct stack *st=" );
  pnum( out, (fdat)( st ) );
  pstr( out, " );\n" );
#endif
  while ( sn != NULL ) { sm = sn; sn = sn->below; free( sm ); }
  st->apex = NULL;
  st->base = NULL;
}

/**********************************************************************/
void destroyspace( struct space *sp, int depth, int dim )
{
  int j;
#ifdef TRACE
  pstr( out, "destroyspace( struct space *sp=" );
  pnum( out, (fdat)( sp ) );
  pstr( out, ", int depth=" );
  pnum( out, depth );
  pstr( out, ", int dim=" );
  pnum( out, (fdat)( dim ) );
  pstr( out, " );\n" );
#endif
  if ( sp != NULL )
  {
    if ( sp->next != NULL ) destroyspace( sp->next, depth, dim );
    if ( depth < dim )
    {
      for ( j = 0; j < SPACEHASHSIZE; j++ )
      {
        destroyspace( ( (struct space**)( sp + 1 ) )[j], depth + 1, dim );
      }
    }
    free( sp );
  }
}

/**********************************************************************/
int mtfi( struct fmach *funge )
{
  struct thread *th = NULL, *rh = NULL;
#ifdef TRACE
  pstr( out, "mtfi( struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  while ( funge->t != NULL )
  {
    if ( th == NULL ) { th = funge->t; funge->ticks++; }
    if ( !step( &th, funge ) ) return ( 0 );
    if ( th == NULL ) th = rh;
    rh = th;
    th = th->next;
  }
}

/**********************************************************************/
int step( struct thread **th, struct fmach *funge )
{
  fdat y[MAXDIM];
  fdat x, z;
  unsigned i;
#ifdef TRACE
  pstr( out, "step( struct thread **th=" );
  pnum( out, (fdat)( th ) );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( i = 0; i < funge->dim; i++ ) y[i] = ( **th ).coord[i];
  while ( *th != NULL && ( **th ).ticks < funge->ticks )
  {
    z = ( **th ).ticks;
    x = get( ( **th ).coord, funge );
#ifdef FUNGETRACE
     pchr( out, x );
#endif
#ifdef BEFUNGE96
      x += ( **th ).hdelta;
#endif
    if ( funge->iset[( **th ).mode][x < 127 && x > 31 ? x - 31 : 0] !=
      NULL )
    {
      if ( !funge->iset[( **th ).mode][x < 127 && x > 31 ? x - 31 : 0]
        ( th, x, funge ) ) return ( 0 );
    }
    else
    {
      if ( !NULLINS ) return ( 0 );
    }
    if ( *th != NULL )
    {
      if ( z == ( **th ).ticks )
      {
        for ( i = 0; i < funge->dim; i++ )
          if ( y[i] != ( **th ).coord[i] ) break;
        if ( i == funge->dim ) return ( 1 );
      }
      else
      {
        for ( i = 0; i < funge->dim; i++ ) y[i] = ( **th ).coord[i];
      }
    }
  }
  return ( 1 );
}

/**********************************************************************/
int put( fdat x, fdat *c, struct fmach *funge )
{
  unsigned char i, k;
  unsigned short j;
  unsigned long e = 0;
  struct space **s = funge->spacehash;
  struct space *d, **g;
#ifdef TRACE
  pstr( out, "put( fdat x=" );
  pnum( out, x );
  pstr( out, ", fdat *c=" );
  pnum( out, (fdat)( c ) );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( funge->topo == LAHEY )
  {
    for ( i = 0; i < funge->dim; i++ )
    {
      if ( c[i] > funge->size[i] ) funge->size[i] = c[i];
      if ( c[i] < funge->nsize[i] ) funge->nsize[i] = c[i];
    }
  }
  for ( j = 0; j < FUNGECACHESIZE; j++ )
  {
    for ( k = 0; k < funge->dim; k++ )
    {
      if ( funge->cache[j].block[k] != ( c[k] >> des[funge->dim] ) - ( c
        [k] < 0 ? 1 : 0 ) )
      break;
    }
    if ( k == funge->dim )
      break;
  }
  if ( j < FUNGECACHESIZE )
  {
    s = (struct space**)funge->cache[j].dat;
  }
  else
  {
    for ( i = 0; i < funge->dim; i++ )
    {
      g = &s[abso( c[i] >> des[funge->dim] ) % SPACEHASHSIZE];
      d = *g;
      while ( d != NULL && d->c != ( c[i] >> des[funge->dim] ) - ( c[i] <
        0 ? 1 : 0 ) )
      {
        g = &d->next;
        d = *g;
      }
      if ( d == NULL )
      {
        *g = (struct space*)malloc( sizeof(struct space) + ( i == funge->
          dim - 1 ? ( dbs[funge->dim] + 1 ) * sizeof(fdat) : SPACEHASHSIZE
          * sizeof(struct space*) ) );
        if ( *g == NULL )
        {
          pestr( "insufficient memory\n" );
          return ( 0 );
        }
        d = *g;
        d->c = ( c[i] >> des[funge->dim] ) - ( c[i] < 0 ? 1 : 0 );
        d->next = NULL;
        if ( i == funge->dim - 1 )
        {
          for ( j = 0; j <= dbs[funge->dim]; j++ )
          {
            ( (fdat*)( d + 1 ) )[j] = DEFAULTSPACE;
          }
        }
        else
        {
          for ( j = 0; j < SPACEHASHSIZE; j++ )
          {
            ( (struct space**)( d + 1 ) )[j] = NULL;
          }
        }
      }
      s = (struct space**)( d + 1 );
    }
    for ( i = 0; i < funge->dim; i++ )
    {
      funge->cache[funge->nextframe].block[i] = ( c[i] >> des[funge->dim
        ] ) - ( c[i] < 0 ? 1 : 0 );
    }
    funge->cache[funge->nextframe++].dat = (fdat*)s;
    if ( funge->nextframe == FUNGECACHESIZE ) funge->nextframe = 0;
  }
  for ( i = 0; i < funge->dim; i++ )
  {
    e <<= des[funge->dim];
    e += c[i] - ( ( ( c[i] >> des[funge->dim] ) - ( c[i] < 0 ? 1 : 0 ) )
      << des[funge->dim] );
  }
  ( (fdat*)s )[e] = x;
  return ( 1 );
}

/**********************************************************************/
fdat get( fdat *c, struct fmach *funge )
{
  unsigned char i;
  unsigned short j;
  unsigned long e = 0;
  struct space **s = funge->spacehash;
  struct space *d;
#ifdef TRACE
  pstr( out, "get( fdat *c=" );
  pnum( out, (fdat)( c ) );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  for ( j = 0; j < FUNGECACHESIZE; j++ )
  {
    for ( i = 0; i < funge->dim; i++ )
    {
      if ( funge->cache[j].block[i] != ( c[i] >> des[funge->dim] ) - ( c
        [i] < 0 ? 1 : 0 ) )
      break;
    }
    if ( i == funge->dim )
      break;
  }
  if ( j < FUNGECACHESIZE )
  {
    s = (struct space**)funge->cache[j].dat;
  }
  else
  {
    for ( i = 0; i < funge->dim; i++ )
    {
      d = s[abso( c[i] >> des[funge->dim] ) % SPACEHASHSIZE];
      while ( d != NULL && d->c != ( c[i] >> des[funge->dim] ) - ( c[i]
        < 0 ? 1 : 0 ) ) d = d->next;
      if ( d == NULL ) return ( ' ' );
      s = (struct space**)( d + 1 );
    }
    for ( i = 0; i < funge->dim; i++ )
    {
      funge->cache[funge->nextframe].block[i] = ( c[i] >> des[funge->dim
        ] ) - ( c[i] < 0 ? 1 : 0 );
    }
    funge->cache[funge->nextframe++].dat = (fdat*)s;
    if ( funge->nextframe == FUNGECACHESIZE ) funge->nextframe = 0;
  }
  for ( i = 0; i < funge->dim; i++ )
  {
    e <<= des[funge->dim];
    e += c[i] - ( ( ( c[i] >> des[funge->dim] ) - ( c[i] < 0 ? 1 : 0 ) )
      << des[funge->dim] );
  }
  return ( ( (fdat *)s )[e] );
}

/**********************************************************************/
int push( fdat n, struct stack *s )
{
  struct stacknode *sn;
#ifdef TRACE
  pstr( out, "push( fdat n=" );
  pnum( out, n );
  pstr( out, ", struct stack *s=" );
  pnum( out, (fdat)( s ) );
  pstr( out, " );\n" );
#endif
  if ( s->apex == NULL )
  {
    s->apex = (struct stacknode*)malloc( sizeof(struct stacknode) );
    if ( s->apex == NULL )
    {
      pestr( "insufficient memory\n" );
      return ( 0 );
    }
    s->base = s->apex;
    s->base->above = NULL;
    s->base->below = NULL;
    s->base->top = STACKSIZE / 2 - 1;
    s->base->bot = STACKSIZE / 2;
  }
  if ( s->writed )
  {
    sn = s->base;
    if ( sn->bot == 0 )
    {
      sn = (struct stacknode*)malloc( sizeof(struct stacknode) );
      if ( sn == NULL )
      {
        pestr( "insufficient memory\n" );
        return ( 0 );
      }
      sn->above = s->base;
      sn->below = NULL;
      sn->top = STACKSIZE - 1;
      sn->bot = STACKSIZE;
      s->base = sn;
    }
    sn->data[--sn->bot] = n;
  }
  else
  {
    sn = s->apex;
    if ( sn->top == STACKSIZE - 1 )
    {
      sn = (struct stacknode*)malloc( sizeof(struct stacknode) );
      if ( sn == NULL )
      {
        pestr( "insufficient memory\n" );
        return ( 0 );
      }
      sn->below = s->apex;
      sn->above = NULL;
      sn->top = -1;
      sn->bot = 0;
      s->apex = sn;
    }
    sn->data[++sn->top] = n;
  }
  return ( 1 );
}

/**********************************************************************/
fdat pop( struct stack *s )
{
  struct stacknode *sn;
  fdat n;
#ifdef TRACE
  pstr( out, "pop( struct stack *s=" );
  pnum( out, (fdat)( s ) );
  pstr( out, " );\n" );
#endif
  if ( s->apex == NULL ) return ( 0 );
  if ( s->readd )
  {
    sn = s->base;
    n = sn->data[sn->bot++];
  }
  else
  {
    sn = s->apex;
    n = sn->data[sn->top--];
  }
  if ( sn->top < sn->bot )
  {
    if ( sn->above == NULL ) s->apex = sn->below;
      else sn->above->below = sn->below;
    if ( sn->below == NULL ) s->base = sn->above;
      else sn->below->above = sn->above;
    free( sn );
  }
  return ( n );
}

/**********************************************************************/
void movewithwrap( struct thread *t, fdat dist, struct fmach *funge )
{
  fdat scratch[MAXDIM];
  fdat r, s;
  unsigned i;
#ifdef TRACE
  pstr( out, "movewithwrap( struct thread *t=" );
  pnum( out, (fdat)( t ) );
  pstr( out, ", fdat dist=" );
  pnum( out, dist );
  pstr( out, ", struct fmach *funge=" );
  pnum( out, (fdat)( funge ) );
  pstr( out, " );\n" );
#endif
  if ( funge->topo == TORUS )
  {
    for ( i = 0; i < funge->dim; i++ )
    {
      t->coord[i] += t->delta[i] * dist;
      if ( t->coord[i] > funge->size[i] )
      {
        t->coord[i] -= funge->size[i] - funge->nsize[i] + 1;
      }
      else if ( t->coord[i] < funge->nsize[i] )
      {
        t->coord[i] += funge->size[i] - funge->nsize[i] + 1;
      }
    }
    return;
  }
  for ( i = 0; i < funge->dim; i++ )
  {
    if ( t->coord[i] > funge->size[i] || t->coord[i] < funge->nsize[i] )
    {
      for ( s = -1, i = 0; i < funge->dim; i++ )
      {
        if ( t->delta[i] != 0 )
        {
          r = ( t->coord[i] - ( t->delta[i] > 0 ? funge->nsize[i] :
            funge->size[i] ) ) / t->delta[i];
          if ( r < s || s < 0 ) s = r;
        }
      }
      if ( s > 0 )
      {
        for ( i = 0; i < funge->dim; i++ )
        {
          if ( t->coord[i] - s * t->delta[i] > funge->size[i] || t->
            coord[i] - s * t->delta[i] < funge->nsize[i] ) return;
        }
        for ( i = 0; i < funge->dim; i++ )
        {
          t->coord[i] -= s * t->delta[i];
        }
        return;
      }
      return;
    }
  }
  for ( i = 0; i < funge->dim; i++ )
  {
    t->coord[i] += dist * t->delta[i];
  }
}

