/***************************************************************

        bwb_dio.c       Device Input/Output Routines
                        for Bywater BASIC Interpreter

                        Copyright (c) 1993, Ted A. Campbell
                        Bywater Software

                        email: tcamp@delphi.com

        Copyright and Permissions Information:

        All U.S. and international rights are claimed by the author,
        Ted A. Campbell.

	This software is released under the terms of the GNU General
	Public License (GPL), which is distributed with this software
	in the file "COPYING".  The GPL specifies the terms under
	which users may copy and use the software in this distribution.

	A separate license is available for commercial distribution,
	for information on which you should contact the author.

***************************************************************/

/*---------------------------------------------------------------*/
/* NOTE: Modifications marked "JBV" were made by Jon B. Volkoff, */
/* 11/1995 (eidetics@cerf.net).                                  */
/*---------------------------------------------------------------*/

#include <stdio.h>

#include "bwbasic.h"
#include "bwb_mes.h"
#ifdef ATARI
#include "tos.h"
#endif

#if HAVE_SYSSTAT
#include <sys/stat.h>
#endif

#ifndef SEEK_SET
#define	SEEK_SET	0
#endif

#if INTENSIVE_DEBUG
#define RANDOM_FILLCHAR		'X'
#else
#define RANDOM_FILLCHAR		' '
#endif

#if COMMON_CMDS
struct dev_element *dev_table;          /* table of devices */
#endif

static struct bwb_variable *v;
static int pos;
static int req_devnumber;
static int rlen;
static int mode;

#if ANSI_C
static struct bwb_line *dio_lrset( struct bwb_line *l, int rset );
static int dio_flush( int dev_number );
#else
static struct bwb_line *dio_lrset();
static int dio_flush();
#endif

#if COMMON_CMDS

/***************************************************************

        FUNCTION:       bwb_open()

	DESCRIPTION:    This function implements the BASIC OPEN
			command to open a stream for device input/output.

        SYNTAX: 1. OPEN "I"|"O"|"R", [#]n, filename [,rlen]
                2. OPEN filename [FOR INPUT|OUTPUT|APPEND|] AS [#]n [LEN=n]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_open( struct bwb_line *l )
#else
struct bwb_line *
bwb_open( l )
   struct bwb_line *l;
#endif
   {
   FILE *fp;
   struct exp_ese *e;
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

   /* Parse syntax Form 1 (OPEN "x",#n, devname...) */

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
	 bwb_error( "String where number was expected for device number" );
#else
	 bwb_error( err_syntax );
#endif
         return bwb_zline( l );
         }
      req_devnumber = (int) exp_getnval( e );

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
         return bwb_zline( l );
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
            bwb_error( "String where number was expected for record length" );
#else
            bwb_error( err_syntax );
#endif
            return bwb_zline( l );
            }
         rlen = (int) exp_getnval( e );

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

   /* Parse syntax Form 2 (OPEN devname FOR mode AS#n ... ) */

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
            return bwb_zline( l );
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
         return bwb_zline( l );
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
         bwb_error( "String where number was expected for dev number" );
#else
         bwb_error( err_syntax );
