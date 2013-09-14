/* 
 * sound.c
 * (c) 1990 by Atari Corporation
 *
 * The Sound/Volume Control Panel Extension for TT/STE machines.
 * 92Jul9	cgee    if AES version >= 3.2, use MFsave, else skip
 *
 * 90Jul13	cgee	Removed Mallocs (static allocation of sound buffers
 *
 * 90Jul8	cgee	Added Workstation Routines
 *
 * 90Jun18	towns	Fixed volume and balance parameters
 *
 * 90Apr20	cgee	Added code to check for Malloc Errors
 *			Redid code so that the sound parameters are
 *			slammed into the hardware while a slider object
 *			is moving, versus setting it after we lift 
 *			the mouse button.
 *			
 * 90Apr18	cgee	Modified slider code to NEW style slider calls
 *			Fixed Slider Redraw Bug ( Balance Slider )
 *			Fixed Initial Volume Redraw Bug ( VSLIDER Redraw )
 *			Save Defaults will update old data like an OK
 *
 * 90Apr02	towns	kleaned up code. Everything appears to work.
 *
 * 90Mar15	towns	modified cpx_call and cpx_init so that they
 *			take care of the old_data and cur_data areas.
 *
 * 90Mar14	towns	changed structure of code. Added lots of 
 *			comments. Moved some stuff into a new 
 *			header file I addded called sound_p.h.
 *
 * 90Mar14	towns	modified code to use SND structure.
 *
 * 90Feb20	cgee	initial design.
 *
 * 
 */

/* Include Files */
#include <sys\gemskel.h>
#include <tos.h>
#include <stdlib.h>
#include <stdio.h>

#include "country.h"

#include "sound.h"		/* Resource include file	*/
#include "sound.rsh"

				/* Local Includes.. 		*/
#include "..\cpxdata.h"		/* CPX generic header		*/
#include "sound_p.h"		/* Sound CPX specific header	*/

#define MAX_BAL		20
#define MWmask 		*( (int *)0xff8924L )
#define MWdata 		*( (int *)0xff8922L )	
#define MWMASKVAL	03777

/* --------------------------------------------------------------------	*/
/* Global Variables 							*/
/* --------------------------------------------------------------------	*/
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];

char    BufferA[ 8000 ];		/* Blit Buffers 		*/
char    BufferB[ 8000 ];

int 	errno;				/* Error Number 		*/

SND	cur_data, *old_data;		/* Structures for Sound Info	*/

int 	cur_face;			/* Current Face     		*/
					/* Index into Face_array[]      */
					/* based on cur_balance which   */
					/* ranges from 0-28. Note       */
					/* That the actual range is     */
					/* 0-14 for each side.          */
					/* An index of 14 in this case  */
					/* is the absolute center.      */
					/* The index below tells which  */
					/* image to use for the face    */

int 	face_array[] = { HD1, HD1, HD1, HD1, HD1,
			 HD2, HD2, HD2, HD2, HD2, HD2,
			 HD3, HD3, HD3, HD3, HD3, HD3,	
		         HD4, HD4, HD4, HD4, HD4, HD4, HD4,
		         HD5, HD5, HD5, HD5, HD5, HD5,
		         HD6, HD6, HD6, HD6, HD6, HD6,
		         HD7, HD7, HD7, HD7, HD7
		  	};


static char beep[] = {			/* The data for the Boing! Snd	*/

	0x00, 0x00,
	0x01, 0x01,
	0x02, 0x01,
	0x03, 0x01,
	0x04, 0x02,
	0x05, 0x01,
	0x07, 0x38, 
	0x08, 0x10,
	0x09, 0x10,
	0x0A, 0x10,
	0x0B, 0x00,
	0x0C, 0x30,
	0x0D, 0x03,
	0xFF, 100,
	0x09, 0x00,
	0x0A, 0x00,
	0xFF, 0x00
};

					/* BLiT variables.. 		*/

MFDB 	source;				/* Source MFDB  		*/
MFDB 	dest;				/* Destination	MFDB 		*/
int  	pxy[8];				/* xyarrays...          	*/
MFDB 	vselect;			/* MFDB for the selected  	*/
MFDB 	vdeselect;			/* and deselected areas   	*/
					/* Note: SELECT areas are 	*/
					/* BLACK. DESELECTED AREAS	*/
					/* are WHITE...		      	*/
long 	location = 0L;			/* Screen MFDB always     	*/

