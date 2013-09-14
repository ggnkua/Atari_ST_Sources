/* FILE:  XCONTROL.C
 *==========================================================================
 * DATE:  January 16, 1990
 * DESCRIPTION:
 *
 * INCLUDE FILES:   XCONTROL.H
 *		    XCONTRL2.H
 * 04/28/92 cjg - changed VERSION to 0x0101 for version 1.01
 * 07/07/92 cjg - save and restore mouse form only if AES 3.2 or greater.
 *		  Skip changing mouse form otherwise...
 * 07/14/92 cjg - added gl_ncolors
 *		- added 3D changes
 * 07/28/92 cjg - Check for Version 0x0330 ( 3D )
 * 12/16/92 cjg - Make sure open_vwork() exits if fails.
 * 01/14/93 cjg - Put in new 3D format
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>

#include "country.h"
#include "xcontrol.rsh"
#include "xcontrol.h"

#include "cpxdata.h"				/* Keep these in order    */
#include "xstructs.h"
#include "cpxhandl.h"				/* Cpxhandl Prototypes    */
#include "slots.h"

#include "fixrsh.h"				/* Fixrsh Prototypes	  */
#include "popstuff.h"				/* Popup Prototypes	  */

#include "sliders.h"				/* Slider Prototypes	  */
#include "timedate.h"				/* TimeDate Prototypes	  */
#include "xconfig.h"				/* Xconfig Prototypes     */
#include "xform_do.h"				/* xformdo prototypes	  */
#include "windows.h"
#include "xerror.h"
#include "stuffptr.h"

#include "xoptions.h"
#include "cookie.h"
#include "mover.h"

#include "text.h"



/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par


/* PROTOTYPES
 *==========================================================================
 */
void    init_slider( void );
void	handle_slider( int obj );
void	draw_slider( void );
BOOLEAN	AES_Check( void );
EXTERN  int AES_Version;

void	Do3D( void );
void	MakeIndex( int xtree, int obj );
void	MakeTed( int xtree, int obj );
void	MakeIndicator( int xtree, int obj );
void	MakeActivator( int xtree, int obj );



/* DEFINES
 *==========================================================================
 */
#define AES_VERSION	0x300		/* AES Version 3.01 */
#define XVERSION        0x0120		/* XCONTROL Version 1.2 */



/* GLOBALS
 *==========================================================================
 */
int ctrl_id;			/* ACC id slot #        	    */
int cur_slot = 0;		/* Current top slot index into nodex*/
int old_slot = 0;		/* Old Slot for when moving sliders */

int Event1_Mask = ( MU_BUTTON | MU_MESAG | MU_KEYBD | MU_TIMER );
int Event2_Mask = ( MU_MESAG );

int nplanes;
int gl_ncolors;




/* FUNCTIONS
 *==========================================================================
 */


/* open_vwork(); 
 *==========================================================================
 * Open the Virtual Workstation
 */
int
open_vwork( void )
{
	int i;
 
	work_in[0] = Getrez()+2; /* let's not gag GDOS */
	for( i = 1; i < 10; work_in[i++] = 1 )
	;
	work_in[10] = 2; /* raster coordinates */
	vhandle = phys_handle;
	v_opnvwk( work_in, &vhandle, work_out );
	xres = work_out[0];
	yres = work_out[1];
	return( vhandle );
}


/* close_vwork();
 *==========================================================================
 * Close the virtual workstation
 */
void
close_vwork( void )
{
   if( vhandle != -1 )
   {
       v_clsvwk( vhandle );
       vhandle = -1;
   }
}


 
 
/* rsrc_init()
 *==========================================================================
 * Initialize resource and xcpb structure
 *
 * IN: void
 * OUT: BOOLEAN	- We, uh, always return TRUE...
 *
 * GLOBALS:   All of the rsh variables for the fixup...
 *	      XCPB xcpb:	xcpb structure for passing to the cpx
 */
