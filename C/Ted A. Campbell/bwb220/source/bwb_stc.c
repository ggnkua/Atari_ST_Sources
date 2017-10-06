/***************************************************************

        bwb_stc.c       Commands Related to Structured Programming
                        for Bywater BASIC Interpreter

                        Commands:	CALL
					SUB
					FUNCTION
					END SUB
					END FUNCTION

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
#include <ctype.h>

#include "bwbasic.h"
#include "bwb_mes.h"

/* prototypes */

#if ANSI_C
static int fslt_clear( void );
static int fslt_add( struct bwb_line *line, int *position, int code );
static struct bwb_line *fslt_findl( char *buffer );
static struct fslte    *fslt_findf( char *buffer );
static int scan_getcmd( struct bwb_line *line, int *position );
static int scan_readargs( struct fslte *f,
   struct bwb_line *line, int *position );
static int call_readargs( struct fslte *f,
   char *expression, int *position );
static int is_endsub( struct bwb_line *l );
static struct bwb_line *find_endsub( struct bwb_line *l );
static struct bwb_line *bwb_loopuntil( struct bwb_line *l );
struct bwb_variable *bwb_vtov( struct bwb_variable *dst, struct bwb_variable *src );
struct bwb_variable *bwb_etov( struct bwb_variable *dst, struct exp_ese *src );
struct bwb_variable *var_pos( struct bwb_variable *firstvar, int p );
int fslt_addcallvar( struct bwb_variable *v );
int fslt_addlocalvar( struct fslte *f, struct bwb_variable *v );
#else
static int fslt_clear();
static int fslt_add();
static struct bwb_line *fslt_findl();
static struct fslte    *fslt_findf();
static int scan_getcmd();
static int scan_readargs();
static int call_readargs();
static int is_endsub();
static struct bwb_line *find_endsub();
static struct bwb_line *bwb_loopuntil();
struct bwb_variable *bwb_vtov();
struct bwb_variable *bwb_etov();
struct bwb_variable *var_pos();
int fslt_addcallvar();
int fslt_addlocalvar();
#endif				/* ANSI_C for prototypes */

/***************************************************************

        FUNCTION:       bwb_scan()

        DESCRIPTION:	This function scans all lines of the
        		program in memory and creates a FUNCTION-
        		SUB lookup table (fslt) for the program.

***************************************************************/

#if ANSI_C
int
bwb_scan( void )
#else
int
bwb_scan()
#endif
   {
   struct bwb_line *current;
   int position;
   int c;

#if PROG_ERRORS
   if ( CURTASK rescan != TRUE )
      {
      bwb_error( "in bwb_scan(): call to scan while CURTASK rescan != TRUE" );
      return FALSE;
      }
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_scan(): beginning scan..." );
   bwb_debug( bwb_ebuf );
#endif

   /* first run through the FUNCTION - SUB loopkup table
      and free any existing memory */

   fslt_clear();

   /* run through the list of lines and identify SUB and FUNCTION statements */

   for ( current = CURTASK bwb_start.next; current != &CURTASK bwb_end; current = current->next )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_scan(): scanning line <%d>", current->number );
      bwb_debug( bwb_ebuf );
#endif

      c = scan_getcmd( current, &position );
      if ( c == getcmdnum( CMD_SUB ))
         {
         fslt_add( current, &position, EXEC_CALLSUB );
         }
      else if ( c == getcmdnum( CMD_FUNCTION ))
         {
         fslt_add( current, &position, EXEC_FUNCTION );
         }
      else if ( c == getcmdnum( CMD_DEF ))
         {
         fslt_add( current, &position, EXEC_FUNCTION );
         }
#if STRUCT_CMDS
      else if ( c == getcmdnum( CMD_LABEL ))
         {
         fslt_add( current, &position, EXEC_LABEL );
         }
#endif
      }

   /* return */

   CURTASK rescan = FALSE;
   return TRUE;

   }

/***************************************************************

        FUNCTION:       fslt_clear()

        DESCRIPTION:	This C function clears all existing memory
        		in the FUNCTION-SUB lookup table.

***************************************************************/

#if ANSI_C
static int
fslt_clear( void )
#else
static int
fslt_clear()
#endif
   {
   struct fslte *current, *next;
   struct bwb_variable *c, *n;

   /* run through table and clear memory */

   next = CURTASK fslt_start.next;
   for ( current = CURTASK fslt_start.next; current != &CURTASK fslt_end;
      current = next )
      {

      /* check for local variables and free them */

      c = current->local_variable;
      while ( c != NULL )
         {
         n = c->next;

         /* Revised to FREE pass-thru call by JBV */
         FREE( c, "fslt_clear" );
         c = n;
         }

      next = current->next;

      /* Revised to FREE pass-thru calls by JBV */
      if (current->name != NULL)
      {
          FREE( current->name, "fslt_clear" ); /* JBV */
          current->name = NULL; /* JBV */
      }
      FREE( current, "fslt_clear" );
      current = NULL; /* JBV */
      }

   /* reset linkage */

   CURTASK fslt_start.next = &CURTASK fslt_end;

   return TRUE;
   }

/***************************************************************

        FUNCTION:       scan_getcmd()

        DESCRIPTION:	This command returns the command number
        		for the first BASIC command word encountered
        		in a line.

***************************************************************/

#if ANSI_C
static int
scan_getcmd( struct bwb_line *line, int *position )
#else
static int
scan_getcmd( line, position )
   struct bwb_line *line;
   int *position;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

   *position = 0;
   adv_ws( line->buffer, position );

   /* check for NULL line */

   if ( line->buffer[ *position ] == '\0' )
      {
      return -1;
      }

   /* check for line number and advance beyond it */

   if ( isdigit( line->buffer[ *position ] ))
      {
      scan_element( line->buffer, position, tbuf );
      }

   /* get the command element in the buffer */

   scan_element( line->buffer, position, tbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in scan_getcmd(): scanning element <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif

#if STRUCT_CMDS

   if ( is_label( tbuf ) == TRUE )
      {
#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in scan_getcmd(): found label <%s>", tbuf );
      bwb_debug( bwb_ebuf );
#endif

      return getcmdnum( CMD_LABEL );
      }

#endif

   bwb_strtoupper( tbuf );

   /* return command number */

   return getcmdnum( tbuf );

   }

