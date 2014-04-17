/* ======================================================================
 * FILE: SUBMENU.C
 * ======================================================================
 * DATE: March 26, 1992
 * DESCRIPTION: CPX to handle the Submenu Variables such as
 *	Submenu Display Delay
 *      Submenu Drag Delay
 *      Submenu Response Delay
 *      Submenu Scroll Delay
 *      Submenu Menu Scrolling Height
 * 04/01/92 cjg - updated to new routine format
 * 07/09/92 cjg - if AES version >= 3.2, use MFsave, else skip it
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
#include "submenu.h"
#include "submenu.rsh"
#include "menubind.h"

	
/* DEFINES
 * ======================================================================
 */
typedef struct _node
{
  WORD	value; 		/* value in ms */
  WORD  xmin;		/* minimum value*/
  WORD  xmax;		/* maximum value */
  WORD  offset;		/* page offset */
  WORD  inc;		/* left and right arrow inc */
  BYTE  text[ 10 ];  	/* text	       */
} NODE, *NODE_PTR;

#define MIN_HEIGHT  5
#define MAX_HEIGHT  999

/* Key codes */
#define	UNDO	0x6100		/* Undo key */
#define	HOME	0x4700		/* Clr Home Key */

#define INIT_DISPLAY    100
#define INIT_DRAG	10000
#define INIT_RESPONSE   250
#define INIT_SCROLL     0
#define INIT_MENU	16


/* PROTOTYPES
 * ======================================================================
 */
CPXINFO	 *cpx_init( XCPB *Xcpb );
BOOLEAN  cpx_call( GRECT *rect );

void	 initialize( void );
void	 Update( void );

void	 Do_Left( int base, int slider, int button, int index );
void	 Do_Right( int base, int slider, int button, int index );
void	 Do_Slider( int base, int slider, int index );
void	 Do_Base( int base, int slider, int index );
void	 do_keys( int key );
void	 PushValues( void );
void	 PopValues( void );
void	 GetValues( void );
void	 PutValues( void );
void	 RedrawSliders( void );
void	 SetHardWare( void );
void	 GetHardWare( void );


/* EXTERNALS
 * ======================================================================
 */
extern int saved[];


/* GLOBALS
 * ======================================================================
 */
XCPB    *xcpb;			/* XControl Parameter Block   */
CPXINFO cpxinfo;		/* CPX Information Structure  */

OBJECT  *tree;			/* Global tree variable...    */
OBJECT  *ad_tree;		/* Main cpx tree...           */


/* VDI arrays */
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
int 	pxyarray[10];		/* input point array */
int	vhandle=-1;		/* virtual workstation handle */
int	hcnt=0;			/* handle count */


/* AES variables */
int	gl_apid, gl_hchar, gl_wchar, gl_hbox, gl_wbox;
GRECT	desk;
MFORM	orig_mf;		/* original mouse form */

int     curslid;

/* Data array */
NODE    CurData[5];		/* Storage nodes for data */
int     OldValue[5];		/* The old values	  */
MN_SET  TData;
int     AES_Version;

