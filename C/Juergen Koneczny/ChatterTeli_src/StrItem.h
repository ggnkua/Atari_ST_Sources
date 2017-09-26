#ifndef	__STR_ITEM__
#define	__STR_ITEM__
#include	<PORTAB.H>

/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	struct	__str_item__
{
	struct __str_item__	*next;
	struct __str_item__	*last;
	BYTE	*Str;
} STR_ITEM;

WORD	AppendStrItem( STR_ITEM **StrItem, BYTE *Str );
STR_ITEM	*GetLastStrItem( STR_ITEM *StrItem );
BYTE	*GetStr( LONG n, STR_ITEM *StrItem );
WORD	AddCharStrItem( BYTE Char, STR_ITEM *StrItem );
WORD	AddStrStrItem( BYTE *Str, LONG L, STR_ITEM *StrItem );
#endif