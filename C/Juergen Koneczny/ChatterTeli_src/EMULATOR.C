#include	<mt_mem.h>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"Emulator.h"
#include	"Emulator\Emu.h"

#include	"KEYTAB.H"

/*-----------------------------------------------------------------------------*/
/* Externe Variable                                                            */
/*-----------------------------------------------------------------------------*/
extern EMU_FUNC	EmuFunc_NVT;
extern EMU_FUNC	EmuFunc_VT52;
extern EMU_FUNC	EmuFunc_VT100;
extern EMU_FUNC	EmuFunc_VT102;

extern KEYT *Keytab;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/

static void	CheckLine( EMU_DATA *EmuData );
static TEXTLINE	*AppendLine( EMU_DATA *EmuData );
static TEXTLINE	*GetLine( long n, EMU_DATA *EmuData );
static void			FreeLine( long n, EMU_DATA *EmuData );

static void	InsertChar( char c, EMU_DATA *EmuData );
static void	DeleteChar( EMU_DATA *EmuData );

static CHAR	*AppendChar( CHAR **Char );	/* Žndern in TEXTLINE */
static CHAR	*GetChar( long n, TEXTLINE *Line );
static void	FreeChar( TEXTLINE *Line );

static ATTR_ITEM	*GetAttribut( int A, ATTR_ITEM *List );
static void			SetAttribut( ATTR_ITEM *AttrItem, CHAR *Char );

static void	FreeXyItem( XY_ITEM **XyItem );


EMU_DATA	*EMU_InitData( EMU_TYPE EmuType, int KeyImport, int Key, XY *Terminal, XY *Tab, long PufLines )
{
	EMU_DATA	*New;
	New = malloc( sizeof( EMU_DATA ));

	New->KeyImport = KeyImport;
	New->Key = Key;
	New->Line = NULL;
	New->Attribut = NULL;
	New->RedrawXy = NULL;
	New->CtrlSeq = NULL;
	New->nLine = 0;
	New->PufLines = PufLines;
	New->Terminal.x = Terminal->x;
	New->Terminal.y = Terminal->y;
	New->Tab.x = Tab->x;
	New->Tab.y = Tab->y;
	New->Cursor.x = 0;
	New->Cursor.y = 0;
	New->MAttribut = NULL;
	New->MCursor.x = -1;
	New->MCursor.y = -1;
	New->ScrollFlag = 0;
	New->Scroll.x = 0;
	New->Scroll.y = Terminal->y - 1;
	New->Invers = 0;
	EMU_NewScreen( New );

	New->EmuFlag = EMUFLAG_NON;
	New->EmuFlag |= EMUFLAG_C_ON;

	EMU_ChangeEmu( New, EmuType );

	return( New );
}

void	EMU_Del( EMU_DATA *EmuData )
{
	FreeXyItem( &( EmuData->RedrawXy ));
	FreeAttribut( &( EmuData->MAttribut ));
	FreeAttribut( &( EmuData->Attribut ));
	if( EmuData->CtrlSeq )
	{
		if(( EmuData->CtrlSeq )->Seq )
			free(( EmuData->CtrlSeq )->Seq );
		free( EmuData->CtrlSeq );
		EmuData->CtrlSeq = NULL;
	}
	while( EmuData->nLine > EmuData->Terminal.y + EmuData->PufLines )
		FreeLine( 0, EmuData );
	free( EmuData );
}

CHAR	*EMU_GetChar( long x, long y, EMU_DATA *EmuData )
{
	TEXTLINE	*Line = GetLine( y, EmuData );
	if( Line )
		return( GetChar( x, Line ));
	return( NULL );
}

int	EMU_GetCursor( XY *Cursor, EMU_DATA *EmuData )
{
	Cursor->x = EmuData->Cursor.x;
	Cursor->y = EmuData->Cursor.y;
	if( EmuData->EmuFlag & EMUFLAG_C_ON )
		return( 1 );
	else
		return( 0 );
}

long	EMU_GetNLine( EMU_DATA *EmuData )
{	return( EmuData->nLine );	}

long EMU_GetNCharMax( EMU_DATA *EmuData )
{	return( EmuData->Terminal.x );	}

long	EMU_GetNCharLine( long n, EMU_DATA *EmuData )
{
	TEXTLINE	*Line = GetLine( n, EmuData );
return( EmuData->Terminal.x );
	if( !Line )
		return( 0 );
	else
		return( Line->Len );
}

