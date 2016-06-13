/****************************************************************
 * adelta.c
 ****************************************************************/

/******
  Copyright (C) 1995 by Klaus Ehrenfried. 

  Permission to use, copy, modify, and distribute this software
  is hereby granted, provided that the above copyright notice appears 
  in all copies and that the software is available to all free of charge. 
  The author disclaims all warranties with regard to this software, 
  including all implied warranties of merchant-ability and fitness. 
  The code is simply distributed as it is.
*******/

#include <stdio.h>
#include "apro.h"

static int change[FLI_MAX_X];
static int val[FLI_MAX_X];
static int work[FLI_MAX_X];

int
make_delta_line
(
unsigned char *preprevious_line,
unsigned char *previous_line,
unsigned char *current_line,
unsigned char *delta_line,
int line_skip_count
);

static int improve_delta_line();
static int test_delta_skip();

static int new_pixels;
static int merge_count;

/****************************************************************
 * make_delta_chunk
 ****************************************************************/

int
make_delta_chunk
(
unsigned char *preprevious,			/* pre previous image */
unsigned char *previous,			/* previous image */
unsigned char *current				/* current image */
)
{
    int skip_count;
    unsigned char *delta_line;
    int chunk_count, line_count;
    int j, line_size, help;
    float change_factor;

    new_pixels=0;
    chunk_count=8;		/* 4 bytes for total size of chunk (header)*/
				/* 2 bytes for chunk type (header)*/
				/* 2 bytes for number of compressed lines */

    skip_count=0;
    line_count=0;

    for (j=0; j < fli_height; j++)
    {
	delta_line = &pixel_chunk_buffer[chunk_count];

	/* printf(" Line: %d   chunk_count: %d   skip: %d\n",
					j,chunk_count,skip_count); */

	line_size = make_delta_line(preprevious, previous, current, 
			delta_line, skip_count);

	preprevious += fli_width;
	previous += fli_width;
	current += fli_width;

	/* printf(" Line: %d  size: %d\n",j,line_size); */

	if (line_size > 0)			/* yes, we got a new line */
	{
	    chunk_count += line_size;
	    skip_count=0;
	    line_count++;
	}
	else
	{
	    skip_count--;
	}
    }

    if (line_count == 0)		/* no lines no chunk */
	return(0);

    if ((chunk_count % 2) == 1)
	add_bytes(pixel_chunk_buffer, &chunk_count, 0x0000, IOM_UBYTE);

    help=0;
    add_bytes(pixel_chunk_buffer, &help, chunk_count, IOM_LONG);
    add_bytes(pixel_chunk_buffer, &help, FLI_DELTA, IOM_UWORD);
    add_bytes(pixel_chunk_buffer, &help, line_count, IOM_UWORD);

    change_factor=100.0*((float)new_pixels)/(fli_width*fli_height);

    fprintf(stdout," Delta chunk: %d bytes    new pixels: %.2f %%\n",
    	chunk_count,change_factor);

    return(chunk_count);
}

/****************************************************************
 * make_delta_line
 ****************************************************************/

int
make_delta_line
(
unsigned char *preprevious_line,
unsigned char *previous_line,
unsigned char *current_line,
unsigned char *delta_line,
int line_skip_count
)
{
  int skip_count, size_count, packets;
  int i, m, ipos, help, ch_flag;

  ch_flag=0;
  for (i=0; i < fli_width; i++)
    {
      val[i]=current_line[i];
      if ((previous_line[i] != current_line[i]) ||
	  ((double_buffer == 1) && (preprevious_line[i] != current_line[i])))
	{
	  change[i]=1;			/* yes, update */
	  ch_flag=1;
	}
      else
	{
	  change[i]=0;			/* no update */
	}
    }

  if (ch_flag == 0) return(0);

  if ((change[fli_width-2] != 0) || (change[fli_width-1] != 0))
    {
      work[fli_width-2]=1;
      new_pixels += 2;
    }
  else
    {
      work[fli_width-2]=0;
    }
  work[fli_width-1]=0;

  for (i=(fli_width-4); i >= 0; i -= 2)
    {
      if ((change[i] != 0) || (change[i+1] != 0))
	{
	  new_pixels += 2;
	  if ((val[i] == val[i+2]) && (val[i+1] == val[i+3]))
	    {
	      if (work[i+2] < 0)
		{
		  work[i]=work[i+2]-1;
		  if (work[i] < -127) work[i]=-1;
		}
	      else if (work[i+2] == 0)
		{
		  work[i]=1;
		}
	      else
		{
		  work[i+2]=-1;
		  work[i]=-2;
		}
	    }
	  else				/* count nonequal words */
	    {
	      if (work[i+2] > 0)
		{
		  work[i]=work[i+2]+1;
		  if (work[i] > 127) work[i]=1;
		}
	      else
		{
		  work[i]=1;
		}
	    }
	}
      else
	{
	  work[i]=0;
	}
      work[i+1]=0;
    }

  test_delta_skip();
  merge_count = 1;
  while (merge_count > 0)
    {
      merge_count=0;
      improve_delta_line();
    }

  packets=0;
  skip_count=0;
  i=0;
  if (line_skip_count != 0)
    ipos=4;
  else
    ipos=2;

  while (i < fli_width)				/* assemble output */
    {
      if (work[i] != 0)				/* add data packet */
	{
	  packets++;
	  size_count=work[i];
	  add_bytes(delta_line, &ipos, skip_count, IOM_UBYTE);
	  add_bytes(delta_line, &ipos, size_count, IOM_SBYTE);
	  if (size_count < 0)
	    {
	      m=i;
	      add_bytes(delta_line, &ipos, val[i], IOM_UBYTE);
	      add_bytes(delta_line, &ipos, val[i+1], IOM_UBYTE);
	      i -= 2*size_count;
	    }
	  else
	    {
	      for (m=0; m < size_count; m++)
		{
		  add_bytes(delta_line, &ipos, val[i++], IOM_UBYTE);
		  add_bytes(delta_line, &ipos, val[i++], IOM_UBYTE);
		}
	    }
	  skip_count=0;
	}
      else
	{
	  skip_count++;
	  i++;
	}
    }

  help=0;
  if (line_skip_count != 0)
    {
      add_bytes(delta_line, &help, line_skip_count, IOM_SWORD);
      add_bytes(delta_line, &help, packets, IOM_SWORD);
    }
  else
    {
      add_bytes(delta_line, &help, packets, IOM_SWORD);
    }

  return(ipos);				/* return number of bytes */
}

