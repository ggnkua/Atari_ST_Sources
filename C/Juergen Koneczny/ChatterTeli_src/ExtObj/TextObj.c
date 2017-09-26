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
#include	"DD.h"
#include	"SmIcons.h"
#include	"Window.h"
#include	"ExtObj\ExtObj.h"
#include	"ExtObj\ExtObj.h"
#include	"ExtObj\TextObj.h"
#include	"ExtObj\Text.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern VdiHandle;
extern GRECT	ScreenRect;

extern WORD	SmIcons;
extern GCBITMAP	SmIcon_Data[N_SIZE][N_SMILEYS];
extern GCBITMAP	SmIcon_Mask[N_SIZE][N_SMILEYS];

typedef	struct
{
	BITMAP	*Bitmap;

	WORD		Dirty;
	WORD		InternDirty;
	WORD		Rh;
	WORD		CellHeight;
	WORD		dBasicLine;
	void		*Text;

	WORD		yScroll;
	WORD		yVis;
	WORD		yVal;

	LONG		nLineVis;

	LONG		Pufline;

	WORD		xScroll;

	WORD		SelS, SelE;

	WORD		SmIcons;
	WORD		ColourTable[COLOUR];
}	EXTOBJ;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static WORD	cdecl UbCode( PARMBLK *ParmBlock );

static void Draw( OBJECT *Tree, WORD Obj );

static BYTE	*CalcLine( OBJECT *Tree, WORD Obj, LONG n, LONG *nLine, WORD *Colour );
static BYTE	*MakeLine( OBJECT *Tree, WORD Obj, BYTE *Puf );
static LONG	CalcLineVis( OBJECT *Tree, WORD Obj );