long 	*volSptr;			/* PTR to VOL SELECT AREA  	*/
long 	*volDptr;			/* PTR to VOL DESELECT AREA	*/
int  	width;				/* width of volume area  	*/
int  	height;				/* height of volume area 	*/
int  	cindex[2];			/* Color for vrt_cpyfm   	*/
int  	nplanes;			/* Number of planes		*/
				   
XCPB 	*xcpb;				/* XControl Parameter Block	*/
CPXINFO cpxinfo;			/* CPXInfo Structure used by XC	*/
SND	*old_data, cur_data;		/* The Sound Structures. 	*/


int 	work_out[57];			/* VDI bindings.. 		*/
int 	vhandle;
int	SNDFlag;			/* DMA Sound Flag 		*/
int	left, right;
extern 	SND	save_vars;		/* used in cpxstart.s		*/

char	volume[3], left_b[3], right_b[3], bass[3], treble[3];
MFORM   Other;				/* MFORM for saving linea-A mouse buffer*/
int     AES_Version;


/* Functions! */ 

/* --------------------------------------------------------------------	*/
/* cpx_init()								*/
/*									*/
/* Initialize the CPX							*/
/*									*/
/* --------------------------------------------------------------------	*/

CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
	long	value;
	long	cookie = '_SND';
	int	ret;
	
	xcpb = Xcpb;

	/* If the boot flag is set.. */
    	if( xcpb->booting ) {

		/* 
		 * get the saved settings from the saved_vars
		 * area. Put those values into the old_data area.
		 * transfer the old_data area to the cur_data area.
		 * Be sure to slam the hardware with old_data! 
		 *
		 */ 
		ret = (*xcpb->getcookie)( cookie, &value );
		
		/* If there is a cookie jar.. do some stuff! */
		if( ret ) {
			if( value & 0x02L ) {
				old_data = ( SND * )(*xcpb->Get_Buffer)();
				get_saved_settings( old_data );
				cur_data = *old_data;
				set_balance( old_data->balance );
				configure( old_data );
			}
		}
		/* Return True */
      		return( ( CPXINFO *)TRUE );  
      		
    	} else {

		appl_init();
		AES_Version = _GemParBlk.global[0];
		
	/* Otherwise.. do this. */

       		/* If the SkipRshFix flag isn't set, then fix up the rsc */
       	
       		if( !xcpb->SkipRshFix )    
          		(*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, 
          				 NUM_TREE, rs_object, rs_tedinfo, 
          				 rs_strings, rs_iconblk, rs_bitblk, 
          				 rs_frstr, rs_frimg, rs_trindex, 
          				 rs_imdope );


		/* Restore the values from the Buffer */
		ret = ( *xcpb->getcookie)( cookie, &value );
		if( ret ) {
			if( value & 0x02L ) {
				SNDFlag  = TRUE;
				old_data = ( SND * )(*xcpb->Get_Buffer)();
				cur_data = *old_data;
				set_balance( old_data->balance );
				configure( old_data );
			} else
			 	SNDFlag = FALSE;
		} else
			SNDFlag = FALSE;
			
		cur_face    	 = face_array[cur_data.balance];	
		
		/* Find out how many planes we have.. */
		open_vwork();
       		vq_extnd( vhandle, 1, work_out );
       		nplanes = work_out[4];			
       	        close_vwork();
       	        
       		/* Initialize the CPXINFO structure, so that XControl is 
       		 * happy!
       		 */
       		 
       		cpxinfo.cpx_call 	= cpx_call;
       		cpxinfo.cpx_draw   	= NULL;
       		cpxinfo.cpx_wmove  	= NULL;
       		cpxinfo.cpx_timer  	= NULL;
       		cpxinfo.cpx_key    	= NULL;
       		cpxinfo.cpx_button 	= NULL;
       		cpxinfo.cpx_m1 	  	= NULL;
       		cpxinfo.cpx_m2	  	= NULL;
       		cpxinfo.cpx_hook	= NULL;
       		cpxinfo.cpx_close  	= NULL;
 
 		/* Then return it! */
       		return( &cpxinfo );
    	}
}

/* --------------------------------------------------------------------	*/
/* cpx_call								*/
/*									*/
/* Call up the CPX using XForm_do()					*/
/*									*/
/* --------------------------------------------------------------------	*/

