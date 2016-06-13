/****************************************************************
 * amain.c
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

static const char ppm2fli_env_var[]="PPM2FLIFILTER";
static int output_file_created;
static char *output_name;

#define SCANINT(x,y) \
if (sscanf(x,"%d",y) != 1) \
{ fprintf(stderr,"Invalid number '%s' in argument %d\n",x,i);\
 print_hint(); exit(1); }

#define GETNUMBER(x) \
ppa++; \
if (*ppa == '\0') { pending_number = &(x); pp_flag = 1; } \
else { SCANINT(ppa,&(x)); }

#define GETNAME(x) \
ppa++; \
if (*ppa == '\0') { pending_name = &(x); pp_flag = 2; } \
else { x = ppa; }


/****************************************************************
 * print_usage
 ****************************************************************/

static int print_usage()
{
  fprintf(stdout,"PPM2FLI beta 1.9d by Klaus Ehrenfried (C) 1995,1996\n");
  fprintf(stdout,"Usage: ppm2fli [options] list-file fli-file\n");

  return(1);
}

/****************************************************************
 * print_hint()
 ****************************************************************/

static int print_hint()
{
  fprintf(stderr,"Type 'ppm2fli -h' for help\n");
  return(1);
}

/****************************************************************
 * print_usage
 ****************************************************************/

static int print_help()
{
  fprintf(stdout,"Function:\n\
  Reads from 'list-file' line by line file names of PPM/PGM/PBM/FBM images,\n\
  generates a common color-table by scanning all images,\n\
  quantizes the images and assembles a FLI/FLC animation,\n\
  which is written to 'fli-file'\n");

  fprintf(stdout,"Quantize options:\n\
  -I                  Individual quantize: Don't use common color table,\n\
                        generate for each image separate table\n\
  -Qc<colors>         Set max number of colors (9 - 256; default = 256)\n\
  -Qd<depth>          Set color depth (2 - 8; default = 8)\n\
  -Qn<limit>          Set node limit in Octree (16 - 2048; default = 512)\n\
  -Qr<value>          Set max number of reduce levels (0 - 8; default = 8)\n\
  -m<file>            Don't scan all images previously, generate color-table\n\
                        by scanning only the image in specified file\n\
                        (ppm or fbm, read filter is ineffective)\n\
  -w<file>            Write generated color-table to file (256x1 PPM ascii)\n\
                        and stop, don't make FLI/FLC\n");

  fprintf(stdout,"FLI/FLC options:\n\
  -D                  Double buffer optimization (for special players)\n\
  -N                  Reverse play suitability (nice when using XAnim)\n\
  -O                  Generate old format FLI instead of FLC\n\
  -b<color>           Set border color (default = 0)\n\
  -g<width>x<height>  Set width and height (10x10 - 1280x1024),\n\
                        default is 640x480 (320x200 when using '-O')\n\
  +/-ox<pos>          Switch off horizontal centering of input images,\n\
                        locate the left/right border at specified position\n\
  +/-oy<pos>          Switch off vertical centering of input images,\n\
                        locate the upper/lower border at specified position\n\
  -s<speed>           Set play speed stored in FLI/FLC file\n");

  fprintf(stdout,"General options:\n\
  -v                  Verbose ('-vv' is more verbose)\n\
  +/-f<filter>        Read all input images via the specified filter\n\
                        (e.g. '-fgunzip', '-fgiftopnm', '-ffbcat', etc.),\n\
                        '+f' filter needs file name as argument\n\
                        '-f' filter reads from stdin\n\
  -t                  Test file magic: use read filter only for files\n\
                        without PPM,PGM,PBM or FBM magic\n");
  fprintf(stdout,"For more details, please read the manual pages\n");
  return(1);
}

/****************************************************************
 * exitialise
 ****************************************************************/

int exitialise(int error_flag)
{
    if (error_flag != 0)
    {
	if (output_file_created == 1)
	{
	  if (output != NULL) fclose(output);

	  fprintf(stderr,"Remove incomplete output file '%s'\n",output_name);
	  (void) remove(output_name);
	}
	fprintf(stderr,"Abnormal termination\n");
    }
    return(1);
}

/****************************************************************
 * main
 ****************************************************************/

