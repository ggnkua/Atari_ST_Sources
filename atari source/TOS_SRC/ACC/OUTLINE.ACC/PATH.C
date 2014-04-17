/* ===================================================================
 * FILE: PATH.C
 * ===================================================================
 * DATE: December  9, 1992	Combine bitmap and outline fonts
 *	 December 15, 1992 	Remove Bitmap and devices
 *	 January  21, 1993	Update Current.FontPath when
 *				switching to directories.
 * 
 * DESCRIPTION: Fonts ACC
 *
 * This file handles the path dialog box.
 *
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 * ===================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
#include <linea.h>
#include <string.h>
#include <stdio.h>

#include "country.h"
#include "fonthead.h"
#include "fonts.h"
#include "mainstuf.h"
#include "text.h"
#include "fsmio.h"
#include "mover.h"
#include "front.h"



/* STRUCTURES
 * ===================================================================
 */


/* EXTERN
 * ===================================================================
 */
extern int AES_Version;



/* PROTOTYPES
 * ===================================================================
 */
void	DoPath( void );
int	HandlePath( int button, WORD *msg );
void	wait_up( void );




/* DEFINES
 * ===================================================================
 */
#define DIR_MAX		30
#define FRONT_HEIGHT  14



/* GLOBALS
 * ===================================================================
 */
char outdirpath[ 128 ];
char outnewpath[ 128 ];
char outbackup[ 128 ];
char outview_path[ 128 ];
int  outdircount;
int  outdirsize;

char underbar[] = "______________________________";


/* FUNCTIONS
 * ===================================================================
 */


/* DoPath()
 * ===================================================================
 */
void
DoPath( void )
{
    Reset_Tree( ad_path );

    /* Setup the Outline Font Path Variables */
    strcpy( outbackup, OutlinePath );
    strcpy( outdirpath, OutlinePath );
    strcat( outdirpath, "\\*.SPD");
    outdircount = 0;
    outdirsize  = ( int )strlen( &outdirpath[0] );
     
    strcpy( outview_path, underbar );
    strncpy( outview_path, outdirpath, min( DIR_MAX, outdirsize ) );
    if( outdirsize > DIR_MAX )
       outview_path[ DIR_MAX - 1 ] = 0xAF;

    TedText( OPATHS ) = outview_path;
    
    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}



/* HandlePath()
 * ===================================================================
 */
