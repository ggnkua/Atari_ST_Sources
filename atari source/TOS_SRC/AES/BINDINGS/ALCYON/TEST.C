/* TEST.C
 * ================================================================
 * DESCRIPTION: Test program for heirarchical menus linked in
 *		with the menu code.
 */

/* INCLUDES
 * ================================================================
 */
#include <portab.h>
#include <machine.h>
#include <taddr.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <vdibind.h>
#include <osbind.h>

#include "mn_tools.h"
#include "test.h"
#include "struct.h"

/* DEFINES
 * ================================================================
 */
#define THEACTIVE       2


/* GLOBALS
 * ================================================================
 */

/* VDI Variables */
WORD	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
WORD	vhandle, xres, yres;
WORD	phys_handle;

/* AES variables */
WORD	gl_apid, gl_hchar, gl_wchar, gl_hbox, gl_wbox;

/* OBJECT Tree pointers */
OBJECT *ad_tree;
OBJECT *ad_box;
OBJECT *ad_country;
OBJECT *ad_other;
OBJECT *ad_menubar;
OBJECT *ad_extra;

GRECT   rect;

/* Current starting value for submenus */
WORD Cur1 = 1;
WORD Cur2 = 1;
WORD Cur3 = 2;
WORD Cur4 = QUOTE1;
WORD Cur5 = MICKEY;
char xtext[] = "[1][  ][OK]";

OBJECT *ptree;
int    pmenu;
int    pscroll;


int msg[8];
OBJECT  **ptr;
LONG    value;
MENU    Menu;
MENU    MData;
MN_SET  TData;

/* Functions
 * ================================================================
 */

/* MAIN()
 * ================================================================
 */
VOID
main( VOID )
{
	OBJECT  *tree;
	WORD    i;
	WORD    button;
	GRECT   box;
	GRECT   xrect;
        WORD    tempx;

        GRECT   rect;
        MRETS   mk;
	
        WORD    ptitle, pitem, pmenu;
	OBJECT  *ptree;
        BOOLEAN flag;
	BOOLEAN done;
	WORD    dummy;

        WORD	xvalue;

        
	appl_init();

	phys_handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );

        graf_mouse( ARROW, 0L );
        
        rsrc_load( "TEST.RSC" );

        rsrc_gaddr( 0, MENU1, &ad_tree );
	rsrc_gaddr( 0, BIGBOX, &ad_box );
        rsrc_gaddr( 0, COUNTRY, &ad_country );
	rsrc_gaddr( 0, OTHER, &ad_other );
        rsrc_gaddr( 0, MENUBAR, &ad_menubar );
	rsrc_gaddr( 0, TREE6, &ad_extra );

	ad_other[ ROOT ].ob_x = ad_other[ ROOT ].ob_y = 0;
#if 0
	/* test setting delay and height variables */
	TData.Delay  = 100L;
	TData.Drag   = 10000L;
	TData.Delay  = 250L;
	TData.Speed  = 0L;
	TData.Height = 16;
	menu_settings( 1, &TData );
