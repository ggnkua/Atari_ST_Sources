#ifndef __IMGMODUL_H
#define __IMGMODUL_H

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif

#ifndef __LDG__
#include "..\tools\ldg.h"
#endif

#ifndef __SLB_H
#include "..\tools\slb.h"
#endif

#define MST_LDI    '1'  /* VISION Internal */
#define MST_ZVLDG  '2'  /* zView LDG       */
/*#define MST_ZVSLB  '3'   zView SLB  Uncomment this line to enable zvSLB support and do necessary changes in IIZVSLB.C     */
#ifdef MST_ZVSLB
#define NB_MST_MAX 3
#else
#define NB_MST_MAX 2
#endif

typedef struct _IMG_MODULE
{
  INFO_IMAGE_DRIVER Capabilities ;

  long  Signature ;
  char  Type ;      /* MST_... */
  char  IsDynamic ;
  short LastError ;

  /* This is the abstraction layer we need to wrap           */
  /* Any specific interface to the previous VISION interface */
  /* We need to pass IMG_MODULE parameter for our specific   */
  /* Interface to be able to access any required information */
  void (*GetDrvCaps)(struct _IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps) ;
  int  (*Identify)(struct _IMG_MODULE* ImgModule, char* name, INFO_IMAGE* inf) ;
  int  (*Load)(struct _IMG_MODULE* ImgModule, INFO_IMAGE* inf) ;
  int  (*Save)(struct _IMG_MODULE* ImgModule, char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog) ;
  void (*Terminate)(struct _IMG_MODULE* ImgModule) ; /* If necessary */

  char*    LibFilename ; /* Remember LDG filename as we may have to reload it */
  void*    hLib ;        /* Handle of the lib, could be LDG or SLB            */
  SLB_EXEC SlbExec ;     /* Functions pointer (SLB only)                      */
  long     SlbVersion ;  /* SLB version of the library                        */

  unsigned long nUsages ; /* Number of time this module was used              */

  /* Now we have specific stuff depending on the module */
  /* We want to support */
  void* Specific ;
}
IMG_MODULE, *PIMG_MODULE ;


void        DImgSetImgModulePrefs(char* path, char* prefs) ;
IMG_MODULE* DImgGetImgModules(char* paths[NB_MST_MAX], short* nb, char* msg_for_prog, char* priorities) ;
short       DImgGetModulesCandidates(char* ext, IID lformat, void* modules[], short nmodules_max) ;
void        DImgFreeModules(void) ;
IMG_MODULE* DImgGetModuleFromIID(IID iid) ;
IMG_MODULE* DImgGetModuleForExtension(char* ext, IMG_MODULE* start_module, int only_pref_for_type) ;
IID         DImgGetIIDFromFile(char* filename) ;
void        DImgSetPriorities(char* priorities) ;
void        DImgGetPriorities(char* priorities, int nmax) ;
short       DImgGetPrefType(void) ;
void        DImgSetPrefType(short type) ;

/* Use these abstraction layer as non VISION interfaces need an extra parameter */
short IMGetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps) ;
short IMIdentify(IMG_MODULE* ImgModule, char* name, INFO_IMAGE* inf) ;
short IMLoad(IMG_MODULE* ImgModule, INFO_IMAGE* inf) ;
short IMSave(IMG_MODULE* ImgModule, char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog) ;
void  IMTerminate(IMG_MODULE* ImgModule, short keep_filename) ;



#endif