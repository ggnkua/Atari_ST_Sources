/*
 *              Interpretation du fichier script & initialise
 *              les structures de donn‚es
 *
 *	Author  : FunShip
 *	File	: Script.C
 *	Date    : 07 August 1995
 *	Revision: 20 August 1995
 *	Version : 1.0
 *
 *
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <aes.h>

#include "Types.h"

/*
 *              D‚clarations des variables globales
 */

#define NBCOMMANDE      13                      /* Nbr Commande connue */

#define PATH            0                       /* Codes des commandes */
#define SPACE           1
#define CNAME           2
#define CINFO           3
#define NUMBER          4
#define PROG            5
#define CMDLINE         6
#define PROGINFO        7
#define SPECIAL         8
#define DISK            9
#define FILES           10
#define	ICON		11
#define	LOCATION	12

/* Commandes connues du "langage" script*/
static char    Liste[NBCOMMANDE][10]={  "PATH",
					"SPACE",
					"NAME",
					"INFO",
                                        "NUMBER",
                                        "PROG",
                                        "CMDLINE",
                                        "PROGINFO",
                                        "SPECIAL",
                                        "DISK",
                                        "FILES",
                                        "ICON",
                                        "LOCATION"
                                      };

static Type_Disk        *DiskLast;      /* Pointe le dernier poste disk */

/* ---------------------------------------------------------------------------
 *				Primitives priv‚es
 */

static int EstCommand(char Commande[])
/*
        Retourne l'indice de la commande reconnue ou une valeur < 0 sinon.
*/
{
  int   Indice=0;

  while((Indice < NBCOMMANDE) && (strcmp(Liste[Indice],Commande) !=0))
    Indice++;
  Indice = (Indice < NBCOMMANDE) ? Indice : -1;
  return(Indice);
}

static int Extraire(char Ligne[],int *Position,char Mot[])
/*
        Extrait un mot de la ligne
*/
{
  int   Indice;

  if(Ligne[*Position] == '\0' || Ligne[*Position] == '\n')
    return(FALSE);

  while(Ligne[*Position] == ' ' ||  Ligne[*Position] == '\t')
        (*Position)++;

  Indice=0;
  while((*Position < strlen(Ligne)) && (Ligne[*Position] != ' ') &&
        (Ligne[*Position] != '\n') && (Ligne[*Position] != '\t'))
  {
    Mot[Indice] = Ligne[*Position];
    Indice++;
    (*Position)++;
  }
  Mot[Indice] = '\0';
  return(TRUE);
}

static int AddDisk(char Parametre[],Type_Parametrage *Config)
/*
        Ajoute dans la liste des "Disk" les noms des disquettes.
*/
{
  Type_Disk     *CurDisk;

  if((CurDisk = malloc(sizeof(Type_Disk))) != NULL)
  {
    if((CurDisk->Name=malloc(strlen(Parametre)))!=NULL)
    {
      strcpy(CurDisk->Name,Parametre);
      CurDisk->Suivant = NULL;
      if(Config->Disk == NULL)
        Config->Disk = CurDisk;
      else
        DiskLast->Suivant = CurDisk;
      DiskLast = CurDisk;
      return(TRUE);
    }
  }
  return(FALSE);
}

static int AddSpecial(char Parametre[],Type_Parametrage *Config)
/*
        Ajoute dans la liste des "Special" les (noms,Chemin) des fichiers
        à copier ailleurs
*/
{
  Type_Special  *CurSpecial;
  char          *Pointeur;

  strupr(Parametre);
  if((CurSpecial = malloc(sizeof(Type_Disk))) != NULL)
  {
    if((CurSpecial->FileName=malloc(strlen(Parametre)))!=NULL &&
       (CurSpecial->Chemin=malloc(strlen(Parametre)))!=NULL)
    {
      Pointeur = strchr(Parametre,',');
      if(Pointeur != NULL)
      {
        *Pointeur = '\0';
        strcpy(CurSpecial->FileName,Parametre);
        *Pointeur = ',';
        strcpy(CurSpecial->Chemin,++Pointeur);
        CurSpecial->Suivant = Config->Special;
        Config->Special = CurSpecial;
        return(TRUE);
      }
    }
  }
  return(FALSE);
}

