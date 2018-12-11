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
#include  "cpupng.h" /* Workaround */

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


/* List of modules embedded in VISION */
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

static char        ImgModulesPath[PATH_MAX] ;
static char        ImgGlobalPriority[1+NB_MST_MAX] ;
static short       ImgModulesPrefType = MST_LDI ;
static IMG_MODULE* ImgModules ;
static short       NbImgModules = -1 ;


static char* GetModuleFullName(IMG_MODULE* ImgModule)
{
  return ImgModule->LdgFilename ;
}

static int DImgUnloadImgModule(IMG_MODULE* img_module)
{
  if ( img_module->Ldg )
  {
    ldg_term( ap_id, img_module->Ldg ) ;
    img_module->Ldg = NULL ;
  }

  return 0 ;
}

static int DImgLoadLDI(char* filename, IMG_MODULE* img_module)
{
  /* Workaround for Mint/Aranym: if libpng is not closed, ldg_exec will freeze */
  cpu_png_terminate() ;
  img_module->Ldg = ldg_exec( ap_id, filename ) ;
  if ( img_module->Ldg )
  {
    img_module->Type       = MST_LDI ;
    img_module->GetDrvCaps = ldg_find( "GetDrvCaps", img_module->Ldg ) ;
    img_module->Identify   = ldg_find( "Identify", img_module->Ldg ) ;
    img_module->Load       = ldg_find( "Load", img_module->Ldg ) ;
    img_module->Save       = ldg_find( "Save", img_module->Ldg ) ;
    if ( img_module->GetDrvCaps == NULL ) DImgUnloadImgModule( img_module ) ;
  }

  return( img_module->Ldg ? 0 : -1 ) ;
}

static short DImgLoadZVLDG(char* filename, IMG_MODULE* img_module)
{
  short ret = -1 ;

  if ( img_module->LdgFilename != filename )
    img_module->LdgFilename = Xstrdup( filename ) ;
  if ( img_module->LdgFilename == NULL )
  {
    LoggingDo(LL_ERROR, "Can't allocate LDG filename") ;
    return ret ;
  }
  /* Workaround for Mint/Aranym: if libpng is not closed, ldg_exec will freeze */
  cpu_png_terminate() ;
  img_module->Ldg = ldg_exec( ap_id, filename ) ;
  if ( img_module->Ldg ) ret = iizview_init( img_module ) ;
  else                   LoggingDo(LL_ERROR, "Failed to load zView plugin %s", filename) ;

  if ( ret )
  {
    img_module->LastError = ret ;
    Xfree( img_module->LdgFilename ) ; img_module->LdgFilename = NULL ;
    DImgUnloadImgModule( img_module ) ;
  }

  return ret ;
}

static int LoadModuleIfRequired(IMG_MODULE* ImgModule)
{
  short ret = EIMG_SUCCESS ;

  /* Don't try to reload a module that already failed to load */
  if ( ImgModule->LastError != EIMG_SUCCESS ) return ImgModule->LastError ;

  if ( ImgModule->IsDynamic && (ImgModule->Ldg == NULL) && ImgModule->LdgFilename )
  {
    LoggingDo(LL_IMG,"Need to load image module %s (type %c)", ImgModule->LdgFilename, ImgModule->Type) ;
    switch( ImgModule->Type )
    {
      case MST_LDI:   ret = DImgLoadLDI( ImgModule->LdgFilename, ImgModule ) ;
                      break ;
      case MST_ZVLDG: ret = DImgLoadZVLDG( ImgModule->LdgFilename, ImgModule ) ;
                      break ;
      default:        ret = -1 ; /* Should not happen */
                      break ;
    }
  }

  return ret ;
}

