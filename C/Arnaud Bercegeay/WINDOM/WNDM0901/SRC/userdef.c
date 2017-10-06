/*
 *	Windom - Librarie Userdef - code
 *
 *	compatible avec Interface/MyDial
 *	type ‚tendu non MyDials:
 *		15  Menu title
 *		16	Onglet
 *		0x1000	User Draw (type r‚serv‚)
 *	type ‚tendu MyDials:
 *		17	boŒte de d‚placement
 *		18	bouton
 *		19  chaŒne soulign‚
 *		20  titre
 *		21  touche d'aide
 *		22  bouton de cycle
 *		24  titre de popup
 *		31  bouton UNDO
 *
 *	flags ‚tendus
 *		ob_flags 15 , pour ‚ditable, champs d'‚dition multiligne : non g‚r‚
 *		ob_flags 11 , pour xtype 18, bouton undo
 *
 *  states ‚tendus:
 *		DRAW3D
 *		STATE8	autre aspect de bouton,
 *		STATE9 a STATE13  attributs des textes
 *
 *	Deux choses … savoir:		
 *		- la fonction userdef retourne un code qui contient les flags
 *		  des ‚tats des objets que l'AES dessinera par dessus notre
 *		  objets. J'ai masqu‚ l'‚tat des objets par les ‚tats standards
 *		  que dessine l'AES (voir MASK_STATE). MyDials le fait ‚galement.
 *		- les flags activator de l'aes 3.5 sont ‚galement pris en compte
 *		  par l'AES (le coquin): il rajoute un petit cadre autour de
 *		  l'objet.
 */

#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "globals.h"
#include "cicon.h"
#include "userdef.h"
#include "wsystem.h"
#include "cookie.h"

/*	Macros & constantes
 */

/* Attributs de texte */
#define BOLD		0x01
#define LIGHT		0x02
#define ITALIC		0x04
#define ULINE		0x08
#define OUTLINE		0x10
#define SHADOW		0x20

/* Bits ob_flags et ob_state */
#define WHITEBAK    0x0040
#define DRAW3D      0x0080
#define FLAGS9  0x0200
#define FLAGS10 0x0400
#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000

#define MASK_STATE		(DISABLED|CROSSED|CHECKED|OUTLINED|SHADOWED)
#define MASK2			(CROSSED|CHECKED|OUTLINED|SHADOWED)

#define STATE(pblk) (pblk)->pb_currstate
#define FLAGS(pblk) (pblk)->pb_tree[(pblk)->pb_obj].ob_flags
#define IS_STATE(pblk,state) (((pblk)->pb_currstate & (state))?1:0)
#define IS_FLAGS(pblk,flags) (((pblk)->pb_tree[(pblk)->pb_obj].ob_flags & (flags))?1:0)
#define PARM( ldata)	(((W_PARM *)(ldata))->wp_spec)

/* Variables locales :
 *	Les fonctions userdefs ne doivent pas ˆtre
 *  surcharg‚es en variables locales.
 */

static INT16 tab[12], dum;	/* utilis‚ par v_plines() */
static INT16 attrib[10];	/* utilis‚ par vqt_attributes() */
static PARMBLK pb;
static char str[128];
static GRECT r1, r2;		/* pour user_draw */

/*	Fonctions externes
 */
WORD __CDECL xdraw_cicon (PARMBLK *pb); 				/* cicon.c */
OBJECT *__xtype_trindex( int index);				/* rsrc.c  */
int FontName2Id( char *);

/***************************************************************
 *	Fonctions utilitaires (statiques)
 ***************************************************************/

/*
 *	initialise la structure parmblk
 */

static void set_parm( PARMBLK *dest, PARMBLK *src) {
	dest->pb_w		=	dest->pb_tree[dest->pb_obj].ob_width;
	dest->pb_h		=	dest->pb_tree[dest->pb_obj].ob_height;
	dest->pb_x		=	src->pb_x;
	dest->pb_y		=	src->pb_y /* +(src->pb_h-dest->pb_h)/2*/;
	dest->pb_xc		=	src->pb_xc;
	dest->pb_yc		=	src->pb_yc;
	dest->pb_wc		=	src->pb_wc;
	dest->pb_hc		=	src->pb_hc;
	dest->pb_parm	=	dest->pb_tree[dest->pb_obj].ob_spec.userblk->ub_parm;

	dest->pb_prevstate	=	dest->pb_tree[dest->pb_obj].ob_state;
	dest->pb_currstate  =	src->pb_tree[src->pb_obj].ob_state;
}

/*
 *	Retourne la couleur fix‚ par Let's them fly
 */

static int let_them_fly_color( void) {
	char *buff;
	
	int get_cookie( long, long *);
	
	if( get_cookie( LTMF_COOKIE, (long*)&buff))
		return( (int)*(buff+37));
	else
		return( CONF(app)->key_color & 0x000F);
}

/*
 *	S‚lectionne fonte, couleur et taille du texte
 *  retourne la fonte choisie
 */

int set_attrib( ATTRIB *attrib) {
	INT16 dum;
	int res;

	/* Dans les modes basses r‚solution, on ne gŠre que la
	   font systŠme pour des raisons esth‚tiques */
	if( _res) {
		if( app.gdos && attrib->font >= 0) res = vst_font( app.handle, attrib->font);
		else res = SYSFONT;
		if( attrib->size) vst_point( app.handle, attrib->size, &dum, &dum, &dum, &dum);
	} else {
		res = vst_font( app.handle, SYSFONT);
		vst_height( app.handle, 6, &dum, &dum, &dum, &dum);
	}
	if( attrib->color >= 0) vst_color( app.handle, attrib->color);
	return res;
}

/*
 *  transforme les coordonn‚es AES en coordonn‚es VDI
 */

#ifdef __GEMLIB__
#define grect2xy(a,b) grect_to_array((GRECT*)a,b)
#else
static void grect2xy( void *g, int *xy) {
	xy[0] = ((GRECT*)g)->g_x;
	xy[1] = ((GRECT*)g)->g_y;
	xy[2] = ((GRECT*)g)->g_x+((GRECT*)g)->g_w-1;
	xy[3] = ((GRECT*)g)->g_y+((GRECT*)g)->g_h-1;
}
#endif

/*
 *	S‚lection des attributs du texte et dessin du texte
 */

static void draw_text( PARMBLK *pblk, int x, int y, char *txt, int disabled) {
	int effect = 0;
	
	if( _res == 0) y++;
	/* effets */
	if( pblk->pb_currstate & STATE9)
		effect |= BOLD;
	if( pblk->pb_currstate & STATE10)
		effect |= ULINE;
	if( pblk->pb_currstate & STATE11)
		effect |= ITALIC;
	if( pblk->pb_currstate & STATE12)
		effect |= OUTLINE;
	if( pblk->pb_currstate & STATE13)
		effect |= SHADOW;
	if( (pblk->pb_currstate & DISABLED && disabled ) ||
		pblk->pb_currstate & STATE14)
		effect |= LIGHT;
	if( effect & SHADOW && !(effect & LIGHT)) {
		vst_effects( app.handle, effect | LIGHT);
		v_gtext( app.handle, x+2,  y+2, txt);
	}
	vst_effects( app.handle, effect);
	#define _FSM 0x5F46534DUL
	if(vq_vgdos() == _FSM)
		v_ftext( app.handle, x,  y, txt);
	else
		v_gtext( app.handle, x,  y, txt);
}

/*
 *	dessine le raccourci clavier
 */

static void draw_shortcut( PARMBLK *pblk, int shortcut, char *txt, int hcell, int xoffset, int yoffset) {
	INT16 textpos[8];
	int wcell;
	char c;
	
	/* taille texte */
	vqt_extent( app.handle, str, textpos);
	wcell = textpos[2] - textpos[0];
	tab[1] = tab[3] = pblk->pb_y + (pblk -> pb_h+hcell)/2 - 1 + yoffset;

	c = txt[shortcut+1];
	txt[shortcut+1] = '\0';
	vqt_extent( app.handle, txt, textpos);
	txt[shortcut+1] = c;
	tab[2] = pblk->pb_x+textpos[2]-textpos[0]-1 + ((xoffset!=-1)?xoffset:((pblk->pb_w-wcell)/2));
	
	c = txt[shortcut];
	txt[shortcut] = '\0';
	vqt_extent( app.handle, txt, textpos);
	txt[shortcut] = c;
	tab[0] = pblk->pb_x+textpos[2]-textpos[0]-1 + ((xoffset!=-1)?xoffset:((pblk->pb_w-wcell)/2));
	
	vsl_color( app.handle, (CONF(app)->key_color & LTMFLY_COLOR)?let_them_fly_color():CONF(app)->key_color);
	v_pline( app.handle, 2, tab);
}


/*
 * Recherche du raccourci clavier 
 */

