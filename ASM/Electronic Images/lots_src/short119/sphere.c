/******************************************************************************
*                                                                             *
*       Copyright (C) 1992,1993,1994 Tony Robinson                            *
*                                                                             *
*       See the file LICENSE for conditions on distribution and usage         *
*                                                                             *
******************************************************************************/

# include <math.h>
# include <stdio.h>
# include <string.h>
# include "shorten.h"

extern jmp_buf	exitenv;
extern char	*exitmessage;

# define MAX_FLAG_SIZE 32
# define MAX_SHORTEN_ARGC 256

int   shorten_argc = 1;
char *shorten_argv[MAX_SHORTEN_ARGC];

void shorten_set_flag(flag) char *flag; {
  int nbyte = strlen(flag) + 1;
  char *new_argv = malloc(nbyte);
  
  if(new_argv == NULL) {
    fprintf(stderr, "shorten_set_flag: malloc(%d) == NULL\n", nbyte);
    exit(1);
  }

  if(shorten_argc >= MAX_SHORTEN_ARGC) {
    fprintf(stderr, "shorten_set_flag: maximum argument count exceeded\n");
    exit(1);
  }

  strcpy(new_argv, flag);
  shorten_argv[shorten_argc++] = new_argv;
}

void shorten_reset_flags() {
  int i;

  for(i = 1; i < shorten_argc; i++)
    free(shorten_argv[i]);
  shorten_argc = 1;
}

void shorten_set_ftype(ftype) char *ftype; {
  char flag[MAX_FLAG_SIZE];
  sprintf(flag, "-t%s", ftype);
  shorten_set_flag(flag);
}

#define MAX_FLAG_SIZE 32
void shorten_set_channel_count(nchannel) int nchannel; {
  char flag[MAX_FLAG_SIZE];
  sprintf(flag, "-c%d", nchannel);
  shorten_set_flag(flag);
}

/* from Jon Fiscus, 18 Aug 93 */
void shorten_init() {
  shorten_reset_flags();
  shorten_argv[0] = "embedded-shorten";
}

/* from Jon Fiscus, 18 Aug 93 */
void shorten_dump_flags(fpout) FILE *fpout; {
  int i;

  fprintf(fpout,"Shorten Arguements:\n");
  for(i = 0; i < shorten_argc; i++)
    fprintf(fpout,"   Arg %1d: %s\n",i,shorten_argv[i]);
}

int shorten_compress(fpin, fpout, status) FILE *fpin, *fpout; char *status; {
  int exitcode;

  exitmessage = status;
  if((exitcode = setjmp(exitenv)) == 0)
    exitcode = shorten(fpin, fpout, shorten_argc, shorten_argv);
  shorten_reset_flags();
  return(exitcode + 1);
}

int shorten_uncompress(fpin, fpout, status) FILE *fpin, *fpout; char *status; {
  int exitcode;

  shorten_set_flag("-x");
  exitmessage = status;
  if((exitcode = setjmp(exitenv)) == 0)
    exitcode = shorten(fpin, fpout, shorten_argc, shorten_argv);
  shorten_reset_flags();
  return(exitcode + 1);
}
