/*
 *				Install.prg
 *
 *	Author  : FunShip
 *	File	: Fichier.C
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
#include <limits.h>

#include "F:\Aads.030\Include\PcAads.h"

#include "Types.h"
#include "InstallF.h"

#define	ATTRIB	FA_SUBDIR | FA_ARCHIVE | FA_READONLY	/* Folder & normal file */

#define	mkdir(Chemin)		Dcreate(Chemin)
#define GetPath(Chemin) 	Dgetpath(Chemin,0)

#define	FILTRE	"*.*"
#define BLOCK                   UINT_MAX-1              /* Buffer maximum */
#define PERMS                   0777

extern  unsigned long           FileCount;

char    Racine[PATHLONG];                               /* Repertoire de Install.Prg */
static	int			ModeCopy=RIEN;		/* Mod de copie de fichiers  */

extern	OBJECT			*Messages;		/* Arbres des messages */
extern	Type_Parametrage	Config;
extern	int			HandleFWork;

extern	int			WriteAlert(char *Path,char *Name);

/* ---------------------------------------------------------------------------
 *			Gestion de la jauge d'incr‚mentation
 */

static void IncJauge(int x,int y, int w,int h)
/*
	Incr‚mente la jauge de copie en fonction du nombre de fichiers copi‚s
	sur le total … faire.
	x,y,w,h sont le clipping AES fournie par AADS
	Total, FileCount et HandleFWork sont des var globales
*/
{
  OBJECT	*Arbre;
  TEDINFO	*Ted;
  int		Pourcent;
  char		Texte[3];
    
  rsrc_gaddr(R_TREE,FWORK,&Arbre);
  
  Arbre[JAUGE].ob_width = (int)(Arbre[BOITEJAUGE].ob_width * FileCount / Config.Files);

  Pourcent = (int)((FileCount * 100) / Config.Files);
  ltoa(Pourcent,Texte,BASE10);
  Ted=(TEDINFO *) Arbre[POURCENT].ob_spec.tedinfo;
  strcpy (Ted->te_ptext,Texte);

  objc_draw(Arbre,JAUGE,2,x,y,w,h);
  objc_draw(Arbre,POURCENT,2,x,y,w,h);
}

/* ---------------------------------------------------------------------------
 *				Commun Atari TOS/PC DOS
 */

void FselInput(char *Prefix,char *Dummy,int *Bouton,char *Label)
/*
	Appel le s‚lecteur de fichiers ‚tendue si le TOS actuel le permet.
	TOS >= 1.4
*/
{
  if(MchInfo.TosVersion < TOS14)
    fsel_input(Prefix,Dummy,Bouton);
  else
    fsel_exinput(Prefix,Dummy,Bouton,Label); 
}

static int EstInstall(char *Name)
/*
	Retourne TRUE si le nom est un fichier r‚serv‚ qu'il ne faut pas copier
	ex: Install.Prg, etc...
*/
{
  int	Indice=0,Retour=0;

  Retour = (strcmp(Name,"INSTALL.DAT") == 0) ? TRUE : FALSE;
  
  Indice = Name[4];					/* Est ce DISK??? */
  Name[4] = '\0';
  Retour |= (strcmp(Name,"DISK") == 0) ? TRUE: FALSE;
  Name[4] = Indice;
  return(Retour);
}

static Type_Special *EstSpecial(char *Name,Type_Parametrage *Config)
/*
        Retourne un pointeur sur le poste si le nom correspond a un fichier
        qui doir etre copie ailleur que dans le rep. d'install.
*/
{
  Type_Special  *Pointeur;

  Pointeur = Config->Special;
  while(Pointeur != NULL && strcmp(strupr(Pointeur->FileName),strupr(Name)) != 0)
    Pointeur = Pointeur->Suivant;
  return(Pointeur);
}

