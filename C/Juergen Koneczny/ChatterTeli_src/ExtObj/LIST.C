#include	<mt_mem.h>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<stdio.h>
#include	<atarierr.h>

#include	"List.h"

typedef struct	__item__
{
	struct __item__	*next;
	struct __item__	*prev;
	char	*Item[COLUMNS];
	int	Colour;
	int	Selected;
}	ITEM;

typedef	struct
{
	ITEM	*Item;
	ITEM	*LastItem;
	int	nColumns;
	int	Sort;
	long	nItems;
}	LIST;

static int	Sort( char *a, char *b );
static void	SortItem( LIST *List, ITEM *New );

void	*ListCreate( int nColumns )
{
	LIST	*List = malloc( sizeof( LIST ));
	if( !List )
		return( NULL );
	List->Item = NULL;
	List->LastItem = NULL;
	List->nColumns = nColumns;
	List->Sort = 0;
	List->nItems = 0;
	return( List );

}
void	ListDelete( void *L )
{
	LIST	*List = L;
	ITEM	*Item = List->Item, *Tmp;
	int	i;
	while( Item )
	{
		Tmp = Item->next;
		for( i = 0; i < List->nColumns; i++ )
			if( Item->Item[i] )
				free( Item->Item[i] );
		free( Item );
		Item = Tmp;
	}
	free( List );
}

void	ListDeleteItem( void *L, long n )
{
	LIST	*List = ( LIST * ) L;
	ITEM	*Item = List->Item;
	long	i = 0;

	if( List->Sort != 0 && ( List->Sort / 2 ) * 2 == List->Sort )
		n = List->nItems - n - 1;

	if( n < 0 || n >= List->nItems )
		return;

	while( n > i )
	{
		Item = Item->next;
		if( !Item )
			break;
		i++;
	}

	if( !Item )
		return;

	if( Item->next )
		( Item->next )->prev = Item->prev;
	else
		List->LastItem = Item->prev;
	if( Item->prev )
		( Item->prev )->next = Item->next;
	else
		List->Item = Item->next;

	for( i = 0; i < List->nColumns; i++ )
	{
		if( Item->Item[i] )
			free( Item->Item[i] );
	}
	free( Item );
	List->nItems--;
}

int	ListAttachItem( void *L, char *Item[], int Colour, int SortFlag )
{
	LIST	*List = ( LIST * ) L;
	ITEM	*New = malloc( sizeof( ITEM ));
	int	i, Ret = E_OK;
	if( !New )
		return( ENSMEM );

	for( i = 0; i < List->nColumns; i++ )
	{
		if( Item[i] )
		{
			New->Item[i] = strdup( Item[i] );
			if( !New->Item[i] )
				Ret = ENSMEM;
		}
		else
			New->Item[i] = NULL;
	}

	New->next = NULL;
	if( List->LastItem )
		( List->LastItem )->next = New;
	New->prev = List->LastItem;
	List->LastItem = New;
	if( List->Item == NULL )
		List->Item = New;
	List->nItems++;
	New->Colour = Colour;
	New->Selected = 0;
	if( SortFlag )
		SortItem( List, New );
	return( Ret );
}

char	**ListGetItem( void *L, long n, int *Colour )
{
	LIST	*List = L;
	ITEM	*Item = List->Item;
	long	i = 0;

	if( !Item )
		return( NULL );

	if( List->Sort != 0 && ( List->Sort / 2 ) * 2 == List->Sort )
		n = List->nItems - n - 1;

	if( n < 0 || n >= List->nItems )
		return( NULL );

	while( n > i )
	{
		Item = Item->next;
		if( !Item )
			break;
		i++;
	}
	if( Item )
	{
		*Colour = Item->Colour;
		return( Item->Item );
	}
	else
		return( NULL );
}

long	ListGetnItem( void *L )
{
	LIST	*List = L;
	return( List->nItems );
}

