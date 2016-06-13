/****************************************************************
 * uoutput.c
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
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "upro.h"
#include <stdlib.h>

#define MAX_LEN 512

int out_image
(
 unsigned char *image_buffer, 
 unsigned char *color_table,
 int width, 
 int height, 
 int outtype,
 char *name_base,
 char *name_ext,
 int digits,
 int num,
 int compress_flag
 )
{
  FILE *fopen(), *fpout;
  struct stat  statbuf; 
  char out_name[MAX_LEN];
  char digiter[MAX_LEN];
  char befehl[MAX_LEN + 20];
  unsigned char *red, *green, *blue, *pp, *zz, *wbuff;
  int m,n,i,j,ic, len, zsize;
  int fbm_planes, fbm_bits, fbm_physbits;
  int fbm_rowlen, fbm_plnlen, fbm_clrlen;
  double fbm_aspect;

  if (name_ext == NULL)
    len=strlen(name_base)+digits+1;
  else
    len=strlen(name_base)+strlen(name_ext)+digits+1;

  if (len > MAX_LEN)
    {
      fprintf(stderr,"Image %d: File name too long!\n",num);
      return(0);
    }

  m=num;
  for (i=(digits-1); i >= 0; i--)
    {
      n=m % 10;
      switch (n)
	{
	case 0: digiter[i] = '0'; break;
	case 1: digiter[i] = '1'; break;
	case 2: digiter[i] = '2'; break;
	case 3: digiter[i] = '3'; break;
	case 4: digiter[i] = '4'; break;
	case 5: digiter[i] = '5'; break;
	case 6: digiter[i] = '6'; break;
	case 7: digiter[i] = '7'; break;
	case 8: digiter[i] = '8'; break;
	case 9: digiter[i] = '9'; break;
	default: break;
	}
      m = (m - n) / 10;
    }
  digiter[digits] = '\0';

  if (name_ext == NULL)
    sprintf(out_name,"%s.%s",name_base,digiter);
  else
    sprintf(out_name,"%s%s.%s",name_base,digiter,name_ext);

  if (stat(out_name, &statbuf) == 0)	/* exists already */
    {
      fprintf(stderr,
	      "Error: file '%s' already exists -- image %d not written\n",
	      out_name,num);
      return(0);
    }

  if ((fpout=fopen(out_name, "wb")) == NULL)
  {
    fprintf(stderr," Error opening '%s'\n",out_name);
    return(0);
  }

  fprintf(stdout,"Write '%s'\n",out_name);

  red=&color_table[0];
  green=&color_table[MAXCOLORS];
  blue=&color_table[2*MAXCOLORS];

  if (outtype == PPM_ASCII)
    {
      fprintf(fpout,"P3\n");
      fprintf(fpout,"%d %d 255\n",width,height);

      pp = image_buffer;
      for (i = 0; i < (width*height); i++)
	{
	  ic = *pp++;
	  fprintf(fpout,"%d %d %d\n",red[ic],green[ic],blue[ic]);
 	}
    }
  else if (outtype == PPM_RAW)
    {
      zsize = 3 * width;
      wbuff = malloc(zsize);
      if (wbuff == NULL)
	{
	  fprintf(stderr,"Error allocating %d bytes\n",zsize);
	  fclose(fpout);
	  return(0);
	}

      fprintf(fpout,"P6\n");
      fprintf(fpout,"%d %d 255\n",width,height);

      pp = image_buffer;
      for (j = 0; j < height; j++)
	{
	  zz = wbuff;
	  for (i = 0; i < width; i++)
	    {
	      ic = *pp++;
	      *zz++ = red[ic];
	      *zz++ = green[ic];
	      *zz++ = blue[ic];
	    }
	  if (fwrite(wbuff, 1, zsize, fpout) != zsize)
	    {
	      fprintf(stderr,"Write error in row %d, '%s' is incomplete\n",
		      j, out_name);
	      fclose(fpout);
	      return(0);
	    }
	}
      free(wbuff);
    }
  else if (outtype == FBM_MAPPED)
    {
      zsize = 256;
      wbuff = calloc(1, zsize);
      if (wbuff == NULL)
	{
	  fprintf(stderr,"Error allocating %d bytes\n", zsize);
	  fclose(fpout);
	  return(0);
	}
      fbm_planes = 1;
      fbm_bits = fbm_physbits = 8;
      fbm_rowlen = width;
      fbm_plnlen = width * height;
      fbm_clrlen = 3 * MAXCOLORS;
      fbm_aspect = 1.0;
      strncpy (&wbuff[0],  "%bitmap", 8);
      sprintf (&wbuff[8],  "%7d",  width);
      sprintf (&wbuff[16], "%7d",  height);
      sprintf (&wbuff[24], "%7d",  fbm_planes);
      sprintf (&wbuff[32], "%7d",  fbm_bits);
      sprintf (&wbuff[40], "%7d",  fbm_physbits);
      sprintf (&wbuff[48], "%11d", fbm_rowlen);
      sprintf (&wbuff[60], "%11d", fbm_plnlen);
      sprintf (&wbuff[72], "%11d", fbm_clrlen);
      sprintf (&wbuff[84], "%11.6f", fbm_aspect);
      if (fwrite(wbuff, 1, zsize, fpout) != zsize)
	{
	  fprintf(stderr,"Error writing fbm header, '%s' is incomplete\n",
		  out_name);
	  fclose(fpout);
	  return(0);
	}
      if (fwrite(color_table, 1, fbm_clrlen, fpout) != fbm_clrlen)
	{
	  fprintf(stderr,"Error writing fbm color table, '%s' is incomplete\n",
		  out_name);
	  fclose(fpout);
	  return(0);
	}
      if (fwrite(image_buffer, 1, fbm_plnlen, fpout) != fbm_plnlen)
	{
	  fprintf(stderr,"Error writing fbm image, '%s' is incomplete\n",
		  out_name);
	  fclose(fpout);
	  return(0);
	}
    }
  else
    {
      fprintf(stderr,"Invalid output type\n");
      fclose(fpout);
      return(0);
    }

  if (ferror(fpout))
    {
      fprintf(stderr,"Error writing ppm\n");
      fclose(fpout);
      return(0);
    }

  fclose(fpout);

  if (compress_flag == 0) return(1);

  if (compress_flag == 1)
    sprintf(befehl,"compress %s", out_name);
  else
    sprintf(befehl,"gzip %s", out_name);

  fprintf(stdout," .... %s\n",befehl);

  if (system(befehl) != 0)
  {
    fprintf(stderr," Error compressing '%s'\n",out_name);
    return(0);
  }

  return(1);
}
