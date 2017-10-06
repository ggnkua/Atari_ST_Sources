/***************************************************************

        bwb_dio.c       Device Input/Output Routines
                        for Bywater BASIC Interpreter

                        Copyright (c) 1992, Ted A. Campbell

                        Bywater Software
                        P. O. Box 4023
                        Duke Station
                        Durham, NC  27706

                        email: tcamp@acpub.duke.edu

        Copyright and Permissions Information:

        All U.S. and international copyrights are claimed by the
        author. The author grants permission to use this code
        and software based on it under the following conditions:
        (a) in general, the code and software based upon it may be
        used by individuals and by non-profit organizations; (b) it
        may also be utilized by governmental agencies in any country,
        with the exception of military agencies; (c) the code and/or
        software based upon it may not be sold for a profit without
        an explicit and specific permission from the author, except
        that a minimal fee may be charged for media on which it is
        copied, and for copying and handling; (d) the code must be
        distributed in the form in which it has been released by the
        author; and (e) the code and software based upon it may not
        be used for illegal activities.

***************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "bwbasic.h"
#include "bwb_mes.h"

#if INTENSIVE_DEBUG
#define RANDOM_FILLCHAR		'X'
#else
#define RANDOM_FILLCHAR		' '
#endif

struct dev_element *dev_table;          /* table of devices */

static struct bwb_variable *v;
static int pos;
static int req_devnumber;
static int rlen;
static int mode;

static struct bwb_line *dio_lrset( struct bwb_line *l, int rset );
static int dio_flush( int dev_number );

/***************************************************************

        FUNCTION:       bwb_open()

        DESCRIPTION: This function implements the BASIC OPEN
        command to open a stream for device input/output.

        SYNTAX: 1. OPEN "I"|"O"|"R", [#]n, filename [,rlen]
                2. OPEN filename [FOR INPUT|OUTPUT|APPEND|] AS [#]n [LEN=n]
 
***************************************************************/

