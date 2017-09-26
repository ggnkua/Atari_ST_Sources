#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<stdio.h>

#include	"main.h"
#include	"Rsc.h"

#include	"Edscroll.h"


/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
void	CopyObjects( OBJECT *Tree, OBJECT *NewTree, WORD Count );
static WORD	CountObject( OBJECT *Tree, WORD Idx );
void	FreeObject( OBJECT *Tree, WORD n );


OBJECT	*InsertTree( OBJECT *Tree, WORD Obj, OBJECT *InsTree, WORD InsObj )
{
	WORD	N = CountObject( Tree, 0 ) + 1;
	WORD	InsN = CountObject( InsTree, 0 ) + 1;
	WORD	i;
	OBJECT	*NewTree = malloc( sizeof( OBJECT ) * ( N + InsN ));
	if( !NewTree )
		return( NULL );
	CopyObjects( Tree, NewTree, N );
	CopyObjects( InsTree, &( NewTree[N] ), InsN );

	for( i = 0; i < N; i++ )
		NewTree[i].ob_flags &=  ~LASTOB;
	for( i = N; i < N + InsN; i++ )
	{
		NewTree[i].ob_next += N;
		if( NewTree[i].ob_head != -1 )
			NewTree[i].ob_head += N;
		if( NewTree[i].ob_tail != -1 )
			NewTree[i].ob_tail += N;
	}
	SetInsertObj( Tree, Obj, NewTree, InsObj );
	return( NewTree );
}

WORD	GetInsertOffset( OBJECT *Tree )
{
	return( CountObject( Tree, 0 ) + 1 );
}

void	SetInsertObj( OBJECT *OrigTree, WORD Obj, OBJECT *InsertTree, WORD InsObj )
{
	WORD	N = CountObject( OrigTree, 0 ) + 1;
	InsertTree[Obj].ob_head = N + InsObj;
	InsertTree[Obj].ob_tail = N + InsObj;
	InsertTree[N + InsObj].ob_next = Obj;
	InsertTree[N + InsObj].ob_x = 0;
	InsertTree[N + InsObj].ob_y = 0;
}

OBJECT	*CopyTree( OBJECT *Tree )
{
	WORD	Count = CountObject( Tree, 0 ) + 1;
	OBJECT	*NewTree = malloc( sizeof( OBJECT ) * Count );
	if( !NewTree )
		return( NULL );
	CopyObjects( Tree, NewTree, Count );
	return( NewTree );
}

