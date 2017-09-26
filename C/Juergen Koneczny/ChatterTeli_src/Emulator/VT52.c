#include	<mt_mem.h>
/*****************************************************************************/
/* VT52                                                                      */
/*****************************************************************************/
#include	<STDDEF.H>
#include	<STRING.H>
#include	<STDLIB.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"..\Emulator.h"
#include	"Emu.h"

#include	"..\MapKey.h"


/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static long	Do( char *Text, long Len, EMU_DATA *EmuData );
static CTRL_SEQ	*Ctrl( int Key, int Flag );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern EMU_FUNC	EmuFunc_NVT;
extern EMU_FUNC	EmuFunc_VT100;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
EMU_FUNC	EmuFunc_VT52 =
{
	Do,
	Ctrl
};

static long	Do( char *Text, long Len, EMU_DATA *EmuData )
{
	long	Ret = 2;
	if( Text[0] == 27 )
	{
		if( Len < 2 )
			return( -1 );
	}
	else
		return( EmuFunc_NVT.Do( Text, Len, EmuData ));
	switch( Text[1] )
	{
		case	'<':
		{
			EmuData->EmuFunc = &EmuFunc_VT100;
			break;
		}
		case	'=':
		{
			EmuData->Key |= KEYPAD_APPLICATION;
			break;
		}
		case	'>':
		{
			EmuData->Key &= ~KEYPAD_APPLICATION;
			break;
		}
		case	'A':
		{
			if( EmuData->Cursor.y > EmuData->nLine - EmuData->Terminal.y )
				EmuData->Cursor.y--;
			break;
		}
		case	'B':
		{
			if( EmuData->Cursor.y < EmuData->nLine - 1 )
				EmuData->Cursor.y++;
			break;

		}
		case	'C':
		{
			EmuData->Cursor.x++;
			if( EmuData->Cursor.x >= EmuData->Terminal.x )
				EmuData->Cursor.x = EmuData->Terminal.x - 1;
			break;
		}
		case	'D':
		{
			EmuData->Cursor.x--;
			if( EmuData->Cursor.x < 0 )
				EmuData->Cursor.x = 0;
			break;
		}
		case	'E':
		{
			XY	Start, End;
			EMU_NewScreen( EmuData );
			Start.x = 0;
			Start.y = EmuData->Cursor.y;
			End.x = EmuData->Terminal.x - 1;
			End.y = Start.y + EmuData->Terminal.y - 1;
			AppendXyItem( &Start, &End, EmuData );
			break;
		}
		case	'H':
		{
			EmuData->Cursor.x = 0;
			EmuData->Cursor.y = EmuData->nLine - EmuData->Terminal.y;
			if( EmuData->Cursor.y < 0 )
				EmuData->Cursor.y = 0;
			break;
		}
		case	'I':
		{
			XY	S;
			EMU_IsScroll( EmuData, &S );
			if( S.x == EmuData->Cursor.y )
			{
				XY	Start, End;
				Start.x = 0;
				End.x = EmuData->Terminal.x - 1;

				Start.y = EmuData->nLine - EmuData->Terminal.y;
				End.y = EmuData->nLine;
				AppendXyItem( &Start, &End, EmuData );

				S.x = S.y;
				EMU_ScrollLines( &S, EmuData->nLine - EmuData->Terminal.y - 1, EmuData );
				EMU_InsertLine( EmuData->Cursor.y, EmuData );
				EmuData->Cursor.y++;
			}
			else
				EmuData->Cursor.y--;

/*			if( EmuData->nLine - EmuData->Terminal.y > EmuData->Cursor.y )
				EmuData->Cursor.y--;
			else
			{
				XY	Start, End, S;
				Start.x = 0;
				End.x = EmuData->Terminal.x - 1;

				Start.y = EmuData->nLine - EmuData->Terminal.y;
				End.y = EmuData->nLine;
				AppendXyItem( &Start, &End, EmuData );

				S.x = EmuData->nLine - 1;
				S.y = EmuData->nLine - 1;
				EMU_ScrollLines( &S, EmuData->nLine - EmuData->Terminal.y - 1, EmuData );
				EMU_InsertLine( EmuData->Cursor.y, EmuData );
				EmuData->Cursor.y++;
            
/*				XY	Start, End;
				EMU_InsertLine( EmuData->Cursor.y - 1, EmuData );
				Start.x = 0;
				Start.y = EmuData->nLine - EmuData->Terminal.y;
				End.x = EmuData->Terminal.x - 1;
				End.y = Start.y + EmuData->Terminal.y - 1;
				AppendXyItem( &Start, &End, EmuData );	*/
			}	*/
			break;
		}
		case	'J':
		{
			XY	Start, End;
			Start.x = EmuData->Cursor.x;
			Start.y = EmuData->Cursor.y;
			End.x = EmuData->Terminal.x;
			End.y = EmuData->nLine - 1;
			EMU_DeleteChar( &Start, &End, EmuData );
			Start.x = EmuData->Cursor.x;
			Start.y = EmuData->Cursor.y;
			End.x = EmuData->Terminal.x - 1;
			End.y = EmuData->Cursor.y;
			AppendXyItem( &Start, &End, EmuData );
			Start.x = 0;
			Start.y = EmuData->Cursor.y + 1;
			End.x = EmuData->Terminal.x - 1;
			End.y = EmuData->nLine - 1;
			AppendXyItem( &Start, &End, EmuData );
			break;
		}
		case	'K':
		{
			XY	Start, End;
			Start.x = EmuData->Cursor.x;
			Start.y = EmuData->Cursor.y;
			End.x = EmuData->Terminal.x - 1;
			End.y = EmuData->Cursor.y;
			EMU_DeleteChar( &Start, &End, EmuData );
			AppendXyItem( &Start, &End, EmuData );
			break;
		}
		case	'L':
		{
			XY	Start, End;
			EMU_InsertLine( EmuData->Cursor.y - 1, EmuData );
			EmuData->Cursor.x = 0;
			Start.x = 0;
			Start.y = EmuData->Cursor.y;
			End.x = EmuData->Terminal.x - 1;
			End.y = EmuData->nLine - 1;
			AppendXyItem( &Start, &End, EmuData );
			break;
		}
		case	'M':
		{
			XY	Start, End;
			EMU_DeleteLine( EmuData->Cursor.y, EmuData );
			EmuData->Cursor.x = 0;
			Start.x = 0;
			Start.y = EmuData->Cursor.y;
			End.x = EmuData->Terminal.x - 1;
			End.y = EmuData->nLine - 1;
			AppendXyItem( &Start, &End, EmuData );
			break;
		}
		case	'Y':
		{
			if( Len < 4 )
				return( -1 );
			else
			{
				long	x = ( long ) Text[3], y = ( long ) Text[2];
				EmuData->Cursor.x = x - 32;
				EmuData->Cursor.y = EmuData->nLine - EmuData->Terminal.y + y - 32;
				Ret = 4;
			}
			break;
		}
		case	'b':
		{
			if( Len < 3 )
				return( -1 );
			else
			{
				ATTR	Attr;
				Attr.A = EMU_FOREGROUND_COLOR;
				Attr.P = ( int ) Text[2];
				AppendAttribut( &Attr, &( EmuData->Attribut ));
				Ret = 3;
			}
			break;
		}
		case	'c':
		{
			if( Len < 3 )
				return( -1 );
			else
			{
				ATTR	Attr;
				Attr.A = EMU_BACKGROUND_COLOR;
				Attr.P = ( int ) Text[2];
				AppendAttribut( &Attr, &( EmuData->Attribut ));
				Ret = 3;
			}
			break;
		}
		case	'd':
		{
			XY	Start, End;

			Start.x = 0;
			Start.y = EmuData->nLine - EmuData->Terminal.y;
			End.x = EmuData->Cursor.x;
			End.y = EmuData->Cursor.y;
			EMU_DeleteChar( &Start, &End, EmuData );

			Start.x = 0;
			Start.y = EmuData->nLine - EmuData->Terminal.y;
			End.x = EmuData->Terminal.x - 1;
			End.y = EmuData->Cursor.y - 1;
			AppendXyItem( &Start, &End, EmuData );
			Start.x = 0;
			Start.y = EmuData->Cursor.y;
			End.x = EmuData->Cursor.x;
			End.y = EmuData->Cursor.y - 1;
			AppendXyItem( &Start, &End, EmuData );
			break;
		}
		case	'e':
		{
			EmuData->EmuFlag |= EMUFLAG_C_ON;
			break;
		}
		case	'f':
		{
			EmuData->EmuFlag &= ~EMUFLAG_C_ON;
			break;
		}
		case	'j':
		{
			EmuData->MCursor.x = EmuData->Cursor.x;
			EmuData->MCursor.y = EmuData->Cursor.y;
			break;
		}
		case	'k':
		{
			if( EmuData->MCursor.x != -1 && EmuData->MCursor.y != -1 )
			{
				EmuData->Cursor.x = EmuData->MCursor.x;
				EmuData->Cursor.y = EmuData->MCursor.y;
			}
			break;
		}
		case	'l':
		{
			XY	Start, End;
			Start.x = 0;
			Start.y = EmuData->Cursor.y;
			End.x = EmuData->Terminal.x - 1;
			End.y = EmuData->Cursor.y;
			EMU_DeleteChar( &Start, &End, EmuData );
			EmuData->Cursor.x = 0;
			AppendXyItem( &Start, &End, EmuData );
			break;
		}
		case	'o':
		{
			XY	Start, End;
			Start.x = 0;
			Start.y = EmuData->Cursor.y;
			End.x = EmuData->Cursor.x;
			End.y = EmuData->Cursor.y;
			EMU_DeleteChar( &Start, &End, EmuData );
			AppendXyItem( &Start, &End, EmuData );
			break;
		}
		case	'p':
		{
			ATTR	Attr;
			Attr.A = EMU_REVERSE;
			Attr.P = 0;
			AppendAttribut( &Attr, &( EmuData->Attribut ));
			break;
		}
		case	'q':
			DeleteAttribut( EMU_REVERSE, &( EmuData->Attribut ));
			break;
		case	'v':
			EmuData->EmuFlag |= EMUFLAG_WRAP;
			break;
		case	'w':
			EmuData->EmuFlag &= ~EMUFLAG_WRAP;
			break;
		default:
			return( 0 );
	}
	return( Ret );
}

