/*
 *              Definitions des types globaux de l'application.
 *
 *	Author  : FunShip
 *	File	: Types.h
 *	Date    : 07 August 1995
 *	Revision: 10 August 1995
 *	Version : 1.0
 *
 *
 */

#ifndef __TYPES__
#define __TYPES__       __TYPES__

#define	TOS14		0x0104			/* Code TOS 1.4 */

#define LIGNE           80                      /* 80 Cars. / Ligne */

#define PATHLONG        512                     /* Longueur max des chemins */
#define NAMELONG        13                      /* Nom de fichiers sur 13 Car*/
#define	BASE10		10
#define	LOADGO		0

#define SCRIPTNAME              "Install.Dat"           /* Script d'installation */
#define	UNINSTAL		"UnInstal.Dat"

/*
 *		Mode de copie des fichiers
 */
 
#define	OVERWRITEALL	2			/* Tout rempla‡er */
#define	OVERWRITE	1			/* Rempla‡er */
#define	RIEN		0			/* Passer */

#ifndef	__PCAADS__

#define	TRUE	1
#define	FALSE	0

#endif

/*
 *              Déclarations des types
 */

typedef struct _Disk
                {
                  char          *Name;          /* Nom de la disquette */
                  struct _Disk  *Suivant;       /* Poste suivant */
                } Type_Disk;

typedef struct _Special
                {
                  char                  *FileName;      /* Nom du fichier */
                  char                  *Chemin;        /* Chemin où copier */
                  struct _Special       *Suivant;       /* Poste suivant */
                } Type_Special;

typedef struct _Icon {
                       int              Id;             /* N° d'icone choisi */
                       char             *Chemin;        /* Chemin du fichier */
                       char             *Nom;           /* Nom pour l'icone  */
                       struct  _Icon    *Suivant;       /* Ptr icone suivante*/
                     } Type_Icone;

typedef struct  {
                  char		*Path;          /* Chemin d'installation */
                  unsigned long	Space;          /* Espace demand‚ */
                  long		Files;		/* Nbr de fichiers au total */
                  char          *Name;          /* Nom du Soft */
                  char          *Info;          /* Info du Soft */
                  int           Number;         /* Nbr Disks */
                  char          *Prog;          /* Prg à appeler */
                  char          *CmdLine;       /* Command line */
                  char          *ProgInfo;      /* Info Prg à appeler */
                  Type_Disk     *Disk;          /* Liste des disks */
                  Type_Special  *Special;       /* Liste des "sp‚ciaux" */
                  Type_Icone	*Icone;		/* Liste des icones */
                } Type_Parametrage;

#endif