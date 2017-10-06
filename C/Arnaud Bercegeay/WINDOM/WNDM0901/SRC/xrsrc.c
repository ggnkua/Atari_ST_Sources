/*
 *    WinDom, Librairie GEM par Dominique B‚r‚ziat
 *    copyright 1997/2000
 *
 *    module: xrsrc.c
 *    description: fonctions ressources extendues
 */

#ifdef MODIF_XEDIT
#include <string.h>
#endif
#include <stddef.h>
#include <stdlib.h>
#include "globals.h"
#include "userdef.h"
#include "cicon.h"
#include "wsystem.rh"
#include "wsystem.rsh"

/* Variables locales et privees
 */

static XRSRCFIX     __iconsys;        /* fixe les icones couleurs internes */

/*    Fonctions externes
 */
WORD __CDECL ub_button    ( PARMBLK *pblk);
WORD __CDECL ub_boxtitle  ( PARMBLK *pblk);
WORD __CDECL ub_xboxchar  ( PARMBLK *pblk);
WORD __CDECL ub_onglet    ( PARMBLK *pblk);
WORD __CDECL ub_boxcircle ( PARMBLK *pblk);
WORD __CDECL ub_but3D     ( PARMBLK *pblk);
WORD __CDECL ub_ulinetext ( PARMBLK *pblk);
WORD __CDECL ub_popuptext ( PARMBLK *pblk);
WORD __CDECL user_draw    ( PARMBLK *pblk);
WORD __CDECL ub_mntitle   ( PARMBLK *pblk);
WORD __CDECL ub_dialmover ( PARMBLK *pblk);
WORD __CDECL ub_editable  ( PARMBLK *pblk);
WORD __CDECL ub_but3d     ( PARMBLK *pblk);
WORD __CDECL ub_multiligne( PARMBLK *pblk);
WORD __CDECL ub_box3d     ( PARMBLK *pblk);
WORD __CDECL ub_ibox3d    ( PARMBLK *pblk);
WORD __CDECL ub_boxchar3d ( PARMBLK *pblk);
WORD __CDECL ub_boxtext3d ( PARMBLK *pblk);

#ifdef MODIF_XEDIT
size_t realloc_xedit( size_t old, size_t len);
#endif

#define        FL3DMASK    0x0600    /* 3D objects AES 3.4    */

/*
 *    TEST : realigne les objects 3D pour
 *           le bug du clippage
 *         mode = 1 : aligne l'objet
 *                0 : desaligne
 *    Il faut penser aussi au OUTLINED, SHADOW et aux
 *    objets a bords variables (boxchar, ...).
 */

void align_obj3d( OBJECT *tree, int index, int mode) {
    int border, e;

    /* notation: border < 0 : outside border */
    /*           border > 0 : inside  border */

    switch (tree[index].ob_type & 0xFF)
    {
        case G_BOXTEXT :
            border = tree[index].ob_spec.tedinfo->te_thickness & 0x00FF;
            if (border >= 128) border = border - 256 ;
            break;
        case G_BOX :
        case G_IBOX:
        case G_BOXCHAR:
            border = tree[index].ob_spec.obspec.framesize;
            break;
        default:
            border = -1;
            if( tree[index].ob_flags & EXIT) border --;
            if( tree[index].ob_flags & DEFAULT) border --;
    }

    /* le probleme ne concerne que les cadres … bord ext‚rieurs  */
    /* si l'objet … traiter … les bords vers l'int‚rieur, il n'y */
    /* … rien … faire (pourquoi ? explication juste en dessous)  */
    if (border>=0) return;
    
    /* Voici maintenant ce que vont subir les objets … bord   */
    /* "ext‚rieurs" : lors de l'installation (mode!=0), les   */
    /* dimensions de l'objets sont agrandies pour englober    */
    /* les bordures, et les objets fils sont d‚cal‚s d'autant */
    /* par rapport … cet objet pŠre pour qu'ils conservent    */
    /* la mˆme position absolue dans le formulaire.           */
    /* SUBTILITE: le champ "border" est cependant conserv‚    */
    /* n‚gatif. Les routines userdef devront donc traiter les */
    /* bords ext‚rieurs comme ‚tant des bords int‚rieurs !    */
    /* RESTAURATION: avec mode=0, les bords ext‚rieurs sont   */
    /* consid‚r‚s comme des bords int‚rieurs car ils ont      */
    /* subits la transformation d‚crite au dessus. Pour       */
    /* revenir … la configuration initiale, il suffit de      */
    /* remettre en place les anciennes coordonn‚es de l'objet */
    /* et de restaurer les positon ob_x/y des objets fils.    */
    
    if( mode == 0) mode =  1;
    else           mode = -1;

    tree[index].ob_x -= (border*mode);
    tree[index].ob_y -= (border*mode);
    tree[index].ob_width  += ((border<<1)*mode);
    tree[index].ob_height += ((border<<1)*mode);

    /* on modifie d'autant le ob_x/y des enfants */
    for (e=tree[index].ob_head; (e>=0) && (e!=index); e=tree[e].ob_next) {
        tree[e].ob_x += (border*mode);
        tree[e].ob_y += (border*mode);
    }
}

