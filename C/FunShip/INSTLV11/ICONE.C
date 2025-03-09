/*
 *			Module d'installation d'icones sur le bureau
 *
 *	Author  : FunShip
 *	File	: Icone.C
 *	Date    : 07 August 1995
 *	Revision: 25 August 1995
 *	Version : 1.0
 *
 *
 */

#include <tos.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "F:\Aads.030\Include\PcAads.h"

#include "InstallF.h"
#include "Types.h"

/* ---------------------------------------------------------------------------
 *
 */
 
#define AES14   	0x140L
#define	AES33		0x330L
#define AES34   	0x340L
#define AES40   	0x400L

/*
 *              Taille tampon AES remarquable
 */

#define SIZEAES14       1024
#define SIZEAES34       4096

/*
 *              Taille des icones
 */

#define ICONHAUTEUR     42
#define ICONLARGEUR     32

#define	SHEL_BUFSIZE	-1

#define	DESKTOPINF	"C:\NewDesk.Inf"
#define	PLUS		2				/* 2 fois tampon Aes 4.1 */
#define EOD             26                      	/* End Of Desktop */

extern	OBJECT		*Messages;

/* ---------------------------------------------------------------------------
 *                            Proc‚dures priv‚es outils
 */

static unsigned int LngBufferAes(void)
/*
        Retourne la longueur du tampon AES du desktop, suivant la version de l'AES
        en cours.
*/
{
  unsigned int	Taille;
  char		Dummy;

  if(MchInfo.AesVersion <= AES14)			/* Version ant‚rieure */
    Taille = SIZEAES14;
  else if(MchInfo.AesVersion <= AES34)
    Taille = SIZEAES34;
  else							/* AES 4.1 => Calcul... */
    Taille = shel_get(&Dummy,SHEL_BUFSIZE);
  return(Taille);
}

static char *AllocBuffer(void)
/*
                Alloue une zone mémoire égale à la taille du tampon AES ou
                de 2 fois sa taille pour les AES 4.1 (Tampon non limit‚).
                pouvoir ajouter au moins une ligne #X ... au desktop.
*/
{
  if(MchInfo.AesVersion < AES40)	               	/* Tampon de taille fixe */
    return(malloc(LngBufferAes()));			/* retourne sa longueur fixe */
  else                                          	/* Tampon de taille illimité */
    return(malloc(PLUS * LngBufferAes()));		/* PLUS fois sa longueur actuelle */
}

static unsigned int Lenght(char *Tampon)
/*
        Retourne la longueur du fichier desktop pr‚sent dans le tampon en paramŠtre.
        La longueur ‚gale la position du EOD.
*/
{
  unsigned int		Indice=0;
  
  while(Tampon[Indice] != EOD)				/* Recherche le EOD */
    Indice++;
  return(Indice);
}

static void Affiche(void)
{
  char	*Tampon;
  int	indice;
    
  Tampon = AllocBuffer();
  shel_get(Tampon,LngBufferAes());
  
  for(indice=0;Tampon[indice] != EOD; indice++)
    Cconout(Tampon[indice]);
  free(Tampon);
}
 
void Myshel_get(char *Tampon,int Longueur)
/*
	Lecture du fichier Newdesk.Inf sur C:\ dans le Tampon en paramŠtre.
	Longueur est la longueur max. du tampon AES. 
*/
{
  int	Fichier;
  int	Compte;
  
  Fichier = (int)Fopen(DESKTOPINF,0);
  Compte = (int)Fread(Fichier,Longueur,Tampon);
  Tampon[Compte] = EOD;
  Fclose(Fichier);
}

/* ---------------------------------------------------------------------------
 *				Proc‚dures priv‚es 
 */