BOOLEAN
rsrc_init(void)
{
   fix_rsh( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE, rs_object,
            rs_tedinfo, rs_strings, rs_iconblk, rs_bitblk, rs_frstr,
            rs_frimg, rs_trindex, rs_imdope );

   vq_extnd( phys_handle, 0 , work_out );
   gl_ncolors = work_out[13];	/* # of Pens */



   /* Convert to 3D if possible - ONLY if AES 0x0330 or Greater */
   if(( AES_Version >= 0x0330 )
     && ( gl_ncolors > LWHITE ))
   {
       Do3D();
   }

   vq_extnd( phys_handle, 1 , work_out );
   nplanes = work_out[4];
  /*
   * XCPB CPX Data Structure XCONTROL inits go here ...
   */   
   xcpb.handle    = phys_handle;

   xcpb.booting	  = TRUE;		/* TRUE = cold boot init    */
   					/* FALSE = warm boot init   */

   xcpb.reserved  = XVERSION;
      					
   xcpb.SkipRshFix = FALSE;		/* Will Skip FixRsh only if */
   					/* Executing from resident  */   

   xcpb.res1 	      = Get_Head_Node;
   xcpb.res2	      = Save_Header; 

   xcpb.rsh_fix   = fix_rsh;
   xcpb.rsh_obfix = Rsrc_obfix; 
   
   xcpb.Popup     = Pop_Up;
   					
   xcpb.Sl_size	  = sl_size;
   xcpb.Sl_x	  = sl_x;
   xcpb.Sl_y	  = sl_y;
   xcpb.Sl_arrow  = sl_arrow;
   xcpb.Sl_dragx  = sl_dragx;
   xcpb.Sl_dragy  = sl_dragy;
   
   xcpb.Xform_do     = xform_do;
   xcpb.GetFirstRect = GetFirstRect;
   xcpb.GetNextRect  = GetNextRect;

   xcpb.Set_Evnt_Mask = SetEvntMask;   
   xcpb.XGen_Alert    = XGen_Alert;
   xcpb.CPX_Save      = CPX_Save;
   xcpb.Get_Buffer    = Get_Buffer;

   xcpb.getcookie     = Get_Cookie;
   
   /* These are the country codes returned to the
    * CPX(s).  They can be found on page 63 of the Rainbow
    * TOS Release Notes
    */
    
   #if USA
       xcpb.Country_Code  = 0;
   #endif
   
   #if UK
       xcpb.Country_Code  = 3;
   #endif
 
   #if GERMAN
       xcpb.Country_Code  = 1;
   #endif
  
   #if FRENCH
       xcpb.Country_Code  = 2;
   #endif
 
   #if SPAIN
       xcpb.Country_Code  = 4;
   #endif
    
   #if SWEDEN
       xcpb.Country_Code  = 6;
   #endif

   #if ITALY
       xcpb.Country_Code  = 5;
   #endif
   
   xcpb.MFsave = MFsave;
   
   /* if AES > 3.01, use only 2 menu items, not 3 */
   if( AES_Check() )
       num_xoptions = XOPT_NOCPX = XOPT1_NOCPX;
   else    
       num_xoptions  = XOPT_NOCPX = XOPT2_NOCPX;
   return(TRUE);      
}



/* wind_init()
 *==========================================================================
 * Initialize window structure
 */
void
wind_init(void)
{
   if( !_app )
        ctrl_id = menu_register( gl_apid, Menu_Text );

   init_window();
   get_defaults();
   init_time();
   
   graf_mouse( BUSYBEE, 0L );
   init_cpxs();
   graf_mouse( ARROW, 0L );
   
   fsel_init();
   linea_init();
   xcpb.booting = FALSE;

   if( _app )
   {
   	open_window();
        init_slider();
        assign_slots( hdptr );
   }
}





/* evnt_init()
 *==========================================================================
 * Initialize the event_multi with the proper messages, timers etc...
 */ 
void
evnt_init(void)
{
/*     evnt_set( Event1_Mask, 2, 1, 1, NULL, NULL, 30000L );*/
     /* We are looking ONLY for evnt messages - ACC_OPEN and ACC_CLOSE */
     evnt_set( Event2_Mask, -1, -1, -1, NULL, NULL, -1L );
     if( _app )
	  evnt_set( Event1_Mask, 2, 1, 1, NULL, NULL, 30000L );
}




