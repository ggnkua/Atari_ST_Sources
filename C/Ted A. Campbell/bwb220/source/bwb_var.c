/***************************************************************

        bwb_var.c       Variable-Handling Routines
                        for Bywater BASIC Interpreter

                        Commands:	DIM
                                        COMMON
                                        ERASE
                                        SWAP
					CLEAR

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
#include <math.h>

#include "bwbasic.h"
#include "bwb_mes.h"

int dim_base = 0;                        	/* set by OPTION BASE */
static int dimmed = FALSE;                      /* has DIM been called? */
static int first, last;				/* first, last for DEFxxx commands */

/* Prototypes for functions visible to this file only */

#if ANSI_C
static int dim_check( struct bwb_variable *v, int *pp );
static int var_defx( struct bwb_line *l, int type );
static int var_letseq( char *buffer, int *position, int *start, int *end );
static size_t dim_unit( struct bwb_variable *v, int *pp );
#else
static int dim_check();
static int var_defx();
static int var_letseq();
static size_t dim_unit();
#endif

/***************************************************************

        FUNCTION:       var_init()

        DESCRIPTION:	This function initializes the internal
			linked list of variables.

***************************************************************/

#if ANSI_C
int
var_init( int task )
#else
int
var_init( task )
   int task;
#endif
   {
   LOCALTASK var_start.next = &(LOCALTASK var_end);
   strcpy( LOCALTASK var_start.name, "<START>" );
   strcpy( LOCALTASK var_end.name, "<END>" );
   return TRUE;
   }

#if COMMON_CMDS

/***************************************************************

        FUNCTION:       bwb_common()

        DESCRIPTION:	This C function implements the BASIC
        		COMMON command.

	SYNTAX:		COMMON variable [, variable...]

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_common( struct bwb_line *l )
#else
struct bwb_line *
bwb_common( l )
   struct bwb_line *l;
#endif
   {
   register int loop;
   struct bwb_variable *v;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* loop while arguments are available */

   loop = TRUE;
   while ( loop == TRUE )
      {

      /* get variable name and find variable */

      bwb_getvarname( l->buffer, tbuf, &( l->position ) );

      if ( ( v = var_find( tbuf ) ) == NULL )
         {
         bwb_error( err_syntax );
         return bwb_zline( l );
         }

      v->common = TRUE;				/* set common flag to true */

      /* check for comma */

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] != ',' )
         {
         return bwb_zline( l );				/* no comma; leave */
         }
      ++( l->position );
      adv_ws( l->buffer, &( l->position ) );

      }

   return bwb_zline( l );

   }

/***********************************************************

        FUNCTION:	bwb_erase()

	DESCRIPTION:    This C function implements the BASIC
			ERASE command.

	SYNTAX:		ERASE variable[, variable]...

***********************************************************/

#if ANSI_C
struct bwb_line *
bwb_erase( struct bwb_line *l )
#else
struct bwb_line *
bwb_erase( l )
   struct bwb_line *l;
#endif
   {
   register int loop;
   struct bwb_variable *v;
   struct bwb_variable *p;		/* previous variable in linked list */
   char tbuf[ MAXSTRINGSIZE + 1 ];
   bstring *sp; /* JBV */
   register int n; /* JBV */

   /* loop while arguments are available */

   loop = TRUE;
   while ( loop == TRUE )
      {

      /* get variable name and find variable */

      bwb_getvarname( l->buffer, tbuf, &( l->position ) );

      if ( ( v = var_find( tbuf ) ) == NULL )
         {
         bwb_error( err_syntax );
         return bwb_zline( l );
         }

      /* be sure the variable is dimensioned */

      if (( v->dimensions < 1 ) || ( v->array_sizes[ 0 ] < 1 ))
	 {
	 bwb_error( err_dimnotarray );
	 return bwb_zline( l );
         }

      /* find previous variable in chain */

      for ( p = &CURTASK var_start; p->next != v; p = p->next )
         {
         ;
         }

      /* reassign linkage */

      p->next = v->next;

      /* deallocate memory */

      /* Revised to FREE pass-thru calls by JBV */
      FREE( v->array_sizes, "bwb_erase" );
      v->array_sizes = NULL; /* JBV */
      FREE( v->array_pos , "bwb_erase");
      v->array_pos = NULL; /* JBV */
      if ( v->type == NUMBER )
	 {
         /* Revised to FREE pass-thru call by JBV */
	 FREE( v->memnum, "bwb_erase" );
	 v->memnum = NULL; /* JBV */
	 }
      else
	 {
		/* Following section added by JBV */
		sp = v->memstr;
		for ( n = 0; n < (int) v->array_units; ++n )
		{
			if ( sp[ n ].sbuffer != NULL )
			{
                                /* Revised to FREE pass-thru call by JBV */
				FREE( sp[ n ].sbuffer, "bwb_erase" );
				sp[ n ].sbuffer = NULL;
			}
			sp[ n ].rab = FALSE;
			sp[ n ].length = 0;
		}
         /* Revised to FREE pass-thru call by JBV */
	 FREE( v->memstr, "bwb_erase" );
	 v->memstr = NULL; /* JBV */
	 }
      /* Revised to FREE pass-thru call by JBV */
      FREE( v, "bwb_erase" );
      v = NULL; /* JBV */

      /* check for comma */

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] != ',' )
         {
         return bwb_zline( l );				/* no comma; leave */
         }
      ++( l->position );
      adv_ws( l->buffer, &( l->position ) );

      }

   return bwb_zline( l );

   }

/***********************************************************

        FUNCTION:	bwb_swap()

	DESCRIPTION:    This C function implements the BASIC
			SWAP command.

	SYNTAX:		SWAP variable, variable

***********************************************************/

#if ANSI_C
struct bwb_line *
bwb_swap( struct bwb_line *l )
#else
struct bwb_line *
bwb_swap( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_variable tmp;                     /* temp holder */
   struct bwb_variable *lhs, *rhs;		/* left and right- hand side of swap statement */
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_swap(): buffer is <%s>",
      &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   /* get left variable name and find variable */

   bwb_getvarname( l->buffer, tbuf, &( l->position ) );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_swap(): tbuf is <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif

   if ( ( lhs = var_find( tbuf ) ) == NULL )
      {
      bwb_error( err_syntax );
      return bwb_zline( l );
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_swap(): lhs variable <%s> found",
      lhs->name );
   bwb_debug( bwb_ebuf );
#endif

   /* check for comma */

   adv_ws( l->buffer, &( l->position ) );
   if ( l->buffer[ l->position ] != ',' )
      {
      bwb_error( err_syntax );
      return bwb_zline( l );
      }
   ++( l->position );
   adv_ws( l->buffer, &( l->position ) );

   /* get right variable name */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_swap(): buffer is now <%s>",
      &( l->buffer[ l->position ] ) );
   bwb_debug( bwb_ebuf );
#endif

   bwb_getvarname( l->buffer, tbuf, &( l->position ) );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_swap(): tbuf is <%s>", tbuf );
   bwb_debug( bwb_ebuf );
