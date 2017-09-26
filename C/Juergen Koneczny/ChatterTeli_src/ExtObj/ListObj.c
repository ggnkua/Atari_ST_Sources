#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"Bitmap.h"
#include	"ExtObj\ExtObj.h"
#include	"ExtObj\ListObj.h"
#include	"ExtObj\List.h"

typedef	struct
{
	BITMAP	*Bitmap;
	WORD		Dirty;
	WORD		InternDirty;
	WORD		Rh;
	WORD		CellHeight;
	WORD		dBasicLine;

	void		*List;

	WORD		yScroll;
	WORD		yVis;

	WORD		Selected;
	WORD		Mode;

	WORD		nColumns;
	WORD		Width[COLUMNS];
	WORD		ColourTable[COLOUR];
}	EXTOBJ;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl UbCode( PARMBLK *ParmBlock );
static void Draw( OBJECT *Tree, WORD Obj );

/*-----------------------------------------------------------------------------*/
/* mt_list_create                                                              */
/*-----------------------------------------------------------------------------*/
WORD	mt_list_create( OBJECT *Tree, WORD Obj, WORD nColumns, WORD Global[15] )
{
	USERBLK	*UserBlk = malloc( sizeof( USERBLK ));
	EXTOBJ	*ExtObj = malloc( sizeof( EXTOBJ ));
	WORD		i;
	if( !UserBlk || !ExtObj )
		return( ENSMEM );

	for( i = 0; i < nColumns; i++ )
		ExtObj->Width[i] = Tree[Obj].ob_width / nColumns;

	if(( ExtObj->List = ListCreate( nColumns )) == NULL )
	{
		free( ExtObj );
		free( UserBlk );
		return( ERROR );
	}

	UserBlk->ub_code = UbCode;
	( EXTOBJ * ) UserBlk->ub_parm = ExtObj;
	Tree[Obj].ob_spec.userblk = UserBlk;

	ExtObj->Selected = -1;
	ExtObj->Mode = LISTOBJ_SHOW_SELECTED;
	ExtObj->Dirty = 0;
	ExtObj->InternDirty = 0;
	ExtObj->yScroll = 0;
	ExtObj->yVis = 0;

	ExtObj->nColumns = nColumns;

	if(( ExtObj->Bitmap = BitmapNew( Tree[Obj].ob_width, Tree[Obj].ob_height )) == NULL )
	{
		ListDelete( ExtObj->List );
		free( ExtObj );
		free( UserBlk );
		return( ERROR );
	}
	extobj_get_fontinfo( ExtObj->Bitmap->BmHandle, &( ExtObj->CellHeight ), &( ExtObj->dBasicLine ));

	ExtObj->Rh = Tree[Obj].ob_height;
	ExtObj->yVis = ( Tree[Obj].ob_height ) / ExtObj->CellHeight;

	for( i = 0; i < COLOUR; i++ )
		ExtObj->ColourTable[i] = 1;

	Draw( Tree, Obj );
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_evnt                                                                */
/*-----------------------------------------------------------------------------*/
WORD	mt_list_evnt( OBJECT *Tree, WORD Obj, WORD WinId, EVNT *Events, WORD Global[15] )
{
	if( Events->mclicks && MT_objc_find( Tree, ROOT, MAX_DEPTH, Events->mx, Events->my, Global ) == Obj )
	{
		WORD	x, y, Slct;
		EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
		MT_objc_offset( Tree, Obj, &x, &y, Global );
		if( ExtObj->Mode == LISTOBJ_MULTIPLE )
		{
			if(( Slct = ( Events->my - y ) / ExtObj->CellHeight + ExtObj->yScroll ) < ListGetnItem( ExtObj->List ))
			{
				WORD	State = ListSelected( ExtObj->List, Slct );
				if( !State && ( Events->kstate ))
				{
					ListSetSelected( ExtObj->List, Slct, 1 );
					ExtObj->Selected++;
					Draw( Tree, Obj );
					extobj_draw( Tree, Obj, WinId, Global );
				}
				else	if( !State && !( Events->kstate ))
				{
					LONG	i;
					for( i = 0; i < ListGetnItem( ExtObj->List ); i++ )
						ListSetSelected( ExtObj->List, i, 0 );
					ListSetSelected( ExtObj->List, Slct, 1 );
					ExtObj->Selected = 1;
					Draw( Tree, Obj );
					extobj_draw( Tree, Obj, WinId, Global );
				}
				if( State && ( Events->kstate ))
				{
					ListSetSelected( ExtObj->List, Slct, 0 );
					ExtObj->Selected--;
					Draw( Tree, Obj );
					extobj_draw( Tree, Obj, WinId, Global );
				}
			}
		}
		else
		{
			if(( Slct = ( Events->my - y ) / ExtObj->CellHeight + ExtObj->yScroll ) < ListGetnItem( ExtObj->List ))
			{
				if( ExtObj->Selected == Slct )
				{
					if( Events->mclicks == 1 )
					{
/*					if( Events->mbutton )
						return( E_OK );	*/
					ExtObj->Selected = -1;
					}
					else
						return( -1 );
				}
				else
					ExtObj->Selected = Slct;
				if( ExtObj->Mode == LISTOBJ_SHOW_SELECTED )
				{
					Draw( Tree, Obj );
					extobj_draw( Tree, Obj, WinId, Global );
				}
				if( Events->mclicks == 2 )
					return( -1 );
			}
		}
		if( ExtObj->Mode == LISTOBJ_SHOW_SELECTED || ExtObj->Mode == LISTOBJ_MULTIPLE )
		{
			EVNTDATA	Evt;
			do
			{
				MT_graf_mkstate( &Evt, Global );
			}
			while( Evt.bstate );
		}
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_delete_item                                                         */
/*-----------------------------------------------------------------------------*/
void	mt_list_delete_item( OBJECT *Tree, WORD Obj, LONG n, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	if( ExtObj->Mode == LISTOBJ_MULTIPLE )
	{
		if( ListSelected( ExtObj->List, n ))
			ExtObj->Selected--;
	}
	ListDeleteItem( ExtObj->List, n );
	if( ExtObj->yScroll > ListGetnItem( ExtObj->List ) - ExtObj->yVis )
		ExtObj->yScroll = ListGetnItem( ExtObj->List ) - ExtObj->yVis;
	if( ExtObj->yScroll < 0 )
		ExtObj->yScroll = 0;
	ExtObj->InternDirty = 1;
	ExtObj->Dirty = 1;	
}

/*-----------------------------------------------------------------------------*/
/* mt_list_delete                                                              */
/*-----------------------------------------------------------------------------*/
void	mt_list_delete( OBJECT *Tree, WORD Obj, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	BitmapDelete( ExtObj->Bitmap );
	ListDelete( ExtObj->List );
	free(( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm );
	free( Tree[Obj].ob_spec.userblk );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_attach_item                                                         */
/*-----------------------------------------------------------------------------*/
WORD	mt_list_attach_item( OBJECT *Tree, WORD Obj, BYTE **Item, WORD Colour, WORD SortFlag, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	Ret;
	if(( Ret = ListAttachItem( ExtObj->List, Item, Colour, SortFlag )) != E_OK )
		return( Ret );

	ExtObj->Dirty = 1;
	ExtObj->InternDirty = 1;
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_get_item                                                            */
/*-----------------------------------------------------------------------------*/
BYTE	**mt_list_get_item( OBJECT *Tree, WORD Obj, LONG n, WORD *Colour, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	if( n >= 0 )
		return( ListGetItem( ExtObj->List, n, Colour ));
	else
		return( NULL );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_get_font                                                            */
/*-----------------------------------------------------------------------------*/
void	mt_list_get_font( OBJECT *Tree, WORD Obj, WORD *Id, WORD *Ht, WORD *Pix, WORD *Mono, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	extobj_get_font( ExtObj->Bitmap->BmHandle, Id, Ht, Pix, Mono );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_get_colour                                                          */
/*-----------------------------------------------------------------------------*/
void	mt_list_get_colour( OBJECT *Tree, WORD Obj, WORD *TColour, WORD *BColour, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	extobj_get_colour( ExtObj->Bitmap->BmHandle, TColour, BColour );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_get_sort                                                            */
/*-----------------------------------------------------------------------------*/
WORD	mt_list_get_sort( OBJECT *Tree, WORD Obj, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	return( ListGetSort( ExtObj->List ));
}

/*-----------------------------------------------------------------------------*/
/* mt_list_get_scrollinfo                                                      */
/*-----------------------------------------------------------------------------*/
void	mt_list_get_scrollinfo( OBJECT *Tree, WORD Obj, LONG *nLines, LONG *yScroll, WORD *yVis, WORD *nCols, WORD *xScroll, WORD *xVis, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	*nLines = ListGetnItem( ExtObj->List );
	*yScroll = ExtObj->yScroll;
	*yVis = ExtObj->yVis;
	*nCols = -1;
	*xVis = Tree[Obj].ob_width;
}

/*-----------------------------------------------------------------------------*/
/* mt_list_get_selected                                                        */
/*-----------------------------------------------------------------------------*/
WORD	mt_list_get_selected( OBJECT *Tree, WORD Obj, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	return( ExtObj->Selected );
}

WORD	mt_list_is_selected( OBJECT *Tree, WORD Obj, LONG n, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	if( ExtObj->Mode == LISTOBJ_MULTIPLE )
		return( ListSelected( ExtObj->List, n ));
	else
	{
		if( n == ExtObj->Selected )
			return( 1 );
		else
			return( 0 );
	}
}

/*-----------------------------------------------------------------------------*/
/* mt_list_set_dirty                                                           */
/*-----------------------------------------------------------------------------*/
void	mt_list_set_dirty( OBJECT *Tree, WORD Obj, WORD Dirty, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ExtObj->Dirty = Dirty;
}
/*-----------------------------------------------------------------------------*/
/* mt_list_get_dirty                                                           */
/*-----------------------------------------------------------------------------*/
WORD	mt_list_get_dirty( OBJECT *Tree, WORD Obj, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	return( ExtObj->Dirty );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_set_colourtable                                                     */
/*-----------------------------------------------------------------------------*/
void	mt_list_set_colourtable( OBJECT *Tree, WORD Obj, WORD Colour, WORD Idx, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ExtObj->ColourTable[Idx] = Colour;
	Draw( Tree, Obj );
	ExtObj->Dirty = 1;
}

/*-----------------------------------------------------------------------------*/
/* mt_list_get_colourtable                                                     */
/*-----------------------------------------------------------------------------*/
WORD	mt_list_get_colourtable( OBJECT *Tree, WORD Obj, WORD Idx, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	return( ExtObj->ColourTable[Idx] );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_set_mode                                                            */
/*-----------------------------------------------------------------------------*/
void	mt_list_set_mode( OBJECT *Tree, WORD Obj, WORD Mode, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ExtObj->Mode = Mode;
}

/*-----------------------------------------------------------------------------*/
/* mt_list_set_font                                                            */
/*-----------------------------------------------------------------------------*/
void	mt_list_set_font( OBJECT *Tree, WORD Obj, WORD Id, WORD Ht, WORD Pix, WORD Mono, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	if( Pix )
		extobj_set_fontabs( ExtObj->Bitmap->BmHandle, Id, Ht );
	else		
		extobj_set_font( ExtObj->Bitmap->BmHandle, Id, Ht );
	extobj_get_fontinfo( ExtObj->Bitmap->BmHandle, &( ExtObj->CellHeight ), &( ExtObj->dBasicLine ));
	Draw( Tree, Obj );
}
/*-----------------------------------------------------------------------------*/
/* mt_list_set_colour                                                          */
/*-----------------------------------------------------------------------------*/
void	mt_list_set_colour( OBJECT *Tree, WORD Obj, WORD TColour, WORD BColour, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;

	if( TColour == -1 )
	{
		WORD	Text[10];
		vqt_attributes( ExtObj->Bitmap->BmHandle, Text );
		TColour = Text[1];
	}
	if( BColour == -1 )
	{
		WORD	Fill[5];
		vqf_attributes( ExtObj->Bitmap->BmHandle, Fill );
		BColour = Fill[1];
	}
	extobj_set_colour( ExtObj->Bitmap->BmHandle, TColour, BColour );
	Draw( Tree, Obj );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_set_sort                                                            */
/*-----------------------------------------------------------------------------*/
void	mt_list_set_sort( OBJECT *Tree, WORD Obj, WORD Sort, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ListSetSort( ExtObj->List, Sort );
	ExtObj->Dirty = 1;
	Draw( Tree, Obj );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_set_format                                                          */
/*-----------------------------------------------------------------------------*/
void	mt_list_set_format( OBJECT *Tree, WORD Obj, WORD Width[], WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	i;
	for( i = 0; i < ExtObj->nColumns; i++ )
		ExtObj->Width[i] = Width[i];
	ExtObj->Width[0] -= 1;
	Draw( Tree, Obj );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_scroll                                                              */
/*-----------------------------------------------------------------------------*/
WORD	mt_list_scroll( OBJECT *Tree, WORD Obj, WORD WinId, WORD yScroll, WORD xScroll, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	Ret = 1, OldyScroll = ExtObj->yScroll;

	if( yScroll == 0x7fff )
		ExtObj->yScroll = ListGetnItem( ExtObj->List ) - ExtObj->yVis;
	else
		ExtObj->yScroll += yScroll;
	if( ExtObj->yScroll > ListGetnItem( ExtObj->List ) - ExtObj->yVis )
	{
		ExtObj->yScroll = ListGetnItem( ExtObj->List ) - ExtObj->yVis;
		Ret = 0;
	}
	if( ExtObj->yScroll < 0 )
	{
		ExtObj->yScroll = 0;
		Ret = 0;
	}

	if( ExtObj->yScroll != OldyScroll || yScroll == 0x7fff )
	{
		ExtObj->InternDirty = 1;
		extobj_draw( Tree, Obj, WinId, Global );
	}
	return( Ret );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_set_selected                                                        */
/*-----------------------------------------------------------------------------*/
void	mt_list_set_selected( OBJECT *Tree, WORD Obj, WORD WinId, WORD Selected, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ExtObj->Selected = Selected;
	Draw( Tree, Obj );
	extobj_draw( Tree, Obj, WinId, Global );
}

/*-----------------------------------------------------------------------------*/
/* mt_list_resize                                                              */
/*-----------------------------------------------------------------------------*/
WORD	mt_list_resize( OBJECT *Tree, WORD Obj, WORD *OldRh, WORD *NewRh, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	New, Old;

	if( BitmapResize( ExtObj->Bitmap, Tree[Obj].ob_width, Tree[Obj].ob_height ) != E_OK )
		return( 0 );
	ExtObj->yVis = ( Tree[Obj].ob_height ) / ExtObj->CellHeight;
	if( ExtObj->yScroll + ExtObj->yVis > ListGetnItem( ExtObj->List ) )
		ExtObj->yScroll = ListGetnItem( ExtObj->List ) - ExtObj->yVis;
	if( ExtObj->yScroll < 0 )
		ExtObj->yScroll = 0;

	Draw( Tree, Obj );
	New = Tree[Obj].ob_height;
	Old = ExtObj->Rh;
	ExtObj->Rh = New;
	*NewRh = New;
	*OldRh = Old;
	return( 1 );
}

/*-----------------------------------------------------------------------------*/
/* USERDEF-Ausgabe                                                             */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl UbCode( PARMBLK *ParmBlock )
{
	if( ParmBlock->pb_prevstate == ParmBlock->pb_currstate )
	{
		EXTOBJ	*ExtObj = ( EXTOBJ * ) ParmBlock->pb_parm;
		RECT16 Clip, Source, Dest;
		if( ExtObj->InternDirty )
			Draw( ParmBlock->pb_tree, ParmBlock->pb_obj );

		Clip.x1 = ParmBlock->pb_xc;
		Clip.y1 = ParmBlock->pb_yc;
		Clip.x2 = Clip.x1 + ParmBlock->pb_wc - 1;
		Clip.y2 = Clip.y1 + ParmBlock->pb_hc - 1;
		Source.x1 = 0;
		Source.y1 = 0;
		Source.x2 = ParmBlock->pb_w;
		Source.y2 = ParmBlock->pb_h;
		Dest.x1 = ParmBlock->pb_x;
		Dest.y1 = ParmBlock->pb_y;
		Dest.x2 = Dest.x1 + Source.x2;
		Dest.y2 = Dest.y1 + Source.y2;
		BitmapCopyOnScreen( ExtObj->Bitmap, &Clip, &Source, &Dest );
	}
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* Draw                                                                        */
/*-----------------------------------------------------------------------------*/
static void Draw( OBJECT *Tree, WORD Obj )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	Pxy[4], i, j, Abs = 0, Colour, Texta[10], Fill[5];
	BYTE	**Text;

	ExtObj->InternDirty = 0;

	vswr_mode( ExtObj->Bitmap->BmHandle, MD_REPLACE );
	Pxy[0] = 0;
	Pxy[1] = 0;
	Pxy[2] = Tree[Obj].ob_width - 1;
	Pxy[3] = Tree[Obj].ob_height - 1;
	v_bar( ExtObj->Bitmap->BmHandle, Pxy );

	for( i = 0; i < ExtObj->nColumns - 1; i++ )
	{
		Pxy[0] = ExtObj->Width[i] + Abs;
		if( Pxy[0] < Tree[Obj].ob_width - 2 )
		{
			Pxy[1] = 0;
			Pxy[2] = Pxy[0];
			Pxy[3] = Tree[Obj].ob_height - 1;
			v_pline( ExtObj->Bitmap->BmHandle, 2, Pxy );
		}
		Abs += ExtObj->Width[i];
	}

	vswr_mode( ExtObj->Bitmap->BmHandle, MD_TRANS );
	for( i = 0; i < ExtObj->yVis; i++ )
	{
		Text = ListGetItem( ExtObj->List, i + ExtObj->yScroll, &Colour );
		Abs = 0;
		if( !Text )
			break;
		if( Colour != -1 )
		{
			vqt_attributes( ExtObj->Bitmap->BmHandle, Texta );
			vst_color( ExtObj->Bitmap->BmHandle, ExtObj->ColourTable[Colour] );
		}
		for( j = 0; j < ExtObj->nColumns; j++ )
		{
			Pxy[0] = Abs + 2;
			if( !j )
				Pxy[0] -= 1;
			Pxy[1] = i * ExtObj->CellHeight;
			if( j == ExtObj->nColumns - 1 )
				Pxy[2] = Tree[Obj].ob_width - 1;
			else
				Pxy[2] = Abs + ExtObj->Width[j] - 2;
			if( Pxy[2] > Tree[Obj].ob_width - 1 )
				Pxy[2] = Tree[Obj].ob_width - 1;

			Pxy[3] = Pxy[1] + ExtObj->CellHeight;
			if( Pxy[3] >= Tree[Obj].ob_height )
				Pxy[3] = Tree[Obj].ob_height - 1;
			vs_clip( ExtObj->Bitmap->BmHandle, 1, Pxy );
			
			if( Text[j] )
				v_gtext( ExtObj->Bitmap->BmHandle, Pxy[0], Pxy[3] - ExtObj->dBasicLine, Text[j] );

			if( ExtObj->Mode == LISTOBJ_SHOW_SELECTED && ExtObj->Selected == i + ExtObj->yScroll )
			{
				vswr_mode( ExtObj->Bitmap->BmHandle, MD_XOR );
				v_bar( ExtObj->Bitmap->BmHandle, Pxy );
				vswr_mode( ExtObj->Bitmap->BmHandle, MD_TRANS );
			}
			if( ExtObj->Mode == LISTOBJ_MULTIPLE )
			{
				if( ListSelected( ExtObj->List, i + ExtObj->yScroll ))
				{
					vswr_mode( ExtObj->Bitmap->BmHandle, MD_XOR );
					v_bar( ExtObj->Bitmap->BmHandle, Pxy );
					vswr_mode( ExtObj->Bitmap->BmHandle, MD_TRANS );
				}
			}
			if( ExtObj->Mode == LISTOBJ_SHOW_COLOUR )
			{
				vqf_attributes( ExtObj->Bitmap->BmHandle, Fill );
				vsf_color( ExtObj->Bitmap->BmHandle, ExtObj->ColourTable[Colour] );
				Pxy[1] -= 1;
				Pxy[3] -= 2;
				v_bar( ExtObj->Bitmap->BmHandle, Pxy );
				Pxy[1] += 1;
				Pxy[3] += 2;
				vsf_color( ExtObj->Bitmap->BmHandle, Fill[1] );
			}
			vs_clip( ExtObj->Bitmap->BmHandle, 0, Pxy );
			Abs += ExtObj->Width[j];
		}
		if( Colour != -1 )
			vst_color( ExtObj->Bitmap->BmHandle, Texta[1] );
	}
}
