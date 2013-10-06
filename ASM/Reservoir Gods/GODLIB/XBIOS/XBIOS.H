#ifndef	INCLUDED_XBIOS_H
#define	INCLUDED_XBIOS_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dXBIOS_BMAP_CHECK		0
#define	dXBIOS_BMAP_INQUIRE		-1
#define	dXBIOS_BMAP_MAPTAB		-2

#define	dXBIOS_BLIT_SOFT		0
#define	dXBIOS_BLIT_HARD		1
#define	dXBIOS_BLIT_INQUIR		-1

#define	dXBIOS_PLAY_ENABLE		1
#define	dXBIOS_PLAY_REPEAT		2
#define	dXBIOS_RECORD_ENABLE	4
#define	dXBIOS_RECORD_REPEAT	8		
#define	dXBIOS_SND_INQUIRE		-1

#define	dXBIOS_CURS_HIDE		0
#define	dXBIOS_CURS_SHOW		1
#define	dXBIOS_CURS_BLINK		2
#define	dXBIOS_CURS_NOBLINK		3
#define	dXBIOS_CURS_SETRATE		4
#define	dXBIOS_CURS_GETRATE		5

#define	dXBIOS_DS_INQUIRE		-1

#define	dXBIOS_DMAPLAY			0
#define	dXBIOS_DSPXMIT			1
#define	dXBIOS_EXTINP			2
#define	dXBIOS_ADC				3

#define	dXBIOS_DMAREC			1
#define	dXBIOS_DSPRECV			2
#define	dXBIOS_EXTOUT			4
#define	dXBIOS_DAC				8

#define	dXBIOS_CLK_25M			0
#define	dXBIOS_CLK_EXT			1
#define	dXBIOS_CLK_32M			2

#define	dXBIOS_CLK_COMPAT		0
#define	dXBIOS_CLK_50K			1
#define	dXBIOS_CLK_33K			2
#define	dXBIOS_CLK_25K			3
#define	dXBIOS_CLK_20K			4
#define	dXBIOS_CLK_16K			5
#define	dXBIOS_CLK_12K			7
#define	dXBIOS_CLK_10K			9
#define	dXBIOS_CLK_8K			11

#define	dXBIOS_ICR_RXDF			0
#define	dXBIOS_ICR_TXDE			1
#define	dXBIOS_ICR_TRDY			2
#define	dXBIOS_ICR_HF2			3
#define	dXBIOS_ICR_HF3			4
#define	dXBIOS_ICR_DMA			6
#define	dXBIOS_ICR_HREQ			7

#define	dXBIOS_BLOCK_LONG		0
#define	dXBIOS_BLOCK_WORD		1
#define	dXBIOS_BLOCK_BYTE		2

#define	dXBIOS_RTS_OFF			1
#define	dXBIOS_RTR_OFF			2

#define	dXBIOS_DSPSEND_NOTHING	0x0L
#define	dXBIOS_DSPSEND_ZERO		0xFF000000L

#define	dXBIOS_ESB_INQUIRE		-1
#define	dXBIOS_EC_INQUIRE		-1

#define	dXBIOS_ESG_INQUIRE		-1
#define	dXBIOS_ESG_COLOR		0
#define	dXBIOS_ESG_GRAY			1

#define	dXBIOS_ESM_INQUIRE		-1
#define	dXBIOS_ESM_NORMAL		0
#define	dXBIOS_ESM_SMEAR		1

#define	dXBIOS_FLOPPY_DSDD		0
#define	dXBIOS_FLOPPY_DSHD		1
#define	dXBIOS_FLOPPY_DSED		2

#define	dXBIOS_FRATE_6			0
#define	dXBIOS_FRATE_12			1
#define	dXBIOS_FRATE_2			2
#define	dXBIOS_FRATE_3			3

#define	dXBIOS_PSG_APPITCHLOW	0
#define	dXBIOS_PSG_APPITCHHIGH	1
#define	dXBIOS_PSG_BPITCHLOW	2
#define	dXBIOS_PSG_BPITCHHIGH	3
#define	dXBIOS_PSG_CPITCHLOW	4
#define	dXBIOS_PSG_CPITCHHIGH	5
#define	dXBIOS_PSG_NOISEPITCH	6
#define	dXBIOS_PSG_MODE			7
#define	dXBIOS_PSG_AVOLUME		8
#define	dXBIOS_PSG_BVOLUME		9
#define	dXBIOS_PSG_CVOLUME		10
#define	dXBIOS_PSG_FREQLOW		11
#define	dXBIOS_PSG_FREQHIGH		12
#define	dXBIOS_PSG_ENVELOPE		13
#define	dXBIOS_PSG_PORTA		14
#define	dXBIOS_PSG_PORTB		15

