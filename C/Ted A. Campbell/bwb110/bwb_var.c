/***************************************************************

        bwb_var.c       Variable-Handling Routines
                        for Bywater BASIC Interpreter

                        Commands:	DIM
                                        COMMON
                                        ERASE
                                        SWAP
					CLEAR

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
#include <ctype.h>
#include <math.h>
#include <string.h>

#include "bwbasic.h"
#include "bwb_mes.h"

struct bwb_variable var_start, var_end;

int dim_base = 0;                        	/* set by OPTION BASE */
static int dimmed = FALSE;                      /* has DIM been called? */
static int first, last;				/* first, last for DEFxxx commands */

/* Prototypes for functions visible to this file only */

static int dim_check( struct bwb_variable *v, int *pp );
static int var_defx( struct bwb_line *l, int type );
static int var_letseq( char *buffer, int *position, int *start, int *end );
static size_t dim_unit( struct bwb_variable *v, int *pp );

/***************************************************************

        FUNCTION:       var_init()

        DESCRIPTION:	This function initializes the internal 
        linked list of variables.

***************************************************************/

int
var_init()
   {
   var_start.next = &var_end;
   strcpy( var_start.name, "<START>" );
   strcpy( var_end.name, "<END>" );
   return TRUE;
   }

/***************************************************************

        FUNCTION:       bwb_common()

        DESCRIPTION:	This C function implements the BASIC
        		COMMON command.

***************************************************************/

struct bwb_line *
bwb_common( struct bwb_line *l )
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
         return l;
         }

      v->common = TRUE;				/* set common flag to true */

      /* check for comma */

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] != ',' )
         {
         return l;				/* no comma; leave */
         }
      ++( l->position );
      adv_ws( l->buffer, &( l->position ) );

      }

   }

/***********************************************************

        Function:	bwb_ddbl()

        This function implements the BASIC DEFDBL command.

***********************************************************/

struct bwb_line *
bwb_ddbl( struct bwb_line *l )
   {
 
   /* call generalized DEF handler with DOUBLE set */

   var_defx( l, DOUBLE );
   
   return l;

   }

/***********************************************************

        Function:	bwb_dint()

        This function implements the BASIC DEFINT command.

***********************************************************/

struct bwb_line *
bwb_dint( struct bwb_line *l )
   {

   /* call generalized DEF handler with INTEGER set */

   var_defx( l, INTEGER );
   
   return l;

   }

/***********************************************************

        Function:	bwb_dsng()

        This function implements the BASIC DEFSNG command.

***********************************************************/

struct bwb_line *
bwb_dsng( struct bwb_line *l )
   {

   /* call generalized DEF handler with SINGLE set */

   var_defx( l, SINGLE );
   
   return l;

   }

/***********************************************************

        Function:	bwb_dstr()

        This function implements the BASIC DEFSTR command.

***********************************************************/

struct bwb_line *
bwb_dstr( struct bwb_line *l )
   {

   /* call generalized DEF handler with STRING set */

   var_defx( l, STRING );
   
   return l;

   }

/***********************************************************

        Function:	var_defx()

        This function is a generalized DEFxxx handler.

***********************************************************/

static int
var_defx( struct bwb_line *l, int type )
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

/***********************************************************

        Function:	var_letseq()

        This function finds a sequence of letters for a DEFxxx
        command.

***********************************************************/

static int
var_letseq( char *buffer, int *position, int *start, int *end )
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

        Function:	bwb_clear()

        This function implements the BASIC CLEAR command.

***********************************************************/

struct bwb_line *
bwb_clear( struct bwb_line *l )
   {
   struct bwb_variable *v;
   register int n;
   int *ip;
   bstring *sp;
   float *fp;
   double *dp;
   
   for ( v = var_start.next; v != &var_end; v = v->next )
      {
      switch( v->type )
         {
         case SINGLE:
            fp = (float *) v->array;
            for ( n = 0; n < v->array_units; ++n )
               {
               fp[ n ] = (float) 0.0;
               }
            break;
         case DOUBLE:
            dp = (double *) v->array;
            for ( n = 0; n < v->array_units; ++n )
               {
               dp[ n ] = (double) 0.0;
               }
            break;
         case INTEGER:
            ip = (int *) v->array;
            for ( n = 0; n < v->array_units; ++n )
               {
               ip[ n ] = 0;
               }
            break;
         case STRING:
            sp = (bstring *) v->array;
            for ( n = 0; n < v->array_units; ++n )
               {
               if ( sp[ n ].buffer != NULL )
                  {
                  free( sp[ n ].buffer );
                  sp[ n ].buffer = NULL;
                  }
               sp[ n ].rab = FALSE;
               sp[ n ].length = 0;
               }
            break;
         }
      }

   return l;

   }

