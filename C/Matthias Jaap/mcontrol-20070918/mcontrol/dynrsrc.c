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

/*----------------------------------------------------------------------------------------*/
/* local includes																									*/
/*----------------------------------------------------------------------------------------*/

#include	"shared\appcomm.h"
#include	"shared\slider.h"
#include	"mcontrol.h"
#include	"dynrsrc.h"
#include	"config.h"
#include	"dialog.h"
#include	"rsrc.h"

#ifndef min
#define min(a, b)             ((a) < (b) ? (a) : (b))
#endif

#ifndef max
#define max(a, b)             ((a) > (b) ? (a) : (b))
#endif

/*----------------------------------------------------------------------------------------*/
/* defines																											*/
/*----------------------------------------------------------------------------------------*/

#ifndef	NIL
#define	NIL	-1
#endif

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

extern	OBJECT	*gl_obptr;
extern	NODE		*gl_nodeptr;

NODE		*clnode;

int16		i_depth;
boolean	gl_srun;
int16		gl_objnr;
int16		gl_width;
int16		nexty = 0;

const		int16		OBS_H	= 16;
const		int16		OBS_W	= 8;
const		int16		ICN_W = 48;
const		int16		OPEN_W = 16;
const		int16		INDENT = 64;

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

int16	cb_findnode( void *addr1, void *addr2, int16 obj, int16 data2 );

int16	refresh( NODE *node, OBJECT *tree );
int16	cb_refresh( void *addr1, void *addr2, int16 d1, int16 d2 );

int16	open_close( NODE *node, OBJECT *tree );
int16	adjusttree( NODE *node, OBJECT *tree );

int16	set_icon( NODE *node, OBJECT *tree );

/*----------------------------------------------------------------------------------------*/
/* functions																										*/
/*----------------------------------------------------------------------------------------*/