BOOLEAN
cdecl cpx_call( GRECT *rect )
{
   OBJECT	*tree;
   int 		button;
   int 		quit = 0;
   WORD 	msg[8];
   MRETS 	mk;
   int   	ox, oy;

   /* If no DMA sound, then return and we are outta here! */
   if ( !SNDFlag ) {
	( *xcpb->XGen_Alert )( NO_SOUND_DMA );
	return( FALSE );
   }
	volume[2] = left_b[2] = right_b[2] = bass[2] = treble[2] = '\0';

   /* Setup the volume, sliders, and the BLiTs */
   if( !setup_volume() )
   {
       /* Error in malloc'ing memory */
       (*xcpb->XGen_Alert)( MEM_ERR );
       return( FALSE );
   }
   setup_MFDB();
				
   /* Set the appropriate Resource Tree */
   tree = ( OBJECT * )rs_trindex[SOUND];
   tree[HDBASE].ob_spec.bitblk = (BITBLK *)rs_frimg[cur_face - HD1];
   ObX( ROOT ) = rect->g_x;
   ObY( ROOT ) = rect->g_y;

   /* Draw the tree */

   /* This is an attempt to fix balance slider problem!
    * The width of the slider must be an even number, otherwise
    * we leave spore on the right edge.
    */
   ObW( BSLIDER ) = 20;	

   HideObj( VSLIDER );
   HideObj( BSLIDER );
   HideObj( BASSSLID );
   HideObj( TREBSLID );
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
   ShowObj( VSLIDER );
   ShowObj( BSLIDER );
   ShowObj( BASSSLID );
   ShowObj( TREBSLID );

   setup_sliders();
   	
   /* Volume Slider and Text Numbers */
   (*xcpb->Sl_y)( tree, VBASE, VSLIDER, cur_data.volume,
    	         VOL_MIN, VOL_MAX, slide_volume );
   Objc_draw( tree, VBASE, MAX_DEPTH, NULL );
   Objc_draw( tree, BBASE, MAX_DEPTH, NULL );
   Objc_draw( tree, BASSBASE, MAX_DEPTH, NULL );
   Objc_draw( tree, TREBBASE, MAX_DEPTH, NULL );
      
   /* Go into a loop until a quit Flag is set */
   do
   {

	/* Go into an XForm_do and wait for a touchexit */
	button = (*xcpb->Xform_do)( tree, 0, msg );

	/* switch on whatever was clicked on */
     	switch( button )
     	{
     	   case RSAVE:	if ( (*xcpb->XGen_Alert)( SAVE_DEFAULTS ) )
     			{
     			     (*xcpb->CPX_Save)( &cur_data, sizeof( SND ) );
        		     Ok();
			}
			deselect( tree, RSAVE );     			     
     			break;
     				
 	   case BOK:	quit = BOK;
     			Deselect( BOK );
     			Ok();
     			break;
     					
	   case CANCEL:	quit = CANCEL;
     		  	Deselect( CANCEL );
			Cancel();
     		  	break;
     		
     	   case BSLIDER:  /* Balance Slider Control */
     	   		  (*xcpb->MFsave)( MFSAVE, &Other );
     	   		  if( AES_Version >= 0x0320 )
     	   		      graf_mouse( FLAT_HAND, 0L );
     			  (*xcpb->Sl_dragx)( tree, BBASE, BSLIDER, BAL_MIN,
     			                    BAL_MAX, &cur_data.balance,
     			                    slide_balance );
     			  (*xcpb->MFsave)( MFRESTORE, &Other );                   
     			  break;
     					  
	   case BL:  /* Balance Control Left Arrow */
     		     (*xcpb->Sl_arrow)( tree, BBASE, BSLIDER, BL, -1,
     		                       BAL_MIN, BAL_MAX, &cur_data.balance,
     		                       HORIZONTAL, slide_balance );
     		     break;
     					
	   case BR:  /* Balance Control Right Arrow */
     		     (*xcpb->Sl_arrow)( tree, BBASE, BSLIDER, BR, 1, BAL_MIN,
     		                       BAL_MAX, &cur_data.balance,
     		                       HORIZONTAL, slide_balance );
     		     break;

	   case BBASE:	Graf_mkstate( &mk );
     			objc_offset( tree, BSLIDER, &ox, &oy );
     			oy = (( mk.x < ox ) ? ( -2 ) : ( 2 ));
     			(*xcpb->Sl_arrow)( tree, BBASE, BSLIDER, -1, oy,
     			                  BAL_MIN, BAL_MAX,
     			                  &cur_data.balance, HORIZONTAL,
     			                  slide_balance );
			break;
     		
	   case VSLIDER:  /* Volume Slider Control */
     	   		  (*xcpb->MFsave)( MFSAVE, &Other );
     	   		  if( AES_Version >= 0x0320 )
	    	   	      graf_mouse( FLAT_HAND, 0L );
    			  (*xcpb->Sl_dragy)( tree, VBASE, VSLIDER, VOL_MIN,
     			                    VOL_MAX, &cur_data.volume,
     			                    slide_volume );
      			  (*xcpb->MFsave)( MFRESTORE, &Other );                   
    			  break;
     						
	   case VR:	/* Volume Control Right Arrow */
     			(*xcpb->Sl_arrow)( tree, VBASE, VSLIDER, VR, 1,
     			                  VOL_MIN, VOL_MAX,
     			                  &cur_data.volume, VERTICAL,
     			                  slide_volume );
     			break;
     					
	   case VL:	/* Volume Control Left Arrow */
     			(*xcpb->Sl_arrow)( tree, VBASE, VSLIDER, VL, -1,
     			                  VOL_MIN, VOL_MAX,
     			                  &cur_data.volume, VERTICAL,
     			                  slide_volume );
     			break;
     				
	   case VBASE:	Graf_mkstate( &mk );
     			objc_offset( tree, VSLIDER, &ox, &oy );
     			ox = (( mk.y < oy ) ? ( 2 ) : ( -2 ));
     			(*xcpb->Sl_arrow)( tree, VBASE, VSLIDER, -1, ox,
     			                  VOL_MIN, VOL_MAX,
     			                  &cur_data.volume, VERTICAL,
     			                  slide_volume );
     			break;
     						
	   case BASSSLID:  /* Bass Slider Control */
      	   		   (*xcpb->MFsave)( MFSAVE, &Other );
      	   		   if( AES_Version >= 0x0320 )
     	   		       graf_mouse( FLAT_HAND, 0L );
    			   (*xcpb->Sl_dragx)( tree, BASSBASE, BASSSLID,
     			                     BASS_MIN, BASS_MAX,
     			                     &cur_data.bass,
     			                     slide_bass );
      			   (*xcpb->MFsave)( MFRESTORE, &Other );                   
    			   break;
     			
	   case LBASS:	/* Bass Control Left Arrow */
     			(*xcpb->Sl_arrow)( tree, BASSBASE, BASSSLID, LBASS,
     			                  -1, BASS_MIN, BASS_MAX,
     			                  &cur_data.bass, HORIZONTAL,
     			                  slide_bass );
     			break;
     							
	   case RBASS:	/* Bass Control Right Arrow */
     			(*xcpb->Sl_arrow)( tree, BASSBASE, BASSSLID, RBASS,
     			                  1, BASS_MIN, BASS_MAX,
     			                  &cur_data.bass, HORIZONTAL,
     			                  slide_bass );
     			break;

	   case BASSBASE:  Graf_mkstate( &mk );
     		  	   objc_offset( tree, BASSSLID, &ox, &oy );
     			   oy = (( mk.x < ox ) ? ( -2 ) : ( 2 ));
     			   (*xcpb->Sl_arrow)( tree, BASSBASE, BASSSLID, -1,
     			                     oy, BASS_MIN, BASS_MAX,
     			                     &cur_data.bass, HORIZONTAL,
     			                     slide_bass );   
			   break;
								     						
	   case TREBSLID:  /* Treble Slider Control */
     	   		   (*xcpb->MFsave)( MFSAVE, &Other );
     	   		   if( AES_Version >= 0x0320 )
     	   		       graf_mouse( FLAT_HAND, 0L );
     			   (*xcpb->Sl_dragx)( tree, TREBBASE, TREBSLID,
     			                     TREBLE_MIN, TREBLE_MAX,
     			                     &cur_data.treble,
     			                     slide_treble );
       			   (*xcpb->MFsave)( MFRESTORE, &Other );                   
    			   break;
     							
	   case LTREB:	/* Treble Control Left Arrow */
     			(*xcpb->Sl_arrow)( tree, TREBBASE, TREBSLID, LTREB,
     			                  -1, TREBLE_MIN, TREBLE_MAX,
     			                  &cur_data.treble, HORIZONTAL,
     			                  slide_treble );
     			break;
     						
	   case RTREB:	/* Treble Contrl Right Arrow */
     			(*xcpb->Sl_arrow)( tree, TREBBASE, TREBSLID, RTREB,
     			                  1, TREBLE_MIN, TREBLE_MAX,
     			                  &cur_data.treble, HORIZONTAL,
     			                  slide_treble );
     			break;

	   case TREBBASE:  Graf_mkstate( &mk );
		    	   objc_offset( tree, TREBSLID, &ox, &oy );
     			   oy = (( mk.x < ox ) ? ( -2 ) : ( 2 ));
     			   (*xcpb->Sl_arrow)( tree, TREBBASE, TREBSLID, -1,
     			                     oy, TREBLE_MIN, TREBLE_MAX,
     			                     &cur_data.treble, HORIZONTAL,
     			                     slide_treble );   
     			   break;

	   case HDBASE:	Dosound( ( void * )beep );
			break;
					  
	   default:	if( button == -1 )
	    		{
     			  switch( msg[0] )
     			  {
     			     case WM_REDRAW: do_redraw( msg );
					     break;

	     		     case AC_CLOSE:  Cancel();
	     				     quit = CANCEL;
	     				     break;
	     				     		
     			     case WM_CLOSED: Ok();
     					     quit = CANCEL;
					     break;

	     		     default:	break;
     		   	   }
     			}
     			break;

	} /* End of switch( button ) */

   } while( !quit );
   
#if 0  
   /* Free up Malloc'ed Ptrs and clear them out... */
   if( volSptr )
   	Mfree( volSptr );
   if( volDptr )
   	Mfree( volDptr );
   volSptr = volDptr = NULL;	
#endif
   
   return( FALSE );
}

