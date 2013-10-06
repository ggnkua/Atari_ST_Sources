#ifndef	INCLUDED_CLOCK_H
#define	INCLUDED_CLOCK_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  ENUMS
################################################################################### */


enum
{
	eCLOCK_STATE_INACTIVE,
	eCLOCK_STATE_ACTIVE,
	eCLOCK_STATE_PAUSE
};

typedef struct
{
	U8	Hours;
	U8	Minutes;
	U8	Seconds;
	U8	MicroSeconds;
} sTime;

typedef	struct
{
	U16			State;
	U32			Duration;
	sTime		StartTime;
	sTime		PauseTime;
	sTime		ElapsedTime;
	sTime		CountDownStartTime;	
	sTime		CountDownTime;
	U32			StartTicks;
	U32			PauseTicks;
	U32			ElapsedTicks;
} sClock;



/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Clock_Init( void );
void	Clock_DeInit( void );

void	Clock_Update( sClock * apClock );
void	Clock_Start( sClock * apClock );
void	Clock_Stop( sClock * apClock );
void	Clock_Pause( sClock * apClock );
void	Clock_UnPause( sClock * apClock );

U32		Time_ToU32(   sTime * apTime );
void	Time_FromU32( sTime * apTime, U32 aTicks );

void	Time_Add( sTime * apSrc0, sTime * apSrc1, sTime * apDst );
void	Time_Sub( sTime * apSrc0, sTime * apSrc1, sTime * apDst );


/* ################################################################################ */

#endif	/*	INCLUDED_CLOCK_H	*/