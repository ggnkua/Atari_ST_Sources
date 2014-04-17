/* ======================================================================
 * FILE: SYSTEM.C
 * ======================================================================
 * DATE: April 8, 1992
 *
 * DESCRIPTION: CPX to display the system information
 */
 

/* INCLUDE FILES
 * ======================================================================
 */
#include <alt\gemskel.h>
#include <string.h>
#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <osbind.h>

#include "cpxdata.h"
#include "country.h"
#include "system.h"
#include "system.rsh"
#include "fixrsh.h"

	
/* DEFINES
 * ======================================================================
 */



/* PROTOTYPES
 * ======================================================================
 */
CPXINFO	 *cpx_init( XCPB *Xcpb );
BOOLEAN  cpx_call( GRECT *rect );

void	 open_vwork( void );
void	 close_vwork( void );
int	 CheckBox( int boxnum, int iconnum );

void	 cpx_button( MRETS *mrets, int nclicks, int *event );
BOOLEAN	 cpx_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks );
void	 cpx_close( BOOLEAN flag );
void	 cpx_draw( GRECT *clip );
void	 cpx_mover( GRECT *work );
void	 cpx_key( int kstate, int key, int *event );

void	 initialize( void );
BOOLEAN	 GetWindow( int item );

void	 do_system( int *msg );


/* DEFINES
 * ======================================================================
 */
#define F1	0x3b00
#define F2	0x3c00
#define F3	0x3d00
#define F4	0x3e00
#define F5	0x3f00
#define F6	0x4000
#define F7	0x4100
#define F8	0x4200
#define RETURN  0x1c0d
#define ENTER   0x720d


/* EXTERNALS
 * ======================================================================
 */


/* GLOBALS
 * ======================================================================
 */
XCPB    *xcpb;			/* XControl Parameter Block   */
CPXINFO cpxinfo;		/* CPX Information Structure  */

OBJECT  *tree;			/* Global tree variable...    */
OBJECT  *ad_tree;		/* Main cpx tree...           */
OBJECT  *ad_xtree;

int     currez;


/* VDI arrays */
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
int 	pxyarray[10];		/* input point array */
int	vhandle=-1;		/* virtual workstation handle */
int	hcnt=0;			/* handle count */


/* AES variables */
int	gl_apid, gl_hchar, gl_wchar, gl_hbox, gl_wbox;
GRECT	desk;



int     CurBox;
int     WHandle;

int     wid;
int     dummy;

char    *title[] = { " System Summary ",
		     " Disk Summary ",
		     " Display Summary ",
		     " Printer Summary ",
		     " Memory Usage ",
		     " Startup Files ",
		     " Init Applications ",
		     " Statistics "
		   };

/* FUNCTIONS
 * ======================================================================
 */


/* cpx_init()
 * ======================================================================
 * cpx_init() is where a CPX is first initialized.
 * There are TWO parts.
 *
 * PART ONE: cpx_init() is called when the CPX is first 'booted'. This is
 *	     where the CPX should read in its defaults and then set the
 *	     hardware based on those defaults.  
 *
 * PART TWO: The other time cpx_init() is called is when the CPX is being
 *	     executed.  This is where the resource is fixed up and current
 *	     cpx variables are updated from the hardware.  In addition,
 *	     this is where the CPXINFO structure should be filled out.
 *
 * IN:  XCPB	*Xcpb:	Pointer to the XControl Parameter Block
 * OUT: CPXINFO  *ptr:	Pointer to the CP Information Structure
 */			
CPXINFO
*cpx_init( XCPB *Xcpb )
{
    gl_apid = appl_init();

    xcpb = Xcpb;

    currez = Getrez();				/* find current resolution */
    
    if( xcpb->booting )
    {
        return( ( CPXINFO *)TRUE );  
    }
    else
    { 

      if( !xcpb->SkipRshFix )
      {
           (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                            rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                            rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                            rs_imdope );

	   /* fix up at normal dialog box sizes */
           fix_rsh( NUMX_OBS, NUMX_FRSTR, NUMX_FRIMG, NUMX_TREE,
                    ws_object, ws_tedinfo, ws_strings, ws_iconblk,
                    ws_bitblk, ws_frstr, ws_frimg, ws_trindex,
                    ws_imdope );
      }
 
      ad_tree   = (OBJECT *)rs_trindex[ MAINTREE ];
      ad_xtree  = (OBJECT *)ws_trindex[ TREE2 ];

      ActiveTree( ad_tree );
      initialize();

          
      /* Initialize the CPXINFO structure */           
      cpxinfo.cpx_call   = cpx_call;
      cpxinfo.cpx_draw   = cpx_draw;
      cpxinfo.cpx_wmove  = cpx_mover;
      cpxinfo.cpx_timer  = NULL;
      cpxinfo.cpx_key    = cpx_key;
      cpxinfo.cpx_button = cpx_button;
      cpxinfo.cpx_m1 	 = NULL;
      cpxinfo.cpx_m2	 = NULL;
      cpxinfo.cpx_hook   = cpx_hook;
      cpxinfo.cpx_close  = cpx_close;

      /* Return the pointer to the CPXINFO structure to XCONTROL */
      return( &cpxinfo );
    }
}




