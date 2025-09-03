#define  VERSION  "Version 1.0 (1989/07/03)\r\n"

/* 
The contents of this file are hereby released to the public domain.

                                   -- Rahul Dhesi 1988/08/25
*/

#include "options.h"
#include "func.h"
#include "zoo.h"

main(argc,argv)
register int argc;
register char **argv;
{
	FILE *listing_fd;
   static char usage[]= "Usage:  zoolist archive[.zoo] listing-file\r\n";

   if (argc < 2) {
      fprintf(stdout,"Public domain Barebones Zoolist\nZoo archive lister\r\n");
      fprintf(stdout, VERSION);
      fprintf(stdout, usage);
      exit (1);
   }

	if (argc < 3)
		listing_fd = stdout;
	else if ((listing_fd = fopen(argv[2], "w")) == (FILE *) NULL) {
				fprintf(stdout, "Error can not open [%s]\r\n", argv[2]);
				fprintf(stdout, usage);
				exit(1);
			}
	oozext (argv[1], listing_fd);
	fclose(listing_fd);

   exit (0);
}

/******
Function itoa() converts a positive long integer into a text string of
digits.  The buffer pointer buf must point to a buffer to receive the
digit string.  The digit string is stored right justified in the
buffer with leading blanks.  If the supplied number is negative, or if
overflow occurs, a single '*' is returned.
*/

char *itoa (pad_ch, n, buf, buflen)
char pad_ch;                  /* leading pad character */
long n;                       /* positive long int to convert */
char *buf;                    /* buffer to receive digit string */
int buflen;                   /* length of buffer */
{
   char *p;
   int i;
   for (i = 0;  i < buflen;  i++)         /* fill buffer with pad char */
      buf[i] = pad_ch;
   p = buf + buflen - 1;
   *p-- = '\0';                           /* ensure null termination */
   i = buflen - 1;
   for (;;) {
      if (n < 0) {                        /* can't handle negative n */
         goto overflow;
      } else {
         *p-- = (int) (n % 10) + '0';     /* store a converted digit */
         n = n / 10;
         i--;
         if (n == 0 || i == 0)
            break;
      } /* end of else of if (n < 0) */
   } /* end while (buflen > 0) */
   if (n != 0)                            /* buffer overflow */
      goto overflow;
   return (buf);

overflow:                                 /* bad value filled with stars */
   for (i = 0; i < buflen; i++)
      buf[i] = '*';
   buf[buflen-1] = '\0';
   return (buf);
}

