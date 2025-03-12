/* $Id: klatt.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
char *klatt_id = "$Id: klatt.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $";
/*
title:  KLATT.C
author: Jon Iles (j.p.iles@uk.ac.bham.cs)
date: 15/11/93
version: 3.0
notes:

This file contains C code to provide a simple interface to
Dennis Klatt's parwave function. This function, as the name
suggests, converts a frame of parameters into a waveform.
The parwave function itself is a translation of the Dennis's
original Fortran code, as published in JASA. The code was
posted to comp.speech in 1993, and has been updated by me
to fix a number of bugs that had been introduced. Subsequently
major rewrites have been done by Nick Ing-Simmons to improve
efficiency and change the code into a more acceptable ANSI C style,
and by me to remove all global variable references.

See the README_klatt file for more details.
*/


#include <stdio.h>
#include <stdlib.h>
#include "proto.h"
#include "parwave.h"


/* for default sampled glottal excitation waveform */

#define NUMBER_OF_SAMPLES 100
#define SAMPLE_FACTOR 0.00001
#define MAX_SAM          20000  /* Maximum sample rate */

/* function prototypes */

void usage PROTO((void));

void
usage()

{
 printf("Options...\n");
 printf("-h Displays this message\n");
 printf("-i <infile> sets input filename\n");
 printf("-o <outfile> sets output filename\n");
 printf("   If output filename not specified, stdout is used\n");
 printf("-q quiet - print no messages\n");
 printf("-t <n> select output waveform\n");
 printf("-c select cascade-parallel configuration\n");
 printf("   Parallel configuration is default\n");
 printf("-n <number> Number of formants in cascade branch.\n");
 printf("   Default is 5\n");
 printf("-s <n> set sample rate\n");
 printf("-f <n> set number of milliseconds per frame, default 10\n");
 printf("-v <n> Specifies voicing source.\n");
 printf("   1=impulse train, 2=natural simulation, 3=sampled natural\n");
 printf("   Default is a simulation of natural voicing\n");
 printf("-F <percent> percentage of f0 flutter\n");
 printf("    Default is 0\n");
}

void main PROTO((int argc, char **argv));

void
main(argc, argv)

int argc;
char *argv[];

{
 extern char *optarg;
 char c;
 char infile[80];
 char outfile[80];
 FILE *infp;
 FILE *outfp;
 int result;
 flag done_flag;
 long value;
 short iwave[MAX_SAM];
 int isam;
 int icount;
 int par_count;
 int nmspf_def;
 klatt_global_t globals;
 klatt_frame_t frame;
 long *frame_ptr;

 static int natural_samples[NUMBER_OF_SAMPLES] =
 {
  -310, -400, 530, 356, 224, 89, 23, -10, -58, -16, 461, 599, 536, 701, 770,
  605, 497, 461, 560, 404, 110, 224, 131, 104, -97, 155, 278, -154, -1165,
  -598, 737, 125, -592, 41, 11, -247, -10, 65, 92, 80, -304, 71, 167, -1, 122,
 233, 161, -43, 278, 479, 485, 407, 266, 650, 134, 80, 236, 68, 260, 269, 179,
 53, 140, 275, 293, 296, 104, 257, 152, 311, 182, 263, 245, 125, 314, 140, 44,
  203, 230, -235, -286, 23, 107, 92, -91, 38, 464, 443, 176, 98, -784, -2449,
  -1891, -1045, -1600, -1462, -1384, -1261, -949, -730
 };


 if (argc == 1)
  {
   usage();
   exit(1);
  }

 /* set up default values */

 strcpy(infile, "");
 strcpy(outfile, "");
 globals.quiet_flag = FALSE;
 globals.synthesis_model = ALL_PARALLEL;
 globals.samrate = 10000;
 globals.glsource = NATURAL;
 globals.natural_samples = natural_samples;
 globals.num_samples = NUMBER_OF_SAMPLES;
 globals.sample_factor = SAMPLE_FACTOR;
 nmspf_def = 10;
 globals.nfcascade = 0;
 globals.outsl = 0;
 globals.f0_flutter = 0;

 while ((c = getopt(argc, argv, "i:o:t:s:f:n:F:v:qch")) != EOF)
  {
   switch (c)
    {
     case 'i':
      strcpy(infile, optarg);
      break;
     case 'o':
      strcpy(outfile, optarg);
      break;
     case 'q':
      globals.quiet_flag = TRUE;
      break;
     case 't':
      globals.outsl = (flag) atoi(optarg);
      break;
     case 'c':
      globals.synthesis_model = CASCADE_PARALLEL;
      globals.nfcascade = 5;
      break;
     case 's':
      globals.samrate = atoi(optarg);
      break;
     case 'f':
      nmspf_def = atoi(optarg);
      break;
     case 'v':
      globals.glsource = (flag) atoi(optarg);
      break;
     case 'h':
      usage();
      exit(1);
      break;
     case 'n':
      globals.nfcascade = atoi(optarg);
      break;
     case 'F':
      globals.f0_flutter = atoi(optarg);
      break;
    }
  }

 globals.nspfr = (globals.samrate * nmspf_def) / 1000;

 if (strcmp(infile, "") == 0)
  {
   printf("Enter name of input parameter file: ");
   scanf("%s", infile);
  }

 infp = fopen(infile, "r");
 if (infp == NULL)
  {
   perror("can't open input file");
   exit(1);
  }

 if (strcmp(outfile, "") == 0)
  {
   outfp = stdout;
   globals.quiet_flag = TRUE;
  }
 else
  {
   outfp = fopen(outfile, "w");
   if (outfp == NULL)
    {
     perror("can't open output file");
     exit(1);
    }
  }

 icount = 0;
 done_flag = FALSE;
 parwave_init(&globals);
 frame_ptr = (long *) &frame;

 while (done_flag == FALSE)
  {
   for (par_count = 0; par_count < NPAR; ++par_count)
    {
     result = fscanf(infp, "%li", &value);
     frame_ptr[par_count] = value;
    }

   if (result == EOF)
    {
     done_flag = TRUE;
    }
   else
    {
     parwave(&globals, &frame, &iwave[0]);

     if (globals.quiet_flag == FALSE)
      {
       printf("\rFrame %i", icount);
       fflush(stdout);
      }

     for (isam = 0; isam < globals.nspfr; ++isam)
      {
       fprintf(outfp, "%i\n", iwave[isam]);
      }
     icount++;
    }
  }
 fclose(infp);
 fclose(outfp);

 if (globals.quiet_flag == FALSE)
  {
   printf("\nDone\n");
  }
}