#endif

   if ( ( rhs = var_find( tbuf ) ) == NULL )
      {
      bwb_error( err_syntax );
      return bwb_zline( l );
      }

   /* check to be sure that both variables are of the same type */

   if ( rhs->type != lhs->type )
      {
      bwb_error( err_mismatch );
      return bwb_zline( l );
      }

   /* copy lhs to temp, rhs to lhs, then temp to rhs */

   if ( lhs->type == NUMBER )
      {
      tmp.memnum = lhs->memnum;
      }
   else
      {
      tmp.memstr = lhs->memstr;
      }
   tmp.array_sizes = lhs->array_sizes;
   tmp.array_units = lhs->array_units;
   tmp.array_pos = lhs->array_pos;
   tmp.dimensions = lhs->dimensions;

   if ( lhs->type == NUMBER )
      {
      lhs->memnum = rhs->memnum;
      }
   else
      {
      lhs->memstr = rhs->memstr;
      }
   lhs->array_sizes = rhs->array_sizes;
   lhs->array_units = rhs->array_units;
   lhs->array_pos = rhs->array_pos;
   lhs->dimensions = rhs->dimensions;

   if ( lhs->type = NUMBER )
      {
      rhs->memnum = tmp.memnum;
      }
   else
      {
      rhs->memstr = tmp.memstr;
      }
   rhs->array_sizes = tmp.array_sizes;
   rhs->array_units = tmp.array_units;
   rhs->array_pos = tmp.array_pos;
   rhs->dimensions = tmp.dimensions;

   /* return */

   return bwb_zline( l );

   }

#endif				/* COMMON_CMDS */

/***********************************************************

        FUNCTION:	bwb_clear()

	DESCRIPTION:    This C function implements the BASIC
			CLEAR command.

	SYNTAX:		CLEAR

***********************************************************/

#if ANSI_C
struct bwb_line *
bwb_clear( struct bwb_line *l )
#else
struct bwb_line *
bwb_clear( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_variable *v;
   register int n;
   bstring *sp;
   bnumber *np;

   for ( v = CURTASK var_start.next; v != &CURTASK var_end; v = v->next )
      {
      if ( v->preset != TRUE )
         {
         switch( v->type )
            {
            case NUMBER:
	       np = v->memnum;
	       for ( n = 0; n < (int) v->array_units; ++n )
		  {
		  np[ n ] = (bnumber) 0.0;
		  }
	       break;
	    case STRING:
	       sp = v->memstr;
               for ( n = 0; n < (int) v->array_units; ++n )
                  {
		  if ( sp[ n ].sbuffer != NULL )
		     {
                     /* Revised to FREE pass-thru call by JBV */
		     FREE( sp[ n ].sbuffer, "bwb_clear" );
		     sp[ n ].sbuffer = NULL;
                     }
                  sp[ n ].rab = FALSE;
                  sp[ n ].length = 0;
                  }
               break;
            }
         }
      }

   return bwb_zline( l );

   }

/***********************************************************

	FUNCTION:       var_delcvars()

	DESCRIPTION:    This function deletes all variables
			in memory except those previously marked
			as common.

***********************************************************/

#if ANSI_C
int
var_delcvars( void )
#else
int
var_delcvars()
#endif
   {
   struct bwb_variable *v;
   struct bwb_variable *p;		/* previous variable */
   bstring *sp; /* JBV */
   register int n; /* JBV */

   p = &CURTASK var_start;
   for ( v = CURTASK var_start.next; v != &CURTASK var_end; v = v->next )
      {

      if ( v->common != TRUE )
         {

         /* if the variable is dimensioned, release allocated memory */

         if ( v->dimensions > 0 )
            {

            /* deallocate memory */

            /* Revised to FREE pass-thru calls by JBV */
            FREE( v->array_sizes, "var_delcvars" );
            v->array_sizes = NULL; /* JBV */
            FREE( v->array_pos, "var_delcvars" );
            v->array_pos = NULL; /* JBV */
	    if ( v->type == NUMBER )
	       {
               /* Revised to FREE pass-thru call by JBV */
	       FREE( v->memnum, "var_delcvars" );
	       v->memnum = NULL; /* JBV */
	       }
	    else
	       {
		/* Following section added by JBV */
		sp = v->memstr;
		for ( n = 0; n < (int) v->array_units; ++n )
		{
			if ( sp[ n ].sbuffer != NULL )
			{
                                /* Revised to FREE pass-thru call by JBV */
				FREE( sp[ n ].sbuffer, "var_delcvars" );
				sp[ n ].sbuffer = NULL;
			}
			sp[ n ].rab = FALSE;
			sp[ n ].length = 0;
		}
               /* Revised to FREE pass-thru call by JBV */
	       FREE( v->memstr, "var_delcvars" );
	       v->memstr = NULL; /* JBV */
	       }
            }

         /* reassign linkage */

         p->next = v->next;

         /* deallocate the variable itself */

         /* Revised to FREE pass-thru call by JBV */
         FREE( v, "var_delcvars" );
         v = NULL; /* JBV */

         }

      /* else reset previous variable */

      else
         {
         p = v;
         }

      }

   return TRUE;

   }

#if MS_CMDS

/***********************************************************

        FUNCTION:	bwb_ddbl()

	DESCRIPTION:    This function implements the BASIC
			DEFDBL command.

	SYNTAX:		DEFDBL letter[-letter](, letter[-letter])...

***********************************************************/

#if ANSI_C
struct bwb_line *
bwb_ddbl( struct bwb_line *l )
#else
struct bwb_line *
bwb_ddbl( l )
   struct bwb_line *l;
#endif
   {

   /* call generalized DEF handler with DOUBLE set */

   var_defx( l, NUMBER );

   return bwb_zline( l );

   }

/***********************************************************

        FUNCTION:	bwb_dint()

	DESCRIPTION:    This function implements the BASIC
			DEFINT command.

	SYNTAX:		DEFINT letter[-letter](, letter[-letter])...

***********************************************************/

#if ANSI_C
struct bwb_line *
bwb_dint( struct bwb_line *l )
#else
struct bwb_line *
bwb_dint( l )
   struct bwb_line *l;
#endif
   {

   /* call generalized DEF handler with INTEGER set */

   var_defx( l, NUMBER );

   return bwb_zline( l );

   }

/***********************************************************

        FUNCTION:	bwb_dsng()

	DESCRIPTION:    This function implements the BASIC
			DEFSNG command.

	SYNTAX:		DEFSNG letter[-letter](, letter[-letter])...

***********************************************************/

#if ANSI_C
struct bwb_line *
bwb_dsng( struct bwb_line *l )
#else
struct bwb_line *
bwb_dsng( l )
   struct bwb_line *l;
#endif
   {

   /* call generalized DEF handler with SINGLE set */

   var_defx( l, NUMBER );

   return bwb_zline( l );

   }

/***********************************************************

        FUNCTION:	bwb_dstr()

	DESCRIPTION:    This function implements the BASIC
			DEFSTR command.

	SYNTAX:		DEFSTR letter[-letter](, letter[-letter])...

***********************************************************/

#if ANSI_C
struct bwb_line *
bwb_dstr( struct bwb_line *l )
#else
struct bwb_line *
bwb_dstr( l )
   struct bwb_line *l;
#endif
   {

   /* call generalized DEF handler with STRING set */

   var_defx( l, STRING );

   return bwb_zline( l );

   }

/***********************************************************

        FUNCTION:	bwb_mid()

	DESCRIPTION:    This function implements the BASIC
			MID$ command.

			Same as MID$ function, except it will set
			the desired substring and not return its
			value.  Added by JBV 10/95

	SYNTAX:		MID$( string-variable$, start-position-in-string
			[, number-of-spaces ] ) = expression

***********************************************************/

