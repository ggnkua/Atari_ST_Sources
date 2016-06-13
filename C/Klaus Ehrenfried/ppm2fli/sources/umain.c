/****************************************************************
 * umain.c
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

#include <sys/types.h>
#include <sys/stat.h>

#include <stdio.h>
#include <math.h>
#include <string.h>

#include <stdlib.h>

#include "upro.h"

#define SCANINT(x,y) \
if (sscanf(x,"%d",y) != 1) \
{ fprintf(stderr,"Invalid number '%s' in argument %d\n",x,i);\
 print_hint(); exit(1); }

#define GETPARAM(x) \
pending_param = &(x); pp_flag = 1; ppb = ppa;


/****************************************************************
 * print_usage
 ****************************************************************/

static void print_usage()
{
  fprintf(stdout,"UNFLICK beta 1.1b by Klaus Ehrenfried (C) 1995\n");
  fprintf(stdout,"Usage: unflick [options] InputFli OutputBase [Ext]\n");
}

/****************************************************************
 * print_hint
 ****************************************************************/

static void print_hint()
{
  fprintf(stderr,"Type 'unflick -h' for help\n");
}

/****************************************************************
 * print_help
 ****************************************************************/

static void print_help()
{
  fprintf(stdout,"Options:\n\
  -a          PPM-ascii output format (default is PPM-raw)\n\
  -m          Mapped FBM output format\n\
  -b<begin>   Begin output at given frame number\n\
  -n<max>     Output not more than given number of frames\n\
  -v          Verbose\n\
  -z          Postprocess output file with 'compress'\n\
  -zz         Postprocess output file with 'gzip'\n");

  fprintf(stdout,"Function:\n\
  Extracts the images of <InputFli> and writes them in separated files;\n\
  creates <OutputBase>.001, <OutputBase>.002, .....\n\
  or <OutputBase>001.<Ext>, <OutputBase>002.<Ext>, .....\n");
}

/****************************************************************
 * main
 ****************************************************************/

int main (int argc, char *argv[])
{
  FILE *fopen(), *fpin;
  char *infile, *outbase, *outext;
  char *ppa, *ppb;
  int i, r;
  int verbose_flag, compress_flag;
  int begin_frame,max_frames;
  int pp_flag;
  int *pending_param;
  int outtype;

  infile = NULL;
  outbase = NULL;
  outext = NULL;
  verbose_flag = 0;
  compress_flag = 0;
  begin_frame=1;
  max_frames=-1;
  outtype = PPM_RAW;

  /* scan arguments */

  pp_flag = 0;
  pending_param = NULL;
  ppa = ppb = NULL;

  if (argc == 1)
    { print_usage(); exit(1); }

  for (i=1; i < argc; i++)
    {
      ppa=argv[i];
      if (pp_flag == 1)
	{
	  SCANINT(ppa,pending_param);
	  pp_flag = 0;
	}
      else if (*ppa == '-')
	{
	  while (*(++ppa) != '\0')
	    {
	      if (pp_flag == 1)
		{
		  SCANINT(ppa,pending_param);
		  pp_flag = 0;
		  break;
		}
	      switch (*ppa)
		{
		case 'b':   GETPARAM(begin_frame); break;
		case 'n':   GETPARAM(max_frames); break;
		case 'a':   outtype = PPM_ASCII; break;
		case 'm':   outtype = FBM_MAPPED; break;
		case 'z':   compress_flag++; break;
		case 'v':   verbose_flag = 1; break;
		case 'h':   print_usage(); print_help(); exit(1);
		default:
		  fprintf(stderr,"Illegal option '%c' in argument %d\n",
			  *ppa,i);
		  print_hint();
		  exit(1);
		}
	    }
	}
      else  if (infile == NULL)
	{
	  infile=argv[i];
	}
      else if (outbase == NULL)
	{
	  outbase=argv[i];
	}
      else if (outext == NULL)
	{
	  outext=argv[i];
	}
      else
	{
	  fprintf(stderr,"Too many parameters specified\n");
	  print_hint();
	  exit(1);
	}
    }

  if (pp_flag == 1)
    {
      fprintf(stderr,"Missing number behind option '%c'\n",*ppb);
      print_hint();
      exit(1);
    }

  if (outbase == NULL)
    {
      print_usage();
      exit(1);
    }

  /* fprintf(stderr,"Open Input File\n"); */
  if ((fpin = fopen(infile, "rb")) == NULL)
    {
      fprintf(stderr,"Error opening input file '%s'\n",infile);
      exit(1);
    }

  r = unfli(fpin,outbase,outext,outtype,
	    begin_frame,max_frames,verbose_flag,compress_flag);

  if (r == 0)
    fprintf(stderr,"Stop\n");
  else if (r == 1)
    fprintf(stderr,"Ready\n");
  else if (r == -1)
    fprintf(stderr,"Read error\n");
  else if (r == -2)
    fprintf(stderr,"Error allocating memory\n");
  else
    fprintf(stderr,"Unknown error\n");

  fclose(fpin);

  return(0);
}
