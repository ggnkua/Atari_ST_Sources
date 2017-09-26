#include	<mt_mem.h>
/*****************************************************************************/
/* VT102/ANSI                                                                     */
/*****************************************************************************/
#include	<STDDEF.H>
#include	<STRING.H>
#include	<STDLIB.H>
#include	<CTYPE.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"..\Emulator.h"
#include	"Emu.h"

#include	"..\MapKey.h"


/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static long	Do( char *Text, long Len, EMU_DATA *EmuData );
static long	Sequenz( char *Text, long Len, EMU_DATA *EmuData );
static void Mode_h( char *Text, EMU_DATA *EmuData );
static void Mode_l( char *Text, EMU_DATA *EmuData );
static void Attribut( char *Text, EMU_DATA *EmuData );
static CTRL_SEQ	*Ctrl( int Key, int Flag );

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern EMU_FUNC	EmuFunc_NVT;
extern EMU_FUNC	EmuFunc_VT52;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
EMU_FUNC	EmuFunc_VT100 =
{
	Do,
	Ctrl
};
EMU_FUNC	EmuFunc_VT102 =
{
	Do,
	Ctrl
};

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static int	Color[8] = {1, 2, 3, 6, 4, 7, 5, 0 };

static long	Do( char *Text, long Len, EMU_DATA *EmuData )
{
	if( Text[0] == 27 )
	{
		if( Len >= 2 )
		{
			if( Text[1] == '[' )
			{
				long	Ret = Sequenz( &( Text[2] ), Len - 2, EmuData );
				if( Ret < 0 )
					return( -1 );
				else	if( Ret == 0 )
					return( 0 );
				else
					return( Ret + 2 );
			}
			else	if( Text[1] == '(' )
				return( 3 );
			else	if( Text[1] == ')' )
				return( 3 );
			else
			{
				switch( Text[1] )
				{
					case	'7':
					{
						ATTR_ITEM	*Item = EmuData->Attribut;
						FreeAttribut( &( EmuData->MAttribut ));
						while( Item )
						{
							AppendAttribut( &( Item->Attr ), &( EmuData->MAttribut ));
							Item = Item->next;
						}
						EmuData->MCursor.x = EmuData->Cursor.x;
						EmuData->MCursor.y = EmuData->Cursor.y;
						return( 2 );
					}
					case	'8':
						if( EmuData->MCursor.x != -1 && EmuData->MCursor.y != -1 )
						{
							ATTR_ITEM	*Item = EmuData->MAttribut;
							FreeAttribut( &( EmuData->Attribut ));
							while( Item )
							{
								AppendAttribut( &( Item->Attr ), &( EmuData->Attribut ));
								Item = Item->next;
							}
							EmuData->Cursor.x = EmuData->MCursor.x;
							EmuData->Cursor.y = EmuData->MCursor.y;
						}
						return( 2 );
					case	'c':
						EmuData->Cursor.x = 0;
						EmuData->Cursor.y = EmuData->nLine - EmuData->Terminal.y;
						if( EmuData->Cursor.y < 0 )
							EmuData->Cursor.y = 0;
						return( 2 );
					case	'D':
					case	'E':
						EmuData->Cursor.y++;
						return( 2 );
					case	'M':
						EmuFunc_VT52.Do( "\033I", 2, EmuData );
						return( 2 );
					default:
						return( EmuFunc_VT52.Do( Text, Len, EmuData ));
						return( 0 );
				}
			}
		}
		else
			return( -1 );	
	}
	else
		return( EmuFunc_NVT.Do( Text, Len, EmuData ));
}

