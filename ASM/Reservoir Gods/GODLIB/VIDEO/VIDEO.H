#ifndef	INCLUDED_VIDEO_H
#define	INCLUDED_VIDEO_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  ENUMS
################################################################################### */

enum
{
	eBITPLANE_NONE        = 0,
	eBITPLANE_INTERLEAVED = 1,
	eBITPLANE_CONTINUOUS  = 2
};

enum
{
	eVIDEO_MODE_1PLANE,
	eVIDEO_MODE_2PLANE,
	eVIDEO_MODE_4PLANE,
	eVIDEO_MODE_8PLANE,
	eVIDEO_MODE_RGB565
};

enum
{
	eMONITOR_MONO = 0,
	eMONITOR_VGA  = 1,
	eMONITOR_RGB  = 2,
	eMONITOR_TV   = 3,
	eMONITOR_HDTV = 4
};


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef struct
{
	void *	pPhysic;
	U16 *	pPalST;
	U16 *	pPalTT;
	U32 *	pPalFalcon;
	U16		Width;
	U16		Height;
	U16		Mode;
	U16		ScrollX;
	U16		ScrollY;
	U16		NTSCFlag;
	U16		ScanLineWords0;
	U16		ScanLineWords1;
	U8		UpdatePhysicFlag;
	U8		UpdatePalSTFlag;
	U8		UpdatePalTTFlag;
	U8		UpdatePalFalconFlag;
	U8		UpdateScrollFlag;
} sVideo;


typedef	struct
{
	U32	pPhysic;
	U32	pLogic;
	U16	Res;
	U8	RegMode;
	U8	RegSync;
} sVideoSaveRegsST;


typedef	struct
{
	U32	pPhysic;
	U32	pLogic;
	U16	Res;
	U8	RegMode;
	U8	RegSync;
	U8	RegLineWidth;
	U8	RegScroll;
} sVideoSaveRegsSTE;


typedef	struct
{
	U32	Regs[32];
	U16	PalST[16];
	U32	PalFalcon[256];
} sVideoSaveState;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Video_Init( void );
void	Video_DeInit( void );
U8		Video_SetMode( const U16 aWidth, const U16 aHeight, const U16 aMode, const U16 aCanvasWidth, const U8 aNTSCflag, const U8 aWideScreenFlag );
S16		Video_GetMode();

void	Video_SetPhysic( const void * apPhysic );
void *	Video_GetpPhysic( void );
void	Video_SetPalST( const U16 * apPal );
void	Video_GetPalST( U16 * apPal );
void	Video_SetPalFalcon( const U32 * apPal );
void	Video_GetPalFalcon( U32 * apPal );
U32		Video_GetScreenSize( void );

void	Video_SetNextPalST( const U16 * apPal );
void	Video_SetNextPalTT( const U16 * apPal );
void	Video_SetNextPalFalcon( const U32 * apPal );


/* ################################################################################ */

#endif	/* INCLUDED_VIDEO_H */