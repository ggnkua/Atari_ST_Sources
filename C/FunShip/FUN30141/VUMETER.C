/*
 *		Fun Falcon 030	Version 1.41
 *
 *		File source to control Vu-Meter display
 *		FunShip - Atari Falcon30
 *	
 */

#include "F:\Aads.030\Include\PCAADS.h"
#include "FUN__30F.h"

#define NB_POINT	10			/* 10 digits pour chaque Vu-Metre */

extern	signed int	*Tampon;
extern	OBJECT		*ArbreDisplay;

/* 
 *	Liste des indices des champs des digits des Vu-Metres 
 */
static int  OutLeftLevel[NB_POINT+1] = {0,LN0,LN1,LN2,LN3,LN4,LN5,LN6,LN7,LN8,LN9};
static int  OutRightLevel[NB_POINT+1]= {0,RN0,RN1,RN2,RN3,RN4,RN5,RN6,RN7,RN8,RN9};

/*
 *	Table des seuils de d‚clenchements des digits lin‚aires aux valeurs
 *	‚chantillonn‚es.
 */
	
static long gain[NB_POINT+1]
	= {0L,0L,3274L,6548L,9822L,13096L,16370L,19644L,22918L,26192L,29466L};

/*
 *		Code de la routine d'affichage Logarithmique, Log10(n)
 */

void LevelDisplay(int x,int y,int w,int h)
/*
	Affiche sur les Vu-Metres le niveau sonore des canaux gauches et droites.
	Entree:	Ptr sur l'arbre d'objets contenant les vu-metres
		niveaux de chaque canal
	Sortie:	rien
*/
{
  int register	Indice;
  
  Indice = NB_POINT;
  while(Indice)
  {
    if((long)Tampon[0] < gain[Indice])
      ArbreDisplay[OutLeftLevel[Indice]].ob_state &=~SELECTED;
    else
      ArbreDisplay[OutLeftLevel[Indice]].ob_state |=SELECTED;

    if((long)Tampon[1] < gain[Indice])
      ArbreDisplay[OutRightLevel[Indice--]].ob_state &=~SELECTED;
    else
      ArbreDisplay[OutRightLevel[Indice--]].ob_state |=SELECTED;
  }
  objc_draw(ArbreDisplay,VUMETERL,2,x,y,w,h);
  objc_draw(ArbreDisplay,VUMETERR,2,x,y,w,h); 
}

void QuickDisplay(void)
/*
	Affiche sur les Vu-Metres le niveau sonore des canaux gauches et droites.
	Devrait etre plus rapide que la pr‚c‚dente mais ne fonctionne pas avec le 
	clipping de r‚gion.
	
	Entree:	Ptr sur l'arbre d'objets contenant les vu-metres
		niveaux de chaque canal
	Sortie:	rien
*/
{
  int register	Indice;
  
  Indice = NB_POINT;
  while(Indice)
  {
    if((long)Tampon[0] < gain[Indice])
      objc_change(ArbreDisplay,OutLeftLevel[Indice],0,ArbreDisplay->ob_x,ArbreDisplay->ob_y,
      		  ArbreDisplay->ob_width,ArbreDisplay->ob_height,FALSE,TRUE);
    else
      objc_change(ArbreDisplay,OutLeftLevel[Indice],0,ArbreDisplay->ob_x,ArbreDisplay->ob_y,
      		  ArbreDisplay->ob_width,ArbreDisplay->ob_height,SELECTED,TRUE);

    if((long)Tampon[1] < gain[Indice])
      objc_change(ArbreDisplay,OutRightLevel[Indice--],0,ArbreDisplay->ob_x,ArbreDisplay->ob_y,
      		  ArbreDisplay->ob_width,ArbreDisplay->ob_height,FALSE,TRUE);
    else
      objc_change(ArbreDisplay,OutRightLevel[Indice--],0,ArbreDisplay->ob_x,ArbreDisplay->ob_y,
      		  ArbreDisplay->ob_width,ArbreDisplay->ob_height,SELECTED,TRUE);
  }
}
