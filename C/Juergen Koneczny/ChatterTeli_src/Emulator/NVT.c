#include	<mt_mem.h>
/*****************************************************************************/
/* NVT (Network Virtual Terminal)                                            */
/*****************************************************************************/
#include	<TOS.H>
#include	<STDDEF.H>
#include	<STRING.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"..\Emulator.h"
#include	"Emu.h"

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static long	Do( char *Text, long Len, EMU_DATA *EmuData );
static CTRL_SEQ	*Ctrl( int Key, int Flag );

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
EMU_FUNC	EmuFunc_NVT =
{
	Do,
	Ctrl
};

static long	Do( char *Text, long Len, EMU_DATA *EmuData )
{
	char	c = Text[0];
	if( c == EMU_NUL )
		return( 1 );
	else	if( c == EMU_BELL )
	{
		Cconout( '\a' );
		return( 1 );
	}
	else	if( c == EMU_BS )
	{	
		if( EmuData->Cursor.x > 0 )
			EmuData->Cursor.x--;
		return( 1 );
	}
	else	if( c == EMU_HT )
	{
		EmuData->Cursor.x += EmuData->Tab.x;
		if( EmuData->Cursor.x >= EmuData->Terminal.x )
		{
			if( EmuData->EmuFlag & EMUFLAG_WRAP )
			{
				EmuData->Cursor.x = 0;
				EmuData->Cursor.y++;
			}
			else
				EmuData->Cursor.x = EmuData->Terminal.x;
		}
		return( 1 );
	}
	else	if( c == EMU_CR )
	{
		EmuData->Cursor.x = 0;
		return( 1 );
	}
	else	if( c == EMU_LF )
	{
		XY	S;
		if( EMU_IsScroll( EmuData, &S ) && EmuData->Cursor.y == S.y )
		{
			XY	Start, End;
			Start.x = 0;
			End.x = EmuData->Terminal.x - 1;

/*			Start.y = EmuData->nLine - EmuData->Terminal.y;
			End.y = Start.y;
			AppendXyItem( &Start, &End, EmuData );

			Start.y = S.y + 1;
			End.y = EmuData->nLine;
			AppendXyItem( &Start, &End, EmuData );
*/
			S.y = S.x;
			EMU_ScrollLines( &S, EmuData->nLine - EmuData->Terminal.y - 1, EmuData );
			EMU_InsertLine( EmuData->Cursor.y, EmuData );

			Start.y = EmuData->nLine - EmuData->Terminal.y - 2;
			End.y = EmuData->nLine - 1;
			AppendXyItem( &Start, &End, EmuData );
		}
		EmuData->Cursor.y++;
		return( 1 );
	}
	else	if( c == EMU_VT )
	{
		EmuData->Cursor.y += EmuData->Tab.y;
		return( 1 );
	}
	else	if( c == EMU_FF )
	{
		XY	Start, End;
		EMU_NewScreen( EmuData );
		Start.x = 0;
		Start.y = EmuData->Cursor.y;
		End.x = EmuData->Terminal.x - 1;
		End.y = Start.y + EmuData->Terminal.y - 1;
		AppendXyItem( &Start, &End, EmuData );
		return( 1 );
	}
	else	if( c == 15 )
		return( 1 );
	return( 0 );
}

static CTRL_SEQ	*Ctrl( int Key, int Flag )
{	return( NULL );	}