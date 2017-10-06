/***************************************************************

        bwb_cmd.c       Miscellaneous Commands
                        for Bywater BASIC Interpreter

                        Commands:       RUN
                                        LET
                                        LOAD
                                        MERGE
                                        CHAIN
                                        NEW
                                        RENUM
                                        SAVE
                                        LIST
                                        GOTO
                                        GOSUB
                                        RETURN
                                        ON
                                        STOP
                                        END
                                        SYSTEM
                                        TRON
                                        TROFF
                                        DELETE
                                        RANDOMIZE
					ENVIRON
                                        CMDS            (*debugging)

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
#include <math.h>
#include <string.h>

#include "bwbasic.h"
#include "bwb_mes.h"
#include "stdlib.h"
struct gsse *bwb_gss;			/* GOSUB stack */
int bwb_gssc = 0;			/* GOSUB stack counter */
int err_gosubn = 0;			/* line number for error GOSUB */

extern struct bwb_line *bwb_xnew( struct bwb_line *l );
extern struct bwb_line *bwb_onerror( struct bwb_line *l );

/***************************************************************

        FUNCTION:       bwb_null()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_null( struct bwb_line *l )
   {
   #if  INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_null(): NULL function: argc = %d", l->argc );
   bwb_debug( bwb_ebuf );
   #endif
   l->next->position = 0;
   return l->next;
   }

/***************************************************************

	FUNCTION:       bwb_rem()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_rem( struct bwb_line *l )
   {
   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_rem(): REM command" );
   bwb_debug( bwb_ebuf );
   #endif

   l->position = strlen( l->buffer ) - 1;

   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_run()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_run( struct bwb_line *l )
   {
   struct bwb_line *current, *x;
   int go_lnumber;                /* line number to go to */
   register int n;                /* counter */
   char tbuf[ MAXSTRINGSIZE + 1 ];
   struct exp_ese *e;
   FILE *input;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_run(): entered function. buffer <%s> pos <%d>",
      l->buffer, l->position );
   bwb_debug( bwb_ebuf );
   #endif

   /* see if there is an element */

   current = NULL;
   adv_ws( l->buffer, &( l->position ) );
   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_run(): check buffer <%s> pos <%d> char <0x%x>",
      l->buffer, l->position, l->buffer[ l->position ] );
   bwb_debug( bwb_ebuf );
   #endif
   switch ( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_run(): no argument; begin at start.next" );
         bwb_debug( bwb_ebuf );
         #endif
         current = bwb_start.next;
         e = NULL;
         break;
      default:
         e = bwb_exp( l->buffer, FALSE, &( l->position ) );
         break;
      }

   /* check its type: if it is a string, open the file and execute it */

   if (( e != NULL ) && ( e->type == STRING ))
      {
      bwb_new( l );				/* clear memory */
      str_btoc( tbuf, exp_getsval( e ) );	/* get string in tbuf */
      if ( ( input = fopen( tbuf, "r" )) == NULL )	/* open file */
         {
         sprintf( bwb_ebuf, err_openfile, tbuf );
         bwb_error( bwb_ebuf );
         }
      bwb_fload( input );		/* load program */
      bwb_run( &bwb_start );		/* and call bwb_run() recursively */
      }

   /* else if it is a line number, execute the progrm in memory
      at that line number */
 
   else
      {

      if ( current == NULL )
         {

         if ( e != NULL )
            {
            go_lnumber = exp_getival( e );
            }

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_run(): element detected <%s>, lnumber <%d>",
            tbuf, go_lnumber );
         bwb_debug( bwb_ebuf );
         #endif

         for ( x = bwb_start.next; x != &bwb_end; x = x->next )
            {
            if ( x->number == go_lnumber )
               {
               current = x;
               }
            }
         }

      if ( current == NULL )
         {
         sprintf( bwb_ebuf, err_lnnotfound, go_lnumber );
         bwb_error( bwb_ebuf );
         return &bwb_end;
         }

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_run(): ready to call do-while loop at line %d",
         current->number );
      bwb_debug( bwb_ebuf );
      #endif

      current->position = 0;

      while ( current != &bwb_end )
         {
         current = bwb_xline( current );
         }

      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_run(): function complete." );
   bwb_debug( bwb_ebuf );
   #endif

   return &bwb_end;

   }

