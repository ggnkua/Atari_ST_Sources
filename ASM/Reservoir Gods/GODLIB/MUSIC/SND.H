#ifndef	INCLUDED_SND_H
#define	INCLUDED_SND_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>

/* ###################################################################################
#  ENUM
################################################################################### */

enum
{
	eSND_TIMER_A,
	eSND_TIMER_B,
	eSND_TIMER_C,
	eSND_TIMER_D,
	eSND_TIMER_VBI,

	eSND_TIMER_LIMIT
};


/* ###################################################################################
#  STRUCTS
################################################################################### */


typedef	struct
{
	U16	Instruction;
	U16	Offset;
} sSndJump;

typedef	struct
{
	U16	Type;
	U16	Freq;
	U8	Div;
	U8	Data;
} sSndTimer;

typedef	struct
{
	sSndJump	Start;
	sSndJump	Stop;
	sSndJump	Play;
	U32			ID;
	char		Data[ 1 ];
} sSndHeader;

typedef	struct
{
	sSndHeader *	pHeader;
	char *			pComposerTxt;
	char *			pTitleTxt;
	char *			pRipperTxt;
	char *			pConversionTxt;
	void			(*Start)( void );
	void			(*Stop)( void );
	void			(*Play)( void );
	sSndTimer		Timer;
} sSndInfo;

/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void	Snd_Init( void );
void	Snd_DeInit( void );

void	Snd_GetInfo( sSndHeader * apHeader, sSndInfo * apInfo );

void	Snd_TuneInit( sSndInfo * apInfo );
void	Snd_TuneDeInit( sSndInfo * apInfo );

void	Snd_SetpPlayFunc( void (*aPlayFunc)(void) );
void	Snd_SetpChaserFunc( void (*aChaserFunc)(void) );


/* ################################################################################ */

#endif	/*	INCLUDED_SND_H */