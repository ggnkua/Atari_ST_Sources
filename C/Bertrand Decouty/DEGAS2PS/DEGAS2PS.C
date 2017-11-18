/*******************************************************************/
/*																   															 */
/* 		DEGAS2PS.PRG																								 */
/* Programme d'impression d'images provenant de DEGAS (.PI3).      */
/* La sortie se fait en PostScript vers un fichier ou une laser.   */
/* Il est possible de s‚lectionner une partie de l'image, 				 */
/* la r‚duction ou l'augmentation ainsi que la position sur				 */
/* la page.														   													 */
/* IRISA de RENNES				 									 				 							 */
/*																  															 */
/* Mat‚riels : ATARI 1040 STFM + LaserWriter II NT			  				 */
/* Langage : Megamax C												  									 */
/*																  															 */
/* ecrit par : 	Bertrand DECOUTY (IRISA-INRIA, Rennes)						 */
/*							Philippe LE THOMAS (stage IUT Lannion 1988)				 */
/*																																 */
/*******************************************************************/
char version[]= "DEGAS2PS 1.53";

/* 1= francais, 0= anglais */
#define FRANCAIS 0

#include <stdio.h>
#include <osbind.h>
#include <gembind.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <string.h>
#include "DEGAS2PS.H"
#define RESSOURCE "DEGAS2PS.RSC"

#if FRANCAIS
#define MESS0 "[3][ | Le fichier ressource | est introuvable... ][ STOP ]"
#define MESS1 "[2][ | Le p‚riph‚rique n'est | pas connect‚... ][ OK | ANNULER ]"
#define MESS2 "[3][ | Erreur lors de l'ouverture | du fichier de sortie... ][ STOP ]"
#define MESS3 "[2][ | Voulez-vous r‚ellement | stopper l'impression ? ][ NON | OUI ]"
#define MESS4 "[3][ Erreur d'‚criture | du fichier PostScript ...| disque plein ? ][ STOP ]"
#define MESS5 "[3][ | Erreur lors de l'ouverture | du fichier image... ][ STOP ]"

#else 		/* messages en anglais */
#define MESS0 "[3][ | Resource file | not found... ][ STOP ]"
#define MESS1 "[2][ | Peripheral device | not connected or off-line... ][ OK | CANCEL ]"
#define MESS2 "[3][ | I can't open | output file... ][ STOP ]"
#define MESS3 "[2][ | Do you really want | to stop printing ? ][ NO | YES ]"
#define MESS4 "[3][ I/O error while | writing PostScript file | disk full ?][ Sorry.. ]"
#define MESS5 "[3][ | I can't open | image file... ][ STOP ]"
#endif

#define void /**/
#define VRAI 1
#define FAUX 0
#define RESW 639															/* Largeur maximale de l'‚cran */
#define RESH 399															/* Hauteur maximale de l'‚cran */
#define Souris_Croix graf_mouse(5,&dummy)
#define Souris_Normale graf_mouse(0,&dummy)
#define Cache_Souris graf_mouse(256,&dummy)
#define Montre_Souris graf_mouse(257,&dummy)

/* structure pour informations sur fichier */
/*
typedef struct {
	long b_free;
	long b_total;
	long b_secsiz;
	long b_clsiz;
} disk_info;
*/

/* variables utilis‚es par le GEM */

int work_in[] = {1,1,1,1,1,1,1,1,1,1,2};
int work_out[57],contrl[12],intin[256],intout[256],
	ptsin[128],ptsout[128];

/* variables globales */

int periph; /* indique le peripherique de sortie : 0 = centronics (PRT:) */
						/*																		 1 = RS 232     (AUX:) */
						/*																		 2 = fichier (file.PS) */
int	handle,x,y,w,h,xres,yres,nombre,sortie,
	xsouris,ysouris,etatbout,etatclav,codeclav,nbpress,event,
	xdial,ydial,wdial,hdial,test,mgbuf[11],debut,lon,
	xstart,ystart,width,height,xso,yso,swo,sho,ouvert,
	rx,ry,rw,rh,dummy,boxw,boxh,deja,sw,sh,suppl,
	w_handle,wx,wy,wh,ww,lecture,ecriture;

MFDB dfbb;
MFDB dfbs ={0L,0,0,0,0,0,0,0,0};
int frmary[8],clpry[4],fin;
long buffer,ecran;
char source[80],tex[4][80],mode[80],cheminlecture[80],
		 cheminecriture[80],nomfenetre[50],nomsortie[30];
OBJECT *barre,*dial;
/**************************************************************************/
/* initialisation des tableaux contenant les coordonn‚es des 	*/
/* blocs pour le clipping 																		*/

void init()

{		
/*	xres = work_out[0]+1;
	yres = work_out[1]+1;*/
/*	vq_extnd(handle,1,work_out);	*/
/*	dfbb.fd_addr initialise ulterieurement  */
	dfbb.fd_w				= work_out[0]+1;
	dfbb.fd_h				= work_out[1]+1;
	dfbb.fd_wdwidth	= dfbb.fd_w / 16;
	dfbb.fd_stand		=0;
	dfbb.fd_nplanes	=1;
	ouvert = lecture = ecriture = FAUX;
/* lecture des coordonn‚es maximales de la fenetre */
	wind_get(0,WF_WORKXYWH,&wx,&wy,&ww,&wh);
	buffer = Malloc((long)(32000+256+256));
	w_handle = wind_create(NAME,wx,wy,ww,wh);
}
/**************************************************************************/
void main()