CTRL_SEQ *EMU_GetCtrl( int Key, EMU_DATA *EmuData )
{
	if( EmuData->CtrlSeq )
	{
		if(( EmuData->CtrlSeq )->Seq )
			free(( EmuData->CtrlSeq )->Seq );
		free( EmuData->CtrlSeq );
		EmuData->CtrlSeq = NULL;
	}
	EmuData->CtrlSeq = (( EMU_FUNC * ) EmuData->EmuFunc )->Ctrl( Key, EmuData->Key );
	return( EmuData->CtrlSeq );
}

/* Cursor hier mitnehmen */
long	EMU_AppendText( char *Text, long Len, XY_ITEM **RedrawXy, int *Invers, EMU_DATA *EmuData )
{
	long	i = 0, w;
	char	c;
	FreeXyItem( &( EmuData->RedrawXy ));


	while( i < Len )
	{
		if(( w = (( EMU_FUNC * ) EmuData->EmuFunc )->Do( &Text[i], Len - i, EmuData )) == 0 )
		{
			if( EmuData->Cursor.x >= EmuData->Terminal.x )
			{
				if( EmuData->EmuFlag & EMUFLAG_WRAP )
				{
					EmuData->Cursor.x = 0;
					EmuData->Cursor.y++;
					CheckLine( EmuData );
				}
			else
				EmuData->Cursor.x = EmuData->Terminal.x - 1;
			}

			c = Text[i];
			c = Keytab->ImportChar( EmuData->KeyImport, c );
			InsertChar( c, EmuData );
			i++;
		}
		else	if( w == -1 )
			break;
		else
			i += w;
		CheckLine( EmuData );
	}

	if( EmuData->nLine > EmuData->Terminal.y + EmuData->PufLines )
	{
		XY	Start, End;
		long		i = 0;

		while( EmuData->nLine > EmuData->Terminal.y + EmuData->PufLines )
		{
			FreeLine( 0, EmuData );
			EmuData->Cursor.y--;
			i++;
		}

		Start.x = 0;
		Start.y = 0;
		End.x = EmuData->Terminal.x - 1;
		End.y = EmuData->Terminal.y + EmuData->PufLines - 1;
		AppendXyItem( &Start, &End, EmuData );
	}

	*RedrawXy = EmuData->RedrawXy;
	*Invers = EmuData->Invers;

	return( i );
}

void	EMU_NewScreen( EMU_DATA *EmuData )
{
	long	i, j;
	CHAR	*Char;
	TEXTLINE	*Line;
	for( i = 0; i < EmuData->Terminal.y; i++ )
	{
		if(( Line = AppendLine( EmuData )) != NULL )
		{
			for( j = 0; j < EmuData->Terminal.x; j++ )
			{
				if(( Char = AppendChar( &( Line->Char ))) != NULL )
					SetAttribut( EmuData->Attribut, Char );
			}
		}
	}
	EmuData->Cursor.y = EmuData->nLine - EmuData->Terminal.y;
	EmuData->Cursor.x = 0;
}

static void	CheckLine( EMU_DATA *EmuData )
{
	CHAR		*Char;
	long		j;
	XY			Start, End;
	while( EmuData->Cursor.y > EmuData->nLine - 1 )
	{
		TEXTLINE	*Line = AppendLine( EmuData );
		Start.x = 0;
		Start.y = EmuData->nLine - 1;
		End.x = EmuData->Terminal.x - 1;
		End.y = Start.y;
		AppendXyItem( &Start, &End, EmuData );
		for( j = 0; j < EmuData->Terminal.x; j++ )
		{
			if(( Char = AppendChar( &( Line->Char ))) != NULL )
				SetAttribut( EmuData->Attribut, Char );
		}
	}
}

void	EMU_ChangeEmu( EMU_DATA *EmuData, EMU_TYPE EmuType )
{
	if( EmuType == NVT )
	{
		EmuData->EmuFunc = &EmuFunc_NVT;
		EmuData->EmuFlag |= EMUFLAG_WRAP;
	}
	else	if( EmuType == VT52 )
	{
		EmuData->EmuFunc = &EmuFunc_VT52;
		EmuData->EmuFlag &= ~EMUFLAG_WRAP;
	}
	else	if( EmuType == VT100 )
	{
		EmuData->EmuFunc = &EmuFunc_VT100;
		EmuData->EmuFlag |= EMUFLAG_WRAP;
	}
	else	if( EmuType == VT102 )
	{
		EmuData->EmuFunc = &EmuFunc_VT102;
		EmuData->EmuFlag |= EMUFLAG_WRAP;
	}
	else
	{
		printf("Nicht implementiert!\n");
	}

}