/* do_windows()
 *==========================================================================
 * window handling...
 *
 * IN:  int *msg:	message buffer
 *	int *event:	flag to end the program
 *
 * OUT: void
 */
void
do_windows( int *msg, int *event )
{
   switch( msg[0] )
   {			
        case WM_REDRAW: Wm_Redraw( msg );
			break;
			
	case WM_NEWTOP:
	case WM_TOPPED: Wm_Topped( msg );
			break;
			
			
	case WM_CLOSED: Wm_Closed( msg );
			break;
			
	case WM_MOVED:  Wm_Moved( msg );
			break;
	default:
		 break;
   }
}




/* acc_open()
 *==========================================================================
 * Accessory Open Messages
 *
 * IN:   int *msg:	message buffer
 * OUT:  void
 *
 * GLOBAL: WINFO w:	window structure
 *	   int ctrl_id: application id
 */	   
void
acc_open( const int *msg )
{


    if( msg[4] == ctrl_id )
    {
       if( hdptr )
       {
           if( w.id == NO_WINDOW )
           {
       	     if( open_window())			
       	     {
	        evnt_set( Event1_Mask, 2, 1, 1, NULL, NULL, 30000L );
       	     
       	        init_slider();
       	        assign_slots( hdptr );
       	        update_time();
       	        clear_active_slot( FALSE );
	        SetCPXstate( CPX_INACTIVE );
       	     }				 
           }				 
           else				 
       	     wind_set( w.id, WF_TOP ); 
       }
       else
         form_alert( 1, Shut_String );
    }
   
}






/* acc_close()
 *==========================================================================
 * Accessory Close message
 *
 * IN:   int *msg:	message buffer
 * OUT:  void
 *
 * GLOBAL:  int ctrl_id:	application id
 *	    WINFO w:		window structure
 * 
 * Closing and deleting the window are unnecessary since the window
 * handles are already invalid by the time we get the acc_close() message
 */
void
acc_close( const int *msg )
{
     if(( msg[3] == ctrl_id ) && ( w.id != NO_WINDOW ) )
     {

        w.id = NO_WINDOW;
        clear_active_slot( FALSE );
        close_xconfig( TRUE );

	Close_Call_CPX( TRUE );
	Shut_CPX_Down( FALSE );
        evnt_set( Event2_Mask, -1, -1, -1, NULL, NULL, -1L );
     }
}




/* do_button()
 *==========================================================================
 * Button handling routines
 *
 * IN:    MRETS *mrets:		mouse information
 *        int nclicks:		number of clicks;
 *	  int *event:		flag to end program
 *
 * OUT:    void
 *
 * GLOBAL: int xconfig:		which xconfig option active? -1 if none
 *	   WINFO  w:		window structure
 */
void
do_button( MRETS *mrets, int nclicks, int *event )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   int   top_window;
   int   obj;
   
   if( w.id == NO_WINDOW )
   		return;      
   wind_get( w.id, WF_TOP, &top_window );
   if( w.id == top_window )
   {
       if( IsCPXActive() )
       {
           cpx_button( mrets, nclicks );
       	   return;   
       }
       				    
       obj = objc_find( tree, XCONTROL, MAX_DEPTH, mrets->x, mrets->y );
       if( ( obj == TIME ) || ( obj == DATE ) )
       {
       	  clear_active_slot( TRUE );
	  time_date_stamp( obj );       
       }
       
       if( !IsXconfigActive() )
       {
         obj = objc_find( tree, XCONTROL, MAX_DEPTH, mrets->x, mrets->y );
         switch( obj )
         {
       	   case XOPTIONS: 
       	   		  xoptions( obj );
       	   		  clear_active_slot( !IsXconfigActive() );
       	   		  break;
       	   case SLOT0:
       	   case SLOT1:
       	   case SLOT2:
       	   case SLOT3:    handle_cpx( obj, nclicks );
        	          break;
       	   
       	   case UARROW:
       	   case DARROW:
       	   case SLIDER:
       	   case BASE:   handle_slider( obj );
       	   		break;		  
       	   		  
	   default:   clear_active_slot( TRUE );
	   	      break;          
         }
       }
       else
         Xconfig_buttons( mrets );
         
   }
}