static int find_shortcut( PARMBLK *pblk) {
	char *p;
	int pos = -1;
	
	strncpy( str, (char*)((W_PARM *)pblk->pb_parm)->wp_spec, 127);
	if( (p = strchr( str, '[')) != NULL ) {
		pos = (int) (p - str);
		*p = '\0';
		strcat( str, p+1);
	}
	return pos;
}

/*
 *	Dessine un fond
 *		dx : d‚calage horizontal ext. si positif
 *		dy : d‚calage vertical ext. si positif
 *		monopat : en couleurs < 16, style pattern
 */

#define BUT3D_PAT 	CONF(app)->actmono
#define ONGLT_PAT	CONF(app)->actmono
#define DIALM_PAT	CONF(app)->actmono
#define SCROL_PAT	CONF(app)->actmono

static void draw_background( PARMBLK *pblk, int dx, int dy, int monopat) {
	tab[0] = pblk->pb_x - dx;
	tab[1] = pblk->pb_y - dy;
	tab[2] = pblk->pb_x + pblk->pb_w-1+dx;
	tab[3] = pblk->pb_y + pblk->pb_h-1+dy;
	if( pblk->pb_currstate & DRAW3D) {
		if( app.color >= 16)  {
			vsf_interior( app.handle, FIS_SOLID);
			/*	Plante de  objc_sysvar() : il faut aussi tester la version de l'AES */
			/* 	objc_sysvar( SV_INQUIRE, ACTBUTCOL, 0, 0, &y, &x); */
			vsf_color( app.handle, CONF(app)->actcol);
		} else {
			vsf_interior( app.handle, FIS_PATTERN);
			vsf_style( app.handle, monopat);
			vsf_perimeter( app.handle, 0);
			vsf_color( app.handle, monopat?BLACK:WHITE);
		}
	} else {
		vsf_interior( app.handle, FIS_SOLID);
		vsf_color( app.handle, WHITE);
	}
	vswr_mode( app.handle, MD_REPLACE);
   	v_bar( app.handle, tab);
	vsf_perimeter( app.handle, 1);
}

/*
 *	Dessine un cadre 3d … la distance <offset> (ext‚rieure si positif
 *	int‚rieur si n‚gatif) de la taille objet:
 *		---------.
 *		|        .     -- <col1>
 *		..........     .. <col2>
 */

static void draw_frame( PARMBLK *pblk, int offset, int col1, int col2) {	
	tab[0] = tab[2] = pblk->pb_x - offset;
	tab[1] = pblk->pb_y + pblk->pb_h - 1 + offset;
	tab[3] = tab[5] = pblk->pb_y - offset;
	tab[4] = pblk->pb_x + pblk->pb_w - 1 + offset;
	vsl_color( app.handle, col1);
	v_pline( app.handle, 3, tab);
	tab[2] = tab[4];
	tab[3] = tab[1];
	vsl_color( app.handle, col2);
	v_pline( app.handle, 3, tab);
}

/***********************************************************
 * ============  Les routines de dessins ==================*
 ***********************************************************/

/*
 *	draw_but3D :
 *	Dessin des boutons userdefs (sous routine)
 */

static void draw_but3D(PARMBLK* pblk, char *txt) {
	int hcar;
	int x, y, width;
	int col1, col2;
	
   	vqt_attributes( app.handle, attrib);
	hcar = attrib[7];
	
	/* Dessin du fond  */
	draw_background( pblk, 0, 0, BUT3D_PAT);

	/* Dessin du cadre */
	width = IS_FLAGS(pblk,EXIT) + IS_FLAGS(pblk,DEFAULT);

	if( IS_STATE(pblk,DRAW3D)) {
		col1 = (STATE(pblk) & SELECTED)?LBLACK:WHITE;
		col2 = (STATE(pblk) & SELECTED)?WHITE:LBLACK;
	} else
		col1 = col2 = BLACK;

	if( width)
		draw_frame( pblk, 0, BLACK, BLACK);
	else
		draw_frame( pblk, 0, col1, col2);

	for(x=1; x <= width; x++)
		draw_frame( pblk, -x, col1, col2);


	/* Dessin du texte */
	set_attrib( (FLAGS(pblk) & EXIT)?&CONF(app)->exit:&CONF(app)->button);
	vqt_extent( app.handle, txt, attrib);
	x = pblk->pb_x + (pblk -> pb_w-attrib[2]+attrib[0])/2 - 1;
	y = pblk->pb_y + (pblk -> pb_h+hcar)/2 - 1;
	if( IS_STATE(pblk,SELECTED) && IS_STATE(pblk,DRAW3D)) {
		x ++;y ++;
	}
	vswr_mode( app.handle, MD_TRANS);
	draw_text( pblk, x, y, txt, 0);
	vswr_mode( app.handle, MD_REPLACE);
}

/*
 *	ub_xboxchar : dessine le type SLIDEPART pour faire des sliders 
 *				  identiques sous TOS, Naes et MagiC
 *	l'objet doit ˆtre de type BOXCHAR
 */

WORD __CDECL ub_xboxchar( PARMBLK *pblk) {
	INT16 dum;
	int x,y;
	char txt[2];
	BFOBSPEC *obspec;

	/* on masque */ 
	grect2xy( &pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);
	
	vswr_mode( app.handle, MD_REPLACE);
	obspec = (BFOBSPEC *)&((W_PARM *)pblk->pb_parm)->wp_spec;
	
	/* Couleur du fond:
	 *	- DRAW3D et fillpattern = interiorcol = 0 : fond activator
	 *	- sinon : couleur et style de obspec
	 */

	grect2xy( &pblk->pb_x, tab);
	
	if( pblk->pb_prevstate & DRAW3D && obspec->fillpattern == 0 && obspec->interiorcol == 0) {
		vsf_interior( app.handle, 1 /*FIS_SOLID*/);
		/* En toute rigueur il faudrait utiliser objc_sysvar() 
		   pour obtenir la couleur l‚gale */
		vsf_color( app.handle, ( app.color >= 16)?CONF(app)->actcol:WHITE);
	} else {
		vsf_interior( app.handle, 2 /*FIS_PATTERN*/);
		vsf_style( app.handle, obspec->fillpattern+1);
		vsf_color( app.handle, obspec->interiorcol);
	}
	vsf_perimeter( app.handle, obspec->framesize?1:0);
	v_bar( app.handle, tab);
	vsf_perimeter( app.handle, 1);
	
	/* frame */
	if( obspec->framesize) {
		tab[0] = pblk -> pb_x-1;
		tab[1] = pblk -> pb_y + pblk -> pb_h;
		tab[2] = tab[0];
		tab[3] = pblk -> pb_y-1;
		tab[4] = pblk -> pb_x + pblk -> pb_w;
		tab[5] = pblk -> pb_y-1;
		tab[6] = tab[4];
		tab[7] = tab[1];
		tab[8] = tab[0];
		tab[9] = tab[1];
	
		vsl_color( app.handle, obspec->framecol);
		v_pline( app.handle, 5, tab);
	
		/* Effet 3D */
		if( pblk->pb_prevstate & DRAW3D) {	
			int lblack = (app.color >= 16)?LBLACK:BLACK;
		
			tab[8] = tab[2] = ++ tab[0];
			tab[9] = tab[7] = -- tab[1];
			tab[3] ++;
			tab[6] = -- tab[4];
			tab[5] ++;
		
			vsl_color( app.handle, ( pblk->pb_currstate & SELECTED)?lblack:WHITE);
			v_pline( app.handle, 3, tab);
			vsl_color( app.handle, ( pblk->pb_currstate & SELECTED)?WHITE:lblack);
			v_pline( app.handle, 3, tab+4);
		}
	}
	
	/* La lettre */
 
   vqt_attributes( app.aeshdl, attrib);

	txt[0] = obspec->character;
	txt[1] = '\0';
	
	x = pblk->pb_x + (pblk->pb_w-attrib[8])/2;
	y = pblk->pb_y + (pblk->pb_h+attrib[9])/2;

	if( pblk->pb_currstate & SELECTED) {
		x ++; y ++;
	}

	vswr_mode( app.handle, obspec->textmode?MD_REPLACE:MD_TRANS);
	if( app.gdos)	vst_font( app.handle, 1);
	/* Pour lui, je sais pas, … voir */
	vst_height( app.handle, _res?13:6, &dum, &dum, &dum, &dum);
	if( app.gdos) vst_font( app.handle, 1);
	vst_color( app.handle, obspec->textcol);
	vst_effects( app.handle, 0);
	v_gtext( app.handle, x,  y, txt);
	
	vs_clip( app.handle, 0, tab);

	return (pblk->pb_currstate & MASK_STATE);
}

/**************************************************************************
 * d‚but d'ajout de code routines USERDEF (d'ARNAUD)                      *
 **************************************************************************/

/* REMARQUE IMPORTANTE:
 * les fonctions objets userdef ci-dessous ont subit un appel
 * … align3D (xrsrc.c) et donc, quelque soit le signe de "border"
 * il faut le consid‚rer comme une bordure vers l'int‚rieur !
 * C'est pour cela que dans chaque fonction on commence par
 * prendre la valeur absolue de border.
 */

