/****************************************************************
 * alc.c
 ****************************************************************/

/******
  Copyright (C) 1993-1995 by Klaus Ehrenfried. 

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
make_lc_line
(
unsigned char *preprevious_line,
unsigned char *previous_line,
unsigned char *current_line,
unsigned char *lc_line,
int start_flag
);

static int improve_lc_line();
static int test_lc_skip();
static int test_lc_packets();

static int new_pixels;
static int merge_count;

/****************************************************************
 * make_lc_chunk
 ****************************************************************/

int
make_lc_chunk
(
unsigned char *preprevious,			/* pre previous image */
unsigned char *previous,			/* previous image */
unsigned char *current				/* current image */
)
{
  int skip_count, start_flag, last_mod;
  unsigned char *lc_line;
  int chunk_count, line_count;
  int j, line_size, help;
  float change_factor;

  new_pixels=0;
  chunk_count=10;		/* 4 bytes for total size of chunk (header)*/
				/* 2 bytes for chunk type (header)*/
				/* 2 bytes for number of skipped lines */
				/* 2 bytes for number of modified lines */

  skip_count=-1;
  last_mod=-1;
  start_flag=0;

  for (j=0; j < fli_height; j++)
    {
      lc_line = &pixel_chunk_buffer[chunk_count];
      line_size = make_lc_line(preprevious, previous, current, 
			       lc_line, start_flag);

      preprevious += fli_width;
      previous += fli_width;
      current += fli_width;

      if (line_size > 0)			/* yes, we got a new line */
	{
	  chunk_count += line_size;
	  if (skip_count == -1)
	    skip_count = j;
	  start_flag=1;
	}
      if (line_size > 1)
	last_mod = j;
    }

  if (last_mod == -1)		/* no lines no chunk */
    return(0);

  line_count=last_mod - skip_count + 1;

  if ((chunk_count % 2) == 1)
    add_bytes(pixel_chunk_buffer, &chunk_count, 0x0000, IOM_UBYTE);

  help=0;
  add_bytes(pixel_chunk_buffer, &help, chunk_count, IOM_LONG);
  add_bytes(pixel_chunk_buffer, &help, FLI_LC, IOM_UWORD);
  add_bytes(pixel_chunk_buffer, &help, skip_count, IOM_UWORD);
  add_bytes(pixel_chunk_buffer, &help, line_count, IOM_UWORD);

  change_factor=100.0*((float)new_pixels)/(fli_width*fli_height);

  fprintf(stdout," LC chunk: %d bytes    new pixels: %.2f %%\n",
	  chunk_count,change_factor);

  return(chunk_count);
}

/****************************************************************
 * make_lc_line
 ****************************************************************/

