/*==========================================================================
 * FILE: XFORM.C
 *==========================================================================
 * DATE: November 8, 1990
 * DESCRIPTION: Form Skeleton CPX
 * COMPILER: Mark Williams C
 */
 

/* INCLUDE FILES
 *==========================================================================
 */
#include "sample.h"

#include "sample.rsh"
#include "cpxdata.h"		   /* Our CPX Data Structures */	


/* PROTOTYPES
 *==========================================================================
 */
CPXINFO	 *cpx_init();
BOOLEAN  cpx_call();
void	 Dummy();	
	

/* DEFINES
 *==========================================================================
 */
 


/* EXTERNALS
 *==========================================================================
 */
extern int save_vars;		/* Save_vars is where our default data
				 * is stored.
				 */



/* GLOBALS
 *==========================================================================
 */
XCPB *xcpb;			/* XControl Parameter Block   */
CPXINFO cpxinfo;		/* CPX Information Structure  */
int  errno;			/* Used by the C Runtime library*/

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
 *	     executed.  This is where the resource is fixed up and current
 *	     cpx variables are updated from the hardware.  In addition,
 *	     this is where the CPXINFO structure should be filled out.
 *
 * IN:  XCPB	*Xcpb:	Pointer to the XControl Parameter Block
 * OUT: CPXINFO  *ptr:	Pointer to the CP Information Structure
 */			
CPXINFO
*cpx_init( Xcpb )
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
         * Return TRUE to tell XCONTROL that the header should be retained
         * so that the cpx may be executed.
         *
         * Return FALSE to tell XCONTROL NOT to retain our header.
         * An example of this would be a 'Set-Only' CPX.
         */
        return( ( CPXINFO *)TRUE );  
    }
    else
    {    
      /* Fixup the resource...
       * The flag prevents rsh_fix() from being called more than once.
       * If executing from disk, rsh_fix() is called every time. However,
       * If the CPX is 'resident', rsh_fix() will be called only once.
       */
      if( !xcpb->SkipRshFix )
           (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                            rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                            rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                            rs_imdope );
           
      /* Get current hardware attributes here and store them away */
                 
      
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
 *==========================================================================
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
cpx_call( rect )
GRECT *rect;
{
     OBJECT *tree  = (OBJECT *)rs_trindex[ SAMPLE ];

     int  button;
     int  quit = 0;
     WORD msg[8];

     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;
               
     objc_draw( tree, ROOT, MAX_DEPTH, PTRS( rect ) );
     do
     {
	button = (*xcpb->Xform_do)( tree, 0, msg );
     	switch( button )
     	{
	/* Resource objects should be checked for here...
	 *
	 * ie...
	 *
	 * case OK:	
	 *	     	break;
	 *
	 * case CANCEL:
	 *		break;
	 * etc...
	 *			    
	 */	    
	 


	/* Xform_do() normally returns the object selected.
	 * In certain cases, it may return a '-1' instead.
	 * This means that the CPX should check for either
	 * WM_REDRAW: window redraw messages
	 * AC_CLOSE:  Close Desk Accessory messages
	 *   and
	 * WM_CLOSED: Close Window Messages
	 *
	 * WM_REDRAW: Xform_do() will handle object redraws. Non-object
	 *	      graphics must be redrawn by yourself.  To properly
	 *	      redraw the CPX, you must walk down the rectangle
	 *	      list.  XControl supplies two routines for you to
	 *	      do this. They are:
	 *		GetFirstRec() and GetNextRec()
	 *
	 * AC_CLOSE:  When the CPX receives the Close Desk Accessory
	 *	      message, the CPX should free up any malloc'ed
	 *	      memory and then exit the CPX.
	 *
	 * WM_CLOSED: When a Close Window message is received, 
	 *	      free up any malloc'ed memory and exit the CPX.
	 *
	 * CT_KEY:    A key was pressed. msg[3] contains the keycode
	 *	      of the key pressed as returned from an 'evnt_keybd()'.
	 *	      Note that we return non-printable keys only, such as
	 *	      F1-F10, HELP and UNDO. However the 'Arrow' keys are
	 *	      not supported because they are handled by Xform_do()
	 *	      for editable text fields.
	 */
	 										
     		default:	if( button == -1 )
     				{
     				   switch( msg[0] )
     				   {
     				     case WM_REDRAW: 
     				     		     break;
     				     case AC_CLOSE:
     				     		     break;
     				     case WM_CLOSED: 
						     break;
				     case CT_KEY:
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
Dummy()
{
}