struct bwb_line *
bwb_open( struct bwb_line *l )
   {
   FILE *fp;
   struct exp_ese *e;
   register int n;
   int previous_buffer;
   char atbuf[ MAXSTRINGSIZE + 1 ];
   char first[ MAXSTRINGSIZE + 1 ];
   char devname[ MAXSTRINGSIZE + 1 ];

   /* initialize */

   mode = req_devnumber = rlen = -1;
   previous_buffer = FALSE;

   /* get the first expression element up to comma or whitespace */

   adv_element( l->buffer, &( l->position ), atbuf );

   /* parse the first expression element */

   pos = 0;
   e = bwb_exp( atbuf, FALSE, &pos );
   str_btoc( first, exp_getsval( e ) );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_open(): first element is <%s>",
      first );
   bwb_debug( bwb_ebuf );
   #endif

   /* test for syntactical form: if a comma follows the first element, 
      then the syntax is form 1 (the old CP/M BASIC format); otherwise we
      presume form 2 */

   adv_ws( l->buffer, &( l->position ) );

   /* Parse syntax Form 1 (OPEN "x", #n, devname...) */

   if ( l->buffer[ l->position ] == ',' )
      {

      /* parse the next element to get the device number */

      ++( l->position );                        /* advance beyond comma */
      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == '#' )
         {
         ++( l->position );
         adv_ws( l->buffer, &( l->position ) );
         }

      adv_element( l->buffer, &( l->position ), atbuf );

      pos = 0;
      e = bwb_exp( atbuf, FALSE, &pos );
      if ( e->type == STRING )
         {
	 #if PROG_ERRORS
	 bwb_error( "String where integer was expected for device number" );
	 #else
	 bwb_error( err_syntax );
	 #endif
         l->next->position = 0;
         return l->next;
         }
      req_devnumber = exp_getival( e );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_open(): syntax 1, req dev number is %d",
         req_devnumber );
      bwb_debug( bwb_ebuf );
      #endif

      /* parse the next element to get the devname */

      adv_ws( l->buffer, &( l->position ) );    /* advance past whitespace */
      ++( l->position );                        /* advance past comma */
      adv_element( l->buffer, &( l->position ), atbuf );

      pos = 0;
      e = bwb_exp( atbuf, FALSE, &pos );
      if ( e->type != STRING )
         {
	 #if PROG_ERRORS
	 bwb_error( "in bwb_open(): number where string was expected for devname" );
	 #else
	 bwb_error( err_syntax );
         #endif
         l->next->position = 0;
         return l->next;
         }
      str_btoc( devname, exp_getsval( e ) );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_open(): syntax 1, devname <%s>",
         devname  );
      bwb_debug( bwb_ebuf );
      #endif

      /* see if there is another element; if so, parse it to get the
         record length */

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == ',' )
         {

         ++( l->position );                     /* advance beyond comma */
         adv_element( l->buffer, &( l->position ), atbuf );

         pos = 0;
         e = bwb_exp( atbuf, FALSE, &pos );
         if ( e->type == STRING )
            {
	    #if PROG_ERRORS
            bwb_error( "String where integer was expected for record length" );
            #else
            bwb_error( err_syntax );
            #endif
            l->next->position = 0;
            return l->next;
            }
         rlen = exp_getival( e );

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_open(): syntax 1, record length is %d",
            rlen );
         bwb_debug( bwb_ebuf );
         #endif

         }

      /* the first letter of the first should indicate the
         type of file opening requested: test this letter,
         then parse accordingly */

      /* open file for sequential INPUT */

      if ( ( first[ 0 ] == 'i' ) || ( first[ 0 ] == 'I' ))
         {
         mode = DEVMODE_INPUT;
         }

      /* open file for sequential OUTPUT */

      else if ( ( first[ 0 ] == 'o' ) || ( first[ 0 ] == 'O' ))
         {
         mode = DEVMODE_OUTPUT;
         }

      /* open file for RANDOM access input and output */

      else if ( ( first[ 0 ] == 'r' ) || ( first[ 0 ] == 'R' ))
         {
         mode = DEVMODE_RANDOM;
         }

      /* error: none of the appropriate modes found */

      else
         {
	 #if PROG_ERRORS
	 sprintf( bwb_ebuf, "in bwb_open(): invalid mode" );
	 bwb_error( bwb_ebuf );
	 #else
	 bwb_error( err_syntax );
	 #endif
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_open(): syntax 1, mode is %d", mode );
      bwb_debug( bwb_ebuf );
      #endif

      }

   /* Parse syntax Form 2 (OPEN devname FOR mode AS #n ... ) */

   else
      {

      /* save the devname from first */

      strcpy( devname, first );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_open(): syntax 2, devname <%s>",
         devname );
      bwb_debug( bwb_ebuf );
      #endif

      /* get the next element */

      adv_element( l->buffer, &( l->position ), atbuf );

      /* check for "FOR mode" statement */

      bwb_strtoupper( atbuf );
      if ( strcmp( atbuf, "FOR" ) == 0 )
         {
         adv_element( l->buffer, &( l->position ), atbuf );
         bwb_strtoupper( atbuf );
         if ( strcmp( atbuf, "INPUT" ) == 0 )
            {
            mode = DEVMODE_INPUT;
            }
         else if ( strcmp( atbuf, "OUTPUT" ) == 0 )
            {
            mode = DEVMODE_OUTPUT;
            }
         else if ( strcmp( atbuf, "APPEND" ) == 0 )
            {
            mode = DEVMODE_RANDOM;
            }
         else 
            {
	    #if PROG_ERRORS
            bwb_error( "in bwb_open(): Invalid device i/o mode specified" );
            #else
            bwb_error( err_syntax );
            #endif
            l->next->position = 0;
            return l->next;
            }

         /* get the next element */

         adv_element( l->buffer, &( l->position ), atbuf );

         }
      else
         {
         mode = DEVMODE_RANDOM;
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_open(): syntax 2, mode is %d", mode );
      bwb_debug( bwb_ebuf );
      #endif

      /* This leaves us with the next element in the atbuf: it
         should read "AS" */

      bwb_strtoupper( atbuf );
      if ( strcmp( atbuf, "AS" ) != 0 )
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_open(): expected AS statement" );
         #else
         bwb_error( err_syntax );
         #endif
         l->next->position = 0;
         return l->next;
         }

      /* get the next element */

      adv_ws( l->buffer, &( l->position ) );

      if ( l->buffer[ l->position ] == '#' )
         {
         ++( l->position );
         }

      adv_element( l->buffer, &( l->position ), atbuf );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_open(): string to parse for req dev number <%s>",
         atbuf );
      bwb_debug( bwb_ebuf );
      #endif

      pos = 0;
      e = bwb_exp( atbuf, FALSE, &pos );
      if ( e->type == STRING )
         {
	 #if PROG_ERRORS
         bwb_error( "String where integer was expected for record length" );
         #else
         bwb_error( err_syntax );
         #endif
         l->next->position = 0;
         return l->next;
         }
      req_devnumber = exp_getival( e );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_open(): syntax 2, req dev number is %d",
         req_devnumber );
      bwb_debug( bwb_ebuf );
      #endif

      /* Check for LEN = n statement */

      adv_element( l->buffer, &( l->position ), atbuf );
      bwb_strtoupper( atbuf );
      if ( strncmp( atbuf, "LEN", (size_t) 3 ) == 0 )
         {

         pos = l->position - strlen( atbuf );
         while( ( l->buffer[ pos ] != '=' ) && ( l->buffer[ pos ] != '\0' ))
            {
            ++pos;
            }
         if ( l->buffer[ pos ] == '\0' )
            {
	    #if PROG_ERRORS
            bwb_error( "Failed to find equals sign after LEN element" );
            #else
            bwb_error( err_syntax );
            #endif
            l->next->position = 0;
            return l->next;
            }
         ++pos;         /* advance past equal sign */

         e = bwb_exp( l->buffer, FALSE, &pos );

         if ( e->type == STRING )
            {
	    #if PROG_ERRORS
            bwb_error( "String where integer was expected for record length" );
            #else
            bwb_error( err_syntax );
            #endif
            l->next->position = 0;
            return l->next;
            }
         rlen = exp_getival( e );

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_open(): syntax 2, record length is %d",
            rlen );
         bwb_debug( bwb_ebuf );
         #endif

         }

      }                                 /* end of syntax 2 */

   /* check for valid requested device number */

   if ( ( req_devnumber < 0 ) || ( req_devnumber >= DEF_DEVICES ))
      {
      #if PROG_ERRORS
      bwb_error( "in bwb_open(): Requested device number is out of range." );
      #else
      bwb_error( err_devnum );
      #endif
      l->next->position = 0;
      return l->next;
      }

   if ( dev_table[ req_devnumber ].mode == DEVMODE_CLOSED )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_open(): using previously closed file (and buffer)" );
      bwb_debug( bwb_ebuf );
      #endif
      previous_buffer = TRUE;
      }

   if ( ( dev_table[ req_devnumber ].mode != DEVMODE_CLOSED ) &&
      ( dev_table[ req_devnumber ].mode != DEVMODE_AVAILABLE ) )
      {
      #if PROG_ERRORS
      bwb_error( "in bwb_open(): Requested device number is already in use." );
      #else
      bwb_error( err_devnum );
      #endif

      l->next->position = 0;
      return l->next;
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_open(): ready to open device <%s> mode <%d>",
      devname, mode );
   bwb_debug( bwb_ebuf );
   #endif

   /* attempt to open the file */

   switch( mode )
      {
      case DEVMODE_OUTPUT:
         fp = fopen( devname, "w" );
         break;
      case DEVMODE_INPUT:
         fp = fopen( devname, "r" );
         break;
      case DEVMODE_APPEND:
         fp = fopen( devname, "a" );
         break;
      case DEVMODE_RANDOM:
         fp = fopen( devname, "r+" );
         if ( fp == NULL )
            {
            fp = fopen( devname, "w" );
            fclose( fp );
            fp = fopen( devname, "r+" );
            }
         break;
      }

   /* check for valid file opening */

   if ( fp == NULL )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Failed to open device <%s>", devname );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_dev );
      #endif
      l->next->position = 0;
      return l->next;
      }

   /* assign values to device table */

   dev_table[ req_devnumber ].mode = mode;
   dev_table[ req_devnumber ].cfp = fp;
   dev_table[ req_devnumber ].reclen = rlen;
   dev_table[ req_devnumber ].next_record = 1;
   dev_table[ req_devnumber ].loc = 0;
   strcpy( dev_table[ req_devnumber ].filename, devname );

   /* allocate a character buffer for random access */

   if (( mode == DEVMODE_RANDOM ) && ( previous_buffer != TRUE ))
      {
      if ( ( dev_table[ req_devnumber ].buffer = calloc( rlen + 1, 1 )) == NULL )
         {
         bwb_error( err_getmem );
         return l;
         }

      dio_flush( req_devnumber );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_open(): allocated new random-access buffer" );
      bwb_debug( bwb_ebuf );
      #endif

      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_open(): file is open now; end of function" );
   bwb_debug( bwb_ebuf );
   #endif

   /* return next line number in sequence */

   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_close()

        DESCRIPTION: This function implements the BASIC CLOSE
        command to close a stream for device input/output.
  
        SYNTAX:         CLOSE [#]n [,[#]n...]

***************************************************************/

struct bwb_line *
bwb_close( struct bwb_line *l )
   {
   struct exp_ese *e;
   char atbuf[ MAXSTRINGSIZE + 1 ];

   /* loop to get device numbers to close */

   do
      {

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] =='#' )
         {
         ++( l->position );
         }

      adv_element( l->buffer, &( l->position ), atbuf );

      pos = 0;
      e = bwb_exp( atbuf, FALSE, &pos );

      if ( e->type == STRING )
         {
	 #if PROG_ERRORS
         bwb_error( "String where integer was expected for device number" );
         #else
         bwb_error( err_syntax );
         #endif
         l->next->position = 0;
         return l->next;
         }

      req_devnumber = exp_getival( e );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_close(): requested device number <%d>",
         req_devnumber );
      bwb_debug( bwb_ebuf );
      #endif

      /* check for valid requested device number */

      if ( ( req_devnumber < 0 ) || ( req_devnumber >= DEF_DEVICES ))
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_close(): Requested device number is out if range." );
         #else
         bwb_error( err_devnum );
         #endif
         l->next->position = 0;
         return l->next;
         }

      if (( dev_table[ req_devnumber ].mode == DEVMODE_CLOSED ) ||
         ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ) )
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_close(): Requested device number is not in use." );
         #else
         bwb_error( err_devnum );
         #endif

         l->next->position = 0;
         return l->next;
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_close(): closing device # <%d>",
	 req_devnumber );
      bwb_debug( bwb_ebuf );
      #endif

      /* attempt to close the file */

      if ( fclose( dev_table[ req_devnumber ].cfp ) != 0 )
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_close(): Failed to close the device" );
         #else
         bwb_error( err_dev );
         #endif
         l->next->position = 0;
         return l->next;
         }

      /* mark the device in the table as unavailable */

      dev_table[ req_devnumber ].mode = DEVMODE_CLOSED;

      /* eat up any remaining whitespace */

      adv_ws( l->buffer, &( l->position ) );

      }

   while ( l->buffer[ l->position ] == ',' );

   /* return next line number in sequence */

   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_chdir()

        DESCRIPTION: This function implements the BASIC CHDIR
        command to switch logged directories.

        SYNTAX: CHDIR pathname$
 