/****************************************************************
 * get_packet_start
 ****************************************************************/

static int get_packet_start(int i)
{
  int j,igo;

  igo=0;

  if (work[i] > 0)
    {
      for (j=i; j > 1; j -= 2)
	{
	  if (work[j-2] != work[j]+1)
	    {
	      igo=j;
	      break;
	    }
	}
    }
  else
    {
      for (j=i; j > 1; j -= 2)
	{
	  if (work[j-2] != work[j]-1)
	    {
	      igo=j;
	      break;
	    }
	}
    }

  return(igo);
}


/****************************************************************
 * merge_packets
 ****************************************************************/

static int merge_packets(int igo1, int igo2, int m)
{
  int j, len;

  len = (igo2-igo1)/2+1;
  if (len > 127) return(0);

  merge_count++;
  if (m == 1)
    for (j=igo2; j >= igo1; j -= 2) work[j] = m++;
  else if (m == -1)
    for (j=igo2; j >= igo1; j -= 2) work[j] = m--;

  return(m);
}

/****************************************************************
 * improve_delta_line
 ****************************************************************/

static int improve_delta_line()
{
  int i,igo1,igo2;

  for (i=0; i < fli_width-5; i += 2)                  /* | -1 |  0 | -N | */
    {
      if ((work[i] == -1) && (work[i+2] == 0) && (work[i+4] < 0) &&
	  (val[i] == val[i+2]) && (val[i] == val[i+4]) &&
	  (val[i+1] == val[i+3]) && (val[i+1] == val[i+5]))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+2-2*work[i+4];
	  merge_packets(igo1,igo2,-1);
	}
    }

  for (i=0; i < fli_width-8; i += 2)       /* | +1 | -3 | -2 | -1 | +N |*/
    {
      if ((work[i] == 1) && (work[i+2] == -3) && (work[i+8] > 0))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+6+2*work[i+8];
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-2; i += 2)                  /* | +1 | -2 | */
    {
      if ((work[i] == 1) && (work[i+2] == -2))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+4;
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-4; i += 2)               /* | XX | -2 | -1 | +N | */
    {
      if ((work[i] == -2) && (work[i+4] > 0) && 
	  ((i == 0) || work[i-2] != -3))
	{
	  igo1 = i;
	  igo2 = i+2+2*work[i+4];
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-4; i += 2)                  /* | +1 |  0 | +N | */
    {
      if ((work[i] == 1) && (work[i+2] == 0) && (work[i+4] > 0))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+2+2*work[i+4];
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-4; i += 2)                  /* | +1 | +N | */
    {
      if ((work[i] == 1) && (work[i+2] > 0))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+2*work[i+2];
	  merge_packets(igo1,igo2,1);
	}
    }

  return(1);
}

/****************************************************************
 * test_delta_skip
 ****************************************************************/

static int test_delta_skip()
{
  int i, iend, ic;

  iend=-1;
  for (i=fli_width-1; i >= 0; i--)
    if (work[i] != 0)
      {
	iend=i;
	break;
      }

  ic=0;
  for (i=0; i <= iend; i += 2)
    {
      if (work[i] == 0)
	{
	  ic += 2;
	  if (ic >= 256)
	    {
	      work[i]=1;
	      ic=0;
	    }
	}
      else
	ic=0;
    }

  return(iend);
}

