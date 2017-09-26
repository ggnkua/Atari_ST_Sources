WORD	mt_text_create( OBJECT *Tree, WORD Obj, WORD Global[15] );
void	mt_text_set_format( OBJECT *Tree, WORD Obj, WORD TabWidth, WORD AutoWrap, WORD Global[15] );
WORD	mt_text_resized( OBJECT *Tree, WORD Obj, WORD *OldRh, WORD *NewRh, WORD Global[15] );
WORD	mt_text_attach_line( OBJECT *Tree, WORD Obj, BYTE *String, WORD Colour, WORD Global[15] );
void	mt_text_delete( OBJECT *Tree, WORD Obj, WORD Global[15] );

void	mt_text_get_font( OBJECT *Tree, WORD Obj, WORD *Id, WORD *Ht, WORD *Pix, WORD *Mono, WORD Global[15] );
void	mt_text_get_colour( OBJECT *Tree, WORD Obj, WORD *TColour, WORD *BColour, WORD Global[15] );
void	mt_text_get_scrollinfo( OBJECT *Tree, WORD Obj, LONG *nLines, LONG *yScroll, WORD *yVis, WORD *yVal, WORD *nCols, WORD *xScroll, WORD *xVis, WORD Global[15] );
WORD	mt_text_get_dirty( OBJECT *Tree, WORD Obj, WORD Global[15] );
WORD	mt_text_get_colourtable( OBJECT *Tree, WORD Obj, WORD Idx, WORD Global[15] );
WORD	mt_text_get_slct( OBJECT *Tree, WORD Obj, LONG *Start, LONG *End, WORD Global[15] );
LONG	mt_text_get_pufline( OBJECT *Tree, WORD Obj, WORD Global[15] );
BYTE	*mt_text_get_line( OBJECT *Tree, WORD Obj, LONG Line, WORD Global[15] );

void	mt_text_set_font( OBJECT *Tree, WORD Obj, WORD Id, WORD Ht, WORD Pix, WORD Mono, WORD Global[15] );
void	mt_text_set_smicons( OBJECT *Tree, WORD Obj, WORD Flag, WORD Global[15] );
void	mt_text_set_colour( OBJECT *Tree, WORD Obj, WORD TColour, WORD BColour, WORD Global[15] );
WORD	mt_text_scroll( OBJECT *Tree, WORD Obj, WORD WinId, WORD yScroll, WORD xScroll, WORD Global[15] );
void	mt_text_set_dirty( OBJECT *Tree, WORD Obj, WORD Dirty, WORD Global[15] );
void	mt_text_set_pufline( OBJECT *Tree, WORD Obj, LONG Pufline, WORD Global[15] );
void	mt_text_set_colourtable( OBJECT *Tree, WORD Obj, WORD Colour, WORD Idx, WORD Global[15] );
WORD	mt_text_deslct( OBJECT *Tree, WORD Obj, WORD WinId, WORD Global[15] );

WORD	mt_text_evnt( OBJECT *Tree, WORD Obj, WORD WinId, EVNT *Events, WORD Global[15] );