OBJECT	*CopyTree( OBJECT *Tree );
WORD		GetParentObject( OBJECT *Tree, WORD Obj );

OBJECT	*InsertTree( OBJECT *Tree, WORD Obj, OBJECT *InsT, WORD InsObj );
void		SetInsertObj( OBJECT *Orig, WORD Obj, OBJECT *InsertTree, WORD InsObj );
WORD		GetInsertOffset( OBJECT *Tree );
void		FreeTree( OBJECT *Tree );
void		FreeInsertTree( OBJECT *Tree, OBJECT *InstT, OBJECT *DelT );
ICONBLK	*SetIconBlk( ICONBLK *New, ICONBLK *IconBlk );
ICONBLK	*FreeIconBlk( ICONBLK *IconBlk );
