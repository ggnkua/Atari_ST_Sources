/****************************************************************/
/*------------------------- XDSP.C -----------------------------*/
/* Quelques fonctions qui Çtendent la bibliothäque standard DSP */
/****************************************************************/
#include <math.h>


long ftob24(double x)
{
  double d ;
  long   result ;
  long   mask ;
  int    i ;
  int    flag ;

  if (x == -1.0) return(0x800000L) ;
  flag   = (x < 0.0) ;
  x      = fabs(x) ;
  result = 0 ;
  mask   = 0x00400000L ;
  d      = 0.5 ;
  for (i = 22; i >= 0; i--)
  {
    if (x/d >= 1.0)
    {
      x      = x-d ;
      result = result | mask ;
    }

    d    = d/2.0 ;
    mask = mask >> 1 ;
  }

  if (flag) result = -result ; /* ComplÇment Ö 2 */
  return(result) ;
}

double b24tof(long x)
{
  double add ;
  double result ;
  long   mask ;
  int    i ;

  if (x == 0x00800000L) return(-1.0) ;
  result = 0.0 ;
  add    = 0.5 ;
  mask   = 0x00400000L ;
  for (i = 22; i >= 0; i--)
  {
    if (x & mask) result += add ;
    mask = mask >> 1 ;
    add  = add/2.0 ;
  }

  if (x & 0x00800000L) result = -result ; /* Bit 23 : bit de signe */
  return(result) ;
}
