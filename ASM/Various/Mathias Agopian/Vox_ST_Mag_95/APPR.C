#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <math.h>

#include "DEFINES.H"
#include "MAIN.H"
#include "VOX_H.H"
#include "VOX.H"
#include "HARD.H"
#include "DEF_VOX.H"
#include "SENDKEY.H"

extern OBJECT *menutree;
extern OBJECT *adr_menu;
extern WINDOW window[nb_window+1];
extern int handle,ap_id;
extern int mx,my,mk,kbd,key,clik,objet;
extern int actif;
extern int SeuilStart,SeuilEnd;

volatile extern int dsp_ready;
volatile extern int dsp_seuil;

LISTE_MOTS liste_mots;
char *inconnu="Mot inconnu";

/* Liste des mots … apprendre */

char *ptr_mots[DefMaxMots]={	"Bonjour",
 								"Information",
 								"Termine",
 								"Ferme",
 								"Monte",
 								"Descend",
 								"Monte page",
 								"Descend page",
 								"Droite",
 								"Gauche",
 								"Page droite",
 								"Page gauche",
 								"Valider",
 								"Couper",
 								"Copier",
 								"Coller"
 							};

char *alerte_txt[3]={	"Prononcez distinctement le mot",
						"Encore une fois, prononcez le mot",
						"Incorrect! Recomman‡ons. Prononcez le mot" };

int samples[Npoints];
int env[3][Npoints];
int moy[DefMaxMots][3][Npoints];		
int mode_appr=0;

double FTauxAppr=0.80;
double FTauxReco=0.80;
double FTauxMin=0.50;


void Affiche_curs(OBJECT *adr,int curs,int gliss,LISTE_MOTS *liste,int xcl,int ycl,int wcl,int hcl);
void aff_liste(OBJECT *adr,LISTE_MOTS *liste);
void gere_liste_clic(int my,LISTE_MOTS *liste);
void apprend(LISTE_MOTS *liste);
int	reconnaissance(int *samples,int nb,double errmot,double *err);
void get_menu(OBJECT *adr,int *nbtitle);
int GereFntCurs(OBJECT *adr, int curs, int gliss, LISTE_MOTS *liste);


void apprentissage(int objet)
{
	switch(objet)
	{
		case F0_B_EXIT:
			WindClose(W_F0);
			break;
		case F0_AFF:
			if (!mode_appr)
			{
				gere_liste_clic(my,&liste_mots);
				if (clik<2)
					break;
			}
			else
				break;
		case F0_B_APPR:
			if ((!mode_appr) && (liste_mots.selected>=0))
			{
	    		if (actif)
	    		{
	    			actif=FALSE;
		    		menu_icheck(adr_menu,M0_RECO,actif);
	    			stop_dsp();
	    		}
				mode_appr=1;
				apprend(&liste_mots);
			}
			break;
		case F0_UP:
			if (liste_mots.first>0)
			{
				liste_mots.first--;
				redraw_w_objc(W_F0,F0_AFF);
				redraw_w_objc(W_F0,F0_GLISS);
			}
			break;
		case F0_DOWN:
			if ((liste_mots.first+liste_mots.nmaxmots)<liste_mots.nmots)
			{
				liste_mots.first++;
				redraw_w_objc(W_F0,F0_AFF);
				redraw_w_objc(W_F0,F0_GLISS);
			}
			break;
		case F0_CURS:
			if (GereFntCurs(window[W_F0].form,F0_CURS,F0_GLISS,&liste_mots))
				redraw_w_objc(W_F0,F0_AFF);
			break;
	}
}

/* Ici, l'ordinateur essaye de reconnaitre le mot *
 * prononc‚ et execute la commande correspondante */

