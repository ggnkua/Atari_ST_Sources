/*********************************************
 *   Fenetre.o
 *	GŠre les fenetres autre que celle avec formulaire
 */

#include <stdlib.h>
#include <gemfast.h>
#include "not_falc.h"
#include "windform.h"

void		open_wind(WINDFORM_VAR *nw);
void		redraw (int x,	 int y,	 int w,	 int h);
void		sized (WINDFORM_VAR *nw);
void		fulled (WINDFORM_VAR *nw);
void		arrow (WINDFORM_VAR *nw);
void		hslider (WINDFORM_VAR *nw);
void		vslider (WINDFORM_VAR *nw);
void		sliders (WINDFORM_VAR *nw);
void		set_clip (int clip_flag,	 GRECT *area);
void		wind(int evnt,	WINDFORM_VAR *nw);
void		w_redraw(WINDFORM_VAR w);

extern	void affiche(void);
extern	void *cherche_objet(void *obj,	int ligne,	int *compte);
extern	void selectionne_item(WINDFORM_VAR *nw);
extern	void modif_objet(void *obj);

extern int	_global[],	buf[],	VDIhandle,	ap_id;
extern int	xb,	yb,	wb,	hb,	mb_return,	m_text_crsr;
extern long	n_liste;
extern OBJECT *adr_icon;
extern WINDFORM_VAR	prog;

/* Ouvre la fenˆtre :	*/
void open_wind (WINDFORM_VAR *nw)
{
int x,	y,	w,	h,	attr;

	if (nw->w_handle > 0) /* Si la fenˆtre est d‚j… ouverte	*/
	{
		wind_set (nw->w_handle,	 WF_NAME,	 (char *)(nw->adr_form)); 	/* Titre fenˆtre	*/
		wind_set (nw->w_handle,	 WF_TOP);  /* On la passe au premier plan	*/
	}
	else
	{
		nw->w_x=xb;
		nw->w_y=yb;
		nw->w_w=wb;
		nw->w_h=hb;

		nw->w_handle = wind_create (nw->w_attr,	 nw->w_x,	 nw->w_y,	nw->w_w,	 nw->w_h);			/* Cr‚er la fenˆtre	*/
		if (nw->w_handle > 0)																	/* Si fenˆtre bien cr‚‚e	*/
		{
			wind_set (nw->w_handle,	 WF_NAME,	 (char *)(nw->adr_form)); 	/* Titre fenˆtre	*/
			wind_open (nw->w_handle,	nw->w_x,	 nw->w_y,	nw->w_w,	 nw->w_h);	/* Ouverture fenˆtre	*/
			sliders(nw);
		}
		else													/* Si la fenˆtre n'a pu ˆtre cr‚‚e	*/
		{
			nw->w_handle = 0;
		}
	}
}