#if ANSI_C
struct bwb_line *
bwb_mid( struct bwb_line *l )
#else
struct bwb_line *
bwb_mid( l )
   struct bwb_line *l;
#endif
   {
   char tbuf[ MAXSTRINGSIZE + 1 ];
   char source_string[ MAXSTRINGSIZE + 1 ];
   struct bwb_variable *v;
   static int pos;
   bstring *d;
   int *pp;
   int n_params;
   int p;
   register int n;
   int startpos, numchars, endpos;
   int source_counter, source_length, target_length;
   int target_terminate;
   struct exp_ese *e;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_mid(): MID$ command" );
   bwb_debug( bwb_ebuf );
#endif

   /* Get past left parenthesis */
   adv_ws( l->buffer, &( l->position ) );
   ++( l->position );
   adv_ws( l->buffer, &( l->position ) );

   /* Get variable name and find variable */
   bwb_getvarname( l->buffer, tbuf, &( l->position ) );
   v = var_find( tbuf );
   if ( v == NULL )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_mid(): failed to find variable" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      }

   if ( v->type != STRING )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_mid(): assignment must be to string variable" );
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
      sprintf( bwb_ebuf, "in bwb_mid(): variable <%s> has 1 dimension",
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
      sprintf( bwb_ebuf, "in bwb_mid(): variable <%s> has > 1 dimensions",
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

   /* Get past next comma and white space */
   adv_ws( l->buffer, &( l->position ) );
   ++( l->position );
   adv_ws( l->buffer, &( l->position ) );

   /* Get starting position (expression) */
   adv_element( l->buffer, &( l->position ), tbuf );
   pos = 0;
   e = bwb_exp( tbuf, FALSE, &pos );
   startpos = (int) exp_getnval( e );

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_mid(): startpos <%d> buffer <%lX>",
      startpos, (long) d->sbuffer );
   bwb_debug( bwb_ebuf );
#endif

   /* Get past next comma and white space (if they exist) */
   adv_ws( l->buffer, &( l->position ) );
   if (l->buffer[l->position] == ',')
      {
      target_terminate = 0;
      ++( l->position );
      adv_ws( l->buffer, &( l->position ) );
      adv_element( l->buffer, &( l->position ), tbuf );
      pos = 0;
      e = bwb_exp( tbuf, FALSE, &pos );
      numchars = (int) exp_getnval( e );
      if ( numchars == 0 )
         {
#if PROG_ERRORS
         sprintf( bwb_ebuf, "in bwb_mid(): destination string no. of chars out of range" );
         bwb_error( bwb_ebuf );
#else
         bwb_error( "Argument out of range" );
#endif
         }
      }
   else
      {
      target_terminate = 1;
      numchars = 0;
      }

   if ( numchars < 0 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_mid(): negative string length" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( "Negative string length" );
#endif
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_mid(): numchars <%d> target_terminate <%d>", numchars, target_terminate );
   bwb_debug( bwb_ebuf );
#endif

   /* Get past equal sign */
   adv_ws( l->buffer, &( l->position ) );
   if (l->buffer[l->position] == ')')
      {
      ++(l->position);
      adv_ws( l->buffer, &( l->position ) );
      }
   ++(l->position);
   adv_ws( l->buffer, &( l->position ) );

   /* Evaluate string expression */
   e = bwb_exp( l->buffer, FALSE, &( l->position ) );
   if ( e->type != STRING )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_mid(): assignment must be from string expression" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      }

   /* Prepare to MID the string */
   str_btoc( source_string, exp_getsval( e ) );
   str_btoc( tbuf, d );
   target_length = strlen( tbuf );
   if ( startpos > ( target_length + 1 ) )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_mid(): non-contiguous string created" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( "Non-contiguous string created" );
#endif
      }

   if ( startpos < 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in bwb_mid(): destination string start position out of range" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( "Argument out of range" );
#endif
      }

   source_length = strlen( source_string );
   if ( numchars == 0 ) numchars = source_length;
   endpos = startpos + numchars - 1;

   /* MID the string */
   if ( endpos < startpos ) tbuf[ startpos - 1 ] = '\0';
   else
      {
      source_counter = 0;
      for ( n = startpos - 1; n < endpos; ++n )
         {
         if ( source_counter < source_length )
            tbuf[ n ] = source_string[ source_counter ];
         else
            tbuf[ n ] = ' ';
         ++source_counter;
         }
      /* Terminate if indicated or characters were added */
      if ( ( endpos > target_length ) || ( target_terminate == 1 ) )
         tbuf[ endpos ] = '\0';
      }
   str_ctob( d, tbuf );

#if MULTISEG_LINES
   adv_eos( l->buffer, &( l->position ));
#endif

   return bwb_zline( l );

   }

/***********************************************************

        Function:	var_defx()

	DESCRIPTION:    This function is a generalized DEFxxx handler.

***********************************************************/

#if ANSI_C
static int
var_defx( struct bwb_line *l, int type )
#else
static int
var_defx( l, type )
   struct bwb_line *l;
   int type;
#endif
   {
   int loop;
   register int c;
   static char vname[ 2 ];
   struct bwb_variable *v;

   /* loop while there are variable names to process */

   loop = TRUE;
   while ( loop == TRUE )
      {

      /* check for end of line or line segment */

      adv_ws( l->buffer, &( l->position ) );
      switch( l->buffer[ l->position ] )
         {
         case '\n':
         case '\r':
         case '\0':
         case ':':
            return FALSE;
         }

      /* find a sequence of letters for variables */

      if ( var_letseq( l->buffer, &( l->position ), &first, &last ) == FALSE )
         {
         return FALSE;
         }

      /* loop through the list getting variables */

      for ( c = first; c <= last; ++c )
         {
         vname[ 0 ] = (char) c;
         vname[ 1 ] = '\0';

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in var_defx(): calling var_find() for <%s>",
            vname );
         bwb_debug( bwb_ebuf );
#endif

         v = var_find( vname );

         /* but var_find() assigns on the basis of name endings
            (so all in this case should be SINGLEs), so we must
            force the type of the variable */

         var_make( v, type );

         }

      }

   return TRUE;

   }

#endif				/* MS_CMDS */

/***********************************************************

        Function:	var_letseq()

	DESCRIPTION:    This function finds a sequence of letters
			for a DEFxxx command.

***********************************************************/

#if ANSI_C
static int
var_letseq( char *buffer, int *position, int *start, int *end )
#else
static int
var_letseq( buffer, position, start, end )
   char *buffer;
   int *position;
   int *start;
   int *end;
#endif
   {

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_letseq(): buffer <%s>", &( buffer[ *position ] ));
   bwb_debug( bwb_ebuf );
#endif

   /* advance beyond whitespace */

   adv_ws( buffer, position );

   /* check for end of line */

   switch( buffer[ *position ] )
      {
      case '\0':
      case '\n':
      case '\r':
      case ':':
         return TRUE;
      }

   /* character at this position must be a letter */

   if ( isalpha( buffer[ *position ] ) == 0 )
      {
      bwb_error( err_defchar );
      return FALSE;
      }

   *end = *start = buffer[ *position ];

   /* advance beyond character and whitespace */

   ++( *position );
   adv_ws( buffer, position );

   /* check for hyphen, indicating sequence of more than one letter */

   if ( buffer[ *position ] == '-' )
      {

      ++( *position );

      /* advance beyond whitespace */

      adv_ws( buffer, position );

      /* character at this position must be a letter */

      if ( isalpha( buffer[ *position ] ) == 0 )
         {
         *end = *start;
         }
      else
         {
         *end = buffer[ *position ];
         ++( *position );
         }

      }

   /* advance beyond comma if present */

   if ( buffer[ *position ] == ',' )
      {
      ++( *position );
      }

   return TRUE;
   }