static int Overwrite(char *Path,char *Name)
/*
		V‚rifie si il existe d‚j… le fichier avant de le re‚crire.
		si il existe demande l'‚crasement, ‚crasement g‚n‚ral ou passer.
		Retourne TRUE = > Ecrasement du fichier ou g‚n‚ral
		FALSE => Passer
*/
{
  int	Fichier,Retour;
  
  if(ModeCopy == OVERWRITEALL)					/* Tout rempla‡er */
    Retour = TRUE;
  else								/* Demander … l'user */
  {
    if((Fichier = open(Path,O_RDONLY)) != -1)			/* Fichier existe */
    {
      close(Fichier);
      ModeCopy = WriteAlert(Path,Name);
      Retour = (ModeCopy == OVERWRITEALL || ModeCopy == OVERWRITE) ? TRUE : FALSE;
    }
    else							/* Fichier existe pas */
      Retour = TRUE;
  }
  return(Retour);
}

static int CreatFolder(char *Chemin,Type_Parametrage *Config)
/*
        Creer un repertoire dans le repertoire d'installation,
        d'apres le chemin absolu Chemin provenant de la source
        d'installation
        Retourne TRUE si OK
*/
{
  int   Indice=0;
  char  Destination[PATHLONG];

  while((Racine[Indice] == Chemin[Indice]) && (Racine[Indice] != '\0'))
    Indice++;
  strcpy(Destination,Config->Path);                     /* Install Path */
  if(Chemin[Indice] != '\\')                            /* Ajouter \ */
    strcat(Destination,"\\");

  strcat(Destination,Chemin+Indice);                    /* Chemin+folder … creer */
  return(mkdir(Destination));
}

/* ---------------------------------------------------------------------------
 * 				Programme XCopier()
 */

static void CrFolDf(char *Chemin)
/*
		Cr‚er la suite de chemin n‚cessaire … un fichier SPECIAL
*/
{
  char	*Prochain;
  
  Prochain = strchr(Chemin,'\\');		/* celui de X:\ */
  if(Prochain != NULL)
  {
    Prochain = strchr(Prochain + 1, '\\');	/* celui de X:\toto\ */
    while(Prochain != NULL )			/* cr‚er les interm‚diares */
    {
      *Prochain = '\0';
      mkdir(Chemin);
      *Prochain = '\\';
      Prochain = strchr(Prochain+1,'\\');
    }
    mkdir(Chemin);				/* Cr‚er le tout dernier */
  }
}