{
	int i;
	register int boucle;
	
/* Initialisation des variables utilis‚es par le systŠme */
	for (boucle=1; boucle<10; work_in[boucle++]=1);
	work_in[10]=2;
	appl_init();
	Cache_Souris;
/* ouverture de la station de travail virtuelle */
	handle = graf_handle(&i,&i,&i,&i);
	v_opnvwk(work_in,&handle,work_out);
	init();							
	Montre_Souris;
/* chargement du fichier ressource contenant le menu, */
/* les boites de dialogue et les diff‚rentes icones */
	if (!rsrc_load(RESSOURCE))
	{
		form_alert(1,MESS0);
	}
	else
	{
/* affichage du menu et lecture de son adresse dans l'arbre	*/			
		Souris_Normale;
		rsrc_gaddr(R_TREE,MENU,&barre);
		edition();
	}												
	quitter();
}
/**************************************************************************/
/* fermeture de la station, de le fenetre et liberation de la	*/
/* memoire 																										*/
void quitter()

{
	menu_bar(barre,FAUX);
/* on libŠre la m‚moire occup‚e par l'image */
	Mfree(buffer);
	if (ouvert) 
	{
/* effacement de la fenetre */
		wind_close(w_handle);
		wind_delete(w_handle);
	}
	v_clsvwk(handle);
	Souris_Normale;
	Montre_Souris;
	appl_exit();
}
/**************************************************************************/
/* routine de copie de bloc															 */
/* drap : 1 = copie sans changement, 0 = inversion video */
void image(sx,sy,dx,dy,l,h,drap)

register int sx,sy,dx,dy,l,h,drap;
{
	frmary[0]=sx;		
	frmary[1]=sy;			
	frmary[2]=sx+l-1;	
	frmary[3]=sy+h-1;		
	frmary[4]=dx;		
	frmary[5]=dy;		
	frmary[6]=dx+l-1;	
	frmary[7]=dy+h-1;
	clpry[0]=dx;
	clpry[1]=dy;
	clpry[2]=dx+l-1;
	clpry[3]=dy+h-1;
	vs_clip(handle,1,clpry);
	Cache_Souris;
	if (drap) 
		vro_cpyfm(handle,3,frmary,dfbb,dfbs);
	else 
		vro_cpyfm(handle,12,frmary,dfbb,dfbs);
	Montre_Souris;
}
/**************************************************************************/
/* attend un appui sur le bouton gauche pour renvoyer les coordonn‚es */
/* de la souris, si bouton droit => on quitte. Un appui sur ALTERNATE */
/* r‚initialise l'ecran 																							*/
void gestion()

{
	int bouton,key;

	Souris_Croix;
	undo();
	do
	{
		event = evnt_mouse(0,0,0,RESW,RESH,&xsouris,&ysouris,&bouton,&key);
/* test le bouton gauche */
		if (bouton & 0x0001) souris();
/* test la touche ALT */
		if (key & 0x0008) undo();
	}	
/* test le bouton droit */
	while (!(bouton & 0x0002));
	Souris_Normale;
}
/**************************************************************************/
/* restitution de l'‚cran original */
void undo()

{
	deja = FAUX;
	sho = 400; swo = 640;
	image(0,0,0,0,RESW+1,RESH+1,VRAI);
}
/**************************************************************************/
/* affichage d'un rectangle de s‚lection pour indiquer la zone */
/* que l'on d‚sire imprimer																			*/
void souris()

{
	int status,x,y,xx,yy,xd,yd;
	char message[80],texte[50];
	
	undo();
	deja = VRAI;
	xx = x = 0; yy = y = 0;
	xd = xsouris;
	yd = ysouris;
	Cconout(0x07);
	do
	{
		vq_mouse(handle,&status,&x,&y);
		if ((xx != x) || (yy != y)) 
		{
			image(xd,yd,xd,yd,xx-xd+1,yy-yd+1,VRAI);
			image(xd,yd,xd,yd,x-xd+1,y-yd+1,FAUX);
			xx = x; yy = y;
		}
	}
	while ((status & 0x0001));
/*	form_alert(1,MESS6);*/
	Souris_Croix;
	if (xd <= x) { xso = xd;swo = x - xso; }
	else { xso = x;swo = xd - xso; }
	if (yd <= y) { yso = yd;sho = y - yso; }
	else { yso = y;sho = yd - yso; }
	Cconout(0x07);
}
/**************************************************************************/
/* gestion des ‚vŠnements : menu, raffraichissement ‚cran */
void edition()

