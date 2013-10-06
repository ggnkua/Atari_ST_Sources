/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: MFP.C
::
:: MFP chip routines
::
:: [c] 2001 Reservoir Gods
::
:: Notes:
:: MFP Clock Frequency = 2457600
:: to make a 200hz clock:
:: control = %101 (/64)
:: data    = (2457600/(64*200)) =192
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"MFP.H"
#include	<GODLIB\SYSTEM\SYSTEM.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U16		Instruction;
	void	(*Func)(void);
} sMfpJumpLong;


/* ###################################################################################
#  VARIABLES
################################################################################### */

sMfpRegisterDump		gMfpRegisterDump;
extern	sMfpJumpLong	gMfpStcOldJump;
extern	sMfpJumpLong	gMfpStcNewJump;
extern	U8				gMfpNewEnableFlag;
extern	sTime			gMfpStcTime;
extern	U32				gMfpStcCounter;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	void	Mfp_SaveRegisters( sMfpRegisterDump * apDump );
extern	void	Mfp_RestoreRegisters( sMfpRegisterDump * apDump );
extern	void	Mfp_InstallStandardTimerC( void );


/* ###################################################################################
#  FUNCTIONS
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Mfp_Init( void )
* ACTION   : inits mfp
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Mfp_Init()
{
	Mfp_SaveRegisters( &gMfpRegisterDump );
	Mfp_InstallStandardTimerC();
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Mfp_DeInit( void )
* ACTION   : deinits mfp
* CREATION : 24.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Mfp_DeInit()
{
	Mfp_RestoreRegisters( &gMfpRegisterDump );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Mfp_GetpTime( void )
* ACTION   : Mfp_GetpTime
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

sTime *	Mfp_GetpTime( void )
{
	return( &gMfpStcTime );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Mfp_SetTime( sTime * apTime )
* ACTION   : Mfp_SetTime
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Mfp_SetClock( sTime * apTime )
{
	gMfpStcTime = *apTime;
}



/*-----------------------------------------------------------------------------------*
* FUNCTION : Mfp_GetCounter200hz( void )
* ACTION   : Mfp_GetCounter200hz
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

U32	Mfp_GetCounter200hz( void )
{
	return( gMfpStcCounter );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Mfp_GetpSavedRegisters( void )
* ACTION   : Mfp_GetpSavedRegisters
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

sMfpRegisterDump *	Mfp_GetpSavedRegisters( void )
{
	return( &gMfpRegisterDump );
}


/* ################################################################################ */
