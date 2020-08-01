#include <string.h>
#include <stdlib.h>

#include "stdprog.h"
#include "imgmodul.h"
#include "frecurse.h"
#include "ini.h"
#include "iizview.h"
#include "iiintern.h"
#include "logging.h"

#include    "img_io.h"
#include    "art_io.h"
#include    "neo_io.h"
#include    "mac_io.h"
#include    "bmp_io.h"
#include    "gif_io.h"
#include    "png_io.h"
#include   "tiff_io.h"
#include   "jpeg_io.h"
#include  "degas_io.h"
#include  "targa_io.h"

typedef struct
{
  char        type ; /* MST_... */
  GEM_WINDOW* wprog ;
  char*       msg_for_prog ;
  HINI        h_ini ;
  short       save_ini ;
  long        nb_files ;
}
MOD_SCAN ;


/* List of embedded modules */
#ifdef STATIC_NONE
  #define NB_STATIC_MODULES 0
#else
  #ifdef STATIC_MIN
    #define STATIC_TIFF
    #define STATIC_IMG
    #define NB_STATIC_MODULES 2
  #else
    #define STATIC_JPEG
    #define STATIC_PNG
    #define STATIC_TIFF
    #define STATIC_GIF
    #define STATIC_TARGA
    #define STATIC_BMP
    #define STATIC_IMG
    #define STATIC_DEGAS
    #define STATIC_ART
    #define STATIC_NEO
    #define STATIC_MAC
    #define NB_STATIC_MODULES 11
  #endif
#endif

static char        ImgModulesPath[NB_MST_MAX][PATH_MAX] ;
static char        ImgGlobalPriority[1+NB_MST_MAX] ;
static short       ImgModulesPrefType = MST_LDI ;
static IMG_MODULE* ImgModules ;
static short       NbImgModules = -1 ;

#define IMG_MODULE_INDEX(img_module) (long)(img_module-ImgModules)

static char* GetModuleFullName(IMG_MODULE* ImgModule)
{
  return ImgModule->LibFilename ;
}

static int DImgUnloadImgModule(IMG_MODULE* img_module)
{
  switch( img_module->Type )
  {
    case MST_LDI:
    case MST_ZVLDG: if ( img_module->hLib )
                    {
                      LoggingDo(LL_IMG, "Unloading ZVLDG #%ld (used %ld times)", IMG_MODULE_INDEX(img_module), img_module->nUsages) ;
                      ldg_term( ap_id, img_module->hLib ) ;
                      img_module->hLib = NULL ;
                    }
                    break ;
#ifdef MST_ZVSLB
    case MST_ZVSLB: if ( img_module->hLib )
                    {
                      LoggingDo(LL_IMG, "Unloading ZVSLB #%ld (used %ld times)", IMG_MODULE_INDEX(img_module), img_module->nUsages) ;
                      Slbclose( img_module->hLib ) ;
                      img_module->hLib = img_module->SlbExec = NULL ;
                    }
                    break ;
#endif
  }

  return 0 ;
}

static short DImgLoadLDI(char* filename, IMG_MODULE* img_module)
{
  /* Note there is no such LDI module right now */
  /* It is just in case image modules be        */
  /* External some day, but considering zView   */
  /* LDGs and SLBs, this is pretty unlikely     */
  short ret = EIMG_MODULERROR ;

  if ( img_module->LibFilename != filename )
    img_module->LibFilename = Xstrdup( filename ) ;
  if ( img_module->LibFilename == NULL )
  {
    LoggingDo(LL_ERROR, "Can't allocate LDI filename") ;
    return ret ;
  }

  img_module->hLib = ldg_exec( ap_id, filename ) ;
  if ( img_module->hLib )
  {
    img_module->Type       = MST_LDI ;
    img_module->GetDrvCaps = ldg_find( "GetDrvCaps", img_module->hLib ) ;
    img_module->Identify   = ldg_find( "Identify", img_module->hLib ) ;
    img_module->Load       = ldg_find( "Load", img_module->hLib ) ;
    img_module->Save       = ldg_find( "Save", img_module->hLib ) ;
    if ( img_module->GetDrvCaps == NULL )
    {
      img_module->LastError = EIMG_MODULERROR ;
      Xfree( img_module->LibFilename ) ; img_module->LibFilename = NULL ;
      DImgUnloadImgModule( img_module ) ;
    }
    else ret = EIMG_SUCCESS ;
  }

  return ret ;
}

static short DImgLoadZVLDG(char* filename, IMG_MODULE* img_module)
{
  short ret = -1 ;

  if ( img_module->LibFilename != filename )
    img_module->LibFilename = Xstrdup( filename ) ;
  if ( img_module->LibFilename == NULL )
  {
    LoggingDo(LL_ERROR, "Can't allocate LDG filename") ;
    return ret ;
  }

  img_module->hLib = ldg_exec( ap_id, filename ) ;
  if ( img_module->hLib ) ret = iizview_init( MST_ZVLDG, img_module ) ;

  if ( ret )
  {
    Xfree( img_module->LibFilename ) ; img_module->LibFilename = NULL ;
    DImgUnloadImgModule( img_module ) ;
  }

  img_module->LastError = (short)ret ;

  return img_module->LastError ;
}

