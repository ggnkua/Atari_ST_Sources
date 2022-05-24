/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plaympeg.h"

/* defined in getvlc.h */
typedef struct {
  char run, level, len;
} DCTtab;

DCTtab_padded biggie[65536l];

extern DCTtab DCTtabfirst[],DCTtabnext[],DCTtab0[],DCTtab1[];
extern DCTtab DCTtab2[],DCTtab3[],DCTtab4[],DCTtab5[],DCTtab6[];
extern DCTtab DCTtab0a[],DCTtab1a[];


void init_getblk(void)
{	unsigned long code,fault;

	/* make intra table */

   	for (code = 0 ; code < 65536 ; code++)
	{	DCTtab *tab;
		fault = 0;
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
			fault = 1;
		if (!fault)
		{	
			biggie[code].len = tab->len;
			biggie[code].run = tab->run;
			biggie[code].level = tab->level;
		} 
		else			
		{	biggie[code].run = 64; /* EOB */
			biggie[code].len = 1;
			biggie[code].level = 0;
		}
	}

}

/*
 *	Initialize the VLC decoding table for macro_block_address_increment
 */

typedef struct {
  unsigned long value;       /* value for macroblock_address_increment */
  long num_bits;             /* length of the Huffman code */
} mb_addr_inc_entry;

mb_addr_inc_entry mb_addr_inc[2048];

#define MACRO_BLOCK_STUFFING 34
#define MACRO_BLOCK_ESCAPE 35

/* Macro for filling up the decoding table for mb_addr_inc */
#define ASSIGN1(start, end, step, val, num) \
  for (i = start; i < end; i+= step) { \
    for (j = 0; j < step; j++) { \
      mb_addr_inc[i+j].value = val; \
      mb_addr_inc[i+j].num_bits = num; \
    } \
    val--; \
    }


void init_mb_addr_inc()
{
  int i, j, val;

  for (i = 0; i < 8; i++) {
    mb_addr_inc[i].value = ERROR;
    mb_addr_inc[i].num_bits = 0;
  }

  mb_addr_inc[8].value = MACRO_BLOCK_ESCAPE;
  mb_addr_inc[8].num_bits = 11;

  for (i = 9; i < 15; i++) {
    mb_addr_inc[i].value = ERROR;
    mb_addr_inc[i].num_bits = 0;
  }

  mb_addr_inc[15].value = MACRO_BLOCK_STUFFING;
  mb_addr_inc[15].num_bits = 11;

  for (i = 16; i < 24; i++) {
    mb_addr_inc[i].value = ERROR;
    mb_addr_inc[i].num_bits = 0;
  }

  val = 33;

  ASSIGN1(24, 36, 1, val, 11);
  ASSIGN1(36, 48, 2, val, 10);
  ASSIGN1(48, 96, 8, val, 8);
  ASSIGN1(96, 128, 16, val, 7);
  ASSIGN1(128, 256, 64, val, 5);
  ASSIGN1(256, 512, 128, val, 4);
  ASSIGN1(512, 1024, 256, val, 3);
  ASSIGN1(1024, 2048, 1024, val, 1);
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