static int PlacerIcone(char *Tampon,char *Nom,char *Chemin,int Id,int x,int y)
/*
        Ajoute un nouvel icone dans le desktop du GEM. L'icone est ajout‚ dans
        le tampon en paramŠtre contenant le bureau courant.
        Si i y a assez de place l'icone est bien ajout‚ et on retourne True sinon
        False.
*/
{
  char          NewLine[256];
  int           Retour;

  if(strrchr(Chemin,'*') != NULL)				/* Cr‚er ligne R‚pertoire */
    sprintf(NewLine,"#V %02X %02X %02X FF   %s@ %s@ \n\r\032",x,y,Id,Chemin,Nom);
  else                                                 		/* Cr‚er ligne Fichier */
    sprintf(NewLine,"#X %02X %02X %02X FF   %s@ %s@ \n\r\032",x,y,Id,Chemin,Nom);
    
  if(MchInfo.AesVersion < AES40)	               		/* Tampon de taille fixe */
  {
    if(Lenght(Tampon) + strlen(NewLine) + 1 < LngBufferAes())	/* Encore de la place... */
    {
      strcpy(Tampon+Lenght(Tampon),NewLine);
      Retour = TRUE;
    }
    else
      Retour = FALSE; 
  }
  else								/* Tampon non fixe */
  {
    if(Lenght(Tampon) + strlen(NewLine) + 1 < PLUS * LngBufferAes())	/* Encore de la place... */
    {
      strcpy(Tampon+Lenght(Tampon),NewLine);
      Retour = TRUE;
    }
    else
      Retour = FALSE;
  }
  return(Retour);
}

/* ---------------------------------------------------------------------------
 *				Proc‚dures publiques
 */

int CreerIcone(Type_Parametrage *Config)
/*
        Placement des icones sur le bureau:
        Parcour la file des icones et les place en partant du coin
        inf‚rieur gauche de l'‚cran jusq'au coin sup‚rieur droit.
        Si on r‚ussi … ajouter tous les icones on retourne True sinon False.
*/
{
  int           x,y;
  Type_Icone    *Pointeur;
  int           Retour;
  char		*Tampon;
  char		Chemin[PATHLONG];  

  /*
   *		V‚rifie que l'Aes supporte les icones fichiers sur le bureau
   */
  if(MchInfo.AesVersion < AES33)			/* AES TT minimum */
  {
    form_alert(1,Messages[MSG20].ob_spec.free_string);
    return(FALSE);
  }
  
  /*
   *		Installation des icones
   */
  Tampon = AllocBuffer();				/* Allouer un tampon = Tampon Aes */
  if(Tampon == NULL)					/* si ‚chec => plus de m‚moire */
  {
    form_error(8);					/* Standard erreur memoire */
    Retour = FALSE;
  }
  else   	                                     	/* Tampon correctement allou‚ */
  {
    /*
     *		Lecture du Fichier Newdesk.inf
     */
    Myshel_get(Tampon,LngBufferAes());			/* Copier le contenu systŠme */

    Pointeur = Config->Icone;
    y = (DesktopH / ICONHAUTEUR) - 1;			/* En bas au d‚part */
    x = 0;                                    		/* Bord gauche au d‚part */
    Retour = TRUE;
    while(Pointeur != NULL && Retour)            	/* Pour toutes les icones */
    {
      strcpy(Chemin,Config->Path);			/* Copie la racine d'install */
      strcat(Chemin,Pointeur->Chemin);			/* Copie le chemin d'acces icone */
				      			/* ex: X:\Newfolder\...\a.prg */
      Retour = PlacerIcone(Tampon,Pointeur->Nom,Chemin,Pointeur->Id,x,y);
      if(x < (DesktopW / ICONLARGEUR) - 1)		/* Inf. au bord droit */
        x++;
      else                                        	/* Totalement à droite */
      {
        x = 0;
        if(y >= 0)                                  	/* Inf. au cot‚ sup. */
          y--;
        else                                        	/* Totalement en haut */
          y = (DesktopH / ICONHAUTEUR) - 1;
      }
      Pointeur = Pointeur->Suivant;               	/* Icone suivante */
    }
    /*
     *		Mise … jour du tampon AES
     */
    if(MchInfo.AesVersion >= AES40)
      Retour |= shel_put(Tampon,Lenght(Tampon));  
    else
      shel_put(Tampon,LngBufferAes());			/* Copier dans tampon systeme */
    free(Tampon);
  }
  /*
   *	Fin d'installation des icones
   */  
  if(!Retour)						/* Tout icones non pla‡‚s ! */
    form_alert(1,Messages[MSG19].ob_spec.free_string);
  return(Retour);
}
