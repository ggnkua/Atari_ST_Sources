/* ===================================================================
 * FILE: FRONT.C
 * ===================================================================
 * DATE: December 7, 1992	Combine outline and bitmap fonts 
 *	 December 15, 1992      Remove Bitmap fonts
 *	 July	   2, 1993 	Added variable to get Speedo Version
 * 
 * DESCRIPTION: Fonts ACC
 *
 * This file handles the front end dialog box.
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
#include "fixrsh.h"
#include "mainstuf.h"
#include "xform_do.h"
#include "windows.h"
#include "text.h"
#include "fsmio.h"
#include "mover.h"
#include "inactive.h"
#include "options.h"
#include "points.h"
#include "buildwd.h"
#include "status.h"



/* STRUCTURES
 * ===================================================================
 */
struct foobar {
	WORD	dummy;
	WORD	*image;
	};

typedef struct jar_entry
{
  long	cookie;
  long	value;
}JAR_ENTRY;


struct _INFO
{
     long  cookie; /*should be _SPD*/
     int   version;	/* if version >= 0x0x420, then add 5000 to font ids */
     int   quality;
}*info;


 
/* EXTERN
 * ===================================================================
 */
extern int AES_Version;



/* PROTOTYPES
 * ===================================================================
 */
void	 initialize( void );
int	 handle_front( int button, WORD *msg );

void	 Reset_Tree( OBJECT *tree );
int	 open_vwork( void );
void	 close_vwork( void );

void	 MF_Save( void );
void	 MF_Restore( void );
void	 Scan_Message( OBJECT *Tree, BOOLEAN flag );
void	 RestoreMainTree( void );

void	 ClearChangeFlag( void );
void	 SetChangeFlag( void );
BOOLEAN	 IsChangeFlag( void );

void	 CloseWindow( void );
long	 get_cookie( void );
void	 ChangeButton( OBJECT *tree, int obj, int flag );

void	SetUpFrontEnd( void );
void	MoveToAvailable( void );

void	SaveFiles( void );
void	InstallAllFonts( void );
void	CheckInstallAll( int draw );


/* DEFINES
 * ===================================================================
 */
#define MENU_WIDTH  	32
#define UNDO		0x6100
#define p_cookies   	(*(JAR_ENTRY **)0x5a0)
#define COOKIE	    	0x46534d43L	/* FSMC */
#define SPEEDO_COOKIE 	0x5F535044L
#define ACTIVE	    	0
#define INACTIVE    	1
#define FRONT_HEIGHT  	14



/* GLOBALS
 * ===================================================================
 */
int     Item;	        /* Index of which item was selected from the menu */
BOOLEAN ChangeFlag;	/* TRUE - Parameter has changed in the ASSIGN.SYS */
BOOLEAN cookie_flag;	/* TRUE - FSMC COOKIE EXISTS */
int  SpeedoFlag;	/* TRUE - This is Speedo...  */
int  SpeedoVersion;	/* SpeedoVersion Number    07/02/93 cjg */


/* FUNCTIONS
 * ===================================================================
 */


/* initialize()
 *==========================================================================
 * Initialize the variables and sliders before displaying the resource.
 */
void
initialize( void )
{
     Wind_get( 0, WF_WORKXYWH, ( WARGS *)&desk );
     fsel_init();
     linea_init();


     MF_Save();
     Scan_Message( ad_scan, TRUE );	

     GetExtendSysPath();
     read_fonts( FALSE, FALSE );

     Scan_Message( ad_scan, FALSE );
     MF_Restore();

     SetUpFrontEnd();

     MakeExit( FINSTALL );
     Enable( FINSTALL );
     
     ClearChangeFlag();
     MakeWidthFlag = FALSE;	/* No Width Tables to make*/
}


/* SetUpFrontEnd()
 * ====================================================================
 */
void
SetUpFrontEnd( void )
{
     mover_setup( installed_list, installed_count,
		  FBASE, FSLIDER, FUP, FDOWN,
		  LINE0, LINE13, LINEBASE, 0, FRONT_HEIGHT );
		  
     NoExit( FREMOVE );
     Disable( FREMOVE );

     NoExit( FCONFIG );
     Disable( FCONFIG );
     
}




