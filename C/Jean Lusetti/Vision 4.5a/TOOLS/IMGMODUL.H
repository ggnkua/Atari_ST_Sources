#ifndef __IMGMODUL_H
#define __IMGMODUL_H

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif

#ifndef __LDG__
#include <ldg.h>
#endif

#define MST_LDI    '1'  /* VISION Internal */
#define MST_ZVLDG  '2'  /* zView LDG       */
#define NB_MST_MAX 2

typedef struct _IMG_MODULE
{
  INFO_IMAGE_DRIVER Capabilities ;

  long  Signature ;
  char  Type ;      /* MST_... */
  char  IsDynamic ;
  short LastError ;

  /* This is abstraction layer we need to wrap               */
  /* Any specific interface to the previous VISION interface */
  /* We need to pass IMG_MODULE parameter for our specific   */
  /* Interface to be able to access any required information */
  void (*GetDrvCaps)(struct _IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps) ;
  int  (*Identify)(struct _IMG_MODULE* ImgModule, char* name, INFO_IMAGE* inf) ;
  int  (*Load)(struct _IMG_MODULE* ImgModule, char* name, MFDB* out, GEM_WINDOW* wprog) ;
  int  (*Save)(struct _IMG_MODULE* ImgModule, char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog) ;
  void (*Terminate)(struct _IMG_MODULE* ImgModule) ; /* If necessary */

  LDG*  Ldg ;         /* In case our module is LDG compliant, here is the handle to it */
  char* LdgFilename ; /* Remember LDG filename as we may have to reload it             */

  /* Now we have specific stuff depending on the module */
  /* We want to support */
  void* Specific ;
}
IMG_MODULE, *PIMG_MODULE ;


void        DImgSetImgModulePrefs(char *path, char* prefs) ;
IMG_MODULE* DImgGetImgModules(char *path, short *nb, char *msg_for_prog, char* priorities) ;
void        DImgFreeModules(void) ;
IMG_MODULE* DImgGetModuleFromIID(IID iid) ;
IMG_MODULE* DImgGetModuleForExtension(char *ext, IMG_MODULE* start_module) ;
IID         DImgGetIIDFromFile(char *filename) ;
void        DImgSetPriorities(char* priorities) ;
void        DImgGetPriorities(char* priorities, int nmax) ;
short       DImgGetPrefType(void) ;
void        DImgSetPrefType(short type) ;

/* Use these abstraction layer as non VISION interfaces need an extra parameter */
void  IMGetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps) ;
short IMIdentify(IMG_MODULE* ImgModule, char* name, INFO_IMAGE* inf) ;
short IMLoad(IMG_MODULE* ImgModule, char* name, MFDB* out, GEM_WINDOW* wprog) ;
short IMSave(IMG_MODULE* ImgModule, char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog) ;
void  IMTerminate(IMG_MODULE* ImgModule) ;



#endif