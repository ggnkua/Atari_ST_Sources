/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: popup.c
 *	description: fonction MenuPopUp(), version largement
 *				 modifi‚e par Arnaud Bercegeay
 */

#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "globals.h"
#include "userdef.h"

/* Corps du Module 
 */


/* sous fonction pour menu popup */

static
void pop_drw(WINDOW *win) {
	objc_draw( (OBJECT*)DataSearch(win,WD_WPOP), 0, 7, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
}

/*
 * pour le moment, seen ne sert … rien 
 *	Premiere grosse modif par Arnaud (mais ca cela va
 *	encore ‚voluer) : parametre marge.
 */

/* objets du "formulaire" pop up/list
    0    -  parent
    1    -  premier choix du menu
    2    -  deuxiŠme choix du menu
    (etc...)
    seen -  dernier choix du menu
    
    (et si size > seen, cad s'il y a un ascenseur)
    seen+ASC_BG : parent de l'ascenseur
    seen+ASC_UP : fleche "haut" de l'ascenseur
    seen+ASC_DW : flŠche "bas" de l'ascenseur
    seen+ASC_PG : fond de l'ascenseur pour les PAGE UP/DW
    seen+ASC_SL : le slider
*/

#define ASC_BG  1
#define ASC_UP  2
#define ASC_DW  3
#define ASC_PG  4
#define ASC_SL  5

#define POPDEBUG 0

typedef struct __xuserblk {
	USERBLK user;
	W_PARM  w_parm;
} XUSERBLK ;

static XUSERBLK uo[4];

extern void align_obj3d( OBJECT *tree, int index, int mode) ;
extern WORD __CDECL ub_box3d     ( PARMBLK *pblk);
extern WORD __CDECL ub_boxchar3d ( PARMBLK *pblk);

#define		FL3DMASK	0x0600	/* 3D objects AES 3.4	*/

static void uo_init_type( OBJECT *tree, int index, void *func, 
						  int extype, XUSERBLK * uo) {
	(W_PARM *)(uo -> user . ub_parm) = & ( uo -> w_parm );
	uo -> user . ub_code = func;
	((W_PARM*)uo -> user . ub_parm) -> wp_type = tree[index].ob_type; 
	((W_PARM*)uo -> user . ub_parm) -> wp_spec = tree[index].ob_spec.index;
	tree[index].ob_spec.userblk = & ( uo -> user ) ;
	tree[index].ob_type = G_USERDEF | (extype<<8);
}

static void uo_set_box( OBJECT *tree, int index, XUSERBLK *uo) {
	align_obj3d( tree, index, 1);
	uo_init_type( tree, index, ub_box3d, XBFOBSPEC, uo);
	tree[ index].ob_flags &= ~FL3DMASK;
}

static void uo_set_boxchar( OBJECT *tree, int index, XUSERBLK *uo) {
	align_obj3d( tree, index, 1);
	uo_init_type( tree, index, ub_boxchar3d, XBFOBSPEC, uo);
	tree[ index].ob_flags &= ~FL3DMASK;
}



static void str2menu( OBJECT * tree, int ypos, int seen, char *ptxt[], 
					  int len_max, int item) {
	int i;
	
	for (i=0; i<seen; i++) {
		if (strncmp(ptxt[i+ypos],"---",3)==0)  /* c'est un s‚parateur */
		{
			tree[i+1].ob_state &= ~CHECKED;
			tree[i+1].ob_flags &= ~SELECTABLE;
			memset( tree[i+1].ob_spec.free_string, '-', len_max);
			tree[i+1].ob_spec.free_string[len_max] = 0;
		} else {
			tree[i+1].ob_flags |= SELECTABLE;
			if (item==i+1+ypos)
				tree[i+1].ob_state |= CHECKED;
			else
				tree[i+1].ob_state &= ~CHECKED;
			strcpy( tree[i+1].ob_spec.free_string, "  ");
			strcat( tree[i+1].ob_spec.free_string, ptxt[i+ypos]);
			strcat( tree[i+1].ob_spec.free_string, " ");
		}
	}
}

static void pop_udslider( OBJECT * tree, int ypos, int size, int seen) {
	/* calcul de la hauteur du slider */
	tree[seen+ASC_SL].ob_height = (seen * tree[seen+ASC_PG].ob_height) / size ;
	/* calcul la position du slider */
	tree[seen+ASC_SL].ob_y = (ypos * tree[seen+ASC_PG].ob_height) / size ;
	/* et on borne */
	if (tree[seen+ASC_SL].ob_height < 16)
		tree[seen+ASC_SL].ob_height = 16;
	if (tree[seen+ASC_SL].ob_y + tree[seen+ASC_SL].ob_height > tree[seen+ASC_PG].ob_height)
		tree[seen+ASC_SL].ob_y = tree[seen+ASC_PG].ob_height - tree[seen+ASC_SL].ob_height;
}

static 
OBJECT *txt2objc( char *ptxt[], int size, int seen, int poplist,
                  INT16 attrib[], int * ptr_len_max) {
	int i;
#define wcell attrib[8]
#define hcell attrib[9]
	int dum;
	OBJECT *tree;
	int width = 0;
	int dy;
#define len_max (*ptr_len_max)
	int nb_obj;

#if POPDEBUG
int Fh;
char tmpstr[1024];
#endif
	
	nb_obj = seen + 1 ;    /* 1 (fond) + seen (choix) */ 
	if (poplist)
		nb_obj += 5 ;       /* + 5 (ascenseur) */

	tree = (OBJECT*)malloc(sizeof(OBJECT)*(nb_obj));
	if (tree == NULL) return NULL;
	
	tree[0].ob_x=tree[0].ob_y=tree[0].ob_state=0;
	tree[0].ob_height = hcell*seen;
	tree[0].ob_type = G_BOX;
	/* tree[0].ob_tail d‚fini selon "poplist" un peu plus bas */
	tree[0].ob_next = -1;
	tree[0].ob_head = 1;
	tree[0].ob_spec.obspec.textmode = 0;
	i = (CONF(app)->poppatt & 0x100)?1:0;
	tree[0].ob_spec.obspec.interiorcol = (CONF(app)->popcolor<app.color)?CONF(app)->popcolor:WHITE;
	tree[0].ob_spec.obspec.fillpattern = (CONF(app)->poppatt & 0xFF);
	tree[0].ob_spec.obspec.framesize = -CONF(app)->popborder;
	tree[0].ob_spec.obspec.framecol = (CONF(app)->popfcolor<app.color)?CONF(app)->popfcolor:BLACK;
	tree[0].ob_flags = SHADOWED;

	/* Une boite peut etre 3D,
	 * AES : la couleur 3D sera activ‚ si le fond est blanc et le style a 1 */

	/* effet 3d ? */
	if( i) tree[0].ob_flags |= 0x0400;

	dy = 0;

	/* largeur max du texte */
	for( dum = 0; dum<size; dum++)
		len_max = MAX( len_max, (int)strlen( ptxt[dum]));
	len_max += 3;  /* 2 " " avant, et 1 aprŠs */
	width = len_max * wcell;
	
	for( i = 1; i<=seen; i++) {
		tree[i].ob_type = G_STRING;
		tree[i].ob_x = 0;
		tree[i].ob_y = dy;
		tree[i].ob_width = width;
		tree[i].ob_height = hcell;
		tree[i].ob_tail = -1;
		tree[i].ob_next = i+1;
		tree[i].ob_head = -1;
		tree[i].ob_flags = SELECTABLE;
		tree[i].ob_state = 0;
		tree[i].ob_spec.free_string = malloc(len_max+1);
		dy += hcell;
	}
	if( poplist) {  /* on ajoute l'ascenseur vertical */
		/************ BG = BackGround : objet parent de l'ascenseur */
		tree[seen+ASC_BG].ob_next   = 0;
		tree[seen+ASC_BG].ob_head   = seen + ASC_UP;
		tree[seen+ASC_BG].ob_tail   = seen + ASC_PG;
		tree[seen+ASC_BG].ob_type   = G_IBOX;
		tree[seen+ASC_BG].ob_flags  = TOUCHEXIT;
		tree[seen+ASC_BG].ob_state  = NORMAL;
		tree[seen+ASC_BG].ob_spec.index   = /*0x19179L*/ 0x11179L;
		tree[seen+ASC_BG].ob_x      = width ;
		tree[seen+ASC_BG].ob_y      = -2 /*-1*/ ;
		tree[seen+ASC_BG].ob_width  = 20 /*19*/;
		tree[seen+ASC_BG].ob_height = tree[0].ob_height +3 /*+ 2*/;
		/************ UP = bouton "flŠche vers le haut" */
		tree[seen+ASC_UP].ob_next   = seen + ASC_DW;
		tree[seen+ASC_UP].ob_head   = -1;
		tree[seen+ASC_UP].ob_tail   = -1;
		tree[seen+ASC_UP].ob_type   = G_BOXCHAR | (SLIDEPART << 8);
		tree[seen+ASC_UP].ob_flags  = SELECTABLE;
		tree[seen+ASC_UP].ob_state  = DRAW3D;
		tree[seen+ASC_UP].ob_spec.index   = 0x1021100L /*0x1FF1100L*/;
		tree[seen+ASC_UP].ob_x      = 0 /*2*/ ;
		tree[seen+ASC_UP].ob_y      = 0 /*1*/ ;
		tree[seen+ASC_UP].ob_width  = 20 /*16*/ ;
		tree[seen+ASC_UP].ob_height = 20 /*17*/ ;
		uo_set_boxchar (tree, seen+ASC_UP, &uo[1]);
		/************ DW = bouton "flŠche vers le bas" */
		tree[seen+ASC_DW].ob_next   = seen + ASC_PG;
		tree[seen+ASC_DW].ob_head   = -1;
		tree[seen+ASC_DW].ob_tail   = -1;
		tree[seen+ASC_DW].ob_type   = G_BOXCHAR | (SLIDEPART << 8);
		tree[seen+ASC_DW].ob_flags  = SELECTABLE;
		tree[seen+ASC_DW].ob_state  = DRAW3D;
		tree[seen+ASC_DW].ob_spec.index   = 0x2021100L /*0x2FF1100L*/;
		tree[seen+ASC_DW].ob_x      = 0 /*2*/ ;
		tree[seen+ASC_DW].ob_y      = tree[seen+ASC_BG].ob_height - 20 /*18*/ ;
		tree[seen+ASC_DW].ob_width  = 20 /*16*/ ;
		tree[seen+ASC_DW].ob_height = 20 /*17*/ ;
		uo_set_boxchar (tree, seen+ASC_DW, &uo[2]);
		/************ PG = fond du slider pour PAGE_UP/PAGE_DW */
		tree[seen+ASC_PG].ob_next   = seen + ASC_BG;
		tree[seen+ASC_PG].ob_head   = seen + ASC_SL;
		tree[seen+ASC_PG].ob_tail   = seen + ASC_SL;
		tree[seen+ASC_PG].ob_type   = G_BOX;
		tree[seen+ASC_PG].ob_flags  = NONE;
		tree[seen+ASC_PG].ob_state  = NORMAL;
		tree[seen+ASC_PG].ob_spec.index   = app.nplanes<4 ? 0x019131L : 0x009179L /*0xFF9131L : 0xFF9179L*/;
		tree[seen+ASC_PG].ob_x      = 0 /*2*/ ;
		tree[seen+ASC_PG].ob_y      = tree[seen+ASC_UP].ob_height + tree[seen+ASC_UP].ob_y - 1 /*+ 1*/;
		tree[seen+ASC_PG].ob_width  = 20 /*16*/;
		tree[seen+ASC_PG].ob_height = tree[seen+ASC_DW].ob_y - tree[seen+ASC_PG].ob_y + 1 /*- 1*/;
		/************ SL = le slider */
		tree[seen+ASC_SL].ob_next   = seen + ASC_PG;
		tree[seen+ASC_SL].ob_head   = -1;
		tree[seen+ASC_SL].ob_tail   = -1;
		tree[seen+ASC_SL].ob_type   = G_BOXCHAR | (SLIDEPART << 8);
		tree[seen+ASC_SL].ob_flags  = SELECTABLE;
		tree[seen+ASC_SL].ob_state  = DRAW3D;
		tree[seen+ASC_SL].ob_spec.index   = 0x021100L /*0xFF1100L*/;
		tree[seen+ASC_SL].ob_x      = 0 ;
		tree[seen+ASC_SL].ob_y      = 0 ;
		tree[seen+ASC_SL].ob_width  = tree[seen+ASC_PG].ob_width;
		tree[seen+ASC_SL].ob_height = 20 /*16*/;
		uo_set_boxchar (tree, seen+ASC_SL, &uo[3]);

		tree[0].ob_tail = seen+ASC_BG;  /* 0=fond 1=premier ‚l‚ment etc ... */
		tree[0].ob_width = width + tree[seen+ASC_BG].ob_width - 1;
	} else {
		tree[seen].ob_next = 0; /* le dernier fils pointe vers le pŠre */
		tree[0].ob_tail = seen;  /* 0=fond 1=premier ‚l‚ment etc ... */
		tree[0].ob_width = width ;
	}
	tree[nb_obj-1].ob_flags |= LASTOB;
	uo_set_box (tree, 0, &uo[0]);

#if POPDEBUG
	Fh=Fcreate("txt2obj.log",0);
	sprintf(tmpstr,"no|next|head|tail|type|flag|stat|  spec  | x | y | w | h\n");
	Fwrite(Fh,strlen(tmpstr),tmpstr);
	for (i=0; i<nb_obj;i++) {
		sprintf(tmpstr,"%2d|%4d|%4d|%4d|%4d|%4x|%4x|%8lx|%3d|%3d|%3d|%3d\n",
		i,tree[i].ob_next,tree[i].ob_head,tree[i].ob_tail,tree[i].ob_type,
		tree[i].ob_flags,tree[i].ob_state,tree[i].ob_spec.index,
		tree[i].ob_x,tree[i].ob_y,tree[i].ob_width,tree[i].ob_height);
		Fwrite(Fh,strlen(tmpstr),tmpstr);
	}
	Fclose(Fh);
#endif
	
/*	objc_extended(tree); */
	
	return tree;
#undef wcell
#undef hcell
#undef len_max
}

/*
 *	Le mode P_EXIT ne sert plus a rien
 *	Les modes P_RGHT et P_WNDW sont OK
 *	Le mode P_LIST est encore beta
 */
 
int MenuPopUp( void *list, int _x, int _y, 
			   int size, int seen, int item, int mode) {
	OBJECT *menu;
	MFDB fond;
	WINDOW *win, *front;
	int res,key;
	INT16 dum, button;
	INT16 xclip, yclip, wclip, hclip;
	INT16 xtclip, ytclip, wtclip, htclip;  /* zone "T"exte, sans l'ascenseur */
	INT16 x = _x ;
	INT16 y = _y ;
	INT16 x16,y16;
	EVNTvar save;
	int last_choice = -1;
	int new_choice;
	/***** ajout Arnaud *******/
	int popwind = 0;  /* par d‚faut, le pop n'est pas en fenˆtre */
	int poplist=0;  /* TRUE pour les P_LIST avec un ascenseur vertical … g‚rer */
	int max;
	int ypos=0, ypos_max;  /* ascenseur vertical si poplist */
	INT16 attrib[10];
#define HCELL attrib[9]
	int len_max = 0;
	
	/* calcul des paramŠtres du mode P_LIST */

	if( mode & P_LIST) {
		/* le vst_height est n‚cessaire */
		vst_height( app.aeshdl, 13, &dum, &dum, &dum, &dum);
		vqt_attributes( app.aeshdl, attrib);
		max = app.h/HCELL - 1;

		/* bornage de "seen" */
		if( seen < 1)        /* -1 ou 0 pour prendre la valeur par d‚faut */
			seen = 16;        /* valeur par d‚faut */
		else if( seen < 6)   /* hauteur mini d'un poplist */
			seen = 6;         /* pour afficher correctement les ascenseurs */
		if( seen > max)      /* hauteur max pour rentrer … l'‚cran */
			seen = max;      /* et donc, … ne pas d‚passer */
		/* affectation de poplist */
		poplist = seen < size;
		/* seen contiendra le nb de choix … r‚ellement afficher */
		if( seen > size) seen = size;
		/* init de la position de l'ascenseur vertical */
		ypos_max = size - seen + 1;
		ypos = 0;
	}
	
	/* choix OBJECT ou liste */
	if( mode & P_LIST)
		menu = txt2objc( list, size, seen, poplist, attrib, &len_max);
	else
		menu = (OBJECT*)list;
	if( menu == NULL)
		return -1;		/* Fin si plus de m‚moire */

	/* mode pr‚emptif ? */
	if( CONF(app)->popwind == TRUE) {
		/* si l'‚cran n'est pas bloqu‚ par un formulaire */
		/* "pas en fenetre", il ne faut pas positionner   */
		/* popwind … TRUE : c'est incompatible !         */
		/* bon ben, yapuka ajouter le test.............  */
		popwind = TRUE;
	}
#if 1
	if( CONF(app)->popwind != DEFVAL) {
		if( CONF(app)->popwind == TRUE)
			mode |= P_WNDW;
		else
			mode &= ~P_WNDW;
	}
#endif

	/*
	 * position du popup 
	 */

	/* cas particulier de x=y=-1 : il faut positionner 
	 * le popup sous la souris, centr‚ sur la 1ere entr‚e
	 * du menu 
	 */
	if( (x==-1) && (y==-1) ) {
		graf_mkstate( &x, &y, &dum, &dum);
		x -= (menu[1].ob_width  >> 1);
		y -= (menu[1].ob_height >> 1);
	}

	if( item != -1) {
		if (poplist) {
			/* d‚placer ‚ventuellement le pop et l'ascenseur */
			/* ‡a peut devenir compliqu‚... */
			/* par d‚faut, on centre le pop et on ajuste */
			/* l'ascenseur pour que ca colle */
			ypos = item - (seen >> 1) -1;
			y -= (menu[1].ob_height) * (seen >> 1);
			/* si ypos sort des limites [0..ypos_max[ */
			/* et bien... on corrige */
			if (ypos < 0) {
				y += (menu[1].ob_height) * (-ypos);
				ypos = 0;
			}
			if (ypos >= ypos_max) {
				y -= (menu[1].ob_height) * (ypos-ypos_max+1);
				ypos = ypos_max-1;
			}
		} else {
			objc_offset( menu, item, &xclip, &yclip);
			if(mode & P_CHCK) menu[item].ob_state |= CHECKED;
			x += (menu->ob_x - xclip);
			y += (menu->ob_y - yclip);
		}
	}
	
	/* a partir d'ici, item est le numero de l'entr‚e */
	/* qui doit ˆtre check‚e */
	if ((item <= 0) || !(mode & P_CHCK))
		item = -1;

	if( x+menu->ob_width>app.x+app.w)
		menu -> ob_x = app.x+app.w-menu->ob_width-1;
	else
		menu -> ob_x = MAX(x,app.x+3);
	if( y+menu->ob_height>app.y+app.h)
		menu -> ob_y = app.y+app.h-menu->ob_height-1;
	else
		menu -> ob_y = MAX(y,app.y+3);

	xclip=menu->ob_x-3;
	yclip=menu->ob_y-3;
	wclip=menu->ob_width+6;
	hclip=menu->ob_height+6;

	if (poplist) {
		xtclip=menu->ob_x + menu[1].ob_x;
		ytclip=menu->ob_y;
		wtclip=menu[1].ob_width;
		htclip=menu->ob_height;
	}
	
	/* maintenant que ypos est parfaitement d‚fini, */
	/* on peut initialiser les free_strings de menu */
	if (mode & P_LIST)
		str2menu(menu, ypos, seen, list, len_max, item);
	if (poplist)
		pop_udslider(menu,ypos,size,seen);

	/* afficher le popup */
	if( popwind) {
		front = wglb.appfront;
		win = WindCreate( 0, app.x, app.y, app.w, app.h);
		win -> status &= ~WS_GROW;
		if( win == NULL) {
			if( mode & P_LIST)
			free( menu);
			return -1;
		}
		MenuDisable();
		WindSet( win, WF_BEVENT, B_MODAL, 0, 0, 0);
		win->w_min = win->h_min = 1;
		WindOpen( win, menu->ob_x , menu->ob_y, menu->ob_width, menu->ob_height);
		EvntAttach( win, WM_REDRAW, pop_drw);
		DataAttach( win, WD_WPOP, menu);
	} else {
		if( mode & P_RDRW)	/* j'ai invers‚ par rapport … la doc car c'est pas logique */
			form_dial( FMD_START, 0, 0, 0, 0, xclip, yclip, wclip, hclip);
		else
			w_get_bkgr( xclip, yclip, wclip, hclip, &fond);
		objc_draw( menu, 0, MAX_DEPTH, xclip, yclip, wclip, hclip);
		while( !wind_update (BEG_MCTRL));
	}

	
	/* Gestion des ‚venements par EvntMulti() */
	
	/* initialiser les paramŠtres MU_BUTTON */
	graf_mkstate( &evnt.mx, &evnt.my, &button, &dum);
	save = evnt;

	/* Modif Arnaud, qui rend obsolete l'option P_RGHT : a tester */
	if( button) {
		/* l'‚v‚nement attendu est le relach‚ du "button" */
		evnt.bmask = button ;
		evnt.bstate = 0;
		evnt.bclick = 1;
	} else {
		/* l'‚vŠnement attendu est l'appuie sur 1 button quelconque */
		evnt.bclick = 258;
		evnt.bmask  = 3;
		evnt.bstate = 0;
	}
	
	/* initialiser les paramŠtres pour MU_M1 */
	last_choice = objc_find( menu, 0, 4 /*2*/, evnt.mx, evnt.my);
	if( last_choice == -1) {
		last_choice = 0;
		evnt.m1_flag = 0;
	} else
		evnt.m1_flag = 1;
	
	if( last_choice != -1 &&
		!(menu[last_choice].ob_flags & SELECTABLE)) {
		evnt.m1_x = evnt.mx-1;
		evnt.m1_y = evnt.my-1;
		evnt.m1_w = 2;
		evnt.m1_h = 2;
	} else {
		objc_offset( menu, last_choice, &x, &y);
		evnt.m1_x = x;
		evnt.m1_y = y;
		evnt.m1_w = menu[last_choice].ob_width;
		evnt.m1_h = menu[last_choice].ob_height;
	}
	if( menu[last_choice].ob_flags & SELECTABLE) {
		if ( (poplist) && (last_choice > seen) )  /* sur l'ascenseur */
			; /* ne rien faire */
		else if( popwind)
			ObjcWindChange( win, menu, last_choice, xclip, yclip, wclip, hclip, SELECTED);
		else
			objc_change( menu, last_choice, 0, xclip, yclip, wclip, hclip, SELECTED, 1);
	}
	key = 0;
	do {
		if( popwind)
			res = EvntWindom( MU_BUTTON|MU_KEYBD|MU_M1|MU_MESAG);
		else
#ifdef __GEMLIB__
			res = evnt_multi( 
					MU_BUTTON|MU_KEYBD|MU_M1,
					evnt.bclick, evnt.bmask, evnt.bstate,
					evnt.m1_flag, evnt.m1_x, evnt.m1_y, evnt.m1_w, evnt.m1_h,
					0, 0, 0, 0, 0,
					evnt.buff,
					0L,
					&evnt.mx, &evnt.my,
					&dum, &dum, &evnt.keybd, &dum);
#else  /* __GEMLIB__ */
			res = evnt_multi( 
					MU_BUTTON|MU_KEYBD|MU_M1,
					evnt.bclick, evnt.bmask, evnt.bstate,
					evnt.m1_flag, evnt.m1_x, evnt.m1_y, evnt.m1_w, evnt.m1_h,
					0, 0, 0, 0, 0,
					evnt.buff,
					0, 0,
					&evnt.mx, &evnt.my,
					&dum, &dum, &evnt.keybd, &dum);
#endif /* __GEMLIB__ */

		if( res & MU_KEYBD) {
			switch( evnt.keybd>>8) {
			case 72: /* Haut */
				break;
			case 80: /* Bas */
				if ((poplist) && (last_choice==seen))
				{
					if (ypos < ypos_max-1)
					{
						ypos ++ ;
						/* recaluler les objets de menu */
						str2menu(menu, ypos, seen, list, len_max, item);
						/* recalculer la position du slider */
						pop_udslider(menu,ypos,size,seen);
						/* redraw  */
						if (popwind) {
							ObjcWindDraw(win,menu, 0, MAX_DEPTH, xtclip, ytclip, wtclip, htclip);
							ObjcWindDraw(win,menu, seen+ASC_PG, MAX_DEPTH, xclip, yclip, wclip, hclip);
						} else {
							objc_draw( menu, 0, MAX_DEPTH, xtclip, ytclip, wtclip, htclip);
							objc_draw( menu, seen+ASC_PG, MAX_DEPTH, xclip, yclip, wclip, hclip);
						}
					}
					new_choice = seen ;
				} else 
					new_choice = obj_fd_flag( menu, MAX(last_choice,0)+1, SELECTABLE);
				key = 1;
				evnt.m1_flag = 1;
#ifdef __GEMLIB__
				graf_mkstate( &x16, &y16, &dum, &dum);
				evnt.m1_x = x16 - 2;
				evnt.m1_y = y16 - 2;
#else
				graf_mkstate( &evnt.m1_x, &evnt.m1_y, &dum, &dum);
				evnt.m1_x -=2;
				evnt.m1_y -=2;
#endif
				evnt.m1_w = evnt.m1_h = 4;
				goto GO_M1;
			case 28:
			case 114:
				res = MU_BUTTON;
				break;
			}
		}
		if( res & MU_M1) {
			key = 0;
			new_choice = objc_find( menu, 0, 4 /*2*/, evnt.mx, evnt.my);
GO_M1:
			if( last_choice != new_choice) {
				graf_mouse( M_OFF, 0L);
				if( last_choice != -1 && menu[ last_choice].ob_flags & SELECTABLE
					&& !(menu[ last_choice].ob_state & DISABLED))
				{
					if ( (poplist) && (last_choice > seen) )  /* sur l'ascenseur */
						; /* ne rien faire */
					else if( popwind)
						ObjcWindChange( win, menu, last_choice, xclip, yclip, wclip, hclip, NORMAL);
					else
						objc_change( menu, last_choice, 0, xclip, yclip, wclip, hclip, NORMAL, 1);
				}
				last_choice = new_choice;
				if( new_choice != -1 && menu[ new_choice].ob_flags & SELECTABLE 
					&& !(menu[ new_choice].ob_state & DISABLED))
				{
					if ( (poplist) && (new_choice > seen) )  /* sur l'ascenseur */
						; /* ne rien faire */
					else if( popwind)
						ObjcWindChange( win, menu, new_choice, xclip, yclip, wclip, hclip, SELECTABLE);
		    		else
		    			objc_change( menu, new_choice, 0, xclip, yclip, wclip, hclip, SELECTED, 1);
				}
				
				/* choisir le nouveau rectangle M1 */
				if( key == 0) {
				 	if( new_choice == -1) { /* hors formulaire */
				 		dum = 0;
				 		evnt.m1_flag = 0;
				 	} else {				/* dans formulaire */
				 		dum = new_choice;
				 		evnt.m1_flag = 1;
				 	}
				 	if( new_choice != -1 &&		/* dans formulaire & objet non selectionnable */
				 		!(menu[new_choice].ob_flags & SELECTABLE) ) {
				 		evnt.m1_x = evnt.mx-1;
						evnt.m1_y = evnt.my-1;
						evnt.m1_w = 2;
						evnt.m1_h = 2;
				 	} else {
				 		objc_offset( menu, dum, &x, &y);
						evnt.m1_x = x;
						evnt.m1_y = y;
						evnt.m1_w = menu[dum].ob_width;
						evnt.m1_h = menu[dum].ob_height;
					}
				}
				graf_mouse( M_ON, 0L);
			}
		}
		if( res & MU_BUTTON) {
			/* si on a MU_KEYBD, new_choice a d‚j… ‚t‚ calcul‚ */
			/* et ne correspond pas … la position de la souris */
			/* il ne faut donc pas faire de objc_find() !!!    */
			if (! (res & MU_KEYBD) )
				new_choice = objc_find( menu, 0, 4 /*2*/, evnt.mx, evnt.my);
			if ((poplist) && (!button) && (new_choice>seen))  /* clic sur l'ascenseur */
			{
				int decal=0;  /* dcalage … appliquer sur ypos ou 0 */
				INT16 x, y;
				int new_ypos;
				EVNTvar save;
				int e;
				int obj_asc_sele; /* objet du formulaire s‚lectionn‚ */
				
				/* calcul de decal */
				switch( new_choice - seen) {
					case ASC_UP : decal = -1; break;
					case ASC_DW : decal = 1;  break;
					case ASC_PG : 
						objc_offset(menu,seen+ASC_SL,&x,&y);
						decal = (evnt.my < y) ? -seen : seen;
						break;
					case ASC_SL : decal = 0;
				}
				
				switch (new_choice - seen) {
					case ASC_UP : 
					case ASC_DW :
					case ASC_SL :
						obj_asc_sele = new_choice; break;
					default :
						obj_asc_sele = 0;
				}
				if( obj_asc_sele) {
					if( popwind) {
						ObjcWindChange( win, menu, obj_asc_sele, xclip, yclip, wclip, hclip, SELECTED);
						ObjcWindDraw( win,menu, obj_asc_sele, MAX_DEPTH, xclip, yclip, wclip, hclip);
					} else {
						objc_change( menu, obj_asc_sele, 0, xclip, yclip, wclip, hclip, SELECTED, 1);
						objc_draw( menu, obj_asc_sele, MAX_DEPTH, xclip, yclip, wclip, hclip);
					}
				}
					
				if( decal) {  /* gestion d'un evnt LINE/PAGE_UP/DW */
					save = evnt;
					evnt.bmask  = 1 ;
					evnt.bstate = 0;
					evnt.bclick = 1;
#define TEMPO1        460
#define TEMPO2        20
					evnt.timer = TEMPO1;
					do {
						new_ypos = ypos + decal;
						if (new_ypos < 0) new_ypos = 0;
						if (new_ypos > ypos_max-1) new_ypos = ypos_max-1;
						if (new_ypos != ypos) {
							ypos = new_ypos;
							/* recaluler les objets de menu */
							str2menu(menu, ypos, seen, list, len_max, item);
							/* recalculer la position du slider */
							pop_udslider(menu,ypos,size,seen);
							/* redraw  */
							if (popwind) {
								ObjcWindDraw(win,menu, 0, MAX_DEPTH, xtclip, ytclip, wtclip, htclip);
								ObjcWindDraw(win,menu, seen+ASC_PG, MAX_DEPTH, xclip, yclip, wclip, hclip);
							} else {
								objc_draw( menu, 0, MAX_DEPTH, xtclip, ytclip, wtclip, htclip);
								objc_draw( menu, seen+ASC_PG, MAX_DEPTH, xclip, yclip, wclip, hclip);
							}
						}
					
						/* attente avant de reboucler */
						if( popwind)
							e = EvntWindom( MU_BUTTON|MU_TIMER);
						else
#ifdef __GEMLIB__
							e = evnt_multi( 
							      MU_BUTTON|MU_TIMER,
									evnt.bclick, evnt.bmask, evnt.bstate,
									0, 0, 0, 0, 0,
									0, 0, 0, 0, 0,
									evnt.buff,
									evnt.timer,
									&evnt.mx, &evnt.my,
									&dum, &dum, &evnt.keybd, &dum);
#else
							e = evnt_multi( 
							      MU_BUTTON|MU_TIMER,
									evnt.bclick, evnt.bmask, evnt.bstate,
									0, 0, 0, 0, 0,
									0, 0, 0, 0, 0,
									evnt.buff,
									(int) evnt.timer, (int)(evnt.timer >> 16),
									&evnt.mx, &evnt.my,
									&dum, &dum, &evnt.keybd, &dum);
#endif
						evnt.timer = TEMPO2;
					} while ( ! (e & MU_BUTTON) ) ;
					evnt = save;
				} else { /* gestion d'un SLIDER temps r‚els */
					/* decal est maintenant le decalage entre la */
					/* position du slider et la position de la souris */
					objc_offset(menu,seen+ASC_SL,&x,&y);
					decal = evnt.my - y;
					objc_offset(menu,seen+ASC_PG,&x,&y);
										
					do {
						/* ‚valuation de new_ypos */
						new_ypos = evnt.my - decal - y;  /* futur ob_y du slider */
						new_ypos = ((long)((long)((long)new_ypos * (long)size)<<1) + (long)menu[seen+ASC_PG].ob_height) / (long)(menu[seen+ASC_PG].ob_height << 1);
						if (new_ypos < 0) new_ypos = 0;
						if (new_ypos > ypos_max-1) new_ypos = ypos_max-1;
						if (new_ypos != ypos)
						{
							ypos = new_ypos;
							/* recaluler les objets de menu */
							str2menu(menu, ypos, seen, list, len_max, item);
							/* recalculer la position du slider */
							pop_udslider(menu,ypos,size,seen);
							/* redraw  */
							if (popwind) {
								ObjcWindDraw(win,menu, 0, MAX_DEPTH, xtclip, ytclip, wtclip, htclip);
								ObjcWindDraw(win,menu, seen+ASC_PG, MAX_DEPTH, xclip, yclip, wclip, hclip);
							} else {
								objc_draw( menu, 0, MAX_DEPTH, xtclip, ytclip, wtclip, htclip);
								objc_draw( menu, seen+ASC_PG, MAX_DEPTH, xclip, yclip, wclip, hclip);
							}
						}
						/* et on reboucle tant que le bouton est appuy‚ */
						graf_mkstate(&evnt.mx,&evnt.my,&evnt.mbut,&dum);
					} while (evnt.mbut) ;
				}
				if (obj_asc_sele) {
					if( popwind) {
						ObjcWindChange( win, menu, obj_asc_sele, xclip, yclip, wclip, hclip, NORMAL);
						ObjcWindDraw(win,menu, obj_asc_sele, MAX_DEPTH, xclip, yclip, wclip, hclip);
					} else {
						objc_change( menu, obj_asc_sele, 0, xclip, yclip, wclip, hclip, NORMAL, 1);
						objc_draw( menu, obj_asc_sele, MAX_DEPTH, xclip, yclip, wclip, hclip);
					}
				}
				res &= ~MU_BUTTON ;
			}
			/* si on vient de cliquer sur une entr‚e du menu */
			/* on continu … gerer le pop jusqu'au relache du bouton */
			if( (new_choice > 0) && (new_choice <= seen)  && 
			    (!(res & MU_KEYBD)) && !button) {
				/* l'‚v‚nement attendu est le relach‚ du "button" */
				button = 1;
				evnt.bmask = button ;
				evnt.bstate = 0;
				evnt.bclick = 1;
				res &= ~MU_BUTTON ;
			}
		}
		
	} while( !(res & MU_BUTTON));

	/* fin */

	/* enlever le popup */
	if( popwind) {
		WindClose( win);
		WindDelete( win);
		MenuEnable();
/*		EvntWindom(MU_MESAG); */
		wglb.appfront = front; /* cette bidouille traduit une mauvaise
							      gestion de la lib de appfront au niveau
							      de WindClose() */
	} else {
		wind_update (END_MCTRL);
		if(mode & P_RDRW)
			form_dial( FMD_FINISH, 0, 0, 0, 0, xclip, yclip, wclip, hclip);
		else
			w_put_bkgr( xclip, yclip, wclip, hclip, &fond);
	}

	evnt = save;

	if( new_choice != -1 && menu[ new_choice].ob_flags & SELECTABLE) {
		menu[ new_choice].ob_state &= ~SELECTED;
		if( menu[ new_choice].ob_state & DISABLED)
			new_choice = -1;
	}	

	if( mode & P_LIST) {
/*		objc_extfree(menu); */
		for( dum = 1; dum <= seen; dum++)
			free(menu[dum].ob_spec.free_string);
		free( menu);
	}

	if (poplist) {
		if (new_choice < 0)
			return new_choice;
		else
			return new_choice + ypos;
	}
	
	return new_choice;
}

