#ifndef __LDV
#define __LDV

#ifndef __LDG__
#include <ldg.h>
#endif

#ifndef __VAPI
#include "ldv\vapi.h"
#endif

/* Codes d'erreurs */
typedef long LDV_STATUS ;             /* Type de status retourne */
#define ELDV_NOERROR              0x0 /* Pas d'erreur */
#define ELDV_INVALIDPARAMETER     0x1 /* Au moins un parametre transmis est invalide */
#define ELDV_NBPLANESNOTSUPPORTED 0x2 /* Nombre de plans non supporte */
#define ELDV_NOTENOUGHMEMORY      0x3 /* Memoire insuffisante */
#define ELDV_PREVIEWNOTSUPPORTED  0x4 /* Preview non supportee */
#define ELDV_RUNNOTSUPPORTED      0x5 /* Run non supporte (!) */
#define ELDV_BADVAPIVERSION       0x6 /* VAPI absent ou mauvaise version */
#define ELDV_IMGFORMATMISMATCH    0x7 /* Format d'image incompatible */
#define ELDV_CANCELLED            0x8 /* Operation annulee par l'utilisateur (GetParams par exemple) */
#define ELDV_BADINTERFACE         0x9 /* Impossible : ce LDV ne possede pas la bonne interface */
#define ELDV_GENERALFAILURE       0xF /* Echec general, raison non precisee */


/* Pour finir, une petite macro pour tester si */
/* Une fonction LDV a retourne une erreur      */
#define LDV_SUCCESS(x)  ((x) == ELDV_NOERROR)


/* Types de LDV */
#define TLDV_MODIFYIMG 0x01     /* Modificateur d'image : filtre, deformation, ... */
                                /* Le nombre de plans de l'image reste inchange    */
#define TLDV_LOADIMG   0x02     /* Module de chargement d'image                    */
#define TLDV_SAVEIMG   0x04     /* Module de sauvegarde d'image                    */

/* Structure de definition du LDV */
/* Pour un nombre de plans defini */
/* Masques de bits pour le champ Flags */
#define LDVF_STDFORMAT       0x00000001UL /* Donnees image au format standard                 */
#define LDVF_ATARIFORMAT     0x00000002UL /* Donnees image au format ATARI (Falcon)           */
#define LDVF_SPECFORMAT      0x00000004UL /* Donnees image au format specifique a la machine  */
#define LDVF_SUPPORTPREVIEW  0x00000008UL /* Support de la pre-visualisation                  */
#define LDVF_AFFECTPALETTE   0x00000010UL /* Le module affecte la palette (si NbPlanes <= 8)  */
#define LDVF_SUPPORTPROG     0x00000020UL /* Le module appelera la fonction de progression    */
#define LDVF_OPINPLACE       0x00000040UL /* Le module modifie la source (param out ignore)   */
#define LDVF_REALTIMEPARAMS  0x00000080UL /* Le module supporte la modification en temps reel */
                                          /* Des parametres (mode Preview)                    */
#define LDVF_SUPPORTCANCEL   0x00000100UL /* Le module gere l'annulation (voir PrSetProgEx)   */
#define LDVF_NOSELECTION     0x00000200UL /* Le module ne peut pas g‚rer la selection         */

/* Cette structure definit ce que ce LDV sait faire, */
/* Pour un nombre donne de plans en entree           */
typedef struct
{
  char NbPlanes ;      /* Nombre de plans de l'image : */
                       /* 0 : Fin de cette structure   */
                       /* 1, 2, 4, 8, 16, 24, ou 32    */

  char NbPlanesOut ;   /* Nombre de plans en sortie    */

  unsigned long Flags ; /* LDVF_...                    */
}
LDV_CAPS ;

/* Cette structure rassemble les infos du module qui sont              */
/* Suceptibles de pouvoir etre traduites dans d'autres langues         */
/* Un fichier .INI doit etre associe (voir SMP_LDV.INI pour exemple)   */

#define LDVNBMAX_PARAMETERS 4 /* Nombre maximal de parametres pouvant etre gere   */
                              /* Depuis VISION et passes au travers de LDV_PARAMS */

typedef union
{
  short s ;
  float f ;
}
LDV_BASICPARAM ;

#define LDVT_SHORT 1
#define LDVT_FLOAT 2
typedef struct
{
  char           Name[1+15] ;
  char           Type ;
  LDV_BASICPARAM MinValue ;
  LDV_BASICPARAM DefaultValue ;
  LDV_BASICPARAM MaxValue ;
  float          FloatIncrement ;
}
LDV_DEF_PARAM ;

typedef struct
{
  short StrSize ;           /* Taille de la structure LDV_INFOS */
  short Type ;              /* TLDV_...                         */
  char  Authors[1+45] ;     /* Liste du ou des auteurs          */

  LDV_CAPS Caps[10] ;      /* Ce que ce LDV sait faire, pour    */
                           /* Chaque type d'image               */
                           /* Mettre cette structure a zero     */
                           /* Des que la liste est terminee     */
                           /* Un maximum de 9 elements utiles   */
                           /* Est donc disponible               */

  char RFU[16] ;           /* Usage futur                       */
}
LDV_INFOS ;

typedef struct
{
  short Red ;   /* 0...1000 */
  short Green ; /* 0...1000 */
  short Blue ;  /* 0...1000 */
}
VDI_ELEMENTPAL ;

typedef struct
{
  short          NbColors ; /* Nombre d'index dans cette palette */
  VDI_ELEMENTPAL *Pal ;     /* ATTENTION : Palette indexee sur les indices VDI */
}
LDV_PALETTE ;

typedef struct
{
  short          x1, y1, x2, y2 ; /* Rectangle definissant la partie du MFDB a traiter */
  short          NbParams ;
  LDV_BASICPARAM Param[LDVNBMAX_PARAMETERS] ;
  void           *UserParam ; /* Peut etre utilise avec GetParams */
}
LDV_PARAMS ;

/* Parametres d'entree de la fonction a effectuer par le LDV */
typedef struct
{
  short       RasterFormat ; /* LDVF_STDFORMAT, LDVF_ATARIFORMAT ou LDVF_SPECFORMAT */
                             /* VISION choisit automatiquement le format optimal en */
                             /* Fonction des capacites du LDV fournies par la       */
                             /* Fonction GetLDVCapabilities                         */

  MFDB        Raster ;       /* Image */

  LDV_PALETTE Palette ;      /* Structure fournie si Raster.fd_nplanes > 8 */
}
LDV_IMAGE ;


#endif
