#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>

/* --- */

#define TRUE		1
#define FALSE		0

extern OBJECT *dial[];
#include "new_stps.h"
extern char *messages[];
extern int date[2];
extern long taille;
extern char chaine[];
int hand;
char *point;

/* --- */

/*	PROCEDURE D'OBTENTION DES DESCRIPTEURS DES FICHIERS	*/
/*	SOURCE ET DESTINATION								*/
/*														*/
/*	Rend istr (fd fichier source, entree)				*/
/*				ostr (fd fichier destination, sortie)	*/
/*		nom du fichier source							*/
/*			1 si OK, -1 si non OK						*/

int dialogue(istr,source,deja_ouvert)
FILE **istr;
char *source;
int deja_ouvert;
{
	int buffer[8];
	char nomfich[80];
	char inpath[80];				/* chemin d'acces  */
	char insel[80];					/* selection document */
	int bouton,drive,i;
	FILE *fd;

	/*	Obtention du nom du fichier source				*/
	/*	On affiche les fichiers *.* dans le repertoire	*/
	/*	courant, sur le drive actif						*/

	drive=Dgetdrv();
	inpath[0]=drive+'A';
	inpath[1]=NULL;
	strcat(inpath,":");
	if(Dgetpath(&inpath[2],drive+1)<0) form_alert(1,messages[3]);
	strcat(inpath,"\\*.*");
	insel[0]=NULL;
	dial[MESSAGES][ROOT].ob_x=(640-dial[MESSAGES][ROOT].ob_width)/2;
	dial[MESSAGES][ROOT].ob_y=24;
	dial[MESSAGES][BOXMOUSE].ob_flags|=HIDETREE;
	dial[MESSAGES][ROOT].ob_height=dial[MESSAGES][BOXCHAIN].ob_height;
	strcpy(((TEDINFO *)dial[MESSAGES][CHAINE].ob_spec)->te_ptext,"FICHIER A TRADUIRE");
	ouvre_form(buffer,dial[MESSAGES],FALSE,FALSE);
	fsel_input(inpath,insel,&bouton);
	ferme_form(buffer,FALSE);
	if(!bouton) return(-2);

	/* sauvegarde du chemin d'acces et constitution */
	/* du nom complet du fichier d'entree           */

	strcpy(nomfich,inpath);
	strcpy(rindex(nomfich,'\\')+1,insel);

	/* Ouverture en lecture du fichier d'entree */

	if ((fd = fopen(nomfich,"r")) == NULL )
    {
       	sprintf(nomfich,messages[4],insel);
       	form_alert(1,nomfich);
       	return(-1);
    }
    if (deja_ouvert) fclose(*istr);
    *istr=fd;
	strcpy(source,nomfich);

/* -- Lecture Date, heure et taille -- */

	fseek(*istr,0L,2);
	taille=ftell(*istr);
	rewind(*istr);
	hand=open(source,0);
	Fdatime(date,hand,0);
	close(hand);
	point=((TEDINFO *)dial[DOCFIRST][DATE].ob_spec)->te_ptext;
	sprintf(point,"%02d/%02d/%2d",date[1] & 31,(date[1]>>5) & 15,80+
		((date[1]>>9) & 127));
	*(point+8)=0;
	point=((TEDINFO *)dial[DOCFIRST][HEURE].ob_spec)->te_ptext;
	sprintf(point,"%02d:%02d:%02d",(date[0]>>11) & 31,(date[0]>>5) & 63,
		(date[0] & 31)*2);
	*(point+8)=0;
	sprintf(((TEDINFO *)dial[DOCFIRST][TAILLE].ob_spec)->te_ptext,
		"%lu",taille);
	return(1);
}
