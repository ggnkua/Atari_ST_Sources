#include <string.h>
#include <stdlib.h>

#include "..\tools\stdprog.h"
#include "..\tools\imgmodul.h"
#include "..\tools\frecurse.h"
#include "..\tools\ini.h"

#include    "img_io.h"
#include    "art_io.h"
#include    "neo_io.h"
#include    "mac_io.h"
#include    "bmp_io.h"
#include    "gif_io.h"
#include   "tiff_io.h"
#include   "jpeg_io.h"
#include  "degas_io.h"
#include  "targa_io.h"

/* Liste des modules a compiler */
#define STATIC_JPEG
#define STATIC_TIFF
#define STATIC_GIF
#define STATIC_TARGA
#define STATIC_BMP
#define STATIC_IMG
#define STATIC_DEGAS
#define STATIC_ART
#define STATIC_NEO
#define STATIC_MAC
#define NB_STATIC_MODULES 10

static char*       ImgModulesPath ;
static IMG_MODULE* ImgModules ;
static short       NbImgModules = -1 ;

void LoadStaticModules(void)
{
  IMG_MODULE* img_module ;
  short       i ;

  NbImgModules = NB_STATIC_MODULES ;
  if ( NbImgModules > 0 )
  {
    ImgModules = (IMG_MODULE*) Xcalloc( NbImgModules, sizeof(IMG_MODULE) ) ;
    if ( ImgModules == NULL ) NbImgModules = 0 ;
  }

  img_module = ImgModules ;
  if ( img_module )
  {
#ifdef STATIC_JPEG
    img_module->GetDrvCaps = jpeg_getdrvcaps ;
    img_module->Identify   = jpeg_identify ;
    img_module->Load       = jpeg_load ;
    img_module->Save       = jpeg_sauve ;
    img_module++ ;
#endif
#ifdef STATIC_TIFF
    img_module->GetDrvCaps = tiff_getdrvcaps ;
    img_module->Identify   = tiff_identify ;
    img_module->Load       = tiff_load ;
    img_module->Save       = tiff_sauve ;
    img_module++ ;
#endif
#ifdef STATIC_GIF
    img_module->GetDrvCaps = gif_getdrvcaps ;
    img_module->Identify   = gif_identify ;
    img_module->Load       = gif_load ;
    img_module->Save       = gif_sauve ;
    img_module++ ;
#endif
#ifdef STATIC_TARGA
    img_module->GetDrvCaps = targa_getdrvcaps ;
    img_module->Identify   = targa_identify ;
    img_module->Load       = targa_load ;
    img_module->Save       = targa_sauve ;
    img_module++ ;
#endif
#ifdef STATIC_BMP
    img_module->GetDrvCaps = bmp_getdrvcaps ;
    img_module->Identify   = bmp_identify ;
    img_module->Load       = bmp_load ;
    img_module->Save       = bmp_sauve ;
    img_module++ ;
#endif
#ifdef STATIC_IMG
    img_module->GetDrvCaps = img_getdrvcaps ;
    img_module->Identify   = img_identify ;
    img_module->Load       = img_load ;
    img_module->Save       = img_sauve ;
    img_module++ ;
#endif
#ifdef STATIC_DEGAS
    img_module->GetDrvCaps = degas_getdrvcaps ;
    img_module->Identify   = degas_identify ;
    img_module->Load       = degas_load ;
    img_module->Save       = degas_sauve ;
    img_module++ ;
#endif
#ifdef STATIC_ART
    img_module->GetDrvCaps = art_getdrvcaps ;
    img_module->Identify   = art_identify ;
    img_module->Load       = art_load ;
    img_module->Save       = art_sauve ;
    img_module++ ;
#endif
#ifdef STATIC_NEO
    img_module->GetDrvCaps = neo_getdrvcaps ;
    img_module->Identify   = neo_identify ;
    img_module->Load       = neo_load ;
    img_module->Save       = neo_sauve ;
    img_module++ ;
#endif
#ifdef STATIC_MAC
    img_module->GetDrvCaps = mac_getdrvcaps ;
    img_module->Identify   = mac_identify ;
    img_module->Load       = mac_load ;
    img_module->Save       = NULL ;
    img_module++ ;
#endif
  }

  for ( img_module = ImgModules, i = 0; i < NbImgModules; i++, img_module++ )
    if ( img_module->GetDrvCaps ) img_module->GetDrvCaps( &img_module->Capabilities ) ;
}