/* do_timer()
 *==========================================================================
 */
void
do_timer( int *event ) 
{
   if( !IsCPXActive() )
   	time_handle();
   else
      cpx_timer();
}





/* do_key()
 *==========================================================================
 */
void
do_key( int kstate, int key, int *event )
{
  int    top_window;
  int    msg[8];
  
  if( w.id == NO_WINDOW )
         return;      
  wind_get( w.id, WF_TOP, &top_window );
  if( w.id == top_window )
  {
     if( !IsCPXActive() && !IsXconfigActive() )
     {
        if( ( key & 0xff ) == '\r')
        {
           msg[0] = WM_CLOSED;
           msg[1] = ctrl_id;
           msg[2] = 0;
           msg[3] = w.id;
           Wm_Closed( msg );
        }    
     }
     else
     {
       Xkeys_config( key );
       cpx_key( kstate, key );
     }  
  }
}



/* do_m1()
 *==========================================================================
 */
void
do_m1( MRETS *mrets, int *event )
{
   cpx_m1( mrets );
}



/* do_m2()
 *==========================================================================
 */
void
do_m2( MRETS *mrets, int *event )
{
   cpx_m2( mrets );
}




/* evnt_hook()
 *==========================================================================
 * OUT: BOOLEAN - return true if one wants to skip event_multi processing
 */
BOOLEAN
evnt_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks )
{
   return( cpx_hook( event, msg, mrets, key, nclicks ) );
}



/* handle_slider()
 *==========================================================================
 * Slider manipulation routines for XCONTROL.ACC
 *
 * IN:  int obj:	slider object
 * OUT: void
 *
 * GLOBAL: int num_active:	number of active cpxs
 *	   int cur_slot:	current value of the slider
 */
void
handle_slider( int obj )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
   MRETS mk;
   int ox,oy;
      
   clear_active_slot( TRUE );
   old_slot = cur_slot;
   
   /* The slider code for vertical sliders have the zero at the bottom
    * and max numbers at the top.  Since our vertical slider is the 
    * other way around ( low on top, max on bottom ), we must swap
    * the min and max numbers, plus, swap the sign of the incrementing
    * and decrementing numbers.
    */   
   switch( obj )
   {
       case UARROW:   sl_arrow( tree, BASE, SLIDER, UARROW, -1,
                                max( num_active - MAX_SLOTS, 0 ), 0,
                                &cur_slot, VERTICAL, draw_slider );
       		      break;
       		      
       case DARROW:   sl_arrow( tree, BASE, SLIDER, DARROW, 1,
                                max( num_active - MAX_SLOTS, 0 ), 0,
                                &cur_slot, VERTICAL, draw_slider );
       		      break;
       		      
       case SLIDER:   MFsave( MFSAVE, &mfOther );
		      if( AES_Version >= 0x0320 )	/* cjg 07/07/92 */
       		         graf_mouse( FLAT_HAND, 0L );
       		      if(( AES_Version >= 0x0330 )
		         && ( gl_ncolors > LWHITE ))
       		      	 xselect( tree, SLIDER, SLIDER );
       		      	    
       		      sl_dragy( tree, BASE, SLIDER,
                                max( num_active - MAX_SLOTS, 0 ),
                                0, &cur_slot, draw_slider );
                      if(( AES_Version >= 0x0330 )
		         && ( gl_ncolors > LWHITE ))
                      	xdeselect( tree, SLIDER, SLIDER );          
		      MFsave( MFRESTORE, &mfOther );
       		      break;

       case BASE:     Graf_mkstate( &mk );
       		      objc_offset( tree, SLIDER, &ox, &oy );
       		      ox = ( ( mk.y < oy )?( -MAX_SLOTS ):( MAX_SLOTS ) );
       		      sl_arrow( tree, BASE, SLIDER, -1, ox,
       		                max( num_active- MAX_SLOTS, 0 ), 0,
       		                &cur_slot, VERTICAL, draw_slider ); 
       		      break;
       		      
       default:
       		      break;
   }
   
}