{
	int xstart,ystart,wstart,hstart,rx,ry,rh,rw;
	
	Souris_Normale;
	menu_ienable(barre,IMPRIMER,FAUX);
	menu_ienable(barre,EDITER,FAUX);
	menu_bar(barre,VRAI);
	while (fin != 1)
	{
		event = evnt_mesag(mgbuf);
		wind_update(VRAI);
		switch (mgbuf[0])
		{
/* un menu a ete selectionne */
			case MN_SELECTED : selection();
				break;
/* rafraichissement de la fenetre */
			case WM_REDRAW :
				wind_get(mgbuf[3],WF_WORKXYWH,&xstart,&ystart,&wstart,&hstart);
				wind_get(mgbuf[3],WF_FIRSTXYWH,&rx,&ry,&rw,&rh);
				frmary[0]=0;		
				frmary[1]=0;			
				frmary[2]=wstart-1;	
				frmary[3]=hstart-1;		
				frmary[4]=xstart;		
				frmary[5]=ystart;		
				frmary[6]=xstart+wstart-1;	
				frmary[7]=ystart+hstart-1;
				clpry[0]=rx;
				clpry[1]=ry;
				clpry[2]=rx+rw-1;
				clpry[3]=ry+rh-1;
				vs_clip(handle,1,clpry);
				Cache_Souris;
				vro_cpyfm(handle,3,frmary,dfbb,dfbs);
				Montre_Souris;
				break;
		}
		wind_update(FAUX);
	}
}
/**************************************************************************/
/* aiguillage vers le choix fait par l'utilisateur */
void selection()

{	
	switch (mgbuf[4])
	{
		case COPY :
/* affichage du copyright */ 
			apropos();
		break;
		case QUITTER : 
/* quitte le programme */
			fin = 1;
		break;
/* affiche la boite d'aide */
		case AIDE :
			aide();
		break;
		case IMPRIMER : 
/* affiche les boites de dialogue pour l'impression */
		impression();
		break;
		case OUVRIR :
/* reservation de la memoire pour l'image */
			ecran = (0xffff00&buffer);
			ecran += (0x200);
/* selection d'un fichier image *.PI? */
			if (dialogue(source,0,"PI?")>0)
			{
				strcpy(nomsortie,rindex(source,'\\')+1);
				strcpy(nomfenetre," ");
				strcat(nomfenetre,rindex(source,'\\')+1);
				strcat(nomfenetre," ");
/* si une fenetre ‚tait d‚j… ouverte, on la ferme */
				if (ouvert) wind_close(w_handle);
				ouvert = VRAI;
				menu_ienable(barre,IMPRIMER,VRAI);
				menu_ienable(barre,EDITER,VRAI);
/* initialise la palette des couleurs */
/*				Setpalette(ecran+2);	*/
				dfbb.fd_addr=(ecran+34);
				menu_bar(barre,FAUX);
				gestion();
/*			impression();*/
/* ouvre une fenetre contenant l'image */
				wind_set(w_handle,WF_NAME,nomfenetre);
				wind_open(w_handle,wx,wy,ww,wh);
				menu_bar(barre,VRAI);
			}
		break;
		case EDITER :
/* edite une image en memoire */
			if (ouvert) 
			{
				wind_close(w_handle);
				menu_bar(barre,FAUX);
				gestion();
/*			impression();*/
				wind_open(w_handle,wx,wy,ww,wh);
				menu_bar(barre,VRAI);
			}
		break;
	}
	menu_tnormal(barre,mgbuf[3],VRAI);
}
/**************************************************************************/
/* s‚lection de la sortie : rs 232, fichier, centronics */
int sortieimprimante()

{	
	rsrc_gaddr(R_TREE,SORTIE,&dial);
	Cache_Souris;
	afficheboite();
	Montre_Souris;
	sortie = form_do(dial,FAUX);
	Cache_Souris;
	effaceboite();
	Montre_Souris;
	if (sortie != ANN1) 
	{
		switch (sortie)
		{
			case FICHIER : periph = 2;
/* selection du fichier de sortie *.PS */
				if (dialogue(source,1,"PS")>0)
				{
					strcpy(mode,source);
					return(VRAI);
				}
				else return(FAUX);
				break; 
			case LASER : strcpy(mode,"AUX:"); periph = 1;
				break;
			case PRINTER : strcpy(mode,"PRT:"); periph = 0;
				break;
		}
/* test si le peripherique est pret ou connecte */
		while (!Bcostat(periph)) if (form_alert(1,MESS1) == 2) return(FAUX);
		return(VRAI);
	}
	else return(FAUX);
}

/**************************************************************************/
/* conversion points => centimetre */
float calculpoint(width,resolution)

float width,resolution;
{
	return((width*resolution*2.540*1)/300.0);
}

/**************************************************************************/
sens_off(page)

int *page;