/***************************************************************

	FUNCTION:       scan_element()

        DESCRIPTION:    This function reads characters in <buffer>
                        beginning at <pos> and advances past a
                        line element, incrementing <pos> appropri-
                        ately and returning the line element in
			<element>.

			This function is almost identical to adv_element(),
			but it will not stop at a full colon.  This is
			necessary to detect a label in the first element
			position.  If MULTISEG_LINES is defined as TRUE,
			adv_element() will stop at the colon, interpreting
			it as the end-of-segment marker.

***************************************************************/

#if ANSI_C
extern int
scan_element( char *buffer, int *pos, char *element )
#else
int
scan_element( buffer, pos, element )
   char *buffer;
   int *pos;
   char *element;
#endif
   {
   int loop;                                    /* control loop */
   int e_pos;                                   /* position in element buffer */
   int str_const;                               /* boolean: building a string constant */

   /* advance beyond any initial whitespace */

   adv_ws( buffer, pos );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in adv_element(): receieved <%s>.", &( buffer[ *pos ] ));
   bwb_debug( bwb_ebuf );
#endif

   /* now loop while building an element and looking for an
      element terminator */

   loop = TRUE;
   e_pos = 0;
   element[ e_pos ] = '\0';
   str_const = FALSE;

   while ( loop == TRUE )
      {
      switch( buffer[ *pos ] )
         {
         case ',':                      /* element terminators */
         case ';':
	 case '=':
	 case ' ':
         case '\t':
         case '\0':
         case '\n':
         case '\r':
            if ( str_const == TRUE )
               {
               element[ e_pos ] = buffer[ *pos ];
               ++e_pos;
               ++( *pos );
               element[ e_pos ] = '\0';
               }
            else
               {
               return TRUE;
               }
            break;

         case '\"':                     /* string constant */
            element[ e_pos ] = buffer[ *pos ];
            ++e_pos;
            ++( *pos );
            element[ e_pos ] = '\0';
            if ( str_const == TRUE )    /* termination of string constant */
               {
               return TRUE;
               }
            else                        /* beginning of string constant */
               {
               str_const = TRUE;
               }
            break;

         case '(':                     /* MID$ command termination (JBV) */
            /* If MID$ is here, get out */
            if (strcmp(element, CMD_MID) == 0)
               return TRUE;

            /* else add it to the accumulation element */
            element[ e_pos ] = buffer[ *pos ];
            ++e_pos;
            ++( *pos );
            element[ e_pos ] = '\0';
            break;

         default:
            element[ e_pos ] = buffer[ *pos ];
            ++e_pos;
            ++( *pos );
            element[ e_pos ] = '\0';
            break;
         }
      }

   /* This should not happen */

   return FALSE;

   }

/***************************************************************

        FUNCTION:       fslt_add()

        DESCRIPTION:	This C function adds an entry to the
        		FUNCTION-SUB lookup table.

***************************************************************/

#if ANSI_C
static int
fslt_add( struct bwb_line *line, int *position, int code )
#else
static int
fslt_add( line, position, code )
   struct bwb_line *line;
   int *position;
   int code;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   char *name;
   struct bwb_variable *v;
   struct fslte *f, *n;
   int p;

   /* get the element for name */

   if ( code == EXEC_LABEL )
      {
      p = 0;
      scan_element( line->buffer, &p, tbuf );
      if ( isdigit( tbuf[ 0 ] ))
         {
	 scan_element( line->buffer, &p, tbuf );
         }
      tbuf[ strlen( tbuf ) - 1 ] = '\0';
      }
   else
      {
      adv_ws( line->buffer, position );
      exp_getvfname( &( line->buffer[ *position ] ), tbuf );
      *position += strlen( tbuf );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fslt_add(): adding SUB/FUNCTION/LABEL code <%d> name <%s>",
      code, tbuf );
   bwb_debug( bwb_ebuf );
#endif

   /* get memory for name buffer */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( name = CALLOC( 1, strlen( tbuf ) + 1, "fslt_add" ) ) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in fslt_add(): failed to get memory for name buffer" );
#else
      bwb_error( err_getmem );
#endif
      return FALSE;
      }

   strcpy( name, tbuf );

   /* get memory for fslt structure */

   if ( ( f = CALLOC( 1, sizeof( struct fslte ), "fslt_add" ) ) == NULL )
      {
#if PROG_ERRORS
      bwb_error( "in fslt_add(): failed to get memory for fslt structure" );
#else
      bwb_error( err_getmem );
#endif
      return FALSE;
      }

   /* fill in structure */

   f->line = line;
   f->name = name;
   f->code = code;
   f->local_variable = NULL;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fslt_add(): current buffer <%s>",
      &( line->buffer[ *position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* read arguments */

   adv_ws( line->buffer, position );
   if ( line->buffer[ *position ] == '(' )
      {
      scan_readargs( f, line, position );
      }

   /* if function, add one more local variable expressing the name
      of the function */

   if ( code == EXEC_FUNCTION )
      {

      v = var_new( tbuf );
      fslt_addlocalvar( f, v );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in fslt_add(): added function-name variable <%s>",
         v->name );
      bwb_debug( bwb_ebuf );
      getchar();
#endif

      }

   /* establish linkages */

   n = CURTASK fslt_start.next;
   CURTASK fslt_start.next = f;
   f->next = n;

   return TRUE;

   }

/***************************************************************

        FUNCTION:       scan_readargs()

        DESCRIPTION:	This C function reads arguments (variable
        		names for an entry added to the FUNCTION-
			SUB lookup table.

***************************************************************/

#if ANSI_C
static int
scan_readargs( struct fslte *f, struct bwb_line *line, int *position )
#else
static int
scan_readargs( f, line, position )
   struct fslte *f;
   struct bwb_line *line;
   int *position;