/*
 *    Attribution de routine userdefs
 *        -> Utilisees par RsrcXtype() et les frames
 */

void init_type( OBJECT *tree, int index, void *func, int extype) {
    USERBLK *user;

    user = (USERBLK *)malloc( sizeof(USERBLK));
    user -> ub_parm = (long)malloc( sizeof(W_PARM));
    user -> ub_code = func;
    ((W_PARM*)user -> ub_parm) -> wp_type = tree[index].ob_type;
    ((W_PARM*)user -> ub_parm) -> wp_spec = tree[index].ob_spec.index;
    tree[index].ob_spec.userblk = user;
    tree[index].ob_type = G_USERDEF | (extype<<8);
}

void free_type( OBJECT *tree, int index) {
    long addr;
    int type;

    type = ((W_PARM*)tree[index].ob_spec.userblk->ub_parm)->wp_type;
    addr = ((W_PARM*)tree[index].ob_spec.userblk->ub_parm)->wp_spec;
    free( (void*)tree[index].ob_spec.userblk->ub_parm);
    free( tree[index].ob_spec.userblk);
    tree[index].ob_spec.index = addr;
    tree[index].ob_type = type;
}

#ifdef MODIF_XEDIT

/* 
 * Mˆme fonction que init_type() mais concerne les objets XEDIT
 */

void init_xedit( OBJECT *tree, int index) {
	USERBLK* user = (USERBLK *)malloc( sizeof(USERBLK));
	W_XEDIT* xedit = (W_XEDIT*)malloc( sizeof(W_XEDIT));
	
	user -> ub_parm = (long)xedit;
	user -> ub_code = ub_editable;

	xedit -> size = (int)realloc_xedit( 0, strlen(tree[index].ob_spec.tedinfo->te_ptext)+1);
	xedit -> line = malloc( xedit->size*sizeof(char));
	strcpy( xedit -> line, tree[index].ob_spec.tedinfo->te_ptext);
	xedit -> tedinfo = tree[index].ob_spec.tedinfo;
	xedit -> pos = 0;
	xedit -> curs = xedit -> blcbeg = 0;
	xedit -> flags = 0;
	xedit -> wp_type = tree[index].ob_type;
	tree[index].ob_spec.userblk = user;
	tree[index].ob_type = G_USERDEF | (XEDIT<<8);
}

/* 
 * Mˆme fonction que free_type() mais concerne les objets XEDIT
 *	peut-etre on fera une recopie partielle du buffer de W_XEDIT
 *	dans le TEDINFO ...
 */

void free_xedit( OBJECT *tree, int index) {
	W_XEDIT *xedit;
	void *user;
	
	xedit = (W_XEDIT *)tree[index].ob_spec.userblk->ub_parm;
	user = tree[index].ob_spec.userblk;
	tree[index].ob_spec.tedinfo = xedit->tedinfo;
	tree[index].ob_type = xedit->wp_type;
	free( xedit);
	free( user);
}
#endif

/* les objets systemes sont definis
 * statiquement dans le fichier WSYSTEM.RSH
 * cette fonction permet au reste de la librarie
 * d'atteindre ces objets */