static long	Sequenz( char *Text, long Len, EMU_DATA *EmuData )
{
	long	lLen = 1;

	if( Len < 1 )
		return( -1 );

	if( Text[0] == '?' )
	{
		while( lLen <= Len )
		{
			if( isdigit( Text[lLen-1] ))
			{
				lLen++;
				continue;
			}			
			switch( Text[lLen-1] )
			{
				case	'h':
					Mode_h( &( Text[1] ), EmuData );
					return( lLen );
				case	'l':
					Mode_l( &( Text[1] ), EmuData );
					return( lLen );
				default:
					lLen++;
			}
		}
		if( lLen > Len )
			return( -1 );
	}
	else	if( Text[0] == 's' )
	{
		EmuData->MCursor.x = EmuData->Cursor.x;
		EmuData->MCursor.y = EmuData->Cursor.y;
		return( 1 );
	}
	else	if( Text[0] == 'u' )
	{
		if( EmuData->MCursor.x != -1 && EmuData->MCursor.y != -1 )
		{
			EmuData->Cursor.x = EmuData->MCursor.x;
			EmuData->Cursor.y = EmuData->MCursor.y;
		}
		return( 1 );
	}
	else	if( Text[0] != 'K' && Text[0] != 'J' )
	{
		while( lLen <= Len )
		{
			if( isdigit( Text[lLen-1] ))
			{
				lLen++;
				continue;
			}			
			switch( Text[lLen-1] )
			{
				case	'm':
					Attribut( Text, EmuData );
					return( lLen );
				case	'H':
				case	'f':
				{
					long	x = 0, y = 0;
					int	i = 0;
					if( Text[0] != 'f' && Text[0] != 'H' && Text[0] != ';' )
					{
						y = atol( Text ) - 1;
						while( Text[i] != ';' && Text[i] != 'H' && Text[i] != 'f' )
							i++;
						x = atol( &Text[i+1] ) - 1;
					}
					EmuData->Cursor.x = x >= EmuData->Terminal.x ? EmuData->Terminal.x - 1 : x;
					EmuData->Cursor.y = y >= EmuData->nLine ? EmuData->nLine - 1 : EmuData->nLine - EmuData->Terminal.y + y;
					return( lLen );
				}
				case	'r':
				{
					long	y1 = 0, y2 = EmuData->Terminal.y - 1;
					int	i = 0;
					if( Text[0] != 'r' )
					{
						y1 = atol( Text ) - 1;
						while( Text[i] != ';' && Text[i] != 'r' )
							i++;
						y2 = atol( &Text[i+1] ) - 1;
					}
					EmuData->Scroll.x = y1;
					EmuData->Scroll.y = y2;
					return( lLen );
				}
				case	'A':
				{
					long	y = 1;
					if( Text[0] != 'A' )
						y = atol( Text );
					EmuData->Cursor.y -= y;
					if( EmuData->Cursor.y < EmuData->nLine - EmuData->Terminal.y )
						EmuData->Cursor.y = EmuData->nLine - EmuData->Terminal.y;
					return( lLen );
				}
				case	'B':
				{
					long	y = 1;
					if( Text[0] != 'B' )
						y = atol( Text );
					EmuData->Cursor.y += y;
					if( EmuData->Cursor.y >= EmuData->nLine )
						EmuData->Cursor.y = EmuData->nLine - 1;
					return( lLen );
				}
				case	'C':
				{
					long	x = 1;

					if( Text[0] != 'C' )
						x = atol( Text );
					EmuData->Cursor.x += x;
					if( EmuData->Cursor.x >= EmuData->Terminal.x )
						EmuData->Cursor.x = EmuData->Terminal.x - 1;
					return( lLen );
				}
				case	'D':
				{
					long	x = 1;
					if( Text[0] != 'D' )
						x = atol( Text );
					EmuData->Cursor.x -= x;
					if( EmuData->Cursor.x < 0 )
						EmuData->Cursor.x = 0;
					return( lLen );
				}
				default:
					lLen++;
			}
			if( Text[lLen-2] == 'J' || Text[lLen-2] == 'K' )
				break;
		}
		if( lLen > Len )
			return( -1 );
	}

	switch( Text[0] )
	{
		case	'0':
			if( Len < 2 )
				return( -1 );
			switch( Text[1] )
			{
				case	'J':
					EmuFunc_VT52.Do( "\033J", 2, EmuData );
					return( 2 );
				case	'K':
					EmuFunc_VT52.Do( "\033K", 2, EmuData );
					return( 2 );
				default:
					return( 0 );
			}
		case	'1':
			if( Len < 2 )
				return( -1 );
			switch( Text[1] )
			{
				case	'J':
					EmuFunc_VT52.Do( "\033d", 2, EmuData );
					return( 2 );
				case	'K':
					EmuFunc_VT52.Do( "\033o", 2, EmuData );
					return( 2 );
				default:
					return( 0 );
			}
		case	'2':
			if( Len < 2 )
				return( -1 );
			switch( Text[1] )
			{
				case	'J':
				{
					EmuData->Cursor.x = 0;
					EmuData->Cursor.y = EmuData->nLine - EmuData->Terminal.y;
					if( EmuData->Cursor.y < 0 )
						EmuData->Cursor.y = 0;
					EmuFunc_VT52.Do( "\033J", 2, EmuData );
					return( 2 );
				}
				case	'K':
					EmuFunc_VT52.Do( "\033K", 2, EmuData );
					EmuFunc_VT52.Do( "\033d", 2, EmuData );
					return( 2 );
				default:
					return( 0 );
			}
		case	'J':
			EmuFunc_VT52.Do( "\033J", 2, EmuData );
			return( 1 );
		case	'K':
			EmuFunc_VT52.Do( "\033K", 2, EmuData );
			return( 1 );
		default:
			return( 0 );
	}
}

