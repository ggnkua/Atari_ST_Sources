/* ===================================================================
 * FILE: DEVICE.C
 * ===================================================================
 * DATE: November 20, 1992
 *	 
 * 
 * DESCRIPTION: DRIVERS ACC
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

#include "country.h"
#include "drvhead.h"
#include "drivers.h"
#include "fixrsh.h"
#include "mainstuf.h"
#include "xform_do.h"
#include "windows.h"
#include "text.h"
#include "fsmio.h"
#include "mover.h"
#include "options.h"
#include "custom.h"
#include "path.h"


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
     long  dummy1;
     int   dummy2;
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
int	 handle_button( int button, WORD *msg );

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
void	 InitDriverNames( void );
long	 get_cookie( void );
void	 ChangeButton( OBJECT *tree, int obj, int flag );

void	 SetDevices( void );



/* DEFINES
 * ===================================================================
 */
#define MENU_WIDTH  27
#define UNDO	0x6100
#define p_cookies   (*(JAR_ENTRY **)0x5a0)
#define COOKIE	    0x46534d43L	/* FSMC */



/* GLOBALS
 * ===================================================================
 */
int     Item;	        /* Index of which item was selected from the menu */
BOOLEAN ChangeFlag;	/* TRUE - Parameter has changed in the ASSIGN.SYS */
char    driver_text[30];/* Text to display driver name                    */
BOOLEAN cookie_flag;	/* TRUE - FSMC COOKIE EXISTS */
int	old_quality;


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
     get_bitpath();
     read_fonts();
     DeleteAssignOld();
     
     Scan_Message( ad_scan, FALSE );
     MF_Restore();

     /* Initialize the Quality Section */     
     Disable( FQUALITY );
     Disable( FDRAFT );
     Disable( FFINAL );

     Deselect( FDRAFT );
     Deselect( FFINAL );

     NoTouchExit( FDRAFT );
     NoTouchExit( FFINAL );
     
     if( cookie_flag )
     {
        Enable( FQUALITY );
        Enable( FDRAFT );
        Enable( FFINAL );
     
        MakeTouchExit( FDRAFT );
        MakeTouchExit( FFINAL );
           
        if( info->quality )
        {
           old_quality = TRUE;
           Select( FFINAL );
        }   
        else
        {
           old_quality = FALSE;
           Select( FDRAFT );
        }   
     }
 
     SetDevices();     
     ClearChangeFlag();
}



/* SetDevices()
 * ====================================================================
 */
void
SetDevices( void )
{
     current_device = device_head;
     InitDriverNames();

     mover_setup( hdriver_head, cdriver_count,
		  FBASE, FSLIDER, FUP, FDOWN,
		  LINE0, LINE7, LINEBASE, 0, 8 );

     MakeExit( FREMOVE );
     Enable( FREMOVE );
     MakeExit( FCONFIG );
     Enable( FCONFIG );
     
     /* If there is no active printer, disable remove and configure */
     if( cur_cdriver == -1 )
     {
        NoExit( FCONFIG );
	Disable( FCONFIG );     
	
	NoExit( FREMOVE );
	Disable( FREMOVE );
     }
     
     
     /* If this is NOT a FSM_GDOS/SPEEDO driver, disable configure */
     if( cur_cdriver != -1 )
     {
        if( strstr( cdrivers[ cur_cdriver ], NonSpeedo ) )
        {
           NoExit( FCONFIG );
           Disable( FCONFIG );
        }
     }

}



/* handle_front()
 * ====================================================================
 */
