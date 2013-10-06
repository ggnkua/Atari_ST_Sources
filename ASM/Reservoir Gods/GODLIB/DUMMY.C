/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\AUDIO\AUDIO.H>
#include	<GODLIB\AUDIO\AMIXER.H>
#include	<GODLIB\BIOS\BIOS.H>
#include	<GODLIB\GEMDOS\GEMDOS.H>
#include	<GODLIB\GRAPHIC\GRAPHIC.H>
#include	<GODLIB\MUSIC\PINKNOTE.H>
#include	<GODLIB\MFP\MFP.H>
#include	<GODLIB\SYSTEM\SYSTEM.H>
#include	<GODLIB\VIDEO\VIDEO.H>
#include	<GODLIB\VBL\VBL.H>
#include	<GODLIB\XBIOS\XBIOS.H>


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	(*gfDummyVoid)();
void	(*gfDummyVoidV)( void );

/* ###################################################################################
#  DATA
################################################################################### */

U16	gDummyU16;


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
	AMIXER_S.S	
*-----------------------------------------------------------------------------------*/

U8 *			gpAudioMixerSilence;
U8 *			gpAudioMixerBuffer;
U8 *			gpAudioMixerMulTable;
U32				gAudioMixerBufferOffset;
U8				gAudioMixerLockFlag;
U8				gAudioMixerEnableFlag;
sAmixerSpl		gAudioMixerSamples[ 2 ];

void			AudioMixer_Vbl( void ){}

/*-----------------------------------------------------------------------------------*
	AUDIO_S.S	
*-----------------------------------------------------------------------------------*/

U8				gAudioDmaPlayingFlag;

void			Audio_ReplayEndInt( void ){}
void			Audio_SaveYM( void ){}
void			Audio_RestoreYM( void ){}
void			Audio_SaveDmaSte( void ){}
void			Audio_RestoreDmaSte( void ){}
void			Audio_SaveDmaFalcon( void ){}
void			Audio_RestoreDmaFalcon( void ){}
void			Audio_SoundChipOff( void ){}
void			Audio_MicroWireWrite( const U16 aVal ) { gDummyU16 = aVal; }

/*-----------------------------------------------------------------------------------*
	CLOCK_S.S	
*-----------------------------------------------------------------------------------*/

void		Clock_TimeVbl( void )	{}

/*-----------------------------------------------------------------------------------*
	EXCEPT_S.S	
*-----------------------------------------------------------------------------------*/

void			Except_Handler68000( void ){}
void			Except_Handler68030( void ){}
U32				gExcept_HandlersTable[ 64 ];
void			__text( void ){}

/*-----------------------------------------------------------------------------------*
	FADE_S.S	
*-----------------------------------------------------------------------------------*/

void			Fade_Vbl( void ) {}
U8				gFadeVblActiveFlag;

/*-----------------------------------------------------------------------------------*
	GEMDOS_S.S	
*-----------------------------------------------------------------------------------*/

