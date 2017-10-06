/*
 *	WinDom, Librairie GEM par Dominique B‚r‚ziat
 *	copyright 1997/2000
 *
 *	module: bubble.c
 *	description: librairie BubbleGEM, routines d'appels
 *				 … BubbleGEM.
 */

#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include "av.h"
#include "globals.h"
#include "cookie.h"

struct bubble {
	OBJECT *tree;
	int index;
	char *help;
	struct bubble *next;
};

static struct bubble *bubble_index=NULL;     /* interne */
static long __bubble_conf = -1;				 /* interne */


/*
 * Trouver l'id de BubbleGEM. Au besoin, le charger.
 */

int BubbleGet( void) {
	int bubble_id = appl_find("BUBBLE  ");

	if( bubble_id < 0 && _AESnumapps != 1) {
		char *value;
    	
    	shel_envrn( &value, "BUBBLE=");
    	if( !value) shel_envrn( &value, "BUBBLEGEM=");
    	if( value)
    		shel_write( 1, 1, 100, value, "");
    	else 
    		return -2;

#ifdef __GEMLIB__
    	evnt_timer( 500);
#else
		evnt_timer( 500, 0);
#endif
    	__bubble_quit = bubble_id = appl_find("BUBBLE  ");
	}
	return bubble_id;
}

/* Appel de Bubble depuis un formulaire
 * bloquant.
 *	-1 : bubble pas en m‚moire
 *	-2 : impossible
 *	-3 : erreur m‚moire
 *	-4 : version version de Bubble ne supportant pas 
 *		 l'appel en formulaire bloquant
 */
  

void snd_mu_button( int mbut, int nbclick) {
	long rec[2];

	rec[0] = 1;
	rec[1] = (long)nbclick + ((long)mbut << 16);
	appl_tplay( rec, 1, 100);
}


int BubbleModal( char *hlp, int mx, int my) {
	BGEM *bgem;
	BHLP bhlp;
	INT16  dummy;
	int bmask, bstate, bclicks, ev;
	int bubble_id = appl_find( "BUBBLE  ");
	long bubble_save;

	if( bubble_id == -1)
		return -1;

	if( get_cookie( BGEM_COOKIE, (long*)&bgem)) {
    	/* Demander de la m‚moire pour la communication */
		if( app.pipe == NULL) return -3;
		strcpy( app.pipe, hlp);
		
		/* Config locale */
		get_cookie (BHLP_COOKIE, &bubble_save);
 		if( __bubble_conf != -1 ) set_cookie( BHLP_COOKIE, __bubble_conf);

 		/* RequŠte fonte */
 		ApplWrite( bubble_id, BUBBLEGEM_FONT, CONF(app)->bubble.font, CONF(app)->bubble.size, 0, 0, 0);

		/* Envoi message a Bubble */
		ApplWrite( bubble_id, BUBBLEGEM_SHOW, mx, my, ADR(app.pipe), BGS7_USRHIDE);
#ifdef __GEMLIB__
		evnt_timer( 10L);
#else
		evnt_timer( 10, 0);
#endif

		/* en mode modal, … nous de g‚rer certaines choses ... */
		graf_mkstate( &dummy, &dummy, &evnt.mbut, &dummy);
        if( (evnt.mbut & 0x3) == 0) {
			bclicks = 258;
			bmask = 3;
			bstate = 0;
		} else {
			bclicks = 0;
            bmask = 3;
            bstate = 0;
		}
		/* forme de la souris */
		graf_mouse(USER_DEF,bgem->mhelp);
#ifdef __GEMLIB__
     	ev = evnt_multi( MU_KEYBD|MU_BUTTON|MU_M1, 
     					 bclicks, bmask, bstate, 
     					 1, mx-6, my-6, 13, 13, 
     					 0, 0, 0, 0, 0, evnt.buff,
						 0L,
          				 &evnt.mx, &evnt.my,  &evnt.mbut, 
          				 &evnt.mkstate, &evnt.keybd, 
          				 &evnt.nb_click);
#else  /* __GEMLIB__ */
     	ev = evnt_multi( MU_KEYBD|MU_BUTTON|MU_M1, 
     					 bclicks, bmask, bstate, 
     					 1, mx-6, my-6, 13, 13, 
     					 0, 0, 0, 0, 0, evnt.buff,
          				 0, 0, 
          				 &evnt.mx, &evnt.my,  &evnt.mbut, 
          				 &evnt.mkstate, &evnt.keybd, 
          				 &evnt.nb_click);
#endif /* __GEMLIB__ */
        		/* attente */
        if( !get_cookie( BHLP_COOKIE, (long*)&bhlp))
       		bhlp.delay = 200;
#ifdef __GEMLIB__
		evnt_timer( bhlp.delay);
#else
		evnt_timer( bhlp.delay,0);
#endif
		/* fin protocole */
        ApplWrite( bubble_id, BUBBLEGEM_HIDE, 0, 0, 0, 0, 0);
        graf_mouse( ARROW, NULL);
        /* Restauration config */
        set_cookie( BHLP_COOKIE, bubble_save);
        if( ev & MU_KEYBD)
        	ApplWrite( app.id, AP_KEYBD, evnt.mkstate, evnt.keybd, 0, 0, 0);
        if( ev & MU_BUTTON)
       	/*	ApplWrite( app.id,  AP_BUTTON, evnt.mx, evnt.my, 
       				   evnt.mbut, evnt.mkstate, evnt.nb_click); */
       		snd_mu_button( evnt.mbut, evnt.nb_click);
        return 0;
	} else {
		/* erreur : ne fonctionne qu'avec un d‚mon
					donc depuis bubble 06 et qui
					correspond a l'apparition du 
					cookie 'BGEM' */
		return -4;
	}
}

