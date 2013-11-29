/*----------------------------------------------------------------------------------------*
 * MControl                                                                               *
 *----------------------------------------------------------------------------------------*
 * Copyright (c) 2000 - 2002 Joachim Fornallaz                                            *
 *----------------------------------------------------------------------------------------*
 * This source file is subject to the BSD license.                                        *
 *----------------------------------------------------------------------------------------*
 * Authors: Joachim Fornallaz <jf@omnis.ch>                                               *
 *----------------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------------*/
/* global includes																								*/
/*----------------------------------------------------------------------------------------*/

#include <cflib.h>
#include <mt_aes.h>

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include	"shared\appcomm.h"
#include	"shared\strcmd.h"
#include	"shared\slider.h"
#include	"shared\popup.h"
#include	"shared\file.h"
#include	"shared\rect.h"
#include	"mcontrol.h"
#include	"dynrsrc.h"
#include	"dialog.h"
#include	"config.h"
#include	"rsrc.h"

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

extern	NODE		*clnode;
extern	NODE		*gl_nodeptr;
extern	OBJECT	*gl_obptr;

WDIALOG		*wdial;
SLD			msld;
int16			hv_olditem = -1;
int16			md_mw, md_mh;
uint8			emptystr[] = " ";
uint8			info_str[256] = " ";

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

static void		wd_selectnew( WDIALOG *wd, int16 new, int16 old, int16 flag );
static int16	hv_objc_find( OBJECT *tree, int16 start, int16 depth, int16 x, int16 y );
		 int16	help_context( NODE *nd );
		 NODE		*node_findlast( NODE *nd );

/*----------------------------------------------------------------------------------------*/
/* init/exit handling for dialog handling												 					*/
/*----------------------------------------------------------------------------------------*/
void	init_dial( void )
{
	uint8		tmp[20];
	int16		dummy;
	
	fix_menu(about);
	get_patchlev(__Ident_cflib, tmp);
	set_string(about, A_PL, tmp);
	set_string(about, A_VERSION, __DATE__);
	
	wdial = create_wdial( gl_obptr, wicon, 0, maindial_open_cb, maindial_exit_cb );

	if( wdial )
		wdial->win_kind += INFO;
		
	if( (aes_flags & GAI_3D ) )
	{
		if( h3d || v3d )
		{
			gl_obptr[MLIST_UP].ob_spec.obspec.framesize = 1;
			gl_obptr[MLIST_UP].ob_flags &= ~FL3DIND;
			gl_obptr[MLIST_DOWN].ob_spec.obspec.framesize = 1;
			gl_obptr[MLIST_DOWN].ob_flags &= ~FL3DIND;
			gl_obptr[MLIST_WHITE].ob_spec.obspec.framesize = 1;
			gl_obptr[MLIST_WHITE].ob_flags &= ~FL3DIND;
		}
	}
	else
	{
		gl_obptr[MLIST_UP].ob_spec.obspec.framesize = 1;
		gl_obptr[MLIST_DOWN].ob_spec.obspec.framesize = 1;
		gl_obptr[MLIST_WHITE].ob_spec.obspec.framesize = 1;
	}
		
	fix_special( gl_obptr );

	if(_app)
		open_wdial( wdial, -1, -1 );
	wind_get( wdial->win_handle, WF_CURRXYWH, &dummy, &dummy, &md_mw, &md_mh );
}

void	exit_dial( void )
{
	delete_wdial( wdial );
}


/*----------------------------------------------------------------------------------------*/
/* open/exit handling for the main window 											 					*/
/*----------------------------------------------------------------------------------------*/
void	maindial_open_cb(WDIALOG *wd)
{
	uint8	str[32];

	sld_create( &msld, wd, MLIST_UP, MLIST_DOWN, MLIST_BACK, MLIST_WHITE, mscroll );
	sld_adjust( wd->tree, -1 );
	
	if( !make_vstr( str, "MagiC ", gl_magx, 16 ) )
		if( !make_vstr( str, "N.AES ", gl_naes, 16 ) )
			make_vstr( str, "TOS   ", gl_tos, 16 );
	set_string( wd->tree, TOS_INFO, str );
	make_vstr( str, "MiNT  ", gl_mint, 10 );		
	set_string( wd->tree, DOS_INFO, str );
	make_vstr( str, "NVDI  ", gl_nvdi, 16 );
	set_string( wd->tree, VDI_INFO, str );
}