/***********************************************************

        Function:	var_delcvars()

        This function deletes all variables in memory except
        those previously marked as common.

***********************************************************/

int
var_delcvars()
   {
   struct bwb_variable *v;
   struct bwb_variable *p;		/* previous variable */

   p = &var_start;
   for ( v = var_start.next; v != &var_end; v = v->next )
      {

      if ( v->common != TRUE )
         {

         /* if the variable is dimensioned, release allocated memory */

         if ( v->dimensions > 0 )
            {

            /* deallocate memory */

            free( v->array_sizes );
            free( v->array_pos );
            free( v->array );

            }

         /* reassign linkage */

         p->next = v->next;

         /* deallocate the variable itself */

         free( v );

         }

      /* else reset previous variable */

      else
         {
         p = v;
         }

      }

   return TRUE;

   }

/***********************************************************

        Function:	bwb_erase()

        This function implements the BASIC ERASE command.

***********************************************************/

struct bwb_line *
bwb_erase( struct bwb_line *l )
   {
   register int loop;
   struct bwb_variable *v;
   struct bwb_variable *p;		/* previous variable in linked list */
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
         return l;
         }

      /* be sure the variable is dimensioned */

      if (( v->dimensions < 1 ) || ( v->array_sizes[ 0 ] < 1 ))
	 {
	 bwb_error( err_dimnotarray );
	 return l;
         }

      /* find previous variable in chain */

      for ( p = &var_start; p->next != v; p = p->next )
         {
         ;
         }

      /* reassign linkage */

      p->next = v->next;

      /* deallocate memory */

      free( v->array_sizes );
      free( v->array_pos );
      free( v->array );
      free( v );

      /* check for comma */

      adv_ws( l->buffer, &( l->position ) );
      if ( l->buffer[ l->position ] != ',' )
         {
         return l;				/* no comma; leave */
         }
      ++( l->position );
      adv_ws( l->buffer, &( l->position ) );

      }

   }

/***********************************************************

        Function:	bwb_swap()

        This function implements the BASIC SWAP command.

***********************************************************/

struct bwb_line *
bwb_swap( struct bwb_line *l )
   {
   struct bwb_variable *v;			/* temp holder */
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
      return l;
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
      return l;
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
      return l;
      }

   /* check to be sure that both variables are of the same type */

   if ( rhs->type != lhs->type )
      {
      bwb_error( err_mismatch );
      return l;
      }

   /* copy lhs to temp, rhs to lhs, then temp to rhs */

   memcpy( &v,  lhs, sizeof( struct bwb_variable ));
   memcpy( lhs, rhs, sizeof( struct bwb_variable ));
   memcpy( rhs, &v,  sizeof( struct bwb_variable ));

   /* return */

   return l;

   }

/***********************************************************

        bwb_const()

        This function takes the string in lb (the large buffer),
        finds a string constant (beginning and ending with 
        quotation marks), and returns it in sb (the small
        buffer), appropriately incrementing the integer
        pointed to by n. The string in lb should NOT include
        the initial quotation mark.

***********************************************************/

bwb_const( char *lb, char *sb, int *n )
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

        bwb_getvarname()

        This function takes the string in lb (the large buffer),
        finds a variable name, and returns it in sb (the
        small buffer), appropriately incrementing the integer
        pointed to by n.

***********************************************************/

bwb_getvarname( char *lb, char *sb, int *n )
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

        DESCRIPTION:

***************************************************************/

