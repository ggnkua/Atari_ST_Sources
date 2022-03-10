
# include "y1.h" 

/*
 * yptitm.1c
 *
 * Modified to make debug code conditionally compile.
 * 28-Aug-81
 * Bob Denny
 */

void putitem( ptr, lptr )
int             * ptr;
struct looksets * lptr;


{
  register struct item * j;

  # ifdef debug
  if ( foutput != NULL )

    {
      fprintf( foutput,
               "putitem(%s), state %d\n",
               writem( ptr ),
               nstate );
    }
    # endif 
  j        = pstate[ nstate + 1 ];
  j->pitem = ptr;
  if ( !nolook )
    j->look = flset( lptr );
  pstate[ nstate + 1 ] = ++j;
  if ( ( int * )j > zzmemsz )

    {
      zzmemsz = ( int * )j;
      if ( zzmemsz >= &mem0[ MEMSIZE ] )
        error( "out of state space" );
    }
}
