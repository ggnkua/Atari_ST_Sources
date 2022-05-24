/* mpeg2dec.c, main(), initialization, option processing                    */
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <fcntl.h>
#include <time.h>

#define GLOBAL
#include "config.h"
#include "global.h"

/* private prototypes */
static void initdecoder _ANSI_ARGS_((void));
static void options _ANSI_ARGS_((int *argcp, char **argvp[]));
static int getval _ANSI_ARGS_((char *argv[]));

/* private data */
static int loopflag;

static int runtime;

int main(argc,argv)
int argc;
char *argv[];
{
  int first, framenum;
#ifdef USE_TIME
  int runtime;
  struct timeval tstart,tstop;
#endif

  options(&argc,&argv);

  ld = &base; /* select base layer context */

  /* open MPEG input file(s) */
  if (argv[1][0]=='-' || argv[1][1]=='\0')
  {
    base.infile = 0; /* stdin */
    loopflag = 0; /* can't rewind stdin */
  }
  else if ((base.infile=open(argv[1],O_RDONLY|O_BINARY))<0)
  {
    sprintf(errortext,"Input file %s not found\n",argv[1]);
    error(errortext);
  }

  if (base.infile != 0)
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
    lseek(base.infile,0l,0);
    initbits();
  }

  if (argc==4)
  {
    ld = &enhan; /* select enhancement layer context */

    if ((enhan.infile = open(argv[2],O_RDONLY|O_BINARY))<0)
    {
      sprintf(errortext,"Input file %s not found\n",argv[2]);
      error(errortext);
    }

    twostreams = 1;
    ld = &base;
  }

  first = 1;

  do
  {
    /* (re)set to begin of file */
    ld = &base;
    if (base.infile!=0)
      lseek(base.infile,0l,0);
    initbits();

    if (twostreams)
    {
      ld = &enhan;
      lseek(enhan.infile,0l,0);
      initbits();
      ld = &base;
    }

    framenum = 0;

    while (getheader())
    {
      if (first)
      {
	initdecoder();
	runtime=clock();
	first = 0;
      }

      getpicture(framenum);

      if (!secondfield)
      {
#ifdef USE_TIME
	if (framerate > 0)
	  doframerate();
#endif  
	framenum++;
      }
    }

    if (framenum!=0)
    {
      /* put last frame */
      putlast(framenum);
    }

  }
  while (loopflag);

  if (base.infile!=0)
    close(base.infile);

  if (twostreams)
    close(enhan.infile);

  fprintf(stderr,"%f\n",(float) framenum / (float) ((clock()-runtime)/CLOCKS_PER_SEC));

  if (outtype==T_X11)
    exit_display();

  return 0;
}

