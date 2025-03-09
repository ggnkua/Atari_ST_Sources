/*
 *			Install.prg Version ATARI GEM
 *
 *	Author  : FunShip
 *	File	: Install.C
 *	Date    : 07 August 1995
 *	Revision: 30 December 1955
 *	Version : 1.1
 *
 *		Ver 1.1: - Correction du message syst‚matique pour les TOS < 2.0
 *			   ("L'aes ne supporte pas les icones" )
 *
 *			 - Le F_Close(FPATH) pouvait provoquer une erreur de bus al‚atoire
 *
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#include "F:\AADS.030\Include\PcAads.h"

#include "Types.h"
#include "InstallF.h"

#include <tos.h>

#define	CODEVERSION		"1.10"			/* Version d'Install */
#define	DATEVERSION		"30/12/1995"		/* Date Version */

#define GetPath(Chemin) 	Dgetpath(Chemin,0)
#define	mkdir(Chemin)		Dcreate(Chemin)

/* ---------------------------------------------------------------------------
 *                      Definitions globales Formulaires
 */

void Quitter(void);
void Accepter(void);
void Desinstall(void);
void PhotoCachee(void);

Type_Form_List
FormMain[]=	{	{QUITTER	,Quitter	,NULL},
			{ACCEPTER	,Accepter	,PhotoCachee},
			{UNINSTALL	,Desinstall	,PhotoCachee},
			FORM_END
		};

void Demarrer(void);
void ParcourPath(void);

Type_Form_List
FormPath[]=	{	{ANNULER	,Quitter	,NULL},
			{INSTALLER	,Demarrer	,NULL},
			{PARCOURIR	,ParcourPath	,NULL},
			FORM_END
		};

void Installer(void);
void QuitSuite(void);

Type_Form_List
FormWork[]=	{	{0		,Quitter	,NULL},
			{CANCEL		,QuitSuite	,NULL},
			{CONTINUE	,Installer	,NULL},
			FORM_END
		};

void Start(void);

Type_Form_List
FormStart[]=	{	{NON		,Start		,NULL},
			{OUI		,Start		,NULL},
			FORM_END
		};

void GoUnInstall(void);

Type_Form_List
FormUninst[]=	{	{JA		,GoUnInstall	,NULL},
			{ABBRUCH	,Quitter	,NULL},
			FORM_END
		};

Type_Bureau_List
Bureau[]=	{	
			BUREAU_END
		};

/* ---------------------------------------------------------------------------
 *                      Definitions globales Atari/PC
 */

#define	INSTALLRSC		"InstallF.Rsc"

/* ---------------------------------------------------------------------------
 *				Definitions externes
 */

extern  char    Racine[];                               /* Rep source d'install */

extern  int	TraiterScript(FILE *Fichier,Type_Parametrage *Config);
extern	void	CleanUp(Type_Parametrage *Config);
extern	void	Parcourir(char *Chemin,Type_Parametrage *Config);
extern	int	FreeDisk(Type_Parametrage *Config);
extern	int	DiskVerify(int Disque);
extern	void	FselInput(char *Prefix,char *Dummy,int *Bouton,char *Label);

extern	int 	MkUnInsDat(Type_Parametrage *Config);
extern	void	UnInstall(Type_Parametrage *Config);

extern  int	CreerIcone(Type_Parametrage *Config);

extern	int	HandleFuninst;

/* ---------------------------------------------------------------------------
 *				Definitions globales 
 */

long		   		FileCount;		/* Compte les fichiers copiees */
OBJECT				*Messages;		/* Arbres des messages */
Type_Parametrage		Config;			/* Config. de l'install. */
int				HandleFWork;		/* Handle fenetre FWORK */

/* ---------------------------------------------------------------------------
 *				Definitions locales
 */

static	int			NombreClicPhoto;	/* Pour faire apparaitre photo */
static	int			Sortir;			/* Pour quitter le prog */
static	int			Disque;			/* Indice du disque courant */
static	Type_Disk		*Disk;			/* Nom du disque courant */


/* ---------------------------------------------------------------------------
 *				M‚thodes des formulaires
 */