S32	GemDos_Call( const S16 aOp ){ return(0); }
S32	GemDos_Call_L( const S16 aOp, const S32  aL0 ){ return(0); }
S32	GemDos_Call_P( const S16 aOp, const void *  ap0 ){ return(0); }
S32	GemDos_Call_W( const S16 aOp, const S16 aW0 ){ return(0); }
S32	GemDos_Call_LW( const S16 aOp, const S32 aL0, const S16 aW0 ){ return(0); }
S32	GemDos_Call_PL( const S16 aOp, const void * ap0, const S32 aL0 ){ return(0); }
S32	GemDos_Call_PP( const S16 aOp, const void * ap0, const void * ap1 ){ return(0); }
S32	GemDos_Call_PW( const S16 aOp, const void * ap0, const S16 aW0 ){ return(0); }
S32	GemDos_Call_WL( const S16 aOp, const S16 aW0, const S32 aL0 ){ return(0); }
S32	GemDos_Call_WP( const S16 aOp, const S16 aW0, const void * ap0 ){ return(0); }
S32	GemDos_Call_WW( const S16 aOp, const S16 aW0, const S16 aW1 ){ return(0); }
S32	GemDos_Call_LWW( const S16 aOp, const S32 aL0, const S16 aW0, const S16 aW1 ){ return(0); }
S32	GemDos_Call_PWW( const S16 aOp, const void * ap0, const S16 aW0, const S16 aW1 ){ return(0); }
S32	GemDos_Call_WLP( const S16 aOp, const S16 aW0, const S32 aL0, const void * ap0 ){ return(0); }
S32	GemDos_Call_WLL( const S16 aOp, const S16 aW0, const S32 aL0, const S32 aL1 ){ return(0); }
S32	GemDos_Call_WLW( const S16 aOp, const S16 aW0, const S32 aL0, const S16 aW1 ){ return(0); }
S32	GemDos_Call_WPL( const S16 aOp, const S16 aW0, const void * ap0, const S32 aL0 ){ return(0); }
S32	GemDos_Call_WPP( const S16 aOp, const S16 aW0, const void * ap0, const void * ap1 ){ return(0); }
S32	GemDos_Call_WWP( const S16 aOp, const S16 aW0, const S16 aW1, const void * ap0 ){ return(0); }
S32	GemDos_Call_WWW( const S16 aOp, const S16 aW0, const S16 aW1, const S16 aW2 ){ return(0); }
S32	GemDos_Call_WPPL( const S16 aOp, const S16 aW0, const void * ap0, const void * ap1, const S32 aL0 ){ return(0); }
S32	GemDos_Call_WPPP( const S16 aOp, const S16 aW0, const void * ap0, const void * ap1, const void * ap2 ){ return(0); }
S32	GemDos_Call_WWLL( const S16 aOp, const S16 aW0, const S16 aW1, const S32 aL0, const S32 aL1 ){ return(0); }

/*-----------------------------------------------------------------------------------*
	GRF_4_S.S	
*-----------------------------------------------------------------------------------*/

