/************* (c) 1997-2000 Trevor Blight ***************
*
* $Id: ass-conv.c 1.13 2001/03/23 22:09:52 tbb Exp $
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

typedef struct W_REC {	/* use this to build a list of workstation info */
   WORKSTN_RECORD wk;
   struct W_REC  *w_next;
} W_REC;

typedef struct Gf_REC {	/* use this to build a list of gem font info */
   FILE_NAME     f_name;
   struct Gf_REC *f_next;
} Gf_REC;

typedef struct Tf_REC {	/* use this to build a list of true type font info */
   FONT_RECORD    ttf;
   struct Tf_REC *f_next;
} Tf_REC;

char rstr[256];      /* read a line from assign.sys into this buffer */


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
int   wcount;       /* nr wkstns so far */
FILE *fin;          /* input file (assign.sys) */
FILE *fout;         /* output file (ttf-gdos.inf) */
char path[256];     /* the gemsys path */ 
char title[256];    /* title for assign.sys */
char *pfnin;        /* input file name */
char *pfnout;       /* output filename */
W_REC  *w_head, **w_tail, *pws;
Gf_REC *g_head, **g_tail, *pGfnt;
Tf_REC *t_head, **t_tail, *pTfnt;

TTF_GDOS_INF_RECORD head;

   /** set default values **/
   pfnin = argc > 1 ? argv[1] : "assign.sys";
   pfnout = argc > 2 ? argv[2] : INF_FILE;

   /** show sign on message **/
   printf( "ass-conv: $Revision: 1.13 $\nconverting %s to %s\n", pfnin, pfnout );   


   /** initialise variables **/
   atexit( exit_fn );
   
   fin  = fopen( pfnin, "r" );
   if( fin == NULL ) {
      fprintf( stderr, "couldn't open file \"%s\"\n", pfnin );
      exit(1);
   } /* if */

   *path = '\0';
   *title = '\0';
   w_head = NULL;
   w_tail = &w_head;
   g_head = NULL;
   g_tail = &g_head;
   t_head = NULL;
   t_tail = &t_head;
   pws = NULL;
   pTfnt = NULL;
   pGfnt = NULL;
   tcount = 0;
   gcount = 0;
   wcount = 0;


   /** loop thru each line of assign.sys until path statement found **/
   /** only comments and path statement allowed at start ... **/

   while( fgets( rstr, sizeof(rstr), fin ) != NULL ) {
   char *q = skip( rstr );
      if( q == NULL ) continue;

      /** is this string a gem path? **/
      if( strlen(q) >= 4
        && tolower(q[0])=='p'
        && tolower(q[1])=='a'
        && tolower(q[2])=='t'
        && tolower(q[3])=='h' ) {
         q = strtok( q+4, " \t=\n" );
         if( q != NULL ) {
            strcpy( path, q );
         }
         else {
            fprintf( stderr, "error in path statement\n" );
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
      if( q == NULL ) continue;

      if( isdigit(*q) ) {       /** is this string a workstation? **/
      char   ch = '\0';
      int    id;
      FILE_NAME   filename;
         *filename = '\0';
         sscanf(q, " %2d%c %s", &id, &ch, filename );
         if( strlen(filename) >= sizeof(filename) ) {
            fprintf( stderr, "workstation name too long in line \"%s\"\n", q );
            continue;
         } /* if */
         if( *filename == '\0' ) {
            fprintf( stderr, "driver filename not found in %s\n", q );
            continue;
         } /* if */
         if( pws != NULL ) {  	/* counted before this ???, and where's first font ??? */
            pws->wk.nr_gemfonts = gcount - pws->wk.first_font;  /* finish font count for previous wkstn */
         } /* if */
         pws = malloc( sizeof(W_REC) );
         pws->wk.id = id;
         strcpy( pws->wk.driver_name, filename );
         pws->w_next = NULL;
         *w_tail = pws;
         w_tail = &pws->w_next;
         pws->wk.first_font = gcount;
         pws->wk.nr_gemfonts = 0;
         ch = tolower(ch);
         pws->wk.load_type = ch=='p'? PERMANENT: (ch=='r'? RESIDENT: DYNAMIC);
         wcount++;
      }
      else if( isalpha(*q) ) {   
         /** must have found a gem font filename **/
         q = strtok( q, " \t\n" );
         pGfnt = malloc( sizeof(Gf_REC) );
         pGfnt->f_next = NULL;
         *g_tail = pGfnt;
         g_tail = &pGfnt->f_next;
         strcpy( pGfnt->f_name, q );
         if( pws != NULL ) {
            pws->wk.nr_gemfonts++;	/* <<< should have defined a workstation */
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
               fprintf( stderr, "no ttf name found in ttf spec\n" );
               continue;
            } /* if */
            qfn = q;

            q = strtok( NULL, " \t[()]," );
            if( q == NULL ) {
               fprintf( stderr, "no font id found in %s\n", qfn );
               continue;
            } /* if */
            qid = atoi( q );

            q = strtok( NULL, " \t)]," );
            if( q == NULL ) {
               fprintf( stderr, "no font sizes found for %s\n", qfn );
               continue;
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
            strcpy( pTfnt->ttf.font_name, qfn );
            pTfnt->ttf.id = qid;
            pTfnt->ttf.psize_mask = qmask;
            tcount++;
         }
         else if( q != NULL /* && *q++ == '@' */ ) {
         char *qfn = q;
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
		  fprintf( stderr, "no size found in cache line\n", qfn );
		  continue;
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
      fprintf( stderr, "path not defined!!\n" );
      exit(-1);
   } /* if */

   if( wcount <= 0 ) {
      fprintf( stderr, "no workstations defined!!\n" );
      exit(-1);
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
   head.file_len = sizeof(head) + wcount*sizeof(WORKSTN_RECORD) 
                                + gcount*sizeof(FILE_NAME)
                                + tcount*sizeof(FONT_RECORD)
                                + strlen(path) 
                                + strlen(title)+1;

   head.nr_gemfonts = gcount;
   head.nr_ttfonts = tcount;
   head.nr_wkstns = wcount;

   if( fwrite( &head, sizeof(head), 1, fout ) < 1 )
   {
      fprintf( stderr, "error writing to %s\n", pfnout );
   } /* if */

   printf( "there are %d wkstns, %d fonts\n", wcount, gcount );
   for( pws = w_head; pws!=NULL; pws=pws->w_next) {
      if( fwrite( &pws->wk, sizeof(pws->wk), 1, fout ) < 1 )
      {
         fprintf( stderr, "error writing to %s\n", pfnout );
      } /* if */
      printf( "wkstn id %d, %s, driver is %s, ", 
         pws->wk.id, 
         pws->wk.load_type == PERMANENT ? "permanent" : (pws->wk.load_type==RESIDENT ? "resident" : "dynamic"),
         pws->wk.driver_name );
      if( pws->wk.nr_gemfonts > 0 ) {
         printf( "nr fonts is %d, first is %d\n", pws->wk.nr_gemfonts, pws->wk.first_font );
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
      } /* if */
      printf( "font is %s\n", pGfnt->f_name );
   } /* for */

   if( fwrite( path, strlen(path), 1, fout ) < 1 )
   {
      fprintf( stderr, "error writing to %s\n", pfnout );
   } /* if */
   if( fwrite( title, strlen(title)+1, 1, fout ) < 1 )
   {
      fprintf( stderr, "error writing to %s\n", pfnout );
   } /* if */

   printf( "file length sb %d\n", (int)head.file_len );

   fclose( fout  );

   exit(0);

} /* main() */

/******************* end of ass-conv.c *********************/
