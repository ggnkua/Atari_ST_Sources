#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>

#include	"ExtObj\ExtObj.h"
#include	"Window.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern GRECT	ScreenRect;


void	extobj_get_colour( WORD Handle, WORD *TColour, WORD *BColour )
{
	WORD	Text[10], Fill[5];
	vqt_attributes( Handle, Text );
	vqf_attributes( Handle, Fill );
	*TColour = Text[1];
	*BColour = Fill[1];
}

void	extobj_set_fontabs( WORD Handle, WORD Id, WORD Ht )
{
	WORD	D;
	vst_font( Handle, Id );
	vst_height( Handle, Ht, &D, &D, &D, &D );
}
void	extobj_set_font( WORD Handle, WORD Id, WORD Pt )
{
	WORD	D;
	vst_font( Handle, Id );
	vst_point( Handle, Pt, &D, &D, &D, &D );
}
void	extobj_set_colour( WORD Handle, WORD TColour, WORD BColour )
{
	vst_color( Handle, TColour );
	vsf_color( Handle, BColour );
}
void	extobj_get_font( WORD Handle, WORD *Id, WORD *Ht, WORD *Pix, WORD *Mono )
{
	WORD	Text[10], i = 0;
	uint16	FontFormat, Flags;
	BYTE	Name[33];

	vqt_attributes( Handle, Text );
	*Ht = Text[7];
	
	while( vqt_ext_name( Handle, i++, Name, &FontFormat, &Flags ) != Text[0] );
	*Mono = Flags & 0x01;
	*Pix = 1;
	*Id = Text[0];
}
void	extobj_get_fontinfo( WORD Handle, WORD *CellHeight, WORD *dBasicLine )
{
	WORD	D, Distances[5], Effects[3];
	vqt_fontinfo( Handle, &D, &D, Distances, &D, Effects );
	*CellHeight =  Distances[4] + Distances[0] + 1;
	*dBasicLine = Distances[0] + 1;
}

void	extobj_draw( OBJECT *Tree, WORD Obj, WORD WinId, WORD Global[15] )
{
	GRECT	Box, ObjBox;
	MT_graf_mouse( M_OFF, NULL, Global );
	MT_wind_update( BEG_UPDATE, Global );
	MT_wind_get_grect( WinId, WF_FIRSTXYWH, &Box, Global );
	MT_objc_offset( Tree, Obj, &( ObjBox.g_x ), &( ObjBox.g_y ), Global );
	ObjBox.g_w = Tree[Obj].ob_width;
	ObjBox.g_h = Tree[Obj].ob_height;
	while( Box.g_w && Box.g_h )
	{
		if( RcInterSect( &ScreenRect, &Box ))
			if( RcInterSect( &ObjBox, &Box ))
				MT_objc_draw( Tree, Obj, MAX_DEPTH, &Box, Global );
		MT_wind_get_grect( WinId, WF_NEXTXYWH, &Box, Global );
	}
	MT_wind_update( END_UPDATE, Global );
	MT_graf_mouse( M_ON, NULL, Global );
}