void		EMU_ChangeKeyImport( EMU_DATA *EmuData, int KeyImport )
{
	EmuData->KeyImport = KeyImport;
}
void	EMU_ChangeKey( EMU_DATA *EmuData, int Key )
{
	EmuData->Key = Key;
}
void	EMU_ChangePufLines( EMU_DATA *EmuData, long PufLines, long *nLine, XY *Cursor )
{
	EmuData->PufLines = PufLines;
	while( EmuData->nLine > EmuData->Terminal.y + EmuData->PufLines )
	{
		FreeLine( 0, EmuData );
		EmuData->Cursor.y--;
	}

	*nLine = EmuData->nLine;
	Cursor->x = EmuData->Cursor.x;
	Cursor->y = EmuData->Cursor.y;
/* EmuData->MCursor checken */
}
void	EMU_ChangeTab( EMU_DATA *EmuData, XY *Tab )
{
	EmuData->Tab.x = Tab->x;
	EmuData->Tab.y = Tab->y;
}
void	EMU_ChangeTerminal( EMU_DATA *EmuData, XY *Terminal, long *nLine, XY *Cursor )
{
	EmuData->Terminal.x = Terminal->x;
	EmuData->Terminal.y = Terminal->y;

	while( EmuData->nLine > EmuData->Terminal.y + EmuData->PufLines )
	{
		FreeLine( 0, EmuData );
		EmuData->Cursor.y--;
	}
	while( EmuData->nLine < EmuData->Terminal.y )
	{
		TEXTLINE	*Line = AppendLine( EmuData );
		CHAR		*Char;
		long		j;
		for( j = 0; j < EmuData->Terminal.x; j++ )
		{
			if(( Char = AppendChar( &( Line->Char ))) != NULL )
				SetAttribut( EmuData->Attribut, Char );
		}
	}

	if( EmuData->Cursor.x >= Terminal->x )
		EmuData->Cursor.x = Terminal->x - 1;
	if( EmuData->Cursor.y >= EmuData->nLine )
		EmuData->Cursor.y = EmuData->nLine - 1;

	*nLine = EmuData->nLine;
	Cursor->x = EmuData->Cursor.x;
	Cursor->y = EmuData->Cursor.y;
/* EmuData->MCursor checken */
}

/*-----------------------------------------------------------------------------*/
/* TEXTLINE                                                                    */
/*-----------------------------------------------------------------------------*/
static TEXTLINE	*AppendLine( EMU_DATA *EmuData )
{
	TEXTLINE	*New = malloc( sizeof( TEXTLINE ));
	TEXTLINE	**Line = &( EmuData->Line );
	if( !New )
		return( NULL );

	if( *Line == NULL )
		*Line = New;
	else
	{
		New->prev = ( *Line )->prev;
		( New->prev )->next = New;
	}
	( *Line )->prev = New;
	New->next = NULL;

	New->Len = 0;
	New->Char = NULL;
	EmuData->nLine++;
	return( New );
}

TEXTLINE	*EMU_InsertLine( long n, EMU_DATA *EmuData )
{
	TEXTLINE	**Line = &( EmuData->Line );
	TEXTLINE	*New = malloc( sizeof( TEXTLINE ));
	CHAR	*Char;
	long	i;

	if( !New )
		return( NULL );
	if( n == -1 )
	{
		TEXTLINE	*Next = *Line;
		*Line = New;
		New->next = Next;
		New->prev = Next->prev;
		Next->prev = New;
	}
	else
	{
		TEXTLINE	*Prev = GetLine( n, EmuData );
		if( !Prev )
			return( NULL );
		New->next = Prev->next;
		New->prev = Prev;
		Prev->next = New;
		if( New->next )
			( New->next )->prev = New;
		if(( *Line )->prev == Prev )
			( *Line )->prev = New;
	}
	New->Len = 0;
	New->Char = NULL;

	for( i = 0; i < EmuData->Terminal.x; i++ )
	{
		if(( Char = AppendChar( &( New->Char ))) != NULL )
			SetAttribut( EmuData->Attribut, Char );
	}
	EmuData->nLine++;
	return( New );
}