static void draw_disabled3D( PARMBLK *pblk, int border) {
	/* on commence par rendre border positif */
	if (border < 0) border = -border;
	
	grect2xy( &pblk->pb_x, tab);

	tab[0] += border;
	tab[1] += border;
	tab[2] -= border;
	tab[3] -= border;	

	vswr_mode (app.handle, MD_TRANS);
	vsf_color (app.handle, 0);
	vsf_interior (app.handle, 2);
	vsf_style (app.handle, 4);
	vr_recfl (app.handle, tab);
}

static void draw_ibox3D( PARMBLK *pblk, int border, int color) {
	static int b;
	static int x1,y1,x2,y2;
	static int i;
	static INT16 p[40]; /* border max = 10 (10*4=40) */
	
	/* on commence par rendre border positif */
	if (border < 0) border = -border;

	grect2xy( &pblk->pb_x, tab);
	x1 = tab[0]; y1 = tab[1];
	x2 = tab[2]; y2 = tab[3];

	vswr_mode (app.handle, MD_REPLACE);

	/* bordure blanc (bord sup‚rieur gauche) */
	if (pblk->pb_currstate & SELECTED) {
		vsl_color (app.handle, app.nplanes<4?1:9);
	} else {
		if ((app.nplanes<4) && (border <= 1)) /* pas de bordure noire */
			vsl_color (app.handle, 1);
		else
			vsl_color (app.handle,0);
	}
	for( b=border>1?1:0; b<border; b++ ) {
		tab[0] = x1 + b;
		tab[1] = y2 - b - 1;
		tab[2] = x1 + b;
		tab[3] = y1 + b;
		tab[4] = x2 - b - 1;
		tab[5] = y1 + b;
		v_pline( app.handle, 3, tab);
	}

	/* bordure gris fonc‚ (bord inf‚rieur droit) [noir si - 16 coul] */
	if (pblk->pb_currstate & SELECTED) {
		if ((app.nplanes<4) && (border <= 1)) /* pas de bordure noire */
			vsl_color (app.handle, 1);
		else
			vsl_color (app.handle,0);
	} else {
		vsl_color (app.handle, app.nplanes<4?1:9);
	}
	for( b=border>1?1:0; b<border; b++ ) {
		tab[0] = x2 - b;
		tab[1] = y1 + b + 1;
		tab[2] = x2 - b;
		tab[3] = y2 - b;
		tab[4] = x1 + b + 1;
		tab[5] = y2 - b;
		v_pline (app.handle, 3, tab);
	}
	
	/* s‚paration entre les deux couleurs des borders */
	/* se fait toujours en gris clair */
	i = 0;
	for( b=border>1?1:0; b<border && i<40; b++ ) {
		p[i++] = x2 - b;
		p[i++] = y1 + b;
		p[i++] = x1 + b;
		p[i++] = y2 - b;
	}
	vsm_color(app.handle, app.nplanes<4?0:8);
	vsm_type(app.handle,1);
	v_pmarker(app.handle,i/2,p);
	
	/* le cadre de couleur */
	if (border > 1) {
		tab[0] = tab[6] = tab[8] = x1;
		tab[1] = tab[3] = tab[9] = y1;
		tab[2] = tab[4] = x2;
		tab[5] = tab[7] = y2;
		vsl_color (app.handle, color);
		v_pline (app.handle, 5, tab);
	}
}

static void	draw_box3D( PARMBLK *pblk, int border, int bordercol, 
                        int fillpattern, int interiorcol) {
	
	/* on commence par rendre border positif */
	if (border < 0) border = -border;
	
	if ((fillpattern==0) && (interiorcol==0)) {
		if (app.nplanes >= 4) {
			fillpattern = 7 ;  /* 100% */
			interiorcol = 8 ;  /* gris clair */
		} else {
			fillpattern = 7 ;  /* 100% */
			interiorcol = 0 ;  /* blanc */
		}
	}
	
	grect2xy( &pblk->pb_x, tab);
	vswr_mode (app.handle, MD_REPLACE);

	/* le fond (motif) */
	
	switch ( fillpattern ) {
	case 0:
		vsf_interior (app.handle, 0);
		break;
	case 1:	case 2:	case 3:
	case 4:	case 5:	case 6:
		vsf_interior (app.handle, 2);
		vsf_style (app.handle, fillpattern);
		break;
	case 7:
		vsf_interior (app.handle,1);
		break;
	}
	vsf_color (app.handle, interiorcol);
	
	tab[0] += border;
	tab[1] += border;
	tab[2] -= border;
	tab[3] -= border;	
	vr_recfl (app.handle, tab);
	
	draw_ibox3D(pblk,border,bordercol);
}

/*
 *	ub_multiligne : dessine un BOXTEXT dont le texte peut
 *                 ˆtre dessin‚ sur plusieurs lignes
 */

static char* str_formater( char *src, char *dest, int width_max, 
						  int len_max, int * width) {
	static int len, prev_len;       /* variables en static pour prendre */
	static unsigned char *s, *d;    /* un minimum de place dans la pile */
	static INT16 textpos[8];          /* superviseur */
	
	len = prev_len = 0 ;
	
	s = (unsigned char *) src;
	d = (unsigned char *) dest;
	
	while (1) {
		while (*s>32 && len<len_max) {
			*d++ = *s++;
			len++;
		}
		*d = 0;
		vqt_extent( app.handle, dest, textpos);
		if ( (textpos[2]-textpos[0]>width_max) || (len==len_max) ) {
			/* ligne remplie ! */
			/* on regarde si on peut faire une c‚sure naturelle */
			if (prev_len) {
				dest[prev_len]=0;
				s = (unsigned char *)&src[prev_len];
				while ( (*s<=32) && (*s!=10) && (*s!=13) )
					s++;
				while (*s && (*s==10 || *s==13))
					s++;
				return (char *)s;
			}
			/* il va falloir faire une c‚sure sauvage */
			while ( (textpos[2]-textpos[0]>width_max) && (d!=(unsigned char *)&dest[1]) ) {
				*--d = 0;
				s--;
				vqt_extent( app.handle, dest, textpos);
			}
			*width = textpos[2]-textpos[0];
			return (char *)s;
		}
		/* on m‚morise cette position comme une position de c‚sure naturelle */
		*width = textpos[2]-textpos[0];
		prev_len = len;
		/* il n'y a pas eu de c‚sure. On regarde s'il y a un retour chariot */
		/* ou si c'est la fin du texte tout simplement */
		if (*s==0 || *s==13 || *s==10) {
			while (*s && (*s==10 || *s==13))
				s++;
			return (char *)s;
		}
		/* on passe le caractŠre "espace" avant de poursuivre */
		*d++ = *s++;
		len++;
	}
}

/* Sous fonction pour les objets de type XTEDINFO */

static void set_attrib_xtedinfo( ATTRIB *attrib, int smallsize, TEDINFO *tedinfo, INT16 *hchar, INT16 *hcell) {
	int fontid = set_attrib( attrib);

	if( fontid == SYSFONT) 
		vst_point (app.handle, tedinfo->te_font==5?8:10, &dum, hchar, &dum, hcell);
	else 
		vst_point (app.handle, tedinfo->te_font==5?smallsize:attrib->size, &dum, hchar, &dum, hcell);
	if( attrib->color < 0)
		/* Par defaut, la couleur est seul de l'objet */
		vst_color( app.handle, (tedinfo->te_color >> 8 ) & 0x0F);
}

/*
 * Objet XBOXLONGEDIT
 */