/***************************************************************

        FUNCTION:       bwb_let()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_let( struct bwb_line *l )
   {

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_let(): pos <%d> line <%s>",
      l->position, l->buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* Call the expression interpreter to evaluate the assignment */

   bwb_exp( l->buffer, TRUE, &( l->position ) );

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_chain()

        DESCRIPTION:	This C function implements the BASIC
			CHAIN command.

***************************************************************/

struct bwb_line *
bwb_chain( struct bwb_line *l )
   {
   struct bwb_line *current;

   /* deallocate all variables except common ones */

   var_delcvars();

   /* remove old program from memory */

   bwb_xnew( l );

   /* call xload function to load new program in memory */

   bwb_xload( l );

   /* process other arguments */

   /*** TEMP -- WORKPOINT ***/

   /* run the newly loaded program */

   current = bwb_start.next;

   current->position = 0;

   while ( current != &bwb_end )
      {
      current = bwb_xline( current );
      }

   /* return */

   return &bwb_end;

   }

/***************************************************************

        FUNCTION:       bwb_merge()

        DESCRIPTION:	This C function implements the BASIC
			MERGE command.

***************************************************************/

struct bwb_line *
bwb_merge( struct bwb_line *l )
   {

   /* call xload function to merge program in memory */

   bwb_xload( l );

   return l;

   }

/***************************************************************

        FUNCTION:       bwb_load()

        DESCRIPTION:	This C function implements the BASIC
			LOAD command.

***************************************************************/

struct bwb_line *
bwb_load( struct bwb_line *l )
   {

   /* clear current contents */

   bwb_new( l );

   /* call xload function to load program in memory */

   bwb_xload( l );

   return l;

   }

/***************************************************************

        FUNCTION:       bwb_xload()

        DESCRIPTION:	This C function implements the BASIC
			LOAD command.

***************************************************************/

struct bwb_line *
bwb_xload( struct bwb_line *l )
   {
   FILE *loadfile;
   char filename[ MAXARGSIZE ];

   /* Get an argument for filename */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         bwb_error( err_nofn );
         l->next->position = 0;
         return l->next;
      default:
         break;
      }

   bwb_const( l->buffer, filename, &( l->position ) );
   if ( ( loadfile = fopen( filename, "r" )) == NULL )
      {
      sprintf( bwb_ebuf, err_openfile, filename );
      bwb_error( bwb_ebuf );
      l->next->position = 0;
      return l->next;
      }

   bwb_fload( loadfile );

   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_new()

        DESCRIPTION:	This C function implements the BASIC
			NEW command.

***************************************************************/

