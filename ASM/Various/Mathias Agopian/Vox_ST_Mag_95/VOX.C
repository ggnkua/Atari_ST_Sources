#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <aes.h>
#include <vdi.h>
#include <tos.h>
#include <math.h>

#include "DEFINES.H"
#include "DEF_VOX.H"
#include "COOKIES.H"
#include "MAIN.H"
#include "VOX.H"
#include "VOX_H.H"
#include "HARD.H"
#include "APPR.H"
#include "AESPATCH.H"
#include "FSELECT.H"

volatile int dsp_ready;
volatile int dsp_seuil;

extern int ValBarSeuil;
extern int TauxAppr,TauxReco,TauxMin,SeuilStart,SeuilEnd;
extern int ap_id;
extern WINDOW window[nb_window+1];
extern OBJECT *adr_menu;
extern int samples[Npoints];
extern int moy[DefMaxMots][3][Npoints];		

extern double FTauxAppr;
extern double FTauxReco;
extern double FTauxMin;

extern LISTE_MOTS liste_mots;
extern mode_appr;
int actif;

void load_mots(LISTE_MOTS *liste);
void save_mots(LISTE_MOTS *liste);
int gere_barre(int idx,OBJECT *adr,int obj,int *var);

void call_main(int event,int wh,int objet,int *buf)
{
	int temp;
	int wind_index;
	
	wind_index=find_index(wh);
	apprend(&liste_mots);
	if ((actif) && (!mode_appr))
		recognize(&liste_mots);

	if ((event==MU_TIMER) && (window[W_F1].opened) && (!mode_appr) && (!actif))
	{
		dsp_seuil=get_seuil();
		if (dsp_seuil>ValBarSeuil)
			ValBarSeuil=dsp_seuil;
		else
		{
			ValBarSeuil-=2000;	
			if (ValBarSeuil<0)
				ValBarSeuil=0;
		}
		redraw_w_objc(W_F1,F1_SEUIL);
	}
	
	if ((event & MU_MESAG) && (buf[0]==MN_SELECTED))
	{
		temp=buf[3];
		menu_tnormal(adr_menu, temp, 0);
		switch(buf[4])
	    {
	    	case M0_INFOS:
	    		wind_form(W_INFOS);
	    		break;
			case M0_APPR:
	    		wind_form(W_F0);
	    		mode_appr=0;
	    		break;
	    	case M0_SEUIL:
	    		wind_form(W_F1);
	    		break;
	    	case M0_PARAM:
	    		wind_form(W_F2);
	    		break;
	    	case M0_RECO:
	    		actif=~actif;
	    		menu_icheck(adr_menu,M0_RECO,actif);
	    		if (actif)
	    		{
					set_trigger(SeuilStart,SeuilEnd);
	    			vox();
	    		}
	    		else
	    			stop_dsp();
	    		break;
	    	case M0_SAVE:
	    		save_mots(&liste_mots);
	    		break;
	    	case M0_LOAD:
	    		load_mots(&liste_mots);
	    		break;
		}	
		menu_tnormal(adr_menu,temp,1);
		wait_mouse();
	}
	
    if ((event & (MU_BUTTON|MU_KEYBD)) && (window[wind_index].iconified==0))
    {
		if ((wind_index==W_INFOS) && (objet==INFOS_B_OK))
			WindClose(W_INFOS);

		if (wind_index==W_F0)
			apprentissage(objet);

		if (wind_index==W_F01)
		{
			if (objet==F01_EXIT)
			{
    			stop_dsp();
				mode_appr=0;
				WindClose(W_F01);
			}
		}
		
		if (wind_index==W_F2)
		{
			if ((objet>=F2_T1) && (objet<=F2_T5))
			{
				switch(objet)
				{
					case F2_T1:
						gere_barre(W_F2,window[W_F2].form,F2_T1,&TauxAppr);
						FTauxAppr=TauxAppr/32767.0;
						break;
					case F2_T2:
						gere_barre(W_F2,window[W_F2].form,F2_T2,&TauxReco);
						FTauxReco=TauxReco/32767.0;
						break;
					case F2_T3:
						gere_barre(W_F2,window[W_F2].form,F2_T3,&TauxMin);
						FTauxMin=TauxMin/32767.0;
						break;
					case F2_T4:
						gere_barre(W_F2,window[W_F2].form,F2_T4,&SeuilStart);
						break;
					case F2_T5:
						gere_barre(W_F2,window[W_F2].form,F2_T5,&SeuilEnd);
						break;
				}
			}
			else if (objet==F2_OK)
			{
				WindClose(W_F2);
			}
		}
	}
}