static int AddIcon(char Parametre[],Type_Parametrage *Config)
/*
        Ajoute dans la liste des "Special" les (noms,Chemin) des fichiers
        … copier ailleurs
*/
{
  Type_Icone	*CurIcon;
  char          *Pointeur,*Pointeur2;

  if((CurIcon = malloc(sizeof(Type_Icone))) != NULL)
  {
    if((CurIcon->Nom=malloc(strlen(Parametre)))!=NULL &&
       (CurIcon->Chemin=malloc(strlen(Parametre)))!=NULL)
    {
      Pointeur = strchr(Parametre,',');
      if(Pointeur != NULL)
      {
        *Pointeur = '\0';
        CurIcon->Id = atoi(Parametre);			/* N' d'icones … installer */

        *Pointeur = ',';				
        Pointeur++;					/* Information suivante */
        Pointeur2 = strchr(Pointeur,',');
        if(Pointeur2 != NULL)
        {
          *Pointeur2 = '\0';
          strcpy(CurIcon->Nom,Pointeur);		/* R‚cupŠre son futur nom */

          *Pointeur2 = ',';
          Pointeur2++;
          strupr(Pointeur2);				/* Passer chemin en MAJUSC. */
          strcpy(CurIcon->Chemin,Pointeur2);		/* R‚cupŠre son chemin */
        
          CurIcon->Suivant = Config->Icone;
          Config->Icone = CurIcon;
          return(TRUE);
        }
      }
    }
  }
  return(FALSE);
}

/* ---------------------------------------------------------------------------
 *				Uniquement pour UnInstall
 */

static int AddLocation(char Parametre[],Type_Parametrage *Config)
/*
        Ajoute dans la liste des "Special" les Chemin des fichiers
        … d‚sinstaller ailleurs signal‚ par la commande LOCATION existante
        que dans UnInstall.Dat.
*/
{
  Type_Special  *CurSpecial;

  strupr(Parametre);
  if((CurSpecial = malloc(sizeof(Type_Disk))) != NULL)
  {
    if((CurSpecial->FileName=malloc(strlen(Parametre)))!=NULL &&
       (CurSpecial->Chemin=malloc(strlen(Parametre)))!=NULL)
    {
      strcpy(CurSpecial->Chemin,Parametre);		/* Drive+Chemin+Nom */
      CurSpecial->FileName = NULL;			/* Pas de nom dans ce cas */
	
      CurSpecial->Suivant = Config->Special;		/* Chainage */
      Config->Special = CurSpecial;
      return(TRUE);
    }
  }
  return(FALSE);
}

/* ---------------------------------------------------------------------------
 *
 */
 
static int Executer(char Commande[],char Parametre[],Type_Parametrage *Config)
/*
        Execute l'action n‚cessaire pour une commande: Initialise
        la structure de donn‚es Config d'aprŠs la commande reconnue.
*/
{
  int           Indice,Retour=TRUE;
  
  if((Indice=EstCommand(Commande)) >= 0)
  {
    switch(Indice)              /* Selon l'indice de la commande */
    {
      case PATH:        Config->Path = malloc(strlen(Parametre)+1);
                        strcpy(Config->Path,strupr(Parametre));
                        break;
      case SPACE:       Config->Space = atoi(Parametre);
                        break;
      case CNAME:       Config->Name = malloc(strlen(Parametre)+1);
                        strcpy(Config->Name,Parametre);
                        break;
      case CINFO:       Config->Info = malloc(strlen(Parametre)+1);
                        strcpy(Config->Info,Parametre);
                        break;
      case NUMBER:      Config->Number = atoi(Parametre);
                        break;
      case PROG:        Config->Prog = malloc(strlen(Parametre)+1);
                        strcpy(Config->Prog,Parametre);
                        break;
      case CMDLINE:     Config->CmdLine = malloc(strlen(Parametre)+1);
                        strcpy(Config->CmdLine,Parametre);
                        break;
      case PROGINFO:    Config->ProgInfo = malloc(strlen(Parametre)+1);
                        strcpy(Config->ProgInfo,Parametre);
                        break;
      case FILES:       Config->Files = atoi(Parametre);
                        break;
                        /*
                         *	Commandes "soeurs"
                         */
      case SPECIAL:     Retour = AddSpecial(Parametre,Config);
                        break;
      case DISK:        Retour = AddDisk(Parametre,Config);
                        break;
      case ICON:	Retour = AddIcon(Parametre,Config);
      			break;
      case LOCATION:    Retour = AddLocation(Parametre,Config);	/* Command de UnInstall ! */
                        break;
      default:          break;
    }
    if(!Retour)
    {
      form_error(8);						/* Not enough memory */
      Retour = FALSE;
    }
  }
  return(Retour);
}

/* ---------------------------------------------------------------------------
 *				Primitive analyse d'une ligne
 */

