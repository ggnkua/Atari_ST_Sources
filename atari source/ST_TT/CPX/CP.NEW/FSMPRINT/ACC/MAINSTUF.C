/* ======================================================================
 * FILE: MAINSTUF.C
 * ======================================================================
 * DATE: MAY  30, 1991
 *       July 10, 1991
 *	 Sept 10, 1991
 *	 Sept 16, 1991
 *	 Nov  20, 1991
 *
 * DESCRIPTION: FSMPRINT -> FSM Printer Config
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 * ======================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>


#include "country.h"
#include "fprint.h"
#include "popmenu.h"
#include "fileio.h"
#include "text.h"
#include "entry.h"
#include "popctrl.h"


/* PROTOTYPES
 * ======================================================================
 */
void	 initialize( void );
int	 handle_button( int button, WORD *msg );

void     do_modify( void );
void	 WaitUpButton( void );
void	 ClearCheckMarks( void );
int	 execform( OBJECT *xtree, int start_obj );

void	 CheckOS( void );
long	 GetOS( void );
	
void	 DoDrivers( void );

	
/* DEFINES
 * ======================================================================
 */
typedef struct _menu_id
{
  int  menuid;
  int  curvalue;
  char text[ 10 ];
  int  num_items;
} MENU_ID; 


#define MAX_MENUS	8

#define MQUALITY	0
#define MCOLOR		1
#define MPAGESIZE	2
#define MREZ		3
#define MPORT		4
#define MTRAY		5
#define MHSIZE		6
#define MVSIZE		7

/* FRONT END DEFINES */
#define MAX_DRIVERS	50	/* Maximum # of Drivers we can use */


/* EXTERNALS
 * ======================================================================
 */


/* GLOBALS
 * ======================================================================
 */
MENU_ID Menu[ MAX_MENUS ];

char *hsize_text[] = {
			"0123",
			"0123",
			"0123",
			"0123"
		     };
		   
char *vsize_text[] = {
			"0123",
			"0123",
			"0123",
			"0123"
		     };
		     		   
char    title[ 128 ];
char    xtext[6];
char    ytext[6];

int     xres_value;	/* Value of the current XRES and YRES variables */
int     yres_value;	/* for the submenus...				*/
int     Tos_Country;	/* TOS Country Version */

/* FRONT END VARIABLES */
char  drivers[ MAX_DRIVERS ][14];    /* Driver names */
char  cdrivers[ MAX_DRIVERS ][ 30 ]; /* Driver names for Front Panel */
int   cur_cdriver;
int   cdriver_count;
char  *CurNames[ MAX_DRIVERS ];      /* Names of the drivers to display in the popup */



/* FUNCTIONS
 * ======================================================================
 */

/* initialize()
 *==========================================================================
 * Initialize the variables and sliders before displaying the resource.
 */
void
initialize( void )
{
     Wind_get( 0, WF_WORKXYWH, ( WARGS *)&desk );

     /* Initialize PopUp Menus and Menu IDs */
     InitPopUpMenus();
     SetSubMenuDelay( 300L );
     SetSubDragDelay( 3000L );
     SetArrowClickDelay( 150L );

     Menu[ MQUALITY ].menuid  = InsertPopUpMenu( print_text[0], 2, 2 );
     Menu[ MPAGESIZE ].menuid = InsertPopUpMenu( size_text[0], 5, 5 );
     Menu[ MREZ ].menuid      = InsertPopUpMenu( rez_text[0], 2, 2 );

     Menu[ MCOLOR ].menuid    = InsertPopUpMenu( color_text[0], 4, 4 );
     Menu[ MPORT ].menuid     = InsertPopUpMenu( port_text[0], 2, 2 );
     Menu[ MTRAY ].menuid     = InsertPopUpMenu( tray_text[0], 4, 4 );

     graf_mouse( BUSYBEE, 0L );
     Scan_Message( ad_scan, TRUE );	
     GetCDrivers();
     Scan_Message( ad_scan, FALSE );	
     graf_mouse( ARROW, 0L );
  
     Disable( XMODIFY );
     NoShadow( XMODIFY );
     NoTouchExit( XMODIFY );
     TedText( XMODIFY ) = NoDrivers;

     if( cdriver_count )
     {
       if( cdriver_count == 1 )
         TedText( XMODIFY ) = cdrivers[0];
       else
         TedText( XMODIFY ) = YesDrivers;
       Enable( XMODIFY );
       MakeShadow( XMODIFY );
       MakeTouchExit( XMODIFY );
     }
}
	


