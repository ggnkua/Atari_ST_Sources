#ifndef __LDVCOM
#define __LDVCOM

#ifndef __LDV
#include "ldv\ldv.h"
#endif

typedef struct
{
  char *ShortName ;   /* Nom court du module (15 carac. max)   */
  char *LongName ;    /* Nom long du module (31 carac. max)    */
  char *Description ; /* Description du module (79 carac. max) */

  /* Definition des parametres pouvant etre applique */
  LDV_DEF_PARAM Params[LDVNBMAX_PARAMETERS] ;
}
LDV_INI_SPEC ;

/* Interface pour la modification d'image */
typedef struct
{
  /* Permet a VISION d'allouer les ressources                */
  /* Necessaires a la fonction assuree par le LDV            */
  /* Renvoyer dans out->Raster les dimensions                */
  /* Voulues et/ou renseigner le champ out->Palette.NbColors */
  /* Renvoyer dans params, la totalite de la zone a envoyer  */
  /* Dans le Undo                                            */
  LDV_STATUS cdecl (*PreRun)(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;

  /* Effectue la fonction du LDV */
  /* VISION a deja alloue la memoire voulue grace a la fonction precedente */
  /* NE SURTOUT PAS ALLOUER OU LIBERER DE LA MEMOIRE QUI SERA UTILISEE PAR */
  /* VISION ! */
  LDV_STATUS cdecl (*Run)(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;

  /* Identique a la fonction precedente, mais en mode Preview */
  LDV_STATUS cdecl (*Preview)(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;

  /* Optionnel : Si cette fonction est presente, VISION l'appelera a la place  */
  /*             de la fonction interne pour parametrer le module              */
  /* Si la valeur de retour est differente de ELDV_NOERROR, VISION consderera  */
  /* Que la saisie a ete annulee (comme si vous aviez appuye sur "Cancel" dans */
  /* Le formulaire standard de saisie.                                         */
  LDV_STATUS cdecl (*GetParams)(LDV_IMAGE *img, LDV_PARAMS *params, char *path) ;
}
ILDVModifImg ;

typedef struct
{
  long RFU[10] ;
}
ILDVLoadImg ;

typedef struct
{
  long RFU[10] ;
}
ILDVSaveImg ;

typedef struct
{
  LDG *Ldg ; /* Le module LDG */

  char *FileName ; /* Nom uniquement, sans le chemin */
  short Version ;   /* Idem que Ldg->vers             */

  LDV_INFOS    Infos ;   /* Informations sur ce module */
  LDV_INI_SPEC IniSpec ; /* Specifique au .INI         */

  /* Indique a VISION ce que ce LDV sait faire          */
  /* VISION fournit son interface de programmation vapi */
  LDV_INFOS * cdecl (*GetLDVCapabilities)(VAPI *vapi) ;

  int          NbReferences ;      /* Nombre de references en cours sur ce module */
  ILDVModifImg *IModifImg ;        /* Interface pour le type TLDV_MODIFYIMG */
  ILDVLoadImg  *ILoadImg ;         /* Interface pour le type TLDV_LOADIMG   */
  ILDVSaveImg  *ISaveImg ;         /* Interface pour le type TLDV_SAVEIMG   */
  long         RFUInterfaces[10] ; /* Interfaces de reserve                 */
}
LDV_MODULE ;

typedef struct
{
  unsigned long prerun_ms ;
  unsigned long pre_ldv_ms ;
  unsigned long run_ms ;
  unsigned long post_ldv_ms ;
  unsigned long total_ms ;
}
LDV_PERF ;

LDV_CAPS   *LDVGetNPlanesCaps(LDV_MODULE *mod, int nplanes) ;
LDV_MODULE *LDVGetModuleList(char *path, int *nb_ldv) ;
void        LDVFreeModuleList(LDV_MODULE *module_list) ;
LDV_MODULE *GetLdvByLdg(LDV_MODULE *ldv_list, LDG *ldg) ;
LDV_STATUS LDVAlloc(LDV_IMAGE *img) ;
LDV_STATUS LDVDo(LDV_MODULE *ldv, LDV_PARAMS *ldv_params, LDV_IMAGE *ldv_img, int preview, LDV_PERF *perfs) ;

LDV_STATUS LDVLoadFunctions(char *path, LDV_MODULE *mod) ;
void       LDVUnloadFunctions(LDV_MODULE *mod) ;

#endif