/***********************************************************

	FUNCTION:       bwb_const()

	DESCRIPTION:    This function takes the string in lb
			(the large buffer), finds a string constant
			(beginning and ending with quotation marks),
			and returns it in sb (the small buffer),
			appropriately incrementing the integer
			pointed to by n. The string in lb should NOT
			include the initial quotation mark.

***********************************************************/

#if ANSI_C
int
bwb_const( char *lb, char *sb, int *n )
#else
int
bwb_const( lb, sb, n )
   char *lb;
   char *sb;
   int *n;
#endif
   {
   register int s;

   ++*n;                        /* advance past quotation mark */
   s = 0;

   while ( TRUE )
      {
      switch ( lb[ *n ] )
         {
         case '\"':
            sb[ s ] = 0;
            ++*n;               /* advance past ending quotation mark */
            return TRUE;
         case '\n':
         case '\r':
         case 0:
            sb[ s ] = 0;
            return TRUE;
         default:
            sb[ s ] = lb[ *n ];
            break;
         }

      ++*n;                     /* advance to next character in large buffer */
      ++s;                      /* advance to next position in small buffer */
      sb[ s ] = 0;              /* terminate with 0 */
      }

   }

/***********************************************************

	FUNCTION:       bwb_getvarname()

	DESCRIPTION:    This function takes the string in lb
			(the large buffer), finds a variable name,
			and returns it in sb (the small buffer),
			appropriately incrementing the integer
			pointed to by n.

***********************************************************/

#if ANSI_C
int
bwb_getvarname( char *lb, char *sb, int *n )
#else
int
bwb_getvarname( lb, sb, n )
   char *lb;
   char *sb;
   int *n;
#endif
   {
   register int s;

   s = 0;

   /* advance beyond whitespace */

   adv_ws( lb, n );

   while ( TRUE )
      {
      switch ( lb[ *n ] )
         {
         case ' ':              /* whitespace */
         case '\t':
         case '\n':             /* end of string */
         case '\r':
         case 0:
         case ':':              /* end of expression */
         case ',':
         case ';':
         case '(':              /* beginning of parameter list for dimensioned array */
         case '+':              /* add variables */
         case '=':              /* Don't forget this one (JBV) */
            sb[ s ] = 0;
            return TRUE;
         default:
            sb[ s ] = lb[ *n ];
            break;
         }

      ++*n;                     /* advance to next character in large buffer */
      ++s;                      /* advance to next position in small buffer */
      sb[ s ] = 0;              /* terminate with 0 */

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_getvarname(): found <%s>", sb );
      bwb_debug( bwb_ebuf );
#endif
      }

   }

/***************************************************************

        FUNCTION:       var_find()

	DESCRIPTION:    This C function attempts to find a variable
			name matching the argument in buffer. If
			it fails to find a matching name, it
			sets up a new variable with that name.

***************************************************************/

#if ANSI_C
struct bwb_variable *
var_find( char *buffer )
#else
struct bwb_variable *
var_find( buffer )
   char *buffer;
#endif
   {
   struct bwb_variable *v;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_find(): received <%s>", buffer );
   bwb_debug( bwb_ebuf );
#endif

   /* check for a local variable at this EXEC level */

   v = var_islocal( buffer );
   if ( v != NULL )
      {
      return v;
      }

   /* now run through the global variable list and try to find a match */

   for ( v = CURTASK var_start.next; v != &CURTASK var_end; v = v->next )
      {

      if ( strcmp( v->name, buffer ) == 0 )
         {
         switch( v->type )
            {
            case STRING:
            case NUMBER:
               break;
            default:
#if PROG_ERRORS
               sprintf( bwb_ebuf, "in var_find(): inappropriate precision for variable <%s>",
                  v->name );
               bwb_error( bwb_ebuf );
#endif
               break;
            }
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in var_find(): found global variable <%s>", v->name );
         bwb_debug( bwb_ebuf );
#endif

         return v;
         }

      }

   /* presume this is a new variable, so initialize it... */
   /* check for NULL variable name */

   if ( strlen( buffer ) == 0 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in var_find(): NULL variable name received\n" );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return NULL;
      }

   /* initialize new variable */

   v = var_new( buffer );

   /* set place at beginning of variable chain */

   v->next = CURTASK var_start.next;
   CURTASK var_start.next = v;

   /* normally not a preset */

   v->preset = FALSE;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_find(): initialized new variable <%s> type <%c>, dim <%d>",
      v->name, v->type, v->dimensions );
   bwb_debug( bwb_ebuf );
   getchar();
#endif

   return v;

   }

/***************************************************************

        FUNCTION:       var_new()

	DESCRIPTION:    This function assigns memory for a new variable.

***************************************************************/

#if ANSI_C
struct bwb_variable *
var_new( char *name )
#else
struct bwb_variable *
var_new( name )
   char *name;
#endif
   {
   struct bwb_variable *v;

   /* get memory for new variable */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( v = (struct bwb_variable *) CALLOC( 1, sizeof( struct bwb_variable ), "var_new" ))
      == NULL )
      {
      bwb_error( err_getmem );
      return NULL;
      }

   /* copy the name into the appropriate structure */

   strcpy( v->name, name );

   /* set memory in the new variable */

   var_make( v, (int) v->name[ strlen( v->name ) - 1 ] );

   /* and return */

   return v;

   }

/***************************************************************

        FUNCTION:       bwb_isvar()

	DESCRIPTION:    This function determines if the string
			in 'buffer' is the name of a previously-
			existing variable.

***************************************************************/

#if ANSI_C
int
bwb_isvar( char *buffer )
#else
int
bwb_isvar( buffer )
   char *buffer;
#endif
   {
   struct bwb_variable *v;

   /* run through the variable list and try to find a match */

   for ( v = CURTASK var_start.next; v != &CURTASK var_end; v = v->next )
      {

      if ( strcmp( v->name, buffer ) == 0 )
         {
         return TRUE;
         }

      }

   /* search failed */

   return FALSE;

   }

/***************************************************************

	FUNCTION:       var_getnval()

	DESCRIPTION:    This function returns the current value of
			the variable argument as a number.

***************************************************************/

#if ANSI_C
bnumber
var_getnval( struct bwb_variable *nvar )
#else
bnumber
var_getnval( nvar )
   struct bwb_variable *nvar;
#endif
   {

   switch( nvar->type )
      {
      case NUMBER:
         return *( var_findnval( nvar, nvar->array_pos ) );
      }

#if PROG_ERRORS
   sprintf( bwb_ebuf, "in var_getnval(): type is <%d>=<%c>.",
      nvar->type, nvar->type );
   bwb_error( bwb_ebuf );
#else
   bwb_error( err_mismatch );
#endif


   return (bnumber) 0.0;

   }

/***************************************************************

	FUNCTION:       var_getsval()

	DESCRIPTION:    This function returns the current value of
			the variable argument as a pointer to a BASIC
			string structure.

***************************************************************/

