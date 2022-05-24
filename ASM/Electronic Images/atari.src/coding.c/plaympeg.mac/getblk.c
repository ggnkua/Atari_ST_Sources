/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plaympeg.h"

DCTtab_padded huff_first[65536l];
DCTtab_padded huff_next[65536l];
mb_addr_inc_entry mb_addr_inc[2048];
mv_tab motion_vectors[2048];

/* Table B-14, DCT coefficients table zero,
 * codes 0100 ... 1xxx (used for first (DC) coefficient)
 */
DCTtab DCTtabfirst[12] =
{
  {0,2,4}, {2,1,4}, {1,1,3}, {1,1,3},
  {0,1,1}, {0,1,1}, {0,1,1}, {0,1,1},
  {0,1,1}, {0,1,1}, {0,1,1}, {0,1,1}
};

/* Table B-14, DCT coefficients table zero,
 * codes 0100 ... 1xxx (used for all other coefficients)
 */
DCTtab DCTtabnext[12] =
{
  {0,2,4},  {2,1,4},  {1,1,3},  {1,1,3},
  {64,0,2}, {64,0,2}, {64,0,2}, {64,0,2}, /* EOB */
  {0,1,2},  {0,1,2},  {0,1,2},  {0,1,2}
};

/* Table B-14, DCT coefficients table zero,
 * codes 000001xx ... 00111xxx
 */
DCTtab DCTtab0[60] =
{
  {65,0,6}, {65,0,6}, {65,0,6}, {65,0,6}, /* Escape */
  {2,2,7}, {2,2,7}, {9,1,7}, {9,1,7},
  {0,4,7}, {0,4,7}, {8,1,7}, {8,1,7},
  {7,1,6}, {7,1,6}, {7,1,6}, {7,1,6},
  {6,1,6}, {6,1,6}, {6,1,6}, {6,1,6},
  {1,2,6}, {1,2,6}, {1,2,6}, {1,2,6},
  {5,1,6}, {5,1,6}, {5,1,6}, {5,1,6},
  {13,1,8}, {0,6,8}, {12,1,8}, {11,1,8},
  {3,2,8}, {1,3,8}, {0,5,8}, {10,1,8},
  {0,3,5}, {0,3,5}, {0,3,5}, {0,3,5},
  {0,3,5}, {0,3,5}, {0,3,5}, {0,3,5},
  {4,1,5}, {4,1,5}, {4,1,5}, {4,1,5},
  {4,1,5}, {4,1,5}, {4,1,5}, {4,1,5},
  {3,1,5}, {3,1,5}, {3,1,5}, {3,1,5},
  {3,1,5}, {3,1,5}, {3,1,5}, {3,1,5}
};