int
handle_front( int button, WORD *msg )
{
   int  quit;
   int  dclick;
   HDEVICE_PTR curptr;
   DEV_PTR xcurptr;
      
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
     case FSAVE:    /* OK */
     		    quit = TRUE;
     		    Deselect( FSAVE );
     		    CloseWindow();
     		    break;
   
     case FEXIT:    /* CANCEL!!!! - RESTORE ASSIGN.OLD IF POSSIBLE */
     		    quit = TRUE;
     		    Deselect( FEXIT );
     		    
     		    /* Restore ASSIGN.OLD to ASSIGN.SYS */
     		    RenameAssignOld();
     		    
     		    /* Restore the DRAFT/FINAL flag */
     		    if( cookie_flag )
		      info->quality = old_quality;
		      
     		    CloseWindow();
     		    break;
 
 
     case FCONFIG:
     case FPRINTER: if( cur_cdriver != -1 )
     		        DoDrivers( cur_cdriver );
     		    if( button == FCONFIG )    
     		       XDeselect( tree, FCONFIG );    
     		    break;
     		    
     case LINE0:
     case LINE1:
     case LINE2:
     case LINE3:
     case LINE4:
     case LINE5:
     case LINE6:
     case LINE7:     		    
     case FUP:
     case FDOWN:
     case FBASE:
     case FSLIDER:  if( dclick )
     		    {
	              curptr = Active_Slit[ button - First_Obj ];
	              if( !curptr )
	      	          return( quit );	      
     		      DoDrivers( HNAME( curptr ) );
     		    }
     		    else
     		      mover_button( button );
     		    break;

     case FREMOVE:  xcurptr = find_device( 21 );
     		    if( xcurptr )
     		    {
 		       /* ASK if we want it removed first.*/
		       if( form_alert( 1, alert56 ) == 2 )
		       {
		           XDeselect( tree, FREMOVE );
		           return( quit );
		       }       
     		    
     		       SetChangeFlag();
     		       
     		       TedText( FPRINTER ) = &driver_null[0];     
		       Objc_draw( tree, FPRINTER, MAX_DEPTH, NULL );
		       Undo_Fnodes( hdriver_head );
     		       XDeselect( tree, FREMOVE );
     		       cur_cdriver = -1;
		       DeleteDevice( 21 );
     		       
     		       if( !IsDisabled( FCONFIG ) )
		         ChangeButton( tree, FCONFIG, FALSE );
		         
		       if( !IsDisabled( FREMOVE ) )
		         ChangeButton( tree, FREMOVE, FALSE );  
		         
		       /* WRITE ASSIGN.SYS IMMEDIATELY */  
		       write_assign();
     		    }   
     		    break;

     case FCUSTOM:  Deselect( FCUSTOM );
     		    DoCustom();
     		    break;
     		    
     case FSETPATH: XDeselect( tree, FSETPATH );
		    DoFontPath();
		    break;

     case FDRAFT:  if( cookie_flag && !IsSelected( FDRAFT ) )
     	           {
     	              XSelect( tree, FDRAFT );
     	              XDeselect( tree, FFINAL );
     	              
     	              /* Set the DRAFT Quality */
      		      info->quality = 0;
     	           }
     		   break;
     
     case FFINAL:  if( cookie_flag && !IsSelected( FFINAL ) )
     		   {
     		      XSelect( tree, FFINAL );
     		      XDeselect( tree, FDRAFT );
     		      
     		      /* Set the FINAL QUALITY */
		      info->quality = 1;	 
     		   }
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
 * ASSIGN.SYS if necessary.
 */
void
CloseWindow( void )
{
#if 0
   if( cookie_flag )
   {
      ActiveTree( ad_front );
      info->quality = (( IsSelected( FDRAFT ) ) ? ( 0 ) : ( 1 ) );	 
   } 
#endif   
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
     HDEVICE_PTR hptr;
     int     num;
          
     temp_device = find_device( 21 );	/* find the printer device */

     TedText( FPRINTER ) = &driver_null[0];     
     cur_cdriver = -1;
     
     if( temp_device )
     {	/*Found a printer device! */
	num = FindCDriverIndex( DNAME( temp_device ) );
        if( num != -1 )
        {
          hptr = Find_HDevice( num );  /* SET it visually inversed */
          if( hptr )
             HFLAG( hptr ) = TRUE;
             
          cur_cdriver = num;  
          strcpy( driver_text, cdrivers[ num ] ); /* Set Name to Show*/
          TedText( FPRINTER ) = &driver_text[0];
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



/* ChangeButton()
 * ====================================================================
 */
void
ChangeButton( OBJECT *tree, int obj, int flag )
{
   GRECT rect;
   
   /* turn on/off the REMOVE button here too */
   rect = ObRect( obj );
   objc_offset( tree, obj, &rect.g_x, &rect.g_y );

   rect.g_x -= 5;
   rect.g_y -= 5;
   rect.g_w += 10;
   rect.g_h += 10;

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
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
}



