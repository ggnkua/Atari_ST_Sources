#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>

#include	<atarierr.h>

#include	"StrItem.h"

WORD	AppendStrItem( STR_ITEM **StrItem, BYTE *Str )
{
	STR_ITEM	*LastItem = *StrItem, *Item = malloc( sizeof( STR_ITEM ));

	if( !Item )
		return( ENSMEM );

	if( *StrItem == NULL )
	{
		*StrItem = Item;
		Item->last = NULL;
	}
	else
	{
		while( LastItem->next )
			LastItem = LastItem->next;
		Item->last = LastItem;
		LastItem->next = Item;
	}
	Item->next = NULL;

	Item->Str = strdup( Str );
	if( !Item->Str )
		return( ENSMEM );

	return( E_OK );
}

BYTE	*GetStr( LONG n, STR_ITEM *StrItem)
{
	LONG	Counter = 0;
	while( StrItem )
	{
		if( Counter == n )
			return( StrItem->Str );
		Counter++;
		StrItem = StrItem->next;
	}
	return( NULL );
}

LONG	GetnLine( STR_ITEM *StrItem )
{
	LONG	Ret = 0;
	while( StrItem )
	{
		Ret++;
		StrItem = StrItem->next;
	}
	return( Ret );
}

STR_ITEM	*GetLastStrItem( STR_ITEM *StrItem )
{
	while( StrItem )
	{
		if( !StrItem->next )
			return( StrItem );
		StrItem = StrItem->next;
	}
	return( NULL );
}

WORD	AddCharStrItem( BYTE Char, STR_ITEM *StrItem )
{
	LONG	l = strlen( StrItem->Str );
	BYTE	*NewStr = realloc( StrItem->Str, l + 2 );
	if( !NewStr )
		return( ENSMEM );
	if( NewStr != StrItem->Str )
	{
		strcpy( NewStr, StrItem->Str );
		free( StrItem->Str );
		StrItem->Str = NewStr;
	}
	StrItem->Str[l] = Char;
	StrItem->Str[l+1] = 0;
	return( E_OK );
}

WORD	AddStrStrItem( BYTE *Str, LONG L, STR_ITEM *StrItem )
{
	LONG	Lold = strlen( StrItem->Str );
	BYTE	*NewStr = realloc( StrItem->Str, Lold + L + 1 );
	if( !NewStr )
		return( ENSMEM );
	if( NewStr != StrItem->Str )
	{
		strcpy( NewStr, StrItem->Str );
		free( StrItem->Str );
		StrItem->Str = NewStr;
	}
	strncat( StrItem->Str, Str, L );
	StrItem->Str[Lold + L] = 0;
	return( E_OK );
}