/* --------------------------------------------------------------------	*/
/* setup_sliders() 							*/
/*									*/
/* Initialize the visual aspect of the sliders. 			*/
/*									*/
/* --------------------------------------------------------------------	*/

void
setup_sliders( void )
{
	OBJECT *tree = (OBJECT *)rs_trindex[SOUND];
    	
 
    	/* Balance Slider and Text Numbers	*/
    	(*xcpb->Sl_x)( tree, BBASE, BSLIDER, cur_data.balance, BAL_MIN,
    	              BAL_MAX, slide_balance ); 
       
    
    	/* Bass Slider and Text Numbers		*/
    	(*xcpb->Sl_x)( tree, BASSBASE, BASSSLID, cur_data.bass, BASS_MIN,
    	              BASS_MAX, slide_bass );

    
    	/* Treble Slider and Text Numbers	*/
    	(*xcpb->Sl_x)( tree, TREBBASE, TREBSLID, cur_data.treble,
    	              TREBLE_MIN, TREBLE_MAX, slide_treble );
}



/* --------------------------------------------------------------------	*/
/* setup_volume()							*/
/*									*/
/* Initialize the MFDB aspects of the volume area			*/
/*									*/
/* --------------------------------------------------------------------	*/
BOOLEAN
setup_volume( void )
{
	int 		i;
/*	unsigned long	size;*/
	BOOLEAN  flag = TRUE;	
	
	/* Set the resource tree variable.. */
	OBJECT *tree = (OBJECT *)rs_trindex[SOUND];

	graf_mouse( M_OFF, 0L );	/* Turn off the mouse 	*/


	width  = ObW( VSBASE );		/* Calculate the width	*/
	height = ObH( VSBASE );		/* and height of the  	*/
					/* Volume rectangles  	*/

#if 0    	
	size = (unsigned long)(((long)width + 7L)/8L) *
	                        (long)height * (long)nplanes;
	                        
    	/* These need Error Checking */	                        
	volSptr = Malloc( (unsigned long) size + ( size / 2L ) );
	volDptr = Malloc( (unsigned long) size + ( size / 2L ) );
#endif
	volSptr = ( long *)BufferA;
	volDptr = ( long *)BufferB;
	
	open_vwork();
	vs_clip( vhandle, 0, pxy );	/* Turn off clipping  	*/
	if( volSptr && volDptr ) {	

	  	vselect.fd_addr		= volSptr;
	  	vdeselect.fd_addr	= volDptr;
	  	vdeselect.fd_w 		= vselect.fd_w 		= width;
	  	vdeselect.fd_h 		= vselect.fd_h 		= height;
	  	vdeselect.fd_wdwidth 	= vselect.fd_wdwidth 	= (width + 15)/16;
	  	vdeselect.fd_stand	= vselect.fd_stand 	= 0;
	  	vdeselect.fd_nplanes 	= vselect.fd_nplanes 	= nplanes;
	  	vselect.fd_r1 		= vselect.fd_r2		= vselect.fd_r3 = 0;
	  	vdeselect.fd_r1 	= vselect.fd_r2		= vselect.fd_r3 = 0;
     
 	  	pxy[0] = pxy[4] = 0;
 	  	pxy[1] = pxy[5] = 0;
 	  	pxy[2] = pxy[6] = width - 1;
 	  	pxy[3] = pxy[7] = height - 1;
 	  	vro_cpyfm( vhandle, 15, pxy, &vdeselect, &vdeselect );
	
          	for( i = VS38; i <= VS0; i++ ) {
 	    		pxy[0] = pxy[4] = 0;
 	    		pxy[1] = pxy[5] = ObY( i );
 	    		pxy[2] = pxy[6] = pxy[0] + ObW( i ) - 1;
 	    		pxy[3] = pxy[7] = pxy[1] + ObH( i ) - 1;
 	    		vro_cpyfm( vhandle, 0, pxy, &vdeselect, &vdeselect );
          	}
		pxy[0] = pxy[4] = 0;
 	  	pxy[1] = pxy[5] = 0;
 	  	pxy[2] = pxy[6] = width - 1;
 	  	pxy[3] = pxy[7] = height - 1;
          	vro_cpyfm( vhandle, 3, pxy, &vdeselect, &vselect );
 								
          	for( i = VS38; i <= VS0; i++ ) {
 	    		pxy[0] = pxy[4] = 1;
 	    		pxy[1] = pxy[5] = ObY( i ) + 1;
 	    		pxy[2] = pxy[6] = pxy[0] + ObW( i ) - 3;
 	    		pxy[3] = pxy[7] = pxy[1] + ObH( i ) - 2;
 	    		vro_cpyfm( vhandle, 15, pxy, &vselect, &vselect );
          	}
       }   
       close_vwork();

       graf_mouse( M_ON, 0L );	
       
       /* If there wasn't enough memory to malloc, clear any
        * malloc's that we were able to do, clear the variables
        * and then return false 
        */
#if 0        
       if( !volSptr || !volDptr )
       {
          if( volSptr )
             Mfree( volSptr );
          if( volDptr )
             Mfree( volDptr );
          volSptr = volDptr = NULL;
          flag = FALSE;
       }
#endif       
       return( flag );
}

