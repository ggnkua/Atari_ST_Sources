
	/* Ce petit programme affiche al‚atoirement des points */

#include "tos.h"
#include "string.h"
#include "aes.h"

	/* D‚clare la constante qui indique le nombre de points */
#define NBPOINTS 100

	/* D‚finit la structure POINT */
typedef struct
{
	int pt_visible;
	int pt_couleur;
	int pt_x, pt_y;
}
POINT;

	/* D‚claration des variables */
int handle_vdi;		/* Indispensable pour toute op‚ration graphique */
int app_id;
int x_desk, y_desk, w_desk, h_desk;
int work_in[11], work_out[57];		/* Tableaux pour la VDI */
POINT pt[NBPOINTS];		/* D‚clare un tableau de 100 structures POINT */

	/* D‚claration des fonctions */
int main (void);
void init_points (void);
void trace_points (void);
void trace_un_point (int n);
void open_work (void);
void cls (void);

int main (void)
{
	app_id = appl_init ();

	/* R‚cupŠre les dimensions du bureau */
	/* les & indiquent que le paramŠtre est VAR (rdv le mois prochain) */
	wind_get (0, WF_WORKXYWH,  &x_desk, &y_desk, &w_desk, &h_desk);
	
	open_work ();
	cls ();
	init_points ();
	trace_points ();
	
	form_alert (1, "[1][Comme c'est beau !][ OK ]");
	
	appl_exit ();						/* Quitte l'AES */
	v_clsvwk (handle_vdi);	/* Ferme la station VDI */
	
	return 0;								/* Quitte tout */
}

void open_work (void)
{
	int i;
	
	/* Cette routine ouvre une station VDI et met son
		handle dans 'handle_vdi' */
	
	for (i = 1 ; i < 10 ; i++)
		work_in[i] = 1;
	work_in[0] = Getrez () + 2;
	work_in[10] = 2;
	
	/* le & indique que nous passons … la routine l'adresse
		de la variable handle_vdi pour qu'elle la modifie. Cela
		correspont au VAR du GFA. (rdv le mois prochain) */
	v_opnvwk (work_in, &handle_vdi, work_out);
	/* ATTENTION : le handle_vdi est le num‚ro de la station ouverte */
}

void init_points (void)
{
	int i;
	
	for (i = 0 ; i < NBPOINTS ; i++)		/* de 0 … 99 */
	{
		/* On d‚cale le Random() car le bit 0 est mal mis... (bug bug) */
		pt[i].pt_visible = (Random() >> 4) & 1;
		pt[i].pt_couleur = (Random() >> 4) & 0xF;		/* 16 couleurs... */
		pt[i].pt_x = x_desk + ((Random() >> 1) % w_desk);	/* Coord. au pif */
		pt[i].pt_y = y_desk + ((Random() >> 1) % h_desk);
	}
}

void trace_points (void)
{
	int i;
	
	v_hide_c (handle_vdi);	/* Il faut cacher la souris pour le graphisme ! */
	for (i = 0 ; i < NBPOINTS ; i++)
		trace_un_point (i);			/* Une seul ligne, donc {} facultatif */
	v_show_c (handle_vdi, 0);
}

void trace_un_point (int n)
{
	int pxy[4];
	
	if (pt[n].pt_visible)
	{
		/* pt[n].pt_x correspont … la coord x du point num‚ro n. */
		
		pxy[0] = pt[n].pt_x;	/* Prend les coord. dans la structure */
		pxy[1] = pt[n].pt_y;
		pxy[2] = pt[n].pt_x + 1;
		pxy[3] = pt[n].pt_y + 1;
		
		vsf_color (handle_vdi, pt[n].pt_couleur);		/* Choisit la couleur */
		v_bar (handle_vdi, 2, pxy);								/* PBOX x,y,x+1,y+1 */
	}
}

void cls (void)
{
	/* Cette routine efface l'‚cran */
	int pxy[4];
	
	vsf_color (handle_vdi, 0);		/* DEFFILL 0 */
	pxy[0] = 0;
	pxy[1] = 0;
	pxy[2] = x_desk + w_desk;
	pxy[3] = y_desk + h_desk;
	v_hide_c (handle_vdi);	/* Il faut cacher la souris pour le graphisme ! */
	v_bar (handle_vdi, pxy);
	v_show_c (handle_vdi, 0);
}