static int Xcopier(char *Name,Type_Parametrage *Config)
/*
        Copie un fichier de nom Name dans un chemin "special"
        defini par la commande SPECIAL du script.
*/
{
  int           Source,Target,Bouton,Retour;
  unsigned int  Compte;
  void          *Tampon;
  char          DestPath[PATHLONG],*Prochain,Message[PATHLONG],
  		Dummy[14]="\0",Prefix[PATHLONG],Label[30];
  Type_Special  *Pointeur;
  
  Tampon = malloc((size_t)BLOCK);
  if((Source = open(Name,O_RDONLY))!=-1)
  {
    if((Pointeur=EstSpecial(Name,Config)) != NULL)
    {
      strcpy(DestPath,Pointeur->Chemin);
      if(DestPath[strlen(DestPath)-1] != '\\')
        strcat(DestPath,"\\");
      strcat(DestPath,Name);
      /*
       *	V‚rifie si le chemin existe sinon le cr‚er ou en demander un autre
       *	(en essayent de cr‚er le fichier destination)
       */
      if((Target=creat(DestPath,PERMS)) == -1)		/* Erreur de cr‚ation */
      {
        sprintf(Message,Messages[MSG16].ob_spec.free_string,
        	Pointeur->Chemin,Name);
	if(form_alert(1,Message) == 1)			/* Cr‚er le r‚pertoire */
	  CrFolDf(Pointeur->Chemin);
	else						/* Localiser le r‚pertoire */
	{
	  strcpy(Prefix,Pointeur->Chemin);		/* r‚cupŠre X:\ dans le chemin */
	  Prochain = strchr(Prefix,'\\');
	  if(Prochain != NULL)
	    *(Prochain+1) = '\0';
	  strcat(Prefix,"*.*");
	  strcpy(Dummy,"\0");
	  sprintf(Label,Messages[MSG17].ob_spec.free_string,Name);
	  FselInput(Prefix,Dummy,&Bouton,Label); 
	  if(Bouton)
	  {
	    Prochain = strrchr(Prefix,'\\');
      	    *(Prochain+1) = '\0';			/* Supprimer le *.* … la fin */
    
            strcpy(DestPath,Prefix);			/* Recopier le nouveau chemin */
            strcat(DestPath,Name);			/* Et ajouter le nom du fichier */
          }
          else						/* Cr‚er celui par defaut */
          {
            form_alert(1,Messages[MSG18].ob_spec.free_string);
            CrFolDf(Pointeur->Chemin);
          }
	}
      }
      else						/* Pas de problŠme */
      {
        close(Target);					/* Le fermer */
        Fdelete(DestPath);				/* Et le d‚truire */
      }
      /*
       *	On modifie dans Config, le chemin d'‚criture du fichier sp‚cial pour
       *	ranger d‚finitivement son Drive+Chemin+Nom o— il sera copi‚
       */
      free(Pointeur->Chemin);				/* LibŠre l'ancienne chaine */
      Pointeur->Chemin = malloc(strlen(DestPath)+1);	/* alloue une nouvelle chaine */
      if(Pointeur != NULL)				/* allocation r‚ussie */
        strcpy(Pointeur->Chemin,DestPath);		/* Copie nouveau Drive+Chemin+Nom */
      else						/* Plus de m‚moire */
      {
        form_error(8);					/* memory error */
        return(FALSE);
      }
      /*
       *	Debut r‚el de la copie
       */      
      if(Overwrite(DestPath,Name))			/* Si Overwrite autoris‚ */
      {
        if((Target=creat(DestPath,PERMS)) == -1)	/* create error */
          Retour = FALSE;
        else
        {
          F_WriteText(FWORK,CHANGEDISK,Name);
          Compte = (unsigned int)read(Source,Tampon,BLOCK); /* Lecture du fichier */
          while(Compte > 0)
          {
            write(Target,Tampon,Compte);		/* Lecture du fichier */
            Compte = (unsigned int)read(Source,Tampon,BLOCK); /* Ecrire les octets lu */
          }
          close(Target);				/* Fermer les fichiers */
          Retour =TRUE;
        }
      }
      else						/* Pas d'overwrite */
        Retour = TRUE;

      close(Source);
      FileCount++;					/* Nombre de fichiers copi‚s */
      F_FreeDraw(HandleFWork,IncJauge);
    }
    else
      Retour = FALSE;
  }
  else
    Retour = FALSE;

  free(Tampon);
  return(Retour);
}

/* ---------------------------------------------------------------------------
 * 				Programme Copier()
 */

static int Copier(char *Nom,char *Chemin,Type_Parametrage *Config)
/*
        Copie avec écrasement des fichiers només Nom
        venant du repertoire absolue Chemin du disque d'installation.
*/
{
  int           Source,Target,Retour,Indice = 0;
  char          DestPath[PATHLONG];
  unsigned int  Compte;
  void          *Tampon;

  Tampon = malloc((size_t)BLOCK);
  if((Source = open(Nom,O_RDONLY))!=-1)
  {
    while((Racine[Indice] == Chemin[Indice]) && (Racine[Indice] != '\0'))
      Indice++;
    strcpy(DestPath,Config->Path);                      /* Install path */

    if(Chemin[Indice] != '\\')                          /* Ajouter \ */
      strcat(DestPath,"\\");
    strcat(DestPath,Chemin+Indice);                     /* Ajouter le chemin */

    if(DestPath[strlen(DestPath)-1] != '\\')            /* Ajouter \ */
      strcat(DestPath,"\\");
    strcat(DestPath,Nom);                               /* Ajouter le Nom du fichier */

    if(Overwrite(DestPath,Nom))				/* Overwrite file */
    {
      if((Target=creat(DestPath,PERMS)) == -1)
        Retour = FALSE;
      else
      {
        F_WriteText(FWORK,CHANGEDISK,Nom);
        Compte = (unsigned int)read(Source,Tampon,BLOCK);/* Lecture du fichier */
        while(Compte > 0)
        {
          write(Target,Tampon,Compte);			/* Lecture du fichier */
          Compte =(unsigned int)read(Source,Tampon,BLOCK);/* Ecrire les octets lu */
        }
        close(Target);					/* Fermer les fichiers */
        Retour = TRUE;
      }
    }
    else						/* Don't overwrite */
      Retour = TRUE;

    close(Source);					/* Ferme la source */
    FileCount++;					/* Compter quand meme */
    F_FreeDraw(HandleFWork,IncJauge);
  }
  else
    Retour = FALSE;
    
  free(Tampon);
  return(Retour);
}

