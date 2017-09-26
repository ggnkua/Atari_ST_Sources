#ifndef	__LISTBOX__
#define	__LISTBOX__

typedef void	( *HNDL_SLCT_LBOX_ITEM )( LBOX_ITEM *Item, WORD LastState );
typedef void	( *HNDL_DD_LBOX_ITEM )( void );

typedef	struct
{
	HNDL_SLCT_LBOX_ITEM	HndlSlctLBoxItem;
	HNDL_DD_LBOX_ITEM	HndlDDLboxItem;
}	LBOX_DATA;

WORD cdecl	SetLBoxItem( LIST_BOX *LBox, OBJECT *Tree, LBOX_ITEM *Item, WORD Index, void *user_data, GRECT *Rect, WORD Offset );
void cdecl	SlctLBoxItem( LIST_BOX *LBox, OBJECT *DialogTree, LBOX_ITEM *Item, void *user_data, WORD ObjIndex, WORD LastState );

#endif