/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: OCTTREE.C
::
:: Routines for octtree colour quantisation
::
:: based on paper 'Octtree Colour Quantisation' by Ian Ashdown
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"OCTTREE.H"

#include	<GODLIB\MEMORY\MEMORY.H>


/* ###################################################################################
#  FUNCTIONS
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTreeNode_Init( sOctTreeNode * apNode, U16 aLevel, U8 aLeafFlag )
* DESCRIPTION : initialises a node
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			OctTreeNode_Init( sOctTreeNode * apNode, U16 aLevel, U8 aLeafFlag )
{
	U16	i;

	apNode->RedSum        = 0;
	apNode->BlueSum       = 0;
	apNode->GreenSum      = 0;

	apNode->ChildrenCount = 0;
	apNode->Index         = 0;
	apNode->PixelCount    = 0;
	apNode->LeafFlag      = aLeafFlag;
	apNode->Level         = aLevel;
	apNode->pNext         = 0;
	apNode->pPrev         = 0;

	for( i=0; i<dOCTTREE_CHILD_LIMIT; i++ )
		apNode->pChild[ i ] = 0;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTreeNode_AddColour( sOctTreeNode * apNode, uCanvasPixel aColour )
* DESCRIPTION : adds a colour to an octtree node
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

void	OctTreeNode_AddColour( sOctTreeNode * apNode, uCanvasPixel aColour )
{
	apNode->RedSum   += aColour.b.r;
	apNode->GreenSum += aColour.b.g;
	apNode->BlueSum  += aColour.b.b;

	apNode->PixelCount++;
}

/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTreeNode_FindChild( sOctTreeNode * apNode, uCanvasPixel aColour )
* DESCRIPTION : returns index for a child
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

U16		OctTreeNode_FindChild( sOctTreeNode * apNode, uCanvasPixel aColour )
{
	U16	lIndex;
	U16	lShift;

	lShift = (dOCTTREE_DEPTH_LIMIT - apNode->Level);

	lIndex  = ( (aColour.b.r >> lShift) & 1 ) << 2;
	lIndex |= ( (aColour.b.g >> lShift) & 1 ) << 1;
	lIndex |= ( (aColour.b.b >> lShift) & 1 );

	return( lIndex );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTreeNode_GetColour( sOctTreeNode * apNode )
* DESCRIPTION : returns averaged colour for a node
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

uCanvasPixel	OctTreeNode_GetColour( sOctTreeNode * apNode )
{
	uCanvasPixel	lColour;

	lColour.b.r = (U8)( apNode->RedSum   / apNode->PixelCount );
	lColour.b.g = (U8)( apNode->GreenSum / apNode->PixelCount );
	lColour.b.b = (U8)( apNode->BlueSum  / apNode->PixelCount );

	return( lColour );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_Init( sOctTree * apTree )
* DESCRIPTION : initialises an octree
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			OctTree_Init( sOctTree * apTree, U16 aColourLimit )
{
	U16	i;

	apTree->ColourMax = aColourLimit;
	apTree->Height    = 0;
	apTree->LeafCount = 0;
	apTree->LeafLevel = dOCTTREE_DEPTH_LIMIT + 1;
	apTree->pRoot     = 0;
	apTree->pPalette  = 0;
	apTree->Width     = 0;

	apTree->NodeCount = 0;

	apTree->ppReducibles = (sOctTreeNode**)Memory_Calloc( (dOCTTREE_DEPTH_LIMIT+1) * 4 );

	for( i=0; i<apTree->LeafLevel; i++ )
	{
		apTree->ppReducibles[ i ] = 0;
	}

	apTree->pPalette = (uCanvasPixel*)Memory_Alloc( apTree->ColourMax * sizeof(uCanvasPixel) );

	for( i=0; i<apTree->ColourMax; i++ )
	{
		apTree->pPalette[ i ].l = 0;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_CreateNode( sOctTree * apTree, U16 aLevel )
* DESCRIPTION : creates a node in an octree
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

sOctTreeNode *	OctTree_CreateNode( sOctTree * apTree, U16 aLevel )
{
	sOctTreeNode *	lpNode;
	U8				lLeafFlag;

	apTree->NodeCount++;

	if( aLevel >= apTree->LeafLevel )
	{
		lLeafFlag = 1;
		apTree->LeafCount++;
	}
	else
	{
		lLeafFlag = 0;
	}

	lpNode = (sOctTreeNode*)Memory_Alloc( sizeof(sOctTreeNode) );

	if( lpNode )
		OctTreeNode_Init( lpNode, aLevel, lLeafFlag );

	return( lpNode );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_DeleteNode( sOctTree * apTree, sOctTreeNode * apNode )
* DESCRIPTION : deletes a node from an octtree
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			OctTree_DeleteNode( sOctTree * apTree, sOctTreeNode * apNode )
{
	U16	i;

	apTree->NodeCount--;

	if( apNode )
	{	
		if( !apNode->LeafFlag )
		{
			for( i=0; i<dOCTTREE_CHILD_LIMIT; i++ )
			{
				if( apNode->pChild[ i ] )
				{
					OctTree_DeleteNode( apTree, apNode->pChild[ i ] );
					apNode->pChild[ i ] = 0;
					apNode->ChildrenCount--;
				}
			}
		}
		else
		{
			apTree->LeafCount--;
		}

		Memory_Release( apNode );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_QuantizeColour( sOctTree * apTree, sOctTreeNode * apNode, uCanvasPixel aColour )
* DESCRIPTION : returns index for colour aColour
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

U16				OctTree_QuantizeColour( sOctTree * apTree, sOctTreeNode * apNode, uCanvasPixel aColour )
{
	U16	lIndex;

	if( (apNode->LeafFlag) || (apNode->Level == apTree->LeafLevel) )
	{
		lIndex = apNode->Index;
	}
	else
	{
		lIndex = OctTreeNode_FindChild( apNode, aColour );
		lIndex = OctTree_QuantizeColour( apTree, apNode->pChild[ lIndex ], aColour );
	}

	return( lIndex );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_MakeReducible( sOctTree * apTree, sOctTreeNode * apNode )
* DESCRIPTION : returns index for colour aColour
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			OctTree_MakeReducible( sOctTree * apTree, sOctTreeNode * apNode )
{
	U16				lLevel;
	sOctTreeNode *	lpHead;
	
	lLevel        = apNode->Level;
	lpHead        = apTree->ppReducibles[ lLevel ];
	apNode->pNext = lpHead;

	if( lpHead )
		lpHead->pPrev = apNode;

	apTree->ppReducibles[ lLevel ] = apNode;
	apNode->MarkFlag               = 1;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_ReduceTree( sOctTree * apTree )
* DESCRIPTION : returns index for colour aColour
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			OctTree_ReduceTree( sOctTree * apTree )
{
	sOctTreeNode *	lpNode;
	sOctTreeNode *	lpChild;
	U16				i;

	lpNode = OctTree_GetReducible( apTree );

	if( lpNode )
	{
		for( i=0; i<dOCTTREE_CHILD_LIMIT; i++ )
		{
			lpChild = lpNode->pChild[ i ];

			if( lpChild )
			{
				OctTree_DeleteNode( apTree, lpChild );
				lpNode->pChild[ i ] = 0;
				lpNode->ChildrenCount--;
			}
		}

		lpNode->LeafFlag = 1;
		apTree->LeafCount++;

		if( lpNode->Level < (apTree->LeafLevel-1) )
			apTree->LeafLevel = lpNode->Level + 1;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_InsertNode( sOctTree * apTree, OctNode * apNode, uCanvasPixel aColour )
* DESCRIPTION : inserts a node into an octree
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8				OctTree_InsertNode( sOctTree * apTree, sOctTreeNode * apNode, uCanvasPixel aColour )
{
	sOctTreeNode *	lpChild;
	U16				lLevel;
	U16				lIndex;

	lLevel = apNode->Level;

	OctTreeNode_AddColour( apNode, aColour );

	if( (!apNode->LeafFlag) && (lLevel < apTree->LeafLevel) )
	{
		lIndex = OctTreeNode_FindChild( apNode, aColour );

		lpChild = apNode->pChild[ lIndex ];

		if( !lpChild )
		{
			lpChild = OctTree_CreateNode( apTree, lLevel+1 );

			if( !lpChild )
				return( 0 );

			apNode->pChild[ lIndex ] = lpChild;
			apNode->ChildrenCount++;
		}

		if( ( apNode->ChildrenCount > 1 ) && ( !apNode->MarkFlag ) )
		{
			OctTree_MakeReducible( apTree, apNode );
		}

		return( OctTree_InsertNode( apTree, lpChild, aColour ) );
	}

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_ReduceTree( sOctTree * apTree )
* DESCRIPTION : returns index for colour aColour
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			OctTree_BuildPalette( sOctTree * apTree, sOctTreeNode * apNode, U16 * apIndex )
{
	U16	i;

	if( apNode )
	{
		if( (apNode->LeafFlag) || (apNode->Level == apTree->LeafLevel) )
		{
			apTree->pPalette[ *apIndex ] = OctTreeNode_GetColour( apNode );
			apNode->Index                = *apIndex;
			*apIndex                     = (*apIndex) + 1;
		}
		else
		{
			for( i=0; i<dOCTTREE_CHILD_LIMIT; i++ )
			{
				OctTree_BuildPalette( apTree, apNode->pChild[ i ], apIndex );
			}
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_GetReducible( sOctTree * apTree )
* DESCRIPTION : returns reducible node
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

sOctTreeNode *	OctTree_GetReducible( sOctTree * apTree )
{
	sOctTreeNode *	lpReduc;
	sOctTreeNode *	lpMostPixels;
	sOctTreeNode *	lpNext;
	sOctTreeNode *	lpPrev;
	U16				lReducIndex;

	lReducIndex = apTree->LeafLevel - 1;

	while(( !apTree->ppReducibles[ lReducIndex ] ) && (lReducIndex) )
		lReducIndex--;

	lpReduc = apTree->ppReducibles[ lReducIndex ];

	if( !lpReduc )
		return( 0 );

	lpMostPixels = lpReduc;
	while( lpReduc )
	{
		if( lpReduc->PixelCount > lpMostPixels->PixelCount )
		{
			lpMostPixels = lpReduc;
		}

		lpReduc = lpReduc->pNext;
	}

	lpNext = lpMostPixels->pNext;
	lpPrev = lpMostPixels->pPrev;

	if( !lpPrev )
	{
		apTree->ppReducibles[ lReducIndex ] = lpNext;
	}
	else
	{
		lpPrev->pNext = lpNext;
	}

	if( lpNext )
		lpNext->pPrev = lpPrev;

	lpMostPixels->pPrev    = 0;
	lpMostPixels->pNext    = 0;
	lpMostPixels->MarkFlag = 0;

	return( lpMostPixels );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_BuildTree( sOctTree * apTree, sCanvas * apCanvas )
* DESCRIPTION : builds octree
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8		OctTree_BuildTree( sOctTree * apTree, sCanvas * apCanvas )
{
	uCanvasPixel	lColour;
	U16				x,y;

	apTree->pRoot = OctTree_CreateNode( apTree, 0 );

	if( !apTree->pRoot )
		return( 0 );

	for( y=0; y<apCanvas->Height; y++ )
	{
		for( x=0; x<apCanvas->Width; x++ )
		{
			lColour = Canvas_GetPixel( apCanvas, x, y );

			if( !OctTree_InsertNode( apTree, apTree->pRoot, lColour ) )
			{
				OctTree_DeleteNode( apTree, apTree->pRoot );
				return( 0 );
			}

			if( apTree->LeafCount > apTree->ColourMax )
			{
				OctTree_ReduceTree( apTree );
			}
		}
	}

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : OctTree_DeleteTree( sOctTree * apTree )
* DESCRIPTION : builds octree
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			OctTree_DeleteTree( sOctTree * apTree )
{
	OctTree_DeleteNode( apTree, apTree->pRoot );

	if( apTree->pPalette )
		Memory_Release( apTree->pPalette );

	if( apTree->ppReducibles )
		Memory_Release( apTree->ppReducibles );
}