int16	maindial_exit_cb(WDIALOG *wd, int16 obj)
{
	int16	close = FALSE;
	extern	int16	quit;
	
	switch (obj)
	{
		case	WD_CLOSER :
			close = TRUE;
			debug("Closer ohne UNDO-Button!\n");
			break;
		
		case	MAIN_QUIT :
			close = TRUE;
			if(_app)
				quit = TRUE;
			break;
			
		case	T_SIZE:
			resize_main( wd );
			break;
			
		case	HELP_BOX:
			open_hyp( "*:\\mcontrol.hyp", "" );
			
		default:
			if( !sld_event( &msld, obj ) )
				dyn_event( wd, obj );
			break;
	}
	if (close)
	{}
	
	wdial_deselect( wd, obj, close );
	
	return close;
}


void	sld_adjust( OBJECT *tree, int16 pos )
{
	int16 size;
		
	size = (int16)(1000l * (int32)tree[LISTBACK].ob_height / (int32)tree[LISTBOX].ob_height);

	sld_setsize( &msld, size );
	sld_setpos( &msld, pos );
	sld_redraw( &msld );
}


/*----------------------------------------------------------------------------------------*/
/* Special key handling for dialog											 								*/
/* Return: -																										*/
/*----------------------------------------------------------------------------------------*/
NODE *node_findlast( NODE *nd )
{
	NODE *ret = NULL;

	if( nd && nd->content )
	{
		nd = nd->content;
	
		while( nd )
		{
			if( (nd->type == FolderTag) || (nd->type == ItemTag) )
				ret = nd;
				
			nd = nd->next;
		}
	}
	return ret;
}

int16	key_sdial(int16 kreturn, int16 kstate)
{
	int16 scan;
	int16	whdl, dummy;
	int16	ret = 1;
	NODE	*lastnode;

	scan = (kreturn & 0xFF00) >> 8;
	
	wind_get( 0, WF_TOP, &whdl, &dummy, &dummy, &dummy );
	
	if( whdl == wdial->win_handle )
	{
		dyn_fnode( wdial, hv_olditem );

		switch( scan )
		{
		case 1:				/* Esc */
			wd_selectnew( wdial, -1, hv_olditem, CHECKED );
			hv_olditem = -1;
			break;
		case 75:				/* Links */
			if( clnode && (clnode->type == FolderTag) && (clnode->attr.folder->open) )
				dyn_event( wdial, hv_olditem );
			break;
		case 77:				/* Rechts */
			if( clnode && (clnode->type == FolderTag) && !(clnode->attr.folder->open) )
				dyn_event( wdial, hv_olditem );
			break;
		case 72:				/* Oben */
			if( clnode )
			{
				NODE *nd1 = NULL;
			
				lastnode = clnode;

				if( clnode->prev )
				{
					clnode = clnode->prev;

					while( (clnode) && (clnode->type != FolderTag) && (clnode->type != ItemTag) )
					{
						lastnode = clnode;
						clnode = clnode->prev;
					}

					nd1 = clnode;

					while( clnode && ((clnode->type == FolderTag && clnode->attr.folder->open) || (clnode->type == RootNode)) )
					{
						lastnode = clnode;
						clnode = node_findlast( clnode );
					}
					
					if( nd1 && !clnode )
						clnode = lastnode;
				}
				else if( clnode->parent && (clnode->parent->type != RootNode) )
					clnode = clnode->parent;
			}
			else
			{
				clnode = gl_nodeptr;
				
				while( clnode && ((clnode->type == FolderTag && clnode->attr.folder->open) || (clnode->type == RootNode)) )
				{
					lastnode = clnode;
					clnode = node_findlast( clnode );
				}
				
				if( !clnode )
					clnode = lastnode;
			}
			
			if( clnode )
			{
				int16 newitem;
				
				if( clnode->type == FolderTag )
					newitem = clnode->attr.folder->text_ob;
				else if( clnode->type == ItemTag )
					newitem = clnode->attr.item->text_ob;
				else
					newitem = -1;
			
				wd_selectnew( wdial, newitem, hv_olditem, CHECKED );
				help_context( clnode );
				
				hv_olditem = newitem;
			}
			
			break;
		case 80:				/* Unten */
			if( !clnode )
				clnode = gl_nodeptr;
			
			lastnode = clnode;
			
			if( clnode->content && ((clnode->type == FolderTag && clnode->attr.folder->open) || (clnode->type == RootNode)) )
				clnode = clnode->content;
			else
				clnode = clnode->next;
			
			while( (clnode) && (clnode->type != FolderTag) && (clnode->type != ItemTag) )
			{
				lastnode = clnode;
				clnode = clnode->next;
			}
			
			if( !clnode && lastnode )
			{
				clnode = lastnode;
			
				while( !(clnode->next) && (clnode->parent) )
					clnode = clnode->parent;
				
				clnode = clnode->next;
					
				while( (clnode) && (clnode->type != FolderTag) && (clnode->type != ItemTag) )
					clnode = clnode->next;
			}
								
			if( clnode )
			{
				int16 newitem;
				
				if( clnode->type == FolderTag )
					newitem = clnode->attr.folder->text_ob;
				else if( clnode->type == ItemTag )
					newitem = clnode->attr.item->text_ob;
				else
					newitem = -1;
			
				wd_selectnew( wdial, newitem, hv_olditem, CHECKED );
				help_context( clnode );
				
				hv_olditem = newitem;
			}
			break;
		case 28:		/* Return */
		case 57:		/* Space */
		case 114:	/* Enter */
			if( hv_olditem >= 0 )
				dyn_event( wdial, hv_olditem );
			break;
					
		default:
			ret = 0;
			break;
		}
	}
	return ret;
}