void	CopyObjects( OBJECT *Tree, OBJECT *NewTree, WORD Count )
{
	WORD	i;
	for( i = 0; i < Count; i++ )
	{
		NewTree[i].ob_next = Tree[i].ob_next;
		NewTree[i].ob_head = Tree[i].ob_head;
		NewTree[i].ob_tail = Tree[i].ob_tail;
		NewTree[i].ob_type = Tree[i].ob_type;
		NewTree[i].ob_flags = Tree[i].ob_flags;
		NewTree[i].ob_state = Tree[i].ob_state;
/*		NewTree[i].ob_spec = Tree[i].ob_spec;*/
		NewTree[i].ob_x = Tree[i].ob_x;
		NewTree[i].ob_y = Tree[i].ob_y;
		NewTree[i].ob_width = Tree[i].ob_width;
		NewTree[i].ob_height = Tree[i].ob_height;
		switch( Tree[i].ob_type & 0xff )
		{
			case	G_BOX:
			case	G_IBOX:
			case	G_BOXCHAR:
				NewTree[i].ob_spec.obspec = Tree[i].ob_spec.obspec;
				break;
			case	G_BUTTON:
			case	G_STRING:
			case	G_TITLE:
				NewTree[i].ob_spec.free_string = ( Tree[i].ob_spec.free_string ? strdup( Tree[i].ob_spec.free_string ) : NULL );
				break;
			case	G_TEXT:
			case	G_BOXTEXT:
			case	G_FTEXT:
			case	G_FBOXTEXT:
				NewTree[i].ob_spec.tedinfo = malloc( sizeof( TEDINFO ));
				NewTree[i].ob_spec.tedinfo->te_font = Tree[i].ob_spec.tedinfo->te_font;
				NewTree[i].ob_spec.tedinfo->te_junk1 = Tree[i].ob_spec.tedinfo->te_junk1;
				NewTree[i].ob_spec.tedinfo->te_just = Tree[i].ob_spec.tedinfo->te_just;
				NewTree[i].ob_spec.tedinfo->te_ucolor.te_color = Tree[i].ob_spec.tedinfo->te_ucolor.te_color;
				NewTree[i].ob_spec.tedinfo->te_junk2 = Tree[i].ob_spec.tedinfo->te_junk2;
				NewTree[i].ob_spec.tedinfo->te_thickness = Tree[i].ob_spec.tedinfo->te_thickness;
				NewTree[i].ob_spec.tedinfo->te_txtlen = Tree[i].ob_spec.tedinfo->te_txtlen;
				NewTree[i].ob_spec.tedinfo->te_tmplen = Tree[i].ob_spec.tedinfo->te_tmplen;
				NewTree[i].ob_spec.tedinfo->te_ptmplt = Tree[i].ob_spec.tedinfo->te_ptmplt ? strdup( Tree[i].ob_spec.tedinfo->te_ptmplt ) : NULL;
				if( !Tree[i].ob_spec.tedinfo->te_ptmplt )
				{
					XTED	*Xted = malloc( sizeof( XTED ));
					WORD	Len = Tree[i].ob_spec.tedinfo->te_tmplen;
					Xted->xte_ptmplt = malloc( Len + 1 );
					memset( Xted->xte_ptmplt, '_', Len );
					( Xted->xte_ptmplt )[Len] = '\0';
					Xted->xte_pvalid = (( XTED * ) Tree[i].ob_spec.tedinfo->te_pvalid )->xte_pvalid ? strdup( (( XTED * ) Tree[i].ob_spec.tedinfo->te_pvalid )->xte_pvalid ) : NULL;
					Xted->xte_vislen = (( XTED * ) Tree[i].ob_spec.tedinfo->te_pvalid )->xte_vislen;
					Xted->xte_scroll = 0;
					NewTree[i].ob_spec.tedinfo->te_pvalid = ( void * ) Xted;
					NewTree[i].ob_spec.tedinfo->te_ptext = calloc( Len, sizeof( BYTE ));
				}
				else
				{
					NewTree[i].ob_spec.tedinfo->te_ptext = ( Tree[i].ob_spec.tedinfo->te_ptext ? strdup( Tree[i].ob_spec.tedinfo->te_ptext ) : NULL );
					NewTree[i].ob_spec.tedinfo->te_pvalid = ( Tree[i].ob_spec.tedinfo->te_pvalid ? strdup( Tree[i].ob_spec.tedinfo->te_pvalid ) : NULL );
				}
				break;
			case	G_ICON:
				NewTree[i].ob_spec.iconblk = malloc( sizeof( ICONBLK ));
				SetIconBlk( NewTree[i].ob_spec.iconblk, Tree[i].ob_spec.iconblk );
				break;
			case	G_CICON:
			{
				CICON	*CiCon = Tree[i].ob_spec.ciconblk->mainlist, *NewCiCon = NULL;
				WORD	A = Tree[i].ob_spec.ciconblk->monoblk.ib_wicon / 8 * Tree[i].ob_spec.ciconblk->monoblk.ib_hicon;
				NewTree[i].ob_spec.ciconblk = malloc( sizeof( CICONBLK ));
				SetIconBlk( &( NewTree[i].ob_spec.ciconblk->monoblk ), &( Tree[i].ob_spec.ciconblk->monoblk ));
				NewTree[i].ob_spec.ciconblk->mainlist = NULL;
				while( CiCon )
				{
					NewCiCon = malloc( sizeof( CICON ));
					if( !NewTree[i].ob_spec.ciconblk->mainlist )
						NewTree[i].ob_spec.ciconblk->mainlist = NewCiCon;
					else
					{
						CICON	*Tmp = NewTree[i].ob_spec.ciconblk->mainlist;
						while( Tmp->next_res )
							Tmp = Tmp->next_res;
						Tmp->next_res = NewCiCon;
					}
					NewCiCon->next_res = NULL;
					NewCiCon->num_planes = CiCon->num_planes;
					NewCiCon->col_data = CiCon->col_data ? malloc( CiCon->num_planes * A ) : NULL;
					NewCiCon->col_mask = CiCon->col_mask ? malloc( CiCon->num_planes * A ) : NULL;
					NewCiCon->sel_data = CiCon->sel_data ? malloc( CiCon->num_planes * A ) : NULL;
					NewCiCon->sel_mask = CiCon->sel_mask ? malloc( CiCon->num_planes * A ) : NULL;
					if( NewCiCon->col_data )
						memcpy( NewCiCon->col_data, CiCon->col_data, CiCon->num_planes * A );
					if( NewCiCon->col_mask )
						memcpy( NewCiCon->col_mask, CiCon->col_mask, CiCon->num_planes * A );
					if( NewCiCon->sel_data )
						memcpy( NewCiCon->sel_data, CiCon->sel_data, CiCon->num_planes * A );
					if( NewCiCon->sel_mask )
						memcpy( NewCiCon->sel_mask, CiCon->sel_mask, CiCon->num_planes * A );
					CiCon = CiCon->next_res;
				}
				break;
			}
		}
	}
}

