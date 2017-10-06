/*
 *	Gestion de frames 
 *		modif mineure: WindGet(), avec WF_WORKXYWH
 					   WindClose(), WindDelete(),
 					   WindSlider()
 *					   WINDOW
 *
 *	Bugs: Quand on enleve certaines frames avec FrameRemove()
 *		  ca plante dans FrameCalc()
 *
 *	Reste a faire: gestion des barres de deplacements
 *	   			   tester les attributs dans set_gadget_pos() et
 *				   utiliser wind_get() pour les r‚glages des couleurs 
 *				   des fenˆtres
 *				   faire des version sp‚cifique MonoChrome et Tos
 */

#include <stddef.h>
#include <stdarg.h>
#include <stdlib.h>
#include "globals.h"
#include "sliders.h"
#include "sliders.rh"
#include "sliders.rsh"
#include "cookie.h"

static void update_scrolls( WINDOW *win);

/* Macros et constantes */
#define PROPOR( mode, wmax, w)	((mode)?((int)((long)wmax * (long)(w) / 100L)):(w))
#define NO_BACKGROUND	0x0002	/* interne */
#define TOPPED_ACTIV	0x0004	/* interne */


/******************************************************************/

void set_frame( INT16 xy[8], int x, int y, int w, int h) {
	xy[8]=xy[0]=x;
	xy[9]=xy[1]=y;
	xy[2]=x+w-1;
	xy[3]=y;
	xy[4]=xy[2];
	xy[5]=y+h-1;
	xy[6]=x;
	xy[7]=xy[5];
}

/* Positionne et dessine les gadgets de la frame
   mode 0x0001	redraw
   		0x0002	redraw par ObjcWindDraw
   		0x0004	deselectionner les gadgets
   		0x0008	mode pour WindSet()
   		0x0010	idem
   		0x0020  idem
   		0x0040	selection des gadgets selon si la fenˆtre est
   				topp‚ (mode pour WindSet())
*/

#define ISNT_HIDE(a,b)	(((a)[(b)].ob_flags & HIDETREE)?0:1)
#define ACTOBSPC( a)	(mode&0x4)?(&dum):(&tree[(a)].ob_spec)
#define DACOBSPC( a)	(mode&0x4)?(&tree[(a)].ob_spec):(&dum)

