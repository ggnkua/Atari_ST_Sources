/********************************************************************/
/* 				MatDigi Window Program - Palette Routines			*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 18.04.93												*/
/*																	*/
/*  WA - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*																	*/
/********************************************************************/

# include <stdio.h>
# include <vdi.h>
# include <aes.h>

# include <global.h>

# include "menus.h"
# include "coltable.h"


/*---------------------------------------------------- draw_pixel --*/
void draw_pixel ( int vdi_handle, int x, int y, int color )
{
	int pxy[4] ;

	pxy[2] = pxy[0] = x ;
	pxy[3] = pxy[1] = y ;

	vsl_color ( vdi_handle, color ) ;
	v_pline ( vdi_handle, 2, pxy ) ;
}

/*---------------------------------------------- set_phys_to_vdi -------*/
void set_phys_to_vdi ( int vdi_handle, int colors, int *phys_to_vdi, int *vdi_to_phys )
{
	int physix, vdix, vdixo, vdixsave, mask ;

	mask = colors -1 ;
	v_get_pixel ( vdi_handle, 0, 0, &physix, &vdixsave ) ;	/* save pixel[0,0]	*/

	vswr_mode ( vdi_handle, MD_REPLACE );      
	vsl_type  ( vdi_handle, 1 );
	vsl_width ( vdi_handle, 1 );
	for ( vdix = 0 ; vdix < colors ; vdix++ )
	{
		draw_pixel ( vdi_handle, 0, 0, vdix ) ;	/* set pixel[0,0] to color 'vdix'	*/
		v_get_pixel ( vdi_handle, 0, 0, &physix, &vdixo ) ;
		physix &= mask ;
		vdixo  &= mask ;
		if ( vdix != vdixo )
		{
			if ( verbose )
				printf ( "* v_get_pixel - error\n" ) ;
			return ;
		}
		if ( phys_to_vdi != NULL )
			phys_to_vdi[physix] = vdix ;
		if ( vdi_to_phys != NULL )
			vdi_to_phys[vdix] = physix ;
	}

	draw_pixel ( vdi_handle, 0, 0, vdixsave ) ;							/* restore pixel[0,0]	*/
}


