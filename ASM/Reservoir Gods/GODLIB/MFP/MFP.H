#ifndef	INCLUDED_MFP_H
#define	INCLUDED_MFP_H


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>
#include	<GODLIB\COOKIE\COOKIE.H>
#include	<GODLIB\CLOCK\CLOCK.H>


/* ###################################################################################
#  ENUMS
################################################################################### */

enum 
{
	eMFP_TIMER_A,
	eMFP_TIMER_B,
	eMFP_TIMER_C,
	eMFP_TIMER_D,
	
	eMFP_TIMER_LIMIT
};


enum
{
	eMFP_HANDLER_CENTRONICSBUSY,
	eMFP_HANDLER_RS232DCD,
	eMFP_HANDLER_RS232CTS,
	eMFP_HANDLER_BLITTERDONE,
	eMFP_HANDLER_TIMERD,
	eMFP_HANDLER_TIMERC,
	eMFP_HANDLER_IKBD,
	eMFP_HANDLER_FDC,
	eMFP_HANDLER_TIMERB,
	eMFP_HANDLER_SENDERROR,
	eMFP_HANDLER_SENDBUFFEREMPTY,
	eMFP_HANDLER_RECEIVEERROR,
	eMFP_HANDLER_RECEIVEBUFFERFULL,
	eMFP_HANDLER_TIMERA,
	eMFP_HANDLER_RS232RINGDETECT,
	eMFP_HANDLER_MONODETECT,

	eMFP_HANDLER_LIMIT
};


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef struct
{
	void	(*TimerFunc)(void);
	U16		Freq;
	U8		Mode;
	U8		Data;
	U8		Mask;
	U8		Enable;
} sMfpTimer;




typedef struct
{
	void	(*Handler[ eMFP_HANDLER_LIMIT ])( void );
	U8		Registers[ 0x30 ];
} sMfpRegisterDump;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void		Mfp_Init( void );
void		Mfp_DeInit( void );

void		Mfp_InstallTimerA( sMfpTimer * apTimer );
void		Mfp_InstallTimerB( sMfpTimer * apTimer );
void		Mfp_InstallTimerC( sMfpTimer * apTimer );
void		Mfp_InstallTimerD( sMfpTimer * apTimer );

void		Mfp_GetTimerA( sMfpTimer * apTimer );
void		Mfp_GetTimerB( sMfpTimer * apTimer );
void		Mfp_GetTimerC( sMfpTimer * apTimer );
void		Mfp_GetTimerD( sMfpTimer * apTimer );

void		Mfp_InstallGPI7( void (*apHandler)(void), U8 aPinLowHighFlag );

void		Mfp_HookIntoTimerC( sMfpTimer * apTimer );
void		Mfp_HookDisableTimerC( void );
void		Mfp_HookEnableTimerC( void );
void		Mfp_DisableSystemTimerC( void );

sTime *			Mfp_GetpTime( void );
void			Mfp_SetTime( sTime * apTime );
sMfpRegisterDump *		Mfp_GetpSavedRegisters( void );

U32			Mfp_GetCounter200hz( void );


/* ################################################################################ */

#endif	/* INCLUDED_MFP_H */