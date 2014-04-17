/* ======================================================================
 * FILE: ESTRING.C
 * ======================================================================
 * DATE: March 12, 1992
 *       March 16, 1992 ( works! )
 *	 March 17, 1992 added in the ability to save files to AES.CNF
 *			We preserve non-'setpath' lines
 *			Paths are designated as...
 *		        'setpath PATH=......(cr)(lf)'
 *	 March 20, 1992 renamed to epath.cpx
 *			renamed to setenv.cpx
 *			'setenv PATH=....(cr)(lf)'
 *			The setenv must be flushed left
 *			'#' comments out the entire line
 *
 *	 March 24, 1992 Try to keep the comments and setenv paths
 *			in the same locations when writing them out.
 *	 April 15, 1992 Happy Tax Day!
 *			Changed AES.CNF to GEM.CNF
 *
 *	 July   9, 1992 if AES Version 3.2 or greater, use MFsave, else skip
 *
 * DESCRIPTION: CPX to handle the Environmental strings ( AES >= 0400 only)
 *
 * Shel_write() calls are used to manipulate the paths.
 *
 *       shel_write( 8, 1, 0, "Path") - Insert a new path or replace an
 *				       existing one.
 *	 shel_write( 8, 2, size, buffer address ) - copies the strings
 *						from the aes buffer to
 *						our own buffer.
 *       shel_write( 8, 0 ) - returns the size of the AES buffer in bytes.
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
#include "estring.h"
#include "estring.rsh"
#include "tools.h"

	
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

void	 Do_Up( int base, int slider, int button, int index );
void	 Do_Down( int base, int slider, int button, int index );
void	 Do_Slider( int base, int slider, int index, int dclick );
void	 Do_Base( int base, int slider, int index );

int	 InitStrings( char *bufptr );
void	 SlotSetup( NODE_PTR list_ptr, int scount, int start_index );
void	 slot_offset_adjust( NODE_PTR ptr, int value, NODE_PTR array[] );
void	 Assign_Slots( NODE_PTR ptr, NODE_PTR array[] );

void	 mover_button( int obj, int clicks );
void	 DrawSlot( void );
void	 BlitSlots( int old_slit, int new_slit );
void	 UndoNodes( void );
void	 UndoSlots( void );

int      execform( OBJECT *tree, int start_obj );
void	 add_string( void );
void	 delete_string( void );
void	 EnableDelete( void );
void	 DisableDelete( void );

void	 initialize( void );
void	 InitSlots( void );
void	 FreeBuffer( void );
void	 save_cnf( void );

char	 GetBaseDrive( void );
long	 GetBootDrive( void );

NODE_PTR FindNode( char *textdata );


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
OBJECT  *ad_subtree;		/* edit path tree...	      */
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


NODE_PTR hdptr;				/* pointer to Nodes             */
NODE_PTR SlotStatus[ MAX_SLOTS ];	/* Ptrs for the scrolling slots */
NODE     Slots[ MAX_NODES ];		/* storage for the nodes        */
int      num_count;			/* Number of nodes loaded       */
char     fblank[]  = "                           "; /* Blanks for a slot*/

int  CurSlot;				/* current node ( by index)at top*/
int  OldSlot;				/* backup of current node        */
char temp[128];				/* Temp 128byte string array     */
char temp2[128];			/* Temp 128byte string array     */
char temp3[128];
MFORM Mbuffer;				/* old mouse image storage	 */

char *buffer = 0L;			/* buffer to store string data   */
char *bufptr = 0L;			/* malloced area to store data   */
char blank[3];				/* pted to by buffer if no data  */

/* Save File Variables */
int  BootDrive;			/* Boot Device - 0x446; */
struct FILEINFO  *olddma, newdma;	/* DTA buffers for _our_ searches */


