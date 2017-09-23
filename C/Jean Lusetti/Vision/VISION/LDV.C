#include <stdlib.h>
#include <string.h>

#include "..\tools\gwindows.h"
#include "..\tools\frecurse.h"

#include "ldv\ldv.h"


typedef struct
{
  LDG *Ldg ; /* Le module LDG */

  int cdecl (*GetLDVCapabilities)(LDV_INFOS *infos) ;
}
LDV_MODULE ;


static LDV_MODULE *Modules ;
static int        NbModules ;
static int        NumModule ;


#pragma warn -par
int LDVInit(char *file, LDV_MODULE *ldv_module)
{
  LDG *ldg ;
  void* cdecl fonc ;
  int err = 0 ;

  ldg = ldg_exec( ap_id, file ) ;
  if ( ldg )
  {
    ldv_module->Ldg = ldg ;
    fonc = ldg_find( "GetLDVCapabilities", ldg ) ;
    if ( fonc ) ldv_module->GetLDVCapabilities = fonc ;
  }

  return( err ) ;
}
#pragma warn +par

void add_ldv(char *file)
{
  /* Toujours le cas a priori */
  if ( NumModule < NbModules )
  {
    if ( LDVInit( file, &Modules[NumModule] ) == 0 ) NumModule++ ;
  }
}

LDV_MODULE *LDVGetModuleList(char *path)
{
  if ( Modules ) free( Modules ) ;
  Modules = NULL ;

  NbModules = (int) count_files( path, "*.LDV", 0 ) ;

  if ( NbModules > 0 )
  {
    /* Le dernier module (non valide) sera rempli de zeros */
    NumModule = 0 ;
    Modules = (LDV_MODULE *) calloc( 1+NbModules, sizeof(LDV_MODULE) ) ;
    if ( Modules ) find_files( path, "*.LDV", add_ldv ) ;
    else           NbModules = 0 ;
  }

  return( Modules ) ;
}

void LDVFreeModuleList(LDV_MODULE *module_list)
{
  LDV_MODULE *mod ;

  mod = module_list ;
  while( mod->Ldg )
  {
    ldg_term( ap_id, mod->Ldg ) ;
    mod++ ;
  }
}
