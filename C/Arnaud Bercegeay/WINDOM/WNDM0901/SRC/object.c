/*
 *	WinDom, Librairie GEM 
 *  Dominique B‚r‚ziat & Arnaud Bercegeay
 *	(c) 1997/2001
 *
 *	module: object.c
 *	description: gestion des objets +
 *				 routines bas niveau de gestion des ‚v‚nements
 *				 dans formulaires et toolbars
 */

#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include "globals.h"
#include "userdef.h"
#include "cookie.h"
#include "scancode.h"

#define PARM( ldata)	(((W_PARM *)(ldata))->wp_spec)

/*
 *	Dessine un objet dans une fenˆtre (n'importe quelle fenetre)
 */

int ObjcWindDraw( WINDOW *win, OBJECT *tree, 
				  int index, int depth, int xclip, int yclip, 
				  int wclip, int hclip) {
	int res=0;
	GRECT r1, win_rect;

	graf_mouse( M_OFF, 0L);
	rc_set( &win_rect, xclip, yclip, wclip, hclip);
	wind_get( win->handle, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	while (r1.g_w && r1.g_h) {
		if ( rc_intersect( &win_rect, &r1)) 
			res = objc_draw( tree, index, depth, r1.g_x, r1.g_y, r1.g_w, r1.g_h);
		wind_get( win->handle, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	}
	graf_mouse( M_ON, 0L);
	return res;
}

/*
 *	Change l'‚tat d'un objet dans une fenˆtre (n'importe quelle fenetre)
 */

int ObjcWindChange( WINDOW *win, OBJECT *tree, int index, int x, int y, int w, int h, int state) {
	GRECT r1, r2;
	int res=0;
	int prev_state = tree[index].ob_state;
	
	wind_get( win->handle, WF_FIRSTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	rc_set( &r2, x, y, w, h);
	graf_mouse( M_OFF, 0L);
	while( r1.g_w && r1.g_h) {
		if ( rc_intersect( &r2, &r1)) {
			tree[index].ob_state = prev_state;
			res = objc_change( tree, index, 0, r1.g_x, r1.g_y, r1.g_w, r1.g_h, state, TRUE);
		}
		wind_get( win->handle, WF_NEXTXYWH, &r1.g_x, &r1.g_y, &r1.g_w, &r1.g_h);
	}
	graf_mouse( M_ON, 0L);
	return res;
}

int obj_nb( register OBJECT *dial) {
register int racine = 0;

	while( !(dial[ racine].ob_flags & LASTOB))
		racine++;
	return( racine + 1);
}

/*
 * Quand un objet est copi‚ par ObjcDup, il faut conserver qqpart
 * les objets r‚serv‚ par malloc() pour pouvoir les lib‚rer par un
 * free() lors de l'appel … ObjcFree().
 * Le problŠme se pose pour les champs ob_spec que l'application
 * peut modifier … son gr‚ par ObjcString() par exemple.
 * Dans ce cas, il faut lib‚rer le bloc r‚serv‚ par malloc() qui
 * n'est plus n‚cessairement dans le champ ob_spec de l'objet
 * dupliqu‚. D'o— ceci:
 */

struct ty_obspec_dup {
	OBJECT * p_ob;    /* pointeur sur l'objet dupliqu‚ */
	void   * p_mem;   /* adresse de la m‚moire allou‚e */
	struct ty_obspec_dup * next;
}; 

static struct ty_obspec_dup * __list_obspec_dup = NULL;

static void * __malloc_obspec(OBJECT * p_ob, long size)
{
	struct ty_obspec_dup  * obspec_dup;
	void * p_mem;
	
	if (! size) return NULL;
	
	p_mem = malloc (size);
	if (! p_mem) return NULL;
	
	obspec_dup = (struct ty_obspec_dup *) malloc (sizeof (struct ty_obspec_dup));
	if (! obspec_dup) {
		free (p_mem);
		return NULL;
	}
	
	obspec_dup->p_ob  = p_ob;
	obspec_dup->p_mem = p_mem;
	obspec_dup->next  = __list_obspec_dup;
	__list_obspec_dup = obspec_dup;
	
	return p_mem;
}

static void __free_obspec( OBJECT * p_ob)
{
	struct ty_obspec_dup  *here, *prev;
	
	here = __list_obspec_dup;
	prev = NULL;
	
	while ((here) && (here->p_ob != p_ob)) {
		prev = here;
		here = here->next;
	}
	
	if (here) {
		free (here->p_mem);
		if (prev) {
			prev->next = here->next;
		} else {
			__list_obspec_dup = here->next;
		}
		free (here);
	}
}

OBJECT *ObjcDup( OBJECT *src, WINDOW *win) {
	OBJECT *cpy;
	int nb = obj_nb( src), i;
	USERBLK *user;
	USER_DRAW *udraw;
	W_PARM *wparm;
	TEDINFO *tedinfo;
	long mem_size;
	char * mem_adr;
	
	cpy = (OBJECT *)malloc(sizeof(OBJECT)*nb);
	if( !cpy )
		return NULL;
	memcpy( cpy, src, sizeof(OBJECT)*obj_nb( src));
	for( i = 0; i < nb; i++)
		switch( src[i].ob_type & 0x00FF) {
		case G_TEXT:
		case G_FTEXT:
		case G_BOXTEXT:
		case G_FBOXTEXT:
			cpy[i].ob_spec.tedinfo = (TEDINFO *)malloc( sizeof( TEDINFO));
			memcpy( cpy[i].ob_spec.tedinfo, src[i].ob_spec.tedinfo, sizeof(TEDINFO));
			mem_size = (cpy[i].ob_spec.tedinfo->te_txtlen + 1) * 2;
			mem_size += cpy[i].ob_spec.tedinfo->te_tmplen + 1;
			mem_adr = __malloc_obspec(&cpy[i],mem_size);
			if (src[i].ob_spec.tedinfo->te_ptext) {
				cpy[i].ob_spec.tedinfo->te_ptext = mem_adr;
				strncpy(mem_adr,src[i].ob_spec.tedinfo->te_ptext,cpy[i].ob_spec.tedinfo->te_txtlen);
			}
			mem_adr += cpy[i].ob_spec.tedinfo->te_txtlen + 1;
			if (src[i].ob_spec.tedinfo->te_pvalid) {
				cpy[i].ob_spec.tedinfo->te_pvalid = mem_adr;
				strncpy(mem_adr,src[i].ob_spec.tedinfo->te_pvalid,cpy[i].ob_spec.tedinfo->te_txtlen);
			}
			mem_adr += cpy[i].ob_spec.tedinfo->te_txtlen + 1;
			if (src[i].ob_spec.tedinfo->te_ptmplt) {
				cpy[i].ob_spec.tedinfo->te_ptmplt = mem_adr;
				strncpy(mem_adr,src[i].ob_spec.tedinfo->te_ptmplt,cpy[i].ob_spec.tedinfo->te_tmplen);
			}
			break;
		case G_STRING:
		case G_BUTTON:
		case G_TITLE:
			cpy[i].ob_spec.free_string = __malloc_obspec(&cpy[i],strlen( src[i].ob_spec.free_string)+1);
			strcpy(cpy[i].ob_spec.free_string,src[i].ob_spec.free_string);
			break;
		case G_USERDEF:
			switch (src[i].ob_type >> 8) {
			case XCICON :
/* !!! FIX ME !!! */
				/* cas particulier des icones: on ne fait qu'un    */
				/* lien vers l'original (pas de copie en m‚moire   */
				/* de l'icone ni du champ texte associ‚).          */
				/* Un volontaire pour faire mieux ?                */
				break;
			case USERDRAW:
				user = (USERBLK *)malloc( sizeof(USERBLK));
				memcpy( user, src[i].ob_spec.userblk, sizeof(USERBLK));
				cpy[i].ob_spec.userblk = user;
				udraw = (USER_DRAW *)malloc( sizeof(USER_DRAW));
				memcpy( udraw, (void*)user->ub_parm, sizeof(USER_DRAW));
				udraw -> win  = win;
				user->ub_parm = (long)udraw;
				break;
			default:
				user = (USERBLK *)malloc( sizeof(USERBLK));
				memcpy(user,src[i].ob_spec.userblk,sizeof(USERBLK));
				cpy[i].ob_spec.userblk = user;
				wparm = (W_PARM*)malloc( sizeof(W_PARM));
				memcpy(wparm,(void*)user->ub_parm,sizeof(W_PARM));
				user -> ub_parm = (long)wparm;
				switch (wparm->wp_type & 0x00FF) {
				case G_TEXT:
				case G_FTEXT:
				case G_BOXTEXT:
				case G_FBOXTEXT:
					tedinfo = (TEDINFO *)malloc( sizeof( TEDINFO));
					memcpy( tedinfo, (void*)wparm->wp_spec, sizeof(TEDINFO));
					mem_size = (cpy[i].ob_spec.tedinfo->te_txtlen + 1) * 2;
					mem_size += cpy[i].ob_spec.tedinfo->te_tmplen + 1;
					mem_adr = __malloc_obspec(&cpy[i],mem_size);
					if (((TEDINFO*)(wparm->wp_spec))->te_ptext) {
						tedinfo->te_ptext = mem_adr;
						strncpy(mem_adr,((TEDINFO*)(wparm->wp_spec))->te_ptext,tedinfo->te_txtlen);
					}
					mem_adr += tedinfo->te_txtlen + 1;
					if (((TEDINFO*)(wparm->wp_spec))->te_pvalid) {
						tedinfo->te_pvalid = mem_adr;
						strncpy(mem_adr,((TEDINFO*)(wparm->wp_spec))->te_pvalid,tedinfo->te_txtlen);
					}
					mem_adr += tedinfo->te_txtlen + 1;
					if (((TEDINFO*)(wparm->wp_spec))->te_ptmplt) {
						tedinfo->te_ptmplt = mem_adr;
						strncpy(mem_adr,((TEDINFO*)(wparm->wp_spec))->te_ptmplt,tedinfo->te_tmplen);
					}
					wparm->wp_spec = (long)tedinfo;
					break;
				case G_STRING:
				case G_BUTTON:
				case G_TITLE:
					mem_adr = __malloc_obspec(&cpy[i],strlen((char*)wparm->wp_spec)+1);
					strcpy(mem_adr,(char*)wparm->wp_spec);
					(char*)wparm->wp_spec = mem_adr;
					break;
				}
			}
			break;
	}
	return cpy;
}

void ObjcFree( OBJECT *cpy) {
	int i, nb = obj_nb( cpy);
	for( i=0; i<nb; i++)
		switch( cpy[i].ob_type & 0xFF) {
		case G_TEXT:
		case G_FTEXT:
		case G_BOXTEXT:
		case G_FBOXTEXT:
			__free_obspec( &cpy[i]);
			free( cpy[i].ob_spec.tedinfo);
			break;
		case G_STRING:
		case G_BUTTON:
		case G_TITLE:
			__free_obspec( &cpy[i]);
			break;
		case G_USERDEF:
			switch ( cpy[i].ob_type >> 8 ) {
			case  XCICON:
				/* rien … faire (cf ObjcDup) */
				break;
			case USERDRAW:
				free( (void*)cpy[i].ob_spec.userblk->ub_parm);
				free( cpy[i].ob_spec.userblk);
				break;
			default:
				switch ( ((W_PARM*)(cpy[i].ob_spec.userblk->ub_parm))->wp_type & 0x00FF) {
				case G_TEXT:
				case G_FTEXT:
				case G_BOXTEXT:
				case G_FBOXTEXT:
					__free_obspec( &cpy[i]);
					free( (void*)PARM(cpy[i].ob_spec.userblk->ub_parm));
					break;
				case G_STRING:
				case G_BUTTON:
				case G_TITLE:
					__free_obspec( &cpy[i]);
					break;
				}
				free( (void*)cpy[i].ob_spec.userblk->ub_parm);
				free( cpy[i].ob_spec.userblk);
			}
			break;
		}
	free( cpy);
}

/* Je fais une modif ici (april 2000) */

int get_next_obj( OBJECT *dial, int racine) {
	if(dial[racine].ob_head != -1 && !(dial[racine].ob_flags & HIDETREE))
			return( dial[racine].ob_head);
	else {
		if(dial[dial[racine].ob_next].ob_tail != racine)
			return( dial[racine].ob_next);
		else {
			while(dial[dial[racine].ob_next].ob_tail == racine) {
				racine = dial[racine].ob_next;
				if(dial[racine].ob_next == -1)
					return( -1);
			}
			return( dial[racine].ob_next);
		}
	}
}

int obj_fd_flag( OBJECT *dial, int racine, int flag) {
	while( 1) {
		if( dial[racine].ob_flags & flag)
			return( racine);
		racine = get_next_obj( dial, racine);
		if (racine == -1)
			return -1;
	}
}

/*
 *	Recherche de type (‚tendus)
 */

int obj_fd_xtype( OBJECT *dial, int racine, int type) {
	while( 1) {
		if( (dial[racine].ob_type>>8) == type)
			return( racine);
		racine = get_next_obj( dial, racine);
		if (racine == -1)
			return -1;
	}
}

/*
 *	Recherche de l'objet pŠre 
 */

int obj_root( OBJECT *tree, int idx) {

	/* allez au bout des enfants */
	while( tree[idx].ob_next != 1 && tree[tree[idx].ob_next].ob_tail != idx)
		idx = tree[idx].ob_next;
	/* puis retourne le papa */
	return tree[idx].ob_next;
}

/*
 *	Du bonne usage des fonction Objc et objc_:
 *
 *	1)
 *	La fonction ObjcDraw() dessine un objet
 *	dans une fenetre. Cela concerne uniquement
 *	les formulaires et les toolbars. Ces fonctions
 *	ne DOIVENT PAS etre appele depuis les routines
 *	de dessin de contenue de fenˆtre car elles utilisent
 *  la liste des rectangles de l'AES.
 *	rem: Ces fonctions redessinnent imm‚diatement les objects
 *	elles n'envoient pas de message WM_REDDRAW clipp‚ sur 
 *	l'objet.
 *	2)
 *	pour dessiner un objet dans une fenetre et dans la routine
 *	de dessin, il faut utiliser objc_draw() ou objc_change()
 *	et le clip en utilisant la variable globale clip. Cette
 *	variable contient en permanence la zone clipp‚ a redessin‚.
 *  rem: clip est mise a jour par les fonctions set_clip() et
 *	et clip_off(). Dans une routine de dessin, il ne faut
 *	JAMAIS clipper puis que c'est le systeme (EvntWindom)
 *	qui s'en charge.
 *	3)
 *	Pour les formulaire classique, ie pas en fenetre, on utilise
 *	objc_draw() et objc_change() comme d'hab.
 *
 */

int ObjcDraw( int mode, void *win, int index, int depth) {
	INT16 x,y;
	int r,res;
	OBJECT *tree;
	
	switch( mode) {
	case OC_FORM:
		tree = FORM((WINDOW*)win);
		break;
	case OC_TOOLBAR:
		tree = TOOL((WINDOW*)win);
		break;
	case OC_OBJC:
		tree = (OBJECT *)win;
	default:
		return -1;
	}
	objc_offset( tree, index, &x, &y);
	r = 6;
	if( mode == OC_OBJC) 
		res = objc_draw( tree, index, 0, x-r, y-r, 
				tree[index].ob_width + 2*r, 
				tree[index].ob_height + 2*r);
	else if( depth & OC_MSG) {
		snd_msg( win, WM_REDRAW, x - r, y - r, 
					tree[index].ob_width + 2*r, 
					tree[index].ob_height + 2*r);
		res = 0;
	} else
		res = ObjcWindDraw( win, tree, index, depth, x - r, y - r, 
							tree[index].ob_width + 2*r, 
							tree[index].ob_height + 2*r);
	return res;
}

int ObjcChange( int mode, void *win, int index, int state, int redraw) {
	OBJECT *tree;
	int res = 0;
	
	switch( mode) {
	case OC_FORM:
		tree = FORM((WINDOW*)win);
		break;
	case OC_TOOLBAR:
		tree = TOOL((WINDOW*)win);
		break;
	case OC_OBJC:
		tree = (OBJECT *)win;
		redraw = redraw?2:3;
		break;
	default:
		return -1;
	}

	/* on filtre les ‚tats */
	if( (state & 0xFF00) == 0xFF00)  /* ‚tats du genre '~SELECTED' */
		state &= tree[ index].ob_state;
	else
		state = (tree[ index].ob_state & 0xFFC0) | (state & 0x003F);
	
	switch( redraw) {
	case 3:
	case 2:
		res = objc_change( tree, index, 0, app.x, app.y, app.w, app.h, state, (redraw==2)?1:0);
		break;
	case 1:
		ObjcWindChange( win, tree, index, app.x, app.y, app.w, app.h, state);
		break;
	case OC_MSG:
		tree[ index].ob_state = state;
		res = ObjcDraw( mode, win, index,  MAX_DEPTH | OC_MSG);
		break;
	case 0:
		res = objc_change( tree, index, 0, app.x, app.y, app.w, app.h, state, 0);
		break;
	}
	return res;
}

/* ***************************************************************************
 * Sous-routines d'‚dition des champs ‚ditables XEDIT
 */

/* Calcul de la reallocation (voir OPTIONS.H/REALLOC_XEDIT) 
 * calcul si on doit ou non r‚allouer l'espace m‚moire 
 * old : taille actuelle
 * len : longueur de la ligne demand‚e
 */

size_t realloc_xedit( size_t old, size_t len) {
	size_t new;
	new = (len/XEDIT_REALLOC + 1)*XEDIT_REALLOC;
	if( new > old)	{
	/*	FormAlert( 1, "[1][Reallocation requise|%d %d][OK]",new, old); */
		return new;
	}
	else			return 0;
}

/* d‚calage vers la droite du buffer */

static
void shift_right( char *buf) {
	int l = (int)strlen(buf);
	
	buf += l;
	*(buf+1) = '\0';
	while( l) {
		*buf = *(buf-1);
		buf --;
		l --;
	}
}

/* d‚calage vers la gauche du buffer */

static
void shift_left( char *buf) {
	do
		*buf = *(buf+1);
	while (*buf++);
}

static
void xedit_add_char( W_XEDIT *xedit, int val) {
	char *p = xedit->line;
	size_t size = realloc_xedit( xedit->size, strlen(p) + 2);
	
	if( size) p = xedit->line = realloc( xedit->line, size);
				
	/* Insertion du caractŠre */
	shift_right( p + xedit->curs);
	p[xedit->curs] = val;
	xedit->curs ++;
}

/*
 * Calcul la position horizontale relative d'une position
 * de curseur (en relatif par rapport … l'objet).
 *   LABEL : Le texte|____
 *   ^---------------^ = retour
 * curs est la position du curseur et tient compte du
 * parametre xedit->pos
 */

static 
int width_curs( W_XEDIT *xedit, int curs) {
	INT16 tab[10], dum, width;
	char c;

	/* Largeur du label */
	#define _FSM 0x5F46534DUL
	if( vq_gdos() && CONF(app)->xedit_label.font >= 0) 
		vst_font( app.handle, CONF(app)->xedit_label.font);
	if( CONF(app)->xedit_text.size > 0)
		vst_point( app.handle, CONF(app)->xedit_label.size, &dum, &dum, &dum, &dum);
	if( vq_vgdos() == _FSM) 
		vqt_f_extent( app.handle, xedit->tedinfo->te_ptmplt, tab);
	else
		vqt_extent( app.handle, xedit->tedinfo->te_ptmplt, tab);
	width = tab[2]-tab[0];

	/* largeur du champ editable */
	c = xedit->line[curs];
	xedit->line[curs] = '\0';
	if( vq_gdos() && CONF(app)->xedit_text.font >= 0) 
		vst_font( app.handle, CONF(app)->xedit_text.font);
	if( CONF(app)->xedit_text.size > 0)
		vst_point( app.handle, CONF(app)->xedit_text.size, &dum, &dum, &dum, &dum);
	if( vq_vgdos() == _FSM) 
		vqt_f_extent( app.handle, xedit->line+xedit->pos, tab);
	else
		vqt_extent( app.handle, xedit->line+xedit->pos, tab);
	width += tab[2]-tab[0];
	xedit->line[curs] = c;
	return width;
}

/*
 * Retourne la taille d'une cellule de caractere dans le champ editable.
 */

static 
void cell_curs( INT16 *wcell, INT16 *hcell) {
	INT16 dum;
	if( vq_gdos() && CONF(app)->xedit_text.font >= 0) 
		vst_font( app.handle, CONF(app)->xedit_text.font);
	if( CONF(app)->xedit_text.size > 0)
		vst_point( app.handle, CONF(app)->xedit_text.size, &dum, &dum, wcell, hcell);
}

/*
 * Affiche le curseur
 */

void xedit_curs( OBJECT *tree, int index) {
	W_XEDIT *xedit = (W_XEDIT*)tree[index].ob_spec.userblk->ub_parm;
	INT16 bar[4], wcell, hcell;
	
	objc_offset( tree, index, &bar[0], &bar[1]);
	cell_curs( &wcell, &hcell);
	bar[0] += width_curs( xedit, xedit->curs);
	
	vswr_mode( app.handle, MD_REPLACE);
	vsf_color( app.handle, BLACK);
	bar[2] = bar[0] + 1;
	bar[3] = bar[1] + hcell;
	v_bar( app.handle, bar);
}

/* 
 * Affiche le bloc
 */

void xedit_bloc( OBJECT *tree, int index) {
	W_XEDIT *xedit = (W_XEDIT*)tree[index].ob_spec.userblk->ub_parm;
	INT16 bar[4], wcell, hcell;
	
	objc_offset( tree, index, &bar[0], &bar[1]);
	cell_curs( &wcell, &hcell);
	bar[0] += width_curs( xedit, xedit->blcbeg);	
	bar[2] = bar[0] + width_curs( xedit, xedit->blcbeg);
	bar[3] = bar[1] + hcell;

	vswr_mode( app.handle, MD_XOR);
	vsf_color( app.handle, BLACK);
	v_bar( app.handle, bar);
}

/* appel a xedit_bloc dans une fenetre  */

static void win_xedit_bloc( WINDOW *win, W_FORM *wform, int index) {
	GRECT r1, r2;
	OBJECT *tree = wform -> root;

	graf_mouse( M_OFF, 0L);
	objc_offset( tree, index, &r1.g_x, &r1.g_y);
	r1.g_w = tree[index].ob_width;
	r1.g_h = tree[index].ob_height;	
	WindGet( win, WF_FIRSTXYWH, &r2.g_x, &r2.g_y, &r2.g_w, &r2.g_h);
	while( r2.g_w && r2.g_h) {
		if( rc_intersect( &r1, &r2)) xedit_bloc( tree, index);
		WindGet( win, WF_NEXTXYWH, &r2.g_x, &r2.g_y, &r2.g_w, &r2.g_h);
	}
	graf_mouse( M_ON, 0L);
}

/* Fonction utile pour la s‚lection … la souris */

int xedit_mouse2curs( OBJECT *tree, int index, int mx) {
	W_XEDIT *xedit = (W_XEDIT*)tree[index].ob_spec.userblk->ub_parm;
	INT16 x, y;
	int curs;
	
	objc_offset( tree, index, &x, &y);
	curs = xedit->pos;
	while( xedit->line[curs] && x + width_curs( xedit, curs++) < mx);
	return curs - 1 ;
}

/*
 *  Pour acc‚der aux ‚ditables et types ‚tendus de facon transparente
 *	Nouveau prototype pour la rendre publique (proto similaire a objc_edit)
 */

/* rappel : role des structures W_FORM */

#if 0 /* Ce if est un if de commentaire car les compilos C
       * ne supporte pas les commentaires imbriqu‚s sauf Pure C */

 typedef struct {
  OBJECT *root,     /* Address of object tree (can be duplicated) */
         *real;     /* Address of the real object tree (used by BubbleEvnt()) */
  int    *save;     /* Copy of objects' state (used by FormSave()) */
  	
  int    edit,      /* index of the current editable field */
         cursor,    /* cursor position in the current editable field */
         nb_ob;     /* number of objects of the formular */
} W_FORM;

	mode : OC_FORM, OC_TOOLBAR, OC_OBJCT
	win : WINDOW ou OBJECT
	obj : index editable
	val : depend de kind
	*idx : position curseur
	kind : ED_INIT	allumer le curseur
		   ED_CHAR 	insertion caractere
		   ED_END	eteindre le curseur
		   
		   ED_BLOC

typedef struct {
	TEDINFO *tedinfo;	/* structure Tedinfo originale */
	char *line;			/* le buffer */
	int pos, 			/* premier caractere visible */
		curs, 			/* position curseur */
		blcbeg, blcend;	/* position bloc */
	int flags;
	int size;			/* taille m‚moire de la ligne */
	int wp_type;		/* type de l'objet */
} W_XEDIT;

	A priori, n'utilise pas les champs cursor, edit de W_FORM, c'est aux fonctions
	qui appelle ObjcEdit() de g‚rer ca.

#endif /* 0 - Fin de commantaire */

#include <stdio.h>	/* Pour Debug */

/* modes additionnels - a mettre plus tard dans WINDOM.H */

#define ED_CURS 10
#define ED_BLC_OFF 11
#define ED_BLC_START 12
#define ED_BLC_END  13

int ObjcEdit( int mode, WINDOW *win, int obj, int val, INT16 *idx, int kind) {
	OBJECT *tree;
	W_FORM *wform;
	INT16 xc, yc, res=0;

	switch( mode) {
	case OC_FORM:
		wform = DataSearch( win, WD_WFRM);
		tree = wform->root;
		break;
	case OC_TOOLBAR:
		wform = &win->tool;
		tree = TOOL((WINDOW*)win);
		break;
	case OC_OBJC:
		tree = (OBJECT *)win;
		wform = NULL;
		break;
	default:
		return -1;	/* Error, bad value for mode */
	}

	objc_offset( tree, obj, &xc, &yc);
		
	/*
	 * Cas d'un objet XEDIT : WinDom gere le curseur.
	 */

#ifdef MODIF_XEDIT

	if( (tree[obj].ob_type & 0x00FF) == G_USERDEF 
		&& (tree[obj].ob_type>>8) == XEDIT) {
		W_XEDIT *xedit = (W_XEDIT *)tree[obj].ob_spec.userblk->ub_parm;
		char *p = xedit->line;
		INT16 wcell, hcell;
	
		#define RDRW_OFF 0
		#define RDRW_ALL 1
		#define RDRW_CUR 2
		#define RDRW_RT	 3

		int redraw = RDRW_OFF;

		switch( kind) {
		case ED_CURS:
			/* test */
			xedit -> curs = *idx;
			break;
		case ED_BLC_OFF:
			xedit -> flags &= ~XEDIT_BLOC_ON;
			if( wform)
				win_xedit_bloc( win, wform, obj);
			else
				xedit_bloc( tree, obj);
			break;
		case ED_BLC_START:
			xedit -> blcbeg = val;
			break;
		case ED_BLC_END:
			xedit -> flags |= XEDIT_BLOC_ON;
			xedit -> blcend = val;
			if( wform)
				win_xedit_bloc( win, wform, obj);
			else
				xedit_bloc( tree, obj);
			break;

		case ED_INIT:	/* Allumer le curseur */
			xedit -> flags |= XEDIT_CURS_ON;
			val = xedit->pos;
			/* position du scroll */
			if( xedit->curs < xedit->pos)
				xedit->pos = xedit->curs;
			cell_curs( &wcell, &hcell);
			while( width_curs( xedit, xedit->curs) + wcell/2 > tree[obj].ob_width)
				xedit->pos ++;
			redraw = ( val != xedit->pos)?RDRW_ALL:RDRW_CUR;
			*idx = xedit -> curs;
			break;
		case ED_END:	/* Eteindre le curseur */
			xedit -> flags &= ~XEDIT_CURS_ON;
			redraw = RDRW_ALL;
			break;
		case ED_CHAR:	/* Ajouter un caractŠre */
			if( xedit->flags & XEDIT_CURS_ON)
			switch( val) {
			
			case 0x4700:	/* HOME : curseur au d‚but du texte */
				if( p[xedit->curs] != '\0') {
					xedit->curs = xedit->pos = 0;
					redraw = RDRW_ALL;
				}
				break;
			case 0x4737:	/* S-HOME : curseur … la fin du texte */
				if( p[xedit->curs] != '\0') {
					redraw = RDRW_ALL;
					xedit->pos = xedit->curs = (int) strlen(p);
					xedit->pos = MAX( 0, xedit->pos-2);
				}	
			case 0x4B00:	/* LFARW : curseur … gauche */
				if( xedit->curs > 0) {
					redraw = RDRW_CUR;
					xedit->curs --;
				}
				break;
			case 0x7300:	/* C-LFARTW : curseur un mot … gauche */
				if( xedit->curs > 0) {
					xedit->curs --;
					/* skip escape */
					while( xedit->curs && p[xedit->curs] == ' ')
						xedit->curs --;
					/* skip word */
					while( xedit->curs && p[xedit->curs] != ' ')
						xedit->curs --;
					if( xedit->curs) xedit->curs ++;
					redraw = RDRW_ALL;
				}
				break;
			case 0x4D00:	/* RTARW : curseur … droite */
				if( p[xedit->curs] != '\0') {
					redraw = RDRW_CUR;
					xedit->curs ++;
				}
				break;
			case 0x7400:	/* C-RTARW : curseur un mot … droite */
				if( p[xedit->curs] != '\0') {					
					/* skip word */
					while( p[xedit->curs] != '\0' && p[xedit->curs] != ' ')
						xedit->curs ++;
					/* skip escape */
					while( p[xedit->curs] != '\0' && p[xedit->curs] == ' ')
						xedit->curs ++;
					redraw = RDRW_ALL;
				/*	xedit->curs --; */
				}
				break;
			case 0x537F: 	/* DEL : effacement devant le curseur */
				if( p[xedit->curs] != '\0')
					xedit->curs ++;

			case 0x0E08:	/* BACK : effacement derriere le curseur */
				if( xedit->curs > 0) {
					redraw = RDRW_RT;
					shift_left( p + xedit->curs-1);
					xedit->curs --;
					if( xedit->curs < xedit->pos) {
						redraw = RDRW_ALL;
						xedit->pos = MIN(xedit->pos-2,0);
					} 
				}
				break;

			case 0x011B:	/* ESC : champ vid‚, curseur au d‚but */
				redraw = RDRW_ALL;
				p[0] = '\0';
				xedit->curs = 0;
				xedit->pos = 0;
				break;
			
			case 0x2E03:	/* C-c : copie dans presse-papier */
				scrap_txt_write( p);				
				break;

			case 0x2F16:	/* C-v : insertion du presse-papier */
				{
					char *s, *q = scrap_txt_read();

					if( q) {
						for( s=q; *s; s++)
							xedit_add_char( xedit, *s);
						free( q);
						redraw = RDRW_ALL;
					}
				}
				break;

			default:		/* Insertion d'un caractŠre */
				if( val & 0x00FF) {
					redraw = p[xedit->curs]?RDRW_RT:RDRW_CUR;
					xedit_add_char( xedit, val);
				}
				
			} /* switch( val>>8) */
			
			val = xedit->pos;
			/* gestion du scroll */
			if( xedit->curs >= 0) {
				if( xedit->curs < xedit->pos)
					xedit->pos = xedit->curs;

				cell_curs( &wcell, &hcell);
				while( width_curs( xedit, xedit->curs) + wcell/2 > tree[obj].ob_width)
					xedit->pos ++;
			}
			if( redraw && val != xedit->pos)
				redraw = RDRW_ALL;

			*idx = xedit -> curs;
			break;
		} /* switch(kind) */

		/* redessin de l'objet */
		if( redraw != RDRW_OFF) {
			switch( redraw) {
			case RDRW_ALL:
				val = width_curs( xedit, xedit->pos);
				wcell = tree[obj].ob_width - val;
				break;
			case RDRW_CUR:
				val = width_curs( xedit, MAX(xedit->pos,xedit->curs-1));
				cell_curs( &wcell, &hcell);
				wcell *= 3;
				break;
			case RDRW_RT:
				val = width_curs( xedit, MAX(xedit->pos,xedit->curs-1));
				wcell = tree[obj].ob_width - val;
				break;
			}
			
			if( wform)
				ObjcWindDraw( win, tree, obj, 0, xc+val, yc, 
							  wcell, tree[obj].ob_height);
			else
				objc_draw( tree, obj, 0, xc+val, yc, 
						   wcell, tree[obj].ob_height);
		}
	} else 

#endif /* MODIF_XEDIT */

	/* Cas objet editable systeme en fenetre */ 

	if( wform) {
		INT16 curs = *idx;
		
		/* PROBLEME : Il n'est pas possible de modifier la zone de
		 *            masquage de objc_edit() */

		res = objc_edit( tree, obj, val, idx, kind);
		/* Je dois recaler le curseur */
		if( curs > 0 && kind == ED_INIT) {		
			while( *idx != curs)
				objc_edit( tree, obj, 
					((*idx > curs)?SC_LFARW:SC_RTARW)<<8, idx, ED_CHAR);
		}

	} else

		/* cas d'un dialogue classique */
	
		res = objc_edit( tree, obj, val, idx, kind);

	return res;
}

/* FIN MODIF OBJC_EDIT */

/*
 *	Retourne l'adresse du texte d'un objet (quelconque)
 *	->… pr‚voir si on veut une compatibilit‚ totale
 *	  avec MyDials de reconnaitre les objets MyDials
 */

char *ObjcString( OBJECT *tree, int index, char *put) {
	static char p[]="";
	USERBLK *user;
#ifdef MODIF_XEDIT
	W_XEDIT *xedit;
#endif

	switch ( tree[index].ob_type & 0x00FF) {
	case G_BUTTON:
	case G_STRING:
	case G_TITLE:
		if( put)
			tree[index].ob_spec.free_string = put;
		return( tree[index].ob_spec.free_string);
			
	case G_TEXT:
	case G_BOXTEXT:
	case G_FTEXT:
	case G_FBOXTEXT:
		if( put)
			tree[index].ob_spec.tedinfo->te_ptext = put;
		return (tree[index].ob_spec.tedinfo->te_ptext);
	case G_ICON:
	case G_CICON:
		if( put)
			tree[index].ob_spec.iconblk->ib_ptext = put;
		return (tree[index].ob_spec.iconblk->ib_ptext);
	case G_USERDEF:
		switch ( (tree[index].ob_type & 0xFF00)>>8) {
		case DCRBUTTON:
		case TITLEBOX:
		case UNDERLINE:
		case CIRCLEBUT:
		case ONGLET:
		case KPOPUPSTRG: /*  a v‚rifier */
		case MENUTITLE:		
		case XFREESTR:
			user = tree[index].ob_spec.userblk;
			if( put)
				(char*)((W_PARM*)user->ub_parm)->wp_spec = put;
			return ( (char*)((W_PARM*)user->ub_parm)->wp_spec);

#ifdef MODIF_XEDIT

		case XEDIT:
			xedit = (W_XEDIT *)tree[index].ob_spec.userblk->ub_parm;
			if( put) {
				int size = (int) realloc_xedit( xedit->size, strlen(put)+1);
				if( size) {
					xedit->size = size;
					xedit->line = realloc( xedit->line, size);
				}
				strcpy( xedit->line, put);
			}
			xedit->flags = 0;
			xedit->curs = xedit->pos = 0;
			return xedit->line;

#endif

		case XTEDINFO:
			user = tree[index].ob_spec.userblk;
#ifdef __GEMLIB__
			((TEDINFO *)PARM(user->ub_parm))->te_fontid = 0;			
#else
			((TEDINFO *)PARM(user->ub_parm))->te_junk1 = 0;
#endif
			if( put)
				((TEDINFO *)PARM(user->ub_parm))->te_ptext = put;
			return ((TEDINFO *)PARM(user->ub_parm))->te_ptext;
		}
		break;
	}
	return (p);
}

void ObjcStrFmt( char *dest, char *src, int size) {
	int len = (int)strlen( src);
	int middle = size/2;
	char buf [255];
	
	if( len > size) {
		strncpy( buf, src, size);
		buf[middle-3] = '\0';
		strcat( buf, "...");
		strcat( buf, src + len - middle - size%2);
		buf[size]='\0';
		strcpy( dest, buf);
	} else
		strcpy( dest, src);
}

struct objcolor {
	unsigned borderc:4;
	unsigned textc  :4;
	unsigned opaque :1;
	unsigned pattern:3;
	unsigned fillc  :4;
};

void ObjcStr3d( OBJECT *tree) {
	int res;
		
	if( !get_cookie( MAGX_COOKIE, NULL)) {
		res = 0;
		while( !(tree[res].ob_flags & LASTOB)) {
			if( tree[res].ob_type == G_FTEXT &&
				!(tree[res].ob_state & (1<<15))) {
				struct objcolor *color;
			
				tree[res].ob_state |= SELECTED;
				tree[res].ob_flags |= (1<<9);
				tree[res].ob_flags |= (1<<10);
				color = (struct objcolor*)&tree[res].ob_spec.tedinfo->te_color;
				color -> fillc = 8;
			}
			res ++;
		}
	} else {
		/*  a faire */
		/* Editable FLAG10 ~FLAG9 */
		
	}
}

/* Fonctions et variables attach‚es aux objets ‚tendus *
 * Attention aux formulaires multiples et menus 
 * Deux cas :
 *	->	une variable attribu‚e … un objet:
 *		sa mise-a-jour se fait dans la routine USERDEF
 *			bouton check : val = 0,1
 *			bouton radio : val = index objet
 *			popup : je ne sais pas faire, il me faudrait un nouveau type.
 *			le reste : rien pour le momment
 *	->	une fonction : elle ne se d‚clenche que si l'objet
 *		est effectivement s‚lectionn‚ : dans la routine de gestion
 *		des clicks. Ne marche donc que sur les SELECTABLE.
 */

/* mode = menu,form,toolbar  *
 * type = function, variable */

#define BIND_VAR 	1
#define BIND_FUNC 	2
#define BIND_BIT	3

void ObjcAttach( int mode, WINDOW *win, int index, int type, ...) {
	BIND   *bind = NULL;
	W_FORM *wfrm = NULL;  /* pour ne pas avoir de warning gcc */
	OBJECT *tree = NULL;  /* idem */
	va_list arg;
	
	va_start( arg, type);
	switch( mode) {
	case OC_MENU:
		if( win) {
			/* a faire */
			if( win->menu.bind == NULL)
				win->menu.bind = (BIND*)calloc( obj_nb(win->menu.root), sizeof(BIND));
			bind = win->menu.bind;
			tree = win->menu.root;
		} else {
			if( app.mnbind == NULL)
				app.mnbind = (BIND*)calloc( obj_nb(app.menu), sizeof(BIND));
			bind = app.mnbind;
			tree = app.menu;
		}
		break;
	case OC_TOOLBAR:
		if( win->tool.bind == NULL)
			win->tool.bind = (BIND*)calloc( win->tool.nb_ob, sizeof(BIND));
		bind = win->tool.bind;
		tree = win->tool.root;
		break;
	case OC_FORM:
		if( (wfrm = DataSearch( win, WD_WFRM)) != NULL) {
			if( wfrm->bind == NULL)
				wfrm->bind = (BIND*)calloc( wfrm->nb_ob, sizeof(BIND));
			bind = wfrm->bind;
			tree = wfrm->root;
		}
		break;
	}
	if( bind) {
		switch( type) {
		case BIND_VAR:
		case BIND_BIT:
			if( type == BIND_BIT) {
				bind[index].var = (void*) va_arg( arg, unsigned int*);
				bind[index].bit = va_arg( arg, unsigned int);
			} else {
				bind[index].var = va_arg( arg, int*);
				bind[index].bit = 0x1;
			}
			/* En plus, on met … jour l'‚tat de l'objet */
			switch( mode) {
			case OC_TOOLBAR:
			case OC_FORM:
				if( tree[index].ob_flags & RBUTTON)
					SET_BIT( tree[index].ob_state, SELECTED, (index == *(int*)bind[index].var)?1:0);
				else if( wfrm->root[index].ob_flags & SELECTABLE)
					SET_BIT( tree[index].ob_state, SELECTED, ((*(int*)bind[index].var) & bind[index].bit)?1:0);
			break;
			case OC_MENU:
				MenuIcheck( win, index, ((*(int*)bind[index].var) & bind[index].bit)?1:0);
				break;
			}
			break;
		case BIND_FUNC:
			bind[index].fnc = va_arg( arg, void*);
			break;
		}
	}
	va_end( arg);
}


/*  Cette fonction remplace les fonctions form_().
 *	On ne peut pas utiliser ces fonctions principalement
 *	… cause de la s‚lection des objets en arriŠre plan
 *	qui merde : le dessin des objets ne tient pas compte
 *	des fenˆtres.
 *
 *  Ces routines devraient logiquement aller dans FORM.C
 */	

static int __win_form_do( WINDOW *win, W_FORM *wform) {
	int res, debut; 
	OBJECT *tree = wform->root;
	INT16 mx, my, mbut, dum;
	BIND *bind = wform->bind;
	
	mx = evnt.mx;
	my = evnt.my;

	/* objet s‚lectionn‚ */
	res = objc_find( tree, ROOTS, MAX_DEPTH, mx, my);
	if( res == -1)
		return -1;

	/* Binding variables */
	if( wform->bind && bind[res].var) {
		/* RADIO -> index */
		if( wform->root[res].ob_flags & RBUTTON)
			*(bind[res].var) = res;
		/* NORMAL -> ‚tat SELECTED */
		else if( wform->root[res].ob_flags & SELECTABLE) {
			if (wform->root[res].ob_state & SELECTED)
				*(bind[res].var) &= ~bind[res].bit;
			else
				*(bind[res].var) |= bind[res].bit;
		} else
			; /* A voir le reste */
	}

	/* Gestion des objets 'SELECTABLE' */
	if( tree[res].ob_flags & SELECTABLE) {
		/* Cas des objets desactiv‚s */
		if( tree[res].ob_state & DISABLED)
			return -1;
		/* Cas des boutons radios */
		if( tree[res].ob_flags & RBUTTON) {
			if( !(tree[res].ob_state & SELECTED)) {
				debut = dum = res;
				while ( 1) { /* on deselectionne le bouton radio */
					if( dum != tree[tree[dum].ob_next].ob_tail)
						dum = tree[dum].ob_next;
					else
						dum = tree[tree[dum].ob_next].ob_head;
					if( dum == debut)
						break;
					if( (tree[dum].ob_flags & RBUTTON) && (tree[dum].ob_state & SELECTED)) {
						tree[dum].ob_state &= ~SELECTED;
						ObjcWindDraw( win, tree, dum, MAX_DEPTH, app.x, app.y, app.w, app.h);
						break;
					}
				}
				tree[res].ob_state |= SELECTED;
		    	ObjcWindDraw( win, tree, res, MAX_DEPTH, app.x, app.y, app.w, app.h);
			}
		}

		/* Cas des objets 'EXIT' */
		if( tree[res].ob_flags & EXIT) {
			do {
				dum = objc_find( tree, ROOTS, MAX_DEPTH, mx, my);				
				if( (tree[res].ob_state & SELECTED)==0 && res == dum) {
					tree[res].ob_state |= SELECTED;
					ObjcWindDraw( win, tree, res, MAX_DEPTH, app.x, app.y, app.w, app.h);
				}
				if( res != dum && (tree[res].ob_state & SELECTED)) {
					tree[res].ob_state &= ~SELECTED;
					ObjcWindDraw( win, tree, res, MAX_DEPTH, app.x, app.y, app.w, app.h);
				}
				graf_mkstate( &mx, &my, &mbut, &dum);
			} while( mbut);
			return( tree[res].ob_state & SELECTED)?res:-1;
		}
		/* Cas des boutons ni radio, ni exit, ni disabled */
		if( !(tree[ res].ob_flags & RBUTTON)) {
			if( tree[res].ob_state & SELECTED )
				tree[res].ob_state &= ~SELECTED;
			else
				tree[res].ob_state |= SELECTED;
		}
		ObjcWindDraw( win, tree, res, MAX_DEPTH, app.x, app.y, app.w, app.h);

		/* Cas objet TOUCHEXIT */
		if( tree[res].ob_flags & TOUCHEXIT)
			return res;
		else {
			/* Object non TOUCHEXIT: le bouton doit ˆtre relach‚ avant de sortir */
			do
				graf_mkstate( &dum, &dum, &mbut, &dum);
			while( mbut);
			return -1;
		}
	}	/* Fin objets selectable */
	
	/* Cas des objets 'TOUCHEXIT' */
	if( tree[res].ob_flags & TOUCHEXIT)
		return( res);

	if( !(tree[res].ob_state & SELECTABLE) &&
	    !(tree[res].ob_flags & TOUCHEXIT)  &&
	    win != wglb.front)
	    ApplWrite( app.id, WM_TOPPED, win->handle, 0, 0, 0, 0);

#ifdef MODIF_XEDIT

	/* Cas des objets 'XEDIT' systeme */
	if( (tree[res].ob_type & 0x00FF) == G_USERDEF 
		 && (tree[res].ob_type>>8) == XEDIT
		 && tree[res].ob_flags & EDITABLE) {
		
		graf_mkstate( &mx, &my, &mbut, &dum);

		if( !mbut) { 
			/* ‚teindre le bloc */
			ObjcEdit( OC_FORM, win, wform->edit, 0, &dum, ED_BLC_OFF);

			/* ‚teindre le curseur */
			ObjcEdit( OC_FORM, win, wform->edit, 0, &wform->cursor, ED_END);
			wform->edit = res;
	
			/* positionner le curseur */
			wform->cursor = xedit_mouse2curs( tree, res, evnt.mx);
			ObjcEdit( OC_FORM, win, res, 0, &wform->cursor, ED_CURS);

			/* Allumer curseur */
			ObjcEdit( OC_FORM, win, res, 0, &wform->cursor, ED_INIT);
		
			wform->edit = res;
		} else {
			W_XEDIT *xedit = (W_XEDIT *)tree[res].ob_spec.userblk->ub_parm;
			int inter;

			inter = xedit -> blcbeg = xedit_mouse2curs( tree, res, evnt.mx);
			do {
				inter = xedit_mouse2curs( tree, res, mx);
				if( inter > xedit -> blcbeg) {
					
				} else if( inter < xedit -> blcend) {
					
				}
				graf_mkstate( &mx, &my, &mbut, &dum);
			} while ( mbut);
			xedit -> blcend = inter;
			xedit -> flags |= XEDIT_BLOC_ON;
		}
	} else

#endif /* MODIF_XEDIT */

	/* Cas des objets 'EDITABLE' systeme */
	if( tree[res].ob_flags & EDITABLE) {
		int offset;
		INT16 tab[8];
		INT16 x,dx,pos=0;
		char *p;
		int dum, len;
		
		/* ‚teindre le curseur */
		ObjcEdit( OC_FORM, win, wform->edit, 0, &wform->cursor, ED_END);
		wform->edit = res;

		/*
		 *	Positionner le curseur … la souris
		 *  calculer les coordonn‚es du texte ....
		 */
		
		/* Position souris par rapport au cot‚ gauche de l'objet */
		objc_offset( tree, res, &x, &dx);
		x = evnt.mx-x;

 		
		/* Largeur du champ */ 		
 		p = tree[res].ob_spec.tedinfo->te_ptmplt;
		if( vq_vgdos() == _FSM) 
			vqt_f_extent( app.aeshdl, p, tab);
		else
			vqt_extent(app.aeshdl, p, tab);
		dx = tab[2] - tab[0] /* + offset? */;
		
		/* d‚calage du texte par rapport … l'objet */
		switch (tree[res].ob_spec.tedinfo->te_just) {
			case 0:	/* align‚ … gauche */
				offset = 0;
				break;
			case 1:	/* align‚ … droite */
				offset = tree[res].ob_width - dx;
				break;
			case 2:	/* centr‚ */
				offset = (tree[res].ob_width - dx)/2;
				break;
			default:
				offset = 0;
		}
		
		/* Calcul de la position du curseur */
 		p = strdup( tree[res].ob_spec.tedinfo->te_ptmplt);
		pos = (int)strlen( p);
		do {
			if( vq_vgdos() == _FSM) 
				vqt_f_extent( app.aeshdl, p, tab);
			else
				vqt_extent(app.aeshdl, p, tab);
			if( p[pos] != '_' && x >= tab[2]-tab[0]+offset)
				break;
			p[--pos] = '\0';
		} while( pos);

		/* on compte les caractŠres non ‚ditable qui restent */
		for( dum = 0, len = 0; dum < pos; dum ++)
			if( p[dum] != '_')
				len ++;
		
		/* nouvelle position du curseur */
		wform->cursor = MIN( pos - len, (int)strlen(tree[res].ob_spec.tedinfo->te_ptext));
		if( wform->edit != res && wform->edit != -1)
			ObjcEdit( OC_FORM, win, wform->edit, 0, &pos, ED_END);
		ObjcEdit( OC_FORM, win, res, 0, &wform->cursor, ED_INIT);
		wform->edit = res;		
		free(p);
	}
	return( -1);
}

/*
 *	Ev‚nement souris dans les formulaires
 */

int frm_buttn_ev( WINDOW *win, int mode) {
	W_FORM *tree;
	int res;
		
	switch( mode) {
	case OC_FORM:
		tree = DataSearch( win, WD_WFRM);
		break;
	case OC_TOOLBAR:
		tree = &win->tool;
		break;
	default:
		return -1;
	}
	
	res = __win_form_do( win, tree);

	/* Binding fonction */
	if( res != -1 && tree->bind && ((BIND *)tree->bind)[res].fnc) {
		void (*f)( WINDOW *,int, int );
		
		f = ((BIND *)tree->bind)[res].fnc;
		(*f)( win, res, mode);
	}
	
	return res;
}

/*
 *	Ev‚n‚ment clavier dans les formulaire
 */

int frm_keybd_ev( OBJECT *tree) {
	int dum=0;
	char *p, rac[2];
	int GemCode2Ascii( int, int, char *);

	if( !(evnt.mkstate & K_ALT))
		return -1;
	GemCode2Ascii( evnt.keybd, evnt.mkstate, rac);

	/* Chercher la commande */
	while(1) {

		if( ((tree[dum].ob_type>>8) == DCRBUTTON || 
			 (tree[dum].ob_type>>8) == ONGLET ||
			 (tree[dum].ob_type>>8) == KPOPUPSTRG )
			 && !(tree[dum].ob_flags & HIDETREE))
		{
			if( (tree[dum].ob_type & 0x00FF) == G_USERDEF)
				p = (char *)((W_PARM*)tree[dum].ob_spec.userblk->ub_parm)->wp_spec;
			else
				p = tree[dum].ob_spec.free_string;
				
			p = strchr( p, '[');
			if( p && toupper( *(p+1)) == rac[0])
				return dum;
		}
		
		dum = get_next_obj( tree, dum);
		if (dum == -1)
			return -1;
	} /* while( !(tree[dum++].ob_flags & LASTOB)); */
}

/*
 *	Fonction standard pour ObjcAttach()
 */

void form_close( WINDOW *win, int index, int mode) {
	ObjcChange( mode, win, index, ~SELECTED, TRUE);
	ApplWrite( app.id, WM_DESTROY, win->handle, 0, 0, 0, 0);
}

