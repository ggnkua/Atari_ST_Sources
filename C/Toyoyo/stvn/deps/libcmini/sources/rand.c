#include <stdlib.h>
#include <limits.h>

#define  A    16807L    /*  A "good" multiplier   */
#define  M   2147483647L    /*  Modulus: 2^31 - 1     */
#define  Q       127773L    /*  M / A         */
#define  R         2836L    /*  M % A         */

long _lseed = 1L;

int rand(void)
{
  _lseed = A * (_lseed % Q) - R * (_lseed / Q);

  if ( _lseed < 0 )
    _lseed += M;

#ifdef __MSHORT__
  return( (int)(_lseed & 0x7fffL) );    /* how "good" is it now ? */
#else
  return( (int) _lseed );
#endif
}
