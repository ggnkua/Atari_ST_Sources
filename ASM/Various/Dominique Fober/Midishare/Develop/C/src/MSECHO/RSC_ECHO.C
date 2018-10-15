/*********************************************************************

	RSC_ECHO.C

	Midi Echo		Accessoire de bureau
	Module GEM	traitement des entrees dans les ressources

	GRAME		D. Fober
	24/10/89	
*********************************************************************/

#include <msh_unit.h>
#include <stdio.h>

#ifdef MWC
# include <gemdefs.h>
# include <obdefs.h>
#endif

#ifdef TURBO_C
# include <aes.h>
# include <vdi.h>
#endif

#include "msecho.h"
#include "echo.h"

extern int form_do();

#define chge_button(b,s)	objc_change( Adr_rsc, b, 0, xwork, ywork, wwork, hwork, s, 1)
#define chge_obj(obj) 	objc_draw( Adr_rsc, obj, 0, xwork, ywork, wwork, hwork)

/*****************************************************************/
/* d‚finition de constantes */
/*****************************************************************/
#define MAX_DELAY	999		/* d‚lai maximum ( en 1/100s.) */
#define MAX_AMORT	127		/* pas d'amortissement maximum */
#define MIN_DELAI	1		/* d‚lai minimum */
#define MIN_AMORT	1		/* pas d'amortissement minimum */

#define FAST_V		80		/* les pas d'incr‚ment ou */
#define SLOW_V		1		/* d‚cr‚ment des paramŠtres */

/*****************************************************************/
/* variables externes	*/
/*****************************************************************/
extern int 	handle;
extern OBJECT 	*Adr_rsc, *Adr_menu, *Adr_infos;
extern int 	xwork, ywork, wwork, hwork;

/*****************************************************************/
/* variable du module */
/*****************************************************************/
/* gestion des echos */
struct echoState echo= {1, 25, 15};	/* paramŠtres par d‚faut */

/*****************************************************************/
void chge_delay( val)	/* initialise le buffer chaine du delay */
register int val;		/* nouvelle valeur du delay */
{
register TEDINFO *s;
static char buff[4];

	sprintf( buff,"%03d", val);
	s= TedInfo( Adr_rsc, DELAY);
	s->te_ptext= buff;
}

/*****************************************************************/
void chge_amort( val)	/* initialise le buffer chaine de l'amortissement */
register int val;
{
register TEDINFO *s;
static char buff[4];

	sprintf( buff,"%03d", val);
	s= TedInfo( Adr_rsc, AMORT);
	s->te_ptext= buff;
}

/*****************************************************************/
void chge_state( state)		/* switch echo on ou off */
register int state;
{
	echo.state= state;		/* nouvel ‚tat de l'echo */
	chge_alarm( state);		/* positionne l'alarme correspondante */
	if( state)			/* et met la fenetre … jour */
		chge_button( OFF, NORMAL|SHADOWED);
	else
		chge_button( ON, NORMAL|SHADOWED);
}

/*****************************************************************/
void inc_delay( op)		/* modifie le d‚lai entre r‚p‚titions */
register int op;		/* op‚ration demand‚e: + ou - */
{
int state=0, ret;
register int i=1, max, delay;

	delay= echo.delay;		/* valeur initiale du d‚lay */
	do{
		/* max du pas d'incr‚ment selon ‚tat du bouton droit de la souris */
		(state & 2) ? (max= FAST_V) : (max= SLOW_V);
		if( op){					/* si incr‚ment */
			if( delay< (MAX_DELAY- i)) 	/* tant qu'on n'est pas au max */
				delay+= i;			/* incr‚mente le d‚lai */
			else delay= MAX_DELAY;		/* sinon d‚lai = max */
		}
		else{					/* si d‚cr‚ment */
			if( delay> (i+ MIN_DELAI)) 	/* tant qu'on n'est pas au min */
				delay-= i;			/* d‚cr‚mente le d‚lai */
			else delay= MIN_DELAI;		/* sinon d‚lai= min */
		}
		if( i< max) i++;	/* si pas d'incr‚ment < max, on augmente */
		else i--;			/* sinon on diminue */
		chge_delay( delay);		/* mise … jour de la chaine de caract */
		chge_obj( DELAY);		/* mise … jour de la fenetre */
		vq_mouse( handle, &state, &ret, &ret);	/* test de la souris */
	} while( (state & 1) && (delay< MAX_DELAY) && (delay> 1));
	echo.delay= delay;			/* range la nouvelle valeur du d‚lai */
	if( op)					/* et met la fenetre … jour */
		chge_button( DPLUS, NORMAL|SHADOWED);
	else
		chge_button( DMOINS, NORMAL|SHADOWED);
}