/*----------------------------------------------------------------------------------------*/
/* Deselection and redraw for wdialog objects						 									*/
/* Return: -																										*/
/*----------------------------------------------------------------------------------------*/
void wdial_deselect( WDIALOG *wd, int16 obj, int16 close )
{
	if (get_flag(wd->tree, obj, EXIT) && !get_flag(wd->tree, obj, TOUCHEXIT) )
	{
		set_state(wd->tree, obj, SELECTED, FALSE);
		if (!close)
		{
			redraw_wdobj(wd, obj);
		}
	}
}


/*----------------------------------------------------------------------------------------*/
/* Context menu handling						 																*/
/* Return: -																										*/
/*----------------------------------------------------------------------------------------*/
int16	menu_context( int16 mx, int16 my )
{
	int16 obj, pob, wh;

	wh = wind_find( mx, my );
	
	set_state( tools, POP_ORIGIN, DISABLED, TRUE );
	set_state( tools, POP_ITOPEN, DISABLED, TRUE );
	set_flag( tools, POP_ITCLOSE, HIDETREE, TRUE );
	set_flag( tools, POP_ITOPEN, HIDETREE, FALSE );

	if( wh == wdial->win_handle && wdial->mode == WD_OPEN )
	{
		obj = objc_find( wdial->tree, ROOT, MAX_DEPTH, mx, my );
		
		if( obj > -1 )
		{
			dyn_fnode( wdial, obj );
			
			if( clnode )
			{
				my -= tools[POP_ITOPEN].ob_y;
			
				if( clnode->type == ItemTag && file_exist(clnode->attr.item->path) )
				{
					set_state( tools, POP_ORIGIN, DISABLED, FALSE );
					set_state( tools, POP_ITOPEN, DISABLED, FALSE );
				}
				else if( clnode->type == FolderTag )
				{
					set_state( tools, POP_ITOPEN, DISABLED, FALSE );
					if( clnode->attr.folder->open )
					{
						set_flag( tools, POP_ITOPEN, HIDETREE, TRUE );
						set_flag( tools, POP_ITCLOSE, HIDETREE, FALSE );					
					}
				}
			}
		}
		
		pob = icn_popup( TOOLS, POPUP, mx, my );
		
		switch( pob )
		{
			case POP_INFO:
				simple_mdial( about, 0 );
				break;
			case POP_ORIGIN:
				av_xwind( clnode->attr.item->path );
				break;
			case POP_ITCLOSE:
			case POP_ITOPEN:
				click_node( clnode, wdial, obj );
				break;
			case POP_HELP:
				open_hyp( "*:\\mcontrol.hyp", "" );
				break;				
			default:
				break;
		}
	}
	
	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* Context menu handling						 																*/
/* Return: -																										*/
/*----------------------------------------------------------------------------------------*/
int16	help_context( NODE *nd )
{
	int16	intaddr[2];
	*(uint8 **)(intaddr) = info_str;

	strcpy( info_str, " " );
	
	if( nd )
	{
		switch( nd->type )
		{
		case FolderTag:
			strcat( info_str, nd->attr.folder->bhlp );
			break;
		case ItemTag:
			strcat( info_str, nd->attr.item->bhlp );
			break;	
		}
	}

	wind_set( wdial->win_handle, WF_INFO, intaddr[0], intaddr[1], 0, 0 );

	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* Rollover effect handling for wdialog						 											*/
/* Return: -																										*/
/*----------------------------------------------------------------------------------------*/
static int16 hv_objc_find( OBJECT *tree, int16 start, int16 depth, int16 x, int16 y )
{
	int16	obj;
	
	obj = objc_find( tree, start, depth, x, y );

	if( (obj != -1) && ( !(tree[obj].ob_flags & 0x8000) || (tree[obj].ob_flags & HIDETREE) || (tree[obj].ob_state & DISABLED)) )
		obj = -1;

	return obj;
}

static void	wd_selectnew( WDIALOG *wd, int16 new, int16 old, int16 flag )
{
	if( old != -1 )
	{
		wd->tree[old].ob_state &= ~flag;
		redraw_wdobj( wd, old );
	}
	
	if( new != -1 )
	{
		GRECT rect;
	
		wd->tree[new].ob_state |= flag;
		redraw_wdobj( wd, new );
		
		objc_rect( wd->tree, new, &rect );
		
		while( (rect.g_y + rect.g_h) > (wd->work.g_y + wd->work.g_h) )
		{
			sld_arrow( &msld, SCROLL_LINE, 1 );
			objc_rect( wd->tree, new, &rect );
		}

		while( rect.g_y < wd->work.g_y )
		{
			sld_arrow( &msld, SCROLL_LINE, -1 );
			objc_rect( wd->tree, new, &rect );
		}
	}
}

int16 wdial_hover( int16 mx, int16 my, GRECT *r1, boolean *leave )
{
	int16		ret = TRUE;
	int16		item;
	WDIALOG	*wd;
	
	wd = wdial;

/*	debug("wdial_hover %d %d\n", r1->g_x, r1->g_y); */

	item = hv_objc_find( wd->tree, ROOT, MAX_DEPTH, mx, my );

	if( item > -1 )
	{
		*leave = TRUE;
		objc_rect( wd->tree, item, r1 );
	}
	else
	{
		*leave = FALSE;
		objc_rect( wd->tree, 0, r1 );
		
		if( rc_inside( r1, mx, my ) )
		{
			*leave = TRUE;
			r1->g_x = mx;
			r1->g_y = my;
			r1->g_w = 1;
			r1->g_h = 1;
		}
	}
	
	if( hv_olditem != item )
	{
		dyn_fnode( wd, item );
		help_context( clnode );
	
		wd_selectnew( wd, item, hv_olditem, CHECKED );
	
/*		if( hv_olditem != -1 )
		{
		/*	debug( "hv_olditem = %d, item = %d\n", hv_olditem, item ); */
		
			if( wd->tree[hv_olditem].ob_state & CHECKED )
				wd->tree[hv_olditem].ob_state &= ~CHECKED;
			else
				wd->tree[hv_olditem].ob_state |= CHECKED;
			redraw_wdobj( wd, hv_olditem );
		}

		if( item != -1 )
		{
			if( wd->tree[item].ob_state & CHECKED )
				wd->tree[item].ob_state &= ~CHECKED;
			else
				wd->tree[item].ob_state |= CHECKED;
			redraw_wdobj( wd, item );
		}
*/	}

	hv_olditem = item;
		
	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* Sizer Implementation																							*/
/* Funktionsresultat: -															 								*/
/*----------------------------------------------------------------------------------------*/
void	resize_main( WDIALOG *wd )
{
	extern	NODE		*gl_nodeptr;

	GRECT		wrect;
	GRECT		work;
	int16		w;
	int16		h;
	OBJECT	*tree;

	tree = wd->tree;

	wind_update( BEG_MCTRL );

	wind_get( wd->win_handle, WF_CURRXYWH, &wrect.g_x, &wrect.g_y, &wrect.g_w, &wrect.g_h );
	wind_get( wd->win_handle, WF_WORKXYWH, &work.g_x, &work.g_y, &work.g_w, &work.g_h );

	if ( graf_rubbox( wrect.g_x, wrect.g_y, md_mw, 198, &w, &h ))
	{
		GRECT	last;

		objc_offset( tree, SIZER_OBJS, &last.g_x, &last.g_y );	/* Position des Sizers */
		last.g_w = tree[SIZER_OBJS].ob_width;
		last.g_h = tree[SIZER_OBJS].ob_height;

		wind_set( wd->win_handle, WF_CURRXYWH, wrect.g_x, wrect.g_y, wrect.g_w, h);

		w -= wrect.g_w - work.g_w;										/* Breite der Arbeitsfl„che */
		h -= wrect.g_h - work.g_h - 16;								/* H”he der Arbeitsfl„che */

/*		tree[SIZER_OBJS].ob_x += w - tree->ob_width; */			/* Sizer verschieben */
		tree[SIZER_OBJS].ob_y += h - tree->ob_height;

		tree[LISTBACK].ob_height	+= h - tree->ob_height;
		tree[RIGHTBOX].ob_height	+= h - tree->ob_height;
		tree[MLIST_BACK].ob_height	+= h - tree->ob_height;
		tree[MLIST_WHITE].ob_height = tree[MLIST_BACK].ob_height;
		tree[MLIST_DOWN].ob_y		+= h - tree->ob_height;
		wd->work.g_h += h - tree->ob_height;

/*		tree->ob_width = w;	*/											/* Wurzelobjekt verkleinern */
		tree->ob_height = h;

		sld_adjust( wd->tree, mscroll( wd, -1, -1 ) );
	   redraw_wdobj(wd, R_TREE);
	}

	wind_update( END_MCTRL );
} 