static void Mode_h( char *Text, EMU_DATA *EmuData )
{
	long	Len = 0;

	while( Text[Len] != 'h' )
		switch( Text[Len] )
		{
			case	'1':
				EmuData->Key |= CURSOR_APPLICATION;
				Len++;
				break;
			case	'5':
				EmuData->Invers = 1;
				Len++;
				break;
			case	'6':
				EmuData->ScrollFlag = 1;
				Len++;
				break;
			case	'7':
				EmuData->EmuFlag |= EMUFLAG_WRAP;
				Len++;
				break;
			default:
				Len++;
		}
	return;
}
static void Mode_l( char *Text, EMU_DATA *EmuData )
{
	long	Len = 0;

	while( Text[Len] != 'l' )
		switch( Text[Len] )
		{
			case	'1':
				EmuData->Key &= ~CURSOR_APPLICATION;
				Len++;
				break;
			case	'2':
				EmuData->EmuFunc = &EmuFunc_VT52;
				Len++;
				break;
			case	'5':
				EmuData->Invers = 0;
				Len++;
				break;
			case	'6':
				EmuData->ScrollFlag = 0;
				Len++;
				break;
			case	'7':
				EmuData->EmuFlag &= ~EMUFLAG_WRAP;
				Len++;
				break;
			default:
				Len++;
		}
	return;
}
static void Attribut( char *Text, EMU_DATA *EmuData )
{
	ATTR	Attr;
	long	Len = 0;

	if( Text[0] == 'm' )
	{
		FreeAttribut( &( EmuData->Attribut ));
		return;
	}
	while( Text[Len] != 'm' )
	{
		switch( Text[Len] )
		{
			case	';':
				if( Len == 0 || Text[Len-1] == ';' )
					FreeAttribut( &( EmuData->Attribut ));
				Len++;
				break;
			case	'0':
			case	'm':
/*				DeleteAttribut( EMU_BOLD, &( EmuData->Attribut ));
				DeleteAttribut( EMU_LIGHT, &( EmuData->Attribut ));
				DeleteAttribut( EMU_ITALIC, &( EmuData->Attribut ));
				DeleteAttribut( EMU_LINE, &( EmuData->Attribut ));
				DeleteAttribut( EMU_FLASH, &( EmuData->Attribut ));
				DeleteAttribut( EMU_FLASHFLASH, &( EmuData->Attribut ));
				DeleteAttribut( EMU_DARK, &( EmuData->Attribut ));	*/
				FreeAttribut( &( EmuData->Attribut ));
				Len++;
				break;
			case	'1':
				Attr.A = EMU_BOLD;
				Attr.P = 0;
				AppendAttribut( &Attr, &( EmuData->Attribut ));
				Len ++;
				break;
			case	'2':
				switch( Text[Len+1] )
				{
					case	'1':
						DeleteAttribut( EMU_BOLD, &( EmuData->Attribut ));
						Len += 2;
						break;
					case	'2':
						DeleteAttribut( EMU_LIGHT, &( EmuData->Attribut ));
						Len += 2;
						break;
					case	'3':
						DeleteAttribut( EMU_ITALIC, &( EmuData->Attribut ));
						Len += 2;
						break;
					case	'4':
						DeleteAttribut( EMU_LINE, &( EmuData->Attribut ));
						Len += 2;
						break;
					case	'5':
						DeleteAttribut( EMU_FLASH, &( EmuData->Attribut ));
						Len += 2;
						break;
					case	'6':
						DeleteAttribut( EMU_FLASHFLASH, &( EmuData->Attribut ));
						Len += 2;
						break;
					case	'7':
						DeleteAttribut( EMU_REVERSE, &( EmuData->Attribut ));
						Len += 2;
						break;
					case	'8':
						DeleteAttribut( EMU_DARK, &( EmuData->Attribut ));
						Len += 2;
						break;
					case	';':
					case	'm':
						Attr.A = EMU_LIGHT;
						Attr.P = 0;
						AppendAttribut( &Attr, &( EmuData->Attribut ));
						Len++;
						break;
					default:
						Len++;
				}
				break;
			case	'3':
				if( isdigit(( int ) Text[Len+1] ))
				{
					Attr.A = EMU_FOREGROUND_COLOR;
					Attr.P = Color[ Text[Len+1] - '0' ];
					AppendAttribut( &Attr, &( EmuData->Attribut ));
					Len +=2;
				}
				else
				{
					Attr.A = EMU_ITALIC;
					Attr.P = 0;
					AppendAttribut( &Attr, &( EmuData->Attribut ));
					Len++;
				}
				break;
				
			case	'4':
				if( isdigit(( int ) Text[Len+1] ))
				{
					Attr.A = EMU_BACKGROUND_COLOR;
					Attr.P = Color[ Text[Len+1] - '0' ];
					AppendAttribut( &Attr, &( EmuData->Attribut ));
					Len +=2;
				}
				else
				{
					Attr.A = EMU_LINE;
					Attr.P = 0;
					AppendAttribut( &Attr, &( EmuData->Attribut ));
					Len++;
				}
				break;
			case	'5':
			{
				Attr.A = EMU_FLASH;
				Attr.P = 0;
				AppendAttribut( &Attr, &( EmuData->Attribut ));
				Len++;
				break;
			}
			case	'6':
			{
				Attr.A = EMU_FLASHFLASH;
				Attr.P = 0;
				AppendAttribut( &Attr, &( EmuData->Attribut ));
				Len++;
				break;
			}
			case	'7':
			{
				Attr.A = EMU_REVERSE;
				Attr.P = 0;
				AppendAttribut( &Attr, &( EmuData->Attribut ));
				Len++;
				break;
			}
			case	'8':
			{
				Attr.A = EMU_DARK;
				Attr.P = 0;
				AppendAttribut( &Attr, &( EmuData->Attribut ));
				Len++;
				break;
			}
			default:
				Len++;
		}
	}
}

