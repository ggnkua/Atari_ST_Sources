/*
 *				Install.prg
 *				Module de d‚sinstallation
 *
 *	Author  : FunShip
 *	File	: UnInstal.C
 *	Date    : 07 August 1995
 *	Revision: 02 September 1995
 *	Version : 1.0
 *
 *
 */

#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "F:\Aads.030\Include\PcAads.h"
#include "Types.h"
#include "InstallF.h"

#define	ATTRIB	FA_SUBDIR | FA_ARCHIVE | FA_READONLY	/* Folder & normal file */
#define	FILTRE	"*.*"

extern	long			FileCount;		/* Nombre de fichiers au total */
extern	OBJECT			*Messages;		/* Arbre d'objets des messages */

static	long			NbFiles;
int				HandleFuninst;

/* ---------------------------------------------------------------------------
 *                            Procedures gestion de la jauge
 */
 
static void DecJauge(int x,int y, int w,int h)
/*
	Incr‚mente la jauge de copie en fonction du nombre de fichiers copi‚s
	sur le total … faire.
	x,y,w,h sont le clipping AES fournie par AADS
	Total, FileCount et HandleFWork sont des var globales
*/
{
  OBJECT	*Arbre;
  int		Largeur;    
  
  rsrc_gaddr(R_TREE,FUNINST,&Arbre);
  
  Largeur = (int)(Arbre[UNBOITE].ob_width * FileCount / NbFiles);
  Arbre[UNJAUGE].ob_width = (FileCount > 0L) ? Largeur : 0;
  objc_draw(Arbre,UNBOITE,2,x,y,w,h);
}

/* ---------------------------------------------------------------------------
 * 				Programmes d'effacements
 */

static int RemoveFile(char *Chemin)
/*
	D‚truit un fichier sp‚cifi‚ dans chemin et appel la d‚cr‚mentation
	de la jauge.
	Retourne True si le fichier est effac‚.
*/
{
  int   Retour;
  DTA   *OldDta,NewDta;

  OldDta=Fgetdta();					/* save previous Dta */
  Fsetdta(&NewDta);					/* set a new Dta */

  if(!Fsfirst(Chemin,ATTRIB))				/* Searching this file */
  {
    if(NewDta.d_attrib & FA_READONLY)			/* if read only */
      Fattrib(Chemin,TRUE,NewDta.d_attrib & ~FA_READONLY);	/* change to read/write */
    Retour = ~Fdelete(Chemin);
    if(Retour)						/* if is deleted */
    {
      FileCount--;                                      /* downcount this file */
      F_FreeDraw(HandleFuninst,DecJauge);		/* shrink thmermometer */
    }
    else                                                /* Delete failed ! */
      form_alert(1,Messages[MSG24].ob_spec.free_string);
  }
  else                                                  /* File not found !! */
    form_alert(1,Messages[MSG25].ob_spec.free_string);
  Fsetdta(OldDta);
  return(Retour);
}

static int RemoveDir(char *Chemin)
/*
	Efface le r‚petoire sp‚cifi‚ dans chemin ainsi que tous ses sous
	réperoires et fichiers pr‚sents.
	(On considŠre le chemin pr‚sent sur le lecteur actuel.)
	Retourne True si pas de problŠmes sinon False.
*/
{
  int	Done,Retour;
  char	Name[NAMELONG];					/* nom du fichier trouve */
  char	CurChemin[PATHLONG]; 				/* pour sauver/restaurer */
  DTA	*OldDta,NewDta;					/* New DTA */

  OldDta=Fgetdta();					/* sauve la DTA courante */
  Fsetdta(&NewDta);					/* nouvelle DTA */
  Dsetpath(Chemin);					/* fixe le chemin courant */

  Done = Fsfirst(FILTRE,ATTRIB);			/* cherche le 1 element */
  Retour = TRUE;
  while(!Done)						/* affiche tous les elements */
  {
    strcpy(Name,NewDta.d_fname);			/* recherche le nom du fichier */
    if(NewDta.d_attrib & FA_SUBDIR)			/* Si c'est un repertoire */
    {
      if(Name[0]!='.')					/* si c'est pas "." ou ".." ! */
      {
	strcpy(CurChemin,Chemin);			/* sauve l'ancien chemin */

	if(Chemin[strlen(Chemin)-1] != '\\')
	  strcat(Chemin,"\\");
	strcat(Chemin,Name);				/* chemin+name+\ */
	RemoveDir(Chemin);				/* appel recursif dans le 1 element */

	strcpy(Chemin,CurChemin);			/* restitue le chemin courant */
	Dsetpath(Chemin);				/* et le fixe */
      }
    }
    else						/* C'est un fichier */
      Retour &= RemoveFile(Name);			/* Effacer le fichier */
    Done = Fsnext();					/* prochain element */
  }
  Fsetdta(OldDta);					/* restitue la DTA */
  Ddelete(Chemin);                                      /* Efface le r‚pertoire pŠre */
  return(Retour);
}