#if ANSI_C
bstring *
var_getsval( struct bwb_variable *nvar )
#else
bstring *
var_getsval( nvar )
   struct bwb_variable *nvar;
#endif
   {
   static bstring b;

   b.rab = FALSE;

   switch( nvar->type )
      {
      case STRING:
	 return var_findsval( nvar, nvar->array_pos );
      case NUMBER:
	 sprintf( bwb_ebuf, "%*f ", prn_precision( nvar ),
	    *( var_findnval( nvar, nvar->array_pos ) ) );
	 str_ctob( &b, bwb_ebuf );
	 return &b;
      default:
#if PROG_ERRORS
	 sprintf( bwb_ebuf, "in var_getsval(): type is <%d>=<%c>.",
	    nvar->type, nvar->type );
	 bwb_error( bwb_ebuf );
#else
	 bwb_error( err_mismatch );
#endif
	 return NULL;
      }

   }

/***************************************************************

	FUNCTION:	bwb_dim()

	DESCRIPTION:	This function implements the BASIC DIM
			statement, allocating memory for a
			dimensioned array of variables.

	SYNTAX:		DIM variable(elements...)[variable(elements...)]...

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_dim( struct bwb_line *l )
#else
struct bwb_line *
bwb_dim( l )
   struct bwb_line *l;
#endif
   {
   register int n;
   static int n_params;                         /* number of parameters */
   static int *pp;                              /* pointer to parameter values */
   struct bwb_variable *newvar;
   bnumber *np;
   int loop;
   int old_name, old_dimensions;
   char tbuf[ MAXSTRINGSIZE + 1 ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_dim(): entered function." );
   bwb_debug( bwb_ebuf );
#endif

   loop = TRUE;
   while ( loop == TRUE )
      {

      old_name = FALSE;

      /* Get variable name */

      adv_ws( l->buffer, &( l->position ) );
      bwb_getvarname( l->buffer, tbuf, &( l->position ) );

      /* check for previously used variable name */

      if ( bwb_isvar( tbuf ) == TRUE )
         {
#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_dim(): variable name is already used.",
            l->number );
         bwb_debug( bwb_ebuf );
#endif
         old_name = TRUE;
         }

      /* get the new variable */

      newvar = var_find( tbuf );

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in bwb_dim(): new variable name is <%s>.",
         newvar->name );
      bwb_debug( bwb_ebuf );
#endif

      /* note that DIM has been called */

      dimmed = TRUE;

      /* read parameters */

      old_dimensions = newvar->dimensions;
      dim_getparams( l->buffer, &( l->position ), &n_params, &pp );
      newvar->dimensions = n_params;

      /* Check parameters for an old variable name */

      if ( old_name == TRUE )
         {

         /* check to be sure the number of dimensions is the same */

         if ( newvar->dimensions != old_dimensions )
            {
#if PROG_ERRORS
            sprintf( bwb_ebuf, "in bwb_dim(): variable <%s> cannot be re-dimensioned",
               newvar->name );
            bwb_error( bwb_ebuf );
#else
            bwb_error( err_redim );
#endif
            }

         /* check to be sure sizes for the old variable are the same */

         for ( n = 0; n < newvar->dimensions; ++n )
            {
#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_dim(): old var <%s> parameter <%d> size <%d>.",
               newvar->name, n, pp[ n ] );
            bwb_debug( bwb_ebuf );
#endif
            if ( ( pp[ n ] + ( 1 - dim_base )) != newvar->array_sizes[ n ] )
               {
#if PROG_ERRORS
               sprintf( bwb_ebuf, "in bwb_dim(): variable <%s> parameter <%d> cannot be resized",
                  newvar->name, n );
               bwb_error( bwb_ebuf );
#else
               bwb_error( err_redim );
#endif
               }
            }

         }         /* end of conditional for old variable */


      /* a new variable */

      else
         {

         /* assign memory for parameters */

         /* Revised to CALLOC pass-thru call by JBV */
         if ( ( newvar->array_sizes = (int *) CALLOC( n_params, sizeof( int ), "bwb_dim"  )) == NULL )
            {
#if PROG_ERRORS
            sprintf( bwb_ebuf, "in line %d: Failed to find memory for array_sizes for <%s>",
               l->number, newvar->name );
            bwb_error( bwb_ebuf );
#else
            bwb_error( err_getmem );
#endif
            return bwb_zline( l );
            }

         for ( n = 0; n < newvar->dimensions; ++n )
            {
            newvar->array_sizes[ n ] = pp[ n ] + ( 1 - dim_base );
#if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in bwb_dim(): array_sizes dim <%d> value <%d>",
               n, newvar->array_sizes[ n ] );
            bwb_debug( bwb_ebuf );
#endif
            }

         /* assign memory for current position */

         /* Revised to CALLOC pass-thru call by JBV */
         if ( ( newvar->array_pos = (int *) CALLOC( n_params, sizeof( int ), "bwb_dim" )) == NULL )
            {
#if PROG_ERRORS
            sprintf( bwb_ebuf, "in line %d: Failed to find memory for array_pos for <%s>",
               l->number, newvar->name );
            bwb_error( bwb_ebuf );
#else
            bwb_error( err_getmem );
#endif
            return bwb_zline( l );
            }

         for ( n = 0; n < newvar->dimensions; ++n )
            {
            newvar->array_pos[ n ] = dim_base;
            }

         /* calculate the array size */

	 newvar->array_units = (size_t) MAXINTSIZE;	/* avoid error in dim_unit() */
	 newvar->array_units = dim_unit( newvar, pp ) + 1;

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in bwb_dim(): array memory requires <%ld> units",
            (long) newvar->array_units );
         bwb_debug( bwb_ebuf );
#endif

         /* assign array memory */

         switch( newvar->type )
            {
            case STRING:
#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_dim(): 1 STRING requires <%ld> bytes",
                  (long) sizeof( bstring ));
               bwb_debug( bwb_ebuf );
               sprintf( bwb_ebuf, "in bwb_dim(): STRING array memory requires <%ld> bytes",
        	  (long) ( newvar->array_units + 1 ) * sizeof( bstring ));
               bwb_debug( bwb_ebuf );
#endif
               /*------------------------------------------------------*/
               /* memnum, not memstr, was used here -- incorrect (JBV) */
               /* Revised to CALLOC pass-thru call by JBV              */
               /*------------------------------------------------------*/
               if ( ( newvar->memstr = (bstring *)
                  CALLOC( newvar->array_units, sizeof( bstring), "bwb_dim" )) == NULL )
               {
#if PROG_ERRORS
                  sprintf( bwb_ebuf, "in line %d: Failed to find memory for array <%s>",
                     l->number, newvar->name );
                  bwb_error( bwb_ebuf );
#else
                  bwb_error( err_getmem );
#endif
                  return bwb_zline( l );
                  }
               break;
            case NUMBER:
#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_dim(): 1 DOUBLE requires <%ld> bytes",
                  (long) sizeof( double ));
               bwb_debug( bwb_ebuf );
               sprintf( bwb_ebuf, "in bwb_dim(): DOUBLE array memory requires <%ld> bytes",
        	  (long) ( newvar->array_units + 1 ) * sizeof( double ));
               bwb_debug( bwb_ebuf );
