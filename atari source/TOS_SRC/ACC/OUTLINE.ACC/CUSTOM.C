/* ===================================================================
 * FILE: CUSTOM.C
 * ===================================================================
 * DATE: December 9, 1992
 * 
 * DESCRIPTION: Fonts ACC
 *
 * This file handles the Custom dialog box.
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
void	DoCustom( void );
int	HandleCustom( int button, WORD *msg );

void	SetXFlags( int devnum );
void	SetCustomDevice( int devnum, int draw );
void	DoXInstall( void );
void	DoXRemove( void );
int	SearchDevicesForFont( FON_PTR curptr );



/* DEFINES
 * ===================================================================
 */
#define ACTIVE	       0
#define INACTIVE       1
#define CUSTOM_HEIGHT  6
#define UNDO		0x6100
#define FRONT_HEIGHT	14
#define INACTIVE_HEIGHT	14


/* GLOBALS
 * ===================================================================
 */
DEV_PTR cur_device;

char DeviceNum[4];
char DeviceName[15];
FON_PTR IList, ILast;	/* Installed List */
int ICount;
FON_PTR AList, ALast;	/* Available List */
int ACount;
int APosition;
int IPosition;

/* FUNCTIONS
 * ===================================================================
 */


/* DoCustom()
 * ===================================================================
 */
void
DoCustom( void )
{
    Reset_Tree( ad_custom );

    /* Get the rest of the fonts if they haven't been loaded */
    if( !Fonts_Loaded )
    {
      MF_Save();
      Scan_Message( ad_scan, TRUE );	

      read_fonts( TRUE, FALSE );

      Scan_Message( ad_scan, FALSE );
      MF_Restore();
    }  


    /* INitialize the device number and the device name */
    cur_device = device_head;
    if( cur_device )
    {
	/* Get the Device Number and Name */
	sprintf( DeviceNum, "%d", DDEV( cur_device ));
	TedText( XDEVNUM ) = DeviceNum;

	strcpy( DeviceName, drivers[ DNAME( cur_device ) ] );
	TedText( XFNAME ) = DeviceName;
    }

    Disable( XINSTALL );
    Disable( XREMOVE );
    NoExit( XINSTALL );
    NoExit( XREMOVE );

    /* Set up the Installed and available bitmap fonts for devices */
    SetCustomDevice( DDEV( cur_device ), FALSE );
    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}



/* HandleCustom()
 * ===================================================================
 */