int
HandlePath( int button, WORD *msg )
{
   int     quit;
   MRETS   mk;
   long    i;
   int     out;
   
   quit   = FALSE;

   
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
      button &= 0x7FFF;
   
   switch( button )
   {
     case PEXIT:    Deselect( PEXIT );
     		    if( strcmp( OutlinePath, outbackup ) )
     		    {
     		    
	              MF_Save();     
		      Scan_Message( ad_scan, TRUE );
		      /* REad the ACTIVE Fonts Only */
		      read_fonts( FALSE, TRUE );
		      Scan_Message( ad_scan, FALSE );
		      MF_Restore();
		    
     		      SetChangeFlag();
			
		      ActiveTree( ad_front );
                      mover_setup( installed_list, installed_count,
		                   FBASE, FSLIDER, FUP, FDOWN,
		  		   LINE0, LINE9, LINEBASE, 0, FRONT_HEIGHT );
		      ActiveTree( ad_options );

     		      /* Set Current.FontPath to OutlinePath */
		      strcpy( Current.FontPath, OutlinePath );
		    }
		    
		    
		    Reset_Tree( ad_options );
		    /* if the path has changed, we need to clear
		     * the total # of fonts box.
		     */
		    if( !Fonts_Loaded )
		    {
		       HideObj( OTITLE3 );
		       HideObj( OBASE );
		    }   
		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
     		    break;
     		    
     case PCANCEL:  Deselect( PCANCEL );
     		    strcpy( OutlinePath, outbackup );
     		    
		    Reset_Tree( ad_options );     
		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
     		    break;
     		    

     case OLEFT:    XSelect( tree, OLEFT );
     		    do
     		    {
     		       Graf_mkstate( &mk );
     		       if( outdircount )
     		       {
     		         outdircount--;
     		         strncpy( outview_path, &outdirpath[ outdircount ], min( DIR_MAX, outdirsize - outdircount ) );
     		         if( outdircount )
     		       	   outview_path[0] = 0xAE;
     		         if((outdirsize - outdircount ) > DIR_MAX )
     		       	   outview_path[ DIR_MAX - 1 ] = 0xAF;
     		         TedText( OPATHS ) = outview_path;
     		         Objc_draw( tree, OPATHS, MAX_DEPTH, NULL );
     		       }  
     		    }while( mk.buttons );
     		    XDeselect( tree, OLEFT );
     		    break;
     		    
     case ORIGHT:   XSelect( tree, ORIGHT );
     		    do
     		    {
     		       Graf_mkstate( &mk );
  		       if( ( outdirsize > DIR_MAX ) && ((outdircount + DIR_MAX ) < outdirsize ))
  		       {
  		          outdircount++;
  		          strncpy( outview_path, &outdirpath[ outdircount], min( DIR_MAX, outdirsize - outdircount) );
  		          outview_path[0] = 0xAE;
  		          if( (outdirsize - outdircount) > DIR_MAX )
  		          	outview_path[ DIR_MAX - 1 ] = 0xAF;
  		          TedText( OPATHS ) = outview_path;
  		          Objc_draw( tree, OPATHS, MAX_DEPTH, NULL );
  		       }	   		    
     		    }while( mk.buttons );
     		    XDeselect( tree, ORIGHT );
     		    break;
     		    
     case OPATHS:   XSelect( tree, OPATHS );
     		    wait_up();
    		    strcpy( outnewpath, outdirpath );
    		    for( i = strlen( outnewpath ); i && ( outnewpath[i] != '\\'); outnewpath[ i-- ] = '\0' );
     		    out = fsel_name( FALSE, outnewpath, "*.SPD", dtext );
     		    if( ( ( out == A_OK ) || ( out == A_CANCEL )) && ( outnewpath[0] != '\0' ) )
     		    {
	     	         for( i = strlen( outnewpath ); i && ( outnewpath[i] != '\\'); outnewpath[ i-- ] = '\0' );
	     	         
  		         strcpy( outdirpath, outnewpath );
  		         
  		         outnewpath[i] = '\0';	/* Get rid of the '\\' */
  		         strcpy( OutlinePath, outnewpath );
  		         
  		         strcat( outdirpath, "*.SPD" );
  		         outdirsize = (int)strlen( &outdirpath[0] );
  		         strcpy( outview_path, underbar );
  		         strncpy( outview_path, outdirpath, min( DIR_MAX, outdirsize) );
  		         outdircount = 0;
  		         if( outdirsize > DIR_MAX )
  		            outview_path[ DIR_MAX - 1 ] = 0xAF;
		         TedText( OPATHS ) = outview_path;
		    }
		    XDeselect( tree, OPATHS );
		    break;


     default:	 if( button == -1 )
     		 {
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     		     
     		     case AC_CLOSE:  quit = TRUE;
     		     		     break;
     				     		     
     		     case WM_CLOSED: quit = TRUE;
		     		     if( strcmp( OutlinePath, outbackup ) )
     		    		     {
     		    		     	strcpy( Current.FontPath, OutlinePath );
		     		        SetChangeFlag();
     				     }     
     		     		     CloseWindow();
				     break;

		     case CT_KEY:
		     		     break;
     		     default:
     		     		break;
     		   }
     		 }
     		 break;
   }
   return( quit );


}




/* wait_up()
 *==========================================================================
 * Wait for an up button.
 */
void
wait_up( void )
{
   MRETS m;
   
   Evnt_button( 1, 1, 0, &m );
}
