/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"XBIOS.H"


/* ###################################################################################
#  ENUM
################################################################################### */

enum
{
	eXBIOS_INITMOUS                =  0,
	eXBIOS_SSBRK                   =  1,
	eXBIOS_PHYSBASE                =  2,
	eXBIOS_LOGBASE                 =  3,
	eXBIOS_GETREZ                  =  4,
	eXBIOS_SETSCREEN               =  5,
	eXBIOS_VSETSCREEN              =  5,
	eXBIOS_SETPALETTE              =  6,
	eXBIOS_SETCOLOR                =  7,
	eXBIOS_FLOPRD                  =  8,
	eXBIOS_FLOPWR                  =  9,
	eXBIOS_FLOPFMT                 = 10,
	eXBIOS_DBMSG                   = 11,
	eXBIOS_MIDIWS                  = 12,
	eXBIOS_MFPINT                  = 13,
	eXBIOS_IOREC                   = 14,
	eXBIOS_RSCONF                  = 15,
	eXBIOS_KEYTBL                  = 16,
	eXBIOS_RANDOM                  = 17,
	eXBIOS_PROTOBT                 = 18,
	eXBIOS_FLOPVER                 = 19,
	eXBIOS_SCRDMP                  = 20,
	eXBIOS_CURSCONF                = 21,
	eXBIOS_SETTIME                 = 22,
	eXBIOS_GETTIME                 = 23,
	eXBIOS_BIOSKEYS                = 24,
	eXBIOS_IKBDWS                  = 25,
	eXBIOS_JDISINIT                = 26,
	eXBIOS_JENABINT                = 27,
	eXBIOS_GIACCESS                = 28,
	eXBIOS_OFFGIBIT                = 29,
	eXBIOS_ONGIBIT                 = 30,
	eXBIOS_XBTIMER                 = 31,
	eXBIOS_DOSOUND                 = 32,
	eXBIOS_SETPRT                  = 33,
	eXBIOS_KBDVBASE                = 34,
	eXBIOS_KBRATE                  = 35,
	eXBIOS_PRTBLK                  = 36,
	eXBIOS_VSYNC                   = 37,
	eXBIOS_SUPEXEC                 = 38,
	eXBIOS_PUNTAES                 = 39,
	eXBIOS_FLOPRATE                = 41,
	eXBIOS_DMAREAD                 = 42,
	eXBIOS_DMAWRITE                = 43,
	eXBIOS_BCONMAP                 = 44,
	eXBIOS_NVMACCESS               = 46,
	eXBIOS_METAINIT                = 48,
	eXBIOS_BLITMODE                = 64,
	eXBIOS_ESETSHIFT               = 80,
	eXBIOS_EGETSHIFT               = 81,
	eXBIOS_ESETBANK                = 82,
	eXBIOS_ESETCOLOR               = 83,
	eXBIOS_ESETPALETTE             = 84,
	eXBIOS_EGETPALETTE             = 85,
	eXBIOS_ESETGRAY                = 86,
	eXBIOS_ESETSMEAR               = 87,
	eXBIOS_VSETMODE                = 88,
	eXBIOS_VGETMONITOR             = 89,
	eXBIOS_VSETSYNC                = 90,
	eXBIOS_VGETSIZE                = 91,
	eXBIOS_VSETMASK                = 92,
	eXBIOS_VSETRGB                 = 93,
	eXBIOS_VGETRGB                 = 94,
	eXBIOS_DSPDOBLOCK              = 96,
	eXBIOS_DSPBLKHANDSHAKE         = 97,
	eXBIOS_DSPBLKUNPACKED          = 98,
	eXBIOS_DSPINSTREAM             = 99,
	eXBIOS_DSPOUTSTREAM            = 100,
	eXBIOS_DSPIOSTREAM             = 101,
	eXBIOS_DSPREMOVEINTERRUPTS     = 102,
	eXBIOS_DSPGETWORDSIZE          = 103,
	eXBIOS_DSPLOCK                 = 104,
	eXBIOS_DSPUNLOCK               = 105,
	eXBIOS_DSPAVAILABLE            = 106,
	eXBIOS_DSPRESERVE              = 107,
	eXBIOS_DSPLOADPROG             = 108,
	eXBIOS_DSPEXECPROG             = 109,
	eXBIOS_DSPEXECBOOT             = 110,
	eXBIOS_DSPLODTOBINARY          = 111,
	eXBIOS_DSPTRIGGERHC            = 112,
	eXBIOS_DSPREQUESTUNIQUEABILITY = 113,
	eXBIOS_DSPGETPROGABILITY       = 114,
	eXBIOS_DSPFLUSHSUBROUTINES     = 115,
	eXBIOS_DSPLOADSUBROUTINE       = 116,
	eXBIOS_DSPINQSUBRABILITY       = 117,
	eXBIOS_DSPRUNSUBROUTINE        = 118,
	eXBIOS_DSPHF0                  = 119,
	eXBIOS_DSPHF1                  = 120,
	eXBIOS_DSPHF2                  = 121,
	eXBIOS_DSPHF3                  = 122,
	eXBIOS_DSPBLKWORDS             = 123,
	eXBIOS_DSPBLKBYTES             = 124,
	eXBIOS_DSPHSTAT                = 125,
	eXBIOS_DSPSETVECTORS           = 126,
	eXBIOS_DSPMULTBLOCKS           = 127,
	eXBIOS_LOCKSND                 = 128,
	eXBIOS_UNLOCKSND               = 129,
	eXBIOS_SOUNDCMD                = 130,
	eXBIOS_SETBUFFER               = 131,
	eXBIOS_SETMODE                 = 132,
	eXBIOS_SETTRACKS               = 133,
	eXBIOS_SETMONTRACKS            = 134,
	eXBIOS_SETINTERRUPT            = 135,
	eXBIOS_BUFFOPER                = 136,
	eXBIOS_DSPTRISTATE             = 137,
	eXBIOS_GPIO                    = 138,
	eXBIOS_DEVCONNECT              = 139,
	eXBIOS_SNDSTATUS               = 140,
	eXBIOS_BUFFPTR                 = 141,
	eXBIOS_WAVEPLAY                = 165
};