#endif

               /* Revised to CALLOC pass-thru call by JBV */
               if ( ( np = (bnumber *)
                  CALLOC( newvar->array_units, sizeof( bnumber ), "bwb_dim" )) == NULL )
                  {
#if PROG_ERRORS
                  sprintf( bwb_ebuf, "in line %d: Failed to find memory for array <%s>",
                  l->number, newvar->name );
                  bwb_error( bwb_ebuf );
#else
                  bwb_error( err_getmem );
#endif
                  return bwb_zline( l );
                  }
	       newvar->memnum = np;
	       break;
	    default:
#if PROG_ERRORS
               sprintf( bwb_ebuf, "in line %d: New variable has unrecognized type.",
                  l->number );
               bwb_error( bwb_ebuf );
#else
               bwb_error( err_syntax );
#endif
               return bwb_zline( l );
            }

         }			/* end of conditional for new variable */

      /* now check for end of string */

      if ( l->buffer[ l->position ] == ')' )
         {
         ++( l->position );
         }
      adv_ws( l->buffer, &( l->position ));
      switch( l->buffer[ l->position ] )
         {
         case '\n':			/* end of line */
         case '\r':
         case ':':			/* end of line segment */
         case '\0':			/* end of string */
            loop = FALSE;
            break;
         case ',':
            ++( l->position );
            adv_ws( l->buffer, &( l->position ) );
            loop = TRUE;
            break;
         default:
#if PROG_ERRORS
            sprintf( bwb_ebuf, "in bwb_dim(): unexpected end of string, buf <%s>",
               &( l->buffer[ l->position ] ) );
            bwb_error( bwb_ebuf );
#else
            bwb_error( err_syntax );
#endif
            loop = FALSE;
            break;
         }

      }				/* end of loop through variables */

   /* return */

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       dim_unit()

        DESCRIPTION:    This function calculates the unit
        		position for an array.

***************************************************************/

#if ANSI_C
static size_t
dim_unit( struct bwb_variable *v, int *pp )
#else
static size_t
dim_unit( v, pp )
   struct bwb_variable *v;
   int *pp;
#endif
   {
   size_t r;
   size_t b;
   register int n;

   /* Calculate and return the address of the dimensioned array */

   b = 1;
   r = 0;
   for ( n = 0; n < v->dimensions; ++n )
      {
      r += b * ( pp[ n ] - dim_base );
      b *= v->array_sizes[ n ];
      }

#if INTENSIVE_DEBUG
   for ( n = 0; n < v->dimensions; ++n )
      {
      sprintf( bwb_ebuf,
         "in dim_unit(): variable <%s> pos <%d> val <%d>.",
         v->name, n, pp[ n ] );
      bwb_debug( bwb_ebuf );
      }
   sprintf( bwb_ebuf, "in dim_unit(): return unit: <%ld>", (long) r );
   bwb_debug( bwb_ebuf );
#endif

   if ( r > v->array_units )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in dim_unit(): unit value <%ld> exceeds array units <%ld>",
         r, v->array_units );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_valoorange );
#endif
      return 0;
      }

   return r;

   }

/***************************************************************

        FUNCTION:       dim_getparams()

	DESCRIPTION:    This function reads a string in <buffer>
                        beginning at position <pos> and finds a
                        list of parameters surrounded by paren-
                        theses, returning in <n_params> the number
                        of parameters found, and returning in
                        <pp> an array of n_params integers giving
                        the sizes for each dimension of the array.

***************************************************************/

#if ANSI_C
int
dim_getparams( char *buffer, int *pos, int *n_params, int **pp )
#else
int
dim_getparams( buffer, pos, n_params, pp )
   char *buffer;
   int *pos;
   int *n_params;
   int **pp;
#endif
   {
   int loop;
   static int params[ MAX_DIMS ];
   int x_pos, s_pos;
   struct exp_ese *e;
   char tbuf[ MAXSTRINGSIZE + 1 ];
   int paren_level, quote_level; /* JBV 1/97 */
#if INTENSIVE_DEBUG
   register int n;
#endif

   /* set initial values */

   *n_params = 0;
#if OLDSTUFF
   paren_found = FALSE;
#endif

   /* advance and check for undimensioned variable */

   adv_ws( buffer, pos );
   if ( buffer[ *pos ] != '(' )
      {
      *n_params = 1;
      params[ 0 ] = dim_base;
      *pp = params;
      return TRUE;
      }
   else
      {
      ++(*pos);
      }

   /* Variable has DIMensions: Find each parameter */

   s_pos = 0;
   tbuf[ 0 ] = '\0';
   loop = TRUE;
   paren_level = 1; /* JBV 1/97 */
   quote_level = 0; /* JBV 1/97 */
   while( loop == TRUE )
      {
      switch( buffer[ *pos ] )
         {
         case ')':                      /* end of parameter list */
            /*-----------------------------------------------------*/
            /* paren_level and quote_level check added by JBV 1/97 */
            /*-----------------------------------------------------*/
            if ( quote_level == 0 ) --paren_level;
            if ( paren_level != 0 || quote_level != 0 ) /* Still not done? */
            {
            tbuf[ s_pos ] = buffer[ *pos ];
            ++(*pos);
            ++s_pos;
            tbuf[ s_pos ] = '\0';
            break;
            }

            x_pos = 0;
            if ( tbuf[ 0 ] == '\0' )
               {
               params[ *n_params ] = DEF_SUBSCRIPT;
               }
            else
               {
#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in dim_getparams(): call bwb_exp() for last element" );
               bwb_debug( bwb_ebuf );
#endif
               e = bwb_exp( tbuf, FALSE, &x_pos );
#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in dim_getparams(): return from bwb_exp() for last element" );
               bwb_debug( bwb_ebuf );
#endif
               params[ *n_params ] = (int) exp_getnval( e );
               }
            ++(*n_params);
            loop = FALSE;
            ++( *pos );
            break;

         case ',':                      /* end of a parameter */
            /*-----------------------------------------------------*/
            /* paren_level and quote_level check added by JBV 1/97 */
            /*-----------------------------------------------------*/
            if ( paren_level != 1 || quote_level != 0 ) /* Still not done? */
            {
            tbuf[ s_pos ] = buffer[ *pos ];
            ++(*pos);
            ++s_pos;
            tbuf[ s_pos ] = '\0';
            break;
            }

            x_pos = 0;
            if ( tbuf[ 0 ] == '\0' )
               {
               params[ *n_params ] = DEF_SUBSCRIPT;
               }
            else
               {
#if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in dim_getparams(): call bwb_exp() for element (not last)" );
               bwb_debug( bwb_ebuf );
#endif
               e = bwb_exp( tbuf, FALSE, &x_pos );
               params[ *n_params ] = (int) exp_getnval( e );
               }
            ++(*n_params);
            tbuf[ 0 ] = '\0';
            ++(*pos);
            s_pos = 0;
            break;

         case ' ':                      /* whitespace -- skip */
         case '\t':
            ++(*pos);
            break;

         default:
            if( buffer[ *pos ] == '(' && quote_level == 0 )
               ++paren_level; /* JBV 1/97 */
            if( buffer[ *pos ] == (char) 34 )
            {
               if (quote_level == 0) quote_level = 1;
               else quote_level = 0;
            }
            tbuf[ s_pos ] = buffer[ *pos ];
            ++(*pos);
            ++s_pos;
            tbuf[ s_pos ] = '\0';
            break;
         }
      }

#if INTENSIVE_DEBUG
   for ( n = 0; n < *n_params; ++n )
      {
      sprintf( bwb_ebuf, "in dim_getparams(): Parameter <%d>: <%d>",
         n, params[ n ] );
      bwb_debug( bwb_ebuf );
      }
#endif

   /* return params stack */

   *pp = params;

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwb_option()

        DESCRIPTION:    This function implements the BASIC OPTION
                        BASE statement, designating the base (1 or
                        0) for addressing DIM arrays.

	SYNTAX:		OPTION BASE number

***************************************************************/

#if ANSI_C
struct bwb_line *
bwb_option( struct bwb_line *l )
#else
struct bwb_line *
bwb_option( l )
   struct bwb_line *l;
#endif
   {
   register int n;
   int newval;
   struct exp_ese *e;
   struct bwb_variable *current;
   char tbuf[ MAXSTRINGSIZE ];

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_option(): entered function." );
   bwb_debug( bwb_ebuf );
#endif

   /* If DIM has already been called, do not allow OPTION BASE */

   if ( dimmed != FALSE )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "at line %d: OPTION BASE must be called before DIM.",
         l->number );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_obdim );
