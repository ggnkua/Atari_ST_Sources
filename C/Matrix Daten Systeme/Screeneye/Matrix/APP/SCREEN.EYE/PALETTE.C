# include <stdio.h>
# include <vdi.h>

# include <global.h>
# include <fast.h>

# if 0
# include "scrneye.h"
# else
extern int vdi_handle ;
# endif

# if USEnoLib
extern TYCtoF8format yctof8_format[3] ;
# include "\pc\app\matdigi.f\yc.h"
# else
# define yctof8_format  (ScreenEyeParameter->DigiParam->YcToF8Format)
# include "\pc\app\matdigi.f\digitise.h"
# include "\pc\app\matdigi.f\digiblit.h"
# include "\pc\app\matdigi.f\mdf_lca.h"
# include "\pc\app\matdigi.f\film.h"
# include "\pc\app\matdigi.f\screyeif.h"
# include "\pc\app\matdigi.f\scryiacc.h"
# endif

# include "\pc\app\screen.eye\palette.h"

int save_clut[3*256] ;
int clut_332[3*256] ;
int clut_grey[3*256] ;
int clut_grey7[3*256] ;
int clut_yc224[3*256] ;

int vdi_to_physix[256] ;
int phys_to_vdiix[256] ;

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
			printf ( "\n* v_get_pixel - error : l%d->%d : p%d\n", vdix, vdixo, physix ) ;
		}
		if ( phys_to_vdi != NULL )
			phys_to_vdi[physix] = vdix ;
		if ( vdi_to_phys != NULL )
			vdi_to_phys[vdix] = physix ;
# if TEST
		switch ( vdix & 15 )
		{
	case 0 :	printf ( "%3d : %3d", vdix, physix ) ;	break ;
	default :	printf ( " %3d", physix ) ;				break ;
	case 15 :	printf ( " %3d\n", physix ) ;			break ;
		}
# endif
	}

	draw_pixel ( vdi_handle, 0, 0, vdixsave ) ;							/* restore pixel[0,0]	*/
}



/*--------------------------------------------------- calc_clut_grey -----*/
void calc_clut_grey ( void ) 
{
	int	physix, vdiix ;
	int *pp ;
	
	for ( physix = 0; physix < 256; physix++ ) 
	{
		vdiix  = phys_to_vdiix[physix] ;
		pp = &clut_grey[ 3*vdiix ] ;
		*pp++ = *pp++ = *pp++ = iscale ( physix, 1000, 255 ) ;
	}
}

/*-------------------------------------------- calc_clut_grey7 -----*/
void calc_clut_grey7 ( void ) 
{
	int	physix, vdiix ;
	int *pp ;
	
	for ( physix = CLUTgrey7Base; physix < CLUTgrey7Base+128; physix++ ) 
	{
		vdiix  = phys_to_vdiix[physix] ;
		pp = &clut_grey7[ 3*vdiix ] ;
		*pp++ = *pp++ = *pp++ = iscale ( physix-CLUTgrey7Base, 1000, 127 ) ;
	}
}


/*---------------------------------------------- calc_clut_332 -----*/
void calc_clut_332 ( void ) 
{
	int	physix, vdiix, r, g, b ;
	int *pp ;
	
	/* default colors : RRRgggBB	*/
	/*					76543210	*/

	for ( r = 0; r < 8; r++ ) 
	{
		for ( g = 0; g < 8; g++ ) 
		{
			for ( b = 0; b < 4; b++ ) 
			{
				physix = ( r<<5 ) | ( g<<2 ) |b ;
				vdiix  = phys_to_vdiix[physix] ;
				pp = &clut_332[ 3*vdiix ] ;
				*pp++ = r * 1000 / 7 ;			
				*pp++ = g * 1000 / 7 ;			
				*pp++ = b * 1000 / 3 ;			
			}
		}
	}
}

# if 0
TYCtoF8format	yctof8_format[3] =
{
	{	0x0f, 4, 0x00, 0x08 },
	{	0x30, 2, 0x80, 0x20 },
	{	0xc0, 0, 0x80, 0x20 }
} ;	
# endif

/*--------------------------------------------------- getcomp -----*/
uword getcomp ( uword i, TYCtoF8format *f )
{
	uword result ;
	
	result = ((((i & f->mask) << f->shift ) ^ f->sign ) + f->rndofs) ;
	if ( result > 255 )
		result = 255 ;

# if 0
	if ( f->sign )
		result = ( 128 + result ) / 2 ;
# endif

	return result ;
}
	
/*--------------------------------------------------- calc_clut_yc224 -----*/
void calc_clut_yc224 ( void ) 
{
	int	physix, vdiix;
	uword y, u, v ;
	int *pp ;
	byte rgb[3] ;
	
	/* default colors : uuvvyyyy	*/
	/*					76543210	*/

	CheckCalcCSCtables ( NULL ) ;

	for ( physix = 0; physix < 256; physix++ ) 
	{
		vdiix  = phys_to_vdiix[physix] ;
		y = getcomp(physix,&yctof8_format[0]) ;
		v = getcomp(physix,&yctof8_format[1]) ;
		u = getcomp(physix,&yctof8_format[2]) ;

		pp = &clut_yc224[ 3*vdiix ] ;
# if 1
		yuv_to_rgb ( rgb, y, v, u ) ;
		*pp++ = iscale ( rgb[0], 1000, 255 ) ;			
		*pp++ = iscale ( rgb[1], 1000, 255 ) ;			
		*pp++ = iscale ( rgb[2], 1000, 255 ) ;			
# else /* only grey	*/
		*pp++ = *pp++ = *pp++ = iscale ( y, 1000, 255 ) ;			
# endif
	}
}

/*--------------------------------------- set_phys_palette -------------*/
void set_phys_palette ( int fr, int to, int *pal ) 
{
	int	physix, vdiix ;

	for ( physix=fr; physix<=to; physix++ ) 
	{
		vdiix  = phys_to_vdiix[physix] ;
		vs_color ( vdi_handle, vdiix, &pal[3*vdiix] ) ;
	}
}

/*--------------------------------------- set_vdi_palette -------------*/
void set_vdi_palette ( int fr, int to, int *pal ) 
{
	int color ;

	for ( color=fr; color<=to; color++ ) 
		vs_color ( vdi_handle, color, &pal[3*color] ) ;
}

/*--------------------------------------- get_vdi_palette -------------*/
void get_vdi_palette ( int fr, int to, int *pal ) 
{
	int color ;

	for ( color=fr; color<=to; color++ ) 
		vq_color ( vdi_handle, color, 1, &pal[3*color] ) ;
}

/*---------------------------------- init_palette ----------------*/
void init_palette ( void )
{
	set_phys_to_vdi ( vdi_handle, 256, phys_to_vdiix, vdi_to_physix ) ;
	calc_clut_332();
	calc_clut_grey();
	calc_clut_grey7();
	calc_clut_yc224();
	get_vdi_palette ( 0, 255, save_clut ) ;
}
