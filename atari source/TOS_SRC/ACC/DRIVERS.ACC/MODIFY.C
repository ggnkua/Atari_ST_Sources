/* ===================================================================
 * FILE: MODIFY.C
 * ===================================================================
 * DATE: December 1, 1992
 *	 January 15, 1993 Write the ASSIGN.SYS immediately once
 *			  we add or modify the device.
 * 
 * DESCRIPTION: DRIVERS ACC
 *
 * This file handles the modify dialog box which lets the user
 * add or modify a device.
 *
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 * ===================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
#include <linea.h>
#include <stdlib.h>

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
#include "popmenu.h"


/* STRUCTURE
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
void	WaitForUpButton( void );



/* PROTOTYPES
 * ===================================================================
 */
void	DoModify( int obj, DEV_PTR curptr );
int	Modify_Button( int button, WORD *msg );
void	DoNamePopUp( void );
void	DoROMRES( int button );
void	DoUpDown( int button );



/* DEFINES
 * ===================================================================
 */
#define MENU_HEIGHT	16
#define MIN_DEV 10



/* GLOBALS
 * ===================================================================
 */
char numtext[] = "   ";
int  menuid;
int  dcurvalue;
int  dcurdevice;
DEV_PTR dcurptr;
int  dtype;
int  dcurflag;
int  startnum;
int  scrn_id;




/* FUNCTIONS
 * ===================================================================
 */


/* DoCustom()
 * ===================================================================
 */
void
DoModify( int obj, DEV_PTR curptr )
{
   Reset_Tree( ad_modify );
   
   dcurptr = curptr;		/* Save off the device pointer  */
   dtype = obj;			/* and whether its MODIFY or ADD*/
      
   if( obj == DMODIFY )
      TedText( MTITLE ) = modtext;     
   else
      TedText( MTITLE ) = addtext;

   /* Get the screen ID index */
   scrn_id = find_driver( "SCREEN.SYS" );


   /* Clear the ROM/RESIDENT buttons */
   Deselect( MROMYES );
   Deselect( MROMNO );
   Deselect( MRESYES );
   Deselect( MRESNO );
   ShowObj( ROMBASE );
   ShowObj( ROMTITLE );

   /* Setup the UP/DOWN/EDIT buttons */
   Enable( MUP );
   Enable( MDOWN );
   Enable( MEDIT );
   MakeEditable( MEDIT );
   MakeTouchExit( MUP );
   MakeTouchExit( MDOWN );


   /* Check if there isn't any drivers..then no popup */
   MakeShadow( MNAME );
   MakeTouchExit( MNAME );

   /* NOTE- SCREEN.SYS means that there will always be at least one*/
   if( driver_count <= 1 )
   {
       NoShadow( MNAME );
       NoTouchExit( MNAME );
   }
   
   
   
   
   if( obj == DMODIFY )
   {
      if( curptr )
      {
	 /* Get the device number */
	 startnum = dcurdevice = DDEV( curptr );
         sprintf( numtext, "%3d", DDEV( curptr ) );
	 TedText( MEDIT ) = numtext;

	 /* Get printer name */	
	 dcurvalue = DNAME( curptr );
	 TedText( MNAME ) = drivers[ DNAME( curptr ) ];


	 /* Get whether its resident or not */
	 dcurflag = DTYPE( curptr );
	 if( DTYPE( curptr ) == 'R')
            Select( MRESYES );
	 else
	    Select( MRESNO );

	 /* Get whether its in ROM or not */
	 if( DTYPE( curptr ) == 'P' )
            Select( MROMYES );
	 else
	    Select( MROMNO );


	 /* If this is a screen device, 1-9, don't let them touch
	  * the device scrolling stuff. ALSO
	  * If we are displaying the screen.sys driver AND the
	  * device num is MIN_DEV, (10), then disable the buttns also.
	  */
	 if( ( dcurdevice <= 9 ) ||
	   ( ( dcurdevice == MIN_DEV ) && ( scrn_id == dcurvalue ) ))
	 {
	   Disable( MUP );
	   Disable( MDOWN );
	   Disable( MEDIT );
	   NoEdit( MEDIT );
	   NoTouchExit( MUP );
	   NoTouchExit( MDOWN );
	 }
	 
	 /* If device >= 10, they can't be in ROM, so hide it! */
	 if( dcurdevice > MIN_DEV )
	 {
	    HideObj( ROMBASE );
	    HideObj( ROMTITLE );
	 }
	 
      }
   }

   if( obj == DADD )
   {
       dcurvalue = 0;	/* Initialize the starting driver to 0 */
       			/* In other words, the first one...    */
   
       /* Adding a Device - they can't be in ROM, so hide it!
        * Except for device 10
        */

       /* Initial Device that we can start with.*/
       dcurdevice = MIN_DEV - 1;
       
       /* Find an UNUSED device number */
       do
       {
          dcurdevice++;
          
          /* If we exceed the MAX, then no more device addons..*/
          if( dcurdevice >= MAX_NUM_DEV )
          {
          	form_alert( 1, alert7 );
	        Reset_Tree( ad_device );     
		Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
		return;
          }
       }while( find_device( dcurdevice ) );


       /* ALSO, if more than 50 devices, then no more also. */
       if( ( device_count + 1 ) >= MAX_DRIVERS )
       {
            /* no more room for any more devices */
            form_alert( 1, alert7 );
	    Reset_Tree( ad_device );     
	    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
	    return;
       }


       /* If device >= 10, they can't be in ROM, so hide it! */
       if( dcurdevice > MIN_DEV )
       {
         HideObj( ROMBASE );
         HideObj( ROMTITLE );
       }  
 
 
       /* If we start off with trying to add a screen.sys driver
        * and a device less than or equal to MIN_DEV, we disable
        * the UP/DOWN/EDIT buttons.
        */
       if(( dcurdevice <= MIN_DEV ) && ( scrn_id == dcurvalue ) )
       {
	   Disable( MUP );
	   Disable( MDOWN );
	   Disable( MEDIT );
	   NoEdit( MEDIT );
	   NoTouchExit( MUP );
	   NoTouchExit( MDOWN );
       }
      
       startnum = dcurdevice;
       sprintf( numtext, "%3d", dcurdevice );
       TedText( MEDIT ) = numtext;

       /* Initial printer name */	
       TedText( MNAME ) = drivers[ dcurvalue ];

       /* Set Resident/ROM status to nothing */
       dcurflag = ' ';
       Select( MRESNO );
       Select( MROMNO );
   }

   Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}