typedef struct
{
  GEM_WINDOW *wprog ;
  char       *msg_for_prog ;
  HINI       h_ini ;
  short      save_ini ;
  long       nb_ldi_files ;
}
LDI_SCAN ;


long DImgUnloadImgModule(IMG_MODULE *img_module)
{
  if ( img_module->Ldg )
  {
    ldg_term( ap_id, img_module->Ldg ) ;
    img_module->Ldg        = NULL ;
    img_module->GetDrvCaps = NULL ;
    img_module->Identify   = NULL ;
    img_module->Load       = NULL ;
    img_module->Save       = NULL ;
  }

  return( 0 ) ;
}

long DImgLoadImgModule(char *filename, IMG_MODULE *img_module)
{
  LDG *ldg ;

  ldg = ldg_exec( ap_id, filename ) ;
  if ( ldg )
  {
    img_module->GetDrvCaps = ldg_find( "GetDrvCaps", ldg ) ;
    img_module->Identify   = ldg_find( "Identify", ldg ) ;
    img_module->Load       = ldg_find( "Load", ldg ) ;
    img_module->Save       = ldg_find( "Save", ldg ) ;
    if ( img_module->GetDrvCaps )
      img_module->Ldg = ldg ;
    else
      DImgUnloadImgModule( img_module ) ;
  }

  return( img_module->Ldg ? 0 : -1 ) ;
}

long GetSignature(DTA *dta)
{
  long signature ;
  long tmp ;

  signature   = dta->d_length ;
  signature <<= 16 ;
  tmp         = 7 * dta->d_date + 2 * dta->d_time ;
  signature |= tmp ;

  return( signature ) ;
}

int UpdateImgDataBase(char *filename, char *ldi_name, long signature, HINI h_ini, IMG_MODULE *img_module)
{
  int  flags ;
  char buf[200] ;
  char *pt1, *pt2 ;

  if ( DImgLoadImgModule( filename, img_module ) == 0 )
  {
    img_module->GetDrvCaps( &img_module->Capabilities ) ;
    DImgUnloadImgModule( img_module ) ;

    img_module->Signature = signature ;
    sprintf( buf, "%ld", img_module->Signature ) ;
    SetIniKey( h_ini, ldi_name, "Signature", buf ) ;

    sprintf( buf, "%ld", img_module->Capabilities.iid ) ;
    if ( SetIniKey( h_ini, ldi_name, "IID", buf ) == 0 ) return( -1 ) ;

    if ( GetIniKey( h_ini, ldi_name, "ShortName", img_module->Capabilities.short_name ) == 0 ) return( -1 ) ;

    sprintf( buf, "%d", img_module->Capabilities.version ) ;
    if ( SetIniKey( h_ini, ldi_name, "Version", buf ) == 0 ) return( -1 ) ;

    if ( SetIniKey( h_ini, ldi_name, "FileExtension", img_module->Capabilities.file_extension ) == 0 ) return( -1 ) ;

    memcpy( &flags, &img_module->Capabilities.file_extension + sizeof(img_module->Capabilities.file_extension), sizeof(int) ) ;
    sprintf( buf, "%d", flags ) ;
    if ( GetIniKey( h_ini, ldi_name, "ImportFlags", buf ) == 0 ) return( -1 ) ;

    memcpy( &flags, &img_module->Capabilities.file_extension + sizeof(img_module->Capabilities.file_extension) + sizeof(int), sizeof(int) ) ;
    sprintf( buf, "%d", flags ) ;
    if ( SetIniKey( h_ini, ldi_name, "ExportFlags", buf ) == 0 ) return( -1 ) ;

    pt1 = buf ;
    pt2 = img_module->Capabilities.known_extensions ;
    while ( *pt2 )
    {
      *pt1++ = *pt2 ;
      pt2++ ;
      if ( *pt2 == 0 )
      {
        *pt1++ = ' ' ;
        pt2++ ;
      }
    }
    if ( SetIniKey( h_ini, ldi_name, "KnownExtensions", buf ) == 0 ) return( -1 ) ;
  }

  return( 0 ) ;
}