struct bwb_variable *
var_find( char *buffer )
   {
   struct bwb_variable *v;
   size_t array_size;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_find(): received <%s>", buffer );
   bwb_debug( bwb_ebuf );
   #endif

   /* first, run through the variable list and try to find a match */

   for ( v = var_start.next; v != &var_end; v = v->next )
      {

      if ( strcmp( v->name, buffer ) == 0 )
         {
         switch( v->type )
            {
            case STRING:
            case DOUBLE:
            case INTEGER:
            case SINGLE:
               break;
            default:
               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in var_find(): inappropriate precision for variable <%s>",
                  v->name );
               bwb_error( bwb_ebuf );
               #endif
               break;
            }
         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in var_find(): found existing variable <%s>", v->name );
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

   /* get memory for new variable */

   if ( ( v = (struct bwb_variable *) calloc( 1, sizeof( struct bwb_variable ) )) 
      == NULL )
      {
      bwb_error( err_getmem );
      return NULL;
      }

   /* get memory for new variable name */

   #if ALLOCATE_NAME
   if ( ( v->name = (char *) calloc( 1, strlen( buffer ) + 1 )) 
      == NULL )
      {
      bwb_error( err_getmem );
      return NULL;
      }
   #endif

   /* copy the name into the appropriate structure */

   strcpy( v->name, buffer );

   /* set memory in the new variable */

   var_make( v, (int) v->name[ strlen( v->name ) - 1 ] );

   /* set place at beginning of variable chain */

   v->next = var_start.next;
   var_start.next = v;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_find(): initialized new variable <%s> type <%c>, dim <%d>",
      v->name, v->type, v->dimensions );
   bwb_debug( bwb_ebuf );
   #endif

   return v;

   }

/***************************************************************

        FUNCTION:       bwb_isvar()

        DESCRIPTION:

***************************************************************/

int
bwb_isvar( char *buffer )
   {
   struct bwb_variable *v;

   /* run through the variable list and try to find a match */

   for ( v = var_start.next; v != &var_end; v = v->next )
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

        FUNCTION:   var_getdval()

        DESCRIPTION:  This function returns the current value of
        the variable argument as a double precision number.

***************************************************************/

double
var_getdval( struct bwb_variable *nvar )
   {

   switch( nvar->type )
      {
      case DOUBLE:
         return *( var_finddval( nvar, nvar->array_pos ) );
      case SINGLE:
         return (double) *( var_findfval( nvar, nvar->array_pos ) );
      case INTEGER:
         return (double) *( var_findival( nvar, nvar->array_pos ) );
      }

   #if PROG_ERRORS
   sprintf( bwb_ebuf, "in var_getdval(): type is <%d>=<%c>.",
      nvar->type, nvar->type );
   bwb_error( bwb_ebuf );
   #else
   bwb_error( err_mismatch );
   #endif


   return (double) 0.0;

   }

/***************************************************************

        FUNCTION:   var_getfval()

        DESCRIPTION:  This function returns the current value of
        the variable argument as a single precision number (float).

***************************************************************/

float
var_getfval( struct bwb_variable *nvar )
   {

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_getfval(): variable <%s>, type <%c>",
      nvar->name, nvar->type );
   bwb_debug( bwb_ebuf );
   #endif

   switch( nvar->type )
      {
      case DOUBLE:
         return (float) *( var_finddval( nvar, nvar->array_pos ) );
      case SINGLE:
         return *( var_findfval( nvar, nvar->array_pos ) );
      case INTEGER:
         return (float) *( var_findival( nvar, nvar->array_pos ) );
      }

   #if PROG_ERRORS
   sprintf( bwb_ebuf, "in var_getfval(): type is <%d>=<%c>.",
      nvar->type, nvar->type );
   bwb_error( bwb_ebuf );
   #else
   bwb_error( err_mismatch );
   #endif

   return (float) 0.0;

   }

/***************************************************************

        FUNCTION:   var_getival()

        DESCRIPTION:  This function returns the current value of
        the variable argument as an integer.

***************************************************************/

int
var_getival( struct bwb_variable *nvar )
   {

   switch( nvar->type )
      {
      case DOUBLE:
         return (int) *( var_finddval( nvar, nvar->array_pos ) );
      case SINGLE:

         #if INTENSIVE_DEBUG
         sprintf( bwb_ebuf, "in var_getival(): float <%f> -> int <%d>",
            nvar->fval, (int) nvar->fval );
         bwb_debug( bwb_ebuf );
         #endif

         return (int) *( var_findfval( nvar, nvar->array_pos ) );
      case INTEGER:
         return *( var_findival( nvar, nvar->array_pos ) );
      }

   #if PROG_ERRORS
   sprintf( bwb_ebuf, "in var_getival(): type is <%d>=<%c>.",
      nvar->type, nvar->type );
   bwb_error( bwb_ebuf );
   #else
   bwb_error( err_mismatch );
   #endif

   return 0;

   }

