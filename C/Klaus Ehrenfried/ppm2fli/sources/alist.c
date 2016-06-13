/****************************************************************
 * alist.c
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
#include <memory.h>
#include <stdlib.h>
#include "apro.h"

#define MAXLEN 512

#define SEEK_SET 0

#define GET_IMAGE(X,Y) \
get_image(X, mframe[Y].pixels, mframe[Y].color);

#define READ_NAME \
if (!get_next_line(input, image_file_name, MAXLEN)) \
{ fprintf(stderr,"Can't read line %d again\n",line); return(-1);} \
line++;

static unsigned char file_header[FLI_FILE_HEADER_SIZE];

static ISS mframe[5];

/****************************************************************
 * make_fli
 ****************************************************************/

int make_fli()
{
  char image_file_name[MAXLEN];
  char mem_name[MAXLEN];
  int k, nof, help, line;
  int file_size, frame_size, frame_one_size;
  int read_flag;
  int i0,i1,i2;
  int ia,ib,ic;

  /* -- first test the list file -- */

  nof=-1;
  if (input != NULL)
    {
      fprintf(stdout,"Checking file list\n");
      for (k=0; k <= FLI_MAX_FRAMES; k++)
	{
	  if (! get_next_line(input, image_file_name, MAXLEN))
	    {
	      nof=k;
	      break;
	    }
	  if (check_exist(image_file_name) == 0)
	    {
	      fprintf(stderr,"Line %d: file '%s' not found\n",
		      (k+1),image_file_name);
	      return(-1);
	    }
	  strcpy(mem_name, image_file_name);
	}

      if (nof < 0)
	{
	  fprintf(stderr,"Too many image names in list file\n");
	  fprintf(stderr,"Maximum is %d\n",FLI_MAX_FRAMES);
	  return(-1);
	}
      else if (nof == 0)
	{
	  fprintf(stderr,"Can't read image any names from list file\n");
	  return(-1);
	}
      fprintf(stdout," %d images\n",nof);
      rewind(input);
    }

  /* -- generate octree -- */

  if (individual_flag == 1)
    {
      for (k=0; k < FLI_MAX_COLORS; k++)
	{
	  mem_color[k] = 0;
	  free_count[k] = 0;
	}
    }
  else if (map_color_flag == 0)
    {
      if (verbose_flag > 1)
	{
	  fprintf(stdout,"Generate color table ...\n");
	  fprintf(stdout,"Octree node limit: %d\n",node_limit);
	}
      clear_octree();

      line=1;
      for (k=0; k < nof; k++)
	{
	  READ_NAME;
	  scan_rgb_image(image_file_name);
	}
      rewind(input);
      prepare_quantize();
    }

  /* -- only write color table as ppm file: no fli file -- */

  if (write_pal_flag)
    return(output_palette());

  /* -- allocate memory -- */

  for (k=0; k < 5; k++)
    {
      mframe[k].pixels = malloc(fli_size);
      if (mframe[k].pixels == NULL)
	{
	  fprintf(stderr,"Can't allocate %d bytes\n",fli_size);
	  exitialise(1);
	  exit(1);
	}
    }

  /* -- read boundary frames -- */

  line=1;
  if (nof > 1)
    {
      if (use_next_flag == 0)
	{
	  GET_IMAGE(mem_name, 3);
	  READ_NAME;
	  GET_IMAGE(image_file_name, 4);
	  ia=4;
	}
      else
	{
	  READ_NAME;
	  GET_IMAGE(image_file_name, 3);
	  READ_NAME;
	  GET_IMAGE(image_file_name, 4);
	  ia=3;
	}
    }
  else
    {
      GET_IMAGE(mem_name, 3);
      ia=3;
    }
  
  /* -- write dummy header -- */

  fprintf(stdout,"Begin writing FLI\n");
  memset(&file_header, 0, FLI_FILE_HEADER_SIZE);

  if (fwrite(file_header, FLI_FILE_HEADER_SIZE, 1, output) != 1)
    {
      fprintf(stderr,"error writing file header\n");
      return(-1);
    }

  file_size=FLI_FILE_HEADER_SIZE;

  /* -- first frame -- */

  fprintf(stdout,"Frame one\n");
  frame_one_size=fli_write_frame(NULL, NULL, &mframe[ia]);
  if (frame_one_size == 0)
    {
      fprintf(stderr,"Error writing first frame\n");
      return(-1);
    }
  file_size += frame_one_size;

  /* -- loop -- */

  i1 = 3;
  i2 = 4;

  for (k=1; k <= nof; k++)
    {
      i0 = i1;
      i1 = i2;

      if (k == (nof-1))
	{
	  i2 = 3;
	  read_flag = 0;
	  fprintf(stdout,"Frame %d\n",(k+1));
	}
      else if (k == nof)
	{
	  if (nof == 1) { i0 = i1 = i2 = 3; } else { i2 = 4; }
	  read_flag = 0;
	  fprintf(stdout,"Close loop\n");
	}
      else
	{
	  if (i2 >= 2) { i2 = 0;} else { i2++; }
	  read_flag = 1;
	  fprintf(stdout,"Frame %d\n",(k+1));
	}

      if (read_flag)
	{
	  READ_NAME;
	  GET_IMAGE(image_file_name, i2);
	}

      if (use_next_flag == 0)
	{ ia = i0; ib = i1; ic = i2; }
      else
	{ ia = i2; ib = i0; ic = i1; }

      frame_size=fli_write_frame(&mframe[ia], &mframe[ib], &mframe[ic]);

      if (frame_size == 0)
	{
	  fprintf(stderr,"Error writing frame\n");
	  return(-1);
	}
      file_size += frame_size;
    }
  
  /* ..................... write actual header ......... */
  
  help=0;
  
  add_bytes(file_header, &help, file_size, IOM_LONG);
  if (old_format_flag == 1)
    add_bytes(file_header, &help, FLI_FILE_OLD_MAGIC, IOM_UWORD);
  else
    add_bytes(file_header, &help, FLI_FILE_MAGIC, IOM_UWORD);
  add_bytes(file_header, &help, nof, IOM_UWORD);
  add_bytes(file_header, &help, fli_width, IOM_UWORD);
  add_bytes(file_header, &help, fli_height, IOM_UWORD);
  add_bytes(file_header, &help, 0x0008, IOM_UWORD);
  add_bytes(file_header, &help, 0x0000, IOM_UWORD);
  add_bytes(file_header, &help, fli_speed, IOM_UWORD);
  
  help=0x0050;
  add_bytes(file_header, &help, 0x0080, IOM_LONG);
  add_bytes(file_header, &help, (0x0080+frame_one_size), IOM_LONG);

  if (fseek(output, 0L, SEEK_SET) != 0)
    {
      fprintf(stderr,"fseek error\n");
      return(-1);
    }

  if (fwrite(file_header, help, 1, output) != 1)
    {
      fprintf(stderr,"Write error\n");
      return(-1);
    }

  return(nof);
}

/****************************************************************
 * get_next_line
 ****************************************************************/

int get_next_line(FILE *fp, char buff[], int len)
{
  int c, i;
  
  i=0;
  while (1)
    {
      c=getc(fp);
      if (i < len) buff[i]=c;
      if ((c == '\n') || (c == EOF))
	{
	  if (i < len)
	    buff[i]='\0';
	  else
	    buff[len-1]='\0';
	  return(i);
	}
      i++;
    }
}

/*********** -- FIN -- *******************************************/