int
HandleCustom( int button, WORD *msg )
{
   int     quit;
   MRETS   mk;
   int     dclick;

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
     case CUSTOMOK: Deselect( button );

		    Reset_Tree( ad_options );		    

		    free_arena_links();
		    installed_count = build_list( &installed_list, &installed_last, ACTIVE );
		    available_count = build_list( &available_list, &available_last, INACTIVE );

		    ClearFnodes( installed_list );
		    ClearFnodes( available_list );
#if 0

THIS ISN'T NEEDED! THE RESET IS DONE WHEN WE RETURN FROM OPTIONS TO FRONT
		    /* RESET the SCROLLERS for the INSTALLED FONTS */
		    Reset_Tree( ad_front );		    
                    mover_setup( installed_list, installed_count,
		                 FBASE, FSLIDER, FUP, FDOWN,
		  		 LINE0, LINE13, LINEBASE, 0, FRONT_HEIGHT );


		    /* RESET the SCROLLERS for the AVAILABLE FONTS */  
		    Reset_Tree( ad_front );		    
		    mover_setup( available_list, available_count,
		 		 IBASE, ISLIDER, IUP, IDOWN,
		 		 ILINE0, ILINE13, ILINE, 0, INACTIVE_HEIGHT );
#endif
		    Reset_Tree( ad_options );		    
		    HideObj( OBASE );
		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
     		    break;

     case XUP:	    XSelect( tree, XUP );
		    do
		    {
		       if( DNEXT( cur_device ) )
		       {
			   cur_device = DNEXT( cur_device );

			   /* Get the Device Number and Name */
			   sprintf( DeviceNum, "%d", DDEV( cur_device ));
			   TedText( XDEVNUM ) = DeviceNum;

			   strcpy( DeviceName, drivers[ DNAME( cur_device ) ] );
			   TedText( XFNAME ) = DeviceName;

			   RedrawObject( tree, XDEVNUM );
			   RedrawObject( tree, XFNAME );

			   SetCustomDevice( DDEV( cur_device ), TRUE );

	            	   if( !IsDisabled( XINSTALL ) )
	       			ChangeButton( ad_custom, XINSTALL, FALSE );

           	    	   if( !IsDisabled( XREMOVE ) )
	       			ChangeButton( ad_custom, XREMOVE, FALSE );

			   Evnt_timer( 50L );
		       }
     		       Graf_mkstate( &mk );
		    }while( mk.buttons );
		    XDeselect( tree, XUP );
		    break;

     case XDOWN:    XSelect( tree, XDOWN );
		    do
		    {
		       if( DPREV( cur_device ) )
		       {
			   cur_device = DPREV( cur_device );

			   /* Get the Device Number and Name */
			   sprintf( DeviceNum, "%d", DDEV( cur_device ));
			   TedText( XDEVNUM ) = DeviceNum;

			   strcpy( DeviceName, drivers[ DNAME( cur_device ) ] );
			   TedText( XFNAME ) = DeviceName;

			   RedrawObject( tree, XDEVNUM );
			   RedrawObject( tree, XFNAME );

			   SetCustomDevice( DDEV( cur_device ), TRUE );

	            	   if( !IsDisabled( XINSTALL ) )
	       			ChangeButton( ad_custom, XINSTALL, FALSE );

           	    	   if( !IsDisabled( XREMOVE ) )
	       			ChangeButton( ad_custom, XREMOVE, FALSE );

			   Evnt_timer( 50L );
		       }
     		       Graf_mkstate( &mk );
		    }while( mk.buttons );
		    XDeselect( tree, XDOWN );
     		    break;

     case LLINE0:
     case LLINE1:
     case LLINE2:
     case LLINE3:
     case LLINE4:
     case LLINE5:
     case LUP:
     case LDOWN:
     case LBASE:
     case LSLIDER:  /* Check if the mover hdptr is already this list's */
		    if( hdptr != IList )
		    {
		      APosition = Get_Findex( AList, Active_Slit[0] );
		      Undo_Fnodes( AList, ( FON_PTR )NULL );
		      mover_setup( IList, ICount, LBASE, LSLIDER, LUP, LDOWN,
		 		   LLINE0, LLINE5, LLINE, IPosition, CUSTOM_HEIGHT );
		    }
		    mover_button( button, dclick );
		    IPosition = Get_Findex( IList, Active_Slit[0] );
		    break;

     case RLINE0:
     case RLINE1:
     case RLINE2:
     case RLINE3:
     case RLINE4:
     case RLINE5:
     case RUP:
     case RDOWN:
     case RBASE:
     case RSLIDER:  /* Check first if the list is already at hdptr */
		    if( hdptr != AList )
		    {
		      IPosition = Get_Findex( IList, Active_Slit[0] );
		      Undo_Fnodes( IList, ( FON_PTR )NULL );
		      mover_setup( AList, ACount, RBASE, RSLIDER, RUP, RDOWN,
		 		 RLINE0, RLINE5, RLINE, APosition, CUSTOM_HEIGHT );
		    }
		    mover_button( button, dclick );
		    APosition = Get_Findex( AList, Active_Slit[0] );
		    break;


     case XINSTALL: DoXInstall();
		    XDeselect( tree, XINSTALL );

		    break;

     case XREMOVE:  DoXRemove();
		    XDeselect( tree, XREMOVE );
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
				     free_arena_links();
		    		     installed_count = build_list( &installed_list, &installed_last, ACTIVE );
		    		     available_count = build_list( &available_list, &available_last, INACTIVE );

		    		     ClearFnodes( installed_list );
		    		     ClearFnodes( available_list );
     		     
     		     		     CloseWindow();
				     break;

		     case CT_KEY:    if( msg[3] == UNDO )
		     		     {
				        if( hdptr == IList )
					      Undo_Fnodes( IList, ( FON_PTR )NULL );

				        if( hdptr == AList )
					      Undo_Fnodes( AList, ( FON_PTR )NULL );
		     		     }
		     		     break;
     		     default:
     		     		break;
     		   }
     		 }
     		 else
     		 {
		     if( hdptr == IList )
		        Undo_Fnodes( IList, ( FON_PTR )NULL );

	             if( hdptr == AList )
		        Undo_Fnodes( AList, ( FON_PTR )NULL );
     		 }
     		 break;
   }
   return( quit );


}



/* SetXFlags()
 * ===================================================================
 */