***************************************************************/

#if DIRECTORY_CMDS
struct bwb_line *
bwb_chdir( struct bwb_line *l )
   {
   int r;
   static int position;
   struct exp_ese *e;
   static char *atbuf;
   static int init = FALSE;

   /* get memory for temporary buffers if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( atbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* get the next element in atbuf */

   adv_element( l->buffer, &( l->position ), atbuf  );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_chdir(): argument is <%s>", atbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* interpret the argument */

   position = 0;
   e = bwb_exp( atbuf, FALSE, &position );

   if ( e->type != STRING )
      {
      bwb_error( err_argstr );
      l->next->position = 0;
      return l->next;
      }

   /* try to chdir to the requested directory */

   str_btoc( atbuf, &( e->sval ) );
   r = chdir( atbuf );

   /* detect error */

   if ( r == -1 )
      {
      bwb_error( err_opsys );
      l->next->position = 0;
      return l->next;
      }

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_rmdir()

        DESCRIPTION: This function implements the BASIC CHDIR
        command to remove a subdirectory.

        SYNTAX: RMDIR pathname$
 
***************************************************************/

struct bwb_line *
bwb_rmdir( struct bwb_line *l )
   {
   int r;
   static int position;
   struct exp_ese *e;
   static char *atbuf;
   static int init = FALSE;

   /* get memory for temporary buffers if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( atbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* get the next element in atbuf */

   adv_element( l->buffer, &( l->position ), atbuf  );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_rmdir(): argument is <%s>", atbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* interpret the argument */

   position = 0;
   e = bwb_exp( atbuf, FALSE, &position );

   if ( e->type != STRING )
      {
      bwb_error( err_argstr );
      l->next->position = 0;
      return l->next;
      }

   /* try to remove the requested directory */

   str_btoc( atbuf, &( e->sval ) );
   r = rmdir( atbuf );

   /* detect error */

   if ( r == -1 )
      {
      bwb_error( err_opsys );
      }

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_mkdir()

        DESCRIPTION: This function implements the BASIC MKDIR
        command to create a new subdirectory.

        SYNTAX: MKDIR pathname$

***************************************************************/

struct bwb_line *
bwb_mkdir( struct bwb_line *l )
   {
   int r;
   static int position;
   struct exp_ese *e;
   static char *atbuf;
   static int init = FALSE;

   /* get memory for temporary buffers if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( atbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* get the next element in atbuf */

   adv_element( l->buffer, &( l->position ), atbuf  );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_mkdir(): argument is <%s>", atbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* interpret the argument */

   position = 0;
   e = bwb_exp( atbuf, FALSE, &position );

   if ( e->type != STRING )
      {
      bwb_error( err_argstr );
      l->next->position = 0;
      return l->next;
      }

   /* try to make the requested directory */

   str_btoc( atbuf, &( e->sval ) );
   r = mkdir( atbuf );

   /* detect error */

   if ( r == -1 )
      {
      bwb_error( err_opsys );
      }

   l->next->position = 0;
   return l->next;

   }

#endif				/* DIRECTORY_CMDS */

/***************************************************************

        FUNCTION:       bwb_kill()

        DESCRIPTION: This function implements the BASIC KILL
        command to erase a disk file.

        SYNTAX: KILL btbuf$
 
***************************************************************/

struct bwb_line *
bwb_kill( struct bwb_line *l )
   {
   int r;
   static int position;
   struct exp_ese *e;
   static char *atbuf;
   static int init = FALSE;

   /* get memory for temporary buffers if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( atbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* get the next element in atbuf */

   adv_element( l->buffer, &( l->position ), atbuf  );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_kill(): argument is <%s>", atbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* interpret the argument */

   position = 0;
  e = bwb_exp( atbuf, FALSE, &position );

   if ( e->type != STRING )
      {
      bwb_error( err_argstr );
      l->next->position = 0;
      return l->next;
      }

   /* try to delete the specified file */

   str_btoc( atbuf, &( e->sval ) );
   r = unlink( atbuf );

   /* detect error */

   if ( r == -1 )
      {
      bwb_error( err_opsys );
      }

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_name()

        DESCRIPTION: This function implements the BASIC NAME
        command to rename a disk file.

        SYNTAX: NAME old_btbuf$ AS new_btbuf$
 
***************************************************************/

struct bwb_line *
bwb_name( struct bwb_line *l )
   {
   int r;
   static int position;
   struct exp_ese *e;
   static char *atbuf;
   static char *btbuf;
   static int init = FALSE;

   /* get memory for temporary buffers if necessary */

   if ( init == FALSE )
      {
      init = TRUE;
      if ( ( atbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      if ( ( btbuf = calloc( MAXSTRINGSIZE + 1, sizeof( char ) )) == NULL )
         {
         bwb_error( err_getmem );
         }
      }

   /* get the first argument in atbuf */

   adv_element( l->buffer, &( l->position ), atbuf  );

   /* interpret the first argument */

   position = 0;
   e = bwb_exp( atbuf, FALSE, &position );

   if ( e->type != STRING )
      {
      bwb_error( err_argstr );
      l->next->position = 0;
      return l->next;
      }

   /* this argument must be copied back to atbuf, else the next
      call to bwb_exp() will overwrite the structure to which e
      refers */

   str_btoc( atbuf, &( e->sval ) );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_name(): old name is <%s>", atbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* get the second argument in btbuf */

   adv_element( l->buffer, &( l->position ), btbuf  );
   bwb_strtoupper( btbuf );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_name(): AS string is <%s>", btbuf );
   bwb_debug( bwb_ebuf );
   #endif

   if ( strcmp( btbuf, "AS" ) != 0 )
      {
      bwb_error( err_syntax );
      l->next->position = 0;
      return l->next;
      }

   /* get the third argument in btbuf */

   adv_element( l->buffer, &( l->position ), btbuf  );

   /* interpret the third argument */

   position = 0;
   e = bwb_exp( btbuf, FALSE, &position );

   if ( e->type != STRING )
      {
      bwb_error( err_argstr );
      l->next->position = 0;
      return l->next;
      }

   str_btoc( btbuf, &( e->sval ) );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_name(): new name is <%s>", btbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* try to rename the file */

   r = rename( atbuf, btbuf );

   /* detect error */

   if ( r != 0 )
      {
      bwb_error( err_opsys );
      }

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_field()

        DESCRIPTION:	This C function implements the BASIC
			FIELD command.

***************************************************************/

struct bwb_line *
bwb_field( struct bwb_line *l )
   {
   int dev_number;
   int length;
   struct exp_ese *e;
   struct bwb_variable *v;
   bstring *b;
   int current_pos;
   char atbuf[ MAXSTRINGSIZE + 1 ];
   char btbuf[ MAXSTRINGSIZE + 1 ];

   current_pos = 0;

   /* first read device number */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] =='#' )
      {
      ++( l->position );
      }

   adv_element( l->buffer, &( l->position ), atbuf );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_field(): device # buffer <%s>", atbuf );
   bwb_debug( bwb_ebuf );
   #endif

   pos = 0;
   e = bwb_exp( atbuf, FALSE, &pos );

   if ( e->type != INTEGER )
      {
      #if PROG_ERRORS
      bwb_error( "in bwb_field(): Integer was expected for device number" );
      #else
      bwb_error( err_syntax );
      #endif
      return l;
      }

   dev_number = exp_getival( e );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_field(): device <%d>", dev_number );
   bwb_debug( bwb_ebuf );
   #endif

   /* be sure that the requested device is open */

   if (( dev_table[ dev_number ].mode == DEVMODE_CLOSED ) ||
      ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ) )
      {
      #if PROG_ERRORS
      bwb_error( "in bwb_field(): Requested device number is not in use." );
      #else
      bwb_error( err_devnum );
      #endif
      return l;
      }

   /* loop to read variables */

   do
      {

      /* read the comma and advance beyond it */

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] ==',' )
         {
         ++( l->position );
         }

      /* first find the size of the field */

      adv_element( l->buffer, &( l->position ), atbuf );	/* get element */

      pos = 0;
      e = bwb_exp( atbuf, FALSE, &pos );

      if ( e->type != INTEGER )
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_field(): integer value for field size not found" );
         #else
         bwb_error( err_syntax );
         #endif
         return l;
         }

      length = exp_getival( e );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_field(): device <%d> length <%d> buf <%s>",
         dev_number, length, &( l->buffer[ l->position ] ) );
      bwb_debug( bwb_ebuf );
      #endif

      /* read the AS */

      adv_element( l->buffer, &( l->position ), atbuf );	/* get element */
      bwb_strtoupper( atbuf );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_field(): AS element <%s>", atbuf );
      bwb_debug( bwb_ebuf );
      #endif

      if ( strncmp( atbuf, "AS", 2 ) != 0 )
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_field(): AS statement not found" );
         #else
         bwb_error( err_syntax );
         #endif
         return l;
         }

      /* read the string variable name */

      adv_element( l->buffer, &( l->position ), atbuf );	/* get element */
      v = var_find( atbuf );

      if ( v->type != STRING )
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_field(): string variable name not found" );
         #else
         bwb_error( err_syntax );
         #endif
         return l;
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_field(): device <%d> var <%s> length <%d>",
         dev_number, v->name, length );
      bwb_debug( bwb_ebuf );
      #endif

      /* check for overflow of record length */

      if ( ( current_pos + length ) > dev_table[ dev_number ].reclen )
         {
	 #if PROG_ERRORS
         bwb_error( "in bwb_field(): record length exceeded" );
         #else
         bwb_error( err_overflow );
         #endif
         return l;
         }

      /* set buffer */

      b = var_findsval( v, v->array_pos );
      if ( b->buffer != NULL )
         {
         free( b->buffer );
         }
      b->buffer = dev_table[ dev_number ].buffer + current_pos;
      b->length = (unsigned char) length;
      b->rab = TRUE;

      current_pos += length;

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_field(): buffer <%lXh> var <%s> buffer <%lXh>",
         (long) dev_table[ dev_number ].buffer, v->name, (long) b->buffer );
      bwb_debug( bwb_ebuf );
      #endif

      /* eat up any remaining whitespace */

      adv_ws( l->buffer, &( l->position ) );

      }

   while ( l->buffer[ l->position ] == ',' );

   /* return */

   return l;

   }