/* Redraw :	*/
void redraw (int x,	 int y,	 int w,	 int h)
{
int xw,	 yw,	 ww,	 hw,	 pxy[8];
GRECT r,	 rd;
MFDB nul = {0};
WINDFORM_VAR *nw;
int icon=0,	dummy;

#ifndef NOT_FALCON
	wind_get(buf[3],	WF_ICONIFY,	&icon,	&dummy,	&dummy,	&dummy);		/* Iconifier ??	*/
#endif

	rd.g_x = x; 	/* Coordonn‚es rectangle … redessiner	*/
	rd.g_y = y;
	rd.g_w = w;
	rd.g_h = h;
	
	wind_get (buf[3],	 WF_WORKXYWH,	 &xw,	 &yw,	 &ww,	 &hw);
	v_hide_c (VDIhandle);	/* Virer la souris	*/
	wind_update (BEG_UPDATE); 	/* Bloquer les fonctions de la souris	*/

		/* Demande les coord. et dimensions du 1ø rectangle de la liste	*/
	wind_get (buf[3],	 WF_FIRSTXYWH,	 &r.g_x,	 &r.g_y,	 &r.g_w,	 &r.g_h);
	while (r.g_w && r.g_h)			/* Tant qu'il y a largeur ou hauteur...	*/
	{
		if (rc_intersect (&rd,	 &r)) /* Si intersection des 2 zones	*/
		{
			if (icon)
			{
				wind_get(buf[3],	 WF_WORKXYWH,	 &adr_icon->ob_x,	 &adr_icon->ob_y,	&dummy,	 &dummy);
				objc_draw(adr_icon,	 ROOT,	 1,	 r.g_x,	 r.g_y,	 r.g_w,	 r.g_h);
			}
			else
			{
				set_clip(1,	&r);
				vsf_color(VDIhandle,	0);
				vsf_interior(VDIhandle,	0);
				pxy[0]=x;	pxy[1]=y;
				pxy[2]=x+w;	pxy[3]=y+h;
				vr_recfl(VDIhandle,	pxy);
				affiche();
				set_clip(0,	&r);
			}
		}
			/* Rectangle suivant	*/
		wind_get (buf[3],	 WF_NEXTXYWH,	 &r.g_x,	 &r.g_y,	 &r.g_w,	 &r.g_h);
	}
	wind_update (END_UPDATE); 	/* D‚bloquer les fonctions de la souris	*/
	v_show_c (VDIhandle,	 1); 			/* Rappeler la souris	*/
}

/* Redimensionnement fenˆtre :	*/
void sized (WINDFORM_VAR *nw)
{
int xw,	 yw,	 ww,	 hw;		/* Coordonn‚es zone de travail	*/

		/* Calculer coordonn‚es zone de travail	*/
	wind_calc (WC_WORK,	 nw->w_attr,	 buf[4],	 buf[5],	 buf[6],	 buf[7],	 &xw,	 &yw,	 &ww,	 &hw);
		/* Recalculer coordonn‚es totales fenˆtre	*/
	wind_calc (WC_BORDER,	 nw->w_attr,	 xw,	 yw,	 ww,	 hw,	 &buf[4],	 &buf[5],	 &buf[6],	 &buf[7]);
		/* Nouvelles coordonn‚es :	*/
	wind_set (buf[3],	 WF_CURRXYWH,	 buf[4],	 buf[5],	 buf[6],	 buf[7]);
	nw->w_x=buf[4];
	nw->w_y=buf[5];
	nw->w_w=buf[6];
	nw->w_h=buf[7];

	nw->w_ful = 0;						/* Annuler le flag de pleine ouverture	*/
	sliders (nw);					/* Tailles et positions sliders	*/
}

/* Fulled :	*/
void fulled (WINDFORM_VAR *nw)
{
int x,	 y,	 w,	 h,	 xw,	 yw,	 ww,	 hw;

	if (nw->w_ful)					/* Si elle est d‚j… plein pot	*/
	{
		wind_get (buf[3],	 WF_PREVXYWH,	 &x,	 &y,	 &w,	 &h); /* Coord. pr‚c‚dentes	*/
		nw->w_ful = 0;									/* Annuler flag	*/
	}
	else											/* Sinon	*/
	{
		x = xb; /* Coord. maxi	= bureau	*/
		y = yb;
		w = wb;
		h = hb;
		nw->w_ful = 1;									/* Positionner flag	*/
	}
		/* Coordonn‚es zone de travail	*/
	wind_calc (WC_WORK,	 nw->w_attr,	 x,	 y,	 w,	 h,	 &xw,	 &yw,	 &ww,	 &hw);
	wind_calc (WC_BORDER,	 nw->w_attr,	 xw,	 yw,	 ww,	 hw,	 &x,	 &y,	 &w,	 &h);
	wind_set (buf[3],	 WF_CURRXYWH,	 x,	 y,	 w,	 h); 				/* Nouvelles coordonn‚es	*/
	nw->w_x=x;
	nw->w_y=y;
	nw->w_w=w;
	nw->w_h=h;


	sliders (nw); /* Ajuster tailles et positions sliders	*/
}