static int Analyser(char Ligne[],Type_Parametrage *Config)
/*
        Analyse d'une ligne:
        Isole chacune des commandes avec leur paramŠtres et appel leur
        interpretation.
        La structure de donn‚es de configuration est alors initialisee.
*/
{
  int   Index;
  char  Commande[LIGNE],Egal[LIGNE],Parametre[LIGNE];
  char  Dummy[LIGNE],Message[255];
  
  if(Ligne[0] != '\0' && Ligne[0] != '\t' &&
     Ligne[0] != '\n' && Ligne[0] != ';')
  {
    Index=0;
    Extraire(Ligne,&Index,Commande);			/* Lire la commande */
    strupr(Commande);					/* En majuscule */
    Extraire(Ligne,&Index,Egal);			/* Lire le = */
    Extraire(Ligne,&Index,Parametre);			/* Lire le paramŠtre */
    
    if(Commande[0] == '\0' || Egal[0] == '\0' || Parametre[0] == '\0')
    {
      sprintf(Message,"[3][ Syntax error at: | %s %s %s ][Ok]",Commande,Egal,Parametre);
      form_alert(1,Message);
      return(FALSE);
    }
    else
    {
      if(  (strcmp(Commande,"NAME") == 0) 
      	|| (strcmp(Commande,"INFO") == 0)
        || (strcmp(Commande,"PROGINFO") == 0)
        || (strcmp(Commande,"CMDLINE")==0)
        || (strcmp(Commande,"DISK")==0))
      { 						/* Le parametre contient des blancs */
        while(Extraire(Ligne,&Index,Dummy))
        {
          strcat(Parametre," ");
          strcat(Parametre,Dummy);
        }
      }
      return(Executer(Commande,Parametre,Config));           /* Interpreter */
    }
  }
  return(TRUE);
}

/* ---------------------------------------------------------------------------
 *				Primitive publiques
 */
 
static void SetDefaultConfig(Type_Parametrage *Config)
/*
        Initialisation par defaut de la structure de config.
*/
{
  Config->Path          = NULL;
  Config->Space         = 0;
  Config->Name          = NULL;
  Config->Info          = NULL;
  Config->Number        = 1;
  Config->Files         = 1;
  Config->Prog          = NULL;
  Config->CmdLine       = NULL;
  Config->ProgInfo      = NULL;
  Config->Disk          = NULL;
  Config->Special       = NULL;
  Config->Icone		= NULL;
}

void CleanUp(Type_Parametrage *Config)
/*
	LibŠre la m‚moire allou‚e dans les differents pointeur de la structure
*/
{
  Type_Disk	*Ptr1;
  Type_Special	*Ptr2;
  Type_Icone	*Ptr3;
  
  free(Config->Path);				/* Chemin d'installation */
  free(Config->Name);       			/* Nom du Soft */
  free(Config->Info);				/* Info du Soft */
  free(Config->Prog);			        /* Prg à appeler */
  free(Config->CmdLine);       			/* Command line */
  free(Config->ProgInfo);      			/* Info Prg à appeler */

  Ptr1 = (void *)Config->Disk;
  while(Config->Disk != NULL)
  {
    Ptr1 = Config->Disk;
    Config->Disk = Config->Disk->Suivant;
    free(Ptr1->Name);
    free(Ptr1);
  }
  Ptr2 = (void *)Config->Special;
  while(Config->Special != NULL)
  {
    Ptr2 = Config->Special;
    Config->Special = Config->Special->Suivant;
    free(Ptr2->FileName);
    free(Ptr2->Chemin);
    free(Ptr2);
  }
  Ptr3 = (void *)Config->Icone;
  while(Config->Icone != NULL)
  {
    Ptr3 = Config->Icone;
    Config->Icone = Config->Icone->Suivant;
    free(Ptr3->Nom);
    free(Ptr3->Chemin);
    free(Ptr3);
  }
}

int TraiterScript(FILE *Fichier,Type_Parametrage *Config)
/*
        Parcour du fichier script d'installation
*/
{
  char  Ligne[LIGNE];
  int	Done=TRUE;
  
  SetDefaultConfig(Config);                             /* Config d'install defaut */
  while(!feof(Fichier) && Done)                         /* Pour toutes les lignes */
  {
    fgets(Ligne,LIGNE,Fichier);                         /* Lire une ligne */
    Done = Analyser(Ligne,Config);                      /* L'interpreter */
  }
  fclose(Fichier);                                      /* Fermer fichier script */
  return(Done);
}

