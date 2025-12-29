#include <windom.h>
#include "test.h"

int main(void)
{
	OBJECT *tree;
	int res;
	
	/* test de bubble */

	ApplInit();
	RsrcLoad( "TEST.RSC");
	rsrc_gaddr( 0, FORM1, &tree);
	FormCreate( tree, MOVER|NAME, NULL, "Formulaire normal", NULL, 1, 0);

	BubbleAttach( tree,  0, "Fond du formulaire"); 	/* FORM1 */
	BubbleAttach( tree, OK, "Bouton de sortie");  	/* FORM1 */
	
	evnt.bclick = 258;
	evnt.bmask = 0x1|0x2;
	evnt.bstate = 0;
	
	do {
		res = EvntWindom( MU_MESAG|MU_BUTTON);
		if( res & MU_MESAG && evnt.buff[0] == WM_FORM) {
			switch( evnt.buff[4]) {
				case OK:
					ObjcChange( OC_FORM, wglb.first, OK, NORMAL, 1);
					snd_msg( wglb.first, WM_CLOSED, 0, 0, 0, 0);
					break;
			}
		}

		if( res & MU_BUTTON && evnt.mbut & 0x2) {
			BubbleEvnt();
		}
	} while( wglb.first);

	/* Formulaire modal */
	
	FormWindBegin(tree, "Formulaire modal");
	
	do {
		res = FormWindDo( MU_MESAG|MU_BUTTON|FORM_EVNT);
		if( (res & FORM_EVNT) && (res & MU_BUTTON))
			BubbleEvnt();
	} while( res != OK);
	
	FormWindEnd();
	
	BubbleFree();
	RsrcFree();
	ApplExit();
	return 0;
}