void IMGetDrvCaps(IMG_MODULE* ImgModule, INFO_IMAGE_DRIVER* caps)
{
  if ( ImgModule->GetDrvCaps ) ImgModule->GetDrvCaps( ImgModule, caps ) ;
  else                         LoggingDo(LL_ERROR,"GetDrvCaps expected to be != NULL") ;
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

short IMLoad(IMG_MODULE* ImgModule, char* name, MFDB* out, GEM_WINDOW* wprog)
{
  short status = LoadModuleIfRequired( ImgModule ) ;

  if ( status == EIMG_SUCCESS )
  {
    status = EIMG_MODULERROR ;
    if ( ImgModule->Load ) return ImgModule->Load( ImgModule, name, out, wprog ) ;
    else                   LoggingDo(LL_ERROR,"Load expected to be != NULL") ;
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
  else LoggingDo(LL_ERROR,"IMLoad: error %d when trying to load dynamic module", status) ;

  return status ;
}

void IMTerminate(IMG_MODULE* ImgModule)
{
  if ( ImgModule->Terminate ) ImgModule->Terminate( ImgModule ) ;
  if ( ImgModule->LdgFilename ) Xfree( ImgModule->LdgFilename ) ;
  ImgModule->LdgFilename = NULL ;
}

static void SetStaticModule(IMG_MODULE* img_module)
{
  img_module->IsDynamic = 0 ;
  img_module->Type      = MST_LDI ;
  IMGetDrvCaps( img_module, &img_module->Capabilities ) ;
}

#define set_iiinternal(iii, getdrvcaps, identify, load, save, terminate) \
  iii.GetDrvCaps = getdrvcaps ;\
  iii.Identify = identify ;\
  iii.Load = load ;\
  iii.Save = save ;\
  iii.Terminate = terminate ;

static void LoadStaticModules(void)
{
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
}

static unsigned long GetSignature(DTA *dta)
{
  unsigned long signature ;
  unsigned long tmp ;

  signature   = dta->d_length ;
  signature <<= 16 ;
  tmp         = 7 * dta->d_date + 2 * dta->d_time ;
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

static int OnNewModule(FR_CDATA* fr_cdata)
{
  MOD_SCAN*     mod_scan = (MOD_SCAN*) fr_cdata->user_data ;
  IMG_MODULE*   img_module ;
  unsigned long signature ;
  unsigned long fsignature = -1 ;
  char          buf[PATH_MAX] ;
  char          nameup[64] ;

  LoggingDo(LL_IMG, "New module %s (type %c) found", fr_cdata->dta->d_fname, mod_scan->type) ;
  memset( nameup, 0, sizeof(nameup) ) ;
  strncpy( nameup, fr_cdata->dta->d_fname, sizeof(nameup)-1 ) ;
  strupr( nameup ) ;
  img_module = &ImgModules[NbImgModules] ;
  buf[0]     = 0 ;
  signature  = GetSignature( fr_cdata->dta ) ;
  if ( GetIniKey( mod_scan->h_ini, nameup, "Signature", buf ) )
    sscanf( buf, "%lx", &fsignature ) ;

  if ( signature == fsignature )
  {
    LoggingDo(LL_IMG, "Module already registered") ;
    signature = LoadImgDataBase( nameup, signature, mod_scan->h_ini, img_module ) ;
    img_module->LdgFilename = Xstrdup( fr_cdata->filename ) ;
    if ( img_module->LdgFilename == NULL )
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

  if ( mod_scan->wprog )
  {
    int pc ;

    pc = (int) ( (100L*NbImgModules) / mod_scan->nb_files ) ;
    mod_scan->wprog->ProgPc( mod_scan->wprog, pc, NULL ) ;
  }

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
    default:        ext_mask[0] = 0 ; /* Should not happen */
                    break ;
  }
  fr_data.long_names  = 0 ;
  fr_data.path        = path ;
  fr_data.mask        = ext_mask ;
  fr_data.log_file    = NULL ;
  fr_data.user_func   = NULL ;
  fr_data.user_data   = NULL ;
  mod_scan.nb_files   = count_files( 0, &fr_data ) ;
  mod_scan.type       = type ;
  LoggingDo(LL_IMG, "%ld modules of type %c found in %s", mod_scan.nb_files, type, path) ;
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
      FR_DATA fr_data ;

      fr_data.long_names = 0 ;
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

static void LoadModulesInformations(char *path, char *msg_for_prog, char* priorities)
{
  if ( strchr( priorities, MST_LDI ) ) LoadStaticModules() ;
  if ( path && strchr( priorities, MST_ZVLDG ) ) LoadDynamicModules( MST_ZVLDG, path, msg_for_prog ) ;

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
    LoggingDo(LL_IMG, "  File:             %s", img_module->LdgFilename ? img_module->LdgFilename:"") ;
    LoggingDo(LL_IMG, "  Type:             %c (%s)", img_module->Type, (img_module->Type == MST_ZVLDG) ? "zView module":"Internal") ;
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
    IMTerminate( img_module ) ;
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

IMG_MODULE* DImgGetModuleForExtension(char *ext, IMG_MODULE* start_module)
{
  IMG_MODULE* img_module = NULL ;
  IMG_MODULE* img_module_found = NULL ;
  short       i ;

  if ( start_module == NULL )
  {
    /* Start from first image module */
    i          = 0 ;
    img_module = ImgModules ;
  }
  else if ( (start_module >= ImgModules) && (start_module < ImgModules+NbImgModules) )
  {
    /* Start from image module in known image module array */
    i          = (short) ((size_t)(start_module-ImgModules)/sizeof(IMG_MODULE)) ;
    img_module = start_module ;
  }
  else
  {
    /* Invalid start module */
    i = NbImgModules ;
    LoggingDo(LL_ERROR, "DImgGetModuleForExtension: start_module %p not between %p and %p", start_module, ImgModules, ImgModules+NbImgModules) ;
  }

  for ( ; i < NbImgModules; i++, img_module++ )
  {
    if ( ModuleCanHandleExtension( img_module, ext ) ) img_module_found = img_module ;
    if ( img_module_found && (img_module_found->Type == ImgModulesPrefType) ) break  ;
  }

  return img_module_found ;
}

IID DImgGetIIDFromFile(char *filename)
{
  IID   iid = IID_UNKNOWN ;
  char* ext ;

  ext = strrchr( filename, '.' ) ;
  if ( ext )
  {
    IMG_MODULE* img_module ;

    img_module = DImgGetModuleForExtension( 1+ext, NULL ) ;
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

void DImgSetImgModulePrefs(char *path, char* prefs)
{
  DImgSetPriorities( prefs ) ;
  if ( path ) strcpy( ImgModulesPath, path ) ;
}

short DImgGetPrefType(void)
{
  return ImgModulesPrefType ;
}

void DImgSetPrefType(short type)
{
  ImgModulesPrefType = type ;
}

IMG_MODULE* DImgGetImgModules(char *path, short *nb, char *msg_for_prog, char* priorities)
{
  DImgSetImgModulePrefs( path, priorities ) ;
  if ( path == NULL ) path = ImgModulesPath ;
  if ( NbImgModules == -1 ) LoadModulesInformations( path, msg_for_prog, priorities ) ;
  if ( nb ) *nb = NbImgModules ;

  return ImgModules ;
}
