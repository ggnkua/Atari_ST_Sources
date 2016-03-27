/* digbltif.c */

# include <stdio.h>

# include <global.h>

# include "digiblit.h"
# include "digitise.h"
# include "digiblix.h"
# define HIDEfunctions
# include "screyeif.h"
# include "mdf_lca.h"
# include "mdf_lcax.h"

# include "digbltif.h"

# define HWpackingColor		0	/* not yet implemented	*/
# define HWpackingGrey		1

typedef struct
{
	TDigitiserMode digmod ;
	TBlitProcedure *bltprc ;
} TBlitParameter ;

TBlitParameter	BlitParamTable[] =
{
	{ DIGcolor, 	NULL				},	/*	0	*/
	{ DIGcolor, 	Blit555Window		},	/*	1	*/
	{ DIGyc,		BlitRGBWindow		},	/*	2	*/
# if HWpackingColor
	{ DIGcolor8,	BlitP8ColorWindow	},	/*	3	*/
# else
	{ DIGcolor, 	BlitF332Window		},	/*	3	*/
# endif
# if HWpackingGrey
	{ DIGgrey7, 	BlitP8ColorWindow	},	/*	4	*/
	{ DIGgrey8, 	BlitP8ColorWindow	},	/*	5	*/
# else
	{ DIGyc,		BlitF7GreyWindow	},	/*	4	*/
	{ DIGyc,		BlitF8GreyWindow	},	/*	5	*/
# endif
	{ DIGyc,		BlitFyc224Window	},	/*	6	*/
	{ DIGyc,		BlitGreyWindow		}	/*	7	*/
} ;

/*------------------------------------------ GetBlitDigiToWindow ---------*/
TBlitProcedure *GetBlitDigiToWindow ( TBlitWindow *blitwind, POINT *zoom,
									  TPictureFormat format )
{
	int 			partabix ;
	TBlitParameter 	*bltpar ;
	
	switch ( format )
	{
default :										partabix = 0 ;	break ;
case _PictureFormat(PITdefault,PIOdefault,16) :
case _PictureFormat(PITcolor,PIOpacked,555) :	partabix = 1 ;	break ;
case _PictureFormat(PITcolor,PIOpacked,888) :	partabix = 2 ;	break ;
case _PictureFormat(PITcolor,PIOmix16,332) :	partabix = 3 ;	break ;
case _PictureFormat(PITdefault,PIOdefault,8) :
case _PictureFormat(PITgrey,PIOmix16,7) :		partabix = 4 ;	break ;
case _PictureFormat(PITgrey,PIOmix16,8) :		partabix = 5 ;	break ;
case _PictureFormat(PITyc,PIOmix16,224) :		partabix = 6 ;	break ;
case _PictureFormat(PITgrey,PIOpacked,555) :	partabix = 7 ;	break ;
	}

	bltpar = &BlitParamTable[partabix] ;
	if ( bltpar->bltprc != NULL )
	{
		if ( LoadMatDigiFLcaData ( 0, bltpar->digmod, zoom, FALSE ) == OK )
			return bltpar->bltprc ;
	}
	return NULL ;
}


/*------------------------------------------ BlitDigiToWindow ---------*/
extern void BlitDigiToWindow ( TBlitWindow *blitwind, POINT *zoom )
{
	TBlitProcedure *blitproc ;

	blitproc = GetBlitDigiToWindow ( blitwind, zoom,
					_PictureFormat(PIOdefault,PITdefault,blitwind->dst.image.planes) ) ;
	if ( blitproc != NULL )
		(*blitproc)( blitwind, zoom ) ;
}