void set_gadget_pos( WINDOW *frame, GRECT *r1, int mode) {
	OBJECT *tree;
	WINDOW *root;
	BFOBSPEC *obspec;

	tree = rs_trindex[ FRAME_SLIDER];
	
	/* S‚lection des gadgets (fonction des attributs) : OKAY */

	tree[M_INFO].ob_spec.tedinfo->te_ptext = frame->info;

	if( frame->attrib & INFO)
		tree[M_INFO].ob_flags &= ~HIDETREE;
	else
		tree[M_INFO].ob_flags |= HIDETREE;

	if( frame->attrib & VSLIDE)
		tree[M_V_PG].ob_flags &= ~HIDETREE;
	else
		tree[M_V_PG].ob_flags |= HIDETREE;
	
	if( frame->attrib & UPARROW)
		tree[M_V_UP].ob_flags &= ~HIDETREE;
	else
		tree[M_V_UP].ob_flags |= HIDETREE;

	if( frame->attrib & DNARROW)
		tree[M_V_DW].ob_flags &= ~HIDETREE;
	else
		tree[M_V_DW].ob_flags |= HIDETREE;

	if( frame->attrib & (SIZER|UPARROW|DNARROW|VSLIDE))
		tree[M_V_BG].ob_flags &= ~HIDETREE;
	else
		tree[M_V_BG].ob_flags |= HIDETREE;
	
	if( frame->attrib & HSLIDE)
		tree[M_H_PG].ob_flags &= ~HIDETREE;
	else
		tree[M_H_PG].ob_flags |= HIDETREE;

	if( frame->attrib & LFARROW)
		tree[M_H_LF].ob_flags &= ~HIDETREE;
	else
		tree[M_H_LF].ob_flags |= HIDETREE;

	if( frame->attrib & RTARROW)
		tree[M_H_RT].ob_flags &= ~HIDETREE;
	else
		tree[M_H_RT].ob_flags |= HIDETREE;

	if( frame->attrib & (LFARROW|RTARROW|HSLIDE))
		tree[M_H_BG].ob_flags &= ~HIDETREE;
	else
		tree[M_H_BG].ob_flags |= HIDETREE;


	if( frame->attrib & SIZER ||
		(!(tree[M_H_BG].ob_flags & HIDETREE) &&
		 !(tree[M_V_BG].ob_flags & HIDETREE)) )
		tree[M_SZ].ob_flags &= ~HIDETREE;
	else
		tree[M_SZ].ob_flags |= HIDETREE;


	/* Coordonn‚es et tailles des gadgets */

	/* barre d'information : okay */
	tree[M_INFO].ob_x =	r1->g_x;
	tree[M_INFO].ob_y = r1->g_y;
	tree[M_INFO].ob_width = r1->g_w;
	
	/* taille des ascenseurs : d‚pend de la pr‚sence du sizer et de la barre d'info */
	tree[M_V_BG].ob_height = r1 -> g_h - ISNT_HIDE(tree,M_SZ)*tree[M_SZ].ob_height
							 - ISNT_HIDE(tree,M_INFO)*(tree[M_INFO].ob_height+1);
	tree[M_H_BG].ob_width  = r1 -> g_w - ISNT_HIDE(tree,M_SZ)*tree[M_SZ].ob_width;
	
	/* position fond des ascenseurs */
	tree[M_V_BG].ob_x =	r1->g_x+r1->g_w-tree[M_V_BG].ob_width;
	tree[M_V_BG].ob_y = r1->g_y+ISNT_HIDE(tree,M_INFO)*(tree[M_INFO].ob_height+1);
	tree[M_H_BG].ob_x = r1->g_x;
	tree[M_H_BG].ob_y = r1->g_y+r1->g_h-tree[M_H_BG].ob_height;

	/* les pagers - depend de la pr‚sences des scrollers : - OK */
	tree[M_V_PG].ob_y = (tree[M_V_UP].ob_height+1)*ISNT_HIDE(tree,M_V_UP);
	tree[M_H_PG].ob_x = (tree[M_H_LF].ob_height+1)*ISNT_HIDE(tree,M_H_LF);
	tree[M_V_PG].ob_height = tree[M_V_BG].ob_height 
							 - ISNT_HIDE(tree,M_V_DW)*(tree[M_V_DW].ob_height+2)
							 - ISNT_HIDE(tree,M_V_UP)*(tree[M_V_UP].ob_height+2);
	tree[M_H_PG].ob_width  = tree[M_H_BG].ob_width 
							 - ISNT_HIDE(tree,M_H_RT)*(tree[M_H_RT].ob_width+2)
							 - ISNT_HIDE(tree,M_H_LF)*(tree[M_H_LF].ob_width+2);
	/* les sliders */
	tree[M_V_SL].ob_height = (int)((long)frame->frame.vsldsize*tree[M_V_PG].ob_height/1000L);
	tree[M_V_SL].ob_height = MAX( tree[M_V_SL].ob_height, tree[M_V_SL].ob_width);
	tree[M_V_SL].ob_y = (int)( (long)frame->frame.vsldpos*(long)(tree[M_V_PG].ob_height-tree[M_V_SL].ob_height)/1000L);
	tree[M_H_SL].ob_width  = (int)((long)frame->frame.hsldsize*(long)tree[M_H_PG].ob_width/1000L);
	tree[M_H_SL].ob_width = MAX( tree[M_H_SL].ob_width, tree[M_H_SL].ob_height);
	tree[M_H_SL].ob_x = (int)((long)frame->frame.hsldpos*(long)(tree[M_H_PG].ob_width-tree[M_H_SL].ob_width)/1000L);

	/* les scrollers */
	tree[M_H_RT].ob_x = tree[M_H_BG].ob_width-tree[M_H_RT].ob_width - 2;
	tree[M_V_DW].ob_y = tree[M_V_BG].ob_height-tree[M_V_DW].ob_height - 2;

	/* le sizer */
	tree[M_SZ].ob_x = r1->g_x+r1->g_w-tree[M_V_BG].ob_width;
	tree[M_SZ].ob_y = r1->g_y+r1->g_h-tree[M_H_BG].ob_height;

	obspec = (BFOBSPEC *)&((W_PARM *)tree[M_SZ].ob_spec.userblk->ub_parm)->wp_spec;

	if( frame->attrib & SIZER)
		obspec->character = '';
	else
		obspec->character = ' ';

	/* Style des gadgets - a voir */
/*
	if( _AESversion >= 0x34) {
		wind_get( frame->handle, WF_COLOR, W_INFO, ACTOBSPC(M_INFO), DACOBSPC(M_INFO));
		wind_get( frame->handle, WF_COLOR, W_HELEV, ACTOBSPC(M_H_PG), DACOBSPC(M_H_PG));
		wind_get( frame->handle, WF_COLOR, W_VELEV, ACTOBSPC(M_V_PG), DACOBSPC(M_V_PG));	
		wind_get( frame->handle, WF_COLOR, W_UPARROW, ACTOBSPC(M_V_UP), DACOBSPC(M_V_UP));
		wind_get( frame->handle, WF_COLOR, W_DNARROW, ACTOBSPC(M_V_DW), DACOBSPC(M_V_DW));
		wind_get( frame->handle, WF_COLOR, W_LFARROW, ACTOBSPC(M_H_LF), DACOBSPC(M_H_LF));
		wind_get( frame->handle, WF_COLOR, W_RTARROW, ACTOBSPC(M_H_RT), DACOBSPC(M_H_RT));
		wind_get( frame->handle, WF_COLOR, W_SIZER, ACTOBSPC(M_SZ), DACOBSPC(M_SZ));
	} else { */
	
	tree[M_INFO].ob_state &= ~DISABLED;
	tree[M_H_PG].ob_state &= ~DISABLED;
	tree[M_V_PG].ob_state &= ~DISABLED;
	tree[M_V_UP].ob_state &= ~DISABLED;
	tree[M_V_DW].ob_state &= ~DISABLED;
	tree[M_H_LF].ob_state &= ~DISABLED;
	tree[M_H_RT].ob_state &= ~DISABLED;
	tree[M_SZ  ].ob_state &= ~DISABLED;

	root = WindHandle( frame->handle);
	
	if( mode & 0x4 ||
		(mode & 0x40 && root != wglb.front) ) {
		tree[M_INFO].ob_state |= DISABLED;
		tree[M_H_PG].ob_state |= DISABLED;
		tree[M_V_PG].ob_state |= DISABLED;
		tree[M_V_UP].ob_state |= DISABLED;
		tree[M_V_DW].ob_state |= DISABLED;
		tree[M_H_LF].ob_state |= DISABLED;
		tree[M_H_RT].ob_state |= DISABLED;
		tree[M_SZ  ].ob_state |= DISABLED;
	} 

	/* dessin */
	if( mode & 0x1 || mode & 0x8 || mode & 0x10 || mode & 0x20) {
		if( mode & 0x2 || mode & 0x8 || mode & 0x10 || mode & 0x20) {
			INT16 x, y, w, h;
		
			wind_get( root -> handle, WF_CURRXYWH, &x, &y, &w, &h);
			WindCalc( 1, root, x, y, w, h, &x, &y, &w, &h);
			
			if( mode & 0x2) {
				ObjcWindDraw( root, tree, M_INFO, 0, x, y, w, h);
				ObjcWindDraw( root, tree, M_H_BG, 2, x, y, w, h);
				ObjcWindDraw( root, tree, M_V_BG, 2, x, y, w, h);
				ObjcWindDraw( root, tree, M_SZ  , 0, x, y, w, h);
			}
			if( mode & 0x8)
				ObjcWindDraw( root, tree, M_H_PG, 1, x, y, w, h);
			if( mode & 0x10)
				ObjcWindDraw( root, tree, M_V_PG, 1, x, y, w, h);
			if( mode & 0x20)
				ObjcWindDraw( root, tree, M_INFO, 0, x, y, w, h);
		} else {
			objc_draw( tree, M_INFO, 0, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
			objc_draw( tree, M_V_BG, 2, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
			objc_draw( tree, M_H_BG, 2, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
			objc_draw( tree, M_SZ  , 0, clip.g_x, clip.g_y, clip.g_w, clip.g_h);	
		}
	}		
}

/* routine de dessin */
/* remarque d'un bug:
   l'appel de WindGet() par une fonction qui utilise WindGet() merde 
   peut-etre lie aux VA_ARG */

void frame_draw( WINDOW *win) {
	FRAME *frame = DataSearch( win, WD_WFRA);
	WINDOW *scan = frame->list;
	INT16 xy[10];
	INT16 xc, yc, wc, hc, i;
	GRECT r1, oldclip;
	EV_MSG *msg;
	
	wind_get( win -> handle, WF_CURRXYWH, &xc, &yc, &wc, &hc); /* au lieu de WindGet() */
	WindCalc( 1, win, xc, yc, wc, hc, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);

	/* fond de la fenˆtre */
	if( !(frame->flags & NO_BACKGROUND) ){
		xy[0]=r1.g_x;xy[1]=r1.g_y;
		xy[2]=r1.g_x+r1.g_w-1;xy[3]=r1.g_y+r1.g_h-1;
		vsf_color( win->graf.handle, (app.color>=16)?frame->color:WHITE);
		v_bar( win->graf.handle, xy);
	}
	/* dessin des frames */

	oldclip = clip;
	
	while( scan) {
		if( scan->status & WS_OPEN) {
			FrameCalc( scan, 1, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
			/* cadres 3D */
			if( frame->border > 0 && !(scan->frame.flags & FRAME_NOBORDER)) {
				if( frame->flags & NO_BACKGROUND) {
					vsl_color( win->graf.handle, frame->color);
					for( i=2; i<frame->border/2+1; i++) {
						set_frame( xy, r1.g_x-i, r1.g_y-i, r1.g_w+2*i, r1.g_h+2*i);
						v_pline( win->graf.handle, 5, xy);
					}
				}
				set_frame( xy, r1.g_x-1, r1.g_y-1, r1.g_w+2, r1.g_h+2);
				vsl_color( win->graf.handle, BLACK);
				v_pline( win->graf.handle, 5, xy);
				if( app.color >= 16) {
					set_frame( xy, r1.g_x-2, r1.g_y-2, r1.g_w+4, r1.g_h+4);
					vsl_color( win->graf.handle, LBLACK);
					v_pline( win->graf.handle, 5, xy);

					vsl_color( win->graf.handle, WHITE);
					v_pline( win->graf.handle, 3, xy+2);
				}
			}
			/* dessin des gadgets */
			if( frame->front == scan)
				set_gadget_pos( scan, &r1, 0x1);
			else
				set_gadget_pos( scan, &r1, 0x1|0x4);
			
			/* routines de dessin des frames */
			/* prendre la premiere valeur de clip */
			FrameCalc( scan, 0, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
			msg = EvntFind( scan, WM_REDRAW);
			if ( msg && rc_intersect( &oldclip, &r1)) {
				rc_clip_on( scan->graf.handle, &r1);
				(*msg->proc)( scan);
				rc_clip_off( scan->graf.handle);
			}
		}
		scan = scan->next;
		clip = oldclip;
	}
}

void frame_destroy( WINDOW *win) {
	FRAME *frame = DataSearch( win, WD_WFRA);
	WINDOW *scan = frame->list, *next;
	
	while( scan) {
		next = scan->next;
		EvntExec( scan, WM_DESTROY);
		scan = next;
	}
	free( frame);
	WindClose( win);
	WindDelete( win);
}

void frame_tpd( WINDOW *win) {
	WINDOW *child = FrameFind( win, evnt.mx, evnt.my);
	INT16 x,y,w,h;
	
	if( child == NULL) {
		if( wglb.front == win)
			WindSet( win, WF_BOTTOM, win->handle, 0, 0, 0);
		else
			WindSet( win, WF_TOP, win->handle, 0, 0, 0);
		return;
	}
		
	FrameCalc( child, 0, &x, &y, &w, &h);
	
	if( IS_IN(evnt.mx, evnt.my, x, y, w, h)) {
		EvntExec( child, WM_TOPPED);
		wind_set( win->handle, WF_TOP, win->handle, 0, 0, 0);
		FrameSet( win, FRAME_ACTIV, child);
	} else
		EvntExec( win, WM_XBUTTON);
}

void frame_untpd( WINDOW *win) {
	GRECT r;
	FRAME *frame = DataSearch( win, WD_WFRA);
	
	if( frame->front && !(win->status & WS_ICONIFY)) {
		FrameCalc( frame->front, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
		set_gadget_pos( frame->front, &r, 0x1|0x2|0x4);
		frame->front = NULL;
	}
}

/*  sous-fonction de frame_click
 *	Trouve sur quelle ligne ou colonne se trouve les coordonn‚es (x,y) 
 *	retourne 0 si c'est une ligne 
 *			 1 si c'est une colonne	
 *	r contient au retour les coordonn‚es du bord (pour les effets movebox)
 *	La ligne de s‚paration sous la ligne de cellules 'line' a l'index 'line'.
 *  La ligne de s‚paration … droite d'une cellule 'col' a l'index 'col'.
 */


static int get_board( WINDOW *win, int x, int y, int *line, int *col, GRECT *r) {
	INT16 xw, yw, ww, hw;
	WINDOW *scan, *begin;
	int max_h, line_h, dum=0;
	FRAME *frame = DataSearch( win, WD_WFRA);
	
	/* coordonn‚e de la fenˆtre mŠre */
	
	wind_get( win -> handle, WF_CURRXYWH, &xw, &yw, &ww, &hw);
	WindCalc( 1, win, xw, yw, ww, hw, &xw, &yw, &ww, &hw);
	max_h = 0;
	line_h = 0;
	rc_set( r, xw, yw, ww, hw);
	begin = scan = frame->list;
	*line = scan->frame.line;
	for( ; scan; scan=scan->next) {
		if( *line != scan->frame.line) {	/* Nouvelle ligne */
			line_h += max_h;
			*line = scan->frame.line;
			if( y >= yw + line_h && y < yw + line_h + frame->border) {
				r->g_y += line_h;
				r->g_h = frame->border;
				return 0;	/* ligne */
			} 
			if( y < yw + line_h) {
				r->g_y += dum;
				r->g_h = max_h;
				break; /* colonne */
			}
			line_h += frame->border;
			dum = line_h;
			begin = scan;
			max_h = 0;
		}
		
		/* on calcule la hauteur MAX de la ligne de cellule */
		max_h = MAX( max_h, PROPOR( scan->frame.flags & FRAME_HSCALE, hw, scan->frame.h));
	}
	/* Recherche de la colonne */
	if( scan != NULL) *line = begin->frame.line;
	line_h = max_h = 0;
	*col = begin->frame.col;
	for( scan=begin; scan; scan=scan->next) {
		if( *col != scan->frame.col) {	/* Nouvelle colonne */
			line_h += max_h;
			max_h = 0;
			*col = scan->frame.col;
			if( x >= xw + line_h && x < xw + line_h + frame->border) {
				r->g_x += line_h;
				r->g_w = frame->border;
				return 1;	/* ok */
			}
			line_h += frame->border;
		}
		max_h = MAX( max_h, PROPOR( scan->frame.flags & FRAME_WSCALE, ww, scan->frame.w));
	}
	return 1;
}

void frame_click( WINDOW *win) {
	WINDOW *child = FrameFind( win, evnt.mx, evnt.my), *scan;
	FRAME *frame = DataSearch( win, WD_WFRA);
	INT16 x, y, w, h;
	INT16 xr, yr, wr, hr;
	INT16 x1, y1, res, dum1, dum2;
	int line, col;
	GRECT r;
	OBJECT *tree;
	
	if( child) {
		if( child->status & WS_OPEN) {
			/*
	 		 * Gestion des gadgets des frames
	 		 */
		
			if( child->frame.flags & FRAME_SELECT) {
				/* Gestion des gadgets */
				tree = rs_trindex[FRAME_SLIDER];
				if( frame->front == child || win != wglb.front) {
					FrameCalc( child, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
					set_gadget_pos( child, &r, 0);
				} else
					FrameSet( win, FRAME_ACTIV, child);
				frame->widget = child;
				res = objc_find( tree, M_H_BG, 2, evnt.mx, evnt.my);
				if( res != -1) {
					switch ( res) {
					case M_H_RT:
						snd_arrw( win, WA_RTLINE);
						break;
					case M_H_LF:
						snd_arrw( win, WA_LFLINE);
						break;
					case M_H_SL:
						while( !wind_update( BEG_MCTRL));
						x = graf_slidebox( tree, M_H_PG, M_H_SL, 0);
						wind_update( END_MCTRL);
						snd_msg( win, WM_HSLID, x, 0, 0, 0);
						break;
					case M_H_PG:
						objc_offset( tree, M_H_SL, &x, &y);
						snd_arrw( win, ( evnt.mx < x)?WA_LFPAGE:WA_RTPAGE);
						break;
					}
					return;
				}
				res = objc_find( tree, M_V_BG, 2, evnt.mx, evnt.my);
				if( res != -1) {
					switch ( res) {
					case M_V_UP:
						snd_arrw( win, WA_UPLINE);
						break;
					case M_V_DW:
						snd_arrw( win, WA_DNLINE);
						break;
					case M_V_SL:
						while( !wind_update( BEG_MCTRL));
						x = graf_slidebox( tree, M_V_PG, M_V_SL, 1);
						wind_update( END_MCTRL);
						snd_msg( win, WM_VSLID, x, 0, 0, 0);
						break;
					case M_V_PG:
						objc_offset( tree, M_V_SL, &x, &y);
						snd_arrw( win, ( evnt.my < y)?WA_UPPAGE:WA_DNPAGE);
						break;
					}
					return;
				}
				res = objc_find( tree, M_SZ, 0, evnt.mx, evnt.my);
				if( res != -1 && child->attrib & SIZER) {
					wind_get( win->handle, WF_CURRXYWH, &x, &y, &w, &h);
					while( !wind_update( BEG_MCTRL));
					graf_mouse( 4, NULL);
					graf_rubberbox( x,y,win->w_min,win->h_min,&w,&h);
					graf_mouse( 0, NULL);
					wind_update( END_MCTRL);
					snd_msg( win, WM_SIZED, x, y, w, h);
					return;
				}
			}
			
			/* d‚clenchement de la bonne routine */
			
			if( !(child->status & WS_UNTOPPABLE) &&  win != wglb.front) {
				EvntExec( child, WM_TOPPED);
				if( frame->flags & TOPPED_ACTIV)
					FrameSet( win, FRAME_ACTIV, child);
			} else
				EvntExec( child, WM_XBUTTON);
		}
	} else {
		/*
		 * Gestion des bords des frames
		 */
		 
		wind_get( win -> handle, WF_CURRXYWH, &x, &y, &w, &h);
		WindCalc( 1, win, x, y, w, h, &xr, &yr, &wr, &hr);
		res = get_board( win, evnt.mx, evnt.my, &line, &col, &r);
		if( res == -1)
			return;	/* erreur - pas encore g‚r‚ */
		dum1 = dum2 = 0;
		for( scan = frame->list; scan; scan = scan->next) {
			/* on v‚rifie si les frames sont resizable et */
			/* taille MAX admissible (ligne) */
			if( res == 0 && scan->frame.line == line) {
			 	if( scan->frame.flags & FRAME_HFIX) 
					return;
				dum1 = MAX( dum1, PROPOR( scan->frame.flags & FRAME_HSCALE, hr, scan->frame.h));
			}
			if( res == 0 && scan->frame.line == line-1) {
				if( scan->frame.flags & FRAME_HFIX)
					return;
				dum2 = MAX( dum2, PROPOR( scan->frame.flags & FRAME_HSCALE, hr, scan->frame.h));
			}
			if( res == 1 && scan->frame.col == col && scan->frame.line == line) {
			 	if( scan->frame.flags & FRAME_WFIX) 
					return;
				dum2 = PROPOR( scan->frame.flags & FRAME_WSCALE, wr, scan->frame.w);
				dum2 = dum2-scan->w_min;
			}
			if( res == 1 && scan->frame.col == col-1 && scan->frame.line == line) {
				if( scan->frame.flags & FRAME_WFIX)
					return;
				dum1 = PROPOR( scan->frame.flags & FRAME_WSCALE, wr, scan->frame.w);
				dum1 = dum1-scan->w_min;
			}
		}
		if( res == 0) { /* ligne - … l'air OK */
			graf_dragbox( wr+1, frame->border, 
						  xr, r.g_y, xr, 
						  r.g_y-dum2, wr, MIN(r.g_y+dum1, yr+hr)-r.g_y+dum2,
						  &x1, &y1);
			/* resize : … faire */
		} else {
			graf_dragbox( frame->border, r.g_h,
						  r.g_x, r.g_y, 
						  r.g_x-dum1, r.g_y, r.g_w+dum1+dum2, r.g_h,
						  &x1, &y1);

			/* bug: la taille de la derniere frame doit correspondre a la fin
			        de l'‚cran ou sa vrai taille, ca merde surement a cause des
			        erreurs d'arrondis */
			if( col == 0)	return;
			/* Resizons mes frŠres: deux frames col et col-1*/
			scan = FrameSearch( win, line, col-1);
			FrameCalc( scan, 1, &x, &y, &w, &h);
			dum1 = (int)((scan->frame.flags & FRAME_WSCALE)?(((long)(x1-x)*100L)/(long)wr):(x1-x));
			
			FrameCalc( scan->next, 1, &x, &y, &w, &h);
			scan->next->frame.w = (int)((scan->next->frame.flags & FRAME_WSCALE)?(((long)(w-x1+x)*100L)/(long)wr):(w-x1+x));
			if( (scan->next->next == NULL || 
				 scan->next->frame.line != scan->next->next->frame.line) &&
				scan->next->frame.flags & FRAME_WSCALE)
				scan->frame.w ++;
			scan->frame.w = dum1;
			
			update_scrolls( scan);
			update_scrolls( scan->next);
			snd_rdw(win);
		}
	}
}

void frame_keybd( WINDOW *win) {
	FRAME *frame = DataSearch( win, WD_WFRA);
	WINDOW *child;
	
	if( frame->flags & KEYBD_ON_MOUSE)
	 	child = FrameFind( win, evnt.mx, evnt.my);
	else
		child = frame->front;
	
	if( child && (child->status & WS_OPEN)) {
		frame->widget = child;
		EvntExec( child, WM_XKEYBD);
	}
}

void frame_timer( WINDOW *win) {
	WINDOW *child = ((FRAME *)DataSearch( win, WD_WFRA))->list;

	while( child) {
		if( child->status & WS_OPEN)
			EvntExec( child, WM_XTIMER);
		child = child->next;
	}
}


static void update_scrolls( WINDOW *win) {
	INT16 x,y,w,h;
	INT16 xc,yc,wc,hc;
	
	wind_get( win -> handle, WF_CURRXYWH, &xc, &yc, &wc, &hc); /* au lieu de WindGet() */
	WindCalc( 1, win, xc, yc, wc, hc, &x, &y, &w, &h);

	if( w >= win -> xpos_max * win -> w_u)
		win -> xpos = 0;
	else
		win -> xpos = MIN( win -> xpos, win -> xpos_max - w / win -> w_u);

	if( h >= win -> ypos_max * win -> h_u)
		win -> ypos = 0;
	else
		win -> ypos = MIN( win -> ypos, win -> ypos_max - h / win -> h_u);
	WindSlider(win,HSLIDER|VSLIDER);
}


void frame_fld( WINDOW *win) {
	INT16 x, y, w, h;
	WINDOW *child = ((FRAME *)DataSearch( win, WD_WFRA))->list;
	
	if( win->status & WS_FULLSIZE) {
		wind_get( evnt.buff[3], WF_PREVXYWH, &x, &y, &w, &h);
		wind_set( evnt.buff[3], WF_CURRXYWH, x, y,  w, h);
	} else
		wind_set(evnt.buff[3], WF_CURRXYWH, app.x, app.y, win->w_max, win->h_max);
	
	snd_rdw( win);
	win->status ^= WS_FULLSIZE;
	/* mise-a-jour des scrolls */
	while( child) {
		if( child->status & WS_OPEN)
			update_scrolls( child);
		child = child->next;
	}
}

void frame_szd( WINDOW *win) {
	int w, h;
	WINDOW *child = ((FRAME *)DataSearch( win, WD_WFRA))->list;
	
	w = MAX( evnt.buff[6], win -> w_min);
	h = MAX( evnt.buff[7], win -> h_min);
	w = MIN( evnt.buff[6], win -> w_max);
	h = MIN( evnt.buff[7], win -> h_max);
	wind_set( evnt.buff[3], WF_CURRXYWH, evnt.buff[4], evnt.buff[5], w, h);
	snd_rdw( win);
	win->status &= ~WS_FULLSIZE;
	while( child) {
		if( child->status & WS_OPEN)
			update_scrolls( child);
		child = child->next;
	}
}

/* fonctions de scrolls (utilise le champs widget) */

void frame_vsld( WINDOW *win) {
	WINDOW *frame = ((FRAME*)DataSearch(win,WD_WFRA))->widget;
	
	if( frame && ( frame->status & WS_OPEN))
		EvntExec( frame, WM_VSLID);
}

void frame_hsld( WINDOW *win) {
	WINDOW *frame = ((FRAME*)DataSearch(win,WD_WFRA))->widget;
	
	if( frame && ( frame->status & WS_OPEN))
		EvntExec( frame, WM_HSLID);
}

void frame_arw( WINDOW *win) {
	WINDOW *frame = ((FRAME*)DataSearch(win,WD_WFRA))->widget;
	INT16 button, dum;
	
	if( frame && ( frame->status & WS_OPEN))
		do {
			EvntExec( frame, WM_ARROWED);
			graf_mkstate( &dum, &dum, &button, &dum);
		} while( button & 0x1 && win != wglb.front);
}

/* fonctions utilisateurs */

WINDOW *FrameSearch( WINDOW *win, int line, int col) {
	WINDOW *scan = ((FRAME*)DataSearch(win,WD_WFRA))->list;
	
	while( scan) {
		if( line == scan->frame.line && col == scan->frame.col)
			return scan;
		scan = scan->next;
	}
	return NULL;
}

WINDOW *FrameFind( WINDOW *win, int x, int y) {
	FRAME *frame = DataSearch( win, WD_WFRA);
	WINDOW *scan = frame->list;
	INT16 xf, yf, wf, hf;
	
	while( scan) {
		FrameCalc( scan, 1, &xf, &yf, &wf, &hf);
		if( IS_IN( x, y, xf, yf, wf, hf))
			break;
		scan = scan->next;
	}
	return scan;
}

WINDOW *FrameCreate( int attrib) {
	WINDOW *win;
	FRAME *frame;

	frame = (FRAME *)malloc( sizeof(FRAME));
	if( frame==NULL) return NULL;
	frame -> list = frame -> front = NULL;
	frame -> border = 0;
	frame -> color = LWHITE;
	frame -> flags = 0;
	win = WindCreate( attrib, app.x, app.y, app.w, app.h);
	EvntAttach( win, WM_REDRAW, frame_draw);
	win -> icon.draw = WindClear;
	EvntAttach( win, WM_DESTROY, frame_destroy);
	EvntAttach( win, WM_VSLID  , frame_vsld);
	EvntAttach( win, WM_HSLID  , frame_hsld);
	EvntAttach( win, WM_ARROWED, frame_arw);
	EvntAttach( win, WM_TOPPED , frame_tpd);
	EvntAttach( win, WM_UNTOPPED, frame_untpd);
	EvntAttach( win, WM_SIZED  , frame_szd);
	EvntAttach( win, WM_FULLED , frame_fld);

	EvntAttach( win, WM_XBUTTON , frame_click);
	EvntAttach( win, WM_XKEYBD , frame_keybd);
	EvntAttach( win, WM_XTIMER , frame_timer);
	
	DataAttach( win, WD_WFRA, frame);
	win -> status |= WS_FRAME_ROOT;
	win -> frame.col = win -> frame.line = 0;
	WindSet( win, WF_BEVENT, B_UNTOPPABLE, 0, 0, 0);
	return win;
}

void FrameAttach( WINDOW *win, WINDOW *src, int line, int col, int w, int h, int flags) {
	FRAME *frame = DataSearch( win, WD_WFRA);
	WINDOW *scan = frame->list, *prev;
	GRECT r;
	
	/* saisie des valeurs des sliders */
	WindSlider( src, VSLIDER|HSLIDER);
	
	if( src -> status & WS_OPEN) 
		WindClose( src);
	wind_delete( src->handle);
	RemoveWindow( src);

	src -> next = NULL;
	src -> status |= WS_FRAME;
	src -> status |= WS_OPEN;
	win -> frame.col = MAX( win -> frame.col, col);
	win -> frame.line = MAX( win -> frame.line, line);
	src -> frame.col = col;
	src -> frame.line = line;
	src -> frame.w = w;
	src -> frame.h = h;
	src -> frame.flags = flags;
	frame -> front = src;

	/* On garde certaines caract‚ristiques globale de la fenˆtre racine */
	src -> handle = win -> handle;
	src -> icon = win -> icon;

	/* Ajout dans la liste ( en les triant) */
	prev = NULL;

	if( scan == NULL) {
		frame->list = src;
	} else {
		while( scan) {
			if( scan->frame.line > line ||
				(scan->frame.line == line &&
				scan->frame.col > col)) { /* inserer */
					src->next = scan;
					if( prev)
						prev -> next = src;
					else
						frame->list = src;
					break;
				}
			prev = scan;
			scan = scan->next;
		}
		if( scan == NULL)
			prev->next = src;
	}
	
	FrameCalc( src, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	set_gadget_pos( src, &r, 0);
}

/*
 *	mode = 0: workxywh
 *	     = 1: currxywh
 */


int FrameCalc( WINDOW *win, int mode, INT16 *x, INT16 *y, INT16 *w, INT16 *h) {
	WINDOW *root = WindHandle( win->handle), *scan;
	int line;
	INT16 xc, yc, wc, hc;
	GRECT r1,r2;
	FRAME *frame = DataSearch( root, WD_WFRA);
	
	/* cas frame ferm‚ */
	if( !(win->status & WS_OPEN)) {
		*x=*y=*w=*h=0;
		return 0;
	}
	/* Taille de la fenetre racine */
	wind_get( root -> handle, WF_CURRXYWH, &xc, &yc, &wc, &hc);
	WindCalc( 1, root, xc, yc, wc, hc, x, y, w, h);
	rc_set( &r1, *x, *y, *w, *h);
	scan = frame->list;
	line = scan->frame.line;
	hc = 0;
	for(; scan;scan=scan->next) {
		/* nouvelle ligne */
		if( scan->frame.line > line) {
			line = scan->frame.line;
			*y += hc + frame->border;
			hc = 0;
		} 
 		hc = MAX( hc, PROPOR( scan->frame.flags & FRAME_HSCALE, *h, scan->frame.h));
		if( scan == win) break;
		/* bonne ligne, nouvelle colonne */
		if( scan->frame.line == win->frame.line) 
			*x += PROPOR( scan->frame.flags & FRAME_WSCALE, *w, scan->frame.w) 
				  + frame->border;
	}

	*w = PROPOR( scan->frame.flags & FRAME_WSCALE, *w, win->frame.w);
	*h = PROPOR( scan->frame.flags & FRAME_HSCALE, *h, win->frame.h);
	
	/* Intersection entre la taille de root et celle de la frame */
	rc_set( &r2, *x, *y, *w, *h);
	rc_intersect( &r1, &r2);
	*x=r2.g_x;*y=r2.g_y;*w=r2.g_w;*h=r2.g_h;
	
	/* les gadgets */
	if( mode == 0 && !(win->status & WS_ICONIFY)) {
		OBJECT *tree = rs_trindex[FRAME_SLIDER];
		
		if( scan->attrib & (UPARROW|DNARROW|VSLIDE|SIZER))
			*w -= tree[M_V_BG].ob_width+1;
		if( scan->attrib & (LFARROW|RTARROW|HSLIDE))
			*h -= tree[M_H_BG].ob_height+1;
		if( scan->attrib & INFO) {
			*y += tree[M_INFO].ob_height+1;
			*h -= tree[M_INFO].ob_height+1;
		}
	}
	
	return 0; 
}

void FrameSet( WINDOW *win, int mode, ...) {
	va_list args;
	int parm1, parm2;
	WINDOW *wparm;
	FRAME *frame = DataSearch( win, WD_WFRA);
	
	va_start( args, mode);
	if( mode == FRAME_ACTIV)
		wparm = va_arg( args, WINDOW*);
	else {
		parm1 = va_arg( args, int);
		parm2 = va_arg( args, int);
	}
	if( win->status & WS_FRAME_ROOT) {
		switch( mode) {
		case FRAME_BORDER:
			frame->border = parm1;
			break;
		case FRAME_COLOR:
			frame->color = parm1;
			break;
		case FRAME_KEYBD:
			if( parm1 == 1)
				frame->flags |= KEYBD_ON_MOUSE;
			else
				frame->flags &= ~KEYBD_ON_MOUSE;
			break;
		case FRAME_NOBG:
			if( parm1 == 1)
				frame->flags |= NO_BACKGROUND;
			else
				frame->flags &= ~NO_BACKGROUND;
			break;
		case FRAME_ACTIV:
			/* on choisit la frame active et on redessine si besoin */
			if( !(wparm->frame.flags & FRAME_SELECT))
				break;
			if( win->status & WS_OPEN) {
				GRECT r;
			
				if( frame->front &&
					frame->front != wparm ) {
					FrameCalc( frame->front, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
					set_gadget_pos( frame->front, &r, 0x1|0x2|0x4);
				}
				
				FrameCalc( wparm, 1, &r.g_x, &r.g_y, &r.g_w, &r.g_h); 		
				set_gadget_pos( wparm, &r, 0x1|0x2);
			}
			frame->front = wparm;
			frame->widget = wparm;
			break;
		case FRAME_TOPPED_ACTIV:
			if( parm1 == 1)
				frame->flags |= FRAME_ACTIV;
			else
				frame->flags &= ~FRAME_ACTIV;
			break;
		}
	}
	if( win->status & WS_FRAME) {
		switch( mode) {
		case FRAME_SIZE:
			win->frame.w = parm1;
			win->frame.h = parm2;
			break;
		case FRAME_FLAGS:
			if( parm2 == 1)  /* SET_FLAGS */
				win->frame.flags |= parm1;
			else
				win->frame.flags &= ~parm1;	/* UNSET_FLAGS */
			break;
		}
	}
	va_end( args);
}

int remove_frame_from_list( WINDOW *win, WINDOW *child) {
	FRAME *frame = DataSearch( win, WD_WFRA);
	WINDOW *scan = frame->list;
	WINDOW *prev = NULL;
	
	while( scan) {
		if( child && child == scan ) {
			/* on retire scan de la liste */
			if( prev == NULL)
				frame->list = scan -> next;
			else
				prev -> next = scan -> next;
			/* on remet a jour les variables de win->frame */
			frame->front = frame->list;
			/* pas fini */
			return 1;
		}
		prev = scan;
		scan = scan->next;
	}
	return 0;
}

WINDOW *FrameRemove( WINDOW *win, WINDOW *child, int line, int col) {
	if( child == NULL)
		child = FrameSearch( win, line, col);
	if( remove_frame_from_list( win, child)) {
			child->handle = wind_create( child->attrib, 
										 child->createsize.g_x, child->createsize.g_y,
										 child->createsize.g_w, child->createsize.g_h);
			AddWindow( child);
			child -> status &= ~WS_FRAME;
			return child;
	}
	return NULL;
}

void FrameInit( void) {
	OBJECT *tree = rs_trindex[FRAME_SLIDER];
	static int init = 1,i;
	
	if( init) {
		for( i=0; i<NUM_OBS; rsrc_obfix( rs_object, i++));
		init = 0;
	}
	/* Cas monochrome */
	if( app.color < 16 ) {
		tree[M_V_PG].ob_spec.obspec.fillpattern = 0;
		tree[M_V_PG].ob_spec.obspec.framesize = 0;
		tree[M_H_PG].ob_spec.obspec.fillpattern = 0;
		tree[M_H_PG].ob_spec.obspec.framesize = 0;
		
		for( i=0; !(tree[i].ob_flags & LASTOB); i++) {
			tree[i].ob_state &= ~DRAW3D;
		}
	}

	for( i=0; !(tree[i].ob_flags & LASTOB); i++) 
		if( tree[i].ob_type == G_BOXCHAR || tree[i].ob_type == G_BOX )
			init_type( tree, i, ub_xboxchar, 0);

	__calc = FrameCalc;
	__swgt = set_gadget_pos;
	__rfrm = remove_frame_from_list;
}

void FrameExit( void) {
	OBJECT *tree = rs_trindex[FRAME_SLIDER];	

	free_type( tree, M_V_BG);
	free_type( tree, M_H_BG);
	free_type( tree, M_H_LF);
	free_type( tree, M_H_RT);
	free_type( tree, M_H_SL);
	free_type( tree, M_H_PG);
	free_type( tree, M_SZ  );
	free_type( tree, M_V_UP);
	free_type( tree, M_V_DW);
	free_type( tree, M_V_SL);
	free_type( tree, M_V_PG);
}