/***************************************************************

        FUNCTION:       bwb_lset()

        DESCRIPTION:	This C function implements the BASIC
			LSET command.

***************************************************************/

struct bwb_line *
bwb_lset( struct bwb_line *l )
   {
   return dio_lrset( l, FALSE );
   }
   
/***************************************************************

        FUNCTION:       bwb_rset()

        DESCRIPTION:	This C function implements the BASIC
			RSET command.

***************************************************************/

struct bwb_line *
bwb_rset( struct bwb_line *l )
   {
   return dio_lrset( l, TRUE );
   }

/***************************************************************

        FUNCTION:       dio_lrset()

        DESCRIPTION:	This C function implements the BASIC
			RSET and LSET commands.

***************************************************************/

struct bwb_line *
dio_lrset( struct bwb_line *l, int rset )
   {
   char varname[ MAXVARNAMESIZE + 1 ];
   bstring *d, *s;
   int *pp;
   int n_params;
   int p;
   register int n, i;
   int startpos;
   struct exp_ese *e;

   /* find the variable name */

   bwb_getvarname( l->buffer, varname, &( l->position ));

   v = var_find( varname );

   if ( v == NULL )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in dio_lrset(): failed to find variable" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      }

   if ( v->type != STRING )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in dio_lrset(): assignment must be to string variable" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      }

   /* read subscripts */

   pos = 0;
   if ( ( v->dimensions == 1 ) && ( v->array_sizes[ 0 ] == 1 ))
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in dio_lrset(): variable <%s> has 1 dimension",
         v->name );
      bwb_debug( bwb_ebuf );
      #endif
      n_params = 1;
      pp = &p;
      pp[ 0 ] = dim_base;
      }
   else
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in dio_lrset(): variable <%s> has > 1 dimensions",
         v->name );
      bwb_debug( bwb_ebuf );
      #endif
      dim_getparams( l->buffer, &( l->position ), &n_params, &pp );
      }

   exp_es[ exp_esc ].pos_adv = pos;
   for ( n = 0; n < v->dimensions; ++n )
      {
      v->array_pos[ n ] = pp[ n ];
      }

   /* get bstring pointer */

   d = var_findsval( v, pp );

   /* find equals sign */

   adv_ws( l->buffer, &( l->position ));
   if ( l->buffer[ l->position ] != '=' )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in dio_lrset(): failed to find equal sign" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      }
   ++( l->position );
   adv_ws( l->buffer, &( l->position ));

   /* read remainder of line to get value */

   e = bwb_exp( l->buffer, FALSE, &( l->position ) );
   s = exp_getsval( e );

   /* set starting position */

   startpos = 0;
   if ( rset == TRUE )
      {
      if ( s->length < d->length )
         {
         startpos = d->length - s->length;
         }
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in dio_lrset(): startpos <%d> buffer <%lX>", 
      startpos, (long) d->buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* write characters to new position */

   i = 0;
   for ( n = startpos; ( i < s->length ) && ( n < d->length ); ++n )
      {
      d->buffer[ n ] = s->buffer[ i ];
      ++i;
      }

   /* return */

   return l;

   }

