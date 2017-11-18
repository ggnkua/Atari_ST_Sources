/*==========================================================================
 * FILE: 	XEVENT.C                                  
 *==========================================================================
 * DATE:        November 8, 1990
 * DESCRIPTION: Event CPX Skeleton
 * COMPILER:	Mark Williams C
 *
 * NOTES:
 *	The Event  CPX, unlike the Form CPX, must handle all of the
 *	messages itself.  Therefore, it is recommended that the CPX 
 *	programmer use a Form CPX whenever possible.  The only
 *	time one might need an Event CPX is when 'Timer' events are
 *	needed.
 */
  
  
/* INCLUDE FILES
 *==========================================================================
 */
#include "sample.h"
#include "sample.rsh"
#include "cpxdata.h"		/* CPX Data Structures */



/* PROTOTYPES
 *==========================================================================
 */
CPXINFO *cpx_init();
BOOLEAN	cpx_call();

void	cpx_draw();
void	cpx_wmove();
void	cpx_timer();
void 	cpx_key();
void	cpx_button();
void	cpx_m1();
void	cpx_m2();
BOOLEAN	cpx_hook();

void	Dummy();


/* DEFINES
 *==========================================================================
 */



/* EXTERNALS
 *==========================================================================
 */
extern int save_vars;



/* GLOBALS
 *==========================================================================
 */
XCPB *xcpb;		/* The XControl Parameter Block  */
CPXINFO cpxinfo;	/* The CPX Information structure */
int errno;		/* Used by the C runtime library */


/***** GLOBAL VARIABLES FOR VDI ***/
WORD	contrl[12];
WORD	intin[128];
WORD	ptsin[128];
WORD	intout[128];
WORD	ptsout[128];



/* FUNCTIONS
 *==========================================================================
 */

/* cpx_init()
 *==========================================================================
 * cpx_init() is where a CPX is first initialized.
 * There are TWO parts.
 *
 * PART ONE: cpx_init() is called when the CPX is first 'booted'. This is
 *	     where the CPX should read in its defaults and then set the
 *	     hardware based on those defaults.
 *
 * PART TWO: The other time cpx_init() is called is when the CPX is being 
 * 	     executed.  This is where the resource is fixed up and current
 *	     cpx variables are updated from the hardware.  In addition,
 *	     this is where the CPXINFO structure should be filled out.
 *
 * IN: XCPB  *Xcpb	Pointer to the XControl Parameter Block
 *
 * OUT: CPXINFO *ptr	Pointer to the CPX Information Structure
 *
 */
CPXINFO
*cdecl cpx_init( Xcpb )
XCPB *Xcpb;
{
    xcpb = Xcpb;
    
    appl_init();
    
    if( xcpb->booting )
    {
      /* Only those CPXs with their 'Booting' flag or 'Set-only' flag
       * set will be initialized here.
       *
       * Read in your defaults from 'save_vars' and slam them into
       * the hardware where appropriate.
       *
       * Return TRUE to tell XCONTROl that the header should be retained
       * so that the cpx may be executed.
       *
       * Return FALSE to tell XCONTRL NOT to retain our header.
       * An example of this would be a 'Set-only' CPX.
       */
      return( ( CPXINFO *)TRUE );  
    }
    else
    {
       /* Fixup the resource...
        * The flag prevents rsh_fix() from being called more than once.
        * If executing from disk, rsh_fix() is called every time. However,
        * if the CPX is 'resident', rsh_fix() will be called only once.
        */    
       if( !xcpb->SkipRshFix )
          (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                           rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                           rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                           rs_imdope );
                           
       /* Get current hardware attributes here and store them away */
          
       /* Initialize the CPXINFO structure
        * Set to 'Dummy()' all unused calls.
        */
          
       cpxinfo.cpx_call   = cpx_call;
       
       cpxinfo.cpx_draw   = cpx_draw;
       cpxinfo.cpx_wmove  = cpx_wmove;
       
       cpxinfo.cpx_timer  = cpx_timer;
       
       cpxinfo.cpx_key    = cpx_key;
       cpxinfo.cpx_button = cpx_button;
       
       cpxinfo.cpx_m1 	  = cpx_m1;
       cpxinfo.cpx_m2	  = cpx_m2;
       cpxinfo.cpx_hook	  = cpx_hook;
              
       cpxinfo.cpx_close  = cpx_close;

       /* Tell XControl what event messages we need...*/
       (*xcpb->Set_Evnt_Mask)( MU_MESAG|MU_BUTTON|MU_KEYBD, NULL, NULL, -1L );
       return( &cpxinfo );
    }
}