char alert1[] = "[1][ | The Display Delay is the | length of time, in seconds,| before the submenu appears.][ OK ]";	/* Display Delay */
char alert2[] = "[1][The Drag Delay is the length |of time the user has to drag |the mouse diagonally to the  |displayed submenu.][ OK ]";	/* Drag Delay */
char alert3[] = "[1][ The Response Delay is the | length of time, in seconds, | the system waits before | scrolling the submenu | continuously.][ OK ]";	/* Response Delay */
char alert4[] = "[1][ The Scroll Delay is the | length of time, in seconds, | the system waits after | scrolling each menu item.][ OK ]";	/* Scroll Delay */
char alert5[] = "[1][The Menu Height is the number|of menu items required to|display the scroll indicators.|The screen height is the|maximum value possible.][ OK ]";	/* Height */
char alert6[] = "[1][ | The Submenu CPX is not | available with this| version of the AES.][ OK ]";

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
    appl_init();
    AES_Version = _AESglobal[0];

    xcpb = Xcpb;

    if( xcpb->booting )
    {
        if( AES_Version >= 0x0330 )	/* if < version 0330 of AES */
	{
	  
	  /* Get our stored values and shove them into the AES */
	  GetValues();
	  PushValues();
	  SetHardWare();
	}
        return( ( CPXINFO *)TRUE );  
    }
    else
    { 
      if( AES_Version < 0x0330 )	/* if < version 0400 of AES */
      {
	 form_alert( 1, alert6 );
	 return( ( CPXINFO *)FALSE );
      }

      if( !xcpb->SkipRshFix )
      {
           (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                            rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                            rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                            rs_imdope );
      }
 
      ad_tree   = (OBJECT *)rs_trindex[ MAINTREE ];

      ActiveTree( ad_tree );
/* temp */
      GetHardWare();
      PushValues();

      initialize();

  
      /* Initialize the CPXINFO structure */           
      cpxinfo.cpx_call   = cpx_call;
      cpxinfo.cpx_draw   = NULL;
      cpxinfo.cpx_wmove  = NULL;
      cpxinfo.cpx_timer  = NULL;
      cpxinfo.cpx_key    = NULL;
      cpxinfo.cpx_button = NULL;
      cpxinfo.cpx_m1 	 = NULL;
      cpxinfo.cpx_m2	 = NULL;
      cpxinfo.cpx_hook   = NULL;
      cpxinfo.cpx_close  = NULL;

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
     int     button;
     int     quit = 0;
     WORD    msg[8], clip[4];
     BOOLEAN dclick;
     MRETS   mk;
     WORD    newvalue;

     ActiveTree( ad_tree );

     WindGet(0, WF_WORKXYWH, &desk );	/* set clipping to */
     rc_2xy( &desk, clip );		/*   Desktop space */

     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;

     ObjcDraw( tree, ROOT, MAX_DEPTH,NULL );
         
     do
     {
        dclick = FALSE;
	button = (*xcpb->Xform_do)( tree, M5SLIDER, msg );

	if(( button != -1 ) && ( button & 0x8000 ) )
        {
	   dclick = TRUE;
	   button &= 0x7fff;
        }

     	switch( button )
     	{	
	   case MOK:     CurData[4].value = atoi( TedText( M5SLIDER ) );
		         CurData[4].value = min( CurData[4].value, CurData[4].xmax );
		         CurData[4].value = max( CurData[4].value, CurData[4].xmin );
			 SetHardWare();

     	   case MCANCEL: quit = TRUE;
     	   	      	 Deselect( button );
     	   	      	 break;

	   case MRELOAD: /* reload the stored values */
			 GetValues();
			 initialize();
			 RedrawSliders();
			 deselect( tree, button );
			 break;

	   case MSAVE:   /* save the current values */
			 if ((*xcpb->XGen_Alert)(SAVE_DEFAULTS) == TRUE)
			 {
			    CurData[4].value = atoi( TedText( M5SLIDER ) );
			    CurData[4].value = min( CurData[4].value, CurData[4].xmax );
		            CurData[4].value = max( CurData[4].value, CurData[4].xmin );

			    PutValues();
			    (*xcpb->CPX_Save)((void *)&saved, 10L );	
			    PushValues();
			 }
			 deselect( tree, button );
			 break;


	   /* DISPLAY DELAY */
	   case M1TITLE:  if( dclick )
			    form_alert( 1, alert1 );
			  break;

	   case M1LEFT:   Do_Left( M1BASE, M1SLIDER, M1LEFT, 0 );
			  break;

	   case M1RIGHT:  Do_Right( M1BASE, M1SLIDER, M1RIGHT, 0 );
			  break;

	   case M1SLIDER: Do_Slider( M1BASE, M1SLIDER, 0 );
			  break;

	   case M1BASE:   Do_Base( M1BASE, M1SLIDER, 0 );
			  break;


	   /* DRAG DELAY */
	   case M2TITLE:  if( dclick )
			    form_alert( 1, alert2 );
			  break;

	   case M2LEFT:   Do_Left( M2BASE, M2SLIDER, M2LEFT, 1 );
			  break;

	   case M2RIGHT:  Do_Right( M2BASE, M2SLIDER, M2RIGHT, 1 );
			  break;

	   case M2SLIDER: Do_Slider( M2BASE, M2SLIDER, 1 );
			  break;

	   case M2BASE:   Do_Base( M2BASE, M2SLIDER, 1 );
			  break;


	   /* RESPONSE DELAY */
	   case M3TITLE:  if( dclick )
			    form_alert( 1, alert3 );
			  break;
	
	   case M3LEFT:   Do_Left( M3BASE, M3SLIDER, M3LEFT, 2 );
			  break;

	   case M3RIGHT:  Do_Right( M3BASE, M3SLIDER, M3RIGHT, 2 );
			  break;

	   case M3SLIDER: Do_Slider( M3BASE, M3SLIDER, 2 );
			  break;

	   case M3BASE:   Do_Base( M3BASE, M3SLIDER, 2 );
			  break;


	   /* SCROLL DELAY */
	   case M4TITLE:  if( dclick )
			    form_alert( 1, alert4 );
			  break;

	   case M4LEFT:   Do_Left( M4BASE, M4SLIDER, M4LEFT, 3 );
			  break;

	   case M4RIGHT:  Do_Right( M4BASE, M4SLIDER, M4RIGHT, 3 );
			  break;

	   case M4SLIDER: Do_Slider( M4BASE, M4SLIDER, 3 );
			  break;

	   case M4BASE:   Do_Base( M4BASE, M4SLIDER, 3 );
			  break;


	   /* MENU HEIGHT */
           case M5TITLE:  if( dclick )
			    form_alert( 1, alert5 );
			  break;

	   case M5UP:	  newvalue = atoi( TedText( M5SLIDER ) );
			  CurData[4].value = min( newvalue, CurData[4].xmax );
		          CurData[4].value = max( newvalue, CurData[4].xmin );
			  if( CurData[4].value < CurData[4].xmax )
			  {
			    select( tree, M5UP );
			    PushValues();
			    do
			    {
			      CurData[4].value += 1;    
			      CurData[4].value = min( CurData[4].value, CurData[4].xmax );
			      sprintf( CurData[4].text, "%3d", CurData[4].value );
		              TedText( M5SLIDER ) = CurData[4].text;
			      ObjcDraw( ad_tree, M5SLIDER, MAX_DEPTH, NULL );
			     
			      if( CurData[4].value >= CurData[4].xmax )
				break;
			      
			      Graf_mkstate( &mk );
			    }while( mk.buttons );
			    deselect( tree, M5UP );
			  }
			  break;

	   case M5DOWN:	  newvalue = atoi( TedText( M5SLIDER ) );
			  CurData[4].value = min( newvalue, CurData[4].xmax );
		          CurData[4].value = max( newvalue, CurData[4].xmin );
			  if( CurData[4].value > CurData[4].xmin )
			  {
			     select( tree, M5DOWN );
			     PushValues();
			     do
			     {
			       CurData[4].value -= 1;
		               CurData[4].value = max( CurData[4].value, CurData[4].xmin );
			       sprintf( CurData[4].text, "%3d", CurData[4].value );
		               TedText( M5SLIDER ) = CurData[4].text;
			       ObjcDraw( ad_tree, M5SLIDER, MAX_DEPTH, NULL );

			       if( CurData[4].value <= CurData[4].xmin )
				 break;
			       Graf_mkstate( &mk );
			     }while( mk.buttons );
			     deselect( tree, M5DOWN );
			  }
			  break;


     	   default:	if( button == -1 )
     			{
     			   switch( msg[0] )
     			   {
     			     case WM_REDRAW: /* redraw the cpx */
     			     		     break;
     			     		     
     			     case AC_CLOSE:  /* treated like a cancel */
					     quit = TRUE;
					     break;


     			     case WM_CLOSED: /* treated like an OK */
					     CurData[4].value = atoi( TedText( M5SLIDER ) );
					     CurData[4].value = min( CurData[4].value, CurData[4].xmax );
		        		     CurData[4].value = max( CurData[4].value, CurData[4].xmin );
					     SetHardWare();

					     quit = TRUE;
					     break;
					     
			     case CT_KEY:    do_keys( msg[3] );
			     		     break;		     

     			     default:
     			     		break;
     			   }
     			}
     			break;
     	}
     }while( !quit);
     return( FALSE );
}





