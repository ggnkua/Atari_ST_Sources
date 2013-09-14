/* 
 * sound.c
 * (c) 1990 by Atari Corporation
 *
 * The Sound/Volume Control Panel Extension for TT/STE machines.
 * 93Jan14	cgee	Modified to new 3D format
 * 92Oct01	cgee	Filtered out double-clicks from Xform_do()
 * 92Sep24	cgee	Increment Balance by proper ratio increment
 * 92Sep23	cgee	Snap Balance to the current ratio for lvol & rvol
 * 92Sep21	cgee	Increased BufferA and BufferB to 15K
 *			Setup_volume() - flipped flopped pen
 *			to draw with if nplanes is > 8
 * 92Sep17	cgee	Fixed Save Bugs ( Inversion problem )
 * 92Aug14      cgee    Convert to Sparrow Hardware and 3D
 *
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

#define MAX_BAL		15
#define MWmask 		*( (int *)0xff8924L )
#define MWdata 		*( (int *)0xff8922L )	
#define MWMASKVAL	03777
#define soundcmd( a, b )  (long)xbios( 0x82, a, b );



/* --------------------------------------------------------------------	*/
/* Global Variables 							*/
/* --------------------------------------------------------------------	*/
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
#if 0
char    BufferA[ 8000 ];		/* Blit Buffers 		*/
char    BufferB[ 8000 ];
#endif
char    BufferA[ 15000 ];		/* Blit Buffers 		*/
char    BufferB[ 15000 ];


int 	errno;				/* Error Number 		*/

SND	cur_data, old_data;		/* Structures for Sound Info	*/

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
int 	face_array[] = { HD1, HD1, HD1, HD1,
			 HD2, HD2, HD2, HD2,
			 HD3, HD3, HD3, HD3, HD3,	
		         HD4, HD4, HD4, HD4, HD4,
		         HD5, HD5, HD5, HD5, HD5,
		         HD6, HD6, HD6, HD6,
		         HD7, HD7, HD7, HD7
		  	};


