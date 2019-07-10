/*
 *	unx2st program.
 *
 *		Converts UNIX-like end-of-lines to ST's end-of-lines,
 *		but does not change the file creation/modification time
 *
 *	This program is freely redistributable. You may modify and use this
 *	program to your heart's content, so long as you send modifications
 *	to Robert Stabl. It can be included in any distribution, commercial 
 *	or otherwise, so long as the banner string defined in the constant
 *	HEADER is not modified (except for the version number) and this banner
 *	is printed on programs invocation, or can be printed on programs
 *	invocation with the -? option.
 *
 *      16.07.90        (C) copyright Robert Stabl.
 *
 *	Compiled with gcc V1.37.1:
 *		Many thanks to Jwahar R. Bammi for gcc and the very, very
 *		useful UNIX-like libraries.
 *
 *	Email address: stabl@unipas.fmi.uni-passau.de
 *
 */

#include <stdio.h>
#include <stat.h>
#include <types.h>
#include <unixlib.h>
#include <stdlib.h>
#include <fcntl.h>

#define BLOCKSIZE 32768L
#define VERSION		"1.00"
#define HEADER		"unx2st - Version %s \275 1990 Robert Stabl\n"

static void usage(void)
{
 fprintf(stderr, HEADER, VERSION);
 fprintf(stderr, "usage: unx2st file ...\n");
}

int main(int argc, char *argv[])
{
 int i;
 char temp [] = "rbsXXXXX";
 struct stat filestat;
 struct utimbuf filetime;
 char *src, *dest;
 char *sp, *dp;
 int fs, fd;
 long sc, dc;
 size_t sr, dw;
 long j;
 int rets;

 if (argc < 2)
  {
   usage();
   return(1);
  }

 mktemp(temp);

 for (i= 1; i <argc; i++)
  {
   rets = stat(argv[i], &filestat);
   if (rets < 0)
    {
     perror(argv[i]);
     continue;
    }
   
   src = (char *)malloc((size_t)BLOCKSIZE);
   if (src == NULL)
    {
     fprintf(stderr, "Can't allocate enough memory\n");
     exit(1);
    }
   dest = (char *)malloc((size_t)(BLOCKSIZE*2));
   if (dest == NULL)
    {
     fprintf(stderr, "Can't allocate enough memory\n");
     exit(1);
    }
   
   fs = open(argv[i], O_RDONLY);
   if (fs < 0)
    {
     perror(argv[i]);
     continue;
    }
   fd = creat(temp, 0777);
   if (fs < 0)
    {
     perror(temp);
     exit(1);
    }

   while (1)
    {
     sr = read(fs, src, BLOCKSIZE);
     if (sr < (size_t)0)
      {
       perror(argv[i]);
       exit(1);
      }
   
     if (sr == (size_t)0)
      {
       break;
      }

     sp = src;
     dp = dest;

     dc = 0;

     for (j=0; j<sr; j++)
      {
       if (*sp == 10)
        {
         *dp = 13;
         dp++;
         dc++;
        }
       *dp = *sp;
       sp++;
       dc++;
       dp++;
      }

     dw = write(fd, dest, dc);

     if (dw != dc)
      {
       perror(temp);
       close(fd);
       unlink(temp);
       exit(1);
      }
    }
   
   close(fd);
   close(fs);

   filetime.axtime = filestat.st_atime;
   filetime.modtime = filestat.st_mtime;

   unlink(argv[i]);
   rename(temp, argv[i]);
   utime(argv[i], &filetime);
  }
 return(0);
}