void
SetXFlags( int devnum )
{
    DEV_PTR curptr;
    FON_PTR fonptr;
    int     i;

    /* Find the current device */
    curptr = find_device( devnum );

    /* Find and set to SELECTED, the fonts on the device */
    if( curptr )
    {
      for( i = 0; i < DFCOUNT( curptr ); i++ )
      {
          fonptr = DFONT( curptr )[i];
          
	  if( fonptr )
	      XFLAG( fonptr ) = TRUE;
      }
    }
}



/* SetCustomDevice()
 * ===================================================================
 */
void
SetCustomDevice( int devnum, int draw )
{
    free_arena_links();
    SetXFlags( devnum );

    IPosition = APosition = 0;
    IList = ILast = ( FON_PTR )NULL;
    AList = ALast = ( FON_PTR )NULL;
    ICount = ACount = 0;

    ICount = BuildBitMapList( &IList, &ILast, ACTIVE );    
    ACount = BuildBitMapList( &AList, &ALast, INACTIVE );    

    mover_setup( IList, ICount, LBASE, LSLIDER, LUP, LDOWN,
		 LLINE0, LLINE5, LLINE, 0, CUSTOM_HEIGHT );

    mover_setup( AList, ACount, RBASE, RSLIDER, RUP, RDOWN,
		 RLINE0, RLINE5, RLINE, 0, CUSTOM_HEIGHT );

    if( draw )
    {
        Objc_draw( tree, LLINE, MAX_DEPTH, NULL );
	RedrawObject( tree, LBASE );

        Objc_draw( tree, RLINE, MAX_DEPTH, NULL );
	RedrawObject( tree, RBASE );
    }
}



/* DoXInstall()
 * ===================================================================
 */
void
DoXInstall( void )
{
    FON_PTR curptr;
    int     flag;
    
    if( IsChanged( AList ) )
    {
	sprintf( line_buf, alertc1, DDEV( cur_device ) );
        if( form_alert( 1, line_buf  ) == 1 )
	{
	    flag = FALSE;
	    curptr = AList;
	    while( curptr )
	    {
		if( AFLAG( curptr ) )
		{
		   flag = add_to_device( cur_device, curptr );
		   if( !flag )
		   {
		      form_alert( 1, alertc7 );
		      break;
		   }
		   
		   /* ADD THIS TO THE INSTALLED LIST!!!!!
		    * If it already hasn't been done
		    * NOTE: ONLY Device 1 - 10 
		    */
		   if( ( DDEV( cur_device ) >= 1 ) && ( DDEV( cur_device ) <= 10 ) )
		        SEL( curptr ) = TRUE;
		}   
		curptr = FNEXT( curptr );
	    }
	    SetCustomDevice( DDEV( cur_device ), TRUE );
            if( !IsDisabled( XINSTALL ) )
       	       ChangeButton( ad_custom, XINSTALL, FALSE );
       	       
       	    /* No errors! */
	    if( flag )
	      SetChangeFlag();
	}
    }
}


/* DoXRemove()
 * ===================================================================
 */
void
DoXRemove( void )
{
    FON_PTR curptr;

    if( IsChanged( IList ) )
    {
	sprintf( line_buf, alertc2, DDEV( cur_device ) );
        if( form_alert( 1, line_buf  ) == 1 )
	{
	    curptr = IList;
	    while( curptr )
	    {
		if( AFLAG( curptr ) )
		{
		   remove_from_device( cur_device, curptr );
		   
		   /* Search devices 1-10, if they exist
		    * and see if this font 'curptr' is used
		    * still. If so, do nothing...
		    * if NOT, REMOVE IT -> SEL() = FALSE
		    */
		   if( !SearchDevicesForFont( curptr ))
		      SEL( curptr ) = FALSE;
		   
		}   
		curptr = FNEXT( curptr );
	    }
	    SetCustomDevice( DDEV( cur_device ), TRUE );
      	    if( !IsDisabled( XREMOVE ) )
      		ChangeButton( ad_custom, XREMOVE, FALSE );
            SetChangeFlag();
	}
    }
}




/* SearchDevicesForFont()
 * ===================================================================
 */
int
SearchDevicesForFont( FON_PTR curptr )
{
   int flag;
   DEV_PTR cur_device;
   
   flag = FALSE;
   
   cur_device = device_head;
   while( cur_device )
   {
        if(  ( DDEV( cur_device ) >= 1 ) && ( DDEV( cur_device ) <= 10 ) )
        {
            if( FindFontInDevice( cur_device, curptr ) )
               flag = TRUE;
        }
        cur_device = DNEXT( cur_device );
   }
   return( flag );
}

