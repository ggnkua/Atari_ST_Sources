/*==========================================================================
 * FILE: POPCTRL.C
 *==========================================================================
 * DATE: July 12, 1990
 * DESCRIPTION: Front End to Popups
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>

#include "popstuff.h"


/* PROTOTYPES
 *==========================================================================
 */



/* EXTERNALS
 *==========================================================================
 */


/* GLOBALS
 *==========================================================================
 */
 
struct foobar {
  WORD dummy;
  WORD *image;
};

char blanks[ 50 ][40];	/* Used for Pop_Up String Manipulation  */
char *blank[ 50 ];		/* and is subject to change after review*/



/* Pop_Handle()
 *==========================================================================
 * Setup strings for popup menu and execute...
 */
int
Pop_Handle( OBJECT *tree, int button, char *items[],
            int num_items, int *default_item,
            int font_size, int width )
{
   GRECT butn, world;
   
   int  i;
   int  obj;
   long max = 0L;
   int small = FALSE;

   butn = ObRect( button );
   objc_offset( tree, button, &butn.g_x, &butn.g_y );

   world = ObRect( ROOT );
   objc_offset( tree, ROOT, &world.g_x, &world.g_y ); 
   
   butn.g_w = 30 * gl_wchar;
   butn.g_x = (( world.g_w - butn.g_w )/2) + world.g_x;
   
   for( i = 0; i < num_items; i++ )
   {
       if( strlen( items[i] ) > max )
       	 	max = strlen( items[i] );
   }
   if( max <= 3L )
   	small = TRUE;
   		   
   for( i = 0; i < num_items; i++ )
   {
      if( small )
        strcpy( &blanks[i][0], "   " );
      else
        strcpy( &blanks[i][0], "  ");		/* get 2 blank spaces */
      strcat( &blanks[i][0], items[ i ]);	/* copy the string    */
      do
      {
         strcat( &blanks[i][0], " ");
      }while( strlen( &blanks[i][0] ) < width );
      blank[i] = &blanks[i][0];
   }
   
   obj = Pop_Up( blank, num_items, *default_item, font_size,
                 &butn, &world );
   return( obj );
}
