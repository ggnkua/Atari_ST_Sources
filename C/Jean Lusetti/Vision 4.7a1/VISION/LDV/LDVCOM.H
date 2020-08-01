#ifndef __LDVCOM_H
#define __LDVCOM_H

#include "ldv\ldv.h"

typedef struct
{
  char* ShortName ;   /* Module short name  (15 chars max) */
  char* LongName ;    /* Module long name   (31 chars max) */
  char* Description ; /* Module description (79 chars max) */

  /* Parameters that can apply */
  LDV_DEF_PARAM Params[LDVNBMAX_PARAMETERS] ;
}
LDV_INI_SPEC ;

/* Image Modification Interface */
typedef struct
{
  /* Allows VISION to allocate required ressources for LDV to operate     */
  /* You have to indicate in out->Raster the output image size            */
  /* As well as in out->Palette.NbColors field                            */
  /* In params, you have to tell which zone has to be send to Undo buffer */
  LDV_STATUS cdecl (*PreRun)(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out) ;

  /* Performs LDV operation                                              */
  /* VISION already allocated required memory from previous call         */
  /* DO NOT ALLOCATE OR FREE MEMORY THAT VISION WILL USE AFTER THIS CALL */
  LDV_STATUS cdecl (*Run)(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out) ;

  /* Same as previous one, but in preview mode */
  LDV_STATUS cdecl (*Preview)(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out) ;
}
ILDVModifImg ;

typedef struct
{
  LDG* Ldg ; /* LDG Module */

  char* FileName ;  /* Only name, no path */
  short Version ;   /* Same as Ldg->vers  */

  LDV_INFOS    Infos ;   /* Module informations */
  LDV_INI_SPEC IniSpec ; /* .INI specific       */

  /* Reports capabilities to VISION */
  /* VISION gives access to its Application Programmer Interface */
  LDV_INFOS* cdecl (*GetLDVCapabilities)(VAPI* vapi) ;

  int           NbReferences ; /* How many times this module is referenced */
  ILDVModifImg* IModifImg ;    /* TLDV_MODIFYIMG Interface                 */
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
LDV_STATUS LDVDo(LDV_MODULE *ldv, LDV_PARAMS *ldv_params, LDV_IMAGE *ldv_img, int preview) ;

LDV_STATUS LDVLoadFunctions(char *path, LDV_MODULE *mod) ;
void       LDVUnloadFunctions(LDV_MODULE *mod) ;
void       LDVFreeDynParams(LDV_PARAMS* ldv_params) ;

#endif
