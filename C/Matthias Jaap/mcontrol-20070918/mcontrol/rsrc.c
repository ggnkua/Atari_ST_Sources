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

#include	"mcontrol.h"
#include	"rsrc.h"

/*----------------------------------------------------------------------------------------*/
/* local defines																									*/
/*----------------------------------------------------------------------------------------*/

#ifndef TXT_LIGHT
#define TXT_LIGHT			0x0002
#define TXT_UNDERLINED	0x0008
#endif

/*----------------------------------------------------------------------------------------*/
/* global variables																								*/
/*----------------------------------------------------------------------------------------*/

OBJECT	*menu, *wicon, *about, *maindial, *tools, *icons;

int16		vdi_handle;
int16		aes_flags;
int16		menu_id = 0;
int16		h3d, v3d;
uint8		**fstring_addr;

/*----------------------------------------------------------------------------------------*/
/* function prototypes																							*/
/*----------------------------------------------------------------------------------------*/

			void	*cf_malloc(long size, char *who, int global);
static	void	make_userdef(OBJECT *tree, int obj, int cdecl (*proc)(PARMBLK *p));
static	int	cdecl draw_underline(PARMBLK *p);
static	int	cdecl draw_aquaback(PARMBLK *p);

/*----------------------------------------------------------------------------------------*/
/* functions																										*/
/*----------------------------------------------------------------------------------------*/

void	init_rsrc( void )
{
	int16	work_out[57];
	int16	ag1, ag2, ag3, ag4;

	vdi_handle = open_vwork(work_out);

	if (gl_gdos)
		vst_load_fonts(vdi_handle, 0);

	if ( (_GemParBlk.global[0] >= 0x0400) || (_app == 0) )
		menu_id = menu_register(gl_apid, "  Control Center");

	rsrc_gaddr( R_TREE, MENUTREE, &menu );				/* get tree pointer */

	if(_app)
		create_menu(menu);

	rsrc_gaddr( R_TREE, MAINDIAL, &maindial );
	rsrc_gaddr( R_TREE, WINICON, &wicon );
	rsrc_gaddr( R_TREE, ABOUT, &about );
	rsrc_gaddr( R_TREE, TOOLS, &tools );
	rsrc_gaddr( R_TREE, ICONS, &icons );
	rsrc_gaddr( R_FRSTR, WRITE_ERROR, &fstring_addr );	/* get first alert */
	
	fix_popup( tools, 1 );

	if ( appl_xgetinfo( 13, &ag1, &ag2, &ag3, &ag4 ))		/* Unterfunktion 13, Objekte */
	{
		if ( ag4 & 0x08 )												/* G_SHORTCUT untersttzt ? */
			aes_flags |= GAI_GSHORTCUT;
			
		if ( ag1 && ag2 )												/* 3D-Objekte und objc_sysvar() vorhanden? */
		{
			if ( objc_sysvar( 0, AD3DVALUE, 0, 0, &h3d, &v3d ))	/* 3D-Look eingeschaltet? */
			{
				if ( gl_planes >= 4 )								/* mindestens 16 Farben? */
				{
					int16	radio_bgcol, dummy;
						
					aes_flags |= GAI_3D;
					objc_sysvar( 0, BACKGRCOL, 0, 0, &radio_bgcol, &dummy );
				}
			}
		}
	}
}

void	exit_rsrc( void )
{
	delete_menu();
	
	if( vdi_handle != -1 )
	{
		if (gl_gdos)
			vst_unload_fonts(vdi_handle, 0);

		v_clsvwk(vdi_handle);		
	}
}

/*----------------------------------------------------------------------------------------*/
/* count number of objects of a tree																		*/
/* result:	number																 								*/
/*----------------------------------------------------------------------------------------*/
int16	objc_count( OBJECT *tree )
{
	int16	ret = 0;

	if( !tree )
		return 0;

	do  ret++;
	while( !(tree[ret-1].ob_flags & LASTOB) );
	
	return ret;
}


/*----------------------------------------------------------------------------------------*/
/* copy object tree																								*/
/* result:	-																		 								*/
/*----------------------------------------------------------------------------------------*/
int16	obj_copy( OBJECT *dtree, int16 di, OBJECT *stree, int16 si )
{
	if( !dtree || !stree )
		return 0;

	dtree[di].ob_next		= stree[si].ob_next;		/* das n„chste Objekt        */
	dtree[di].ob_head		= stree[si].ob_head;		/* erstes Kind               */
	dtree[di].ob_tail		= stree[si].ob_tail;		/* letztes Kind              */
	dtree[di].ob_type		= stree[si].ob_type;		/* Objektart                 */
	dtree[di].ob_flags	= stree[si].ob_flags;	/* Manipulationsflags        */
	dtree[di].ob_state	= stree[si].ob_state;	/* Objektstatus              */
	dtree[di].ob_spec		= stree[si].ob_spec;		/* mehr unter Objektart      */
	dtree[di].ob_x			= stree[si].ob_x;			/* x-Koordinate des Objekts  */
	dtree[di].ob_y			= stree[si].ob_y;			/* y-Koordinate des Objekts  */
	dtree[di].ob_width	= stree[si].ob_width;	/* Breite des Objekts        */
	dtree[di].ob_height	= stree[si].ob_height;	/* H”he des Objekts          */
	
	return 1;
}


