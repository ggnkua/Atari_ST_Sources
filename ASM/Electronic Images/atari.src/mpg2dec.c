/* mpeg2dec.c, main(), initialization, option processing
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#define GLOBAL
#include "config.h"
#include "global.h"

void error(text)
char *text;
{
  fprintf(stderr,text);
  exit(1);
}

static void initdecoder(void)
{
  INT32 i, cc, size;

  /* clip table */
  if (!(clp=(unsigned char *)malloc(1024l)))
    error("malloc failed\n");

  clp += 384;

  for (i=-384; i<640; i++)
    clp[i] = (i<0) ? 0 : ((i>255) ? 255 : i);

  mb_width = (horizontal_size+15)/16;
  mb_height = (vertical_size+15)/16;
  coded_picture_width = 16*mb_width;
  coded_picture_height = 16*mb_height;
  chrom_width = coded_picture_width>>1;
  chrom_height = coded_picture_height>>1;
  
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
  
  init_display();
  printf("\nwidth=%d  height=%d\n",horizontal_size,vertical_size);
}


int main(argc,argv)
int argc;
char *argv[];
{
  INT16 first;
  INT32 runtime,framenum;
  clock_t tstart,tstop;

  if ((ld_infile=open(argv[1],O_RDONLY|O_BINARY))<=0)
  {
    sprintf(errortext,"Input file %s not found\n",argv[1]);
    error(errortext);
  }

  initbits();
 
  startcode();
  switch(showbits(32)){
    case SEQ_START_CODE:
      break;
    case PACK_START_CODE:
      sysstream = 1;
      break;
    default:
      error("This not a valid MPEG system or video stream\n");
      break;
  }
 
 first = 1;

 lseek(ld_infile,0l,0);	    /* (re)set to begin of file */
 initbits();

 framenum = 0;

	while (getheader())
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
  	
  	tstop = clock();
  	
	if (ld_infile!=0)
    	close(ld_infile);

  	runtime = (tstop-tstart);
	if (runtime!=0)
    {	printf("%ld.%02ld seconds, %ld frames, %ld.%02ld fps\n",runtime/CLK_TCK, (runtime%CLK_TCK)/(CLK_TCK/100),
      	framenum, (framenum*CLK_TCK)/runtime,
      	(100*framenum*CLK_TCK/runtime)%100);
	}
    exit_display();

  return 0;
}



