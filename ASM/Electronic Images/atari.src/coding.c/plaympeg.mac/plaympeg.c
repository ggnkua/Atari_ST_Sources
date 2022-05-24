/*
 *	PLAYMPEG
 *	Martin Griffiths 1995.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define GLOBAL
#include "plaympeg.h"

static void initdecoder _ANSI_ARGS_((void));
static INT32 loopflag=0;

void error(text)
char *text;
{
  fprintf(stderr,text);
  exit(1);
}

int main(argc,argv)
int argc;
char *argv[];
{
  INT32 first, framenum,runtime;
  clock_t tstart,tstop;
  if (argv[1] == NULL)
  { sprintf(errortext,"Input file required\n",argv[1]);
    error(errortext);
  } 
  if ((ld_infile=open(argv[1],O_RDONLY|O_BINARY))<0)
  {
    sprintf(errortext,"Input file %s not found\n",argv[1]);
    error(errortext);
  }

  if (ld_infile != 0)
  {
    initbits();
    startcode();
    switch(showbits(32))
    {
    case SEQ_START_CODE:
      break;
    case PACK_START_CODE:
      sysstream = 1;
      break;
    default:
      error("This not a valid MPEG system or video stream\n");
      break;
    }
    lseek(ld_infile,0l,0);
    initbits();
  }
  first = 1;

  do
  {
    /* (re)set to begin of file */
    if (ld_infile!=0)
      lseek(ld_infile,0l,0);
    initbits();

    framenum = 0;

    while (getheader() && (Cconis()==0) )
    {
      if (first)
      {
        initdecoder();
      	tstart=clock();
        first = 0;
      }

      getpicture(framenum);
      framenum++;
    }

    if (framenum!=0)
      putlast(framenum);      /* put last frame */

  }
  while (loopflag);
 
  tstop = clock();

  runtime = (tstop-tstart);
  if (runtime!=0)
  {	printf("%ld.%02ld seconds, %ld frames, %ld.%02ld fps\n",runtime/CLK_TCK, (runtime%CLK_TCK)/(CLK_TCK/100),
   	framenum, (framenum*CLK_TCK)/runtime,
   	(100*framenum*CLK_TCK/runtime)%100);
  }
  
  if (ld_infile!=0)
    close(ld_infile);

  exit_display();

  return 0;
}

static unsigned char clip[1024l];

static void initdecoder()
{
  INT32 i, cc, size;
  clp = clip+384;
  for (i=-384; i<640; i++)
    clp[i] = (i<0) ? 0 : ((i>255) ? 255 : i);

  mb_width = (horizontal_size+15)/16;
  mb_height = (vertical_size+15)/16;
  coded_picture_width = 16*mb_width;
  coded_picture_height = 16*mb_height;

  chrom_width = coded_picture_width >> 1;
  chrom_height = coded_picture_height >> 1;

  for (cc=0; cc<3; cc++)
  {
    if (cc==0)
      size = (INT32) coded_picture_width*coded_picture_height;
    else
      size = (INT32) chrom_width*chrom_height;

    if (!(refframe[cc] = (unsigned char *)malloc(size)))
      error("malloc failed\n");

    if (!(oldrefframe[cc] = (unsigned char *)malloc(size)))
      error("malloc failed\n");

    if (!(auxframe[cc] = (unsigned char *)malloc(size)))
      error("malloc failed\n");

  }
  init_mv_table();
  init_mb_addr_inc();
  init_getblk();
  init_display();
}

