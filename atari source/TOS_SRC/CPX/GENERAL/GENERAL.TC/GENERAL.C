/* GENERAL.C 
 *==========================================================================
 * DATE:	February 2, 1990
 * DESCRIPTION: GENERAL CPX Dialog Box
 */
 


/* INCLUDE FILES
 *==========================================================================
 */ 
#include <sys\gemskel.h>
#include <tos.h>
#include <stdlib.h>
#include <string.h>

#include "country.h"

#include "general.h"
#include "general.rsh"

#include "..\cpxdata.h"

#include "super.h"
#include "status.h"
#include "ttblit.h"
#include "dclick.h"
#include "keybell.h"
#include "keyboard.h"
#include "block2.h"


/* DEFINES
 *==========================================================================
 */
#define UP 	0				/* wait button up   */
#define DOWN 	1				/* wait button down */


typedef struct _gen
{
   int 	keyclick;	/* Keyclick   On/Off       	    */
   int  bell;		/* Bell	      On/Off	   	    */
   int  dclick;		/* Double click rate: 0, 1, 2, 3, 4 */
   
   int  repeat;		/* Keyboard repeat rate		    */
   int  response;	/* Keyboard response rate	    */
   
   int  BlitCache;	/* Blitter/TT Cache On/Off	    */
   
   int  TT_Speaker;	/* TT Speaker On/Off  */
   int  STE_Chip;	/* STE Chip speed - 8mhz, 16mhz no cache
   			 *                  16 mhz with cache
   			 */
   			 
}GEN;




/* PROTOTYPES
 *==========================================================================
 */

BOOLEAN  cdecl cpx_call( GRECT *rect );
BOOLEAN	 cdecl cpx_call( GRECT *rect );

int   handle_button( int button, WORD *msg );
void  Set_Data( void );
void  Get_Data( void );
void  Set_Objects( void);
void  Redraw_Objects( void );

void  pop_data( void );
void  push_data( void );
void  wait_button( int flag );
void  open_vwork( void );
void  close_vwork( void );
void  XDeselect( OBJECT *tree, int button );
void  XSelect( OBJECT *tree, int button );
void  MakeActivator( int xtree, int obj );


/* EXTERNALS
 *==========================================================================
 */
extern GEN save_vars;
 
 
/* GLOBALS 
 *==========================================================================
 */

XCPB *xcpb;
CPXINFO cpxinfo;
int vhandle;
int  AES_Version;
int  numcol;
int  hcnt=0;			/* handle count */
int  currez;

/* VDI arrays */
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];


GEN old_value, cur_value;

char blanks[5][30];	/* Used for Pop_Up String Manipulation  */
char *blank[5];		/* and is subject to change after review*/

OBJECT *xtree;		/* This is a global tree that is passed to 
			 * XFORM_DO(). It is EITHER  the GENERAL tree
			 * or the PARTZ tree.
			 * When status is selected, we switch xtree ptrs
			 * to that xform_do will work correctly.
			 * When we switch back, we must restore the
			 * GENERAL tree pointer.
			 * In addition, the ObX and ObYs of the tree
			 * must be updated.
			 */
MFORM	Other;		/* Mouse Buffer for using MFsave() */
			 

/* FUNCTIONS
 *==========================================================================
 */
 
 
/* cpx_init() 
 *==========================================================================
 * initialize the cpx ( what else can I say? )
 *
 * IN:  XCPB Xcpb:	The structure passed into the cpx
 * OUT: return the CPXINFO structure to XCONTROL
 *
 * GLOBALS:	XCPB *xcpb:	We'll be using this one for calls
 *		int vhandle:	workstation handle
 *		CPXINFO cpxinfo: filled with functions address...
 */		
CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
    OBJECT *tree;
    int    i;

    appl_init();

    currez = Getrez();				/* find current resolution */
    xcpb = Xcpb;
    vhandle = xcpb->handle;
    if( xcpb->booting )
    {
      /* Read in the default settings and set the hardware */
      cur_value = save_vars;
      Init_Speed();
      Init_Block2();
      Set_Data();
      return( ( CPXINFO *)TRUE );  
    }
    else
    {

       open_vwork();
       close_vwork();
       numcol = work_out[13];			/* size of CLUT */
       
       AES_Version = _GemParBlk.global[0];
        
       if( !xcpb->SkipRshFix )
          (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                           rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                           rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                           rs_imdope );
       /*
        * Get the current settings of the hardware and store them
        * in the current GEN structure
        */
       cur_value = save_vars;
       Init_Speed();
       Init_Block2();
       Get_Data();
       push_data();
       cpxinfo.cpx_call   = cpx_call;
       cpxinfo.cpx_draw   = NULL;
       cpxinfo.cpx_wmove  = NULL;
       cpxinfo.cpx_timer  = NULL;
       cpxinfo.cpx_key    = NULL;
       cpxinfo.cpx_button = NULL;
       cpxinfo.cpx_m1 	  = NULL;
       cpxinfo.cpx_m2	  = NULL;
       cpxinfo.cpx_hook	  = NULL;
       cpxinfo.cpx_close  = NULL;

       if( !xcpb->SkipRshFix )
       {
        if(( AES_Version >= 0x0330 )
	    && ( numcol > LWHITE ) )
        {
         tree = ( OBJECT *)rs_trindex[ GENERAL ];
         MakeActivator( GENERAL, GSAVE );
         MakeActivator( GENERAL, GOK );
         MakeActivator( GENERAL, GCANCEL );
	 ObH( GSAVE )    = 16;
	 ObH( GOK )      = 16;
	 ObH( GCANCEL )  = 16;
	 ObIndex( B4 ) &= 0xff00ffffL;

	 ObX( GSAVE ) += 1;
	 ObY( GSAVE ) += 2;
	 ObW( GSAVE ) -= 2;
	 ObH( GSAVE ) -= 3;

	 ObX( GOK ) += 1;
	 ObY( GOK ) += 2;
	 ObW( GOK ) -= 2;
	 ObH( GOK ) -= 3;

	 ObX( GCANCEL ) += 1;
	 ObY( GCANCEL ) += 2;
	 ObW( GCANCEL ) -= 2;
	 ObH( GCANCEL ) -= 3;

	 ObX( LRESP ) += 2;
	 ObX( RRESP ) -= 2;
	 for( i = RESPBASE; i <= LRESP; i++ )
	 {
	    MakeActivator( GENERAL, i );
	    ObH( i ) = 16;
	    if( ( ObType( i ) & 0x00ff ) == G_BOXTEXT )
	      TedColor( i ) = ( TedColor( i ) & 0xff70 ) | LWHITE | 0x70;
	    
	    if( ( ObType( i ) & 0x00ff ) == G_BOXCHAR )
	      ObIndex( i ) = ( ObIndex( i ) & 0xffffff70 ) | LWHITE | 0x70;

	   if( i == RESPBASE )	   
	   {
	     ObX( i ) = ObX( LRESP ) + ObW( LRESP ) + 5;
	     ObW( i ) = ( ObX( RRESP ) - 5 ) - ObX( i );
	   }
	      
	 }   
	 ObIndex( B6 ) &= 0xff00ffffL;
	 ObIndex( B7 ) &= 0xffffff70L;


	 ObX( LREPEAT ) += 2;
	 ObX( RREPEAT ) -= 2;	 
	 for( i = LREPEAT; i <= KREPEAT; i++ )
	 {
	    MakeActivator( GENERAL, i );
	    ObH( i ) = 16;
	    if( ( ObType( i ) & 0x00ff ) == G_BOXTEXT )
	      TedColor( i ) = ( TedColor( i ) & 0xff70 ) | LWHITE | 0x70;

	    if( ( ObType( i ) & 0x00ff ) == G_BOXCHAR )
	      ObIndex( i ) = ( ObIndex( i ) & 0xffffff70 ) | LWHITE | 0x70;

	    if( i == REPTBASE )	   
	    {
	      ObX( i ) = ObX( LREPEAT ) + ObW( LREPEAT ) + 5;
	      ObW( i ) = ( ObX( RREPEAT ) - 5 ) - ObX( i );
	    }

	 }   
	 ObIndex( B8 ) &= 0xff00ffffL;
	 ObIndex( B9 ) &= 0xffffff70L;
	 
	 ObIndex( B0 ) &= 0xffffff70L;
	 MakeActivator( GENERAL, STATUS );
	 ObX( STATUS ) += 1;
	 ObY( STATUS ) += 2;
	 ObW( STATUS ) -= 2;
	 ObH( STATUS ) -= 4;


	 MakeActivator( GENERAL, DOUBLE );
	 ObX( DOUBLE ) += 1;
	 ObY( DOUBLE ) += 1;
	 ObW( DOUBLE ) -= 2;
	 ObH( DOUBLE ) -= 2;
         TedColor( DOUBLE ) = ( TedColor( DOUBLE ) & 0xFF70 ) | LWHITE | 0x70;
	 ObIndex( B5 ) &= 0xff00ff70L;	 	 

	 ObIndex( B1 ) = ( ObIndex( B1 ) & 0xffffff70L ) | LWHITE | 0x70;
	 ObIndex( B2 ) = ( ObIndex( B1 ) & 0xffffff70L ) | LWHITE | 0x70;
	 ObIndex( B3 ) &= 0xffffff70L;

         TedColor( BLK1TXT ) = ( TedColor( BLK1TXT ) & 0xFF70 );
	 ObIndex( BLK1 ) &= 0xffffff70L;
	 tree[(BLK1TXT)].ob_spec.tedinfo->te_thickness = 0;
	 
         TedColor( BLK2TXT ) = ( TedColor( BLK2TXT ) & 0xFF70 );
	 ObIndex( BLK2 ) &= 0xffffff70L;
	 tree[(BLK2TXT)].ob_spec.tedinfo->te_thickness = 0;
	 
         tree = ( OBJECT *)rs_trindex[ PARTZ ];
         MakeActivator( PARTZ, STATOK );
        }
       } /*        if( !xcpb->SkipRshFix )*/

       return( &cpxinfo );
    }
}





