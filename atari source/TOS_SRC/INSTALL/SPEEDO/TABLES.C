/* TABLES.C
 * ================================================================
 * Builds and handles the DAT Table information
 * DATE: April 20, 1992
 */
#include <alt\gemskel.h>
#include <alt\vdikeys.h>
#include <gemlib.h>
#include <strings.h>

#include "country.h"
#include "setup.h"
#include "text.h"
#include "gemskel.h"
#include "handlers.h"
#include "file.h"

/* DEFINES
 * ================================================================
 */
typedef struct _file_node
{
     char fname[15];		/* filename or wild card 	*/
     char parameter[15]; 	/* parameter following, if any  */
}FILE_NODE;


typedef struct _title_node
{
     char      pattern[30];	/* Pattern - [FOLDER.GDOS]  */
     char      path[30];	/* Path - ie: GDOS	    */ 
     int       count;		/* Count - Num of nodes used*/
     FILE_NODE fnode[20];	/* Nodes to store FILE_NODES*/
}TITLE_NODES;

#define NUM_PATTERNS  7

/* EXTERNS
 * ================================================================
 */


/* PROTOTYPES
 * ================================================================
 */
void	BuildTables( void );
void	InitTables( void );


/* GLOBALS 
 * ================================================================
 */
TITLE_NODES Titles[20];

char *Patterns[] = { 
			 "[FOLDER.GDOS]",
		     "[FOLDER.AUTO]",
		     "[FOLDER.ACC]",
		     "[FOLDER.ASSIGN]",
		     "[FOLDER.EXTEND]",
		     "[FOLDER.DRIVERS]",
		     "[FOLDER.FONTS]",
		   };

char *TPaths[] = { 
		   "GDOS",
		   "AUTO",
		   "ACC",
		   "ASSIGN",
		   "EXTEND",
		   "DRIVERS",
		   "FONTS",
		 };


/* FUNCTIONS
 * ================================================================
 */


/* BuildTables()
 * ================================================================
 */
void
BuildTables( void )
{
   int  i;
   char *bufptr;
   int  count;
   char *cptr;
   char *ptr;

   InitTables();

   /* NO Error Checking. if the user mucks with the DAT file,
    * well, that's their fault.
    */
   for( i = 0; i < NUM_PATTERNS; i++ )
   {
      count = 0;
      if( (bufptr = strstr( data_buffer, Titles[i].pattern ))!=NULL)
      {
	  /* Gets us to the next line */
     	  bgetstr( bufptr, TempString );
          bufptr += ( (char)strlen( TempString) + 2 );

	  /* Get the first data line */
          bgetstr( bufptr, TempString ); 

     	  while( TempString[0] != '[' )
     	  {
	     /* Skip comments */
             if( TempString[0] != ';' )
	     {
		 /* Skip Blanks...but, get the string data */
	         if( ( cptr = GetStringData( TempString )) != NULL )
	         {
		    /* If there is a comma, then there is a parameter */
		    if( (ptr = strchr( cptr, ',' )) != NULL )
		    {
			strcpy( Titles[i].fnode[count].parameter, ptr+1 );
			*ptr = '\0';
		    }
		    
	            strcpy( Titles[i].fnode[count].fname, cptr );
	            count++;
	         } 
	      }
     	      bufptr += ( strlen( TempString ) + 2 );
              bgetstr( bufptr, TempString ); 
          }
	  Titles[i].count = count;
      }
   }
}




/* InitTables();
 * ================================================================
 */
void
InitTables( void )
{
   int i;

   for( i = 0; i < NUM_PATTERNS; i++ )
   {
     strcpy( Titles[ i ].pattern, Patterns[ i ] );
     strcpy( Titles[ i ].path, TPaths[ i ] );
     Titles[ i ].count = 0;
   }
}