WORD __CDECL ub_multiligne( PARMBLK *pblk) {
	/*il y aurait surement moyen de sortir ces variables de la fonction... */
	static int x,y;
	static TEDINFO *tedinfo;
	static int border, b;
	static int x1,y1,x2,y2;
	static INT16 char_h, cell_h;
	static INT16 tabclip[4];
	static char *tmpptr;
	static int width;

	/* le fond */	
	tedinfo = (TEDINFO*)PARM(pblk->pb_parm);
	grect2xy( &pblk->pb_x, tab);
	x1 = tab[0] ;
	y1 = tab[1] ;
	x2 = tab[2] ;
	y2 = tab[3] ;
	
	/* on masque */ 
	grect2xy( &pblk->pb_xc, tabclip);
	if (tabclip[0]<tab[0]) tabclip[0]=tab[0];
	if (tabclip[1]<tab[1]) tabclip[1]=tab[1];
	if (tabclip[2]>tab[2]) tabclip[2]=tab[2];
	if (tabclip[3]>tab[3]) tabclip[3]=tab[3];
	if (tabclip[0]>tabclip[2]) return 0;
	if (tabclip[1]>tabclip[3]) return 0;
	vs_clip( app.handle, 1, tabclip);
	
	/* fond gris clair (y compris les bordures) [blanc - 16 coul] */
	vswr_mode (app.handle, MD_REPLACE);
	vsf_color (app.handle, app.nplanes<4?0:8);
	vsf_interior (app.handle, 1);
	vr_recfl (app.handle, tab);
	vsl_width (app.handle, 1);

	/* r‚cupŠre la valeur absolue de "border"  car cette bordure devra ˆtre */
	/* dans tous les cas consid‚r‚e comme une bordure vers l'int‚rieur      */
	border = tedinfo->te_thickness & 0x00FF;
   if (border >= 128) border = 256 - border;
	
	/* le fond (motif) */
	if ( tedinfo->te_color & 0x0070) {
		tab[0] += border;
		tab[1] += border;
		tab[2] -= border;
		tab[3] -= border;
		vsf_color (app.handle, (int)(tedinfo->te_color & 0x0FL));
		vsf_interior (app.handle, 1);
		vr_recfl (app.handle, tab);
	}

	vsl_color (app.handle,9);
	for( b=0; b<border; b++ ) {
		tab[0] = x1 + b;
		tab[1] = y2 - b - 1;
		tab[2] = x1 + b;
		tab[3] = y1 + b;
		tab[4] = x2 - b - 1;
		tab[5] = y1 + b;
		v_pline (app.handle, 3, tab);
	}

	vsl_color (app.handle,0);
	for( b=0; b<border; b++ ) {
		tab[0] = x2 - b;
		tab[1] = y1 + b + 1;
		tab[2] = x2 - b;
		tab[3] = y2 - b;
		tab[4] = x1 + b + 1;
		tab[5] = y2 - b;
		v_pline (app.handle, 3, tab);
	}

	/* le cadre noir */
	if (border > 1) {
		tab[0] = tab[6] = tab[8] = x1+border-1;
		tab[1] = tab[3] = tab[9] = y1+border-1;
		tab[2] = tab[4] = x2-border+1;
		tab[5] = tab[7] = y2-border+1;
		vsl_color (app.handle, 8);
		v_pline (app.handle, 5, tab);
	}

	/* fin clippage */
	vs_clip( app.handle, 0, tabclip);

	/* et le texte */
	
	/* clippage */
	if (tabclip[0] < x1+border) tabclip[0] = x1+border;
	if (tabclip[1] < y1+border) tabclip[1] = y1+border;
	if (tabclip[2] > x2-border) tabclip[2] = x2-border;
	if (tabclip[3] > y2-border) tabclip[3] = y2-border;
	if (tabclip[0]>tabclip[2]) return 0;
	if (tabclip[1]>tabclip[3]) return 0;
	vs_clip( app.handle, 1, tabclip);

	vswr_mode( app.handle, tedinfo->te_color & 0x0080?MD_REPLACE:MD_TRANS);
	set_attrib_xtedinfo( &CONF(app)->xlongedit, CONF(app)->xlgedt_smlfnt, tedinfo, &char_h, &cell_h);
	vst_effects (app.handle, 0 /*(pblk->pb_currstate & DISABLED)?2:0*/);

	x1 += border + 1;
	y = y1 + border + char_h + 1;
	
	tmpptr = tedinfo->te_ptext;
	while (*tmpptr) {
		tmpptr = str_formater(tmpptr,str,x2-x1-border-border,128,&width);
		switch (tedinfo->te_just) {
			case 0 : /* left */ x=x1; break;
			case 2 : /*center*/ x=x1+((pblk->pb_w - width)>>1)-border-1; break;
			default: /* right*/ x=x1+(pblk->pb_w - width)-(border<<1)-2; break;
		}
		v_gtext( app.handle, x,  y, str);
		if (y>y2) break;
		y += cell_h;
	}
	
	/* fin clippage */
	vs_clip( app.handle, 0, tabclip);

	if (pblk->pb_currstate & DISABLED)
		draw_disabled3D( pblk, border);

	return (pblk->pb_currstate & MASK2);
}

/*
 *  Objet XTEDINFO
 */

WORD __CDECL ub_boxtext3d( PARMBLK *pblk) {
	static int x,y;
	static TEDINFO *tedinfo;
	static int x1,y1,x2,y2;
	static INT16 char_h;
	static INT16 tabclip[4];
	static int width;
	static int fillpattern, interiorcol, border, bordercol;

	/* on masque */ 
	grect2xy( &pblk->pb_xc, tabclip);
	vs_clip( app.handle, 1, tabclip);
	
	tedinfo = (TEDINFO*)PARM(pblk->pb_parm);
	border = tedinfo->te_thickness & 0x00FF;
	bordercol = (tedinfo->te_color >> 12) & 0x0F;
	fillpattern = (tedinfo->te_color >> 4) & 0x07;
	interiorcol = tedinfo->te_color & 0x0F;
	
	/* on commence par rendre border positif */
   if (border >= 128) border = 256 - border;

	draw_box3D(pblk,border,bordercol,fillpattern,interiorcol);

	grect2xy( &pblk->pb_x, tab);
	x1 = tab[0] ;
	y1 = tab[1] ;
	x2 = tab[2] ;
	y2 = tab[3] ;
	
	/* fin clippage */
	vs_clip( app.handle, 0, tabclip);

	/* et le texte */
	
	/* clippage */
	if (tabclip[0] < x1+border) tabclip[0] = x1+border;
	if (tabclip[1] < y1+border) tabclip[1] = y1+border;
	if (tabclip[2] > x2-border) tabclip[2] = x2-border;
	if (tabclip[3] > y2-border) tabclip[3] = y2-border;
	if (tabclip[0]>tabclip[2]) return 0;
	if (tabclip[1]>tabclip[3]) return 0;
	vs_clip( app.handle, 1, tabclip);

	/* et le texte */
	vswr_mode( app.handle, MD_TRANS);  /* MD_TRANS pour objets 3D */
	set_attrib_xtedinfo( &CONF(app)->xtedinfo, CONF(app)->xtdinf_smlfnt, tedinfo, &char_h, &dum);
	vst_effects( app.handle, 0);
	vqt_extent( app.handle, tedinfo->te_ptext, attrib);

	width = attrib[2] - attrib[0];
	switch (tedinfo->te_just) {
	case 0 : /* left */
		x = x1 + border + 1;  break;
	case 2 : /*center*/
		x = x1 + ((pblk->pb_w - width)>>1) + 1; break;
	default: /* right*/
		x = x2 - width - border + 2; break;
	}
	y = y1 + ((pblk->pb_h + char_h) >> 1);
	
	if( ! (pblk->pb_currstate & SELECTED) ) {
		x --;
		y --;
	}

	v_gtext( app.handle, x,  y, tedinfo->te_ptext);
	
	if (pblk->pb_currstate & DISABLED)
		draw_disabled3D(pblk,border);
	
	grect2xy( &pblk->pb_xc, tab);
	vs_clip( app.handle, 0, tabclip);

	return (pblk->pb_currstate & MASK2);
}

/* Cette fonction est trŠs certainement
 * identique … xboxchar
 */

WORD __CDECL ub_boxchar3d( PARMBLK *pblk) {
	static int x,y;
	static int x1,y1,x2,y2;
	static INT16 char_l, char_h, cell_l, cell_h;
	static int fontid;
	static int fillpattern, interiorcol, border, bordercol;
	static BFOBSPEC obspec;
	static char c[2];

	/* on masque */ 
	grect2xy( &pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);
	
	memcpy( &obspec, &PARM(pblk->pb_parm), sizeof(BFOBSPEC));
	border = obspec.framesize;
	bordercol = obspec.framecol;
	fillpattern = obspec.fillpattern;
	interiorcol = obspec.interiorcol;

	draw_box3D( pblk, border, bordercol, fillpattern, interiorcol);

	grect2xy( &pblk->pb_x, tab);
	x1 = tab[0] ;
	y1 = tab[1] ;
	x2 = tab[2] ;
	y2 = tab[3] ;
	
	/* et le caractere */
	vswr_mode( app.handle, obspec.textmode? MD_REPLACE : MD_TRANS);
	fontid = -1;
/*	if( app.gdos)	fontid = FontName2Id("Monospace 821");	*/
	if( fontid>0) {
		vst_font( app.handle, fontid);
		vst_point (app.handle, 9, &char_l, &char_h, &cell_l, &cell_h);
	} else {
		if( app.gdos) vst_font( app.handle, 0);
		vst_point (app.handle, 10, &char_l, &char_h, &cell_l, &cell_h);
	}
	vst_color( app.handle, obspec.textcol);
	vst_effects( app.handle, 0 /*(pblk->pb_currstate & DISABLED)?2:0*/);
	
	c[0] = obspec.character;
	c[1] = 0;

	vqt_extent( app.handle, c, attrib);
	x = pblk->pb_x + ((pblk->pb_w - attrib[2] + attrib[0]) >> 1) + 1;
	y = pblk->pb_y + ((pblk->pb_h + char_h) >> 1);
	
	if( !(pblk->pb_currstate & SELECTED) ) {
		x --;
		y --;
	}

	v_gtext( app.handle, x,  y, c);
	
	if (pblk->pb_currstate & DISABLED)
		draw_disabled3D(pblk,border);

	grect2xy( &pblk->pb_xc, tab);
	vs_clip( app.handle, 0, tab);

	return (pblk->pb_currstate & MASK2);
}

