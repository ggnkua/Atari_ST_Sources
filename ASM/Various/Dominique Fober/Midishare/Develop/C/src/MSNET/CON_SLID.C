/********************************************************************************/
/*                     MIDI SHARE Application Midi Connecte                     */
/*------------------------------------------------------------------------------*/
/*		CON_SLID.C												*/
/*		Module de gestion des affichages	(sliders)						*/
/*------------------------------------------------------------------------------*/
/*		@ GRAME 1989/90, Dominique Fober (Atari ST)						*/
/********************************************************************************/

#ifdef MWC
# include <gemdefs.h>
# include <aesbind.h>
# include <vdibind.h>
# include <obdefs.h>
# include <osbind.h>
#endif

#ifdef TURBO_C
# include <aes.h>
# include <vdi.h>
# include <tos.h>
#endif

#include <stdio.h>
#include <string.h>

#include "msnet.h"			/* fichier de ressources gem */
#include "con_defs.h"		/* gestion g‚n‚rale du programme */


#define H_LINE		10		/* hauteur d'une ligne d'affichage  */
#define SIZE_MIN	5		/* taille min. de l'ascenceur */
#define SIZE_MAX	100		/* taille max. de l'ascenceur */
#define POS_MIN	0		/* position min. de l'ascenceur */
#define POS_MAX	100		/* position max. de l'ascenceur */

#define NLINES  	Adr_rsc[APP].ob_height/ H_LINE



/* Variables globales de l'application */
/*---------------------------------------------------------------*/
extern short myRefNum;
extern struct GEST gest;

/*---------------------------------------------------------------*/
/* les adresses des ressources  */
extern OBJECT *Adr_rsc, *Adr_menu, *Adr_about;

/*---------------------------------------------------------------*/
/* les handlers menu, application, fenetres */
extern short handle;			/* virtual workstation handle	*/
extern short wi_handle;			/* window handle 			*/

/*---------------------------------------------------------------*/
/* l'espace de travail courant 							*/
extern short xwork, ywork, hwork, wwork;
extern GRECT clip[3];		/* clippings de chaque sous fenetre*/


/*********************************************************************/
void set_appl_first( i, sf)/* positionne l'appl i pour affichage first */
register int i, sf;
{
	register APPL *appl;

	if( appl= gest.appl){
		for( ; i && appl->next; --i)
			appl= appl->next;
		gest.aff[sf]= appl;
	}
}

/*********************************************************************/
int count_appls()
{
	register APPL *appl;
	register int i=0;
	
	appl= gest.appl;
	while( appl)
	{
		appl= appl->next;
		i++;
	}
	return i;
}


/****************************************************************/
int get_sf_slide( i)
int i;
{
	switch( i)
	{
		case SFIN:
			return SLIDEIN;
		case SFOUT:
			return SLIDEOUT;
		default:
			return SLIDEAPP;
	}
}

/****************************************************************/
int get_parent( i)
int i;
{
	switch( i)
	{
		case SLIDEIN:
			return FSIN;
		case SLIDEOUT:
			return FSOUT;
		default:
			return FSAPP;
	}
}

/****************************************************************/
void set_pos_slide( pos, ob)	/* change la position d'un slider vertical */
register int pos, ob;
{
	register OBJECT *rsc;
	register int pos_max;

	rsc= Adr_rsc;
	pos_max= count_appls()- NLINES;
	if( !pos_max) pos_max= 1;		/* debug */
	if( pos > pos_max) pos= pos_max;
	if( pos < POS_MIN) pos= POS_MIN;
	rsc[ob].ob_y= ((rsc[FSAPP].ob_height - rsc[SLIDEAPP].ob_height)* pos)/ pos_max;
}

/****************************************************************/
void set_size_slide( size, ob)/* change la taille d'un slider vertical */
register int size, ob;
{
	register OBJECT *rsc;
	
	rsc= Adr_rsc;
	if( size < SIZE_MIN) size= SIZE_MIN;
	if( size > SIZE_MAX) size= SIZE_MAX;
	rsc[ob].ob_height= ((rsc[FSAPP].ob_height-SIZE_MIN)*size)/ SIZE_MAX + SIZE_MIN;
}

/*********************************************************************/
void chge_vslide( diff)	/* change la taille de l'ascenceur vertical */
register int diff;			/* diff‚rence de taille de la fenetre */
{
	register int nline, tot, first, slide;
	int i;

	nline= NLINES;
	tot= count_appls();
	for( i=0; i<NBRE_SF; i++)
	{
		slide= get_sf_slide( i);
		first= getIndAppl( gest.aff[i]);
		if( (tot- nline)> 0){
			if( (diff> 0) && ((tot- first)< nline))
			{
				if(  (first= tot-nline) < 0)
					first= 0;
				set_appl_first( first, i);
			}
			set_size_slide( (SIZE_MAX* nline)/ tot, slide);
			set_pos_slide( first, slide);
		}
		else{
			gest.aff[i]= gest.appl;
			set_size_slide( SIZE_MAX, slide);
			set_pos_slide( POS_MIN, slide);
		}
	}
}

/********************************************************************/
void step_page( act, sf)	/* action dans le bandeau de droite  de la fenetre */
int act;				/* action demand‚e */
register int sf;
{
	register int ob, app_max, first, nline;
	register OBJECT *rsc;

	rsc= Adr_rsc;
	ob= get_sf_slide( sf);
	nline= NLINES;
	first= getIndAppl( gest.aff[sf]);
	if( (app_max= count_appls()- nline)> 0)
	{
		switch( act){
			case LINEUP:			/* ligne sup‚rieure */
				nline= 1;
			case PAGEUP:			/* page sup‚rieure */
				if( (first-= nline) < 0)
					first= 0;
				break;
			case LINEDOWN:			/* ligne inf‚rieure */
				nline= 1;
			case PAGEDOWN:			/* page inf‚rieure */
				if( (first+= nline) > app_max)
					first= app_max;
				break;
		}
		set_appl_first( first, sf);
		set_pos_slide( first, ob);
		objc_draw( Adr_rsc, get_parent( ob), 2, xwork, ywork, wwork, hwork);
		set_clip( clip[sf].g_x, clip[sf].g_y, clip[sf].g_w, clip[sf].g_h);
		aff_appls( gest.aff[sf], gest.state, gest.sel, sf);
		set_clip( xwork, ywork, wwork, hwork);
	}	
}

/********************************************************************/
void chge_page( pos, sf)		/* action sur l'ascenceur vertical */
register int pos, sf;		/* nlle position de l'ascenceur */
{
	register OBJECT *rsc;
	register int line, nline, first;
	int ob;

	pos/= 10;
	rsc= Adr_rsc;
	nline= NLINES;
	if( (line= count_appls()- nline) > 0){
		set_appl_first( first= pos* line/ POS_MAX, sf);
		set_pos_slide( first, ob= get_sf_slide( sf));
		objc_draw( Adr_rsc, get_parent( ob), 2, xwork, ywork, wwork, hwork);
		set_clip( clip[sf].g_x, clip[sf].g_y, clip[sf].g_w, clip[sf].g_h);
		aff_appls( gest.aff[sf], gest.state, gest.sel, sf);
		set_clip( xwork, ywork, wwork, hwork);
	}
}

/******************************** fin ********************************/