static CTRL_SEQ	*Ctrl( int Key, int Flag )
{
	char	C = 0xff & Key;
	if( C == EMU_HT )
		return( ( Key & KbSHIFT ) ? MakeCtrlSeq( "\33[Z" ) : MakeCtrlSeq( "\t" ));
	else	if( Key & KbSCAN )
	{
		if(( Key & KbSHIFT ) && ( Key & KbCONTROL ))
			switch( C )
			{
				case	KbHOME:
					return( MakeCtrlSeq( "\33[Y" ));
				case	KbINSERT:
					return( MakeCtrlSeq( "\33[L" ));
			}
		if( Key & KbSHIFT )
			switch( C )
			{
				case	KbUP:
					return( MakeCtrlSeq( "\33[I" ));
				case	KbDOWN:
					return( MakeCtrlSeq( "\33[G" ));
				case	KbHOME:
					return( MakeCtrlSeq( "\33[F" ));
				case	KbINSERT:
					return( MakeCtrlSeq( "\33[4l" ));
				case	KbUNDO:
					return( MakeCtrlSeq( "\33[M" ));
			}
		else	if( Key & KbCONTROL )
			switch( C )
			{
				case	KbUP:
					return( MakeCtrlSeq( "\33[V" ));
				case	KbDOWN:
					return( MakeCtrlSeq( "\33[U" ));
				case	KbHOME:
					return( MakeCtrlSeq( "\33[X" ));
				case	KbUNDO:
					return( MakeCtrlSeq( "\33[K" ));
			}
		else
			switch( C )
			{
				case	KbUP:
					return( Flag & CURSOR_APPLICATION ? MakeCtrlSeq( "\33OA" ) : MakeCtrlSeq( "\33[A" ));
				case	KbDOWN:
					return( Flag & CURSOR_APPLICATION ? MakeCtrlSeq( "\33OB" ) : MakeCtrlSeq( "\33[B" ));
				case	KbRIGHT:
					return( Flag & CURSOR_APPLICATION ? MakeCtrlSeq( "\33OC" ) : MakeCtrlSeq( "\33[C" ));
				case	KbLEFT:
					return( Flag & CURSOR_APPLICATION ? MakeCtrlSeq( "\33OD" ) : MakeCtrlSeq( "\33[D" ));
				case	KbHOME:
					return( Flag & CURSOR_APPLICATION ? MakeCtrlSeq( "\33[F" ) : MakeCtrlSeq( "\33[H" ));
				case	KbINSERT:
					return( MakeCtrlSeq( "\33[4h" ));
				case	KbUNDO:
					return( MakeCtrlSeq( "\33[P" ));
			}
		return( NULL );
	}
	else	if( Key & KbNUM )
	{
		switch( C )
		{
			case	'(':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33OP" ) : MakeCtrlSeq( "\33[P" ));
			case	')':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33OQ" ) : MakeCtrlSeq( "\33[Q" ));
			case	'/':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33OR" ) : MakeCtrlSeq( "\33[R" ));
			case	'*':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33OS" ) : MakeCtrlSeq( "\33[S" ));
			case	'0':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Op" ) : MakeCtrlSeq( "0" ));
			case	'1':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Oq" ) : MakeCtrlSeq( "1" ));
			case	'2':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Or" ) : MakeCtrlSeq( "2" ));
			case	'3':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Os" ) : MakeCtrlSeq( "3" ));
			case	'4':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Ot" ) : MakeCtrlSeq( "4" ));
			case	'5':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Ou" ) : MakeCtrlSeq( "5" ));
			case	'6':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Ov" ) : MakeCtrlSeq( "6" ));
			case	'7':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Ow" ) : MakeCtrlSeq( "7" ));
			case	'8':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Ox" ) : MakeCtrlSeq( "8" ));
			case	'9':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Oy" ) : MakeCtrlSeq( "9" ));
			case	'-':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Om" ) : MakeCtrlSeq( "-" ));
			case	'+':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33Ol" ) : MakeCtrlSeq( "," ));
			case	'.':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33On" ) : MakeCtrlSeq( "." ));
			case	'\n':
				return( Flag & KEYPAD_APPLICATION ? MakeCtrlSeq( "\33OM" ) : MakeCtrlSeq( "\n" ));
			default:
				return( NULL );
		}
	}
	return( NULL );
}