/*----------------------------------------------------------------------------------------*/
/* copy object tree																								*/
/* result:	-																		 								*/
/*----------------------------------------------------------------------------------------*/
int16	obj_dcopy( OBJECT *dtree, int16 di, OBJECT *stree, int16 si )
{
	if( !dtree || !stree )
		return 0;

	dtree[di].ob_next		= -1;
	dtree[di].ob_head		= -1;
	dtree[di].ob_tail		= -1;
	dtree[di].ob_type		= stree[si].ob_type;
	dtree[di].ob_flags	= stree[si].ob_flags & ~LASTOB;
	dtree[di].ob_state	= stree[si].ob_state;
	dtree[di].ob_spec		= stree[si].ob_spec;
	dtree[di].ob_x			= stree[si].ob_x;
	dtree[di].ob_y			= stree[si].ob_y;
	dtree[di].ob_width	= stree[si].ob_width;	/* Breite des Objekts        */
	dtree[di].ob_height	= stree[si].ob_height;	/* H”he des Objekts          */
	
	return 1;
}


/*----------------------------------------------------------------------------------------*/
/* copy object tree																								*/
/* result:	-																		 								*/
/*----------------------------------------------------------------------------------------*/
int16	tree_copy( OBJECT *dest, OBJECT *src )
{
	int16 i = -1;

	if( !dest || !src )
		return 0;

	do
	{
		i++;
		obj_copy( dest, i, src, i );
	}
	while( !(src[i].ob_flags & LASTOB) );
	
	return i;
}


void fix_special(OBJECT *tree)
{
	int	i = -1;

	do
	{
		i++;
		if( (tree[i].ob_type == G_STRING) || (tree[i].ob_type == G_SHORTCUT) )
		{
			if( tree[i].ob_flags & 0x8000 )
				make_userdef(tree, i, draw_underline);
		}
		
		if(i == RIGHTBOX)
			make_userdef(tree, i, draw_aquaback);
	}
	while (!(tree[i].ob_flags & LASTOB));
}


static void make_userdef(OBJECT *tree, int obj, int cdecl (*proc)(PARMBLK *p))
{
	USERBLK	*uPtr;

	uPtr = (USERBLK *)cf_malloc(sizeof(USERBLK), "make_userdef", FALSE);
	if (uPtr != NULL)
	{
		uPtr->ub_code = proc;								/* neue Zeichenfunktion */
		uPtr->ub_parm = tree[obj].ob_spec.index;		/* alte obSpec sichern */
										/* alten Typ hochschieben und neuen eintragen */
		tree[obj].ob_type = (tree[obj].ob_type << 8) + G_USERDEF;
		tree[obj].ob_spec.index = (long)uPtr;			/* Userblock eintragen */
	}
}


static int cdecl draw_aquaback(PARMBLK *p)
{
	int16 pxy[8];
	int16	x0;
	int16 y0;

	set_clipping(vdi_handle, p->pb_xc, p->pb_yc, p->pb_wc, p->pb_hc, TRUE);
	vswr_mode(vdi_handle, MD_REPLACE);

	pxy[0] = x0 = p->pb_x;				pxy[1] = y0 = p->pb_y;
	pxy[2] = p->pb_x + p->pb_w -1 ;	pxy[3] = p->pb_y + p->pb_h - 1;

	vsf_interior(vdi_handle, FIS_PATTERN); /* FIS_PATTERN */
	vsf_color(vdi_handle, LWHITE );
	vsf_style(vdi_handle, 4);
	v_bar(vdi_handle, pxy);

	pxy[3] = pxy[1];

/*	while( (pxy[1]-y0) < (p->pb_h) )
	{
		vsl_color(vdi_handle, WHITE);
		v_pline(vdi_handle, 2, pxy);
		pxy[1]+=2;	pxy[3]+=2;
	}
*/	
	while( (pxy[1]-y0+2) < (p->pb_h) )
	{
		vsl_color(vdi_handle, LWHITE); 
		v_pline(vdi_handle, 2, pxy);
		pxy[1]+=2;	pxy[3]+=2;
		vsl_color(vdi_handle, WHITE);
		v_pline(vdi_handle, 2, pxy);
		pxy[1]+=2;	pxy[3]+=2;
	}
	
	if( (pxy[1]-y0) < (p->pb_h) )
	{
		vsl_color(vdi_handle, LWHITE);
		v_pline(vdi_handle, 2, pxy);
	}
	
	return (p->pb_currstate);
}

static int cdecl draw_underline(PARMBLK *p)
{
	char	*str;
	int	d, wBox, hBox, effect = 0;

	set_clipping(vdi_handle, p->pb_xc, p->pb_yc, p->pb_wc, p->pb_hc, TRUE);
	vswr_mode(vdi_handle, MD_TRANS);

	/* Font */
	vst_alignment(vdi_handle, 0, 5, &d, &d);
	vst_font(vdi_handle, sys_big_id);
	vst_height(vdi_handle, sys_big_height, &d, &d, &wBox, &hBox);

	/* Text ausgeben */
	str = (char *)p->pb_parm;
	vst_color(vdi_handle, 12);
	
	if(p->pb_tree[p->pb_obj].ob_state & DISABLED)
		effect |= TXT_LIGHT;

	if(p->pb_tree[p->pb_obj].ob_state & CHECKED)
		effect |= TXT_UNDERLINED;

	if(p->pb_tree[p->pb_obj].ob_state & SELECTED)
		vst_color(vdi_handle, 2);

	vst_effects(vdi_handle, effect);
	v_gtext(vdi_handle, p->pb_x, p->pb_y, str);

	/* Linie */
/*	len = get_txtlen(str);*/
/*	len = p->pb_w;

	vsl_color(vdi_handle, 9);

	pxy[0] = p->pb_x;			pxy[1] = p->pb_y + hBox;
	pxy[2] = p->pb_x + len; pxy[3] = pxy[1];
	v_pline(vdi_handle, 2, pxy);

	vsl_color(vdi_handle, 0);
	pxy[1]--; pxy[3]--;
	v_pline(vdi_handle, 2, pxy); */

	return (p->pb_currstate & ~(CHECKED|DISABLED|SELECTED));
}