void recognize(LISTE_MOTS *liste)
{
	static int buf[8];
	static oldchoix=-1;
	int choix;
	int wh,owner;
	int dummy;
	int x0,y0;
	int nbgtitle;
	OBJECT *adr;
	double err;
	if (dsp_ready)
	{
	
		/* Acquisition des enveloppes en provenance du DSP */
		get_samples(Npoints,samples);
		
		/* Reconnaissance du mots proprement dite */
		choix=reconnaissance(samples,liste->nmots,FTauxReco,&err);

		/* Affichage du mot reconnu */
		if (choix!=oldchoix)
		{
			oldchoix=choix;
			adr=window[W_F1].form;
			if (choix<(liste->nmots))
				adr[F1_MOT].ob_spec.tedinfo->te_ptext=ptr_mots[choix];
			else
				adr[F1_MOT].ob_spec.tedinfo->te_ptext=inconnu;
			objc_offset(adr,F1_MOT,&x0,&y0);
			send_redraw_message(window[W_F1].hwind,x0,y0,adr[F1_MOT].ob_width,adr[F1_MOT].ob_height);
		}
		
		/* execution de la commande associ‚e */
		switch(choix)
		{
			case 0:
				wind_form(W_INFOS);
				break;
			case 1:
				owner=menu_bar(0,-1);
				get_menu(menutree,&nbgtitle);
				buf[0]=MN_SELECTED;		/* Num‚ro du message */
				buf[1]=ap_id;			/* Indentificateur exp‚diteur du message */
				buf[2]=0;				/* Pas d'exc‚dent au message */
				buf[3]=3;				/* title */
				buf[4]=nbgtitle+5;		/* item -> INFORMATION */
				appl_write(owner,16,buf);
				break;
			case 2:
				if (alerte(A_QUIT)==1)
				{
					owner=menu_bar(0,-1);
					buf[0]=AP_TERM;			/* Num‚ro du message */
					buf[1]=ap_id;			/* Indentificateur exp‚diteur du message */
					buf[2]=0;				/* Pas d'exc‚dent au message */
					buf[5]=AP_TERM;			/* Handle fenˆtre concern‚e */
					appl_write(owner,16,buf);
				}
				break;
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
			case 9:
			case 10:
			case 11:
				my_wind_get(0,WF_TOP,&wh,&owner,&dummy,&dummy);
				buf[1]=ap_id;			/* Indentificateur exp‚diteur du message */
				buf[2]=0;				/* Pas d'exc‚dent au message */
				buf[3]=wh;				/* Handle fenˆtre concern‚e */
				buf[0]=WM_ARROWED;
				switch (choix)
				{
					case 3:		buf[0]=WM_CLOSED;	break;
					case 4:		buf[4]=WA_UPLINE;	break;
					case 5:		buf[4]=WA_DNLINE;	break;
					case 6:		buf[4]=WA_UPPAGE;	break;
					case 7:		buf[4]=WA_DNPAGE;	break;
					case 8:		buf[4]=WA_RTLINE;	break;
					case 9:		buf[4]=WA_LFLINE;	break;
					case 10:	buf[4]=WA_RTPAGE;	break;
					case 11:	buf[4]=WA_LFPAGE;	break;
				}
				appl_write(owner,16,buf);
				break;
			case 12:	
				SendKey(0x1c,0xd);
				break;
			case 13:
				SendKey(0x2d,0x18);
				break;
			case 14:
				SendKey(0x2e,0x03);
				break;
			case 15:
				SendKey(0x2f,0x16);
				break;
		}
		set_trigger(SeuilStart,SeuilEnd);
		vox();
	}
}


/* Reconnaissance preprement dite 		*/
/* on applique Pearson pour chaque mots */
/* de la banque de donn‚e, si un mot	*/
/* obtient un score assez grand, on note */
/* ce score, le mot reconnu est celui qui */
/* obtient le meilleur score … Pearson	*/