/***************************************************************

        FUNCTION:       bwb_get()

        DESCRIPTION:	This C function implements the BASIC
			GET command.

***************************************************************/

struct bwb_line *
bwb_get( struct bwb_line *l )
   {
   int dev_number;
   int rec_number;
   register int i;
   struct exp_ese *e;
   char atbuf[ MAXSTRINGSIZE + 1 ];
   char btbuf[ MAXSTRINGSIZE + 1 ];

   /* first read device number */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] =='#' )
      {
      ++( l->position );
      }

   adv_element( l->buffer, &( l->position ), atbuf );

   pos = 0;
   e = bwb_exp( atbuf, FALSE, &pos );

   if ( e->type != INTEGER )
      {
      #if PROG_ERRORS
      bwb_error( "in bwb_get(): Integer was expected for device number" );
      #else
      bwb_error( err_syntax );
      #endif
      return l;
      }

   dev_number = exp_getival( e );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_get(): device <%d>", dev_number );
   bwb_debug( bwb_ebuf );
   #endif

   /* be sure that the requested device is open */

   if ( ( dev_table[ dev_number ].mode == DEVMODE_CLOSED ) ||
      ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ) )
      {
      #if PROG_ERRORS
      bwb_error( "in bwb_get(): Requested device number is not in use." );
      #else
      bwb_error( err_devnum );
      #endif
      return l;
      }

   /* see if there is a comma (and record number) */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] == ',' )	/* yes, there is a comma */
      {
      ++( l->position );

      /* get the record number element */

      adv_element( l->buffer, &( l->position ), atbuf );

      pos = 0;
      e = bwb_exp( atbuf, FALSE, &pos );
      rec_number = exp_getival( e );

      }

   else				/* no record number given */
      {
      rec_number = dev_table[ dev_number ].next_record;
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_get(): record number <%d>", rec_number );
   bwb_debug( bwb_ebuf );
   #endif

   /* wind the c file up to the proper point */

   if ( fseek( dev_table[ dev_number ].cfp,
      (long) (( rec_number - 1 ) * dev_table[ dev_number ].reclen ), 
      SEEK_SET ) != 0 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_get(): fseek() failed, rec number <%d> offset <%ld>",
        rec_number, (long) (( rec_number - 1 ) * dev_table[ dev_number ].reclen ) );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_dev );
      #endif
      return l;
      }

   /* read the requested bytes into the buffer */

   for ( i = 0; i < dev_table[ dev_number ].reclen; ++i )
      {
      dev_table[ dev_number ].buffer[ i ] =
         (char) fgetc( dev_table[ dev_number ].cfp );
      ++( dev_table[ dev_number ].loc );
      }

   /* increment (or reset) the current record */

   dev_table[ dev_number ].next_record = rec_number + 1;

   return l;

   }

