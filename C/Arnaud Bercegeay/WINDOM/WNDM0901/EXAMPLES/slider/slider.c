/*
 *	Exemple de gestion d'un slider dans une fenˆtre
 *	C'est pas long et ya beaucouq de commentaires
 */

#include <windom.h>
#include <stdio.h>
#include <stdlib.h>
#include "slider.h"

int real_time = FALSE;

void doFORM1( WINDOW *win);
void ApTerm ( void);
void F1Close( WINDOW *win, int index);
void Slider	( WINDOW *win);

void main( void) {
	OBJECT *tree;
	WINDOW *win;

	ApplInit();
	RsrcLoad("slider.rsc");
	
	rsrc_gaddr( 0, FORM1, &tree);
	win = FormCreate( tree, NAME|MOVER|CLOSER, NULL, "Slider & WinDom", NULL, 1, 0);
	ObjcAttach( OC_FORM, win, F1_CLOSE, BIND_FUNC, F1Close);
	ObjcAttach( OC_FORM, win, SLIDER,   BIND_FUNC, Slider);
	ObjcAttach( OC_FORM, win, F1_TR,    BIND_VAR,  &real_time);
	

	EvntAttach( NULL, AP_TERM, ApTerm);
	/* Boucle Principale */
	for( ;;) EvntWindom( MU_MESAG);
}

void F1Close( WINDOW *win, int index) {
	/* ApplWrite ( app.id, WM_CLOSED, win->handle); */
	ApplWrite( app.id, AP_TERM);
	ObjcChange( OC_FORM, win, index, NORMAL, 1);
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

void Slider( WINDOW *win) {
	OBJECT *tree = FORM( win);
	unsigned long res;
	int x,y;
	
	if( !real_time) {
		/* A cause de la d‚mo temps r‚el, le slider ne peut
		 * pas etre selectable. Dans le cas non temps r‚el, on
		 * selectionne nous-meme le slider 
		 */
		ObjcChange( OC_FORM, win, SLIDER, SELECTED, TRUE);

		/* on r‚cupŠre les coordonn‚es du slider */
		objc_offset( tree, SLIDER, &x, &y);
		
		/* on simule le d‚placement du slider */
		res = (unsigned long)graf_slidebox( tree, PERE_SLD, SLIDER, 1);
						
		/* res contient la position relative (entre 0 et 1000) */
		
		res *= (unsigned long)(tree[PERE_SLD].ob_height-tree[SLIDER].ob_height);
		tree[SLIDER].ob_y = (int)(res/1000UL);
		
		/* On redessine le slider */
		ObjcChange( OC_FORM, win, SLIDER, NORMAL, 0);
		ObjcDraw( OC_FORM, win, PERE_SLD, 1);
	} else {
		static int lastx = 0, lasty = 0;
		static int offset = 0;
		int dum, soby, poby, but;
		
		graf_mkstate( &x, &y, &but, &dum);
		if( x != lastx || y != lasty) {

			/* coordonn‚ du fond slider */
			objc_offset( tree, PERE_SLD, &dum, &poby);
			objc_offset( tree, SLIDER,   &dum, &soby);
		
			if( lastx == 0) {
				ObjcChange( OC_FORM, win, SLIDER, SELECTED, TRUE);
				offset = y - poby;
			}

			
			/* hauteur souris par rapport au fond slider */
			y -= offset;
			dum = max( y-poby, 0);
			dum = min( dum, tree[PERE_SLD].ob_height-tree[SLIDER].ob_height);
			
			/* dum = nouvelle position relative, en pixel cette fois */
			
			tree[SLIDER].ob_y = dum;
		
			res = dum;
		/*	res = (size_t)dum*1000L/(tree[PERE_SLD].ob_height-tree[SLIDER].ob_height);			 */
			
			if( !but) ObjcChange( OC_FORM, win, SLIDER, NORMAL, FALSE);
			ObjcDraw( OC_FORM, win, PERE_SLD, 1);
			
		}
		lastx = x ; lasty = y;
		
		/* Remarque:
			La routine pourrait etre am‚lior‚ pour que ce soit plus joli
			et plus rapide:
			 - faudrait tester que le curseur a bouger pour ne pas
			   remettre tout a jour
			 - l'objet ne devrait pas ˆtre s‚lectable car 
			   … chaque passage il change d'‚tat (SELECTED)
			*/
	}

	sprintf( ObjcString( tree, F1_FIELD, NULL), "%4ld", res);
	ObjcDraw( OC_FORM, win, F1_FIELD, TRUE);

}

void ApTerm( void) {
	while( wglb.first) {
		ApplWrite( app.id, WM_DESTROY, wglb.first->handle);
		EvntWindom( MU_MESAG);
	}
	RsrcFree();
	ApplExit();	exit( 0);
}

