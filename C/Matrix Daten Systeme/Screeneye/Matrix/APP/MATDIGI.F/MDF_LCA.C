/* matdigif.c */

# include <stdio.h>
# include <global.h>

# include "initdmsd.h"
# include "digitise.h"
# include "digitisx.h"
# include "digiblit.h"
# include "digiblix.h"

# include "mdf_if.h"

# include "..\xload\global.h"
# include "..\xload\lca.h"
# include "..\xload\lcaload.h"

# include "mdf_lca.h"

# define TEST	0

# define SEplusLca	3030
								/*		zoom : 		x		y		*/
extern LCAdata	lca_C,			/*	Color 555		1,2   	1		*/
				lca_YC,			/*	YC								*/
				lca_Cyz2,		/*	Color 555		1,2		2		*/
				lca_Cxy2, 		/*	Color 555		1,4		2		*/
				lca_G8,			/*	Grey  8 bit		1,2    	1		*/
				lca_G8y2,		/*	Grey  8 bit		2,4    	2		*/
				mfp_C,			/*	Color 555		1,2   	1		*/
				mfp_Cyz2,		/*	Color 555		1,2		2		*/
				mfp_Cxy2,		/*	Color 555		1,4		2		*/

				mfp_3C,			/* = mfp_C for 3030					*/
				mfp_C8,			/*	Color 8 bit 332	1    	1		*/
				mfp_G8 ;		/*	Grey  8 bit		1    	1		*/


PLCAdata LoadedLcaData = NULL ;
TGrabMode GrabMode = GMnormal ;

# define MAXzoomX		4
# define MAXzoomY		2
# define CASExy(x,y)	(((x)*(MAXzoomY+1))+(y))

/*-------------------------------- LoadMdfLcaDataBlock ------------*/
int LoadMdfLcaDataBlock ( PLCAdata lcadata )
{
	int result ;

	if ( lcadata == NULL )
	{
		if ( LoadedLcaData == NULL )
		{
			if ( ( result = LoadMdfLcaDataBlock ( &lca_C ) ) != OK )
			{
				if ( verbose )
					printf ( "load 3020 (lca_C) r=%d\n", result ) ;
				ResetLCA ( 0 ) ;
				if ( verbose )
					printf ( "reset lca\n" ) ;
				result = LoadMdfLcaDataBlock ( &mfp_G8 ) ;
				if ( verbose )
					printf ( "try 3030 (mfp_G8) r=%d\n", result ) ;
			}
			return result ;		
		}
		switch ( LoadedLcaData->number )
		{
	default :	printf ( "- illegal lca device number : %d\n", 
							LoadedLcaData->number ) ;
				return 1 ;
	case 3020 :	lcadata = &lca_C ;
				break ;
	case 3030 :	lcadata = &mfp_G8 ;
				break ;
		}
	}
	if ( ( result = LoadLCA ( lcadata->number, 0, lcadata->Buffer, lcadata->bytes ) ) == OK )
	{
		LoadedLcaData = lcadata ;
		if ( verbose )
			printf ( "- loaded LCA : $%06lx\n", lcadata ) ;
	}

	return result ;
}


/*-------------------------------- LoadMatDigiFLcaData ------------*/
int LoadMatDigiFLcaData ( unsigned chip, TDigitiserMode mode, POINT *zoom, bool init )
{
	PLCAdata lcadata = NULL ;
	POINT	 usedzoom ;
	int  	 result = 0 ;
	bool	 lca3020 ;
	TGrabMode newgrabmod = GMnormal ;
	
	if ( verbose )
		printf ( "* LoadMatDigiFLcaData #%u/", chip ) ;
	if ( chip == 0 )
	{
		if ( DmsdParameterBlock.dmsd == 0 )
		{
			if ( verbose )
				printf ( " * DmsdType not set * " ) ;
			DmsdParameterBlock.dmsd = DEFdmsdType ;
		}
		chip = DmsdParameterBlock.dmsd ;
	}
	else
	{
		DmsdParameterBlock.dmsd = chip ;
	}

	if ( verbose )
		printf ( "#%u\n", chip ) ;
	
	usedzoom.x = zoom->x <= MAXzoomX ? zoom->x : MAXzoomX ;
	usedzoom.y = zoom->y <= MAXzoomY ? zoom->y : MAXzoomY ;

	if ( LoadedLcaData == NULL )
	{
		printf ( "- lca type undefined\n" ) ;
		return 1 ;
	}
						
	switch ( LoadedLcaData->number )
	{
default :	printf ( "- illegal lca device number : %d\n", 
						LoadedLcaData->number ) ;
			return 1 ;
case 3020 :	lca3020 = TRUE ;	break ;
case 3030 :	lca3020 = FALSE ;	break ;
	}
	
	switch ( mode )
	{
  case DIGcolor :	if ( DmsdParameterBlock.dmsd == 9051 )
					{
						switch ( CASExy(usedzoom.x,usedzoom.y) )
  						{
	case CASExy(1,1):
	case CASExy(2,1):
	case CASExy(4,1):	lcadata = &lca_C ;		break ;
	case CASExy(2,2):	lcadata = &lca_Cyz2 ;	break ;
	case CASExy(4,2):	lcadata = &lca_Cxy2 ;	break ;
  						}
  					}
  					else	/* ScreenEye+	*/
					{
						if ( lca3020 )
						{
							switch ( CASExy(usedzoom.x,usedzoom.y) )
	  						{
			case CASExy(1,1):
			case CASExy(2,1):
			case CASExy(4,1):	lcadata = &mfp_C ;		break ;
			case CASExy(2,2):	lcadata = &mfp_Cyz2 ;	break ;
			case CASExy(4,2):	lcadata = &mfp_Cxy2 ;	break ;
	  						}
	  					}
	  					else	/* 3030 */
	  					{
							switch ( CASExy(usedzoom.x,usedzoom.y) )
  							{
			case CASExy(1,1):
			case CASExy(2,1):
			case CASExy(4,1):	lcadata = &mfp_3C ;		break ;
	  						}
  						}
 					}
		  			break ;
  case DIGyc :		
  case DIGgrey :	if ( lca3020 )
  						lcadata = &lca_YC ;
  					break ;
  case DIGcolor8 :	if ( ! lca3020 )
  						lcadata = &mfp_C8 ;
  					break ;
  case DIGgrey8 :	if ( lca3020 )
  					{
						switch ( CASExy(usedzoom.x,usedzoom.y) )
  						{
		  case CASExy(4,1):
		  case CASExy(2,1):	newgrabmod = GMzoomG8 ;
		  case CASExy(1,1):	lcadata = &lca_G8 ;
		  					break ;
		  case CASExy(4,2):	newgrabmod = GMzoomG8 ;
		  case CASExy(2,2):	lcadata = &lca_G8y2 ;
		  					break ;
	  					}
					}
  					else
  						lcadata = &mfp_G8 ;
  					break ;
  default :			printf ( "* dig mode %d not yet supported !", mode ) ;
  					return 1 ;
	}

	if ( lcadata == NULL )
	{
  		printf ( "* illegal zoom !\n" ) ;
  		return 1 ;
  	}
		
	if ( lcadata != LoadedLcaData )
	{
		if ( ( result = LoadMdfLcaDataBlock ( lcadata ) ) == OK )
			GrabMode = newgrabmod ;
		if ( init )
			InitDmsd ( chip ) ;
	}
	else
		GrabMode = newgrabmod ;
	
	return result ;
}