/* cpx_call()
 * ======================================================================
 * Called ONLY when the CPX is being executed. Note that it is CPX_INIT()
 * that returned the ptr to cpx_call().
 * CPX_CALL() is the entry point to displaying and manipulating the
 * dialog box.
 *
 * IN: GRECT *rect:	Ptr to a GRECT that describes the current work
 *			area of the XControl window.
 *
 * OUT:
 *   FALSE:     The CPX has exited and no more messages are
 *		needed.  XControl will either return to its
 *		main menu or close its windows.
 *		This is used by XForm_do() type CPXs.
 *
 *   TRUE:	The CPX requests that XCONTROL continue to
 *		send AES messages.  This is used by Call-type CPXs.
 */
BOOLEAN
cpx_call( GRECT *rect )
{
     WORD    clip[4];

     ActiveTree( ad_tree );

     WindGet(0, WF_WORKXYWH, &desk );	/* set clipping to */
     rc_2xy( &desk, clip );		/*   Desktop space */

     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;

     open_vwork();
     vs_clip( vhandle, 1, ( int *)clip );
     ObjcDraw( tree, ROOT, MAX_DEPTH,NULL );
     close_vwork();

     return( TRUE );
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


/* CheckBox
 * ==================================================================
 * Check the box and select it, or deselect it
 */
int
CheckBox( int boxnum, int iconnum )
{
   int   dummy;
   int   i;
   GRECT rect;
    

   ActiveTree( ad_tree );

   for( i = BOX1; i<= ICON8; i++ )
      Deselect( i );

   if( CurBox )
   {
      rect = ObRect( CurBox );
      objc_offset( ad_tree, CurBox, &rect.g_x, &rect.g_y );
      cpx_draw( &rect );      
   }

   if( CurBox != boxnum )
   {
     Select( boxnum );
     Select( iconnum );
     rect = ObRect( boxnum );
     objc_offset( ad_tree, boxnum, &rect.g_x, &rect.g_y );
     cpx_draw( &rect );      
     CurBox = boxnum;
   }
   else
     CurBox = NULL;

   evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
   return( CurBox );
}


void
cpx_draw( GRECT *clip )
{
    GRECT rect;

    ActiveTree( ad_tree );
    wind_get( wid, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
    while( rect.g_w && rect.g_h )
    {
	if( rc_intersect( clip, &rect ))
        {
	   ObjcDraw( tree, ROOT, MAX_DEPTH, &rect );
        }
        wind_get( wid, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
    }
}


void
cpx_mover( GRECT *work )
{
    ActiveTree( ad_tree );
    ObX( ROOT ) = work->g_x;
    ObY( ROOT ) = work->g_y;
}



void
cpx_button( MRETS *mrets, int nclicks, int *event )
{
   int   obj;
   int   box;
   MRETS mk;
   int   dummy;

   ActiveTree( ad_tree );

   /* Look for the objects */
   if( ( obj = objc_find( ad_tree, ROOT, MAX_DEPTH, mrets->x, mrets->y ))>= 0)
   {
      switch( obj )
      {
     	 case SEXIT:  select( tree, SEXIT );
		      graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
		      while( mk.buttons )
		      {
			obj = objc_find( ad_tree, SEXIT, 0, mk.x, mk.y );
			if( obj != SEXIT )
			{
			  if( IsSelected( SEXIT ) )
			    deselect( tree, SEXIT );
			}
			else
			{
			  if( !IsSelected( SEXIT ) )
			      select( tree, SEXIT );
			}
		        graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
		      }
		      evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
		      obj = objc_find( ad_tree, SEXIT, 0, mk.x, mk.y );
		      if( obj == SEXIT )
		      {
			  *event = TRUE;
		  	  cpx_close( TRUE );
		      }
     	   	      Deselect( obj );
     	   	      break;

	 case COVER1:
	 case COVER2:
	 case COVER3:
	 case COVER4:
	 case COVER5:
	 case COVER6:
	 case COVER7:
	 case COVER8: box = ((( obj - COVER1 )* 2 ) + BOX1 );
		      if( CheckBox( box, box + 1 ) )
		         GetWindow( obj - COVER1 );
		      else
		      {
		         cpx_close( TRUE );
			 wind_set( wid, WF_TOP );
		      }
		      break;

	 default:
		  break;
      }
   }
}



void
cpx_key( int kstate, int key, int *event )
{
    int obj;
    int box;

    if( ( key >= F1 ) && ( key <= F8 ))
    {
	obj = (  ( key - F1 ) >> 8 ) + COVER1; 
	box = ((( obj - COVER1 )* 2 ) + BOX1 );
	if( CheckBox( box, box + 1 ))
	   GetWindow( obj - COVER1 );
	else
	{
	   cpx_close( TRUE );
	   wind_set( wid, WF_TOP );	/* not working, do this later...*/
	}
    }

    if(( key == RETURN ) || ( key == ENTER ))
    {
	*event = TRUE;
	cpx_close( TRUE );
    }
}


void
cpx_close( BOOLEAN flag )
{
    if( WHandle > 0 )
    {
      wind_close( WHandle );
      wind_delete( WHandle ); 
    }
    WHandle = NIL;
}



/* cpx_hook()
 * ==================================================================
 * Called after XControl returns from the evnt_multi but before
 * entering XForm_Do
 *
 * Always return FALSE - we want to continue processing.
 */
BOOLEAN
cpx_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks )
{
    int topid;
    int dummy;
    int obj;
    int box;

    if( WHandle > 0 )
    {

      if( event & MU_MESAG )
      {
        if( msg[3] == WHandle )
        {
	   do_system( msg );
	   wind_update( END_UPDATE );
	   return( TRUE );
	}
      }

      if( event & MU_KEYBD )
      {
	wind_get( 0, WF_TOP, &topid, &dummy, &dummy, &dummy );
	if( topid == WHandle )
	{
	    if( ( *key >= F1 ) && ( *key <= F8 ))
    	    {
	      obj = (  ( *key - F1 ) >> 8 ) + COVER1; 
	      box = ((( obj - COVER1 )* 2 ) + BOX1 );
	      if( CheckBox( box, box + 1 ))
	        GetWindow( obj - COVER1 );
	      else
	        cpx_close( TRUE );
            }

	    wind_update( END_UPDATE );
	    return( TRUE );
	}
      }
    }
    return( FALSE );
}



/* initialize()
 * ==================================================================
 * INitialize the cpx data structures.
 */
void
initialize( void )
{
      CurBox  = NULL;
      WHandle = NIL;
      wind_get( 0, WF_TOP, &wid, &dummy, &dummy, &dummy );
      (*xcpb->Set_Evnt_Mask)( MU_BUTTON | MU_MESAG | MU_KEYBD, NULL, NULL, -1L );
}



/* GetWindow()
 * ==================================================================
 */
BOOLEAN
GetWindow( int item )
{
    GRECT rect;

    if( WHandle < 0 )
    {
      if( ( WHandle = wind_create( CLOSER | FULLER | MOVER | SIZER | NAME , 
			0, 16, 640, 480 )) < 0 )
      {
	  WHandle = NIL;
	  form_alert( 1, "[1][ No More Windows ][OK]");
	  return( FALSE );
      }

      ActiveTree( ad_xtree );
      wind_set( WHandle, WF_NAME, title[ item ] );	
      wind_open( WHandle, 100, 100, 400, 200 );

      wind_get( WHandle, WF_WORKXYWH, &rect.g_x, &rect.g_y,&rect.g_w,&rect.g_h);
      ObX( ROOT ) = rect.g_x;
      ObY( ROOT ) = rect.g_y;
      ObW( ROOT ) = rect.g_w;
      ObH( ROOT ) = rect.g_h;

      ActiveTree( ad_tree );
    }
    else
    {
      wind_set( WHandle, WF_NAME, title[ item ] );	
    }
    return( TRUE );
}






/* do_system()
 * ==================================================================
 */
void
do_system( int *msg )
{
    GRECT rect;
    GRECT clip;

    switch( msg[0] )
    {
	case WM_REDRAW: ActiveTree( ad_xtree );
			clip.g_x = msg[4];
			clip.g_y = msg[5];
			clip.g_w = msg[6];
			clip.g_h = msg[7];
    			wind_get( WHandle, WF_FIRSTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
			while( rect.g_w && rect.g_h )
			{
			   if( rc_intersect( &clip, &rect ))
        		   {
	  		      ObjcDraw( ad_xtree, ROOT, MAX_DEPTH, &rect );
        		   }
        		   wind_get( WHandle, WF_NEXTXYWH, &rect.g_x, &rect.g_y, &rect.g_w, &rect.g_h);
    			}
			break;

	case WM_TOPPED: wind_set( WHandle, WF_TOP );
			break;
			
	case WM_CLOSED:
			break;

	case WM_FULLED:
			break;

	case WM_MOVED:  ActiveTree( ad_xtree );
			wind_set( WHandle, WF_CURRXYWH, msg[4],msg[5],msg[6],msg[7] );
			wind_get( WHandle, WF_WORKXYWH, &rect.g_x,&rect.g_y,&rect.g_w,&rect.g_h );
			ObX( ROOT ) = rect.g_x;
			ObY( ROOT ) = rect.g_y;
			break;

	default:
			break;
    }
    ActiveTree( ad_tree );
}