int HardWare[] = { 15, 14, 13, 12,
		   11, 10,  9,  8,
		    7,  6,  5,  4,
		    3,  2,  1,  0
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
int     cur_volume;

int 	work_out[57];			/* VDI bindings.. 		*/
int 	vhandle;
int	SNDFlag;			/* DMA Sound Flag 		*/
int	left, right;
extern 	SND	save_vars;		/* used in cpxstart.s		*/

char	volume[3], left_b[3], right_b[3], bass[3], treble[3];
MFORM   Other;				/* MFORM for saving linea-A mouse buffer*/
int     AES_Version;
int     cur_balance;
int     numcol;

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
	long	ret;
	OBJECT  *tree;
		
	xcpb = Xcpb;

	/* If the boot flag is set.. */
    	if( xcpb->booting )
    	{

		/* 
		 * get the saved settings from the saved_vars
		 * area. Put those values into the old_data area.
		 * transfer the old_data area to the cur_data area.
		 * Be sure to slam the hardware with old_data! 
		 *
		 */ 
		ret = (int)soundcmd( 0, -1 );
		ret &= 0x000000FFL;
		if( ret != 0x82L )
		{
		    get_saved_settings( &old_data );
		    cur_data = old_data;
		    configure( &old_data );
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
		ret = soundcmd( 0, -1 );
		ret &= 0x000000ffL;
		if( ret != 0x82L )
		{
				SNDFlag  = TRUE;
				get_curdata( &old_data );
				cur_data = old_data;
		} else
			SNDFlag = FALSE;
			
		cur_face = face_array[ cur_balance ];	
		
		/* Find out how many planes we have.. */
		open_vwork();
       		numcol  = work_out[13];			

       		vq_extnd( vhandle, 1, work_out );
       		nplanes = work_out[4];
       	        close_vwork();


       	       if( !xcpb->SkipRshFix )    
	       {
	         if(( AES_Version >= 0x0330 )
		    && ( numcol > LWHITE ) )
	         {
	           Do3D();
       	         }        
       	       }  
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
   int          cur_value;
   int		temp;
   int		inc;
         
   /* If no DMA sound, then return and we are outta here! */
   if ( !SNDFlag )
   {
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

   cur_volume = max( cur_data.lvol, cur_data.rvol );   
   (*xcpb->Sl_y)( tree, VBASE, VSLIDER, cur_volume,
    	         VOL_MIN, VOL_MAX, slide_volume );
   DrawObject( tree, VSLIDER ); 	         
   DrawObject( tree, BSLIDER ); 	         
   DrawObject( tree, BASSSLID ); 	         
   DrawObject( tree, TREBSLID ); 	         
    	         
   /* Go into a loop until a quit Flag is set */
   do
   {

	/* Go into an XForm_do and wait for a touchexit */
	button = (*xcpb->Xform_do)( tree, 0, msg );

        if( ( button != -1 ) && ( button & 0x8000 ) )
        {
          button &= 0x7FFF;
        }
	
	/* switch on whatever was clicked on */
     	switch( button )
     	{
     	   case RSAVE:	if ( (*xcpb->XGen_Alert)( SAVE_DEFAULTS ) )
     			{
     			     Ok();
	                     cur_data.lvol = HardWare[ cur_data.lvol ];
			     cur_data.rvol = HardWare[ cur_data.rvol ];     			     
     			     (*xcpb->CPX_Save)( &cur_data, sizeof( SND ) );
        		     cur_data = old_data;
			}
			XDeselect( tree, RSAVE );     			     
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
 
           		  if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XSelect( tree, BSLIDER );

 
     			  (*xcpb->Sl_dragx)( tree, BBASE, BSLIDER, BAL_MIN,
     			                    BAL_MAX, &cur_balance,
     			                    slide_balance );

			   SnapBalance();
			  
          		  if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XDeselect( tree, BSLIDER );

     			  (*xcpb->MFsave)( MFRESTORE, &Other );                   
     			  break;
     					  
	   case BL:  /* Balance Control Left Arrow */
	   	     inc = FindIncrement( &cur_data, -1 );
     		     (*xcpb->Sl_arrow)( tree, BBASE, BSLIDER, BL, -inc,
     		                       BAL_MIN, BAL_MAX, &cur_balance,
     		                       HORIZONTAL, slide_balance );

		      SnapBalance();
     		      break;
     					
	   case BR:  /* Balance Control Right Arrow */
	   	     inc = FindIncrement( &cur_data, 1 );
     		     (*xcpb->Sl_arrow)( tree, BBASE, BSLIDER, BR, inc, BAL_MIN,
     		                       BAL_MAX, &cur_balance,
     		                       HORIZONTAL, slide_balance );
		      SnapBalance();
     		      break;

	   case BBASE:	Graf_mkstate( &mk );
     			objc_offset( tree, BSLIDER, &ox, &oy );
     			inc = FindIncrement( &cur_data, 0 );
     			inc *= 2;
     			inc = max( 2, inc );
     			inc = min( VOL_MAX, inc );
     			oy = (( mk.x < ox ) ? ( -inc ) : ( inc ));
     			(*xcpb->Sl_arrow)( tree, BBASE, BSLIDER, -1, oy,
     			                  BAL_MIN, BAL_MAX,
     			                  &cur_balance, HORIZONTAL,
     			                  slide_balance );
		        SnapBalance();
		        break;
     		
	   case VSLIDER:  /* Volume Slider Control */
     	   		  (*xcpb->MFsave)( MFSAVE, &Other );
     	   		  if( AES_Version >= 0x0320 )
	    	   	      graf_mouse( FLAT_HAND, 0L );

          		  if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XSelect( tree, VSLIDER );

	    	   	      
		          graf_mkstate( &mk.x, &oy, &mk.buttons, &mk.kstate );
	  		  do
	  		  {
	     		     graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
	  		  }while( mk.buttons && ( mk.y == oy ));

			  if( mk.buttons && ( mk.y != oy ))
			  {
	    	   	      
	    	   	     cur_volume = max( cur_data.lvol, cur_data.rvol );    
    			     (*xcpb->Sl_dragy)( tree, VBASE, VSLIDER, VOL_MIN,
     			                    VOL_MAX, &cur_volume,
     			                    slide_volume );
     			  }
		          SnapBalance();
 
          		  if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XDeselect( tree, VSLIDER );
     			                    
      			  (*xcpb->MFsave)( MFRESTORE, &Other );                   
    			  break;
     						
	   case VR:	/* Volume Control Right Arrow */
	    	   	cur_volume = max( cur_data.lvol, cur_data.rvol );    
     			(*xcpb->Sl_arrow)( tree, VBASE, VSLIDER, VR, 1,
     			                  VOL_MIN, VOL_MAX,
     			                  &cur_volume, VERTICAL,
     			                  slide_volume );
		        SnapBalance();
     			break;
     					
	   case VL:	/* Volume Control Left Arrow */
	    	   	cur_volume = max( cur_data.lvol, cur_data.rvol );    
     			(*xcpb->Sl_arrow)( tree, VBASE, VSLIDER, VL, -1,
     			                  VOL_MIN, VOL_MAX,
     			                  &cur_volume, VERTICAL,
     			                  slide_volume );
		        SnapBalance();
     			break;
     				
	   case VBASE:	Graf_mkstate( &mk );
     			objc_offset( tree, VSLIDER, &ox, &oy );
     			ox = (( mk.y < oy ) ? ( 2 ) : ( -2 ));
	    	   	cur_volume = max( cur_data.lvol, cur_data.rvol );    
     			(*xcpb->Sl_arrow)( tree, VBASE, VSLIDER, -1, ox,
     			                  VOL_MIN, VOL_MAX,
     			                  &cur_volume, VERTICAL,
     			                  slide_volume );
		        SnapBalance();
     			break;
     						
	   case BASSSLID:  /* Left Gain Slider Control */
      	   		   (*xcpb->MFsave)( MFSAVE, &Other );
      	   		   if( AES_Version >= 0x0320 )
     	   		       graf_mouse( FLAT_HAND, 0L );

           		  if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XSelect( tree, BASSSLID );

    			   (*xcpb->Sl_dragx)( tree, BASSBASE, BASSSLID,
     			                     GAIN_MIN, GAIN_MAX,
     			                     &cur_data.lgain,
     			                     slide_lgain );
     			                     
            		  if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XDeselect( tree, BASSSLID );
    			                     
      			   (*xcpb->MFsave)( MFRESTORE, &Other );                   
    			   break;
     			
	   case LBASS:	/* Left Gain Control Left Arrow */
     			(*xcpb->Sl_arrow)( tree, BASSBASE, BASSSLID, LBASS,
     			                  -1, GAIN_MIN, GAIN_MAX,
     			                  &cur_data.lgain, HORIZONTAL,
     			                  slide_lgain );
     			break;
     							
	   case RBASS:	/* Left Gain Control Right Arrow */
     			(*xcpb->Sl_arrow)( tree, BASSBASE, BASSSLID, RBASS,
     			                  1, GAIN_MIN, GAIN_MAX,
     			                  &cur_data.lgain, HORIZONTAL,
     			                  slide_lgain );
     			break;

	   case BASSBASE:  Graf_mkstate( &mk );
     		  	   objc_offset( tree, BASSSLID, &ox, &oy );
     			   oy = (( mk.x < ox ) ? ( -2 ) : ( 2 ));
     			   (*xcpb->Sl_arrow)( tree, BASSBASE, BASSSLID, -1,
     			                     oy, GAIN_MIN, GAIN_MAX,
     			                     &cur_data.lgain, HORIZONTAL,
     			                     slide_lgain );   
			   break;
								     						
	   case TREBSLID:  /* Right Gain Slider Control */
     	   		   (*xcpb->MFsave)( MFSAVE, &Other );
     	   		   if( AES_Version >= 0x0320 )
     	   		       graf_mouse( FLAT_HAND, 0L );

           		  if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XSelect( tree, TREBSLID );

     			   (*xcpb->Sl_dragx)( tree, TREBBASE, TREBSLID,
     			                     GAIN_MIN, GAIN_MAX,
     			                     &cur_data.rgain,
     			                     slide_rgain );

           		  if(( AES_Version >= 0x0330 )
	       		     && ( numcol > LWHITE ) )
	     		     XDeselect( tree, TREBSLID );

       			   (*xcpb->MFsave)( MFRESTORE, &Other );                   
    			   break;
     							
	   case LTREB:	/* RGain Control Left Arrow */
     			(*xcpb->Sl_arrow)( tree, TREBBASE, TREBSLID, LTREB,
     			                  -1, GAIN_MIN, GAIN_MAX,
     			                  &cur_data.rgain, HORIZONTAL,
     			                  slide_rgain );
     			break;
     						
	   case RTREB:	/* RGain Contrl Right Arrow */
     			(*xcpb->Sl_arrow)( tree, TREBBASE, TREBSLID, RTREB,
     			                  1, GAIN_MIN, GAIN_MAX,
     			                  &cur_data.rgain, HORIZONTAL,
     			                  slide_rgain );
     			break;

	   case TREBBASE:  Graf_mkstate( &mk );
		    	   objc_offset( tree, TREBSLID, &ox, &oy );
     			   oy = (( mk.x < ox ) ? ( -2 ) : ( 2 ));
     			   (*xcpb->Sl_arrow)( tree, TREBBASE, TREBSLID, -1,
     			                     oy, GAIN_MIN, GAIN_MAX,
     			                     &cur_data.rgain, HORIZONTAL,
     			                     slide_rgain );   
     			   break;

	   case HDBASE:	/* Dosound( ( void * )beep );*/
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
    	(*xcpb->Sl_x)( tree, BBASE, BSLIDER, cur_balance, BAL_MIN,
    	              BAL_MAX, slide_balance ); 
       
    
    	/* Left Gain Slider and Text Numbers		*/
    	(*xcpb->Sl_x)( tree, BASSBASE, BASSSLID, cur_data.lgain, GAIN_MIN,
    	              GAIN_MAX, slide_lgain );

    
    	/* Treble Slider and Text Numbers	*/
    	(*xcpb->Sl_x)( tree, TREBBASE, TREBSLID, cur_data.rgain,
    	              GAIN_MIN, GAIN_MAX, slide_rgain );
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
	BOOLEAN  flag = TRUE;	
	int		white,black;

	/* Set the resource tree variable.. */
	OBJECT *tree = (OBJECT *)rs_trindex[SOUND];


	/* cjg 09/21/92 */	
	white = 0;
	black = 15;
	
	if( nplanes > 8 )	/* True Color Mode */
	{
	    white = 15;
	    black = 0;
	}
		

	graf_mouse( M_OFF, 0L );	/* Turn off the mouse 	*/


	width  = ObW( VSBASE );		/* Calculate the width	*/
	height = ObH( VSBASE );		/* and height of the  	*/
					/* Volume rectangles  	*/

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
 	  	vro_cpyfm( vhandle, black, pxy, &vdeselect, &vdeselect );
/* 	  	vro_cpyfm( vhandle, 15, pxy, &vdeselect, &vdeselect );*/
	
          	for( i = VS38; i <= VS0; i++ ) {
 	    		pxy[0] = pxy[4] = 0;
 	    		pxy[1] = pxy[5] = ObY( i );
 	    		pxy[2] = pxy[6] = pxy[0] + ObW( i ) - 1;
 	    		pxy[3] = pxy[7] = pxy[1] + ObH( i ) - 1;
 	    		vro_cpyfm( vhandle, white, pxy, &vdeselect, &vdeselect );
/* 	    		vro_cpyfm( vhandle, 0, pxy, &vdeselect, &vdeselect );*/
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
 	    		vro_cpyfm( vhandle, black, pxy, &vselect, &vselect );
/* 	    		vro_cpyfm( vhandle, 15, pxy, &vselect, &vselect );*/
          	}
       }   
       close_vwork();

       graf_mouse( M_ON, 0L );	
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
	value = ( value * 40 ) / 15;
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


/* snap_balance()
 *==========================================================================
 * Handle the BALANCE slider text and image updating
 */
void
snap_balance( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ SOUND ];
   	
   int 	value1;				/* Left Balance  	  */
   int 	value2;				/* Right Balance 	  */
 
   set_balance( cur_balance );
   set_volume();
 
      
   /* Blit the proper face onto the screen */	
   do_face_blit( cur_balance );			
   value1 = value2 = 0;

   if( cur_balance >= BAL_MID )
	value2 = cur_balance - BAL_MID;
   else				
	value1 = BAL_MID - cur_balance;

   /* Convert Left Text Value */	   												
   itoa( value1, left_b, 10 );
   TedText( BALNUM1 ) = left_b;

   Objc_draw( tree, BALNUM1, 0, NULL );
	
   /* Convert Right Text Value */	
   itoa( value2, right_b, 10 );
   TedText( BALNUM2 ) = right_b;

   Objc_draw( tree, BALNUM2, 0, NULL );
/*
   set_balance( cur_balance );
   set_volume();
 */   
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
   int  temp;
   
   set_balance( cur_balance );
   set_volume();
/*
   SnapBalance(); 
 */
    /* cjg 09/30/92 */
    temp = cur_balance;
    get_curdata( &cur_data );
    if( temp == cur_balance )
    {
         
      /* Blit the proper face onto the screen */	
      do_face_blit( cur_balance );			
      value1 = value2 = 0;

      if( cur_balance >= BAL_MID )
	value2 = cur_balance - BAL_MID;
      else				
	value1 = BAL_MID - cur_balance;

      /* Convert Left Text Value */	   												
      itoa( value1, left_b, 10 );
      TedText( BALNUM1 ) = left_b;

      Objc_draw( tree, BALNUM1, 0, NULL );
	
      /* Convert Right Text Value */	
      itoa( value2, right_b, 10 );
      TedText( BALNUM2 ) = right_b;

      Objc_draw( tree, BALNUM2, 0, NULL );
   }
   else
     cur_balance = temp;   
/*
   set_balance( cur_balance );
   set_volume();
 */   
}



/* slide_volume()
 *==========================================================================
 * Handle the VOLUME slider text and image updating
 */
void
slide_volume( void )
{
   
   OBJECT *tree = ( OBJECT *)rs_trindex[ SOUND ];
   int diff;
   int cur_value;
   int 	value1;				/* Left Balance  	  */
   int 	value2;				/* Right Balance 	  */
  
   
   /* Blit Volume MFDBs */
   if( cur_volume == BAL_MAX )
      do_volume_blit( BAL_MAX - 1, ( GRECT *)0L );
   else      
      do_volume_blit( cur_volume, ( GRECT *)0L );
   
   /* Set the Text Value... */
   itoa( cur_volume, volume, 10 );
   TedText( VSLIDER ) = volume;

   DrawObject( tree, VSLIDER );   
   
   cur_value = max( cur_data.lvol, cur_data.rvol );
   if( cur_volume != cur_value )
   {
      if( cur_volume > cur_value )
      {
         diff = cur_volume - cur_value;
         cur_data.lvol += diff;
         cur_data.rvol += diff;
      }
      else
      {
        diff = cur_value - cur_volume;
        cur_data.lvol -= diff;
        cur_data.rvol -= diff;
      }
   }
   if( cur_data.lvol >= VOL_MAX )
      cur_data.lvol = VOL_MAX;
      
   if( cur_data.lvol <= VOL_MIN )
      cur_data.lvol = VOL_MIN;

   if( cur_data.rvol >= VOL_MAX )
      cur_data.rvol = VOL_MAX;
      
   if( cur_data.rvol <= VOL_MIN )
      cur_data.rvol = VOL_MIN;

   set_balance( cur_balance );	/* Adjust lvol and rvol based on balance*/
   set_volume();
}



/* slide_lgain()
 *==========================================================================
 * Handle the BASS slider text updating
 */
void
slide_lgain( void )
{
  OBJECT *tree = ( OBJECT *)rs_trindex[ SOUND ];

  if( cur_data.lgain >= GAIN_MAX )
       cur_data.lgain = GAIN_MAX;
  if( cur_data.lgain <= GAIN_MIN )
       cur_data.lgain = GAIN_MIN;

  itoa( cur_data.lgain, bass, 10 );
  TedText( BASSSLID ) = bass;

  DrawObject( tree, BASSSLID );

  set_lgain();
}



/* slide_rgain()
 *==========================================================================
 * Handle the RGAIN slider text updating
 */
void
slide_rgain( void )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ SOUND ];

    if( cur_data.rgain >= GAIN_MAX )
       cur_data.rgain = GAIN_MAX;
    if( cur_data.rgain <= GAIN_MIN )
       cur_data.rgain = GAIN_MIN;
           
    itoa( cur_data.rgain, treble, 10 );
    TedText( TREBSLID ) = treble;

    DrawObject( tree, TREBSLID );
    set_rgain();
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
   	while( xrect )
   	{
    		rect = *xrect;
    		cur_volume = max( cur_data.lvol, cur_data.rvol );
		if( cur_volume == BAL_MAX )
		   do_volume_blit( BAL_MAX - 1, ( GRECT *)&rect );
		else
		   do_volume_blit( cur_volume, ( GRECT *)&rect );

        	Objc_draw( tree, VSLIDER, 1, &rect );
        	xrect = (*xcpb->GetNextRect)();
   	};   
}


void
set_balance( int balance )
{
	/* If the current balance is set in the left direction.. */
	int upper;
	int total;
	int mod;
		
	upper = max( cur_data.lvol, cur_data.rvol );

	
	if( balance < BAL_MID )
	{

		/* Set left to the highest level, set the right to 
		 * reflect that it is lower. 
		 */
		cur_data.lvol = upper;
		total = balance * upper;
		cur_data.rvol = total / BAL_MID;
		mod = total % BAL_MID;
		mod = (( mod > 7  ) ? ( 1 ) : ( 0 ));
		cur_data.rvol = max( BAL_MIN, cur_data.rvol + mod );
	}
	else
	{
		cur_data.rvol = upper;
		total = ( BAL_MID - ( balance - BAL_MID )) * upper;
		cur_data.lvol = total / BAL_MID;
		mod = total % BAL_MID;
		mod = (( mod > 7 ) ? ( 1 ) : ( 0 ));
		cur_data.lvol = max( BAL_MIN, cur_data.lvol + mod );
	}
}


/* Set the Volume */
void
set_volume( void )
{
   int Volume;
   
   Volume = HardWare[ cur_data.lvol ];
   Volume &= 0x000F;
   soundcmd( 0, Volume << 4 );
 
   Volume = HardWare[ cur_data.rvol ];
   Volume &= 0x000F;
   soundcmd( 1, Volume << 4 );
}



/* set the left gain value.. */
void
set_lgain( void )
{
  soundcmd( 2, ( cur_data.lgain & 0x000f ) << 4 );
}

/* Right Gain settings.. */
void
set_rgain( void )
{
  soundcmd( 3, ( cur_data.rgain & 0x000f ) << 4 );
}



/* --------------------------------------------------------------------	*/
/* Handle the OK button!						*/
/* --------------------------------------------------------------------	*/

void
Ok( void )
{
	/* Copy the current values to saved area. */
	old_data = cur_data;
	configure( &cur_data );
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
	cur_data = old_data;
	configure( &cur_data );
}

void
get_saved_settings( SND *snd_struct )
{
	*snd_struct = save_vars;
	
	/* Convert from 0 == max 15==min TO   15MAX 0==min*/
	snd_struct->lvol = HardWare[ snd_struct->lvol ];
	snd_struct->rvol = HardWare[ snd_struct->rvol ];
}



void
get_curdata( SND *snd_struct )
{
    long sdata;

   /* Convert from 0 == max 15==min TO   15MAX 0==min*/
    sdata = soundcmd( 0, -1 );	/* Get Left Attenuation */

    snd_struct->lvol = (int)( sdata >> 4 );
    snd_struct->lvol = HardWare[ snd_struct->lvol ];
    
    sdata = soundcmd( 1, -1 );	/* Get Right Attenuation */
    snd_struct->rvol = ( int )( sdata >> 4 );
    snd_struct->rvol = HardWare[ snd_struct->rvol ];
    
    sdata = soundcmd( 2, -1 );/* Get Left Gain  */
    snd_struct->lgain = ( int )( sdata >> 4 );
    
    sdata = soundcmd( 3, -1 );	/* Get Right Gain */
    snd_struct->rgain = ( int )( sdata >> 4 );
    cur_balance = GetBalance( snd_struct );
}


void
configure( SND *snd_struct )
{
	int Volume;

	/* Convert from 0==MIN 15==MAX, TO 0 == MAX, 15==MIN*/	
	Volume = HardWare[ snd_struct->lvol ];
	soundcmd( 0, ( Volume & 0x000F ) << 4 );  /* Set Left Attenuation */
	
	Volume = HardWare[ snd_struct->rvol ];
	soundcmd( 1, ( Volume & 0x000F ) << 4 );  /* Set Right Attenuation */

	soundcmd( 2, ( snd_struct->lgain & 0x000F ) << 4 );/* Set Left Gain  */
	soundcmd( 3, ( snd_struct->rgain & 0x000F ) << 4 );/* Set Right Gain */
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


void
SetFaceData( SND *snd_struct )
{
    int balance;
    cur_face = face_array[ balance ];	
}


int
GetBalance( SND *snd_struct )
{
    int balance;
    int diff;
    int upper;
    int lower;
    int mod;
        
    upper = max( snd_struct->lvol, snd_struct->rvol );
    lower = min( snd_struct->lvol, snd_struct->rvol );
    
    diff  = snd_struct->lvol - snd_struct->rvol;
    
    if( !diff )
        balance = BAL_MID;
    else
    {
        balance = ( lower * VOL_MAX ) / upper;

	mod = ( lower * VOL_MAX ) % upper;
	mod = (( mod > ( upper / 2 )  ) ? ( 1 ) : ( 0 ));
	balance += mod;
	balance = max( BAL_MIN, balance );
	balance = min( BAL_MAX, balance );
	
        if( diff < 0 ) /* Balance is to the RIGHT */
        {		
            balance = BAL_MAX - balance;
        }
        else
        {              /* Balance is to the LEFT */
            balance += BAL_MIN;
        }

	        
    }
    return( balance );    
}


void
XDeselect( OBJECT *tree, int button )
{
   GRECT rect;

   Deselect( button );
   DrawObject( tree, button );
}


void
XSelect( OBJECT *tree, int button )
{
   GRECT rect;

   Select( button );
   DrawObject( tree, button );
}


void
DrawObject( OBJECT *tree, int button )
{
    GRECT rect;

    rect = ObRect( button );
    objc_offset( tree, button, &rect.g_x, &rect.g_y );
    rect.g_x -= 3;
    rect.g_y -= 3;
    rect.g_w += 6;
    rect.g_h += 6;
    Objc_draw( tree, button, MAX_DEPTH, &rect );
}


void
SnapBalance( void )
{
   int temp;
   OBJECT *tree = ( OBJECT * )rs_trindex[SOUND];

   /* cjg 09/23/92
    * Snap the Balance to the actual value for
    * this ratio of volume
    */
    temp = cur_balance;
    get_curdata( &cur_data );
    if( temp != cur_balance )
    {
        (*xcpb->Sl_x)( tree, BBASE, BSLIDER, cur_balance, BAL_MIN,
       		     BAL_MAX, snap_balance ); 
        DrawObject( tree, BBASE ); 	         
    }   
}


int
FindIncrement( SND *snd_struct, int flag )
{
    int upper, lower;
    int NewBalance;
    int value;
    int mod;
    int CalcBalance;
    SND TData;        
    int lvol, rvol;
    
    upper = max( snd_struct->lvol, snd_struct->rvol );
    lower = min( snd_struct->lvol, snd_struct->rvol );
        
    value = VOL_MAX / upper;
    
    mod   = VOL_MAX % upper;
    mod   = (( mod > ( upper / 2 )  ) ? ( 1 ) : ( 0 ));
    
    value += mod;
    value = max( 1, value );
    value = min( VOL_MAX, value );
     
    /* Check only if +1/-1 
     * Get the new balance
     * get the new lvol and rvol based on the new balance
     * get the actual balance based on the new lvol and rvol
     *
     * If the temp balance == NewBalance, increment/decrement
     * the 'inc Value' by +1/-1 based on flag.
     */
    if( flag && ( upper != VOL_MAX ) && ( upper != VOL_MIN ) )
    {
	CalcBalance = cur_balance + ( flag * value ); /* new balance */
	
	lvol = cur_data.lvol;
	rvol = cur_data.rvol;
	
	set_balance( CalcBalance );	/* Modify new lvol and rvol */

	NewBalance = GetBalance( &cur_data );
		
	cur_data.lvol = lvol;	/* restore cur_data */
	cur_data.rvol = rvol;
	
	/* SAME? or Different?
	 * If the same, kick it one more number over...
	 */
	if( cur_balance == NewBalance )
	{
	   value += 1;
	}   
	   
        value = max( 1, value );
        value = min( VOL_MAX, value );

    }
    return( value );
}



void
Do3D( void )
{
	OBJECT *tree;

	tree = ( OBJECT *)rs_trindex[ SOUND ];
	 
	MakeActivator( SOUND, RSAVE );
	MakeActivator( SOUND, BOK );
	MakeActivator( SOUND, CANCEL );
	      	   
	/* Volume Slider */   
	MakeActivator( SOUND, VR );
	MakeActivator( SOUND, VL );
	MakeActivator( SOUND, VSLIDER );
	MakeActivator( SOUND, VBASE );

        MakeTed( SOUND, VSLIDER );	
	ObIndex( VR ) = ( ObIndex( VR ) & 0xffffff70 ) | LWHITE | 0x70;
	ObIndex( VL ) = ( ObIndex( VL ) & 0xffffff70 ) | LWHITE | 0x70;
	ObH( VR ) = 14;
	ObH( VL ) = 14;
	ObH( VSLIDER ) = 14;
	ObY( VR ) += 2;
	ObY( VBASE ) = ObY( VR ) + ObH( VR ) + 5;
	ObH( VBASE ) = ( ObY( VL ) - 5 ) - ObY( VBASE );

	/* LEFT GAIN Slider */   
	MakeActivator( SOUND, LBASS );
	MakeActivator( SOUND, RBASS );
	MakeActivator( SOUND, BASSSLID );
	MakeActivator( SOUND, BASSBASE );
	MakeTed( SOUND, BASSSLID );
	MakeIndex( SOUND, LBASS );
	MakeIndex( SOUND, RBASS );
	ObH( LBASS ) = 14;
	ObH( RBASS ) = 14;
	ObH( BASSSLID ) = 14;
	ObH( BASSBASE ) = 14;
	ObX( LBASS ) += 2;
	ObW( LBASS ) -= 2;
	ObW( RBASS ) -= 2;
	ObX( BASSBASE ) = ObX( LBASS ) + ObW( LBASS ) + 5;
	ObW( BASSBASE ) = ( ObX( RBASS ) - 5 ) - ObX( BASSBASE );

	/* RT GAIN Slider */   
	MakeActivator( SOUND, LTREB );
	MakeActivator( SOUND, RTREB );
	MakeActivator( SOUND, TREBSLID );
	MakeActivator( SOUND, TREBBASE );
	MakeTed( SOUND, TREBSLID );

	MakeIndex( SOUND, LTREB );
	MakeIndex( SOUND, RTREB );	
	ObY( LTREB ) += 1;
	ObY( RTREB ) += 1;
	ObY( TREBBASE ) += 1;
	ObH( LTREB ) = 14;
	ObH( RTREB ) = 14;
	ObH( TREBSLID ) = 14;
	ObH( TREBBASE ) = 14;
	ObX( LTREB ) += 2;
	ObW( LTREB ) -= 2;
	ObW( RTREB ) -= 2;
	ObX( TREBBASE ) = ObX( LTREB ) + ObW( LTREB ) + 5;
	ObW( TREBBASE ) = ( ObX( RTREB ) - 5 ) - ObX( TREBBASE );

		   
	/* Balance Slider */   
	MakeActivator( SOUND, BL );
	MakeActivator( SOUND, BR );
	MakeActivator( SOUND, BSLIDER );
	MakeActivator( SOUND, BBASE );
	MakeIndex( SOUND, BSLIDER );
	MakeIndex( SOUND, BL );
	MakeIndex( SOUND, BR );
	ObY( BL ) += 1;
	ObY( BR ) += 1;
	ObY( BBASE ) += 1;
	ObX( BL ) += 2;
	ObX( BR ) -= 3;
	ObH( BL ) = 14;
	ObH( BR ) = 14;
	ObH( BSLIDER ) = 14;
	ObH( BBASE ) = 14;
	ObX( BBASE ) = ObX( BL ) + ObW( BL ) + 5;
	ObW( BBASE ) = ( ObX( BR ) - 5 ) - ObX( BBASE );
        ObIndex( B1 ) &= 0xf000ff70L;
	ObIndex( B2 ) &= 0xf000ff00L;
	ObIndex( B3 ) &= 0xf000ff00L;
	ObIndex( B10 )&= 0xffffff00L;	
	ObIndex( B4 ) &= 0xffffff70L;
	ObIndex( B5 ) &= 0xf000ff00L;
	ObIndex( B6 ) &= 0xffffff70L;
	ObIndex( B7 ) &= 0xf000ff00L;
	ObIndex( B8 ) &= 0xffffff70L;
	ObIndex( B9 ) &= 0xf000ff00L;

	ObX( RSAVE ) += 1;
	ObY( RSAVE ) += 1;
	ObW( RSAVE ) -= 2;
	ObH( RSAVE ) -= 2;
		   		
	ObX( BOK ) += 1;
	ObY( BOK ) += 1;
	ObW( BOK ) -= 2;
	ObH( BOK ) -= 2;

	ObX( CANCEL ) += 1;
	ObY( CANCEL ) += 1;
	ObW( CANCEL ) -= 2;
	ObH( CANCEL ) -= 2;
}



void
MakeActivator( int xtree, int obj )
{
    OBJECT *tree;
    
    tree = ( OBJECT *)rs_trindex[ xtree ];
    
    ObFlags( obj ) |= IS3DOBJ;
    ObFlags( obj ) |= IS3DACT;
}


void
MakeIndex( int xtree, int obj )
{
   OBJECT *tree;
   
   tree = ( OBJECT *)rs_trindex[ xtree ];
   
   ObIndex( obj ) = ( ObIndex( obj ) & 0xffffff70 ) | LWHITE | 0x70;
}


void
MakeTed( int xtree, int obj )
{
   OBJECT *tree;
   
   tree = ( OBJECT *)rs_trindex[ xtree ];

   TedColor( obj ) = ( TedColor( obj ) & 0xff70 ) | LWHITE | 0x70;
}