static int RemoveSpecial(Type_Parametrage *Config)
/*
	Efface tous les fichiers présents dans la liste des "copi‚s ailleurs" si il
	y en a.
	Retourne TRUE si pas de problèmes sinon False.
*/
{
  Type_Special  *Pointeur;
  int           Retour=TRUE;

  Pointeur = Config->Special;                           /* Premier poste d'un fichier */
  while(Pointeur != NULL)                               /* Pour tous les postes */
  {
    Retour  &= RemoveFile(Pointeur->Chemin);		/* Effacer le fichier */
    Pointeur = Pointeur->Suivant;                       /* Poste suivant */
  }
  return(Retour);
}

/* ---------------------------------------------------------------------------
 * 			     G‚n‚ration du script de d‚sinstallation
 */

int MkUnInsDat(Type_Parametrage *Config)
/*
	G‚nŠre le fichier de d‚sinstallation
*/
{
  FILE		*Fichier;
  char		Chemin[PATHLONG];
  Type_Special	*Pointeur;
  
  strcpy(Chemin,Config->Path);
  strcat(Chemin,"\\");
  strcat(Chemin,UNINSTAL);
  
  Fichier = fopen(Chemin,"w");
  if(Fichier == NULL)
  {
    form_error(2);
    return(FALSE);
  }
  
  fprintf(Fichier,"; UnInstall file maked by Install.Prg V1.0\n");
  fprintf(Fichier,"; Copyright FRANCE 1995 - FunShip - ATARI Falcon30\n");
  
  fprintf(Fichier,"\n; Software's path to remove\n\n");
  fprintf(Fichier,"PATH		=	%s\n",Config->Path);
  fprintf(Fichier,"SPACE	=	%ld\n",Config->Space);
    
  fprintf(Fichier,"\n; Software's name\n\n");
  fprintf(Fichier,"NAME		=	%s\n",Config->Name);
  fprintf(Fichier,"INFO		=	%s\n",Config->Info);

  fprintf(Fichier,"\n; Number of files expected\n\n");
  fprintf(Fichier,"FILES	=	%ld\n",Config->Files);
  
  fprintf(Fichier,"\n; List of files copied in another location\n\n");  
  Pointeur = Config->Special;
  while(Pointeur != NULL)
  {
    fprintf(Fichier,"LOCATION	=	%s\n",Pointeur->Chemin);
    Pointeur = Pointeur->Suivant;
  }
  fprintf(Fichier,"\n; End Of File\n");

  fclose(Fichier);
  return(TRUE);
}

/* ---------------------------------------------------------------------------
 * 		     Programmes point d'entr‚ du bouton UnInstall
 */

void UnInstall(Type_Parametrage *Config)
/*
	Effectue la d‚sinstallation du logiciel
*/
{
  int   NewLecteur;
  char  *Pointeur;
  char  Chemin[PATHLONG];
  
  NewLecteur = Config->Path[0] - 'A';			/* compute the new drive */
  Dsetdrv(NewLecteur);                                  /* Set new drive */

  NbFiles = Config->Files + 1L;				/* Number of files to remove */
  FileCount = Config->Files;				/* plus Uninstal.Dat */
    
  Pointeur = strchr(Config->Path,'\\');                 /* searching first \ */
  if(Pointeur != NULL)                                  /* If found */
  {
    strcpy(Chemin,Pointeur);				/* Extracting the folder to delete */
    RemoveDir(Chemin);                                  /* Deleting this folder */
    RemoveSpecial(Config);                              /* Deleting 'Special' Files */
    form_alert(1,Messages[MSG26].ob_spec.free_string);
  }
  else                                                  /* Else error ! */
    form_alert(1,Messages[MSG27].ob_spec.free_string);
}