struct bwb_line *
bwb_new( struct bwb_line *l )
   {

   /* clear program in memory */

   bwb_xnew( l );

   /* clear all variables */

   bwb_clear( l );

   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_xnew()

        DESCRIPTION:	Clears the program in memory, but does not
			deallocate all variables.

***************************************************************/

struct bwb_line *
bwb_xnew( struct bwb_line *l )
   {
   struct bwb_line *current, *previous;
   int wait;

   wait = TRUE;
   for ( current = bwb_start.next; current != &bwb_end; current = current->next )
      {
      if ( wait != TRUE )
         {
         free( previous );
         }
      wait = FALSE;
      previous = current;
      }

   bwb_start.next = &bwb_end;

   l->next->position = 0;

   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_renum()

        DESCRIPTION:

***************************************************************/

#ifdef ALLOW_RENUM
struct bwb_line *
bwb_renum( struct bwb_line *l )
   {
   struct bwb_line *current, *x;
   register int c, o;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* set c to initial number */

   c = 10;

   /* set all reset flags to FALSE */

   for ( x = bwb_start.next; x != &bwb_end; x = x->next )
      {
      x->reset = FALSE;
      }

   /* cycle through each line */

   for ( current = bwb_start.next; current != &bwb_end; current = current->next )
      {
      o = current->number;
      current->number = c;

      /* run back through and change any GOTO statements
         or GOSUB statements depending on this line */

      for ( x = bwb_start.next; x != &bwb_end; x = x->next )
         {

         if ( ( x->vector == bwb_goto ) || ( x->vector == bwb_gosub ))
            {
            if ( atoi( x->argv[ 0 ] ) == o )
               {

               if ( x->reset == FALSE )
                  {

                  #if INTENSIVE_DEBUG
                  sprintf( bwb_ebuf,
                     "in bwb_renum(): renumbering line %d, new argument is %d",
                     x->number, c );
                  bwb_debug( bwb_ebuf );
                  #endif

                  free( x->argv[ 0 ] );
                  sprintf( tbuf, "%d", c );
                  if ( ( x->argv[ 0 ] = calloc( 1, strlen( tbuf ) + 1 )) == NULL )
                     {
                     bwb_error( err_getmem );
                     l->next->position = 0;
                     return l->next;
                     }
                  strcpy( x->argv[ 0 ], tbuf );
                  x->reset = TRUE;
                  }
               }
            }

         }

      c += 10;
      }

   l->next->position = 0;
   return l->next;
   }
#endif

/***************************************************************

        FUNCTION:       bwb_save()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_save( struct bwb_line *l )
   {
   FILE *outfile;
   static char filename[ MAXARGSIZE ];

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_save(): entered function." );
   bwb_debug( bwb_ebuf );
   #endif

   /* Get an argument for filename */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         bwb_error( err_nofn );
         l->next->position = 0;
         return l->next;
      default:
         break;
      }

   bwb_const( l->buffer, filename, &( l->position ) );
   if ( ( outfile = fopen( filename, "w" )) == NULL )
      {
      sprintf( bwb_ebuf, err_openfile, filename );
      bwb_error( bwb_ebuf );
      l->next->position = 0;
      return l->next;
      }

   bwb_xlist( l, outfile );
   fclose( outfile );

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_list()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_list( struct bwb_line *l )
   {
   bwb_xlist( l, stdout );
   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_xlist()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_xlist( struct bwb_line *l, FILE *file )
   {
   struct bwb_line *start, *end, *current;
   register int n;
   static int s, e;
   int f, r;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   start = bwb_start.next;
   end = &bwb_end;

   r = bwb_numseq( &( l->buffer[ l->position ] ), &s, &e );

   if (( r == FALSE ) || ( s == 0 ))
      {
      s = bwb_start.next->number;
      }

   if ( e == 0 )
      {
      e = s;
      }

   if ( r == FALSE )
      {
      for ( current = bwb_start.next; current != &bwb_end; current = current->next )
         {
         if ( current->next == &bwb_end )
            {
            e = current->number;
            }
         }
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_list(): LBUFFER sequence is %d-%d", s, e );
   bwb_debug( bwb_ebuf );
   #endif

   /* Now try to find the actual lines in memory */

   f = FALSE;

   for ( current = bwb_start.next; current != &bwb_end; current = current->next )
      {
      if ( current != l )
         {
         current->position = 0;
         adv_element( current->buffer, &( current->position ), tbuf );
         if ( atoi( tbuf ) == s )
            {
            f = TRUE;
	    start = current;

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_list(): start line number is <%d>",
               s );
            bwb_debug( bwb_ebuf );
            #endif

            }
         }
      }

   /* check and see if a line number was found */

   if ( f == FALSE )
      {
      sprintf( bwb_ebuf, err_lnnotfound, s );
      bwb_error( bwb_ebuf );
      l->next->position = 0;
      return l->next;
      }

   if ( e > s )
      {
      for ( current = bwb_start.next; current != &bwb_end; current = current->next )
         {
         if ( current != l )
            {
            current->position = 0;
            adv_element( current->buffer, &( current->position ), tbuf );
            if ( atoi( tbuf ) == e )
               {
               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_list(): end line number is <%d>",
                  e );
               bwb_debug( bwb_ebuf );
               #endif

               end = current->next;
               }
            }
         }
      }
   else
      {
      end = start;
      }

   /* previous should now be set to the line previous to the
      first in the omission list */

   /* now go through and list appropriate lines */

   if ( start == end )
      {
      fprintf( file, "%s\n", start->buffer );
      }
   else
      {
      current = start;
      while ( current != end )
         {
         fprintf( file, "%s\n", current->buffer );
         current = current->next;
         }
      }

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_goto

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_goto( struct bwb_line *l )
   {
   struct bwb_line *x;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         bwb_error( err_noln );
         l->next->position = 0;
         return l->next;
      default:
         break;
      }

   adv_element( l->buffer, &( l->position ), tbuf );

   for ( x = &bwb_start; x != &bwb_end; x = x->next )
      {
      if ( x->number == atoi( tbuf ) )
         {
         x->position = 0;
         return x;
         }
      }

   sprintf( bwb_ebuf, err_lnnotfound, atoi( tbuf ) );
   bwb_error( bwb_ebuf );

   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_gosub()

	DESCRIPTION:    This function implements the BASIC GOSUB
			command.

***************************************************************/

struct bwb_line *
bwb_gosub( struct bwb_line *l )
   {
   struct bwb_line *x, *nl;
   int save_pos;
   register int c;
   char atbuf[ MAXSTRINGSIZE + 1 ];
   char btbuf[ MAXSTRINGSIZE + 1 ];

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         sprintf( bwb_ebuf, err_noln );
         bwb_error( bwb_ebuf );
         l->next->position = 0;
         return l->next;
      default:
         break;
      }

   /* get the target line number in tbuf */

   adv_element( l->buffer, &( l->position ), atbuf );

   for ( x = &bwb_start; x != &bwb_end; x = x->next )
      {

      if ( x != l )
         {
         x->position = 0;
         }

      /* try to get line number in tbuf */

      adv_element( x->buffer, &( x->position ), btbuf );

      if ( is_numconst( btbuf ) == TRUE )
         {
         if ( atoi( btbuf ) == atoi( atbuf ) )
            {
	    save_pos = l->position;

	    #if  INTENSIVE_DEBUG
	    sprintf( bwb_ebuf, "in bwb_gosub() at line <%d> gssc <%d>\n",
               l->number, bwb_gssc );
            bwb_debug( bwb_ebuf );
            bwb_debug( "Press RETURN: " );
            getchar();
            #endif

            /* increment the GOSUB stack counter */

            ++bwb_gssc;

            x->cmdnum = -1;
            x->marked = FALSE;
            x->position = 0;

            do
               {
               bwb_gss[ bwb_gssc ].position = 0;

	       /* execute the line */

	       nl = bwb_xline( x );

	       /* check for RETURN in the line */

	       if ( x->cmdnum == getcmdnum( "RETURN" ) )
		  {
		  l->position = save_pos;
		  #if  INTENSIVE_DEBUG
		  sprintf( bwb_ebuf, "in bwb_gosub(): return to line <%d>, position <%d>, gssc <%d>",
		     l->number, l->position, bwb_gssc );
		  bwb_debug( bwb_ebuf );
		  #endif
		  l->next->position = 0;
		  return l->next; 	/* but why shouldn't we continue processing */
		  }			/* this line? */
					/* answer: bwb_xline() will continue */
	       x = nl;

	       }

	    while ( TRUE );

            }
         }
      }

   sprintf( bwb_ebuf, err_lnnotfound, atoi( atbuf ) );
   bwb_error( bwb_ebuf );

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_return()

	DESCRIPTION:    This function implements the BASIC RETURN
			command.

***************************************************************/

struct bwb_line *
bwb_return( struct bwb_line *l )
   {

   #if  INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_return() at line <%d> bwb_gssc <%d>, cmdnum <%d>",
      l->number, bwb_gssc, l->cmdnum );
   bwb_debug( bwb_ebuf );
   #endif

   if ( bwb_gssc < 1 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_return(): bwb_gssc <%d>", bwb_gssc );
      #else
      sprintf( bwb_ebuf, ERR_RETNOGOSUB );
      #endif
      bwb_error( bwb_ebuf );
      l->next->position = 0;
      return l->next;
      }

   --bwb_gssc;

   #if  INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_return() at line <%d>: gss level <%d>",
      l->number, bwb_gssc );
   bwb_debug( bwb_ebuf );
   #endif

   l->cmdnum = getcmdnum( "RETURN" );
   l->marked = FALSE;

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       bwb_on

        DESCRIPTION:    This function implements the BASIC ON...
                        GOTO or ON...GOSUB statements.

***************************************************************/

struct bwb_line *
bwb_on( struct bwb_line *l )
   {
   struct bwb_line *x;
   char varname[ MAXVARNAMESIZE + 1 ];
   static int p;
   struct exp_ese *rvar;
   int v;
   int loop;
   int num_lines;
   int command;
   int lines[ MAX_GOLINES ];
   char tbuf[ MAXSTRINGSIZE + 1 ];
   char sbuf[ 7 ];

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );

   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         sprintf( bwb_ebuf, err_incomplete );
         bwb_error( bwb_ebuf );
         l->next->position = 0;
         return l->next;
      default:
         break;
      }

   /* get the variable name or numerical constant */

   adv_element( l->buffer, &( l->position ), varname );

   /* check for ON ERROR statement */

   strncpy( sbuf, varname, 6 );
   bwb_strtoupper( sbuf );
   if ( strcmp( sbuf, "ERROR" ) == 0 )
      {
      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_on(): detected ON ERROR" );
      bwb_debug( bwb_ebuf );
      #endif
      return bwb_onerror( l );
      }

   /* evaluate the variable name or constant */

   p = 0;
   rvar = bwb_exp( varname, FALSE, &p );
   v = exp_getival( rvar );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_on(): value is <%d>", v );
   bwb_debug( bwb_ebuf );
   #endif

   /* Get GOTO or GOSUB statements */

   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );
   if ( strncmp( tbuf, "GOTO", (size_t) 4 ) == 0 )
      {
      command = getcmdnum( "GOTO" );
      }
   else if ( strncmp( tbuf, "GOSUB", (size_t) 5 ) == 0 )
      {
      command = getcmdnum( "GOSUB" );
      }
   else
      {
      sprintf( bwb_ebuf, ERR_ONNOGOTO );
      bwb_error( bwb_ebuf );
      l->next->position = 0;
      return l->next;
      }

   num_lines = 0;

   loop = TRUE;
   while( loop == TRUE )
      {

      /* read a line number */

      inp_adv( l->buffer, &( l->position ) );
      adv_element( l->buffer, &( l->position ), tbuf );

      lines[ num_lines ] = atoi( tbuf );

      ++num_lines;

      if ( num_lines >= MAX_GOLINES )
         {
         loop = FALSE;
         }

      /* check for end of line */

      adv_ws( l->buffer, &( l->position ) );
      switch( l->buffer[ l->position ] )
         {
         case '\0':
         case '\n':
         case '\r':
         case ':':
            loop = FALSE;
            break;
         }

      }

   /* Be sure value is in range */

   if ( ( v < 1 ) || ( v > num_lines ))
      {
      sprintf( bwb_ebuf, err_valoorange );
      bwb_error( bwb_ebuf );
      l->next->position = 0;
      return l->next;
      }

   if ( command == getcmdnum( "GOTO" ))
      {
      sprintf( tbuf, "GOTO %d", lines[ v - 1 ] );
      return cnd_xpline( l, tbuf );
      }
   else if ( command == getcmdnum( "GOSUB" ))
      {
      sprintf( tbuf, "GOSUB %d", lines[ v - 1 ] );
      return cnd_xpline( l, tbuf );
      }
   else
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_on(): invalid value for command." );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      l->next->position = 0;
      return l->next;
      }

   }