void GoUnInstall(void)
/*
	Appel la proc‚dure de d‚sinstallation logiciel
*/
{
  OBJECT	*Arbre;
  
  UnInstall(&Config);
  
  rsrc_gaddr(R_TREE,FUNINST,&Arbre);
  Arbre[JA].ob_state |=DISABLED;
  F_RedrawObject(Arbre,JA);
}

void Desinstall(void)
/*
	Ouvre le formulaire de d‚sinstallation.
*/
{
  FILE	*Fichier;
  
  if((Fichier = fopen(UNINSTAL,"r")) == NULL)
    form_alert(1,Messages[MSG22].ob_spec.free_string);
  else
  {
    CleanUp(&Config);
    if(!TraiterScript(Fichier,&Config))			/* Analyser le fichier script */
    {
      fclose(Fichier);
      form_alert(1,Messages[MSG23].ob_spec.free_string);
    }
    else
    { 
      fclose(Fichier);      
      HandleFuninst = F_Open(FUNINST,Messages[MSG21].ob_spec.free_string,F_WIND,NOTEXT,FormUninst);
      F_Close(FMAIN);
    }
  }
}

/*
 *
 */

void PhotoCachee(void)
/*
	Called by Double-Clic on Exit button of about me window
*/
{
  OBJECT	*Arbre;
  
  if(NombreClicPhoto == 3)			/* Rendre la photo visible */
  {
      rsrc_gaddr(R_TREE,BUREAU,&Arbre);		/* Bit cach‚ Off */
      Arbre[FUNSHIP].ob_flags &= ~HIDETREE;	
      F_RedrawObject(Arbre,FUNSHIP);		/* Redessiner la photo */
      NombreClicPhoto = 1;
  } 
  else						/* Compter le nombre de DbClics */
    NombreClicPhoto++;
}

/*
 *
 */ 
 
void Quitter(void)
/*
	Fin de l'application: Ferme tous les formulaires sauf FSTART qui est g‚r‚
	par une autre proc‚dure ( Start() )
*/
{
  F_Close(FMAIN);
  F_Close(FPATH);
  F_Close(FWORK);
  F_Close(FUNINST);
  Sortir = TRUE;
}

void Accepter(void)
/*
	Bouton Ok du formulaire principal
*/
{
  GetPath(Racine);                                      /* Copier racine d'install */
  if(strlen(Racine)==0)					/* Racine d'install = Root Disk */
    strcpy(Racine,"\\");

  F_Open(FPATH,Messages[MSG7].ob_spec.free_string,F_WIND,DESTINATION,FormPath);
  F_WriteText(FPATH,SOURCE,Racine);
  F_WriteText(FPATH,DESTINATION,Config.Path);

  F_Close(FMAIN);
}

void QuitSuite(void)
/*
	Appel‚ par le bouton Quitter du formulaire FWORK.
	Soit quitte ou si il y a un PRG suppl‚mentaire ouvre le formulaire FSTART
*/
{
  MkUnInsDat(&Config);					/* G‚nŠre le UnInstall.Dat */

  if(FileCount == Config.Files && Config.Prog != NULL)
  {
    CreerIcone(&Config);
    F_Open(FSTART,Messages[MSG8].ob_spec.free_string,F_WIND,NOTEXT,FormStart);
    F_WriteText(FSTART,NAME2,Config.Name);
    F_WriteText(FSTART,EXECUTER,Config.ProgInfo);
  }
  else if(FileCount == Config.Files)
  {
    if(Config.Icone != NULL)				/* Si existe icones … installer */
      CreerIcone(&Config);
    form_alert(1,Messages[MSG1].ob_spec.free_string);
    Quitter();
  }
  else
  {
    if(form_alert(2,Messages[MSG2].ob_spec.free_string) == 1)
      Quitter();
  }
}

