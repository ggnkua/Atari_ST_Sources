/**************************************************************************************/
/* IIVISION.C: wrapper for exposing LDI interface from VISION static plugin interface */
/**************************************************************************************/

#include <string.h>
#include <stdlib.h>

#include "gwindows.h"
#include "iiintern.h"
#include "imgmodul.h"
#include "logging.h"


static void iii_GetDrvCaps(IMG_MODULE* img_module, INFO_IMAGE_DRIVER* caps)
{
  II_INTERNAL* iii = (II_INTERNAL*) img_module->Specific ;

  iii->GetDrvCaps( caps ) ;
}

int iii_Identify(IMG_MODULE* img_module, char* name, INFO_IMAGE* inf)
{
  II_INTERNAL* iii = (II_INTERNAL*) img_module->Specific ;

  return iii->Identify( name, inf ) ;
}

static int iii_Load(IMG_MODULE* img_module, INFO_IMAGE* inf)
{
  II_INTERNAL* iii = (II_INTERNAL*) img_module->Specific ;

  return iii->Load( inf ) ;
}

static int iii_Save(IMG_MODULE* img_module, char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog)
{
  II_INTERNAL* iii = (II_INTERNAL*) img_module->Specific ;

  return iii->Save( name, img, info, wprog ) ;
}

static void iii_Terminate(IMG_MODULE* img_module)
{
  II_INTERNAL* iii = (II_INTERNAL*) img_module->Specific ;

  if ( iii->Terminate ) iii->Terminate() ;
  Xfree( img_module->Specific ) ;
  img_module->Specific = NULL ;
}

int iiinternal_init(IMG_MODULE* img_module, II_INTERNAL* ii_internal)
{
  II_INTERNAL* iii ;
  int          ret = 1 ;

  /* First allocate room for our own stuff */
  img_module->Specific = Xcalloc( 1, sizeof(II_INTERNAL) ) ;
  iii = (II_INTERNAL*) img_module->Specific ;
  if ( iii == NULL )
  {
    LoggingDo(LL_ERROR, "Can't allocate %ld bytes for image internal module", sizeof(II_INTERNAL)) ;
    return ret ;
  }

  memcpy( iii, ii_internal, sizeof(II_INTERNAL) ) ;
  img_module->Type       = MST_LDI ;
  img_module->IsDynamic  = 0 ;
  img_module->GetDrvCaps = iii_GetDrvCaps ;
  img_module->Identify   = iii_Identify ;
  img_module->Load       = iii_Load ; 
  img_module->Save       = iii_Save ;
  img_module->Terminate  = iii_Terminate ;
  ret = 0 ;

  return ret ;
}
