#ifndef	EXT_OBJ
#define	EXT_OBJ

#define	COLOUR	64

void	extobj_get_font( WORD Handle, WORD *Id, WORD *Ht, WORD *Pix, WORD *Mono );
void	extobj_get_colour( WORD Handle, WORD *TColour, WORD *BColour );
void	extobj_set_font( WORD Handle, WORD Id, WORD Ht );
void	extobj_set_fontabs( WORD Handle, WORD Id, WORD Pt );
void	extobj_set_colour( WORD Handle, WORD TColour, WORD BColour );
void	extobj_get_fontinfo( WORD Handle, WORD *CellHeight, WORD *dBasicLine );

void	extobj_draw( OBJECT *Tree, WORD Obj, WORD WinId, WORD Global[15] );
#endif