/*
 *	Cette fonction remplace form_do() pour permettre
 *	la gestion des bulles d'aides.
 */

int BubbleDo( OBJECT *tree, int edit) {
	INT16 msg[8], mx, my, mbut;
	INT16 dum, keybd, click, obj;
	INT16 ev;
	INT16 pos = 0;
	char *help;

	if( edit != -1) objc_edit( tree, edit, 0, &ev, ED_INIT);
	
	while( 1) {
#ifdef __GEMLIB__
		ev = evnt_multi( MU_BUTTON|MU_KEYBD, 
					258, 3, 0, 
     				0, 0, 0, 0, 0,
     				0, 0, 0, 0, 0, 
     				msg, 
					0L,
          			&mx, &my, &mbut,  
   					&dum, &keybd, &click);
#else  /* __GEMLIB__ */
		ev = evnt_multi( MU_BUTTON|MU_KEYBD, 
					258, 3, 0, 
     				0, 0, 0, 0, 0,
     				0, 0, 0, 0, 0, 
     				msg, 
     				0, 0, 
          			&mx, &my, &mbut,  
   					&dum, &keybd, &click);
#endif /* __GEMLIB__ */
	
		if( ev & MU_BUTTON) {
			obj = objc_find( tree, 0, 7, mx, my);
			if( obj != -1 && mbut & 0x1) {
				if( !form_button( tree, obj, click, &dum))
					return obj;
				if( tree[obj].ob_flags & EDITABLE && obj != edit) {
					objc_edit( tree, edit, 0, &pos, ED_END);
					edit = obj;
					objc_edit( tree, edit, 0, &pos, ED_INIT);			
				}
			} else if( obj != -1 && mbut & 0x2) {
				if(	BubbleFind( tree, obj, &help))
					BubbleModal( help, mx, my);
			}
		}
		
		if( ev & MU_KEYBD) {
			INT16 key;
			
			if( !form_keybd( tree, (edit==-1)?0:edit, 1, keybd, &obj, &key))
				return obj;
			if( key) 
				objc_edit( tree, edit, key, &pos, ED_CHAR);
			else {
				objc_edit( tree, edit, 0, &pos, ED_END);
				edit = obj;
				objc_edit( tree, edit, 0, &pos, ED_INIT);
			}	
		}
	}
}