void Graphic_4BP_Blit(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, void * apSrc, void * apDst ){}
void Graphic_4BP_ClearScreen(  struct sGraphicCanvas * apCanvas, void * apDst ){}
void Graphic_4BP_CopyScreen(   struct sGraphicCanvas * apCanvas, void * apSrc, void * apDst ){}
void Graphic_4BP_DrawBox(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour ){}
void Graphic_4BP_DrawLine(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawPixel(    struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawSprite(   struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   void * apSprite ){}
void Graphic_4BP_DrawTri(      struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawQuad(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}

void Graphic_4BP_Blit_Clip(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, void * apSrc, void * apDst ){}
void Graphic_4BP_DrawBox_Clip(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour ){}
void Graphic_4BP_DrawLine_Clip(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawPixel_Clip(    struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawSprite_Clip(   struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   void * apSprite ){}
void Graphic_4BP_DrawTri_Clip(      struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawQuad_Clip(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}

void Graphic_4BP_Blit_BLT(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, void * apSrc, void * apDst ){}
void Graphic_4BP_ClearScreen_BLT(  struct sGraphicCanvas * apCanvas, void * apDst ){}
void Graphic_4BP_CopyScreen_BLT(   struct sGraphicCanvas * apCanvas, void * apSrc, void * apDst ){}
void Graphic_4BP_DrawBox_BLT(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour ){}
void Graphic_4BP_DrawLine_BLT(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawPixel_BLT(    struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawSprite_BLT(   struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   void * apSprite ){}
void Graphic_4BP_DrawTri_BLT(      struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawQuad_BLT(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}

void Graphic_4BP_Blit_Clip_BLT(         struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,  sGraphicRect * apRect, void * apSrc, void * apDst ){}
void Graphic_4BP_DrawBox_Clip_BLT(      struct sGraphicCanvas * apCanvas,  sGraphicRect * apCoords,  S16 aColour ){}
void Graphic_4BP_DrawLine_Clip_BLT(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawPixel_Clip_BLT(    struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawSprite_Clip_BLT(   struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   void * apSprite ){}
void Graphic_4BP_DrawTri_Clip_BLT(      struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}
void Graphic_4BP_DrawQuad_Clip_BLT(     struct sGraphicCanvas * apCanvas,  sGraphicPos * apCoords,   S16 aColour ){}

/*-----------------------------------------------------------------------------------*
	IKBD_S.S	
*-----------------------------------------------------------------------------------*/

void			IKBD_Flush( void ){}
void			IKBD_FlushGemdos( void ){}
void		 	(*IKBD_GetHandler( void ))(void){return( gfDummyVoidV );}
void			IKBD_SetHandler( void (*apHandler)(void) ){}
void			IKBD_SendCmd( U8 aCmd ){}
void			IKBD_MainHandler( void ){}
void			IKBD_PowerpadHandler( void ){}
void			IKBD_InitTosLink( U32 apBuffer, U32 aFunction ){}
U16				IKBD_GetMidiBytesWaiting( void ){return(0);}
U16				IKBD_GetKbdBytesWaiting( void ){return(0);}
U8				IKBD_PopMidiByte( void ){return(0);}
U8				IKBD_PopKbdByte( void ){return(0);}


/*-----------------------------------------------------------------------------------*
	MFP_S.S	
*-----------------------------------------------------------------------------------*/

typedef	struct
{
	U16		Instruction;
	void	(*Func)(void);
} sMfpJumpLong;
sMfpJumpLong	gMfpStcOldJump;
sMfpJumpLong	gMfpStcNewJump;
U8				gMfpNewEnableFlag;
U32				gMfpStcCounter;
sTime			gMfpStcTime;
void			Mfp_SaveRegisters( sMfpRegisterDump * apDump ){}
void			Mfp_RestoreRegisters( sMfpRegisterDump * apDump ){}
void			Mfp_InstallStandardTimerC( void ){}
void			Mfp_GetTimerA( sMfpTimer * apTimer ){}
void			Mfp_GetTimerB( sMfpTimer * apTimer ){}
void			Mfp_GetTimerC( sMfpTimer * apTimer ){}
void			Mfp_GetTimerD( sMfpTimer * apTimer ){}
void			Mfp_InstallTimerA( sMfpTimer * apTimer ){}
void			Mfp_InstallTimerB( sMfpTimer * apTimer ){}
void			Mfp_InstallTimerC( sMfpTimer * apTimer ){}
void			Mfp_InstallTimerD( sMfpTimer * apTimer ){}
void			Mfp_HookIntoTimerC( sMfpTimer * apTimer ){}
void			Mfp_HookDisableTimerC( void ){}
void			Mfp_HookEnableTimerC( void ){}
void			Mfp_DisableSystemTimerC( void ){}

/*-----------------------------------------------------------------------------------*
	PACKER_S.S	
*-----------------------------------------------------------------------------------*/

void			Packer_DepackIce( void * apData ){}
void			Packer_DepackAtomic( void * apData ){}

/*-----------------------------------------------------------------------------------*
	PNKNOT_S.S	
*-----------------------------------------------------------------------------------*/

sPinkNoteChannel	gPinkNoteChannel[ 3 ];
void			PinkNote_Player( void ){}
void			PinkNote_NotePlayChannelA( sPinkNoteChannel * apChannel ){}
void			PinkNote_NotePlayChannelB( sPinkNoteChannel * apChannel ){}
void			PinkNote_NotePlayChannelC( sPinkNoteChannel * apChannel ){}

/*-----------------------------------------------------------------------------------*
	PROFILES.S	
*-----------------------------------------------------------------------------------*/

void			Profiler_HBL( void ){}
void			Profiler_VBL( void ){}

/*-----------------------------------------------------------------------------------*
	SCRGRABS.S	
*-----------------------------------------------------------------------------------*/

void			ScreenGrab_Vbl( void ){}

/*-----------------------------------------------------------------------------------*
	SND_S.S	
*-----------------------------------------------------------------------------------*/

void			Snd_SetpPlayFunc( void (*aPlayFunc)(void) ){}
void			Snd_SetpChaserFunc( void (*aChaserFunc)(void) ){}
void			Snd_CallFunction( void (*aFunc)() ){}
void			Snd_Player( void ){}

/*-----------------------------------------------------------------------------------*
	SYSTEM_S.S	
*-----------------------------------------------------------------------------------*/

typedef	struct
{
	U32	Vectors[ 62 ];
} sSystemVectors;
U32				gSystemHblTempCounter;
U32				gSystem200hzTempCounter;
void			System_SaveVectors( sSystemVectors * apVectors ){}
void			System_RestoreVectors( sSystemVectors * apVectors ){}
void			System_SetDataCache030( U32 aFlag ){}
void			System_HblTemp( void ){}
void			System_200hzTemp( void ){}
void			System_SetIML( U16 aIML ){}
U16				System_GetIML( void ){return(0);}
U32				System_GetEmuName0( void ){return(0);}
U32				System_GetEmuName1( void ){return(0);}
U32				System_GetEmuVers( void ){return(0);}
sSystemEmuDesc *	System_GetpEmuDescLL( void )	{ return(0); }

/*-----------------------------------------------------------------------------------*
	VBL_S.S	
*-----------------------------------------------------------------------------------*/

U32				Vbl_GetCounter( void ){return( 0 );}
void			Vbl_SetHandler( void (*apHandler)() ){}
void			Vbl_HandlerST( void ){}
void			Vbl_HandlerSTE( void ){}
void			Vbl_HandlerTT( void ){}
void			Vbl_HandlerFalcon( void ){}
void			Vbl_WaitVbl(){}
void			(*Vbl_GetHandler( void ) ) (){return( gfDummyVoid );}
void	Vbl_DummyFunc( void )	{}
void	Vbl_Handler( void ) {}

/*-----------------------------------------------------------------------------------*
	VIDEO_S.S	
*-----------------------------------------------------------------------------------*/

void			Video_SaveRegsST(     void * apBuffer ){}
void			Video_RestoreRegsST(  void * apBuffer ){}
void			Video_SaveRegsSTE(    void * apBuffer ){}
void			Video_RestoreRegsSTE( void * apBuffer ){}
void			Video_SaveRegsTT(     void * apBuffer ){}
void			Video_RestoreRegsTT(  void * apBuffer ){}
void			Video_SaveRegsFalcon(     void * apBuffer ){}
void			Video_RestoreRegsFalcon(  void * apBuffer ){}
void			Video_XbiosSetScreen( U16 aMode ){}
void			Video_XbiosFalconSetLow( void ){}
void			Video_SetFalconSTLowVGA( void ){}
void			Video_SetFalconSTLowRGBPAL( void ){}
void			Video_SetFalconSTLowRGBNTSC( void ){}
void			Video_SetFalconSTLowRGBPAL_W( void ){}
void			Video_SetFalconSTLowRGBNTSC_W( void ){}
void			Video_SetPalST( const U16 * apPal ){}
void			Video_GetPalST( U16 * apPal ){}
void			Video_GetPalFalcon( U32 * apPal ){}
void			Video_SetPalFalcon( const U32 * apPal ){}

void	Video_UpdateRegsST( void ){}
void	Video_UpdateRegsSTE( void ){}
void	Video_UpdateRegsTT( void ){}
void	Video_UpdateRegsFalcon( void ){}

/*-----------------------------------------------------------------------------------*
	XBIOS_S.S	
*-----------------------------------------------------------------------------------*/

S32	Xbios_Call( const S16 aOp ){ return(0); }
S32	Xbios_Call_L( const S16 aOp, const S32 aL0 ){ return(0); }
S32	Xbios_Call_P( const S16 aOp, const void * ap0 ){ return(0); }
S32	Xbios_Call_W( const S16 aOp, const S16 aW0 ){ return(0); }
S32	Xbios_Call_LL( const S16 aOp, const S32 aL0, const S32 aL1 ){ return(0); }
S32	Xbios_Call_PP( const S16 aOp, const void * ap0, const void * ap1 ){ return(0); }
S32	Xbios_Call_WP( const S16 aOp, const S16 aW0, const void * ap0 ){ return(0); }
S32	Xbios_Call_WW( const S16 aOp, const S16 aW0, const S16 aW1 ){ return(0); }
S32	Xbios_Call_LLW( const S16 aOp, const S32 aL0, const S32 aL1, const S16 aW0 ){ return(0); }
S32	Xbios_Call_WWL( const S16 aOp, const S16 aW0, const S16 aW1, const S32 aL0 ){ return(0); }
S32	Xbios_Call_WWP( const S16 aOp, const S16 aW0, const S16 aW1, const void * ap0 ){ return(0); }
S32	Xbios_Call_PLW( const S16 aOp, const void * ap0, const S32 aL0, const S16 aW0 ){ return(0); }
S32	Xbios_Call_PPP( const S16 aOp, const void * ap0, const void * ap1, const void * ap2 ){ return(0); }
S32	Xbios_Call_PPW( const S16 aOp, const void * ap0, const void * ap1, const S16 aW0 ){ return(0); }
S32	Xbios_Call_PWP( const S16 aOp, const void * ap0, const S16 aW0, const void * ap1 ){ return(0); }
S32	Xbios_Call_WPP( const S16 aOp, const S16 aW0, const void * ap0, const void * ap1 ){ return(0); }
S32	Xbios_Call_WWWP( const S16 aOp, const S16 aW0, const S16 aW1, const S16 aW2, const void * ap0 ){ return(0); }
S32	Xbios_Call_WLPL( const S16 aOp, const S16 aW0, const S32 aL0, const void * ap0, const S32 aL1 ){ return(0); }
S32	Xbios_Call_LLPP( const S16 aOp, const S32 aL0, const S32 aL1, const void * ap0, const void * ap1 ){ return(0); }
S32	Xbios_Call_LWPW( const S16 aOp, const S32 aL0, const S16 aW0, const void * ap0, const S16 aW1 ){ return(0); }
S32	Xbios_Call_PLLP( const S16 aOp, const void * ap0, const S32 aL0, const S32 aL1, const void * ap1 ){ return(0); }
S32	Xbios_Call_PLPL( const S16 aOp, const void * ap0, const S32 aL0, const void * ap1, const S32 aL1 ){ return(0); }
S32	Xbios_Call_PLWW( const S16 aOp, const void * ap0, const S32 aL0, const S16 aW0, const S16 aW1 ){ return(0); }
S32	Xbios_Call_PPWW( const S16 aOp, const void * ap0, const void * ap1, const S16 aW0, const S16 aW1 ){ return(0); }
S32	Xbios_Call_WWWWW( const S16 aOp, const S16 aW0, const S16 aW1, const S16 aW2, const S16 aW3, const S16 aW4 ){ return(0); }
S32	Xbios_Call_WWWWWW( const S16 aOp, const S16 aW0, const S16 aW1, const S16 aW2, const S16 aW3, const S16 aW4, const S16 aW5 ){ return(0); }
S32	Xbios_Call_PPLLLP( const S16 aOp, const void * ap0,  const void * ap1, const S32 aL0, const S32 aL1, const S32 aL2, const void * ap2 ){ return(0); }
S32	Xbios_Call_PLWWWWW( const S16 aOp, const void * ap0, const S32 aL0, const S16 aW0, const S16 aW1, const S16 aW2, const S16 aW3, const S16 aW4 ){ return(0); }
S32	Xbios_Call_PLWWWWWW( const S16 aOp, const void * ap0, const S32 aL0, const S16 aW0, const S16 aW1, const S16 aW2, const S16 aW3, const S16 aW4, const S16 aW5 ){ return(0); }
S32	Xbios_Call_PPWWWWWLW( const S16 aOp, const void * ap0,  const void * ap1, const S16 aW0,  const S16 aW1,  const S16 aW2,  const S16 aW3,  const S16 aW4, const S32 aL0, const S16 aW5 ){ return(0); }


/* ################################################################################ */
