/* graph.c / 13.12.90 / MATRIX / WA */

#include <vdi.h>
#include <aes.h>

# include <global.h>
# include <fast.h>

# include "graph.h"
				
/*------------------------------------------ draw_curve ------------*/
void draw_curve ( int vhandle,
				  RECTangle *rect, uword maxval,
				  uword *table, int tab_size,
				  int color )
{
	int pxy[2*512], *pix, mix, bottom, maxmix ;
	
	if ( tab_size > 512 )
		maxmix = 512 ;
	else
		maxmix = tab_size ;
		
	bottom = rect->y + rect->h - 1 ;
		
	vswr_mode ( vhandle, MD_REPLACE ) ;      
	vsl_type  ( vhandle, 1 ) ;
	vsl_width ( vhandle, 1 ) ;
	vsl_color ( vhandle, color ) ;

	pix = pxy ;
# if 1
	for ( mix=0; mix<maxmix; mix++ )
	{
	/* X */	*pix++ = rect->x + uscale ( mix, rect->w, tab_size ) ;
	/* Y */	*pix++ = bottom	- uscale ( *table++, rect->h - 1, maxval ) ;
	}
# else
	for ( mix=0; mix<rect->w; mix++ )
	{
		*pix++ = rect->x + mix ;
		*pix++ = bottom	- uscale ( table [ uscale ( mix, tab_size, rect->w ) ],
													rect->h - 1, maxval ) ;
	}
# endif
	v_pline ( vhandle, maxmix, pxy );
}


# if 0
/*------------------------------------------ draw_rgb_curve ---*/
void draw_rgb_curve( OBJECT *tree, int frameobj,
					 RGB (*rgbtab)[], int bascol, int max_point  )
{
	RECTangle matrix ;
	int min_bc, max_bc, bc ;

	ObjectGetRectangle ( tree, frameobj, matrix ) ;

	if ( bascol < R || bascol > B ) { min_bc = R ; max_bc = B ; }
							   else { min_bc =     max_bc = bascol ; }

	for( bc = min_bc; bc <= max_bc; bc++ )
	{
		draw_curve ( vdi_handle, &matrix, MAXlevel,
				  (*rgbtab)[cix?][bc], 256,
				  RED+bc  ) ;
	}
}

			
# endif