void	EMU_ScrollLines( XY *S, long D, EMU_DATA *EmuData )
{
	TEXTLINE	*SourceLine = GetLine( S->x, EmuData );
	long	i;

	for( i = S->x; i <= S->y; i++ )
	{
		TEXTLINE	*New = EMU_InsertLine( D, EmuData );
		if( New )
			New->Char = SourceLine->Char;
		
		SourceLine->Char = NULL;
		SourceLine = SourceLine->next;

		FreeLine( S->x + 1, EmuData );
	}
}

void	EMU_DeleteLine( long n, EMU_DATA *EmuData )
{
	TEXTLINE	*NewLine;
	CHAR		*Char;
	long	i;
	FreeLine( n, EmuData );
	NewLine = AppendLine( EmuData );
	for( i = 0; i < EmuData->Terminal.x; i++ )
	{
		if(( Char = AppendChar( &( NewLine->Char ))) != NULL )
			SetAttribut( EmuData->Attribut, Char );

	}
}

static void	FreeLine( long n, EMU_DATA *EmuData )
{
	TEXTLINE	**Line = &( EmuData->Line );
	TEXTLINE	*DelLine = GetLine( n, EmuData );

	if( DelLine )
	{
		if( DelLine->next == NULL && *Line == DelLine )
			*Line = NULL;
		else	if( *Line == DelLine )
		{
			*Line = DelLine->next;
			( *Line )->prev = DelLine->prev;
		}
		else	if( DelLine->next == NULL )
		{
			( *Line )->prev = DelLine->prev;
			( DelLine->prev )->next = NULL;
		}
		else
		{
			( DelLine->prev )->next = DelLine->next;
			( DelLine->next )->prev = DelLine->prev;
		}
		FreeChar( DelLine );
		free( DelLine );
		EmuData->nLine--;
	}
}

static TEXTLINE	*GetLine( long n, EMU_DATA *EmuData )
{
	TEXTLINE	*Line = EmuData->Line;
	long	i = 0;
	while( Line )
	{
		if( i == n )
			return( Line );
		Line = Line->next;
		i++;
	}
	return( NULL );
}

/*-----------------------------------------------------------------------------*/
/* CHAR                                                                        */
/*-----------------------------------------------------------------------------*/
static void	InsertChar( char c, EMU_DATA *EmuData )
{
	TEXTLINE	*Line;
	CHAR		*Char;
	XY			Start, End;

	Line = GetLine( EmuData->Cursor.y, EmuData );
	if( !Line )
		printf("Huhu\n");
	Char = GetChar( EmuData->Cursor.x, Line );
	if( !Char )
		return;

	Start.x = EmuData->Cursor.x;
	Start.y = EmuData->Cursor.y;
	End.x = EmuData->Cursor.x;
	End.y = EmuData->Cursor.y;
	EmuData->Cursor.x++;

	Char->C[0] = c;
	Char->C[1] = 0;
	SetAttribut( EmuData->Attribut, Char );

	AppendXyItem( &Start, &End, EmuData );
}

void	EMU_DeleteChar( XY *Start, XY *End, EMU_DATA *EmuData )
{
	TEXTLINE	*Line;
	CHAR	*Char;
	long	i, j;

	Line = GetLine( Start->y, EmuData );
	for( i = Start->x; i <= ( Start->y == End->y ? End->x : EmuData->Terminal.x - 1 ); i++ )
	{
		Char = GetChar( i, Line );
		if( Char )
		{
			Char->C[0] = 0;
			SetAttribut( EmuData->Attribut, Char );
		}
	}

	for( i = Start->y + 1; i <= End->y; i++ )
	{
		Line = GetLine( i, EmuData );
		for( j = 0; j <= ( i == End->y ? End->x : EmuData->Terminal.x - 1 ); j++ )
		{
			Char = GetChar( j, Line );
			if( Char )
			{
				Char->C[0] = 0;
				SetAttribut( EmuData->Attribut, Char );
			}
		}
	}
}

static CHAR	*AppendChar( CHAR **Char )
{
	CHAR	*New = malloc( sizeof( CHAR ));
	if( !New )
		return( NULL );

	if( *Char == NULL )
		*Char = New;
	else
	{
		New->prev = ( *Char )->prev;
		( New->prev )->next = New;
	}
	( *Char )->prev = New;
	New->next = NULL;
	New->C[0] = ' ';
	New->C[1] = 0;
	New->Attribut = NULL;
	return( New );
}
static CHAR	*GetChar( long n, TEXTLINE *Line )
{
	CHAR	*Char = Line->Char;
	long	i = 0;
	while( Char )
	{
		if( i == n )
			return( Char );
		Char = Char->next;
		i++;
	}
	return( NULL );
}
static void	FreeChar( TEXTLINE *Line )
{
	if( Line )
	{
		CHAR	*Char = Line->Char, *Tmp;
		while( Char )
		{
			Tmp = Char->next;
			FreeAttribut( &( Char->Attribut ));
			free( Char );
			Char = Tmp;
		}
		Line->Char = NULL;
	}
}