/* cpx_call()
 *==========================================================================
 * Execute the cpx
 *
 * 
 */
BOOLEAN
cdecl cpx_call( GRECT *rect )
{
     OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
     int button;
     int quit = 0;
     WORD msg[8];

     xtree = tree;     
     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;
     Set_Objects();
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     do
     {
	  button = (*xcpb->Xform_do)( xtree, 0, msg );
	  if( xtree == ( OBJECT *)rs_trindex[ PARTZ ] )
	     quit = stat_button( button, msg );
	  else
             quit = handle_button( button, msg );
             
     }while(!quit );
     return( FALSE );

}




/* handle_button()
 *==========================================================================
 /* button handling using XFORM_DO
 */
int
handle_button( int button, WORD *msg )
{
    OBJECT *tree  = (OBJECT *)rs_trindex[GENERAL];
    int    done = FALSE;
    BOOLEAN  click_flag = FALSE;
    MRETS  mk;
    int    ox, oy;
       
    if( ( button != -1 ) && ( button & 0x8000 ) )
    {
      click_flag = TRUE;
      button &= 0x7FFF;
    }

    switch( button )
    {
       case GSAVE:   if( (*xcpb->XGen_Alert)( SAVE_DEFAULTS ) )
       		     {
       			 (*xcpb->CPX_Save)( &cur_value, sizeof( GEN ) );
       			 push_data();
       			 Set_Data();
       		     }
       		     XDeselect( tree, GSAVE );
       		     break;
       		     
       case GOK:     done = TRUE;
       		     Set_Data();
       		     Deselect( GOK );
       		     break;
       			
       case GCANCEL: done = TRUE;
       		     pop_data();
       		     Deselect( GCANCEL );
       		     break;
       
       case STATUS:  graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
       		     if( objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y ) == STATUS )
       		         do_status();
       		     break;
       		     
       case BELL:    keybell_handle( BELLICON, &cur_value.bell );
       		     break;
       		     
       case KEYCLICK:keybell_handle( KEYICON, &cur_value.keyclick );
       		     break;
       		     
       case M0:
       case M1:
       case M2:
       case M3:
       case M4:	     Dclick_Select( button );
       		     break;
       		     
       case DOUBLE:  Dclick_Handle( click_flag, button );
        	     break;

       	case KREPEAT:   (*xcpb->MFsave )( MFSAVE, &Other );
       			if( AES_Version >= 0x0320 )
       			    graf_mouse( FLAT_HAND, 0L );


		        if(( AES_Version >= 0x0330 )
	      		    && ( numcol > LWHITE ) )
	     		    XSelect( tree, KREPEAT );

		        graf_mkstate( &ox, &mk.y, &mk.buttons, &mk.kstate );
	  		do
	  		{
	     		   graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
	  		}while( mk.buttons && ( mk.x == ox ));

			if( mk.buttons && ( mk.x != ox ))
			{
       			   (*xcpb->Sl_dragx)( tree, REPTBASE, KREPEAT, KEYMIN,
       					      KEYMAX, &cur_value.repeat,
       	                                      KRepeat );
       	                   Set_Kbrate();
			}
			
          		if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XDeselect( tree, KREPEAT );
       	                
       	                (*xcpb->MFsave)( MFRESTORE, &Other );
       			break;
 	       					
       	case KRESPONS:  (*xcpb->MFsave)( MFSAVE, &Other );
       			if( AES_Version >= 0x0320 )
       			    graf_mouse( FLAT_HAND, 0L );
       			    
		        if(( AES_Version >= 0x0330 )
	      		    && ( numcol > LWHITE ) )
	     		    XSelect( tree, KRESPONS );

		        graf_mkstate( &ox, &mk.y, &mk.buttons, &mk.kstate );
	  		do
	  		{
	     		   graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
	  		}while( mk.buttons && ( mk.x == ox ));

			if( mk.buttons && ( mk.x != ox ))
			{
       			   (*xcpb->Sl_dragx)( tree, RESPBASE, KRESPONS, KEYMIN,
       					      KEYMAX, &cur_value.response,
       	                                      KResponse );
       	                   Set_Kbrate();                  
			}
			
          		if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XDeselect( tree, KRESPONS );

       	                (*xcpb->MFsave)( MFRESTORE, &Other );
       			break;
       			
       	case RRESP:     (*xcpb->Sl_arrow)( tree, RESPBASE, KRESPONS, RRESP,
       	                                  1, KEYMIN, KEYMAX,
       	                                  &cur_value.response, HORIZONTAL,
       	                                  KResponse );
       	                Set_Kbrate();
       	 		break;
 	       	
       	case LRESP:     (*xcpb->Sl_arrow)( tree, RESPBASE, KRESPONS, LRESP,
       	                                  -1, KEYMIN, KEYMAX,
       	                                  &cur_value.response, HORIZONTAL,
       	                                  KResponse );
       	                Set_Kbrate();
       			break;
 	       	
       	case RREPEAT:   (*xcpb->Sl_arrow)( tree, REPTBASE, KREPEAT, RREPEAT,
       	                                  1, KEYMIN, KEYMAX,
       	                                  &cur_value.repeat, HORIZONTAL,
       	                                  KRepeat );
       	                Set_Kbrate();
       			break;
 	       	
       	case LREPEAT:   (*xcpb->Sl_arrow)( tree, REPTBASE, KREPEAT, LREPEAT,
       	                                  -1, KEYMIN, KEYMAX,
       	                                  &cur_value.repeat, HORIZONTAL,
       	                                  KRepeat );
       	                Set_Kbrate();
       			break;

	case REPTBASE:  Graf_mkstate( &mk );
			objc_offset( tree, KREPEAT, &ox, &oy );
			oy = (( mk.x < ox ) ? ( -3 ) : ( 3 ) );
       			(*xcpb->Sl_arrow)( tree, REPTBASE, KREPEAT, -1,
       			                  oy, KEYMIN, KEYMAX,
       			                  &cur_value.repeat, HORIZONTAL,
       			                  KRepeat );
       			Set_Kbrate();
  			break;
			
	case RESPBASE:  Graf_mkstate( &mk );
			objc_offset( tree, KRESPONS, &ox, &oy );
			oy = (( mk.x < ox ) ? ( -3 ) : ( 3 ));
       			(*xcpb->Sl_arrow)( tree, RESPBASE, KRESPONS, -1,
       			                  oy, KEYMIN, KEYMAX,
       			                  &cur_value.response, HORIZONTAL,
       			                  KResponse );
       			Set_Kbrate();
			break;
			

	case BLK1BUTT:  Do_Speed();
			break;
			
	case BLK2BUTT:  Do_Block2();
        		
	default:	if( button == -1 )
  			{
     			   switch( msg[0] )
     			   {
     			     case WM_REDRAW: Redraw_Objects();
     			     		     break;
     			     		     
     			     case AC_CLOSE:  done = TRUE;
     			     		     pop_data();	
     			     		     break;
     			     		     
     			     case WM_CLOSED: done = TRUE;
     			     		     Set_Data();
					     break;
     			     default:
     			     		break;
     			   }
     			}
     			break;
    }
    return( done );
}









