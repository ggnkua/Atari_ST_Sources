/* oozext.c -- lists files from archive */

/* The contents of this file are hereby released to the public domain.

                                   -- Rahul Dhesi 1987/02/08
*/

#include "options.h"
#include "zoo.h"
#include "oozio.h"
#include "func.h"

int oozext (zoo_path, listing_fd)
char *zoo_path;
FILE *listing_fd;
{
int zoo_han;                              /* handle for open archive */
long next_ptr;                            /* pointer to within archive */
struct zoo_header zoo_header;             /* header for archive */
int status;                               /* error status */
struct direntry direntry;                 /* directory entry */

int first_time = 1;
static char *month_list="000JanFebMarAprMayJunJulAugSepOctNovDec";

{
   /* If no dot in name, add ".zoo" extension */
   char *p;
   p = zoo_path;
   while (*p != '\0' && *p != '.')
      p++;
   if (*p != '.') {  /* no dot found */
      p = malloc (strlen (zoo_path) + 5);
      if (p == (char *) 0) {
			fprintf(listing_fd, "Ran out of memory\r\n");
			fclose(listing_fd);
         exit(1);
		}
      strcpy (p, zoo_path);
      strcat (p, ".zoo");
      zoo_path = p;
   }
}

zoo_han = OPEN(zoo_path);

if (zoo_han == -1) {
   fprintf (listing_fd, "Could not open %s\r\n", zoo_path);
	fclose(listing_fd);
	exit(1);
}

/* read header */
rd_zooh (&zoo_header, zoo_han);
lseek (zoo_han, zoo_header.zoo_start, 0); /* seek to where data begins */

while (1) {
   rd_dir (&direntry, zoo_han);

   if (direntry.lo_tag != LO_TAG || direntry.hi_tag != HI_TAG) {
         fprintf (listing_fd, "Bad entry in archive\r\n");
			fclose(listing_fd);
			exit(1);
	}
   if (direntry.next == 0L) {                /* END OF CHAIN */
      break;                                 /* EXIT on end of chain */
   }
   next_ptr = direntry.next;                 /* ptr to next dir entry */

  /* If list needed, give information and loop again */
   {
      char outstr[80];
      char buf[20];
      int year, month, day, hours, min, sec;
      int size_factor;
      size_factor = cfactor (direntry.org_size, direntry.size_now);
   
      year  =  ((unsigned int) direntry.date >> 9) & 0x7f;
      month =  ((unsigned int) direntry.date >> 5) & 0x0f;
      day   =  direntry.date        & 0x1f;
      
      hours =  ((unsigned int) direntry.time >> 11)& 0x1f;
      min   =  ((unsigned int) direntry.time >> 5) & 0x3f;
      sec   =  ((unsigned int) direntry.time & 0x1f) * 2;

      if (first_time) {
         fprintf (listing_fd,"Length    CF  Size Now  Date       Time\r\n");
         fprintf (listing_fd,"--------  --- --------  ---------- --------\r\n");
         first_time = 0;
      }

      fprintf (listing_fd, "%8lu %3u%% %8lu  %2d %-.3s %02d %02d:%02d:%02d  ",  
               direntry.org_size, 
               size_factor, direntry.size_now, 
               day, &month_list[month*3], 
               (day && month) ?  (year+80) % 100 : 0,
               hours, min, sec);
      fprintf (listing_fd, "%s\r\n", direntry.fname);

	}
   lseek (zoo_han, next_ptr, 0); /* ..seek to next dir entry */
} /* end while */
close (zoo_han);
fclose(listing_fd);
exit(0);
} /* end oozext */

/* cfactor() calculates the compression factor given a directory entry */
int cfactor (org_size, size_now)
long org_size, size_now;
{
   register int size_factor;

   while (org_size > 10000) { /* avoid overflow below */
      org_size = org_size >> 4;
      size_now = size_now >> 4;
   }
   if (org_size == 0)         /* avoid division by zero */
      size_factor = 0;
   else {
      size_factor = 
         (
            (1000 * 
               (org_size - size_now)
            ) / org_size + 5
         ) / 10;
   }
   return (size_factor);
}