#endif

	/* test attaching submenus */
	Menu.mn_tree   = ad_country;
	Menu.mn_menu   = ROOT;
        Menu.mn_item   = Cur2;
	Menu.mn_scroll = TRUE;
	menu_attach( 1, ad_tree, DELETE, &Menu );

	Menu.mn_tree   = ad_other;
	Menu.mn_menu   = DISNEY;
        Menu.mn_item   = MICKEY;
	Menu.mn_scroll = FALSE;
	menu_attach( 1, ad_tree, FLOPPY, &Menu );

	Menu.mn_tree   = ad_other;
	Menu.mn_menu   = MODEM;
        Menu.mn_item   = Cur3;
	Menu.mn_scroll = FALSE;
        menu_attach( 1, ad_country, 5, &Menu );

	Menu.mn_tree   = ad_other;
	Menu.mn_menu   = DISNEY;
        Menu.mn_item   = MICKEY;
	Menu.mn_scroll = FALSE;
        menu_attach( 1, ad_country, 1, &Menu );

	Menu.mn_tree   = ad_other;
	Menu.mn_menu   = DISNEY;
        Menu.mn_item   = MICKEY;
	Menu.mn_scroll = FALSE;
	menu_attach( 1, ad_country, ARKANSAS, &Menu );

	Menu.mn_tree   = ad_other;
	Menu.mn_menu   = QUOTES;
        Menu.mn_item   = Cur4;
	Menu.mn_scroll = FALSE;
	menu_attach( 1, ad_other, 5, &Menu );

	Menu.mn_tree   = ad_country;
	Menu.mn_menu   = ROOT;
        Menu.mn_item   = Cur2;
	Menu.mn_scroll = TRUE;
	menu_attach( 1, ad_menubar, PASTE, &Menu );

	Menu.mn_tree   = ad_country;
	Menu.mn_menu   = ROOT;
        Menu.mn_item   = Cur2;
	Menu.mn_scroll = TRUE;
	menu_attach( 1, ad_menubar, FNEW, &Menu );

        menu_icheck( ad_tree, Cur1, 1 );
	menu_icheck( ad_country, Cur2, 1 );
	menu_icheck( ad_other, Cur3, 1 );
	menu_icheck( ad_other, Cur4, 1 );
	menu_icheck( ad_other, Cur5, 1 );

	ActiveTree( ad_box );

        form_center( ad_box, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );

	ObX( ROOT ) = rect.g_x;
        xrect = ObRect( TITLE1 );
        objc_offset( ad_box, TITLE1, &xrect.g_x, &xrect.g_y );
	tempx = xrect.g_x;
        xrect.g_x = (( xrect.g_x + 7 )/8 ) * 8;
	rect.g_x = rect.g_x + ( xrect.g_x - tempx );
	ObX( ROOT ) = rect.g_x;
	rect.g_x -= 3;

	form_dial( FMD_START, rect.g_x, rect.g_y, rect.g_w, rect.g_h,
			      rect.g_x, rect.g_y, rect.g_w, rect.g_h );
	objc_draw( ad_box, ROOT, MAX_DEPTH, rect.g_x, rect.g_y,
					    rect.g_w, rect.g_h );

        do
        {
	  ActiveTree( ad_box );
          button = form_do( ad_box, 0L );

	  switch( button )
	  {
	    case TITLE1:
			 box = ObRect( TITLE1 );
			 objc_offset( ad_box, TITLE1, &box.g_x, &box.g_y );
			 
			 Menu.mn_tree   = ad_tree;
			 Menu.mn_menu   = ROOT;
			 Menu.mn_item   = Cur1;
			 Menu.mn_scroll = FALSE;
			 flag = menu_popup( &Menu, box.g_x, box.g_y, &MData );
			 if( flag )
			   MenuCheck( MData.mn_tree,
				      MData.mn_menu, 
				      MData.mn_item );
			 break;

            case TITLE2:
			 box = ObRect( TITLE2 );
			 objc_offset( ad_box, TITLE2, &box.g_x, &box.g_y );

			 Menu.mn_tree   = ad_country;
			 Menu.mn_menu   = ROOT;
			 Menu.mn_item   = Cur2;
			 Menu.mn_scroll = TRUE;
			 flag = menu_popup( &Menu, box.g_x, box.g_y, &MData );
			 if( flag )
			   MenuCheck( MData.mn_tree,
				      MData.mn_menu,
				      MData.mn_item );
			 break;

            case TITLE3:
			 box = ObRect( TITLE3 );
			 objc_offset( ad_box, TITLE3, &box.g_x, &box.g_y );

			 Menu.mn_tree   = ad_other;
			 Menu.mn_menu   = MODEM;
			 Menu.mn_item   = Cur3;
			 Menu.mn_scroll = FALSE;
			 flag = menu_popup( &Menu, box.g_x, box.g_y, &MData );
			 if( flag )
			   MenuCheck( MData.mn_tree,
				      MData.mn_menu,
				      MData.mn_item );
			 break;

            case TITLE4:
			 box = ObRect( TITLE4 );
			 objc_offset( ad_box, TITLE4, &box.g_x, &box.g_y );

			 Menu.mn_tree   = ad_other;
			 Menu.mn_menu   = QUOTES;
			 Menu.mn_item   = Cur4;
			 Menu.mn_scroll = FALSE;
			 flag = menu_popup( &Menu, box.g_x, box.g_y, &MData );
			 if( flag )
			   MenuCheck( MData.mn_tree,
				      MData.mn_menu,
				      MData.mn_item );
			 break;

            default:
			break;
          }

        }while( button != XEXIT );

	form_dial( FMD_FINISH, rect.g_x, rect.g_y, rect.g_w, rect.g_h,
			       rect.g_x, rect.g_y, rect.g_w, rect.g_h );

        evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );



       /* display menubar stuff here */
        ActiveTree( ad_menubar );
        menu_bar( ad_menubar, TRUE );

        
	do
	{
	    evnt_mesag( msg );
	    if( msg[0] == MN_SELECTED )
	    {
		/* msg[7] is the parent of FQUIT - which the user can't know */
		ptr = &msg[5];
		if( ( *ptr == ad_menubar ) &&
                    ( msg[4] == FQUIT )
		  )
                {
		  button = form_alert( 1, "[1][ |  EXIT PROGRAM? ][OK|Cancel]");
		  if( button == 1 )
		    done = TRUE;
                }  
		else
		    MenuCheck( *ptr, msg[7], msg[4] );
		menu_tnormal( ad_menubar, msg[3], TRUE );
            }	
	}while( !done );
        menu_bar( ad_menubar, FALSE );

        rsrc_free();
	graf_mouse( ARROW, 0L );
	appl_exit();
}




VOID
MenuCheck( ptree, pmenu, pitem )
OBJECT	*ptree;
WORD	pmenu;
WORD	pitem;
{
   if( ad_tree == ptree )
   {
     menu_icheck( ad_tree, Cur1, 0 );
     menu_icheck( ad_tree, pitem, 1 );
     Cur1 = pitem;
     menu_istart( 1, ad_tree, ROOT, Cur1 );
   }

   if( ad_country == ptree )
   {
     menu_icheck( ad_country, Cur2, 0 );
     menu_icheck( ad_country, pitem, 1 );
     Cur2 = pitem;
     menu_istart( 1, ad_country, ROOT, Cur2 );
   }


   if( ad_other == ptree )
   {
      if( pmenu == QUOTES )
      {
        menu_icheck( ad_other, Cur4, 0 );	/* QUOTES */
        menu_icheck( ad_other, pitem, 1 );
        Cur4 = pitem;
      }

      if( pmenu == MODEM )
      {
        menu_icheck( ad_other, Cur3, 0 );
        menu_icheck( ad_other, pitem, 1 );
        Cur3 = pitem;
      }

      if( pmenu == DISNEY )
      {
        menu_icheck( ad_other, Cur5, 0 );
        menu_icheck( ad_other, pitem, 1 );
        Cur5 = pitem;
      }
      menu_istart( 1, ptree, pmenu, pitem );  /* MODEM, DISNEY, QUOTES */
    
   }
}
