/* getblk.c, DCT block decoding                                             */

/*
 * All modifications (mpeg2decode -> mpeg2play) are
 * Copyright (C) 1994, Stefan Eckart. All Rights Reserved.
 */

/* Copyright (C) 1994, MPEG Software Simulation Group. All Rights Reserved. */

/*
 * Disclaimer of Warranty
 *
 * These software programs are available to the user without any license fee or
 * royalty on an "as is" basis.  The MPEG Software Simulation Group disclaims
 * any and all warranties, whether express, implied, or statuary, including any
 * implied warranties or merchantability or of fitness for a particular
 * purpose.  In no event shall the copyright-holder be liable for any
 * incidental, punitive, or consequential damages of any kind whatsoever
 * arising from the use of these programs.
 *
 * This disclaimer of warranty extends to the user of these programs and user's
 * customers, employees, agents, transferees, successors, and assigns.
 *
 * The MPEG Software Simulation Group does not represent or warrant that the
 * programs furnished hereunder are free of infringement of any third-party
 * patents.
 *
 * Commercial implementations of MPEG-1 and MPEG-2 video, including shareware,
 * are subject to royalty fees to patent holders.  Many of these patents are
 * general enough such that they are unavoidable regardless of implementation
 * design.
 *
 */

#include <stdio.h>

#include "config.h"
#include "global.h"


/* defined in getvlc.h */
typedef struct {
  char run, level, len;
} DCTtab;

extern DCTtab DCTtabfirst[],DCTtabnext[],DCTtab0[],DCTtab1[];
extern DCTtab DCTtab2[],DCTtab3[],DCTtab4[],DCTtab5[],DCTtab6[];
extern DCTtab DCTtab0a[],DCTtab1a[];


/* decode one intra coded MPEG-1 block */