/* Arrow :	*/
void arrow (WINDFORM_VAR *nw)
{
int xw,	 yw,	 ww,	 hw;
int wc,	hc,	dummy;
int attr[10];

	vqt_attributes(VDIhandle,	 attr);

		/* Coordonn‚es zone de travail :	*/
	wind_get (nw->w_handle,	 WF_WORKXYWH,	 &xw,	 &yw,	 &ww,	 &hw);
	wc=ww/attr[8];		hc=hw/attr[9];

	switch (buf[4])
	{
	case WA_UPPAGE :				/* Page vers le haut	*/
		if (nw->w_lin > 0)	/* Si on n'est pas d‚j… au d‚but	*/
		{
			nw->w_lin = max (nw->w_lin - hc,	 0);	/* Nouvelle ligne	*/
			dummy=0;
			curr_aff=cherche_objet(start,	nw->w_lin,	&dummy);
			redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
			sliders (nw); 				/* Actualiser les sliders	*/
		}
		break;
	case WA_DNPAGE :				/* Page vers le bas	*/
		if ((nw->w_lin + hc) < n_liste)	/* Si pas d‚j… … la fin	*/
		{
			nw->w_lin = min (nw->w_lin + hc,	 n_liste - hc);	/* Nouvelle ligne	*/
			dummy=0;
			curr_aff=cherche_objet(start,	nw->w_lin,	&dummy);
			redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
			sliders (nw); 				/* Actualiser les sliders	*/
		}
		break;
	case WA_UPLINE :				/* Ligne vers le haut	*/
		if (nw->w_lin > 0)	/* Si on n'est pas d‚j… au d‚but	*/
		{
			nw->w_lin -= 1;		/* Nouvelle ligne	*/
			if (nw->w_lin < 0)
				nw->w_lin = 0;
			dummy=0;
			curr_aff=cherche_objet(start,	nw->w_lin,	&dummy);
			redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
			sliders (nw); 				/* Actualiser les sliders	*/
		}
		break;
	case WA_DNLINE :				/* Ligne vers le bas	*/
		if ((nw->w_lin + hc) < n_liste)	/* Si pas d‚j… … la fin	*/
		{
			nw->w_lin += 1;		/* Nouvelle ligne	*/
			if (nw->w_lin + hc > n_liste)
				nw->w_lin = n_liste - hc;
			dummy=0;
			curr_aff=cherche_objet(start,	nw->w_lin,	&dummy);
			redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
			sliders (nw); 				/* Actualiser les sliders	*/
		}
		break;
	case WA_LFPAGE :				/* Page vers la gauche	*/
		if (nw->w_col > 0)	/* Si on n'est pas d‚j… au d‚but	*/
		{
			nw->w_col = max (nw->w_col - wc,	 0);	/* Nouvelle colonne	*/
			redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
			sliders (nw); 				/* Actualiser les sliders	*/
		}
		break;
	case WA_RTPAGE :				/* Page vers la droite	*/
		if ((nw->w_col + wc) < 256)	/* Si pas d‚j… … la fin	*/
		{
			nw->w_col = min (nw->w_col + wc,	 256 - wc);	/* Nouvelle colonne	*/
			redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
			sliders (nw); 				/* Actualiser les sliders	*/
		}
		break;
	case WA_LFLINE :				/* Ligne vers la gauche	*/
		if (nw->w_col > 0)	/* Si on n'est pas d‚j… au d‚but	*/
		{
			nw->w_col -= 1;		/* Nouvelle colonne	*/
			if (nw->w_col < 0)
				nw->w_col = 0;
			redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
			sliders (nw); 				/* Actualiser les sliders	*/
		}
		break;
	case WA_RTLINE :				/* Ligne vers la droite	*/
		if ((nw->w_col + wc) < 256)	/* Si pas d‚j… … la fin	*/
		{
			nw->w_col += 1;		/* Nouvelle colonne	*/
			if (nw->w_col + wc > 256)
				nw->w_col = 256 - wc;
			redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
			sliders (nw); 				/* Actualiser les sliders	*/
		}
		break;
	}
}