int16	mscroll( WDIALOG *wd, int16 kind, int16 val )
{
	int16	ret = 0;
	int16	oldy = wd->tree[LISTBOX].ob_y;

	if( kind == SCROLL_LINE )
	{
		wd->tree[LISTBOX].ob_y -= ( val * tools[ITEM_BOX].ob_height );
	}
	else if( kind == SCROLL_PAGE )
	{
		wd->tree[LISTBOX].ob_y -= ( val * wd->tree[LISTBACK].ob_height );
	}
	else if( kind == SCROLL_LIVE )
	{
		wd->tree[LISTBOX].ob_y = (int16)( (int32)-val * (int32)max(1,(wd->tree[LISTBOX].ob_height-wd->tree[LISTBACK].ob_height)) / 1000l );
	}
	else
	{}
	
	if( (wd->tree[LISTBOX].ob_y + wd->tree[LISTBOX].ob_height) < wd->tree[LISTBACK].ob_height )
		wd->tree[LISTBOX].ob_y = wd->tree[LISTBACK].ob_height - wd->tree[LISTBOX].ob_height;
	
	if( wd->tree[LISTBOX].ob_y > 0 )
		wd->tree[LISTBOX].ob_y = 0;
	
	if( oldy != wd->tree[LISTBOX].ob_y )
	{
		if( !objc_scroll( wd->tree, vdi_handle, LISTBACK, wd->win_handle, wd->tree[LISTBOX].ob_y - oldy, 0, 0 ) )
			redraw_wdobj( wd, LISTBACK );
	}

	ret = (int16)(1000l * (int32)-wd->tree[LISTBOX].ob_y / (int32)max(1,(wd->tree[LISTBOX].ob_height-wd->tree[LISTBACK].ob_height)));

	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* find object	(right click)																					*/
/*----------------------------------------------------------------------------------------*/
int16	dyn_fnode( WDIALOG *wd, int16 obj )
{
	gl_srun = TRUE;
	clnode = NULL;

	if( obj > -1 )
		searchtree( gl_nodeptr, wd, obj, 0, cb_findnode );
	
	return 0;
}


int16	cb_findnode( void *addr1, void *addr2, int16 obj, int16 data2 )
{
	int16		ret = 0;
	NODE		*nd = addr1;
	WDIALOG	*wd = addr2;

	if( nd->object == obj )
	{
		clnode = nd;
		ret = 1;
	}
	else if( nd->type == FolderTag )
	{
		if( obj == nd->attr.folder->icon_ob || obj == nd->attr.folder->text_ob 
		 || obj == nd->attr.folder->open_ob )
		{
			clnode = nd;
			ret = 1;
		}
	}
	else if( nd->type == ItemTag )
	{
		if( obj == nd->attr.item->icon_ob || obj == nd->attr.item->text_ob )
		{
			clnode = nd;
			ret = 1;
		}
	}
	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* find object	(left click)																					*/
/*----------------------------------------------------------------------------------------*/
int16	dyn_event( WDIALOG *wd, int16 obj )
{
	dyn_fnode( wd, obj );

	if( clnode )
	{
		click_node( clnode, wd, obj );
	}
	
	return 0;
}


int16	click_node( NODE *nd, WDIALOG	*wd, int16 obj )
{
	int16		ret = 0;

	if( nd->object == obj )
	{
		switch( nd->type )
		{
			case FolderTag:	break;
			case ItemTag: 		break;
			case HrTag: 		break;
			default:				break;
		}
	}
	else if( nd->type == FolderTag )
	{
		if( obj == nd->attr.folder->icon_ob )
		{}
		else if( obj == nd->attr.folder->text_ob || obj == nd->attr.folder->open_ob )
		{
			open_close( nd, wd->tree );
			refresh( nd, wd->tree );
			adjusttree( gl_nodeptr, wd->tree );
			redraw_wdobj( wd, LISTBACK );
			sld_adjust( wd->tree, mscroll( wd, -1, -1 ) );
		}
	}
	else if( nd->type == ItemTag )
	{
		if( obj == nd->attr.item->icon_ob )
		{}
		else if( obj == nd->attr.item->text_ob )
		{
			uint8	*args = NULL;
			
			if( strlen( nd->attr.item->args ) )
				args = nd->attr.item->args;
		
			av_startprog( nd->attr.item->path, args );
		}
	}
	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* open / close subfolders																						*/
/*----------------------------------------------------------------------------------------*/
int16	refresh( NODE *node, OBJECT *tree )
{
	gl_srun = TRUE;	
	searchtree( node, tree, 0, 0, cb_refresh );	
	return 0;
}

int16	cb_refresh( void *addr1, void *addr2, int16 d1, int16 d2 )
{
	NODE		*step;
	NODE		*node = addr1;
	OBJECT	*tree = addr2;

	if( node->content && node->type == FolderTag )
		step = node->content;
	else
		return 0;

	while( step )
	{
		set_flag( tree, step->object, HIDETREE, !(node->attr.folder->open) );		
		step = step->next;
	}
	
	return 0;
}

int16	open_close( NODE *node, OBJECT *tree )
{
	if( node->attr.folder->open )
	{
		tree[node->attr.folder->open_ob].ob_spec = tools[FOLDER_OPEN].ob_spec;
		node->attr.folder->open = FALSE;
	}
	else
	{
		tree[node->attr.folder->open_ob].ob_spec = tools[FOLDER_CLOSE].ob_spec;
		node->attr.folder->open = TRUE;
	}
	
	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* open / close subfolders																						*/
/*----------------------------------------------------------------------------------------*/
int16	set_icon( NODE *node, OBJECT *tree )
{
	int16	objc;
	int16	i = 0;
	uint8	*name;

	if( !node || !tree )
		return 0;

	if( node->type == FolderTag )
	{
		name = node->attr.folder->icon;
		objc = node->attr.folder->icon_ob;
	} 
	else if( node->type == ItemTag )
	{
		name = node->attr.item->icon;
		objc = node->attr.item->icon_ob;
	}
	else
		return 0;

	do
	{	
		if( icons[i].ob_type == G_CICON )
		{
			if( strcmp(icons[i].ob_spec.ciconblk->monoblk.ib_ptext, name) == 0 )
			{
				icons[i].ob_spec.ciconblk->monoblk.ib_xicon = 0;
				icons[i].ob_spec.ciconblk->monoblk.ib_yicon = 0;
		/*		icons[i].ob_spec.ciconblk->monoblk.ib_xchar = 0;
				icons[i].ob_spec.ciconblk->monoblk.ib_ychar = 0; */
				icons[i].ob_spec.ciconblk->monoblk.ib_xtext = -1;
				icons[i].ob_spec.ciconblk->monoblk.ib_ytext = -1;
				icons[i].ob_spec.ciconblk->monoblk.ib_wtext = 0;
				icons[i].ob_spec.ciconblk->monoblk.ib_htext = 0;
				icons[i].ob_width = icons[i].ob_spec.ciconblk->monoblk.ib_wicon;
				icons[i].ob_height = icons[i].ob_spec.ciconblk->monoblk.ib_hicon;

				tree[objc].ob_type	= icons[i].ob_type;
				tree[objc].ob_spec	= icons[i].ob_spec;
				tree[objc].ob_width	= icons[i].ob_width;
				tree[objc].ob_height	= icons[i].ob_height;
				
				tree[objc].ob_x = tree[objc].ob_x + (ICN_W - tree[objc].ob_width)/2;
			}
		}
		i++;
	}
	while( !(icons[i-1].ob_flags & LASTOB) );
	
	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* adjust object positions																						*/
/*----------------------------------------------------------------------------------------*/
int16	adjusttree( NODE *node, OBJECT *tree )
{
	int16	height = 0;
	NODE	*step = node;
	i_depth++;
	
	while( step )
	{	
		if( step->type != RootNode )
			tree[step->object].ob_y = get_nexty( step );


		if( step->type == ItemTag )
		{
			if( tree[step->object].ob_y == 0 )
				tree[step->object].ob_y = 32;	
		}

		if( step->content )
		{
			if( step->type == FolderTag )
			{
				if( step->attr.folder->open )
				{
					tree[step->object].ob_height = adjusttree( step->content, tree );
					tree[step->object].ob_height += 32;
				}
				else
					tree[step->object].ob_height = 32;
			}
			else
				tree[step->object].ob_height = adjusttree( step->content, tree );
		}

		height += tree[step->object].ob_height;
		step = step->next;			
	}
	
	i_depth--;

	return height;
}


/*----------------------------------------------------------------------------------------*/
/* search the tree / callback																					*/
/* return:	0																										*/
/*----------------------------------------------------------------------------------------*/
int16	searchtree( NODE *node, void *addr2, int16 data1, int16 data2, SEARCHTREE_CB callback )
{
	NODE	*step;
	step = node;
	i_depth++;
	
	while( gl_srun && step )
	{
		if( callback( step, addr2, data1, data2 ) == 1 )
		{
			gl_srun = FALSE;
			break;
		}
	
		if( step->content )
		{
			searchtree( step->content, addr2, data1, data2, callback );
		}
		step = step->next;
	}
	
	i_depth--;
	return 0;
}


/*----------------------------------------------------------------------------------------*/
/* -																													*/
/*----------------------------------------------------------------------------------------*/
int16	get_nexty( NODE *node )
{
	int16	ret = 0;

/*	ret = nexty;
	nexty+= 24; */

	if( node->prev  )
	{
		ret = gl_obptr[node->prev->object].ob_y + gl_obptr[node->prev->object].ob_height;
	}
	
	return ret;
}


void	rscadd_hr( NODE *node )
{
	int16	ind = 0;
	if( node->parent->type == FolderTag )
		ind = INDENT;

	obj_dcopy( gl_obptr, gl_objnr, tools, SEPARATOR );
	gl_obptr[gl_objnr].ob_x = OBS_W + ind;
	gl_obptr[gl_objnr].ob_y = get_nexty( node );
	gl_obptr[gl_objnr].ob_width = gl_obptr[node->parent->object].ob_width - OBS_H - ind;
	objc_add( gl_obptr, node->parent->object, gl_objnr );
	gl_obptr[node->parent->object].ob_height += 8;
	node->object = gl_objnr;
	
	gl_objnr++;
}


void	rscadd_item( NODE *node )
{
	obj_dcopy( gl_obptr, gl_objnr, tools, ITEM_BOX );
	gl_obptr[gl_objnr].ob_x = INDENT;
	gl_obptr[gl_objnr].ob_y = get_nexty( node );
	if( gl_obptr[gl_objnr].ob_y == 0 ) gl_obptr[gl_objnr].ob_y = 32;	
	objc_add( gl_obptr, node->parent->object , gl_objnr );
	node->object = gl_objnr;
	
	gl_objnr++;

	obj_dcopy( gl_obptr, gl_objnr, tools, ITEM_STRING );
	gl_obptr[gl_objnr].ob_x = ICN_W;
	gl_obptr[gl_objnr].ob_y = 8;
	objc_add( gl_obptr, node->object, gl_objnr );
	gl_obptr[gl_objnr].ob_spec.free_string = node->attr.item->name;
	node->attr.item->text_ob = gl_objnr;
	
	gl_objnr++;

	obj_dcopy( gl_obptr, gl_objnr, tools, ITEM_ICON );
	gl_obptr[gl_objnr].ob_x = 0;
	gl_obptr[gl_objnr].ob_y = 0;
	objc_add( gl_obptr, node->object, gl_objnr );
	node->attr.item->icon_ob = gl_objnr;
	set_icon( node, gl_obptr );
	
	gl_objnr++;
}


void	rscadd_folder( NODE *node )
{
	obj_dcopy( gl_obptr, gl_objnr, tools, FOLDER_BOX );
	gl_obptr[gl_objnr].ob_x = OBS_W;
	gl_obptr[gl_objnr].ob_y = get_nexty( node );
	gl_obptr[gl_objnr].ob_width = gl_obptr[node->parent->object].ob_width - OBS_H;
	objc_add( gl_obptr, node->parent->object, gl_objnr );
	node->object = gl_objnr;
	
	gl_objnr++;
	
	obj_dcopy( gl_obptr, gl_objnr, tools, FOLDER_OPEN );
	gl_obptr[gl_objnr].ob_x = 0;
	gl_obptr[gl_objnr].ob_y = 8;
	objc_add( gl_obptr, node->object, gl_objnr );
	node->attr.folder->open_ob = gl_objnr;
	
	gl_objnr++;
	
	obj_dcopy( gl_obptr, gl_objnr, tools, FOLDER_ICON );
	gl_obptr[gl_objnr].ob_x = OPEN_W;
	gl_obptr[gl_objnr].ob_y = 0;
	objc_add( gl_obptr, node->object, gl_objnr );
	node->attr.folder->icon_ob = gl_objnr;
	set_icon( node, gl_obptr );
	
	gl_objnr++;
	
	obj_dcopy( gl_obptr, gl_objnr, tools, FOLDER_STRING );
	gl_obptr[gl_objnr].ob_x = OPEN_W + ICN_W;
	gl_obptr[gl_objnr].ob_y = 8;
	objc_add( gl_obptr, node->object, gl_objnr );
	node->attr.folder->text_ob = gl_objnr;
	gl_obptr[gl_objnr].ob_spec.free_string = node->attr.folder->name;
	
	gl_objnr++;

/*	obj_dcopy( gl_obptr, gl_objnr, tools, CONTENT_BOX );
	gl_obptr[gl_objnr].ob_x = 80;
	gl_obptr[gl_objnr].ob_y = 16;
	gl_obptr[gl_objnr].ob_height = 0;
	objc_add( gl_obptr, node->object, gl_objnr );
	node->attr.folder->cntn_ob = gl_objnr;
	
	gl_objnr++; */
}


void	build_subtree( NODE *np )
{
	NODE	*step;
	step = np;

	while( step )
	{
		switch( step->type )
		{
			case FolderTag:	rscadd_folder( step );
									break;
			case ItemTag: 		rscadd_item( step );
									break;
			case HrTag: 		rscadd_hr( step );
									break;
			default:				break;
		}

		if( step->content )
		{
			i_depth++;
			build_subtree( step->content );
			i_depth--;
		}
		step = step->next;
	}
}


void	build_obtree( NODE *np )
{
	np->object = LISTBOX;
	
	gl_objnr = tree_copy( gl_obptr, maindial );
	gl_obptr[gl_objnr].ob_flags &= ~LASTOB;
	gl_objnr++;
	gl_width = gl_obptr[LISTBOX].ob_width;
	
	build_subtree( np );
	
	gl_obptr[gl_objnr-1].ob_flags |= LASTOB;
	
	refresh( np, gl_obptr );
	adjusttree( np, gl_obptr );
}