/***************************************************************

        FUNCTION:       bwb_onerror()

        DESCRIPTION:	This C function implements the BASIC
        		ON ERROR GOSUB command.

***************************************************************/

struct bwb_line *
bwb_onerror( struct bwb_line *l )
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_onerror(): entered function" );
   bwb_debug( bwb_ebuf );
   #endif

   /* get the GOSUB STATEMENT */

   adv_element( l->buffer, &( l->position ), tbuf );

   /* check for GOSUB statement */

   bwb_strtoupper( tbuf );
   if ( strcmp( tbuf, "GOSUB" ) != 0 )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_onerror(): GOSUB statement missing" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return l;
      }

   /* get the GOSUB line number */

   adv_element( l->buffer, &( l->position ), tbuf );
   err_gosubn = atoi( tbuf );

   return l;
   }

/***************************************************************

        FUNCTION:       bwb_stop()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_stop( struct bwb_line *l )
   {
   return bwb_xend( l );
   }

/***************************************************************

        FUNCTION:       bwb_xend()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_xend( struct bwb_line *l )
   {

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_xend(): entered funtion" );
   bwb_debug( bwb_ebuf );
   #endif

   break_handler();

   return &bwb_end;
   }

/***************************************************************

        FUNCTION:       bwb_system()

        DESCRIPTION:


***************************************************************/