WORD __CDECL ub_ibox3d( PARMBLK *pblk) {
	static BFOBSPEC obspec;
	
	/* on masque */ 
	grect2xy( &pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);
	
	memcpy( &obspec,&PARM(pblk->pb_parm), sizeof(BFOBSPEC));
	draw_ibox3D( pblk, obspec.framesize, obspec.framecol);
	
	if (pblk->pb_currstate & DISABLED)
		draw_disabled3D( pblk, obspec.framesize);

	/* clip off */
	grect2xy( &pblk->pb_xc, tab);  /* warning: tab was modified by draw_ibox() */
	vs_clip( app.handle, 0, tab);
	
	return (pblk->pb_currstate & MASK2);
}

WORD __CDECL ub_box3d( PARMBLK *pblk) {
	static int border, fillpattern, interiorcol, bordercol;
	static BFOBSPEC obspec;

	/* on masque */ 
	grect2xy( &pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);
	
	memcpy( &obspec, &PARM(pblk->pb_parm), sizeof(BFOBSPEC));
	border = obspec.framesize;
	bordercol = obspec.framecol;
	fillpattern = obspec.fillpattern;
	interiorcol = obspec.interiorcol;

	draw_box3D( pblk, border, bordercol, fillpattern, interiorcol);
	
	if (pblk->pb_currstate & DISABLED)
		draw_disabled3D(pblk,border);

	grect2xy( &pblk->pb_xc, tab);
	vs_clip( app.handle, 0, tab);

	return (pblk->pb_currstate & MASK2);
}

WORD __CDECL ub_but3d( PARMBLK *pblk) {
	static int x,y;
	static int border;
	static int x1,y1,x2,y2;
	static int char_h, cell_h;
	static int width;
	int rac_pos;

	/* Recherche raccourci clavier */
	rac_pos = find_shortcut( pblk);

	/* on masque */ 
	grect2xy( &pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);
	
	border = 1;
	if (pblk->pb_tree[pblk->pb_obj].ob_flags & EXIT)    border++;
	if (pblk->pb_tree[pblk->pb_obj].ob_flags & DEFAULT) border++;

	draw_box3D(pblk,-border,1,0,0);

	grect2xy( &pblk->pb_x, tab);
	x1 = tab[0] ;
	y1 = tab[1] ;
	x2 = tab[2] ;
	y2 = tab[3] ;
	
	/* et le texte */
	vswr_mode( app.handle, MD_TRANS);
	if (pblk->pb_tree[pblk->pb_obj].ob_flags & EXIT) 
		set_attrib( &CONF(app)->exit);
	else 
		set_attrib( &CONF(app)->button);
	vqt_attributes( app.handle, attrib);
	char_h = attrib[7];
	cell_h = attrib[9];	
	vst_effects (app.handle, 0);

	vqt_extent( app.handle, str, attrib);
	width = attrib[2] - attrib[0];
	x = x1 + ((pblk->pb_w - width)>>1) + 1;
	y = y1 + ((pblk->pb_h + char_h) >> 1);
	
	if( !(pblk->pb_currstate & SELECTED) ) {
		x --;
		y --;
	}

	v_gtext( app.handle, x,  y, str);
	if( rac_pos != -1 && !(pblk->pb_currstate & SELECTED))
		draw_shortcut( pblk, rac_pos, str, cell_h, -1, 0);
	
	if (pblk->pb_currstate & DISABLED)
		draw_disabled3D(pblk,border);

	grect2xy( &pblk->pb_xc, tab);
	vs_clip( app.handle, 0, tab);

	return (pblk->pb_currstate & MASK2);
}


/**************************************************************************
 * fin d'ajout de code routines USERDEF d'Arnaud                          *
 **************************************************************************/

/*
 *	Dessine les objets DCRBUTTON
 */

WORD __CDECL ub_button( PARMBLK *pblk) {
	int hcell, hcar, wicon;
	int rac_pos;

	/* Recherche raccourci clavier */
	rac_pos = find_shortcut( pblk);

	/* Attribut texte */
	vqt_attributes( app.handle, tab);
	hcar = tab[7];
	hcell = tab[9];
	
	/* on clippe */ 
	grect2xy(&pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);

	/* Cas bouton Exit */	
	if( IS_FLAGS(pblk,EXIT) && !IS_FLAGS(pblk,RBUTTON)) {
		draw_but3D( pblk, str);
		if( rac_pos != -1 && !(pblk->pb_currstate & SELECTED))
			draw_shortcut( pblk, rac_pos, str, hcell, -1, 0);
		vs_clip( app.handle, 0, tab);
		if( pblk->pb_currstate & DRAW3D)
			return (pblk->pb_currstate & MASK_STATE);
		else
			return (pblk->pb_currstate & (MASK_STATE|SELECTED));
	}

	/* Autres boutons */
	pb.pb_tree  = __xtype_trindex(USERDEF);	
	if( IS_FLAGS(pblk,RBUTTON)) {	
		/* Bouton radio */
		if( IS_STATE(pblk,DRAW3D)) {
			if(  _res)
				pb.pb_obj = ( pblk->pb_tree[pblk->pb_obj].ob_state & STATE8)?HRAD2:HRAD;
			else
				pb.pb_obj = ( pblk->pb_tree[pblk->pb_obj].ob_state & STATE8)?LRAD2:LRAD;
		} else {
			if(  _res)
				pb.pb_obj = ( pblk->pb_tree[pblk->pb_obj].ob_state & STATE8)?MHRAD2:MHRAD;
			else
				pb.pb_obj = ( pblk->pb_tree[pblk->pb_obj].ob_state & STATE8)?MLRAD2:MLRAD;
		}
	} else {
		if( IS_STATE(pblk,DRAW3D)) {
			if(  _res)
				pb.pb_obj = ( pblk->pb_tree[pblk->pb_obj].ob_state & STATE8)?HBUT2:HBUT;
			else
				pb.pb_obj = ( pblk->pb_tree[pblk->pb_obj].ob_state & STATE8)?LBUT2:LBUT;
		} else {
			if(  _res)
				pb.pb_obj = ( pblk->pb_tree[pblk->pb_obj].ob_state & STATE8)?MHBUT2:MHBUT;
			else
				pb.pb_obj = ( pblk->pb_tree[pblk->pb_obj].ob_state & STATE8)?MLBUT2:MLBUT;
		}
	}

	wicon = pb.pb_tree[pb.pb_obj].ob_width;
	vswr_mode( app.handle, ( pblk->pb_currstate & DRAW3D)?MD_TRANS:MD_REPLACE);	
	set_parm( &pb, pblk);

	/* Affichage texte et raccourci clavier */	
	set_attrib( &CONF(app)->button);
	draw_text( pblk, pblk->pb_x + wicon + 5, 
			   pblk->pb_y+pblk->pb_h/2+hcar/2-1, str, 1);

	/* afficher le raccourci */
	if( rac_pos != -1)
		draw_shortcut( pblk, rac_pos, str,  hcell, wicon + 5, 0);

	xdraw_cicon( &pb);

 	vs_clip( app.handle, 0, tab);

	return (pblk->pb_currstate & MASK2);
}

#if ! MODIF_ARNAUD  /* code mort */
static void v_box( int handle, int *xy) {
	INT16 tab[10];

	tab[0]=xy[0];
	tab[1]=xy[1];
	tab[2]=xy[0];
	tab[3]=xy[3];
	tab[4]=xy[2];
	tab[5]=xy[3];
	tab[6]=xy[2];
	tab[7]=xy[1];
	tab[8]=xy[0];
	tab[9]=xy[1];
	v_pline( handle, 5, tab);
}
#endif

/*
 *	Dessine le type ONGLET
 *	Bouton pour formulaire multiple  (objet non MyDial)
 *	STATE8: coins arrondis
 *	STATE15: bouton en bas
 *	STATE9-14: attribut du texte
 */