void InitRessource(void)
{
	register int i;
	COOKIE *p;
	p=get_cookie('MiNT');
	if (p)
		menu_register(ap_id,"  Vox...");
	
	window[W_INFOS].title		="Informations";
	window[W_F0].title			="Apprentissage";
	window[W_F01].title			="Apprendre un mot";
	window[W_F1].title			="Seuil";
	window[W_F2].title			="Param‚trages";
	window[W_PRG_GRP].title		="VOX";
	window[W_INFOS].title_icn	="INFOS";
	window[W_F0].title_icn		="APPR";
	window[W_F01].title_icn		="MOT";
	window[W_F1].title_icn		="SEUIL";
	window[W_F2].title_icn		="PARAMS";
	window[W_PRG_GRP].title_icn	="VOX";
	
	for(i=0;i<=nb_window;i++)
	{
		window[i].DrawWind=0L;
		window[i].bloquante=TRUE;
	}

	window[W_F01].attr=(NAME|MOVER|SMALLER);
	window[W_F0].DrawWind=redraw_f0;
 	window[W_F1].bloquante=FALSE;


	actif=0;
	TauxAppr=FTauxAppr*32767;
	TauxReco=FTauxReco*32767;
	TauxMin=FTauxMin*32767;
	SeuilStart=1000;
	SeuilEnd=4000;
	
	PatchAes();
	init_liste_mots(&liste_mots);
	init_snd();
	set_trigger(1,0);
	set_nbp(Npoints);
	vox();
	while(!dsp_ready);
	get_samples(Npoints,samples);	 
	set_trigger(SeuilStart,SeuilEnd);
	set_nbp(Npoints);
}

void byebye(void)
{
	UnpatchAes();
	Dsp_RemoveInterrupts(3);
	Dsp_Unlock();
}

void fulled(void)
{
}

void resize(void)
{
}

void redraw_window(int index,GRECT *rect)
{
	OBJECT *adr=window[index].form;
	int x=rect->g_x;
	int y=rect->g_y;
	int w=rect->g_w;
	int h=rect->g_h;
	if (adr)
	{
		if (window[index].DrawWind)
			window[index].DrawWind(adr,x,y,w,h);
		else
			objc_draw(adr,0,MAX_DEPTH,x,y,w,h);
	}
}

void load_mots(LISTE_MOTS *liste)
{
	int fh;
	static char CNF_filename[256];
	static char CNF_default[12];
	static char *CNF_mask="*.VOX\0\0\0\0\0\0\0\0";
	static char *CNF_loadtxt="Charger l'apprentissage...";
	if (!fileselect(CNF_mask,CNF_default,CNF_filename,CNF_loadtxt))
	{
		fh=(int)Fopen(CNF_filename,FO_READ);
		Fread(fh,sizeof(int)*3*Npoints*DefMaxMots,moy);		
		init_liste_mots(liste);
		Fclose(fh);
	}
}

void save_mots(LISTE_MOTS *liste)
{
	int fh;
	static char CNF_filename[256];
	static char CNF_default[12];
	static char *CNF_mask="*.VOX\0\0\0\0\0\0\0\0";
	static char *CNF_savetxt="Sauver l'apprentissage...";
	if (!fileselect(CNF_mask,CNF_default,CNF_filename,CNF_savetxt))
	{
		fh=(int)Fcreate(CNF_filename,0);
		Fwrite(fh,sizeof(int)*3*Npoints*DefMaxMots,moy);
		Fclose(fh);
	}
}

int gere_barre(int idx,OBJECT *adr,int obj,int *var)
{
	int x,y,w,h;
	int mx,my,mk;
	int dummy;
	long v;
	objc_offset(adr,obj,&x,&y);
	w=adr[obj].ob_width;
	h=adr[obj].ob_height;	
	do
	{
		graf_mkstate(&mx,&my,&mk,&dummy);
		v=(((mx-x)*32767L)/w);		
		if (v<0)			v=0;
		else if(v>32767)	v=32767;
		*var=(int)v;
		redraw_w_rect(window[idx].hwind,adr,obj,MAX_DEPTH);
	}while ((mk&1) && (mx>x) && (my>y) && (mx<x+w) && (my<y+h));
	return 0;
}