#define	dXBIOS_GPIO_INQUIRE		0
#define	dXBIOS_GPIO_READ		1
#define	dXBIOS_GPIO_WRITE		2

#define	dXBIOS_IM_DISABLE		0
#define	dXBIOS_IM_RELATIVE		1
#define	dXBIOS_IM_ABSOLUTE		2
#define	dXBIOS_IM_KEYCODE		3

#define	dXBIOS_IO_SERIAL		0
#define	dXBIOS_IO_KEYBOARD		1
#define	dXBIOS_IO_MIDI			2

#define	dXBIOS_KB_INQUIRE		-1

#define	dXBIOS_MFP_PARALLEL		0
#define	dXBIOS_MFP_DCD			1
#define	dXBIOS_MFP_CTS			2
#define	dXBIOS_MFP_BITBLT		3
#define	dXBIOS_MFP_TIMERD		4
#define	dXBIOS_MFP_200HZ		5
#define	dXBIOS_MFP_ACIA			6
#define	dXBIOS_MFP_DISK			7
#define	dXBIOS_MFP_TIMERB		8
#define	dXBIOS_MFP_TERR			9
#define	dXBIOS_MFP_TBE			10
#define	dXBIOS_MFP_RERR			11
#define	dXBIOS_MFP_RBF			12
#define	dXBIOS_MFP_TIMERA		13
#define	dXBIOS_MFP_RING			14
#define	dXBIOS_MFP_MONODETECT	15

#define	dXBIOS_NVM_READ			0
#define	dXBIOS_NVM_WRITE		1
#define	dXBIOS_NVM_RESET		2

#define	dXBIOS_GI_FLOPPYSIDE	1
#define	dXBIOS_GI_FLOPPYA		2
#define	dXBIOS_GI_FLOPPYB		4
#define	dXBIOS_GI_RTS			8
#define	dXBIOS_GI_DTR			0x10
#define	dXBIOS_GI_STROBE		0x20
#define	dXBIOS_GI_GPO			0x40
#define	dXBIOS_GI_SCCPORT		0x80

#define	dXBIOS_SERIAL_NOCHANGE	-1
#define	dXBIOS_SERIAL_RANDOM	0x01000001

#define	dXBIOS_DISK_NOCHANGE	-1
#define	dXBIOS_DISK_SSSD		0
#define	dXBIOS_DISK_DSSD		1
#define	dXBIOS_DISK_SSDD		2
#define	dXBIOS_DISK_DSDD		3
#define	dXBIOS_DISK_DSHD		4
#define	dXBIOS_DISK_DSED		5

#define	dXBIOS_EXEC_NOCHANGE	-1
#define	dXBIOS_EXEC_NO			0
#define	dXBIOS_EXEC_YES			1

#define	dXBIOS_BAUD_INQUIRE		-2
#define	dXBIOS_BAUD_19200		0
#define	dXBIOS_BAUD_9600		1
#define	dXBIOS_BAUD_4800		2
#define	dXBIOS_BAUD_3600		3
#define	dXBIOS_BAUD_2400		4
#define	dXBIOS_BAUD_2000		5
#define	dXBIOS_BAUD_1800		6
#define	dXBIOS_BAUD_1200		7
#define	dXBIOS_BAUD_600			8
#define	dXBIOS_BAUD_300			9
#define	dXBIOS_BAUD_200			10
#define	dXBIOS_BAUD_150			11
#define	dXBIOS_BAUD_134			12
#define	dXBIOS_BAUD_110			13
#define	dXBIOS_BAUD_75			14
#define	dXBIOS_BAUD_50			15

#define	dXBIOS_FLOW_NONE		0
#define	dXBIOS_FLOW_SOFT		1
#define	dXBIOS_FLOW_HARD		2
#define	dXBIOS_FLOW_BOTH		3

#define	dXBIOS_INT_DISABLE		0
#define	dXBIOS_INT_PLAY			1
#define	dXBIOS_INT_RECORD		2
#define	dXBIOS_INT_BOTH			3

