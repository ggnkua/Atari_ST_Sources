#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>
#include	<STRING.H>

#include	<stdio.h>

#include	"ListBox.h"

WORD cdecl	SetLBoxItem( LIST_BOX *LBox, OBJECT *Tree, LBOX_ITEM *Item, WORD Index, void *user_data, GRECT *Rect, WORD Offset )
{
	BYTE	*Ptext;
	BYTE	*Str;
	Ptext = Tree[Index].ob_spec.tedinfo->te_ptext;
	if ( Item )
	{
		if ( Item->selected )
			Tree[Index].ob_state |= SELECTED;
		else
			Tree[Index].ob_state &= ~SELECTED;
		Str = ( BYTE * ) Item->data2;
		if ( Offset == 0 )
		{
			if ( *Ptext )
				*Ptext++ = ' ';
		}
		else
			Offset -= 1;
		if ( Offset <= strlen( Str ))
		{
			Str += Offset;

			while ( *Ptext && *Str )
				*Ptext++ = *Str++;
		}
	}
	else
		Tree[Index].ob_state &= ~SELECTED;
	while ( *Ptext )
		*Ptext++ = ' ';
	return( Index );
}

void cdecl	SlctLBoxItem( LIST_BOX *LBox, OBJECT *DialogTree, LBOX_ITEM *Item, void *user_data, WORD ObjIndex, WORD LastState )
{
	LBOX_DATA	*ListBox = ( LBOX_DATA * ) user_data;
	if( ListBox )
		ListBox->HndlSlctLBoxItem( Item, LastState );
}