void getintrablock(comp,dc_dct_pred)
int comp;
int dc_dct_pred[];
{
  int val, i, j, sign;
  int incnt;
  unsigned int bfr;
  unsigned int code;
  int tval;
  DCTtab *tab;
  short *bp;

  bp = ld->block[comp];
  /* decode DC coefficients */
  if (comp<4)
    bp[0] = (dc_dct_pred[0]+=getDClum()) << 3;
  else if (comp==4)
    bp[0] = (dc_dct_pred[1]+=getDCchrom()) << 3;
  else
    bp[0] = (dc_dct_pred[2]+=getDCchrom()) << 3;

  if (fault) return;

  incnt = ld->incnt;
  bfr = ld->bfr;

  /* decode AC coefficients */
  for (i=1; ; i++)
  {
    code = bfr >> 16;
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

    /* flushbits(tab->len); */
    bfr <<= tab->len;
    incnt -= tab->len;

    if (incnt <= 24)
    {
      if (sysstream && (ld->rdptr >= ld->rdmax-4))
      {
        do
        {
          if (ld->rdptr >= ld->rdmax)
            nextpacket();
          bfr |= getbyte() << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
      }
      else if (ld->rdptr < ld->rdbfr+2044)
      {
        do
        {
          bfr |= *ld->rdptr++ << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
      }
      else
      {
        do
        {
          if (ld->rdptr >= ld->rdbfr+2048)
            fillbfr();
          bfr |= *ld->rdptr++ << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
      }
    }

    if (tab->run==64) /* end_of_block */
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
      return;
    }

    if (tab->run==65) /* escape */
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
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
      incnt = ld->incnt;
      bfr = ld->bfr;
    }
    else
    {
      i+= tab->run;
      val = tab->level;
      /* sign = getbits(1); */
      sign = bfr>>31;
      bfr <<= 1;
      incnt--;
    }

/*
    if (i>=64)
    {
      if (!quiet)
        fprintf(stderr,"DCT coeff index (i) out of bounds (intra)\n");
      fault = 1;
      return;
    }
*/

    j = zig_zag_scan[i];
    val = (val*ld->quant_scale*ld->intra_quantizer_matrix[j]) >> 3;
    /* if (val!=0) should always be true */
      val = (val-1) | 1;
    bp[j] = sign ? -val : val;
  }
}


/* decode one non-intra coded MPEG-1 block */

void getinterblock(comp)
int comp;
{
  int val, i, j, sign;
  int incnt;
  unsigned int bfr;
  unsigned int code;
  int tval;
  unsigned char *rdptr;
  DCTtab *tab;
  short *bp;

  bp = ld->block[comp];
  incnt = ld->incnt;
  bfr = ld->bfr;
  rdptr = ld->rdptr;

  /* decode AC coefficients */
  for (i=0; ; i++)
  {
    code = bfr >> 16;
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

    /* flushbits(tab->len); */
    bfr <<= tab->len;
    incnt -= tab->len;

    if (incnt <= 24)
    {
      if (sysstream && (rdptr >= ld->rdmax-4))
      {
        ld->rdptr = rdptr;
        do
        {
          if (ld->rdptr >= ld->rdmax)
            nextpacket();
          bfr |= getbyte() << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
        rdptr = ld->rdptr;
      }
      else if (rdptr < ld->rdbfr+2044)
      {
        do
        {
          bfr |= *rdptr++ << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
      }
      else
      {
        do
        {
          if (rdptr >= ld->rdbfr+2048)
          {
            fillbfr();
            rdptr = ld->rdptr;
          }
          bfr |= *rdptr++ << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
      }
    }

    if (tab->run==64) /* end_of_block */
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
      ld->rdptr = rdptr;
      return;
    }

    if (tab->run==65) /* escape */
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
      ld->rdptr = rdptr;
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
      incnt = ld->incnt;
      bfr = ld->bfr;
      rdptr = ld->rdptr;
    }
    else
    {
      i+= tab->run;
      val = tab->level;
      /* sign = getbits(1); */
      sign = bfr>>31;
      bfr <<= 1;
      incnt --;
    }

/*
    if (i>=64)
    {
      if (!quiet)
        fprintf(stderr,"DCT coeff index (i) out of bounds (inter)\n");
      fault = 1;
      return;
    }
*/

    j = zig_zag_scan[i];
    val = (((val<<1)+1)*ld->quant_scale*ld->non_intra_quantizer_matrix[j]) >> 4;
    /* if (val!=0) should always be true */
      val = (val-1) | 1;
    bp[j] = sign ? -val : val;
  }
}


/* decode one intra coded MPEG-2 block */

void getmpg2intrablock(comp,dc_dct_pred)
int comp;
int dc_dct_pred[];
{
  int val, i, j, sign, nc;
  int incnt;
  unsigned int bfr;
  unsigned int code;
  DCTtab *tab;
  short *bp;
  int *qmat;
  struct layer_data *ld1;

  /* with data partitioning, data always goes to base layer */
  ld1 = (ld->scalable_mode==SC_DP) ? &base : ld;
  bp = ld1->block[comp];

  if (base.scalable_mode==SC_DP)
    if (base.pri_brk<64)
      ld = &enhan;
    else
      ld = &base;

  qmat = (comp<4 || chroma_format==CHROMA420)
         ? ld1->intra_quantizer_matrix
         : ld1->chroma_intra_quantizer_matrix;

  /* decode DC coefficients */
  if (comp<4)
    val = (dc_dct_pred[0]+= getDClum());
  else if ((comp&1)==0)
    val = (dc_dct_pred[1]+= getDCchrom());
  else
    val = (dc_dct_pred[2]+= getDCchrom());

  if (fault) return;

  bp[0] = val << (3-dc_prec);

  nc=0;

  incnt = ld->incnt;
  bfr = ld->bfr;

  /* decode AC coefficients */
  for (i=1; ; i++)
  {
    code = bfr >> 16;
    if (code>=16384 && !intravlc)
      tab = &DCTtabnext[(code>>12)-4];
    else if (code>=1024)
    {
      if (intravlc)
        tab = &DCTtab0a[(code>>8)-4];
      else
        tab = &DCTtab0[(code>>8)-4];
    }
    else if (code>=512)
    {
      if (intravlc)
        tab = &DCTtab1a[(code>>6)-8];
      else
        tab = &DCTtab1[(code>>6)-8];
    }
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
        fprintf(stderr,"invalid Huffman code in getmpg2intrablock()\n");
      fault = 1;
      return;
    }

    /* flushbits(tab->len); */
    bfr <<= tab->len;
    incnt -= tab->len;

    if (incnt <= 24)
    {
      if (ld->rdptr < ld->rdbfr+2044)
      {
        do
        {
          bfr |= *ld->rdptr++ << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
      }
      else
      {
        do
        {
          if (ld->rdptr >= ld->rdbfr+2048)
            fillbfr();
          bfr |= *ld->rdptr++ << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
      }
    }

    if (tab->run==64) /* end_of_block */
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
      return;
    }

    if (tab->run==65) /* escape */
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
      i+= getbits(6);

      val = getbits(12);
      if ((val&2047)==0)
      {
        if (!quiet)
          fprintf(stderr,"invalid signed_level (escape) in getmpg2intrablock()\n");
        fault = 1;
        return;
      }
      if (sign = (val>=2048))
        val = 4096 - val;
      incnt = ld->incnt;
      bfr = ld->bfr;
    }
    else
    {
      i+= tab->run;
      val = tab->level;
      /* sign = getbits(1); */
      sign = bfr>>31;
      bfr <<= 1;
      incnt--;
    }

/*
    if (i>=64)
    {
      if (!quiet)
        fprintf(stderr,"DCT coeff index (i) out of bounds (intra2)\n");
      fault = 1;
      return;
    }
*/

    j = (ld1->altscan ? alternate_scan : zig_zag_scan)[i];
    val = (val * ld1->quant_scale * qmat[j]) >> 4;
    bp[j] = sign ? -val : val;
    nc++;

    if (base.scalable_mode==SC_DP && nc==base.pri_brk-63)
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
      ld = &enhan;
      incnt = ld->incnt;
      bfr = ld->bfr;
    }
  }
}