#define	dXBIOS_MODE_STEREO8		0
#define	dXBIOS_MODE_STEREO16	1
#define	dXBIOS_MODE_MONO		2

#define	dXBIOS_PRT_DOTMATRIX	1
#define	dXBIOS_PRT_MONO			2
#define	dXBIOS_PRT_ATARI		4
#define	dXBIOS_PRT_DRAFT		8
#define	dXBIOS_PRT_PARALLEL		0x10
#define	dXBIOS_PRT_CONTINUOUS	0x20

#define	dXBIOS_SND_RESET		1
#define	dXBIOS_SND_OK			0
#define	dXBIOS_SND_BADCONTROL	1
#define	dXBIOS_SND_BADSYNC		2
#define	dXBIOS_SND_BADCLOCK		3

#define	dXBIOS_LTATTEN			0
#define	dXBIOS_RATTEN			1
#define	dXBIOS_LTGAIN			2
#define	dXBIOS_RTGAIN			3
#define	dXBIOS_ADDERIN			4
#define	dXBIOS_ADCINPUT			5
#define	dXBIOS_SETPRESCALE		6

#define	dXBIOS_CCLK_6K			0
#define	dXBIOS_CCLK_12K			1
#define	dXBIOS_CCLK_25K			2
#define	dXBIOS_CCLK_50K			3

#define	dXBIOS_MON_MONO			0
#define	dXBIOS_MON_COLOUR		1
#define	dXBIOS_MON_VGA			2
#define	dXBIOS_MON_TV			3


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U8 *	pBuffer;
	U16		BufferSize;
	U16		BufferHead;
	U16		BufferTail;
	U16		BufferLow;
	U16		BufferHigh;
} sXbiosIoRec;

typedef	struct
{
	S16				(*fBconstat)(void);
	S32				(*fBconin)(void);
	S32				(*fBcostat)(void);
	void			(*fBconout)(void);
	U32				(*fRsconf)(void);
	sXbiosIoRec *	pIoRec;
} sXbiosMapTab;


typedef	struct
{
	sXbiosMapTab *	pMapTab;
	S16				MapTabSize;
} sXbiosBconMap;


typedef	struct
{
	void *	pPlayBuffer;
	void *	pRecordBuffer;
	void *	pReserved;
	void *	pReserved2;
} sXbiosBufPtr;


typedef	struct
{
	U16		BlockType;
	U32		BlockSize;
	void *	pBlock;
} sXbiosDspBlock;



typedef	struct
{
	void (*afMidiIn)( void );
	void (*afIkbdErr)( void );
	void (*afMidiErr)( void );
	void (*afIkbdStatus)( void );
	void (*afMouse)( void );
	void (*afClock)( void );
	void (*afJoy)( void );
	void (*afMidiSys)( void );
	void (*afIkbdSys)( void );
	U8	IkbdState;
} sXbiosKbdVecs;


typedef	struct
{
	char *	pNormal;
	char *	pShift;
	char *	pCaps;
} sXbiosKeyTab;

typedef	struct
{
	U32		DriveMap;
	char *	pVersion;
	U32		Reserved[ 2 ];
} sXbiosMetaInfo;

typedef	struct
{
	void *	pBlock;
	U16		Offset;
	U16		Width;
	U16		Height;
	U16		Left;
	U16		Right;
	U16		SrcRes;
	U16		DstRes;
	U16 *	pPal;
	U16		Type;
	U16		Port;
	char *	pMasks;
} sXbiosPrtBlock;

/* ###################################################################################
#  PROTOTYPES
################################################################################### */

S32				Xbios_Bconmap( const S16 aDevNo );
void			Xbios_BiosKeys( void );
S16				Xbios_Blitmode( const S16 aMode );
S32				Xbios_Buffptr( const sXbiosBufPtr * apBuffer );

S16				Xbios_Cursconf( const S16 aMode, const S16 aRate );

void			Xbios_Dbmsg( const S16 aRsrved, const S16 aMsgNum, const S32 aMsgArg );
S32				Xbios_Devconnect( const S16 aSrc, const S16 aDst, const S16 aClk, const S16 aPreScale, const S16 aProtocol );

