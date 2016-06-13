/****************************************************************
 * abrun.c
 ****************************************************************/

/******
  Copyright (C) 1995,1996 by Klaus Ehrenfried. 

  Permission to use, copy, modify, and distribute this software
  is hereby granted, provided that the above copyright notice appears 
  in all copies and that the software is available to all free of charge. 
  The author disclaims all warranties with regard to this software, 
  including all implied warranties of merchant-ability and fitness. 
  The code is simply distributed as it is.
*******/

#include <stdio.h>
#include <stdlib.h>
#include "apro.h"

#define MLOAD  1
#define MCONST 2

static int modus[FLI_MAX_X];
static int bingo[FLI_MAX_X];
static int val[FLI_MAX_X];

static int make_brun_line(unsigned char *image_line,
	unsigned char *brun_line);

/****************************************************************
 * make_brun_chunk
 ****************************************************************/

int
make_brun_chunk
(
UBYTE *image				/* first image */
)
{
    int chunk_count, j, help;
    unsigned char *brun_line;
    float compression;

    chunk_count=6;			/* 4 bytes for chunk size */
					/* 2 bytes for chunk type */
    for (j=0; j < fli_height; j++)
    {
	brun_line = &pixel_chunk_buffer[chunk_count];
	chunk_count += make_brun_line(image, brun_line);
	image += fli_width;
    }

    if ((chunk_count % 2) == 1)
	add_bytes(pixel_chunk_buffer, &chunk_count, 0x0000, IOM_UBYTE);

    help=0;
    add_bytes(pixel_chunk_buffer, &help, chunk_count, IOM_LONG);
    add_bytes(pixel_chunk_buffer, &help, FLI_BRUN, IOM_UWORD);

    compression=fli_size/((float)chunk_count);

    fprintf(stdout," Brun chunk: %d bytes    compression: %f\n",
    	chunk_count,compression);

    return(chunk_count);
}

/****************************************************************
 * test_const
 ****************************************************************/

static int test_const(int i)
{
  int j, len;

  j=i+1;
  len = 1;
  while (j < fli_width)
    {
      if (len >= 127) break;
      if (val[j] != val[i]) break;
      len++;
      j++;
    }
  return(len);
}

/****************************************************************
 * test_mload
 ****************************************************************/

static int test_mload(int i)
{
  int j, len;

  j=i+1;
  len = 1;
  while (j < fli_width)
    {
      if (len >= 127) break;
      if (modus[j] != MLOAD) break;
      len++;
      j++;
    }
  return(len);
}

/****************************************************************
 * test_packets
 ****************************************************************/

static int test_packets()
{
  int i, packets;

  packets=0;
  i=0;
  while (i < fli_width)
    {
      packets++;
      i += bingo[i];
    }

  return(packets);
}

/****************************************************************
 * merge_packets
 ****************************************************************/

static int merge_packets(int i)
{
  int j, jstart, jend;
  int sum;

  sum = bingo[i-1] + bingo[i];
  if (sum > 127) return(0);

  jstart = i - bingo[i-1];
  jend = i + bingo[i];
  for (j = jstart; j < jend; j++)
    {
      modus[j] = MLOAD;
      bingo[j] = sum;
    }
  /* printf("merge %d %d %d\n",i,jstart,jend); */
  return(1);
}

/****************************************************************
 * reduce_packets
 ****************************************************************/

static void reduce_packets()
{
  int i;

  i=bingo[0];
  while (i < fli_width)
    {
      if (merge_packets(i)) return;
      i += bingo[i];
    }
}

/****************************************************************
 * make_brun_line
 ****************************************************************/

static int make_brun_line
(
unsigned char *image_line,
unsigned char *brun_line
)
{
    int i, ipos, n, packets;
    int len, help;
    int inext;

    for (i=0; i < fli_width; i++)
        val[i]=image_line[i];

    i=0;
    while (i < fli_width)
      {
	len = test_const(i);
	if (len > 1)
	  {
	    for (n=0; n < len; n++)
	      {
		modus[i] = MCONST;
		bingo[i] = len;
		i++;
	      }
	  }
	else
	  {
	    modus[i] = MLOAD;
	    bingo[i] = 1;
	    i++;
	  }
      }

    i=0;
    while (i < fli_width)
      {
	if (modus[i] == MCONST)
	  {
	    i += bingo[i];
	  }
	else
	  {
	    len = test_mload(i);
	    for (n=0; n < len; n++)
	      {
		bingo[i] = len;
		i++;
	      }
	  }
      }

    i=bingo[0];
    while (i < fli_width)
      {
	inext = i + bingo[i];
	if ((((modus[i] == MCONST) && (bingo[i] <= 2)) || (modus[i] == MLOAD))
	    && (modus[i-1] == MLOAD)) merge_packets(i);
	i = inext;
      }

    i=fli_width - bingo[fli_width - 1];
    while (i > 0)
      {
	inext = i - bingo[i-1];
	if ((((modus[i-1] == MCONST) && (bingo[i-1] <= 2))
	     || (modus[i-1] == MLOAD)) && (modus[i] == MLOAD))
	  merge_packets(i);
	i = inext;
      }

    while (test_packets() > 255)
      {reduce_packets();}

    ipos=1;

    packets=0;
    i=0;
    while (i < fli_width)
    {
        len=bingo[i];
	/* fprintf(stdout," %d  %d\n",i,len); */

        if (modus[i] == MCONST)
        {
	  add_bytes(brun_line, &ipos, len, IOM_UBYTE);
	  add_bytes(brun_line, &ipos, val[i], IOM_UBYTE);
	  i += len;
        }
        else
        {
	  add_bytes(brun_line, &ipos, -len, IOM_UBYTE);
	  for (n=0; n < len; n++)
	    {
	      add_bytes(brun_line, &ipos, val[i++], IOM_UBYTE);
            }
	}
	packets++;
    }
    /* fprintf(stdout," packets: %d    ipos: %d\n\n",packets,ipos); */

    help=0;
    add_bytes(brun_line, &help, packets, IOM_UBYTE);

    return(ipos);
}

/* -- FIN -- */
