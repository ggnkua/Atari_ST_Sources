/****************************************************************
 * appm.c
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

static int get_ppm_int(FILE *fp);
static int get_ppm_bit(FILE *fp);

static int line;

/****************************************************************
 * get_ppm_data
 ****************************************************************/

int get_ppm_data(PMS *image, FILE *fp, int type)
{
  UBYTE *pp, *buff, *zz;
  UBYTE newval[FLI_MAX_COLORS];
  int c, raw_flag, k, maxval, pix_len, bitshift, i,j,n;
  int gray_flag, bw_flag;
  int buff_len;

  /* magic is already read */

  bw_flag = 0;
  raw_flag = 0;
  gray_flag = 0;
  
  switch (type)
    {
    case 1:
      bw_flag = 1;
      if (verbose_flag > 0) fprintf(stdout," pbm ascii ");
      break;
    case 2:
      gray_flag = 1;
      if (verbose_flag > 0) fprintf(stdout," pgm ascii ");
      break;
    case 3:
      if (verbose_flag > 0) fprintf(stdout," ppm ascii ");
      break;
    case 4:
      raw_flag = 1;
      bw_flag = 1;
      if (verbose_flag > 0) fprintf(stdout," pbm raw ");
      break;
    case 5:
      raw_flag = 1;
      gray_flag = 1;
      if (verbose_flag > 0) fprintf(stdout," pgm raw ");
      break;
    case 6:
      raw_flag = 1;
      if (verbose_flag > 0) fprintf(stdout," ppm raw ");
      break;
    default:
      fprintf(stderr,"Invalid ppm/pgm/pbm file type\n");
      return(0);
    }

  /* -- get file header -- */

  line=1;

  if ((image->width=get_ppm_int(fp)) < 0) return(0);
  if ((image->height=get_ppm_int(fp)) < 0) return(0);
  if (bw_flag)
    { maxval = 255; }
  else
    { if ((maxval=get_ppm_int(fp)) < 0) return(0); }

  image->len = image->width * image->height;
  pix_len = 3 * image->len;

  if (verbose_flag > 0)
    fprintf(stdout," %d x %d  (%d)\n",
	    image->width,
	    image->height,
	    maxval);

  if (pix_len == 0)
    {
      fprintf(stderr,"Invalid geometry: %d x %d\n",image->width,image->height);
      return(0);
    }

  if ((bw_flag) && (raw_flag))
    {
      k = image->len % 8;
      buff_len = (image->len - k)/8;
      if (k > 0) buff_len++;
    }
  else if ((gray_flag) && (raw_flag))
    {
      buff_len = image->len;
    }
  else
    {
      buff_len = 0;
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

  buff=NULL;
  if (buff_len > 0)
    {
      if ((buff=(UBYTE *)calloc(1, buff_len)) == NULL)
	{
	  fprintf(stderr,"Can't allocate %d bytes\n",buff_len);
	  return(0);
	}
    }

  /* -- reading data -- */

  bitshift=0;
  while (maxval > 255)
    {
      maxval = maxval >> 1;
      bitshift++;
    }

  if (raw_flag == 0) /* ascii data */
    {
      pp=image->pixels;
      if (bw_flag)
	{
	  for (i=0; i < image->len; i++)
	    {
	      if ((k=get_ppm_bit(fp)) < 0)
		{
		  fprintf(stderr,
			  "Need %d black-white values but got only %d\n",
			  image->len, i);
		  break;
		}
	      *pp++ = (UBYTE) k;
	      *pp++ = (UBYTE) k;
	      *pp++ = (UBYTE) k;
	    }
	}
      else if (gray_flag)
	{
	  for (i=0; i < image->len; i++)
	    {
	      if ((k=get_ppm_int(fp)) < 0)
		{
		  fprintf(stderr,
			  "Need %d gray values but got only %d\n",
			  image->len, i);
		  break;
		}
	      k = (k >> bitshift);
	      *pp++ = (UBYTE) k;
	      *pp++ = (UBYTE) k;
	      *pp++ = (UBYTE) k;
	    }
	}
      else /* rgb */
	{
	  for (i=0; i < pix_len; i++)
	    {
	      if ((k=get_ppm_int(fp)) < 0)
		{
		  fprintf(stderr,
			  "Need %d rgb values but got only %d\n",
			  pix_len, i);
		  break;
		}
	      *pp++ = (UBYTE) (k >> bitshift);
	    }
	}

    }
  else /* raw data */
    {
      if (bw_flag)
	{
	  read_raw(fp, buff, buff_len);
	  pp=image->pixels;
	  zz=buff;
	  i = 0;
	  for (j=0; j < buff_len; j++)
	    {
	      c = *zz++;
	      for (n=0; n < 8; n++)
		{
		  if (i++ >= image->len) break;
		  if (c >= 128)
		    {
		      k = 0;
		      c = 2 * (c - 128);
		    }
		  else
		    {
		      k = 255;
		      c *= 2;
		    }
		  *pp++ = (UBYTE) k;
		  *pp++ = (UBYTE) k;
		  *pp++ = (UBYTE) k;
		}
	    }
	}
      else if (gray_flag)
	{
	  read_raw(fp, buff, buff_len);
	  pp=image->pixels;
	  zz=buff;
	  for (i=0; i < image->len; i++)
	    {
	      k = (*zz++ >> bitshift);
	      *pp++ = (UBYTE) k;
	      *pp++ = (UBYTE) k;
	      *pp++ = (UBYTE) k;
	    }
	}
      else /* rgb */
	{
	  read_raw(fp, image->pixels, pix_len);
	  if (bitshift > 0)
	    {
	      pp=image->pixels;
	      for (i=0; i < pix_len; i++)
		{
		  *pp = *pp >> bitshift;
		  pp++;
		}
	    }
	}
    }

  if (buff_len > 0) free(buff);

  /* -- normalize if necessary -- */

  if (maxval < 255)
    {
      for (i = 0; i < 255; i++)
	{
	  k = (i * 255)/maxval;
	  if (k > 255) k=255;
	  newval[i] = (UBYTE) k;
	}
      pp=image->pixels;
      for (i=0; i < pix_len; i++)
	{
	  *pp = newval[*pp];
	  pp++;
	}
    }

  return(1);
}

/****************************************************************
 * get_ppm_int
 ****************************************************************/

static int get_ppm_int(FILE *fp)
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
	case '#':
	  while (1)            /* read comment */
	    {
	      c=getc(fp);
	      if ((c == '\n') || (c == EOF))
		{
		  line++;
		  break;
		}
	    }
	  break;
	case '\n':
	  line++;
	  break;
	default:
	  break;
	}

      if (z == -1)     /* if no digit: char is assumed to be a whitespace */
	{
	  if (i > 0) return(w);
	  if (c == EOF)
	    {
	      fprintf(stderr,"Unexpected end of file in line %d\n", line);
	      return(-1);
	    }
	}
      else
	{
	  i++;
	  if (i >= MAXDIGITS)
	    {
	      fprintf(stderr,"Number too long in line %d\n", line);
	      return(-1);
	    }
	  w=10*w+z;
	}
    }
  return(-1);
}

/****************************************************************
 * get_ppm_bit
 ****************************************************************/

static int get_ppm_bit(FILE *fp)
{
  int c;

  while (1)
    {
      c=getc(fp);
      switch (c)
	{
	case '0': return(255);
	case '1': return(0);
	case '#':
	  while (1) /* read comment */
	    {
	      c=getc(fp);
	      if ((c == '\n') || (c == EOF))
		{
		  line++;
		  break;
		}
	    }
	  break;
	default:    /* everything beside '0','1' and '#' is ignored */
	  break;
	}
      if (c == EOF)
	{
	  fprintf(stderr,"Unexpected end of pbm file\n");
	  return(-1);
	}
    }
  return(-1);
}

/**** -- FIN -- *****/