struct bwb_line *
bwb_system( struct bwb_line *l )
   {
   fprintf( stdout, "\n" );

   #if INTENSIVE_DEBUG
   bwb_debug( "in bwb_system(): ready to exit" );
   #endif

   exit( 0 );
   return &bwb_end;                 /* to make LINT happy */
   }

/***************************************************************

        FUNCTION:       bwb_tron()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_tron( struct bwb_line *l )
   {
   bwb_trace = TRUE;
   fprintf( stdout, "Trace is ON\n" );
   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_troff()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_troff( struct bwb_line *l )
   {
   bwb_trace = FALSE;
   fprintf( stdout, "Trace is OFF\n" );
   l->next->position = 0;
   return l->next;
   }

/***************************************************************


        FUNCTION:       bwb_delete()

        DESCRIPTION:

***************************************************************/

struct bwb_line *

bwb_delete( struct bwb_line *l )
   {
   struct bwb_line *start, *end, *current, *previous, *p;
   register int n;
   static int s, e;
   int f;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   previous = &bwb_start;
   start = bwb_start.next;
   end = &bwb_end;

   bwb_numseq( &( l->buffer[ l->position ] ), &s, &e );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_delete(): LBUFFER sequence is %d-%d", s, e );
   bwb_debug( bwb_ebuf );
   #endif

   /* Now try to find the actual lines in memory */

   previous = p = &bwb_start;
   f = FALSE;

   for ( current = bwb_start.next; current != &bwb_end; current = current->next )
      {
      if ( current != l )
         {
         current->position = 0;
         adv_element( current->buffer, &( current->position ), tbuf );
         if ( atoi( tbuf ) == s )
            {
            f = TRUE;
            previous = p;
            start = current;

            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_delete(): start line number is <%d>",
               s );
            bwb_debug( bwb_ebuf );
            #endif

            }
         }
      p = current;
      }

   /* check and see if a line number was found */

   if ( f == FALSE )
      {
      sprintf( bwb_ebuf, err_lnnotfound, s );
      bwb_error( bwb_ebuf );
      l->next->position = 0;
      return l->next;
      }

   if ( e > s )
      {
      for ( current = bwb_start.next; current != &bwb_end; current = current->next )
         {
         if ( current != l )
            {
            current->position = 0;
            adv_element( current->buffer, &( current->position ), tbuf );
            if ( atoi( tbuf ) == e )
               {
               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_delete(): end line number is <%d>",
                  e );
               bwb_debug( bwb_ebuf );
               #endif

               end = current->next;
               }
            }
         }
      }
   else
      {
      end = start;
      }

   /* previous should now be set to the line previous to the
      first in the omission list */

   /* now go through and delete appropriate lines */

   current = start;
   while ( current != end )
      {

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_delete(): deleting line %d",
         current->number );
      bwb_debug( bwb_ebuf );
      #endif

      /* free line memory */

      bwb_freeline( current );

      /* recycle */

      current = current->next;
      }

   /* reset link */

   previous->next = current;

   l->next->position = 0;
   return l->next;
   }

