#include <stdio.h>
#include <stdlib.h>
#include "plaympeg.h"
#include "proto.h"

int getbyte(void);

/* initialize buffer, call once before first getbits or showbits */

void initbits()
{ extern UINT32 ld_bitpos;
  int l;
  l = read(ld_infile,ld_rdbfr,8192+4);
  endian_convert(2049,ld_rdbfr);
  ld_bitpos = -32;
  ld_rdptr  = ld_rdbfr;
}

void fillbfr()
{
  unsigned int l;
  ld_rdptr  = ld_rdbfr;
  ld_rdbfr[0] = ld_rdbfr[8192];
  ld_rdbfr[1] = ld_rdbfr[8193];
  ld_rdbfr[2] = ld_rdbfr[8194];
  ld_rdbfr[3] = ld_rdbfr[8195];
  l = read(ld_infile,ld_rdbfr+4,8192l);
  if (l != 8192)
  {
    while (l & 3)
    {  ld_rdbfr[l+4] = 0;
       l++;
    }
    while (l<=8188)
    {
      ld_rdbfr[l+7] = SEQ_END_CODE>>24;
      ld_rdbfr[l+6] = SEQ_END_CODE>>16;
      ld_rdbfr[l+5] = SEQ_END_CODE>>8;
      ld_rdbfr[l+4] = SEQ_END_CODE&0xff;
      l+=4;
    }
  }
  endian_convert(2048,ld_rdbfr+4);
}