/* ###################################################################################
#  DATA
################################################################################### */


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	S32	Xbios_Call( const S16 aOp );
extern	S32	Xbios_Call_L( const S16 aOp, const S32 aL0 );
extern	S32	Xbios_Call_P( const S16 aOp, const void * ap0 );
extern	S32	Xbios_Call_W( const S16 aOp, const S16 aW0 );
extern	S32	Xbios_Call_LL( const S16 aOp, const S32 aL0, const S32 aL1 );
extern	S32	Xbios_Call_PP( const S16 aOp, const void * ap0, const void * ap1 );
extern	S32	Xbios_Call_WP( const S16 aOp, const S16 aW0, const void * ap0 );
extern	S32	Xbios_Call_WW( const S16 aOp, const S16 aW0, const S16 aW1 );
extern	S32	Xbios_Call_LLW( const S16 aOp, const S32 aL0, const S32 aL1, const S16 aW0 );
extern	S32	Xbios_Call_WWL( const S16 aOp, const S16 aW0, const S16 aW1, const S32 aL0 );
extern	S32	Xbios_Call_WWP( const S16 aOp, const S16 aW0, const S16 aW1, const void * ap0 );
extern	S32	Xbios_Call_PLW( const S16 aOp, const void * ap0, const S32 aL0, const S16 aW0 );
extern	S32	Xbios_Call_PPP( const S16 aOp, const void * ap0, const void * ap1, const void * ap2 );
extern	S32	Xbios_Call_PPW( const S16 aOp, const void * ap0, const void * ap1, const S16 aW0 );
extern	S32	Xbios_Call_PWP( const S16 aOp, const void * ap0, const S16 aW0, const void * ap1 );
extern	S32	Xbios_Call_WPP( const S16 aOp, const S16 aW0, const void * ap0, const void * ap1 );
extern	S32	Xbios_Call_WWWP( const S16 aOp, const S16 aW0, const S16 aW1, const S16 aW2, const void * ap0 );
extern	S32	Xbios_Call_WLPL( const S16 aOp, const S16 aW0, const S32 aL0, const void * ap0, const S32 aL1 );
extern	S32	Xbios_Call_LLPP( const S16 aOp, const S32 aL0, const S32 aL1, const void * ap0, const void * ap1 );
extern	S32	Xbios_Call_LWPW( const S16 aOp, const S32 aL0, const S16 aW0, const void * ap0, const S16 aW1 );
extern	S32	Xbios_Call_PLLP( const S16 aOp, const void * ap0, const S32 aL0, const S32 aL1, const void * ap1 );
extern	S32	Xbios_Call_PLPL( const S16 aOp, const void * ap0, const S32 aL0, const void * ap1, const S32 aL1 );
extern	S32	Xbios_Call_PLWW( const S16 aOp, const void * ap0, const S32 aL0, const S16 aW0, const S16 aW1 );
extern	S32	Xbios_Call_PPWW( const S16 aOp, const void * ap0, const void * ap1, const S16 aW0, const S16 aW1 );
extern	S32	Xbios_Call_WWWWW( const S16 aOp, const S16 aW0, const S16 aW1, const S16 aW2, const S16 aW3, const S16 aW4 );
extern	S32	Xbios_Call_WWWWWW( const S16 aOp, const S16 aW0, const S16 aW1, const S16 aW2, const S16 aW3, const S16 aW4, const S16 aW5 );
extern	S32	Xbios_Call_PPLLLP( const S16 aOp, const void * ap0,  const void * ap1, const S32 aL0, const S32 aL1, const S32 aL2, const void * ap2 );
extern	S32	Xbios_Call_PLWWWWW( const S16 aOp, const void * ap0, const S32 aL0, const S16 aW0, const S16 aW1, const S16 aW2, const S16 aW3, const S16 aW4 );
extern	S32	Xbios_Call_PLWWWWWW( const S16 aOp, const void * ap0, const S32 aL0, const S16 aW0, const S16 aW1, const S16 aW2, const S16 aW3, const S16 aW4, const S16 aW5 );
extern	S32	Xbios_Call_PPWWWWWLW( const S16 aOp, const void * ap0,  const void * ap1, const S16 aW0,  const S16 aW1,  const S16 aW2,  const S16 aW3,  const S16 aW4, const S32 aL0, const S16 aW5 );


