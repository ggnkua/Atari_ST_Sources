/*==========================================================================
 * FILE: MAINSTUF.C
 *==========================================================================
 * DATE: December 19, 1990
 * DESCRIPTION: Font GDOS - BITMAP Font CPX Manager
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
 
#include "country.h"

#include "choice.h"

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "choice.rsh"
#pragma warn .apt
#pragma warn .rpt

#include "..\cpxdata.h"		   /* Our CPX Data Structures */	
#include "popup.h"
#include "inactive.h"


#include "fonthead.h"
#include "fsmio.h"
#include "mover.h"

#include "path.h"
#include "edit.h"
#include "text.h"


/* PROTOTYPES
 *==========================================================================
 */
CPXINFO	 *cdecl cpx_init( XCPB *Xcpb );
BOOLEAN  cdecl  cpx_call( GRECT *rect );

void	 initialize( void );
void	 Build_Active_Menu( void );
int	 handle_button( int button, WORD *msg );
int	 handle_front( int button, WORD *msg );

void	 Reset_Tree( OBJECT *tree );

int	 open_vwork( void );
void	 close_vwork( void );

void	 MF_Save( void );
void	 MF_Restore( void );
void	 Scan_Message( OBJECT *Tree, BOOLEAN flag );

void	 DeviceUpDown( int button );
void	 SetupDriverFonts( DEV_PTR device );
void	 strip_period( char *text );
void	 ClearDriverFontList( void );
void	 SortDriverFonts( int num );
void	 Remove_Fonts( void );

void	 RestoreMainTree( void );

void	 ClearChangeFlag( void );
void	 SetChangeFlag( void );
BOOLEAN	 IsChangeFlag( void );
 
void	 CloseWindow( void );

void	 InitDriverNames( void );
void	 DoDrivers( void );
long	 get_cookie( void );

/* Main Menu tree routines */
void 	 DoMainMenu( void );
int	 Handle_Menu( int button, WORD *msg );
void	 TurnOnOffRemove( void );



/* DEFINES
 *==========================================================================
 */
#define UNDO	0x6100


typedef struct jar_entry
{
  long	cookie;
  long	value;
}JAR_ENTRY;


struct _INFO
{
     long  dummy1;
     int   dummy2;
     int   quality;
}*info;

#define p_cookies   (*(JAR_ENTRY **)0x5a0)
#define COOKIE	    0x46534d43L	/* FSMC */



/* EXTERNALS
 *==========================================================================
 */
extern int save_vars;		/* Save_vars is where our default data
				 * is stored.
				 */

int errno;			/* When using the itoa() etc libraries
				 * TC uses 'errno' which is a variable
				 * found in TCSTART.S. But, since
				 * we're not including TCSTART.S..well...
				 */

/* GLOBALS
 *==========================================================================
 */
int	contrl[12], intin[128], intout[128], ptsin[128],ptsout[128],
	work_in[12], work_out[57];

int	vhandle;
GRECT	desk;
	 
OBJECT *tree; 
OBJECT *ad_inactive;	/* Outline Tree              */
OBJECT *ad_active;	/* Font GDOS tree            */
OBJECT *ad_scan;	/* scan message tree	     */
OBJECT *ad_path;	/* tree for setting font path*/
OBJECT *ad_edit;	/* tree for editing devices  */
OBJECT *ad_front;	/* tree for FONT dialog      */
OBJECT *ad_menu;	/* tree for main menu dialog */

OBJECT *PrevTree;

XCPB    *xcpb;	        /* XControl Parameter Block   */
CPXINFO cpxinfo;	/* CPX Information Structure  */

int     Item;		/* Index of which item was selected from the menu */
BOOLEAN ChangeFlag;	/* TRUE - Parameter has changed in the ASSIGN.SYS */
char    device_text[3]; /* Text to display device number                  */
char    driver_text[30];/* Text to display driver name                    */

int     amenu_num;	/* Number of active font menu items to display    */
BOOLEAN cookie_flag;	/* TRUE - FSMC COOKIE EXISTS */

		     



/* FUNCTIONS
 *==========================================================================
 */
	


/* cpx_init()
 *==========================================================================
 */			
CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
    xcpb = Xcpb;
    
    if( xcpb->booting )
    {
        return( ( CPXINFO *)TRUE );  
    }    
    else
    {    
      if( !xcpb->SkipRshFix )
           (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                            rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                            rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                            rs_imdope );
      
           
      ad_inactive= ( OBJECT *)rs_trindex[ INACTIVE ];
      ad_active  = ( OBJECT *)rs_trindex[ FONTGDOS ];
      ad_scan    = ( OBJECT *)rs_trindex[ SCANMSG ];
      ad_path    = ( OBJECT *)rs_trindex[ PATH ];
      ad_edit	 = ( OBJECT *)rs_trindex[ EDIT ];
      ad_front   = ( OBJECT *)rs_trindex[ FRONT ];
      ad_menu    = ( OBJECT *)rs_trindex[ MMENU ];
                  
      PrevTree   = ( OBJECT *)NULL;
                            
      /* Initialize the CPXINFO structure */           
      cpxinfo.cpx_call   = cpx_call;
      cpxinfo.cpx_draw   = NULL;
      cpxinfo.cpx_wmove  = NULL;
      cpxinfo.cpx_timer  = NULL;
      cpxinfo.cpx_key    = NULL;
      cpxinfo.cpx_button = NULL;
      cpxinfo.cpx_m1 	 = NULL;
      cpxinfo.cpx_m2	 = NULL;
      cpxinfo.cpx_hook   = NULL;
      cpxinfo.cpx_close  = NULL;

      /* Initialize the DRAFT/FINAL flag based on the cookie */
      Supexec( get_cookie );
      
      return( &cpxinfo );
    }
}




/* cpx_call()
 *==========================================================================
 * IN: GRECT *rect:	Ptr to a GRECT that describes the current work
 *			area of the XControl window.
 *
 * OUT:
 *   FALSE:     The CPX has exited and no more messages are
 *		needed.  XControl will either return to its
 *		main menu or close its windows.
 *		This is used by XForm_do() type CPXs.
 *
 *   TRUE:	The CPX requests that XCONTROL continue to
 *		send AES messages.  This is used by Call-type CPXs.
 */
BOOLEAN
cdecl cpx_call( GRECT *rect )
{
     int  button;
     int  quit = 0;
     WORD msg[8];
     
     ActiveTree( ad_front );
     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;

     initialize();


     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     do
     {
	button = (*xcpb->Xform_do)( tree, 0, msg );

	/* Front Tree Button Handling */
	if( IsActiveTree( ad_front ) )
	{
	    quit = handle_front( button, msg );
	    continue;
	}    
        
	/* MainTree Button Handling */
	if( IsActiveTree( ad_active ) )
	{
	    quit = handle_button( button, msg );
	    continue;
	}    


	/* Inactive Font Button Handling */
	if( IsActiveTree( ad_inactive ))
	{
	    quit = InActive_Button( button, msg );
	    continue;
	}    
	
	/* Font Path Button Handling */
	if( IsActiveTree( ad_path ) )
	{
	    quit = Path_Button( button, msg );
	    continue;
	}
	
	/* Edit Devices Button handling */
	if( IsActiveTree( ad_edit ) )
	{
	    quit = Edit_Button( button, msg );
	    continue;
	}
	

	/* Main Menu Button Handling */
	if( IsActiveTree( ad_menu ) )
	{
	    quit = Handle_Menu( button, msg );
	    continue;
	}
		
     }while( !quit);
     return( FALSE );
}





/* initialize()
 *==========================================================================
 * Initialize the variables and sliders before displaying the resource.
 */
void
initialize( void )
{
     Wind_get( 0, WF_WORKXYWH, ( WARGS *)&desk );

     fsel_init();

     MF_Save();     
     Scan_Message( ad_scan, TRUE );	
     get_bitpath();
     read_fonts();
     Scan_Message( ad_scan, FALSE );
     MF_Restore();

     current_device = device_head;
     InitDriverNames();

     Disable( FQUALITY );
     Disable( FDRAFT );
     Disable( FFINAL );

     Deselect( FDRAFT );
     Deselect( FFINAL );

     if( cookie_flag )
     {
        Enable( FQUALITY );
        Enable( FDRAFT );
        Enable( FFINAL );
        
        if( info->quality )
           Select( FFINAL );
        else
           Select( FDRAFT );
     }
     
     Disable( FPRINTER );
     NoShadow( FPRINTER );
     NoTouchExit( FPRINTER );
     if( cdriver_count )
     {
        Enable( FPRINTER );
        MakeShadow( FPRINTER );
        MakeTouchExit( FPRINTER );
     }
     ClearChangeFlag();
}

 


