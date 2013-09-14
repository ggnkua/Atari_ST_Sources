/* DEMO.C
 * ================================================================
 * DESCRIPTION: Test program for heirarchical menus linked in
 *		with the menu code.
 */

/* INCLUDES
 * ================================================================
 */
#include <alt\gemskel.h>
/*
#include <portab.h>
 */
#include <gemlib.h>

#include "menubind.h"			/* Menu Bindings */
#include "demo.h"		


/* PROTOTYPES
 * ================================================================
 */
void	MenuCheck( OBJECT *ptree, WORD pmenu, WORD pitem );
int	execform( OBJECT *tree, int start_obj );
void	do_modem( void );
void	DoPopup( int titlenum, int button, OBJECT *poptree, int *CurValue, char *Text[] );


/* DEFINES
 * ================================================================
 */
#define VOID	void


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
OBJECT *ad_menubar;
OBJECT *ad_fonts;
OBJECT *ad_style;
OBJECT *ad_position;
OBJECT *ad_color;
OBJECT *ad_pattern;
OBJECT *ad_modem;

OBJECT *ad_baudrate;
OBJECT *ad_parity;
OBJECT *ad_bittree;
OBJECT *ad_stoptree;
OBJECT *ad_porttree;
OBJECT *ad_flowtree;

WORD Cur1 = 1;
WORD Cur2 = 1;
WORD Cur3 = 1;
WORD Cur4 = 1;
WORD Cur5 = 1;
WORD Cur6 = 1;
WORD CurStyle = 1;
WORD CurPos = 1;
WORD CurFonts = 1;

OBJECT *ptree;
int    pmenu;
int    pscroll;

int msg[8];
OBJECT **ptr;
LONG    value;

MENU    Menu;
MENU    MData;




BYTE *Text1[] = { "19200",
		  "9600",
		  "4800",
		  "3600",
		  "2400",
		  "2000",
		  "1800",
		  "1200",
		  "600",
		  "300",
		  "200",
		  "150",
		  "134",
		  "110",
		  "75",
		  "50"
		};

BYTE *Text2[] = { "None",
		  "Odd",
		  "Even"
		};

BYTE *Text3[] = { "8",
		  "7",
		  "6",
		  "5"
		};


BYTE *Text4[] = { "1",
		  "1.5",
		  "2"
		};

BYTE *Text5[] = { "Modem1",
		  "Modem2",
		  "Serial1",
		  "Serial2"
		};

BYTE *Text6[] = { "None",
		  "Xon/Xoff",
		  "Rts/Cts"
		};


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
	GRECT   xrect;
        WORD    tempx;

        GRECT   rect;
	
        WORD    ptitle, pitem, pmenu;
	OBJECT  *ptree;
	BOOLEAN done;
	WORD    dummy;

        WORD	xvalue;

        
	appl_init();

	phys_handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );

        graf_mouse( ARROW, 0L );
        
        rsrc_load( "DEMO.RSC" );

        rsrc_gaddr( 0, MENUBAR, &ad_menubar );
        rsrc_gaddr( 0, ATREE, &ad_tree );
	rsrc_gaddr( 0, FONTTREE, &ad_fonts );
	rsrc_gaddr( 0, STREE, &ad_style );
	rsrc_gaddr( 0, POSTREE, &ad_position );
	rsrc_gaddr( 0, CTREE, &ad_color );
        rsrc_gaddr( 0, PTREE, &ad_pattern );
	rsrc_gaddr( 0, MTREE, &ad_modem );

	rsrc_gaddr( 0, BAUDRATE, &ad_baudrate );
	rsrc_gaddr( 0, PARTREE, &ad_parity );
	rsrc_gaddr( 0, BITTREE, &ad_bittree );
	rsrc_gaddr( 0, STOPTREE, &ad_stoptree );
	rsrc_gaddr( 0, PORTTREE, &ad_porttree );
	rsrc_gaddr( 0, FLOWTREE, &ad_flowtree );

	/* test attaching submenus */
	Menu.mn_tree   = ad_fonts;
	Menu.mn_menu   = ROOT;
        Menu.mn_item   = 1;
	Menu.mn_scroll = TRUE;
	menu_attach( 1, ad_menubar, FONTS1, &Menu );

	Menu.mn_tree   = ad_style;
	Menu.mn_menu   = ROOT;
        Menu.mn_item   = 1;
	Menu.mn_scroll = FALSE;
	menu_attach( 1, ad_menubar, STYLE, &Menu );

	Menu.mn_tree   = ad_position;
	Menu.mn_menu   = ROOT;
        Menu.mn_item   = 1;
	Menu.mn_scroll = FALSE;
	menu_attach( 1, ad_menubar, POSITION, &Menu );

	Menu.mn_tree   = ad_color;
	Menu.mn_menu   = ROOT;
        Menu.mn_item   = 1;
	Menu.mn_scroll = FALSE;
	menu_attach( 1, ad_menubar, COLOR, &Menu );

	Menu.mn_tree   = ad_pattern;
	Menu.mn_menu   = ROOT;
        Menu.mn_item   = 1;
	Menu.mn_scroll = FALSE;
	menu_attach( 1, ad_menubar, PATTERN1, &Menu );

	menu_icheck( ad_baudrate, Cur1, 1 );
	menu_icheck( ad_parity, Cur2, 1 );
	menu_icheck( ad_bittree, Cur3, 1 );
	menu_icheck( ad_stoptree, Cur4, 1 );
	menu_icheck( ad_porttree, Cur5, 1 );
	menu_icheck( ad_flowtree, Cur6, 1 );

	menu_icheck( ad_style, CurStyle, 1 );
	menu_icheck( ad_position, CurPos, 1 );
	menu_icheck( ad_fonts, CurFonts, 1 );

       /* display menubar stuff here */
        menu_bar( ad_menubar, TRUE );

        done = FALSE;
	do
	{
	    evnt_mesag( msg );
	    if( msg[0] == MN_SELECTED )
	    {
		/* msg[7] is the parent of FQUIT - which the user can't know */
		ptr = ( OBJECT **)&msg[5];
		if( *ptr == ad_menubar )
		{
		   switch( msg[4] )
		   {
		      case FQUIT:
				  button = form_alert( 1, "[1][ |  EXIT PROGRAM? ][OK|Cancel]");
				  if( button == 1 )
		 		      done = TRUE;
		       		  break;

		      case ABOUTX: execform( ad_tree, 0 );
				   break;

		      case PHONE: do_modem();
				  break;

		      default:
				   break;
		   }
		}

		if( *ptr == ad_style )
		{
		   menu_icheck( ad_style, CurStyle, 0 );
		   menu_icheck( ad_style, msg[4], 1 );
		   CurStyle = msg[4];
		   menu_istart( 1, ad_style, ROOT, CurStyle );
		}

		if( *ptr == ad_position )
		{
		   menu_icheck( ad_position, CurPos, 0 );
		   menu_icheck( ad_position, msg[4], 1 );
		   CurPos = msg[4];
		   menu_istart( 1, ad_position, ROOT, CurPos );
		}


		if( *ptr == ad_fonts )
		{
		   menu_icheck( ad_fonts, CurFonts, 0 );
		   menu_icheck( ad_fonts, msg[4], 1 );
		   CurFonts = msg[4];
		   menu_istart( 1, ad_fonts, ROOT, CurFonts );
		}

		menu_tnormal( ad_menubar, msg[3], TRUE );
            }	
	}while( !done );
        menu_bar( ad_menubar, FALSE );

	graf_mouse( ARROW, 0L );	
        rsrc_free();
	appl_exit();
}