void Start(void)
/*
	Gere les deux boutons du formulaires de lancement d'un PRG suppl‚mentaire
*/
{
  char	*Pointeur, Env[1]="\0",Chemin[PATHLONG];
  int	NewLecteur;
      
  switch(F_NameObject)
  {
    case OUI:	F_UnSelect(FSTART,OUI); 

    		strcpy(Chemin,strchr(Config.Path,'\\'));	/* Copier racine install‚ */
		strcat(Chemin,Config.Prog);

		NewLecteur = Config.Path[0] - 'A';		/* Set Target Drive */
		Dsetdrv(NewLecteur);				/* To set new path */
		
    		Pointeur = strrchr(Chemin,'\\');		/* Retenir que le chemin */
    		*Pointeur = '\0';
    		if(strlen(Chemin) == 0)				/* Si vide */
    		  Dsetpath("\\");				/* Racine du disque */
    		else						/* Sinon fixe chemin */
    		  Dsetpath(Chemin);
    		*Pointeur = '\\';

    		if(Config.CmdLine == NULL)			/* Si pas d'arguments */
    		  Config.CmdLine = Env;				/* pointe un octet Null */
    		Pexec(LOADGO,Chemin,Config.CmdLine,Env);
    case NON:	Sortir = TRUE;
    		F_Close(FSTART);
    		break;
  }
}

void ParcourPath(void)
/*	
	Appel le s‚lecteur de fichiers pour designer l'endroit d'installation
*/
{
  char	Prefix[PATHLONG],Dummy[14],Label[30],*Prochain;
  int	Bouton;
    
  strcpy(Prefix,Config.Path);			/* r‚cupŠre X:\ dans le chemin */
  Prochain = strchr(Prefix,'\\');
  if(Prochain != NULL)
    *(Prochain+1) = '\0';
  strcat(Prefix,"*.*");
  strcpy(Dummy,"\0");
  sprintf(Label,Messages[MSG14].ob_spec.free_string);

  FselInput(Prefix,Dummy,&Bouton,Label);
  if(Bouton)
  {
    Prochain = strrchr(Prefix,'\\');
    *(Prochain) = '\0';				/* Supprimer le \*.* … la fin */
    
    strcpy(Config.Path,Prefix);			/* Recopier le nouveau chemin */
    F_WriteText(FPATH,DESTINATION,Config.Path);  
  }
}

/* ---------------------------------------------------------------------------
 *                            Procedures appel‚es par les parcours
 */

void CDate(unsigned int iDate, char *cDate)
/*
	Convertie une date sur un entier au format GEMDOS en chaine de caractŠres.
*/
{
  char		Aux[5];
    
  itoa((iDate & 0x001F),Aux,BASE10);
  strcpy(cDate,Aux);
  itoa((iDate & 0x01E0) >> 5,Aux,BASE10);
  strcat(cDate,"/");
  strcat(cDate,Aux);
  itoa(((iDate & 0xFE00) >> 9) + 1980,Aux,BASE10);
  strcat(cDate,"/");
  strcat(cDate,Aux);
}

int WriteAlert(char *Path,char *Name)
/*
	GŠre la boite d'alerte … trois boutons de conflit de copie: 
	Rempla‡er Oui/Non/Ignorer
*/
{
  int		Mode;
  char		OldDate[15],NewDate[15];
  unsigned long	OldSize,NewSize;
  char		Message[255];
  DTA		*DtaSystem,OldDta,NewDta;
    
  DtaSystem = Fgetdta();

  Fsetdta(&OldDta);
  Fsfirst(Path,FA_ARCHIVE | FA_READONLY);
  CDate(OldDta.d_date,OldDate);
  OldSize = OldDta.d_length;

  Fsetdta(&NewDta);
  Fsfirst(Name,FA_ARCHIVE | FA_READONLY);
  CDate(NewDta.d_date,NewDate);
  NewSize = NewDta.d_length;
  sprintf(Message,Messages[MSG3].ob_spec.free_string,
  			Name,OldDate,OldSize,NewDate,NewSize);
  Mode = form_alert(1,Message);
  switch(Mode)
  {
    case 1 :	Mode = OVERWRITE;			/* Rempla‡er */
    		break;
    case 2 :	Mode = OVERWRITEALL;			/* Tout rempla‡er */
    		break;
    case 3 : 	Mode = RIEN;				/* Ignorer */
    		break;
    default:	Mode = OVERWRITE;
  }
  Fsetdta(DtaSystem);
  return(Mode);
}