/* DoActiveFonts()
 * ====================================================================
 */
void
DoActiveFonts( void )
{
     DEV_PTR temp_device;
   
     PrevTree = ad_menu;
     Reset_Tree( ad_active );

     NoExit( REMOVE );
     Disable( REMOVE );

     ClearListFlags();
     
     current_device = temp_device = device_head;
     sprintf( device_text, "%d", DDEV( temp_device ) );
     TedText( XDEVICE ) = &device_text[0];

     strcpy( driver_text, drivers[ DNAME( temp_device )] );
     strip_period( &driver_text[0] );
     TedText( XDRIVER ) = &driver_text[0];

     SetupDriverFonts( temp_device );
     mover_setup( first_font, DFCOUNT( temp_device ),
		  BASE, SLIDER, UP, DOWN,
		  LINE0, LINE5, LINEBASE, 0 );
		  
     if( IsChanged( first_font ) )
     {
       MakeExit( XTRANSFR );
       Enable( XTRANSFR );
     }
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}



/* Build_Active_Menu()
 * ====================================================================
 * Sets the number of active menu items to display.
 */
void
Build_Active_Menu( void )
{
     amenu_num = (( IsChanged( hdptr )) ? ( 3 ) : ( 2 ) );
}


/* handle_front()
 * ====================================================================
 */
int
handle_front( int button, WORD *msg )
{
   int  quit = FALSE;
/*   int  default_item = -1;*/
   
   
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      button &= 0x7FFF;      
   }   
   
   switch( button )
   {
     case FEXIT:    quit = TRUE;
     		    Deselect( FEXIT );
     		    CloseWindow();
     		    break;

     case FOPTIONS: Deselect( FOPTIONS );
     		    DoMainMenu();
     		    break;
     		         		    
     case FPRINTER: DoDrivers();
     		    break;

     case FSAVE:    if( form_alert( 1, alert10 ) == 1 )
     		    {
		      MF_Save();     		      
     		      write_assign();
     		      MF_Restore();
     		      ClearChangeFlag();
     		    }   
     		    deselect( tree, FSAVE );
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

				     /* Want only UNDO */
		     case CT_KEY:    if( msg[3] == UNDO )
		     			Undo_Fnodes( hdptr );
		     		     break;
     		     default:
     		     		break;
     		   }
     		 }
     		 else
		     Undo_Fnodes( hdptr );
     		 break;
   }
   return( quit );

}



/* handle_button()
 * ====================================================================
 * Main Menu Button handling.
 */
int
handle_button( int button, WORD *msg )
{
   int  quit = FALSE;
   int  default_item = -1;
   
   
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      button &= 0x7FFF;      
   }   
   
   switch( button )
   {
     case QUIT:    Deselect( QUIT );
     		   RestoreMainTree();
     		   break;

     case AMENU:   Build_Active_Menu();
		   Item = Pop_Handle( tree, AMENU, amenu_text,
			              amenu_num, &default_item,
       			              IBM, 25 );
   		   switch( Item )
   		   {
   		      case 0: Do_InActiveFonts();
   		   	      break;
   		   	   
   		      case 1: RestoreMainTree();
   		   	      break;

   		      case 2: if( form_alert( 1, alert11 ) == 1 )
   		              {
   		   	         Remove_Fonts();
   		   	         SetChangeFlag();
   		   	      }  
   		   	      break;

   		      default:
   		   	      break;
   		   }
     		   break;

     case REMOVE:  if( form_alert( 1, alert11 ) == 1 )
   		   {
   		      Remove_Fonts();
   		      SetChangeFlag();
   		   }  
     		   else
     		      deselect( tree, REMOVE );
     		   break;
     		        		        		        		   
     case UP:
     case DOWN:
     case BASE:
     case SLIDER:
     case LINE0:
     case LINE1:
     case LINE2:
     case LINE3:
     case LINE4:
     case LINE5: mover_button( button );
     		 break;

     case XUP:
     case XDOWN: DeviceUpDown( button );
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

				     /* Want only UNDO */
		     case CT_KEY:    if( msg[3] == UNDO )
		     			Undo_Fnodes( hdptr );
		     		     break;
     		     default:
     		     		break;
     		   }
     		 }
     		 else
		     Undo_Fnodes( hdptr );
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
   graf_mouse( BUSYBEE, 0L );
}



/* MF_Restore()
 *==========================================================================
 * Restore the previously saved mouse image.
 */