/* Table B-15, DCT coefficients table one,
 * codes 000001xx ... 11111111
*/
DCTtab DCTtab0a[252] =
{
  {65,0,6}, {65,0,6}, {65,0,6}, {65,0,6}, /* Escape */
  {7,1,7}, {7,1,7}, {8,1,7}, {8,1,7},
  {6,1,7}, {6,1,7}, {2,2,7}, {2,2,7},
  {0,7,6}, {0,7,6}, {0,7,6}, {0,7,6},
  {0,6,6}, {0,6,6}, {0,6,6}, {0,6,6},
  {4,1,6}, {4,1,6}, {4,1,6}, {4,1,6},
  {5,1,6}, {5,1,6}, {5,1,6}, {5,1,6},
  {1,5,8}, {11,1,8}, {0,11,8}, {0,10,8},
  {13,1,8}, {12,1,8}, {3,2,8}, {1,4,8},
  {2,1,5}, {2,1,5}, {2,1,5}, {2,1,5},
  {2,1,5}, {2,1,5}, {2,1,5}, {2,1,5},
  {1,2,5}, {1,2,5}, {1,2,5}, {1,2,5},
  {1,2,5}, {1,2,5}, {1,2,5}, {1,2,5},
  {3,1,5}, {3,1,5}, {3,1,5}, {3,1,5},
  {3,1,5}, {3,1,5}, {3,1,5}, {3,1,5},
  {1,1,3}, {1,1,3}, {1,1,3}, {1,1,3},
  {1,1,3}, {1,1,3}, {1,1,3}, {1,1,3},
  {1,1,3}, {1,1,3}, {1,1,3}, {1,1,3},
  {1,1,3}, {1,1,3}, {1,1,3}, {1,1,3},
  {1,1,3}, {1,1,3}, {1,1,3}, {1,1,3},
  {1,1,3}, {1,1,3}, {1,1,3}, {1,1,3},
  {1,1,3}, {1,1,3}, {1,1,3}, {1,1,3},
  {1,1,3}, {1,1,3}, {1,1,3}, {1,1,3},
  {64,0,4}, {64,0,4}, {64,0,4}, {64,0,4}, /* EOB */
  {64,0,4}, {64,0,4}, {64,0,4}, {64,0,4},
  {64,0,4}, {64,0,4}, {64,0,4}, {64,0,4},
  {64,0,4}, {64,0,4}, {64,0,4}, {64,0,4},
  {0,3,4}, {0,3,4}, {0,3,4}, {0,3,4},
  {0,3,4}, {0,3,4}, {0,3,4}, {0,3,4},
  {0,3,4}, {0,3,4}, {0,3,4}, {0,3,4},
  {0,3,4}, {0,3,4}, {0,3,4}, {0,3,4},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,1,2}, {0,1,2}, {0,1,2}, {0,1,2},
  {0,2,3}, {0,2,3}, {0,2,3}, {0,2,3},
  {0,2,3}, {0,2,3}, {0,2,3}, {0,2,3},
  {0,2,3}, {0,2,3}, {0,2,3}, {0,2,3},
  {0,2,3}, {0,2,3}, {0,2,3}, {0,2,3},
  {0,2,3}, {0,2,3}, {0,2,3}, {0,2,3},
  {0,2,3}, {0,2,3}, {0,2,3}, {0,2,3},
  {0,2,3}, {0,2,3}, {0,2,3}, {0,2,3},
  {0,2,3}, {0,2,3}, {0,2,3}, {0,2,3},
  {0,4,5}, {0,4,5}, {0,4,5}, {0,4,5},
  {0,4,5}, {0,4,5}, {0,4,5}, {0,4,5},
  {0,5,5}, {0,5,5}, {0,5,5}, {0,5,5},
  {0,5,5}, {0,5,5}, {0,5,5}, {0,5,5},
  {9,1,7}, {9,1,7}, {1,3,7}, {1,3,7},
  {10,1,7}, {10,1,7}, {0,8,7}, {0,8,7},
  {0,9,7}, {0,9,7}, {0,12,8}, {0,13,8},
  {2,3,8}, {4,2,8}, {0,14,8}, {0,15,8}
};

/* Table B-14, DCT coefficients table zero,
 * codes 0000001000 ... 0000001111
 */
DCTtab DCTtab1[8] =
{
  {16,1,10}, {5,2,10}, {0,7,10}, {2,3,10},
  {1,4,10}, {15,1,10}, {14,1,10}, {4,2,10}
};

/* Table B-15, DCT coefficients table one,
 * codes 000000100x ... 000000111x
 */
DCTtab DCTtab1a[8] =
{
  {5,2,9}, {5,2,9}, {14,1,9}, {14,1,9},
  {2,4,10}, {16,1,10}, {15,1,9}, {15,1,9}
};

/* Table B-14/15, DCT coefficients table zero / one,
 * codes 000000010000 ... 000000011111
 */