int	reconnaissance(int *samples,int nb,double errmot,double *err)
{
	int i,hit;
	double erreur;
	double a,b,c;
	hit=nb+1;
	
	/* Optimisation de l'amplitude */
	optimise(samples,Npoints*3);
	
	/* copie des trois enveloppes dans des tableau separ‚s */
	copy_tab(samples  ,env[0],3,Npoints);
	copy_tab(samples+1,env[1],3,Npoints);
	copy_tab(samples+2,env[2],3,Npoints);
	
	/* repeter pour chaque mot */
	for(i=0;i<nb;i++)
	{
		/* Pearson pour chaque enveloppe */
		a=pearson(moy[i][0],env[0],Npoints);
		b=pearson(moy[i][1],env[1],Npoints);
		c=pearson(moy[i][2],env[2],Npoints);
		
		/* Le score est il suffisant ? */
		if ((a<FTauxMin) || (b<FTauxMin) || (c<FTauxMin))
			erreur=0;
		else
		
			/* oui, alors on fait la moyenne */
			erreur=(a+b+c)/3.0;
			
		/* on conserve le meilleur score */		
		if (erreur>errmot)
		{
			errmot=erreur;
			hit=i;
		}
	}
	*err=errmot;
	return hit;
}


/*  Apprentissage d'un mot */
void apprend(LISTE_MOTS *liste)
{
	static int i=0;
	int j,k;
	int apmot;
	OBJECT *adr_dia;
	rsrc_gaddr(0,F01,&adr_dia);
	adr_dia[F01_TXT_MOT].ob_spec.tedinfo->te_ptext=ptr_mots[liste->selected];
	apmot=liste->selected;
	
	switch(mode_appr)
	{
		case 0:
			i=0;
			break;
		case 1:
			adr_dia[F01_TXT_TEXT].ob_spec.tedinfo->te_ptext=alerte_txt[0];
		case 4:
			wind_form(W_F01);
			set_trigger(SeuilStart,SeuilEnd);
			vox();
			mode_appr=2;
			break;
		case 2:
			if (dsp_ready)
				mode_appr=3;
			break;
		case 3:
			WindClose(W_F01);
			get_samples(Npoints,samples);
			optimise(samples,Npoints*3);
			copy_tab(samples  ,env[0],3,Npoints);
			copy_tab(samples+1,env[1],3,Npoints);
			copy_tab(samples+2,env[2],3,Npoints);
			if (i==0)
			{
				for(j=0;j<3;j++)
					for(k=0;k<Npoints;k++)
						moy[apmot][j][k]=env[j][k];
				adr_dia[F01_TXT_TEXT].ob_spec.tedinfo->te_ptext=alerte_txt[1];
				mode_appr=4;
			}
			else
			{
				if ((pearson(moy[apmot][0],env[0],Npoints)<FTauxAppr) ||
					(pearson(moy[apmot][1],env[1],Npoints)<FTauxAppr) ||
					(pearson(moy[apmot][2],env[2],Npoints)<FTauxAppr))
				{
					i=-1;
					adr_dia[F01_TXT_TEXT].ob_spec.tedinfo->te_ptext=alerte_txt[2];
					mode_appr=4;
				}
				else
				{
					for(j=0;j<3;j++)
						for(k=0;k<Npoints;k++)
							moy[apmot][j][k]=moy[apmot][j][k]/2+env[j][k]/2;
					mode_appr=0;
					i=-1;
				}
			}
			i++;
			break;
	}
}

void gere_liste_clic(int my,LISTE_MOTS *liste)
{
	OBJECT *adr;
	int x0,y0;
	int new;
	adr=window[W_F0].form;
	objc_offset(adr,F0_AFF,&x0,&y0);
	y0+=4;
	new=(liste->first)+(max(0,my-y0)/(liste->hcar));
	if (new>=(liste->nmots))
		new=-1;
	if (new!=liste->selected)
	{
		redraw_w_objc(W_F0,F0_AFF);
		liste->selected=new;
	}
}