void
Do_Left( int base, int slider, int button, int index )
{
     PushValues();
     curslid = slider;
     (*xcpb->Sl_arrow)(tree, base, slider, button, -CurData[index].inc,
		       CurData[index].xmin, CurData[index].xmax,
		       &CurData[index].value, HORIZONTAL, Update );
}



void
Do_Right( int base, int slider, int button, int index )
{
    PushValues();
    curslid = slider;
    (*xcpb->Sl_arrow)(tree, base, slider, button, CurData[index].inc, 
    		      CurData[index].xmin, CurData[index].xmax,
		      &CurData[index].value, HORIZONTAL, Update );
}



void
Do_Slider( int base, int slider, int index )
{
     PushValues();
     (*xcpb->MFsave)(MFSAVE, &orig_mf);
     if( AES_Version >= 0x0320 )
         graf_mouse( FLAT_HAND, 0L );
     curslid = slider;
     (*xcpb->Sl_dragx)(tree, base, slider,
		       CurData[index].xmin, CurData[index].xmax, 
    		       &CurData[index].value, Update );
     (*xcpb->MFsave)(MFRESTORE, &orig_mf);
}



void
Do_Base( int base, int slider, int index )
{
   MRETS mk;
   int   ox,oy;

   PushValues();

   Graf_mkstate(&mk);
   objc_offset(tree, slider, &ox, &oy);
   if( mk.x < ox)
        ox = -CurData[index].offset;
   else
        ox = CurData[index].offset;
   curslid = slider;
   (*xcpb->Sl_arrow)(tree, base, slider, -1, ox, CurData[index].xmin, 
   		     CurData[index].xmax, &CurData[index].value,
		     HORIZONTAL, Update );
}