/***************************************************************

        FUNCTION:       bwb_put()

        DESCRIPTION:	This C function implements the BASIC
			PUT command.

***************************************************************/

struct bwb_line *
bwb_put( struct bwb_line *l )
   {
   int dev_number;
   int rec_number;
   register int i;
   struct exp_ese *e;
   struct bwb_variable *v;
   char atbuf[ MAXSTRINGSIZE + 1 ];
   char btbuf[ MAXSTRINGSIZE + 1 ];

   /* first read device number */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] =='#' )
      {
      ++( l->position );
      }

   adv_element( l->buffer, &( l->position ), atbuf );
   dev_number = atoi( atbuf );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_put(): device <%d>", dev_number );
   bwb_debug( bwb_ebuf );
   #endif

   /* be sure that the requested device is open */

   if ( ( dev_table[ dev_number ].mode == DEVMODE_CLOSED ) ||
      ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ) )
      {
      #if PROG_ERRORS
      bwb_error( "in bwb_put(): Requested device number is not in use." );
      #else
      bwb_error( err_devnum );
      #endif
      return l;
      }

   /* see if there is a comma (and record number) */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] == ',' )	/* yes, there is a comma */
      {
      ++( l->position );

      /* get the record number element */

      adv_element( l->buffer, &( l->position ), atbuf );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_put(): rec no buffer <%s>", atbuf );
      bwb_debug( bwb_ebuf );
      #endif

      pos = 0;
      e = bwb_exp( atbuf, FALSE, &pos );

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_put(): return type <%c>", e->type );
      bwb_debug( bwb_ebuf );
      #endif

      rec_number = exp_getival( e );

      }

   else				/* no record number given */
      {
      rec_number = dev_table[ dev_number ].next_record;
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_put(): record number <%d>", rec_number );
   bwb_debug( bwb_ebuf );
   #endif

   /* wind the c file up to the proper point */

   if ( fseek( dev_table[ dev_number ].cfp,
      (long) (( rec_number - 1 ) * dev_table[ dev_number ].reclen ), 
      SEEK_SET ) != 0 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_get(): fseek() failed, rec number <%d> offset <%ld>",
        rec_number, (long) (( rec_number - 1 ) * dev_table[ dev_number ].reclen ) );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_dev );
      #endif
      return l;
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_put(): ready to write to file, buffer <%lXh>",
      (long) dev_table[ dev_number ].buffer );
   bwb_debug( bwb_ebuf );
   xprintf( stderr, "Buffer: <" );
   #endif

   /* write the requested bytes to the file */

   for ( i = 0; i < dev_table[ dev_number ].reclen; ++i )
      {
      fputc( dev_table[ dev_number ].buffer[ i ],
         dev_table[ dev_number ].cfp );
      #if INTENSIVE_DEBUG
      xputc( stderr, dev_table[ dev_number ].buffer[ i ] );
      #endif
      ++( dev_table[ dev_number ].loc );
      }

   #if INTENSIVE_DEBUG
   xprintf( stderr, ">\n" );
   sprintf( bwb_ebuf, "in bwb_put(): write to file complete" );
   bwb_debug( bwb_ebuf );
   #endif

   /* flush the buffer */

   dio_flush( dev_number );

   /* increment (or reset) the current record */

   dev_table[ dev_number ].next_record = rec_number + 1;

   return l;

   }