/* decode one non-intra coded MPEG-2 block */

void getmpg2interblock(comp)
int comp;
{
  int val, i, j, sign, nc;
  int incnt;
  unsigned int bfr;
  unsigned int code;
  DCTtab *tab;
  short *bp;
  int *qmat;
  struct layer_data *ld1;

  /* with data partitioning, data always goes to base layer */
  ld1 = (ld->scalable_mode==SC_DP) ? &base : ld;
  bp = ld1->block[comp];

  if (base.scalable_mode==SC_DP)
    if (base.pri_brk<64)
      ld = &enhan;
    else
      ld = &base;

  qmat = (comp<4 || chroma_format==CHROMA420)
         ? ld1->non_intra_quantizer_matrix
         : ld1->chroma_non_intra_quantizer_matrix;

  nc = 0;

  incnt = ld->incnt;
  bfr = ld->bfr;

  /* decode AC coefficients */
  for (i=0; ; i++)
  {
    code = bfr >> 16;
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
        fprintf(stderr,"invalid Huffman code in getmpg2interblock()\n");
      fault = 1;
      return;
    }

    /* flushbits(tab->len); */
    bfr <<= tab->len;
    incnt -= tab->len;

    if (incnt <= 24)
    {
      if (ld->rdptr < ld->rdbfr+2044)
      {
        do
        {
          bfr |= *ld->rdptr++ << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
      }
      else
      {
        do
        {
          if (ld->rdptr >= ld->rdbfr+2048)
            fillbfr();
          bfr |= *ld->rdptr++ << (24 - incnt);
          incnt += 8;
        }
        while (incnt <= 24);
      }
    }

    if (tab->run==64) /* end_of_block */
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
      return;
    }

    if (tab->run==65) /* escape */
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
      i+= getbits(6);

      val = getbits(12);
      if ((val&2047)==0)
      {
        if (!quiet)
          fprintf(stderr,"invalid signed_level (escape) in getmpg2intrablock()\n");
        fault = 1;
        return;
      }
      if (sign = (val>=2048))
        val = 4096 - val;
      incnt = ld->incnt;
      bfr = ld->bfr;
    }
    else
    {
      i+= tab->run;
      val = tab->level;
      /* sign = getbits(1); */
      sign = bfr>>31;
      bfr <<= 1;
      incnt --;
    }

/*
    if (i>=64)
    {
      if (!quiet)
        fprintf(stderr,"DCT coeff index (i) out of bounds (inter2)\n");
      fault = 1;
      return;
    }
*/

    j = (ld1->altscan ? alternate_scan : zig_zag_scan)[i];
    val = (((val<<1)+1) * ld1->quant_scale * qmat[j]) >> 5;
    bp[j] = sign ? -val : val;
    nc++;

    if (base.scalable_mode==SC_DP && nc==base.pri_brk-63)
    {
      ld->incnt = incnt;
      ld->bfr = bfr;
      ld = &enhan;
      incnt = ld->incnt;
      bfr = ld->bfr;
    }
  }
}