WORD __CDECL ub_onglet( PARMBLK *pblk) {
	int hcar, hcell;
	int rac_pos;
	int x,y,sel,draw3d;
	
	/* Recherche raccourci clavier */
	rac_pos = find_shortcut( pblk);

	/* tailles des caractŠres */	
	vqt_attributes( app.handle, tab);
	hcar  = tab[7];
	hcell = tab[9];

	sel = (pblk->pb_currstate & SELECTED)?1:0;
	draw3d = ( (app.color >= 16) && (pblk->pb_currstate & DRAW3D));
	
	/* clippage : si radio, il faut intersectionner */
   	grect2xy(&pblk->pb_xc, tab);
   	if( IS_FLAGS(pblk,RBUTTON)) {
   		if( IS_STATE(pblk,STATE15))
   			tab[1] = MAX( tab[1], pblk -> pb_y-1);
		else
  			tab[3] = MIN( tab[3], pblk -> pb_y+pblk -> pb_h);
   	}
	vs_clip( app.handle, 1, tab);
	
	/* on pr‚pare le fond */
	draw_background( pblk, 0, 2*(IS_FLAGS(pblk,RBUTTON) && sel), ONGLT_PAT);

	/* le cadre */
	if( IS_FLAGS(pblk,RBUTTON) && IS_STATE(pblk,STATE8)) {
		if( IS_STATE(pblk,STATE15)) {
			tab[0]=pblk->pb_x;
			tab[1]=pblk->pb_y - pblk->pb_h;
			tab[2]=pblk->pb_x+pblk->pb_w-1;
			tab[3]=pblk->pb_y+pblk->pb_h - 1 - !sel*3;
		} else {
			tab[0]=pblk->pb_x;
			tab[1]=pblk->pb_y + !sel*3;
			tab[2]=pblk->pb_x+pblk->pb_w-1;
			tab[3]=pblk->pb_y+pblk->pb_h*2-1;
		}
		vsl_color( app.handle, draw3d? WHITE:BLACK);
		v_rbox( app.handle, tab);
		if( app.color>=16) {
			tab[0]++;
			tab[1]++;
			if( IS_STATE(pblk,STATE15)) {
			/*	tab[2]--; */
				tab[3]--;
			}
			vsl_color( app.handle, draw3d?LBLACK:BLACK);
			v_rbox( app.handle, tab);
		}
	} else {
		tab[0] = pblk->pb_x;
		tab[1] = pblk->pb_y + pblk->pb_h - 1;
		tab[2] = pblk->pb_x;
		tab[3] = pblk->pb_y + !sel*3*IS_FLAGS(pblk,RBUTTON);
		tab[4] = pblk->pb_x + pblk->pb_w - 1;
		tab[5] = pblk->pb_y + !sel*3*IS_FLAGS(pblk,RBUTTON);
		tab[6] = pblk->pb_x + pblk->pb_w - 1;
		tab[7] = pblk->pb_y + pblk->pb_h - 1 + 2*sel;
		tab[8] = tab[0];
		tab[9] = tab[1];
		vsl_color( app.handle, draw3d? WHITE:BLACK);
		v_pline( app.handle, 3, tab);
		vsl_color( app.handle, draw3d?LBLACK:BLACK);
		v_pline( app.handle, 2, tab+4);
		if( !IS_FLAGS(pblk,RBUTTON))
			v_pline( app.handle, 2, tab+6);
	}
	
	/* le texte */
	set_attrib(&CONF(app)->button);
	vqt_extent( app.handle, str, attrib);
	vst_alignment( app.handle, 0, 0, &dum, &dum);
	x = pblk->pb_x + (pblk -> pb_w-attrib[2]+attrib[0])/2 - 1;
	y = pblk->pb_y + (pblk -> pb_h+hcar)/2 - 1;
	if( pblk->pb_currstate & STATE15)
		y -= 2*!sel;
	else
		y += 2*!sel;
	vswr_mode( app.handle, MD_TRANS);
	draw_text ( pblk, x, y, str, 1);
	vswr_mode( app.handle, MD_REPLACE);
	/* surligner le raccourci clavier */
	if( rac_pos != -1 && !IS_STATE(pblk,SELECTED))
		draw_shortcut( pblk, rac_pos, str, hcell, -1, 
			(STATE(pblk) & STATE15)?(-2*!sel):2*!sel);
	
	vs_clip( app.handle, 0, tab); 

	return (pblk->pb_currstate & MASK2);
}

/*
 *	Bouton de cycle (CIRCLEBUT)
 */

WORD __CDECL ub_boxcircle( PARMBLK *pblk) {
	pb.pb_tree  = __xtype_trindex(USERDEF);
	
	if( IS_STATE(pblk,DRAW3D))
		pb.pb_obj = _res?HCIR:LCIR;
	else
		pb.pb_obj = _res?MHCIR:MLCIR;
	set_parm( &pb, pblk);

	/* masquer */
	grect2xy(&pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);
	/* affichage ic“ne */
	xdraw_cicon(&pb);
	vs_clip( app.handle, 0, tab);
	return (pblk->pb_currstate & MASK_STATE);
}

/*
 *	bouton DRAW3D uniquement (boutons … ob_state mis a DRAW3D)
 */

/* attention, arnaud redefinit cette fonction (pourquoi ?)
 * un peu plus loin sous le nom ub_but3d  */

WORD __CDECL ub_but3D( PARMBLK *pblk) {
	/* on masque */
   	grect2xy(&pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);
	/* dessin du bouton */
	draw_but3D( pblk, (char*)((W_PARM *)pblk->pb_parm)->wp_spec);
	vs_clip( app.handle, 0, tab);
	/* code pour AES */
	if( pblk->pb_currstate & DRAW3D)
		return (pblk->pb_currstate & MASK_STATE);
	else
		return (pblk->pb_currstate & (MASK_STATE|SELECTED));
}

/*
 *	BoŒte avec un titre (TITLEBOX)
 */

WORD __CDECL ub_boxtitle(PARMBLK* pblk) {
	int hcar;

   	grect2xy(&pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);

   	vqt_attributes( app.handle, attrib);
   	hcar = attrib[ 7];
    set_attrib( &CONF(app)->string);
	vqt_extent( app.handle, (char*)((W_PARM *)pblk->pb_parm)->wp_spec, attrib);
	vswr_mode( app.handle, ( pblk->pb_currstate & DRAW3D)?MD_TRANS:MD_REPLACE);
	draw_text( pblk, pblk->pb_x + 8, pblk->pb_y + hcar/2 - 1, 
					(char*)((W_PARM *)pblk->pb_parm)->wp_spec, 1);
	vswr_mode( app.handle, MD_REPLACE);

	if( pblk->pb_currstate & DRAW3D && app.color>=16) {
		tab[0] = pblk -> pb_x + 5;
		tab[11] = tab[9] = tab[3] = tab[1] = pblk -> pb_y;
		tab[4] = tab[2] = pblk -> pb_x;
		tab[7] = tab[5] = tab[3] + pblk -> pb_h - 1;
		tab[8] = tab[6] = tab[4] + pblk -> pb_w - 1;
		tab[10] = tab[0] + attrib[2] - attrib[0] + 4;
		vsl_color( app.handle, LBLACK);
		v_pline( app.handle, 6, tab);
		for(hcar=1;hcar<12;tab[hcar++]++);
		tab[10]--;
		vsl_color( app.handle, WHITE);
		v_pline( app.handle, 6, tab);
	} else {
		tab[0] = pblk -> pb_x + 5;
		tab[11] = tab[9] = tab[3] = tab[1] = pblk -> pb_y;
		tab[4] = tab[2] = pblk -> pb_x;
		tab[7] = tab[5] = tab[3] + pblk -> pb_h - 1;
		tab[8] = tab[6] = tab[4] + pblk -> pb_w - 1;
		tab[10] = tab[0] + attrib[2] - attrib[0] + 4;
		vsl_color( app.handle, BLACK);
		v_pline( app.handle, 6, tab);
	}
	vs_clip( app.handle, 0, tab);
	return (pblk->pb_currstate & MASK2);
}

/*
 *	Texte soulign‚ (UNDERLINE)
 */

WORD __CDECL ub_ulinetext( PARMBLK *pblk) {
	int hcar,hcell;

	grect2xy(&pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);

	vqt_attributes( app.handle, tab);
   	hcar  = tab[7];
	hcell = tab[9];
	set_attrib(&CONF(app)->string);
	if( pblk->pb_currstate & STATE8) {
		tab[0] = pblk->pb_x;
		tab[1] = pblk->pb_y + pblk->pb_h - 1;
		tab[2] = pblk->pb_x + pblk->pb_w - 1;
		tab[3] = tab[1];
	} else {
		vqt_extent( app.handle, (char*)((W_PARM *)pblk->pb_parm)->wp_spec, tab);
		tab[0] += pblk->pb_x;
		tab[1] += pblk->pb_y + pblk->pb_h/2 + hcell/2 + 1;
		tab[2] += pblk->pb_x;
		tab[3] = tab[1];
	}

	tab[1] ++; tab[3] ++;
	vswr_mode( app.handle, MD_REPLACE);
	vsl_color( app.handle, LBLACK);
	v_pline( app.handle, 2, tab);
	
	if( pblk->pb_currstate & DRAW3D) {
		tab[1] --; tab[3] --;
		vsl_color( app.handle, WHITE);
		v_pline( app.handle, 2, tab);
	}

	vswr_mode( app.handle, MD_TRANS);
	draw_text( pblk, pblk->pb_x, pblk->pb_y + pblk->pb_h/2 + hcar/2 - 1,
				(char *)((W_PARM*)pblk->pb_parm)->wp_spec, 1);

	vs_clip( app.handle, 0, tab);
	return (pblk->pb_currstate & MASK2);
}