void
MF_Restore( void )
{
  graf_mouse( ARROW, 0L );
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
	vhandle = xcpb->handle;
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



/* DeviceUpDown()
 * =======================================================================
 * Handles the up/down buttons on displaying an active driver and device.
 */
void
DeviceUpDown( int button )
{
   MRETS   mk;
   DEV_PTR olddev;
   
   select( tree, button );
   do
   {
      olddev = current_device;
      
      if( button == XUP )
      {
         if( DNEXT( current_device ) )
             current_device = DNEXT( current_device );
      }
      else
      {
         if( DPREV( current_device ) )
             current_device = DPREV( current_device );
      }

      if( olddev != current_device )
      {
        sprintf( device_text, "%d", DDEV( current_device ) );
        TedText( XDEVICE ) = &device_text[0];
        
        strcpy( driver_text, drivers[ DNAME( current_device )] );
	strip_period( &driver_text[0] );
        TedText( XDRIVER ) = &driver_text[0];
        
        SetupDriverFonts( current_device );

        mover_setup( first_font, DFCOUNT( current_device ),
		     BASE, SLIDER, UP, DOWN,
		     LINE0, LINE5, LINEBASE, 0 );

        Objc_draw( tree, XDEVICE, MAX_DEPTH, NULL );
        Objc_draw( tree, XDRIVER, MAX_DEPTH, NULL );
	Objc_draw( tree, LINEBASE, MAX_DEPTH, NULL );
	Objc_draw( tree, BASE, MAX_DEPTH, NULL );	

	TurnOnOffRemove();
      }  
      Evnt_timer( 100L );
      
      Graf_mkstate( &mk );
   }while( mk.buttons );
   
   deselect( tree, button );
}




/* SetupDriverFonts()
 * =======================================================================
 * When we display the fonts for a driver, they must be in an array
 * with a linked list in a FON structure. This will copy the
 * fonts from the device structure and move them temporarily into the
 * new structure.
 */
void
SetupDriverFonts( DEV_PTR device )
{
   FON_PTR t_fon;
   FON_PTR x_fon;
   int     index;

   ClearDriverFontList();       /* really temp_fon[] */

   for( index = 0; index < DFCOUNT( device ); index++ )
   {
      t_fon = DFONT( device )[ index ];
      x_fon = &temp_fon[ index ];
      *x_fon = *t_fon;
      FNEXT( x_fon ) = FPREV( x_fon ) = ( FON_PTR )NULL;
      AFLAG( x_fon ) = SFLAG( x_fon ) = FALSE;     
   }
   SortDriverFonts( DFCOUNT( device ) );
   first_font = ( FON_PTR )( DFCOUNT( device ) ? ( &temp_fon[0] ) : ( NULL ) );
}



/* strip_period()
 * =======================================================================
 * Takes a filename and erases the '.ext'
 * This is used to display just the driver name without the extension.
 */
void
strip_period( char *text )
{
   long i;

   for( i = strlen( text ); i && ( text[i] != '.'); text[i--] = '\0' );
   text[i] = '\0';
}



/* ClearDriverFontList()
 * =======================================================================
 * Clears out and initializes the temp_fon[] array which is used to
 * display the fonts for a driver.
 */
void
ClearDriverFontList( void )
{
   FON_PTR  x_fon;
   int index;
   
   /* Clear out the pointers in the temporary font name array */
   for( index = 0; index < MAX_FONTS; index++ )
   {
       x_fon = &temp_fon[ index ];
       strcpy( FNAME( x_fon ), "" );
       strcpy( FFNAME( x_fon ), "" );
       FNEXT( x_fon ) = FPREV( x_fon ) = ( FON_PTR )NULL;
       AFLAG( x_fon ) = SFLAG( x_fon ) = FALSE;   
   }

}




/* SortDriverFonts()
 *==========================================================================
 * Sort the Driver Font Names ( smallest to largest alphabetically )
 */
void
SortDriverFonts( int num )
{
   int i,j;
   FON_PTR cur_ptr;
   FON_PTR a_ptr, b_ptr;
   BOOLEAN found;
 
   if( !num )	/* if there are no fonts, don't do anything...*/
       return;
          
   cur_ptr = &temp_fon[ MAX_FONTS ];	/* Get a temporary buffer...just use the end */

   for( i = 1; i < num; i++ )
   {
      a_ptr = &temp_fon[ i ];
      b_ptr = &temp_fon[ i - 1 ];
      if( strcmp( FNAME( a_ptr ), FNAME( b_ptr ) ) < 0 )
      {
         j = i;
         
         /* Save to our temp buffer */
	 strcpy( FFNAME( cur_ptr ), FFNAME( a_ptr ) );
         strcpy( FNAME( cur_ptr ), FNAME( a_ptr ) );
         
         found = FALSE;
         while( !found )
         {
             j = j - 1;
             a_ptr = &temp_fon[ j ];
             b_ptr = &temp_fon[ j + 1 ];
             strcpy( FFNAME( b_ptr ), FFNAME( a_ptr ) );
             strcpy( FNAME( b_ptr ), FNAME( a_ptr ) );
             
             if( !j )
                found = TRUE;
             else
             {
                 a_ptr = &temp_fon[ j - 1 ];
		   found = ( strcmp( FNAME( a_ptr ), FNAME( cur_ptr ) ) <= 0 );
             }   
         }
         
         a_ptr = &temp_fon[ j ];
         strcpy( FFNAME( a_ptr ), FFNAME( cur_ptr ) );
         strcpy( FNAME( a_ptr ), FNAME( cur_ptr ) );
      }
   }

   /* Now, fix up the linked list...*/
   for( i = 0; i < num; i++ )
   {
     if( ( i - 1 ) >= 0 )
     {
     	a_ptr = &temp_fon[ i ];
        b_ptr = &temp_fon[ i - 1 ];
        FNEXT( b_ptr ) = a_ptr;
        FPREV( a_ptr ) = b_ptr;
     }
   }  
}




/* Remove_Fonts()
 * =======================================================================
 * Remove the selected fonts from the linked list.
 * Update the driver's font list and redraw.
 * 
 * We do this by 1) clearing the Devices font pointer list.
 *               2) Go through temp_fon[] looking for the fonts that
 *		    have real strings ( no blanks ) and do not have their
 *		    AFLAG set.
 *		 3) So, we take the font name, look for the font in 
 *		    the font list, get the pointer and shove this into
 *		    the device font pointer list.
 */
void
Remove_Fonts( void )
{
   int     count;
   FON_PTR t_fon;
   FON_PTR x_fon;
   int     i;
   
   if( IsChanged( hdptr ) )	/* Make sure we have fonts to deselect */
   {
      count = DFCOUNT( current_device );   
 
      for( i = 0; i < count; i++ )
      {
         x_fon = &temp_fon[i];
         if( AFLAG( x_fon ) )
         {
	    t_fon = FindFont( x_fon );
            if( t_fon != ( FON_PTR ) NULL )
            {
		remove_from_device( current_device, t_fon );            
            }
         }
      }
      SetupDriverFonts( current_device );
      mover_setup( first_font, DFCOUNT( current_device ),
		   BASE, SLIDER, UP, DOWN,
		   LINE0, LINE5, LINEBASE, 0 );
      Objc_draw( tree, LINEBASE, MAX_DEPTH, NULL );
      Objc_draw( tree, BASE, MAX_DEPTH, NULL );
   }
   deselect( tree, REMOVE );	/* clear the button...*/
   TurnOnOffRemove();
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
 * ASSIGN.SYS if necessary.
 */
void
CloseWindow( void )
{
   if( IsChangeFlag() )
   {
      if( form_alert( 1, alert12 ) == 1 )
      {
	 write_assign();                   
      }
   }

   if( cookie_flag )
   {
      ActiveTree( ad_front );
      info->quality = (( IsSelected( FDRAFT ) ) ? ( 0 ) : ( 1 ) );	 
   }     
}



/* InitDriverNames()
 * =======================================================================
 * Initializes the Driver Names in the Chooser Tree.
 * The 'tree' must already be set by the calling routine.
 */
void
InitDriverNames( void )
{
     DEV_PTR temp_device;
     int     num;
          
     temp_device = find_device( 21 );	/* find the printer device */

     TedText( FPRINTER ) = &driver_null[0];     
     TedText( FPAPER )   = &data_null[0];
     TedText( FREZ )     = &data_null[0];
     TedText( FDPI )     = &data_null[0];

     if( temp_device )
     {	/*Found a printer device! */
	num = FindCDriverIndex( DNAME( temp_device ) );
        if( num != -1 )
        {
          strcpy( driver_text, cdrivers[ num ] );
          TedText( FPRINTER ) = &driver_text[0];
          
          TedText( FPAPER )   = &cdriver_data[ num ].pagesize[0];
          TedText( FREZ )     = &cdriver_data[ num ].frez[0];
          TedText( FDPI )     = &cdriver_data[ num ].fdpi[0];
        }
     }
}




/* DoDrivers()
 * =======================================================================
 * Handles the FPrinter Popup menu.
 */
void
DoDrivers( void )
{
   int 	   i;
   int 	   Item;
   int 	   temp;
   DEV_PTR temp_device;

   /* If there are no drivers to list, don't popup the menu 
    * or if there is only one driver.
    */
   if( cdriver_count < 2 )
        return;
              
   for( i = 0; i < cdriver_count; i++ )
        CurNames[i] = &cdrivers[i][0];

   temp_device = find_device( 21 );	/* find the printer device */
   if( temp_device )
       cur_cdriver = FindCDriverIndex( DNAME( temp_device ));
   else
       cur_cdriver = -1;
       
   temp = cur_cdriver;
   Item = Pop_Handle( tree, FPRINTER, CurNames, cdriver_count, &cur_cdriver, IBM, 28 );
   if( Item != -1 )
   {
      cur_cdriver = Item;
      strcpy( driver_text, cdrivers[ Item ] );
      TedText( FPRINTER ) = &driver_text[0];

      TedText( FPAPER ) = &cdriver_data[ Item ].pagesize[0];
      TedText( FREZ )   = &cdriver_data[ Item ].frez[0];
      TedText( FDPI )   = &cdriver_data[ Item ].fdpi[0];

      Objc_draw( tree, FPRINTER, MAX_DEPTH, NULL );

      Objc_draw( tree, FPAPER, MAX_DEPTH, NULL );
      Objc_draw( tree, FREZ, MAX_DEPTH, NULL );
      Objc_draw( tree, FDPI, MAX_DEPTH, NULL );
      
      if( !temp_device )
      {
        temp_device = AddNewDevice( 21 );
        if( temp_device )
        {
          /* found a slot and added it to the device linked list array. */
	  DNAME( temp_device ) = cdriver_array[ Item ];         
	}  
      }
      else
        DNAME( temp_device ) = cdriver_array[ Item ];   
        
      if( temp_device && ( cur_cdriver != temp ) )
              SetChangeFlag();   
   }
}



/* get_cookie()
 * ====================================================================
 */
long
get_cookie( void )
{
    JAR_ENTRY	*pjar;

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
    return( 0L );
}



/* Main Menu Routines
 * ====================================================================
 */


/* DoMainMenu()
 * ========================================================================
 */
void 
DoMainMenu( void )
{
   PrevTree = ad_front;
   Reset_Tree( ad_menu );
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}



 
/* Handle_Menu() 
 * ====================================================================
 */
int
Handle_Menu( int button, WORD *msg )
{
   int  quit = FALSE;


   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
      button &= 0x7FFF;      
   
   switch( button )
   {
     case MTOP:     Deselect( MTOP );
		    Reset_Tree( ad_front );     
		    InitDriverNames();
		    
		    if( IsActiveTree( ad_front ))
   		    {
		       Disable( FPRINTER );
		       NoShadow( FPRINTER );
		       NoTouchExit( FPRINTER );
		       if( cdriver_count )
		       {
		          Enable( FPRINTER );
		          MakeShadow( FPRINTER );
		          MakeTouchExit( FPRINTER );
		       }
		    }
		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
     		    break;

     case MDRIVER:  Deselect( MDRIVER );
     		    DoEditDevices();
     		    break;
     		   
     case MFONT:   Deselect( MFONT );
     		   DoActiveFonts();
     		   break;
     		   
     case MPATH:   Deselect( MPATH );
     		   DoFontPath();
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


void
TurnOnOffRemove( void )
{
   GRECT rect;
   
   /* turn on/off the REMOVE button here too */
   rect = ObRect( REMOVE );
   objc_offset( tree, REMOVE, &rect.g_x, &rect.g_y );

   rect.g_x -= 3;
   rect.g_y -= 3;
   rect.g_w += 6;
   rect.g_h += 6;

   if( IsChanged( first_font ) )
   {
       MakeExit( REMOVE );
       Enable( REMOVE );
   }
   else
   {
       NoExit( REMOVE );
       Disable( REMOVE );           
   }
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
}



