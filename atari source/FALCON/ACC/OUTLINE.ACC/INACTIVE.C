/* ===================================================================
 * FILE: INACTIVE.C
 * ===================================================================
 * DATE: December  9, 1992  Combine BitMap and Outline Fonts
 *	 December 15, 1992  Remove Bitmap fonts and devices
 * 
 * DESCRIPTION: Fonts ACC
 *
 * This file handles the available fonts dialog box.
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
#include "points.h"
#include "options.h"


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
void	DoAvailable( void );
int	HandleAvailable( int button, WORD *msg );
void	MoveToInstalled( int flag );
int	CheckForFontsInDevices( void );
void	AddToScreenDevices( FON_PTR curptr, int flag );
void	DoSelectAll( void );
void	SelectAllUnusedFonts( void );
void	CheckSelectAll( int draw );



/* DEFINES
 * ===================================================================
 */
#define MENU_WIDTH  32
#define UNDO	0x6100
#define ACTIVE	    0
#define INACTIVE    1
#define FRONT_HEIGHT  14
#define INACTIVE_HEIGHT 14



/* GLOBALS
 * ===================================================================
 */


/* FUNCTIONS
 * ===================================================================
 */


/* DoAvailable()
 * ===================================================================
 */
void
DoAvailable( void )
{
    PrevTree = ad_front;
    Reset_Tree( ad_inactive );


    NoExit( IINSTALL );
    Disable( IINSTALL );
    
    NoExit( ICONFIG );
    Disable( ICONFIG );


    /* Read in the UnUsed fonts, if necessary */
    
    if( !Fonts_Loaded )
    {
      MF_Save();
      Scan_Message( ad_scan, TRUE );	

      read_fonts( TRUE, FALSE );

      Scan_Message( ad_scan, FALSE );
      MF_Restore();
    }  

    CheckSelectAll( FALSE );
    
    mover_setup( available_list, available_count,
		 IBASE, ISLIDER, IUP, IDOWN,
		 ILINE0, ILINE13, ILINE, 0, INACTIVE_HEIGHT );
    HideObj( ILINE );		 
    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
    ShowObj( ILINE );
    RedrawBase( tree, ILINE );
}



/* HandleAvailable()
 * ===================================================================
 */
int
HandleAvailable( int button, WORD *msg )
{
   int     quit;
   int     dclick;
   FON_PTR curptr;

   
   dclick = FALSE;  
   quit   = FALSE;
      
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      button &= 0x7FFF;
      dclick = TRUE;
   }   
   
   switch( button )
   {
     case IEXIT:    Deselect( IEXIT );

		    ClearFnodes( installed_list );
		    ClearFnodes( available_list );

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

     case ILINE0:
     case ILINE1:
     case ILINE2:
     case ILINE3:
     case ILINE4:
     case ILINE5:
     case ILINE6:
     case ILINE7:
     case ILINE8:
     case ILINE9:
     case ILINE10:
     case ILINE11:
     case ILINE12:
     case ILINE13:  if( dclick )
     		    {
	              curptr = Active_Slit[ button - First_Obj ];
	              if( !curptr )
	      	          return( quit );	      
		      DoPoints( tree, button );
     		    }
     		    else
     		      mover_button( button, dclick );
     		    break;


     case IUP:
     case IDOWN:
     case IBASE:
     case ISLIDER:  mover_button( button, dclick );
		    break;


     case IINSTALL: if( IsChanged( available_list ) )
     		    {  
 		       /* ASK if we want it install these fonts first.*/
		       if( form_alert( 1, alert58 ) == 2 )
		       {
		           XDeselect( tree, IINSTALL );
		           return( quit );
		       }       
		       MoveToInstalled( FALSE );
     		    }   
    		    XDeselect( tree, IINSTALL );
     		    break;

     case ICONFIG:  Deselect( ICONFIG );
		    if( DoPoints( ad_inactive, 0 ))
		       XDeselect( tree, ICONFIG );
		    break;

     case ISELECT:  DoSelectAll();
		    XDeselect( tree, ISELECT );
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
     		     		     CloseWindow();
				     break;

		     case CT_KEY:    if( msg[3] == UNDO )
				        Undo_Fnodes( available_list, ( FON_PTR )NULL );
		     		     break;
     		     default:
     		     		break;
     		   }
     		 }
     		 else
	           Undo_Fnodes( available_list, ( FON_PTR )NULL );
     		 break;
   }
   return( quit );

}


/* MoveToInstalled()
 * ====================================================================
 * Move any Available fonts to the Installed List.
 * type -> 0 -> USE Available list CALLS
 *      -> 1 -> Skip available list calls
 */