S32				Xbios_Dmaread( const S32 aSector, const S16 aCount, void * apBuffer, const S16 aDev );
S32				Xbios_Dmawrite( const S32 aSector, const S16 aCount, void * apBuffer, const S16 aDev );

void			Xbios_Dosound( const char * apCmdList );

void			Xbios_DspAvailable( const S32 * apXavail, const S32 * apYavail );
void			Xbios_DspBlkBytes( const U8 * apSrc, const S32 aSrcSize, U8 * apDst, const S32 aDstSize );
void			Xbios_DspBlkHandShake( const U8 * apSrc, const S32 aSrcSize, U8 * apDst, const S32 aDstSize );
void			Xbios_DspBlkUnpacked( const U32 * apSrc, const S32 aSrcSize, U32 * apDst, const S32 aDstSize );
void			Xbios_DspBlkWords( const U16 * apSrc, const S32 aSrcSize, U16 * apDst, const S32 aDstSize );
void			Xbios_DspDoBlock( const U8 * apSrc, const S32 aSrcSize, U8 * apDst, const S32 aDstSize );
void			Xbios_DspExecBoot( const U8 * apCode, const U32 aCodeSize, const S16 aAbility );
void			Xbios_DspExecProg( const U8 * apCode, const U32 aCodeSize, const S16 aAbility );

void			Xbios_DspFlushSubroutines( void );
S16				Xbios_DspGetProgAbility( void );
S16				Xbios_DspGetWordSize( void );
S16				Xbios_DspHf0( const S16 aFlag );
S16				Xbios_DspHf1( const S16 aFlag );
S16				Xbios_DspHf2( const S16 aFlag );
S16				Xbios_DspHf3( const S16 aFlag );
U8				Xbios_DspHstat( void );
S16				Xbios_DspInqSubrAbility( const S16 aAbility );
void			Xbios_DspInStream( const U8 * apSrc, const U32 aBlockSize, const U32 aBlockCount, U32 * apBlocksDone );
void			Xbios_DspIOStream( const U8 * apSrc, U8 * apDst, const U32 aSrcBlkSize, const U32 aDstBlkSize, const U32 aBlkCount, U32 * apBlocksDone );
void			Xbios_DspLoadProg( const char * apFile, const S16 aAbility, U8 * apBuffer );
S16				Xbios_DspLoadSubroutine( const U8 * apCode, const U32 aSize, const S16 aAbility );
S16				Xbios_DspLock( void );
S32				Xbios_DspLodToBinary( const char * apFile, U8 * apCode );
void			Xbios_DspMultBlocks( const U32 aSendBlockCount, const U32 aRecvBlockCount, const sXbiosDspBlock * apSendBlocks, sXbiosDspBlock * apRecvBlocks );
void			Xbios_DspOutStream( U8 * pData, const U32 aBlockSize, const U32 aBlockCount, U32 * apBlocksDone );
void			Xbios_DspRemoveInterrupts( const S16 aMask );
S16				Xbios_DspRequestUniqueAbility( void );
S16				Xbios_DspReserve( const U32 aReserveX, const U32 aReserveY );
S16				Xbios_DspRunSubroutine( const S16 aHandle );
void			Xbios_DspSetVectors( void (*afRecv)(void), void (*afTrans)(void) );
void			Xbios_DspTriggerHC( const S16 aVec );
void			Xbios_DspUnlock( void );
S32				Xbios_DspTristate( const S16 aDspXmit, const S16 aDspRec );

void			Xbios_EgetPalette( const U16 aStart, const U16 aCount, U16 * apPal );
U16				Xbios_EgetShift( void );
S16				Xbios_EsetBank( const S16 aBank );
S16				Xbios_EsetColor( const U16 aIndex, const U16 aColour );
S16				Xbios_EsetGray( const S16 aMode );
void			Xbios_EsetPalette( const U16 aStart, const U16 aCount, const U16 * apPal );
S16				Xbios_EsetShift( const S16 aMode );
S16				Xbios_EsetSmear( const S16 aMode );

