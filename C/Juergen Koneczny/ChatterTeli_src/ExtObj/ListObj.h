#define	LISTOBJ_SHOW_SELECTED	0x01
#define	LISTOBJ_SHOW_COLOUR		0x02
#define	LISTOBJ_MULTIPLE			0x04

WORD	mt_list_create( OBJECT *Tree, WORD Obj, WORD nColumns, WORD Global[15] );
WORD	mt_list_evnt( OBJECT *Tree, WORD Obj, WORD WinId, EVNT *Events, WORD Global[15] );
void	mt_list_set_sort( OBJECT *Tree, WORD Obj, WORD Sort, WORD Global[15] );
void	mt_list_set_format( OBJECT *Tree, WORD Obj, WORD Width[], WORD Global[15] );
WORD	mt_list_resize( OBJECT *Tree, WORD Obj, WORD *OldRh, WORD *NewRh, WORD Global[15] );
WORD	mt_list_attach_item( OBJECT *Tree, WORD Obj, BYTE **Item, WORD Colour, WORD SortFlag, WORD Global[15] );
void	mt_list_delete_item( OBJECT *Tree, WORD Obj, LONG n, WORD Global[15] );
void	mt_list_delete( OBJECT *Tree, WORD Obj, WORD Global[15] );

BYTE	**mt_list_get_item( OBJECT *Tree, WORD Obj, LONG n, WORD *Colour, WORD Global[15] );
WORD	mt_list_get_sort( OBJECT *Tree, WORD Obj, WORD Global[15] );
void	mt_list_get_font( OBJECT *Tree, WORD Obj, WORD *Id, WORD *Ht, WORD *Pix, WORD *Mono, WORD Global[15] );
void	mt_list_get_colour( OBJECT *Tree, WORD Obj, WORD *TColour, WORD *BColour, WORD Global[15] );
void	mt_list_get_scrollinfo( OBJECT *Tree, WORD Obj, LONG *nLines, LONG *yScroll, WORD *yVis, WORD *nCols, WORD *xScroll, WORD *xVis, WORD Global[15] );
WORD	mt_list_get_dirty( OBJECT *Tree, WORD Obj, WORD Global[15] );
WORD	mt_list_get_selected( OBJECT *Tree, WORD Obj, WORD Global[15] );
WORD	mt_list_get_colourtable( OBJECT *Tree, WORD Obj, WORD Idx, WORD Global[15] );

void	mt_list_set_font( OBJECT *Tree, WORD Obj, WORD Id, WORD Ht, WORD Pix, WORD Mono, WORD Global[15] );
void	mt_list_set_colour( OBJECT *Tree, WORD Obj, WORD TColour, WORD BColour, WORD Global[15] );
WORD	mt_list_scroll( OBJECT *Tree, WORD Obj, WORD WinId, WORD yScroll, WORD xScroll, WORD Global[15] );
void	mt_list_set_dirty( OBJECT *Tree, WORD Obj, WORD Dirty, WORD Global[15] );
void	mt_list_set_selected( OBJECT *Tree, WORD Obj, WORD WinId, WORD Selected, WORD Global[15] );
void	mt_list_set_colourtable( OBJECT *Tree, WORD Obj, WORD Colour, WORD Idx, WORD Global[15] );
void	mt_list_set_mode( OBJECT *Tree, WORD Obj, WORD Mode, WORD Global[15] );

WORD	mt_list_is_selected( OBJECT *Tree, WORD Obj, LONG n, WORD Global[15] );