void
Update( void )
{
    if( curslid == M1SLIDER )
    {
       CurData[0].value = max( CurData[0].value, CurData[0].xmin );
       CurData[0].value = min( CurData[0].value, CurData[0].xmax );

       sprintf( CurData[0].text, "%2.2f", CurData[0].value/1000.0 );
       TedText( M1SLIDER ) = CurData[0].text;
       ObjcDraw( ad_tree, M1SLIDER, MAX_DEPTH, NULL );
    }

    if( curslid == M2SLIDER )
    {
       CurData[1].value = max( CurData[1].value, CurData[1].xmin );
       CurData[1].value = min( CurData[1].value, CurData[1].xmax );

       sprintf( CurData[1].text, "%d", CurData[1].value/1000 );
       TedText( M2SLIDER ) = CurData[1].text;
       ObjcDraw( ad_tree, M2SLIDER, MAX_DEPTH, NULL );
    }

    if( curslid == M3SLIDER )
    {
       CurData[2].value = max( CurData[2].value, CurData[2].xmin );
       CurData[2].value = min( CurData[2].value, CurData[2].xmax );

       sprintf( CurData[2].text, "%2.2f", CurData[2].value/1000.0 );
       TedText( M3SLIDER ) = CurData[2].text;
       ObjcDraw( ad_tree, M3SLIDER, MAX_DEPTH, NULL );
    }

    if( curslid == M4SLIDER )
    {
       CurData[3].value = max( CurData[3].value, CurData[3].xmin );
       CurData[3].value = min( CurData[3].value, CurData[3].xmax );

       sprintf( CurData[3].text, "%2.2f", CurData[3].value/1000.0 );
       TedText( M4SLIDER ) = CurData[3].text;
       ObjcDraw( ad_tree, M4SLIDER, MAX_DEPTH, NULL );
    }

}



void
initialize( void )
{
/* Should get the values stored in the AES */

     /* DISPLAY DELAY */
/*     CurData[0].value;	*/
     CurData[0].xmin   = 0;
     CurData[0].xmax   = 1000;
     CurData[0].offset = 100;
     CurData[0].inc    = 10;
     CurData[0].text[0] = '\0';
     (*xcpb->Sl_x)( ad_tree, M1BASE, M1SLIDER, CurData[0].value,
		    CurData[0].xmin, CurData[0].xmax, NULLPTR );
     sprintf( CurData[0].text, "%2.2f", CurData[0].value/1000.0 );
     TedText( M1SLIDER ) = CurData[0].text;


     /* DRAG DELAY */
/*     CurData[1].value;*/
     CurData[1].xmin   = 0;
     CurData[1].xmax   = 20000;
     CurData[1].offset = 2000;
     CurData[1].inc    = 1000;
     CurData[1].text[0] = '\0';
     (*xcpb->Sl_x)( ad_tree, M2BASE, M2SLIDER, CurData[1].value,
		    CurData[1].xmin, CurData[1].xmax, NULLPTR );
     sprintf( CurData[1].text, "%2d", CurData[1].value/1000 );
     TedText( M2SLIDER ) = CurData[1].text;


     /* RESPONSE DELAY */
/*     CurData[2].value  =;*/
     CurData[2].xmin   = 0;
     CurData[2].xmax   = 1000;
     CurData[2].offset = 100;
     CurData[2].inc    = 10;
     CurData[2].text[0] = '\0';
     (*xcpb->Sl_x)( ad_tree, M3BASE, M3SLIDER, CurData[2].value,
		    CurData[2].xmin, CurData[2].xmax, NULLPTR );
     sprintf( CurData[2].text, "%2.2f", CurData[2].value/1000.0 );
     TedText( M3SLIDER ) = CurData[2].text;


     /* SCROLL DELAY */
/*     CurData[3].value  = ;*/
     CurData[3].xmin   = 0;
     CurData[3].xmax   = 1000;
     CurData[3].offset = 100;
     CurData[3].inc    = 10;
     CurData[3].text[0] = '\0';
     (*xcpb->Sl_x)( ad_tree, M4BASE, M4SLIDER, CurData[3].value,
		    CurData[3].xmin, CurData[3].xmax, NULLPTR );
     sprintf( CurData[3].text, "%2.2f", CurData[3].value/1000.0 );
     TedText( M4SLIDER ) = CurData[3].text;


     /* MENU HEIGHT */
/*     CurData[4].value  = ;*/
     CurData[4].xmin   = MIN_HEIGHT;
     CurData[4].xmax   = MAX_HEIGHT;
     CurData[4].offset = 100;
     CurData[4].inc    = 1;
     CurData[4].text[0] = '\0';
     sprintf( CurData[4].text, "%3d", CurData[4].value );
     TedText( M5SLIDER ) = CurData[4].text;
}