/* handle_front()
 * ====================================================================
 */
int
handle_front( int button, WORD *msg )
{
   int  quit;
   int  dclick;
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
     case FEXIT:    quit = TRUE;
     		    Deselect( FEXIT );
     		    CloseWindow();
     		    break;
     		    
     case LINE0:
     case LINE1:
     case LINE2:
     case LINE3:
     case LINE4:
     case LINE5:
     case LINE6:
     case LINE7:     		    
     case LINE8:     		    
     case LINE9:
     case LINE10:
     case LINE11: 
     case LINE12:
     case LINE13:   if( dclick )
     		    {
	              curptr = Active_Slit[ button - First_Obj ];
	              if( !curptr )
	      	          return( quit );
		      DoPoints( tree, button );
     		    }
     		    else
     		      mover_button( button, dclick );
     		    break;

     case FUP:
     case FDOWN:
     case FBASE:
     case FSLIDER:  mover_button( button, dclick );
		    break;


     case FREMOVE:  if( IsChanged( installed_list ) )
     		    {  
 		       /* ASK if we want it removed first.*/
		       if( form_alert( 1, alert56 ) == 2 )
		       {
		           XDeselect( tree, FREMOVE );
		           return( quit );
		       }
		       MoveToAvailable();
     		    }   
    		    XDeselect( tree, FREMOVE );
     		    break;

     case FADD:	    Deselect( FADD );
	 	    ClearFnodes( installed_list );
	 	    ClearFnodes( available_list );

	 	    Disable( FREMOVE );
	 	    NoExit( FREMOVE );
	 	    Disable( FCONFIG );
	 	    NoExit( FCONFIG );
 
     	            DoAvailable();
     	            break;


     case FOPTIONS: Deselect( FOPTIONS );
	 	    ClearFnodes( installed_list );
	 	    ClearFnodes( available_list );

	 	    Disable( FREMOVE );
	 	    NoExit( FREMOVE );
	 	    Disable( FCONFIG );
	 	    NoExit( FCONFIG );
	 	    
		    DoOptions();
     		    break;
     		    
		    /* NOTE: Need to prompt for CUSTOM or SCREEN format*/
     case FSAVE:    if( form_alert( 1, alert10 ) == 1 )
     		    {
			SaveFiles();
     		    }   
     		    XDeselect( tree, FSAVE );
     		    break;


     case FCONFIG:  Deselect( FCONFIG );
		    if( DoPoints( ad_front, 0 ) )
		       XDeselect( tree, FCONFIG );
		    break;

     case FINSTALL: InstallAllFonts();
     		    XDeselect( tree, FINSTALL );
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
				        Undo_Fnodes( installed_list, ( FON_PTR )NULL );
		     		     break;
     		     default:
     		     		break;
     		   }
     		 }
     		 else
	           Undo_Fnodes( installed_list, ( FON_PTR )NULL );
     		 break;
   }
   return( quit );

}




/* Reset_Tree()
 *==========================================================================
 * Make the incoming tree the active tree setting the x,y coordinates
 * at the same time.
 */
void
Reset_Tree( OBJECT *xtree )
{
  int x,y;
  
  x = ObX( ROOT );
  y = ObY( ROOT );
  ActiveTree( xtree );
  ObX( ROOT ) = x;
  ObY( ROOT ) = y;
}






/* MF_Save()
 *==========================================================================
 * Save the current mouse image.
 */
void
MF_Save( void )
{
   if( AES_Version >= 0x0320 )
   {
     graf_mouse( 258, 0L );
     graf_mouse( BUSYBEE, 0L );
   }
}



/* MF_Restore()
 *==========================================================================
 * Restore the previously saved mouse image.
 */
void
MF_Restore( void )
{
  if( AES_Version >= 0x0320 )
    graf_mouse( 259, 0L );
}




/* open_vwork()
 *==========================================================================
 * Open the virtual workstation. ( Note that the workstation should
 * be closed after doing whatever you have to do. )
 * OUT: 0 - failed
 *      non-zero = handle
 *      vhandle == new handle tho...
 */