DCTtab DCTtab2[16] =
{
  {0,11,12}, {8,2,12}, {4,3,12}, {0,10,12},
  {2,4,12}, {7,2,12}, {21,1,12}, {20,1,12},
  {0,9,12}, {19,1,12}, {18,1,12}, {1,5,12},
  {3,3,12}, {0,8,12}, {6,2,12}, {17,1,12}
};

/* Table B-14/15, DCT coefficients table zero / one,
 * codes 0000000010000 ... 0000000011111
 */
DCTtab DCTtab3[16] =
{
  {10,2,13}, {9,2,13}, {5,3,13}, {3,4,13},
  {2,5,13}, {1,7,13}, {1,6,13}, {0,15,13},
  {0,14,13}, {0,13,13}, {0,12,13}, {26,1,13},
  {25,1,13}, {24,1,13}, {23,1,13}, {22,1,13}
};

/* Table B-14/15, DCT coefficients table zero / one,
 * codes 00000000010000 ... 00000000011111
 */
DCTtab DCTtab4[16] =
{
  {0,31,14}, {0,30,14}, {0,29,14}, {0,28,14},
  {0,27,14}, {0,26,14}, {0,25,14}, {0,24,14},
  {0,23,14}, {0,22,14}, {0,21,14}, {0,20,14},
  {0,19,14}, {0,18,14}, {0,17,14}, {0,16,14}
};

/* Table B-14/15, DCT coefficients table zero / one,
 * codes 000000000010000 ... 000000000011111
 */
DCTtab DCTtab5[16] =
{
  {0,40,15}, {0,39,15}, {0,38,15}, {0,37,15},
  {0,36,15}, {0,35,15}, {0,34,15}, {0,33,15},
  {0,32,15}, {1,14,15}, {1,13,15}, {1,12,15},
  {1,11,15}, {1,10,15}, {1,9,15}, {1,8,15}
};

/* Table B-14/15, DCT coefficients table zero / one,
 * codes 0000000000010000 ... 0000000000011111
 */
DCTtab DCTtab6[16] =
{
  {1,18,16}, {1,17,16}, {1,16,16}, {1,15,16},
  {6,3,16}, {16,2,16}, {15,2,16}, {14,2,16},
  {13,2,16}, {12,2,16}, {11,2,16}, {31,1,16},
  {30,1,16}, {29,1,16}, {28,1,16}, {27,1,16}
};

VLCtab PMBtab[64] = {
  {ERROR,0},
  {MB_QUANT|MB_INTRA,6},
  {MB_QUANT|MB_PATTERN,5}, {MB_QUANT|MB_PATTERN,5},
  {MB_QUANT|MB_FORWARD|MB_PATTERN,5}, {MB_QUANT|MB_FORWARD|MB_PATTERN,5},
  {MB_INTRA,5}, {MB_INTRA,5},

  {MB_FORWARD,3},{MB_FORWARD,3},{MB_FORWARD,3},{MB_FORWARD,3},
  {MB_FORWARD,3},{MB_FORWARD,3},{MB_FORWARD,3},{MB_FORWARD,3},

  {MB_PATTERN,2},{MB_PATTERN,2},{MB_PATTERN,2},{MB_PATTERN,2},
  {MB_PATTERN,2},{MB_PATTERN,2},{MB_PATTERN,2},{MB_PATTERN,2},

  {MB_PATTERN,2},{MB_PATTERN,2},{MB_PATTERN,2},{MB_PATTERN,2},
  {MB_PATTERN,2},{MB_PATTERN,2},{MB_PATTERN,2},{MB_PATTERN,2},

  {MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},
  {MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},

  {MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},
  {MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},

  {MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},
  {MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},

  {MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},
  {MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1},{MB_FORWARD|MB_PATTERN,1}

};