void
do_keys( int key )
{
     switch( key )
     {
	   /* Restore the previous values */
	   case UNDO: PopValues();
		      initialize();
		      RedrawSliders();
	              break;

           /* RESTORE DEFAULTS */
	   case HOME:
		      CurData[4].value = atoi( TedText( M5SLIDER ) );
		      CurData[4].value = min( CurData[4].value, CurData[4].xmax );
		      CurData[4].value = max( CurData[4].value, CurData[4].xmin );

		      PushValues();

		      CurData[0].value = INIT_DISPLAY;     /* Display */
		      CurData[1].value = INIT_DRAG;  	   /* DRAG  */
		      CurData[2].value = INIT_RESPONSE;    /* RESPONSE */
		      CurData[3].value = INIT_SCROLL;      /* SCROLL */
		      CurData[4].value = INIT_MENU;        /* MENU_HEIGHT */

		      initialize();
		      RedrawSliders();
	              break;
     }
}



void
PushValues( void )
{
     int i;

     for( i = 0; i < 5; i++ )
        OldValue[i] = CurData[i].value;
}


void
PopValues( void )
{
   int i;
 
   for( i = 0; i < 5; i++ )
      CurData[i].value = OldValue[i];
}


void
GetValues( void )
{
   int i;
 
   for( i = 0; i < 5; i++ )
     CurData[i].value = saved[i];
}



void
PutValues( void )
{
   int i;
   
   for( i = 0; i < 5; i++ )
     saved[i] = CurData[i].value;
}



void
RedrawSliders( void )
{
    GRECT rect;

    ObjcDraw( tree, M1BASE, MAX_DEPTH, NULL );
    ObjcDraw( tree, M2BASE, MAX_DEPTH, NULL );
    ObjcDraw( tree, M3BASE, MAX_DEPTH, NULL );
    ObjcDraw( tree, M4BASE, MAX_DEPTH, NULL );

    rect = ObRect( M5SLIDER );
    objc_offset( tree, M5SLIDER, &rect.g_x, &rect.g_y );
    rect.g_y -= 3;
    rect.g_h += 6;
    /* Stupid way to make sure we still have the editable line */
    ObjcDraw( tree, ROOT, MAX_DEPTH, &rect );
}



void
SetHardWare( void )
{
    TData.Display = (LONG)CurData[0].value;
    TData.Drag    = (LONG)CurData[1].value;
    TData.Delay   = (LONG)CurData[2].value;
    TData.Speed   = (LONG)CurData[3].value;
    TData.Height  = CurData[4].value;
    menu_settings( 1, &TData );
}



void
GetHardWare( void )
{
    menu_settings( 0, &TData );
    CurData[0].value = (WORD)TData.Display;
    CurData[1].value = (WORD)TData.Drag;
    CurData[2].value = (WORD)TData.Delay;
    CurData[3].value = (WORD)TData.Speed;
    CurData[4].value = TData.Height;
}