/* draw_slider()
 *==========================================================================
 * Redraw XCONTROL slider due to scrolling
 *
 * IN: the stuff for redrawing stupid...:-)
 * OUT: void
 *
 * GLOBAL:  int cur_slot:    Current value of the slider. We can use this
 *			     because it hasn't yet been updated with value.
 *			     cur_slot, in draw_slider(), is really the
 *			     OLD value. :-)
 */
void
draw_slider( void )             
{
        slot_offset_adjust( cur_slot );	
	blit_slots( old_slot, cur_slot );
	old_slot = cur_slot;	
}



/* init_slider()
 *==========================================================================
 * Initialize the slider by setting the ROOT Y coordinate and sizing the
 * slider.
 *
 * GLOBAL: int cur_slot:	current value of the slider.
 */
void
init_slider( void )
{
     OBJECT *tree = ( OBJECT *)rs_trindex[ XCONTROL ];
  
     ObY( SLIDER ) = cur_slot = 0;
     sl_size( tree, BASE, SLIDER, num_active, MAX_SLOTS, VERTICAL, 0 );
}




/* AES_Check()
 *==========================================================================
 * If the Current AES version number that this system is running on is 
 * > 3.01 or AES_VERSION, we will not display the shutdown flag.
 */
BOOLEAN
AES_Check( void )
{
   return( AES_Version >= AES_VERSION );   	
}



/* Do3D()
 *==========================================================================
 */
