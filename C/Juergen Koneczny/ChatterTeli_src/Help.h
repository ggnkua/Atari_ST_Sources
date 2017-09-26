#ifndef	__BG__
#define	__BG__

#define BUBBLEGEM_SHOW  0xBABB
#define BUBBLEGEM_ACK   0xBABC
#define BUBBLEGEM_REQUEST	0xBABA

WORD	Help_Init( void );
WORD	BG_Action( OBJECT *DialogTree, WORD TreeIdx, WORD ObjIdx, WORD x, WORD y, WORD Global[15] );
WORD	StGuide_Action( OBJECT *DialogTree, WORD TreeIdx, WORD Global[15] );
WORD	StGuide_ActionDirect( OBJECT *DialogTree, WORD TreeIdx, WORD Idx, WORD Global[15] );
void	StGuide( BYTE *Puf, WORD Global[15] );
#endif