/* ###################################################################################
#  CODE
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Bconmap( const S16 aDevNo )
* ACTION   : Xbios_Bconmap
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Bconmap( const S16 aDevNo )
{
	return( Xbios_Call_W( eXBIOS_BCONMAP, aDevNo ) ); 	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_BiosKeys( void )
* ACTION   : Xbios_BiosKeys
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_BiosKeys( void )
{
	Xbios_Call( eXBIOS_BIOSKEYS );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Blitmode( const S16 aMode )
* ACTION   : Xbios_Blitmode
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Blitmode( const S16 aMode )
{
	return( (S16)Xbios_Call_W( eXBIOS_BLITMODE, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Buffptr( const sXbiosBufPtr * apBuffer )
* ACTION   : Xbios_Buffptr
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Buffptr( const sXbiosBufPtr * apBuffer )
{
	return( Xbios_Call_P( eXBIOS_BUFFPTR, apBuffer ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Cursconf( const S16 aMode,const S16 aRate )
* ACTION   : Xbios_Cursconf
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Cursconf( const S16 aMode,const S16 aRate )
{
	return( (S16)Xbios_Call_WW( eXBIOS_CURSCONF, aMode, aRate ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Dbmsg( const S16 aRsrved,const S16 aMsgNum,const S32 aMsgArg )
* ACTION   : Xbios_Dbmsg
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Dbmsg( const S16 aRsrved,const S16 aMsgNum,const S32 aMsgArg )
{
	Xbios_Call_WWL( eXBIOS_DBMSG, aRsrved, aMsgNum, aMsgArg );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Devconnect( const S16 aSrc,const S16 aDst,const S16 aClk,const S16 aPreScale,const S16 aProtocol )
* ACTION   : Xbios_Devconnect
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Devconnect( const S16 aSrc,const S16 aDst,const S16 aClk,const S16 aPreScale,const S16 aProtocol )
{
	return( Xbios_Call_WWWWW( eXBIOS_DEVCONNECT, aSrc, aDst, aClk, aPreScale, aProtocol ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Dmaread( const S32 aSector,const S16 aCount,void * apBuffer,const S16 aDev )
* ACTION   : Xbios_Dmaread
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Dmaread( const S32 aSector,const S16 aCount,void * apBuffer,const S16 aDev )
{
	return( Xbios_Call_LWPW( eXBIOS_DMAREAD, aSector, aCount, apBuffer, aDev ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Dmawrite( const S32 aSector,const S16 aCount,void * apBuffer,const S16 aDev )
* ACTION   : Xbios_Dmawrite
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Dmawrite( const S32 aSector,const S16 aCount,void * apBuffer,const S16 aDev )
{
	return( Xbios_Call_LWPW( eXBIOS_DMAWRITE, aSector, aCount, apBuffer, aDev ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Dosound( const char * apCmdList )
* ACTION   : Xbios_Dosound
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Dosound( const char * apCmdList )
{
	Xbios_Call_P( eXBIOS_DOSOUND, apCmdList );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspAvailable( const S32 * apXavail,const S32 * apYavail )
* ACTION   : Xbios_DspAvailable
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspAvailable( const S32 * apXavail,const S32 * apYavail )
{
	Xbios_Call_PP( eXBIOS_DSPAVAILABLE, apXavail, apYavail );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspBlkBytes( const U8 * apSrc,const S32 aSrcSize,U8 * apDst,const S32 aDstSize )
* ACTION   : Xbios_DspBlkBytes
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspBlkBytes( const U8 * apSrc,const S32 aSrcSize,U8 * apDst,const S32 aDstSize )
{
	Xbios_Call_PLPL( eXBIOS_DSPBLKBYTES, apSrc, aSrcSize, apDst, aDstSize );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspBlkHandShake( const U8 * apSrc,const S32 aSrcSize,U8 * apDst,const S32 aDstSize )
* ACTION   : Xbios_DspBlkHandShake
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspBlkHandShake( const U8 * apSrc,const S32 aSrcSize,U8 * apDst,const S32 aDstSize )
{
	Xbios_Call_PLPL( eXBIOS_DSPBLKHANDSHAKE, apSrc, aSrcSize, apDst, aDstSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspBlkUnpacked( const U32 * apSrc,const S32 aSrcSize,U32 * apDst,const S32 aDstSize )
* ACTION   : Xbios_DspBlkUnpacked
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspBlkUnpacked( const U32 * apSrc,const S32 aSrcSize,U32 * apDst,const S32 aDstSize )
{
	Xbios_Call_PLPL( eXBIOS_DSPBLKUNPACKED, apSrc, aSrcSize, apDst, aDstSize );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspBlkWords( const U16 * apSrc,const S32 aSrcSize,U16 * apDst,const S32 aDstSize )
* ACTION   : Xbios_DspBlkWords
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspBlkWords( const U16 * apSrc,const S32 aSrcSize,U16 * apDst,const S32 aDstSize )
{
	Xbios_Call_PLPL( eXBIOS_DSPBLKWORDS, apSrc, aSrcSize, apDst, aDstSize );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspDoBlock( const U8 * apSrc,const S32 aSrcSize,U8 * apDst,const S32 aDstSize )
* ACTION   : Xbios_DspDoBlock
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspDoBlock( const U8 * apSrc,const S32 aSrcSize,U8 * apDst,const S32 aDstSize )
{
	Xbios_Call_PLPL( eXBIOS_DSPDOBLOCK, apSrc, aSrcSize, apDst, aDstSize );			
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspExecBoot( const U8 * apCode,const U32 aCodeSize,const S16 aAbility )
* ACTION   : Xbios_DspExecBoot
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspExecBoot( const U8 * apCode,const U32 aCodeSize,const S16 aAbility )
{
	Xbios_Call_PLW( eXBIOS_DSPEXECBOOT, apCode, aCodeSize, aAbility );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspExecProg( const U8 * apCode,const U32 aCodeSize,const S16 aAbility )
* ACTION   : Xbios_DspExecProg
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspExecProg( const U8 * apCode,const U32 aCodeSize,const S16 aAbility )
{
	Xbios_Call_PLW( eXBIOS_DSPEXECPROG, apCode, aCodeSize, aAbility );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspFlushSubroutines( void )
* ACTION   : Xbios_DspFlushSubroutines
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspFlushSubroutines( void )
{
	Xbios_Call( eXBIOS_DSPFLUSHSUBROUTINES );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspGetProgAbility( void )
* ACTION   : Xbios_DspGetProgAbility
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspGetProgAbility( void )
{
	return( (S16)Xbios_Call( eXBIOS_DSPGETPROGABILITY ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspGetWordSize( void )
* ACTION   : Xbios_DspGetWordSize
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspGetWordSize( void )
{
	return( (S16)Xbios_Call( eXBIOS_DSPGETWORDSIZE ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspHf0( const S16 aFlag )
* ACTION   : Xbios_DspHf0
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspHf0( const S16 aFlag )
{
	return( (S16)Xbios_Call_W( eXBIOS_DSPHF0, aFlag ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspHf1( const S16 aFlag )
* ACTION   : Xbios_DspHf1
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspHf1( const S16 aFlag )
{
	return( (S16)Xbios_Call_W( eXBIOS_DSPHF1, aFlag ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspHf2( const S16 aFlag )
* ACTION   : Xbios_DspHf2
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspHf2( const S16 aFlag )
{
	return( (S16)Xbios_Call_W( eXBIOS_DSPHF2, aFlag ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspHf3( const S16 aFlag )
* ACTION   : Xbios_DspHf3
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspHf3( const S16 aFlag )
{
	return( (S16)Xbios_Call_W( eXBIOS_DSPHF3, aFlag ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspHstat( void )
* ACTION   : Xbios_DspHstat
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U8	Xbios_DspHstat( void )
{
	return( (U8)Xbios_Call( eXBIOS_DSPHSTAT ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspInqSubrAbility( const S16 aAbility )
* ACTION   : Xbios_DspInqSubrAbility
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspInqSubrAbility( const S16 aAbility )
{
	return( (S16)Xbios_Call_W( eXBIOS_DSPINQSUBRABILITY, aAbility ) );		
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspInStream( const U8 * apSrc,const U32 aBlockSize,const U32 aBlockCount,U32 * apBlocksDone )
* ACTION   : Xbios_DspInStream
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspInStream( const U8 * apSrc,const U32 aBlockSize,const U32 aBlockCount,U32 * apBlocksDone )
{
	Xbios_Call_PLLP( eXBIOS_DSPINSTREAM, apSrc, aBlockSize, aBlockCount, apBlocksDone );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspIOStream( const U8 * apSrc,U8 * apDst,const U32 aSrcBlkSize,const U32 aDstBlkSize,const U32 aBlkCount,U32 * apBlocksDone )
* ACTION   : Xbios_DspIOStream
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspIOStream( const U8 * apSrc,U8 * apDst,const U32 aSrcBlkSize,const U32 aDstBlkSize,const U32 aBlkCount,U32 * apBlocksDone )
{
	Xbios_Call_PPLLLP( eXBIOS_DSPIOSTREAM, apSrc, apDst, aSrcBlkSize, aDstBlkSize, aBlkCount, apBlocksDone );
	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspLoadProg( const char * apFile,const S16 aAbility,U8 * apBuffer )
* ACTION   : Xbios_DspLoadProg
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspLoadProg( const char * apFile,const S16 aAbility,U8 * apBuffer )
{
	Xbios_Call_PWP( eXBIOS_DSPLOADPROG, apFile, aAbility, apBuffer );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspLoadSubroutine( const U8 * apCode,const U32 aSize,const S16 aAbility )
* ACTION   : Xbios_DspLoadSubroutine
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspLoadSubroutine( const U8 * apCode,const U32 aSize,const S16 aAbility )
{
	return( (S16)Xbios_Call_PLW( eXBIOS_DSPLOADSUBROUTINE, apCode, aSize, aAbility ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspLock( void )
* ACTION   : Xbios_DspLock
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspLock( void )
{
	return( (S16)Xbios_Call( eXBIOS_DSPLOCK ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspLodToBinary( const char * apFile,U8 * apCode )
* ACTION   : Xbios_DspLodToBinary
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_DspLodToBinary( const char * apFile,U8 * apCode )
{
	return( Xbios_Call_PP( eXBIOS_DSPLODTOBINARY, apFile, apCode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspMultBlocks( const U32 aSendBlockCount,const U32 aRecvBlockCount,const sXbiosDspBlock * apSendBlocks,sXbiosDspBlock * apRecvBlocks )
* ACTION   : Xbios_DspMultBlocks
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspMultBlocks( const U32 aSendBlockCount,const U32 aRecvBlockCount,const sXbiosDspBlock * apSendBlocks,sXbiosDspBlock * apRecvBlocks )
{
	Xbios_Call_LLPP( eXBIOS_DSPMULTBLOCKS, aSendBlockCount, aRecvBlockCount, apSendBlocks, apRecvBlocks );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspOutStream( U8 * pData,const U32 aBlockSize,const U32 aBlockCount,U32 * apBlocksDone )
* ACTION   : Xbios_DspOutStream
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspOutStream( U8 * apData,const U32 aBlockSize,const U32 aBlockCount,U32 * apBlocksDone )
{
	Xbios_Call_PLLP( eXBIOS_DSPOUTSTREAM, apData, aBlockSize, aBlockCount, apBlocksDone );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspRemoveInterrupts( const S16 aMask )
* ACTION   : Xbios_DspRemoveInterrupts
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspRemoveInterrupts( const S16 aMask )
{
	Xbios_Call_W( eXBIOS_DSPREMOVEINTERRUPTS, aMask );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspRequestUniqueAbility( void )
* ACTION   : Xbios_DspRequestUniqueAbility
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspRequestUniqueAbility( void )
{
	return( (S16)Xbios_Call( eXBIOS_DSPREQUESTUNIQUEABILITY ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspReserve( const U32 aReserveX,const U32 aReserveY )
* ACTION   : Xbios_DspReserve
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspReserve( const U32 aReserveX,const U32 aReserveY )
{
	return( (S16)Xbios_Call_LL( eXBIOS_DSPRESERVE, aReserveX, aReserveY ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspRunSubroutine( const S16 aHandle )
* ACTION   : Xbios_DspRunSubroutine
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_DspRunSubroutine( const S16 aHandle )
{
	return( (S16)Xbios_Call_W( eXBIOS_DSPRUNSUBROUTINE, aHandle ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspSetVectors( void (*afRecv)(void),void (*afTrans)(void) )
* ACTION   : Xbios_DspSetVectors
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspSetVectors( void (*afRecv)(void),void (*afTrans)(void) )
{
	Xbios_Call_PP( eXBIOS_DSPSETVECTORS, afRecv, afTrans );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspTriggerHC( const S16 aVec )
* ACTION   : Xbios_DspTriggerHC
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspTriggerHC( const S16 aVec )
{
	Xbios_Call_W( eXBIOS_DSPTRIGGERHC, aVec );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspUnlock( void )
* ACTION   : Xbios_DspUnlock
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_DspUnlock( void )
{
	Xbios_Call( eXBIOS_DSPUNLOCK );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_DspTristate( const S16 aDspXmit,const S16 aDspRec )
* ACTION   : Xbios_DspTristate
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_DspTristate( const S16 aDspXmit,const S16 aDspRec )
{
	return( Xbios_Call_WW( eXBIOS_DSPTRISTATE, aDspXmit, aDspRec ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_EgetPalette( const U16 aStart,const U16 aCount,U16 * apPal )
* ACTION   : Xbios_EgetPalette
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_EgetPalette( const U16 aStart,const U16 aCount,U16 * apPal )
{
	Xbios_Call_WWP( eXBIOS_EGETPALETTE, aStart, aCount, apPal );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_EgetShift( void )
* ACTION   : Xbios_EgetShift
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16	Xbios_EgetShift( void )
{
	return( (U16)Xbios_Call( eXBIOS_EGETSHIFT ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_EsetBank( const S16 aBank )
* ACTION   : Xbios_EsetBank
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_EsetBank( const S16 aBank )
{
	return( (S16)Xbios_Call_W( eXBIOS_ESETBANK, aBank ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_EsetColor( const U16 aIndex,const U16 aColour )
* ACTION   : Xbios_EsetColor
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_EsetColor( const U16 aIndex,const U16 aColour )
{
	return( (S16)Xbios_Call_WW( eXBIOS_ESETCOLOR, aIndex, aColour ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_EsetGray( const S16 aMode )
* ACTION   : Xbios_EsetGray
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_EsetGray( const S16 aMode )
{
	return( (S16)Xbios_Call_W( eXBIOS_ESETGRAY, aMode ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_EsetPalette( const U16 aStart,const U16 aCount,const U16 * apPal )
* ACTION   : Xbios_EsetPalette
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_EsetPalette( const U16 aStart,const U16 aCount,const U16 * apPal )
{
	Xbios_Call_WWP( eXBIOS_ESETPALETTE, aStart, aCount, apPal );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_EsetShift( const S16 aMode )
* ACTION   : Xbios_EsetShift
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_EsetShift( const S16 aMode )
{
	return( (S16)Xbios_Call_W( eXBIOS_ESETSHIFT, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_EsetSmear( const S16 aMode )
* ACTION   : Xbios_EsetSmear
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_EsetSmear( const S16 aMode )
{
	return( (S16)Xbios_Call_W( eXBIOS_ESETSMEAR, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Flopfmt( const void * apBuffer,const U16 * apSke,const U16 aDev,const U16 aSpt,const U16 aTrack,const U16 aSide,const U16 aIntlv,const U32 aMagic,const U16 aVirgin )
* ACTION   : Xbios_Flopfmt
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Flopfmt( const void * apBuffer,const U16 * apSkew,const U16 aDev,const U16 aSpt,const U16 aTrack,const U16 aSide,const U16 aIntlv,const U32 aMagic,const U16 aVirgin )
{
	return( (S16)Xbios_Call_PPWWWWWLW( eXBIOS_FLOPFMT, apBuffer, apSkew, aDev, aSpt, aTrack, aSide, aIntlv, aMagic, aVirgin ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Floprate( const U16 aDev,const U16 aRate )
* ACTION   : Xbios_Floprate
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Floprate( const U16 aDev,const U16 aRate )
{
	return( (S16)Xbios_Call_WW( eXBIOS_FLOPRATE, aDev, aRate ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Floprd( void * apBuffer,const U32 aReserved,const U16 aDev,const U16 aSector,const U16 aTrack,const U16 aSide,const aCount )
* ACTION   : Xbios_Floprd
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Floprd( void * apBuffer,const U32 aReserved,const U16 aDev,const U16 aSector,const U16 aTrack,const U16 aSide,const aCount )
{
	return( (S16)Xbios_Call_PLWWWWW( eXBIOS_FLOPRD, apBuffer, aReserved, aDev, aSector, aTrack, aSide, aCount ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Flopver( const void * apBuffer,const U32 aReserved,const U16 aDev,const U16 aSector,const U16 aTrack,const U16 aSide,const aCount )
* ACTION   : Xbios_Flopver
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Flopver( const void * apBuffer,const U32 aReserved,const U16 aDev,const U16 aSector,const U16 aTrack,const U16 aSide,const aCount )
{
	return( (S16)Xbios_Call_PLWWWWW( eXBIOS_FLOPVER, apBuffer, aReserved, aDev, aSector, aTrack, aSide, aCount ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Flopwr( const void * apBuffer,const U32 aReserved,const U16 aDev,const U16 aSector,const U16 aTrack,const U16 aSide,const aCount )
* ACTION   : Xbios_Flopwr
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Flopwr( const void * apBuffer,const U32 aReserved,const U16 aDev,const U16 aSector,const U16 aTrack,const U16 aSide,const aCount )
{
	return( (S16)Xbios_Call_PLWWWWW( eXBIOS_FLOPWR, apBuffer, aReserved, aDev, aSector, aTrack, aSide, aCount ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_GetRez( void )
* ACTION   : Xbios_GetRez
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16	Xbios_GetRez( void )
{
	return( (U16)Xbios_Call( eXBIOS_GETREZ ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_GetTime( void )
* ACTION   : Xbios_GetTime
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32	Xbios_GetTime( void )
{
	return( Xbios_Call( eXBIOS_GETTIME ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Giacces( const U16 aData,const U16 aRegister )
* ACTION   : Xbios_Giacces
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16	Xbios_Giacces( const U16 aData,const U16 aRegister )
{
	return( (U16)Xbios_Call_WW( eXBIOS_GIACCESS, aData, aRegister ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Gpio( const S16 aMode,const S16 aData )
* ACTION   : Xbios_Gpio
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Gpio( const S16 aMode,const S16 aData )
{
	return( Xbios_Call_WW( eXBIOS_GPIO, aMode, aData ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Ikbdws( const U16 aLen,const U8 * apBuffer )
* ACTION   : Xbios_Ikbdws
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Ikbdws( const U16 aLen,const U8 * apBuffer )
{
	Xbios_Call_WP( eXBIOS_IKBDWS, aLen, apBuffer );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Initmous( const U16 aMode,const void * apParam,void (*afHandler)(void) )
* ACTION   : Xbios_Initmous
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Initmous( const U16 aMode,const void * apParam,void (*afHandler)(void) )
{
	Xbios_Call_WPP( eXBIOS_INITMOUS, aMode, apParam, afHandler );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Iorec( const U16 aDev )
* ACTION   : Xbios_Iorec
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

sXbiosIoRec *	Xbios_Iorec( const U16 aDev )
{
	return( (sXbiosIoRec*)Xbios_Call_W( eXBIOS_IOREC, aDev ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Jdisinit( const U16 aIntno )
* ACTION   : Xbios_Jdisinit
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Jdisinit( const U16 aIntno )
{
	Xbios_Call_W( eXBIOS_JDISINIT, aIntno );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Jenabint( const U16 aIntno )
* ACTION   : Xbios_Jenabint
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Jenabint( const U16 aIntno )
{
	Xbios_Call_W( eXBIOS_JENABINT, aIntno );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Kbdvbase( void )
* ACTION   : Xbios_Kbdvbase
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

sXbiosKbdVecs *	Xbios_Kbdvbase( void )
{
	return( (sXbiosKbdVecs*)Xbios_Call( eXBIOS_KBDVBASE ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Kbrate( const S16 aDelay,const S16 aRate )
* ACTION   : Xbios_Kbrate
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Kbrate( const S16 aDelay,const S16 aRate )
{
	return( (S16)Xbios_Call_WW( eXBIOS_KBRATE, aDelay, aRate ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Keytbl( const char * apNormal,const char * apShift,const char * apCaps )
* ACTION   : Xbios_Keytbl
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

sXbiosKeyTab *	Xbios_Keytbl( const char * apNormal,const char * apShift,const char * apCaps )
{
	return( (sXbiosKeyTab*)Xbios_Call_PPP( eXBIOS_KEYTBL, apNormal, apShift, apCaps ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Locksnd( void )
* ACTION   : Xbios_Locksnd
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Locksnd( void )
{
	return( Xbios_Call( eXBIOS_LOCKSND ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Logbase( void )
* ACTION   : Xbios_Logbase
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void *	Xbios_Logbase( void )
{
	return( (void *)Xbios_Call( eXBIOS_LOGBASE ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Metainit( sXbiosMetaInfo * apMeta )
* ACTION   : Xbios_Metainit
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Metainit( sXbiosMetaInfo * apMeta )
{
	Xbios_Call_P( eXBIOS_METAINIT, apMeta );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Mfpint( const U16 aIntNo,const void (*afVector)(void) )
* ACTION   : Xbios_Mfpint
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Mfpint( const U16 aIntNo,const void (*afVector)(void) )
{
	Xbios_Call_WP( eXBIOS_MFPINT, aIntNo, afVector );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Midiws( const U16 aCount,const char * apBuffer )
* ACTION   : Xbios_Midiws
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Midiws( const U16 aCount,const char * apBuffer )
{
	Xbios_Call_WP( eXBIOS_MIDIWS, aCount, apBuffer );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_NVMaccess( const U16 aOp,const U16 aStart,const U16 aCount,char * apBuffer )
* ACTION   : Xbios_NVMaccess
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_NVMaccess( const U16 aOp,const U16 aStart,const U16 aCount,char * apBuffer )
{
	return( (S16)Xbios_Call_WWWP( eXBIOS_NVMACCESS, aOp, aStart, aCount, apBuffer ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Offgibit( const U16 aMask )
* ACTION   : Xbios_Offgibit
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Offgibit( const U16 aMask )
{
	Xbios_Call_W( eXBIOS_OFFGIBIT, aMask );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Ongibit( const U16 aMask )
* ACTION   : Xbios_Ongibit
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Ongibit( const U16 aMask )
{
	Xbios_Call_W( eXBIOS_ONGIBIT, aMask );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Physbase( void )
* ACTION   : Xbios_Physbase
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void *	Xbios_Physbase( void )
{
	return( (void *)Xbios_Call( eXBIOS_PHYSBASE ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Protobt( const void * apBuffer,const U32 aSerial,const U16 aType,const U16 aExecFlag )
* ACTION   : Xbios_Protobt
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Protobt( const void * apBuffer,const U32 aSerial,const U16 aType,const U16 aExecFlag )
{
	Xbios_Call_PLWW( eXBIOS_PROTOBT, apBuffer, aSerial, aType, aExecFlag );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Prtblk( const sXbiosPrtBlock * apBlock )
* ACTION   : Xbios_Prtblk
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Prtblk( const sXbiosPrtBlock * apBlock )
{
	return( (S16)Xbios_Call_P( eXBIOS_PRTBLK, apBlock ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Puntaes( void )
* ACTION   : Xbios_Puntaes
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Puntaes( void )
{
	Xbios_Call( eXBIOS_PUNTAES );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Random( void )
* ACTION   : Xbios_Random
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32		Xbios_Random( void )
{
	return( Xbios_Call( eXBIOS_RANDOM ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Rsconf( const U16 aSpeed,const U16 aFlow,const U16 aUcr,const U16 aRsr,const U16 aTsr,const U16 aScr )
* ACTION   : Xbios_Rsconf
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32	Xbios_Rsconf( const U16 aSpeed,const U16 aFlow,const U16 aUcr,const U16 aRsr,const U16 aTsr,const U16 aScr )
{
	return( Xbios_Call_WWWWWW( eXBIOS_RSCONF, aSpeed, aFlow, aUcr, aRsr, aTsr, aScr ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Scrdmp( void )
* ACTION   : Xbios_Scrdmp
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Scrdmp( void )
{
	Xbios_Call( eXBIOS_SCRDMP );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_SetBuffer( const U16 aMode,const void * pStart,const void * pEnd )
* ACTION   : Xbios_SetBuffer
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_SetBuffer( const U16 aMode,const void * apStart,const void * apEnd )
{
	return( Xbios_Call_WPP( eXBIOS_SETBUFFER, aMode, apStart, apEnd ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Setcolor( void )
* ACTION   : Xbios_Setcolor
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Setcolor( void )
{
	return( (S16)Xbios_Call( eXBIOS_SETCOLOR ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Setinterrupt( const U16 aMode,const U16 aCause )
* ACTION   : Xbios_Setinterrupt
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Setinterrupt( const U16 aMode,const U16 aCause )
{
	return( Xbios_Call_WW( eXBIOS_SETINTERRUPT, aMode, aCause ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Setmode( const U16 aMode )
* ACTION   : Xbios_Setmode
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Setmode( const U16 aMode )
{
	return( Xbios_Call_W( eXBIOS_SETMODE, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Setmontracks( const U16 aMode )
* ACTION   : Xbios_Setmontracks
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Setmontracks( const U16 aMode )
{
	return( Xbios_Call_W( eXBIOS_SETMONTRACKS, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Setpalette( const U16 * apPal )
* ACTION   : Xbios_Setpalette
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Setpalette( const U16 * apPal )
{
	Xbios_Call_P( eXBIOS_SETPALETTE, apPal );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Setprt( const S16 aNew )
* ACTION   : Xbios_Setprt
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_Setprt( const S16 aNew )
{
	return( (S16)Xbios_Call_W( eXBIOS_SETPRT, aNew ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Setscreen( void * pLogic,void * pPhysic,const U16 aMode )
* ACTION   : Xbios_Setscreen
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Setscreen( void * apLogic,void * apPhysic,const U16 aMode )
{
	Xbios_Call_PPW( eXBIOS_SETSCREEN, apLogic, apPhysic, aMode );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Settime( const U32 aTime )
* ACTION   : Xbios_Settime
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Settime( const U32 aTime )
{
	Xbios_Call_L( eXBIOS_SETTIME, aTime );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Settracks( const U16 aPlayTracks,const U16 aRecTracks )
* ACTION   : Xbios_Settracks
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Settracks( const U16 aPlayTracks,const U16 aRecTracks )
{
	return( Xbios_Call_WW( eXBIOS_SETTRACKS, aPlayTracks, aRecTracks ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Sndstatus( const U16 aReset )
* ACTION   : Xbios_Sndstatus
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Sndstatus( const U16 aReset )
{
	return( Xbios_Call_W( eXBIOS_SNDSTATUS, aReset ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Soundcmd( const U16 aMode,const U16 aData )
* ACTION   : Xbios_Soundcmd
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Soundcmd( const U16 aMode,const U16 aData )
{
	return( Xbios_Call_WW( eXBIOS_SOUNDCMD, aMode, aData ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Ssbrk( const U16 aLen )
* ACTION   : Xbios_Ssbrk
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void *	Xbios_Ssbrk( const U16 aLen )
{
	return( (void *)Xbios_Call_W( eXBIOS_SSBRK, aLen ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Supexec( void (*afFunc)(void) )
* ACTION   : Xbios_Supexec
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Supexec( void (*afFunc)(void) )
{
	return( Xbios_Call_P( eXBIOS_SUPEXEC, afFunc ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Unlocksnd( void )
* ACTION   : Xbios_Unlocksnd
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Unlocksnd( void )
{
	return( Xbios_Call( eXBIOS_UNLOCKSND ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Vgetmonitor( void )
* ACTION   : Xbios_Vgetmonitor
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U16	Xbios_Vgetmonitor( void )
{
	return( (U16)Xbios_Call( eXBIOS_VGETMONITOR ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Vgetrgb( const U16 aIndex,const U16 aCount,U32 * apRGB )
* ACTION   : Xbios_Vgetrgb
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Vgetrgb( const U16 aIndex,const U16 aCount,U32 * apRGB )
{
	Xbios_Call_WWP( eXBIOS_VGETRGB, aIndex, aCount, apRGB );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Vgetsize( const U16 aMode )
* ACTION   : Xbios_Vgetsize
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S32	Xbios_Vgetsize( const U16 aMode )
{
	return( Xbios_Call_W( eXBIOS_VGETSIZE, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_VsetMask( const U32 aOrMask,const U32 aAndMask,const U16 aOverlay )
* ACTION   : Xbios_VsetMask
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_VsetMask( const U32 aOrMask,const U32 aAndMask,const U16 aOverlay )
{
	Xbios_Call_LLW( eXBIOS_VSETMASK, aOrMask, aAndMask, aOverlay );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_VsetMode( const U16 aMode )
* ACTION   : Xbios_VsetMode
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_VsetMode( const U16 aMode )
{
	return( (S16)Xbios_Call_W( eXBIOS_VSETMODE, aMode ) );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_VsetScreen( void * apLogic,void * apPhysic,const U16 aMode,const U16 aModeCode )
* ACTION   : Xbios_VsetScreen
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_VsetScreen( void * apLogic,void * apPhysic,const U16 aMode,const U16 aModeCode )
{
	Xbios_Call_PPWW( eXBIOS_VSETSCREEN, apLogic, apPhysic, aMode, aModeCode );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_VsetSync( const U16 aExternal )
* ACTION   : Xbios_VsetSync
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_VsetSync( const U16 aExternal )
{
	Xbios_Call_W( eXBIOS_VSETSYNC, aExternal );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Vsync( void )
* ACTION   : Xbios_Vsync
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Vsync( void )
{
	Xbios_Call( eXBIOS_VSYNC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_WavePlay( const U16 aFlags,const U32 aRate,void * apSample,const U32 aLen )
* ACTION   : Xbios_WavePlay
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

S16	Xbios_WavePlay( const U16 aFlags,const U32 aRate,void * apSample,const U32 aLen )
{
	return( (S16)Xbios_Call_WLPL( eXBIOS_WAVEPLAY, aFlags, aRate, apSample, aLen ) );	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Xbios_Xbtimer( const U16 aTimer,const U16 aControl,const U16 aData,void (*afHandler)(void) )
* ACTION   : Xbios_Xbtimer
* CREATION : 03.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Xbios_Xbtimer( const U16 aTimer,const U16 aControl,const U16 aData,void (*afHandler)(void) )
{
	Xbios_Call_WWWP( eXBIOS_XBTIMER, aTimer, aControl, aData, afHandler );
}


/* ################################################################################ */