void
Do3D( void )
{
   OBJECT *tree;

   tree = ( OBJECT *)rs_trindex[ XCONTROL ];

   MakeActivator( XCONTROL, UARROW );
   MakeActivator( XCONTROL, SLIDER );
   MakeIndicator( XCONTROL, BASE );
   MakeActivator( XCONTROL, DARROW );
   
   MakeIndex( XCONTROL, UARROW );
   MakeIndex( XCONTROL, SLIDER );
   MakeIndex( XCONTROL, DARROW );

   ObY( UARROW ) += 1;
   ObY( DARROW ) -= 3;
	
   ObY( BASE ) = ObY( UARROW ) + ObH( UARROW ) + 5;
   ObH( BASE ) = ( ObY( DARROW ) - 5 ) - ObY( BASE );
	
   ObY( SLOTBASE ) -= 1;
   ObW( SLOTBASE ) -= 2;
   ObW( SLOT0 )  -= 2;
   ObW( SLOT1 )  -= 2;
   ObW( SLOT2 )  -= 2;
   ObW( SLOT3 )  -= 2;
   ObW( SLOTB0 ) -= 2;
   ObW( SLOTB1 ) -= 2;
   ObW( SLOTB2 ) -= 2;
   ObW( SLOTB3 ) -= 2;
	
   tree = ( OBJECT *)rs_trindex[ XABOUT ];
   MakeActivator( XABOUT, ABOUTOK );
       
   tree = ( OBJECT *)rs_trindex[ CPXSTAT ];
   MakeActivator( CPXSTAT, XEXIT );



       
   tree = ( OBJECT *)rs_trindex[ XINFO ];
   MakeActivator( XINFO, LEFTNODE );
   MakeIndicator( XINFO, NODETEXT );
   MakeActivator( XINFO, RTNODE );
   MakeActivator( XINFO, CPXLEFT );
   MakeActivator( XINFO, CPXRIGHT );
   MakeIndicator( XINFO, CPXPATH );


   ObX( LEFTNODE ) -= 4;
   ObX( RTNODE ) += 4;
       
   ObX( CPXLEFT ) -= 1;
   ObX( CPXRIGHT ) += 1;
   ObW( CPXRIGHT ) -= 1;
   ObX( CPXPATH ) += 2;
   ObW( CPXPATH ) -= 4;

   MakeActivator( XINFO, XSAVE );
   MakeActivator( XINFO, OKOPTION );
   MakeActivator( XINFO, CANOPT );

   MakeIndex( XINFO, LEFTNODE );
   MakeTed( XINFO, NODETEXT );
   MakeIndex( XINFO, RTNODE );
       
   MakeIndex( XINFO, CPXLEFT );
   MakeIndex( XINFO, CPXRIGHT );
   MakeTed( XINFO, CPXPATH );
       

   ObIndex( STATBASE ) = ( ObIndex( STATBASE ) & 0xfffffff0L ) | LWHITE | 0x40;	
   ObIndex( RLDBASE ) = ( ObIndex( RLDBASE ) & 0xfffffff0L ) | LWHITE | 0x40;	
   ObIndex( B0 ) = ( ObIndex( B0 ) & 0xfffffff0L );	
   ObX( B0 ) -= 1;
   ObW( B0 ) += 1;
   ObW( STITLE ) += 1;
   ObY( STITLE ) += 1;
              
   ObIndex( B1 ) = ( ObIndex( B1 ) & 0xfffffff0L );	
   ObIndex( B2 ) = ( ObIndex( B2 ) & 0xfffffff0L );	
   ObIndex( B3 ) = ( ObIndex( B3 ) & 0xfffffff0L );	

   ObIndex( STITLE ) = ( ObIndex( STITLE ) & 0xffff0fffL );
   TedColor( CPXTITLE ) = ( TedColor( CPXTITLE ) & 0x0FF0L ) | 0;

   tree = ( OBJECT *)rs_trindex[ MOVECPX ];
   MakeActivator( MOVECPX, ROK );       
   MakeActivator( MOVECPX, MOVETEXT );       
   MakeActivator( MOVECPX, AUP );       
   MakeActivator( MOVECPX, ASLIDER );
   MakeIndicator( MOVECPX, ABASE );
   MakeActivator( MOVECPX, ADOWN );       
   MakeActivator( MOVECPX, IUP );       
   MakeActivator( MOVECPX, ISLIDER );       
   MakeIndicator( MOVECPX, IBASE );
   MakeActivator( MOVECPX, IDOWN );       

   ObW( TITLEA ) += 4;
   ObW( TITLEB ) += 4;       

   MakeTed( MOVECPX, MOVETEXT );
   MakeIndex( MOVECPX, AUP );
   MakeIndex( MOVECPX, ASLIDER );
   MakeIndex( MOVECPX, ADOWN );
       
   ObY( AUP )   += 2;
   ObY( ADOWN ) -= 2;
   ObY( ABASE ) = ObY( AUP ) + ObH( AUP ) + 5;
   ObH( ABASE ) = ( ObY( ADOWN ) - 5 ) - ObY( ABASE );
   ObX( AUP )   += 2;
   ObX( ADOWN ) += 2;
   ObX( ABASE ) += 2;

   MakeIndex( MOVECPX, IUP );
   MakeIndex( MOVECPX, ISLIDER );
   MakeIndex( MOVECPX, IDOWN );
              
   ObY( IUP )   += 2;
   ObY( IDOWN ) -= 2;
   ObY( IBASE ) = ObY( IUP ) + ObH( IUP ) + 5;
   ObH( IBASE ) = ( ObY( IDOWN ) - 5 ) - ObY( IBASE );
   ObX( IUP )   += 2;
   ObX( IDOWN ) += 2;
   ObX( IBASE ) += 2;
}




void
MakeIndex( int xtree, int obj )
{
    OBJECT *tree;
    
    tree = ( OBJECT *)rs_trindex[ xtree ];
    
    ObIndex( obj ) = ( ObIndex( obj ) & 0xfffffff0L ) | LWHITE | 0x70L;

}


void
MakeTed( int xtree, int obj )
{
    OBJECT *tree;
    
    tree = ( OBJECT *)rs_trindex[ xtree ];
    
    TedColor( obj ) = ( TedColor( obj ) & 0xFFF0L ) | LWHITE | 0x70L;
}



void
MakeIndicator( int xtree, int obj )
{
     OBJECT *tree;
     
     tree = ( OBJECT *)rs_trindex[ xtree ];
     
     ObFlags( obj ) |= IS3DOBJ;
     ObFlags( obj ) &= ~IS3DACT;
}


void
MakeActivator( int xtree, int obj )
{
    OBJECT *tree;
    
    tree = ( OBJECT *)rs_trindex[ xtree ];
    
    ObFlags( obj ) |= IS3DOBJ;
    ObFlags( obj ) |= IS3DACT;
}