OBJECT *__xtype_trindex( int index) {
    return (rs_trindex[index]);
}

/*
 *    Interface avec WinDom
 */

/*
 *    Fixer les type etendus
 *    principe:
 *        le ob_spec pointe maintenant sur une structure USERBLK
 *        le type etendu vaut le type normal (on garde la valeur)
 *        le type normal vaut G_USERDEF
 *        ub_code pointe sur la nouvelle fonction
 *        ub_parm vaut null ou pointe sur du texte pour les
 *            objets contenant du texte
 */

static void objc_extended( int mode, OBJECT *tree) {
    register int index;
    int type, extype;
    int is_menu = 0;

    /* on ne traite pas les menus... trop dangereux ! */
    for (index=0; !(tree[index].ob_flags & LASTOB); index++) {
        if ( (tree[index].ob_type == G_TITLE) ||
             (tree[index].ob_type >> 8) == MENUTITLE )
            is_menu=1;
    }

    index = 0;
    do {
        type = tree[index].ob_type & 0x00FF;
        extype = tree[index].ob_type >> 8;
        if( type == G_USERDEF)
            continue;

        if (mode & 0x01) { /* fix extended type only if (mode & 0x01) */
	        switch( extype) {
	        case DCRBUTTON:
	            align_obj3d( tree, index, 1);
	            init_type( tree, index, ub_button, extype);
	            break;
	        case TITLEBOX:
	            init_type( tree, index, ub_boxtitle, extype);
	            break;
	        case UNDERLINE:
	            init_type( tree, index, ub_ulinetext, extype);
	            break;
	        case CIRCLEBUT:
	            init_type( tree, index, ub_boxcircle, extype);
	            break;
	        case ONGLET:
	            init_type( tree, index, ub_onglet, extype);
	            break;
	        case KPOPUPSTRG:
	            init_type( tree, index, ub_popuptext, extype);
	            break;
	        case SLIDEPART:
	            init_type( tree, index, ub_xboxchar, extype);
	            break;
	        case MENUTITLE:
	            init_type( tree, index, ub_mntitle, extype);
	            break;
	        case DIALMOVER:
	            init_type( tree, index, ub_dialmover, extype);
	            break;
#ifdef MODIF_XEDIT
	        case XEDIT:
	            init_xedit( tree, index);
	            break;
#endif
	        case XBOXLONGTEXT:
	            align_obj3d( tree, index, 1);
	            init_type( tree, index, ub_multiligne, XTEDINFO);
	            break;
	        }
	     }
	     
	     if ((mode & 0x02) && (extype==0)) {
            if (is_menu) 
                ;  /* ne rien faire... trop dangereux... */
            else if ((tree[ index].ob_state & DRAW3D) || (tree[ index].ob_flags & FL3DMASK)) {
                /* Transformation des objets 3D standards en userdef */
                switch( type) {
                case G_BUTTON:
                    align_obj3d( tree, index, 1);
                    init_type( tree, index, ub_but3d, XFREESTR);
                    break;
                case G_BOX:
                    align_obj3d( tree, index, 1);
                    init_type( tree, index, ub_box3d, XBFOBSPEC);
                    break;
                case G_IBOX:
                    align_obj3d( tree, index, 1);
                    init_type( tree, index, ub_ibox3d, XBFOBSPEC);
                    break;
                case G_BOXCHAR:
                    align_obj3d( tree, index, 1);
                    init_type( tree, index, ub_boxchar3d, XBFOBSPEC);
                    break;
                case G_BOXTEXT:
                	/* normalement, un objet G_BOXTEXT ne peut pas */
                	/* ˆtre ‚ditable (dans ce cas, c'est un FBOXTEXT) */
                	/* mais pour ˆtre sur... (anciennement MODIF_DOM) */
					if( !(tree[index].ob_flags & EDITABLE)) {
	                    align_obj3d( tree, index, 1);
    	                init_type( tree, index, ub_boxtext3d, XTEDINFO);
					}
                    break;
                }
                /* supression des flags 3d pour que l'AES ne fasse pas */
                /* des trucs 3d dans notre dos */
                tree[ index].ob_flags &= ~FL3DMASK;
            }
        }
/* DOM : J'ai un truc a dire la dessus */
#if 0 /* anciennement #if !( MODIF_ARNAUD ) */
        if( extype == 0 && type == G_BUTTON && tree[ index].ob_state & DRAW3D) {
            align_obj3d( tree, index, 1);
            init_type( tree, index, ub_but3D, 0);
        }
      /* Les boutons qui ont le drapeaux Draw3D sont des userdefs, c'est
       * pour la compatibilit‚ MyDial, mais bon c'est pas important car
       * c'est redondant avec le type 18. et il y a le mode 0x2 de
       * RsrcXtype()
       * Il faut donc changer la doc (tutorial)
       */
#endif
    } while( !(tree[index++].ob_flags & LASTOB));
}