#endif
         return bwb_zline( l );
         }
      req_devnumber = (int) exp_getnval( e );

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
            return bwb_zline( l );
            }
         ++pos;         /* advance past equal sign */

         e = bwb_exp( l->buffer, FALSE, &pos );

         if ( e->type == STRING )
            {
#if PROG_ERRORS
            bwb_error( "String where number was expected for record length" );
#else
            bwb_error( err_syntax );
#endif
            return bwb_zline( l );
            }
         rlen = (int) exp_getnval( e );

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
      return bwb_zline( l );
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

      return bwb_zline( l );
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
      return bwb_zline( l );
      }

   /* assign values to device table */

   /* Random mode has a default record length (JBV) */
   if (mode == DEVMODE_RANDOM && rlen == -1) rlen = 128;

   dev_table[ req_devnumber ].mode = mode;
   dev_table[ req_devnumber ].cfp = fp;
   dev_table[ req_devnumber ].reclen = rlen;
   dev_table[ req_devnumber ].next_record = 1;
   dev_table[ req_devnumber ].loc = 0;
   strcpy( dev_table[ req_devnumber ].filename, devname );

   /* File length finding routine, added by JBV */
   fseek( dev_table[ req_devnumber ].cfp, 0, SEEK_END );
   dev_table[ req_devnumber ].lof = ftell( dev_table[ req_devnumber ].cfp );
   fseek( dev_table[ req_devnumber ].cfp, 0, SEEK_SET );

   /* allocate a character buffer for random access */

   if (( mode == DEVMODE_RANDOM ) && ( previous_buffer != TRUE ))
      {
      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( dev_table[ req_devnumber ].buffer = CALLOC( rlen + 1, 1, "bwb_open" )) == NULL )
	 {
#if PROG_ERRORS
	 bwb_error( "in bwb_open(): failed to find memory for device buffer" );
#else
	 bwb_error( err_getmem );
#endif
	 return bwb_zline( l );
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

   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_close()

	DESCRIPTION:    This function implements the BASIC CLOSE
			command to close a stream for device input/output.

        SYNTAX:         CLOSE [#]n [,[#]n...]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_close( struct bwb_line *l )
#else
struct bwb_line *
bwb_close( l )
   struct bwb_line *l;
#endif
   {
   struct exp_ese *e;
   char atbuf[ MAXSTRINGSIZE + 1 ];
   int blanket_close; /* JBV */
   register int n; /* JBV */

   blanket_close = -1; /* JBV */
   req_devnumber = 0; /* JBV */

   /* loop to get device numbers to close */

   do
      {

      if ( l->buffer[ l->position ] == ',' && blanket_close == 0)
         ++( l->position); /* JBV */
      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] == '#')
         {
         ++( l->position );
         }

      adv_element( l->buffer, &( l->position ), atbuf );

      pos = 0;
      e = bwb_exp( atbuf, FALSE, &pos );

      if ( e->type == STRING )
         {
#if PROG_ERRORS
         bwb_error( "String where number was expected for device number" );
#else
         bwb_error( err_syntax );
#endif
         return bwb_zline( l );
         }

      /*-------------------------------------------------------------*/
      /* Added the following section for blanket close feature (JBV) */
      /*-------------------------------------------------------------*/
      if (blanket_close == -1)
      if (strlen(atbuf) != 0) blanket_close = 0;
      else blanket_close = 1;

      if (blanket_close == 0) req_devnumber = (int) exp_getnval( e );
      else
      {
          ++req_devnumber;

          /* Find the next device in use */
          for (n = req_devnumber; n < DEF_DEVICES; ++n)
          {
              req_devnumber = -1;
              if (( dev_table[ n ].mode != DEVMODE_CLOSED ) &&
                 ( dev_table[ n ].mode != DEVMODE_AVAILABLE ) )
              {
                  req_devnumber = n;
                  break;
              }
          }
          if (req_devnumber == -1) break; /* Skidoo if no more to close */
      }

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
         return bwb_zline( l );
         }

      if (( dev_table[ req_devnumber ].mode == DEVMODE_CLOSED ) ||
         ( dev_table[ req_devnumber ].mode == DEVMODE_AVAILABLE ) )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_close(): Requested device number is not in use." );
#else
         bwb_error( err_devnum );
#endif

         return bwb_zline( l );
         }

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_close(): closing device# <%d>",
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
         return bwb_zline( l );
         }

      /* mark the device in the table as unavailable */

      dev_table[ req_devnumber ].mode = DEVMODE_CLOSED;

      /* Revised to FREE pass-thru call by JBV */
      if ( dev_table[ req_devnumber ].buffer != NULL )
      {
          FREE( dev_table[ req_devnumber ].buffer, "bwb_close" ); /* JBV */
          dev_table[ req_devnumber ].buffer = NULL; /* JBV */
      }

      /* eat up any remaining whitespace */

      adv_ws( l->buffer, &( l->position ) );

      }

   while ( l->buffer[ l->position ] == ',' || blanket_close == 1); /* JBV */

   /* return next line number in sequence */

   return bwb_zline( l );
   }

#endif 				/* COMMON_CMDS */

/***************************************************************

        FUNCTION:       bwb_chdir()

	DESCRIPTION:    This function implements the BASIC CHDIR
			command to switch logged directories.

	SYNTAX:         CHDIR pathname$

***************************************************************/

#if UNIX_CMDS
#if ANSI_C
struct bwb_line *
bwb_chdir( struct bwb_line *l )
#else
struct bwb_line *
bwb_chdir( l )
   struct bwb_line *l;
