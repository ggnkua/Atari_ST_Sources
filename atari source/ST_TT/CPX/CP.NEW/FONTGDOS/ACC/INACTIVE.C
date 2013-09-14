/* FILE:  INACTIVE.C
 * ========================================================================
 * DATE:  December 18, 1990
 * DESCRIPTION: Handle the Inactive Bitmap fonts
 *
 * INCLUDE FILE: InActive.H
 */



/* INCLUDE FILES
 * ========================================================================
 */
#include <sys\gemskel.h> 
#include "country.h"

#include "choice.h"

#include "fonthead.h"
#include "mainstuf.h"
#include "fontacc.h"
#include "fsmio.h"
#include "mover.h"
#include "text.h"
#include "popup.h"


struct foobar {
	WORD	dummy;
	WORD	*image;
	};



/* PROTOTYPES
 * ========================================================================
 */
void	Do_InActiveFonts( void );
void	Build_InActive_Menu( void );
int	InActive_Button( int button, WORD *msg );
void	XDeviceUpDown( int button );
void	ClearListFlags( void );
void	SetListFlags( void );
void	MoveFonts( void );
void    RemoveActiveFonts( void );


/* DEFINES
 * ========================================================================
 */
#define UNDO		0x6100


/* GLOBALS
 * ========================================================================
 */
 
DEV_PTR cur_device;	/* used to know which device to transfer to*/
char    Device_Text[3];	/* Text to display device number */
char    Driver_Text[9];	/* Text to display driver name   */

int     imenu_num;	/* Number of inactive menu items to use */


/* FUNCTIONS
 * ========================================================================
 */


/* Do_InActiveFonts()
 * ========================================================================
 */
void
Do_InActiveFonts( void )
{
   PrevTree = ad_menu;
   Reset_Tree( ad_inactive );       		                

   NoExit( XTRANSFR );
   Disable( XTRANSFR );

   /* Let's display the current device displayed...*/
   cur_device = current_device;

   ClearListFlags();
   SetListFlags();   
   mover_setup( bit_list, bit_count - DFCOUNT( cur_device ),
		OBASE, OSLIDE, OUP, ODOWN,
		OLINE0, OLINE5, OLBASE, 0 );
  
   sprintf( Device_Text, "%d", DDEV( cur_device ) );
   TedText( OXDEVICE ) = &Device_Text[0];
   
   strcpy( Driver_Text, drivers[ DNAME( cur_device )] );
   strip_period( &Driver_Text[0] );
   TedText( OXDRIVER ) = &Driver_Text[0];

   if( IsChanged( bit_list ) )
   {
      MakeExit( XTRANSFR );
      Enable( XTRANSFR );
   }
   
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL );   		  
}



/* Build_InActive_Menu()
 * =====================================================================
 */
void
Build_InActive_Menu( void )
{
   imenu_num = (( IsChanged( bit_list )) ? ( 3 ) : ( 2 ) );
}

 
 
/* InActive_Button()
 * =====================================================================
 */