#endif
      return bwb_zline( l );
      }

   /* capitalize first element in tbuf */

   adv_element( l->buffer, &( l->position ), tbuf );
   for ( n = 0; tbuf[ n ] != '\0'; ++n )
      {
      if ( islower( tbuf[ n ] ) != FALSE )
         {
         tbuf[ n ] = (char) toupper( tbuf[ n ] );
         }
      }

   /* check for BASE statement */

   if ( strncmp( tbuf, "BASE", (size_t) 4 ) != 0 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "at line %d: Unknown statement <%s> following OPTION.",
         l->number, tbuf );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_syntax );
#endif
      return bwb_zline( l );
      }

   /* Get new value from argument. */

   adv_ws( l->buffer, &( l->position ) );
   e = bwb_exp( l->buffer, FALSE, &( l->position ) );
   newval = (int) exp_getnval( e );

   /* Test the new value. */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in bwb_option(): New value received is <%d>.", newval );
   bwb_debug( bwb_ebuf );
#endif

   if ( ( newval < 0 ) || ( newval > 1 ) )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "at line %d: value for OPTION BASE must be 1 or 0.",
         l->number );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_valoorange );
#endif
      return bwb_zline( l );
      }

   /* Set the new value. */

   dim_base = newval;

   /* run through the variable list and change any positions that had
      set 0 before OPTION BASE was run */

   for ( current = CURTASK var_start.next; current != &CURTASK var_end; current = current->next )
      {
      current->array_pos[ 0 ] = dim_base;
      }

   /* Return. */

   return bwb_zline( l );

   }

/***************************************************************

        FUNCTION:       var_findnval()

        DESCRIPTION:    This function returns the address of
                        the number for the variable <v>.  If
                        <v> is a dimensioned array, the address
                        returned is for the double at the
                        position indicated by the integer array
                        <pp>.

***************************************************************/


#if ANSI_C
bnumber *
var_findnval( struct bwb_variable *v, int *pp )
#else
bnumber *
var_findnval( v, pp )
   struct bwb_variable *v;
   int *pp;
#endif
   {
   size_t offset;
   bnumber *p;
#if INTENSIVE_DEBUG
   register int n;
#endif

   /* Check for appropriate type */

   if ( v->type != NUMBER )
      {
#if PROG_ERRORS
      sprintf ( bwb_ebuf, "in var_findnval(): Variable <%s> is not a number.",
         v->name );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_mismatch );
#endif
      return NULL;
      }

   /* Check subscripts */

   if ( dim_check( v, pp ) == FALSE )
      {
      return NULL;
      }

   /* Calculate and return the address of the dimensioned array */

   offset = dim_unit( v, pp );

#if INTENSIVE_DEBUG
   for ( n = 0; n < v->dimensions; ++n )
      {
      sprintf( bwb_ebuf,
         "in var_findnval(): dimensioned variable pos <%d> <%d>.",
         n, pp[ n ] );
      bwb_debug( bwb_ebuf );
      }
#endif

   p = v->memnum;
   return (p + offset);

   }

/***************************************************************

        FUNCTION:       var_findsval()

        DESCRIPTION:    This function returns the address of
                        the string for the variable <v>.  If
                        <v> is a dimensioned array, the address
                        returned is for the string at the
                        position indicated by the integer array
                        <pp>.

***************************************************************/

#if ANSI_C
bstring *
var_findsval( struct bwb_variable *v, int *pp )
#else
bstring *
var_findsval( v, pp )
   struct bwb_variable *v;
   int *pp;
#endif
   {
   size_t offset;
   bstring *p;

#if INTENSIVE_DEBUG
   register int n;

   sprintf( bwb_ebuf, "in var_findsval(): entered, var <%s>", v->name );
   bwb_debug( bwb_ebuf );
#endif

   /* Check for appropriate type */

   if ( v->type != STRING )
      {
#if PROG_ERRORS
      sprintf ( bwb_ebuf, "in var_findsval(): Variable <%s> is not a string.", v->name );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_mismatch );
#endif
      return NULL;
      }

   /* Check subscripts */

   if ( dim_check( v, pp ) == FALSE )
      {
      return NULL;
      }

   /* Calculate and return the address of the dimensioned array */

   offset = dim_unit( v, pp );

#if INTENSIVE_DEBUG
   for ( n = 0; n < v->dimensions; ++n )
      {
      sprintf( bwb_ebuf,
         "in var_findsval(): dimensioned variable pos <%d> val <%d>.",
         n, pp[ n ] );
      bwb_debug( bwb_ebuf );
      }
#endif

   p = v->memstr;
   return (p + offset);

   }

/***************************************************************

        FUNCTION:       dim_check()

        DESCRIPTION:    This function checks subscripts of a
                        specific variable to be sure that they
                        are within the correct range.

***************************************************************/

#if ANSI_C
static int
dim_check( struct bwb_variable *v, int *pp )
#else
static int
dim_check( v, pp )
   struct bwb_variable *v;
   int *pp;
#endif
   {
   register int n;

   /* Check for dimensions */

   if ( v->dimensions < 1 )
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in dim_check(): var <%s> dimensions <%d>",
         v->name, v->dimensions );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_valoorange );
#endif
      return FALSE;
      }

   /* Check for validly allocated array */

   if (( v->type == NUMBER ) && ( v->memnum == NULL ))
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in dim_check(): numerical var <%s> memnum not allocated",
	 v->name );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_valoorange );
#endif
      return FALSE;
      }

   if (( v->type == STRING ) && ( v->memstr == NULL ))
      {
#if PROG_ERRORS
      sprintf( bwb_ebuf, "in dim_check(): string var <%s> memstr not allocated",
	 v->name );
      bwb_error( bwb_ebuf );
#else
      bwb_error( err_valoorange );
#endif
      return FALSE;
      }

   /* Now check subscript values */

   for ( n = 0; n < v->dimensions; ++n )
      {
      if ( ( pp[ n ] < dim_base ) || ( ( pp[ n ] - dim_base )
         > v->array_sizes[ n ] ))
         {
#if PROG_ERRORS
         sprintf( bwb_ebuf, "in dim_check(): array subscript var <%s> pos <%d> val <%d> out of range <%d>-<%d>.",
            v->name, n, pp[ n ], dim_base, v->array_sizes[ n ]  );
         bwb_error( bwb_ebuf );
#else
         bwb_error( err_valoorange );
#endif
         return FALSE;
         }
      }

   /* No problems found */

   return TRUE;

   }

