/****************************************************************
 * afbm.c
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
#include <memory.h>
#include <stdlib.h>

#include "apro.h"

#define MAXDIGITS 64
#define MAXSLEN 81

static int get_fbm_int(FILE *fp);
static int get_fbm_string(FILE *fp, char *string, int len);

static int planes, clrlen, plnlen;
static int bits, physbits, aspect, pix_len, rowlen;
static int width, height;
static char test[MAXSLEN];

/****************************************************************
 * get_fbm_header
 ****************************************************************/

static int get_fbm_header(FILE *fp)
{
  if ((width=get_fbm_int(fp)) < 0) return(0);
  if ((height=get_fbm_int(fp)) < 0) return(0);
  if ((planes=get_fbm_int(fp)) < 0) return(0);
  if ((bits=get_fbm_int(fp)) < 0) return(0);
  if ((physbits=get_fbm_int(fp)) < 0) return(0);
  if ((rowlen=get_fbm_int(fp)) < 0) return(0);
  if ((plnlen=get_fbm_int(fp)) < 0) return(0);
  if ((clrlen=get_fbm_int(fp)) < 0) return(0);
  if ((aspect=get_fbm_int(fp)) < 0) return(0);
  if (get_fbm_string(fp, test, 80) == 0) return(0);
  if (get_fbm_string(fp, test, 80) == 0) return(0);
  return(1);
}

/****************************************************************
 * get_fbm_data
 ****************************************************************/

int get_fbm_data(PMS *image, FILE *fp)
{
  UBYTE *pp, *buff, *zz;
  UBYTE palette[FLI_MAX_COLORS][3];
  int i,j,k,n;
  int rest, ncolors;

  /* -- get file header (magic is already read) -- */

  if (get_fbm_header(fp) == 0)
    {
      fprintf(stderr,"Invalid FBM header\n");
      return(0);
    }
  image->width=width;
  image->height=height;

  if (verbose_flag > 0)
    {
      fprintf(stdout," %d x %d  (FBM: %d planes, %d bits)\n",
	      image->width,
	      image->height,
	      planes,
	      bits);
    }

  if ((planes != 1) && (planes != 3))
    {
      fprintf(stderr,"Sorry can't handle %d planes\n",planes);
      return(0);
    }

  if (physbits != 8)
    {
      fprintf(stderr,"Sorry can't handle %d physbits\n",physbits);
      return(0);
    }

  if ((planes == 3) && (clrlen != 0))
    {
      fprintf(stderr,"Invalid file structure: RGB data plus color table\n");
      return(0);
    }

  image->len = image->width * image->height;
  pix_len = 3 * image->len;

  if (image->width > rowlen)
    {
      fprintf(stderr,"Invalid file structure:\n");
      fprintf(stderr,"Row length %d is too small, expected >= %d\n",
	      rowlen, image->width);
      return(0);
    }

  if (image->len > plnlen)
    {
      fprintf(stderr,"Invalid file structure:\n");
      fprintf(stderr,"Plane length %d is too small, expected >= %d\n",
	      plnlen, image->len);
      return(0);
    }

  if (pix_len == 0)
    {
      fprintf(stderr,"Invalid geometry: %d x %d\n",image->width,image->height);
      return(0);
    }

  ncolors = 0;
  if (planes == 1)
    {
      if (clrlen == 0)
	{
	  fprintf(stderr,"Invalid file structure: no color table\n");
	  return(0);
	}
      rest = clrlen % 3;
      ncolors = (clrlen - rest)/3;
      if (rest > 0)
	{
	  fprintf(stderr,"Invalid file structure:\n");
	  fprintf(stderr,"Length of colors table is %d = 3 * %d + %d\n",
		  clrlen, ncolors, rest);
	  return(0);
	}
      if (ncolors > FLI_MAX_COLORS)
	{
	  fprintf(stderr,"Color table too long: %d",ncolors);
	  return(0);
	}
    }

  /* -- allocate space -- */

  if (image->pixels != NULL)
    {
      free(image->pixels);
      image->pixels=NULL;
    }

  if ((image->pixels=(UBYTE *)calloc(1, pix_len)) == NULL)
    {
      fprintf(stderr,"Can't allocate %d bytes\n",pix_len);
      return(0);
    }

  if ((buff=(UBYTE *)calloc(1, plnlen)) == NULL)
    {
      fprintf(stderr,"Can't allocate %d bytes\n",plnlen);
      return(0);
    }

  /* -- reading data -- */

  if (planes == 1)
    {
      /* read color table */
      for (k=0; k<3; k++)
	{
	  for (i=0; i < ncolors; i++)
	    {
	      palette[i][k] = getc(fp);
	    }
	  for (i=(ncolors); i < FLI_MAX_COLORS; i++)
	    {
	      palette[i][k] = 0;
	    }
	}

      read_raw(fp, buff, plnlen);
      pp=image->pixels;

      for (j=0; j < image->height; j++)
	{
	  zz=buff + j * rowlen;
	  for (i=0; i < image->width; i++)
	    {
	      k = *zz++;
	      *pp++ = palette[k][0];
	      *pp++ = palette[k][1];
	      *pp++ = palette[k][2];
	    }
	}
    }
  else
    {
      for (n=0; n<3; n++)
	{
	  read_raw(fp, buff, plnlen);
	  pp=image->pixels + n;

	  for (j=0; j < image->height; j++)
	    {
	      zz=buff + j * rowlen;
	      for (i=0; i < image->width; i++)
		{
		  *pp = *zz++;
		  pp += 3;
		}
	    }
	}
    }

  free(buff);
  return(1);
}

/****************************************************************
 * get_fbm_string
 ****************************************************************/

static int get_fbm_string(FILE *fp, char *string, int len)
{
  int i, c;

  for (i=0; i < len; i++)
    {
      if ((c = getc(fp)) == EOF) return(0);
      string[i] = c;
    }

  return(1);
}

/****************************************************************
 * get_fbm_int
 ****************************************************************/

static int get_fbm_int(FILE *fp)
{
  int c,i,w,z;

  i=0;
  w=0;
  while (1)
    {
      z=-1;
      c=getc(fp);
      switch (c)
	{
	case '0': z=0; break;
	case '1': z=1; break;
	case '2': z=2; break;
	case '3': z=3; break;
	case '4': z=4; break;
	case '5': z=5; break;
	case '6': z=6; break;
	case '7': z=7; break;
	case '8': z=8; break;
	case '9': z=9; break;
	case '\0': return(w);
	case '-': return(-1);
	default:
	  w=0; break;
	}

      i++;
      if (i >= MAXDIGITS)
	{
	  fprintf(stderr,"Number too long in fbm header\n");
	  return(-1);
	}
      if (z >=0) w=10*w+z;
    }
  return(-1);
}

/**** -- FIN -- *****/