#endif
   {
   int control_loop;
   struct bwb_variable *v;
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in scan_readargs(): reading arguments, buffer <%s>",
      &( line->buffer[ *position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* if we are at begin paren, advance */

   if ( line->buffer[ *position ] == '(' )
      {
      ++( *position );
      }

   /* loop through looking for arguments */

   control_loop = TRUE;
   adv_ws( line->buffer, position );
   while ( control_loop == TRUE )
      {

      switch( line->buffer[ *position ] )
         {
         case '\n':		/* premature end of line */
         case '\r':
         case '\0':
            control_loop = FALSE;
            f->startpos = *position;
            bwb_error( err_syntax );
            return FALSE;
         case ')':		/* end of argument list */
            ++( *position );
            control_loop = FALSE;
            f->startpos = *position;
            return TRUE;

         default:		/* presume beginning of argument == variable name */

            exp_getvfname( &( line->buffer[ *position ] ), tbuf );
            *position += strlen( tbuf );

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in scan_readargs(): read argument <%s>",
               tbuf );
            bwb_debug( bwb_ebuf );
#endif

            /* initialize the variable and add it to local chain */

            v = var_new( tbuf );
            fslt_addlocalvar( f, v );

            /* advance past the comma */

            if ( line->buffer[ *position ] == ',' )
               {
               ++( *position );
               }

            break;
         }

      adv_ws( line->buffer, position );
      }

   return TRUE;

   }

/***************************************************************

        FUNCTION:       call_readargs()

        DESCRIPTION:	This C function reads arguments (variable
        		names for a subroutine CALL or function
			call.

***************************************************************/

#if ANSI_C
static int
call_readargs( struct fslte *f, char *expression, int *position )
#else
static int
call_readargs( f, expression, position )
   struct fslte *f;
   char *expression;
   int *position;
#endif
   {
   int control_loop;
   struct bwb_variable *v, *c;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   int argument_counter;
   int local_pos, single_var;
   struct exp_ese *e;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in call_readargs(): reading arguments, buffer <%s>",
      &( expression[ *position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* if we are at begin paren, advance */

   if ( expression[ *position ] == '(' )
      {
      ++( *position );
      }

   /* loop through looking for arguments */

   control_loop = TRUE;
   argument_counter = 0;

   while ( control_loop == TRUE )
      {

      adv_ws( expression, position );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in call_readargs(): in loop, buffer <%s>",
         &( expression[ *position ] ) );
      bwb_debug( bwb_ebuf );
#endif

      switch( expression[ *position ] )
         {
         case '\n':		/* end of line */
         case '\r':
	 case '\0':
#if MULTISEG_LINES
	 case ':':              /* end of segment */
#endif
            control_loop = FALSE;
            return FALSE;

         case ')':		/* end of argument list */
            ++( *position );
            control_loop = FALSE;
            return TRUE;

         default:		/* presume beginning of argument */

            /* read the first word to see if it is a single variable name */

            single_var = FALSE;
            exp_getvfname( &( expression[ *position ] ), tbuf );
            local_pos = *position + strlen( tbuf );

            adv_ws( expression, &local_pos );

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in call_readargs(): in loop, tbuf <%s>",
               tbuf );
            bwb_debug( bwb_ebuf );
#endif

            /* check now for the single variable name */

            if ( strlen( tbuf ) == 0 )
               {
               single_var = FALSE;
               }

            else
               {
               switch ( expression[ local_pos ] )
                  {
                  case ')':		/* end of argument list */

#if INTENSIVE_DEBUG
		     sprintf( bwb_ebuf, "in call_readargs(): detected end of argument list" );
		     bwb_debug( bwb_ebuf );
#endif

		     ++local_pos;       /* and fall through */
                  case '\n':		/* end of line */
                  case '\r':
		  case '\0':
#if MULTISEG_LINES
		  case ':':             /* end of segment */
#endif
		     control_loop = FALSE;      /* and fall through */
						/* added 1993-06-16 */
		  case ',':             /* end of argument */

		     single_var = TRUE;

		     /* look for variable from previous (calling) level */

		     -- CURTASK exsc;
		     v = var_find( tbuf );      /* find variable there */
		     ++ CURTASK exsc;

		     c = var_pos( CURTASK excs[ CURTASK exsc ].local_variable,
                        argument_counter );	/* find local equivalent */
                     bwb_vtov( c, v );		/* assign calling value to local variable */

#if INTENSIVE_DEBUG
		     sprintf( bwb_ebuf, "in call_readargs(): variable name is <%s>, local name <%s>",
			v->name, c->name );
		     bwb_debug( bwb_ebuf );
#endif

		     *position = local_pos;
                     break;
                  default:
                     single_var = FALSE;
                     break;
                  }
               }

            if ( single_var == FALSE )
               {
#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in call_readargs(): in loop, parse expression <%s>",
                  &( expression[ *position ] ) );
               bwb_debug( bwb_ebuf );
#endif

               e = bwb_exp( expression, FALSE, position );	/* parse */

#if INTENSIVE_DEBUG
	       sprintf( bwb_ebuf, "in call_readargs(): in loop, parsed expression, buffer <%s>",
		  &( expression[ *position ] ) );
               bwb_debug( bwb_ebuf );
#endif

               v = var_pos( CURTASK excs[ CURTASK exsc ].local_variable,
                  argument_counter );		/* assign to variable */
               bwb_etov( v, e );		/* assign value */
               }

            /* add the variable to the calling variable chain */

            fslt_addcallvar( v );

#if INTENSIVE_DEBUG
            str_btoc( tbuf, var_getsval( v ));
            if ( single_var == TRUE )
               {
               sprintf( bwb_ebuf, "in call_readargs(): added arg <%d> (single) name <%s> value <%s>",
                  argument_counter, v->name, tbuf );
               }
            else
               {
               sprintf( bwb_ebuf, "in call_readargs(): added arg <%d> (expression) name <%s> value <%s>",
                  argument_counter, v->name, tbuf );
               }
            bwb_debug( bwb_ebuf );
            getchar();
#endif

            /* advance past comma if present */

            adv_ws( expression, position );
            if ( expression[ *position ] == ',' )
               {
               ++( *position );
               }

            break;
         }

      ++argument_counter;

      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in call_readargs(): exiting function" );
   bwb_debug( bwb_ebuf );
#endif

   return TRUE;

   }

/***************************************************************

        FUNCTION:       fslt_findl()

        DESCRIPTION:	This C function finds a line corresponding
        		to a name in the FUNCTION-SUB lookup
			table.

***************************************************************/

#if ANSI_C
static struct bwb_line *
fslt_findl( char *buffer )
#else
static struct bwb_line *
fslt_findl( buffer )
   char *buffer;
#endif
   {
   struct fslte *r;

   r = fslt_findf( buffer );

   return r->line;

   }

/***************************************************************

        FUNCTION:       fslt_findf()

        DESCRIPTION:	This C function finds an fslte structure
			corresponding to a name in the FUNCTION-
			SUB lookup table.

***************************************************************/

#if ANSI_C
static struct fslte *
fslt_findf( char *buffer )
#else
static struct fslte *
fslt_findf( buffer )
   char *buffer;
#endif
   {
   struct fslte *f;
   register int c;

   /* remove open-paren from string */

   for ( c = 0; buffer[ c ] != '\0'; ++c )
      {
      if ( buffer[ c ] == '(' )
         {
         buffer[ c ] = '\0';
         }
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fslt_findf(): search for name <%s>", buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* run through the table */

   for ( f = CURTASK fslt_start.next; f != &CURTASK fslt_end; f = f->next )
      {
      if ( strcmp( f->name, buffer ) == 0 )
         {
         return f;
         }
      }

   /* search has failed */

#if PROG_ERRORS
   sprintf( bwb_ebuf, "in fslt_findf(): failed to find Function/Subroutine <%s>",
      buffer );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_lnnotfound );
#endif

   return NULL;

   }

/***************************************************************

        FUNCTION:       bwb_def()

        DESCRIPTION:    This C function implements the BASIC
                        DEF statement. Since DEF and FUNCTION
			are equivalent, it simply passes execution
			to bwb_function().

	SYNTAX:		DEF FNname(arg...)] = expression

	NOTE:		It is not a strict requirement that the
			function name should begin with "FN".

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_def( struct bwb_line *l )
#else
struct bwb_line *
bwb_def( l )
   struct bwb_line *l;
#endif
   {

#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif

   return bwb_zline( l );
   }

#if STRUCT_CMDS

/***************************************************************

        FUNCTION:       bwb_function()

        DESCRIPTION:	This C function implements the BASIC
			FUNCTION and DEF commands.

	SYNTAX:		FUNCTION function-definition

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_function( struct bwb_line *l )
#else
struct bwb_line *
bwb_function( l )
   struct bwb_line *l;
#endif
   {

   return bwb_def( l );

   }

/***************************************************************

        FUNCTION:       bwb_endfnc()

        DESCRIPTION:	This C function implements the BASIC
			END FUNCTION command, ending a subroutine
			definition.  Because the command END
			can have multiple meanings, this function
			should be called from the bwb_xend()
			function, which should be able to identify
			an END FUNCTION command.

	SYNTAX:		END FUNCTION

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_endfnc( struct bwb_line *l )
#else
struct bwb_line *
bwb_endfnc( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_variable *local;
   register int c;

   /* assign local variable values to calling variables */

   local = CURTASK excs[ CURTASK exsc ].local_variable;
   for ( c = 0; c < CURTASK excs[ CURTASK exsc ].n_cvs; ++c )
      {
      bwb_vtov( CURTASK excs[ CURTASK exsc ].calling_variable[ c ], local );
      local = local->next;
      }

   /* decrement the EXEC stack counter */

   bwb_decexec();

   /* and return next from old line */

   CURTASK excs[ CURTASK exsc ].line->next->position = 0;
   return CURTASK excs[ CURTASK exsc ].line->next;

   }

