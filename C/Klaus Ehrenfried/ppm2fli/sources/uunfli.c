/****************************************************************
 * uunfli.c
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
#include <stdlib.h>
#include <string.h>

#include "upro.h"

#define COLOR_FLAG_64 2
#define COLOR_FLAG_256 0

static unsigned char palette[3 * MAXCOLORS];
static unsigned char *image_buffer;
static int image_height, image_width;

static int table_colors(unsigned char *pcc, int color_flag);
static int process_frame(unsigned char *pwork, int nchunks, int verbose);

static int get_ulong(unsigned char *lbuff)
{
  int value;

  value = lbuff[0] + 
    0x100 * (lbuff[1] + 0x100 * (lbuff[2] + 0x100 * lbuff[3]));
  return(value);
}

static int get_ushort(unsigned char *lbuff)
{
  int value;

  value = lbuff[0] + (0x100 * lbuff[1]);
  return(value);
}

int unfli
(
FILE *input, 
char *out_name_base, 
char *out_name_ext, 
int outtype,
int begin_frame, 
int max_frames,
int verbose,
int compress_flag
)
{
  unsigned char file_header[FILE_HEAD_SIZE];
  unsigned char frame_header[FRAME_HEAD_SIZE];
  unsigned char *frame_buffer;
  int buffer_len;
  int work_len;
  int file_len, file_type, frame_len, frame_type;
  int n, nframes;
  int last_frame, digits, help;
  int nchunks;

  if (fread(file_header, 1, FILE_HEAD_SIZE, input) != FILE_HEAD_SIZE)
    return(-1);

  file_len = get_ulong(&file_header[0]);
  if (verbose) fprintf(stdout,"Size of input file: %d\n", file_len);

  file_type = get_ushort(&file_header[4]);
  if (verbose) fprintf(stdout,"Type of input file: 0x%X\n", file_type);

  if (!((file_type == FLI_FILE_MAGIC) || (file_type == FLC_FILE_MAGIC)))
    {
      fprintf(stdout,"Unknown file type!\n");
      return(0);
    }

  nframes = get_ushort(&file_header[6]);
  image_width = get_ushort(&file_header[8]);
  image_height = get_ushort(&file_header[10]);
  if (verbose)
    {
      fprintf(stdout,"Number of frames: %d\n", nframes);
      fprintf(stdout,"Width:  %d\n", image_width);
      fprintf(stdout,"Height: %d\n", image_height);
    }

  buffer_len = image_width * image_height;

  frame_buffer = malloc(buffer_len);
  image_buffer = malloc(buffer_len);

  if ((frame_buffer == NULL) || (image_buffer == NULL))
    return(-2);

  memset(image_buffer, 0, buffer_len);
  memset(palette, 0, MAXCOLORS * 3);

  if (max_frames <= 0) max_frames = nframes;
  nframes++;

  if ((begin_frame < 1) || (begin_frame > nframes))
    {
      fprintf(stderr,"Begin frame-number %d out of range (1 .... %d)\n",
	      begin_frame, nframes);
      return(0);
    }

  last_frame = begin_frame + max_frames - 1;

  if (last_frame > nframes) last_frame = nframes;

  help = nframes;
  digits=0;
  while (help > 0)
    {
      help = (help - (help % 10))/10;
      digits++;
    }
  if (digits < 3) digits = 3;

  if (last_frame == begin_frame)
    fprintf(stdout,"Extracting frame %d\n",begin_frame);
  else
    fprintf(stdout,"Extracting frames from %d to %d\n",
	    begin_frame, last_frame);

  for (n = 1; n <= nframes; n++)
    {
      if (n > last_frame) break;

      if (fread(frame_header, 1, FRAME_HEAD_SIZE, input) != FRAME_HEAD_SIZE)
	return(-1);
      frame_len = get_ulong(&frame_header[0]);
      if (verbose)
	fprintf(stdout,"Frame %d  --  size: %d\n", n, frame_len);

      frame_type = get_ushort(&frame_header[4]);
      if (frame_type != FLI_FRAME_MAGIC)
	{
	  fprintf(stderr,"Invalid frame type: 0x%X\n", frame_type);
	  return(0);
	}

      work_len = frame_len - FRAME_HEAD_SIZE;
      if (work_len > 0)
	{
	  if (buffer_len < work_len)
	    {
	      free(frame_buffer);
	      buffer_len = work_len;
	      frame_buffer = malloc(buffer_len);
	      if (frame_buffer == NULL) return(-2);
	    }
      
	  if (fread(frame_buffer, 1, work_len, input) != work_len) return(-1);
	  nchunks = get_ushort(&frame_header[6]);
	  process_frame(frame_buffer, nchunks, verbose);
	}

      if (n >= begin_frame)
	{
	  if (!out_image(image_buffer,palette,image_width,image_height,
		       outtype,out_name_base,out_name_ext,digits,n,
		       compress_flag))
	    return(0);
	}
    }

  return(1);
}

/* ---------------------------------------------------------------- */
static int table_colors(unsigned char *pcc, int color_flag)
{
    int packets;
    int i, n, ic;
    int change;
    int skip;
    unsigned char red, green, blue;
    unsigned char by0,by1;

    by0=*(pcc++);
    by1=*(pcc++);

    packets=by0+256*by1;

    ic=0;

    for (i=0; i<packets; i++)
    {
	skip=(unsigned char) *(pcc++);
	ic += skip;
	ic = ic % MAXCOLORS;

	change=(unsigned char) *(pcc++);
	if (change == 0) change=256;

	for (n=0; n < change; n++)
	{
	    red = (*(pcc++)) << color_flag;
	    green = (*(pcc++)) << color_flag;
	    blue = (*(pcc++)) << color_flag;
	    palette[ic] = red;
	    palette[ic + MAXCOLORS] = green;
	    palette[ic + 2*MAXCOLORS] = blue;
	    ic++;
	}
    }

    return(1);
}

/****************************************************************
 * process_frame
 ****************************************************************/

static int process_frame(unsigned char *pwork, int nchunks, int verbose)
{
  unsigned char *pmchunk;
  unsigned long chunk_size;
  int i, chunk_type;

  for (i=0; i< nchunks; i++)
    {
      chunk_size = get_ulong(&pwork[0]);
      chunk_type = get_ushort(&pwork[4]);

      pmchunk = pwork + CHUNK_HEAD_SIZE;
      if (verbose)
	fprintf(stdout,"chunk %d of type 0x%X and size %ld\n",
		i,chunk_type,chunk_size);

      if (chunk_type == FLI_COLOR)
	{
	  table_colors(pmchunk, COLOR_FLAG_64);
	}
      else if (chunk_type == FLI_256_COLOR)
	{
	  table_colors(pmchunk, COLOR_FLAG_256);
	}
      else if (chunk_type == FLI_DELTA)
	{
	  buffer_delta_chunk(pmchunk, image_buffer, 
			     image_height, image_width);
	}
      else if (chunk_type == FLI_LC)
	{
	  buffer_lc_chunk(pmchunk, image_buffer,
			  image_height, image_width);
	}
      else if (chunk_type == FLI_BRUN)
	{
	  buffer_brun_chunk(pmchunk, image_buffer,
			    image_height, image_width);
	}
      else
	{
	  fprintf(stderr,"unknown chunk type 0x%X -- chunk ignored\n",
		  chunk_type);
	}
      pwork += chunk_size;
    }

  return(1);
}