/* Set_Data()
 *==========================================================================
 * Set keyclick, bell, double-click speed, keyboard response and repeat
 * and blitter/ttcache.
 */
void
Set_Data()
{
   Set_Keybell();
   Set_Dclick();
   Set_Kbrate();
   Set_Speed();
   Set_Block2();
}



/* Get_Data()
 *==========================================================================
 * Get the current hardware values and shove them into the data structure
 */
void
Get_Data( void )
{
    Get_Keybell();
    Get_Dclick();
    Get_Kbrate();
    Get_Speed();
    Get_Block2();
}


void
Set_Objects( void)
{
   Keybell_Update();
   Dclick_Update();
   Kbrate_Update();
   Speed_Update();
   Block2_Update();
}




/*--------------------------------------------------------------------------
 * OTHER Routines
 *--------------------------------------------------------------------------
 */
 
 
 
void
push_data( void )
{
    old_value = cur_value;
}



void
pop_data( void )
{
    cur_value = old_value;
    Set_Data();
}



/* wait_button()
 *==========================================================================
 */
void
wait_button( int flag )
{
  MRETS m;
  
  Evnt_button( 1, 1, flag, &m );
}




/* Pop_Handle()
 *==========================================================================
 * Setup strings for popup menu and execute...
 */
int
Pop_Handle( int button, char *items[], int num_items, int *default_item,
            int font_size, int width )
{
   GRECT butn, world;
   
   int  i;
   int  obj;
   long max = 0L;
   OBJECT *tree = (OBJECT *)rs_trindex[ GENERAL ];
   int small = FALSE;
     
   butn = ObRect( button );
   objc_offset( tree, button, &butn.g_x, &butn.g_y );
   world = ObRect( ROOT );
   objc_offset( tree, ROOT, &world.g_x, &world.g_y ); 
   
   
   for( i = 0; i < num_items; i++ )
   {
       if( strlen( items[i] ) > max )
       	 	max = strlen( items[i] );
   }
   if( max <= 3L )
   	small = TRUE;
   		   
   for( i = 0; i < num_items; i++ )
   {
      if( small )
        strcpy( &blanks[i][0], "   " );
      else
        strcpy( &blanks[i][0], "  ");		/* get 2 blank spaces */
      strcat( &blanks[i][0], items[ i ]);	/* copy the string    */
      do
      {
         strcat( &blanks[i][0], " ");
      }while( strlen( &blanks[i][0] ) < width );
      blank[i] = &blanks[i][0];
   }
   
   obj = (*xcpb->Popup)( blank, num_items, *default_item, font_size,
                        &butn, &world );

   if( obj != -1 )
      	*default_item = obj;
   return( obj );
}