/***************************************************************

        FUNCTION:       dio_flush()

        DESCRIPTION:    This C function flushes the random-access
			buffer associated with file dev_number.

***************************************************************/

int
dio_flush( int dev_number )
   {
   register int n;

   if ( dev_table[ dev_number ].mode != DEVMODE_RANDOM )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in dio_flush(): only random-access buffers can be flushed" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_dev );
      #endif
      }

   /* fill buffer with blanks (or 'X' for test) */

   for ( n = 0; n < dev_table[ req_devnumber ].reclen; ++n )
      {
      dev_table[ req_devnumber ].buffer[ n ] = RANDOM_FILLCHAR;
      }

   return TRUE;

   }

/***************************************************************

        FUNCTION:       fnc_loc()

        DESCRIPTION:    This C function implements the BASIC
			LOC() function. As implemented here,
			this only workd for random-acess files.

***************************************************************/

struct bwb_variable *
fnc_loc( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   int dev_number;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_loc(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   if ( argc < 1 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function LOC().",
         argc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return NULL;
      }
   else if ( argc > 1 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Too many parameters (%d) to function LOC().",
         argc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return NULL;
      }

   dev_number = var_getival( &( argv[ 0 ] ) );

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, INTEGER );
      }

   /* note if this is the very beginning of the file */

   if ( dev_table[ dev_number ].loc == 0 )
      {
      * var_findival( &nvar, nvar.array_pos ) = 0;
      }
   else
      {
      * var_findival( &nvar, nvar.array_pos ) =
         dev_table[ dev_number ].next_record;
      }

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_lof()

        DESCRIPTION:    This C function implements the BASIC
			LOF() function. 

