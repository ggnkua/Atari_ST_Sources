/*************************************************************
 * Copyright 1999 by Caldera Thin Clients, Inc.              *
 * This software is licensed under the GNU Public License.   *
 * Please see LICENSE.TXT for further information.           *
 *************************************************************/
#include <portab.h>
#include <machine.h>
#if GEMDOS
#if TURBO_C
#include <aes.h>
#include <vdi.h>
#endif
#else
#include <obdefs.h>
#include <gembind.h>
#endif
#include "rcs.h"
#include "rcslib.h"
#include "rcsfiles.h"
#include "rcsload.h"
#include "rcsiext.h"
#include "rcsiinit.h"
#include "rcsiedit.h"
#include "rcsimain.h"
#include "rcsifile.h"

VOID clear_img(VOID)
{
	WORD old_color, old_pen;
	
	old_color = colour;
	old_pen = pen_on;
	colour = WHITE;
	pen_on = ERASEBOX;
	solid_img();
	fb_redraw();
	colour = old_color;
	pen_on = old_pen;
}

WORD save_icn(VOID)
{    
	LONG	daddr, maddr;
	WORD	ret;
					    
	save_fat(FALSE);
	rast_op(3,&hold_area, &hold_mfdb, &hold_area, &save_mfdb);
	if(gl_isicon)
		rast_op(3, &hold_area, &hld2_mfdb, &hold_area, &sav2_mfdb);
	daddr = GET_SPEC(ad_pbx, DATAWIND); 
	if (gl_isicon)
	{
		/* write data and mask */
		maddr = GET_SPEC(ad_pbx, MASKWIND);
		ret = writ_icon(LLGET(BI_PDATA(daddr)),
			gl_wimage, gl_himage, gl_datasize,
			TRUE) ;
		if (ret )
			return( writ_icon(LLGET(BI_PDATA(maddr)),
			gl_wimage, gl_himage, gl_datasize,
			FALSE) );
		else 
			return( ret );
	}
	else	 
		/* write data only */
		return(	writ_icon(LLGET(BI_PDATA(daddr)),
			gl_wimage, gl_himage, gl_datasize,
			TRUE) );
}

WORD svas_icn(VOID)
{
	get_icnfile(&icn_file[0], STSASICN);
	if (!icn_file[0])
		return(FALSE);
	else		  
		if (save_icn())
		{
			icn_state = FILE_STATE;
			return(TRUE);
		}
		else
			return(FALSE);	
}   

WORD new_img(VOID)
{
	WORD	abtn;					  
	if ( icn_edited && !rcs_xpert )
	{
	 	if ( (abtn = abandon_button()) == 1 ) 
   		{
			clear_img();				    
			return( TRUE );
		}
		else if (abtn == 2) /* Save Changes */			   
		{
			if ( icn_state == NOFILE_STATE)
				return( svas_icn());
			else
				return(	save_icn());
		}
		else /* cancel */
			return (FALSE);
	}
	else			      
	{
		clear_img();
		return( TRUE );
	}
}

VOID do_open(VOID)
{
    WORD state;
	load_part(save_obj); /*if successfully load, icn_state = file_state*/
	state = icn_state;
	icn_init(FALSE);
	icn_edited = FALSE;
	icn_state = state;	/*icn_init will put icn_state = nofile_state*/
}

WORD icnopen(VOID)
{
	WORD	abtn;					  

	if ( icn_edited && !rcs_xpert )
	 	if ( (abtn = abandon_button()) == 1 ) 
   		{
			do_open();
			return( TRUE );
		}
		else if (abtn == 2) /* Save Changes */			   
		{
			if ( icn_state == NOFILE_STATE)
				if( svas_icn())
				{
					do_open();
					return(TRUE);
				}
				else
					return( FALSE );
			else
				if(save_icn())
				{
					do_open();
					return(TRUE);
				}
				else
					return( FALSE );
	
		}
		else /* cancel */
			return (FALSE) ;
	else			      
	{
		do_open();
		return( TRUE );
	}
}

WORD rvrt_icn(VOID)
{
	WORD	abtn;					  

	if ( icn_edited && !rcs_xpert )
	 	if ( (abtn = abandon_button()) == 1 ) 
   		{
			undo_img();				    
			return( TRUE );
		}
		else if (abtn == 2) /* Save Changes */			   
			if ( icn_state == NOFILE_STATE)
				if( svas_icn())
					return(TRUE);
				else
					return(FALSE);
			else
				if(save_icn())
					return(TRUE);
				else
					return(FALSE);
		else /* cancel */
			return (FALSE) ;
	else			      
	{
		undo_img();
		return( TRUE );
	}
}