long LoadImgDataBase(char *ldi_name, long signature, HINI h_ini, IMG_MODULE *img_module)
{
  unsigned int flags ;
  char         buf[200] ;
  char         *pt ;

  memset( img_module, 0, sizeof(IMG_MODULE) ) ;
  img_module->Signature = signature ;

  if ( GetIniKey( h_ini, ldi_name, "IID", buf ) == 0 ) return( -1 ) ;
  img_module->Capabilities.iid = atol( buf ) ;

  if ( GetIniKey( h_ini, ldi_name, "ShortName", buf ) == 0 ) return( -1 ) ;
  strcpy( img_module->Capabilities.short_name, buf ) ;

  if ( GetIniKey( h_ini, ldi_name, "Version", buf ) == 0 ) return( -1 ) ;
  img_module->Capabilities.version = atoi( buf ) ;

  if ( GetIniKey( h_ini, ldi_name, "FileExtension", buf ) == 0 ) return( -1 ) ;
  strcpy( img_module->Capabilities.file_extension, buf ) ;

  if ( GetIniKey( h_ini, ldi_name, "ImportFlags", buf ) == 0 ) return( -1 ) ;
  flags = atoi( buf ) ;
  memcpy( &img_module->Capabilities.file_extension + sizeof(img_module->Capabilities.file_extension), &flags, sizeof(int) ) ;

  if ( GetIniKey( h_ini, ldi_name, "ExportFlags", buf ) == 0 ) return( -1 ) ;
  flags = atoi( buf ) ;
  memcpy( &img_module->Capabilities.file_extension + sizeof(img_module->Capabilities.file_extension) + sizeof(int), &flags, sizeof(int) ) ;

  if ( GetIniKey( h_ini, ldi_name, "KnownExtensions", buf ) == 0 ) return( -1 ) ;
  strcpy( img_module->Capabilities.known_extensions, buf ) ;
  pt = img_module->Capabilities.known_extensions ;
  while ( *pt )
  {
    if ( *pt == ' ' ) *pt = 0 ;
    pt++ ;
  }

  return( signature ) ;
}

int OnNewLDI(FR_CDATA* fr_cdata)
{
  LDI_SCAN   *ldi_scan = (LDI_SCAN *) fr_cdata->user_data ;
  IMG_MODULE *img_module ;
  long       signature = -1 ;
  char       buf[200] ;

  img_module = &ImgModules[NbImgModules] ;
  buf[0]     = 0 ;
  if ( GetIniKey( ldi_scan->h_ini, fr_cdata->dta->d_fname, "Signature", buf ) )
  {
    signature = GetSignature( fr_cdata->dta ) ;
  }

  if ( signature == atol( buf ) )
  {
    signature = LoadImgDataBase( fr_cdata->dta->d_fname, signature, ldi_scan->h_ini, img_module ) ;
  }

  if ( signature != atol( buf ) )
  {
    memset( img_module, 0, sizeof(IMG_MODULE) ) ;
    if ( ldi_scan->wprog == NULL )
      ldi_scan->wprog = DisplayStdProg( ldi_scan->msg_for_prog, "", fr_cdata->dta->d_fname, 0 ) ;
    UpdateImgDataBase( fr_cdata->filename, fr_cdata->dta->d_fname, signature, ldi_scan->h_ini, img_module ) ;
    ldi_scan->save_ini = 1 ;
  }

  img_module->IsDynamic = 1 ;
  NbImgModules++ ;

  if ( ldi_scan->wprog )
  {
    int pc ;

    pc = (int) ( (100L*NbImgModules) / ldi_scan->nb_ldi_files ) ;
    ldi_scan->wprog->ProgPc( ldi_scan->wprog, pc, NULL ) ;
  }

  return 0 ;
}