/* Modify_Button()
 * ===================================================================
 */
int
Modify_Button( int button, WORD *msg )
{
   int     quit;
   DEV_PTR curptr;
   int     num;
   int     obj; 
   MRETS   mk;
   
   quit   = FALSE;
      
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      button &= 0x7FFF;      
   }   
   
   switch( button )
   {
     case MOK:	
		    /* Get the status of the ROM/RES flags */
		    dcurflag = ' ';
     		    if( IsSelected( MROMYES ) ) /* Put INTO ROM */
     		        dcurflag  = 'P';
     		       
     		    if( IsSelected( MRESYES ) ) /* Put into RAM */
     		        dcurflag = 'R';
     
     
     
     
      	            if( dtype == DMODIFY )  /* MODIFY the DEVICE */
     		    {
     		       /* If these are > 9, then let them modify devnum */
     		       if( DDEV( dcurptr ) >= MIN_DEV )
     		       {	    
		         num = atoi( numtext );
  
		         if(( num >= MIN_DEV ) && ( num <= ( MAX_NUM_DEV - 1 )))
		             dcurdevice = num;
		       }      

		       /* Make the Actual Change ONLY if a change has
		        * been made.
		        */
		       if( ( DDEV( dcurptr )  != dcurdevice ) ||
		           ( DNAME( dcurptr ) != dcurvalue  ) ||
		           ( DTYPE( dcurptr ) != dcurflag ) )
		       {

			  /* Look to see if we're moving to an OCCUPIED
			   * LOCATION. Other than its own, that is..
			   */
			  curptr = find_device( dcurdevice );
			  if( curptr && ( curptr != dcurptr ) )
			  {
			     if( form_alert( 1, alert55 ) == 2 )
			     {
			         /* Cancel */
			         XDeselect( tree, MOK );
			         return( quit );
			     }
			     DeleteDevice( dcurdevice );			     
			  }
			  
			  /* If this is the printer device, clear the cur_cdriver variable
			   * BUT ONLY if the new device is not the printer device.
			   */
			  if( ( DDEV( dcurptr ) == 21 ) && ( dcurdevice != 21 ))
			      cur_cdriver = -1;
			      
     		          DDEV( dcurptr )  = dcurdevice; 
     		          DNAME( dcurptr ) = dcurvalue;
     		          DTYPE( dcurptr ) = dcurflag;
     		          SortDevices();   
     		       }
		    }


		    /* ADD A NEW DEVICE! */
		    if( dtype == DADD )
		    {
		       /* Get the Device Value */
		       dcurdevice = atoi( numtext );
  
  		       /* Check if we are within limits */
  		       if( ( dcurdevice < MIN_DEV ) ||
  		           ( dcurdevice >= MAX_NUM_DEV ))
  		       {
  		          /* NO- WE ARE NOT! */
  		          form_alert( 1, alert57 );
			  XDeselect( tree, MOK );
  		          return( quit );
  		       }
  		       
  		       /* See if the device already EXISTS! */
  		       dcurptr = find_device( dcurdevice );
  		       if( dcurptr )
  		       {
  		          /* YES! REPLACE! or REFACE!*/
			  if( form_alert( 1, alert55 ) == 2 )
			  {
			      /* Cancel */
			      XDeselect( tree, MOK );
			      return( quit );
			  }
			  /* REPLACE! So Delete that device */
			  DeleteDevice( dcurdevice );			     
  		       }
  		       
  		       /* no more ROOM! */
  		       dcurptr = AddNewDevice( dcurdevice );
  		       if( !dcurptr )
  		       {
		          XDeselect( tree, MOK );
  		          return( quit );
  		       }   

		       /* Put the DATA INTO the Node */  		          
      		       DDEV( dcurptr )  = dcurdevice; 
     		       DNAME( dcurptr ) = dcurvalue;
     		       DTYPE( dcurptr ) = dcurflag;
		    }
		    SetChangeFlag();   
			
		    /* WRITE THE ASSIGN.SYS IMMEDIATELY */
		    write_assign();
		    
     case MCANCEL:  Deselect( button );
		    Reset_Tree( ad_device );     

		    Disable( DMODIFY );
		    Disable( DDELETE );
		    NoExit( DMODIFY );
		    NoExit( DDELETE );

		    device_mover_setup( device_head, device_count,
		    			DBASE, DSLIDE, DUP, DDOWN,
		    			DLINE0, DLINE11, DLINE, 0, 12 );

		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
     		    break;

     case MNAME:   XSelect( tree, MNAME );
     		   do
     		   {
	 	     Graf_mkstate( &mk );
	 	     obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
	 	     if( obj != MNAME )
	 	     {
	 	        if( IsSelected( MNAME ) )
	 	          XDeselect( tree, MNAME );
	 	     }

		     if( obj == MNAME )
		     {
		        if( !IsSelected( MNAME ) )
		          XSelect( tree, MNAME );
		     }	 	
	 	   }while( mk.buttons );
	 	     
 		   if( obj == MNAME )
		       DoNamePopUp();
		       
		   if( IsSelected( MNAME ) )    
		      XDeselect( tree, MNAME );    
		   break;

     case MRESYES:
     case MRESNO:
     case MROMYES:
     case MROMNO:  DoROMRES( button );
     		   break;


     case MUP:
     case MDOWN: DoUpDown( button );
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



/* DoNamePopUp()
 * ===================================================================
 */
void
DoNamePopUp( void )
{
      GRECT rect;
      long  value;
      int   item, id;

      InitPopUpMenus();
      SetSubMenuDelay( 300L );
      SetSubDragDelay( 3000L );
      SetArrowClickDelay( 150L );

      rect = ObRect( MNAME );
      objc_offset( tree, MNAME, &rect.g_x, &rect.g_y );
      menuid  = InsertPopUpMenu( display[0], driver_count, MENU_HEIGHT );

      CheckItem( menuid, dcurvalue, TRUE );
      SetStartItem( menuid, dcurvalue );
      
      /* Disable the Screen Item if the device num is > MIN_DEV */
      EnableItem( menuid, scrn_id );
      if(( dcurdevice > MIN_DEV ) )
          DisableItem( menuid, scrn_id );

      value = PopUpMenuSelect( menuid, rect.g_x, rect.g_y, dcurvalue );        
      if( value != -1L )
      {
         item  = (int)value;
         id = (int)( value >> 16L );

         if( ( item != -1 ) && ( id == menuid ) )
         {
            CheckItem( id, dcurvalue, FALSE );
            CheckItem( id, item, TRUE );
            dcurvalue = item;
            SetStartItem( id, item );
            
	    TedText( MNAME ) = drivers[ dcurvalue ];
	    RedrawObject( tree, MNAME );

	    /* If we have selected screen.sys, then disable
	     * the scrolling buttons IF we are at device 10 or less.
	     */
            if( ( dcurdevice <= MIN_DEV ) && ( scrn_id == dcurvalue ) )
            {
               if( !IsDisabled( MUP ) )
               {
	          Disable( MUP );
	          Disable( MDOWN );
	          Disable( MEDIT );
	          NoEdit( MEDIT );
	          NoTouchExit( MUP );
	          NoTouchExit( MDOWN );

	          RedrawObject( tree, MUP );
	          RedrawObject( tree, MDOWN );
	          RedrawObject( tree, MEDIT );
	       }  
            }
            else
            {
               if( ( dcurdevice >= MIN_DEV ) && IsDisabled( MUP ) )
               {
	          Enable( MUP );
	          Enable( MDOWN );
	          Enable( MEDIT );
	          MakeEditable( MEDIT );
	          MakeTouchExit( MUP );
	          MakeTouchExit( MDOWN );
	          
	          RedrawObject( tree, MUP );
	          RedrawObject( tree, MDOWN );
	          RedrawObject( tree, MEDIT );
               }
            }
	                
  	 }    
      }	
	
      DeletePopUpMenu( menuid );

}



/* DoROMRES()
 * =======================================================================
 * Handle the Current Driver ROM/RES flag.
 */
void
DoROMRES( int button )
{
    WaitForUpButton();
    
    if( button == MROMYES )
    {
        if( IsSelected( MROMNO ) )
           XDeselect( tree, MROMNO );
           
        if( !IsSelected( MROMYES ) )   
           XSelect( tree, MROMYES );
           
        if( IsSelected( MRESYES ) )
        {
            XDeselect( tree, MRESYES );
            XSelect( tree, MRESNO );
        }   
    }


    if( button == MROMNO )
    {
        if( IsSelected( MROMYES ) )
           XDeselect( tree, MROMYES );
        
        if( !IsSelected( MROMNO ))
           XSelect( tree, MROMNO );
    }



    if( button == MRESYES )
    {
        if( IsSelected( MRESNO ) )
           XDeselect( tree, MRESNO );
           
        if( !IsSelected( MRESYES ) )   
           XSelect( tree, MRESYES );

	if( !IsHidden( ROMBASE ) )
	{
          if( IsSelected( MROMYES ) )
          {
             XDeselect( tree, MROMYES );
             XSelect( tree, MROMNO );
          }   
        }  
    }


    if( button == MRESNO )
    {
        if( IsSelected( MRESYES ) )
           XDeselect( tree, MRESYES );
        
        if( !IsSelected( MRESNO ))
           XSelect( tree, MRESNO );
    }
}




/* DoUpDown()
 * =======================================================================
 * Handles the Up/Down Arrows for the device num
 */
void
DoUpDown( int button )
{
    MRETS mk;
    int   oldnum;
    int   redraw_flag;
            
    XSelect( tree, button );
    
    /* Get the text value of the device from the dialog box */
    redraw_flag = FALSE;
    dcurdevice = atoi( numtext );
  
    if( dcurdevice < MIN_DEV )
    {
       dcurdevice = MIN_DEV;
       redraw_flag = TRUE;
    }
    
    if( dcurdevice > ( MAX_NUM_DEV - 1 ) )
    {
       dcurdevice = ( MAX_NUM_DEV - 1 );
       redraw_flag = TRUE;
    }   

    do
    {
       oldnum = dcurdevice;

       if( button == MUP )
       {
         do
         {
           if( dcurdevice < ( MAX_NUM_DEV - 1 ) )	
     	      dcurdevice++;
     	   else
     	   {
     	      dcurdevice = oldnum;
     	      break;    
     	   }
     	   
     	   if( dcurdevice == startnum )
     	      break;
     	 }while( find_device( dcurdevice ) );  
       }
       else  /* button == MDOWN */
       {
         do
         {
	   if( dcurdevice >= MIN_DEV )
     	      dcurdevice--;
     	   else
     	   {
     	      dcurdevice = oldnum;
     	      break;   
     	   }
     	   
     	   if( dcurdevice == startnum )
     	      break;   
     	 }while( find_device( dcurdevice ) );     
       
       }

       if( ( oldnum != dcurdevice ) || redraw_flag )
       {
         /* Check if we should display ROM variables or NOT.
          * We display them if the device is 10 or less.
          */
         if( dcurdevice > MIN_DEV )
         {
         
            if( !IsHidden( ROMBASE ) )
            {
              HideObj( ROMBASE );
              HideObj( ROMTITLE );
              RedrawObject( tree, ROMBASE );
              RedrawObject( tree, ROMTITLE );
            }   
         }
         else
         {
            if( IsHidden( ROMBASE ) )
            {
              ShowObj( ROMBASE );
              ShowObj( ROMTITLE );
              RedrawObject( tree, ROMBASE );
              RedrawObject( tree, ROMTITLE );
            }
         }
         /* Display the new Device Num */
         sprintf( numtext, "%d", dcurdevice );
         TedText( MEDIT ) = numtext;
        
         Objc_draw( tree, MEDIT, MAX_DEPTH, NULL );
       }  
           
       Evnt_timer( 100L );
       Graf_mkstate( &mk );
    }while( mk.buttons );   
    
    XDeselect( tree, button );
}