void
MoveToInstalled( int flag )
{
    FON_PTR curptr;
    FON_PTR xcurptr;
    int     index;

    curptr = available_list;

    /* Try to maintain the top node displayed to remain that way if
     * at all possible.
     */
    xcurptr = Active_Slit[ 0 ];
    if( curptr && xcurptr )
    	index = Get_Findex( curptr, xcurptr );

    /* Go through the list looking for selected nodes ( AFLAG == TRUE )
     * and set their SEL() to FALSE.
     * Where SEL == TRUE means installed. and SEL == FALSE means 
     * available.
     * Set MakeWidth Tables flag if moving Outline Fonts TO INSTALLED!
     */
    while( curptr )
    {
       if( AFLAG( curptr ) )
       {
           if( FTYPE( curptr ) == SPD_FONT )
             MakeWidthFlag = TRUE;
           SEL( curptr ) = TRUE;
       }    
       curptr = FNEXT( curptr );
    }


    /* Now, fix up the linked list for both the
     * available and installed fonts.
     */
    free_arena_links();
    installed_count = build_list( &installed_list, &installed_last, ACTIVE );
    available_count = build_list( &available_list, &available_last, INACTIVE );

    /* Prompt to save SYS files */
    SetChangeFlag();

    if( !flag )
    {
       mover_setup( available_list, available_count,
		    IBASE, ISLIDER, IUP, IDOWN,
		    ILINE0, ILINE13, ILINE, index, INACTIVE_HEIGHT );

       RedrawObject( tree, IBASE );
       Objc_draw( tree, ILINE, MAX_DEPTH, NULL );
    
       if( !IsDisabled( IINSTALL ) )
          ChangeButton( ad_inactive, IINSTALL, FALSE );
    
       if( !IsDisabled( ICONFIG ) )
          ChangeButton( ad_inactive, ICONFIG, FALSE );
          
       CheckSelectAll( TRUE );
    }      
}




/* DoSelectAll()
 * ====================================================================
 */
void
DoSelectAll( void )
{
    int  index;
    int  ocount;
    int  unselected;
    
    /* Count Number of Selected Fonts */
    ocount = CountSelectedFonts( available_list, SPD_FONT );
    unselected = available_count - ocount;
    
    if( !unselected )
    {
        form_alert( 1, nosel );
        ChangeButton( ad_inactive, ISELECT, FALSE );
        return;
    }
    
    if( form_alert( 1, selall ) == 1 )
    {
       SelectAllUnusedFonts();
       
       index = Get_Findex( available_list, Active_Slit[0] );

       mover_setup( available_list, available_count,
		    IBASE, ISLIDER, IUP, IDOWN,
		    ILINE0, ILINE13, ILINE, index, INACTIVE_HEIGHT );

       RedrawObject( tree, IBASE );
       Objc_draw( tree, ILINE, MAX_DEPTH, NULL );

       if( IsDisabled( IINSTALL ) )
          ChangeButton( ad_inactive, IINSTALL, TRUE );
    
       if( IsDisabled( ICONFIG ) )
          ChangeButton( ad_inactive, ICONFIG, TRUE );
    }   
    CheckSelectAll( TRUE );
}




/* SelectAllUnusedFonts()
 * ====================================================================
 */
void
SelectAllUnusedFonts( void )
{
   FON_PTR curptr;
   
   curptr = available_list;
   while( curptr )
   {
       if( !SEL( curptr ) )
          AFLAG( curptr ) = TRUE;
       curptr = FNEXT( curptr );          
   }  
}
 
 

/* CheckSelectAll() 
 * ====================================================================
 */
void
CheckSelectAll( int draw )
{
    int  ocount;
    int  unselected;
    
    /* Count Number of Selected Fonts */
    ocount = CountSelectedFonts( available_list, SPD_FONT );
    unselected = available_count - ocount;
    
    /* If we have some unselected available fonts, then enable button */
    if( unselected )
    {
      if( IsDisabled( ISELECT ) )
      {
         if( draw )
            ChangeButton( ad_inactive, ISELECT, TRUE );
         else
         {
            Enable( ISELECT );
            MakeExit( ISELECT );
         }
      }   
         
    }
    else
    {
      /* No more fonts to select, shut it off */
      if( !IsDisabled( ISELECT ) )
      {
         if( draw )
            ChangeButton( ad_inactive, ISELECT, FALSE );
         else
         {
            Disable( ISELECT );
            NoExit( ISELECT );
         }
      }   
    
    }
}
