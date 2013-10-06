/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: GRAPHIC.C
::
:: Display Independent Graphic Routs
::
:: [c] 2002 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"GRAPHIC.H"


#include	<GODLIB\BLITTER\BLITTER.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>


/* ###################################################################################
#  DATA
################################################################################### */

sGraphicFuncs	gGraphicFuncs[ eGRAPHIC_COLOURMODE_LIMIT ];
sGraphicFuncs	gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_LIMIT ];


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	void Graphic_4BP_Blit(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, struct sGraphicCanvas * apSrc	);
extern	void Graphic_4BP_ClearScreen(  struct sGraphicCanvas * apCanvas );
extern	void Graphic_4BP_CopyScreen(   struct sGraphicCanvas * apCanvas, void * apSrc );
extern	void Graphic_4BP_DrawBox(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
extern	void Graphic_4BP_DrawLine(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawPixel(    struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawSprite(   struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   void * apSprite );
extern	void Graphic_4BP_DrawTri(      struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawQuad(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );

extern	void Graphic_4BP_Blit_Clip(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, struct sGraphicCanvas * apSrc	);
extern	void Graphic_4BP_DrawBox_Clip(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
extern	void Graphic_4BP_DrawLine_Clip(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawPixel_Clip(    struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawSprite_Clip(   struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   void * apSprite );
extern	void Graphic_4BP_DrawTri_Clip(      struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawQuad_Clip(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );

extern	void Graphic_4BP_Blit_BLT(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, struct sGraphicCanvas * apSrc	);
extern	void Graphic_4BP_ClearScreen_BLT(  struct sGraphicCanvas * apCanvas );
extern	void Graphic_4BP_CopyScreen_BLT(   struct sGraphicCanvas * apCanvas, void * apSrc );
extern	void Graphic_4BP_DrawBox_BLT(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
extern	void Graphic_4BP_DrawLine_BLT(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawPixel_BLT(    struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawSprite_BLT(   struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   void * apSprite );
extern	void Graphic_4BP_DrawTri_BLT(      struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawQuad_BLT(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );

extern	void Graphic_4BP_Blit_Clip_BLT(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, struct sGraphicCanvas * apSrc	);
extern	void Graphic_4BP_DrawBox_Clip_BLT(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
extern	void Graphic_4BP_DrawLine_Clip_BLT(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawPixel_Clip_BLT(    struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawSprite_Clip_BLT(   struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   void * apSprite );
extern	void Graphic_4BP_DrawTri_Clip_BLT(      struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
extern	void Graphic_4BP_DrawQuad_Clip_BLT(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Graphic_Init
* ACTION   :
* CREATION : 01.02.02 PNK
*-----------------------------------------------------------------------------------*/

void	Graphic_Init( void )
{
	Blitter_Init();
	if( BLT_BLITTER == System_GetBLT() )
	{
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].Blit        = Graphic_4BP_Blit;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].ClearScreen = Graphic_4BP_ClearScreen_BLT;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].CopyScreen  = Graphic_4BP_CopyScreen_BLT;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].DrawBox     = Graphic_4BP_DrawBox_BLT;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].DrawPixel   = Graphic_4BP_DrawPixel_BLT;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].DrawSprite  = Graphic_4BP_DrawSprite_BLT;

		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].Blit        = Graphic_4BP_Blit_Clip;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].ClearScreen = Graphic_4BP_ClearScreen_BLT;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].CopyScreen  = Graphic_4BP_CopyScreen_BLT;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].DrawBox     = Graphic_4BP_DrawBox_Clip_BLT;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].DrawPixel   = Graphic_4BP_DrawPixel_Clip_BLT;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].DrawSprite  = Graphic_4BP_DrawSprite_Clip_BLT;
	}
	else
	{
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].Blit        = Graphic_4BP_Blit;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].ClearScreen = Graphic_4BP_ClearScreen;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].CopyScreen  = Graphic_4BP_CopyScreen;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].DrawBox     = Graphic_4BP_DrawBox;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].DrawPixel   = Graphic_4BP_DrawPixel;
		gGraphicFuncs[ eGRAPHIC_COLOURMODE_4BP ].DrawSprite  = Graphic_4BP_DrawSprite;

		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].Blit        = Graphic_4BP_Blit_Clip;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].ClearScreen = Graphic_4BP_ClearScreen;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].CopyScreen  = Graphic_4BP_CopyScreen;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].DrawBox     = Graphic_4BP_DrawBox_Clip;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].DrawPixel   = Graphic_4BP_DrawPixel_Clip;
		gGraphicFuncsClip[ eGRAPHIC_COLOURMODE_4BP ].DrawSprite  = Graphic_4BP_DrawSprite_Clip;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Graphic_DeInit( void )
* ACTION   : Graphic_DeInit
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Graphic_DeInit( void )
{
	Blitter_DeInit();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GraphicCanvas_Init( sGraphicCanvas * apCanvas,const U16 aColourMode,const U16 aWidth,const U16 aHeight )
* ACTION   : GraphicCanvas_Init
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GraphicCanvas_Init( sGraphicCanvas * apCanvas,const U16 aColourMode,const U16 aWidth,const U16 aHeight )
{
	U16		i;
	U32		lLineWidth;
	U32		lOffset;

	apCanvas->ColourMode = aColourMode;
	apCanvas->Width      = aWidth;
	apCanvas->Height     = aHeight;

	switch( aColourMode )
	{
	case	eGRAPHIC_COLOURMODE_1BP:
		lLineWidth   = (aWidth+15);
		lLineWidth  &= 0x0000FFF0L;
		lLineWidth >>= 3L;
		break;

	case	eGRAPHIC_COLOURMODE_2BP:
		lLineWidth   = (aWidth+15);
		lLineWidth  &= 0x0000FFF0L;
		lLineWidth >>= 2L;
		break;

	case	eGRAPHIC_COLOURMODE_4BP:
		lLineWidth   = (aWidth+15);
		lLineWidth  &= 0x0000FFF0L;
		lLineWidth >>= 1L;
		break;

	case	eGRAPHIC_COLOURMODE_8BPP:
		lLineWidth = aWidth;
		break;

	case	eGRAPHIC_COLOURMODE_16BPP:
		lLineWidth   = aWidth;
		lLineWidth <<= 1L;
		break;

	case	eGRAPHIC_COLOURMODE_24BPP:
		lLineWidth  = aWidth;
		lLineWidth *= 3;
		break;

	case	eGRAPHIC_COLOURMODE_32BPP:
		lLineWidth   = aWidth;
		lLineWidth <<= 2L;
		break;
	default:
		lLineWidth = aWidth;
		break;
	}

	lOffset = 0;

	if( apCanvas->Height >= (dGRAPHIC_HEIGHT_LIMIT-1) )
	{
		apCanvas->Height = dGRAPHIC_HEIGHT_LIMIT-1;
	}

	for( i=0; i<=apCanvas->Height; i++ )
	{
		apCanvas->LineOffsets[ i ] = lOffset;
		lOffset += lLineWidth;
	}

	apCanvas->pFuncs     = &gGraphicFuncs[ aColourMode ];
	apCanvas->pClipFuncs = &gGraphicFuncsClip[ aColourMode ];

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : GraphicCanvas_SetpVRAM( sGraphicCanvas * apCanvas,void * apVRAM )
* ACTION   : GraphicCanvas_SetpVRAM
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	GraphicCanvas_SetpVRAM( sGraphicCanvas * apCanvas,void * apVRAM )
{
	apCanvas->pVRAM = apVRAM;
}


/* ################################################################################ */