***************************************************************/

struct bwb_variable *
fnc_lof( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   int dev_number;
   int r;
   static struct stat statbuf;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_lof(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   if ( argc < 1 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function LOF().",
         argc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return NULL;
      }
   else if ( argc > 1 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Too many parameters (%d) to function LOF().",
         argc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return NULL;
      }

   dev_number = var_getival( &( argv[ 0 ] ) );

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, SINGLE );
      }

   /* stat the file */

   r = stat( dev_table[ dev_number ].filename, &statbuf );

   if ( r != 0 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in fnc_lof(): failed to find file <%s>",
         dev_table[ dev_number ].filename );
      bwb_error( bwb_ebuf );
      #else
      sprintf( bwb_ebuf, ERR_OPENFILE,
         dev_table[ dev_number ].filename );
      bwb_error( bwb_ebuf );
      #endif
      return NULL;
      }

   * var_findfval( &nvar, nvar.array_pos ) = (float) statbuf.st_size;

   return &nvar;
   }

/***************************************************************

        FUNCTION:       fnc_eof()

        DESCRIPTION:    This C function implements the BASIC
			EOF() function. 

***************************************************************/

struct bwb_variable *
fnc_eof( int argc, struct bwb_variable *argv )
   {
   static struct bwb_variable nvar;
   static int init = FALSE;
   int dev_number;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fnc_loc(): received f_arg <%f> ",
      var_getdval( &( argv[ 0 ] ) ) );
   bwb_debug( bwb_ebuf );
   #endif

   if ( argc < 1 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Not enough parameters (%d) to function EOF().",
         argc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return NULL;
      }
   else if ( argc > 1 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "Too many parameters (%d) to function EOF().",
         argc );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return NULL;
      }

   dev_number = var_getival( &( argv[ 0 ] ) );

   if ( init == FALSE )
      {
      init = TRUE;
      var_make( &nvar, INTEGER );
      }

   /* note if this is the very beginning of the file */

   if ( dev_table[ dev_number ].mode == DEVMODE_AVAILABLE )
      {
      bwb_error( err_devnum );
      * var_findival( &nvar, nvar.array_pos ) = TRUE;
      }
   else if ( dev_table[ dev_number ].mode == DEVMODE_CLOSED )
      {
      bwb_error( err_devnum );
      * var_findival( &nvar, nvar.array_pos ) = TRUE;
      }
   else if ( feof( dev_table[ dev_number ].cfp ) == 0 )
      {
      * var_findival( &nvar, nvar.array_pos ) = FALSE;
      }
   else
      {
      * var_findival( &nvar, nvar.array_pos ) = TRUE;
      }

   return &nvar;
   }


