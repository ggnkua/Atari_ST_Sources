#ifndef	INCLUDED_VBL_H
#define	INCLUDED_VBL_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>
#include	<GODLIB\MFP\MFP.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dVBL_MAX_CALLS	64


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U8		LockFlag;
	U8		TimerBScanLine;
	U16		HbiCounterStart;
	U16		HbiCounter;
	U16		CallCount;
	void	(*pHbi)();
	void	(*pTimerBFunc)();
	void	(*pVideoFunc)();
	void 	(*pCalls[ dVBL_MAX_CALLS ])();
} sVBL;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Vbl_Init( void );
void	Vbl_DeInit( void  );
U8		Vbl_AddCall( void (* apFunc)() );
U8		Vbl_RemoveCall( void (* apFunc)() );
U32		Vbl_GetCounter( void );
void	Vbl_WaitVbl( void );
void	Vbl_WaitVbls( const U16 aCount );
void	Vbl_InstallTimerB( sMfpTimer * apTimer );
void	Vbl_InstallHbi( sMfpTimer * apTimer );
sVBL *	Vbl_GetpVbl( void );
void	Vbl_SetVideoFunc( void (* apFunc)() );


/* ################################################################################ */

#endif	/*	INCLUDED_VIDEO_H */