int
make_lc_line
(
unsigned char *preprevious_line,
unsigned char *previous_line,
unsigned char *current_line,
unsigned char *lc_line,
int start_flag
)
{
  int skip_count, size_count, packets;
  int i, m, ipos, help, ch_flag;

  ch_flag = 0;
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

  if (ch_flag == 0)
    {
      if (start_flag == 0)
	return(0);
      *lc_line = 0;
      return(1);
    }

  if (change[fli_width-1] != 0)
    {
      work[fli_width-1]=1;
      new_pixels++;
    }
  else
    {
      work[fli_width-1]=0;
    }

  for (i=(fli_width-2); i >= 0; i--)
    {
      if (change[i] != 0)
	{
	  new_pixels++;
	  if (val[i] == val[i+1])
	    {
	      if (work[i+1] < 0)
		{
		  work[i]=work[i+1]-1;
		  if (work[i] < -127) work[i]=-1;
		}
	      else if (work[i+1] == 0)
		{
		  work[i]=1;
		}
	      else
		{
		  work[i+1]=-1;
		  work[i]=-2;
		}
	    }
	  else				/* count nonequal bytes */
	    {
	      if (work[i+1] > 0)
		{
		  work[i]=work[i+1]+1;
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
    }

  test_lc_skip();
  merge_count = 1;
  while (merge_count > 0)
    {
      merge_count=0;
      improve_lc_line();
    }
  test_lc_packets();

  packets=0;
  skip_count=0;
  i=0;
  ipos=1;

  while (i < fli_width)				/* assemble output */
    {
      if (work[i] != 0)				/* add data packet */
	{
	  packets++;
	  size_count=work[i];
	  add_bytes(lc_line, &ipos, skip_count, IOM_UBYTE);
	  add_bytes(lc_line, &ipos, size_count, IOM_SBYTE);
	  if (size_count < 0)
	    {
	      m=i;
	      add_bytes(lc_line, &ipos, val[i], IOM_UBYTE);
	      i -= size_count;
	    }
	  else
	    {
	      for (m=0; m < size_count; m++)
		{
		  add_bytes(lc_line, &ipos, val[i++], IOM_UBYTE);
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

  /* printf("(%d %d) ",packets,ipos); */

  help=0;
  add_bytes(lc_line, &help, packets, IOM_UBYTE);

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
      for (j=i; j > 0; j--)
	{
	  if (work[j-1] != work[j]+1)
	    {
	      igo=j;
	      break;
	    }
	}
    }
  else
    {
      for (j=i; j > 0; j--)
	{
	  if (work[j-1] != work[j]-1)
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

  len = igo2-igo1+1;
  if (len > 127) return(0);

  merge_count++;

  if (m == 1)
    for (j=igo2; j >= igo1; j--) work[j] = m++;
  else if (m == -1)
    for (j=igo2; j >= igo1; j--) work[j] = m--;

  return(m);
}

/****************************************************************
 * improve_lc_line
 ****************************************************************/

static int improve_lc_line()
{
  int i,igo1,igo2;

  for (i=0; i < fli_width-1; i++)                  /* | +1 | -2 | */
    {                                              /* | +1 | -3 | */

      if ((work[i] == 1) && ((work[i+1] == -2) || (work[i+1] == -3)))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i-work[i+1];
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-2; i++)                  /* | XX | -2 | -1 | +N | */
    {
      if ((work[i] == -2) && (work[i+2] > 0) && 
	  ((i == 0) || (work[i-1] != -3)))
	{
	  igo1 = i;
	  igo2 = i+1+work[i+2];
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-3; i++)           /* | XX | -3 | -2 | -1 | +N | */
    {
      if ((work[i] == -3) && (work[i+3] > 0) &&
	  ((i == 0) || (work[i-1] != -4)))
	{
	  igo1 = i;
	  igo2 = i+2+work[i+3];
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-2; i++)                  /* | XX | -2 | -1 | -2 | */
    {
      if ((work[i] == -2) && (work[i+2] == -2) && 
	  ((i == 0) || work[i-1] != -3))
	{
	  igo1 = i;
	  igo2 = i+3;
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-2; i++)                  /* | +1 |  0 | +N | */
    {
      if ((work[i] == 1) && (work[i+1] == 0) && (work[i+2] > 0))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+1+work[i+2];
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-2; i++)                  /* | -1 |  0 | -N | */
    {
      if ((work[i] == -1) && (work[i+1] == 0) && (work[i+2] < 0) &&
	  (val[i] == val[i+1]) && (val[i] == val[i+2]))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+1-work[i+2];
	  merge_packets(igo1,igo2,-1);
	}
    }

  for (i=0; i < fli_width-3; i++)             /* | XX | -2 | -1 | 0 | +N | */
    {
      if ((work[i] == -2) && (work[i+2] == 0) && (work[i+3] > 0) &&
	  ((i == 0) || (work[i-1] != -3)))
	{
	  igo1=i;
	  igo2 = i+2+work[i+2];
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-2; i++)                  /* | +1 |  0 | -2 | */
    {
      if ((work[i] == 1) && (work[i+1] == 0) && (work[i+2] == -2))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+3;
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-3; i++)                  /* | +1 |  0 |  0 | +N | */
    {
      if ((work[i] == 1) && (work[i+1] == 0) &&
	  (work[i+2] == 0) && (work[i+3] > 0))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+2+work[i+2];
	  merge_packets(igo1,igo2,1);
	}
    }

  for (i=0; i < fli_width-3; i++)                  /* | -1 |  0 |  0 | -N | */
    {
      if ((work[i] == -1) && (work[i+1] == 0) &&
	  (work[i+2] == 0) && (work[i+3] < 0) &&
	  (val[i] == val[i+1]) && (val[i] == val[i+2]) &&
	  (val[i] == val[i+3]))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+2-work[i+2];
	  merge_packets(igo1,igo2,-1);
	}
    }

  for (i=0; i < fli_width-1; i++)                  /* | +1 | +N | */
    {
      if ((work[i] == 1) && (work[i+1] > 0))
	{
	  igo1 = get_packet_start(i);
	  igo2 = i+work[i+1];
	  merge_packets(igo1,igo2,1);
	}
    }

  return(1);
}

/****************************************************************
 * test_lc_skip
 ****************************************************************/

static int test_lc_skip()
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
  for (i=0; i <= iend; i++)
    {
      if (work[i] == 0)
	{
	  ic++;
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

/****************************************************************
 * test_lc_packets
 ****************************************************************/

static int test_lc_packets()
{
  int packets,i, igo1,igo2, istart,iend;

  packets=0;
  for (i = 0; i < fli_width; i++)
    if ((work[i] == 1) || (work[i] == -1)) packets++;
  if (packets < 256) return(packets);

  istart=0;
  iend=0;
  for (i=0; i < fli_width; i++)
    if (work[i] != 0)
      {
	istart=i;
	break;
      }

  for (i=fli_width-1; i >= 0; i--)
    if (work[i] != 0)
      {
	iend=i;
	break;
      }

  igo1=istart;
  while (igo1 <= iend)
    {
      igo2=i+125;
      if (igo2 > iend) igo2=iend;
      merge_packets(igo1,igo2,1);
      igo1=igo2+1;
    }

  return(-1);
}