static CTRL_SEQ	*Ctrl( int Key, int Flag )
{
	char	C = 0xff & Key;
	if( C == EMU_HT )
		return( MakeCtrlSeq( "\t" ));
	if( Key & KbSCAN )
	{
		switch( C )
		{
			case	KbUP:
				return( Key & KbSHIFT ? NULL : MakeCtrlSeq( "\33A" ));
			case	KbDOWN:
				return( Key & KbSHIFT ? NULL : MakeCtrlSeq( "\33B" ));
			case	KbRIGHT:
				return( Key & KbSHIFT ? NULL : MakeCtrlSeq( "\33C" ));
			case	KbLEFT:
				return( Key & KbSHIFT ? NULL : MakeCtrlSeq( "\33D" ));
			case	KbHOME:
				return( Key & KbSHIFT ? MakeCtrlSeq( "\33E" ) : MakeCtrlSeq( "\33H" ));
			default:
				return( NULL );
		}
	}
	else	if(( Key & KbNUM ))
	{
		switch( C )
		{
			case	'(':
				return( MakeCtrlSeq( "\33P" ));
			case	')':
				return( MakeCtrlSeq( "\33Q" ));
			case	'/':
				return( MakeCtrlSeq( "\33R" ));
			case	'*':
				return( MakeCtrlSeq( "\33S" ));
			case	'0':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?p" ) : MakeCtrlSeq( "0" ));
			case	'1':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?q" ) : MakeCtrlSeq( "1" ));
			case	'2':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?r" ) : MakeCtrlSeq( "2" ));
			case	'3':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?s" ) : MakeCtrlSeq( "3" ));
			case	'4':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?t" ) : MakeCtrlSeq( "4" ));
			case	'5':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?u" ) : MakeCtrlSeq( "5" ));
			case	'6':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?v" ) : MakeCtrlSeq( "6" ));
			case	'7':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?w" ) : MakeCtrlSeq( "7" ));
			case	'8':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?x" ) : MakeCtrlSeq( "8" ));
			case	'9':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?y" ) : MakeCtrlSeq( "9" ));
			case	'-':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?m" ) : MakeCtrlSeq( "-" ));
			case	'+':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?l" ) : MakeCtrlSeq( "," ));
			case	'.':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?n" ) : MakeCtrlSeq( "." ));
			case	'\n':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33?M" ) : MakeCtrlSeq( "\n" ));
			default:
				return( NULL );
		}
	}
	return( NULL );
}