void
main (int argc, char *argv[])
{
  FILE *fopen();
  char *listfile, *ppa, *ppb, *map_file, *output_pal_file, *geom;
  char **pending_name;
  char abuff[10];
  int answer_flag, max_chunk_size;
  int s_speed;
  int i, itest, pp_flag, list_input_flag;
  int *pending_number;
  int help_filter_flag;
  int help_origin;

  /* octree defaults */
  max_colors=FLI_MAX_COLORS;
  node_limit = 2 * FLI_MAX_COLORS;
  reduce_dynamics=MAXDEPTH;
  color_depth=8;

  /* -- -- - - -- -- */
  tmp_file_name = NULL;
  verbose_flag = 0;

  geom=NULL;
  listfile=NULL;
  output_name=NULL;
  map_file=NULL;
  input=0;
  output=0;

  output_file_created=0;

  pixel_chunk_buffer=NULL;

  Xorigin=0;
  Xorigin_flag=0;
  Yorigin=0;
  Yorigin_flag=0;
  s_speed=-1;

  border_color=0;
  map_color_flag=0;
  use_next_flag=0;
  double_buffer=0;
  old_format_flag=0;

  write_pal_flag = 0;
  individual_flag = 0;
  filter_flag = 0;
  help_filter_flag = 0;
  test_magic_flag = 0;

  /* scan arguments */

  pp_flag = 0;
  pending_number = NULL;
  pending_name = NULL;
  ppa = ppb = NULL;

  if (argc == 1)
    { print_usage(); exit(1); }

  for (i=1; i < argc; i++)
    {
      ppa=argv[i];
      if (pp_flag == 1)
	{ SCANINT(ppa, pending_number); pp_flag = 0; }
      else if (pp_flag == 2)
	{ *pending_name = ppa; pp_flag = 0; }
      else if ((*ppa == '-') || (*ppa == '+'))
	{
	  ppb = (ppa++);
	  switch (*ppa)
	    {
	    case 'h':   print_usage(); print_help(); exit(1);
	    case 'b':   GETNUMBER(border_color); break;
	    case 'D':   double_buffer=1; break;
	    case 'g':   GETNAME(geom); break;
	    case 'f':
	      GETNAME(filter_name);
	      if (*ppb == '+')
		{help_filter_flag = 2;}
	      else
		{help_filter_flag = 1;}
	      break;
	    case 'I':   individual_flag=1; break;
	    case 'm':   GETNAME(map_file); map_color_flag=1; break;
	    case 'N':   use_next_flag=1; break;
	    case 'O':   old_format_flag=1; break;
	    case 'o':
	      if (*ppb == '+')
		{help_origin = 1;}
	      else
		{help_origin = 2;}
	      ppa++;
	      if (*ppa == 'x')
		{ GETNUMBER(Xorigin); Xorigin_flag = help_origin;}
	      else if (*ppa == 'y')
		{ GETNUMBER(Yorigin); Yorigin_flag = help_origin;}
	      else
		{ goto invalid_option;}
	      break;
	    case 'Q':
	      ppa++;
	      if (*ppa == 'c')
		{ GETNUMBER(max_colors);}
	      else if (*ppa == 'd')
		{ GETNUMBER(color_depth);}
	      else if (*ppa == 'n')
		{ GETNUMBER(node_limit);}
	      else if (*ppa == 'r')
		{ GETNUMBER(reduce_dynamics);}
	      else
		{ goto invalid_option;}
	      break;
	    case 's':   GETNUMBER(s_speed); break;
	    case 't':   test_magic_flag = 1; break;
	    case 'v':
	      ppa++;
	      if (*ppa == 'v') {verbose_flag = 2;} else {verbose_flag = 1;}
	      break;
	    case 'w':   GETNAME(output_pal_file); write_pal_flag=1; break;
	    invalid_option:
	    default:
	      fprintf(stderr,"Invalid option '%s'\n",ppb);
	      print_hint();
	      exit(1);
	    }
	}
      else if (listfile == NULL)
	{
	  listfile=ppa;
	}
      else if (output_name == NULL)
	{
	  output_name=ppa;
	}
      else
	{
	  fprintf(stderr,"Too many parameters specified\n");
	  print_hint();
	  exit(1);
	}
    }

  if (pp_flag != 0)
    {
      fprintf(stderr,"Missing parameter behind option '%s'\n",ppb);
      print_hint();
      exit(1);
    }

  /* -- check if all necessary file names are given -- */

  if ((map_color_flag) && (write_pal_flag))
    { list_input_flag = 0; }
  else
    { list_input_flag = 1; }

  if (listfile == NULL)
    {
      if (list_input_flag)
	{
	  fprintf(stderr,"No list-file specified\n");
	  print_hint();
	  exit(1);
	}
    }
  else
    {
      if (!list_input_flag)
	{
	  fprintf(stderr,"No list-file required: file name '%s' ignored\n",
		  listfile);
	}
    }

  if (output_name == NULL)
    {
      if (!write_pal_flag)
	{
	  fprintf(stderr,"No FLI-file specified\n");
	  print_hint();
	  exit(1);
	}
    }
  else
    {
      if (write_pal_flag)
	{
	  fprintf(stderr,"Only write color table: file name '%s' ignored\n",
		  output_name);
	}
    }

  /* --- check for incompatibilities --- */

  if (use_next_flag)
    {
      if (double_buffer)
	{
	  fprintf(stderr,"Invalid combination of '-D' and '-N'\n");
	  print_hint();
	  exit (1);
	}
      double_buffer = 1;
    }

  if (individual_flag)
    {
      if (map_color_flag)
	{
	  fprintf(stderr,"Invalid combination of '-I' and '-m <file>'\n");
	  print_hint();
	  exit (1);
	}
      if (write_pal_flag)
	{
	  fprintf(stderr,"Invalid combination of '-I' and '-w <file>'\n");
	  print_hint();
	  exit (1);
	}
    }

  /* --- check options for quantize --- */

  if ((node_limit < MIN_NODE_LIMIT) || (node_limit > MAX_NODE_LIMIT))
    {
      fprintf(stderr,"Invalid node limit specified: %d\n",node_limit);
      print_hint();
      exit (1);
    }

  if (color_depth > 8 || color_depth < 2)
    {
      fprintf (stderr,"Invalid color depth specified: %d\n",color_depth);
      print_hint();
      exit (1);
    }

  if (max_colors > 256 || max_colors < 9)
    {
      fprintf (stderr, "Invalid number of colors specified: %d\n",
	       max_colors);
      print_hint();
      exit (1);
    }

  if (reduce_dynamics < 0) reduce_dynamics = 0;

  /* --- output format --- */

  if (write_pal_flag)
    {
      output_name = output_pal_file;
    }
  else
    {
      if (old_format_flag == 1)
	{
	  fli_width=320;
	  fli_height=200;
	  fli_speed=5;
	}
      else
	{
	  fli_width=640;
	  fli_height=480;
	  fli_speed=72;
	}

      if (geom != NULL)
	{
	  if ((sscanf(geom,"%dx%d",&fli_width,&fli_height)) != 2)
	    {
	      fprintf (stderr,"Invalid geometry: '%s'\n",geom);
	      print_hint();
	      exit (1);
	    }

	  if ((fli_width % 2) == 1) fli_width++;            /* no odd width */
	  if ((fli_width < 10) || (fli_width > FLI_MAX_X))
	    {
	      fprintf (stderr,"Invalid width: %d\n",fli_width);
	      print_hint();
	      exit (1);
	    }
	  if ((fli_height < 10) || (fli_height > FLI_MAX_Y))
	    {
	      fprintf (stderr,"Invalid height: %d\n",fli_height);
	      print_hint();
	      exit (1);
	    }
	}

      fli_size = fli_width * fli_height;

      if (s_speed >= 0)           /* be tolerant */
	fli_speed = s_speed;
    }

  if (list_input_flag)
    {
      if ((input = fopen(listfile, "r")) == NULL)
	{
	  fprintf(stderr,"Error opening list-file '%s'\n",listfile);
	  exit(1);
	}
    }
  else
    {
      input = NULL;
    }

  if (verbose_flag > 0)
    {
      fprintf(stdout,"Output:     '%s'\n",output_name);
    }

  if (check_exist(output_name) == 1)
    {
      fprintf(stderr,"%s already exists\n",output_name);
      answer_flag=0;
      while (answer_flag == 0)
	{
	  fprintf(stderr," overwrite %s (y/n) ",output_name);
	  fflush(stdout);
	  if ((itest=get_next_line(stdin, abuff, 2)) == 1)
	    {
	      if ((abuff[0] == 'y') || (abuff[0] == 'Y'))
		answer_flag=1;
	      else if ((abuff[0] == 'n') || (abuff[0] == 'N'))
		answer_flag=2;
	    }
	}
      if (answer_flag != 1) exit(1);
    }

  /* ............. open output file ........ */

  if (write_pal_flag)
    {
      if ((output = fopen(output_name, "w")) == NULL)
	{
	  fprintf(stderr,"Error opening color table file '%s'\n",output_name);
	  exit(1);
	}
      output_file_created = 1;
    }
  else
    {
      if ((output = fopen(output_name, "wb")) == NULL)
	{
	  fprintf(stderr,"Error opening fli-file '%s'\n",output_name);
	  exit(1);
	}
      output_file_created = 1;

      if (border_color > 0x00FF) border_color=0x00FF;
      if (border_color < 0x0000) border_color=0x0000;

      if (verbose_flag > 0)
	{
	  fprintf(stdout," Resolution: %dx%d\n",fli_width,fli_height);
	  fprintf(stdout," Origin:     %dx%d\n",Yorigin,Xorigin);
	  fprintf(stdout," Speed:      %d\n",fli_speed);
	}

      max_chunk_size=fli_height*(2*fli_width+10)+1024;

      pixel_chunk_buffer = malloc(max_chunk_size);
      if (pixel_chunk_buffer == NULL)
	{
	  fprintf(stderr,"Can't allocate %d bytes\n",max_chunk_size);
	  exitialise(1);
	  exit(1);
	}
    }

  if (map_color_flag == 1)
    {
      fprintf(stdout,"Generate color table from file '%s'\n",map_file);
      clear_octree();
      scan_rgb_image(map_file);
      prepare_quantize();
    }

  if (help_filter_flag == 0)
    {
      filter_name = getenv(ppm2fli_env_var);
      if (filter_name != NULL)
	{
	  help_filter_flag = 1;
	  if (*filter_name == '-')
	    {
	      filter_name++;
	    }
	  else if (*filter_name == '+')
	    {
	      filter_name++;
	      help_filter_flag = 2;
	    }
	}
    }

  filter_flag = help_filter_flag;

  if (make_fli() < 0)
    {
      exitialise(1);
      exit(1);
    }

  fprintf(stdout,"Ready\n");
  exitialise(0);
  exit(0);
}

/* -- FIN -- */