#endif
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

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( atbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "bwb_chdir" )) == NULL )
         {
#if PROG_ERRORS
	 bwb_error( "in bwb_chdir(): failed to find memory for atbuf" );
#else
	 bwb_error( err_getmem );
#endif
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
      return bwb_zline( l );
      }

   /* try to chdir to the requested directory */

   str_btoc( atbuf, &( e->sval ) );
   r = chdir( atbuf );

   /* detect error */

   if ( r == -1 )
      {
      bwb_error( err_opsys );
      return bwb_zline( l );
      }

   return bwb_zline( l );

   }


/***************************************************************

        FUNCTION:       bwb_rmdir()

	DESCRIPTION:    This function implements the BASIC CHDIR
			command to remove a subdirectory.

	SYNTAX:         RMDIR pathname$

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_rmdir( struct bwb_line *l )
#else
struct bwb_line *
bwb_rmdir( l )
   struct bwb_line *l;
#endif
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

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( atbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "bwb_rmdir" )) == NULL )
         {
#if PROG_ERRORS
	 bwb_error( "in rmdir(): failed to find memory for atbuf" );
#else
	 bwb_error( err_getmem );
#endif
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
      return bwb_zline( l );
      }

   /* try to remove the requested directory */

   str_btoc( atbuf, &( e->sval ) );
#ifndef ATARI
	r = rmdir( atbuf );
#else
	r = Ddelete( atbuf );
#endif
   /* detect error */

   if ( r == -1 )
      {
      bwb_error( err_opsys );
      }

   return bwb_zline( l );

   }
/***************************************************************

        FUNCTION:       bwb_mkdir()

	DESCRIPTION:    This function implements the BASIC MKDIR
			command to create a new subdirectory.

	SYNTAX:         MKDIR pathname$

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_mkdir( struct bwb_line *l )
#else
struct bwb_line *
bwb_mkdir( l )
   struct bwb_line *l;
#endif
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

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( atbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "bwb_mkdir" )) == NULL )
         {
#if PROG_ERRORS
	 bwb_error( "in bwb_mkdir(): failed to find memory for atbuf" );
#else
	 bwb_error( err_getmem );
#endif
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
      return bwb_zline( l );
      }

   /* try to make the requested directory */

   str_btoc( atbuf, &( e->sval ) );
#ifndef ATARI
#if MKDIR_ONE_ARG
   r = mkdir( atbuf );
#else
   r = mkdir( atbuf, PERMISSIONS );
#endif
#else
	r = Dcreate( atbuf );
#endif


   /* detect error */

   if ( r == -1 )
      {
      bwb_error( err_opsys );
      }

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_kill()

	DESCRIPTION:    This function implements the BASIC KILL
			command to erase a disk file.

	SYNTAX:         KILL filename

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_kill( struct bwb_line *l )
#else
struct bwb_line *
bwb_kill( l )
   struct bwb_line *l;
#endif
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

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( atbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "bwb_kill" )) == NULL )
         {
#if PROG_ERRORS
	 bwb_error( "in bwb_kill(): failed to find memory for atbuf" );
#else
	 bwb_error( err_getmem );
#endif
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
      return bwb_zline( l );
      }

   /* try to delete the specified file */

   str_btoc( atbuf, &( e->sval ) );
   r = unlink( atbuf );

   /* detect error */

   if ( r == -1 )
      {
      bwb_error( err_opsys );
      }

   return bwb_zline( l );

   }

#endif				/* UNIX_CMDS */

#if COMMON_CMDS