/* code retour de la fonction:
	0, pas d'‚rreur
	-1, bubble pas en m‚moire
	-2, la variable d'environnement BUBBLE= est incorrecte
	-3, erreur d'allocation m‚moire
 */

 
int BubbleCall( char *help, int x, int y) {
	INT16 msg[8];
	int bubble_id;
	long bubble_save;
	
	bubble_id = BubbleGet();

    if (bubble_id >= 0) {
		if( app.pipe == NULL) return -3;

		/* Config locale */
		get_cookie (BHLP_COOKIE, &bubble_save);
 		if( __bubble_conf != -1 ) set_cookie( BHLP_COOKIE, __bubble_conf);
 		
 		/* RequŠte fonte */
 		ApplWrite( bubble_id, BUBBLEGEM_FONT, CONF(app)->bubble.font, CONF(app)->bubble.size, 0, 0, 0);
	
		/* Affichage de la bulle */
		strcpy( app.pipe, help);
		ApplWrite( bubble_id, BUBBLEGEM_SHOW, x, y, ADR(app.pipe),  BGS7_MOUSE);
 		
 		/* Attente accus‚ de reception, max, une seconde d'attente */
 		AvWaitfor( BUBBLEGEM_ACK, msg, 1000);

        /* Restauration config */
        set_cookie( BHLP_COOKIE, bubble_save);
        return 0;
    }
    return bubble_id;
}

int BubbleAttach( OBJECT *tree, int index, char *help) {
	struct bubble *b=bubble_index;
	
	if( b == NULL) {
		b = (struct bubble *)malloc(sizeof(struct bubble));
		if( b == NULL) return -1; /* erreur */
		b->tree=tree;
		b->index=index;
		b->help=help;
		b->next=NULL;
		bubble_index = b;
	} else {
		while( b->next) b = b->next;
		b->next = (struct bubble *)malloc(sizeof(struct bubble));
		if( b->next == NULL) return -1; /* erreur */
		b->next->tree=tree;
		b->next->index=index;
		b->next->help=help;
		b->next->next=NULL;
	}
	return 0;
}

void BubbleFree( void)
{
	struct bubble *b=bubble_index,*n;
	
	while( b) {
		n = b->next;
		free(b);
		b=n;
	}
}

int BubbleFind( OBJECT *tree, int index, char **help)
{
	struct bubble *b=bubble_index;
	
	while( b) {
		if( b->tree == tree && b->index == index) {
			*help = b->help;
			return 1;
		}
		b=b->next;
	}
	return 0;
}


int BubbleEvnt( void) {
	WINDOW *win;
	int res;
	char *help;
	W_FORM *form;
	
	win = WindHandle( wind_find(evnt.mx,evnt.my));
	if( win && win->status & WS_FORM) {
		form = DataSearch(win,WD_WFRM);
		res = objc_find( form->root, 0, 8, evnt.mx, evnt.my);
		if( res != -1 && BubbleFind( form->real, res, &help)) {
			BubbleCall( help, evnt.mx, evnt.my);
			return WS_FORM;
		}
	}
	if( win && win->status & WS_TOOLBAR) {
		res = objc_find( TOOL(win), 0, 8, evnt.mx, evnt.my);
		if( res != -1 && BubbleFind( win->tool.real, res, &help)) {
			BubbleCall( help, evnt.mx, evnt.my);
			return WS_TOOLBAR;
		}
	}
	return 0;
}

void BubbleConf( BHLP conf) {
	__bubble_conf = ((long)conf.delay << 16) + conf.flag;
}
