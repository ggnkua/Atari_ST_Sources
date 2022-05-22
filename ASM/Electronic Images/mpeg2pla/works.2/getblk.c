/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plaympeg.h"
#include "proto.h"

/* defined in getvlc.h */
typedef struct {
  char run, level, len;
} DCTtab;

extern DCTtab DCTtabfirst[],DCTtabnext[],DCTtab0[],DCTtab1[];
extern DCTtab DCTtab2[],DCTtab3[],DCTtab4[],DCTtab5[],DCTtab6[];
extern DCTtab DCTtab0a[],DCTtab1a[];


/* decode one intra coded MPEG-1 block */

void getintrablock(comp,dc_dct_pred)
INT32 comp;
INT32 dc_dct_pred[];
{
  INT32 val, i, j, sign;
  UINT32 code;
  INT32 tval;
  DCTtab *tab;
  INT16 *bp;

  bp = ld_block[comp];
  /* decode DC coefficients */
  if (comp<4)
    bp[0] = (dc_dct_pred[0]+=getDClum()) << 3;
  else if (comp==4)
    bp[0] = (dc_dct_pred[1]+=getDCchrom()) << 3;
  else
    bp[0] = (dc_dct_pred[2]+=getDCchrom()) << 3;

  if (fault) return;

  /* decode AC coefficients */
  for (i=1; ; i++)
  {
    code = showbits(16);
    if (code>=16384)
      tab = &DCTtabnext[(code>>12)-4];
    else if (code>=1024)
      tab = &DCTtab0[(code>>8)-4];
    else if (code>=512)
      tab = &DCTtab1[(code>>6)-8];
    else if (code>=256)
      tab = &DCTtab2[(code>>4)-16];
    else if (code>=128)
      tab = &DCTtab3[(code>>3)-16];
    else if (code>=64)
      tab = &DCTtab4[(code>>2)-16];
    else if (code>=32)
      tab = &DCTtab5[(code>>1)-16];
    else if (code>=16)
      tab = &DCTtab6[code-16];
    else
    {
      if (!quiet)
        fprintf(stderr,"invalid Huffman code in getintrablock()\n");
      fault = 1;
      return;
    }

    flushbits( (UINT32) tab->len); 

    if (tab->run==64) /* end_of_block */
    {
      return;
    }

    if (tab->run==65) /* escape */
    {
      i+= getbits(6);

      val = getbits(8);
      if (val==0)
        val = getbits(8);
      else if (val==128)
        val = getbits(8) - 256;
      else if (val>128)
        val -= 256;

      if (sign = (val<0))
        val = -val;
    }
    else
    {
      i+= tab->run;
      val = tab->level;
      sign = getbits(1); 
    }

    j = zig_zag_scan[i];
    val = (val*ld_quant_scale*ld_intra_quantizer_matrix[j]) >> 3;
    val = (val-1) | 1;
    bp[j] = sign ? -val : val;
  }
}


/* decode one non-intra coded MPEG-1 block */

void getinterblock(comp)
int comp;
{
  INT32 val, i, j, sign;
  UINT32 code;
  INT32 tval;
  unsigned char *rdptr;
  DCTtab *tab;
  INT16 *bp;

  bp = ld_block[comp];

  /* decode AC coefficients */
  for (i=0; ; i++)
  {
    code = showbits(16);
    if (code>=16384)
    {
      if (i==0)
        tab = &DCTtabfirst[(code>>12)-4];
      else
        tab = &DCTtabnext[(code>>12)-4];
    }
    else if (code>=1024)
      tab = &DCTtab0[(code>>8)-4];
    else if (code>=512)
      tab = &DCTtab1[(code>>6)-8];
    else if (code>=256)
      tab = &DCTtab2[(code>>4)-16];
    else if (code>=128)
      tab = &DCTtab3[(code>>3)-16];
    else if (code>=64)
      tab = &DCTtab4[(code>>2)-16];
    else if (code>=32)
      tab = &DCTtab5[(code>>1)-16];
    else if (code>=16)
      tab = &DCTtab6[code-16];
    else
    {
      if (!quiet)
        fprintf(stderr,"invalid Huffman code in getinterblock()\n");
      fault = 1;
      return;
    }

    flushbits((UINT32) tab->len); 

    if (tab->run==64) /* end_of_block */
    {
      return;
    }

    if (tab->run==65) /* escape */
    {
      i+= getbits(6);

      val = getbits(8);
      if (val==0)
        val = getbits(8);
      else if (val==128)
        val = getbits(8) - 256;
      else if (val>128)
        val -= 256;

      if (sign = (val<0))
        val = -val;
    }
    else
    {
      i+= tab->run;
      val = tab->level;
      sign = getbits(1); 
    }

    j = zig_zag_scan[i];
    val = (((val<<1)+1)*ld_quant_scale*ld_non_intra_quantizer_matrix[j]) >> 4;
    /* if (val!=0) should always be true */
      val = (val-1) | 1;
    bp[j] = sign ? -val : val;
  }
}