/***************************************************************

        FUNCTION:       var_make()

        DESCRIPTION:	This function initializes a variable,
        		allocating necessary memory for it.

***************************************************************/

#if ANSI_C
int
var_make( struct bwb_variable *v, int type )
#else
int
var_make( v, type )
   struct bwb_variable *v;
   int type;
#endif
   {
   size_t data_size;
   bstring *b;
   bstring *sp; /* JBV */
   register int n; /* JBV */
#if TEST_BSTRING
   static int tnumber = 0;
#endif

   switch( type )
      {
      case STRING:
         v->type = STRING;
         data_size = sizeof( bstring );
         break;
      default:
         v->type = NUMBER;
         data_size = sizeof( bnumber );
         break;
      }

   /* get memory for array */

   /* First kleanup the joint (JBV) */
   if (v->memnum != NULL)
   {
       /* Revised to FREE pass-thru call by JBV */
       FREE(v->memnum, "var_make");
       v->memnum = NULL;
   }
   if (v->memstr != NULL)
   {
       /* Remember to deallocate those far-flung branches! (JBV) */
       sp = v->memstr;
       for ( n = 0; n < (int) v->array_units; ++n )
       {
           if ( sp[ n ].sbuffer != NULL )
           {
               /* Revised to FREE pass-thru call by JBV */
               FREE( sp[ n ].sbuffer, "var_make" );
               sp[ n ].sbuffer = NULL;
           }
           sp[ n ].rab = FALSE;
           sp[ n ].length = 0;
       }
       /* Revised to FREE pass-thru call by JBV */
       FREE(v->memstr, "var_make");
       v->memstr = NULL;
   }
   /* Revised to FREE pass-thru calls by JBV */
   if (v->array_sizes != NULL)
   {
       FREE(v->array_sizes, "var_make");
       v->array_sizes = NULL; /* JBV */
   }
   if (v->array_pos != NULL)
   {
       FREE(v->array_pos, "var_make");
       v->array_pos = NULL; /* JBV */
   }

   if ( v->type == NUMBER )
      {
      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( v->memnum = CALLOC( 2, sizeof( bnumber ), "var_make" )) == NULL )
	 {
	 bwb_error( err_getmem );
	 return FALSE;
	 }
      }
   else
      {
      /* Revised to CALLOC pass-thru call by JBV */
      if ( ( v->memstr = CALLOC( 2, sizeof( bstring ), "var_make" )) == NULL )
	 {
	 bwb_error( err_getmem );
	 return FALSE;
	 }
      }

   /* get memory for array_sizes and array_pos */

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( v->array_sizes = (int *) CALLOC( 2, sizeof( int ), "var_make" )) == NULL )
      {
      bwb_error( err_getmem );
      return FALSE;
      }

   /* Revised to CALLOC pass-thru call by JBV */
   if ( ( v->array_pos = (int *) CALLOC( 2, sizeof( int ), "var_make" )) == NULL )
      {
      bwb_error( err_getmem );
      return FALSE;
      }

   v->array_pos[ 0 ] = dim_base;
   v->array_sizes[ 0 ] = 1;
   v->dimensions = 1;
   v->common = FALSE;
   v->array_units = 1;

   if ( type == STRING )
      {
      b = var_findsval( v, v->array_pos );
      b->rab = FALSE;
      }

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_make(): made variable <%s> type <%c> pos[ 0 ] <%d>",
      v->name, v->type, v->array_pos[ 0 ] );
   bwb_debug( bwb_ebuf );
#endif

#if TEST_BSTRING
   if ( type == STRING )
      {
      b = var_findsval( v, v->array_pos );
      sprintf( b->name, "bstring# %d", tnumber );
      ++tnumber;
      sprintf( bwb_ebuf, "in var_make(): new string variable <%s>",
         b->name );
      bwb_debug( bwb_ebuf );
      }
#endif

   return TRUE;

   }

/***************************************************************

	FUNCTION:       var_islocal()

	DESCRIPTION:    This function determines whether the string
			pointed to by 'buffer' has the name of
			a local variable at the present EXEC stack
			level.

***************************************************************/

#if ANSI_C
extern struct bwb_variable *
var_islocal( char *buffer )
#else
struct bwb_variable *
var_islocal( buffer )
   char *buffer;
#endif
   {
   struct bwb_variable *v;

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_islocal(): check for local variable <%s> EXEC level <%d>",
      buffer, CURTASK exsc );
   bwb_debug( bwb_ebuf );
#endif

   /* run through the local variable list and try to find a match */

   for ( v = CURTASK excs[ CURTASK exsc ].local_variable; v != NULL; v = v->next )
      {

#if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in var_islocal(): checking var <%s> level <%d>...",
         v->name, CURTASK exsc );
      bwb_debug( bwb_ebuf );
#endif

      if ( strcmp( v->name, buffer ) == 0 )
         {

#if PROG_ERRORS
         switch( v->type )
            {
            case STRING:
            case NUMBER:
               break;
            default:
               sprintf( bwb_ebuf, "in var_islocal(): inappropriate precision for variable <%s>",
                  v->name );
               bwb_error( bwb_ebuf );
               break;
            }
#endif

#if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in var_islocal(): found local variable <%s>", v->name );
         bwb_debug( bwb_ebuf );
#endif

         return v;
         }

      }

   /* search failed, return NULL */

#if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_islocal(): Failed to find local variable <%s> level <%d>",
      buffer, CURTASK exsc );
   bwb_debug( bwb_ebuf );
#endif

   return NULL;

   }

/***************************************************************

        FUNCTION:       bwb_vars()

        DESCRIPTION:    This function implements the Bywater-
        		specific debugging command VARS, which
        		gives a list of all variables defined
        		in memory.

***************************************************************/

#if PERMANENT_DEBUG

#if ANSI_C
struct bwb_line *
bwb_vars( struct bwb_line *l )
#else
struct bwb_line *
bwb_vars( l )
   struct bwb_line *l;
#endif
   {
   struct bwb_variable *v;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* run through the variable list and print variables */

   for ( v = CURTASK var_start.next; v != &CURTASK var_end; v = v->next )
      {
      sprintf( bwb_ebuf, "variable <%s>\t", v->name );
      prn_xprintf( stdout, bwb_ebuf );
      switch( v->type )
         {
         case STRING:
            str_btoc( tbuf, var_getsval( v ) );
	    sprintf( bwb_ebuf, "STRING\tval: <%s>\n", tbuf );
	    prn_xprintf( stdout, bwb_ebuf );
            break;
         case NUMBER:
#if NUMBER_DOUBLE
	    sprintf( bwb_ebuf, "NUMBER\tval: <%lf>\n", var_getnval( v ) );
	    prn_xprintf( stdout, bwb_ebuf );
#else
	    sprintf( bwb_ebuf, "NUMBER\tval: <%f>\n", var_getnval( v ) );
	    prn_xprintf( stdout, bwb_ebuf );
#endif
            break;
         default:
	    sprintf( bwb_ebuf, "ERROR: type is <%c>", (char) v->type );
	    prn_xprintf( stdout, bwb_ebuf );
            break;
         }
      }

   return bwb_zline( l );
   }

#endif