int
open_vwork( void )
{
	int i;
	
	work_in[0] = Getrez() + 2;
	for( i = 1; i < 10; work_in[i++] = 1 );
	work_in[10] = 2;
	vhandle = phys_handle;
	v_opnvwk( work_in, &vhandle, work_out );
	return( vhandle );
}




/* close_vwork()
 *==========================================================================
 * Close the virtual workstation.
 */
void
close_vwork( void )
{
   if( vhandle )
   {
      v_clsvwk( vhandle );
      vhandle = 0;
   }
}


/* Open_Scanning()
 *==========================================================================
 * Displays the dialog box using 'Tree';
 * IN: flag = TRUE  - Display the dialog box.
 *          = FALSE - Generate the Redraw Message
 */
void
Scan_Message( OBJECT *Tree, BOOLEAN flag )
{  
     static GRECT rect;
     static GRECT xrect;
     
     if( flag )
     {
       xrect.g_x = xrect.g_y = 10;
       xrect.g_w = xrect.g_h = 36;
   
       Form_center( Tree, &rect );
       Form_dial( FMD_START, &xrect, &rect );
       Objc_draw( Tree, ROOT, MAX_DEPTH, &rect );
     }
     else
       Form_dial( FMD_FINISH, &xrect, &rect );
}



/* RestoreMaintree()
 * =======================================================================
 * Return from a tree BACK to the previous tree
 */
void
RestoreMainTree( void )
{
   Reset_Tree( PrevTree );     
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}



/************************************************************************
 * SETTIN/CLEARING a flag to see if the assign.sys has changed
 ************************************************************************
 */

/* ClearChangeFlag()
 * =======================================================================
 * Clears the ChangeFlag variable.
 */
void
ClearChangeFlag( void )
{
   ChangeFlag = FALSE;
}


/* SetChangeFlag()
 * =======================================================================
 * Sets the ChangeFlag variable signifying that the ASSIGN.SYS has changed.
 */
void
SetChangeFlag( void )
{
  ChangeFlag = TRUE;
}


/* IsChangeFlag()
 * =======================================================================
 * Returns TRUE/FALSE if the ASSIGN.SYS has been changed. TRUE - YES.
 */
BOOLEAN
IsChangeFlag( void )
{
   return( ChangeFlag );
}



/* CloseWindow()
 * =======================================================================
 * The user has pressed the close window box. Check to see if any
 * parameters have been changed. If so, prompt the user and save the
 * ASSIGN.SYS and EXTEND.SYS if necessary.
 */
void
CloseWindow( void )
{
   if( IsChangeFlag() )
   {
      if( form_alert( 1, alert12 ) == 1 )
      {
	 SaveFiles();
      }
   }
}



/* get_cookie()
 * ====================================================================
 */
long
get_cookie( void )
{
    JAR_ENTRY	*pjar;

    SpeedoFlag    = FALSE;
    SpeedoVersion = 0x0;

    info = ( struct _INFO *)NULL;
    pjar = p_cookies;
    if( !pjar ) return( 0L );
    while( pjar->cookie )
    {
	if( pjar->cookie == COOKIE )
	    info = (struct _INFO *)( pjar->value );
	++pjar;
    }
    cookie_flag = (( info ) ? ( TRUE ) : ( FALSE ));
    if( cookie_flag ) {
       SpeedoFlag = ( info->cookie == SPEEDO_COOKIE );
       SpeedoVersion = info->version;	/* 07/02/93 cjg */
    }
    return( 0L );
}



/* ChangeButton()
 * ====================================================================
 */
void
ChangeButton( OBJECT *tree, int obj, int flag )
{
   if( flag )
   {
       MakeExit( obj );
       Enable( obj );
   }
   else
   {
       NoExit( obj );
       Disable( obj );           
   }
   RedrawObject( tree, obj );
}



/* MoveToAvailable()
 * ====================================================================
 * Move any Installed fonts to the Available List.
 */