/***************************************************************

        FUNCTION:       bwb_call()

        DESCRIPTION:	This C function implements the BASIC
        		CALL subroutine command.

	SYNTAX:		CALL subroutine-name

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_call( struct bwb_line *l )
#else
struct bwb_line *
bwb_call( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   struct bwb_line *call_line;
   struct fslte *f;

   adv_element( l->buffer, &( l->position ), tbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_call(): call to subroutine <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif

   /* find the line to call */

   call_line = fslt_findl( tbuf );
   f = fslt_findf( tbuf );

   if ( call_line == NULL )
      {
      return bwb_zline( l );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_call(): found line <%s>",
      call_line->buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* save the old position on the EXEC stack */

   bwb_setexec( l, l->position, CURTASK excs[ CURTASK exsc ].code );

   /* increment and set new EXEC stack */

   bwb_incexec();
   call_line->position = 0;
   bwb_setexec( call_line, 0, EXEC_CALLSUB );

   /* attach local variables */

   CURTASK excs[ CURTASK exsc ].local_variable = f->local_variable;

   /* read calling variables for this call */

   call_readargs( f, l->buffer, &( l->position ) );

   return call_line;

   }

/***************************************************************

        FUNCTION:       bwb_sub()

	DESCRIPTION:    This function implements the BASIC
			SUB command, introducing a named
			subroutine.

	SYNTAX:		SUB subroutine-name
			(followed by subroutine definition ending
			with END SUB).

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_sub( struct bwb_line *l )
#else
struct bwb_line *
bwb_sub( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   struct bwb_line *rline;
#if MULTISEG_LINES
   struct fslte *f;
#endif

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_sub(): entered function at exec level <%d>",
      CURTASK exsc );
   bwb_debug( bwb_ebuf );
#endif

   /* check current exec level: if 1 then only MAIN should be executed */

   if ( CURTASK exsc == 0 )
      {
      adv_element( l->buffer, &( l->position ), tbuf );
      bwb_strtoupper( tbuf );
      if ( strcmp( tbuf, "MAIN" ) == 0 )
         {
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_sub(): found MAIN function at level 0" );
         bwb_debug( bwb_ebuf );
#endif

         bwb_incexec();

         bwb_setexec( l->next, 0, EXEC_MAIN );

         return bwb_zline( l );

         }

      /* if a MAIN function was not found at level 0, then skip the subroutine */

      else
         {

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_sub(): found non-MAIN function at level 0" );
         bwb_debug( bwb_ebuf );
#endif

         rline = find_endsub( l );
         bwb_setexec( rline->next, 0, EXEC_CALLSUB );
         rline->next->position = 0;
         return rline->next;
         }
      }

   /* check for integrity of CALL-SUB sequence if above level 0 */

   else if ( CURTASK excs[ CURTASK exsc ].code != EXEC_CALLSUB )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_sub(): SUB without CALL" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_retnogosub );