/* Slider H :	*/
void hslider (WINDFORM_VAR *nw)
{
int slide,	 xw,	 yw,	 ww,	 hw;
int wc;
int attr[10];

	vqt_attributes(VDIhandle,	 attr);

	slide = buf[4];
	wind_get (buf[3],	 WF_WORKXYWH,	 &xw,	 &yw,	 &ww,	 &hw);
	wc=ww/attr[8];
	
		/* Calcul de la colonne :	*/
	nw->w_col = ((long)slide * (256 - (long)wc) / 1000);
	if (nw->w_col + wc > 256)	/* Corrections	*/
		nw->w_col = 256 - wc;
	if (nw->w_col < 0)
		nw->w_col = 0;
	wind_set (buf[3],	 WF_HSLIDE,	 slide);
	redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
}

/* Slider V :	*/
void vslider (WINDFORM_VAR *nw)
{
int slide,	 xw,	 yw,	 ww,	 hw;
int hc;
int attr[10];

	vqt_attributes(VDIhandle,	 attr);

	slide = buf[4];
	wind_get (buf[3],	 WF_WORKXYWH,	 &xw,	 &yw,	 &ww,	 &hw);
	hc=hw/attr[9];
	
		/* Calcul de la ligne :	*/
	nw->w_lin = ((long)slide * (n_liste - (long)hc) / 1000);
	if (nw->w_lin + hc > n_liste)	/* Corrections	*/
		nw->w_lin = n_liste - hc;
	if (nw->w_lin < 0)
		nw->w_lin = 0;
	wind_set (buf[3],	 WF_VSLIDE,	 slide);
	hc=0;		/*	evite de cr‚er un dummy	pour cherche_objet	*/
	curr_aff=cherche_objet(start,	nw->w_lin,	&hc);
	redraw (xw,	 yw,	 ww,	 hw);	/* R‚affichage	*/
}

/* Taille et position sliders :	*/
void sliders (WINDFORM_VAR *nw)
{
int slide,	 xw,	 yw,	 ww,	 hw;
int wc,	hc;
int attr[10];

	vqt_attributes(VDIhandle,	 attr);

		/* Coordonn‚es zone de travail :	*/
	wind_get (nw->w_handle,	 WF_WORKXYWH,	 &xw,	 &yw,	 &ww,	 &hw);
	wc=ww/attr[8];		hc=hw/attr[9];

	if(n_liste==0)
		wind_set (nw->w_handle,	 WF_VSLSIZE,					/* Taille slider vertical	*/
						(int)( (long)hc *1000) );
	else
		wind_set (nw->w_handle,	 WF_VSLSIZE,					/* Taille slider vertical	*/
						(int)( (long)hc *1000/n_liste) );

	nw->w_lin = min (nw->w_lin,	 n_liste - hc); /* Calculer la ligne	*/
	nw->w_lin = max (0,	 nw->w_lin);
	wind_set (nw->w_handle,	 WF_HSLSIZE,					/* Taille slider horizontal	*/
						(int)((long)wc*1000 /256 ));
	nw->w_col = min (nw->w_col,	 256 - wc); /* Calculer la colonne	*/
	nw->w_col = max (0,	 nw->w_col);
	slide = (long)nw->w_lin * 1000 / (long)(n_liste - hc); 	/* Position slider vertical	*/
	if (slide < 0)
		slide = 0;
	if (slide > 1000)
		slide = 1000;
	wind_set (nw->w_handle,	 WF_VSLIDE,	 slide);
	slide = (long)nw->w_col * 1000 / (long)(256 - wc); 	/* Position slider horizontal	*/
	if (slide < 0)
		slide = 0;
	if (slide > 1000)
		slide = 1000;
	wind_set (nw->w_handle,	 WF_HSLIDE,	 slide);
}