/* --------------------------------------------------------------------	*/
/* setup_MFDB()								*/
/* 									*/
/* setup some initial face MFDB information				*/
/*									*/
/*									*/
/* --------------------------------------------------------------------	*/

void
setup_MFDB( void ) 
{
	source.fd_stand   = 0;
	source.fd_nplanes = 1;
	source.fd_r1 	  = source.fd_r2 = source.fd_r3 = 0;	
}


/* --------------------------------------------------------------------	*/
/* do_volume_blit()							*/
/*									*/
/* Update the visual area of the voume MFDB using BLiTs			*/
/*									*/
/* --------------------------------------------------------------------	*/

void
do_volume_blit( int value, GRECT *rect )
{
	int  	item;			/* New volume number index */
	int  	ox,oy;
	int  	vox, voy;
	int  	clipxy[4];
	GRECT 	xrect;

	OBJECT *tree = (OBJECT *)rs_trindex[SOUND];
	
	if( !volSptr || !volDptr ) return;
			
	graf_mouse( M_OFF, 0L );
	
	if( rect == ( GRECT *)0L ) {
		xrect = ObRect( VSBASE );
	   	objc_offset( tree, VSBASE, &xrect.g_x, &xrect.g_y );
	   	rc_2xy( &xrect, ( WORD *)clipxy );
	} else
          	rc_2xy( rect, ( WORD *)clipxy );

	open_vwork();	
	vs_clip( vhandle, 1, clipxy );
        item = VS0 - value + 1;		/* Get the Object Chosen   */
	objc_offset( tree, VSBASE, &vox, &voy );

	if( item <= VS0 ) {

	  	objc_offset( tree, item, &ox, &oy );
	  
	  	pxy[0] = 0;			/* Source	  	   */
	  	pxy[1] = ObY( item );
		pxy[2] = width - 1;
	 	pxy[3] = height - 1;
	
	  	pxy[4] = vox;			/* Destination		   */
	  	pxy[5] = oy;			/* needs offset of base    */
	  	pxy[6] = vox + width  - 1;
	  	pxy[7] = oy + height - 1;

	  	Vsync();
	  	vro_cpyfm(vhandle,3,pxy,&vselect,(MFDB *)&location);
        }
        
        if( item > VS38 ) {        

	  	objc_offset( tree, item - 1, &ox, &oy );

	  	pxy[0] = 0;			/* Source...		   */
	  	pxy[1] = 0;
	  	pxy[2] = width  - 1; 
	  	pxy[3] = ObY( item - 1 ) + ObH( item - 1 ) - 1;
	
	  	pxy[4] = vox;
	  	pxy[5] = voy;
	  	pxy[6] = vox + width  - 1;
	  	pxy[7] = oy + ObH( item - 1 ) - 1;

	  	Vsync();
	  	vro_cpyfm(vhandle,3,pxy,&vdeselect,(MFDB *)&location);
        }
	close_vwork();
	graf_mouse( M_ON, 0L );
}

