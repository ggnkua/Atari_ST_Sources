/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: fontsel.c
 *	description: fonction FontSel()
 */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "scancode.h"
#include "globals.h"
#include "fontsel.h"
#include "fontsel.rh"
#include "fontsel.rsh"
#include "cookie.h"
#include "userdef.h"


struct fonte {
	char name[33];
	int id; 
};
	
static void fill_field( OBJECT *tree, struct fonte *list, int pos, int max) {
	int i;
	char buf[33];
	
	for( i = FONT1; i <= FONT8; i++) {
		if( i-FONT1+pos <= max) {
			if( i-FONT1+pos == 0)
				strcpy( buf, "system font");
			else
				strcpy( buf, list[i-FONT1+pos].name);
			strncpy( tree[i].ob_spec.free_string, buf, 30);
			tree[i].ob_spec.free_string[30]='\0';
		} else
			strcpy( tree[i].ob_spec.free_string, "");
	}
}

/* Dessin du texte t‚moin */

static
void font_draw( WINDOW *win, PARMBLK *pblk) {
	v_gtext( win->graf.handle, pblk->pb_x+5,
			 pblk->pb_y+pblk->pb_h-5, (char *)DataSearch( win, WD_WFNT));
}

/*
 *	S‚lecteur interne de fonte
 */
 