/***************************************************************

        FUNCTION:   var_getsval()

        DESCRIPTION:  This function returns the current value of
        the variable argument as a pointer to a BASIC string
        structure.

***************************************************************/

bstring *
var_getsval( struct bwb_variable *nvar )
   {
   static bstring b;

   b.rab = FALSE;

   switch( nvar->type )
      {
      case STRING:
         return var_findsval( nvar, nvar->array_pos );
      case DOUBLE:
         sprintf( bwb_ebuf, "%*f ", prn_precision( nvar ),
            *( var_finddval( nvar, nvar->array_pos ) ) );
         str_ctob( &b, bwb_ebuf );
         return &b;
      case SINGLE:
         sprintf( bwb_ebuf, "%*f ", prn_precision( nvar ),
            *( var_findfval( nvar, nvar->array_pos ) ) );
         str_ctob( &b, bwb_ebuf );
         return &b;
      case INTEGER:
         sprintf( bwb_ebuf, "%d ", *( var_findival( nvar, nvar->array_pos ) ) );
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

        FUNCTION:       bwb_dim()

        DESCRIPTION:    This function implements the BASIC DIM
                        statement, allocating memory for a
                        dimensioned array of variables.

***************************************************************/

struct bwb_line *
bwb_dim( struct bwb_line *l )
   {
   register int n;
   static int n_params;                         /* number of parameters */
   static int *pp;                              /* pointer to parameter values */
   struct bwb_variable *newvar;
   double *d;
   float *f;
   int *i;
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

         if ( ( newvar->array_sizes = (int *) calloc( n_params, sizeof( int )  )) == NULL )
            {
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "in line %d: Failed to find memory for array_sizes for <%s>",
               l->number, newvar->name );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_getmem );
            #endif
            l->next->position = 0;
            return l->next;
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

         if ( ( newvar->array_pos = (int *) calloc( n_params, sizeof( int ) )) == NULL )
            {
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "in line %d: Failed to find memory for array_pos for <%s>",
               l->number, newvar->name );
            bwb_error( bwb_ebuf );
            #else
            bwb_error( err_getmem );
            #endif
            l->next->position = 0;
            return l->next;
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
               if ( ( newvar->array = (char *) calloc( newvar->array_units, sizeof( bstring) )) == NULL )
                  {
                  #if PROG_ERRORS
                  sprintf( bwb_ebuf, "in line %d: Failed to find memory for array <%s>",
                     l->number, newvar->name );
                  bwb_error( bwb_ebuf );
                  #else
                  bwb_error( err_getmem );
                  #endif
                  l->next->position = 0;
                  return l->next;
                  }
               break;
            case DOUBLE:
               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_dim(): 1 DOUBLE requires <%ld> bytes",
                  (long) sizeof( double ));
               bwb_debug( bwb_ebuf );
               sprintf( bwb_ebuf, "in bwb_dim(): DOUBLE array memory requires <%ld> bytes",
        	  (long) ( newvar->array_units + 1 ) * sizeof( double ));
               bwb_debug( bwb_ebuf );
               #endif
               if ( ( d = (double *) calloc( newvar->array_units, sizeof( double ) )) == NULL )
                  {
                  #if PROG_ERRORS
                  sprintf( bwb_ebuf, "in line %d: Failed to find memory for array <%s>",
                  l->number, newvar->name );
                  bwb_error( bwb_ebuf );
                  #else
                  bwb_error( err_getmem );
                  #endif
                  l->next->position = 0;
                  return l->next;
                  }
               newvar->array = (char *) d;
               break;
            case SINGLE:
               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_dim(): 1 SINGLE requires <%ld> bytes",
                  (long) sizeof( float ));
               bwb_debug( bwb_ebuf );
               sprintf( bwb_ebuf, "in bwb_dim(): SINGLE array memory requires <%ld> bytes",
        	  (long) ( newvar->array_units + 1 ) * sizeof( float ));
               bwb_debug( bwb_ebuf );
               #endif
               if ( ( f = (float *) calloc( newvar->array_units, sizeof( float ) )) == NULL )
                  {
                  #if PROG_ERRORS
                  sprintf( bwb_ebuf, "in line %d: Failed to find memory for array <%s>",
                     l->number, newvar->name );
                  bwb_error( bwb_ebuf );
                  #else
                  bwb_error( err_getmem );
                  #endif
                  l->next->position = 0;
                  return l->next;
                  }
               newvar->array = (char *) f;
               break;
            case INTEGER:
               #if INTENSIVE_DEBUG
               sprintf( bwb_ebuf, "in bwb_dim(): 1 INTEGER requires <%ld> bytes",
                  (long) sizeof( int ));
               bwb_debug( bwb_ebuf );
               sprintf( bwb_ebuf, "in bwb_dim(): INTEGER array memory requires <%ld> bytes",
        	  (long) ( newvar->array_units + 1 ) * sizeof( int ));
               bwb_debug( bwb_ebuf );
               #endif
               if ( ( i = (int *) calloc( newvar->array_units, sizeof( int ) )) == NULL )
                  {
                  #if PROG_ERRORS
                  sprintf( bwb_ebuf, "in line %d: Failed to find memory for array <%s>",
                     l->number, newvar->name );
                  bwb_error( bwb_ebuf );
                  #else
                  bwb_error( err_getmem );
                  #endif
                  l->next->position = 0;
                  return l->next;
                  }
               newvar->array = (char *) i;
               break;
            default:
               #if PROG_ERRORS
               sprintf( bwb_ebuf, "in line %d: New variable has unrecognized type.",
                  l->number );
               bwb_error( bwb_ebuf );
               #else
               bwb_error( err_syntax );
               #endif
               l->next->position = 0;
               return l->next;
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

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       dim_unit()

        DESCRIPTION:    This function calculates the unit
        		position for an array.