/* --------------------------------------------------------------------	*/
/* do_face_blit()							*/
/* 									*/
/* BLiT the appropriate face into the MFDB area.			*/
/*									*/
/* --------------------------------------------------------------------	*/

void
do_face_blit( int numvalue )
{

	int 	item;
	GRECT 	p;
   	int 	clip[4]; 
	
	OBJECT *tree = (OBJECT *)rs_trindex[SOUND];

   	cindex[0] = 1;
	cindex[1] = 0;
	cur_face = face_array[numvalue];
	item = cur_face - HD1;

        tree[HDBASE].ob_spec.bitblk = (BITBLK *)rs_frimg[item];
      
	source.fd_addr     = tree[HDBASE].ob_spec.bitblk->bi_pdata;
 	source.fd_w 	   = ObW( HDBASE );
	source.fd_h 	   = ObH( HDBASE );
	source.fd_wdwidth  = ( ObW( HDBASE ) + 15 ) / 16;
	
	p      = ObRect( HDBASE );
	pxy[0] = pxy[1] = 0; 					/* Source...	*/ 
	pxy[2] = source.fd_w;  
	pxy[3] = source.fd_h;
								/* Destination  */
	clip[0] = pxy[4] = p.g_x + ObX( 0 ) + ObX( HDMASK );
	pxy[5]  = p.g_y + ObY( 0 ) + ObY( HDMASK );
	clip[2] = pxy[6] = pxy[4] + p.g_w - 1;
	pxy[7]  = pxy[5] + p.g_h - 1;

	clip[1]  = pxy[5];					/* clip Rectangle */
	clip[3]  = pxy[7];
	
	open_vwork();
	vs_clip( vhandle, 1, clip );
	Vsync();

	graf_mouse( M_OFF, 0L );
	vrt_cpyfm( vhandle, 1, pxy, &source, (MFDB *)&location, cindex );
	graf_mouse( M_ON, 0L );
	close_vwork();
}


