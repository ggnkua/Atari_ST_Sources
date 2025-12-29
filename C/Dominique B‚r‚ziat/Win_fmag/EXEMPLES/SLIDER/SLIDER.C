/*
 *	Exemple de gestion d'un slider dans une fenˆtre
 *	C'est pas long et ya beaucouq de commentaires
 */

#include <windom.h>
#include <stdio.h>
#include "slider.h"

void doFORM1( WINDOW *win);

int main(void)
{
	OBJECT *tree;
	
	ApplInit();
	RsrcLoad("slider.rsc");
	
	/* Cr‚er le formulaire */
	rsrc_gaddr( 0, FORM1, &tree);
	FormCreate( tree, NAME|MOVER|CLOSER, /* objet et attributs GEM */
				doFORM1,	/* La routine de Gestion du formulaire */
				"Slider & WinDom", NULL, 1, 0);	/* le reste des options 
												 * voir la doc
												 */
	
	/* Boucle Principale */
	
	do{
		EvntWindom(MU_MESAG);
		/* Cas de shutdown (systŠme multitƒche */
		if( evnt.buff[0] == AP_TERM)
			snd_msg( wglb.first, WM_CLOSED, 0, 0, 0, 0);
	}while( wglb.first);	/* fin de la boucle si ya plus de fenˆtre */

	/* fin du programme */

	RsrcFree();
	ApplExit();
	return 0;
}

/*
 * Routine de gestion du formulaire
 *	Cette routine est appel‚ lorsque un objet
 *	EXIT ou TOUCHEXIT … ‚t‚ s‚lectionn‚ dans le
 *	formulaire. evnt.buffer contient les infos
 *	(objet cliqu‚ etc ...). Tu remarqueras que
 *	l'on gŠre pratiquement de la mˆme fa‡on les
 *	formulaire en fenˆtre que les formulaire
 *	GEM classique.
 *	-> voir doc ObjcChange()
 *				ObjcDraw()
 *				Les formulaires en fenˆtre ( c'est
 *		mal expliqu‚ dans la doc, je vais corriger cela )
 */
 
void doFORM1( WINDOW *win)
{
	OBJECT *tree = FORM(win);
	int x,y,dum;
	size_t res;
	int obj = evnt.buff[4];
	
	switch( obj){
	case F1_CLOSE:
		/* On envoit un message pour fermer la fenˆtre */
		snd_msg( win, WM_CLOSED, 0, 0, 0, 0);
		
		/* on remet le bouton en normal et on le redessine */
		ObjcChange( OC_FORM, win, obj, NORMAL, 1);
		break;

	case SLIDER:
		if( !(tree[F1_TR].ob_state & SELECTED))
		{
			/* on r‚cupŠre les coordonn‚es du slider */
			objc_offset( tree, SLIDER, &x, &y);
		
			/* on simule le d‚placement du slider */
			res = (size_t)graf_slidebox( tree, PERE_SLD, SLIDER, 1);
			
			/* On affiche la position du slider (en plus) */
			sprintf( tree[F1_FIELD].ob_spec.tedinfo->te_ptext, "%4ld", res);
			ObjcDraw( OC_FORM, win, F1_FIELD, 0);
			
			/* res contient la position relative (entre 0 et 1000) */
		
			res *= (size_t)(tree[PERE_SLD].ob_height-tree[SLIDER].ob_height);
			tree[SLIDER].ob_y = (int)(res/1000UL);
		
			/* On redessine le slider */
			ObjcChange( OC_FORM, win, SLIDER, NORMAL, 0);
			ObjcDraw( OC_FORM, win, PERE_SLD, 1);
		}
		else /* Version en temps r‚el - plus compliqu‚ */
		{
			/* coordonn‚es verticale de la souris et du pŠre du slider*/
			graf_mkstate( &dum, &y, &dum, &dum);
			objc_offset( tree, PERE_SLD, &dum, &x);
			
			dum = max( y - x, 0);
			dum = min( dum, tree[PERE_SLD].ob_height-tree[SLIDER].ob_height);
			
			/* dum = nouvelle position relative, en pixel cette fois */
			
			tree[SLIDER].ob_y = dum;
			
			res = (size_t)dum*1000L/(tree[PERE_SLD].ob_height-tree[SLIDER].ob_height);
			sprintf( tree[F1_FIELD].ob_spec.tedinfo->te_ptext, "%4ld", res);
			ObjcDraw( OC_FORM, win, F1_FIELD, 0);
			
			/* Etat du bouton de la souris */
			ObjcChange( OC_FORM, win, SLIDER, NORMAL, 0);
			
			ObjcDraw( OC_FORM, win, PERE_SLD, 1);
			
			/* Remarque:
				La routine pourrait etre am‚lior‚ pour que ce soit plus joli
				et plus rapide:
			 - faudrait tester que le curseur a bouger pour ne pas
			   remettre tout a jour
			 - l'objet ne devrait pas ˆtre s‚lectable car 
			   … chaque passage il change d'‚tat (SELECTED)
			*/
		}
		break;
	}
}