/*
 *	Texte pour popup (KPOPUPSTR)
 */

WORD __CDECL ub_popuptext( PARMBLK *pblk) {
	int hcar, hcell;
	int rac_pos;
	int x,y;
	
	/* Recherche raccourci clavier */
	rac_pos = find_shortcut( pblk);

	/* tailles des caractŠres */	
	vqt_attributes( app.handle, tab);
	hcar  = tab[7];
	hcell = tab[9];
	
	/* clippage */
   	grect2xy(&pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);
	
	if( pblk->pb_prevstate == pblk->pb_currstate) /* redraw */
	{
	if (pblk->pb_currstate & SELECTED) {
		tab[0]=pblk->pb_x-1;
		tab[1]=pblk->pb_y-1;
		tab[2]=pblk->pb_x+pblk->pb_w+1;
		tab[3]=pblk->pb_y+pblk->pb_h+1;
		vsf_color( app.handle, BLACK);
		vswr_mode( app.handle, MD_XOR);
		vsf_interior( app.handle, 1 /*FIS_SOLID*/ );
		v_bar( app.handle, tab);
	}
	
	/* le texte */
	set_attrib( &CONF(app)->string);
	vqt_extent( app.handle, str, attrib);
	x = pblk->pb_x;								/* align‚ … gauche */
	y = pblk->pb_y + (pblk -> pb_h+hcar)/2 - 1; /* centr‚ en hauteur */
	vswr_mode( app.handle, MD_TRANS);
	draw_text( pblk, x,  y, str, 1);
	vswr_mode( app.handle, MD_REPLACE);

	/* surligner le raccourci clavier */
	if( rac_pos != -1 && !(pblk->pb_currstate & SELECTED))
		draw_shortcut( pblk, rac_pos, str, hcell, 0, 0);
	
	} else {	/* Changement d'‚tat : le seul possible (SELECTED) */
		if( (pblk->pb_currstate & SELECTED &&
			 (pblk->pb_prevstate & SELECTED) == 0) ||
			(pblk->pb_prevstate & SELECTED &&
			 (pblk->pb_currstate & SELECTED) == 0)) {
			tab[0]=pblk->pb_x-1;
			tab[1]=pblk->pb_y-1;
			tab[2]=pblk->pb_x+pblk->pb_w+1;
			tab[3]=pblk->pb_y+pblk->pb_h+1;
			vsf_color( app.handle, BLACK);
			vswr_mode( app.handle, MD_XOR);
			vsf_interior( app.handle, 1 /*FIS_SOLID*/ );
			v_bar( app.handle, tab);
		}
	}
	
	vs_clip( app.handle, 0, tab); 

	return (pblk->pb_currstate & MASK2);
}

/*
 *	Objet WinDom, pour mettre du texte a fonte
 *	dans les menus et que ce soit bien formatt‚
 *	(raccourci clavier … droite).
 *	On gŠre l'‚tat DISABLED pour que ce soit
 *	joli avec les fonds de couleurs
 */

/* si ca marche, ca ira dans APPvar */

int is_title	( OBJECT *, int );
#ifndef __GEMLIB__
int rc_intersect( GRECT*, GRECT*);
#endif

WORD __CDECL ub_mntitle( PARMBLK *pblk) {
	char *p;
	int len;
	int x,y;
	int line = 0;
	int pre = 0, post = 0;
	int type = (((W_PARM *)pblk->pb_parm)->wp_type & 0x00FF);
	GRECT r1, r2;
	
	/*
	 * Clippage non respect‚ sous TOS 
	 * peut-etre parce qu'il s'agit d'un menu ??
	 * j'utilise plutot les coordonn‚es de l'objet intersect‚
	 * avec le clip sauf pour les title du bureau
	 */

	if( type == G_TITLE) {
		r1.g_x = pblk -> pb_x + 1;
		r1.g_y = pblk -> pb_y + 1;
		r1.g_w = pblk -> pb_w - 2;
		r1.g_h = pblk -> pb_h - 2;
	} else {
		r1.g_x = pblk -> pb_x - 1;
		r1.g_y = pblk -> pb_y - 1;
		r1.g_w = pblk -> pb_w + 2;
		r1.g_h = pblk -> pb_h + 2;
	}
	r2.g_x = pblk -> pb_xc;
	r2.g_y = pblk -> pb_yc;
	r2.g_w = pblk -> pb_wc;
	r2.g_h = pblk -> pb_hc;
	
	/* Si nul, c'est un TITLE de menu du bureau */
	if( r2.g_x) rc_intersect( &r2, &r1);
	tab[3] = r1.g_y+r1.g_h-1;
	grect2xy( &r1, tab);
	vs_clip( app.handle, 1, tab);

	/* Rep‚rer la chaine */
	strcpy( str, (char*)((W_PARM *)pblk->pb_parm)->wp_spec);
	p = NULL;

	/* C'est une ligne de s‚paration ? */
	if( (*str == '-' && pblk->pb_currstate & DISABLED)
		|| IS_STATE(pblk, STATE8)) {
		char *s;
		line = 1;

		/* y a-t-il un label ? */		
		for( s = str; *s; s++)
			if( *s != '-') break;
			else *s = ' ';

		if( *s) {
			pre = (int)(s - str);
			/* continuer jusqu'au prochain '-' */
			for(  s = str; *s; s++)
				if( *s == '-') break;
			post = (int)(s - str);
			if( *s) {
				for( ; *s == '-'; s++) 
					*s = ' ';
			}
			
		}
	} else
	/* L'‚ventuel texte */	
	if( (((W_PARM *)pblk->pb_parm)->wp_type & 0x00FF) != G_TITLE) {
		/* on r‚cupŠre le raccourci clavier (… droite) */
		len = (int)strlen(str);
		if( len > 2 && str[len-2] != ' ') { 
			/* Il y a un raccourci */
			str[len-1] = '\0';
			p = strrchr( str, ' ');
			if( p) *p = '\0';
		}
		/* str = le titre, p = le raccourci */
	}
	
	if( pblk->pb_prevstate == pblk->pb_currstate) { /* redraw */
		/* Dessin du texte normal */
		int charpos = 0;
		int xpos = 0;

		/* le texte */
		set_attrib( &CONF(app)->title);
		vqt_attributes( app.handle, tab);			
		if( line && str[1] == '-' ) {
			charpos = 1;
			xpos = tab[8]*2;
		}
		x = pblk->pb_x;							  	/* align‚ … gauche */
		y = pblk->pb_y + (pblk -> pb_h+tab[7])/2-2; /* centr‚ en hauteur */
		vswr_mode( app.handle, MD_TRANS);
		draw_text( pblk, x+xpos,  y, str+charpos, 1);
		/* Au tour du raccourci */
		if( p) {
			vqt_extent( app.handle, p+1, attrib);
			x = pblk->pb_x + pblk->pb_w - attrib[2] + attrib[0] - tab[6];
			draw_text( pblk, x,  y, p+1, 1);
		}
		vswr_mode( app.handle, MD_REPLACE);

		/* Cas ligne de s‚paration */
		if( line) {
			vswr_mode( app.handle, MD_REPLACE);
			vsf_perimeter(app.handle, 0);
			if( app.color >= 16) {
				vsf_color	( app.handle, LBLACK);
				vsf_interior( app.handle, 1 /* FIS_SOLID */);
			} else {
				vsf_color	( app.handle, BLACK);
				vsf_interior( app.handle, 2 /* FIS_PATTERN */);				
				vsf_style	( app.handle, 4);
			}
			tab[0] = pblk->pb_x;
			tab[1] = pblk->pb_y + pblk->pb_h/2 - 1;
			tab[3] = pblk->pb_y + pblk->pb_h/2;
			if( pre) {
				char c = str[pre];
				str[pre] = 0;
				vqt_extent( app.handle, str, attrib);
				str[pre] = c;
				tab[2] = pblk->pb_x + attrib[2]-attrib[0];
				v_bar( app.handle, tab);
				c = str[post];
				str[post] = 0;
				vqt_extent( app.handle, str, attrib);
				str[post] = c;
				tab[0] = pblk->pb_x + attrib[2]-attrib[0];
				tab[2] = pblk->pb_x + pblk->pb_w - 1;
				v_bar( app.handle, tab);
	
			} else {
				tab[2] = pblk->pb_x + pblk->pb_w - 1;
				v_bar( app.handle, tab);
			}
		}
		
		/* Fond noir quand SELECTED */
		if( pblk->pb_currstate & SELECTED)
			goto INVERSE;
		
	} else {	/* Changement d'‚tat: SELECTED */
		if( (pblk->pb_currstate & SELECTED &&
			 (pblk->pb_prevstate & SELECTED) == 0) ||
			(pblk->pb_prevstate & SELECTED &&
			 (pblk->pb_currstate & SELECTED) == 0)) {
INVERSE:	grect2xy(&pblk->pb_x, tab);

			vsf_color( app.handle, BLACK);
			vswr_mode( app.handle, MD_XOR);
			vsf_interior( app.handle, 1 /*FIS_SOLID*/ );

			v_bar( app.handle, tab);
			vs_clip( app.handle, 0, tab);			

			if( app.hilight && pblk->pb_currstate & SELECTED ) {
				int i;
				void (*hilight)( void *, int, int);

				hilight = app.hilight;
				if( is_title( pblk->pb_tree, pblk->pb_obj)) 
					(*hilight)( NULL, pblk->pb_obj, -1);
				else {
					/* Autre facon : trouver le G_TITLE s‚lectionn‚ */
					i = 2;
					while( !(pblk->pb_tree[i].ob_flags & LASTOB)) {
						if( is_title( pblk->pb_tree, i) && pblk->pb_tree[i].ob_state & SELECTED)
						   	break;
						i ++;
					}
					(*hilight)( NULL, i, pblk->pb_obj);
				}
			}
		}
	}
	vs_clip( app.handle, 0, tab);
	return (pblk->pb_currstate & MASK2);
}


