/* ===================================================================
 * FILE: CUSTOM.C
 * ===================================================================
 * DATE: November 24, 1992
 *	 January  15, 1993 Write the assign.sys out immediately for
 *			   a delete device.
 * 
 * DESCRIPTION: DRIVERS ACC
 *
 * This file handles the initializing and button management
 * for the custom driver handling dialog box.
 *
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 * ===================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
#include <linea.h>

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
#include "device.h"
#include "modify.h"


/* STRUCTURES
 * ===================================================================
 */
struct foobar {
	WORD	dummy;
	WORD	*image;
	};



/* EXTERN
 * ===================================================================
 */
extern int AES_Version;



/* PROTOTYPES
 * ===================================================================
 */
void	DoCustom( void );
int	handle_custom( int button, WORD *msg );
void	DoDeleteDevice( void );
void	InitNames( void );
DEV_PTR FindSelectedDevice( void );




/* DEFINES
 * ===================================================================
 */



/* GLOBALS
 * ===================================================================
 */


/* FUNCTIONS
 * ===================================================================
 */


/* DoCustom()
 * ===================================================================
 */
void
DoCustom( void )
{
   PrevTree = ad_front;
   Reset_Tree( ad_device );

   Disable( DMODIFY );
   Disable( DDELETE );
   NoExit( DMODIFY );
   NoExit( DDELETE );

   device_mover_setup( device_head, device_count,
		  DBASE, DSLIDE, DUP, DDOWN,
		  DLINE0, DLINE11, DLINE, 0, 12 );
    
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}





/* handle_custom()
 * ===================================================================
 */
int
handle_custom( int button, WORD *msg )
{
   int  quit;
   DEV_PTR curptr;
   
   quit   = FALSE;
      
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      button &= 0x7FFF;      
   }   
   
   switch( button )
   {
     case DMENU:    Deselect( DMENU );
		    Reset_Tree( ad_front );     
		    InitNames();
                    mover_setup( hdriver_head, cdriver_count,
		                 FBASE, FSLIDER, FUP, FDOWN,
		  		 LINE0, LINE7, LINEBASE, 0, 8 );
		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
     		    break;

     case DCOVER0:
     case DCOVER1:
     case DCOVER2:
     case DCOVER3:
     case DCOVER4:
     case DCOVER5:
     case DCOVER6:
     case DCOVER7:
     case DCOVER8:
     case DCOVER9:
     case DCOVER10:
     case DCOVER11:
          
     case DUP:
     case DDOWN:
     case DBASE:
     case DSLIDE:   device_mover_button( button );
     		    break;
     		     
     case DDELETE:  DoDeleteDevice();
		    break;

     case DMODIFY:  Deselect( button );
		    curptr = FindSelectedDevice();
		    DoModify( DMODIFY, curptr );
		    break;
		   
     case DADD:	    Deselect( button );
		    DoModify( DADD, ( DEV_PTR )NULL );
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




/* DoDeleteDevice()
 * =======================================================================
 * Delete the Active Device Selected
 */
void
DoDeleteDevice( void )
{
    DEV_PTR curptr;
    
    curptr = FindSelectedDevice();

    if( !curptr )
       return;

    if( form_alert( 1, alert1 ) == 2 )
    {
       XDeselect( tree, DDELETE );
       return;
    }       

    if( DDEV( curptr ) == 21 )
      cur_cdriver = -1;

    DeleteDevice( DDEV( curptr ) );

    /* Re-display mover_setup */
    SetChangeFlag();
    device_mover_setup( device_head, device_count,
		  DBASE, DSLIDE, DUP, DDOWN,
		  DLINE0, DLINE11, DLINE, 0, 12 );
    Objc_draw( tree, DLINE, MAX_DEPTH, NULL );
    XDeselect( tree, DBASE );

    Deselect( DDELETE );
    Undo_Dnodes( device_head, TRUE );
    
    /* WRITE THE ASSIGN.SYS IMMEDIATELY */
    write_assign();
}


/* InitNames()
 * =======================================================================
 * Initializes the Driver Names in the Chooser Tree.
 * The 'tree' must already be set by the calling routine.
 * If we can't find the device or the driver, then 
 * set it to None Selected.
 */
void
InitNames( void )
{
     DEV_PTR temp_device;
     HDEVICE_PTR hptr;
     int     num;

     hptr = NULL;
     num  =  -1;
     temp_device = find_device( 21 );	/* find the printer device */
     if( temp_device )
     {
	num = FindCDriverIndex( DNAME( temp_device ) );
        if( num != -1 )
        {
          hptr = Find_HDevice( num );  /* SET it visually inversed */
        }
     }

     ClearHFLAG( hdriver_head );
     if( !temp_device || !hptr )
     {     
         cur_cdriver = -1;
         
         /* If there IS a driver, just not a FSM_GDOS one, display
          * it anyway. IE: SLM804.SYS, a GDOS driver or META.SYS
          */
         if( temp_device )
         {
           strcpy( driver_text, drivers[ DNAME( temp_device ) ] ); /* Set Name to Show*/
	   strcat( driver_text, NonSpeedo );
           TedText( FPRINTER ) = &driver_text[0];
           
           /* Allow Remove, but not CONFIG */
	   Enable( FREMOVE );
	   MakeExit( FREMOVE );
	   Disable( FCONFIG );
	   NoExit( FCONFIG );         
         }
	 else
	 {
	   /* OTHERWISE, NULL IT and HIDE EVERYTHING...*/
           TedText( FPRINTER ) = &driver_null[0];
	   Disable( FREMOVE );
	   Disable( FCONFIG );
	   NoExit( FREMOVE );
	   NoExit( FCONFIG );         
	 }  
	 return;
     }

     if( temp_device )
     {
	  if( hptr )
	  {
             HFLAG( hptr ) = TRUE;
             cur_cdriver = num;  
             strcpy( driver_text, cdrivers[ num ] ); /* Set Name to Show*/
             TedText( FPRINTER ) = &driver_text[0];

	     Enable( FREMOVE );
	     Enable( FCONFIG );
	     MakeExit( FREMOVE );
	     MakeExit( FCONFIG );
          }   
     }            
}



/* FindSelectedDevice()
 * =======================================================================
 */
DEV_PTR
FindSelectedDevice( void )
{
    int i;
    DEV_PTR xdevice;

    xdevice = NULL;

    for( i = DCOVER0; i <= DCOVER11; i+= 6 )
    {
       if( IsSelected( i ) )
       {
	  xdevice = Device_Slit[ (( i - 5 ) - DLINE0 ) / 6 ];
	  break;
       }
    }
    return( xdevice );
}