/* cpx_call()
 *==========================================================================
 * Called ONLY when the CPX is being executed.  Note that it is CPX_INIT()
 * that returned the ptr to cpx_call() back to XCONTROL.
 *
 * Cpx_call() is the entry point to displaying and manipulating the
 * dialog box.
 *
 * IN:  GRECT *rect	Ptr to a GRECT that describes the current work
 *			area of the XControl window.
 *
 * OUT:
 *     FALSE - The cpx has exited and no more messages are
 *	       needed.  XControl will either return to its
 *	       main menu or close its windows.
 *	       This is used by XForm_do() type CPXs.
 *
 *     TRUE  - The CPX requests that XCONTROL continue to
 *	       send AES messages.  This is used by Call-type CPXs.
 */
BOOLEAN
cpx_call( rect )
GRECT *rect;
{
     OBJECT *tree = ( OBJECT *)rs_trindex[ SAMPLE ];
     
     ObX( ROOT ) = rect->g_x;			
     ObY( ROOT ) = rect->g_y;
          
     objc_draw( tree, ROOT, MAX_DEPTH, PTRS( rect ) );

     return( TRUE );
}



/* cpx_draw()
 *==========================================================================
 * Called when a CPX is active and the XControl window needs to be redrawn.
 * To redraw, the CPX must go down the rectangle list using
 *          GetFirstRect() and GetNextRect().
 * 
 * IN:   GRECT *clip	Pointer to a GRECT describing the area that 
 *			needs to be redrawn.
 * OUT:  NONE
 */
void
cpx_draw( clip )
GRECT *clip;
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ SAMPLE ];
   GRECT *xrect;
   GRECT rect;
   
   xrect = (*xcpb->GetFirstRect)( clip );
   while( xrect )
   {
    	rect = *xrect;
        objc_draw( tree, ROOT, MAX_DEPTH, ELTS( rect ) );
        xrect = (*xcpb->GetNextRect)();
   };   
}




/* cpx_wmove()
 *==========================================================================
 * Called when the user moves the XControl window.
 * The CPX should fix up its object tree based on the new x,y coordinates.
 *
 * IN: GRECT *work	GRECT pointer to the work window's new coordinates.
 *
 * OUT: NONE
 */
void
cpx_wmove( work )
GRECT *work;
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ SAMPLE ];
   
   ObX( ROOT ) = work->g_x;
   ObY( ROOT ) = work->g_y;   
}




/* cpx_timer()
 *==========================================================================
 * Called when a timer event has occurred.
 * 
 * IN: int *quit	A Flag to tell XControl if this timer event has
 *			terminated the active CPX.
 *
 *			Set '*quit' to 'TRUE' to terminate the CPX
 *				         ELSE
 *			          IGNORE the '*quit' flag
 * OUT: none
 */
void
cpx_timer( quit )
int *quit;
{
}




/* cpx_key()
 *==========================================================================
 * Called when a keyboard event has occurred.
 * The variables kstate and key are the same ones returned from 
 * the evnt_multi() call.
 *
 * IN:  int kstate:	Represents the states of the control, alt and
 *			shift keys 'OR'd together.
 *
 *	int key:	Code of the key pressed.
 *
 *      int *quit	A Flag to tell XControl if this event has
 *			terminated the active CPX.
 *
 *			Set '*quit' to 'TRUE' to terminate the CPX
 *				         ELSE
 *		               IGNORE the '*quit' flag
 * OUT: none
 */
void 
cpx_key( kstate, key, quit )
int kstate;
int key;
int *quit;
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ SAMPLE ];
    
    switch( key )
    {
    	case ENTER:
        case RETURN:	
        		break;
        default:
        		break;
    }
}





