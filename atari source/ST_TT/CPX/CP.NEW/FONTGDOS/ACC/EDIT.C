/* FILE:  EDIT.C
 * ========================================================================
 * DATE:  January 7, 1991
 * DESCRIPTION: Handle the Device Editing Tree
 *
 * INCLUDE FILE: EDIT.H
 *
 * April 26, 1991 cjg	Fixed AddDevice() routine to display the
 *			proper state of the delete key.
 * Sept  11, 1991 cjg   Adjusted for DA
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
#include "popup.h"
#include "path.h"
#include "text.h"

struct foobar {
	WORD	dummy;
	WORD	*image;
	};


/* PROTOTYPES
 * ========================================================================
 */
void DoEditDevices( void );
void InitActiveEdit( void );

int  Edit_Button( int button, WORD *msg );

void CurDeviceUpDown( int button );
void DoCurDrivers( void );
void DoCurROMRES( int button );

void DoADrivers( void );
void DoAROMRES( int button );
void ADeviceUpDown( int button );

void DeleteDevice( void );
void AddDevice( void );

void SetATitle( int device, int old_device, BOOLEAN flag );



/* DEFINES
 * ========================================================================
 */
#define UNDO	0x6100
#define MIN_DEV 10


#define MONITOR		0
#define PLOTTER	 	1
#define PRINTER		2
#define METAFILE	3
#define CAMERA   	4
#define TABLET   	5
#define OTHER_DEV	6

#define DRAW	1
#define NO_DRAW 0



/* GLOBALS
 * ========================================================================
 */
DEV_PTR  xdevice;	/* device number index we are messing with - Active Drivers  */
int      adevice;	/* device number index we are messing with - Available Driver */

char DeviceText[3];	/* Text to display device number - Active */
char DriverText[15];	/* Text to display driver name   - Active */

char ADeviceText[3];	/* Text to display device number - Available Driver */
char ADriverText[15];   /* Text to display driver name - Available Driver   */

int  CurHotDriver;
int  AHotDriver;

char *CurNames[ MAX_DRIVERS ];  /* Names of the drivers to display in the popup */


/* FUNCTIONS
 * ========================================================================
 */


/* DoEditDevices()
 * ========================================================================
 * Add, Delete devices...
 */
void 
DoEditDevices( void )
{
   PrevTree = ad_menu;
   Reset_Tree( ad_edit );
  
   xdevice = device_head;

   if( driver_count <= 1 )
   {
      NoTouchExit( CURNAME );
      NoTouchExit( ANAME );
      Disable( CURNAME ); 
      Disable( ANAME );
   }
   else
   {
      MakeTouchExit( CURNAME );
      MakeTouchExit( ANAME );
      Enable( CURNAME );
      Enable( ANAME );
   }
   
      
   InitActiveEdit();
   
   /* SETUP the Available Driver Information
    * =====================================================================
    */
   adevice = MIN_DEV;	/* Set the initial device - unless its a device...*/

   /* Check to see if the device exists. If it does, increment and check again
    * until we don't have an active device.
    */   
   while( find_device( adevice ) )
   	adevice++;
   
   /* Set a global index number for the device editor so that we
    * know which one is currently being displayed. Note that this is
    * for the active drivers.
    */   
   /* Display the device number in text form. */              
   sprintf( ADeviceText, "%d", adevice );
   TedText( ANUM ) = &ADeviceText[0];

   /* Display the driver name in text form ( includes the .SYS ) */
/*   AHotDriver = find_driver( "SCREEN.SYS" );*/
   AHotDriver = -1;
   
   /* Start out with no driver listed - NONE */
/* strcpy( ADriverText, drivers[ AHotDriver ] );*/
   strcpy( ADriverText, driver_null );
   TedText( ANAME ) = &ADriverText[0];

   /* Set the ROM/RES flags */
   Deselect( AROM );
   Deselect( ARES );
   
   /* Can't add till they select a driver */
   Deselect( EADD );
   NoExit( EADD );
   Disable( EADD );
    
   SetATitle( adevice, 0, NO_DRAW );
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}




/* InitActiveEdit()
 * =====================================================================
 * Initializes the Active Device display to preset initial values.
 * the device to display is in xdevice.
 */