VOID
MenuCheck( ptree, pmenu, pitem )
OBJECT	*ptree;
WORD	pmenu;
WORD	pitem;
{
   if( ad_baudrate == ptree )
   {
     menu_icheck( ad_baudrate, Cur1, 0 );
     menu_icheck( ad_baudrate, pitem, 1 );
     Cur1 = pitem;
     menu_istart( 1, ad_baudrate, ROOT, Cur1 );
   }

   if( ad_parity == ptree )
   {
     menu_icheck( ad_parity, Cur2, 0 );
     menu_icheck( ad_parity, pitem, 1 );
     Cur2 = pitem;
     menu_istart( 1, ad_parity, ROOT, Cur2 );
   }

   if( ad_bittree == ptree )
   {
     menu_icheck( ad_bittree, Cur3, 0 );
     menu_icheck( ad_bittree, pitem, 1 );
     Cur3 = pitem;
     menu_istart( 1, ad_bittree, ROOT, Cur3 );
   }

   if( ad_stoptree == ptree )
   {
     menu_icheck( ad_stoptree, Cur4, 0 );
     menu_icheck( ad_stoptree, pitem, 1 );
     Cur4 = pitem;
     menu_istart( 1, ad_stoptree, ROOT, Cur4 );
   }

   if( ad_porttree == ptree )
   {
     menu_icheck( ad_porttree, Cur5, 0 );
     menu_icheck( ad_porttree, pitem, 1 );
     Cur5 = pitem;
     menu_istart( 1, ad_porttree, ROOT, Cur5 );
   }

   if( ad_flowtree == ptree )
   {
     menu_icheck( ad_flowtree, Cur6, 0 );
     menu_icheck( ad_flowtree, pitem, 1 );
     Cur6 = pitem;
     menu_istart( 1, ad_flowtree, ROOT, Cur6 );
   }
}


/* execform()
 * ================================================================
 * Custom routine to put up a standard dialog box and wait for a key.
 */