int
InActive_Button( int button, WORD *msg )
{
  int default_item = -1;
  int quit = FALSE;
      
  if( ( button != -1 ) && ( button & 0x8000 ) )
     button &= 0x7FFF;      

  switch( button )
  {
     case IQUIT:    Deselect( IQUIT );
     		    RestoreMainTree();
     		    break;

     case OXUP:
     case OXDOWN:   XDeviceUpDown( button );
     		    break;
     		    
     case IMENU:   Build_InActive_Menu();
		   Item = Pop_Handle( tree, IMENU, imenu_text,
			              imenu_num, &default_item,
       			              IBM, 23 );
   		   switch( Item )
   		   {
   		      case 0: DoActiveFonts();
   		   	      break;
   		   	   
   		      case 1: RestoreMainTree();
   		   	      break;

		      case 2: if( form_alert( 1, alert9 ) == 1 )
     		              {
     		                MoveFonts();
     		                SetChangeFlag();
     		              } 
   		   	      break;

   		      default:
   		   	      break;
   		   }
     		   break;
     		         		    
     case OUP:
     case ODOWN:
     case OBASE:
     case OSLIDE:
     case OLINE0:
     case OLINE1:
     case OLINE2:
     case OLINE3:
     case OLINE4:
     case OLINE5: mover_button( button );
		  break;

     case XTRANSFR: if( form_alert( 1, alert9 ) == 1 )
     		    {
     		      MoveFonts();
     		      SetChangeFlag();
     		    }  
     		    else
     		      deselect( tree, XTRANSFR );
     		    break;
     		    		       		       
     default:	if( button == -1 )
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
		    
		    		     /* UNDO key restores the fonts of
		    		      * the specific driver.
		    		      */
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



/* XDeviceUpDown()
 * =======================================================================
 * Handles the up/down buttons on displaying an active driver and device.
 * so that we can decide which driver to transfer fonts to.
 */
void
XDeviceUpDown( int button )
{
   MRETS mk;
   DEV_PTR olddev;
   GRECT rect;
      
   select( tree, button );
   do
   {
      olddev = cur_device;
      
      if( button == OXUP )
      {
         if( DNEXT( cur_device ) )
             cur_device = DNEXT( cur_device );
      }
      else
      {
         if( DPREV( cur_device ) )
             cur_device = DPREV( cur_device );
      }

      if( olddev != cur_device )
      {
        sprintf( Device_Text, "%d", DDEV( cur_device ) );
        TedText( OXDEVICE ) = &Device_Text[0];
        
        strcpy( Driver_Text, drivers[ DNAME( cur_device )] );
	strip_period( &Driver_Text[0] );
	        
        TedText( OXDRIVER ) = &Driver_Text[0];
        
        ClearListFlags();
        SetListFlags();   
        mover_setup( bit_list, bit_count - DFCOUNT( cur_device ),
		     OBASE, OSLIDE, OUP, ODOWN,
		     OLINE0, OLINE5, OLBASE, Cur_Slit );
        
        Objc_draw( tree, OXDEVICE, MAX_DEPTH, NULL );
        Objc_draw( tree, OXDRIVER, MAX_DEPTH, NULL );
        Objc_draw( tree, OLBASE, MAX_DEPTH, NULL );
        Objc_draw( tree, OBASE, MAX_DEPTH, NULL );
        
        
        /* turn on/off the XTRANSFR button here too */
        rect = ObRect( XTRANSFR );
        objc_offset( tree, XTRANSFR, &rect.g_x, &rect.g_y );

	rect.g_x -= 3;
	rect.g_y -= 3;
	rect.g_w += 6;
	rect.g_h += 6;

        if( IsChanged( bit_list ) )
        {
           MakeExit( XTRANSFR );
           Enable( XTRANSFR );
        }
        else
        {
           NoExit( XTRANSFR );
	   Disable( XTRANSFR );           
        }
        Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
      }  
      Evnt_timer( 100L );
      
      current_device = cur_device;	/* let's make them equal */
      
      Graf_mkstate( &mk );
   }while( mk.buttons );
   
   deselect( tree, button );
}



/* ClearListFlags()
 * =======================================================================
 * clears the AFLAG and SFLAG in the bitlist only.
 * We reset all of the links in the inactive font list.
 */
void
ClearListFlags( void )
{
   FON_PTR curptr;
   FON_PTR temp;
   int     i;
     
   for( i = 0; i < bit_count; i++ )
   {
      curptr = &font_arena[ i ];
      FPREV( curptr ) = FNEXT( curptr ) = ( FON_PTR )NULL;
      if( i )
      {
         temp = &font_arena[ i - 1 ];
         FPREV( curptr ) = temp;
         FNEXT( temp ) = curptr;
         AFLAG( curptr ) = SFLAG( curptr ) = FALSE;   
      }
   }
   
   bit_list = bit_last = ( FON_PTR )NULL;
   if( bit_count )
   {
     bit_list = &font_arena[0];
     bit_last = &font_arena[ bit_count - 1 ];   
   }
}



/* SetListFlags()
 * =======================================================================
 * Sets the AFLAGS and SFLAGS of the bitlist if the device fonts
 * match.
 * 
 * We take the fonts allocated to the device and find them in
 * the main font list. If found, we unlink it from the linked list.
 */
void
SetListFlags( void )
{
   FON_PTR font;
   FON_PTR xfont;
   int     index;
      
   for( index = 0; index < DFCOUNT( cur_device ); index++ )
   {
       font = DFONT( cur_device )[ index ];
       xfont = FindFont( font );

       if( xfont )
       {
         if( xfont == bit_list )
             bit_list = FNEXT( xfont );
         
         if( xfont == bit_last )
             bit_last = FPREV( xfont );
                 
         if( FPREV( xfont ) )
         {
           FNEXT( FPREV( xfont ) ) = FNEXT( xfont );
         }
       
         if( FNEXT( xfont ) )
         {
           FPREV( FNEXT( xfont ) ) = FPREV( xfont );
         }
       }             
   }
}




/* MoveFonts()
 * =======================================================================
 * Move fonts from the InActive List to the Current_Device.
 * Note- we remove the activated fonts from the display
 * AND we APPEND the fonts to the device.
 */
void
MoveFonts( void )
{
   FON_PTR curptr;
   GRECT   rect;
   
   if( hdptr )		/* make sure we have a list of fonts...  */
   {
      curptr = hdptr;
      while( curptr )
      {
           /* Append the active fonts */
           if( AFLAG( curptr ) )
	       add_to_device( current_device, curptr );
           curptr = FNEXT( curptr );
      }

      /* Remove the fonts from the font list. */
      RemoveActiveFonts();
      mover_setup( bit_list, bit_count - DFCOUNT( cur_device ),
	           OBASE, OSLIDE, OUP, ODOWN,
		   OLINE0, OLINE5, OLBASE, Cur_Slit );
        
      Objc_draw( tree, OLBASE, MAX_DEPTH, NULL );
      Objc_draw( tree, OBASE, MAX_DEPTH, NULL );
        
        
      /* turn on/off the XTRANSFR button here too */
      rect = ObRect( XTRANSFR );
      objc_offset( tree, XTRANSFR, &rect.g_x, &rect.g_y );

      rect.g_x -= 3;
      rect.g_y -= 3;
      rect.g_w += 6;
      rect.g_h += 6;

      NoExit( XTRANSFR );
      Disable( XTRANSFR );           
      Deselect( XTRANSFR );
      Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   }
   else
    deselect( tree, XTRANSFR );	/* clear the button...*/
}



/* RemoveActiveFonts()
 * =======================================================================
 * Remove the active fonts from the inactive font list.
 * We do this by going thru the linked list and checking for AFLAGS set.
 */
void
RemoveActiveFonts( void )
{
   FON_PTR font;
   
   font = bit_list;
   while( font )
   {
      if( AFLAG( font ) )
      {
         AFLAG( font ) = SFLAG( font ) = FALSE;
         if( font == bit_list )
            bit_list = FNEXT( font );
            
         if( font == bit_last )
            bit_last = FPREV( font );

         if( FPREV( font ) )
         {
           FNEXT( FPREV( font ) ) = FNEXT( font );
         }
       
         if( FNEXT( font ) )
         {
           FPREV( FNEXT( font ) ) = FPREV( font );
         }
      }
      font = FNEXT( font );
   }
}