void
MoveToAvailable( void )
{
    FON_PTR curptr;
    FON_PTR xcurptr;
    int     index;
            
    curptr = installed_list;

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
     */
    while( curptr )
    {
       /* REMOVE THE FONT TO THE AVAILABLE LIST */
       if( AFLAG( curptr ) )
           SEL( curptr ) = FALSE;
       curptr = FNEXT( curptr );
    }


    /* Now, fix up the linked list for both the
     * available and installed fonts.
     */
    free_arena_links();
    installed_count = build_list( &installed_list, &installed_last, ACTIVE );
    available_count = build_list( &available_list, &available_last, INACTIVE );

    mover_setup( installed_list, installed_count,
		 FBASE, FSLIDER, FUP, FDOWN,
		 LINE0, LINE13, LINEBASE, index, FRONT_HEIGHT );

    RedrawObject( tree, FBASE );
/*    
    Objc_draw( tree, LINEBASE, MAX_DEPTH, NULL );
 */
    RedrawBase( tree, LINEBASE );
        
    SetChangeFlag();

    if( !IsDisabled( FREMOVE ) )
       ChangeButton( ad_front, FREMOVE, FALSE );
    
    if( !IsDisabled( FCONFIG ) )
       ChangeButton( ad_front, FCONFIG, FALSE );
       
    CheckInstallAll( TRUE );
}



/* SaveFiles()
 * ====================================================================
 * Save the ASSIGN.SYS and EXTEND.SYS files.
 */
void
SaveFiles( void )
{
     MF_Save();     		      
     write_extend();
     MF_Restore();
     ClearChangeFlag();

     CachePrompt();

     /* Prompt to user to make width tables if necessary */
     if( MakeWidthFlag )
     {
        if( SpeedoFlag && Current.Width )
        {
          if( form_alert( 1, alertpnt23 ) == 1 )
              Make_Width_Table();
        }    
     }
}





/* InstallAllFonts()
 * ====================================================================
 * Install ALL of the unused fonts immediately.
 */
void
InstallAllFonts( void )
{
   /* Check if the Unused fonts are loaded yet. */
   if( !Fonts_Loaded )
   {
      /* Fonts are not loaded yet. */
      
   }
   else
   {
      /* The fonts are already loaded.*/
      /* Check if there are any to load anyway...*/
      if( !available_count )
      {
         /* NO! There are no more to install! */
         form_alert( 1, nomore );
         ChangeButton( ad_front, FINSTALL, FALSE );
         return;
      }
   }
   
   /* Prompt to Install the Available Fonts? */
   if( form_alert( 1, showall ) == 1 )
   {
      /* If the fonts are not loaded yet, do so..*/
      if( !Fonts_Loaded )
      {
         MF_Save();
         Scan_Message( ad_scan, TRUE );	

         read_fonts( TRUE, FALSE );

         Scan_Message( ad_scan, FALSE );
         MF_Restore();
      }
      
      /* Select all Fonts */
      SelectAllUnusedFonts();
      
      /* And move them...*/
      MoveToInstalled( TRUE );
      SetUpFrontEnd();
      RedrawObject( tree, FCONFIG );
      RedrawObject( tree, FREMOVE );
      
      RedrawObject( tree, FBASE );
/*      
      Objc_draw( tree, LINEBASE, MAX_DEPTH, NULL );
 */
      RedrawBase( tree, LINEBASE );      
   }

   CheckInstallAll( TRUE );    
}



/* CheckInstallAll()
 * ====================================================================
 */
void
CheckInstallAll( int draw )
{
   if( !available_count && Fonts_Loaded )
   {
      if( !IsDisabled( FINSTALL ) )
      {
         if( draw )
            ChangeButton( ad_front, FINSTALL, FALSE );
         else
         {
            Disable( FINSTALL );
            NoExit( FINSTALL );
         }
      }   
   }
   else
   {
      if( IsDisabled( FINSTALL ) )
      {
         if( draw )
            ChangeButton( ad_front, FINSTALL, TRUE );
         else
         {
            Enable( FINSTALL );
            MakeExit( FINSTALL );
         }
      }   
   }
}