int FontSel( char *winname, char *example, int flags,        /* entr‚es */
			 int *fontid, int *fontsize, char *fontname) {	 /* sorties */
	OBJECT *tree;
	int res;
	INT16 x,y;
	int max, pos=0,
			 sel=0;
	int id, size;
	WINDOW *win;
	static int init_fontsel = 0;
	EVNTvar save;
	struct fonte *list;

	char dummy[70];
	int mono = -1, index, i, v;

	/* ressource interne */
	tree = rs_trindex[FONTSEL];
	if( !init_fontsel) {
		for( res=0; res<NUM_OBS; rsrc_obfix( rs_object, res++));
		init_fontsel = 1;
	}
	/* Installer nos types ‚tendus de sliders */
/*	init_type( tree, FONT_UP, ub_xboxchar, SLIDEPART);
	init_type( tree, FONT_DN, ub_xboxchar, SLIDEPART); */
	init_type( tree, FONT_UP, ub_boxchar3d, SLIDEPART);
	init_type( tree, FONT_DN, ub_boxchar3d, SLIDEPART);	

	win = FormWindBegin( tree, winname);

	/* Sans Gdos, on a une fonte : "system font", id 0
	 * Avec Gdos, la fonte 0 est la fonte systeme  */

	RsrcUserDraw( OC_FORM, win, FONT_USER, font_draw);
	DataAttach( win, WD_WFNT, example?example:fontname);
	
	id = *fontid;
	size = *fontsize;
	sel = -1;

	max = VstLoadFonts( win->graf.handle, 0)+app.work_out[10];
	list = (struct fonte *)malloc(sizeof(struct fonte)*(max+1));
	for( i=0; i<=max; i++) {
		if( flags & MONOSPACED) {
			VqtXname( win->graf.handle, 0, i, dummy, &v);
			if( v & 0x2) {
				index = ++mono;
				res = VqtName( win->graf.handle, i, list[mono].name);
				list[mono].id = res;
			} else
				continue;
		} else {
			index = i;
			res = VqtName( win->graf.handle, i, list[i].name);
			list[i].id = res;
		}
		if( res == id) {
			sel = index;
			VstFont( win->graf.handle, id);
			strcpy( fontname, id?list[i].name:"system font");
		}
	}
	if( flags & MONOSPACED) max = mono;
	
	pos = MAX(MIN( sel, max-8),0);
	fill_field( tree, list, pos, max);
	if( (sel-pos) >= 0 && (sel-pos)<8)
		ObjcChange( OC_FORM, win, sel-pos+FONT1, SELECTED, 0);

	if( size == 0)
		size = 10;
	sprintf( ObjcString( tree, FONT_SIZE, NULL), "%d", size);
	if( flags & VSTHEIGHT) {
		vst_height( win->graf.handle, size, &x, &x, &x, &x);
		strcpy( tree[FONT_SIZE].ob_spec.tedinfo->te_ptmplt, " __ pxl" );
	} else
		vst_point( win->graf.handle, size, &x, &x, &x, &x);

	save = evnt;
	evnt.bclick = 2;
	evnt.bmask = 1;
	evnt.bstate = 1;
	
	do {
		res = FormWindDo(MU_MESAG|MU_KEYBD|FORM_EVNT);

		/* Gestion des ‚v‚nements */
		if ( res & FORM_EVNT) {
			if ( res & MU_MESAG) 
			switch( evnt.buff[0]) {
			case AP_TERM:
				res = FONT_CANCEL;
				snd_msg( NULL, AP_TERM, 0, 0, 0, 0);
				break;
			case WM_DESTROY:
				res = FONT_CANCEL;
				break;
			}
			if ( res & MU_KEYBD) {
				if ( ((evnt.keybd&0x00FF)>='0' &&  (evnt.keybd&0x00FF)<='9')
					 || (evnt.keybd&0x00FF) == 0x16 /*CONTROL-V*/)
					goto UPDATE;

				switch (evnt.keybd >> 8) {
				case SC_BACK:
				case SC_DEL:
				case SC_ESC:
UPDATE:				size = atoi( ObjcString( tree, FONT_SIZE, NULL));
					if( flags & VSTHEIGHT)
						vst_height( win->graf.handle, size, &x, &x, &x, &x);
					else
						vst_point( win->graf.handle, size, &x, &x, &x, &x);
					ObjcDraw( OC_FORM, win, FONT_DRAW, OC_MSG);
					break;
				case SC_UPARW:
				case SC_DWARW:
					if( (sel-pos) >= 0 && (sel-pos)<8)
						ObjcChange( OC_FORM, win, sel-pos+FONT1, NORMAL, OC_MSG);
					sel = ((evnt.keybd >> 8)==SC_UPARW)?MAX(sel-1, 0):MIN(sel+1,max);
					strcpy( fontname, list[sel].name);
					id = list[sel].id;
					vst_font( win->graf.handle, id);
					ObjcDraw( OC_FORM, win, FONT_DRAW, OC_MSG);
					sprintf( ObjcString( tree, IDFONT, NULL), "%d", id);
					ObjcDraw( OC_FORM, win, IDFONT, OC_MSG);
					if( (sel-pos) >= 0 && (sel-pos)<8)
						ObjcChange( OC_FORM, win, sel-pos+FONT1, SELECTED, OC_MSG);
					if((evnt.keybd >> 8)==SC_UPARW) {
						if( sel < pos)
							res = FONT_UP;
					} else {
						if(  sel >= pos+8)
							res = FONT_DN;
					}
					break;
				}
			}
		}
		switch( res) {
		case FONT_UP:
			ObjcChange( OC_FORM, win, res, SELECTED, 1);
			do {
				if( pos > 0) {
					if( (sel-pos) >= 0 && (sel-pos)<8)
						ObjcChange( OC_FORM, win, sel-pos+FONT1, NORMAL, 0);
					pos --;
					if( (sel-pos) >= 0 && (sel-pos)<8)
						ObjcChange( OC_FORM, win, sel-pos+FONT1, SELECTED, 0);
					
					fill_field( tree, list, pos, max);
					ObjcDraw( OC_FORM, win, FONT_BACK, 2);
  				}
				graf_mkstate( &x,&x,&y,&x);
			} while( y);
			ObjcChange( OC_FORM, win, res, NORMAL, 1);
			break;
		case FONT_DN:
			ObjcChange( OC_FORM, win, res, SELECTED, 1);
			do {
				if( pos <= max-8 ) {
					if( (sel-pos) >= 0 && (sel-pos)<8)
						ObjcChange( OC_FORM, win, sel-pos+FONT1, NORMAL, 0);
					pos ++;
					if( (sel-pos) >= 0 && (sel-pos)<8)
						ObjcChange( OC_FORM, win, sel-pos+FONT1, SELECTED, 0);
					fill_field( tree, list, pos, max);
					ObjcDraw( OC_FORM, win, FONT_BACK, 2);
				}
				graf_mkstate( &x,&x,&y,&x);
			} while( y);
			ObjcChange( OC_FORM, win, res, NORMAL, 1);
			break;
		case FONT1:
		case FONT2:
		case FONT3:
		case FONT4:
		case FONT5:
		case FONT6:
		case FONT7:
		case FONT8:
			if( strlen( tree[res].ob_spec.free_string)) {
				if( sel != res-FONT1+pos) {
					strcpy( fontname, list[pos+res-FONT1].name);
					id = list[pos+res-FONT1].id;
					vst_font( win->graf.handle, id);
					ObjcChange( OC_FORM, win, res, SELECTED, OC_MSG);
					if( (sel-pos) >= 0 && (sel-pos)<8)
						ObjcChange( OC_FORM, win, sel-pos+FONT1, NORMAL, OC_MSG);
					sel = res-FONT1+pos;
					if( sel == 0)
						strcpy( fontname, "system font");
					sprintf( ObjcString( tree, IDFONT, NULL), "%d", id);
					ObjcDraw( OC_FORM, win, IDFONT, OC_MSG|7);
					ObjcDraw( OC_FORM, win, FONT_DRAW, /*OC_MSG|*/7);
				}
				if( evnt.nb_click == 2)
					res = FONT_OK;
			}
			break;
		}
	} while ( res != FONT_OK && res != FONT_CANCEL);
	
	tree[res].ob_state &= ~SELECTED;
	if( (sel-pos) >= 0 && (sel-pos)<8)
		tree[sel-pos+FONT1].ob_state &= ~SELECTED;
	
	VstUnloadFonts( win->graf.handle, 0);
	DataDelete( win, WD_WFNT);
	FormWindEnd();
	evnt = save;
	
	free( list);

	/* Lib‚rer les types ‚tendus */
	free_type( tree, FONT_UP);
	free_type( tree, FONT_DN);
	
	*fontid = id;
	*fontsize = size;
	return (res == FONT_OK);
}
