/********************************************************************************/
/*                     MIDI SHARE Application Midi Connecte                     */
/*------------------------------------------------------------------------------*/
/*		CON_AFF.C													*/
/*		Module de gestion des affichages								*/
/*------------------------------------------------------------------------------*/
/*		@ GRAME 1989/90, Yann Orlarey et Herv‚ Lequay 					*/
/*					  Dominique Fober (Atari ST)						*/
/********************************************************************************/

#include <stdio.h>
#include <msh_unit.h>
#include <string.h>

#ifdef MWC
# include <obdefs.h>
# include <gemdefs.h>
# include <aesbind.h>
# include <vdibind.h>
# include <osbind.h>
#endif

#ifdef TURBO_C
# include <aes.h>
# include <vdi.h>
# include <tos.h>
#endif

#include "msnet.h"
#include "con_defs.h"


#define MAX_NAME	14		/* longueur max d'affichage d'un nom */

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

/*---------------------------------------------------------------*/
/* les variables du module								*/
GRECT clip[3];		/* clippings de chaque sous fenetre		*/

/*---------------------------------------------------------------*/
void clear_sf( x, y, w, h)
int x, y, w, h;
{
	int rect[4];

	rect[0]= x+1;
	rect[1]= y+1;
	rect[2]= rect[0]+ w- 2;
	rect[3]= rect[1]+ h- 2;
	vsf_color( handle, 0);
	hide_mouse();
	v_bar( handle, rect);
	show_mouse();
}

/*---------------------------------------------------------------*/
void init_aff()
{
	int ret;

	vst_color( handle, 1);
	vst_alignment( handle, 1, 0, &ret, &ret);
	vst_height( handle, 6, &ret, &ret, &ret, &ret);
}

/*---------------------------------------------------------------*/
void get_sf_clips()
{
	register short i, p1, p2;
	register OBJECT *rsc;
	
	rsc= Adr_rsc;
	for(i=0; i<3; i++)
	{
		switch( i)
		{
			case SFIN:
				p1= FIN; p2= IN;
				break;
			case SFOUT:
				p1= FOUT; p2= OUT;
				break;
			case SFAPP:
				p1= FAPP; p2= APP;
				break;
		}
		clip[i].g_x= xwork + rsc[p1].ob_x + rsc[p2].ob_x + 1;
		clip[i].g_y= ywork + rsc[p1].ob_y + rsc[p2].ob_y + 1;
		clip[i].g_w= rsc[p2].ob_width - 2;
		clip[i].g_h= rsc[p2].ob_height - 2;
	}
}

/*---------------------------------------------------------------*/
void	reverse( handle, sf, y)
register int handle;
int sf, y;
{
	int rect[4];
	
	rect[0]= clip[sf].g_x + 1;
	rect[1]= y+ 2;
	rect[2]= rect[0]+ clip[sf].g_w- 2;
	rect[3]= rect[1]+ H_LINE;
	vswr_mode( handle, 3);		/* mode XOR (reverse vid‚o) */
	hide_mouse();
	v_bar( handle, rect);
	show_mouse();
	vswr_mode( handle, 1);		/* restaure le mode replace */
}

/*---------------------------------------------------------------*/
void aff_appls( appl, state, sel, sf)
register APPL *appl, *sel;
register short sf;
Boolean state;
{
	register char *cnct;
	register short x, y, limit, i;
	char buff[MAX_NAME+1];
	int rect[4];
	Boolean invert;
	
	buff[MAX_NAME]= 0;
	if( state && sel)
	{
		if( sf == SFIN)
			cnct= sel->in;
		else if( sf ==SFOUT)
			cnct= sel->out;
	}
	i= getIndAppl( appl);
	rect[0]= clip[sf].g_x+ 1;
	rect[2]= rect[0]+ clip[sf].g_w- 2;
	x= clip[sf].g_x + (clip[sf].g_w/2);
	y= clip[sf].g_y;
	limit= clip[sf].g_h/ H_LINE + i;
	init_aff();
 	for( i; (i < limit) && appl; i++)
	{
		y+= H_LINE;
		buff[0]= 0;
		invert= FALSE;
		if( state)
		{
			if( sf== SFAPP)
			{
				if( appl== sel)
					invert= TRUE;
			}
			else if( IsAcceptedBit(cnct,i))
				invert= TRUE;
		}
		rect[1]= y- H_LINE+ 2;
		rect[3]= rect[1]+ H_LINE+ 1;
		vsf_color( handle, 0);
		hide_mouse();
		v_bar( handle, rect);
		vst_color( handle, 1);
		v_gtext( handle, x, y, strncpy( buff, appl->name, MAX_NAME));
		if( invert)
			reverse( handle, sf, y-H_LINE);
		show_mouse();
		appl= appl->next;
	}
}

