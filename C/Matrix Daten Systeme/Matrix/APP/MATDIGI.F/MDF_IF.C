/* matdigif.c */

# include <stdio.h>
# include <string.h>
# include <ctype.h>
# include <tos.h>
# include <linea.h>
# include <portab.h>
# include <ext.h>

# include <global.h>
# include <scancode.h>
# include <picfiles.h>
# include "yc.h"
# include "yc_fast.h"
# include "tools.h"

# include "initdmsd.h"
# include "digiblit.h"
# include "digiblix.h"
# include "digitise.h"
# include "digitisx.h"
# include "film.h"
# include "draw_555.h"

# include "mdf_if.h"

# include "..\xload\lca.h"
# include "..\xload\lcaload.h"

# define LCATypeFormat		"%u"	/* 7(151),9(051)		*/
# define LCAVersionFormat	"%c"	/* Uni,Grey,Color,Yc	*/
# define LCAReleaseFormat	"%u"	/* 0,1,...				*/

char DefaultLcaFileNameFormat[] = 
	"mdf_" LCATypeFormat LCAVersionFormat LCAReleaseFormat ".rbt" ;

char 	 CurrentLcaType    = LCAtypUndef ;
unsigned CurrentLcaVersion = 9999 ;
unsigned CurrentLcaRelease = 9999 ;

unsigned LcaVersion		= 0 ;	/* board/dmsd type	*/
unsigned LcaRelease		= 0 ;

int   	 test = 0 ;
bool	 DisplayEnabled   = TRUE ;
bool	 WaitUntilGrabbed = TRUE ;

int ScreenDx, ScreenDy, ScreenPlanes, ScreenBytesPerLine ;


uword 	 *ScreenBase ;

# if 1
/*-------------------------------- LoadMdfLcaFile ------------*/
int LoadMdfLcaFile ( char typ, unsigned ver, unsigned rel )
{
	char LcaFileName[128] ;
	int  result = 0 ;
	
	if ( CurrentLcaType != typ || CurrentLcaVersion != ver || CurrentLcaRelease != rel )
	{
		sprintf ( LcaFileName, DefaultLcaFileNameFormat, ver, typ, rel ) ;
		if ( ( result = ProgramLcaFromFile ( LcaFileName, 0  ) ) == 0 )
		{
			InitDmsd ( DmsdParameterBlock.dmsd ) ;
			CurrentLcaType    = typ ;
			CurrentLcaVersion = ver ;
			CurrentLcaRelease = rel ;
		}
	}
	return result ;
}
# endif


/*--------------------------------------------- CheckLimit ------*/
void CheckLimit ( int *pi, int mini, int maxi )
{
	if ( *pi < mini )
		*pi = mini ;
	else if ( *pi > maxi )
		*pi = maxi ;
}

int minimum ( int a, int b ) { return a < b ? a : b ; }
int maximum ( int a, int b ) { return a > b ? a : b ; }


/*--------------------------------------------- ResetDigiWindows ------*/
void ResetDigiWindows ( TBlitWindow *blitwind )
{
	blitwind->dst.window.x = blitwind->dst.window.y = 0 ;
	blitwind->dst.window.w = minimum ( blitwind->dst.image.w, blitwind->src.image.w ) ;
	blitwind->dst.window.h = minimum ( blitwind->dst.image.h, blitwind->src.image.h ) ;

	blitwind->src.window.x = blitwind->src.window.y = 0 ;
	blitwind->src.window.w = blitwind->dst.window.w ;
	blitwind->src.window.h = blitwind->dst.window.h ;
}


/*--------------------------------------------- CheckDigiWindows ------*/
void CheckDigiWindows ( TBlitWindow *blitwind, POINT *zoom,
						TImage *dstimg )
{
	int digdx, digdy ;

	digdx = blitwind->src.image.w / zoom->x ;
	digdy = blitwind->src.image.h / zoom->y ;

	CheckLimit ( &blitwind->dst.window.w, 0, dstimg->w ) ;	/* dimension	*/
	CheckLimit ( &blitwind->dst.window.w, 0, digdx ) ;
	CheckLimit ( &blitwind->dst.window.h, 0, dstimg->h ) ;
	CheckLimit ( &blitwind->dst.window.h, 0, digdy ) ;
	CheckLimit ( &blitwind->dst.window.x, 0, dstimg->w - blitwind->dst.window.w ) ;
	CheckLimit ( &blitwind->dst.window.y, 0, dstimg->h - blitwind->dst.window.h ) ;

	CheckLimit ( &blitwind->src.window.x, 0, digdx - blitwind->dst.window.w ) ;
	CheckLimit ( &blitwind->src.window.y, 0, digdy - blitwind->dst.window.h ) ;
	blitwind->src.window.w = blitwind->dst.window.w ;
	blitwind->src.window.h = blitwind->dst.window.h ;

	if ( verbose )
		BlitWindowInfo ( blitwind ) ;
}

# if 1
/*----------------------------------------- SetDmsdType ----------*/
int SetDmsdType ( int chip, unsigned lcatyp )
{
	DmsdParameterBlock.dmsd   = chip ;
	LcaVersion = chip / 1000 ;
	return LoadMdfLcaFile ( lcatyp, LcaVersion, LcaRelease ) ;
}
# endif