/* handle_button()
 * ====================================================================
 * Main Menu Button handling.
 */
int
handle_button( int button, WORD *msg )
{
   int  quit = FALSE;

   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      button &= 0x7FFF;      
   }   

   switch( button )
   {
     	   case FOK:     quit = TRUE;
     	   		 Deselect( button );
     	   		 break;
     	   		 
     	   case XMODIFY: DoDrivers();
     	   		 break;

     	   default:	if( button == -1 )
     			{
     			   switch( msg[0] )
     			   {
     			     case WM_REDRAW: 
     			     		     break;
     			     		     
     			     case AC_CLOSE:  /* treated like a cancel */
     			     		     quit = TRUE;
     			     		     break;
     			     		     
     			     case WM_CLOSED: quit = TRUE; /* treated like an OK */
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



/* do_modify()
 * ======================================================================
 */
void
do_modify( void )
{
   GRECT rect;
   GRECT xrect;
   int   button;
   int   obj;
   MRETS mk;
   int   menuid;

   long  value;
   int   item;
   int   id;
   int   xobj;
   int   xtitle;
   int   curvalue;
   int   offset;
   char  **txtptr;
   int   i;
   int   output;
   int   tempx, tempy;
   int   xstart;   
            
   int   xdpi,ydpi;
   float Xres,Yres;

   ActiveTree( drivetree );

   xres_value = hdr->xres;	/* Set the globals for xres and yres */
   yres_value = hdr->yres;
   ClearCheckMarks();
   
   Menu[ MQUALITY ].curvalue = hdr->quality;
   strcpy( Menu[ MQUALITY ].text, print_text[ Menu[ MQUALITY ].curvalue + 2 ] );
   
   Menu[ MPAGESIZE ].curvalue = hdr->PageSize;
   strcpy( Menu[ MPAGESIZE ].text, size_text[ Menu[ MPAGESIZE ].curvalue + 5 ] );
   
   Menu[ MCOLOR ].curvalue = max( 0, hdr->nplanes - 1 );
   Menu[ MVSIZE ].curvalue = max( 0, hdr->nplanes - 1 );
   Menu[ MHSIZE ].curvalue = max( 0, hdr->nplanes - 1 );
   
   strcpy( Menu[ MCOLOR ].text, color_text[ Menu[ MCOLOR ].curvalue ] );

   Menu[ MPORT ].curvalue = hdr->port;   
   strcpy( Menu[ MPORT ].text, port_text[ Menu[ MPORT ].curvalue + 2 ] );
   
   Menu[ MTRAY ].curvalue = hdr->paper_feed;
   strcpy( Menu[ MTRAY ].text, tray_text[ Menu[ MTRAY ].curvalue + 4 ] );
   
   strcpy( Menu[ MVSIZE ].text, vsize_text[ Menu[ MVSIZE ].curvalue ] );
   strcpy( Menu[ MHSIZE ].text, hsize_text[ Menu[ MHSIZE ].curvalue ] );

   if( hdr->config_map & 0x0040 )	/* Check for Color...*/
   {
      MakeShadow( DCOLOR );
      MakeTouchExit( DCOLOR );
   }
   else
   {
      NoShadow( DCOLOR );
      NoTouchExit( DCOLOR );
   }    
   
   if( hdr->config_map & 0x0001 )  /* Check for Print Quality */
   {
     MakeShadow( DPRINT );
     MakeTouchExit( DPRINT );
   }
   else
   {
      NoShadow( DPRINT );
      NoTouchExit( DPRINT );
   }

   if( hdr->config_map & 0x0100 ) /* Check for Port */
   {
     MakeShadow( DPORT );
     MakeTouchExit( DPORT );
   }
   else
   {
      NoShadow( DPORT );
      NoTouchExit( DPORT );
   }
      
   if( Menu[ MTRAY ].num_items > 1 ) /* Check for Trays */
   {
     MakeShadow( DTRAY );
     MakeTouchExit( DTRAY );
   }
   else
   {
      NoShadow( DTRAY );
      NoTouchExit( DTRAY );
   }
     
   if( Menu[ MPAGESIZE ].num_items > 1 )
   {
     MakeShadow( DPAGE );
     MakeTouchExit( DPAGE );
   }
   else
   {
      /* If there is only the pagetype of OTHER, then display it.*/
      if( Menu[ MPAGESIZE ].curvalue == 4 )
      {
        MakeShadow( DPAGE );
        MakeTouchExit( DPAGE );
      }
      else
      {
        NoShadow( DPAGE );
        NoTouchExit( DPAGE );
      }  
   }
        
   ObString( DPRINT ) = Menu[ MQUALITY ].text;
   ObString( DPAGE )  = Menu[ MPAGESIZE ].text;     
   ObString( DCOLOR ) = Menu[ MCOLOR ].text;
   ObString( DPORT )  = Menu[ MPORT ].text;
   ObString( DTRAY )  = Menu[ MTRAY ].text;    
   ObString( DHSIZE ) = Menu[ MHSIZE ].text;
   ObString( DVSIZE ) = Menu[ MVSIZE ].text;
    
   TedText( DDRIVER ) = title;


   for( i = MQUALITY; i <= MTRAY; i++ )
   {
      CheckItem( Menu[ i ].menuid, Menu[i].curvalue, TRUE );
      SetStartItem( Menu[i].menuid, Menu[i].curvalue );
   }
      
   Menu[ MREZ ].curvalue = 0;
   SetStartItem( Menu[ MREZ ].menuid, 0 );
   CheckItem( Menu[ MREZ ].menuid, 0, FALSE );
   CheckItem( Menu[ MREZ ].menuid, 1, FALSE );
   
   Form_center( tree, &rect );
   Form_dial( FMD_START, &rect, &rect );
   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   do
   {

      button = form_do( tree, 0 );

      if( button & 0x8000 )
          button &= 0x7FFF;      

      if(( button != DOK ) && ( button != DCANCEL ))
      {		     
         xrect = ObRect( button );
     	 objc_offset( tree, button, &xrect.g_x, &xrect.g_y );

	 if( !IsDisabled( button ) )
	   select( tree, button );
	 WaitUpButton();
	 Graf_mkstate( &mk );
	 obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );

	 if( ( obj == button ) && ( !IsDisabled( obj ) ) )
	 {
	    switch( button )
	    {
	       case DPRINT:  menuid   = Menu[ MQUALITY ].menuid;
			     curvalue = Menu[ MQUALITY ].curvalue;
			     xobj     = MQUALITY;			
			     offset   = 2;
			     txtptr   = print_text;
			     xtitle   = QTITLE;
		 	     break;

	       case DPAGE:   menuid   = Menu[ MPAGESIZE ].menuid;
			     curvalue = Menu[ MPAGESIZE ].curvalue;
			     xobj     = MPAGESIZE;	
			     offset   = 5;
			     txtptr   = size_text;
			     xtitle   = STITLE;
			     break;

	       case DCOLOR:  menuid   = Menu[ MCOLOR ].menuid;
			     curvalue = Menu[ MCOLOR ].curvalue;
			     xobj     = MCOLOR;
			     offset   = 0;
			     txtptr   = color_text;
			     xtitle   = CTITLE;
			     break;

	       case DPORT:   menuid   = Menu[ MPORT ].menuid;
			     curvalue = Menu[ MPORT ].curvalue;
			     xobj     = MPORT;
			     offset   = 2;
			     txtptr   = port_text;
			     xtitle   = PTITLE;
			     break;

	       case DTRAY:   menuid   = Menu[ MTRAY ].menuid;
			     curvalue = Menu[ MTRAY ].curvalue;
			     xobj     = MTRAY;
			     offset   = 4;
			     txtptr   = tray_text;
			     xtitle   = TTITLE;
			     break;
		
	       default:
	       		break;
	       			       
            }
            if( button != DPRINT )
                disable( tree, DPRINT );
                
            if( button != DPAGE )
                disable( tree, DPAGE );
                
            if( button != DCOLOR )
                disable( tree, DCOLOR );
                
            if( button != DPORT )    
                disable( tree, DPORT );
            
            if( button != DTRAY )    
                disable( tree, DTRAY );

            select( tree, xtitle );
            
            value = PopUpMenuSelect( menuid, xrect.g_x, xrect.g_y, curvalue );        
            if( value != -1L )
            {
               item  = (int)value;
               id = (int)( value >> 16L );

	       if( ( item != -1 ) && ( id != Menu[ MREZ ].menuid ))
	       {
                  CheckItem( id, curvalue, FALSE );
                  CheckItem( id, item, TRUE );
                  Menu[ xobj ].curvalue = item;
                  SetStartItem( id, item );

                  strcpy( Menu[ xobj ].text, txtptr[ Menu[ xobj ].curvalue + offset ] );
                  ObString( button ) = Menu[ xobj ].text;
                  Objc_draw( tree, button, MAX_DEPTH, NULL );
                  
                  if( menuid == Menu[ MCOLOR ].menuid )
                  {
                      Menu[ MHSIZE ].curvalue = item;
                      Menu[ MVSIZE ].curvalue = item;
                      strcpy( Menu[ MVSIZE ].text, hsize_text[ Menu[ MVSIZE ].curvalue ] );
                      strcpy( Menu[ MHSIZE ].text, vsize_text[ Menu[ MHSIZE ].curvalue ] );
                      Objc_draw( tree, DHSIZE, MAX_DEPTH, NULL );
                      Objc_draw( tree, DVSIZE, MAX_DEPTH, NULL );
                  }
               }

               if( ( item != -1 ) && ( id == Menu[ MREZ ].menuid ) )
               {
                  xdpi = hdr->X_PIXEL[ hdr->nplanes - 1 ];
                  ydpi = hdr->Y_PIXEL[ hdr->nplanes - 1 ];

		  /* ZERO BASED - so we add one pixel */
                  Xres = hdr->xres + 1;
                  Yres = hdr->yres + 1;
	        
                  Xres /= xdpi;	/* gets us inches */
                  Yres /= ydpi;
                  
                  ActiveTree( xytree );

                  CheckOS();
		  if( Tos_Country )/* Get's us CM if other than USA */
		  {
 		    sprintf( xtext, "%2.2f", Xres * 2.54 );
		    sprintf( ytext, "%2.2f", Yres * 2.54 ); 
                    TedText( XYUNITS ) = xy2_unit;
		  }
		  else
		  {
 		    sprintf( xtext, "%2.1f", Xres );
		    sprintf( ytext, "%2.1f", Yres );
                    TedText( XYUNITS ) = xy1_unit;
		  } 
                  
                  TedText( SETX ) = xtext;
                  TedText( SETY ) = ytext;
                  xstart = (( !item ) ? ( SETX ) : ( SETY ) );
		  output = execform( xytree, xstart );
		  ActiveTree( drivetree );
		  if( output == XYOK )
		  {
                      CheckItem( menuid, curvalue, FALSE );
                      CheckItem( menuid, 4, TRUE ); /* set to OTHER */
                      Menu[ xobj ].curvalue = 4;
                      SetStartItem( menuid, 4 );
                      strcpy( Menu[ xobj ].text, txtptr[ Menu[ xobj ].curvalue + offset ] );
                      ObString( button ) = Menu[ xobj ].text;

		      tempx = atof( xtext );
		      tempy = atof( ytext );
		      
		      if( ( ( tempx > 0.0 ) && ( tempy > 0.0 ) ) &&
		          ( ( tempx <= 99.9 ) && ( tempy <= 99.9 ) ))
		      {
		        Xres = tempx;
		        Yres = tempy;
		        
		        if( Tos_Country )
		        {
		          tempx /= 2.54;
		          tempy /= 2.54;
		        }
		          
		        /* ZERO BASED - so we subtract one pixel */  
		        xres_value = hdr->xres = ( tempx * xdpi ) - 1;
		        yres_value = hdr->yres = ( tempy * ydpi ) - 1;
			
		        if( !Tos_Country )
		        { /* If USA, use inches */
		          sprintf( rez_text[0], rez_width, Xres );
		          sprintf( rez_text[1], rez_height, Yres );
		        }
		        else
		        { /* Get us CM for other than USA */
		          sprintf( rez_text[0], rez2_width, Xres * 2.54 );
		          sprintf( rez_text[1], rez2_height, Yres * 2.54 );
		        }
                        SetItem( Menu[ MREZ ].menuid, 0, rez_text[0] );
                        SetItem( Menu[ MREZ ].menuid, 1, rez_text[1] );
                      }  
		  }
		  Objc_draw( tree, ROOT, MAX_DEPTH, NULL );		  
               }
               
            }
	 
	   if( button != DPRINT )
	        enable( tree, DPRINT );
	        
	   if( button != DPAGE )
	        enable( tree, DPAGE );
	        
	   if( button != DCOLOR )
	        enable( tree, DCOLOR );
	        
	   if( button != DPORT )
        	enable( tree, DPORT );
        	
	   if( button != DTRAY )
         	enable( tree, DTRAY );

           deselect( tree, xtitle );
	 }
	 deselect( tree, button );
      }
      else
      {
         if( button == DOK )
         {
            graf_mouse( ARROW, 0L );
            if( form_alert( 1, alert0 ) == 1 )
            {
               graf_mouse( BUSYBEE, 0L );
               Save_Data();
            }   
            graf_mouse( ARROW, 0L );
         }
         deselect( tree, button );
      }
      
   }while( button != DCANCEL );
   
   Form_dial( FMD_FINISH, &rect, &rect );
   Deselect( button );
   
   ActiveTree( cpxtree );
   deselect( tree, XMODIFY );
}


/* WaitUpButton()
 * ======================================================================
 */
void
WaitUpButton( void )
{
   MRETS mk;

   do
   {
      Graf_mkstate( &mk );
   }while( mk.buttons );
}


/* ClearCheckMarks()
 * ======================================================================
 */
void
ClearCheckMarks( void )
{
     int    i,j;
     long   length;
     int    mask;
     int    xdpi,ydpi;
     float  Xres,Yres;
     char   *ptr;
          
     xdpi = hdr->X_PIXEL[ hdr->nplanes - 1 ];
     ydpi = hdr->Y_PIXEL[ hdr->nplanes - 1 ];

     /* ZERO BASED - so, we add one pixel */
     Xres = hdr->xres + 1;
     Yres = hdr->yres + 1;
	        
     Xres /= xdpi;	/* gets us inches */
     Yres /= ydpi;


     CheckOS();
     if( !Tos_Country )
     { /* If USA, use inches */
       sprintf( rez_text[0], rez_width, Xres );
       sprintf( rez_text[1], rez_height, Yres );
     }
     else
     { /* Get us CM for other than USA */
       sprintf( rez_text[0], rez2_width, Xres * 2.54 );
       sprintf( rez_text[1], rez2_height, Yres * 2.54 );
     }
       
     
/* We must clear the array completely. Strings are terminated with '\0'
 * and must be nulled out to the next string.
 */
     for( i = 0; i < 2; i++ )
     {
        length = strlen( rez_text[i] );
        ptr    = rez_text[i];
        ptr    += length;
        for( j = (int)length; j < 19; j++ )
           *ptr++ = '\0';
     }



     for( i = 0; i < 2; i++ )
     {
       CheckItem( Menu[ MQUALITY ].menuid, i, FALSE );
       CheckItem( Menu[ MPORT ].menuid, i, FALSE );
       SetItem( Menu[ MREZ ].menuid, i, rez_text[i] );
     }

     mask = 0x0002;
     Menu[ MPAGESIZE ].num_items = 0;
     for( i = 0; i < 5; i++ )
     {
       CheckItem( Menu[ MPAGESIZE ].menuid, i, FALSE );
       if( hdr->config_map & mask )
       {
          EnableItem( Menu[ MPAGESIZE ].menuid, i );
          Menu[ MPAGESIZE ].num_items++;
       }   
       else
	  DisableItem( Menu[ MPAGESIZE ].menuid, i );
       mask = mask << 1;
     }  


     for( i = 0; i < 3; i++ )
     { 
       CheckItem( Menu[ MCOLOR ].menuid, i, FALSE );
       Menu[ MCOLOR ].num_items = hdr->total_planes - 1;
     }

     mask = 0x0200;
     Menu[ MTRAY ].num_items     = 0;
     for( i = 0; i < 4; i++ )
     {
       CheckItem( Menu[ MTRAY ].menuid, i, FALSE );

       if( hdr->config_map & mask )
       {
          EnableItem( Menu[ MTRAY ].menuid, i );
          Menu[ MTRAY ].num_items++;
       }   
       else   
	  DisableItem( Menu[ MTRAY ].menuid, i );
       mask = mask << 1;
           
       CheckItem( Menu[ MHSIZE ].menuid, i, FALSE );
       sprintf( vsize_text[i], "%d", hdr->Y_PIXEL[i] );
       sprintf( hsize_text[i], "%d", hdr->X_PIXEL[i] );
     }     

     /* check for wot's available */
     
     Menu[ MVSIZE ].num_items    = 0;
     Menu[ MHSIZE ].num_items    = 0;
     Menu[ MQUALITY ].num_items  = 2;
     Menu[ MPORT ].num_items     = 2;
     Menu[ MHSIZE ].curvalue     = Menu[ MVSIZE ].curvalue = 0;
}


/* execform()
 * ================================================================
 * Custom routine to put up a standard dialog box and wait for a key.
 */
int
execform( OBJECT *xtree, int start_obj )
{
   GRECT rect;
   GRECT xrect;
   int button;
   
   xrect.g_x = xrect.g_y = 10;
   xrect.g_w = xrect.g_h = 36;
   
   Form_center( xtree, &rect );
   Form_dial( FMD_START, &xrect, &rect );
   Objc_draw( xtree, ROOT, MAX_DEPTH, &rect );
   button = form_do( xtree, start_obj );
   Form_dial( FMD_FINISH, &xrect, &rect );
   Deselect( button );
   return( button );
}



/* CheckOS()    
 * ================================================================
 * Checks the OS for version 3.01 of TOS which will have problems
 * with Bezier functions.
 */
void
CheckOS( void )
{
    Supexec( GetOS );
}



/* GetOS()
 * ================================================================
 * A Supexec routine to get the current version of the OS.
 */
long
GetOS( void )
{
   SYSHDR *osheader;
   
   osheader = *((SYSHDR **)0x4f2L );
   
   osheader = osheader->os_base;
   Tos_Country  = osheader->os_palmode;
   return( 0L );
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

   /* If there are no drivers to list, don't popup the menu */
   if( cdriver_count < 1 )
        return;

   /* If there is only one driver, then we just display it */
   if( cdriver_count == 1 )
   {
      sprintf( FPath, "%s\\%s", epath, &drivers[ 0 ][0] );
      graf_mouse( BUSYBEE, 0L );
      if( Read_Data() )
      {
          graf_mouse( ARROW, 0L );
	  do_modify();
      }
      graf_mouse( ARROW, 0L );	  
      return;
   }
   

   for( i = 0; i < cdriver_count; i++ )
        CurNames[i] = &cdrivers[i][0];

   graf_mouse( ARROW, 0L );
   cur_cdriver = -1;
   Item = Pop_Handle( tree, XMODIFY, CurNames, cdriver_count, &cur_cdriver, IBM, 28 );
   if( Item != -1 )
   {
      sprintf( FPath, "%s\\%s", epath, &drivers[ Item ][0] );
      graf_mouse( BUSYBEE, 0L );
      if( Read_Data() )
      {
          graf_mouse( ARROW, 0L );
	  do_modify();
      }	  
   }
   graf_mouse( ARROW, 0L );
}