#endif
      }

   /* advance position */

#if MULTISEG_LINES
   adv_ws( l->buffer, &( l->position ));
   adv_element( l->buffer, &( l->position ), tbuf );
   f = fslt_findf( tbuf );

   l->position = f->startpos;

   return bwb_zline( l );
#else
   return bwb_zline( l );
#endif
   }

/***************************************************************

        FUNCTION:       find_endsub()

        DESCRIPTION:    This function searches for a line containing
                        an END SUB statement corresponding to a previous
                        SUB statement.

***************************************************************/

#if ANSI_C
static struct bwb_line *
find_endsub( struct bwb_line *l )
#else
static struct bwb_line *
find_endsub( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *current;
   register int s_level;
   int position;

   s_level = 1;
   for ( current = l->next; current != &CURTASK bwb_end; current = current->next )
      {
      position = 0;
      if ( current->marked != TRUE )
         {
         line_start( current->buffer, &position, &( current->lnpos ),
            &( current->lnum ),
            &( current->cmdpos ),
            &( current->cmdnum ),
            &( current->startpos ) );
         }
      current->position = current->startpos;

      if ( current->cmdnum > -1 )
         {

         if ( bwb_cmdtable[ current->cmdnum ].vector == bwb_sub )
            {
            ++s_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in find_endsub(): found SUB at line %d, level %d",
               current->number, s_level );
            bwb_debug( bwb_ebuf );
#endif

            }
         else if ( is_endsub( current ) == TRUE )
            {
            --s_level;

#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in find_endsub(): found END SUB at line %d, level %d",
               current->number, s_level );
            bwb_debug( bwb_ebuf );
#endif

            if ( s_level == 0 )
               {
               return current;
               }
            }

         }
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "SUB without END SUB" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax  );
#endif

   return NULL;

   }

/***************************************************************

	FUNCTION:       is_endsub()

	DESCRIPTION:    This function determines whether the
			line buffer for line 'l' is positioned
			at an END SUB statement.

***************************************************************/

#if ANSI_C
static int
is_endsub( struct bwb_line *l )
#else
static int
is_endsub( l )
   struct bwb_line *l;
#endif
   {
   int position;
   char tbuf[ MAXVARNAMESIZE + 1];

   if ( bwb_cmdtable[ l->cmdnum ].vector != bwb_xend )
      {
      return FALSE;
      }

   position = l->startpos;
   adv_ws( l->buffer, &position );
   adv_element( l->buffer, &position, tbuf );
   bwb_strtoupper( tbuf );

   if ( strcmp( tbuf, "SUB" ) == 0 )
      {
      return TRUE;
      }

   return FALSE;

   }

/***************************************************************

        FUNCTION:       bwb_endsub()

        DESCRIPTION:	This C function implements the BASIC
			END SUB command, ending a subroutine
			definition.  Because the command END
			can have multiple meanings, this function
			should be called from the bwb_xend()
			function, which should be able to identify
			an END SUB command.

	SYNTAX:		END SUB

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_endsub( struct bwb_line *line )
#else
struct bwb_line *
bwb_endsub( line )
   struct bwb_line *line;
#endif
   {
   struct bwb_variable *l;
   register int c;

   /* assign local variable values to calling variables */

   l = CURTASK excs[ CURTASK exsc ].local_variable;
   for ( c = 0; c < CURTASK excs[ CURTASK exsc ].n_cvs; ++c )
      {
      bwb_vtov( CURTASK excs[ CURTASK exsc ].calling_variable[ c ], l );
      l = l->next;
      }

   /* decrement the EXEC stack counter */

   bwb_decexec();

   /* if the previous level was EXEC_MAIN,
      then execution continues from this point */

   if ( CURTASK excs[ CURTASK exsc + 1 ].code == EXEC_MAIN )
      {
      return bwb_zline( line );
      }

   /* else return next from old line */

   CURTASK excs[ CURTASK exsc ].line->next->position = 0;
   return CURTASK excs[ CURTASK exsc ].line->next;

   }

/***************************************************************

	FUNCTION:	find_label()

	DESCRIPTION:	This C function finds a program line that
			begins with the label included in <buffer>.

***************************************************************/

#if ANSI_C
extern struct bwb_line *
find_label( char *buffer )
#else
extern struct bwb_line *
find_label( buffer )
   char *buffer;
#endif
   {
   struct fslte *f;

   for ( f = CURTASK fslt_start.next; f != & ( CURTASK fslt_end ); f = f->next )
      {
      if ( strcmp( buffer, f->name ) == 0 )
         {
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in find_label(): found label <%s>", buffer );
         bwb_debug( bwb_ebuf );
#endif
         return f->line;
         }
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "in find_label(): failed to find label <%s>", buffer );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_lnnotfound );
#endif

   return NULL;

   }

/***************************************************************

	FUNCTION:       bwb_doloop()

	DESCRIPTION:    This C function implements the ANSI BASIC
			DO statement, when DO is not followed by
			an argument.  It is called by bwb_do() in
			bwb_cmd.c.

	SYNTAX:		DO

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_doloop( struct bwb_line *l )
#else
struct bwb_line *
bwb_doloop( l )
   struct bwb_line *l;
#endif
   {

   /* if this is the first time at this DO statement, note it */

   if ( CURTASK excs[ CURTASK exsc ].while_line != l )
      {

      bwb_incexec();
      CURTASK excs[ CURTASK exsc ].while_line = l;

      /* find the LOOP statement */

      CURTASK excs[ CURTASK exsc ].wend_line = find_loop( l );

      if ( CURTASK excs[ CURTASK exsc ].wend_line == NULL )
	 {
	 return bwb_zline( l );
	 }

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_doloop(): initialize DO loop, line <%d>",
	 l->number );
      bwb_debug( bwb_ebuf );