/*****************************************************************/
void inc_amort( op)		/* modifie le pas d'incr‚ment */
register int op;		/* op‚ration demand‚e: + ou - */
{
int state=0, ret;
register int i=1, max, amort;

	amort= echo.amort;		/* amortissement initial */
	do{
		(state & 2) ? (max= FAST_V) : (max= SLOW_V);
		if( op){					/* si incr‚ment */
			if( amort< (MAX_AMORT- i)) 	/* tant que amortissement < max */
				amort+= i;			/* on incr‚mente */
			else amort= MAX_AMORT;		/* sinon amortissement = max */
		}
		else{					/* si d‚cr‚ment */
			if( amort> (i+ MIN_AMORT)) 	/* tant que amortissement > min */
				amort-= i;			/* on d‚cr‚mente */
			else amort= 1;				/* sinon amortissement = min */
		}
		if( i< max) i++;		/* modification du pas d'incr‚ment */
		else i--;
		chge_amort( amort);		/* mise … jour de la chaine de caract */
		chge_obj( AMORT);		/* mise … jour de la fenetre */
		vq_mouse( handle, &state, &ret, &ret);	/* test de la souris */
	} while( (state & 1) && (amort< MAX_AMORT) && (amort> 1));
	echo.amort= amort;			/* range le nouveau pas d'amortissement */
	if( op)					/* et met la fenetre … jour */
		chge_button( APLUS, NORMAL|SHADOWED);
	else
		chge_button( AMOINS, NORMAL|SHADOWED);
}

/*****************************************************************/
int make_form( rsc, f, i)	 	/* remplit et gŠre un formulaire */
register OBJECT *rsc;			/* adresse de la ressource */
register int (*f)();			/* fonction de traitement de la ressource */
int i;						/* index du champ d'‚dition … activer */
{
	static char ms_version[6];
	static char echo_version[6];
	register short n;
	int x, y, w, h;
	register int ret;

	n= MidiGetVersion();
	sprintf( ms_version,"%01d.%02d", n/100, n%100 );
	sprintf( echo_version,"%01d.%02d", NUMVERSION/100, NUMVERSION%100 );
	TedInfo( rsc, VERSION)->te_ptext= ms_version;
	TedInfo( rsc, VAPPL)->te_ptext= echo_version;

	wind_update( BEG_UPDATE);
	form_center(rsc, &x, &y, &w, &h);
	form_dial(FMD_START, 0,0,0,0, x, y, w, h); 
	objc_draw( rsc, 0, 5, x, y, w, h);			/* affiche le formulaire */
	ret= ( *f)( rsc, i);					/* gestion du formulaire */
	form_dial(FMD_FINISH, 0,0,0,0, x, y, w, h); 
	wind_update( END_UPDATE);
	return( ret);
}

/****************************************************************/
void traite_menu( titre, select)
register int titre, select;
{
	menu_tnormal( Adr_menu, titre, 1);
	if( select== MESSAGE){
		make_form( Adr_infos, &form_do, 0);
		objc_change( Adr_infos, INFOUT, 0, 0,0,640,400, 0, 0);
	} 
}

/*****************************************************************/
/* traitement g‚n‚ral des entr‚es dans le formulaire 	*/
/* affich‚ dans la fenetre						*/
/*****************************************************************/
void traite_entrees( x, y)
int x, y;				/* coordonn‚es du click de la souris */
{
register int object;	/* l'objet s‚lectionn‚ */
register OBJECT *adr;	/* l'adresse de la ressource */
register int state;

	adr= Adr_rsc;
	if( (object= objc_find( adr, ROOT, 5, x, y)) != -1 
	  && ( adr[object].ob_flags & SELECTABLE)) {
		state= adr[object].ob_state;
		chge_button( object, state|SELECTED);
		switch( object){
			case OFF:
				chge_state( FALSE);
				break;
			case ON:
				chge_state( TRUE);
				break;
			case DPLUS:
				inc_delay( TRUE);
				break;
			case DMOINS:
				inc_delay( FALSE);
				break;
			case APLUS:
				inc_amort( TRUE);
				break;
			case AMOINS:
				inc_amort( FALSE);
				break;
			case INFOS:
				make_form( Adr_infos, &form_do, 0);
				chge_button( object, state);
				objc_change( Adr_infos, INFOUT, 0, 0,0,640,400, 0, 0);
				break;
		}
	}
}

/******************************* fin *****************************/