/* 	selection du sens (portrait, paysage) de l'impression et invalidation	*
 *	du sens non-retenu																										*/
{
	if (swo<=sho)
	{
		objc_change(dial,PORTRAIT,0,xdial,ydial,wdial,hdial,SELECTED,VRAI);
		objc_change(dial,PAYSAGE,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
		*page = FAUX;
	}
	else
	{
		objc_change(dial,PORTRAIT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
		objc_change(dial,PAYSAGE,0,xdial,ydial,wdial,hdial,SELECTED,VRAI);
		*page = VRAI;
	}
	objc_change(dial,PORTXT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
	objc_change(dial,PAYTXT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
	objc_change(dial,REDUC,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
	objc_change(dial,MOINS,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
	objc_change(dial,PLUS,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
	dial[PLUS].ob_flags=NONE;
	dial[MOINS].ob_flags=NONE;

}

/**************************************************************************/
sens_on(page)

int *page;

/* 	selection du sens (portrait, paysage) de l'impression et validation		*
 *	de l'autre choix																											*/
{
	if (swo<=sho)
	{
		objc_change(dial,PORTRAIT,0,xdial,ydial,wdial,hdial,SELECTED,VRAI);
		objc_change(dial,PAYSAGE,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
		*page = FAUX;
	}
	else
	{
		objc_change(dial,PORTRAIT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
		objc_change(dial,PAYSAGE,0,xdial,ydial,wdial,hdial,SELECTED,VRAI);
		*page = VRAI;
	}
	objc_change(dial,PORTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,PAYTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,REDUC,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,MOINS,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,PLUS,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	dial[PLUS].ob_flags=TOUCHEXIT;
	dial[MOINS].ob_flags=TOUCHEXIT;
}


/**************************************************************************/
/* s‚lection des options de mise en page */

int choixformat(page,centre,copie,latex,reduction)

int *page,*centre,*copie,*latex;
float *reduction;
{	
	char cop[5],reduc[5],haut[10],larg[10];
	float agrand,largeur,hauteur;
	
	rsrc_gaddr(R_TREE,FORMAT,&dial);
	Cache_Souris;
	agrand = 4.00;
	largeur = calculpoint((float)swo,agrand);
	hauteur = calculpoint((float)sho,agrand);
	strcpy(cop,"01");
	sprintf(reduc,"%04.0f",agrand*100);
	sprintf(larg,"%05.0f",largeur*100);
	sprintf(haut,"%05.0f",hauteur*100);
	((TEDINFO *)dial[REDUC].ob_spec)->te_ptext = reduc;
	((TEDINFO *)dial[REDUC].ob_spec)->te_txtlen = 5;
	((TEDINFO *)dial[COPIE].ob_spec)->te_ptext = cop;
	((TEDINFO *)dial[COPIE].ob_spec)->te_txtlen = 3;
	((TEDINFO *)dial[LARGEUR].ob_spec)->te_ptext = larg;
	((TEDINFO *)dial[LARGEUR].ob_spec)->te_txtlen = 6;
	((TEDINFO *)dial[HAUTEUR].ob_spec)->te_ptext = haut;
	((TEDINFO *)dial[HAUTEUR].ob_spec)->te_txtlen = 6;
	afficheboite();
	
/* initialise la boite de selection */
	
	objc_change(dial,REEL,0,xdial,ydial,wdial,hdial,SELECTED,VRAI);
	objc_change(dial,NOLATEX,0,xdial,ydial,wdial,hdial,SELECTED,VRAI);
	objc_change(dial,LATEX,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,AUTO,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,CUSTOM,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,TMAXTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,TREELTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,PERSOTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	objc_change(dial,COPIE,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
	dial[PORTRAIT].ob_flags=TOUCHEXIT | RBUTTON | SELECTABLE;
	dial[PAYSAGE].ob_flags= TOUCHEXIT | RBUTTON | SELECTABLE;
	dial[CUSTOM].ob_flags=  TOUCHEXIT | RBUTTON | SELECTABLE;
	dial[COPIE].ob_flags=   EDITABLE;
	dial[AUTO].ob_flags=    TOUCHEXIT | RBUTTON | SELECTABLE;
	dial[REEL].ob_flags=    TOUCHEXIT | RBUTTON | SELECTABLE;
	sens_off(page);
	Montre_Souris;
	*latex = FAUX;
	*centre = 0;
	do
	{
		sortie = form_do(dial,0);
		switch (sortie) 
		{
		case AUTO : *centre = 1; sens_off(page);
			break;
		case REEL : *centre = 0; sens_off(page);
			break;
		case CUSTOM : *centre = 2;sens_on(page);
			break;
		case PAYSAGE : *page = VRAI;
			break;
		case PORTRAIT : *page = FAUX;
			break;
		case LATEX : *latex = VRAI;
			objc_change(dial,TMAXTXT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			objc_change(dial,TREELTXT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			objc_change(dial,PERSOTXT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			objc_change(dial,COPIE,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			objc_change(dial,PORTXT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			objc_change(dial,PAYTXT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			objc_change(dial,REDUC,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			objc_change(dial,MOINS,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			objc_change(dial,PLUS,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			dial[PLUS].ob_flags=    NONE;
			dial[MOINS].ob_flags=   NONE;
			dial[COPIE].ob_flags=   NONE;
			dial[PORTRAIT].ob_flags=NONE;
			dial[PAYSAGE].ob_flags= NONE;
			dial[CUSTOM].ob_flags=  NONE;
			dial[AUTO].ob_flags=    NONE;
			dial[REEL].ob_flags=    NONE;
			break;
		case NOLATEX : *latex = FAUX;
			objc_change(dial,TMAXTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
			objc_change(dial,TREELTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
			objc_change(dial,PERSOTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
			objc_change(dial,COPIE,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
			if(*centre==2)
			{
				objc_change(dial,REDUC,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
				objc_change(dial,MOINS,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
				objc_change(dial,PLUS,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
				objc_change(dial,PORTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
				objc_change(dial,PAYTXT,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
				dial[PLUS].ob_flags=    TOUCHEXIT;
				dial[MOINS].ob_flags=   TOUCHEXIT;
			} else
			{
				objc_change(dial,PORTXT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
				objc_change(dial,PAYTXT,0,xdial,ydial,wdial,hdial,DISABLED,VRAI);
			}
			dial[PORTRAIT].ob_flags=TOUCHEXIT | RBUTTON | SELECTABLE;
			dial[PAYSAGE].ob_flags= TOUCHEXIT | RBUTTON | SELECTABLE;
			dial[CUSTOM].ob_flags=  TOUCHEXIT | RBUTTON | SELECTABLE;
			dial[COPIE].ob_flags=   EDITABLE;
			dial[AUTO].ob_flags=    TOUCHEXIT | RBUTTON | SELECTABLE;
			dial[REEL].ob_flags=    TOUCHEXIT | RBUTTON | SELECTABLE;
			break;
		case PLUS :
			if (agrand+0.050<99.9)
			{ 
				agrand += 0.050;
				largeur = calculpoint((float)swo,agrand);
				hauteur = calculpoint((float)sho,agrand);
				sprintf(reduc,"%04.0f",agrand*100);
				sprintf(larg,"%05.0f",largeur*100);
				sprintf(haut,"%05.0f",hauteur*100);
				objc_draw(dial,REDUC,0,xdial,ydial,wdial,hdial);
				objc_draw(dial,HAUTEUR,0,xdial,ydial,wdial,hdial);
				objc_draw(dial,LARGEUR,0,xdial,ydial,wdial,hdial);
			}
			objc_change(dial,PLUS,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
			break;
		case MOINS : 
			if (agrand-0.050>0.99)
			{
				agrand -= 0.050;
				largeur = calculpoint((float)swo,agrand);
				hauteur = calculpoint((float)sho,agrand);
				sprintf(reduc,"%04.0f",agrand*100);
				sprintf(larg,"%05.0f",largeur*100);
				sprintf(haut,"%05.0f",hauteur*100);
				objc_draw(dial,REDUC,0,xdial,ydial,wdial,hdial);
				objc_draw(dial,HAUTEUR,0,xdial,ydial,wdial,hdial);
				objc_draw(dial,LARGEUR,0,xdial,ydial,wdial,hdial);
			}
			objc_change(dial,MOINS,0,xdial,ydial,wdial,hdial,NORMAL,VRAI);
			break;
		}
	}
	while ((sortie != PRINT) && (sortie != ANN2));
	if (*centre == 0) strcpy(reduc,"400");
	*copie = atoi(cop);
	*reduction=agrand;
	Cache_Souris;
	effaceboite();
	Montre_Souris;
	if (sortie == PRINT) 
		return(VRAI);
	else 
		return(FAUX);
}

/**************************************************************************/
/* calcul des coordonn‚es d'un bloc pour l'envoi vers la laser */
void calcul(masqueg,masqued,masquageg,masquaged)

int *masqueg,*masqued,*masquageg,*masquaged;
{
	register int x,y,h,w,bitdroite,bitgauche;
	
	x = xso;y = yso;h = sho;w = swo;
	*masquageg = FAUX;
	*masquaged = FAUX;
	if (x % 8)
	{
		*masquageg = VRAI;	
		bitgauche = (x % 8);
		*masqueg = 0xff >> bitgauche;
		x -= bitgauche;
	}
	if ((w % 8) != 7)
	{
		*masquaged = VRAI;
		bitdroite = 7 - (w % 8);
		*masqued = (0x00ff << bitdroite) & 0x00ff;
		w += bitdroite;
	}	
	debut = (int)(x / 8) + y*80;
	lon = (int)(w / 8);
	if (w % 8) lon ++;
	nombre = h * lon;
}
/**************************************************************************/		
void impression()

/* impression de l'image avec toutes les options */

{
	register FILE *fd;
	register int i,j,k,buf_ptr;
	register long inc;
	unsigned int date,time;
	int hauteur,largeur,x,bouton,compteur,dep,masqueg,masqued;
	int masquaged,masquageg,page,centre,copie,latex;
	int llx,lly,urx,ury;
	float reduction,unite;
	unsigned char buf[512], tamp1,tamp2;
	date=Tgetdate(); time=Tgettime();
	if (choixformat(&page,&centre,&copie,&latex,&reduction))
	{
		if (sortieimprimante())
		{
			if ((fd = fopen(mode,"w")) == NULL)
			{
				form_alert(1,MESS2);
			}
			else
			{
				Cache_Souris;
				calcul(&masqueg,&masqued,&masquageg,&masquaged);
				rsrc_gaddr(R_TREE,ANNONCE,&dial);
				if (deja){
					hauteur = sho;
					largeur = lon * 8;
				}
				else{
					hauteur = 400;					
					largeur = 640;					
				}
				dial[CADRE].ob_width = (dial[CADRE].ob_width/dial[BOITE].ob_width)*dial[BOITE].ob_width;
				objc_change(dial,CADRE,0,xdial,ydial,wdial,hdial,NORMAL,1);
				dial[BOITE].ob_x = 0;
				objc_change(dial,BOITE,0,xdial,ydial,wdial,hdial,NORMAL,1);
				afficheboite();
				resetboite();	
/* d‚but du code PostScript */
				if (periph!=2) fprintf(fd,"\004"); /* initialisation de l'imprimante */
				if (copie == 0) copie = 1;
				llx=72; lly=72; unite=(72.0*4.0)/300.0;
				urx=llx+(((float)largeur)*unite); ury=lly+(((float)hauteur)*unite);
				if (latex)
				{	fprintf(fd,"%%!PS-Adobe-2.0 EPSF-2.0");
					fprintf(fd,"%%%%BoundingBox: %d %d %d %d\n",llx,lly,urx,ury);
					fprintf(fd,"%%%%Creator: DEGAS2PS on Atari ST\n");
					fprintf(fd,"%%%%Title: %s\n",rindex(source,'\\')+1);
					fprintf(fd,"%%%%CreationDate: %02d/%02d/%4d  %02d:%02d\n",
					                  date&0x1f,(date>>5)&0x0f,((date>>9)&0x7f)+1980,
					                  (time>>11)&0x1f,(time>>5)&0x3f);
					fprintf(fd,"%%%%EndComments\n");
					fprintf(fd,"%%%%Pages 1\n%%%%EndComments\n%%%%Page: 1 1\n");
					fprintf(fd,"gsave 72 72 translate /height %d def /width %d def\n",hauteur, largeur);
					fprintf(fd,"/dot {%1.2f mul}def width dot height dot scale\n",unite);
				} else{
					fprintf(fd,"%%!\ngsave initmatrix /#copies %d def\n",copie);
					fprintf(fd,"/reduc %2.2f def /page %d def /centre %d def\n",reduction,page,centre);
					fprintf(fd,"/height %d def /width %d def\n",hauteur,largeur);
					fprintf(fd,"/devit { dtransform 2 copy dup mul exch dup mul exch add sqrt\n");
					fprintf(fd,"         dup 3 1 roll div 3 1 roll div exch idtransform } def\n");
					fprintf(fd,"/xdev 1 0 devit pop def /ydev 0 1 devit exch pop def\n");
					fprintf(fd,"xdev reduc mul ydev reduc mul scale\n/reduc2 1 def\n");
					fprintf(fd,"clippath pathbbox\n");									/* On r‚cupŠre les valeurs */
					fprintf(fd,"/yhaut exch def /xhaut exch def\n");		/* exactes des coordonn‚es */
					fprintf(fd,"/ybas  exch def /xbas  exch def\n");		/* de l'imprimante		   	 */
					fprintf(fd,"/yutil yhaut ybas sub def /xutil xhaut xbas sub def\n");
					fprintf(fd,"centre 1 le\n");
					fprintf(fd," { height width gt\n");
					fprintf(fd,"  { /page 0 def } { /page 1 def } ifelse } if\n");
					fprintf(fd,"centre 1 eq\n");
					fprintf(fd," { /reduc2 0.05 def\n");
					fprintf(fd,"  { /h reduc2 height mul def\n");
					fprintf(fd,"    /l reduc2 width mul def\n");
					fprintf(fd,"    h xutil le l yutil le and\n");
					fprintf(fd,"     { /reduc2 reduc2 0.05 add def } {exit} ifelse");
					fprintf(fd,"  } loop\n");
					fprintf(fd," /reduc2 reduc2 0.05 sub def }if \n");
				 	fprintf(fd,"1 page eq { /topoffset  { yutil width  dot sub 2 div cvi } def\n");
					fprintf(fd,"            /leftoffset { xutil height dot sub 2 div cvi } def }\n");
					fprintf(fd,"          { /leftoffset { xutil width  dot sub 2 div cvi } def\n");
					fprintf(fd,"            /topoffset  { yutil height dot sub 2 div cvi } def } ifelse\n");
					fprintf(fd,"/dot { reduc2 mul } def xbas ybas translate\n");
					fprintf(fd,"1 page eq\n");
					fprintf(fd,"{ xutil 0 translate 90 rotate topoffset leftoffset translate }\n");
					fprintf(fd,"{ leftoffset topoffset translate } ifelse\n");
					fprintf(fd,"width dot height dot scale\n");
				}
				fprintf(fd,"/imagedegas { width height 1 [width 0 0 height neg 0 height]\n");
				fprintf(fd,"{ currentfile picstr readhexstring pop } image } def\n");
				fprintf(fd,"/picstr width 8 idiv string def\n");
				fprintf(fd,"{ 1 exch sub } settransfer\n");
				fprintf(fd,"imagedegas\n");
				
				compteur = 0;
				dep = (int)(dial[CADRE].ob_width/dial[BOITE].ob_width);
				/* envoi d'une partie d'image */
				if (deja)
				{
					inc = debut + 34;
					dep = (int)(nombre/dep);			
					for (j=1; j<=sho; j++)
					{
						if (testarret() == 2) { if (periph == 2) fclose(fd); Montre_Souris;return;}
						compteur++;
						if (masquageg) fprintf(fd,"%02x",*(unsigned char *)(ecran+inc++) & masqueg);
						else fprintf(fd,"%02x",*(unsigned char *)(ecran+inc++));
						for (i=2; i<lon; i++)
						{
							if (periph == 1) gestionerreur();
							fprintf(fd,"%02x",*(unsigned char *)(ecran+inc++));
							if (compteur++ >= dep)
							{
								compteur = 0;
								dial[BOITE].ob_x += dial[BOITE].ob_width;
								objc_draw(dial,CADRE,xdial,ydial,wdial,hdial);
								objc_draw(dial,BOITE,xdial,ydial,wdial,hdial);
							}
						}
						if (masquaged) fprintf(fd,"%02x",*(unsigned char *)(ecran+inc++) & masqued);
						else fprintf(fd,"%02x",*(unsigned char *)(ecran+inc++));
						if(fprintf(fd,"\n")<0) {
								form_alert(1,MESS4);
								if (periph == 2) fclose(fd);	Montre_Souris;
								return;
						}					
						inc += (80 - lon);
						compteur++;
					}
				}
				else
				/* envoi de l'image entiŠre */	
				{
					dep = (int)(32000/dep);		inc=0L;	
					for (i=0; i<=RESH;i++)
					{
						if (testarret() == 2) {if (periph == 2) fclose(fd); Montre_Souris;return;}
						if (periph == 1) gestionerreur();
						
						for(j=buf_ptr=0; j<80; j++){
							tamp1=*(unsigned char *)((ecran+34)+(inc++));
							tamp2=(tamp1&0x0F0)>>4;
							buf[buf_ptr++]=tamp2+(tamp2<10 ? 0x030 : 0x037);
							tamp2=(tamp1&0x00F);
							buf[buf_ptr++]=tamp2+(tamp2<10 ? 0x030 : 0x037);
						}
						buf[160]='\0';
						if(fprintf(fd,"%s\n",buf)<0) {
								form_alert(1,MESS4);
								if (periph == 2) fclose(fd);	Montre_Souris;
								return;
						}
						if ((compteur=compteur+80) >= dep){
							compteur = 0;
							dial[BOITE].ob_x += dial[BOITE].ob_width;
							objc_draw(dial,CADRE,xdial,ydial,wdial,hdial);
							objc_draw(dial,BOITE,xdial,ydial,wdial,hdial);
						}
					} /* for i=*/
				} /* fin else*/
				if (fprintf(fd,"grestore showpage\n%%%%Trailer\n")<0){
					form_alert(1,MESS4);
				};
				if (periph == 2) fclose(fd); else fflush(fd); /* on ne ferme pas si AUX ou PRN */
				Cconout(0x07);
				/* attend les messages de la laser */
				if (periph != 2)
				{
					Bconout(periph,0x04);
					k = 0;
					if (periph == 1)
					do
					{	
						evnt_mouse(0,0,0,RESW,RESH,&x,&x,&bouton,&x);
						if (k++ == 1000) 
						{
							Bconout(periph,0x14);
							k = 0;
						}
						gestionerreur();
					}
					while (!(bouton & 0x0002));
				}
				effaceboite();
				Montre_Souris;
			}
	  }
  }
}
/**************************************************************************/
/* test si on appuie sur le bouton de droite pour l'arret de 	*/
/* l'impression																								*/
int testarret()

{
	int status,x;
	
	vq_mouse(handle,&status,&x,&x);
	if (status & 0x0002)
		return(form_alert(1,MESS3));
	else return(0);
}
/**************************************************************************/
/* initialise la boite de dialogue */
void resetboite()

{
	register int i;
	char mess[80];
	
	strcpy(mess,"");
	for (i=PHRASE1; i<=PHRASE4; i++)
	{
		((TEDINFO *)dial[i].ob_spec)->te_ptext = mess;
		((TEDINFO *)dial[i].ob_spec)->te_txtlen = 40;
		objc_draw(dial,i,0,xdial,ydial,wdial,hdial);
	}
	for (i=0; i<=3; i++) strcpy(tex[i],"");
}
/**************************************************************************/
/* test si l'imprimante envoie des messages pour signaler des	*/
/* anomalies lors de l'impression	*/
void gestionerreur()

{
	register int i,j,l;
	char texte[20],mess[80];
	
	while (Bconstat(periph))
	{
		while (((l = (int)Bconin(periph)) != 13) && ( l <= 122) && (l >= 32))
		{
			strcpy(texte,"");
			if ((l != 37) && (l != 91) && (l != 93))
			{
				sprintf(texte,"%c",l);
				strcat(mess,texte);
			}
		}
		if (l == 13)
		{
			l = (int)Bconin(periph);
			for (i = 0; i <= 2; i++) strcpy(tex[i],tex[i+1]);
			strcpy(tex[3],mess);
			j = 0;
			for (i=PHRASE1; i<=PHRASE4; i++)
			{
				((TEDINFO *)dial[i].ob_spec)->te_ptext = tex[j++];
				((TEDINFO *)dial[i].ob_spec)->te_txtlen = 40;
				objc_draw(dial,i,0,xdial,ydial,wdial,hdial);
			}
			strcpy(mess,"");
		}
	}
}
/**************************************************************************/
/* r‚serve la place pour l'affichage d'une boite de dialogue */
void afficheboite()

{
	form_center(dial,&xdial,&ydial,&wdial,&hdial);
	form_dial(FMD_START,1,1,10,10,xdial,ydial,wdial,hdial);
	form_dial(FMD_GROW,1,1,10,10,xdial,ydial,wdial,hdial);
	objc_draw(dial,ROOT,MAX_DEPTH,xdial,ydial,wdial,hdial);
}
/**************************************************************************/
/* libŠre la place occup‚e par la boite et l'efface */
void effaceboite()

{
	form_dial(FMD_SHRINK,1,1,10,10,xdial,ydial,wdial,hdial);
	form_dial(FMD_FINISH,1,1,10,10,xdial,ydial,wdial,hdial);
	objc_change(dial,sortie,0,xdial,ydial,wdial,hdial,NORMAL,FAUX);
}
/**************************************************************************/
/* affiche une fenetre d'aide */
void aide()

{	
	rsrc_gaddr(R_TREE,HELP,&dial);
	Cache_Souris;
	afficheboite();
	Montre_Souris;
	sortie = form_do(dial,FAUX);
	Cache_Souris;
	effaceboite();
	Montre_Souris;
}
/**************************************************************************/
/* affiche le copyright */
void apropos()

{
	rsrc_gaddr(R_TREE,COPYRIG,&dial);
	((TEDINFO *)dial[NUMVER].ob_spec)->te_ptext=version;
	((TEDINFO *)dial[NUMVER].ob_spec)->te_txtlen=strlen(version);
	Cache_Souris;
	afficheboite();
	Montre_Souris;
	sortie = form_do(dial,FAUX);
	Cache_Souris;
	effaceboite();
	Montre_Souris;
}
/**************************************************************************/
/* s‚lection d'un fichier … partir d'un disque */
int dialogue(source,type,suffixe)

char *source;
int type;
char *suffixe;
{
	int fichier,drive;
	char nomfich[80];
	char inpath[80];			   /* chemin d'acces */
	char insel[80];				   /* selection document */
	int bouton,res;
	long longueur = 32034;	/* longueur d'un fichier DEGAS */
	disk_info diskinfo;
	long space;

/* Obtention du nom du fichier source */
/* On affiche les fichiers dans le repertoire */
/* courant, sur le drive actif */

	drive=Dgetdrv();
	inpath[0]=drive+0x41;
	inpath[1]=NULL;
	strcat(inpath,":");
	Dgetpath(&inpath[2],drive+1);
	strcat(inpath,"\\*.");
	strcat(inpath,suffixe);
	insel[0]='\0';
	if (lecture && (!type)) 
	{
		strcpy(inpath,cheminlecture);
		strcpy(rindex(inpath,'.')+1,suffixe);
	}	
	if (ecriture && (type))
	{
		strcpy(inpath,cheminecriture);
		strcpy(rindex(inpath,'.')+1,suffixe);
	}
	if (type) 
	{
		strcpy(insel,nomsortie);
		strcpy(rindex(insel,'.')+1,suffixe);
	}
	if (!fsel_input(inpath,insel,&bouton)) return(FAUX);
	if (((bouton) && (insel[0] == '\0')) || (!bouton)) return(FAUX);
	else
	{
/* sauve le chemin pour le lecture des fichiers PI3 */
		if (type)
		{
			strcpy(cheminecriture,inpath);
			ecriture = VRAI;
		} 
		else 
		{ 
/* sauve le chemin pour l'‚criture des fichiers PS */
			strcpy(cheminlecture,inpath);
			lecture = VRAI;
		}
		strcpy(nomfich,inpath);
		strcpy(rindex(nomfich,'\\')+1,insel);
		strcpy(source,nomfich);	
		if (type) 
		{
/*
			Dfree(&diskinfo,(source[0]-'A')+1);
			space = diskinfo.b_free * diskinfo.b_clsiz * diskinfo.b_secsiz;
			if (space < 70000) 
			{
				form_alert(1,MESS4);
				return(FAUX);
			}
			else 
*/
				return(VRAI);
		}
		else
		{      
			if ((fichier = Fopen(nomfich,0)) < 0) 
			{
				form_alert(1,MESS5);
				return(FAUX);
			}
			else 
			{		
				Fread(fichier,longueur,ecran);
				Fclose(fichier);	
				return(VRAI); 
			}
		}
	}

/**********************************/
/* fin du programme ST_PostScript */
/***********************************************************************/
}
