/*
 *	Exemple de gestion de formulaire multiple
 *		Dominique B‚r‚ziat 1997
 */

#include <windom.h>
#include "multifrm.h"

/* cet algo utilise une hypothŠse les boutons qui d‚clenchent 
   l'apparition du formulaire qui leurs correspondent sont RADIO
   et leurs index se suivent (cela permet de simplifier les choses)
   
	Pour utiliser les objets ‚tendues de look calepin, il faut attribuer
	aux boutons radio et aux fond des formulaires le type ‚tendu 16.
	Les fond de formulaires ne doivent pas ˆtre radio. Enfin les boutons 
	radios doivent ˆtre dessin‚ aprŠs les fond des formulaire (donc ils
	devraient avec un indx plus grand que ceux des fonds...).
	le bit FLAG8 des ‚tats des objets double la tailles des cadres. Enfin
	le bit Draw3D est pris en compte.
*/
   

void formFORM1( WINDOW *win)
{
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

int main(void)
{
	OBJECT *tree;
	
	ApplInit();
	RsrcLoad( "multifrm.rsc");
	RsrcXtype( 1, NULL, 0);
	rsrc_gaddr( 0, FORM1, &tree);
	FormCreate( tree, NAME|MOVER|CLOSER|SMALLER, 
				formFORM1, "Formulaire multiple",
				NULL, TRUE, FALSE);
		
	while( wglb.first) EvntWindom(MU_MESAG);
	RsrcXtype( 0, NULL, 0);
	RsrcFree();
	ApplExit();
	return 0;
}