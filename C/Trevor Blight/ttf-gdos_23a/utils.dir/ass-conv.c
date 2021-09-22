/************* (c) 1997-2021 Trevor Blight ***************
*
* $Id: ass-conv.c 3271 2021-08-27 14:45:25Z trevor $
*
* translate assign.sys --> ttf-gdos.inf
* scan assign.sys, building info, then output data
*
******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>
#include <time.h>
#include <osbind.h>
#include "ttf-gdos.h"

typedef struct W_REC {	/* use this to build a list of device info */
   DEVICE_RECORD dev;
   struct D_REC  *d_next;
} D_REC;

typedef struct Gf_REC {	/* use this to build a list of gem font info */
   FILE_NAME     f_name;
   struct Gf_REC *f_next;
} Gf_REC;

typedef struct Tf_REC {	/* use this to build a list of true type font info */
   FONT_RECORD    ttf;
   struct Tf_REC *f_next;
} Tf_REC;

int line_nr;
char rstr[256];      /* read a line from assign.sys into this buffer */

void quit(char *s)
{
   printf("line %d: %s - quitting\n", line_nr, s);
   exit(1);
}

void exit_fn()
{
   Cconws( "finished! press a key ..." );
   (void)Cnecin();
   Cconws( "\r\n" );
} /* exit_fn() */


/***************************
* skip leading whitespace
* return pointer to first non-space char,
* or NULL iff only spaces ound
*/

char *skip( char *s )
{
   while( isspace(*s) ) s++;
   return *s != '\0' ? s : NULL;
} /* skip() */