#ifdef MST_ZVSLB
static short DImgLoadZVSLB(char* filename, IMG_MODULE* img_module)
{
  char  name[260] ;
  char  path[260] ;
  char* last_slash ;
  long  ret = -1 ;

  if ( img_module->LibFilename != filename )
    img_module->LibFilename = Xstrdup( filename ) ;
  if ( img_module->LibFilename == NULL )
  {
    LoggingDo(LL_ERROR, "Can't allocate memory for SLB filename") ;
    return EIMG_NOMEMORY ;
  }

  /* Slbopen wants name and path separate */
  last_slash = strrchr( filename, '\\' ) ;
  if ( last_slash )
  {
    strcpy( name, 1 + last_slash ) ;
    *last_slash = 0 ;
    sprintf( path, "%s\\", filename ) ; /* Magic 5.02 expects '\' */
    *last_slash = '\\' ; /* Restore last slash in filename */
  }
  else strcpy( name, filename ) ;

  ret = Slbopen( name, last_slash ? path:NULL, 0L, &img_module->hLib, &img_module->SlbExec ) ;
  if ( ret >= 0 )
  {
    img_module->SlbVersion = ret ;
    ret                    = iizview_init( MST_ZVSLB, img_module ) ;
  }
  else ret = EIMG_MODULERROR ;

  if ( ret != EIMG_SUCCESS )
  {
    LoggingDo(LL_ERROR, "Can't open/init SLB %s: error %ld", filename, ret) ;
    Xfree( img_module->LibFilename ) ; img_module->LibFilename = NULL ;
    DImgUnloadImgModule( img_module ) ;
  }

  img_module->LastError = (short)ret ;

  return img_module->LastError ;
}
#endif

static short DMNeedUnload(size_t required_memory)
{
  size_t st_ram, tt_ram, ram_available ;
  short  need_unload ;

  XMemAvailable( &st_ram, &tt_ram ) ;
  ram_available = (st_ram > tt_ram) ? st_ram:tt_ram ; /* Largest block */
  need_unload = (ram_available < required_memory) ;
  LoggingDo(LL_INFO, "Estimated memory required: %lu KB, ram available is %lu KB", required_memory/1024, ram_available/1024) ;
  if ( need_unload ) LoggingDo(LL_INFO, "Need to unload modules as estimate is %lu KB and ram available is %lu KB", required_memory/1024, ram_available/1024) ;

  return need_unload ;
}

static int img_mod_usage_compare(const void *i, const void *j)
{
  IMG_MODULE** one = (IMG_MODULE**) i ;
  IMG_MODULE** two = (IMG_MODULE**) j ;

  return (int)((*one)->nUsages - (*two)->nUsages) ;
}

static void DMMemoryManager(IMG_MODULE* NotThisOne, size_t required_memory)
{
  if ( (NbImgModules > 0) && DMNeedUnload(required_memory) )
  {
    IMG_MODULE* modules_list[200] ; /* For simplicity, assume no more than 200 modules loaded at the same time */
    size_t      oram_available, ram_available ;
    size_t      bytes_freed ;
    short       i, n_mod_loaded = 0 ;

    oram_available = XmemAvailableG() ;
    LoggingDo(LL_INFO, "Request to unload some image module(s)...") ;
    /* Build an array of pointer to image modules that  */
    /* Are loaded and sort it out based on module usage */
    /* To decide which module(s) to unload              */
    for ( i = 0; (i < NbImgModules) && (n_mod_loaded < ARRAY_SIZE(modules_list)); i++ )
      if ( ImgModules[i].hLib != NULL )
        modules_list[n_mod_loaded++] = &ImgModules[i] ;
    if ( n_mod_loaded > 0 )
    {
      short n = 0 ;

      LoggingDo(LL_DEBUG, "%d modules are loaded, starting clean-up...", n_mod_loaded) ;
      qsort( modules_list, n_mod_loaded, sizeof(IMG_MODULE*), img_mod_usage_compare ) ;
      i = 0 ;
      do
      {
        if ( modules_list[i] != NotThisOne ) /* Don't unload module about to get used */
        {
          IMTerminate( modules_list[i], 1 ) ;
          DImgUnloadImgModule( modules_list[i] ) ;
          n++ ;
        }
      }
      while( DMNeedUnload( required_memory ) && (++i < n_mod_loaded) ) ;
      ram_available = XmemAvailableG() ;
      bytes_freed = ram_available - oram_available ;
      LoggingDo(LL_INFO, "%d modules unloaded, %lu bytes freed (%lu by LDG unload)", n, bytes_freed, bytes_freed-n*sizeof(ZVIEW_SPECIFIC) ) ;
    }
  }
}