void
InitActiveEdit( void )
{
   /* Set a global index number for the device editor so that we
    * know which one is currently being displayed. Note that this is
    * for the active drivers.
    */   
   CurHotDriver = DNAME( xdevice );   
   NoExit( EDELETE );
   Disable( EDELETE );

   /* Display the device number in text form. */              
   sprintf( DeviceText, "%d", DDEV( xdevice ) );
   TedText( CURNUM ) = &DeviceText[0];

   /* Display the driver name in text form ( includes the .SYS ) */
   strcpy( DriverText, drivers[ DNAME( xdevice )] );
   TedText( CURNAME ) = &DriverText[0];

   /* Set the ROM/RES flags */
   Deselect( CURROM );
   Deselect( CURRES );
   
   if( DTYPE( xdevice ) == 'P' )	/* ROM driver - SCREEN.SYS */
        Select( CURROM );

   if( DTYPE( xdevice ) == 'R' )    /* Resident Driver */
   	Select( CURRES );
}




/* Edit_Button()
 * ========================================================================
 * Handle Edit Devices Tree Buttons...
 */
int
Edit_Button( int button, WORD *msg )
{
  int quit = FALSE;
      
  if( ( button != -1 ) && ( button & 0x8000 ) )
     button &= 0x7FFF;      

  switch( button )
  {
     case EEXIT:   Deselect( EEXIT );
     		   RestoreMainTree();
     		   break;

     case EDELETE: DeleteDevice();
     		   break;
     		   
     case EADD:    AddDevice();
     		   break;
     		        
     case CURUP:
     case CURDOWN: CurDeviceUpDown( button );
     		   break;

     case CURNAME: DoCurDrivers();
     		   break;

     case CURROM:
     case CURRES:  DoCurROMRES( button );
     		   break;
     		        		        		   		
     case AUP:
     case ADOWN: ADeviceUpDown( button );
     		 break;
     		 
     case ANAME: DoADrivers();
     		 break;
     		 
     case AROM:
     case ARES:  DoAROMRES( button );
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


 
 
/* CurDeviceUpDown()
 * =======================================================================
 * Handles the up/down buttons on displaying an active driver and device.
 * so that we can decide which driver to transfer fonts to.
 */
void
CurDeviceUpDown( int button )
{
   MRETS mk;
   DEV_PTR  olddev;
   GRECT rect;
      
   select( tree, button );
   do
   {
      olddev = xdevice;
      
      if( button == CURUP )
      {
         if( DNEXT( xdevice ) )
             xdevice = DNEXT( xdevice );
      }
      else
      {
         if( DPREV( xdevice ) )
             xdevice = DPREV( xdevice );
      }

      if( olddev != xdevice )
      {
        sprintf( DeviceText, "%d", DDEV( xdevice ) );
        TedText( CURNUM ) = &DeviceText[0];
        
        CurHotDriver = DNAME( xdevice );
        strcpy( DriverText, drivers[ DNAME( xdevice )] );
        TedText( CURNAME ) = &DriverText[0];

	/* Take care of the ROM/RES flags */
	Deselect( CURROM );
	Deselect( CURRES );
	
	if( DTYPE( xdevice ) == 'P' )	/* ROM driver */
	     Select( CURROM );
	
	if( DTYPE( xdevice ) == 'R' )	/* Resident Driver */
	     Select( CURRES );
	
        Objc_draw( tree, CURNUM, MAX_DEPTH, NULL );
        Objc_draw( tree, CURNAME, MAX_DEPTH, NULL );
        Objc_draw( tree, CURROM, MAX_DEPTH, NULL );
        Objc_draw( tree, CURRES, MAX_DEPTH, NULL );

	/* Let's check and redraw the DELETE driver key only
	 * when the device # is >= 9 so that it won't blink.
	 */
	if( DDEV( xdevice ) >= 9 )
	{
          /* turn on/off the EDELETE button here too */
          rect = ObRect( EDELETE  );
          objc_offset( tree, EDELETE, &rect.g_x, &rect.g_y );

	  rect.g_x -= 3;
	  rect.g_y -= 3;
	  rect.g_w += 6;
	  rect.g_h += 6;
        
          if( DDEV( xdevice ) > 9 )
          {
             MakeExit( EDELETE );
             Enable( EDELETE );
          }
          else
          {
             NoExit( EDELETE );
	     Disable( EDELETE );           
          }
          Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
        }  
      }  
      Evnt_timer( 100L );
      
      Graf_mkstate( &mk );
   }while( mk.buttons );
   
   deselect( tree, button );
}




/* DoCurDrivers()
 * =======================================================================
 * Display in a popup the current drivers available.
 */
void
DoCurDrivers( void )
{
   int i;
   int Item;
   int temp;

   /* if there are no drivers, don't use the popup menu */
   if( !driver_count )
       return;
          
   for( i = 0; i < driver_count; i++ )
        CurNames[i] = &drivers[i][0];

   temp = CurHotDriver;
   Item = Pop_Handle( tree, CURNAME, CurNames, driver_count, &CurHotDriver, IBM, 15 );
   if( Item != -1 )
   {
      CurHotDriver = Item;
      strcpy( DriverText, drivers[ Item ] );
      TedText( CURNAME ) = &DriverText[0];
      Objc_draw( tree, CURNAME, MAX_DEPTH, NULL );
      DNAME( xdevice ) = Item;   
   }
   if( CurHotDriver != temp )
      SetChangeFlag();   
}

       			           


/* DoCurROMRES()
 * =======================================================================
 * Handle the Current Driver ROM/RES flag.
 */
void
DoCurROMRES( int button )
{
    wait_up();
    if( button == CURROM )	/* ROM key pressed...  */
    {
        if( IsSelected( CURROM ) )
             deselect( tree, CURROM );
        else     
        {
           select( tree, CURROM );
           if( IsSelected( CURRES ) )
               deselect( tree, CURRES );
        }     
    }
    else			/* RESident key pressed */
    {
        if( IsSelected( CURRES ) )
            deselect( tree, CURRES );
        else
        {
           select( tree, CURRES );
           if( IsSelected( CURROM ) )
               deselect( tree, CURROM );
        }
    }

    DTYPE( xdevice ) = ' ';
    if( IsSelected( CURROM ) )
       DTYPE( xdevice  ) = 'P';
    
    if( IsSelected( CURRES ) )
       DTYPE( xdevice ) = 'R';
    SetChangeFlag();   
}




/* DoADrivers()
 * =======================================================================
 * Handle the Available Driver Popup
 */
void
DoADrivers( void )
{
   int i;
   int Item;
   GRECT rect;
   
   /* If there are no drivers, don't use the popup menu */
   if( !driver_count )
       return;
          
   for( i = 0; i < driver_count; i++ )
        CurNames[i] = &drivers[i][0];

   Item = Pop_Handle( tree, ANAME, CurNames, driver_count, &AHotDriver, IBM, 15 );
   if( Item != -1 )
   {
      AHotDriver = Item;
      strcpy( ADriverText, drivers[ Item ] );
      TedText( ANAME ) = &ADriverText[0];
      Objc_draw( tree, ANAME, MAX_DEPTH, NULL );
      
      /* turn off the EADD button here too */
      rect = ObRect( EADD  );
      objc_offset( tree, EADD, &rect.g_x, &rect.g_y );

      rect.g_x -= 3;
      rect.g_y -= 3;
      rect.g_w += 6;
      rect.g_h += 6;
        
      MakeExit( EADD );
      Enable( EADD );           
      Deselect( EADD );
      Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
   }
}




/* DoAROMRES()
 * =======================================================================
 * Handle the Current Driver ROM/RES flag.
 */
void
DoAROMRES( int button )
{
    wait_up();
    if( button == AROM )	/* ROM key pressed...  */
    {
        if( IsSelected( AROM ) )
             deselect( tree, AROM );
        else     
        {
           select( tree, AROM );
           if( IsSelected( ARES ) )
               deselect( tree, ARES );
        }     
    }
    else			/* RESident key pressed */
    {
        if( IsSelected( ARES ) )
            deselect( tree, ARES );
        else
        {
           select( tree, ARES );
           if( IsSelected( AROM ) )
               deselect( tree, AROM );
        }
    }
}




/* ADeviceUpDown()
 * =======================================================================
 * Handles the up/down buttons on displaying an available device.
 * so that we can decide which driver to transfer fonts to.
 */
void
ADeviceUpDown( int button )
{
   MRETS mk;
   int   oldnum;
      
   select( tree, button );
   do
   {
      oldnum = adevice;
      
      /* when moving among the devices, check to see if they are
       * active. If so, we skip them and go on to the next
       */
      if( button == AUP )
      {
         do
         {
           if( adevice < ( MAX_NUM_DEV - 1 ) )	
     	      adevice++;
     	   else
     	   {
     	      adevice = oldnum;
     	      break;    
     	   }   
     	 }while( find_device( adevice ) );  
     	 
      }
      else
      {
         do
         {
	   if( adevice > MIN_DEV )
     	      adevice--;
     	   else
     	   {
     	      adevice = oldnum;
     	      break;   
     	   }   
     	 }while( find_device( adevice ) );     
      }

      if( oldnum != adevice )
      {
        sprintf( ADeviceText, "%d", adevice );
        TedText( ANUM ) = &ADeviceText[0];
        
        Objc_draw( tree, ANUM, MAX_DEPTH, NULL );

        SetATitle( adevice, oldnum, DRAW );
      }  
      Evnt_timer( 100L );
      
      Graf_mkstate( &mk );
   }while( mk.buttons );
   
   deselect( tree, button );
}



/* DeleteDevice()
 * =======================================================================
 * Delete the Active Device in the Edit Device tree.
 */
void
DeleteDevice( void )
{
    GRECT   rect;
    DEV_PTR temp_device;
    
    wait_up();
    
    if( form_alert( 1, alert1 ) == 2 )
    {
       deselect( tree, EDELETE );
       return;
    }       
    if( device_count == 0 ) return;

    SetChangeFlag();
     
    temp_device = xdevice;
    if( DNEXT( xdevice ) )
        DPREV( DNEXT( xdevice ) ) = DPREV( xdevice );
        
    if( DPREV( xdevice ) )    
        DNEXT( DPREV( xdevice ) ) = DNEXT( xdevice );
    ClearDeviceFont( xdevice );
    
    
    /* Fix up device count */
    device_count--;
    
    /* Change display since we're looking at deleted a device 
     * We shall use xdevice - 1 if there is no device.
     */
     if( DNEXT( xdevice ) )
     	 xdevice = DNEXT( xdevice );
     else
         xdevice = DPREV( xdevice );
         
     DNEXT( temp_device ) = DPREV( temp_device ) = ( DEV_PTR )NULL;
     DDEV( temp_device ) = 0;    
         
     CurHotDriver = DNAME( xdevice );   
     NoExit( EDELETE );
     Disable( EDELETE );

     /* Display the device number in text form. */              
     sprintf( DeviceText, "%d", DDEV( xdevice ) );
     TedText( CURNUM ) = &DeviceText[0];

     /* Display the driver name in text form ( includes the .SYS ) */
     strcpy( DriverText, drivers[ DNAME( xdevice )] );
     TedText( CURNAME ) = &DriverText[0];

     /* Set the ROM/RES flags */
     Deselect( CURROM );
     Deselect( CURRES );
   
     if( DTYPE( xdevice ) == 'P' )	/* ROM driver - SCREEN.SYS */
        Select( CURROM );

     if( DTYPE( xdevice ) == 'R' )    /* Resident Driver */
   	Select( CURRES );

     Objc_draw( tree, CURNUM, MAX_DEPTH, NULL );
     Objc_draw( tree, CURNAME, MAX_DEPTH, NULL );
     Objc_draw( tree, CURROM, MAX_DEPTH, NULL );
     Objc_draw( tree, CURRES, MAX_DEPTH, NULL );

     /* turn on/off the EDELETE button here too */
     rect = ObRect( EDELETE  );
     objc_offset( tree, EDELETE, &rect.g_x, &rect.g_y );

     rect.g_x -= 3;
     rect.g_y -= 3;
     rect.g_w += 6;
     rect.g_h += 6;
        
     if( DDEV( xdevice ) > 9 )
     {
       MakeExit( EDELETE );
       Enable( EDELETE );
     }
     else
     {
       NoExit( EDELETE );
       Disable( EDELETE );           
     }
     Deselect( EDELETE );
     Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
     
     /* Check if the device deleted is the current_device.
      * if so, we have to update the current_device to a new device.
      */
     if( temp_device == current_device )
     	 current_device = xdevice;
     	 
     if( temp_device == device_head )
         device_head = xdevice;	 
}




/* AddDevice()
 * =======================================================================
 * Add a new device.
 * int adevice - >   devnum to add.
 * int AHotDriver->  Index into driver list of driver for the device.
 *
 */
void
AddDevice( void )
{
     GRECT   rect;
     DEV_PTR temp_device;     
 
     wait_up();

     if( form_alert( 1, alert2 ) == 2 )
     {
        deselect( tree, EADD );
     	return;
     }	
     
     SetChangeFlag();	
          
     temp_device = AddNewDevice( adevice );
     if( temp_device )
     {
        /* found a slot and added it to the device linked list array. */
	DNAME( temp_device ) = AHotDriver;         
	if( IsSelected( AROM ) )
	    DTYPE( temp_device ) = 'P';
	
	if( IsSelected( ARES ) )
	    DTYPE( temp_device ) = 'R';    
	
	xdevice = temp_device;
	InitActiveEdit();
	

	/* re-init the inactive devices. 
	 * we only need to check for the device, not everything else.
	 */
   	 adevice = MIN_DEV;	/* Set the initial device - unless its a device...*/

   	/* Check to see if the device exists. If it does, increment and check again
    	 * until we don't have an active device.
    	 */   
   	 while( find_device( adevice ) )
   	        adevice++;
   
   	/* Set a global index number for the device editor so that we
	 * know which one is currently being displayed. Note that this is
         * for the active drivers.
    	 */   
   	/* Display the device number in text form. */              
   	 sprintf( ADeviceText, "%d", adevice );
   	 TedText( ANUM ) = &ADeviceText[0];
		
	 Objc_draw( tree, CURNUM, MAX_DEPTH, NULL );	
	 Objc_draw( tree, CURNAME, MAX_DEPTH, NULL );
	 Objc_draw( tree, CURROM, MAX_DEPTH, NULL );
	 Objc_draw( tree, CURRES, MAX_DEPTH, NULL );
	
	 Objc_draw( tree, ANUM, MAX_DEPTH, NULL );

         /* turn on/off the EDELETE button here too */
         rect = ObRect( EDELETE  );
         objc_offset( tree, EDELETE, &rect.g_x, &rect.g_y );

         rect.g_x -= 3;
         rect.g_y -= 3;
         rect.g_w += 6;
         rect.g_h += 6;
        
         if( DDEV( temp_device ) > 9 )
         {
           MakeExit( EDELETE );
           Enable( EDELETE );
         }
         else
         {
           NoExit( EDELETE );
           Disable( EDELETE );           
         }
         Deselect( EDELETE );
         Objc_draw( tree, ROOT, MAX_DEPTH, &rect );

	 device_count++;
     }

     /* Reset the driver name to NONE */
     strcpy( ADriverText, driver_null );
     TedText( ANAME ) = &ADriverText[0];
     Objc_draw( tree, ANAME, MAX_DEPTH, NULL );

     /* Set the ROM/RES flags */
     deselect( tree, AROM );
     deselect( tree, ARES );
     AHotDriver = -1;

     /* turn off the EADD button here too */
     rect = ObRect( EADD  );
     objc_offset( tree, EADD, &rect.g_x, &rect.g_y );

     rect.g_x -= 3;
     rect.g_y -= 3;
     rect.g_w += 6;
     rect.g_h += 6;
        
     NoExit( EADD );
     Disable( EADD );           
     Deselect( EADD );
     Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
}




/* SetATitle( )
 * =======================================================================
 * Set the Available Devices Title to a Device Name.
 *             SCREEN      1-10
 *	       PLOTTER	  11-20
 *	       PRINTER	  21-30
 *	       METAFILE	  31-40
 *	       CAMERA	  41-50
 *	       TABLET	  51-60
 *	       Other      61-99
 */
void
SetATitle( int device, int old_device, BOOLEAN draw_flag )
{
   int index;
   
   if( device <= 10 )
   {
   	index = MONITOR;
   	if( old_device <= 10 )
   	    draw_flag = FALSE;
   }
   
   	
   if( ( device >= 11 ) && ( device <= 20 ) )	    
   {
        index = PLOTTER;
        if( ( old_device >= 11 ) && ( old_device <= 20 ) )	    
   	    draw_flag = FALSE;
   }
   
        
   if( ( device >= 21 ) && ( device <= 30 ) )
   {
        index = PRINTER;
        if( ( old_device >= 21 ) && ( old_device <= 30 ) )
            draw_flag = FALSE;
   }     
        
   if( ( device >= 31 ) && ( device <= 40 ) )
   {
        index = METAFILE;
        if( ( old_device >= 31 ) && ( old_device <= 40 ) )
              draw_flag = FALSE;
   }     
        
   if( ( device >= 41 ) && ( device <= 50 ) )
   {
        index = CAMERA;
        if( ( old_device >= 41 ) && ( old_device <= 50 ) )
              draw_flag = FALSE;
              
   }     
   
   if( ( device >= 51 ) && ( device <= 60 ) )
   {
        index = TABLET;
        if( ( old_device >= 51 ) && ( old_device <= 60 ) )
              draw_flag = FALSE;
   }     
   
   if( device >= 61 )
   {
        index = OTHER_DEV;
        if( old_device >= 61 )
            draw_flag = FALSE;
   }     
        
        
   TedText( ATITLE ) = DevTitles[ index ];
   
   if( draw_flag )
      Objc_draw( tree, ATITLE, MAX_DEPTH, NULL );
}

