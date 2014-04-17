/* DRIVERS.C
 * ================================================================
 * Handles the Destination Path Dialog Box
 * DATE: April 16, 1992
 */
#include <alt\gemskel.h>
#include <alt\vdikeys.h>
#include <gemlib.h>
#include <string.h>

#include "country.h"
#include "setup.h"
#include "text.h"
#include "gemskel.h"
#include "handlers.h"
#include "menubind.h"

/* DEFINES
 * ================================================================
 */


/* EXTERNS
 * ================================================================
 */


/* PROTOTYPES
 * ================================================================
 */
int	driver_dialog( void );
void	SetDriverWindow( void );
int	driver_handler( void );
void	driver_redraw( int *msg );

void	FillPNode( char *cptr, int count );
void	SetPrinterMenu( void );


/* GLOBALS
 * ================================================================
 */



/* FUNCTIONS
 * ================================================================
 */


/* Driver_Dialog()
 * ================================================================
 */
int
driver_dialog( void )
{
   int flag;
   static int sflag = FALSE;

   /* Setup the Printer Menu */
   if( !sflag )
   {
      sflag = TRUE;
      SetPrinterMenu();
   }
   else
   {
      menu_icheck( ad_submenu, SNONE + gl_printer, 0 );
      menu_icheck( ad_submenu, SNONE, 1 );
      gl_printer = 0;
   }

   ActiveTree( ad_driver );   
   ObString( PBUTTON ) = anone;

   SetDriverWindow();

   flag = driver_handler();
   return( flag );
}


/* SetDriverWindow()
 * ================================================================
 */
void
SetDriverWindow()
{
      SetNewDialog( ad_driver );
}


/* driver_handler()
 * ================================================================
 */
int
driver_handler( void )
{
    int   msg[8];
    int   button;
    int   done;
    GRECT clip;
    int   dummy;
    MENU  Menu;
    MENU  MData;
    GRECT rect;

    done = FALSE;
    do
    {
      button = xform_do( ad_tree, 0, msg );

      switch( button )
      {
	 case DSETUP:   done = TRUE;
			Deselect( DSETUP );
			break;

	 case DEXIT:    CheckExit();
			deselect( ad_tree, DEXIT );
			break;
/*
	 case PMETA:
	 case PMETA2: 	gl_meta ^= 1;
			if( gl_meta )
			{
		          objc_xywh( ad_driver, PMETA2, &clip );
			  msg[3] = wid;
			  msg[4] = clip.g_x;
			  msg[5] = clip.g_y;
			  msg[6] = clip.g_w;
			  msg[7] = clip.g_h;
        		  driver_redraw( msg );
			}
			else
			  ObjcDraw( ad_driver, PMETA2, MAX_DEPTH, NULL );
		        evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
			break;

	 case PMEM:
	 case PMEM2:	gl_mem ^= 1;
			if( gl_mem )
			{
		          objc_xywh( ad_driver, PMEM2, &clip );
			  msg[3] = wid;
			  msg[4] = clip.g_x;
			  msg[5] = clip.g_y;
			  msg[6] = clip.g_w;
			  msg[7] = clip.g_h;
        		  driver_redraw( msg );
			}
			else
			  ObjcDraw( ad_driver, PMEM2, MAX_DEPTH, NULL );
		        evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
			break;
*/
	 case PBUTTON:  select( ad_driver, PBUTTON );
		        evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
			select( ad_driver, PTITLE );

			objc_xywh( ad_driver, PBUTTON, &rect );
			Menu.mn_tree   = ad_submenu;
			Menu.mn_menu   = ROOT;
			Menu.mn_item   = SNONE + gl_printer;
			Menu.mn_scroll = FALSE;	
			if( menu_popup( &Menu, rect.g_x, rect.g_y, &MData ))
			{
			   menu_icheck( ad_submenu, SNONE + gl_printer, 0 );
			   gl_printer = MData.mn_item - SNONE;
			   menu_icheck( ad_submenu, SNONE + gl_printer, 1 );
			   if( gl_printer )
			   {
		     	      ObString( PBUTTON ) = MenuNode[ gl_printer ].name;
			   }
			   else
			     ObString( PBUTTON ) = anone;
			}
			deselect( ad_driver, PTITLE );
			Deselect( PBUTTON );
			objc_xywh( ad_driver, PBUTTON, &rect );
			rect.g_x -= 1;
			rect.g_w += 2;
			ObjcDraw( ad_driver, PBUTTON, MAX_DEPTH, &rect );
			break;

	 default: if( button == NIL )
		  {
		     switch( msg[0] )
		     {
			case  WM_REDRAW: driver_redraw( msg );
					 break;

		        case  WM_CLOSED: return( FALSE );
					 break;

			case  CT_KEY:    if( msg[3] == K_F10 )
					   CheckExit();
					 break;
			default:
				 break;
		     }
		  }
		  break;
      }
    }while( !done );
    return( TRUE );
}


/* driver_redraw()
 * ================================================================
 */
void
driver_redraw( int *msg )
{
   GRECT area;
   GRECT rect;
   int   clip[4];

   area.g_x = msg[4];
   area.g_y = msg[5];
   area.g_w = msg[6];
   area.g_h = msg[7];

   graf_mouse( M_OFF, 0L );
   wind_get( msg[3], WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );

   while( rect.g_w && rect.g_h )
   {
     if( rc_intersect( &area, &rect ) )
     {
	 rc_2xy( &rect, clip );
	 vs_clip( vhandle, 1, clip );

	 /* Redraw Meta Driver */
#if 0
	 if( gl_meta )
	   do_cross_draw( ad_driver, PMETA2 );

	 /* Redraw Memory Driver */
	 if( gl_mem )
	   do_cross_draw( ad_driver, PMEM2 );	 
#endif
     }
     wind_get( msg[3], WF_NEXTXYWH,&rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );
   }
   vs_clip( vhandle, 0, clip );
   graf_mouse( M_ON, 0L );
}


/* FillPNode()
 * ================================================================
 */
void
FillPNode( char *cptr, int count )
{
    int  index;
    char *ptr;
    int  length;
    int  i;

    index = count + 1;
    ptr = strchr( cptr, ',' );

    /* Get the filename */
    strcpy( MenuNode[ index ].fname, ptr+1 );
    *ptr = '\0';
    
    /* Get the button name */
    strcpy( MenuNode[ index ].name, cptr );

    /* Get the menu name */
    strcpy( MenuNode[ index ].mname, "  " );
    strcat( MenuNode[ index ].mname, cptr );
    
    length = (int)strlen( MenuNode[ index ].mname );
    for( i = length; i < 20; i++ )
    {
	strcat( MenuNode[ index ].mname, " " );
    }
}



/* SetPrinterMenu()
 * ================================================================
 */
void
SetPrinterMenu( void )
{
     int i;
     int obj;

     ActiveTree( ad_submenu );
     menu_icheck( ad_submenu, SNONE, 1 );

     for( i = 0; i < gl_num_printers; i++ )
     {
	obj = i + SNONE + 1;
	ObString( obj ) =  MenuNode[i + 1].mname;
     }

     for( i = SLAST; i > obj; i-- )
     {
	objc_delete( ad_submenu, i );
	ObH( ROOT ) -= gl_hchar;
     }
}