/* A simplified version of DMMemoryManager but probably no less efficient: */
/* Just remove all image modules but the one to be used                    */
static void DMMMFreeModules(IMG_MODULE* NotThisOne)
{
  IMG_MODULE* img_module ;
  size_t      oram_available ;
  size_t      bytes_freed ;
  short       i, n = 0 ;

  oram_available = XmemAvailableG() ;
  for ( i = 0, img_module = &ImgModules[0]; i < NbImgModules; i++, img_module++ )
    if ( img_module->hLib && (img_module != NotThisOne) ) /* Don't unload module about to get used */
    {
      IMTerminate( img_module, 1 ) ;
      DImgUnloadImgModule( img_module ) ;
      n++ ;
    }

  bytes_freed = XmemAvailableG()-oram_available ;
  /* Depeding on how memory was allocated/allocator algo, memory freed may not show here */
  if ( bytes_freed > n*sizeof(ZVIEW_SPECIFIC) ) LoggingDo(LL_INFO, "%d modules unloaded, %lu bytes freed (%lu by LDG unload)", n, bytes_freed, bytes_freed-n*sizeof(ZVIEW_SPECIFIC) ) ;
  else                                          LoggingDo(LL_INFO, "%d modules unloaded, %lu bytes freed", n, bytes_freed ) ;
}

static int LoadModuleIfRequired(IMG_MODULE* ImgModule)
{
  short ret = EIMG_SUCCESS ;

  /* Don't try to reload a module that already failed to load */
  if ( ImgModule->LastError != EIMG_SUCCESS ) return ImgModule->LastError ;

  if ( ImgModule->IsDynamic && (ImgModule->hLib == NULL) && ImgModule->LibFilename )
  {
    LoggingDo(LL_IMG,"Need to load image module #%ld %s (type %c)", IMG_MODULE_INDEX(ImgModule), ImgModule->LibFilename, ImgModule->Type) ;
    switch( ImgModule->Type )
    {
      case MST_LDI:   ret = DImgLoadLDI( ImgModule->LibFilename, ImgModule ) ;
                      break ;
      case MST_ZVLDG: ret = DImgLoadZVLDG( ImgModule->LibFilename, ImgModule ) ;
                      break ;
#ifdef MST_ZVSLB
      case MST_ZVSLB: ret = DImgLoadZVSLB( ImgModule->LibFilename, ImgModule ) ;
                      break ;
#endif
      default:        ret = -1 ; /* Should not happen */
                      break ;
    }
  }

  /* Let's remember we used this module once again */
  /* If we need to free some memory, we will have  */
  /* Metric to decide on                           */
  if ( ret == EIMG_SUCCESS ) ImgModule->nUsages++ ;

  return ret ;
}

short IMGetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps)
{
  /* This information is cached when module is loaded for      */
  /* First time, so then just copy back the cached information */
  if ( ImgModule->Capabilities.short_name[0] == 0 ) /* short_name shall be set by 1st call */
  {
    /* First time we are called, library has just been loaded */
    /* So no need to call LoadModuleIfRequired                */
    if ( ImgModule->GetDrvCaps ) ImgModule->GetDrvCaps( ImgModule, caps ) ;
    else                         LoggingDo(LL_ERROR,"GetDrvCaps expected to be != NULL") ;
  }
  else memcpy( caps, &ImgModule->Capabilities, sizeof(INFO_IMAGE_DRIVER) ) ;

  return EIMG_SUCCESS ;
}

short IMIdentify(IMG_MODULE* ImgModule, char* name, INFO_IMAGE* inf)
{
  short status = LoadModuleIfRequired( ImgModule ) ;

  if ( status == EIMG_SUCCESS )
  {
    status = EIMG_MODULERROR ;
    if ( ImgModule->Identify ) status = ImgModule->Identify( ImgModule, name, inf ) ;
    else                       LoggingDo(LL_ERROR,"Identify expected to be != NULL") ;
  }
  else LoggingDo(LL_ERROR,"IMIdentify: error %d when trying to load dynamic module", status) ;

  return status ;
}