#endif

      }
#if INTENSIVE_DEBUG
   else
      {
      sprintf( bwb_ebuf, "in bwb_doloop(): return to DO loop, line <%d>",
	 l->number );
      bwb_debug( bwb_ebuf );
      }
#endif

   bwb_setexec( l, l->position, EXEC_DO );
   return bwb_zline( l );
   }

/***************************************************************

        FUNCTION:       bwb_loop()

	DESCRIPTION:    This C function implements the ANSI BASIC
			LOOP statement.

	SYNTAX:		LOOP [UNTIL expression]
			
***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_loop( struct bwb_line *l )
#else
struct bwb_line *
bwb_loop( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_loop(): entered subroutine" );
   bwb_debug( bwb_ebuf );
#endif

   /* If the current exec stack is set for EXEC_WHILE, then we
      presume that this is a LOOP statement ending a DO WHILE
      loop */

   if ( CURTASK excs[ CURTASK exsc ].code == EXEC_WHILE )
      {
      return bwb_wend( l );
      }

   /* check integrity of DO loop */

   if ( CURTASK excs[ CURTASK exsc ].code != EXEC_DO )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_loop(): exec stack code != EXEC_DO" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      }

   if ( CURTASK excs[ CURTASK exsc ].while_line == NULL )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_loop(): exec stack while_line == NULL" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      }

   /* advance to find the first argument */

   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );

   /* detect a LOOP UNTIL structure */

   if ( strcmp( tbuf, CMD_XUNTIL ) == 0 )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_loop(): detected LOOP UNTIL" );
      bwb_debug( bwb_ebuf );
#endif

      return bwb_loopuntil( l );

      }

   /* LOOP does not have UNTIL */

   else
      {

      /* reset to the top of the current DO loop */

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_loop() return to line <%d>",
	 CURTASK excs[ CURTASK exsc ].while_line->number );
      bwb_debug( bwb_ebuf );
#endif

      CURTASK excs[ CURTASK exsc ].while_line->position = 0;
      bwb_setexec( CURTASK excs[ CURTASK exsc ].while_line, 0, EXEC_DO );

      return CURTASK excs[ CURTASK exsc ].while_line;

      }

   }

/***************************************************************

	FUNCTION:       bwb_loopuntil()

	DESCRIPTION:    This C function implements the ANSI BASIC
			LOOP UNTIL statement and is called by
			bwb_loop().

***************************************************************/

#if ANSI_C
static struct bwb_line *
bwb_loopuntil( struct bwb_line *l )
#else
static struct bwb_line *
bwb_loopuntil( l )
   struct bwb_line *l;
#endif
   {
   struct exp_ese *e;
   struct bwb_line *r;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_loopuntil(): entered subroutine" );
   bwb_debug( bwb_ebuf );
#endif

   /* call bwb_exp() to interpret the expression */

   e = bwb_exp( l->buffer, FALSE, &( l->position ) );

   if ( (int) exp_getnval( e ) != FALSE ) /* Was == TRUE (JBV 10/1996) */
      {
      CURTASK excs[ CURTASK exsc ].while_line = NULL;
      r = CURTASK excs[ CURTASK exsc ].wend_line;
      bwb_setexec( r, 0, CURTASK excs[ CURTASK exsc - 1 ].code );
      r->position = 0;
      bwb_decexec();
      return r;
      }

   /* condition is false: loop around to DO again */

   else
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_loopuntil() return to line <%d>",
	 CURTASK excs[ CURTASK exsc ].while_line->number );
      bwb_debug( bwb_ebuf );
#endif

      CURTASK excs[ CURTASK exsc ].while_line->position = 0;
      bwb_setexec( CURTASK excs[ CURTASK exsc ].while_line, 0, EXEC_DO );

      return CURTASK excs[ CURTASK exsc ].while_line;

      }

   }

/***************************************************************

        FUNCTION:       bwb_exit()

	DESCRIPTION:    This C function implements the BASIC EXIT
			statement, calling subroutines for either
			EXIT FOR or EXIT DO.

	SYNTAX:		EXIT FOR|DO

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_exit( struct bwb_line *l )
#else
struct bwb_line *
bwb_exit( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_exit(): entered subroutine" );
   bwb_debug( bwb_ebuf );
#endif

   adv_element( l->buffer, &( l->position ), tbuf );
   bwb_strtoupper( tbuf );

   if ( strcmp( tbuf, CMD_XFOR ) == 0 )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_exit(): detected EXIT FOR" );
      bwb_debug( bwb_ebuf );
#endif

      return bwb_exitfor( l );
      }

   if ( strcmp( tbuf, CMD_XDO ) == 0 )
      {
      return bwb_exitdo( l );
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "in bwb_exit(): Nonsense or nothing following EXIT" );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_syntax );
#endif

   return bwb_zline( l );
   }

/***************************************************************

	FUNCTION:       bwb_exitdo()

	DESCRIPTION:    This function handles the BASIC EXIT
			DO statement.  This is a structured
			programming command compatible with ANSI
			BASIC. It is called from the bwb_exit()
			subroutine.

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_exitdo( struct bwb_line *l )
#else
struct bwb_line *
bwb_exitdo( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_line *next_line;
   int found;
   register int level;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_exitdo(): entered subroutine" );
   bwb_debug( bwb_ebuf );
#endif

   /* Check the integrity of the DO statement */

   found = FALSE;
   level = CURTASK exsc;
   do
      {
      if ( CURTASK excs[ level ].code == EXEC_DO )
	 {
	 next_line = CURTASK excs[ CURTASK level ].wend_line;
	 found = TRUE;
	 }
      else
	 {
	 --level;
	 }
      }
   while ( ( level >= 0 ) && ( found == FALSE ) );

   if ( found != TRUE )
      {

#if PROG_ERRORS
      /* JBV 1/97 (was "bwb_exitfor") */
      sprintf( bwb_ebuf, "in bwb_exitdo(): EXIT DO without DO" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif

      return bwb_zline( l );

      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_exitdo(): level found is <%d>, current <%d>",
      level, CURTASK exsc );
   bwb_debug( bwb_ebuf );
#endif

   /* decrement below the level of the NEXT statement */

   while( CURTASK exsc >= level )
      {
      bwb_decexec();
      }

   /* set the next line in the exec stack */

   next_line->position = 0;
   bwb_setexec( next_line, 0, EXEC_NORM );

   return next_line;

   }