void set_clip (int clip_flag,	 GRECT *area)
{
int pxy[4];

	pxy[0] = area->g_x;
	pxy[1] = area->g_y;
	pxy[2] = area->g_w + area->g_x - 1;
	pxy[3] = area->g_h + area->g_y - 1;
	vs_clip (VDIhandle,	 clip_flag,	 pxy);
}

void wind(int evnt,	WINDFORM_VAR *nw)
{
int wx,	wy,	ww,	wh;

	if(evnt & MU_MESAG)
	{
		switch (buf[0])
		{
		case	WM_REDRAW:
			redraw(buf[4],	buf[5],	buf[6],	buf[7]);
			break;
		case WM_TOPPED:
			wind_set(buf[3],	WF_TOP);
			break;
		case	WM_CLOSED:
			wind_close(buf[3]);		/* on vire la fenetre	*/
			wind_delete(buf[3]);
			nw->w_handle=NULL;	
			break;
		case WM_FULLED:
			fulled(nw);
			break;
		case WM_ARROWED:
			arrow(nw);
			break;
		case WM_HSLID:
			hslider(nw);
			break;
		case WM_VSLID:
			vslider(nw);
			break;
		case WM_SIZED:
			sized(nw);
			break;
		case WM_BOTTOMED:
			wind_set(buf[3],	WF_BOTTOM,	0,	0,	0,	0);
			break;
		case WM_MOVED:
			wind_set(buf[3],	WF_CURRXYWH,	buf[4],	buf[5],	buf[6],	buf[7]);
			nw->w_x=buf[4];
			nw->w_y=buf[5];
			nw->w_w=buf[6];
			nw->w_h=buf[7];
			nw->w_ful=0;	/* annuler flag full window	*/
			break;
		case WM_ICONIFY :
			wind_set(buf[3],	 WF_ICONIFY,	 buf[4],	 buf[5],	 buf[6],	 buf[7]);
			nw->w_x = buf[4]; nw->w_y = buf[5];
			nw->w_w = buf[6]; nw->w_h = buf[7];
			wind_get(buf[3],	 WF_WORKXYWH,	 &wx,	 &wy,	 &ww,	 &wh);
			adr_icon->ob_x = wx + nw->offset;
			adr_icon->ob_y = wy + nw->offset;
			break;
		case WM_UNICONIFY :
			wind_set(buf[3],	 WF_UNICONIFY,	 buf[4],	 buf[5],	 buf[6],	 buf[7]);
			wind_set(buf[3],	 WF_CURRXYWH,	 buf[4],	 buf[5],	 buf[6],	 buf[7]);
			nw->w_x = buf[4]; nw->w_y = buf[5];
			nw->w_w = buf[6]; nw->w_h = buf[7];
			wind_get(buf[3],	 WF_WORKXYWH,	 &wx,	 &wy,	 &ww,	 &wh);		/* virer ‡… on est pas sur un formulaire en fenetre */
			nw->adr_form->ob_x = wx + nw->offset;
			nw->adr_form->ob_y = wy + nw->offset;
			break;
		}
	}
	else if (evnt & MU_BUTTON)
	{
		if (nw == &prog)
		{
			selectionne_item(nw); 
			if (mb_return==2)			/*	Si on a cliquer 2 fois	*/
			{
				modif_objet(sel_obj);
			}
		}
	}
	
	if (evnt & MU_TIMER)
	{
		if (m_text_crsr==TRUE)
		{
			m_text_crsr=FALSE;
			graf_mouse(ARROW,	0);
		}
	}
}

void w_redraw(WINDFORM_VAR w)
{
		buf[0]=WM_REDRAW;							/*on genere un message de redraw*/
		buf[1]=ap_id;
		buf[2]=0;
		buf[3]=w.w_handle;
		buf[4]=w.w_x;
		buf[5]=w.w_y;
		buf[6]=w.w_w;
		buf[7]=w.w_h;
		appl_write(ap_id,	16,	buf);
}