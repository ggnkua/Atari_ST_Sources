/* ===================================================================
 * FILE: PRINTER.C
 * ===================================================================
 * DATE: December 9, 1992
 * 
 * DESCRIPTION: Fonts ACC
 *
 * This file handles the printer size dialog box.
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
void	DoPrinter( void );
int	HandlePrinter( int button, WORD *msg );
void	DoPrintOK( void );




/* DEFINES
 * ===================================================================
 */
#define PRINT_HEIGHT	9
#define ACTIVE	    	0
#define INACTIVE    	1



/* GLOBALS
 * ===================================================================
 */
FON_PTR print_list, print_last;
int print_count;
int PrintInternalFlag;
int BeforeCount;
int AfterCount;


/* FUNCTIONS
 * ===================================================================
 */


/* DoPrinter()
 * ===================================================================
 */
void
DoPrinter( void )
{
    DEV_PTR  curptr;
    FON_PTR  fonptr;
    int      i;

    Reset_Tree( ad_printer );

    /* Read in the UnUsed fonts, if necessary
     * This way, we have a list of ALL fonts.
     */
    
    if( !Fonts_Loaded )
    {
      MF_Save();
      Scan_Message( ad_scan, TRUE );	

      read_fonts( TRUE, FALSE );

      Scan_Message( ad_scan, FALSE );
      MF_Restore();
    }  

    free_arena_links();
    print_count = build_specific_list( &print_list, &print_last, BITMAP_FONT );

    /* Find the printer device */
    curptr = find_device( 21 );

    /* Find and set to SELECTED, the printer fonts on the device */
    if( curptr )
    {
      for( i = 0; i < DFCOUNT( curptr ); i++ )
      {
          fonptr = DFONT( curptr )[i];
	  if( fonptr )
	      AFLAG( fonptr ) = TRUE;
      }
    }

    mover_setup( print_list, print_count,
		 PRNTBASE, PRNTSLDR, PRNTUP, PRNTDOWN,
		 PLINE0, PLINE8, PLINE, 0, PRINT_HEIGHT );

    PrintInternalFlag = FALSE;    
    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}



/* HandlePrinter()
 * ===================================================================
 */
int
HandlePrinter( int button, WORD *msg )
{
   int     quit;
   int     dclick;

   quit   = FALSE;
   dclick = FALSE;
   
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      button &= 0x7FFF;
      dclick = TRUE;
   }


   switch( button )
   {
     case PRINTOK:  /* OK! Look through the fonts and find the active
		     * AFLAG ones. Then clear the device fonts and
		     * replace these ones instead.
		     */
		    if( PrintInternalFlag )
		    {
		       DoPrintOK();
		       SetChangeFlag();
		    }
		    
		    
     case PRINTCAN: Deselect( button );
		    ClearFnodes( print_list );

		    Reset_Tree( ad_options );     

		    free_arena_links();
		    installed_count = build_list( &installed_list, &installed_last, ACTIVE );
		    available_count = build_list( &available_list, &available_last, INACTIVE );

		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
     		    break;

     case PLINE0:
     case PLINE1:
     case PLINE2:
     case PLINE3:
     case PLINE4:
     case PLINE5:
     case PLINE6:
     case PLINE7:
     case PLINE8:    BeforeCount = CountSelectedFonts( print_list, BITMAP_FONT );
       		     mover_button( button, dclick );
       		     AfterCount = CountSelectedFonts( print_list, BITMAP_FONT );
       		     if( BeforeCount != AfterCount )
       		        PrintInternalFlag = TRUE;
		     break;
		     
     case PRNTUP:
     case PRNTDOWN:
     case PRNTBASE:
     case PRNTSLDR:  mover_button( button, dclick );
     		     break;


     case PRINTCLR:  if( form_alert( 1, alertp1 ) == 1 )
     		     {
			 BeforeCount = CountSelectedFonts( print_list, BITMAP_FONT );
			 if( BeforeCount )
		 	     PrintInternalFlag = TRUE;
		         Undo_Fnodes( print_list, ( FON_PTR )NULL );
		     }    
		     XDeselect( tree, PRINTCLR );
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
     		     		     if( PrintInternalFlag )
     		     		     {
				        DoPrintOK();
				        SetChangeFlag();
				     }   
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




/* DoPrintOK()
 * ===================================================================
 * Clear the printer devices fonts and then add in our newly selected ones.
 */
void
DoPrintOK( void )
{
    DEV_PTR  curptr;
    FON_PTR  fon_ptr;

    curptr = find_device(21);
    if( curptr )
    {
        ClearDeviceFont( curptr );

        fon_ptr = print_list;
	while( fon_ptr )
        {
	    if( AFLAG( fon_ptr ) )
		add_to_device( curptr, fon_ptr );
	    fon_ptr = FNEXT( fon_ptr );
        }
    }
}