ICONBLK	*SetIconBlk( ICONBLK *New, ICONBLK *IconBlk )
{
	New->ib_char = IconBlk->ib_char;
	New->ib_xchar = IconBlk->ib_xchar;
	New->ib_ychar = IconBlk->ib_ychar;
	New->ib_xicon = IconBlk->ib_xicon;
	New->ib_yicon = IconBlk->ib_yicon;
	New->ib_wicon = IconBlk->ib_wicon;
	New->ib_hicon = IconBlk->ib_hicon;
	New->ib_xtext = IconBlk->ib_xtext;
	New->ib_ytext = IconBlk->ib_ytext;
	New->ib_wtext = IconBlk->ib_wtext;
	New->ib_htext = IconBlk->ib_htext;
	New->ib_pmask = malloc( IconBlk->ib_wicon / 8 * IconBlk->ib_hicon );
	memcpy( New->ib_pmask, IconBlk->ib_pmask, IconBlk->ib_wicon / 8 * IconBlk->ib_hicon );
	New->ib_pdata = malloc( IconBlk->ib_wicon / 8 * IconBlk->ib_hicon );
	memcpy( New->ib_pdata, IconBlk->ib_pdata, IconBlk->ib_wicon / 8 * IconBlk->ib_hicon );
	New->ib_ptext = IconBlk->ib_ptext ? strdup( IconBlk->ib_ptext ) : NULL;
	return( New );
}
ICONBLK *FreeIconBlk( ICONBLK *IconBlk )
{
	free( IconBlk->ib_pmask );
	free( IconBlk->ib_pdata );
	if( IconBlk->ib_ptext )
		free( IconBlk->ib_ptext );
	return( IconBlk );
}
void	FreeInsertTree( OBJECT *Tree, OBJECT *InsT, OBJECT *DelT )
{
	WORD	N = CountObject( Tree, 0 ) + 1;
	WORD	InsN = CountObject( InsT, 0 ) + 1;
	FreeObject( DelT, N + InsN );
	free( DelT );
}

void	FreeTree( OBJECT *Tree )
{
	WORD	N = CountObject( Tree, 0 ) + 1;
	FreeObject( Tree, N ); 
	free( Tree );
}

void	FreeObject( OBJECT *Tree, WORD n )
{
	if( Tree )
	{
		WORD	i;
		for( i = 0; i < n ; i++ )
		{
			switch( Tree[i].ob_type & 0xff )
			{
				case	G_BUTTON:
				case	G_STRING:
				case	G_TITLE:
					free( Tree[i].ob_spec.free_string );
					break;
				case	G_TEXT:
				case	G_BOXTEXT:
				case	G_FTEXT:
				case	G_FBOXTEXT:
					if( Tree[i].ob_spec.tedinfo->te_ptext )
						free( Tree[i].ob_spec.tedinfo->te_ptext );
					if( Tree[i].ob_spec.tedinfo->te_ptmplt )
					{
						free( Tree[i].ob_spec.tedinfo->te_ptmplt );
						if( Tree[i].ob_spec.tedinfo->te_pvalid )
							free( Tree[i].ob_spec.tedinfo->te_pvalid );
					}
					else
					{
						XTED	*Xted = ( XTED * ) Tree[i].ob_spec.tedinfo->te_pvalid;
						free( Xted->xte_ptmplt );
						free( Xted->xte_pvalid );
						free( Xted );
					}
					free( Tree[i].ob_spec.tedinfo );
					break;
				case	G_ICON:
					free( FreeIconBlk( Tree[i].ob_spec.iconblk ));
					break;
				case	G_CICON:
				{
					CICON	*CiCon = Tree[i].ob_spec.ciconblk->mainlist, *Tmp;
					FreeIconBlk( &( Tree[i].ob_spec.ciconblk->monoblk ));
					while( CiCon )
					{
						Tmp = CiCon->next_res;
						if( CiCon->col_data )
							free( CiCon->col_data );
						if( CiCon->col_mask )
							free( CiCon->col_mask );
						if( CiCon->sel_data )
							free( CiCon->sel_data );
						if( CiCon->sel_mask )
							free( CiCon->sel_mask );
						free( CiCon );
						CiCon = Tmp;
					}
					free( Tree[i].ob_spec.ciconblk );
					break;
				}
				case	G_USERDEF:
				{
					break;
				}
			}
		}
	}
}

WORD	GetParentObject( OBJECT *Tree, WORD Obj )
{
	while( Tree[Obj].ob_next != - 1 && Tree[Tree[Obj].ob_next].ob_tail != Obj )
		Obj = Tree[Obj].ob_next;
	return( Tree[Obj].ob_next );
}

static WORD	CountObject( OBJECT *Tree, WORD Idx )
{
	WORD	Count = 0, i = Tree[Idx].ob_head;
	if( i == -1 )
		return( 0 );
	do
	{
		if( Tree[i].ob_head != -1 )
			Count += CountObject( Tree, i );
		Count++;
		i = Tree[i].ob_next;
	}
	while( i != Idx );
	return( Count );
}