short IMLoad(IMG_MODULE* ImgModule, INFO_IMAGE* inf)
{
  short status = LoadModuleIfRequired( ImgModule ) ;

  if ( status == EIMG_SUCCESS )
  {
    MFDB* out = &inf->mfdb ;

    status = EIMG_MODULERROR ;
    if ( ImgModule->Load ) status = ImgModule->Load( ImgModule, inf ) ;
    else                   LoggingDo(LL_ERROR,"Load expected to be != NULL") ;
    if ( status == EIMG_NOMEMORY )
    {
      INFO_IMAGE inf_bck ;

      /* Let's unload unused modules to free some memory   */
      /* And hope it would help image module to load image */
      LoggingDo(LL_INFO, "Module ran out of memory, unloading other modules...") ;
      DMMMFreeModules( ImgModule ) ;
      memcpy( &inf_bck, inf, sizeof(INFO_IMAGE) ) ;
      if ( inf->palette ) Xfree( inf->palette ) ; inf->palette = NULL ;
      /* Need to call identify again as resources have been freed when module returned error */
      status = IMIdentify( ImgModule, inf->filename, inf ) ;
      if ( status == EIMG_SUCCESS )
      {
        inf->lformat         = inf_bck.lformat ;
        inf->mfdb.fd_nplanes = inf_bck.mfdb.fd_nplanes ;
        inf->nb_modules      = inf_bck.nb_modules ;
        memcpy( &inf->img_modules, &inf_bck.img_modules, sizeof(inf->img_modules) ) ;
        status = ImgModule->Load( ImgModule, inf ) ;
      }
    }
    if ( status == EIMG_USERCANCELLED )
    {
      LoggingDo(LL_INFO, "User cancelled loading, freeing partial image") ;
      if ( out->fd_addr ) Xfree( out->fd_addr ) ;
      memset( out, 0, sizeof(MFDB) ) ;
    }
  }
  else LoggingDo(LL_ERROR,"IMLoad: error %d when trying to load dynamic module", status) ;

  return status ;
}

short IMSave(IMG_MODULE* ImgModule, char* name, MFDB* img, INFO_IMAGE* info, GEM_WINDOW* wprog)
{
  short status = LoadModuleIfRequired( ImgModule ) ;

  if ( status == EIMG_SUCCESS )
  {
    status = EIMG_MODULERROR ;
    if ( ImgModule->Save ) return ImgModule->Save( ImgModule, name, img, info, wprog ) ;
    else                   LoggingDo(LL_ERROR,"Save expected to be != NULL") ;
  }
  else LoggingDo(LL_ERROR,"IMSave: error %d when trying to load dynamic module", status) ;

  return status ;
}

void IMTerminate(IMG_MODULE* ImgModule, short keep_filename)
{
  if ( ImgModule->Terminate ) ImgModule->Terminate( ImgModule ) ;
  if ( !keep_filename )
  {
    if ( ImgModule->LibFilename ) Xfree( ImgModule->LibFilename ) ;
    ImgModule->LibFilename = NULL ;
  }
}

static void SetStaticModule(IMG_MODULE* img_module)
{
  img_module->IsDynamic = 0 ;
  img_module->Type      = MST_LDI ;
  (void)IMGetDrvCaps( img_module, &img_module->Capabilities ) ;
}

#define set_iiinternal(iii, getdrvcaps, identify, load, save, terminate) \
  iii.GetDrvCaps = getdrvcaps ;\
  iii.Identify = identify ;\
  iii.Load = load ;\
  iii.Save = save ;\
  iii.Terminate = terminate ;