/*-----------------------------------------------------------------------------*/
/* ATTR                                                                        */
/*-----------------------------------------------------------------------------*/
void	AppendAttribut( ATTR *Attr, ATTR_ITEM **List )
{
	ATTR_ITEM	*New;
	if( Attr == NULL )
		return;
	if(( New = GetAttribut( Attr->A, *List )) == NULL )
	{
		New = malloc( sizeof( ATTR_ITEM ));
		if( !New )
			return;
		if( *List == NULL )
			*List = New;
		else
		{
			New->prev = ( *List )->prev;
			( New->prev )->next = New;
		}
		( *List )->prev = New;
		New->next = NULL;
	}
	New->Attr.A = Attr->A;
	New->Attr.P = Attr->P;
}
static void	SetAttribut( ATTR_ITEM *AttrItem, CHAR *Char )
{
	if( !Char )
		return;

	FreeAttribut( &( Char->Attribut ));

	while( AttrItem )
	{
		AppendAttribut( &( AttrItem->Attr ), &( Char->Attribut ));
		AttrItem = AttrItem->next;
	}
}

void	DeleteAttribut( int A, ATTR_ITEM **List )
{
	ATTR_ITEM	*DelAttr = GetAttribut( A, *List );
	if( DelAttr )
	{
		if( DelAttr->next == NULL && *List == DelAttr )
			*List = NULL;
		else	if( *List == DelAttr )
		{
			*List = DelAttr->next;
			( *List )->prev = DelAttr->prev;
		}
		else	if( DelAttr->next == NULL )
		{
			( *List )->prev = DelAttr->prev;
			( DelAttr->prev )->next = NULL;
		}
		else
		{
			( DelAttr->prev )->next = DelAttr->next;
			( DelAttr->next )->prev = DelAttr->prev;
		}
		free( DelAttr );
	}
}

static ATTR_ITEM	*GetAttribut( int A, ATTR_ITEM *List )
{
	ATTR_ITEM	*AttrItem = List;
	while( AttrItem )
	{
		if( AttrItem->Attr.A == A )
			return( AttrItem );
		AttrItem = AttrItem->next;
	}
	return( NULL );
}

void	FreeAttribut( ATTR_ITEM	**List )
{
	ATTR_ITEM	*AttrItem = *List, *Tmp;

	while( AttrItem )
	{
		Tmp = AttrItem->next;
		free( AttrItem );
		AttrItem = Tmp;
	}
	*List = NULL;
}

