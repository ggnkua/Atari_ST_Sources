/****************************************************************
 * aimage.c
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
#include <memory.h>
#include <stdlib.h>

#include "apro.h"

static void remap_image(UBYTE *pp, LONG color[], int len, int ncolor);

/****************************************************************
 * get_image
 ****************************************************************/

void get_image(char *fname,UBYTE *data,LONG color_table[])
{
  PMS image;					/* Image */
  UBYTE *run_pp, *pdest, *psource, *raw_data;
  LONG rgb_value;
  int i, j, len, used_count, nhelp, image_width, ncolor;
  int idstart, idend, jdstart, jdend, isstart, jsstart;
  int x_origin, y_origin;
  int histogram[FLI_MAX_COLORS];

  fprintf(stdout,"Load '%s'\n",fname);
  image.pixels = (unsigned char *) NULL;
  if (!read_image(&image, fname))
    {
      fprintf(stderr,"error reading '%s'\n",fname);
      exitialise(1);
      exit(1);
    }

  if (individual_flag)
    {
      clear_octree();
      add_to_large_octree(&image);
      prepare_quantize();
    }

  raw_data=malloc(image.len);
  if (raw_data == NULL)
    {
      fprintf(stderr,"error allocating %d bytes\n",image.len);
      exitialise(1);
      exit(1);
    }

  ncolor=clr_quantize(&image, raw_data, color_table);

  image_width = image.width;
  run_pp = raw_data;

  /* compute histogram */
  for (j=0; j < FLI_MAX_COLORS; j++) histogram[j]=0;

  if (individual_flag)
    remap_image(raw_data, color_table, image.len, ncolor);

  if (border_color == 0)
    {
      for (i=0; i < image.len; i++)
	histogram[*(run_pp++)]++;
    }
  else
    {
      rgb_value=color_table[0];
      color_table[0]=color_table[border_color];
      color_table[border_color]=rgb_value;

      for (i=0; i < image.len; i++)
	{
	  if (*run_pp == 0)
	    *run_pp = (UBYTE)  border_color;
	  else if (*run_pp == border_color)
	    *run_pp = (UBYTE) 0;

	  histogram[*(run_pp++)]++;
	}
    }

  used_count=0;
  for (j=0; j < FLI_MAX_COLORS; j++)
    {
      if (histogram[j] > 0) used_count++;
    }

  if (verbose_flag > 0)
    {
      fprintf(stdout," %d color(s) used\n",used_count);
    }

  memset(data, 0, fli_size);

  if (Xorigin_flag == 1)
    {
      x_origin = Xorigin;
    }
  else if (Xorigin_flag == 2)
    {
      x_origin = fli_width - Xorigin - image.width;
    }
  else
    {
      nhelp=fli_width - image.width;
      x_origin = nhelp/2;
    }

  if (x_origin >= 0)
    {
      idstart = x_origin;
      isstart = 0;
    }
  else
    {
      idstart = 0;
      isstart = -x_origin;
    }
  nhelp = x_origin + image.width;
  idend = (nhelp < fli_width) ? nhelp : fli_width;

  if (Yorigin_flag == 1)
    {
      y_origin = Yorigin;
    }
  else if (Yorigin_flag == 2)
    {
      y_origin = fli_height - Yorigin - image.height;
    }
  else
    {
      nhelp=fli_height - image.height;
      y_origin = nhelp/2;
    }

  if (y_origin >= 0)
    {
      jdstart = y_origin;
      jsstart = 0;
    }
  else
    {
      jdstart = 0;
      jsstart = -y_origin;
    }
  nhelp = y_origin + image.height;
  jdend = (nhelp < fli_height) ? nhelp : fli_height;

  psource = raw_data + (jsstart * image_width + isstart);
  pdest = data + (jdstart * fli_width + idstart);

  len = idend - idstart;

  if (len > 0)
    {
      for (j=jdstart; j < jdend; j++)
	{
	  memcpy(pdest, psource, len);
	  psource += image_width;
	  pdest += fli_width;
	}
    }

  free_pms(&image);
  free(raw_data);
}

/****************************************************************
 * remap_image
 ****************************************************************/

static void remap_image(UBYTE *pp, LONG color[], int len, int ncolor)
{
  int occ[FLI_MAX_COLORS];
  int map[FLI_MAX_COLORS];
  int i,j,bingo,free_max;

  for (j = 0; j < FLI_MAX_COLORS; j++) occ[j] = 0;

  /* check if in previous table */

  /* fprintf(stdout,"(1)\n"); */
  for (i = 0; i < ncolor; i++)
    {
      map[i] = -1;
      for (j = 0; j < FLI_MAX_COLORS; j++)
	{
	  if (color[i] == mem_color[j])
	    {
	      map[i] = j;
	      occ[j] = 1;
	      /* fprintf(stdout," %3d",j); */
	      break;
	    }
	}
    }

  /* take the most free entry */

  /* fprintf(stdout,"\n(2)\n"); */
  for (i = 0; i < ncolor; i++)
    {
      if (map[i] != -1) continue;
      bingo = -1;
      free_max = -1;
      for (j = 0; j < FLI_MAX_COLORS; j++)
	{
	  if (occ[j] == 0)
	    {
	      if (free_count[j] > free_max)
		{
		  bingo = j;
		  free_max = free_count[j];
		}
	    }
	}
      if (bingo == -1)
	{
	  fprintf(stderr,"Error remapping image\n");
	  exitialise(1);
	  exit(1);
	}
      map[i] = bingo;
      occ[bingo] = 1;
      /* fprintf(stdout," %3d",bingo); */
    }
  /* fprintf(stdout,"\n"); */

  for (i=0; i < len; i++)
    {
      *pp = map[*pp];
      pp++;
    }

  for (j = 0; j < ncolor; j++) mem_color[map[j]] = color[j];

  for (j = 0; j < FLI_MAX_COLORS; j++)
    {
      color[j] = mem_color[j];
      if (occ[j] == 0)
	{
	  free_count[j]++;
	}
      else
	{
	  free_count[j] = 0;
	}
    }
}

/* -- FIN -- */
