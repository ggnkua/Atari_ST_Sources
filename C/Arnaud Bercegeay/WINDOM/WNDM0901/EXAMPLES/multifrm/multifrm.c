/*
 *	Exemple de gestion de formulaire multiple
 *		Dominique B‚r‚ziat 1997
 */

#include <windom.h>
#include "multifrm.h"

/* #define OLD_WAY */

/*
 *	Pour utiliser les objets ‚tendues de look calepin, il faut attribuer
 *	aux boutons radio et aux fond des formulaires le type ‚tendu 16.
 *	Les fond de formulaires ne doivent pas ˆtre radio. Enfin les boutons 
 *	radios doivent ˆtre dessin‚ aprŠs les fond des formulaire (donc ils
 *	devraient avec un indx plus grand que ceux des fonds...).
 *	le bit FLAG8 des ‚tats des objets double la tailles des cadres. Enfin
 *	le bit Draw3D est pris en compte.
 */

/*
 *  OLD WAY
 *  cet algo utilise une hypothŠse les boutons qui d‚clenchent 
 *  l'apparition du formulaire qui leurs correspondent sont RADIO
 *  et leurs index se suivent (cela permet de simplifier les choses)
 */

#ifdef OLD_WAY
void formFORM1( WINDOW *win) {
	static int show = FOND1;
	int bckgrd[] = {FOND1, FOND2, FOND3 /*, etc ...*/};	/* attribue un fond de 
														   formulaire a un bouton */
	int res;
	
	switch( res=evnt.buff[4]) {
	/* ici on gŠre le choix des formulaires */
	case BUT1:
	case BUT2:
	case BUT3:
	/* etc ... */
		if( show == bckgrd[res-BUT1])	break;  /* pour ne pas r‚afficher le mˆme fond */
		FORM(win)[bckgrd[res-BUT1]].ob_flags &= ~HIDETREE;	/* on cache l'ancien fond */
		FORM(win)[show].ob_flags |= HIDETREE;	/* on r‚affiche le nouveau fond */
		show = bckgrd[res-BUT1];				/* on garde ca en m‚moire */
		((W_FORM*)win->data)->edit = -1;		/* bug windom d‚sol‚ */
		ObjcDraw( OC_FORM, wglb.appfront, show, MAX_DEPTH);	/* On redessine le nouveau fond */
		ObjcDraw( OC_FORM, wglb.appfront, res, 0);	/* On redessinne le bouton */
		break;
	
	/* gestion de tous les autres boutons */
	case OK:
		snd_rdw( win);
		ObjcChange( OC_FORM, win, res, NORMAL, 0);
		break;
	case CANCEL:
		snd_msg( win, WM_CLOSED, 0, 0, 0, 0);
		break;
	default:
		ObjcChange( OC_FORM, win, res, NORMAL, 1);
		break;		
	}

}
#endif

/*
 *	New Way : the previous algorithm is now obsolet because WinDom
 *  provides a function which handle automatically thumb indexes in
 *  a dialog window. However, only one group of thumb indexes can be
 *  used by window. If you can to use more, you have to use the
 *  previous algorithm.
 *
 */

#ifndef OLD_WAY
void closeform( WINDOW *win, int index) {
	ObjcChange( OC_FORM, win, index, ~SELECTED, TRUE);
	ApplWrite( app.id, WM_DESTROY, win->handle);
}
#endif

int main(void) {
	OBJECT *tree;
#ifndef OLD_WAY
	WINDOW *win;
	int frms[] = {FOND1, FOND2, FOND3};
	int buts[] = {BUT1, BUT2, BUT3};
#endif

	ApplInit();
	RsrcLoad( "multifrm.rsc");
	RsrcXtype( 1, NULL, 0);
	rsrc_gaddr( 0, FORM1, &tree);

#ifdef OLD_WAY
	FormCreate( tree, WAT_FORM, formFORM1, "Formulaire multiple",
				NULL, TRUE, FALSE);
#else
	win = FormCreate( tree, WAT_FORM, NULL, "Formulaire multiple", 
					  NULL, TRUE, FALSE);
	FormThumb( win, frms, buts, 3);
	ObjcAttach( OC_FORM, win, OK, BIND_FUNC, closeform);
	ObjcAttach( OC_FORM, win, CANCEL, BIND_FUNC, closeform);
	EvntAdd( win, WM_DESTROY, FormThbFree, EV_TOP);
#endif		

	while( wglb.first) EvntWindom(MU_MESAG);
	RsrcXtype( 0, NULL, 0);
	RsrcFree();
	ApplExit();
	return 0;
}