S16				Xbios_Flopfmt( const void * apBuffer, const U16 * apSke, const U16 aDev, const U16 aSpt, const U16 aTrack, const U16 aSide, const U16 aIntlv, const U32 aMagic, const U16 aVirgin ); 
S16				Xbios_Floprate( const U16 aDev, const U16 aRate );
S16				Xbios_Floprd( void * apBuffer, const U32 aReserved, const U16 aDev, const U16 aSector, const U16 aTrack, const U16 aSide, const aCount );
S16				Xbios_Flopver( const void * apBuffer, const U32 aReserved, const U16 aDev, const U16 aSector, const U16 aTrack, const U16 aSide, const aCount );
S16				Xbios_Flopwr( const void * apBuffer, const U32 aReserved, const U16 aDev, const U16 aSector, const U16 aTrack, const U16 aSide, const aCount );

U16				Xbios_GetRez( void );
U32				Xbios_GetTime( void );
U16				Xbios_Giacces( const U16 aData, const U16 aRegister );
S32				Xbios_Gpio( const S16 aMode, const S16 aData );

void			Xbios_Ikbdws( const U16 aLen, const U8 * apBuffer );
void			Xbios_Initmous( const U16 aMode, const void * apParam, void (*afHandler)(void) );
sXbiosIoRec *	Xbios_Iorec( const U16 aDev );

void			Xbios_Jdisinit( const U16 aIntno );
void			Xbios_Jenabint( const U16 aIntno );

sXbiosKbdVecs *	Xbios_Kbdvbase( void );
S16				Xbios_Kbrate( const S16 aDelay, const S16 aRate );
sXbiosKeyTab *	Xbios_Keytbl( const char * apNormal, const char * apShift, const char * apCaps );

S32				Xbios_Locksnd( void );
void *			Xbios_Logbase( void );

void			Xbios_Metainit( sXbiosMetaInfo * apMeta );
void			Xbios_Mfpint( const U16 aIntNo, const void (*afVector)(void) );
void			Xbios_Midiws( const U16 aCount, const char * apBuffer );

S16				Xbios_NVMaccess( const U16 aOp, const U16 aStart, const U16 aCount, char * apBuffer );

void			Xbios_Offgibit( const U16 aMask );
void			Xbios_Ongibit( const U16 aMask );

void *			Xbios_Physbase( void );
void			Xbios_Protobt( const void * apBuffer, const U32 aSerial, const U16 aType, const U16 aExecFlag );
S16				Xbios_Prtblk( const sXbiosPrtBlock * apBlock );
void			Xbios_Puntaes( void );
U32				Xbios_Random( void );

U32				Xbios_Rsconf( const U16 aSpeed, const U16 aFlow, const U16 aUcr, const U16 aRsr, const U16 aTsr, const U16 aScr );

void			Xbios_Scrdmp( void );
S32				Xbios_SetBuffer( const U16 aMode, const void * pStart, const void * pEnd );
S16				Xbios_Setcolor( void );
S32				Xbios_Setinterrupt( const U16 aMode, const U16 aCause );
S32				Xbios_Setmode( const U16 aMode );
S32				Xbios_Setmontracks( const U16 aMode );
void			Xbios_Setpalette( const U16 * apPal );
S16				Xbios_Setprt( const S16 aNew );
void			Xbios_Setscreen( void * pLogic, void * pPhysic, const U16 aMode );
void			Xbios_Settime( const U32 aTime );
S32				Xbios_Settracks( const U16 aPlayTracks, const U16 aRecTracks );
S32				Xbios_Sndstatus( const U16 aReset );
S32				Xbios_Soundcmd( const U16 aMode, const U16 aData );
void *			Xbios_Ssbrk( const U16 aLen );
S32				Xbios_Supexec( void (*afFunc)(void) );

S32				Xbios_Unlocksnd( void );

U16				Xbios_Vgetmonitor( void );
void			Xbios_Vgetrgb( const U16 aIndex, const U16 aCount, U32 * apRGB );
S32				Xbios_Vgetsize( const U16 aMode );
void			Xbios_VsetMask( const U32 aOrMask, const U32 aAndMask, const U16 aOverlay );
S16				Xbios_VsetMode( const U16 aMode );
void			Xbios_VsetScreen( void * apLogic, void * apPhysic, const U16 aMode, const U16 aModeCode );
void			Xbios_VsetSync( const U16 aExternal );
void			Xbios_Vsync( void );
S16				Xbios_WavePlay( const U16 aFlags, const U32 aRate, void * apSample, const U32 aLen );
void			Xbios_Xbtimer( const U16 aTimer, const U16 aControl, const U16 aData, void (*afHandler)(void) );


/* ################################################################################ */

#endif	/*	INCLUDED_XBIOS_H */