static void initdecoder()
{
  int i, cc, size;
  static int blk_cnt_tab[3] = {6,8,12};

  /* check scalability mode of enhancement layer */
  if (twostreams && enhan.scalable_mode!=SC_SNR &&
     !(base.scalable_mode==SC_DP && base.scalable_mode==SC_DP))
    error("unsupported scalability mode\n");

  /* clip table */
  if (!(clp=(unsigned char *)malloc(1024)))
    error("malloc failed\n");

  clp += 384;

  for (i=-384; i<640; i++)
    clp[i] = (i<0) ? 0 : ((i>255) ? 255 : i);

  /* force MPEG-1 parameters */
  if (!base.mpeg2)
  {
    prog_seq = 1;
    prog_frame = 1;
    pict_struct = FRAME_PICTURE;
    frame_pred_dct = 1;
    chroma_format = CHROMA420;
    matrix_coefficients = 5;
  }

  /* round to nearest multiple of coded macroblocks */
  mb_width = (horizontal_size+15)/16;
  mb_height = (base.mpeg2 && !prog_seq) ? 2*((vertical_size+31)/32)
					: (vertical_size+15)/16;
  coded_picture_width = 16*mb_width;
  coded_picture_height = 16*mb_height;

  chrom_width = (chroma_format==CHROMA444) ? coded_picture_width
					   : coded_picture_width>>1;
  chrom_height = (chroma_format!=CHROMA420) ? coded_picture_height
					    : coded_picture_height>>1;
  blk_cnt = blk_cnt_tab[chroma_format-1];

  for (cc=0; cc<3; cc++)
  {
    if (cc==0)
      size = coded_picture_width*coded_picture_height;
    else
      size = chrom_width*chrom_height;

    if (!(refframe[cc] = (unsigned char *)malloc(size)))
      error("malloc failed\n");

    if (!(oldrefframe[cc] = (unsigned char *)malloc(size)))
      error("malloc failed\n");

    if (!(auxframe[cc] = (unsigned char *)malloc(size)))
      error("malloc failed\n");

    if (base.scalable_mode==SC_SPAT)
    {
      /* this assumes lower layer is 4:2:0 */
      if (!(llframe0[cc] = (unsigned char *)malloc((llw*llh)/(cc?4:1))))
	error("malloc failed\n");
      if (!(llframe1[cc] = (unsigned char *)malloc((llw*llh)/(cc?4:1))))
	error("malloc failed\n");
    }
  }

  if (base.scalable_mode==SC_SPAT)
  {
    if (!(lltmp = (short *)malloc(llw*((llh*vn)/vm)*sizeof(short))))
      error("malloc failed\n");
  }

  /* IDCT */
  init_idct();

  if (outtype==T_X11)
  {
    init_display();
    init_dither();
  }
}

void error(text)
char *text;
{
  fprintf(stderr,text);
  exit(1);
}

/* compliance warning messages to user, but don't exit() */
void warning(text)
char *text;
{
  fprintf(stderr,"%s\n",text);
} 

#ifdef TRACE
/* trace output */
void printbits(code,bits,len)
int code,bits,len;
{
  int i;
  for (i=0; i<len; i++)
    printf("%d",(code>>(bits-1-i))&1);
}
#endif

/* option processing */
static void options(argcp,argvp)
int *argcp;
char **argvp[];
{
  outtype = T_X11;

  while (*argcp>1 && (*argvp)[1][0]=='-')
  {
    if ((*argvp)[1][1]=='\0') /* single '-' */
      break;

    while ((*argvp)[1][1])
    {
      switch (toupper((*argvp)[1][1]))
      {
#ifdef USE_TIME
      case 'F':
	framerate = getval(*argvp);
	break;
#endif
      case 'V':
	verbose = getval(*argvp);
	break;
      case 'O':
	outtype = getval(*argvp);
	break;
      case 'L':
	loopflag = 1;
	break;
      case 'S':
	sflag = 1;
	break;
#ifdef TRACE
      case 'T':
	trace = 1;
	break;
#endif
      case 'Q':
	quiet = 1;
	break;
      default:
	fprintf(stderr,"undefined option -%c ignored\n",(*argvp)[1][1]);
      }

      (*argvp)[1]++;
    }

    (*argvp)++;
    (*argcp)--;
  }

  if (sflag)
  {
    /* input file for spatial prediction */
    llinputname = (*argvp)[1];
    (*argvp)++;
    (*argcp)--;
  }

  if (*argcp!=2 && *argcp!=3)
  {
    printf("\n%s, %s\n",version,author);
    printf("Usage:   mpeg2play {options} input.m2v {upper.m2v}\n\
Options: -vn  verbose output (n: level)\n\
	 -on  output format (0: X11 (default), 1: none)\n\
	 -l   loop sequence\n\
	 -q   quiet (no error output)\n\
	 -s infile   spatial scalable sequence\n");
#ifdef USE_TIME
    printf("\
	 -fn  frame rate (default = as fast as possible)\n");
#endif    
    exit(0);
  }
}

static int getval(argv)
char *argv[];
{
  int val;

  if (sscanf(argv[1]+2,"%d",&val)!=1)
    return 0;

  while (isdigit(argv[1][2]))
    argv[1]++;

  return val;
}