/* Strings, Alerts etc, that need to be translated */
char Title1[] = "Modify Environment String";
char Title2[] = "Add Environment String";
char alert1[] = "[1][ | Delete the selected  | environment string?  ][ OK | Cancel ]";
char alert2[] = "[1][ | The environmental | string data is not  | available. ][ OK ]";
char alert3[] = "[1][ | Memory Error! ][ OK ]";
char alert4[] = "[1][ | There is a limit of  | 128 Environment Strings. ][ OK ]";
char alert5[] = "[1][ | Save the Environmental | String Data? ][ OK | Cancel ]";
char alert6[] = "[1][ | Memory Error! GEM.CNF | is not written to| GEM.OLD][ OK ]";
char alert7[] = "[1][ | Unable to open the GEM.CNF | file. The operation | is cancelled.][ OK ]";
char alert8[] = "[1][ | Unable to  open the GEM.OLD | file. The operation | is cancelled.][ OK ]";

int  AES_Version;


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

    currez = Getrez();				/* find current resolution */
    
    if( xcpb->booting )
    {
        return( ( CPXINFO *)TRUE );  
    }
    else
    { 
      if( _AESglobal[0] < 0x0400 )	/* if < version 0400 of AES */
      {
	 form_alert( 1, alert2 );
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
      ad_subtree   = (OBJECT *)rs_trindex[ SUBTREE ];

      ActiveTree( ad_tree );
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

     ActiveTree( ad_tree );

     WindGet(0, WF_WORKXYWH, &desk );	/* set clipping to */
     rc_2xy( &desk, clip );			/*   Desktop space */

     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;

     open_vwork();
     vs_clip( vhandle, 1, ( int *)clip );
     ObjcDraw( tree, ROOT, MAX_DEPTH,NULL );
     close_vwork();

          
     do
     {
        dclick = FALSE;
	button = (*xcpb->Xform_do)( tree, 0, msg );

	if(( button != -1 ) && ( button & 0x8000 ) )
        {
	   dclick = TRUE;
	   button &= 0x7fff;
        }

     	switch( button )
     	{
     	   case EEXIT:  quit = TRUE;
     	   	        Deselect( button );
			FreeBuffer();
     	   	        break;

	   case XADD:   add_string();
		        break;

	   case XDELETE: delete_string();
	   		 break;

	   case XSAVE:   save_cnf();
			 break;

	   case  T1:
	   case  T2:
	   case  T3:
	   case  T4:
	   case  T5:
	   case  T6:
	   case  T7:
	   case XUP:
	   case XDOWN:
	   case XSLIDE:
	   case XBASE:  mover_button( button, dclick );
			break;

     	   default:	if( button == -1 )
     			{
     			   switch( msg[0] )
     			   {
     			     case WM_REDRAW: /* redraw the cpx */
     			     		     break;
     			     		     
     			     case AC_CLOSE:  /* treated like a cancel */
     			     case WM_CLOSED: quit = TRUE; 	/* treated like an OK */
					     FreeBuffer();
					     break;
					     
			     case CT_KEY:    if( msg[3] == UNDO )
						 UndoNodes();
			     		     break;		     
     			     default:
     			     		break;
     			   }
     			}
			else
			  UndoNodes();
     			break;
     	}
     }while( !quit);
     return( FALSE );
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



/* InitStrings()
 *==========================================================================
 * Copies the strings from the buffer to the node structure.
 * returns the number of strings read in.
 */
int
InitStrings( char *bufptr )
{
   long     length;
   char     *ptr;
   int      count;
   long     xlength;
   NODE_PTR curptr;

   hdptr = NULL;
   ptr   = bufptr;   
   count = 0;
 
   length = strlen( ptr );
   while( length && ( count < MAX_NODES ) )
   {
	curptr = &Slots[ count ];
	strcpy( ESTRING( curptr ), ptr );
	strcpy( ACTUAL( curptr ), ptr );
	USED( curptr ) = FALSE;

	/* shorten the string to TEXT_LENGTH if it exceeds it
	 * So that we can display it...
	 */
	if( (xlength = strlen( ESTRING( curptr ))) > TEXT_LENGTH )
	    ESTRING( curptr )[27] = '\0';

	/* pad the shorter strings to the length of the buffer ( TEXT_LENGTH ) */
	while( ( xlength = strlen( ESTRING( curptr ))) < TEXT_LENGTH )
	   strcat( ESTRING( curptr ), " " );
	
	NEXT( curptr ) = NULL;      	

	/* fix up the previous pointer if this is not the first slot */
	if( count )
	  Slots[ count - 1 ].next = ( NODE *)&Slots[ count ];
	ptr += ( length + 1 );
	length = strlen( ptr );
	count++;

	if( count >= MAX_NODES )
          form_alert( 1, alert4 );
	
   }

   return( count );
}


/* SlotSetup()
 *==========================================================================
 */
void
SlotSetup( NODE_PTR list_ptr, int scount, int start_index )
{
    int i;

    hdptr = list_ptr;

    for( i = 0; i < MAX_SLOTS; i++ )
    {
       SlotStatus[i] = NULL;
       TedText( T1 + i ) = fblank;
    }


    if( scount > MAX_SLOTS )
    {
	if( start_index > ( scount - MAX_SLOTS ) )
	    start_index = ( scount - MAX_SLOTS);
    }

    slot_offset_adjust( hdptr, start_index, SlotStatus );
    OldSlot = CurSlot = start_index;

    (*xcpb->Sl_size)( tree, XBASE, XSLIDE, scount, MAX_SLOTS, VERTICAL, 1 );
    (*xcpb->Sl_y)( tree, XBASE, XSLIDE, CurSlot,
           	   max( scount - MAX_SLOTS, 0 ), 0, NULLFUNC );
}


/* slot_offset_adjust()
 *==========================================================================
 * Assign the linked list to the slits. Used in conjuction with Assign_Slit.
 * IN: FNODE *ptr:	The Head Pointer Node
 *     int   value:	The Index (base 0 ) into the linked list
 *     FNODE *array[]:	Text for the slider.
 */
void
slot_offset_adjust( NODE_PTR ptr, int value, NODE_PTR array[] )
{
    NODE_PTR curptr;
    int   i;
    
    curptr = ptr;
   
    for( i = 0; i < value; i++ )
       curptr = NEXT( curptr );
    Assign_Slots( curptr, array );
}



/* Assign_Slot()
 *==========================================================================
 *  Assigns the 7 slits visible a NODE, where possible.
 * IN: NODE *ptr:	Start assigning with this node
 *     NODE *array[]:	A 7 slit pointer array.
 */
void
Assign_Slots( NODE_PTR ptr, NODE_PTR array[] )
{
    int i;
    NODE_PTR curptr;
    
    curptr = ptr;
    for( i = 0; i < MAX_SLOTS; i++ )
    {
        array[ i ] = NULL;
        Deselect( T1 + i );
        
        TedText( T1 + i ) = fblank;
            
	if( IsActiveTree( ad_tree ) )
	{
            if( curptr && strlen( ESTRING( curptr )) )
            {
              array[i] = curptr;
              TedText( T1 + i ) = ESTRING( curptr );
	      curptr = NEXT( curptr );            
            }  
        }   
    }
}




/* mover_button()
 *==========================================================================
 * Handles the button events for the CPX Mover/Rename Function
 * IN: int obj:		The RCS Object clicked on.
 * OUT: BOOLEAN:   TRUE - Exit the CPX Mover Config
 *		   FALSE - Remain in the CPX Mover Config
 */
void
mover_button( int obj, int clicks )
{
   MRETS    mk;
   int      ox,oy;
   NODE_PTR curptr;
   LONG     xlength;
   int      button;

        OldSlot = CurSlot;

	if( obj == XUP )
	{
           UndoSlots();        
	   (*xcpb->Sl_arrow)( tree, XBASE, XSLIDE, XUP, -1,
           	    	      max( num_count - MAX_SLOTS, 0 ), 0,
           		      &CurSlot, VERTICAL, DrawSlot );
           return;			    	     
        }   			    	     

        if( obj == XDOWN )
        {
           UndoSlots();
           (*xcpb->Sl_arrow)( tree, XBASE, XSLIDE, XDOWN, 1,
           		      max( num_count - MAX_SLOTS, 0 ), 0,
           		      &CurSlot, VERTICAL, DrawSlot );
           return;			    	     
        }   			    	     

        if( obj == XSLIDE )
        {
           UndoSlots();
	   (*xcpb->MFsave)( MFSAVE, &Mbuffer );
	   if( AES_Version >= 0x0320 )
	       graf_mouse( FLAT_HAND, 0L );
           (*xcpb->Sl_dragy)( tree, XBASE, XSLIDE,
           		      max( num_count - MAX_SLOTS, 0 ), 0,
           	    	      &CurSlot, DrawSlot );
	   (*xcpb->MFsave)( MFRESTORE, &Mbuffer );
           return;		  
        }           		  
        
        if( obj == XBASE )
        {
           UndoSlots();   		 
           Graf_mkstate( &mk );
           objc_offset( tree, XSLIDE, &ox, &oy );
           ox = (( mk.y < oy ) ? ( -MAX_SLOTS ) : ( MAX_SLOTS ) );
           (*xcpb->Sl_arrow)( tree, XBASE, XSLIDE, -1, ox,
             	    	      max( num_count - MAX_SLOTS, 0 ), 0,
             	    	      &CurSlot, VERTICAL, DrawSlot );
           return;           		  	    	     
        }   		  	    	     

        /* CPX filename buttons */
        if( ( obj >= T1 ) &&
            ( obj <= T7 ) )
        {           
	   if( clicks )				/* double click? */
	   {
	       curptr = ( NODE_PTR)&Slots[(obj-T1)+CurSlot ];
	       if( (xlength = strlen( ACTUAL( curptr ) )) > 0 )
	       {
	         if( !IsSelected( obj ) )
	         {
		   UndoSlots();
		   EnableDelete();
		   select( tree, obj );
	         }
	         curptr = ( NODE_PTR)&Slots[(obj-T1)+CurSlot ];
	         strcpy( temp, ACTUAL( curptr ));

	         /* need to shorten the string if it is greater than length */
	         if( (xlength = strlen( temp )) > EDIT_LENGTH )
		   temp[ EDIT_LENGTH ] = '\0';
	
	         ActiveTree( ad_subtree ); 
	         TedText( ETITLE ) = Title1;
	         TedText( ETEXT )  = temp;	
	         button = execform( ad_subtree, ETEXT );

	         if( button == EOK )
                 {
		    strcpy( temp, TedText( ETEXT ) );
	            ActiveTree( ad_tree ); 
		    /* Tell the AES about the new string path
		     * The second temp is merely a placeholder
		     */
                    shel_write( 8, 1, 0, &temp[0], &temp[0] );
		    UndoNodes();
                 }	
	         ActiveTree( ad_tree ); 
	      }
	      else
	      {
		 UndoSlots();
		 DisableDelete();
	      }
	   }    
	   else
	   {
	       /* We check if its selected FIRST, so we can't do
		* the UndoSlots() here. It must be done twice in the code
		*/
	       if( IsSelected( obj ) )
	       {	
                 UndoSlots();
		 DisableDelete();
	       }
	       else
	       {
                 UndoSlots();
	         curptr = ( NODE_PTR)&Slots[(obj-T1)+CurSlot ];
		 if( (xlength = strlen( ACTUAL( curptr ) )) > 0 )
		 {
		   EnableDelete();
	           select( tree, obj );
		 }
	       }
	   }
	   return;
	}   		  		 
}



/* DrawSlot()
 *==========================================================================
 * The Draw Slider Routine passed into the Active ( CPX ) slider routines.
 */
void
DrawSlot( void )
{
    slot_offset_adjust( hdptr, CurSlot, SlotStatus );
    BlitSlots( OldSlot, CurSlot );
    OldSlot = CurSlot;
}


/* BlitSlots()
 *==========================================================================
 * Perform the blitting when the slits are scrolling.
 * IN: BOOLEAN flag:	either Active or Inactive
 *     int old_slit:	The previous slit
 *     int new_slit:	The current slit to work on.
 */
void
BlitSlots( int old_slit, int new_slit )
{
    GRECT srcbase;
    GRECT dstbase;
    GRECT clip;
    GRECT rect;
    int   pxy[16];
    GRECT clip2;
                
    int   offset;
    long  location = 0L;
    int   dummy;
    int   obj;
    int   base;
    
    obj  = T1;
    base = TBASE;
    clip = ObRect( base );
    objc_offset( tree, obj, &clip.g_x, &clip.g_y );
    clip2 = srcbase = dstbase = rect = clip;  
    offset = new_slit - old_slit;
               
    if( !offset )			/* went nowhere fast...*/
    	   return;

    open_vwork();
    rc_intersect( &desk, &clip2 );
    if(  ( abs( offset )  <  MAX_SLOTS ) &&
    	 rc_equal( &clip2, &clip ) 
      )
    {
       rect.g_h    = ( abs( offset ) * ObH( obj ) );
       dstbase.g_h = srcbase.g_h = ( MAX_SLOTS - abs( offset ) ) * ObH( obj );
       if( offset > 0 )
       {
          objc_offset( tree, obj + abs( MAX_SLOTS - offset ),
                       &dummy, &rect.g_y );
	  objc_offset( tree, obj + abs( offset ), &dummy, &srcbase.g_y );
       }
       else
	  objc_offset( tree, obj + abs( offset ), &dummy, &dstbase.g_y );

       rc_intersect( &desk, &srcbase );
       rc_intersect( &desk, &dstbase );
       
       rc_2xy( &srcbase, ( WORD *) &pxy[0] );
       rc_2xy( &dstbase, ( WORD *)&pxy[4] );
       rc_2xy( &clip, ( WORD *)&pxy[8] );
       
       vs_clip( vhandle, 1, &pxy[8] );

       graf_mouse( M_OFF, 0L );
       Vsync();
       vro_cpyfm( vhandle, 3, pxy, ( MFDB *)&location,
                                   ( MFDB *)&location );
       graf_mouse( M_ON, 0L );
    }
    else
    {
       rc_2xy( &clip, ( WORD *)&pxy[0] );
       vs_clip( vhandle, 1, &pxy[0] );
    }

    Vsync();
    ObjcDraw( tree, base, MAX_DEPTH, &rect );

    close_vwork();
}



/* UndoNodes()
 *==========================================================================
 */
void
UndoNodes( void )
{
    UndoSlots();

    FreeBuffer();
    initialize();
    ObjcDraw( ad_tree, TBASE, MAX_DEPTH, NULL );
    ObjcDraw( ad_tree, XBASE, MAX_DEPTH, NULL );
}



/* UndoSlots()
 *==========================================================================
 */
void
UndoSlots( void )
{
    int i;

    for( i = 0; i < MAX_SLOTS; i++ )
	deselect( tree, T1 + i );
    DisableDelete();
}



/* execform()
 * ================================================================
 * Custom routine to put up a standard dialog box and wait for a key.
 */
int
execform( OBJECT *tree, int start_obj )
{
   GRECT rect;
   GRECT xrect;
   int button;

   xrect.g_x = xrect.g_y = 10;
   xrect.g_w = xrect.g_h = 36;
   FormCenter( tree, &rect );
   FormDial( FMD_START, &xrect, &rect );
   ObjcDraw( tree, ROOT, MAX_DEPTH, &rect );
   button = form_do( tree, start_obj );
   FormDial( FMD_FINISH, &xrect, &rect );
   Deselect( button );
   return( button );
}



/* add_string()
 * ================================================================
 */
void
add_string( void )
{
       int button;

       ActiveTree( ad_subtree ); 
       TedText( ETITLE ) = Title2;
       temp[0] = '\0';
       TedText( ETEXT )  = temp;	
       button = execform( ad_subtree, ETEXT );


       if( button == EOK )
       {
	  strcpy( temp, TedText( ETEXT ));
          ActiveTree( ad_tree ); 
          /* Tell the AES about the new string path.
	   * The second temp is merely a placeholder.
	   */
          shel_write( 8, 1, 0, &temp[0], &temp[0] );
	  UndoNodes();
       }
       ActiveTree( ad_tree );	
       deselect( ad_tree, XADD );
}




/* delete_string()
 * ================================================================
 */
void
delete_string( void )
{
      int      button;
      NODE_PTR curptr;
      char     *cptr;
      int      i;

      if( ( button = form_alert( 1, alert1 )) == 1 )
      {
	  /* now, find the object we want to delete */
	  for( i = T1; i <= T7; i++ )
	  {
	     if( IsSelected( i ) )
	     {
		/* Found it, now, truncate it to the = sign */
		curptr = &Slots[ (i - T1)+CurSlot ];
		cptr = strchr( ESTRING( curptr ), '=' );
		if( cptr )
		{
		  cptr++;
		  *cptr = '\0';
		  /* Remove the current string path by truncating it to
 		   * its equal sign. The second ESTRING( curptr ) is
		   * merely a placeholder.
		   */
		  shel_write( 8, 1, 0, ESTRING( curptr ), ESTRING( curptr ) );
		  UndoNodes();
		}
		break;
	     }
	  }	 
      }
      deselect( ad_tree, XDELETE );
}



/* EnableDelete()
 * ================================================================
 */
void
EnableDelete( void )
{
   GRECT rect;

   if( IsDisabled( XDELETE ) )
   {
     objc_xywh( ad_tree, XDELETE, &rect );
     rect.g_x -= 2;
     rect.g_y -= 2;
     rect.g_w += 4;
     rect.g_h += 4;

     MakeExit( XDELETE );
     Enable( XDELETE );
     ObjcDraw( ad_tree, DUMMY2, MAX_DEPTH, &rect );
   }
}



/* DisableDelete()
 * ================================================================
 */
void
DisableDelete( void )
{
    GRECT rect;

    if( IsEnabled( XDELETE ) )
    {
      objc_xywh( ad_tree, XDELETE, &rect );
      rect.g_x -= 2;
      rect.g_y -= 2;
      rect.g_w += 4;
      rect.g_h += 4;
      NoExit( XDELETE );
      Disable( XDELETE );
      ObjcDraw( ad_tree, DUMMY2, MAX_DEPTH, &rect );
    }
}



/* initialize()
 * ================================================================
 */
void
initialize( void )
{
      int buffer_size;

      blank[0] = blank[1] = blank[2] = '\0';

      InitSlots();     

      /* Get the buffer_size of the environmental string area.
       * the 2 temp variables are merely placeholders.
       */
      buffer_size = shel_write( 8, 0, 0, &temp[0], &temp[0] );
      /* In case the buffer is zippo */
      if( !buffer_size )
         buffer_size = 2;

      /* Let's get a buffer TWICE as big as we really need it! */
      bufptr = ( char *)Malloc( ( long )( buffer_size * 2L ) );
      /* Write the environmental strings into my buffer area.
       * the 2nd buffer variable is merely a placeholder
       */
      if( !bufptr )
      {
	form_alert( 1, alert3 );
	buffer = &blank[0];	/* just so that we don't blow up */
      }
      else
        buffer = bufptr;
      shel_write( 8, 2, buffer_size, buffer, buffer );

      /* If empty, there will be 2 nulls */
      num_count = InitStrings( ( char *)buffer );

      SlotSetup( ( NODE_PTR )&Slots[0], num_count, 0 );
      NoExit( XDELETE );
      Disable( XDELETE );
}



/* FreeBuffer()
 * ================================================================
 */
void
FreeBuffer( void )
{
     if( bufptr )
        Mfree( bufptr );
     bufptr = 0L;
}


/* InitSlots()
 * ================================================================
 */
void
InitSlots( void )
{
   int      i;
   NODE_PTR curptr;

   for( i = 0; i < MAX_NODES; i++ )
   {
       curptr = &Slots[ i ];

       ACTUAL( curptr )[0]  = '\0';
       ESTRING( curptr )[0] = '\0';
       NEXT( curptr )       = NULL;
   }
}



/* save_cnf()
 * ================================================================
 * Save the estrings out to the file 'GEM.CNF'
 * Preserving non-'setenv' lines
 *
 *	1) read in the old file
 *	2) rename the old file to GEM.OLD
 *	
 *	3) Go thru the existing buffer and write out line by line
 *         1) if its a non'setenv' line, write it out
 *	   2) if its a setevn line, look for it in the linked list
 *	      Write it out, if found
 *	      skip it, if not
 *	   3) write out remaining setenvs....
 */
void
save_cnf( void )
{
      int      button;
      char     *cnfptr;
      long     cnfsize;
      int      sys_file;
      NODE_PTR curptr;
      NODE_PTR nodeptr;
      long     xlength;
      char     *line_ptr;
      char     *endptr;
      char     *crptr;
      int      i;
      char     *sptr;

      if( ( button = form_alert( 1, alert5 )) == 1 )
      {
	 olddma = Fgetdta();	
	 Fsetdta( &newdma );		/* Point to OUR buffer */

	 strcpy( temp, "C:\\GEM.CNF" );
	 temp[0] = GetBaseDrive();

	 strcpy( temp2, "C:\\GEM.OLD" );
	 temp2[0] = GetBaseDrive();
	 
	 cnfptr  = 0L;
	 cnfsize = 0L;

	 /* Normal file search for 1st file
	  * See if GEM.CNF even exists
	  */
         if( !Fsfirst( temp, 0 ))
	 {
	      /* found it! */
	      if( ( cnfptr = ( char *)Malloc( newdma.size * 2L )) != NULL )
	      {
		  cnfsize = newdma.size;
		  if( ( sys_file = (int)Fopen( temp, 0 ) ) < 0 )
		  {
		     /* Check if we can open the file. */
	   	     Fsetdta( olddma );		/* Point to OLD buffer */
	   	     if( cnfptr )
	   	     {
	   	       Mfree( cnfptr );
	   	       cnfptr = 0L;
	   	     }
	             form_alert(1, alert7 );
		     deselect( tree, XSAVE );
	             return;
		  }
		  /* The file is open! */
	  	  Fread( sys_file, cnfsize, cnfptr );
		  Fclose( sys_file );

		  /* write out the file to GEM.OLD */
		  if( ( sys_file = (int)Fcreate( temp2, 0) ) < 0 )
		  {
		     /* Can't create GEM.OLD */
	   	     Fsetdta( olddma );		/* Point to OLD buffer */
	   	     if( cnfptr )
	   	     {
	   	       Mfree( cnfptr );
	   	       cnfptr = 0L;
	   	     }
	             form_alert(1, alert8 );
		     deselect( tree, XSAVE );
	             return;
		  }
		  Fwrite( sys_file, cnfsize, cnfptr );
		  Fclose( sys_file );

		  /* Don't remove the memory just yet...we need it below */
	      }   /* end of If Malloc */
	      else
		form_alert( 1, alert6 ); /* can't malloc memory */
         }	/* end of if FSFIRST() */



	 /* write out NEW DATA to the file to GEM.CNF */
	 if( ( sys_file = (int)Fcreate( temp, 0) ) < 0 )
	 {
	     /* Can't create GEM.CNF */
	     Fsetdta( olddma );		/* Point to OLD buffer */
	     form_alert(1, alert7 );

	     /* Ok, let's remove the memory */
	     Mfree( cnfptr );
	     cnfptr = 0L;

	     deselect( tree, XSAVE );
	     return;
	 }


	 /* Clear out the USED flags first! */
	 if( num_count )	/* make sure we have paths */
	 {
	    curptr = &Slots[0];
	    while( curptr )
	    {
		USED( curptr ) = FALSE;
		curptr = NEXT( curptr );
	    }
	 }


	 /*
	  * -------------------------------------------------------------
	  * Only if there is an GEM.CNF file, meaning, cnfptr != NULLPTR
	  * Parse thru the buffer...
 	  *  1) if non-setenv line, write it out immediately
	  *  2) if setenv line, find the path in the linked list
	  *	if found, write it out
	  *     if not found, skip it
	  *  3) continue to the end of the buffer
	  */
	 if( cnfptr )
	 {
	    line_ptr = cnfptr;

	    endptr  = ( BYTE *)cnfptr + cnfsize;
	    *endptr = '\0';	/* make sure we have an end */
	    *( endptr + 1 ) = '\0';
	    *( endptr + 2 ) = '\0';

	    /* Look for both '(cr)(lf)' and '(lf)(cr)'*/
	    if( ( crptr = strstr( line_ptr, "\r\n" )) == NULL )
	       crptr = strstr( line_ptr, "\n\r" );	

	    while( crptr && *line_ptr )
	    {
	       for( i = 0; i < 128; i++ )  /* Clear the string */
		  temp[i] = '\0';

	       crptr += 2;	         /* gets us past the \r\n */
	       xlength = crptr - line_ptr;
	       strncpy( temp, line_ptr, xlength );
	       temp[ xlength + 1 ] = '\0';

	       /* Check if 'setenv' is in this line */
	       sptr = strstr( temp, "setenv" );
	       if( ( temp[0] == '#' ) || !sptr || strncmp( "setenv",temp, 6 ) )
	       {
		  /* Its not in this line, so write it out! */
		  xlength = strlen( temp );
	          Fwrite( sys_file, xlength, temp );			
	       }
	       else	
	       {  
		  /* Its IN this line, look for it first in the linked list*/
		  if( (nodeptr = FindNode( temp )) != NULL )
		  {		  
	            sprintf( temp, "setenv %s\r\n", ACTUAL( nodeptr ) );
		    xlength = strlen( temp );
	            Fwrite( sys_file, xlength, temp );
		    USED( nodeptr ) = TRUE;
		  }
	       }

	       /* Advance to the next line, if any */
	       line_ptr = crptr;

	       if( ( crptr = strstr( line_ptr, "\r\n" )) == NULL )
		   crptr = strstr( line_ptr, "\n\r" );
	    }	/* end of while loop */

	 }  /* end of if cnfptr */




	 /* write out the NEW PATHS - those not marked as USED
	  * --------------------------------------------------------------
	  */
	 if( num_count )	/* make sure we have paths */
	 {
	    curptr = &Slots[0];
	    while( curptr )
	    {
		if( !USED( curptr ) )
		{
	          sprintf( temp, "setenv %s\r\n", ACTUAL( curptr ) );
		  xlength = strlen( temp );
	          Fwrite( sys_file, xlength, temp );
		}
		curptr = NEXT( curptr );
	    }
	 }

	 /* OK! All done! Let's close up! */
	 Fclose( sys_file );

         /* Ok, let's remove the memory. 
	  * NOTE: this won't happen if there wasn't an GEM.CNF file
	  */
	 if( cnfptr )
	 {
   	   Mfree( cnfptr );
   	   cnfptr = 0L;
	 }

	 Fsetdta( olddma );		/* Point to OLD buffer */
      }
      deselect( tree, XSAVE );
}



/* GetBaseDrive()
 * ====================================================================
 * Get the A drive or C drive for the ASSIGN.SYS based upon
 * the boot drive.
 */
char
GetBaseDrive( void )
{
    char Drive;

    Supexec( GetBootDrive );
    Drive = BootDrive + 'A';    
    return( Drive );
}



/* GetBootDrive()
 * ====================================================================
 */
long
GetBootDrive( void )
{
   int *ptr;
   
   ptr = ( int *)0x446L;
   BootDrive = *ptr;
   return( 0L );
}



/* FindNode()
 * ====================================================================
 * Given a path in the GEM.CNF file, look for the path in the
 * linked list. return the nodeptr or NULL
 */
NODE_PTR
FindNode( char *textdata )
{
   NODE_PTR curptr;
   char *cptr;

   if( num_count )	/* make sure we have paths */
   {
      curptr = &Slots[0];
      while( curptr )
      {
  	if( !USED( curptr ) )
	{
	    strcpy( temp3, ACTUAL( curptr ) );
	    if( (cptr = strchr( temp3, '=' )) != NULL )
	    {
		/* Put a null after the = sign */
		*( cptr + 1 ) = '\0';
		if( ( cptr = strstr( textdata, temp3 )) != NULL )
		  return( curptr );
	    }
	}
	curptr = NEXT( curptr );
      }
   }

   return( ( NODE_PTR )NULLPTR );
}