void
Redraw_Objects( void )
{
   Kbell_Redraw();
   Dclick_Redraw();
   Kbrate_Redraw();
   Speed_Redraw();
   Block2_Redraw();
}



void
do_redraw( OBJECT *tree, int obj )
{
   GRECT *xrect;
   GRECT rect;
   GRECT t;
   
   t = ObRect( obj );
   objc_offset( tree, obj, &t.g_x, &t.g_y );   
   
   xrect = (*xcpb->GetFirstRect)( &t );
   while( xrect )
   {
    	rect = *xrect;
        Objc_draw( tree, obj, MAX_DEPTH, &rect );
        xrect = (*xcpb->GetNextRect)();
   };   
}



/*
 * Open virtual workstation
 */
void
open_vwork(void)
{
  int i;
  
  if (hcnt == 0) {
  	for (i = 1; i < 10;)
    	work_in[i++] = 1;
  	work_in[0] = currez + 2;
  	work_in[10] = 2;
  	vhandle = xcpb->handle;
  	v_opnvwk(work_in, &vhandle, work_out);
  }
  hcnt++;
}


/*
 * Close virtual workstation
 */
void
close_vwork(void)
{
    hcnt--;
    if( !hcnt )
    {
 	v_clsvwk(vhandle);
	vhandle = -1;
    }
}



void
XDeselect( OBJECT *tree, int button )
{
   GRECT rect;

   Deselect( button );
   rect = ObRect( button );
   objc_offset( tree, button, &rect.g_x, &rect.g_y );
   rect.g_x -= 2;
   rect.g_y -= 2;
   rect.g_w += 4;
   rect.g_h += 4;
   Objc_draw( tree, button, MAX_DEPTH, &rect );
}


void
XSelect( OBJECT *tree, int button )
{
   GRECT rect;

   Select( button );
   rect = ObRect( button );
   objc_offset( tree, button, &rect.g_x, &rect.g_y );
   rect.g_x -= 2;
   rect.g_y -= 2;
   rect.g_w += 4;
   rect.g_h += 4;
   Objc_draw( tree, button, MAX_DEPTH, &rect );
}



void
MakeActivator( int xtree, int obj )
{
   OBJECT *tree;
   
   tree = ( OBJECT *)rs_trindex[ xtree ];
   
   ObFlags( obj ) |= IS3DOBJ;
   ObFlags( obj ) |= IS3DACT;
}