/*
 *	Fond formulaire (DIALMOVER)
 *	-> a compl‚ter, il faudrait qu'il prenne
 *	   en compte les paramŠtre d'une P_BOX
 */
 
WORD __CDECL ub_dialmover( PARMBLK* pblk) {
	int res;

	/* clippage */
	grect2xy(&pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);
	
	if( IS_STATE(pblk,DRAW3D)) {
		if( IS_STATE(pblk,OUTLINED)) {
			draw_background( pblk, 2, 2, DIALM_PAT);
			draw_frame( pblk, 3, BLACK, BLACK);
			draw_frame( pblk, 2, WHITE, LBLACK);
			draw_frame( pblk, -1, LBLACK, WHITE);
			draw_frame( pblk, -2, BLACK, BLACK);
		} else {
			draw_background( pblk, 0, 0, DIALM_PAT);
			draw_frame( pblk, 0, BLACK, BLACK);
			draw_frame( pblk, -1, WHITE, LBLACK);
		}
	} else {
		if( IS_STATE(pblk,OUTLINED)) {
			draw_background( pblk, 2, 2, 0);
			draw_frame( pblk, 3, BLACK, BLACK);
			draw_frame( pblk, -1, BLACK, BLACK);
			draw_frame( pblk, -2, BLACK, BLACK);
		} else {
			draw_background( pblk, 0, 0, 0);
			draw_frame( pblk, 0, BLACK, BLACK);
		}
	}
	
	vs_clip( app.handle, 0, tab);
	res = pblk->pb_currstate;
	res &= ~OUTLINED;
	return res;
}

#ifdef MODIF_XEDIT

/*
 * Champ ‚ditable de longueur quelconque (XEDIT)
 *  Aspect :
 *		label avec raccourci : ___champ_encadr‚___
 *
 *	Le userdef pointe vers une structure XEDITDATA
 *	associ‚e … l'objet par la fonction init_type() (voir XRSC.C).
 *
 *	On utilise la structure XEDITDATA.TEDINFO pour coder le texte
 *	et le label. Accessoirement, cela permet de conserver le
 *  texte saisi si on desalloue le type XEDIT.
 *	Le reste de la structure XEDITDATA sert a coder
 *	les position, curseur et bloc. La fonction ub_editable
 *	reste assez simple. Le gros du boulot est dans ObjcEdit().
 *
 *	Il faut ‚crire une routine ObjcEdit() qui fonctionne
 *	pour tous objets ‚ditables. C'est elle qui s'occupera
 *	de la gestion dynamique du texte, du curseur et aussi des blocs.
 *
 */

#define XTEXT	xedit->line;
#define XLABEL	xedit->tedinfo->te_ptmplt;

int xedit_curs( OBJECT *, int);
int xedit_bloc( OBJECT *, int);

#define OPAQUE (1<<7)	/* Parametre Opaque/trans des TEDINFO */

WORD __CDECL ub_editable( PARMBLK *pblk) {
	char *p, *q;
	int y;
	W_XEDIT *xedit = (W_XEDIT *)pblk->pb_parm;
	
	/* clippage */
	grect2xy(&pblk->pb_xc, tab);
	vs_clip( app.handle, 1, tab);

	/* le fond */
	draw_background( pblk, 2, 2, DIALM_PAT);

	/* Le label : doit avoir un certain format */

	p = XLABEL;
	q = strchr( p, '_');
	if( q) *q = '\0';
	vqt_attributes( app.handle, tab);
	y = pblk->pb_y + (pblk->pb_h+tab[7])/2;	
	/* MD_TRANS ou MD_REPLACE selon le mode : A VERIFIER */
	vswr_mode( app.handle, 
			   (xedit->tedinfo->te_color & OPAQUE)?MD_TRANS:MD_REPLACE);
	set_attrib( &CONF(app)->xedit_label);
	if( CONF(app)->xedit_label.color == -1)
		vst_color( app.handle, (xedit->tedinfo->te_color>>8) & 0xF);
		
	if( vq_vgdos() == _FSM) 
		v_ftext( app.handle, pblk->pb_x+2, y, p);
	else
		v_gtext( app.handle, pblk->pb_x+2, y, p);
	vqt_extent( app.handle, p, tab);
	pblk->pb_x += tab[2]-tab[0];
	pblk->pb_w -= tab[2]-tab[0];

	/*
	 * Le cadre
	 */

	grect2xy(&pblk->pb_x, tab);
	vsf_color( app.handle, WHITE);
	vsf_interior( app.handle, FIS_SOLID);
	vswr_mode( app.handle, MD_REPLACE);
	v_bar( app.handle, tab);
	if( IS_STATE(pblk,DRAW3D)) {
		draw_frame( pblk, 2, LBLACK, WHITE);
		draw_frame( pblk, 1, BLACK, BLACK);
	} else 
		draw_frame( pblk, 1, BLACK, BLACK);

	/*
	 * Le texte du champ 
	 */

	p = XTEXT;
	if( xedit->pos > 0) p += xedit->pos;

	/* Pas d'effet */
	vst_effects( app.handle, 0);
	/* fonte systŠme pour le moment */
	if( vq_gdos()) vst_font( app.handle, 0);
	vqt_attributes( app.handle, tab);	
	y = pblk->pb_y + (pblk->pb_h+tab[7])/2;

	/* On clippe a l'interieur du cadre pour que
	 * le texte ne d‚borde pas. */
	
	rc_set( &r2, pblk->pb_x, pblk->pb_y, pblk->pb_w, pblk->pb_h);
	rc_set( &r1, pblk->pb_xc, pblk->pb_yc, pblk->pb_wc, pblk->pb_hc);
	rc_intersect( &r1, &r2);	 
	grect2xy( &r2, tab);
	vs_clip( app.handle, 1, tab);

	set_attrib( &CONF(app)->xedit_text);
	if( CONF(app)->xedit_text.color == -1)
		vst_color( app.handle, (xedit->tedinfo->te_color>>8) & 0xF);

	if( vq_vgdos() == _FSM) 
		v_ftext( app.handle, pblk->pb_x+2, y, p);
	else
		v_gtext( app.handle, pblk->pb_x+2, y, p);

	/* Le curseur */
 	if( xedit->curs & XEDIT_CURS_ON )	/* allum‚ ?  */
		xedit_curs( pblk->pb_tree, pblk->pb_obj);

	/* Le bloc */
	if( xedit->blcbeg & XEDIT_BLOC_ON  )
		xedit_bloc( pblk->pb_tree, pblk->pb_obj);

	vs_clip( app.handle, 0, tab);
	return (pblk->pb_currstate & MASK_STATE);
}

#endif /* MODIF_XEDIT */

/*
 *	Routine userdef pour dessiner n'importe nawak : n'est pas
 *  attribu‚ par le principe des types ‚tendus mais par la
 *  fonction 
 *		set_user_draw( OBJECT *tree, int index, void (*user)(WINDOW *), GRECT *clip)
 *	
 */

WORD  __CDECL user_draw( PARMBLK *pblk) {
	USER_DRAW *udraw;
	
	/* R‚cup‚rer la routine */
	udraw = (USER_DRAW *)pblk->pb_parm;
	/* Rectangle de masquage */
	rc_set( &r1, pblk -> pb_xc, pblk -> pb_yc, pblk -> pb_wc, pblk -> pb_hc);
	rc_set( &r2, pblk -> pb_x, pblk -> pb_y, pblk -> pb_w, pblk -> pb_h);
	if( rc_intersect( &r1, &r2)) {
   		grect2xy( &r2, tab);
		vs_clip( udraw->win->graf.handle, 1, tab);
		/* ex‚cuter la routine */
		(*udraw->draw)( udraw->win, pblk);
		vs_clip( udraw->win->graf.handle, 0, tab);
	}
	return (pblk->pb_currstate & MASK_STATE);
}


/* EOF */