static void objc_extfree( OBJECT *tree) {
    int index = 0;

    do {
        if( (tree[index].ob_type & 0x00FF) != G_USERDEF)
            continue;
        switch( (tree[index].ob_type >> 8) )
        {
        case DCRBUTTON:
        case XFREESTR:
        case XTEDINFO:
        case XBFOBSPEC:
            free_type( tree, index);
            align_obj3d( tree, index, 0);
            break;
        case TITLEBOX:
        case UNDERLINE:
        case CIRCLEBUT:
        case ONGLET:
        case KPOPUPSTRG:
        case SLIDEPART:
        case MENUTITLE:
        case DIALMOVER:
        /* case ... */
            free_type( tree, index);
            break;
#ifdef MODIF_XEDIT
		case XEDIT:
			free_xedit( tree, index);
#endif
        }
#if 0  /* !(MODIF_ARNAUD) */
        if( (tree[index].ob_type >> 8) == 0
            && (tree[index].ob_type & 0x00FF) == G_USERDEF
            && tree[ index].ob_state & DRAW3D )
        {
            free_type( tree, index);
            align_obj3d( tree, index, 0);
        }
#endif
    } while( !(tree[index++].ob_flags & LASTOB));
}

/*
 *   mode : fixe ou libŠre les objets AES "userdef"
 *   mode & 0x01 : fixe les types ‚tendus
 *   mode & 0x02 : fixe les objets 3D
 *   mode = 0    : libŠre les types ‚tendus et les objets 3D
 */

void RsrcXtype( int mode, OBJECT **trindex, int num_tree) {
    OBJECT *tree;
    int dum, num;
    static int init=0;

    /*    Fixer les icones couleurs systeme */
    if( (mode & 0x01) && (init==0) ) { /* 1er appel */
        for( dum=0; dum<NUM_OBS; rsrc_obfix( rs_object, dum++));
        RsrcFixCicon( rs_object, NUM_OBS, NUM_CIB, rgb_palette, &__iconsys);
    }
    if( (init==1) && !(mode & 0x01) )
        RsrcFreeCicon(  &__iconsys);

    if( mode & 0x01)
        init++;
    else
        init--;

    num = (trindex == NULL)?app.ntree:num_tree;
    for( dum = 0; dum < num; dum ++) {
        if( trindex == NULL)
            rsrc_gaddr( 0, dum, &tree);
        else
            tree = trindex[dum];
        if( mode)
            objc_extended( mode, tree);
        else
            objc_extfree( tree);
    }
}


/*
 *    Insertion d'une routine utilisateur
 */

int RsrcUserDraw( int mode, WINDOW *win, int index, void (*draw)( WINDOW *, PARMBLK *)) {
    USERBLK *user;
    USER_DRAW *udraw;
    OBJECT *tree = (mode == OC_FORM)?FORM(win):TOOL(win);

    user = (USERBLK *)malloc( sizeof(USERBLK));
    if( user == NULL) return -69;
    udraw = (USER_DRAW *)malloc(sizeof(USER_DRAW));
    if( udraw == NULL) {
        free( user);
        return -69;
    }
    udraw -> win  = win;
    udraw -> draw = draw;
    user->ub_code = user_draw;
    user->ub_parm = (long)udraw;
    tree[index].ob_type = G_USERDEF | (USERDRAW << 8);
    tree[index].ob_spec.userblk = user;
    return 0;
}


/* EOF */