/*****************************
*
* scan the input file, building the lists, etc as we go
* then write the output file
*/
int main( int argc, char *argv[] )
{
int   tcount;       /* nr tt fonts so far */
int   gcount;       /* nr gem fonts so far */
int   dcount;       /* nr devices so far */
FILE *fin;          /* input file (assign.sys) */
FILE *fout;         /* output file (ttf-gdos.inf) */
char path[256];     /* the gemsys path */
char title[256];    /* title for assign.sys */
char *pfnin;        /* input file name */
char *pfnout;       /* output filename */
D_REC  *d_head, **d_tail, *pdev;
Gf_REC *g_head, **g_tail, *pGfnt;
Tf_REC *t_head, **t_tail, *pTfnt;

TTF_GDOS_INF_RECORD head;

   /** set default values **/
   pfnin = argc > 1 ? argv[1] : "assign.sys";
   pfnout = argc > 2 ? argv[2] : INF_FILE;

   /** show sign on message **/
   printf( "ass-conv: converting %s to %s\n", pfnin, pfnout );


   /** initialise variables **/
   atexit( exit_fn );

   fin  = fopen( pfnin, "r" );
   if( fin == NULL ) {
      fprintf( stderr, "couldn't open file \"%s\"\n", pfnin );
      exit(1);
   } /* if */

   *path = '\0';
   *title = '\0';
   d_head = NULL;
   d_tail = &d_head;
   g_head = NULL;
   g_tail = &g_head;
   t_head = NULL;
   t_tail = &t_head;
   pdev = NULL;
   pTfnt = NULL;
   pGfnt = NULL;
   tcount = 0;
   gcount = 0;
   dcount = 0;


   /** loop thru each line of assign.sys until path statement found **/
   /** only comments and path statement allowed at start ... **/

   line_nr = 0;
   while( fgets( rstr, sizeof(rstr), fin ) != NULL ) {
   char *q = skip( rstr );
      ++line_nr;
      if( q == NULL ) continue;

      /** is this string a gem path? **/
      if( strlen(q) >= 4
        && tolower(q[0])=='p'
        && tolower(q[1])=='a'
        && tolower(q[2])=='t'
        && tolower(q[3])=='h' ) {
         q = strtok( q+4, " \t=\n" );
         if( q != NULL ) {
            if( strlen(q) > sizeof(path) - 1 ) {
               quit("gempath is too long");
            }
            strcpy( path, q );
         }
         else {
            quit( "error in path statement" );
         } /* if */
         break;
      }
      else if( *q == ';' ) {
      int i;
      char *s;
         /** found a comment line,
         **  if it is the first comment containing mostly text,
         **  use it for the title
         **/
         q = skip( ++q );
         if( q== NULL ) continue;
         for( i=0, s=q; *s!='\0'; s++ ) {
           if( isalnum(*s) ) i++;
         } /* for */
         if( (i>10) && (i+i >= strlen(q)) && (*title=='\0') ) {
            if( strlen(q) > sizeof(title) - 1 ) {
               quit("title is too long");
            }
            strcpy(title, q);
         } /* if */
      } /* if */
   } /* while */


   /** path statement found **/
   /** now scan for workstations, fonts and special info ... **/
   /** workstation definition lines start with a digit (eg 03p screen.sys) **/
   /** gem font files start with an alpha char **/
   /** special info is embedded inside comments **/

   while( fgets( rstr, sizeof(rstr), fin ) != NULL ) {
   char *q = skip( rstr );
      ++line_nr;
      if( q == NULL ) continue;

      if( isdigit(*q) ) {       /** is this string a workstation? **/
      char   ch = '\0';
      int    id;
      FILE_NAME   filename;
         *filename = '\0';
         sscanf(q, " %2d%c %s", &id, &ch, filename );
         if( *filename == '\0' ) {
            quit( "missing driver filename" );
         } /* if */
         if( strlen(filename) > MAX_FN_LEN ) {
            quit( "driver name is too long" );
         } /* if */
         if( pdev != NULL ) {  	/* counted before this ???, and where's first font ??? */
            pdev->dev.nr_gemfonts = gcount - pdev->dev.first_font;  /* finish font count for previous device */
         } /* if */
         pdev = malloc( sizeof(D_REC) );
         pdev->dev.id = id;
         strcpy( pdev->dev.driver_name, filename );
         pdev->d_next = NULL;
         *d_tail = pdev;
         d_tail = &pdev->d_next;
         pdev->dev.first_font = gcount;
         pdev->dev.nr_gemfonts = 0;
         ch = tolower(ch);
         pdev->dev.load_type = ch=='p'? PERMANENT: (ch=='r'? RESIDENT: DYNAMIC);
         dcount++;
      }
      else if( isalpha(*q) ) {
         /** must have found a gem font filename **/
         q = strtok( q, " \t\n" );
         pGfnt = malloc( sizeof(Gf_REC) );
         pGfnt->f_next = NULL;
         *g_tail = pGfnt;
         g_tail = &pGfnt->f_next;
         if( strlen(q) > MAX_FN_LEN ) {
            quit("font file name is too long");
         }
         strcpy( pGfnt->f_name, q );
         if( pdev != NULL ) {
            pdev->dev.nr_gemfonts++;	/* <<< should have defined a device */
         } /* if */
         gcount++;
      }
      else if( *q == ';' ) {
         /** look for ttf spec ... **/
         q = skip( ++q );
         if( q != NULL && *q == '&' ) {
         char *qfn;
         int   qid;
         int32 qmask = 0;
            q = strtok( ++q, " \t" );
            if( q == NULL ) {
               quit( "missing ttf name" );
            } /* if */
            qfn = q;

            q = strtok( NULL, " \t[()]," );
            if( q == NULL ) {
               quit( "missing font id" );
            } /* if */
            qid = atoi( q );

            q = strtok( NULL, " \t)]," );
            if( q == NULL ) {
               quit( "missing font sizes" );
            } /* if */

            do {
               int    s = atoi( q );
               int    p = 7;
               uint32 i;
               if( *q == ';' ) break;  /* comment found */
               if( (s>=p) && (s<p+32) ) {
                  i = 0x80000000L;
                  while( s>p ) {
                     p++;
                     i >>= 1;
                  } /* while */
                  qmask |= i;
               } /* if */
            } while( (q = strtok( NULL, " \t\n," )) != NULL );

            pTfnt = malloc( sizeof(Tf_REC) );
            pTfnt->f_next = NULL;
            *t_tail = pTfnt;
            t_tail = &pTfnt->f_next;
            if( strlen(qfn) > MAX_FN_LEN ) {
                 quit("ttf file name is too long");
            }
            strcpy( pTfnt->ttf.font_name, qfn );
            pTfnt->ttf.id = qid;
            pTfnt->ttf.psize_mask = qmask;
            tcount++;
         }
         else if( q != NULL /* && *q++ == '@' */ ) {
            /** look for cache size spec ... **/
            q = strtok( q, " \t=\n" );	/* look for cache specifier */
            if( q != NULL
              && strlen(q) >= 5
              && tolower(q[0])=='c'
              && tolower(q[1])=='a'
              && tolower(q[2])=='c'
              && tolower(q[3])=='h'
              && tolower(q[4])=='e' ) {
               q = strtok( NULL, " \t=\n" );
               if( q == NULL ) {
                  quit( "missing size in cache definition" );
               } /* if */
               head.cache_size = atoi( q );
            } /* if */
         } /* if */
      } /* if */

   } /* while */

   /*** end of assign.sys ***/

   fclose( fin  );

   /*** check for minimum assign.sys ***/

   if( *path == '\0' ) {
      quit( "path not defined!!" );
   } /* if */

   if( dcount <= 0 ) {
      quit( "no devices defined!!\n" );
   } /* if */

   /*** now ready to write out inf file ***/

   fout = fopen( pfnout, "wb" );
   if( fout == NULL ) {
      fprintf( stderr, "couldn't open file \"%s\"\n", pfnout );
      exit(1);
   } /* if */

   {
   register char *pp = path+strlen(path);
   if( pp[-1] != '\\' ) {
      strcpy( pp, "\\" );
   } /* if */
   }

   if( *title == '\0' )
   {
      sprintf( title, "%s created from %s\n", pfnout, pfnin );
   } /* if */

   printf( title );
   printf( "path is %s\n", path );
   printf( "cache size is %dk bytes\n", head.cache_size );

   head.magic_nr = MAGIC_NR;
   head.version = MY_VERSION;
   head.len_gem_path = strlen(path);
   head.file_len = sizeof(head) + dcount*sizeof(DEVICE_RECORD)
                                + gcount*sizeof(FILE_NAME)
                                + tcount*sizeof(FONT_RECORD)
                                + strlen(path)
                                + strlen(title)+1;

   head.nr_gemfonts = gcount;
   head.nr_ttfonts = tcount;
   head.nr_devices = dcount;

   if( fwrite( &head, sizeof(head), 1, fout ) < 1 )
   {
      fprintf( stderr, "error writing to %s\n", pfnout );
      exit(1);
   } /* if */

   printf( "there are %d devicess, %d fonts\n", dcount, gcount );
   for( pdev = d_head; pdev!=NULL; pdev=pdev->d_next) {
      if( fwrite( &pdev->dev, sizeof(pdev->dev), 1, fout ) < 1 )
      {
         fprintf( stderr, "error writing to %s\n", pfnout );
      } /* if */
      printf("size of load_type is %d\n", (int)sizeof(pdev->dev.load_type) );

      printf( "device id %d, %s, driver is %s, ",
         pdev->dev.id,
         pdev->dev.load_type == PERMANENT ? "permanent" : (pdev->dev.load_type==RESIDENT ? "resident" : "dynamic"),
         pdev->dev.driver_name );
      if( pdev->dev.nr_gemfonts > 0 ) {
         printf( "nr fonts is %d, first is %d\n", pdev->dev.nr_gemfonts, pdev->dev.first_font );
      }
      else {
         printf( "no fonts\n" );
      } /* if */
   } /* for */

   for( pTfnt = t_head; pTfnt!=NULL; pTfnt=pTfnt->f_next) {
   int32 m = pTfnt->ttf.psize_mask;
   int   pi = 7;
      if( fwrite( pTfnt->ttf.font_name, sizeof(FONT_RECORD), 1, fout ) < 1 )
      {
         fprintf( stderr, "error writing to %s\n", pfnout );
         exit(1);
      } /* if */
      printf( "true type font is %s, (id=%d), sizes are", pTfnt->ttf.font_name, pTfnt->ttf.id );
      while( m != 0 ) {
         if( m<0 ) {
            printf( m==0x80000000L? " %d": " %d,", pi );
         } /* if */
         pi++;
         m <<= 1;
      } /* while */
      printf( "\n" );
   } /* for */

   for( pGfnt = g_head; pGfnt!=NULL; pGfnt=pGfnt->f_next) {
      if( fwrite( pGfnt->f_name, sizeof(FILE_NAME), 1, fout ) < 1 )
      {
         fprintf( stderr, "error writing to %s\n", pfnout );
         exit(1);
      } /* if */
      printf( "font is %s\n", pGfnt->f_name );
   } /* for */

   if( fwrite( path, strlen(path), 1, fout ) < 1 )
   {
       fprintf( stderr, "error writing to %s\n", pfnout );
       exit(1);
   } /* if */
   if( fwrite( title, strlen(title)+1, 1, fout ) < 1 )
   {
      fprintf( stderr, "error writing to %s\n", pfnout );
      exit(1);
  } /* if */

   printf( "file length sb %d\n", (int)head.file_len );

   fclose( fout  );

   exit(0);

} /* main() */

/******************* end of ass-conv.c *********************/
