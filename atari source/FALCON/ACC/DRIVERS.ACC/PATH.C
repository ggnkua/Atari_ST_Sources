/* FILE:  PATH.C
 * =======================================================================
 * DATE:  December 1, 1992
 *	  January 15, 1993 When changing the path, write the assign.sys
 *			   imediately.
 *
 * DESCRIPTION: Handle the Font Path Setting
 *
 * INCLUDE FILE: path.h
 */



/* INCLUDE FILES
 * =======================================================================
 */
#include <sys\gemskel.h> 
#include "country.h"

#include "device.h"
#include "drvhead.h"
#include "mainstuf.h"
#include "fsmio.h"
#include "mover.h"
#include "text.h"
#include "drivers.h"


/* STRUCTURES
 * ========================================================================
 */
struct foobar {
	WORD	dummy;
	WORD	*image;
	};




/* PROTOTYPES
 * ========================================================================
 */
void	DoFontPath( void );
int	Path_Button( int button, WORD *msg );
void 	wait_up( void );



/* DEFINES
 * ========================================================================
 */
#define UNDO		0x6100
#define DIR_MAX		28




/* GLOBALS
 * ========================================================================
 */
char dirpath[ 128 ];
char newpath[ 128 ];
char backup[ 128 ];
char view_path[ 128 ];

/*char view_path[ DIR_MAX + 1 ];*/
int  dircount;
int  dirsize;
char underbar[] = "____________________________";




/* FUNCTIONS
 * ========================================================================
 */

/* DoFontPath()
 * ========================================================================
 * Set the Font Path ...
 */
void
DoFontPath( void )
{ 
   PrevTree = ad_front;
   Reset_Tree( ad_path );       	

   /* Font Directory Path */

   strcpy( backup, bitmap_path );
   strcpy( dirpath, bitmap_path );
   strcat( dirpath, "\\*.SYS");

   dircount = 0;
   dirsize = ( int )strlen( &dirpath[0] );
     
   strcpy( view_path, underbar );
   strncpy( view_path, dirpath, min( DIR_MAX, dirsize ) );

   if( dirsize > DIR_MAX )
       view_path[ DIR_MAX - 1 ] = 0xAF;

   TedText( PPATH ) = view_path;
   	                
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}




/* Path_Button()
 * ========================================================================
 * Handle the Button handling for the set font path tree...
 */
int
Path_Button( int button, WORD *msg )
{
  int   quit = FALSE;
  long  i;
  MRETS mk;
  int   out;
  
          
  if( ( button != -1 ) && ( button & 0x8000 ) )
     button &= 0x7FFF;      
     
  switch( button )
  {
     case POK:    XDeselect( tree, POK );
     		  if( strcmp( bitmap_path, backup ) )
     		  {
	            MF_Save();     
		    Scan_Message( ad_scan, TRUE );	
		    read_fonts();
		    Scan_Message( ad_scan, FALSE );
		    MF_Restore();
     		    SetChangeFlag();

		    Reset_Tree( PrevTree );     
		    SetDevices();
		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
		    
		    /* WRITE THE ASSIGN.SYS IMMEDIATELY */
		    write_assign();
		    return( quit );
     		  }  
     		  RestoreMainTree();
     		  break;
   
     case PCANCEL:  Deselect( PCANCEL );
     		    strcpy( bitmap_path, backup );
     		    RestoreMainTree();
     		    break;
     		      		
     case PLEFT:    XSelect( tree, PLEFT );
     		    do
     		    {
     		       Graf_mkstate( &mk );
     		       if( dircount )
     		       {
     		         dircount--;
     		         strncpy( view_path, &dirpath[ dircount ], min( DIR_MAX, dirsize - dircount ) );
     		         if( dircount )
     		       	   view_path[0] = 0xAE;
     		         if((dirsize - dircount ) > DIR_MAX )
     		       	   view_path[ DIR_MAX - 1 ] = 0xAF;
     		         TedText( PPATH ) = view_path;
     		         Objc_draw( tree, PPATH, MAX_DEPTH, NULL );
     		       }  
     		    }while( mk.buttons );
     		    XDeselect( tree, PLEFT );
     		    break;
     		    
     case PRIGHT:   XSelect( tree, PRIGHT );
     		    do
     		    {
     		       Graf_mkstate( &mk );
  		       if( ( dirsize > DIR_MAX ) && ((dircount + DIR_MAX ) < dirsize ))
  		       {
  		          dircount++;
  		          strncpy( view_path, &dirpath[ dircount], min( DIR_MAX, dirsize - dircount) );
  		          view_path[0] = 0xAE;
  		          if( (dirsize - dircount) > DIR_MAX )
  		          	view_path[ DIR_MAX - 1 ] = 0xAF;
  		          TedText( PPATH ) = view_path;
  		          Objc_draw( tree, PPATH, MAX_DEPTH, NULL );
  		       }	   		    
     		    }while( mk.buttons );
     		    XDeselect( tree, PRIGHT );
     		    break;
     		    
     case PPATH:    XSelect( tree, PPATH );
     		    wait_up();
    		    strcpy( newpath, dirpath );
    		    for( i = strlen( newpath ); i && ( newpath[i] != '\\'); newpath[ i-- ] = '\0' );
     		    out = fsel_name( FALSE, newpath, "*.SYS", dtext );
     		    if( ( ( out == A_OK ) || ( out == A_CANCEL )) && ( newpath[0] != '\0' ) )
     		    {
	     	         for( i = strlen( newpath ); i && ( newpath[i] != '\\'); newpath[ i-- ] = '\0' );
	     	         
  		         strcpy( dirpath, newpath );
  		         
  		         newpath[i] = '\0';	/* Get rid of the '\\' */
  		         strcpy( bitmap_path, newpath );
  		         
  		         strcat( dirpath, "*.SYS" );
  		         dirsize = (int)strlen( &dirpath[0] );
  		         strcpy( view_path, underbar );
  		         strncpy( view_path, dirpath, min( DIR_MAX, dirsize) );
  		         dircount = 0;
  		         if( dirsize > DIR_MAX )
  		            view_path[ DIR_MAX - 1 ] = 0xAF;
		         TedText( PPATH ) = view_path;
/*		         
		         Objc_draw( tree, PPATH, MAX_DEPTH, NULL );
 */		         
		    }
		    XDeselect( tree, PPATH );
		    break;
     		  
     default:	if( button == -1 )
     		{
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     		     
     		     case AC_CLOSE:  quit = TRUE;
     		     		     break;
     				     		     
     		     case WM_CLOSED: quit = TRUE;
     		     		     if( strcmp( bitmap_path, backup ) )
     		     		     	SetChangeFlag();
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