static void LoadStaticModules(void)
{
#if ( NB_STATIC_MODULES > 0 )
  IMG_MODULE* img_module ;
  II_INTERNAL iii ;

  NbImgModules = NB_STATIC_MODULES ;
  ImgModules = (IMG_MODULE*) Xcalloc( NbImgModules, sizeof(IMG_MODULE) ) ;
  if ( ImgModules == NULL ) NbImgModules = 0 ;

  img_module = ImgModules ;
  if ( img_module )
  {
#ifdef STATIC_JPEG
    set_iiinternal( iii, jpeg_getdrvcaps, jpeg_identify, jpeg_load, jpeg_sauve, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_PNG
    set_iiinternal( iii, png_getdrvcaps, png_identify, png_load, png_sauve, png_terminate ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_TIFF
    set_iiinternal( iii, tiff_getdrvcaps, tiff_identify, tiff_load, tiff_sauve, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_GIF
    set_iiinternal( iii, gif_getdrvcaps, gif_identify, gif_load, gif_sauve, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_TARGA
    set_iiinternal( iii, targa_getdrvcaps, targa_identify, targa_load, targa_sauve, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_BMP
    set_iiinternal( iii, bmp_getdrvcaps, bmp_identify, bmp_load, bmp_sauve, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_IMG
    set_iiinternal( iii, img_getdrvcaps, img_identify, img_load, img_sauve, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_DEGAS
    set_iiinternal( iii, degas_getdrvcaps, degas_identify, degas_load, degas_sauve, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_ART
    set_iiinternal( iii, art_getdrvcaps, art_identify, art_load, art_sauve, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_NEO
    set_iiinternal( iii, neo_getdrvcaps, neo_identify, neo_load, neo_sauve, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    img_module++ ;
#endif
#ifdef STATIC_MAC
    set_iiinternal( iii, mac_getdrvcaps, mac_identify, mac_load, NULL, NULL ) ;
    iiinternal_init( img_module, &iii ) ;
    SetStaticModule( img_module ) ;
    /* Last module, don't img_module++ */
#endif
  }
#endif
}

static unsigned long GetSignature(unsigned long size, unsigned short date, unsigned short time)
{
  unsigned long signature ;
  unsigned long tmp ;

  signature  = size << 16 ;
  tmp        = 7 * date + 2 * time ;
  signature |= tmp ;

  return signature ;
}

static int UpdateImgDataBase(int type, char *filename, char *mod_name, long signature, HINI h_ini, IMG_MODULE* img_module)
{
  int  ret ;
  char buf[200] ;
  char *pt1, *pt2 ;

  switch( type )
  {
    case MST_LDI:   ret = DImgLoadLDI( filename, img_module ) ;
                    break ;
    case MST_ZVLDG: ret = DImgLoadZVLDG( filename, img_module ) ;
                    break ;
#ifdef MST_ZVSLB
    case MST_ZVSLB: ret = DImgLoadZVSLB( filename, img_module ) ;
                    break ;
#endif
    default:        ret = -1 ; /* Should not happen */
                    break ;
  }

  if ( ret == 0 )
  {
    /* Get capabilities and unload module, we will reload it when used */
    IMGetDrvCaps( img_module, &img_module->Capabilities ) ;
    DImgUnloadImgModule( img_module ) ;

    img_module->Signature = signature ;
    sprintf( buf, "%lx", img_module->Signature ) ;
    SetIniKey( h_ini, mod_name, "Signature", buf ) ;

    sprintf( buf, "%lx", img_module->Capabilities.iid ) ;
    if ( SetIniKey( h_ini, mod_name, "IID", buf ) == 0 ) return -1 ;

    if ( SetIniKey( h_ini, mod_name, "Name", img_module->Capabilities.name ) == 0 ) return -1 ;

    if ( SetIniKey( h_ini, mod_name, "ShortName", img_module->Capabilities.short_name ) == 0 ) return -1 ;

    sprintf( buf, "%x", img_module->Capabilities.version ) ;
    if ( SetIniKey( h_ini, mod_name, "Version", buf ) == 0 ) return -1 ;

    sprintf( buf, "%x", img_module->Capabilities.export ) ;
    if ( SetIniKey( h_ini, mod_name, "ExportFlags", buf ) == 0 ) return -1 ;

    sprintf( buf, "%x", img_module->Capabilities.import ) ;
    if ( SetIniKey( h_ini, mod_name, "ImportFlags", buf ) == 0 ) return -1 ;

    pt1 = buf ;
    pt2 = img_module->Capabilities.known_extensions ;
    while ( *pt2 )
    {
      *pt1++ = *pt2++ ;
      if ( *pt2 == 0 )
      {
        *pt1++ = ' ' ;
        pt2++ ;
      }
    }
    *pt1 = 0 ;
    if ( SetIniKey( h_ini, mod_name, "KnownExtensions", buf ) == 0 ) return -1 ;

    if ( SetIniKey( h_ini, mod_name, "FileExtension", img_module->Capabilities.file_extension ) == 0 ) return -1 ;
  }
  else
    LoggingDo(LL_ERROR, "Failed to load module %s with %d", filename, ret) ;

  return ret ;
}

static long LoadImgDataBase(char *mod_name, long signature, HINI h_ini, IMG_MODULE* img_module)
{
  char  buf[200] ;
  char* pt ;

  memset( img_module, 0, sizeof(IMG_MODULE) ) ;
  img_module->Signature = signature ;
  img_module->LastError = EIMG_SUCCESS ;

  if ( GetIniKey( h_ini, mod_name, "IID", buf ) == 0 ) return -1 ;
  sscanf( buf, "%lx", &img_module->Capabilities.iid ) ;

  if ( GetIniKey( h_ini, mod_name, "ShortName", buf ) == 0 ) return -1 ;
  sscanf( buf, "%15s", img_module->Capabilities.short_name ) ;

  if ( GetIniKey( h_ini, mod_name, "Name", buf ) == 0 ) return -1 ;
  sscanf( buf, "%39s", img_module->Capabilities.name ) ;

  if ( GetIniKey( h_ini, mod_name, "Version", buf ) == 0 ) return -1 ;
  sscanf( buf, "%x", &img_module->Capabilities.version ) ;

  if ( GetIniKey( h_ini, mod_name, "FileExtension", buf ) == 0 ) return -1 ;
  sscanf( buf, "%5s", img_module->Capabilities.file_extension ) ;

  if ( GetIniKey( h_ini, mod_name, "ImportFlags", buf ) == 0 ) return -1 ;
  sscanf( buf, "%x", &img_module->Capabilities.import ) ;

  if ( GetIniKey( h_ini, mod_name, "ExportFlags", buf ) == 0 ) return -1 ;
  sscanf( buf, "%x", &img_module->Capabilities.export ) ;

  if ( GetIniKey( h_ini, mod_name, "KnownExtensions", img_module->Capabilities.known_extensions ) == 0 ) return -1 ;
  pt = img_module->Capabilities.known_extensions ;
  while ( *pt )
  {
    if ( *pt == ' ' ) *pt = 0 ;
    pt++ ;
  }
  *pt = 0 ;

  return signature ;
}

static char* GetModuleType(char type)
{
  switch( type )
  {
    case MST_LDI:   return "Internal" ;
    case MST_ZVLDG: return "zView LDG" ;
#ifdef MST_ZVSLB
    case MST_ZVSLB: return "zView SLB" ;
#endif
  }

  return "???" ;
}

static short OnNewModule(FR_CDATA* fr_cdata)
{
  MOD_SCAN*     mod_scan = (MOD_SCAN*) fr_cdata->user_data ;
  IMG_MODULE*   img_module ;
  unsigned long signature ;
  unsigned long fsignature = -1 ;
  char          buf[PATH_MAX] ;
  char          nameup[64] ;
  char*         d_fname = strrchr( fr_cdata->filename, '\\' ) ;

  if ( d_fname == NULL ) d_fname = fr_cdata->filename ;
  else                   d_fname++ ;
  LoggingDo(LL_DEBUG, "New module %s (type %s) found", d_fname, GetModuleType(mod_scan->type)) ;
  memset( nameup, 0, sizeof(nameup) ) ;
  strncpy( nameup, d_fname, sizeof(nameup)-1 ) ;
  strupr( nameup ) ;
  img_module = &ImgModules[NbImgModules] ;
  buf[0]     = 0 ;
  signature  = GetSignature( fr_cdata->size, fr_cdata->date, fr_cdata->time ) ;
  if ( GetIniKey( mod_scan->h_ini, nameup, "Signature", buf ) )
    sscanf( buf, "%lx", &fsignature ) ;

  if ( signature == fsignature )
  {
    LoggingDo(LL_DEBUG, "Module already registered") ;
    signature = LoadImgDataBase( nameup, signature, mod_scan->h_ini, img_module ) ;
    img_module->LibFilename = Xstrdup( fr_cdata->filename ) ;
    if ( img_module->LibFilename == NULL )
    {
      LoggingDo(LL_ERROR, "Can't allocate LDG filename") ;
      return 0 ;
    }
  }

  if ( signature != fsignature )
  {
    LoggingDo(LL_IMG, "Module updated or not registered, updating module database...") ;
    memset( img_module, 0, sizeof(IMG_MODULE) ) ;
    img_module->LastError = EIMG_SUCCESS ;
    if ( UpdateImgDataBase( mod_scan->type, fr_cdata->filename, nameup, signature, mod_scan->h_ini, img_module ) )
      return 0 ;
    if ( mod_scan->msg_for_prog && (mod_scan->wprog == NULL) )
      mod_scan->wprog = DisplayStdProg( mod_scan->msg_for_prog, "", nameup, 0 ) ;
    mod_scan->save_ini = 1 ;
  }

  /* If we are here, this is a success */
  img_module->Type      = mod_scan->type ;
  img_module->IsDynamic = 1 ;
  NbImgModules++ ;

  (void)GWProgRange( mod_scan->wprog, NbImgModules, mod_scan->nb_files, NULL ) ;
  if ( mod_scan->wprog ) StdProgWText( mod_scan->wprog, 2, nameup ) ;
  return 0 ;
}

static void LoadDynamicModules(int type, char *path, char *msg_for_prog)
{
  MOD_SCAN mod_scan ;
  FR_DATA  fr_data ;
  char     ext_mask[10] ;

  switch( type )
  {
    case MST_LDI:   strcpy( ext_mask, "*.LDI" ) ;
                    break ;
    case MST_ZVLDG: strcpy( ext_mask, "*.LDG" ) ;
                    break ;
#ifdef MST_ZVSLB
    case MST_ZVSLB: strcpy( ext_mask, "*.SLB" ) ;
                    break ;
#endif
    default:        ext_mask[0] = 0 ; /* Should not happen */
                    break ;
  }
  fr_data.flags       = 0 ;
  fr_data.path        = path ;
  fr_data.mask        = ext_mask ;
  fr_data.log_file    = NULL ;
  fr_data.user_func   = NULL ;
  fr_data.user_data   = NULL ;
  mod_scan.nb_files   = count_files( 0, &fr_data ) ;
  mod_scan.type       = type ;
  LoggingDo(LL_IMG, "%ld modules of type %s found in %s", mod_scan.nb_files, GetModuleType(type), path) ;
  if ( mod_scan.nb_files > 0 )
  {
    IMG_MODULE* new_img_modules ;
    char        ini_file[256] ;

    if ( NbImgModules < 0 ) NbImgModules = 0 ; /* Was not initialized */
    new_img_modules = (IMG_MODULE*) Xcalloc( mod_scan.nb_files + NbImgModules, sizeof(IMG_MODULE) ) ;
    if ( new_img_modules == NULL )
    {
      LoggingDo(LL_WARNING, "Not enough memory to allocate ZView LDG array") ;
      return ;
    }

    if ( ImgModules && (NbImgModules > 0) )
    {
      memcpy( new_img_modules, ImgModules, sizeof(IMG_MODULE)*NbImgModules ) ;
      Xfree( ImgModules ) ;
    }
    ImgModules            = new_img_modules ;
    mod_scan.wprog        = NULL ;
    mod_scan.msg_for_prog = msg_for_prog ;
    mod_scan.save_ini     = 0 ;
    sprintf( ini_file, "%s\\MOD%c.INI", path, type ) ;
    mod_scan.h_ini = OpenIni( ini_file ) ;
    if ( mod_scan.h_ini )
    {
      /* File exists or is to be created */
      fr_data.flags      = 0 ;
      fr_data.path       = path ;
      fr_data.mask       = ext_mask ;
      fr_data.log_file   = NULL ;
      fr_data.user_func  = OnNewModule ;
      fr_data.user_data  = &mod_scan ;
      find_files( &fr_data ) ;

      if ( mod_scan.save_ini ) SaveAndCloseIni( mod_scan.h_ini, NULL ) ;
      else                     CloseIni( mod_scan.h_ini ) ;
    }
    if ( mod_scan.wprog ) GWDestroyWindow( mod_scan.wprog ) ;
  }
}

static void LoadModulesInformations(char *paths[NB_MST_MAX], char *msg_for_prog, char* priorities)
{
  short type ;
  char* path ;

  /* paths[MST_LDI-MST_LDI]:   path where internal modules are located (unused) */
  /* paths[MST_ZVLDG-MST_LDI]: path where zView LDG modules are located         */
  /* paths[MST_ZVSLB-MST_LDI]: path where zView SLB modules are located         */
  LoggingDo(LL_INFO, "Image module priorities: %s", priorities) ;
  if ( strchr( priorities, MST_LDI ) ) LoadStaticModules() ;
  for ( type = MST_LDI; type < MST_LDI+NB_MST_MAX; type++ )
  {
    path = paths[type-MST_LDI] ;
    if ( path ) LoggingDo(LL_DEBUG, "Loading dynamic modules %s from path %s...", GetModuleType(type), path) ;
    else        LoggingDo(LL_DEBUG, "No path for dynamic modules %s", GetModuleType(type)) ;
    if ( path && strchr( priorities, type ) ) LoadDynamicModules( type, path, msg_for_prog ) ;
  }

#ifndef __NO_LOGGING
{
  IMG_MODULE*        img_module ;
  INFO_IMAGE_DRIVER* caps ;
  char               buffer[64] ;
  char*              c, *b ;
  short              i ;

  LoggingDo(LL_IMG,"%d image module available:", NbImgModules) ;
  for ( img_module = ImgModules, i = 0; i < NbImgModules; i++, img_module++ )
  {
    caps = &img_module->Capabilities ;
    c    = (char*)&caps->iid ;
    LoggingDo(LL_IMG, "  #%d", i) ;
    LoggingDo(LL_IMG, "  File:             %s", img_module->LibFilename ? img_module->LibFilename:"") ;
    LoggingDo(LL_IMG, "  Type:             %c (%s module)", img_module->Type, GetModuleType(img_module->Type)) ;
    LoggingDo(LL_IMG, "  Dynamic:          %s", img_module->IsDynamic ? "Yes":"No") ;
    LoggingDo(LL_IMG, "  IID:              %c%c%c ($%lx)", c[0], c[1], c[2], caps->iid) ;
    LoggingDo(LL_IMG, "  Name:             %s", caps->name) ;
    LoggingDo(LL_IMG, "  Version:          %02x.%02x", caps->version >> 8, caps->version & 0xFF) ;
    memset( buffer, 0, sizeof(buffer) ) ;
    b = buffer ;
    c = caps->known_extensions ;
    while ( *c )
    {
      while ( *c ) *b++ = *c++ ;
      *b++ = ' ' ;
      c++ ;
    }
    LoggingDo(LL_IMG, "  Known extensions: %s", buffer ) ;
  }
}
#endif
}

void DImgFreeModules(void)
{
  IMG_MODULE* img_module ;
  int         i ;

  /* Call all Terminate & Unload if provided */ 
  for ( img_module = ImgModules, i = 0; i < NbImgModules; i++, img_module++ )
  {
    IMTerminate( img_module, 0 ) ; /* Don't keep LibFileName as we won't reload module */
    DImgUnloadImgModule( img_module ) ;
  }

  if ( ImgModules ) Xfree( ImgModules ) ;
  ImgModules   = NULL ;
  NbImgModules = -1 ;
}

IMG_MODULE* DImgGetModuleFromIID(IID iid)
{
  IMG_MODULE* img_module ;
  IMG_MODULE* img_module_found = NULL ;
  short       i ;

  for ( img_module = ImgModules, i = 0; i < NbImgModules;  i++, img_module++ )
  {
    if ( img_module->Capabilities.iid == iid ) img_module_found = img_module ;
    if ( img_module_found && (img_module_found->Type == ImgModulesPrefType) ) break  ;
  }

  return img_module_found ;
}

static short ModuleCanHandleExtension(IMG_MODULE* img_module, char *ext)
{
  char* know_ext = img_module->Capabilities.known_extensions ;
  short can_handle = 0 ;

  while ( !can_handle && know_ext[0] )
  {
    if ( strcmpi( know_ext, ext ) == 0 ) can_handle = 1 ;
    else                                 know_ext  += 1 + strlen( know_ext ) ;
  }

  return can_handle ;
}

IMG_MODULE* DImgGetModuleForExtension(char *ext, IMG_MODULE* start_module, int only_pref_for_type)
{
  IMG_MODULE* img_module = NULL ;
  IMG_MODULE* img_module_found = NULL ;
  IMG_MODULE* post_last_module = &ImgModules[NbImgModules] ;

  if ( start_module == NULL )
    img_module = ImgModules ; /* Start from first image module */
  else if ( (start_module >= ImgModules) && (start_module < post_last_module) )
    img_module = start_module ; /* Start from image module in known image module array */
  else
  {
    img_module = post_last_module ; /* Invalid start module */
    LoggingDo(LL_ERROR, "DImgGetModuleForExtension: start_module %p not between %p and %p", start_module, ImgModules, post_last_module) ;
  }

  if ( only_pref_for_type )
  {
    /* Only preferred type requested */
    for ( ; img_module < post_last_module; img_module++ )
    {
      if ( (img_module->Type == ImgModulesPrefType) && ModuleCanHandleExtension( img_module, ext ) )
      {
        img_module_found = img_module ;
        break  ;
      }
    }
  }
  else
  {
    /* If preferred type cannot handle, allow other types */
    for ( ; img_module < post_last_module; img_module++ )
    {
      if ( ModuleCanHandleExtension( img_module, ext ) ) img_module_found = img_module ;
      if ( img_module_found && (img_module_found->Type == ImgModulesPrefType) ) break  ;
    }
  }

  return img_module_found ;
}

short DImgGetModulesCandidates(char* ext, IID lformat, void** mods, short nmodules_max)
{
  IMG_MODULE** modules = (IMG_MODULE**) mods ;
  short nmods = 0 ;
  short j, i  = 0 ;

  while ( ImgGlobalPriority[i] )
  {
    for ( j = 0; j < NbImgModules; j++ )
    {
      if ( ImgModules[j].Type == ImgGlobalPriority[i] )
      {
        short add_it = 0 ;

        if ( lformat != IID_UNKNOWN )
        {
          if ( ImgModules[j].Capabilities.iid == lformat ) add_it = 1 ;
        }
        else if ( ext && ext[0] )
          if ( ModuleCanHandleExtension( &ImgModules[j], ext ) ) add_it = 1 ;

        if ( add_it && (nmods < nmodules_max) ) modules[nmods++] = &ImgModules[j] ;
      }
    }
    i++ ;
  }

  return nmods ;
}

IID DImgGetIIDFromFile(char *filename)
{
  IID   iid = IID_UNKNOWN ;
  char* ext ;

  ext = strrchr( filename, '.' ) ;
  if ( ext )
  {
    IMG_MODULE* img_module ;

    img_module = DImgGetModuleForExtension( 1+ext, NULL, 0 ) ; /* Pref has preference but allow other types */
    if ( img_module ) iid = img_module->Capabilities.iid ;
  }

  return iid ;
}

void DImgSetPriorities(char* priorities)
{
  if ( priorities )
  {
    memset( ImgGlobalPriority, 0, sizeof(ImgGlobalPriority) ) ;
    strncpy( ImgGlobalPriority, priorities, sizeof(ImgGlobalPriority)-1 ) ;
  }
}

void DImgGetPriorities(char* priorities, int nmax)
{
  memset( priorities, 0, nmax ) ;
  strncpy( priorities, ImgGlobalPriority, nmax ) ;
}

short DImgGetPrefType(void)
{
  return ImgModulesPrefType ;
}

void DImgSetPrefType(short type)
{
  ImgModulesPrefType = type ;
}

IMG_MODULE* DImgGetImgModules(char *paths[NB_MST_MAX], short *nb, char *msg_for_prog, char* priorities)
{
  char* ipaths[NB_MST_MAX] ;
  char* path ;
  short type ;

  memset( ipaths, 0, sizeof(ipaths) ) ;
  if ( paths == NULL ) paths = ipaths ; /* We now need a pointer to an array of paths */
  DImgSetPriorities( priorities ) ;

  for ( type = MST_LDI; type < MST_LDI+NB_MST_MAX; type++ )
  {
    path = paths[type-MST_LDI] ;
    if ( path ) strcpy( ImgModulesPath[type-MST_LDI], path ) ;
  }
  if ( NbImgModules == -1 ) LoadModulesInformations( paths, msg_for_prog, priorities ) ;
  if ( nb ) *nb = NbImgModules ;

  return ImgModules ;
}