/* ---------------------------------------------------------------------------
 *                            Programmes d'installation lui-meme
 */

void Installer(void)
/*
	Effectue la copie complŠte d'UN disque source.
*/
{
  char                  Chemin[PATHLONG];               /* Chemin d'acces source */
  char			Message[100];
  OBJECT		*Arbre;
  
  F_UnSelect(FWORK,CONTINUE);  
  F_ReadText(FWORK,CURRPATH,Racine);			/* Lire chemin source courant */
  strupr(Racine);					/* => Majuscule */
  if(Dsetpath(Racine) != 0)				/* Fixe le rep. du drive courant */
  {
    form_alert(1,Messages[MSG28].ob_spec.free_string);
    return;						/* Quitter proc‚dure */
  }
  
  if(!DiskVerify(Disque))
  {
    sprintf(Message,Messages[MSG4].ob_spec.free_string,Disk->Name);
    form_alert(1,Message);
  }
  else
  {
    strcpy(Chemin,Racine);
    Parcourir(Chemin,&Config);				/* Parcourir & Copier */
    Disque++;
    if(Disque <= Config.Number)				/* Encore un disque */
    {
      Disk = Disk->Suivant;
      sprintf(Message,Messages[MSG15].ob_spec.free_string,Disk->Name);
      F_WriteText(FWORK,CHANGEDISK,Message);
    }
    else						/* All done ! */
    {
      if(FileCount == Config.Files)
      {
        F_WriteText(FWORK,CHANGEDISK,Messages[MSG11].ob_spec.free_string);
        rsrc_gaddr(R_TREE,FWORK,&Arbre);
        Arbre[CONTINUE].ob_state |=DISABLED;
        F_RedrawObject(Arbre,CONTINUE);
      }
      else
        F_WriteText(FWORK,CHANGEDISK,Messages[MSG12].ob_spec.free_string);
    }
  }
}

void Demarrer(void)
/*
	Pr‚pare l'installation en se positionnant sur le formulaire FWORK.
	Effectue la relecture des r‚pertoires source et destination
*/
{
  OBJECT		*Arbre;
  char			Message[100], Aux[PATHLONG],*Pointeur;
  int			NewLecteur,Erreur;

  F_ReadText(FPATH,DESTINATION,Aux);			/* Relecture des r‚pertoires */
  strupr(Aux);
  if(strlen(Aux) != 0)					/* Si destination n'est pas vide */
  {
    if(Aux[0] >= 'A' && Aux[0] <= 'Z' && Aux[1] == ':' && Aux[2] == '\\')	
      strcpy(Config.Path,strupr(Aux));			/* take it as a new target */
    else
    {
      form_alert(1,Messages[MSG29].ob_spec.free_string); 
      return;						/* Quitter proc‚dure */
    }
  }
    
  F_ReadText(FPATH,SOURCE,Aux);				/* Lire chemin source */
  strupr(Aux);						/* => Majuscule */
  if(strlen(Aux) == 0)					/* La source est vide */
    strcpy(Aux,"\\");					/* => Rep. courant = racine */

  if(Aux[0] >= 'A' && Aux[0] <= 'Z')			/* Si drive sp‚cifi‚ */
  {
    NewLecteur = Aux[0] - 'A';				/* compute the new drive */
    if(!(Dsetdrv(NewLecteur) & (0x01 << NewLecteur)))	/* Set new drive */
    {
      form_error(15);  
      return;
    }
  }

  Pointeur = strchr(Aux,'\\');				/* compute the new path */
  if(Pointeur == NULL)
  {
    form_alert(1,Messages[MSG28].ob_spec.free_string);
    return;						/* Quitter proc‚dure */
  }
  strcpy(Racine,Pointeur);				/* Copie le chemin source */
  if(Dsetpath(Racine) != 0) 				/* Fixer le chemin courant */
  {
    form_alert(1,Messages[MSG28].ob_spec.free_string);
    return;						/* Quitter proc‚dure */
  }
  
  if(FreeDisk(&Config))					/* if space expected ok */
  {
    Erreur = mkdir(Config.Path);
    if(Erreur != -36 && Erreur != 0)			/* Creer rep. d'installation */
    {							/* Err -36 = AccŠs imposible */
      form_alert(1,Messages[MSG29].ob_spec.free_string); 
      return;						/* Quitter proc‚dure */
    }
/*    F_Close(FPATH);			*/		/* !!! */

    Disque = 1;						/* Begin with first disk */
    Disk = Config.Disk;					/* Disk name */
    FileCount = 0L;					/* Number of files processed */

    rsrc_gaddr(R_TREE,FWORK,&Arbre);
    Arbre[JAUGE].ob_width = 0;
    sprintf(Message,Messages[MSG15].ob_spec.free_string,Disk->Name);

    HandleFWork = F_Open(FWORK,Messages[MSG9].ob_spec.free_string,F_WIND,CURRPATH,FormWork);
    F_WriteText(FWORK,CURRPATH,Racine);
    F_WriteText(FWORK,CHANGEDISK,Message);
  }
  else
    form_alert(1,Messages[MSG13].ob_spec.free_string);
  F_Close(FPATH);
}