int
execform( OBJECT *tree, int start_obj )
{
   GRECT rect;
   GRECT xrect;
   int button;

   xrect.g_x = xrect.g_y = 10;
   xrect.g_w = xrect.g_h = 36;
   form_center( tree, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );
   form_dial( FMD_START, xrect.g_x, xrect.g_y, xrect.g_w, xrect.g_h,
                         rect.g_x, rect.g_y, rect.g_w, rect.g_h );
   form_dial( FMD_GROW, xrect.g_x, xrect.g_y, xrect.g_w, xrect.g_h,
                         rect.g_x, rect.g_y, rect.g_w, rect.g_h );

   objc_draw( tree, ROOT, MAX_DEPTH, rect.g_x, rect.g_y, rect.g_w,rect.g_h );
   button = form_do( tree, start_obj );
   form_dial( FMD_SHRINK, xrect.g_x, xrect.g_y, xrect.g_w, xrect.g_h,
                         rect.g_x, rect.g_y, rect.g_w, rect.g_h );

   form_dial( FMD_FINISH, xrect.g_x, xrect.g_y, xrect.g_w, xrect.g_h,
                         rect.g_x, rect.g_y, rect.g_w, rect.g_h );
   tree[ button ].ob_state &= ~SELECTED;
   return( button );
}



void
do_modem( void )
{
   GRECT rect;
   GRECT xrect;
   int button;
   OBJECT *tree;

   wind_update( BEG_UPDATE );

   ActiveTree( ad_modem );
   TedText( M1BUTTON ) = Text1[ Cur1 - 1 ];
   TedText( M2BUTTON ) = Text2[ Cur2 - 1 ];
/*
   ( TEDINFO *)(ad_modem[ M1BUTTON ].ob_spec)->te_ptext = Text1[ Cur1 - 1 ];
   ( TEDINFO *)(ad_modem[ M2BUTTON ].ob_spec)->te_ptext = Text2[ Cur2 - 1 ];
 */
   xrect.g_x = xrect.g_y = 10;
   xrect.g_w = xrect.g_h = 36;
   form_center( ad_modem, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h );
   form_dial( FMD_START, xrect.g_x, xrect.g_y, xrect.g_w, xrect.g_h,
                         rect.g_x, rect.g_y, rect.g_w, rect.g_h );
   form_dial( FMD_GROW, xrect.g_x, xrect.g_y, xrect.g_w, xrect.g_h,
                         rect.g_x, rect.g_y, rect.g_w, rect.g_h );

   objc_draw( ad_modem, ROOT, MAX_DEPTH, rect.g_x, rect.g_y, rect.g_w,rect.g_h );
   do
   {
      button = form_do( ad_modem, 0 );

      switch( button )
      {
	case M1BUTTON:  DoPopup( M1TITLE, M1BUTTON, ad_baudrate, &Cur1, Text1 );
			break;

	case M2BUTTON:  DoPopup( M2TITLE, M2BUTTON, ad_parity, &Cur2, Text2 );
			break;

	case M3BUTTON:  DoPopup( M3TITLE, M3BUTTON, ad_bittree, &Cur3, Text3 );
			break;

	case M4BUTTON:  DoPopup( M4TITLE, M4BUTTON, ad_stoptree, &Cur4, Text4 );
			break;

	case M5BUTTON:  DoPopup( M5TITLE, M5BUTTON, ad_porttree, &Cur5, Text5 );
			break;

	case M6BUTTON:  DoPopup( M6TITLE, M6BUTTON, ad_flowtree, &Cur6, Text6 );
			break;

	default:
		 break;
      }

   }while( button != MOK );

   form_dial( FMD_SHRINK, xrect.g_x, xrect.g_y, xrect.g_w, xrect.g_h,
                         rect.g_x, rect.g_y, rect.g_w, rect.g_h );

   form_dial( FMD_FINISH, xrect.g_x, xrect.g_y, xrect.g_w, xrect.g_h,
                         rect.g_x, rect.g_y, rect.g_w, rect.g_h );
   ad_modem[ button ].ob_state &= SELECTED;
   wind_update( END_UPDATE );  
}


void
DoPopup( int titlenum, int button, OBJECT *poptree, int *CurValue, char *Text[] )
{
   GRECT  box;
   GRECT  title;
   WORD   flag;
   OBJECT *tree;

   ActiveTree( ad_modem );
   ad_modem[ titlenum ].ob_state |= SELECTED;
   objc_xywh( ad_modem, titlenum, &title );
   objc_draw( ad_modem, titlenum, 1, title.g_x,title.g_y,title.g_w,title.g_h );

   objc_xywh( ad_modem, button, &box );

   Menu.mn_tree   = poptree;
   Menu.mn_menu   = ROOT;
   Menu.mn_item   = *CurValue;
   Menu.mn_scroll = FALSE;
   flag = menu_popup( &Menu, box.g_x, box.g_y, &MData );
   if( flag )
   {
     MenuCheck( MData.mn_tree,
  	        MData.mn_menu, 
		MData.mn_item );
     TedText( button ) = Text[ *CurValue - 1 ];
/*
     ( TEDINFO *)( ad_modem[ button ].ob_spec)->te_ptext = Text[ *CurValue - 1 ];
 */ 
  }

   ad_modem[ titlenum ].ob_state &= ~SELECTED;
   objc_draw( ad_modem, titlenum, 1, title.g_x,title.g_y,title.g_w,title.g_h );


   ad_modem[ button ].ob_state &= ~SELECTED;
   box.g_x -= 1;
   box.g_y -= 1;
   box.g_w += 2;
   box.g_h += 2;
   objc_draw( ad_modem, ROOT, MAX_DEPTH, box.g_x,box.g_y,box.g_w,box.g_h );	
}