/* ---------------------------------------------------------------------------
 * 				Programmes version Atari TOS
 */

int DiskVerify(int Disque)
/*
		Retourne TRUE si le disque porte le num‚ro solicit‚ dans le
		chemin d'install source.
		Le num‚ro sera un fichier vide ayant un nom de la forme: DISK5,DISK45,...
*/
{
  int	Fichier,Retour;
  char	Nom[13], Number[10];

  strcpy(Nom,"DISK");
  strcat(Nom,itoa(Disque,Number,BASE10));
  Retour = FALSE;
  if((Fichier = open(Nom,O_RDONLY)) != -1)
  {
    close(Fichier);
    Retour = TRUE;
  }
  return(Retour);
}

int FreeDisk(Type_Parametrage *Config)
/*
		Retourne TRUE si l'espace disque est suffisant.
*/
{
  DISKINFO	Disk;					/* Information Disque */
  char		Lecteur;				/* Lecteur … v‚rifier */
  unsigned long	Espace;					/* Espace libre calcul‚ */
  
  Lecteur = Config->Path[0] - 64;

  Dfree(&Disk,Lecteur);
  Espace = Disk.b_free * Disk.b_clsiz * Disk.b_secsiz;
  return( Espace > (Config->Space * 1024) );
  
}

void Parcourir(char *Chemin,Type_Parametrage *Config)
/*
        Parcour de l'arborescence du lecteur courant dans le chemin courant
        et copies avec creation de repertoires.
*/
{
  int	Done;
  char	Name[NAMELONG];					/* nom du fichier trouve */
  char	CurChemin[PATHLONG]; 				/* pour sauver/restaurer */
  DTA	*OldDta,NewDta;					/* Old and New DTA */


  OldDta=Fgetdta();					/* sauve la DTA courante */
  Fsetdta(&NewDta);					/* nouvelle DTA */
  Dsetpath(Chemin);					/* fixe le chemin courant */
  Done = Fsfirst(FILTRE,ATTRIB);			/* cherche le 1 element */
  while(!Done)						/* affiche tous les elements */
  {
    strcpy(Name,NewDta.d_fname);			/* recherche le nom du folder */
    if(NewDta.d_attrib & FA_SUBDIR)			/* Si est un repertoire */
    {
      if(Name[0]!='.')					/* si c'est pas "." ou ".." ! */
      {
        strcpy(CurChemin,Chemin);			/* sauve l'ancien chemin */

        if(Chemin[strlen(Chemin)-1] != '\\')
          strcat(Chemin,"\\");
        strcat(Chemin,Name);				/* chemin+name+\ */
        CreatFolder(Chemin,Config);                     /* Creer folder cible */
        Parcourir(Chemin,Config); 			/* appel recursif dans le 1 element */

        strcpy(Chemin,CurChemin);			/* restitue le chemin courant */
        Dsetpath(Chemin);				/* et le fixe */
      }
    }
    else						/* C'est un fichier */
    {
      if(!EstInstall(Name))				/* C'est pas un fichier d'install */
      {							/* Tel Install.prg,dat,rsc,... */
        if(EstSpecial(Name,Config)==NULL)
          Copier(Name,Chemin,Config);
        else
          Xcopier(Name,Config);
      }
    }
    Done = Fsnext();					/* prochain element */
  }
  Fsetdta(OldDta);					/* restitue la DTA */
}