***************************************************************/

size_t
dim_unit( struct bwb_variable *v, int *pp )
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

        DESCRIPTION:    This fuunction reads a string in <buffer>
                        beginning at position <pos> and finds a
                        list of parameters surrounded by paren-
                        theses, returning in <n_params> the number
                        of parameters found, and returning in
                        <pp> an array of n_params integers giving
                        the sizes for each dimension of the array.

***************************************************************/

int
dim_getparams( char *buffer, int *pos, int *n_params, int **pp )
   {
   int loop;
   static int params[ MAX_DIMS ];
   int x_pos, s_pos;
   int paren_found;
   register int n;
   struct exp_ese *e;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* set initial values */

   *n_params = 0;
   paren_found = FALSE;

   /* find open parenthesis */

   loop = TRUE;
   while ( loop == TRUE )
      {

      #if INTENSIVE_DEBUG
      sprintf( bwb_ebuf, "in dim_getparams(): eval char <%c = 0x%x>",
         buffer[ *pos ], buffer[ *pos ] );
      bwb_debug( bwb_ebuf );
      #endif

      switch( buffer[ *pos ] )
         {
         case '\0':                     /* end of line */
         case '\n':
         case '\r':
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "Unexpected end of line in dimensioned variable." );
            bwb_error ( bwb_ebuf );
            #else
            bwb_error( err_syntax );
            #endif
	    return FALSE;
            break;
         case ' ':                      /* whitespace */
         case '\t':
            if ( paren_found == FALSE )
               {
               ++(*pos);
               *n_params = 1;
               params[ 0 ] = dim_base;
               *pp = params;
               free( tbuf );
               return TRUE;
               }
            else
               {
               ++(*pos);
               }
            break;

         case '(':                      /* the open parenthesis */
            ++(*pos);
            paren_found = TRUE;
            loop = FALSE;
            #if INTENSIVE_DEBUG
            sprintf( bwb_ebuf, "in dim_getparams(): open parenthesis found (1)." );
            bwb_debug( bwb_ebuf );
            #endif
            break;

         default:			/* any other character */
            #if PROG_ERRORS
            sprintf( bwb_ebuf, "in dim_getparams(): illegal char <%c = 0x%x> in dimensioned variable.",
               buffer[ *pos ], buffer[ *pos ] );
            bwb_error ( bwb_ebuf );
            #else
            bwb_error( err_syntax );
            #endif
	    return FALSE;
         }
      }

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in dim_getparams(): open parenthesis found (2)." );
   bwb_debug( bwb_ebuf );
   #endif

   /* Find each parameter */

   s_pos = 0;
   tbuf[ 0 ] = '\0';
   loop = TRUE;
   while( loop == TRUE )
      {
      switch( buffer[ *pos ] )
         {
         case ')':                      /* end of parameter list */
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
               params[ *n_params ] = exp_getival( e );
               }
            ++(*n_params);
            loop = FALSE;
            ++( *pos );
            break;

         case ',':                      /* end of a parameter */
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
               params[ *n_params ] = exp_getival( e );
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

***************************************************************/

struct bwb_line *
bwb_option( struct bwb_line *l )
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
      l->next->position = 0;
      return l->next;
      }

   /* capitalize first element in tbuf */

   adv_element( l->buffer, &( l->position ), tbuf );
   for ( n = 0; tbuf[ n ] != '\0'; ++n )
      {
      if ( islower( tbuf[ n ] ) != FALSE )
         {
         tbuf[ n ] = toupper( tbuf[ n ] );
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
      l->next->position = 0;
      return l->next;
      }

   /* Get new value from argument. */

   adv_ws( l->buffer, &( l->position ) );
   e = bwb_exp( l->buffer, FALSE, &( l->position ) );
   newval = exp_getival( e );

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
      l->next->position = 0;
      return l->next;
      }

   /* Set the new value. */

   dim_base = newval;

   /* run through the variable list and change any positions that had
      set 0 before OPTION BASE was run */ 

   for ( current = var_start.next; current != &var_end; current = current->next )
      {
      current->array_pos[ 0 ] = dim_base;
      }

   /* Return. */

   l->next->position = 0;
   return l->next;

   }