/* cpx_button()
 *==========================================================================
 * Called by XControl when a button event has occurred.
 * 
 * IN:
 *	MRETS *mrets:   Pointer to the Mouse Parameters Structure returned
 *			by the event. The structure is defined to be:
 *
 *			typedef struct {
 *				WORD	x;
 *				WORD	y;
 *				WORD	buttons;
 *				WORD	kstate;
 *			}MRETS;
 *			
 *
 *	int   nclicks:	Number of button clicks
 *
 *      int *quit	A Flag to tell XControl if this event has
 *			terminated the active CPX.
 *
 *			Set '*quit' to 'TRUE' to terminate the CPX
 *				         ELSE
 *		               IGNORE the '*quit' flag
 * OUT: none
 *
 * The CPX must 'find' the object underneath the mouse when the event
 * occurred and decide what to do with that object.
 */
void
cpx_button( mrets, nclicks, quit )
MRETS *mrets;
int   nclicks;
int   *quit;
{
    OBJECT *tree  = (OBJECT *)rs_trindex[ SAMPLE ];
    int    obj;

    obj = objc_find( tree, ROOT, MAX_DEPTH, mrets->x, mrets->y );
    switch( obj )
    {
       case OK:     
       case CANCEL: 
      		     break;
       default:
       		     break;	     
    }
}





/* cpx_m1()
 *==========================================================================
 * Called when a mouse event has occurred.
 *
 * IN:
 *	MRETS *mrets:   Pointer to the Mouse Parameters Structure returned
 *			by the event. The structure is defined to be:
 *
 *			typedef struct {
 *				WORD	x;
 *				WORD	y;
 *				WORD	buttons;
 *				WORD	kstate;
 *			}MRETS;
 *
 *      int *quit	A Flag to tell XControl if this event has
 *			terminated the active CPX.
 *
 *			Set '*quit' to 'TRUE' to terminate the CPX
 *				         ELSE
 *		               IGNORE the '*quit' flag
 */
void
cpx_m1( mrets, quit )
MRETS *mrets;
int   *quit;
{
}




/* cpx_m2()
 *==========================================================================
 * Called when a mouse event has occurred.
 *
 * IN:
 *	MRETS *mrets:   Pointer to the Mouse Parameters Structure returned
 *			by the event. The structure is defined to be:
 *
 *			typedef struct {
 *				WORD	x;
 *				WORD	y;
 *				WORD	buttons;
 *				WORD	kstate;
 *			}MRETS;
 *
 *      int *quit	A Flag to tell XControl if this event has
 *			terminated the active CPX.
 *
 *			Set '*quit' to 'TRUE' to terminate the CPX
 *				         ELSE
 *		               IGNORE the '*quit' flag
 */
void
cpx_m2( mrets, quit )
MRETS *mrets;
int   *quit;
{
}



/* cpx_hook()
 *==========================================================================
 * Called immediately after evnt_multi() returns BEFORE
 * the event is handled by XCONTROL.
 *
 * This routine should return 'TRUE' ( nonzero )  to override default 
 * event handling or 'FALSE' (zero ) to continue with event handling.
 *
 * IN:
 *      int event;	The Events that have occurred OR'd together.
 *
 *	int *msg;	The message buffer containing the parameters of
 *			the event.
 *
 *	MRETS *mrets:   Pointer to the Mouse Parameters Structure returned
 *			by the event. The structure is defined to be:
 *
 *			typedef struct {
 *				WORD	x;
 *				WORD	y;
 *				WORD	buttons;
 *				WORD	kstate;
 *			}MRETS;
 *
 *	int *key;	The key selected
 *
 *	int *nclicks;	Number button clicks
 *
 * OUT: TRUE or FALSE
 */
BOOLEAN
cpx_hook( event, msg, mrets, key, nclicks )
int   event;
int   *msg;
MRETS *mrets;
int   *key;
int   *nclicks;
{
}



/* cpx_close()
 *==========================================================================
 * This routine is called whenever an ACC_CLOSE or WM_CLOSE message
 * is generated. The CPX should immediately free up any allocated
 * memory and return to XCONTROL.
 *
 * Treat ACC_CLOSE messages as 'Cancel'
 * Treat WM_CLOSE messages as 'OK'
 *
 * IN: BOOLEAN flag:	TRUE  - WM_CLOSE message
 *			FALSE - ACC_CLOSE message
 * OUT: none
 */
void
cpx_close( flag )
BOOLEAN flag;
{
}



/* Dummy()
 *==========================================================================
 */
void
Dummy()
{
}
 