/*-----------------------------------------------------------------------------*/
/* XY_ITEM                                                                     */
/*-----------------------------------------------------------------------------*/
void	AppendXyItem( XY *Start, XY *End, EMU_DATA *EmuData )
{
/*	XY_ITEM	**XyItem = &( EmuData->RedrawXy );	*/
	XY_ITEM	*New; /*, *Last = *XyItem && ( *XyItem )->prev ? ( *XyItem )->prev : *XyItem;*/

	if( Start->y > EmuData->Terminal.y + EmuData->PufLines && End->y > EmuData->Terminal.y + EmuData->PufLines )
		return;
	else	if( End->y > EmuData->Terminal.y + EmuData->PufLines )
		End->y = EmuData->Terminal.y + EmuData->PufLines;

/*
	if( Last )
	{
		if( Last->End.y == Start->y && Last->End.x + 1 == Start->x )
		{
			Last->End.x = End->x;
			Last->End.y = End->y;
			return;
		}
		else	if( Last->End.y + 1 == Start->y && Last->End.x == EmuData->Terminal.x - 1 && Start->x == 0 )
		{
			Last->End.x = End->x;
			Last->End.y = End->y;
			return;
		}
	}
*/
/*
	{
		XY_ITEM	*XyItem = EmuData->RedrawXy;
		while( XyItem )
		{
			if( XyItem->Start.y >= Start->y && XyItem->End.y <
			if( XyItem->Start.y <= Start->y && XyItem->End.y < End->y )
			{
				XyItem->Start.x = 0;
				XyItem->End.x = EmuData->Terminal.x - 1;
				XyItem->End.y = End->y;
				return;
			}
			if( XyItem->Start.y > Start->y && XyItem->End.y <= End->y )
			{
				XyItem->Start.x = 0;
				XyItem->End.x = EmuData->Terminal.x - 1;
				XyItem->Start.y = Start->y;
				return;
			}
			XyItem = XyItem->next;
		}
	}
*/
	{
		XY_ITEM	*XyItem = EmuData->RedrawXy;
		while( XyItem )
		{
/* Redraw von Elementen, die bereits in anderen enthalten sind */
			if( XyItem->Start.y <= Start->y && XyItem->End.y >= End->y )
			{
				XyItem->Start.x = 0;
				XyItem->End.x = EmuData->Terminal.x - 1;
				return;
			}
/* Redraw von Elementen, die sich teilweise berschneiden */
			if( XyItem->Start.y >= Start->y && XyItem->End.y >= End->y )
			{
				XyItem->Start.x = 0;
				XyItem->Start.y = Start->y;
				XyItem->End.x = EmuData->Terminal.x - 1;
				return;
			}
			if( XyItem->Start.y <= Start->y && XyItem->End.y <= End->y )
			{
				XyItem->Start.x = 0;
				XyItem->End.x = EmuData->Terminal.x - 1;
				XyItem->End.y = End->y;
				return;
			}
			XyItem = XyItem->next;
		}
	}


	{
		XY_ITEM	*XyItem = EmuData->RedrawXy;
		while( XyItem )
		{
			if( XyItem->Start.y >= Start->y && XyItem->End.y <= End->y )
			{
				XY_ITEM	*Del = XyItem;
				XyItem = XyItem->next;
				Start->x = 0;
				End->x = EmuData->Terminal.x - 1;

				if( Del->next == NULL && EmuData->RedrawXy == Del )
					EmuData->RedrawXy = NULL;
				else	if( EmuData->RedrawXy == Del )
				{
					EmuData->RedrawXy = Del->next;
					( EmuData->RedrawXy )->prev = Del->prev;
				}
				else	if( Del->next == NULL )
				{
					( EmuData->RedrawXy )->prev = Del->prev;
					( Del->prev )->next = NULL;
				}
				else
				{
					( Del->prev )->next = Del->next;
					( Del->next )->prev = Del->prev;
				}
				free( Del );
			}
			else
				XyItem = XyItem->next;
		}
	}

	New = malloc( sizeof( XY_ITEM ));
	if( !New )
		return;

	New->Start.x = Start->x;
	New->Start.y = Start->y;
	New->End.x = End->x;
	New->End.y = End->y;

	if( EmuData->RedrawXy == NULL )
		EmuData->RedrawXy = New;
	else
	{
		New->prev = ( EmuData->RedrawXy )->prev;
		( New->prev )->next = New;
	}
	( EmuData->RedrawXy )->prev = New;
	New->next = NULL;

/*	if( *XyItem == NULL )
	{
		*XyItem = New;
		New->prev = NULL;
	}
	else	if(( Last = ( *XyItem )->prev ) == NULL )
	{
		( *XyItem )->next = New;
		( *XyItem )->prev = New;
		New->prev = *XyItem;
	}
	else
	{
		Last->next = New;
		( *XyItem )->prev = New;
		New->prev = Last;
	}
	New->next = NULL;	*/
}
static void	FreeXyItem( XY_ITEM **XyItem )
{
	XY_ITEM	*Item = *XyItem, *Next;
	while( Item )
	{
		Next = Item->next;
		free( Item );
		Item = Next;
	}
	*XyItem = NULL;
}

CTRL_SEQ	*MakeCtrlSeq( char *Seq )
{
	CTRL_SEQ	*New = malloc( sizeof( CTRL_SEQ ));
	if( New )
	{
		New->Seq = strdup( Seq );
		New->Len = strlen( Seq );
		return( New );
	}
	else
		return( NULL );
}

int	EMU_IsScroll( EMU_DATA *EmuData, XY *S )
{
	S->x = EmuData->nLine - EmuData->Terminal.y + EmuData->Scroll.x;
	S->y = EmuData->nLine - EmuData->Terminal.y + EmuData->Scroll.y;

	if( EmuData->Scroll.x == 0 && EmuData->Scroll.y == EmuData->Terminal.y - 1 )
		return( 0 );

	if( S->x <= EmuData->Cursor.y && S->y >= EmuData->Cursor.y )
		return( 1 );
	else
		return( 0 );
}