/***************************************************************

        FUNCTION:       var_findival()

        DESCRIPTION:    This function returns the address of
                        the integer for the variable <v>.  If
                        <v> is a dimensioned array, the address
                        returned is for the integer at the
                        position indicated by the integer array
                        <pp>.

***************************************************************/

int *
var_findival( struct bwb_variable *v, int *pp )
   {
   register int n;
   size_t offset;
   int *p;

   /* Check for appropriate type */

   if ( v->type != INTEGER )
      {
      #if PROG_ERRORS
      sprintf ( bwb_ebuf, "in var_findival(): variable <%s> is not an integer.", v->name );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_mismatch );
      #endif
      return NULL;
      }

   /* check subscripts */

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
         "in var_findival(): dimensioned variable pos <%d> <%d>.",
         n, pp[ n ] );
      bwb_debug( bwb_ebuf );
      }
   #endif

   p = (int *) v->array;
   return (p + offset);

   }

/***************************************************************

        FUNCTION:       var_finddval()

        DESCRIPTION:    This function returns the address of
                        the double for the variable <v>.  If
                        <v> is a dimensioned array, the address
                        returned is for the double at the
                        position indicated by the integer array
                        <pp>.

***************************************************************/

double *
var_finddval( struct bwb_variable *v, int *pp )
   {
   register int n;
   size_t offset;
   double *p;

   /* Check for appropriate type */

   if ( v->type != DOUBLE )
      {
      #if PROG_ERRORS
      sprintf ( bwb_ebuf, "in var_finddval(): Variable <%s> is not double precision.", 
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
         "in var_finddval(): dimensioned variable pos <%d> <%d>.",
         n, pp[ n ] );
      bwb_debug( bwb_ebuf );
      }
   #endif

   p = (double *) v->array;
   return (p + offset);

   }

/***************************************************************

        FUNCTION:       var_findfval()

        DESCRIPTION:    This function returns the address of
                        the float value for the variable <v>.  If
                        <v> is a dimensioned array, the address
                        returned is for the float at the
                        position indicated by the integer array
                        <pp>.

***************************************************************/