void LoadDynamicModules(char *path, char *msg_for_prog, short force)
{
  LDI_SCAN ldi_scan ;
  FR_DATA  fr_data ;

  fr_data.long_names = 0 ;
  fr_data.path       = path ;
  fr_data.mask       = "*.LDI" ;
  fr_data.log_file   = NULL ;
  fr_data.user_func  = NULL ;
  fr_data.user_data  = NULL ;
  ldi_scan.nb_ldi_files = count_files( 0, &fr_data ) ;
  if ( ldi_scan.nb_ldi_files > 0 )
  {
    IMG_MODULE *new_img_modules ;
    char       ini_file[256] ;

    new_img_modules = (IMG_MODULE*) Xcalloc( ldi_scan.nb_ldi_files + NbImgModules, sizeof(IMG_MODULE) ) ;
    if ( new_img_modules == NULL ) return ;

    memcpy(new_img_modules, ImgModules, sizeof(IMG_MODULE)) ;
    Xfree(ImgModules) ;
    ImgModules            = new_img_modules ;
    ldi_scan.wprog        = NULL ;
    ldi_scan.msg_for_prog = msg_for_prog ;
    ldi_scan.save_ini     = force ;
    sprintf( ini_file, "%s\\LDI.INI", path ) ;
    ldi_scan.h_ini = OpenIni( ini_file ) ;
    if ( ldi_scan.h_ini >= 0 )
    {
      /* Le fichier existe ou bien il va etre cree */
      FR_DATA fr_data ;

      fr_data.long_names = 0 ;
      fr_data.path       = path ;
      fr_data.mask       = "*.LDI" ;
      fr_data.log_file   = NULL ;
      fr_data.user_func  = OnNewLDI ;
      fr_data.user_data  = &ldi_scan ;
      find_files( &fr_data ) ;

      if ( ldi_scan.save_ini ) SaveAndCloseIni( ldi_scan.h_ini, NULL ) ;
      else                     CloseIni( ldi_scan.h_ini ) ;
    }
    if ( ldi_scan.wprog ) GWDestroyWindow( ldi_scan.wprog ) ;
  }
}

#pragma warn -par
void LoadModulesInformations(char *path, char *msg_for_prog, short force)
{
  LoadStaticModules() ;
/*  if ( path ) LoadDynamicModules( path, msg_for_prog, force ) ;*/
}
#pragma warn +par

IMG_MODULE* DImgGetImgModules(char *path, short *nb, char *msg_for_prog, short force)
{
  if ( path == NULL ) path = ImgModulesPath ;
  if ( force || ( NbImgModules == -1 ) ) LoadModulesInformations( path, msg_for_prog, force ) ;
  if ( nb ) *nb = NbImgModules ;

  return( ImgModules ) ;
}

void DImgFreeModules(void)
{
  if ( ImgModulesPath ) Xfree( ImgModulesPath ) ;
  ImgModulesPath = NULL ;
  if ( ImgModules ) Xfree( ImgModules ) ;
  ImgModules   = NULL ;
  NbImgModules = -1 ;
}

IMG_MODULE* DImgGetModuleFromIID(IID iid)
{
  IMG_MODULE *img_module ;
  IMG_MODULE *img_module_found = NULL ;
  short      i ;

  for ( img_module = ImgModules, i = 0;
      ( img_module_found == NULL ) && ( i < NbImgModules );
      i++, img_module++ )
    if ( img_module->Capabilities.iid == iid ) img_module_found = img_module ;

  return( img_module_found ) ;
}

short ModuleCanHandleExtension(IMG_MODULE* img_module, char *ext)
{
  char  *know_ext = img_module->Capabilities.known_extensions ;
  short can_handle = 0 ;

  while ( !can_handle && know_ext[0] )
  {
    if ( strcmpi( know_ext, ext ) == 0 ) can_handle = 1 ;
    else                                 know_ext  += 1 + strlen( know_ext ) ;
  }

  return( can_handle ) ;
}

IMG_MODULE* DImgGetModuleForExtension(char *ext)
{
  IMG_MODULE *img_module ;
  IMG_MODULE *img_module_found = NULL ;
  short      i ;

  for ( img_module = ImgModules, i = 0;
      ( img_module_found == NULL ) && ( i < NbImgModules );
      i++, img_module++ )
    if ( ModuleCanHandleExtension( img_module, ext ) ) img_module_found = img_module ;

  return( img_module_found ) ;
}

IID DImgGetIIDFromFile(char *filename)
{
  IID  iid = IID_UNKNOWN ;
  char *ext ;

  ext = strrchr( filename, '.' ) ;
  if ( ext )
  {
    IMG_MODULE *img_module ;

    img_module = DImgGetModuleForExtension( 1+ext ) ;
    if ( img_module ) iid = img_module->Capabilities.iid ;
  }

  return( iid ) ;
}

void DImgSetImgModulePath(char *path)
{
  if ( path )
  {
    if ( ImgModulesPath ) Xfree( ImgModulesPath ) ;
    ImgModulesPath = (char *) Xalloc( 1+ strlen( path ) ) ;
    if ( ImgModulesPath ) strcpy( ImgModulesPath, path ) ;
  }
}