/*---------------------------------------------------------------*/
void aff_state_appls()
{
	register Boolean state;
	
	state= gest.state;
	set_clip( clip[SFAPP].g_x, clip[SFAPP].g_y, clip[SFAPP].g_w, clip[SFAPP].g_h);
	aff_appls( gest.aff[SFAPP], state, gest.sel, SFAPP);
	if( state)
	{
		set_clip( clip[SFIN].g_x, clip[SFIN].g_y, clip[SFIN].g_w, clip[SFIN].g_h);
		aff_appls( gest.aff[SFIN], state, gest.sel, SFIN);
		set_clip( clip[SFOUT].g_x, clip[SFOUT].g_y, clip[SFOUT].g_w, clip[SFOUT].g_h);
		aff_appls( gest.aff[SFOUT], state, gest.sel, SFOUT);
	}
	set_clip( xwork, ywork, wwork, hwork);
}

/*---------------------------------------------------------------*/
APPL *applFind( y, appl)
register int y;
register APPL *appl;
{
	register int i;

	y-= clip[SFAPP].g_y+ 2;
	y/= H_LINE;
	for( i=0; (i<y) && appl; i++)
		appl= appl->next;
	return appl;
}

/*---------------------------------------------------------------*/
void applSelect( y)
register int y;
{
	register APPL *appl;

	if( appl= applFind( y, gest.aff[SFAPP]))
	{
		if( appl== gest.sel)
		{
			gest.state= FALSE;
			gest.sel= (APPL *)NULL;
			clear_sf( clip[SFIN].g_x, clip[SFIN].g_y, clip[SFIN].g_w, clip[SFIN].g_h);
			clear_sf( clip[SFOUT].g_x, clip[SFOUT].g_y, clip[SFOUT].g_w, clip[SFOUT].g_h);
		}
		else
		{
			gest.state= TRUE;
			gest.sel= appl;
		}
		aff_state_appls();
	}
}

/*---------------------------------------------------------------*/
void chge_connect( i, sf)
register int i, sf;
{
	register APPL *appl, *sel;
	register char *cnct;
	APPL *first;

	if( sel= gest.sel)
	{
		if( sf== SFIN)
			cnct= sel->in;
		else if( sf== SFOUT)
			cnct= sel->out;
		else return;
		appl= applFind( i, first= gest.aff[sf]);
	}
	else return;
	if( appl) i= getIndAppl( appl);
	else return;
	if( sf== SFIN)
		MidiConnect( appl->refnum, sel->refnum, !IsAcceptedBit( cnct, i));
	else if( sf== SFOUT)
		MidiConnect( sel->refnum, appl->refnum, !IsAcceptedBit( cnct, i));

	set_clip( clip[sf].g_x, clip[sf].g_y, clip[sf].g_w, clip[sf].g_h);
	reverse( handle, sf, clip[sf].g_y + ((i-getIndAppl(first))* H_LINE));
	if( getIndAppl( sel)== i)
	{
		sf= ( sf== SFIN) ?  SFOUT : SFIN;
		set_clip( clip[sf].g_x, clip[sf].g_y, clip[sf].g_w, clip[sf].g_h);
		reverse( handle, sf, clip[sf].g_y + ((i-getIndAppl(gest.aff[sf]))* H_LINE));
	}
	set_clip( xwork, ywork, wwork, hwork);
}

/*---------------------------- fin ------------------------------*/
