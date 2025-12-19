/*
 * COMBINEDUMP.C
 *
 * Written by Ville Saari
 *
 * Copyright (c) 1991 Ferry Island Pixelboys
 * All rights reserved
 *
 * Created: 06-Jan-91
 * Updated: 31-Jan-91
 *
 * Updated: 07-May-91 - Aaron A. Collins - Made somewhat more portable, and
 * made the program write out to a file instead of stdout.
 */

#define VERSION "1.10"

#define COPYRIGHT \
   "\033[33;1mCOMBINEDUMP\033[0m V" VERSION " by Ville Saari.\n"\
   "Copyright (c) 1991 Ferry Island Pixelboys.\n"\
   "Freeware.\n"

#define USAGE \
   "\n" \
   "Usage: combinedump [-l(R|G|B)] [-r(R|G|B)]"\
   " [-c((l|r)((t|b)<value>)...)...]\n"\
   "                  <leftfile> <rightfile> <outfile>\n\n"\
   "Defaults: -lR -rG -clt34b85rt0b51\n"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

#define R 0
#define G 1
#define B 2
#define BUFSIZE 16384L

FILE *lfile = NULL, *rfile = NULL, *ofile = NULL;

long left=R, lbot=85, ltop=34;
long right=G, rbot=51, rtop=0;

long readval(FILE *file)
   {
   long x;

   x=fgetc(file);
   x|=fgetc(file)<<8;

   return x;
   }

void writeval(long x, FILE *file)
   {
   putc((char)x, file);
   putc((char)(x>>8), file);
   }

long getrgb(char ch)
   {
   switch(ch|0x20)
      {
      case 'r':
         return R;
      case 'g':
         return G;
      case 'b':
         return B;
      default:
         return -1;
      }
   }

void error(char *text, int code)
   {
   if(code) fputs("COMBINEDUMP: ", stderr);
   fputs(text, stderr);
   fflush(stderr);
   if (ofile != NULL)
	  {
	  fflush(ofile);
	  fclose(ofile);
	  }
   if (lfile != NULL)
	  fclose(lfile);
   if (rfile != NULL)
	  fclose(rfile);
   exit(code);
   }

void main(int ac, char **arg)
   {
   char *lname=NULL, *rname=NULL, *oname=NULL;
   unsigned char *lbuf, *rbuf;
   long f, n, l, r, t, b, val;
   long width, height, buflines, bufsize, linesize, bufplace;
   long lcol, rcol;
   long lbc, rbc, lsc, rsc;
   long ofs[3];

   fputs(COPYRIGHT, stderr);

   if(ac < 4 || arg[1][0] == '?')
	   error(USAGE, 0);

   for(f=1; f<ac; f++)
      {
      if(arg[f][0]!='-')
         {
         if(!lname) lname=arg[f];
         else
            {
			if(!rname) rname=arg[f];
			else
				{
				if(!oname) oname=arg[f];
				else error("Too many arguments.\n", 20);
				}
			}
		}
      else
         {
         switch(arg[f][1])
            {
            case 'l':
               if((left=getrgb(arg[f][2]))<0)
                  error("Illegal '-l' switch.\n", 20);
               break;
            case 'r':
               if((right=getrgb(arg[f][2]))<0)
				  error("Illegal '-r' switch.\n", 20);
               break;
            case 'c':
               n=2, l=r=t=b=0;
               while(arg[f][n])
                  {
                  switch(arg[f][n])
                     {
                     case 'l':
                        l=1, r=0, n++;
                        break;
                     case 'r':
                        l=0, r=1, n++;
                        break;
                     case 't':
                        t=1, b=0, n++;
                        break;
                     case 'b':
                        t=0, b=1, n++;
                        break;
                     default:
                        if(isdigit(arg[f][n])) val=0; else val=-1;
                        for(; isdigit(arg[f][n]); n++)
                           val=10*val+arg[f][n]-'0';
                        if(!l && !r || !t && !b || val<0 || val>255)
                           error("Illegal '-c' switch.\n", 20);
                        if(l && b) lbot=val;
                        if(l && t) ltop=val;
                        if(r && b) rbot=val;
                        if(r && t) rtop=val;
                     }
                  }
               break;
            default:
               error("Illegal switch.\n", 20);
			}
         }
      }

   if((lfile=fopen(lname, "rb"))==NULL)
      error("Can't open left input file.\n", 20);

   if((rfile=fopen(rname, "rb"))==NULL)
      error("Can't open right input file.\n", 20);

   if((ofile=fopen(oname, "wb"))==NULL)
      error("Can't open output file.\n", 20);

   if((width=readval(lfile))!=readval(rfile) ||
      (height=readval(lfile))!=readval(rfile))
         error("Input files are incompatible.\n", 20);

   linesize=2+3*width;

   if((buflines=BUFSIZE/linesize)<0)
    error("Too long input lines.\n", 20);

   bufsize=buflines*linesize;

   if((lbuf = (unsigned char *)malloc((unsigned long)(buflines*linesize)))==(unsigned char *)0)
    error("Can't allocate memory for buffers.\n", 20);
   if((rbuf = (unsigned char *)malloc((unsigned long)(buflines*linesize)))==(unsigned char *)0)
    error("Can't allocate memory for buffers.\n", 20);
   writeval(width, ofile);
   writeval(height, ofile);

#ifndef NOANSICODES
   fprintf(stderr, "\033[0mProcessing line:      of %-5d\033[14D", (int)height);
#endif

   for(f=0, bufplace=0; f<height; f++)
      {
      if(bufplace==0)
         if(!fread((char *)lbuf, (unsigned int)linesize, (unsigned int)buflines, lfile) ||
            !fread((char *)rbuf, (unsigned int)linesize, (unsigned int)buflines, rfile))
				error("Input files are incomplete.\n", 20);

      if(lbuf[bufplace]!=rbuf[bufplace] ||
         lbuf[bufplace+1]!=rbuf[bufplace+1])
			 error("Line numbers don't match.\n", 20);

#ifndef NOANSICODES
      fprintf(stderr, "%5d\033[5D", (int)f+1);
#endif

      ofs[0]=bufplace+2; ofs[1]=bufplace+2+width; ofs[2]=bufplace+2+2*width;

      for(n=0; n<width; n++)
         {
         lcol=lbuf[ofs[2]]+(lbuf[ofs[0]]<<1)+(lbuf[ofs[1]]<<2);
         rcol=rbuf[ofs[2]]+(rbuf[ofs[0]]<<1)+(rbuf[ofs[1]]<<2);

         rbc=(1785-lcol)*rbot/1786;
         lbc=(1785-rcol)*lbot/1786;
         rsc=255-lcol*rtop/1786-rbc;
         lsc=255-rcol*ltop/1786-lbc;

         lcol=lbc+lcol*lsc/1786;
         rcol=rbc+rcol*rsc/1786;

         lbuf[ofs[0]]=lbuf[ofs[1]]=lbuf[ofs[2]]=0;

         lbuf[ofs[left]]=(char)lcol;
         lbuf[ofs[right]]=(char)rcol;

         ofs[0]++, ofs[1]++, ofs[2]++;
         }

      if((bufplace+=linesize)>=bufsize || f==height-1)
         {
         if(!(fwrite(lbuf, (unsigned int)bufplace, 1, ofile)))
             error("Error when writing output file.\n", 20);
         bufplace=0;
         }
      }
#ifndef NOANSICODES
   fputs("\033[0m\n", stderr);
#endif
   }
