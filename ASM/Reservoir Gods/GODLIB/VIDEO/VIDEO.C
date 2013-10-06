/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: VIDEO.C
::
:: Video register manipulation routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"VIDEO.H"

#include	<GODLIB\DEBUGLOG\DEBUGLOG.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>
#include	<GODLIB\VBL\VBL.H>


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Video_SaveRegsST(     void * apBuffer );
void	Video_RestoreRegsST(  void * apBuffer );
void	Video_SaveRegsSTE(    void * apBuffer );
void	Video_RestoreRegsSTE( void * apBuffer );
void	Video_SaveRegsTT(     void * apBuffer );
void	Video_RestoreRegsTT(  void * apBuffer );
void	Video_SaveRegsFalcon(     void * apBuffer );
void	Video_RestoreRegsFalcon(  void * apBuffer );

extern	void	Video_XbiosSetScreen( U16 aMode );
extern	void	Video_XbiosFalconSetLow( void );
extern	void	Video_SetFalconSTLowVGA( void );
extern	void	Video_SetFalconSTLowRGBPAL_W( void );
extern	void	Video_SetFalconSTLowRGBNTSC_W( void );

extern	void	Video_SetFalconSTLowRGBPAL( void );
extern	void	Video_SetFalconSTLowRGBNTSC( void );

extern	void	Video_UpdateRegsST( void );
extern	void	Video_UpdateRegsSTE( void );
extern	void	Video_UpdateRegsTT( void );
extern	void	Video_UpdateRegsFalcon( void );


/* ###################################################################################
#  VARIABLES
################################################################################### */

