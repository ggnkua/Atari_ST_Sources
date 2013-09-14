/* ===================================================================
 * FILE: OPTIONS.C
 * ===================================================================
 * DATE: December  9, 1992	Combine bitmap and outline fonts
 *       December 15, 1992      Remove Bitmap fonts and devices
 * 
 * DESCRIPTION: Fonts ACC
 *
 * This file handles the options dialog box.
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

#include "path.h"
#include "points.h"
#include "custom.h"
#include "cache.h"
#include "printer.h"
#include "buildwd.h"
#include "status.h"



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
void	DoOptions( void );
int	HandleOptions( int button, WORD *msg );
void	DoWidth( void );




/* DEFINES
 * ===================================================================
 */
#define FRONT_HEIGHT  14



/* GLOBALS
 * ===================================================================
 */
char InstalledText[8];		/* Text strings for font statistics */
char AvailableText[8];
char TotalText[8];
int  MakeWidthFlag;	/* Make or not width Tables.*/
int  OldCurrentWidth;



/* FUNCTIONS
 * ===================================================================
 */


/* DoOptions()
 * ===================================================================
 */
void
DoOptions( void )
{
    PrevTree = ad_front;
    Reset_Tree( ad_options );

    HideObj( OTITLE3 );
    HideObj( OBASE );
    if( Fonts_Loaded )
    {
      ShowObj( OTITLE3 );
      ShowObj( OBASE );
      sprintf( InstalledText, "%3d", installed_count );
      sprintf( AvailableText, "%3d", available_count );
      sprintf( TotalText, "%3d", font_counter );
      TedText( ONUM1 ) = InstalledText;
      TedText( ONUM2 ) = AvailableText;
      TedText( ONUM3 ) = TotalText;
    }

    HideObj( WBACK );
    HideObj( WEXIT );
    HideObj( WCANCEL );
    TedText( OTITLE ) = otitle1;	/* Font Accessory Options */

    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}



/* HandleOptions()
 * ===================================================================
 */
int
HandleOptions( int button, WORD *msg )
{
   int     quit;

   quit   = FALSE;

   
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
      button &= 0x7FFF;
   
   switch( button )
   {
     case OOK:    Deselect( OOK );
		  Reset_Tree( ad_front );     

		  CheckInstallAll( FALSE );
                  mover_setup( installed_list, installed_count,
		                 FBASE, FSLIDER, FUP, FDOWN,
		  		 LINE0, LINE13, LINEBASE, 0, FRONT_HEIGHT );
		  HideObj( LINEBASE );
		  Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
		  ShowObj( LINEBASE );
		  RedrawBase( tree, LINEBASE );
     		  break;

     case OPATH:  Deselect( OPATH );
		  DoPath();
     		  break;
     		  
     case OPOINT: Deselect( OPOINT );
		  DoPoints( ad_options, 0 );
     		  break;		  

     case OCACHE: Deselect( OCACHE );
     		  DoCache();
     		  break;
     		  
     case OWIDTH:  Deselect( OWIDTH );
     		   DoWidth();
     		   break;

     case WEXIT:   Current.Width = (( IsSelected( WON ) ) ? ( TRUE ) : ( FALSE ) );
     		   CacheCheck();
     		   	
     case WCANCEL: Deselect( button );
     		   if( button == WEXIT )
     		   {
     		      if( Current.Width != OldCurrentWidth )
     		   	SetChangeFlag();
     		   }
     		   else
     		     Current.Width = OldCurrentWidth;
     		     
     		   HideObj( WBACK );
     		   HideObj( WEXIT );
     		   HideObj( WCANCEL );
		   RedrawObject( tree, WEXIT );
		   RedrawObject( tree, WCANCEL );
     		   
     		   ShowObj( OBACK1 );
     		   ShowObj( OOK );
/*     		   
		   Objc_draw( tree, OBACK1, MAX_DEPTH, NULL );
 */
 		   /* Force a redraw the size of the WBACK */
 		   RedrawObject( tree, WBACK );		   
		   RedrawObject( tree, OOK );

		   TedText( OTITLE ) = otitle1;	/* Width Table Options */
		   RedrawObject( tree, OTITLE );
     		   break;

     case WBUILD:  Make_Width_Table();
     		   XDeselect( tree, WBUILD );
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
     		     		     if( !IsHidden( WBACK ) )
     		     		     {
				       Current.Width = (( IsSelected( WON ) ) ? ( TRUE ) : ( FALSE ) );     		     
     		      		       if( Current.Width != OldCurrentWidth )
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




/* DoWidth()
 * ===================================================================
 * DIsplay and prompt to turn width tables on/off or build them.
 */
void
DoWidth( void )
{
   HideObj( OBACK1 );
   HideObj( OOK );
   RedrawObject( tree, OOK );
   
   ShowObj( WBACK );
   ShowObj( WEXIT );
   ShowObj( WCANCEL );

   Deselect( WON );
   Deselect( WOFF );
   if( Current.Width )
      Select( WON );
   else
      Select( WOFF );   

   OldCurrentWidth = Current.Width;
         
   TedText( OTITLE ) = otitle2;	/* Width Table Options */
   
   Disable( WBUILD );
   NoExit( WBUILD );
   if( SpeedoFlag )
   {
      Enable( WBUILD );
      MakeExit( WBUILD );
   }
         
   RedrawObject( tree, WBACK );		   
   
   RedrawObject( tree, WEXIT );
   RedrawObject( tree, WCANCEL );
   RedrawObject( tree, OTITLE );
}