/*-----------------------------------------------------------------------------*/
/* mt_text_create                                                              */
/*-----------------------------------------------------------------------------*/
WORD	mt_text_create( OBJECT *Tree, WORD Obj, WORD Global[15] )
{
	WORD	i;
	USERBLK	*UserBlk = malloc( sizeof( USERBLK ));
	EXTOBJ	*ExtObj = malloc( sizeof( EXTOBJ ));
	if( !UserBlk || !ExtObj )
		return( ENSMEM );

	if(( ExtObj->Text = TextCreate()) == NULL )
	{
		free( ExtObj );
		free( UserBlk );
		return( ERROR );
	}

	UserBlk->ub_code = UbCode;
	( EXTOBJ * ) UserBlk->ub_parm = ExtObj;
	Tree[Obj].ob_spec.userblk = UserBlk;

	ExtObj->Dirty = 0;
	ExtObj->InternDirty = 0;
	ExtObj->yScroll = 0;
	ExtObj->yVal = 0;
	ExtObj->yVis = 0;

	ExtObj->xScroll = 0;

	ExtObj->nLineVis = 0;

	ExtObj->Pufline = 0;

	ExtObj->SelS = -1;
	ExtObj->SelE = -1;

	ExtObj->SmIcons = 0;

	if(( ExtObj->Bitmap = BitmapNew( Tree[Obj].ob_width, Tree[Obj].ob_height )) == NULL )
	{
		TextDelete( ExtObj->Text );
		free( ExtObj );
		free( UserBlk );
		return( ERROR );
	}
	extobj_get_fontinfo( ExtObj->Bitmap->BmHandle, &( ExtObj->CellHeight ), &( ExtObj->dBasicLine ));
	ExtObj->Rh = Tree[Obj].ob_height;
	ExtObj->yVis = ( Tree[Obj].ob_height ) / ExtObj->CellHeight;
	ExtObj->yVal = ( Tree[Obj].ob_height ) / ExtObj->CellHeight;

	for( i = 0; i < COLOUR; i++ )
		ExtObj->ColourTable[i] = 1;

	Draw( Tree, Obj );
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* mt_text_evnt                                                                */
/*-----------------------------------------------------------------------------*/
WORD	mt_text_evnt( OBJECT *Tree, WORD Obj, WORD WinId, EVNT *Events, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	Ret = E_OK;
	if(( Events->mwhich & MU_BUTTON ) && Events->mclicks && MT_objc_find( Tree, ROOT, MAX_DEPTH, Events->mx, Events->my, Global ) == Obj )
	{
		if( Events->mbutton )
		{
			LONG	nLineVis, FirstVisLine, OutputnLine, Line;
			WORD	Colour, yPos, xPos, SelS, SelE, Sel = -1, CalcFlag = 1, ActFlag = 0;
			BYTE	*Puf = NULL;
			EVNTDATA	EvNew, EvOld, Ev;
			MT_wind_update( BEG_UPDATE, Global );
			MT_wind_update( BEG_MCTRL, Global );
			MT_objc_offset( Tree, Obj, &xPos, &yPos, Global );

			MT_graf_mkstate( &Ev, Global );
			if( !Ev.bstate && Events->mclicks == 1 )
			{
				ExtObj->SelS = -1;
				ExtObj->SelE = -1;
				Draw( Tree, Obj );
				extobj_draw( Tree, Obj, WinId, Global );
			}
			else
			{
				MT_graf_mouse( M_SAVE, NULL, Global );
				if( ExtObj->SelS != -1 )
				{
					nLineVis = 0;
					FirstVisLine = -1;
					OutputnLine = 0;
					do
					{
						nLineVis += OutputnLine;
						Puf = CalcLine( Tree, Obj, ++FirstVisLine, &OutputnLine, &Colour );
						if( Puf )
							free( Puf );
					}
					while( nLineVis + OutputnLine <= ExtObj->yScroll );

					nLineVis = 0;
					OutputnLine = 0;
					Line = FirstVisLine - 1;
					do
					{
						nLineVis += OutputnLine;
						Puf = CalcLine( Tree, Obj, ++Line, &OutputnLine, &Colour );
						if( Puf )
							free( Puf );
					}
					while( nLineVis + OutputnLine <= ( Ev.y - yPos ) / ExtObj->CellHeight );
					if( Line >= ExtObj->SelS && Line <= ExtObj->SelE )
						ActFlag = 1;
				}
				if( ActFlag && !Ev.kstate )
				{
					WORD	Pxy[10], Cxy[4], Dx, Dy;
					MT_graf_mouse( FLAT_HAND, NULL, Global );
					Pxy[0] = xPos;
					Pxy[1] = yPos;
					Pxy[2] = Pxy[0] + Tree[Obj].ob_width;
					Pxy[3] = Pxy[1];
					Pxy[4] = Pxy[2];
					Pxy[5] = Pxy[1] + Tree[Obj].ob_height;
					Pxy[6] = Pxy[0];
					Pxy[7] = Pxy[5];
					Pxy[8] = Pxy[0];
					Pxy[9] = Pxy[1];
					Cxy[0] = ScreenRect.g_x; Cxy[1] = ScreenRect.g_y;
					Cxy[2] = Cxy[0] + ScreenRect.g_w; Cxy[3] = Cxy[2] + ScreenRect.g_h;
					vs_clip( VdiHandle, 1, Cxy );
					vsl_udsty( VdiHandle, 0xaaaa );
					vsl_type( VdiHandle, 7 );
					vswr_mode( VdiHandle, MD_XOR );
					MT_graf_mouse( M_OFF, NULL, Global );
					v_pline( VdiHandle, 5, Pxy );
					MT_graf_mouse( M_ON, NULL, Global );
					EvNew.x = Ev.x;
					EvNew.y = Ev.y;
					do
					{
						if( EvNew.x != Ev.x || EvNew.y != Ev.y )
						{
							Dx = EvNew.x - Ev.x; Dy = EvNew.y - Ev.y;
							MT_graf_mouse( M_OFF, NULL, Global );
							v_pline( VdiHandle, 5, Pxy );
							Pxy[0] += Dx;	Pxy[1] += Dy;
							Pxy[2] += Dx;	Pxy[3] += Dy;
							Pxy[4] += Dx;	Pxy[5] += Dy;
							Pxy[6] += Dx;	Pxy[7] += Dy;
							Pxy[8] += Dx;	Pxy[9] += Dy;
							v_pline( VdiHandle, 5, Pxy );
							MT_graf_mouse( M_ON, NULL, Global );
							Ev.x = EvNew.x; Ev.y = EvNew.y;
						}
						MT_graf_mkstate( &EvNew, Global );
					}
					while( EvNew.bstate );
					MT_graf_mouse( M_OFF, NULL, Global );
					v_pline( VdiHandle, 5, Pxy );
					vs_clip( VdiHandle, 0, Cxy );
					MT_graf_mouse( M_ON, NULL, Global );
					MT_graf_mouse( M_RESTORE, NULL, Global );
					MT_wind_update( END_MCTRL, Global );
					MT_wind_update( END_UPDATE, Global );

					{
						WORD	DestWinId = MT_wind_find( EvNew.x, EvNew.y, Global );
						WORD	AppId, w2, w3, w4;
						LONG	Len = 0, i;
						WORD	Colour;
						BYTE	*Puf, *Tmp;
						for( i = ExtObj->SelS; i <= ExtObj->SelE; i++ )
						{
							Tmp = TextGetLine( ExtObj->Text, i, &Colour );
							if( Tmp )
							{
								Len += strlen( Tmp );
								Len += 2;
							}
						}
						Puf = malloc( Len + 1 );
						if( !Puf )
							return( ENSMEM );
						*Puf = 0;
						for( i = ExtObj->SelS; i <= ExtObj->SelE; i++ )
						{
							Tmp = TextGetLine( ExtObj->Text, i, &Colour );
							if( Tmp )
							{
								strcat( Puf, Tmp );
								strcat( Puf, "\r\n" );
							}
						}

						if( DestWinId != -1 /*&& DestWinId != WinId */)
						{
							MT_wind_get( DestWinId, WF_OWNER, &AppId, &w2, &w3, &w4, Global );
							if( AppId != Global[2] )
								PutDragDrop( DestWinId, EvNew.x, EvNew.y, EvNew.kstate, AppId, '.TXT', Puf, strlen( Puf ), Global );
							else
							{
								EVNT	lEvent;
								DD_INFO	DdInfo;
								DdInfo.format = '.TXT';
								DdInfo.mx = EvNew.x;
								DdInfo.my = EvNew.y;
								DdInfo.kstate = EvNew.kstate;
								DdInfo.size = strlen( Puf );
								DdInfo.puf = Puf;
								lEvent.mwhich = MU_MESAG;
								lEvent.msg[0] = WIN_CMD;
								lEvent.msg[1] = Global[2];
								lEvent.msg[2] = 0;
								lEvent.msg[3] = DestWinId;
								lEvent.msg[4] = WIN_DRAGDROP;
								*( DD_INFO ** )&( lEvent.msg[5] ) = &DdInfo;
								HandleWindow( &lEvent, Global );
							}
						}
						free( Puf );
					}
					return( E_OK );
				}
				else
				{
					MT_graf_mouse( POINT_HAND, NULL, Global );
					EvOld.y = 0;
					EvNew.y = Events->my;
					do
					{
						if( EvNew.y != EvOld.y )
						{
							if( EvNew.y > yPos + Tree[Obj].ob_height )
							{
								mt_text_scroll( Tree, Obj, WinId, 1, 0, Global );
								CalcFlag = 1;
							}
							else	if( EvNew.y < yPos )
							{
								mt_text_scroll( Tree, Obj, WinId, -1, 0, Global );
								CalcFlag = 1;
							}
	
							if( CalcFlag )
							{
								nLineVis = 0;
								FirstVisLine = -1;
								OutputnLine = 0;
								do
								{
									nLineVis += OutputnLine;
									Puf = CalcLine( Tree, Obj, ++FirstVisLine, &OutputnLine, &Colour );
									if( Puf )
										free( Puf );
								}
								while( nLineVis + OutputnLine <= ExtObj->yScroll );
								CalcFlag = 0;
							}

							nLineVis = 0;
							OutputnLine = 0;
							Line = FirstVisLine - 1;
							do
							{
								nLineVis += OutputnLine;
								Puf = CalcLine( Tree, Obj, ++Line, &OutputnLine, &Colour );
								if( Puf )
									free( Puf );
							}
							while( nLineVis + OutputnLine <= ( EvNew.y - yPos ) / ExtObj->CellHeight );
	
							SelS = ExtObj->SelS;
							SelE = ExtObj->SelE;
							if( Line >= TextGetnLines( ExtObj->Text ))
								Line = TextGetnLines( ExtObj->Text ) - 1;
							if( Sel == -1 )
							{
								if( !Ev.kstate )
									Sel = Line;
								else
								{
									if( Line > SelS )
										Sel = SelS;
									else
										Sel = SelE;
								}
							}

							if( Line >= Sel )
							{
								SelE = Line;
								SelS = Sel;
							}
							else
							{
								SelE = Sel;
								SelS = Line;
							}
							if( SelS != ExtObj->SelS || SelE != ExtObj->SelE )
							{
								ExtObj->SelS = SelS;
								ExtObj->SelE = SelE;
								Draw( Tree, Obj );
								extobj_draw( Tree, Obj, WinId, Global );
							}
							EvOld.y = EvNew.y;
						}
						MT_graf_mkstate( &EvNew, Global );
					}
					while( EvNew.bstate );
					if( Events->mclicks == 2 )
						Ret = 1;
				}
				MT_graf_mouse( M_RESTORE, NULL, Global );
			}

			MT_wind_update( END_MCTRL, Global );
			MT_wind_update( END_UPDATE, Global );
		}
		/* Block deselektieren */
	}
	return( Ret );
}

LONG	mt_text_get_pufline( OBJECT *Tree, WORD Obj, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	return( ExtObj->Pufline );
}

WORD	mt_text_get_slct( OBJECT *Tree, WORD Obj, LONG *Start, LONG *End, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	if( ExtObj->SelS != -1 )
	{
		*Start = ExtObj->SelS;
		*End = ExtObj->SelE;
		return( E_OK );
	}
	return( ERROR );
}
WORD	mt_text_deslct( OBJECT *Tree, WORD Obj, WORD WinId, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ExtObj->SelS = -1;
	ExtObj->SelE = -1;
	Draw( Tree, Obj );
	extobj_draw( Tree, Obj, WinId, Global );
}

BYTE	*mt_text_get_line( OBJECT *Tree, WORD Obj, LONG Line, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD		Colour;
	return( TextGetLine( ExtObj->Text, Line, &Colour ));
}

/*-----------------------------------------------------------------------------*/
/* mt_text_set_format                                                          */
/*-----------------------------------------------------------------------------*/
void	mt_text_set_format( OBJECT *Tree, WORD Obj, WORD TabWidth, WORD AutoWrap, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	BitmapResize( ExtObj->Bitmap, Tree[Obj].ob_width, Tree[Obj].ob_width );
	ExtObj->yVis = ( Tree[Obj].ob_height ) / ExtObj->CellHeight;
	ExtObj->yVal = ( Tree[Obj].ob_height ) / ExtObj->CellHeight;
	ExtObj->nLineVis = CalcLineVis( Tree, Obj );
	if( ExtObj->yScroll + ExtObj->yVis > ExtObj->nLineVis )
		ExtObj->yScroll = ExtObj->nLineVis - ExtObj->yVis;
	if( ExtObj->yScroll < 0 )
		ExtObj->yScroll = 0;
	Draw( Tree, Obj );
}

/*-----------------------------------------------------------------------------*/
/* mt_text_resize                                                              */
/*-----------------------------------------------------------------------------*/
WORD	mt_text_resized( OBJECT *Tree, WORD Obj, WORD *OldRh, WORD *NewRh, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	New, Old;

	if( BitmapResize( ExtObj->Bitmap, Tree[Obj].ob_width, Tree[Obj].ob_height ) != E_OK )
		return( 0 );
	ExtObj->yVis = ( Tree[Obj].ob_height ) / ExtObj->CellHeight;
	ExtObj->yVal = ( Tree[Obj].ob_height ) / ExtObj->CellHeight;
	ExtObj->nLineVis = CalcLineVis( Tree, Obj );
	if( ExtObj->yScroll + ExtObj->yVis > ExtObj->nLineVis )
		ExtObj->yScroll = ExtObj->nLineVis - ExtObj->yVis;
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
/* mt_text_append                                                              */
/*-----------------------------------------------------------------------------*/
WORD	mt_text_attach_line( OBJECT *Tree, WORD Obj, BYTE *String, WORD Colour, WORD Global[15] )
{
	WORD	Ret;
	LONG	nLine;
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	if(( Ret = TextAttachLine( ExtObj->Text, String, Colour )) != E_OK )
		return( Ret );

	free( CalcLine( Tree, Obj, TextGetnLines( ExtObj->Text ) - 1, &nLine, &Colour ));
	ExtObj->nLineVis += nLine;

	if( ExtObj->Pufline + ExtObj->yVis < TextGetnLines( ExtObj->Text ))
	{
		free( CalcLine( Tree, Obj, 0, &nLine, &Colour ));
		ExtObj->nLineVis -= nLine;
		TextDeleteLine( ExtObj->Text, 0 );
		if( ExtObj->SelS != -1 )
			ExtObj->SelS--;
		if( ExtObj->SelE != -1 )
		{
			ExtObj->SelE--;
			if( ExtObj->SelS == -1 )
				ExtObj->SelS = 0;
		}
	}

	ExtObj->InternDirty = 1;
	ExtObj->Dirty = 1;
	return( E_OK );
}

/*-----------------------------------------------------------------------------*/
/* mt_text_delete                                                              */
/*-----------------------------------------------------------------------------*/
void	mt_text_delete( OBJECT *Tree, WORD Obj, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	BitmapDelete( ExtObj->Bitmap );
	TextDelete( ExtObj->Text );
	free(( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm );
	free( Tree[Obj].ob_spec.userblk );
}

/*-----------------------------------------------------------------------------*/
/* mt_text_get_font                                                            */
/*-----------------------------------------------------------------------------*/
void	mt_text_get_font( OBJECT *Tree, WORD Obj, WORD *Id, WORD *Ht, WORD *Pix, WORD *Mono, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	extobj_get_font( ExtObj->Bitmap->BmHandle, Id, Ht, Pix, Mono );
}
/*-----------------------------------------------------------------------------*/
/* mt_text_get_colour                                                          */
/*-----------------------------------------------------------------------------*/
void	mt_text_get_colour( OBJECT *Tree, WORD Obj, WORD *TColour, WORD *BColour, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	extobj_get_colour( ExtObj->Bitmap->BmHandle, TColour, BColour );
}
/*-----------------------------------------------------------------------------*/
/* mt_text_get_scrollinfo                                                      */
/*-----------------------------------------------------------------------------*/
void	mt_text_get_scrollinfo( OBJECT *Tree, WORD Obj, LONG *nLines, LONG *yScroll, WORD *yVis, WORD *yVal, WORD *nCols, WORD *xScroll, WORD *xVis, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	*nLines = ExtObj->nLineVis;
	*yScroll = ExtObj->yScroll;
	*yVis = ExtObj->yVis;
	*yVal = ExtObj->yVal;
	*nCols = -1;
	*xScroll = ExtObj->xScroll;
	*xVis = Tree[Obj].ob_width;
}

/*-----------------------------------------------------------------------------*/
/* mt_text_set_colourtable                                                     */
/*-----------------------------------------------------------------------------*/
void	mt_text_set_colourtable( OBJECT *Tree, WORD Obj, WORD Colour, WORD Idx, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ExtObj->ColourTable[Idx] = Colour;
	Draw( Tree, Obj );
	ExtObj->Dirty = 1;
}

/*-----------------------------------------------------------------------------*/
/* mt_text_get_colourtable                                                     */
/*-----------------------------------------------------------------------------*/
WORD	mt_text_get_colourtable( OBJECT *Tree, WORD Obj, WORD Idx, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	return( ExtObj->ColourTable[Idx] );
}

/*-----------------------------------------------------------------------------*/
/* mt_text_set_font                                                            */
/*-----------------------------------------------------------------------------*/
void	mt_text_set_font( OBJECT *Tree, WORD Obj, WORD Id, WORD Ht, WORD Pix, WORD Mono, WORD Global[15] )
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
/* mt_text_set_colour                                                          */
/*-----------------------------------------------------------------------------*/
void	mt_text_set_colour( OBJECT *Tree, WORD Obj, WORD TColour, WORD BColour, WORD Global[15] )
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
/* mt_text_scroll                                                              */
/*-----------------------------------------------------------------------------*/
WORD	mt_text_scroll( OBJECT *Tree, WORD Obj, WORD WinId, WORD yScroll, WORD xScroll, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	Ret = 1, OldyScroll = ExtObj->yScroll;

	if( yScroll == 0x7fff )
		ExtObj->yScroll = ExtObj->nLineVis - ExtObj->yVis;
	else
		ExtObj->yScroll += yScroll;
	if( ExtObj->yScroll > ExtObj->nLineVis - ExtObj->yVis )
	{
		ExtObj->yScroll = ExtObj->nLineVis - ExtObj->yVis;
		Ret = 0;
	}
	if( ExtObj->yScroll < 0 )
		ExtObj->yScroll = 0;

	if( ExtObj->yScroll != OldyScroll || yScroll == 0x7fff )
	{
		ExtObj->InternDirty = 1;
		extobj_draw( Tree, Obj, WinId, Global );
	}
	return( Ret );
}

/*-----------------------------------------------------------------------------*/
/* mt_text_set_dirty                                                           */
/*-----------------------------------------------------------------------------*/
void	mt_text_set_dirty( OBJECT *Tree, WORD Obj, WORD Dirty, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ExtObj->Dirty = Dirty;
}

/*-----------------------------------------------------------------------------*/
/* mt_text_get_dirty                                                           */
/*-----------------------------------------------------------------------------*/
WORD	mt_text_get_dirty( OBJECT *Tree, WORD Obj, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	return( ExtObj->Dirty );
}

void	mt_text_set_smicons( OBJECT *Tree, WORD Obj, WORD Flag, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ExtObj->SmIcons = Flag;
}

/*-----------------------------------------------------------------------------*/
/* mt_text_set_pufline                                                         */
/*-----------------------------------------------------------------------------*/
void	mt_text_set_pufline( OBJECT *Tree, WORD Obj, LONG Pufline, WORD Global[15] )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	ExtObj->Pufline = Pufline;
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

static void Draw( OBJECT *Tree, WORD Obj )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	Cxy[4], Pxy[4], Colour, Text[10];
	LONG	OutputnLine = 0;
	LONG	nLineVis = 0, Line = 0;
	WORD	i, j;
	BYTE	*Puf = NULL, *TmpPuf, *fPuf;

	ExtObj->InternDirty = 0;
	Cxy[0] = 0;
	Cxy[1] = 0;
	Cxy[2] = Cxy[0] + Tree[Obj].ob_width - 1;
	Cxy[3] = Cxy[1] + Tree[Obj].ob_height - 1;
	vs_clip( ExtObj->Bitmap->BmHandle, 1, Cxy );

	do
	{
		if( Puf )
			free( Puf );
		nLineVis += OutputnLine;
		Puf = CalcLine( Tree, Obj, Line++, &OutputnLine, &Colour );
	}
	while( nLineVis + OutputnLine < ExtObj->yScroll );

	fPuf = Puf;
	while( nLineVis < ExtObj->yScroll )
	{
		if( Puf )
			Puf += strlen( Puf ) + 1;
		OutputnLine--;
		nLineVis++;
	}

	i = 0;
	do
	{
		Pxy[0] = 0;
		Pxy[1] = i * ExtObj->CellHeight;
		Pxy[2] = Tree[Obj].ob_width - 1;
		Pxy[3] = Pxy[1] + ExtObj->CellHeight * OutputnLine;
		vswr_mode( ExtObj->Bitmap->BmHandle, MD_REPLACE );
		v_bar( ExtObj->Bitmap->BmHandle, Pxy );

		if( Puf )
		{
			TmpPuf = Puf;
			if( Colour != -1 )
			{
				vqt_attributes( ExtObj->Bitmap->BmHandle, Text );
				vst_color( ExtObj->Bitmap->BmHandle, ExtObj->ColourTable[Colour] );
			}
			for( j = 0; j < OutputnLine; j++ )
			{
				if( Pxy[1] + ( j + 1 ) * ExtObj->CellHeight > Tree[Obj].ob_height )
					break;
				vswr_mode( ExtObj->Bitmap->BmHandle, MD_TRANS );
				if( ExtObj->SmIcons && SmIcons )
				{
					WORD	i;

					v_gtext( ExtObj->Bitmap->BmHandle, 0, Pxy[1] + ( j + 1 ) * ExtObj->CellHeight - ExtObj->dBasicLine, TmpPuf );
					for( i = 0; i < strlen( TmpPuf ); i++ )
					{
						if( TmpPuf[i] == '-' && i > 0 && i < strlen( TmpPuf ))
						{
							WORD	Smiley = -1;
							if( TmpPuf[i-1] == ':' && TmpPuf[i+1] == ')' )
								Smiley = 0;
							if( TmpPuf[i-1] == ';' && TmpPuf[i+1] == ')' )
								Smiley = 1;
							if( TmpPuf[i-1] == ':' && TmpPuf[i+1] == '(' )
								Smiley = 2;
							if( TmpPuf[i-1] == ':' && TmpPuf[i+1] == '/' )
								Smiley = 3;
							if( Smiley != -1 )
							{
								WORD	Extent1[8], Extent2[8];
								WORD	xy[4], k, Icon = N_SIZE - 1;
								BYTE	*Tmp = malloc( i + 2 );
								RECT16 Clip, Source, Dest;
								if( !Tmp )
									break;
								strncpy( Tmp, TmpPuf, i - 1 );
								Tmp[i-1] = 0;
								vqt_extent( ExtObj->Bitmap->BmHandle, Tmp, Extent1 );
								strncpy( Tmp, &TmpPuf[i-1], 3 );
								Tmp[3] = 0;
								vqt_extent( ExtObj->Bitmap->BmHandle, Tmp, Extent2 );
								xy[0] = Extent1[2];
								xy[1] = Pxy[1] + j * ExtObj->CellHeight + Extent1[3];
								xy[2] = xy[0] + Extent2[4];
								xy[3] = xy[1] + Extent2[5];
								vswr_mode( ExtObj->Bitmap->BmHandle, MD_REPLACE );
								v_bar( ExtObj->Bitmap->BmHandle, xy );
								vswr_mode( ExtObj->Bitmap->BmHandle, MD_TRANS );
/* Nach der richtigen Gr”že suchen */
/* Vorraussetzung: Niedrigster Index mit gr”žtem Smiley! */
								for( k = 0; k < N_SIZE; k++ )
								{
									if( SmIcon_Data[k][Smiley].ymax <= ExtObj->CellHeight )
										if( SmIcon_Data[k][Smiley].ymax >= SmIcon_Data[Icon][Smiley].ymax )
											Icon = k;
								}
								Source.x1 = 0;
								Source.y1 = 0;
								Source.x2 = SmIcon_Data[Icon][Smiley].xmax - 1;
								Source.y2 = SmIcon_Data[Icon][Smiley].ymax - 1;
								Dest.x1 = xy[0] + ( xy[2] - xy[0] + 1 ) / 2 - ( Source.x2 - Source.x1 + 1 ) / 2;
								Dest.y1 = xy[1] + ( xy[3] - xy[1] + 1 ) / 2 - ( Source.y2 - Source.y1 + 1 ) / 2;
								Dest.x2 = Dest.x1 + Source.x2;
								Dest.y2 = Dest.y1 + Source.y2;
								vr_transfer_bits(( int16 ) ExtObj->Bitmap->BmHandle, &SmIcon_Mask[Icon][Smiley], ExtObj->Bitmap->GcBitmap, ( int16 * ) &Source, ( int16 * ) &Dest, T_LOGIC_NOT_AND );
								vr_transfer_bits(( int16 ) ExtObj->Bitmap->BmHandle, &SmIcon_Data[Icon][Smiley], ExtObj->Bitmap->GcBitmap, ( int16 * ) &Source, ( int16 * ) &Dest, T_TRANSPARENT );
								free( Tmp );
							}
						}
					}
				}
				else
					v_gtext( ExtObj->Bitmap->BmHandle, 0, Pxy[1] + ( j + 1 ) * ExtObj->CellHeight - ExtObj->dBasicLine, TmpPuf );

				TmpPuf += strlen( TmpPuf ) + 1;
			}
			if( Line - 1 >= ExtObj->SelS && Line - 1 <= ExtObj->SelE )
			{
				WORD	xy[4];
				xy[0] = Pxy[0];
				xy[1] = Pxy[1] + j * ExtObj->CellHeight;
				xy[2] = Pxy[2];
				xy[3] = xy[1] + ExtObj->CellHeight;
				vswr_mode( ExtObj->Bitmap->BmHandle, MD_XOR );
				v_bar( ExtObj->Bitmap->BmHandle, Pxy );
				vswr_mode( ExtObj->Bitmap->BmHandle, MD_TRANS );
			}
			free( fPuf );
			if( Colour != -1 )
				vst_color( ExtObj->Bitmap->BmHandle, Text[1] );
		}
		i += OutputnLine;
		Puf = CalcLine( Tree, Obj, Line++, &OutputnLine, &Colour );
		fPuf = Puf;
	}
	while( i <= ExtObj->yVis );
	vs_clip( ExtObj->Bitmap->BmHandle, 0, Cxy );
}

static BYTE	*CalcLine( OBJECT *Tree, WORD Obj, LONG n, LONG *nLine, WORD *Colour )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	BYTE	*Puf, *TmpPuf, *Line = TextGetLine( ExtObj->Text, n, Colour );

	( *nLine ) = 1;

	if( !Line )
		return( NULL );

	if(( Puf = malloc( strlen( Line ) + 2 )) == NULL )
		return( NULL );
	strcpy( Puf, Line );
	Puf[strlen(Puf)+1] = 0;
	TmpPuf = Puf;
	while( *( TmpPuf = MakeLine( Tree, Obj, TmpPuf )) != '\0' )
		( *nLine ) ++;
	return( Puf );
}
static BYTE	*MakeLine( OBJECT *Tree, WORD Obj, BYTE *Puf )
{
	EXTOBJ	*ExtObj = ( EXTOBJ *) Tree[Obj].ob_spec.userblk->ub_parm;
	WORD	NextPos = 0, Pos = strlen( Puf ), Extent[8];
	
	vqt_extent( ExtObj->Bitmap->BmHandle, Puf, Extent );

	while( Extent[2] >= Tree[Obj].ob_width )
	{
		while( --Pos >= 0 )
		{
			if( Puf[Pos] == ' ' )
			{
				Puf[Pos] = '\0';
				break;
			}
		}

		if( Pos >= 0 )
		{
			vqt_extent( ExtObj->Bitmap->BmHandle, Puf, Extent );
			if( Extent[2] >= Tree[Obj].ob_width )
			{
				Puf[Pos] = ' ';
				NextPos = Pos;
				continue;
			}
		}
		else	if( NextPos )
			Puf[NextPos] = '\0';;
		break;
	}
	return( Puf + strlen( Puf ) + 1 );		
}

static LONG	CalcLineVis( OBJECT *Tree, WORD Obj )
{
	LONG	n = 0, nLine, Ret = 0;
	WORD	Colour;
	BYTE	*Line;
	while(( Line = CalcLine( Tree, Obj, n++, &nLine, &Colour )) != NULL )
	{
		free( Line );
		Ret += nLine;
	}
	return( Ret );
}