/***************************************************************

        FUNCTION:       bwb_randomize()

        DESCRIPTION:

***************************************************************/

struct bwb_line *
bwb_randomize( struct bwb_line *l )
   {
   register unsigned n;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* Check for argument */

   adv_ws( l->buffer, &( l->position ) );
   switch( l->buffer[ l->position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         n = (unsigned) 1;
         break;
      default:
         n = (unsigned) 0;
         break;
      }

   /* get the argument in tbuf */

   if ( n == (unsigned) 0 )
      {
      adv_element( l->buffer, &( l->position ), tbuf );
      n = (unsigned) atoi( tbuf );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_randomize(): argument is <%d>", n );
   bwb_debug( bwb_ebuf );
   #endif

   srand( n );

   l->next->position = 0;
   return l->next;
   }


/***************************************************************

        FUNCTION:       bwb_environ()

        DESCRIPTION:	This C function implements the BASIC
			ENVIRON command.  

***************************************************************/

struct bwb_line *
bwb_environ( struct bwb_line *l )
   {
   static char tbuf[ MAXSTRINGSIZE + 1 ];
   char tmp[ MAXSTRINGSIZE + 1 ];
   register int h, i;
   int pos;
   struct exp_ese *e;

   /* find the equals sign */

   for ( i = 0; ( l->buffer[ l->position ] != '=' ) && ( l->buffer[ l->position ] != '\0' ); ++i )
      {
      tbuf[ i ] = l->buffer[ l->position ];
      tbuf[ i + 1 ] = '\0';
      ++( l->position );
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_environ(): variable string is <%s>", tbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* get the value string to be assigned */

   pos = 0;
   e = bwb_exp( tbuf, FALSE, &pos );
   str_btoc( tbuf, exp_getsval( e ) );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_environ(): variable string resolves to <%s>", tbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* find the equals sign */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] != '=' )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_environ(): failed to find equal sign" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_syntax );
      #endif
      return l;
      }
   ++( l->position );

   /* get the value string to be assigned */

   e = bwb_exp( l->buffer, FALSE, &( l->position ));
   str_btoc( tmp, exp_getsval( e ) );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_environ(): value string resolves to <%s>", tmp );
   bwb_debug( bwb_ebuf );
   #endif

   /* construct string */

   strcat( tbuf, "=" );
   strcat( tbuf, tmp );

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_environ(): assignment string is <%s>", tbuf );
   bwb_debug( bwb_ebuf );
   #endif

   /* now assign value to variable */

 /*  if ( putenv( tbuf ) == -1 )
      {
      bwb_error( err_opsys );
      return l;
      }*/

   /* return */ 

   return l;

   }

/***************************************************************

        FUNCTION:       bwb_cmds()

        DESCRIPTION:

***************************************************************/

#if PERMANENT_DEBUG
struct bwb_line *
bwb_cmds( struct bwb_line *l )
   {
   register int n;

   fprintf( stdout, "BWBASIC COMMANDS AVAILABLE: \n" );

   /* run through the command table and print comand names */

   for ( n = 0; n < COMMANDS; ++n )
      {
      fprintf( stdout, "%s \n", bwb_cmdtable[ n ].name );
      }

   l->next->position = 0;
   return l->next;
   }
#endif

int
getcmdnum( char *cmdstr )
   {
   register int c;

   for ( c = 0; c < COMMANDS; ++c )
      {
      if ( strcmp( bwb_cmdtable[ c ].name, cmdstr ) == 0 )
         {
         return c;
         }
      }

   return -1;

   }
