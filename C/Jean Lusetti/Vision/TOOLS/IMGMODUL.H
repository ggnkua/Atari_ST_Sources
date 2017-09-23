#ifndef __IMGMODUL
#define __IMGMODUL

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif

#ifndef __LDG__
#include <ldg.h>
#endif

typedef struct
{
  INFO_IMAGE_DRIVER Capabilities ;

  long              Signature ;
  unsigned int      IsDynamic : 1 ;
  unsigned int      Rfu       : 15 ;

  void (*GetDrvCaps)(INFO_IMAGE_DRIVER *caps) ;
  int  (*Identify)(char *nom, INFO_IMAGE *inf) ;
  int  (*Load)(char *name, MFDB *out, GEM_WINDOW *wprog) ;
  int  (*Save)(char *name, MFDB *img, INFO_IMAGE *info, GEM_WINDOW *wprog) ;
  long rfu[5] ;

  LDG  *Ldg ;
}
IMG_MODULE ;

void        DImgSetImgModulePath(char *path) ;
IMG_MODULE* DImgGetImgModules(char *path, short *nb, char *msg_for_prog, short force) ;
void        DImgFreeModules(void) ;
IMG_MODULE* DImgGetModuleFromIID(IID iid) ;
IMG_MODULE* DImgGetModuleForExtension(char *ext) ;
IID         DImgGetIIDFromFile(char *filename) ;
long        DImgUnloadImgModule(IMG_MODULE *img_module) ;
long        DImgLoadImgModule(char *filename, IMG_MODULE *img_module) ;

#endif