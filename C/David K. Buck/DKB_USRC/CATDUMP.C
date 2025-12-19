/*
 * CATDUMP.C
 *
 * Written by Ville Saari
 *
 * Copyright (c) 1991 Ferry Island Pixelboys
 * All rights reserved
 *
 * Created: 26-Dec-90
 * Updated: 31-Jan-91
 *
 * Updated: 07-May-91 - Aaron A. Collins - Made somewhat more portable, and
 * made the program write out to a file instead of stdout.
 */

#define VERSION "1.10"

#define COPYRIGHT \
   "\033[33;1mCATDUMP\033[0m V" VERSION " by Ville Saari.\n"\
   "Copyright (c) 1991 Ferry Island pixelboys.\n"\
   "Freeware.\n"

#define USAGE \
   "\n" \
   "Usage: catdump <in-file1> <in-file2> [<in-file3>...] <out-file>\n"

/* #define NOANSICODES 1 */		/* uncomment if you don't want ANSI */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define min(a, b)   ((a) < (b) ? (a) : (b))
#define max(a, b)   ((a) > (b) ? (a) : (b))


#define BUFSIZE 32768L

FILE *outfile = NULL;

struct 
   {
   char *fn;
   FILE *fp;
   long width, height;
   long startline, endline;
   } infile[30];

long width, height, startline=0x7fffffffL, endline=0L;

char buf[81];
char *buffer;

void error(char *text, int code)
   {
   if(code) fputs("CATDUMP: ", stderr);
   fputs(text, stderr);
   if (outfile != NULL)
	  {
	  fflush(outfile);
	  fclose(outfile);
	  }
   exit(code);
   }

void main(int ac, char **arg)
   {
#ifndef NOANSICODES
   long prev;
#endif
   long f, ct=0, first, ok, line, linesize, bufp, buflines;

   fputs(COPYRIGHT, stderr);

   if(ac < 4 || arg[1][0] == '?' || arg[1][0] == '-')
      error(USAGE, 0);

  for(f=1; f<ac; f++)
      {
      if(f == ac - 1)
         {
	    if ((outfile = fopen(arg[f], "wb")) == NULL)
	       error("Couldn't open output file\n", 20);
	    continue;
	 }
      infile[ct].fn=arg[f];
      if((infile[ct].fp=fopen(infile[ct].fn, "rb"))!=NULL)
         {
         if(fread(buf, 6, 1, infile[ct].fp))
            {
            fseek(infile[ct].fp, 0L, 2);
            infile[ct].width=(unsigned char)buf[0]|((unsigned char)buf[1]<<8);
            infile[ct].height=(unsigned char)buf[2]|((unsigned char)buf[3]<<8);
            infile[ct].startline=(unsigned char)buf[4]|((unsigned char)buf[5]<<8);
            infile[ct].endline=infile[ct].startline+(ftell(infile[ct].fp)-4)/(infile[ct].width*3+2);

            ok=1;

            if(!ct)
               {
               first=f;
               width=infile[ct].width;
               linesize=width*3+2;
               }
            else
               if(width!=infile[ct].width)
                  {
                  ok=0;
                  fprintf(stderr, "CATDUMP: File '%s' incompatible with '%s'.\n",
                     infile[ct].fn, arg[first]);
                  fflush(stderr);
                  }

            if(ok)
               {
               height=max((long)infile[ct].height, height);
               startline=min((long)infile[ct].startline, startline);
               endline=max((long)infile[ct].endline, endline);

               ct++;
               }
            }
         else
            {
            infile[ct].fp=0;
            fprintf(stderr, "CATDUMP: File '%s' is not a valid DKB/QRT Dump file.\n", infile[ct].fn);
            fflush(stderr);
            }
         }
      else
         {
         fprintf(stderr, "CATDUMP: Couldn't open file '%s'.\n", infile[ct].fn);
         fflush(stderr);
         }
      }

   if(!ct) error("No valid input files.\n", 20);

   fprintf(outfile,"%c%c%c%c", (char)width, (char)(width>>8), (char)height, (char)(height>>8));

   buflines=BUFSIZE/linesize;
   if((buffer=malloc((unsigned int)(linesize*buflines)))==NULL)
      error("Couldn't allocate memory for buffer.\n", 20);
   bufp=0;

#ifndef NOANSICODES
   prev=-2;
#endif

   for(line=startline; line<endline; line++)
      {
      for(f=ct-1; f>=0 && (infile[f].startline > line || infile[f].endline <= line); f--);

#ifndef NOANSICODES
      if(f!=prev)
         {
         if(prev!=-2) fputs("\n", stderr);
         if(f==-1)
            fprintf(stderr, "Lines%5d to      zeroed.\033[13D", (int)line);
         else
            fprintf(stderr, "Lines%5d to      copied from file '%s'.\r\033[13C",
               (int)line, infile[f].fn);
         prev=f;
         }
#endif

      if(f>=0)
         {
         fseek(infile[f].fp, 4L+linesize*(line-infile[f].startline), 0);
         if(!fread(buffer+bufp, (unsigned int)linesize, 1, infile[f].fp) ||
		    (long)((unsigned char)buffer[bufp]|((unsigned char)buffer[bufp+1]<<8))!=line)
            {
            free(buffer);
            fputs("\n", stderr);
            sprintf(buf, "Error while reading input file '%s'.\n", infile[f].fn);
            error(buf, 20);
            }
         }
      else
         {
         memset(buffer+bufp, 0, (unsigned int)linesize);
         buffer[bufp]=(char)line, buffer[bufp+1]=(char)(line>>8);
         }

      if((bufp+=linesize)>=linesize*buflines || line>=endline-1)
         {
         if(!fwrite(buffer, (unsigned int)bufp, 1, outfile))
            {
            free(buffer);
            fputs("\n", stderr);
            error("Error while writing output file.\n", 20);
            }
         bufp=0;
         }

#ifndef NOANSICODES
      fprintf(stderr, "%5d\033[5D", (int)line);
      fflush(stderr);
#endif

      }
   fputs("\n", stderr);

   for(f=0; f<ct; f++) fclose(infile[f].fp);
   free(buffer);
   }