int	ListGetSort( void *L )
{
	return((( LIST * ) L )->Sort );
}
void	ListSetSort( void *L, int Sort )
{
	LIST	*List = L;
	int	SortOld = List->Sort;
	List->Sort = Sort;
	if(( Sort == SortOld ) || ( Sort != 0 && ( List->Sort - 1 ) / 2 != ( SortOld - 1 ) / 2 ))
	{
		ITEM	*Item = List->Item, *Tmp;
		while( Item )
		{
			Tmp = Item->next;
			SortItem( List, Item );
			Item = Tmp;
		}
	}
}

static int	Sort( char *a, char *b )
{
	if( !a )
		return( -1 );
	if( !b )
		return( 1 );
	while( *a != 0 && *b != 0 )
	{
		if( *a > *b )
			return( 1 );
		if( *a < *b )
			return( -1 );
		a++;
		b++;
	}
	if( *a == 0 )
		return( -1 );
	else	if( *b == 0 )
		return( 1 );
	else
		return( 0 );
}

static void	SortItem( LIST *List, ITEM *New )
{
	ITEM	*Item = List->Item, *a;
	int	Flag, C = ( List->Sort - 1 ) / 2;

	if( List->Sort == 0 )
		return;
	a = New->prev;
	while( a )
	{
		Flag = Sort( a->Item[C], New->Item[C] );
		if( a->prev == NULL || Flag == -1 )
		{
/* Letztes Item soll vor vorletztes Item gesetzt werden */
			if( a == New->prev && Flag == -1 )
				break;

			if( New == List->LastItem )
			{
				List->LastItem = New->prev;
				( List->LastItem )->next = NULL;
			}
			else
			{
				( New->prev )->next = New->next;
				( New->next )->prev = New->prev;
			}

/* Item muž *vor* erstes Item gesetzt werden */
			if( a->prev == NULL && Flag != -1 )
			{
				List->Item = New;
				New->prev = NULL;
				a->prev = New;
				New->next = a;
			}
			else
			{
/* Item vor ein anderes Item setzen */
				New->next = a->next;
				New->prev = a;
				( a->next )->prev = New;
				a->next = New;
			}
			break;
		}
		a = a->prev;
	}

/*	while( Item && Item != New )
	{
		a = Item;
		Flag = Sort( a->Item[C], New->Item[C] );
		if( Flag == 1 )
		{

/* New herausl”sen */
			if( New == List->Item )
			{
				List->Item = New->next;
				( List->Item )->prev = NULL;
			}
			else	if( New == List->LastItem )
			{
				List->LastItem = New->prev;
				( List->LastItem )->next = NULL;
			}
			else
			{
				( New->prev )->next = New->next;
				( New->next )->prev = New->prev;
			}

/* New vor a einbringen */
			if( a == List->Item )
				List->Item = New;
			else
			{
				( a->prev )->next = New;
			}
			New->next = a;
			New->prev = a->prev;
			a->prev = New;
			break;
		}
		Item = Item->next;
	}	*/
}

void	ListSetSelected( void *L, long n, int selected )
{
	LIST	*List = ( LIST * ) L;
	ITEM	*Item = List->Item;
	long	i = 0;

	if( List->Sort != 0 && ( List->Sort / 2 ) * 2 == List->Sort )
		n = List->nItems - n - 1;

	if( n < 0 || n >= List->nItems )
		return;

	while( n > i )
	{
		Item = Item->next;
		if( !Item )
			break;
		i++;
	}

	if( !Item )
		return;

	Item->Selected = selected;
}
int	ListSelected( void *L, long n )
{
	LIST	*List = ( LIST * ) L;
	ITEM	*Item = List->Item;
	long	i = 0;

	if( List->Sort != 0 && ( List->Sort / 2 ) * 2 == List->Sort )
		n = List->nItems - n - 1;

	if( n < 0 || n >= List->nItems )
		return( 0 );

	while( n > i )
	{
		Item = Item->next;
		if( !Item )
			break;
		i++;
	}

	if( !Item )
		return( 0 );
	else
		return( Item->Selected );
}