#endif					/* STRUCT_CMDS */

/***************************************************************

	FUNCTION:       bwb_vtov()

	DESCRIPTION:    This function assigns the value of one
			bwBASIC variable (src) to the value of another
			bwBASIC variable (dst).

***************************************************************/

#if ANSI_C
struct bwb_variable *
bwb_vtov( struct bwb_variable *dst,
   struct bwb_variable *src )
#else
struct bwb_variable *
bwb_vtov( dst, src )
   struct bwb_variable *dst;
   struct bwb_variable *src;
#endif
   {

   if ( dst == src )
      {
      return dst;
      }

   if ( src->type != dst->type )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_vtov(): mismatch src <%s> type <%d> dst <%s> type <%d>",
	 src->name, src->type, dst->name, dst->type );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_mismatch );
#endif
      return NULL;
      }

   if ( dst->type == NUMBER )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_vtov(): assigning var <%s> val <%lf> to var <%s>",
	 src->name, var_getnval( src ), dst->name );
      bwb_debug( bwb_ebuf );
#endif

      * var_findnval( dst, dst->array_pos ) = var_getnval( src );
      }
   else
      {
      str_btob( var_getsval( dst ), var_getsval( src ) );
      }

   return dst;
   }

/***************************************************************

	FUNCTION:       bwb_etov()

	DESCRIPTION:    This function assigns the value of a
			bwBASIC expression stack element (src)
			to the value of a bwBASIC variable (dst).

***************************************************************/

#if ANSI_C
struct bwb_variable *
bwb_etov( struct bwb_variable *dst, struct exp_ese *src )
#else
struct bwb_variable *
bwb_etov( dst, src )
   struct bwb_variable *dst;
   struct exp_ese *src;
#endif
   {

   if ( (int) src->type != dst->type )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_etov(): mismatch src <%d> dst <%d>",
         src->type, dst->type );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_mismatch );
#endif
      return NULL;
      }

   if ( dst->type == NUMBER )
      {
      * var_findnval( dst, dst->array_pos ) = exp_getnval( src );
      }
   else
      {
      str_btob( var_getsval( dst ), exp_getsval( src ) );
      }

   return dst;
   }

/***************************************************************

	FUNCTION:       var_pos()

	DESCRIPTION:    This function returns the name of a
			local variable at a specified position
			in the local variable list.

***************************************************************/

#if ANSI_C
struct bwb_variable *
var_pos( struct bwb_variable *firstvar, int p )
#else
struct bwb_variable *
var_pos( firstvar, p )
   struct bwb_variable *firstvar;
   int p;
#endif
   {
   register int c;
   struct bwb_variable *v;

   v = firstvar;
   for ( c = 0; c != p; ++c )
      {
      v = v->next;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_pos(): returning pos <%d> variable <%s>",
      p, v->name );
   bwb_debug( bwb_ebuf );
#endif

   return v;
   }

/***************************************************************

	FUNCTION:       fslt_addcallvar()

	DESCRIPTION:    This function adds a calling variable
			to the FUNCTION-SUB lookup table at
			a specific level.

***************************************************************/

#if ANSI_C
int
fslt_addcallvar( struct bwb_variable *v )
#else
int
fslt_addcallvar( v )
   struct bwb_variable *v;
#endif
   {

   if ( CURTASK excs[ CURTASK exsc ].n_cvs >= MAX_FARGS )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in fslt_addcallvar(): Maximum number of Function Args Exceeded" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_overflow );
#endif
      }

   CURTASK excs[ CURTASK exsc ].calling_variable[ CURTASK excs[ CURTASK exsc ].n_cvs ] = v;
   ++CURTASK excs[ CURTASK exsc ].n_cvs;

   return TRUE;

   }

/***************************************************************

	FUNCTION:       exp_ufnc()

        DESCRIPTION:	This C function interprets a user-defined
			function, returning its value at the current
			level of the expression stack.

***************************************************************/

#if ANSI_C
int
exp_ufnc( char *expression )
#else
int
exp_ufnc( expression )
   char *expression;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   struct bwb_line *call_line;
   struct fslte *f, *c;
   struct bwb_variable *v, *r;
   struct exp_ese *e;
   int save_elevel;
   int position, epos;
#if INTENSIVE_DEBUG
   register int i;
#endif

   position = 0;

   /* get the function name in tbuf */

   exp_getvfname( expression, tbuf );

   /* find the function name in the function-subroutine lookup table */

   for ( f = CURTASK fslt_start.next; f != &CURTASK fslt_end; f = f->next )
      {
      if ( strcmp( f->name, tbuf ) == 0 )
	 {
#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in exp_ufnc(): found user function <%s>",
	    tbuf );
	 bwb_debug( bwb_ebuf );
#endif
	 c = f; 		/* current function-subroutine lookup table element */
	 call_line = f->line;	/* line to call for function */
	 }
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_ufnc(): call to function <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif

   position += strlen( tbuf );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_ufnc(): found line <%s>",
      call_line->buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* save the old position on the EXEC stack */

   bwb_setexec( CURTASK excs[ CURTASK exsc ].line,
      position, CURTASK excs[ CURTASK exsc ].code );
   save_elevel = CURTASK exsc;

   /* increment and set new EXEC stack */

   bwb_incexec();
   call_line->position = 0;
   bwb_setexec( call_line, 0, EXEC_FUNCTION );

   /* attach local variables */

   CURTASK excs[ CURTASK exsc ].local_variable = c->local_variable;