/* slide_balance()
 *==========================================================================
 * Handle the BALANCE slider text and image updating
 */
void
slide_balance( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ SOUND ];
   	
   int 	value1;				/* Left Balance  	  */
   int 	value2;				/* Right Balance 	  */

   /* Blit the proper face onto the screen */	
   do_face_blit( cur_data.balance );			
   value1 = value2 = 0;

   /* Adjust the numbers for left and right balance
    * which range from 0 - 19 instead of 0 - 28
    */	   
   if( cur_data.balance >= BAL_MID )
	value2 = cur_data.balance - BAL_MID;
   else				
	value1 = BAL_MID - cur_data.balance;

   /* Convert Left Text Value */	   												
   itoa( value1, left_b, 10 );
   TedText( BALNUM1 ) = left_b;

   Objc_draw( tree, BALNUM1, 0, NULL );
	
   /* Convert Right Text Value */	
   itoa( value2, right_b, 10 );
   TedText( BALNUM2 ) = right_b;

   Objc_draw( tree, BALNUM2, 0, NULL );

   Supexec( set_bal );     			  		
}



/* slide_volume()
 *==========================================================================
 * Handle the VOLUME slider text and image updating
 */
void
slide_volume( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ SOUND ];
   
   /* Blit Volume MFDBs */
   if( cur_data.volume == BAL_MAX )
      do_volume_blit( BAL_MAX - 1, ( GRECT *)0L );
   else      
      do_volume_blit( cur_data.volume, ( GRECT *)0L );
   
   /* Set the Text Value... */
   itoa( cur_data.volume, volume, 10 );
   TedText( VSLIDER ) = volume;
   
   Objc_draw( tree, VSLIDER, MAX_DEPTH, NULL );
   
   Supexec( set_volume );
}



/* slide_bass()
 *==========================================================================
 * Handle the BASS slider text updating
 */
void
slide_bass( void )
{
  OBJECT *tree = ( OBJECT *)rs_trindex[ SOUND ];

  itoa( cur_data.bass, bass, 10 );
  TedText( BASSSLID ) = bass;

  Objc_draw( tree, BASSSLID, 0, NULL );

  Supexec( set_bass );
}



/* slide_treble()
 *==========================================================================
 * Handle the TREBLE slider text updating
 */
void
slide_treble( void )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ SOUND ];
    
    itoa( cur_data.treble, treble, 10 );
    TedText( TREBSLID ) = treble;

    Objc_draw( tree, TREBSLID, 0, NULL );

    Supexec( set_treble );
}