void aff_liste(OBJECT *adr,LISTE_MOTS *liste)
{
	register int i;
	int dummy;
	int j;
	int hcar;
	int x,y,x0,y0;
	int pxy[4];
	int first=liste->first;

	objc_offset(adr,F0_AFF,&x0,&y0);
	vst_height(handle,13,&dummy,&dummy,&dummy,&hcar);
	liste->hcar=hcar;
	pxy[0]=x0;
	pxy[2]=x0+adr[F0_AFF].ob_width-1;
	vswr_mode(handle,MD_REPLACE);
	vsf_color(handle,BLACK);
	
	liste->nmaxmots=(adr[F0_AFF].ob_height-4)/hcar;
	x=x0+5;
	y=y0+hcar+2;
	j=first+min(liste->nmaxmots,liste->nmots-first);
	for (i=first;i<j;i++)
	{
		vswr_mode(handle,MD_TRANS);
		v_gtext(handle,x,y,(liste->ptrmots)[i]);
		if ((liste->selected)==i)
		{
			vswr_mode(handle,MD_XOR);
			pxy[1]=y-hcar+2,pxy[3]=y+3;
			v_bar(handle,pxy);
		}
		y+=hcar;
	}
	vswr_mode(handle,MD_REPLACE);
}

void Affiche_curs(OBJECT *adr,int curs,int gliss,LISTE_MOTS *liste,int xcl,int ycl,int wcl,int hcl)
{
	int xc,yc,hc;
	int xg,yg,hg;
	objc_offset(adr,gliss,&xg,&yg);
	hg=adr[gliss].ob_height;
	objc_offset(adr,curs,&xc,&yc);
	hc=min(hg,max(16,(hg*(liste->nmaxmots))/(liste->nmots)));
	adr[curs].ob_height=hc;
	adr[curs].ob_y=((hg-hc-3)*(liste->first))/((liste->nmots)-(liste->nmaxmots));
	objc_draw(adr,F0_GLISS,MAX_DEPTH,xcl,ycl,wcl,hcl);
}


int GereFntCurs(OBJECT *adr,int curs,int gliss,LISTE_MOTS *liste)
{
	int dummy;
	int choix;
	int xc,yc,hc;
	int xg,yg,hg;
	int oldy,my;
	int ey=0;
	objc_offset(adr,curs,&xc,&yc);
	objc_offset(adr,gliss,&xg,&yg);
	hc=adr[curs].ob_height;
	hg=adr[gliss].ob_height;
	graf_mouse(4,0);
	oldy=adr[curs].ob_y;
	do
	{
		graf_mkstate(&mx,&my,&mk,&dummy);
		ey=max(0,(my-yg)-hc/2);
		ey=min(hg-hc,ey);
		if (ey!=oldy)
		{
			oldy=ey;
			adr[curs].ob_y=ey;
			send_redraw(window[W_F0].hwind,adr,gliss,MAX_DEPTH);
		}
	}while(mk&1);
	ey=max(yg,my-hc/2);
	ey=min(yg+hg-hc,ey);
	graf_mouse(0,0);
	choix=((ey-yg)*((liste->nmots)-(liste->nmaxmots)))/(hg-hc-3);
	if (choix==liste->first)
		return FALSE;
	liste->first=choix;	
	return TRUE;
}


void redraw_f0(OBJECT *adr,int x,int y,int w,int h)
{
	int pxy[4];
	objc_draw(adr,0,MAX_DEPTH,x,y,w,h);
	pxy[0]=x,pxy[1]=y,pxy[2]=x+w-1,pxy[3]=y+h-1;
	vs_clip(handle,1,pxy);
	v_hide_c(handle);
	aff_liste(adr,&liste_mots);
	v_show_c(handle,1);
	vs_clip(handle,0,pxy);
	Affiche_curs(adr,F0_CURS,F0_GLISS,&liste_mots,x,y,w,h);
}

void init_liste_mots(LISTE_MOTS *liste)
{
	liste->nmots=DefMaxMots;
	liste->nmaxmots=0;
	liste->hcar=16;
	liste->first=0;
	liste->selected=-1;
	liste->ptrmots=ptr_mots;
}


void get_menu(OBJECT *adr,int *nbt)
{
	int index=3;
	int cnt=0;
	int father=parent(adr,index);
	if (adr)
	{
		do
		{
			cnt++;
			index=adr[index].ob_next;
		}while(index!=father);
	}
	*nbt=cnt;
}