/* ---------------------------------------------------------------------------
 *                            Programme principal
 */

int main(void)
{
  char		Espace[10];
  FILE		*Fichier,*Fichier2;
  OBJECT	*Arbre;
    
  if(!A_Open(INSTALLRSC))
    form_alert(1,"[3][ Install.Rsc Not Found ][ Sorry ]");
  else
  {
    W_Init();  
    F_Init();						/* Init Form    */
    graf_mouse(ARROW,NULL);
    
    /*
     *		Calculer adresse arbre des messages
     */
    rsrc_gaddr(R_TREE,MESSAGES,&Messages);		/* Arbre des messages */
    rsrc_gaddr(R_TREE,FMAIN,&Arbre);			/* Formulaire principal */

    if((Fichier = fopen(UNINSTAL,"r")) == NULL)		/* Existe ? UnInstal.Dat */
      Arbre[UNINSTALL].ob_state |=DISABLED;		/* Non */
    
    if((Fichier2 = fopen(SCRIPTNAME,"r")) == NULL)	/* Existe ? Install.Dat */
      Arbre[ACCEPTER].ob_state |=DISABLED;		/* Non */
    else
    {
      if(Fichier != NULL)				/* Si existe UnInstall.Dat */
        fclose(Fichier);				/* Fermer avant */
      Fichier = Fichier2;				/* Prendre Install.Dat */
    }
     
    if(Fichier == NULL)					/* Si pas de fichiers */
      form_alert(1,Messages[MSG6].ob_spec.free_string);	/* Erreur => quitter  */
    else
    {
      rsrc_gaddr(R_TREE,BUREAU,&Arbre);			/* Adr de l'arbre */
      Arbre[FUNSHIP].ob_flags |= HIDETREE;		/* Bit HIDE oui */
      D_Open(BUREAU,Bureau); 

      F_Open(FMAIN,Messages[MSG10].ob_spec.free_string,F_WIND,NOTEXT,FormMain);
      F_WriteText(FMAIN,CODEVER,CODEVERSION);
      F_WriteText(FMAIN,DATEVER,DATEVERSION);
      
      if(!TraiterScript(Fichier,&Config))		/* Analyser le fichier script */
      {
	form_alert(1,Messages[MSG5].ob_spec.free_string);
	F_Close(FMAIN);
      }
      else
      {        
        F_WriteText(FMAIN,SOFTNAME,Config.Name);	/* Affiche les infos */
        F_WriteText(FMAIN,SOFTINFO,Config.Info);
        ltoa(Config.Space,Espace,BASE10);
        F_WriteText(FMAIN,DSPACE,Espace);

        Sortir = FALSE;
        do
        {
          A_WaitEvent();				/* Waiting an event	*/
          F_Event();					/* Form Event 		*/
          W_Event();					/* Window Event		*/
        }
        while(!Sortir);
      }
      CleanUp(&Config);
    }
    D_Close();
    F_Exit();
    W_Exit();
  }
  A_Close();
  return(0);
}