VLCtab BMBtab[64] = {
  {ERROR,0},
  {MB_QUANT|MB_INTRA,6},
  {MB_QUANT|MB_BACKWARD|MB_PATTERN,6},
  {MB_QUANT|MB_FORWARD|MB_PATTERN,6},
  {MB_QUANT|MB_FORWARD|MB_BACKWARD|MB_PATTERN,5},{MB_QUANT|MB_FORWARD|MB_BACKWARD|MB_PATTERN,5},
  {MB_INTRA,5}, {MB_INTRA,5},

  {MB_FORWARD,4}, {MB_FORWARD,4}, {MB_FORWARD,4}, {MB_FORWARD,4},

  {MB_FORWARD|MB_PATTERN,4},{MB_FORWARD|MB_PATTERN,4}, {MB_FORWARD|MB_PATTERN,4}, {MB_FORWARD|MB_PATTERN,4},

  {MB_BACKWARD,3},{MB_BACKWARD,3},{MB_BACKWARD,3},{MB_BACKWARD,3},
  {MB_BACKWARD,3},{MB_BACKWARD,3},{MB_BACKWARD,3},{MB_BACKWARD,3},

  {MB_BACKWARD|MB_PATTERN,3}, {MB_BACKWARD|MB_PATTERN,3}, {MB_BACKWARD|MB_PATTERN,3}, {MB_BACKWARD|MB_PATTERN,3},
  {MB_BACKWARD|MB_PATTERN,3}, {MB_BACKWARD|MB_PATTERN,3}, {MB_BACKWARD|MB_PATTERN,3}, {MB_BACKWARD|MB_PATTERN,3},

  {MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},{MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},
  {MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},{MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},
  {MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},{MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},
  {MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},{MB_FORWARD|MB_BACKWARD,2}, {MB_FORWARD|MB_BACKWARD,2},

  {MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},
  {MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},
  {MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},
  {MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},{MB_FORWARD|MB_BACKWARD|MB_PATTERN,2},
  
};





void init_getblk(void)
{	unsigned long code,fault;

	/* make intra table */

   	for (code = 0 ; code < 65536 ; code++)
	{	DCTtab *tab;
		fault = 0;
		if (code>=16384)
    		tab = &DCTtabfirst[(code>>12)-4];
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
			huff_first[code].len = tab->len;
			huff_first[code].run = tab->run;
			huff_first[code].level = tab->level;
		} 
		else			
		{	huff_first[code].run = 64; /* EOB */
			huff_first[code].len = 1;
			huff_first[code].level = 0;
		}
		  		
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
			huff_next[code].len = tab->len;
			huff_next[code].run = tab->run;
			huff_next[code].level = tab->level;
		} 
		else			
		{	huff_next[code].run = 64; /* EOB */
			huff_next[code].len = 1;
			huff_next[code].level = 0;
		}
		
	}

}

/*
 *	Initialize the VLC decoding table for macro_block_address_increment
 */

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


void init_mb_addr_inc(void)
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

/* Macro for filling up the decoding tables for motion_vectors */
#define ASSIGN3(start, end, step, val, num) \
  for (i = start; i < end; i+= step) { \
    for (j = 0; j < step / 2; j++) { \
      motion_vectors[i+j].code = val; \
      motion_vectors[i+j].num_bits = num; \
    } \
    for (j = step / 2; j < step; j++) { \
      motion_vectors[i+j].code = -val; \
      motion_vectors[i+j].num_bits = num; \
    } \
    val--; \
  }


void init_mv_table(void)
{
  int i, j, val = 16;

  for (i = 0; i < 24; i++) {
    motion_vectors[i].code = ERROR;
    motion_vectors[i].num_bits = 0;
  }

  ASSIGN3(24, 36, 2, val, 11);
  ASSIGN3(36, 48, 4, val, 10);
  ASSIGN3(48, 96, 16, val, 8);
  ASSIGN3(96, 128, 32, val, 7);
  ASSIGN3(128, 256, 128, val, 5);
  ASSIGN3(256, 512, 256, val, 4);
  ASSIGN3(512, 1024, 512, val, 3);
  ASSIGN3(1024, 2048, 1024, val, 1);
}

