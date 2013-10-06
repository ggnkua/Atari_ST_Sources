#ifndef	INCLUDED_GRAPHIC_H
#define	INCLUDED_GRAPHIC_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dGRAPHIC_HEIGHT_LIMIT	1025


/* ###################################################################################
#  ENUMS
################################################################################### */

enum
{
	eGRAPHIC_COLOURMODE_1BP,
	eGRAPHIC_COLOURMODE_2BP,
	eGRAPHIC_COLOURMODE_4BP,
	eGRAPHIC_COLOURMODE_8BPP,
	eGRAPHIC_COLOURMODE_16BPP,
	eGRAPHIC_COLOURMODE_24BPP,
	eGRAPHIC_COLOURMODE_32BPP,

	eGRAPHIC_COLOURMODE_LIMIT
};


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef struct
{
	S16	X;
	S16	Y;
} sGraphicPos;

typedef struct
{
	S16	X;
	S16	Y;
	S16	Width;
	S16	Height;
} sGraphicRect;

typedef struct
{
	void (*	Blit )(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, struct sGraphicCanvas * apSrc	);
	void (*	ClearScreen )(  struct sGraphicCanvas * apCanvas );
	void (*	CopyScreen )(   struct sGraphicCanvas * apCanvas, void * apSrc );
	void (* DrawBox )(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour );
	void (* DrawLine )(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
	void (* DrawPixel )(    struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
	void (* DrawSprite )(   struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   void * apSprite );
	void (* DrawTri  )(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
	void (* DrawQuad )(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour );
} sGraphicFuncs;


typedef	struct sGraphicCanvas
{
	void *			pVRAM;
	U16				ColourMode;
	U16				Width;
	U16				Height;
	U16				pad;
	sGraphicFuncs *	pFuncs;
	sGraphicFuncs *	pClipFuncs;
	U32				LineOffsets[ dGRAPHIC_HEIGHT_LIMIT ];
} sGraphicCanvas;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Graphic_Init( void );
void	Graphic_DeInit( void );

void	GraphicCanvas_Init(     sGraphicCanvas * apCanvas, const U16 aColourMode, const U16 aWidth, const U16 aHeight );
void	GraphicCanvas_SetpVRAM( sGraphicCanvas * apCanvas, void * apVRAM );


/* ################################################################################ */

#endif	/* INCLUDED_GRAPHIC_H */