float *
var_findfval( struct bwb_variable *v, int *pp )
   {
   register int n;
   size_t offset;
   float *r;
   float *p;

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf, "in var_findfval(): variable <%s>, type <%c>",
      v->name, v->type );
   bwb_debug( bwb_ebuf );
   #endif

   /* Check for appropriate type */

   if ( v->type != SINGLE )
      {
      #if PROG_ERRORS
      sprintf ( bwb_ebuf, "in var_findfval(): Variable <%s> is not single precision: prec <%c>",
         v->name, v->type );
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
         "in var_findfval(): dimensioned variable <%s> dim <%d> val <%d>.",
         v->name, n, pp[ n ] );
      bwb_debug( bwb_ebuf );
      }
   #endif

   #if INTENSIVE_DEBUG
   sprintf( bwb_ebuf,
      "in var_findfval(): dimensioned variable <%s> offset <%ld>",
      v->name, (long) offset );
      bwb_debug( bwb_ebuf );
   #endif

   p = (float *) v->array;
   r = (p + offset);

   #if INTENSIVE_DEBUG
   if ( ( r < (float *) v->array ) || ( r > (float *) v->array_max ))
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in var_findfval(): return value is out of range" );
      bwb_error( bwb_ebuf );
      #else
      bwb_error( err_valoorange );
      #endif
      return r;
      }
   #endif

   return r;

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

bstring *
var_findsval( struct bwb_variable *v, int *pp )
   {
   register int n;
   size_t offset;
   bstring *p;

   #if INTENSIVE_DEBUG
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

   p = (bstring *) v->array;
   return (p + offset);

   }

/***************************************************************

        FUNCTION:       dim_check()

        DESCRIPTION:    This function checks subscripts of a
                        specific variable to be sure that they
                        are within the correct range.

***************************************************************/

int
dim_check( struct bwb_variable *v, int *pp )
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

   if ( v->array == NULL )
      {
      #if PROG_ERRORS
      sprintf( bwb_ebuf, "in dim_check(): var <%s> array not allocated",
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

int
var_make( struct bwb_variable *v, int type )
   {
   size_t data_size;
   bstring *b;
   #if TEST_BSTRING
   static int tnumber = 0;
   #endif

   switch( type )
      {
      case DOUBLE:
         v->type = DOUBLE;
         data_size = sizeof( double );
         break;
      case INTEGER:
         v->type = INTEGER;
         data_size = sizeof( int );
         break;
      case STRING:
         v->type = STRING;
         data_size = sizeof( bstring );
         break;
      default:
         v->type = SINGLE;
         data_size = sizeof( float );
         break;
      }

   /* get memory for array */

   if ( ( v->array = (char *) calloc( 2, data_size )) == NULL )
      {
      bwb_error( err_getmem );
      /* da stand vorher NULL */
      return 0;
      }

   /* get memory for array_sizes and array_pos */

   if ( ( v->array_sizes = (int *) calloc( 2, sizeof( int ) )) == NULL )
      {
      bwb_error( err_getmem );
      return 0;
      }

   if ( ( v->array_pos = (int *) calloc( 2, sizeof( int ) )) == NULL )
      {
      bwb_error( err_getmem );
      return 0;
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
      sprintf( b->name, "bstring # %d", tnumber );
      ++tnumber;
      sprintf( bwb_ebuf, "in var_make(): new string variable <%s>",
         b->name );
      bwb_debug( bwb_ebuf );
      }
   #endif

   return TRUE;

   }

/***************************************************************

        FUNCTION:       bwb_vars()

        DESCRIPTION:    This function implements the Bywater-
        		specific debugging command VARS, which
        		gives a list of all variables defined
        		in memory.

***************************************************************/

#if PERMANENT_DEBUG
struct bwb_line *
bwb_vars( struct bwb_line *l )
   {
   struct bwb_variable *v;
   char tbuf[ MAXSTRINGSIZE + 1 ];

   /* run through the variable list and print variables */

   for ( v = var_start.next; v != &var_end; v = v->next )
      {
      fprintf( stdout, "variable <%s>\t", v->name );
      switch( v->type )
         {
         case STRING:
            str_btoc( tbuf, var_getsval( v ) );
            fprintf( stdout, "STRING\tval: <%s>\n", tbuf );
            break;
         case INTEGER:
            fprintf( stdout, "INTEGER\tval: <%d>\n", var_getival( v ) );
            break;
         case DOUBLE:
            fprintf( stdout, "DOUBLE\tval: <%lf>\n", var_getdval( v ) );
            break;
         case SINGLE:
            fprintf( stdout, "SINGLE\tval: <%f>\n", var_getfval( v ) );
            break;
         default:
            fprintf( stdout, "ERROR: type is <%c>", (char) v->type );
            break;
         }
      }

   l->next->position = 0;
   return l->next;
   }
#endif