sVideoSaveState	gVideoSaveState;
sVideo			gVideo;


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Video_Init( void )
* ACTION   : saves video registers
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Video_Init()
{
	gVideo.UpdatePhysicFlag    = 0xFF;
	gVideo.UpdatePalSTFlag     = 0xFF;
	gVideo.UpdatePalTTFlag     = 0xFF;
	gVideo.UpdatePalFalconFlag = 0xFF;
	gVideo.UpdateScrollFlag    = 0xFF;

	switch( System_GetVDO() )
	{
	case VDO_ST:
		Video_SaveRegsST( &gVideoSaveState.Regs[0] );
		Video_GetPalST(   &gVideoSaveState.PalST[0] );
		Vbl_SetVideoFunc( Video_UpdateRegsST );
		break;
	case VDO_STE:
		Video_SaveRegsSTE( &gVideoSaveState.Regs[0] );
		Video_GetPalST(    &gVideoSaveState.PalST[0] );
		Vbl_SetVideoFunc( Video_UpdateRegsSTE );
		break;
	case VDO_TT:
		Video_SaveRegsTT( &gVideoSaveState.Regs[0] );
		Video_GetPalST(   &gVideoSaveState.PalST[0] );
		Vbl_SetVideoFunc( Video_UpdateRegsTT );
		break;
	case VDO_FALCON:
		Video_SaveRegsFalcon( &gVideoSaveState.Regs[0] );
		Video_GetPalST(       &gVideoSaveState.PalST[0] );
		Video_GetPalFalcon(   &gVideoSaveState.PalFalcon[0] );
		Vbl_SetVideoFunc( Video_UpdateRegsFalcon );
		break;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Video_DeInit( void )
* ACTION   : restores video registers
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Video_DeInit()
{
	gVideo.UpdatePhysicFlag    = 0xFF;
	gVideo.UpdatePalSTFlag     = 0xFF;
	gVideo.UpdatePalTTFlag     = 0xFF;
	gVideo.UpdatePalFalconFlag = 0xFF;
	gVideo.UpdateScrollFlag    = 0xFF;

	switch( System_GetVDO() )
	{
	case VDO_ST:
		Video_RestoreRegsST( &gVideoSaveState.Regs[0] );
		Video_SetPalST(      &gVideoSaveState.PalST[0] );
		break;
	case VDO_STE:
		Video_RestoreRegsSTE( &gVideoSaveState.Regs[0] );
		Video_SetPalST(       &gVideoSaveState.PalST[0] );
		break;
	case VDO_TT:
		Video_RestoreRegsTT( &gVideoSaveState.Regs[0] );
		Video_SetPalST(      &gVideoSaveState.PalST[0] );
		break;
	case VDO_FALCON:
		Video_RestoreRegsFalcon( &gVideoSaveState.Regs[0] );
		Video_SetPalST(          &gVideoSaveState.PalST[0] );
		Video_SetPalFalcon(      &gVideoSaveState.PalFalcon[0] );
		break;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Video_SetMode( const U16 aWidth, const U16 aHeight, const U16 aMode, const U16 aCanvasWidth, const U8 aNTSCFlag, const U8 aWideScreenFlag )
* ACTION   : sets video mode
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

U8	Video_SetMode( const U16 aWidth, const U16 aHeight, const U16 aMode, const U16 aCanvasWidth, const  U8 aNTSCFlag, const U8 aWideScreenFlag )
{
	gVideo.Width    = aWidth;
	gVideo.Height   = aHeight;
	gVideo.NTSCFlag = aNTSCFlag;
	gVideo.Mode     = aMode;

	switch( aMode )
	{
	case eVIDEO_MODE_1PLANE:
		gVideo.ScanLineWords0 = aCanvasWidth >> 4;
		gVideo.ScanLineWords1 = gVideo.ScanLineWords0 - 1;
		break;
	case eVIDEO_MODE_2PLANE:
		gVideo.ScanLineWords0 = aCanvasWidth >> 3;
		gVideo.ScanLineWords1 = gVideo.ScanLineWords0 - 1;
		break;
	case eVIDEO_MODE_4PLANE:
		gVideo.ScanLineWords0 = aCanvasWidth >> 2;
		gVideo.ScanLineWords1 = gVideo.ScanLineWords0 - 1;
		break;
	case eVIDEO_MODE_8PLANE:
		gVideo.ScanLineWords0 = aCanvasWidth >> 1;
		gVideo.ScanLineWords1 = gVideo.ScanLineWords0 - 1;
		break;
	case eVIDEO_MODE_RGB565:
		gVideo.ScanLineWords0 = aCanvasWidth;
		gVideo.ScanLineWords1 = gVideo.ScanLineWords0 - 1;
		break;
	}

	switch( System_GetVDO() )
	{
	case VDO_ST:
		if( aCanvasWidth != aWidth )
		{
			DebugLog_Printf2( "Video_SetMode() : error : width!=canvas width on ST %d %d\n", aWidth, aCanvasWidth );
			return( 0 );
		}

		switch( aMode )
		{

		case eVIDEO_MODE_1PLANE:
			Vbl_WaitVbl();
			if( (aWidth == 640) && (aHeight == 400 ) )
			{
				*(U8 *)0xFFFF8260L = 2;
				return( 1 );
			}
			break;

		case eVIDEO_MODE_2PLANE:
			Vbl_WaitVbl();
			if( (aWidth == 640) && (aHeight == 200 ) )
			{
				*(U8 *)0xFFFF8260L = 1;
				if( !aNTSCFlag )
				{
					*(U8 *)0xFFFF820AL = 0x2;
				}
				else
				{
					*(U8 *)0xFFFF820AL = 0x0;
				}
				return( 1 );
			}
			break;

		case eVIDEO_MODE_4PLANE:
			Vbl_WaitVbl();
			if( (aWidth == 320) && (aHeight == 200 ) )
			{
				*(U8 *)0xFFFF8260L = 0;
				if( !aNTSCFlag )
				{
					*(U8 *)0xFFFF820AL = 0x2;
				}
				else
				{
					*(U8 *)0xFFFF820AL = 0x0;
				}
				return( 1 );
			}
			break;

		}
		break;

	case VDO_STE:
		switch( aMode )
		{

		case eVIDEO_MODE_1PLANE:
			Vbl_WaitVbl();
			*(U8 *)0xFFFF8260L = 2;
			*(U8 *)0xFFFF8265L = 0;
			*(U8 *)0xFFFF820FL = (U8)(gVideo.ScanLineWords1&0xFF);
			return( 1 );

		case eVIDEO_MODE_2PLANE:
			Vbl_WaitVbl();
			*(U8 *)0xFFFF8260L = 1;
			*(U8 *)0xFFFF8265L = 0;
			*(U8 *)0xFFFF820FL = 0; /*(U8)(gVideo.ScanLineWords1&0xFF);*/
			if( !aNTSCFlag )
			{
				*(U8 *)0xFFFF820AL = 0x2;
			}
			else
			{
				*(U8 *)0xFFFF820AL = 0x0;
			}
			return( 1 );

		case eVIDEO_MODE_4PLANE:
			Vbl_WaitVbl();
			*(U8 *)0xFFFF8260L = 0;
			*(U8 *)0xFFFF8265L = 0;
			*(U8 *)0xFFFF820FL = 0; /*(U8)(gVideo.ScanLineWords0&0xFF); */
			if( !aNTSCFlag )
			{
				*(U8 *)0xFFFF820AL = 0x2;
			}
			else
			{
				*(U8 *)0xFFFF820AL = 0x0;
			}
			return( 1 );

		}
		break;

	case VDO_TT:
		switch( aMode )
		{

		case eVIDEO_MODE_1PLANE:
			if( (aWidth <= 640) && (aHeight <= 400) )
			{
				*(U8 *)0xFFFF8260L = 2;
				*(U8 *)0xFFFF8265L = 0;
				*(U8 *)0xFFFF820FL = (U8)(gVideo.ScanLineWords1&0xFF);
			}
			else
			{
				*(U16 *)0xFFFF8262L = 0x500;
				*(U8 *)0xFFFF8265L = 0;
				*(U8 *)0xFFFF820FL = (U8)(gVideo.ScanLineWords1&0xFF);
			}
			return( 1 ); 

		case eVIDEO_MODE_2PLANE:
			*(U8 *)0xFFFF8260L = 1;
			*(U8 *)0xFFFF8265L = 0;
			*(U8 *)0xFFFF820FL = (U8)(gVideo.ScanLineWords1&0xFF);
			return( 1 );

		case eVIDEO_MODE_4PLANE:
			if( (aWidth <= 320) && (aHeight <= 200) )
			{
				*(U8 *)0xFFFF8260L = 0;
				*(U8 *)0xFFFF8265L = 0;
				*(U8 *)0xFFFF820FL = (U8)(gVideo.ScanLineWords1&0xFF);
			}
			else
			{
				*(U16 *)0xFFFF8262L = 0x400;
				*(U8 *)0xFFFF8265L = 0;
				*(U8 *)0xFFFF820FL = (U8)(gVideo.ScanLineWords1&0xFF);
			}
			return( 1 );

		case eVIDEO_MODE_8PLANE:
			*(U16 *)0xFFFF8262L = 0x700;
			*(U8 *)0xFFFF8265L = 0;
			*(U8 *)0xFFFF820FL = (U8)(gVideo.ScanLineWords1&0xFF);
			return( 1 );

		}
		break;

	case VDO_FALCON:

		switch( aMode )
		{

		case eVIDEO_MODE_1PLANE:
			if( (aWidth == 640) && (aHeight == 400 ) )
			{
				Video_XbiosSetScreen( 2 );
				return( 1 );
			}
			break;
		case eVIDEO_MODE_2PLANE:
			if( (aWidth == 640) && (aHeight == 200 ) )
			{
				Video_XbiosSetScreen( 1 );
				return( 1 );
			}
			break;
		case eVIDEO_MODE_4PLANE:
			if( (aWidth == 320) && (aHeight == 200 ) )
			{
/*					Video_XbiosSetScreen( 0 );*/
				if( System_GetMON() == MON_VGA )
				{
					Video_SetFalconSTLowVGA();
				}
				else
				{
					if( aNTSCFlag )
					{
						if( aWideScreenFlag )
						{
							Video_SetFalconSTLowRGBNTSC_W();
						}
						else
						{
							Video_SetFalconSTLowRGBNTSC();
						}
					}
					else
					{
						if( aWideScreenFlag )
						{
							Video_SetFalconSTLowRGBPAL_W();
						}
						else
						{
							Video_SetFalconSTLowRGBPAL();
						}
					}
				}
				return( 1 );
			}
			break;

		}
		break;

	}
	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Video_GetScreenSize()
* ACTION   : returns the size of the screen
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

U32		Video_GetScreenSize()
{
	U32	lSize;

	lSize  = gVideo.ScanLineWords0 << 1;
	lSize *= gVideo.Height;

	return( lSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Video_SetPhysic( const void * apPhysic )
* ACTION   : sets physic to be apPhysic
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Video_SetPhysic( const void * apPhysic )
{
	gVideo.pPhysic          = (void *)apPhysic;
	gVideo.UpdatePhysicFlag = 0;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Video_pPhysic( void )
* ACTION   : returns pointer to physic
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void *	Video_GetpPhysic( void )
{
	return( gVideo.pPhysic );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Video_SetNextPalST( const U16 * apPal )
* ACTION   : sets ST palette on next VBL interrupt
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Video_SetNextPalST( const U16 * apPal )
{
	gVideo.pPalST          = (U16*)apPal;
	gVideo.UpdatePalSTFlag = 0;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Video_SetNextPalTT( const U16 * apPal )
* ACTION   : sets TT palette on next VBL interrupt
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Video_SetNextPalTT( const U16 * apPal )
{
	gVideo.pPalTT          = (U16*)apPal;
	gVideo.UpdatePalTTFlag = 0;
}



/*-----------------------------------------------------------------------------------*
* FUNCTION : Video_SetNextPalFalcon( const U16 * apPal )
* ACTION   : sets Falcon palette on next VBL interrupt
* CREATION : 24.03.00 PNK
*-----------------------------------------------------------------------------------*/

void	Video_SetNextPalFalcon( const U32 * apPal )
{
	gVideo.pPalFalcon          = (U32*)apPal;
	gVideo.UpdatePalFalconFlag = 0;
}


/* ################################################################################ */
