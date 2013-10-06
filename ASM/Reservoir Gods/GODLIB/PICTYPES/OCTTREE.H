#ifndef	INCLUDED_OCTTREE_H
#define	INCLUDED_OCTTREE_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>
#include	<GODLIB\PICTYPES\CANVAS.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dOCTTREE_CHILD_LIMIT	8
#define	dOCTTREE_DEPTH_LIMIT	4


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct	sOctTreeNode
{
	U32						PixelCount;
	U32						RedSum;
	U32						GreenSum;
	U32						BlueSum;

	U16						Level;
	U16						Index;
	U16						ChildrenCount;				

	U8						LeafFlag;
	U8						MarkFlag;

	struct	sOctTreeNode *	pChild[ dOCTTREE_CHILD_LIMIT ];
	struct	sOctTreeNode *	pNext;
	struct	sOctTreeNode *	pPrev;

} sOctTreeNode;


typedef	struct
{
	sOctTreeNode *	pRoot;
	uCanvasPixel *	pPalette;
	sOctTreeNode **	ppReducibles;

	U32				NodeCount;

	U16				LeafLevel;
	U16				LeafCount;
	U16				Width;
	U16				Height;
	U16				ColourMax;

} sOctTree;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void			OctTreeNode_Init( sOctTreeNode * apNode, U16 aLevel, U8 aLeafFlag );
void			OctTreeNode_AddColour( sOctTreeNode * apNode, uCanvasPixel aColour );
U16				OctTreeNode_FindChild( sOctTreeNode * apNode, uCanvasPixel aColour );
uCanvasPixel	OctTreeNode_GetColour( sOctTreeNode * apNode );


void			OctTree_Init( sOctTree * apTree, U16 aColourCount );
void			OctTree_DeleteTree( sOctTree * apTree );

U8				OctTree_BuildTree( sOctTree * apTree, sCanvas * apCanvas );
void			OctTree_BuildPalette( sOctTree * apTree, sOctTreeNode * apNode, U16 * apIndex );

sOctTreeNode *	OctTree_CreateNode( sOctTree * apTree, U16 aLevel );
U8				OctTree_InsertNode( sOctTree * apTree, sOctTreeNode * apNode, uCanvasPixel aPixel );
void			OctTree_DeleteNode( sOctTree * apTree, sOctTreeNode * apNode );

sOctTreeNode *	OctTree_GetReducible( sOctTree * apTree );
void			OctTree_MakeReducible( sOctTree * apTree, sOctTreeNode * apNode );
void			OctTree_ReduceTree( sOctTree * apTree );

U16				OctTree_QuantizeColour( sOctTree * apTree, sOctTreeNode * apNode, uCanvasPixel aColour );


/* ################################################################################ */

#endif