/***************************************************************

        FUNCTION:       bwb_name()

	DESCRIPTION:    This function implements the BASIC NAME
			command to rename a disk file.

	SYNTAX:         NAME old_filename AS new_filename

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_name( struct bwb_line *l )
#else
struct bwb_line *
bwb_name( l )
   struct bwb_line *l;
#endif
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

      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( atbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "bwb_name" )) == NULL )
         {
#if PROG_ERRORS
	 bwb_error( "in bwb_name(): failed to find memory for atbuf" );
#else
	 bwb_error( err_getmem );
#endif
	 }
      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( btbuf = CALLOC( MAXSTRINGSIZE + 1, sizeof( char ), "bwb_name" )) == NULL )
	 {
#if PROG_ERRORS
	 bwb_error( "in bwb_name(): failed to find memory for btbuf" );
#else
	 bwb_error( err_getmem );
#endif
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
      return bwb_zline( l );
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
      return bwb_zline( l );
      }

   /* get the third argument in btbuf */

   adv_element( l->buffer, &( l->position ), btbuf  );

   /* interpret the third argument */

   position = 0;
   e = bwb_exp( btbuf, FALSE, &position );

   if ( e->type != STRING )
      {
      bwb_error( err_argstr );
      return bwb_zline( l );
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

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_field()

        DESCRIPTION:	This C function implements the BASIC
			FIELD command.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_field( struct bwb_line *l )
#else
struct bwb_line *
bwb_field( l )
   struct bwb_line *l;
#endif
   {
   int dev_number;
   int length;
   struct exp_ese *e;
   struct bwb_variable *v;
   bstring *b;
   int current_pos;
   char atbuf[ MAXSTRINGSIZE + 1 ];

   current_pos = 0;

   /* first read device number */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] =='#' )
      {
      ++( l->position );
      }

   adv_element( l->buffer, &( l->position ), atbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_field(): device# buffer <%s>", atbuf );
   bwb_debug( bwb_ebuf );
#endif

   pos = 0;
   e = bwb_exp( atbuf, FALSE, &pos );

   if ( e->type != NUMBER )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_field(): Number was expected for device number" );
#else
      bwb_error( err_syntax );
#endif
      return bwb_zline( l );
      }

   dev_number = (int) exp_getnval( e );

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
      return bwb_zline( l );
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

      if ( e->type != NUMBER )
         {
#if PROG_ERRORS
         bwb_error( "in bwb_field(): number value for field size not found" );
#else
         bwb_error( err_syntax );
#endif
         return bwb_zline( l );
         }

      length = (int) exp_getnval( e );

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
         return bwb_zline( l );
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
         return bwb_zline( l );
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
         return bwb_zline( l );
         }

      /* set buffer */

      b = var_findsval( v, v->array_pos );

#if DONTDOTHIS
      if ( b->sbuffer != NULL )
	 {
         /* Revised to FREE pass-thru call by JBV */
	 FREE( b->sbuffer, "bwb_field" );
	 b->sbuffer = NULL; /* JBV */
	 }
#endif

      b->sbuffer = dev_table[ dev_number ].buffer + current_pos;
      b->length = (unsigned int) length; /* Was unsigned char (JBV 9/4/97) */
      b->rab = TRUE;

      current_pos += length;

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_field(): buffer <%lXh> var <%s> buffer <%lXh>",
         (long) dev_table[ dev_number ].buffer, v->name, (long) b->sbuffer );
      bwb_debug( bwb_ebuf );
#endif

      /* eat up any remaining whitespace */

      adv_ws( l->buffer, &( l->position ) );

      }

   while ( l->buffer[ l->position ] == ',' );

   /* return */

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_lset()

        DESCRIPTION:	This C function implements the BASIC
			LSET command.

	SYNTAX:		LSET string-variable$ = expression

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_lset( struct bwb_line *l )
#else
struct bwb_line *
bwb_lset( l )
   struct bwb_line *l;
#endif
   {
   return dio_lrset( l, FALSE );
   }

/***************************************************************

        FUNCTION:       bwb_rset()

        DESCRIPTION:	This C function implements the BASIC
			RSET command.

	SYNTAX:		RSET string-variable$ = expression

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_rset( struct bwb_line *l )
#else
struct bwb_line *
bwb_rset( l )
   struct bwb_line *l;
#endif
   {
   return dio_lrset( l, TRUE );
   }

/***************************************************************

        FUNCTION:       dio_lrset()

        DESCRIPTION:	This C function implements the BASIC
			RSET and LSET commands.

***************************************************************/

#if ANSI_C
static struct bwb_line *
dio_lrset( struct bwb_line *l, int rset )
#else
static struct bwb_line *
dio_lrset( l, rset )
   struct bwb_line *l;
   int rset;
#endif
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

   CURTASK exps[ CURTASK expsc ].pos_adv = pos;
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
      startpos, (long) d->sbuffer );
   bwb_debug( bwb_ebuf );