/* --------------------------------------------------------------------	*/
/* do_redraw()								*/
/*									*/
/* Preform a redraw for the non-object tree items that need to be 	*/
/* redrawn. Get the rectangel list from XControl and do any needed	*/
/* redrawing.. 								*/
/*									*/
/* --------------------------------------------------------------------	*/
void
do_redraw( WORD *msg )
{
   	GRECT 	*xrect;
   	GRECT 	rect;
   
   	/* Set the proper resource tree */
	OBJECT *tree = ( OBJECT *)rs_trindex[ SOUND ];

	/* Get the first Rectangle from XControl */
   	xrect = (*xcpb->GetFirstRect)( ( GRECT *)&msg[4] );

	/* While we have a real rectangle, do something with it. */
   	while( xrect ) {
    		rect = *xrect;
#if 0
	       if( cur_data.volume == BAL_MAX )
                   do_volume_blit( BAL_MAX - 1, ( GRECT *)0L );
 	       else      
	           do_volume_blit( cur_data.volume, ( GRECT *)0L );
#endif
		if( cur_data.volume == BAL_MAX )
		   do_volume_blit( BAL_MAX - 1, ( GRECT *)&rect );
		else
		   do_volume_blit( cur_data.volume, ( GRECT *)&rect );

        	Objc_draw( tree, VSLIDER, 1, &rect );
        	xrect = (*xcpb->GetNextRect)();
   	};   
}

/* Hardware settings! WARNING: Bad code. */

void
mwwrite( int x )
{
	MWmask = MWMASKVAL;
	MWdata = x;
	while( MWdata != 0 ) ;		/* Wait for bits to leave 	*/
	while( MWmask != MWMASKVAL ) ;	/* Wait for complete cycle	*/
}

void
set_balance( int balance )
{

	/* If the current balance is set in the left direction.. */

	if( balance < BAL_MID ) {

		/* Set left to the highest level, set the right to 
		 * reflect that it is lower. 
		 */
		 
		left  = MAX_BAL;
		right = MAX_BAL - ( MAX_BAL - balance );
	} else {
	
		left  = BAL_MAX - balance;
		right = MAX_BAL;
	}
}

/* These MUST BE SUPEXEC'ed */


/* Set the Volume */
long
set_volume( void )
{
	mwwrite( 02000 | 00300 | cur_data.volume );
	return( 0L );
}

/* set the bass value.. */
long
set_bass( void )
{
	mwwrite( 02000 | 00100 | cur_data.bass );
	return( 0L );
}

/* Treble settings.. */
long
set_treble( void )
{
	mwwrite( 02000 | 00200 | cur_data.treble );
	return( 0L );
}

/* Figure out the balance settings, then slam to hardware */
long
set_bal( void )
{
	set_balance( cur_data.balance );
	mwwrite( 02000 | 00500 | left );
	mwwrite( 02000 | 00400 | right );
	return( 0L );
}

/* --------------------------------------------------------------------	*/
/* Handle the OK button!						*/
/* --------------------------------------------------------------------	*/

void
Ok( void )
{
	/* Copy the current values to saved area. */

	*old_data = cur_data;
}

/* --------------------------------------------------------------------	*/
/* Handle the CANCEL button and ACC_CLOSE (which is a cancel) messages  */
/* --------------------------------------------------------------------	*/

void
Cancel( void )
{
	/* Since we are canceling the operation, reset the current 
	 * user interface values to the saved values.. 
	 */

	cur_data = *old_data;
}

void
get_saved_settings( SND *snd_struct )
{
	*snd_struct = save_vars;
}

long
configure( SND *snd_struct )
{
	long	oldssp;

	if( Super( (void *)1L) == 0) oldssp = Super( (void *)0L );
	else oldssp = 0;
			
	mwwrite( 02000 | 00300 | snd_struct->volume );
	mwwrite( 02000 | 00500 | left );
	mwwrite( 02000 | 00400 | right );
 	mwwrite( 02000 | 00200 | snd_struct->treble );
	mwwrite( 02000 | 00100 | snd_struct->bass );

	if( oldssp != 0 ) Super( (void *)oldssp );	
	return( 0L );
}


/* open_vwork(); 
 *==========================================================================
 * Open the Virtual Workstation
 */
void
open_vwork( void )
{
	int i;
 
	work_in[0] = Getrez()+2; /* let's not gag GDOS */
	for( i = 1; i < 10; work_in[i++] = 1 )
	;
	work_in[10] = 2; /* raster coordinates */
    	vhandle = xcpb->handle;
	v_opnvwk( work_in, &vhandle, work_out );
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