#if INTENSIVE_DEBUG
   i = 0;
   sprintf( bwb_ebuf, "in exp_ufnc(): <%s> attached local variables EXEC level <%d>",
      tbuf, CURTASK exsc );
   bwb_debug( bwb_ebuf );
   for ( v = CURTASK excs[ CURTASK exsc ].local_variable; v != NULL; v = v->next )
      {
      sprintf( bwb_ebuf, "in exp_ufnc():   <%s> level <%d> variable <%d> name <%s>",
	 tbuf, CURTASK exsc, i, v->name );
      bwb_debug( bwb_ebuf );
      ++i;
      }
   getchar();
#endif

   /* read calling variables for this call */

   call_readargs( c, expression, &position );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in exp_ufnc(): current buffer <%s>",
      &( call_line->buffer[ c->startpos ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* determine if single-line function */

   epos = c->startpos;
   adv_ws( call_line->buffer, &epos );
   if ( call_line->buffer[ epos ] == '=' )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_ufnc(): found SINGLE-LINE function" );
      bwb_debug( bwb_ebuf );
#endif

      ++epos;
      call_line->position = epos;
      bwb_setexec( call_line, epos, EXEC_FUNCTION );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_ufnc(): single line: parse <%s>",
	 &( call_line->buffer[ epos ] ) );
      bwb_debug( bwb_ebuf );
#endif

      e = bwb_exp( call_line->buffer, FALSE, &epos );
      v = var_find( tbuf );

#if INTENSIVE_DEBUG
      if ( e->type == STRING )
	 {
	 sprintf( bwb_ebuf, "in exp_ufnc(): expression returns <%d>-byte string",
	    exp_getsval( e )->length );
	 bwb_debug( bwb_ebuf );
	 }
      else
	 {
	 sprintf( bwb_ebuf, "in exp_ufnc(): expression returns number <%lf>",
	    (double) exp_getnval( e ) );
	 bwb_debug( bwb_ebuf );
	 }
#endif

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_ufnc(): single line after parsing, <%s>",
	 &( call_line->buffer[ epos ] ) );
      bwb_debug( bwb_ebuf );
#endif

      bwb_etov( v, e );
      bwb_decexec();
      }

   /* multi-line function must be executed now */

   else
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in exp_ufnc(): found MULTI-LINE function" );
      bwb_debug( bwb_ebuf );
#endif

      /* now execute until function is resolved */

      bwb_execline();
      while( CURTASK exsc > save_elevel )
	 {
	 bwb_execline();
	 }

      /* find the return value */

      for ( r = c->local_variable; r != NULL; r = r->next )
	 {
	 if ( strcmp( r->name, c->name ) == 0 )
	    {
	    v = r;
	    }
	 }

      }

   /* now place value in expression stack */

   CURTASK exps[ CURTASK expsc ].type = (char) v->type;
   CURTASK exps[ CURTASK expsc ].pos_adv = position;

   switch( v->type )
      {
      case STRING:
	 CURTASK exps[ CURTASK expsc ].operation = CONST_STRING;

#if INTENSIVE_DEBUG
	 sprintf( bwb_ebuf, "in exp_ufnc(): ready to assign <%d>-byte STRING",
	    var_getsval( v )->length );
	 bwb_debug( bwb_ebuf );
#endif

	 str_btob( exp_getsval( &( CURTASK exps[ CURTASK expsc ] )),
	    var_getsval( v ) );

#if INTENSIVE_DEBUG
	 str_btoc( tbuf, var_getsval( v ) );
	 sprintf( bwb_ebuf, "in exp_ufnc(): string assigned <%s>", tbuf );
	 bwb_debug( bwb_ebuf );
#endif

	 break;

      default:
	 CURTASK exps[ CURTASK expsc ].operation = NUMBER;
	 CURTASK exps[ CURTASK expsc ].nval = var_getnval( v );
	 break;
      }

   return TRUE;

   }

/***************************************************************

	FUNCTION:       fslt_addlocalvar()

	DESCRIPTION:    This function adds a local variable
			to the FUNCTION-SUB lookup table at
			a specific level.

***************************************************************/

#if ANSI_C
int
fslt_addlocalvar( struct fslte *f, struct bwb_variable *v )
#else
int
fslt_addlocalvar( f, v )
   struct fslte *f;
   struct bwb_variable *v;
#endif
   {
   struct bwb_variable *c, *p;
#if INTENSIVE_DEBUG
   register int i;
#endif

   /* find end of local chain */

   if ( f->local_variable == NULL )
      {
#if INTENSIVE_DEBUG
      i = 0;
#endif
      f->local_variable = v;
      }
   else
      {
#if INTENSIVE_DEBUG
      i = 1;
#endif
      p = f->local_variable;
      for ( c = f->local_variable->next; c != NULL; c = c->next )
         {
         p = c;
#if INTENSIVE_DEBUG
         ++i;
#endif
         }
      p->next = v;
      }

   v->next = NULL;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in fslt_addlocalvar(): added local variable variable <%s> arg number <%d>",
      v->name, i );
   bwb_debug( bwb_ebuf );
   getchar();
#endif

   return TRUE;

   }

/***************************************************************

	FUNCTION:       fslt_init()

	DESCRIPTION:    This function initializes the FUNCTION-SUB
			lookup table.

***************************************************************/

#if ANSI_C
int
fslt_init( int task )
#else
int
fslt_init( task )
   int task;
#endif
   {
   LOCALTASK fslt_start.next = &(LOCALTASK fslt_end);
   return TRUE;
   }

/***************************************************************

	FUNCTION:       is_label()

	DESCRIPTION:    This function determines whether the string
			pointed to by 'buffer' is a label (i.e.,
			ends with colon).

***************************************************************/

#if ANSI_C
extern int
is_label( char *buffer )
#else
int
is_label( buffer )
   char *buffer;
#endif
   {

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in is_label(): check element <%s>", buffer );
   bwb_debug( bwb_ebuf );
#endif

   if ( buffer[ strlen( buffer ) - 1 ] == ':' )
      {
      return TRUE;
      }
   else
      {
      return FALSE;
      }

   }