#endif

   /* write characters to new position */

   i = 0;
   for ( n = startpos; ( i < (int) s->length ) && ( n < (int) d->length ); ++n )
      {
      d->sbuffer[ n ] = s->sbuffer[ i ];
      ++i;
      }

   /* return */

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_get()

        DESCRIPTION:	This C function implements the BASIC
			GET command.

	SYNTAX:		GET [#] device-number [, record-number]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_get( struct bwb_line *l )
#else
struct bwb_line *
bwb_get( l )
   struct bwb_line *l;
#endif
   {
   int dev_number;
   int rec_number;
   register int i;
   struct exp_ese *e;
   char atbuf[ MAXSTRINGSIZE + 1 ];
   long offset; /* JBV */

   /* first read device number */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] =='#' )
      {
      ++( l->position );
      }

   adv_element( l->buffer, &( l->position ), atbuf );

   pos = 0;
   e = bwb_exp( atbuf, FALSE, &pos );

   if ( e->type != NUMBER )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_get(): Number was expected for device number" );
#else
      bwb_error( err_syntax );
#endif
      return bwb_zline( l );
      }

   dev_number = (int) exp_getnval( e );

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
      return bwb_zline( l );
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
      rec_number = (int) exp_getnval( e );

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

   /* Added by JBV */
   offset = (long) (( rec_number - 1 ) * dev_table[ dev_number ].reclen);

   if ( fseek( dev_table[ dev_number ].cfp, offset, SEEK_SET ) != 0 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_get(): fseek() failed, rec number <%d> offset <%ld>",
        rec_number, (long) (( rec_number - 1 ) * dev_table[ dev_number ].reclen ) );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_dev );
#endif
      return bwb_zline( l );
      }

   /* read the requested bytes into the buffer */

   dev_table[ dev_number ].loc = offset; /* Slight bug fix (JBV) */
   for ( i = 0; i < dev_table[ dev_number ].reclen; ++i )
      {
      dev_table[ dev_number ].buffer[ i ] =
         (char) fgetc( dev_table[ dev_number ].cfp );
      ++( dev_table[ dev_number ].loc );
      }

   /* increment (or reset) the current record */

   dev_table[ dev_number ].next_record = rec_number + 1;

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       bwb_put()

        DESCRIPTION:	This C function implements the BASIC
			PUT command.

	SYNTAX:		PUT [#] device-number [, record-number]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_put( struct bwb_line *l )
#else
struct bwb_line *
bwb_put( l )
   struct bwb_line *l;
#endif
   {
   int dev_number;
   int rec_number;
   register int i;
   struct exp_ese *e;
   char atbuf[ MAXSTRINGSIZE + 1 ];
   long offset; /* JBV */

   /* first read device number */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] =='#' )
      {
      ++( l->position );
      }

   adv_element( l->buffer, &( l->position ), atbuf );
/*   dev_number = atoi( atbuf ); */  /* Not quite right (JBV) */

   /* Added by JBV */
   pos = 0;
   e = bwb_exp( atbuf, FALSE, &pos );

   if ( e->type != NUMBER )
      {
#if PROG_ERRORS
      bwb_error( "in bwb_put(): Number was expected for device number" );
#else
      bwb_error( err_syntax );
#endif
      return bwb_zline( l );
      }

   dev_number = (int) exp_getnval( e );

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
      return bwb_zline( l );
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

      rec_number = (int) exp_getnval( e );

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

   /* Added by JBV */
   offset = (long) (( rec_number - 1 ) * dev_table[ dev_number ].reclen);

   if ( fseek( dev_table[ dev_number ].cfp, offset, SEEK_SET ) != 0 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_get(): fseek() failed, rec number <%d> offset <%ld>",
        rec_number, (long) (( rec_number - 1 ) * dev_table[ dev_number ].reclen ) );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_dev );
#endif
      return bwb_zline( l );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_put(): ready to write to file, buffer <%lXh>",
      (long) dev_table[ dev_number ].buffer );
   bwb_debug( bwb_ebuf );
   prn_xprintf( stderr, "Buffer: <" );
#endif

   /* write the requested bytes to the file */

   dev_table[ dev_number ].loc = offset; /* Slight bug fix (JBV) */
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
   prn_xprintf( stderr, ">\n" );
   sprintf( bwb_ebuf, "in bwb_put(): write to file complete" );
   bwb_debug( bwb_ebuf );
#endif

   /* flush the buffer */

   dio_flush( dev_number );

   /* increment (or reset) the current record */

   dev_table[ dev_number ].next_record = rec_number + 1;

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       dio_flush()

        DESCRIPTION:    This C function flushes the random-access
			buffer associated with file dev_number.

***************************************************************/

#if ANSI_C
static int
dio_flush( int dev_number )
#else
static int
dio_flush( dev_number )
   int dev_number;
#endif
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

#endif				/* COMMON_CMDS */


