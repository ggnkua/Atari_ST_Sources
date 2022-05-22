/* getbits.c, bit level routines                                            */

#include <stdio.h>
#include <stdlib.h>
#include "global.h"

/* initialize buffer, call once before first getbits or showbits */

void initbits()
{
  ld_incnt = 0;
  ld_rdptr = ld_rdbfr + 8192;
  ld_bfr = 0;
  flushbits(0); /* fills valid data into bfr */
}

void fillbfr()
{
  long l;

  l = read(ld_infile,&ld_rdbfr[0],8192);
  ld_rdptr = &ld_rdbfr[0];

  if (l<8192)
  {
    if (l<0)
      l = 0;

    while (l & 3)
      ld_rdbfr[l++] = 0;

    while (l<8192)
    {
      ld_rdbfr[l++] = ((unsigned long) SEQ_END_CODE>>24);
      ld_rdbfr[l++] = ((unsigned long) SEQ_END_CODE>>16);
      ld_rdbfr[l++] = ((unsigned long) SEQ_END_CODE>>8);
      ld_rdbfr[l++] = ((unsigned long) SEQ_END_CODE&0xff);
    }
  }
}

/* advance by n bits 

void flushbits(n)
int n;
{
  ld_bfr <<= n;
  ld_incnt -= n;
  while (ld_incnt <= 24)
  {
   if (ld_rdptr >= ld_rdbfr+8192)
      fillbfr();
      ld_bfr |= ((unsigned long) *ld_rdptr++) << (24 - ld_incnt);
     ld_incnt += 8;
   }
}

unsigned long getbits(n)
int n;
{
  unsigned long l;
  l=showbits(n);
  ld_bfr <<= n;
  ld_incnt -= n;
  while (ld_incnt <= 24)
  {
   if (ld_rdptr >= ld_rdbfr+8192)
      fillbfr();
   	ld_bfr |= ((unsigned long) *ld_rdptr++) << (24 - ld_incnt);
      ld_incnt += 8;
  }

  return l;
}
*/
