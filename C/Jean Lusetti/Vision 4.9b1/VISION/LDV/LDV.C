#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "..\tools\chkstack.h"
#include "..\tools\scalemem.h"
#include "..\tools\gwindows.h"
#include "..\tools\rasterop.h"
#include "..\tools\frecurse.h"
#include "..\tools\logging.h"
#include "..\tools\dither.h"
#include "..\tools\xfile.h"
#include "..\tools\ini.h"

#include "actions.h"
#include "ldv\ldvcom.h"

static LDV_MODULE* Modules ;
static int         NbModules ;
static int         NumModule ;
static short       ListTypes[] = { TLDV_MODIFYIMG } ;

#define VAPI_LDVVERSION 0x0109
static VAPI*       Vapi = NULL ;
static GEM_WINDOW* LdvProg = NULL ;


void cdecl PrSetText(long no_line, char* text)
{
  if ( LdvProg && (no_line >= 0) && (no_line <= 2) )
    StdProgWText( LdvProg, (int)no_line, text ) ;
}

void cdecl PrSetProg(long pc)
{
  (void)GWProgRange( LdvProg, pc, 100, NULL ) ;
}

long cdecl PrSetProgRange(long current, long max)
{
  long ret = 0 ;

  ret = GWProgRange( LdvProg, current, max, NULL ) ;
  if ( PROG_CANCEL_CODE(ret) ) LdvProg = NULL ;

  return ret ;
}

long cdecl PrSetProgEx(long pc)
{
  long ret = PrSetProgRange( pc, 100 ) ;

  if ( PROG_GUINUP_CODE( ret ) ) ret = SPROG_GUIUPDATED ; /* Now GWProgRange return SPROG_GUINOTUPDATED if call did not end up with a GUI update */

  return ret ;
}

void cdecl PrOptimize(long mask)
{
  if ( LdvProg )
  {
    StdProgDisplay030( LdvProg, (int)mask & 0x01 ) ;
    StdProgDisplayDSP( LdvProg, (int)mask & 0x02 ) ;
    StdProgDisplayFPU( LdvProg, (int)mask & 0x04 ) ;
  }
}

void cdecl RaImgWhite(MFDB* img)
{
  img_raz( img ) ;
}

long cdecl RaIs15Bits(void)
{
  long is_15bits = 0 ;

  if ( screen.fd_nplanes == 16 ) is_15bits = RVBOrg.Is15Bits ;

  return is_15bits ;
}

void cdecl RaTCConvert(MFDB* img)
{
  tc_convert( img ) ;
}

void cdecl RaTCInvConvert(MFDB* img)
{
  tc_invconvert( img ) ;
}

void cdecl RaInd2RasterInit(MFDB* out, long width)
{
  i2r_init( out, (short)width, 0 ) ;
}

void cdecl RaInd2Raster(unsigned char* indexes, long nb_indexes)
{
  i2r_data = indexes ;
  i2r_nb   = nb_indexes ;
  ind2raster() ;
}

void cdecl RaRaster2Ind(short* pt_raster, long nb_pts, long nplans, unsigned char* out)
{
  raster2ind( (int*)pt_raster, out, nb_pts, (short)nplans ) ;
}

unsigned char* cdecl RaGetTOS2VDIArray(long nplanes)
{
  return( get_pttos2vdi( (short)nplanes ) ) ;
}

unsigned char* cdecl RaGetVDI2TOSArray(long nplanes)
{
  return( get_ptvdi2tos( (short)nplanes ) ) ;
}

unsigned long cdecl RaGetImgSize(long width, long height, long nplanes)
{
  return( (unsigned long) img_size( (int)width, (int)height, (int)nplanes ) ) ;
}

long cdecl RaRasterAlloc(MFDB* raster)
{
  size_t size ;

  size            = img_size( raster->fd_w, raster->fd_h, raster->fd_nplanes ) ;
  raster->fd_addr = Xalloc( size ) ;
  if ( raster->fd_addr == NULL ) return -1 ;

  raster->fd_wdwidth = w2wdwidth( raster->fd_w ) ;

  return 0 ;
}

void cdecl RaRasterFree(MFDB* raster)
{
  if ( raster->fd_addr ) Xfree( raster->fd_addr ) ;
  ZeroMFDB( raster ) ;
}

void cdecl RaTC15RemapColors(REMAP_COLORS* rc)
{
  TC15RemapColors( rc ) ;
}

void cdecl RaTC16RemapColors(REMAP_COLORS* rc)
{
  TC16RemapColors( rc ) ;
}

void cdecl RaTC32RemapColors(REMAP_COLORS* rc)
{
  TC32RemapColors( rc ) ;
}

void cdecl RaRasterRotateGetDstMFDB(MFDB* in, MFDB* out, long angle)
{
  float cosinus, sinus ;

  raster_rgetdstmfdb( (int)angle, in, out, &cosinus, &sinus ) ;
}

long cdecl RaRasterRotate(MFDB* in, MFDB* out, long angle, long flags)
{
  LDV_STATUS status ;
  int        ret ;

  if ( flags & 0x01L ) ret = raster_rotate( in, out, (int) angle, LdvProg ) ; /* With progress */
  else                 ret = raster_rotate( in, out, (int) angle, NULL ) ;

  switch( ret )
  {
    case 0  : status = ELDV_NOERROR ;
              break ;
    case -1 : status = ELDV_NOTENOUGHMEMORY ;
              break ;
    case  1 : status = ELDV_CANCELLED ;
              break ;
    default : status = ELDV_GENERALFAILURE ;
              break ;
  }

  return (long)status ;
}

void cdecl GEMMessageLoop(void* msg)
{
  EVENT event ;

  memcpy( &event.ev_mmgpbuf, msg, sizeof(event.ev_mmgpbuf) ) ;
  GeneralMesagHandler( &event ) ;
}

char* cdecl CoGetLDVPath(void)
{
  return config.path_ldv ;
}

char* cdecl CoGetCurrentLanguage(void)
{
  return config.language ;
}

unsigned long cdecl CoGetFunctionOptimizations(void* function)
{
  unsigned long code = 0 ;

  if ( MachineInfo.cpu >= 30L )
  {
    if ( (function == (void*)Vapi->MeSCopyMemory16) ||
         (function == (void*)Vapi->MeSCopyMemory32) ||
         (function == (void*)Vapi->RaRasterRotate)  ||
         (function == (void*)Vapi->RaInd2Raster)
       ) code |= 0x01 ;
  }

  return code ;
}

unsigned long cdecl CoGetProcessors(void)
{
  unsigned long pmask = 0 ;

  if ( (MachineInfo.cpu >= 30L) && ((config.ldv_options & LDVO_HIDE030) == 0) )
    pmask |= CO_HAS_030 ;

  if ( get_fpu() && ((config.ldv_options & LDVO_HIDEFPU) == 0) )
    pmask |= CO_HAS_FPU ;

  if ( DspInfo.type && ((config.ldv_options & LDVO_HIDEDSP) == 0) )
    pmask |= CO_HAS_DSP ;

  return pmask ;
}

void cdecl CoGetScreenInfo(SCREEN_INFO* sinfo)
{
  sinfo->Width     = (short) screen.fd_w ;
  sinfo->Height    = (short) screen.fd_h ;
  sinfo->NPlanes   = (short) screen.fd_nplanes ;
  sinfo->UseStdVDI = (short) UseStdVDI ;
}

long cdecl InOpen(char* file)
{
  return( (long) OpenIni( file ) ) ;
}

long cdecl InClose(HINI h_ini)
{
  return( CloseIni( h_ini ) ) ;
}

long cdecl InSaveAndClose(HINI h_ini, char* new_name)
{
  return( SaveAndCloseIni( h_ini, new_name ) ) ;
}

long cdecl InGetKey(HINI h_ini, char* section, char* key, char* val_key)
{
  return( GetIniKey( h_ini, section, key, val_key ) ) ;
}

long cdecl InSetKey(HINI h_ini, char* section, char* key, char* val_key)
{
  return( SetIniKey( h_ini, section, key, val_key ) ) ;
}

long cdecl InGetOrSetKey(HINI h_ini, char* section, char* key, char* val_default_key)
{
  return( GetOrSetIniKey( h_ini, section, key, val_default_key ) ) ;
}

long cdecl InGetKeyFromFile(char* file, char* section, char* key, char* val_key)
{
  return GetIniKeyFromFile( file, section, key, val_key ) ;
}

void cdecl MeSCopyMemory8(void* dst, void* src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm_smemcpy8( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl MeSCopyMemory16(void* dst, void* src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm_smemcpy16( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl MeSCopyMemory32(void* dst, void* src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm_smemcpy32( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl Me030SCopyMemory8(void* dst, void* src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm030_smemcpy8( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl Me030SCopyMemory16(void* dst, void* src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm030_smemcpy16( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl Me030SCopyMemory32(void* dst, void* src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm030_smemcpy32( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void* cdecl MeXalloc(unsigned long size)
{
  return Xalloc( size ) ;
}

void* cdecl MeXrealloc(void* ptr, unsigned long size)
{
  return Xrealloc( ptr, size ) ;
}

void cdecl MeXfree(void* ptr)
{
  Xfree( ptr ) ;
}

void* cdecl MeXcalloc(unsigned long nb_elems, unsigned long elem_size)
{
  return Xcalloc( nb_elems, elem_size ) ;
}

char* cdecl MeXstrdup(char* s)
{
  return Xstrdup( s ) ;
}

unsigned long cdecl LoGetLogLevel(void)
{
  return LoggingGetLevel() ;
}

#ifdef __NO_LOGGING
#pragma warn -par
long cdecl LoDoLog(unsigned long level, char* format, ...)
{
  return 0 ;
}
#pragma warn +par
#else
long cdecl LoDoLog(unsigned long level, char* format, ...)
{
  va_list argp ;
  long    r ;

  va_start( argp, format ) ;
  r = LoggingvDo( level, format, argp ) ;
  va_end( argp ) ;

  return r ; 
}
#endif

static int LDVSetValueFromString(char* buf, int type, LDV_BASICPARAM* p)
{
  int set = 1 ;

  switch( type )
  {
    case LDVT_SHORT :  p->s = atoi( buf ) ;
                       break ;

    case LDVT_FLOAT :  p->f = atof( buf ) ;
                       break ;

    case LDVT_FILE  : if ( buf[0] ) p->str = Xstrdup( buf ) ;
                       break ;

    default :         set = 0 ;
                      break ;
  }

  return set ;
}

static void LDVFreeParameters(LDV_MODULE* ldv_module)
{
  short i ;

  for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
  {
    LDV_DEF_PARAM* param = &ldv_module->IniSpec.Params[i] ;

    if ( (param->Type == LDVT_FILE) && param->DefaultValue.str )
    {
      Xfree( param->DefaultValue.str ) ;
      param->DefaultValue.str = NULL ;
    }
    if ( ldv_module->IniSpec.ParamLabels[i] ) Xfree( ldv_module->IniSpec.ParamLabels[i] ) ;
  }
}

static int LDVGetIniSpec(char* base_path, LDV_MODULE* ldv_module)
{
  HINI  hini ;
  char  name[PATH_MAX] ;
  char  short_name[16] ;
  char  long_name[32] ;
  char  description[80] ;
  char  buf[200] ;
  char* point ;
  int   err = 0 ;
  int   i, max_len ;

  point = strrchr( ldv_module->FileName, '.' ) ;
  if ( point ) *point = 0 ;
  sprintf( name, "%s\\%s\\%s.INI", base_path, config.language, ldv_module->FileName ) ;
  if ( !FileExist( name ) ) sprintf( name, "%s\\%s.INI", base_path, ldv_module->FileName ) ;
  hini = OpenIni( name ) ;
  if ( ( hini != NULL ) && FileExist( name ) )
  {
    short len_sname, len_lname ;

    /* ShortName */
    buf[0] = 0 ;
    GetIniKey( hini, "Informations", "ShortName", buf ) ;
    max_len = (int) sizeof(short_name) - 1 ;
    if ( strlen( buf ) > max_len ) buf[max_len] = 0 ;
    strcpy( short_name, buf ) ;

    /* LongName */
    buf[0] = 0 ;
    GetIniKey( hini, "Informations", "LongName", buf ) ;
    max_len = (int) sizeof(long_name) - 1 ;
    if ( strlen( buf ) > max_len ) buf[max_len] = 0 ;
    strcpy( long_name, buf ) ;

    /* Description */
    buf[0] = 0 ;
    GetIniKey( hini, "Informations", "Description", buf ) ;
    max_len = (int) sizeof(description) - 1 ;
    if ( strlen( buf ) > max_len ) buf[max_len] = 0 ;
    strcpy( description, buf ) ;

    ldv_module->IniSpec.ShortName   = NULL ;
    ldv_module->IniSpec.LongName    = NULL ;
    ldv_module->IniSpec.Description = NULL ;
    len_sname = 1 + (short)strlen( short_name ) ;
    len_lname = 1 + (short)strlen( long_name ) ;
    max_len  = len_sname ;
    max_len += len_lname ;
    max_len += 1 + (int) strlen( description ) ;
    ldv_module->IniSpec.ShortName = (char*) Xalloc( max_len ) ;
    if ( ldv_module->IniSpec.ShortName )
    {
      strcpy( ldv_module->IniSpec.ShortName, short_name ) ;
      strcpy( ldv_module->IniSpec.ShortName + len_sname, long_name ) ;
      strcpy( ldv_module->IniSpec.ShortName + len_sname + len_lname, description ) ;
      ldv_module->IniSpec.LongName    = ldv_module->IniSpec.ShortName + len_sname ;
      ldv_module->IniSpec.Description = ldv_module->IniSpec.LongName  + len_lname ;
    }

    /* Parameters */
    for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
    {
      LDV_DEF_PARAM* param = &ldv_module->IniSpec.Params[i] ;

      /* Name */
      buf[0] = 0 ;
      sprintf( name, "Parameter%d", 1 + i ) ;
      GetIniKey( hini, name, "Name", buf ) ;
      max_len = (int) sizeof(param->Name) - 1 ;
      if ( strlen( buf ) > max_len ) buf[max_len] = 0 ;
      strcpy( param->Name, buf ) ;

      /* Type */
      buf[0] = 0 ;
      GetIniKey( hini, name, "Type", buf ) ;
      param->Type = atoi( buf ) ;

      if ( param->Type == LDVT_SHORT )
      {
        /* MinValue */
        buf[0] = 0 ;
        GetIniKey( hini, name, "MinValue", buf ) ;
        LDVSetValueFromString( buf, param->Type, &param->MinValue ) ;

        /* DefaultValue */
        buf[0] = 0 ;
        GetIniKey( hini, name, "DefaultValue", buf ) ;
        LDVSetValueFromString( buf, param->Type, &param->DefaultValue ) ;

        /* MaxValue */
        buf[0] = 0 ;
        GetIniKey( hini, name, "MaxValue", buf ) ;
        LDVSetValueFromString( buf, param->Type, &param->MaxValue ) ;

        /* Labels */
        buf[0] = 0 ;
        GetIniKey( hini, name, "Labels", buf ) ;
        if ( buf[0] )
        {
          /* Format buffer for easier usage: */
          /* Label1,Label2,Label3\0 --> Label1\0Label2\0,Label3\0\0 */
          ldv_module->IniSpec.ParamLabels[i] = Xcalloc( 1, 2+strlen(buf) ) ;
          if ( ldv_module->IniSpec.ParamLabels[i] )
          {
            strcpy( ldv_module->IniSpec.ParamLabels[i], buf ) ;
            strrep( ldv_module->IniSpec.ParamLabels[i], ',', 0 ) ; /* Change all ',' with NULL termination */
          }
        }
        else ldv_module->IniSpec.ParamLabels[i] = NULL ;

        /* Sanity check */
        if ( param->MinValue.s > param->MaxValue.s )
          param->Name[0] = 0 ; /* Ignore */
      }
      else if ( param->Type == LDVT_FILE )
      {
        buf[0] = 0 ;
        GetIniKey( hini, name, "DefaultValue", buf ) ;
        if ( LDVSetValueFromString( buf, param->Type, &param->DefaultValue ) == 0 )
          param->Name[0] = 0 ; /* String allocation failed, ignore parameter */
      }
    }

    CloseIni( hini ) ;
  }
  else err = 1 ;
  if ( point ) *point ='.' ;

  return err ; 
}

void LDVReleaseInterface(LDV_MODULE* mod, int iid)
{
  void* old_interface = NULL ;

  if ( mod && ( mod->Infos.Type & iid ) )
  {
    switch( iid )
    {
      case TLDV_MODIFYIMG : old_interface  = mod->IModifImg ;
                            mod->IModifImg = NULL ;
                            break ;
    }
  }

  if ( old_interface )
  {
    Xfree( old_interface ) ;
    mod->NbReferences-- ;
  }
}

void* LDVGetInterface(LDV_MODULE* mod, int iid)
{
  LDG*  ldg ;
  void* interface = NULL ;

  if ( mod && (mod->Infos.Type & iid) )
  {
    ldg = mod->Ldg ;
    switch( iid )
    {
      case TLDV_MODIFYIMG : if ( mod->IModifImg ) LDVReleaseInterface( mod, iid ) ;
                            mod->IModifImg = (ILDVModifImg*) Xcalloc( 1, sizeof(ILDVModifImg) ) ;
                            if ( mod->IModifImg )
                            {
                              mod->IModifImg->PreRun  = ldg_find( "PreRun", ldg ) ;
                              mod->IModifImg->Run     = ldg_find( "Run", ldg ) ;
                              mod->IModifImg->Preview = ldg_find( "Preview", ldg ) ;
                            }
                            interface = mod->IModifImg ;
                            break ;
    }
  }

  if ( interface ) mod->NbReferences++ ;

  return interface ;
}

void LDVReleaseAllInterfaces(LDV_MODULE* ldv_module)
{
  short index ;

  for ( index = 0; index < ARRAY_SIZE(ListTypes); index++ )
    LDVReleaseInterface( ldv_module, ListTypes[index] ) ;
}

void LDVGetAllInterfaces(LDV_MODULE* ldv_module)
{
  short index ;

  for ( index = 0; index < ARRAY_SIZE(ListTypes); index++ )
    LDVGetInterface( ldv_module, ListTypes[index] ) ;
}

void LDVUnloadFunctions(LDV_MODULE* ldv_module)
{
  LDVReleaseAllInterfaces( ldv_module ) ;
  ldg_term( ap_id, ldv_module->Ldg ) ;
  ldv_module->Ldg = NULL ;
}

void LDVFreeDynParams(LDV_PARAMS* params)
{
  int i ;

  for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
  {
    if ( (params->ParamType[i] == LDVT_FILE) && params->Param[i].str )
    {
      Xfree( params->Param[i].str ) ;
      params->Param[i].str = NULL ;
    }
  }
}

LDV_STATUS LDVInit(char* file, LDV_MODULE* ldv_module, int minimal_infos)
{
  LDV_INFOS* ldv_infos = NULL ;
  LDG*       ldg ;
  LDV_STATUS err = ELDV_NOERROR ;
#if !defined(__NO_LOGGING)
  short      ver ;
#endif
  char*      slash ;
  char*      lname = file ;
  char       base_path[PATH_MAX] ;

  if ( minimal_infos )
  {
    if ( ldv_module->FileName ) Xfree( ldv_module->FileName ) ;
    memzero( ldv_module, sizeof(LDV_MODULE) ) ;
  }

  slash = strrchr( file, '\\' ) ;
  if ( slash )
  {
    *slash = 0 ;
    strcpy( base_path, file ) ;
    *slash = '\\' ;
    lname = 1 + slash ;
  }

  if ( ldv_module->FileName )
  {
    if ( strlen( ldv_module->FileName ) < strlen( lname ) )
    {
      Xfree( ldv_module->FileName ) ;
      ldv_module->FileName = Xalloc( 1 + strlen( lname ) ) ;
      if ( ldv_module->FileName == NULL ) return ELDV_NOTENOUGHMEMORY ;
    }
    strcpy( ldv_module->FileName, lname ) ;
  }
  else
  {
    ldv_module->FileName = Xalloc( 1 + strlen( lname ) ) ;
    if ( ldv_module->FileName == NULL ) return ELDV_NOTENOUGHMEMORY ;
    strcpy( ldv_module->FileName, lname ) ;
  }

  ldg = ldg_exec( ap_id, file ) ;
  if ( ldg )
  {
    ldv_module->Ldg = ldg ;

    ldv_module->GetLDVCapabilities = ldg_find( "GetLDVCapabilities", ldg ) ;
    ldv_module->Infos.StrSize      = sizeof(ldv_module->Infos) ;
    if ( ldv_module->GetLDVCapabilities ) ldv_infos = ldv_module->GetLDVCapabilities( Vapi ) ;
    else                                  err       = ELDV_GENERALFAILURE ;
    if ( LDV_SUCCESS( err ) && ldv_infos )
    {
      if ( ldv_infos->StrSize <= ldv_module->Infos.StrSize ) memcpy( &ldv_module->Infos, ldv_infos, ldv_infos->StrSize ) ;
      else                                                   err = ELDV_GENERALFAILURE ;
    }
    else
      err = ELDV_GENERALFAILURE ;
    ldv_module->Version = ldg->vers ;
#if !defined(__NO_LOGGING)
    ver = ldg->vers ;
#endif
  }
  else LoggingDo(LL_ERROR, "Failed to exec ldg %s", file);

  if ( !err )
  {
    if ( minimal_infos )
    {
      LDVGetIniSpec( base_path, ldv_module ) ;
      LDVUnloadFunctions( ldv_module ) ;
    }
    else LDVGetAllInterfaces( ldv_module ) ;
  }


#if !defined(__NO_LOGGING)
  if ( err ) LoggingDo(LL_INFO, "Loading LDV %12s returned %ld", lname, err) ;
  else       LoggingDo(LL_INFO, "Loading LDV %12s(v%x.%02x)...OK", lname, ver >> 8, ver & 0xFF) ;
#endif
 
  return err ;
}

static long ImErr(char* caller, int err)
{
  if ( err < 0 ) LoggingDo(LL_ERROR, "%s got imagelib error %d", caller, err ) ;

  return (long)err ;
}

long cdecl ImGetInf(char* filename, void* v)
{
  LDV_IMAGE*  ldv_img = (LDV_IMAGE*) v ;
  INFO_IMAGE* inf = Xcalloc( 1, sizeof(INFO_IMAGE) ) ;
  int         err ;

  if ( inf == NULL ) return EIMG_NOMEMORY ;
  memzero( ldv_img, sizeof(LDV_IMAGE) ) ;
  inf->lformat = IID_UNKNOWN ;
  err          = img_format( filename, inf ) ;
  if ( !err )
  {
    /* Copy back image information from INFO_IMAGE to LDV_IMAGE */
    ldv_img->Raster.fd_w       = align16( inf->width ) ;
    ldv_img->Raster.fd_h       = inf->height ;
    ldv_img->Raster.fd_nplanes = inf->nplanes ;
    if ( ldv_img->Raster.fd_nplanes == 24 ) ldv_img->Raster.fd_nplanes = 32 ; /* FIXME: because this is how image io works internally */
    ldv_img->Palette.NbColors  = (short) inf->nb_cpal ;
    ldv_img->Palette.Pal       = (VDI_ELEMENTPAL*) inf->palette ;
    ldv_img->Context           = inf ;
  }
  else
  {
    free_info( inf ) ;
    Xfree( inf ) ;
  }

  return ImErr( "ImGetInf", err ) ;
}

static void INF2LDVImg(INFO_IMAGE* inf, LDV_IMAGE* ldv_img)
{
  CopyMFDB( &ldv_img->Raster, &inf->mfdb ) ;
  ldv_img->Palette.Pal      = inf->palette ;
  ldv_img->Palette.NbColors = (short) inf->nb_cpal ;
  ldv_img->Context          = inf ;
}

static void LDVImg2INF(LDV_IMAGE* ldv_img, INFO_IMAGE* inf)
{
  memzero( inf, sizeof(INFO_IMAGE) ) ;
  CopyMFDB( &inf->mfdb, &ldv_img->Raster ) ;
  inf->width   = ldv_img->Raster.fd_w ;
  inf->height  = ldv_img->Raster.fd_h ;
  inf->nplanes = ldv_img->Raster.fd_nplanes ;
  inf->palette = ldv_img->Palette.Pal ;
  inf->nb_cpal = ldv_img->Palette.NbColors ;
}

static void free_ldvimg_context(LDV_IMAGE* ldv_img)
{
  INFO_IMAGE* inf = (INFO_IMAGE*) ldv_img->Context ;

  if ( inf )
  {
    release_informations( inf ) ;    
    Xfree( inf ) ;
    ldv_img->Context = NULL ;
  }
}

void cdecl ImFree(void* v)
{
  LDV_IMAGE*  ldv_img = (LDV_IMAGE*) v ;
  INFO_IMAGE* inf = (INFO_IMAGE*) ldv_img->Context ;

  if ( inf )
  {
    if ( ldv_img->Palette.Pal == inf->palette ) ldv_img->Palette.Pal = NULL ;
    free_info( inf ) ;
    free_ldvimg_context( ldv_img ) ;
  }
}

long cdecl ImLoad(void* v)
{
  LDV_IMAGE*  ldv_img = (LDV_IMAGE*) v ;
  INFO_IMAGE* inf = (INFO_IMAGE*) ldv_img->Context ;
  int         old_stdvdi = UseStdVDI ;
  int         err ;

  if ( inf == NULL ) return EIMG_DATAINCONSISTENT ;

  inf->prog = LdvProg ;
  if ( ldv_img->Raster.fd_nplanes == 32 ) inf->mfdb.fd_nplanes = 32 ; /* We may have forced it in ImGetInf because a LDV will most likely handle 32bit but not 24bit images */
  else                                    inf->mfdb.fd_nplanes = -1 ; /* We want the original number of planes, no dithering */
  UseStdVDI = (ldv_img->RasterFormat == LDVF_ATARIFORMAT) ? 0:1 ;
  err       = load_picture( inf ) ;
  UseStdVDI = old_stdvdi ;

  if ( err )
  {
    if ( err == EIMG_USERCANCELLED )
    {
      LoggingDo(LL_INFO, "ImLoad: user cancelled" ) ;
      LDVDestroyProgWindow() ;
    }
    ImFree( ldv_img ) ;
    memzero( ldv_img, sizeof(LDV_IMAGE) ) ;
  }
  else
  {
    /* Update information to raster */
    CopyMFDB( &ldv_img->Raster, &inf->mfdb ) ;
  }

  return ImErr( "ImLoad", err ) ;
}

long cdecl ImSave(char* filename, void* v, char* save_options)
{
  LDV_IMAGE*  ldv_img = (LDV_IMAGE*) v ;
  INFO_IMAGE* inf = (INFO_IMAGE*) ldv_img->Context ;
  char        local_save_options[128] ;
  char*       fmt_opt ;
  int         err, old_std_vdi = UseStdVDI ;

  fmt_opt = strstr( save_options, "fmt=" ) ;
  if ( fmt_opt )
  {
    char  fake_filename[32] ;
    char* ext = fmt_opt + 4 ; /* Right after 'fmt=' */
    char* c = strchr( ext, ';' ) ;

    if ( c ) *c = 0 ;
    sprintf( fake_filename, "fk.%s", ext ) ;             /* Build a fake file name for DImgGetIIDFromFile to detect */
    inf->lformat = DImgGetIIDFromFile( fake_filename ) ; /* File format based of the fmt value in save options      */
    LoggingDo(LL_INFO, "ImSave: save options %s, IID=%lX", save_options, inf->lformat ) ;
    if ( c ) *c = ';' ;
  }
  if ( inf->lformat == IID_UNKNOWN ) inf->lformat = DImgGetIIDFromFile( filename ) ;
  strcpy( inf->filename, filename ) ;
  /* Replace all ';' by \0 as imagelib expects each option to be a string */
  strcpy( local_save_options, save_options ) ;
  strrep( local_save_options, ';', 0 ) ;
  inf->save_options = local_save_options ;
  if ( ldv_img->RasterFormat == LDVF_ATARIFORMAT ) UseStdVDI = 0 ;
  err = save_picture( filename, &inf->mfdb, inf, NULL ) ;
  UseStdVDI = old_std_vdi ;

  return ImErr( "ImSave", err ) ;
}

long cdecl ImDither(long method, long param, void* v_in, void* v_out)
{
  LDV_IMAGE*  ldv_img_in = (LDV_IMAGE*) v_in ;
  LDV_IMAGE*  ldv_img_out = (LDV_IMAGE*) v_out ;
  INFO_IMAGE  inf_in ;
  INFO_IMAGE* inf_out = Xcalloc( 1, sizeof(INFO_IMAGE) ) ; /* Dynamic as caller will have to call ImFree which frees INFO_IMAGE */
  int         err ;

  if ( inf_out == NULL ) return EIMG_NOMEMORY ;

  LDVImg2INF( ldv_img_in, &inf_in ) ;
  LDVImg2INF( ldv_img_out, inf_out ) ;
  inf_in.dither_method = (char) method ;
  inf_in.dither_param  = (short) param ;
  err                  = dither( (int)method | 0x80, &inf_in, inf_out, NULL ) ; /* Set bit#7 of method to force memory allocation */
  if ( err == EIMG_SUCCESS ) INF2LDVImg( inf_out, ldv_img_out ) ;
  else                       Xfree( inf_out ) ;

  return ImErr( "ImDither", err ) ;
}

long cdecl ImGetStdData(void* v, char* query, char* out_data, long out_data_size)
{
  LDV_IMAGE*  ldv_img = (LDV_IMAGE*) v ;
  INFO_IMAGE* inf = (INFO_IMAGE*) ldv_img->Context ;
  int         err ;

  if ( inf == NULL ) return ELDV_INVALIDPARAMETER ;

  err = img_getstddata( inf, query, out_data, out_data_size ) ;

  return ImErr( "ImGetStdData", err ) ;
}

long cdecl ImComputeHistogram(void* v, HISTO *histo)
{
  LDV_IMAGE* ldv_img = (LDV_IMAGE*) v ;
  INFO_IMAGE inf ;
  int        err ;

  LDVImg2INF( ldv_img, &inf ) ;
  err = compute_histo( &inf, histo, NULL, (ldv_img->RasterFormat == LDVF_ATARIFORMAT) ? 0:1 ) ;

  return ImErr( "ImComputeHistogram", err ) ;
}

long cdecl FiFileExist(char* file)
{
  return (long)FileExist( file ) ;
}

long cdecl FiFolderExist(char* folder)
{
  return (long)FolderExist( folder ) ;
}

long cdecl FiCopyFile(char* src, char* dst)
{
  return (long)CopyFile( src, dst ) ;
}

long cdecl FiCopyFileR(char* src, char* dst)
{
  return (long)CopyFileR( src, dst ) ;
}

long cdecl FiMoveFile(char* src, char* dst)
{
  return (long)MoveFile( src, dst ) ;
}

long cdecl FiCreateFolder(char* path)
{
  return (long)CreateFolder( path ) ;
}

long cdecl FiCmpFiles(char* f1, char* f2)
{
  return (long)CmpFiles( f1, f2 ) ;
}

static void LDVInitVAPI(void)
{
  if ( Vapi ) return ;

  Vapi = (VAPI*) Xcalloc( 1, sizeof(VAPI) ) ;
  if ( Vapi == NULL ) return ;

  Vapi->Header.Version = VAPI_LDVVERSION ;
  Vapi->Header.StrSize = sizeof(VAPI) ;
  LoggingDo(LL_INFO, "VAPI Version:       %02x.%02x", Vapi->Header.Version >> 8, Vapi->Header.Version & 0xFF) ;
  LoggingDo(LL_INFO, "VAPI interface size:%d bytes", Vapi->Header.StrSize) ;
  Vapi->Header.Global         = _GemParBlk.global ;
  Vapi->Header.GEMMessageLoop = GEMMessageLoop ;

  /* Progress Interface */
  Vapi->PrSetProg      = PrSetProg ;
  Vapi->PrOptimize     = PrOptimize ;
  Vapi->PrSetText      = PrSetText ;
  Vapi->PrSetProgEx    = PrSetProgEx ;
  Vapi->PrSetProgRange = PrSetProgRange ;

  /* Raster Interface */
  Vapi->RaImgWhite     = RaImgWhite ;

  Vapi->RaIs15Bits     = RaIs15Bits ;
  Vapi->RaTCInvConvert = RaTCInvConvert ;
  Vapi->RaTCConvert    = RaTCConvert ;

  Vapi->RaInd2RasterInit = RaInd2RasterInit ;
  Vapi->RaInd2Raster     = RaInd2Raster ;
  Vapi->RaRaster2Ind     = RaRaster2Ind ;

  Vapi->RaGetTOS2VDIArray = RaGetTOS2VDIArray ;
  Vapi->RaGetVDI2TOSArray = RaGetVDI2TOSArray ;
  
  Vapi->RaGetImgSize  = RaGetImgSize ;
  Vapi->RaRasterAlloc = RaRasterAlloc ;
  Vapi->RaRasterFree  = RaRasterFree ;

  Vapi->RaTC15RemapColors = RaTC15RemapColors ;
  Vapi->RaTC16RemapColors = RaTC16RemapColors ;
  Vapi->RaTC32RemapColors = RaTC32RemapColors ;

  Vapi->RaRasterRotateGetDstMFDB = RaRasterRotateGetDstMFDB ;
  Vapi->RaRasterRotate           = RaRasterRotate ;

  /* Config Interface */
  Vapi->CoGetLDVPath               = CoGetLDVPath ;
  Vapi->CoGetCurrentLanguage       = CoGetCurrentLanguage ;
  Vapi->CoGetFunctionOptimizations = CoGetFunctionOptimizations ;
  Vapi->CoGetProcessors            = CoGetProcessors ;
  Vapi->CoGetScreenInfo            = CoGetScreenInfo ;

  /* INI Interface */
  Vapi->InOpen           = InOpen ;
  Vapi->InClose          = InClose ;
  Vapi->InSaveAndClose   = InSaveAndClose ;
  Vapi->InGetKey         = InGetKey ;
  Vapi->InSetKey         = InSetKey ;
  Vapi->InGetOrSetKey    = InGetOrSetKey ;
  Vapi->InGetKeyFromFile = InGetKeyFromFile ;

  /* MEM Interface */      
  if ( MachineInfo.cpu >= 30L )
  {
    Vapi->MeSCopyMemory8  = Me030SCopyMemory8 ;
    Vapi->MeSCopyMemory16 = Me030SCopyMemory16 ;
    Vapi->MeSCopyMemory32 = Me030SCopyMemory32 ;
  }
  else
  {
    Vapi->MeSCopyMemory8  = MeSCopyMemory8 ;
    Vapi->MeSCopyMemory16 = MeSCopyMemory16 ;
    Vapi->MeSCopyMemory32 = MeSCopyMemory32 ;
  }
  Vapi->MeXalloc   = MeXalloc ;
  Vapi->MeXrealloc = MeXrealloc ;
  Vapi->MeXfree    = MeXfree ; ;
  Vapi->MeXcalloc  = MeXcalloc ;
  Vapi->MeXstrdup  = MeXstrdup ;
  
  /* Logging Interface */      
  Vapi->LoDoLog       = LoDoLog ;
  Vapi->LoGetLogLevel = LoGetLogLevel ;

  /* Image I/O interface */
  Vapi->ImGetInf           = ImGetInf ;
  Vapi->ImLoad             = ImLoad ;
  Vapi->ImFree             = ImFree ;
  Vapi->ImSave             = ImSave ;
  Vapi->ImDither           = ImDither ;
  Vapi->ImGetStdData       = ImGetStdData ;
  Vapi->ImComputeHistogram = ImComputeHistogram ;

  /* File interface */
  Vapi->FiFileExist    = FiFileExist ;
  Vapi->FiFolderExist  = FiFolderExist ;
  Vapi->FiCopyFile     = FiCopyFile ;
  Vapi->FiCopyFileR    = FiCopyFileR ;
  Vapi->FiMoveFile     = FiMoveFile ;
  Vapi->FiCreateFolder = FiCreateFolder ;
  Vapi->FiCmpFiles     = FiCmpFiles ;
}

LDV_STATUS LDVLoadFunctions(char* path, LDV_MODULE* mod)
{
  char filename[PATH_MAX] ;

  /* Make sure VAPI is ready to propose its service */
  LDVInitVAPI() ;
  sprintf( filename, "%s\\%s", path, mod->FileName ) ;
  return( LDVInit( filename, mod, 0 ) ) ;
}

LDV_CAPS* LDVGetNPlanesCaps(LDV_MODULE* mod, int nplanes)
{
  LDV_CAPS* caps ;

  caps = &mod->Infos.Caps[0] ;
  while ( caps->NbPlanes )
  {
    if ( caps->NbPlanes == nplanes ) break ;
    else                             caps++ ;
  }

  if ( caps->NbPlanes == 0 ) caps = NULL ;

  return caps ;
}

short add_ldv(FR_CDATA* fr_cdata)
{
  /* Should always be true */
  if ( NumModule < NbModules )
    if ( LDVInit( fr_cdata->filename, &Modules[NumModule], 1 ) == 0 ) NumModule++ ;

  return 0 ;
}

LDV_MODULE* LDVGetModuleList(char* path, int* nb_ldv)
{
  FR_DATA fr_data ;

  memzero( &fr_data, sizeof(fr_data) ) ;
  fr_data.path       = path ;
  fr_data.mask       = "*.LDV" ;
/*
  fr_data.flags      = 0 ; Better not use long filenames here, old OSes would report no files 
  fr_data.log_file   = NULL ;
  fr_data.user_func  = NULL ;
  fr_data.user_data  = NULL ;
*/
  Modules   = NULL ;
  NbModules = (int) count_files( 0, &fr_data ) ;
  if ( NbModules > 0 )
  {
    LDVInitVAPI() ;

    /* Last module (not valid) will be zeroed */
    NumModule = 0 ;
    Modules = (LDV_MODULE*) Xcalloc( 1+NbModules, sizeof(LDV_MODULE) ) ;
    fr_data.path       = path ;
    fr_data.mask       = "*.LDV" ;
    fr_data.user_func  = add_ldv ;
/*    fr_data.flags      = 0 ;
    fr_data.log_file   = NULL ;
    fr_data.user_data  = NULL ;*/
    if ( Modules ) find_files( &fr_data ) ;
    else           NbModules = 0 ;
  }

  if ( nb_ldv ) *nb_ldv = NbModules ;

  return Modules ;
}

void LDVFreeModuleList(LDV_MODULE* module_list)
{
  if ( module_list )
  {
    LDV_MODULE* mod ;
    int         i ;

    mod = module_list ;
    for ( i = 0; i < NbModules; i++, mod++ )
    {
      LDVFreeParameters( mod ) ;
      if ( mod->IniSpec.ShortName ) Xfree( mod->IniSpec.ShortName ) ;
      if ( mod->FileName ) Xfree( mod->FileName ) ;
      if ( mod->Ldg ) LDVUnloadFunctions( mod ) ;
    }
    Xfree( module_list ) ;
  }

  if ( Vapi ) Xfree( Vapi ) ;
  Vapi = NULL ;
}

LDV_MODULE* GetLdvByLdg(LDV_MODULE* ldv_list, LDG* ldg)
{
  LDV_MODULE* ldv_module = NULL ;
  LDV_MODULE* cldv = ldv_list ;

  if ( ldv_list )
  {
    while ( cldv->Ldg && (ldv_module == NULL) )
    {
      if ( cldv->Ldg == ldg ) ldv_module = cldv ;
      else                    cldv++ ;
    }
  }

  return ldv_module ;
}

LDV_STATUS LDVAlloc(LDV_IMAGE* img)
{
  LDV_STATUS err = ELDV_NOERROR ;

  if ( img->Raster.fd_w && img->Raster.fd_h )
  {
    img->Raster.fd_addr = img_alloc( img->Raster.fd_w, img->Raster.fd_h,img->Raster.fd_nplanes ) ;
    if ( img->Raster.fd_addr == NULL ) err = ELDV_NOTENOUGHMEMORY ;
    else                               img->Raster.fd_wdwidth = w2wdwidth( img->Raster.fd_w ) ;
  }

  if ( img->Palette.NbColors > 0 )
  {
    img->Palette.Pal = Xcalloc( img->Palette.NbColors, sizeof(VDI_ELEMENTPAL) ) ;
    if ( img->Palette.Pal == NULL ) err = ELDV_NOTENOUGHMEMORY ;
  }

  return err ;
}

static int GetBestImgFormat(LDV_CAPS* caps)
{
  long img_fmt ;

  switch( caps->NbPlanes )
  {
    case 1   :
    case 2   :
    case 4   :
    case 8   : if ( caps->Flags & LDVF_SPECFORMAT )       img_fmt = LDVF_SPECFORMAT ;
               else if ( caps->Flags & LDVF_STDFORMAT )   img_fmt = LDVF_STDFORMAT ;
               else                                       img_fmt = LDVF_ATARIFORMAT ;
               break ;

    case 16  :
    case 24  :
    case 32  : if ( caps->Flags & LDVF_SPECFORMAT )       img_fmt = LDVF_SPECFORMAT ;
               else                                       img_fmt = LDVF_ATARIFORMAT ;
               break ;

    default  : img_fmt = (int)LDVF_SPECFORMAT ;
               break ;
  }

  return (int)img_fmt ;
}

static LDV_STATUS FormatLdvImgFromSpec(LDV_IMAGE* ldv_img, int new_format)
{
  MFDB       std_img ;
  LDV_STATUS err = ELDV_NOERROR ;

  /* ldv_img->raster doit valoir LDVF_SPECFORMAT */
  if ( ldv_img->RasterFormat != LDVF_SPECFORMAT ) return ELDV_GENERALFAILURE ;

  if ( ldv_img->RasterFormat != new_format )
  {
    switch( new_format )
    {
      case LDVF_STDFORMAT   : if ( ldv_img->Raster.fd_nplanes <= 8 )
                              {
                                CopyMFDB( &std_img, &ldv_img->Raster ) ;
                                std_img.fd_addr = img_alloc( std_img.fd_w, std_img.fd_h, std_img.fd_nplanes ) ;
                                if ( std_img.fd_addr == NULL ) err = ELDV_NOTENOUGHMEMORY ;
                                if ( LDV_SUCCESS( err ) )
                                {
                                  std_img.fd_stand = 1 ;
                                  vr_trnfm( handle, &ldv_img->Raster, &std_img ) ;
                                  Xfree( ldv_img->Raster.fd_addr ) ;
                                  CopyMFDB( &ldv_img->Raster, &std_img ) ;
                                }
                              }
                              else
                                err = ELDV_GENERALFAILURE ;
                              break ;

      case LDVF_ATARIFORMAT : if ( ldv_img->Raster.fd_nplanes <= 8 )
                              {
                                if ( MakeMFDBClassicAtari( &ldv_img->Raster, NULL ) != 0 )
                                  err = ELDV_NOTENOUGHMEMORY ;
                              }
                              else if ( UseStdVDI ) tc_invconvert( &ldv_img->Raster ) ;
                              break ;

      default               : err = ELDV_GENERALFAILURE ;
                              break ;
    }
    if ( LDV_SUCCESS( err ) ) ldv_img->RasterFormat = (short)new_format ;
  }

  return err ;
}

static LDV_STATUS FormatLdvImgFromAtariC(LDV_IMAGE* ldv_img, int new_format)
{
  LDV_STATUS err = ELDV_NOERROR ;

  /* ldv_img->raster doit valoir LDVF_ATARIFORMAT */
  if ( ldv_img->RasterFormat != LDVF_ATARIFORMAT ) return ELDV_GENERALFAILURE ;

  if ( ldv_img->RasterFormat != new_format )
  {
    switch( new_format )
    {
      case LDVF_STDFORMAT : if ( ldv_img->Raster.fd_nplanes <= 8 )
                            {
                              MFDB std_img ;

                              CopyMFDB( &std_img, &ldv_img->Raster ) ;
                              std_img.fd_stand = 1 ;
                              std_img.fd_addr  = img_alloc( std_img.fd_w, std_img.fd_h, std_img.fd_nplanes ) ;
                              if ( std_img.fd_addr == NULL ) err = ELDV_NOTENOUGHMEMORY ;
                              else
                              {
                                ClassicAtari2StdVDI( &ldv_img->Raster, &std_img ) ;
                                Xfree( ldv_img->Raster.fd_addr ) ;
                                CopyMFDB( &ldv_img->Raster, &std_img ) ;
                              }
                            }
                            break ;

      case LDVF_SPECFORMAT: if ( UseStdVDI )
                            {
                              if ( ldv_img->Raster.fd_nplanes <= 8 )
                              {
                                if ( MakeMFDBSpec( &ldv_img->Raster, NULL ) != 0 )
                                  err = ELDV_NOTENOUGHMEMORY ;
                              }
                              else tc_convert( &ldv_img->Raster ) ;
                            }
                            break ;

    case LDVF_ATARIFORMAT : err = ELDV_NOERROR ;
                            break ;

      default             : err = ELDV_GENERALFAILURE ;
                            break ;
    }
    if ( LDV_SUCCESS( err ) ) ldv_img->RasterFormat = (short)new_format ;
  }

  return err ;
}

static LDV_STATUS FormatLdvImgToSpec(LDV_IMAGE* ldv_img)
{
  MFDB       img ;
  LDV_STATUS err = ELDV_NOERROR ;

  switch( ldv_img->RasterFormat )
  {
    case LDVF_SPECFORMAT  : err = ELDV_NOERROR ;
                            break ;

    case LDVF_STDFORMAT   : if ( ldv_img->Raster.fd_nplanes <= 8 )
                            {
                              CopyMFDB( &img, &ldv_img->Raster ) ;
                              img.fd_addr = img_alloc( img.fd_w, img.fd_h, img.fd_nplanes ) ;
                              if ( img.fd_addr == NULL ) err = ELDV_NOTENOUGHMEMORY ;
                              if ( LDV_SUCCESS( err ) )
                              {
                                img.fd_stand = 0 ;
                                vr_trnfm( handle, &ldv_img->Raster, &img ) ;
                                Xfree( ldv_img->Raster.fd_addr ) ;
                                CopyMFDB( &ldv_img->Raster, &img ) ;
                              }
                            }
                            else err = ELDV_GENERALFAILURE ;
                            break ;

    case LDVF_ATARIFORMAT : if ( UseStdVDI )
                            {
                              if ( ldv_img->Raster.fd_nplanes == screen.fd_nplanes )
                              {
                                /* Here we are hitting several problems: */
                                /* 1. UseStdVDI applies to current number of planes, but could be different on */
                                /*    a different number of planes from image, for instance:                   */
                                /*    Aranym,  TC32, UseStdVDI=1 but in 256c: StdVDI=0                         */
                                /*    MagicPC, TC32, UseStdVDI=1     in 256c: StdVDI=1                         */
                                /* 2. vr_trnfm may work for a raster in same number of planes as current       */
                                /*    resolution but does nothing on a different number of planes, e.g.:       */
                                /*   Aranym TC32 resolution, 8plane raster                                     */
                                /* So following code may be very wrong, better return success and keep         */
                                /* current raster format, caller will then call LDVAdapt2Planes to fix that    */
                                if ( ldv_img->Raster.fd_nplanes <= 8 )
                                {
                                  CopyMFDB( &img, &ldv_img->Raster ) ;
                                  img.fd_addr = img_alloc( img.fd_w, img.fd_h, img.fd_nplanes ) ;
                                  if ( img.fd_addr )
                                  {
                                    img.fd_stand = 1 ;
                                    ClassicAtari2StdVDI( &ldv_img->Raster, &img ) ;
                                    ldv_img->Raster.fd_stand = 0 ;
                                    LoggingDo(LL_DEBUG,"FormatLdvImgToSpec: vr_trnfm %d planes", img.fd_nplanes);
                                    vr_trnfm( handle, &img, &ldv_img->Raster ) ;
                                    Xfree( img.fd_addr ) ;
                                  }
                                  else err = ELDV_NOTENOUGHMEMORY ;
                                }
                                else tc_convert( &ldv_img->Raster ) ;
                              }
                              else return ELDV_NOERROR ;
                            }
                            break ;

    default               : err = ELDV_GENERALFAILURE ;
                            break ;
  }

  if ( LDV_SUCCESS( err ) ) ldv_img->RasterFormat = (int)LDVF_SPECFORMAT ;

  return err ;
}

static LDV_STATUS FormatLdvImgToAtariC(LDV_IMAGE* ldv_img)
{
  LDV_STATUS err = ELDV_NOERROR ;

  switch( ldv_img->RasterFormat )
  {
    case LDVF_SPECFORMAT  : if ( UseStdVDI )
                            {
                              if ( ldv_img->Raster.fd_nplanes <= 8 )
                              {
                                if ( MakeMFDBClassicAtari( &ldv_img->Raster, NULL ) != 0 )
                                  err = ELDV_NOTENOUGHMEMORY ;
                              }
                              else tc_invconvert( &ldv_img->Raster ) ;
                            }
                            break ;

    case LDVF_STDFORMAT   : if ( ldv_img->Raster.fd_nplanes <= 8 )
                            {
                              MFDB img ;

                              CopyMFDB( &img, &ldv_img->Raster ) ;
                              img.fd_addr = img_alloc( img.fd_w, img.fd_h, img.fd_nplanes ) ;
                              if ( img.fd_addr == NULL ) err = ELDV_NOTENOUGHMEMORY ;
                              if ( LDV_SUCCESS( err ) )
                              {
                                StdVDI2ClassicAtari( &ldv_img->Raster, &img ) ;
                                img.fd_stand = 0 ;
                                Xfree( ldv_img->Raster.fd_addr ) ;
                                CopyMFDB( &ldv_img->Raster, &img ) ;
                              }
                            }
                            break ;

    case LDVF_ATARIFORMAT : err = ELDV_NOERROR ;
                            break ;

    default               : err = ELDV_GENERALFAILURE ;
                            break ;
  }

  if ( LDV_SUCCESS( err ) ) ldv_img->RasterFormat = (int)LDVF_SPECFORMAT ;

  return err ;
}

static LDV_STATUS BuildLdvImgForLDV(LDV_IMAGE* ldv_img, int new_format)
{
  LDV_STATUS err ;

  switch ( ldv_img->RasterFormat )
  {
    case LDVF_SPECFORMAT:  err = FormatLdvImgFromSpec( ldv_img, new_format ) ;
                           break ;

    case LDVF_ATARIFORMAT: err = FormatLdvImgFromAtariC( ldv_img, new_format ) ;
                           break ;

    default:               err = ELDV_GENERALFAILURE ;
                           break ;
  }

  return err ;
}

static LDV_STATUS BuildLdvImgFromLDV(LDV_IMAGE* ldv_img, int new_format)
{
  LDV_STATUS err ;

  if ( ldv_img->Raster.fd_addr == NULL ) return ELDV_NOTENOUGHMEMORY ;

  switch ( new_format )
  {
    case LDVF_SPECFORMAT:  err = FormatLdvImgToSpec( ldv_img ) ;
                           break ;

    case LDVF_ATARIFORMAT: err = FormatLdvImgToAtariC( ldv_img ) ;
                           break ;

    default:               err = ELDV_GENERALFAILURE ;
                           break ;
  }

  return err ;
}

LDV_STATUS LDVAdapt2Planes(LDV_IMAGE* pldv_img, short nplanes)
{
  LDV_STATUS err = ELDV_NOERROR ;

  LoggingDo(LL_DEBUG, "LDVAdapt2Planes: format %d, %d-->%d planes", pldv_img->RasterFormat, pldv_img->Raster.fd_nplanes, nplanes) ;
  if ( pldv_img->Raster.fd_nplanes != nplanes )
  {
    INFO_IMAGE inf ;

    memzero( &inf, sizeof(INFO_IMAGE) ) ;
    CopyMFDB( &inf.mfdb, &pldv_img->Raster ) ;
    inf.nplanes = inf.mfdb.fd_nplanes ;
    inf.palette = pldv_img->Palette.Pal ;
    inf.nb_cpal = pldv_img->Palette.NbColors ;
    if ( pldv_img->RasterFormat == LDVF_SPECFORMAT )
    {
      if ( inf.mfdb.fd_nplanes > 8 ) tc_invconvert( &inf.mfdb ) ;
      else if ( MakeMFDBClassicAtari( &inf.mfdb, NULL ) ) return EIMG_NOMEMORY ;
    }
    /* fit_to_planes assumes AtariClassic format */
    if ( fit_to_planes( &inf, nplanes, NULL ) == EIMG_SUCCESS )
    {
      /* Returns MFDB in Classic Atari format unless cancel_stdvdi != 0 */
      if ( !inf.cancel_stdvdi )
      {
        LoggingDo(LL_DEBUG,"LDVAdapt2Planes: use STDVDI");
        if ( inf.mfdb.fd_nplanes > 8 ) tc_convert( &inf.mfdb ) ;
        else if ( MakeMFDBSpec( &inf.mfdb, NULL ) ) return EIMG_NOMEMORY ;
      }
      CopyMFDB( &pldv_img->Raster, &inf.mfdb ) ;
    }
    else
    {
      err = ELDV_NOTENOUGHMEMORY ;
      LoggingDo(LL_WARNING, "LDVAdapt2Planes: can't change from %d planes to %d", pldv_img->Raster.fd_nplanes, nplanes) ;
    }
  }

  return err ;
}

GEM_WINDOW* LDVGetProgWindow(void)
{
  return LdvProg ;
}

GEM_WINDOW* LDVCreateProgWindow(int ldv_capflags)
{
  if ( (ldv_capflags & LDVF_SUPPORTPROG) && (LdvProg == NULL) )
  {
    int nflags ; 

    if ( ldv_capflags & LDVF_SUPPORTCANCEL ) nflags = 0 ;
    else                                     nflags = CLOSER ; /* No cancel possible by default */
    LdvProg = DisplayStdProg( "", "", "", nflags ) ;
  }

  return LdvProg ;
}

void LDVDestroyProgWindow(void)
{
  if ( LdvProg ) GWDestroyWindow( LdvProg ) ;
  LdvProg = NULL ;
}

LDV_STATUS LDVDo(LDV_MODULE* ldv, LDV_PARAMS* pldv_params, LDV_IMAGE* pldv_img, int flags)
{
  LDV_PARAMS    ldv_params ;
  LDV_CAPS*     caps ;
  ILDVModifImg* IModifImg = ldv->IModifImg ;
  LDV_IMAGE*    ldv_img, img_sel, out ;
  LDV_STATUS    err ;
  int           img_format_src, img_format_ldv ;

  if ( IModifImg == NULL ) return ELDV_BADINTERFACE ;

  ldv_img        = pldv_img ;
  img_format_src = ldv_img->RasterFormat ;
  memcpy( &ldv_params, pldv_params, sizeof(LDV_PARAMS) ) ;
  caps = LDVGetNPlanesCaps( ldv, ldv_img->Raster.fd_nplanes ) ;
  if ( caps == NULL ) return ELDV_NBPLANESNOTSUPPORTED ;

  if ( ( (ldv_params.x1 != 0) || (ldv_params.y1 != 0) ||
         (ldv_params.x2 != ldv_img->Raster.fd_w -1) || (ldv_params.y2 != ldv_img->Raster.fd_h -1)
       ) && (caps->Flags & LDVF_NOSELECTION)
     )
  {
    int xy[8] ;

    LoggingDo(LL_INFO, "Need to duplicate selection (%d,%d,%d,%d) from (0,0,%d,%d)", ldv_params.x1, ldv_params.y1, ldv_params.x2, ldv_params.y2, ldv_img->Raster.fd_w -1, ldv_img->Raster.fd_h -1 ) ;
    /* Dupliquer la selection, le LDV ne peut pas travailler sur une partie d'image */
    memcpy( &img_sel, ldv_img, sizeof(LDV_IMAGE) ) ;
    img_sel.Raster.fd_w = 1 + ldv_params.x2 - ldv_params.x1 ;
    img_sel.Raster.fd_h = 1 + ldv_params.y2 - ldv_params.y1 ;
    RaRasterAlloc( &img_sel.Raster ) ;
    if ( img_sel.Raster.fd_addr == NULL ) return ELDV_NOTENOUGHMEMORY ;
    xy[0] = ldv_params.x1 ; xy[1] = ldv_params.y1 ;
    xy[2] = ldv_params.x2 ; xy[3] = ldv_params.y2 ;
    xy[4] = xy[5] = 0 ;
    xy[6] = img_sel.Raster.fd_w - 1 ;
    xy[7] = img_sel.Raster.fd_h - 1 ;
    vro_cpyfm( handle, S_ONLY, xy, &ldv_img->Raster, &img_sel.Raster ) ;
    ldv_img = &img_sel ;
    ldv_params.x1 = ldv_params.y1 = 0 ;
    ldv_params.x2 = img_sel.Raster.fd_w - 1 ;
    ldv_params.y2 = img_sel.Raster.fd_h - 1 ;
  }
  else memzero( &img_sel, sizeof(LDV_IMAGE) ) ;

  img_format_ldv = GetBestImgFormat( caps ) ;
  LoggingDo(LL_INFO, "Original format: %d, to provide to LDV: %d", img_format_src, img_format_ldv) ;
  err = BuildLdvImgForLDV( ldv_img, img_format_ldv ) ;
  if ( !LDV_SUCCESS( err ) ) return err ;

  memzero( &out, sizeof(LDV_IMAGE) ) ;
  out.Raster.fd_nplanes = caps->NbPlanesOut ;
  out.RasterFormat      = img_format_ldv ;

  if ( IModifImg->PreRun ) err = IModifImg->PreRun( ldv_img, &ldv_params, &out ) ;
  if ( LDV_SUCCESS( err ) )
  {
    if ( caps->Flags & LDVF_OPINPLACE )
    {
      memcpy( &out, ldv_img, sizeof(LDV_IMAGE) ) ;
      out.Raster.fd_nplanes = caps->NbPlanesOut ;
      out.Palette.Pal       = NULL ; /* Don't reference the current palette for output; LDV will allocate */
    }
    else
    {
      err = LDVAlloc( &out ) ;
      if ( !LDV_SUCCESS( err ) ) RaRasterFree( &img_sel.Raster ) ;
    }
  }

  if ( LDV_SUCCESS( err ) )
  {
    clock_t t0 = clock() ;

    if ( flags & LDVDOF_PREVIEW )
    {
      if ( IModifImg->Preview ) err = IModifImg->Preview( ldv_img, &ldv_params, &out ) ;
      else                      err = ELDV_PREVIEWNOTSUPPORTED ;
    }
    else
    {
      if ( IModifImg->Run )
      {
        LDVCreateProgWindow( caps->Flags ) ;
        if ( LdvProg )
        {
          char buf[128] ;

          sprintf( buf, "%s...", ldv->FileName ) ;
          GWSetWindowCaption( LdvProg, buf ) ;
        }
        err = IModifImg->Run( ldv_img, &ldv_params, &out ) ;
        if ( LdvProg && ((flags & LDVDOF_PROGLFOUT) == 0) ) LDVDestroyProgWindow() ;
      }
      else err = ELDV_RUNNOTSUPPORTED ;
    }
    LoggingDo(LL_PERF, "LDV %s took %ldms, returned %ld", (flags & LDVDOF_PREVIEW) ? "Preview":"Run", (1000L * (clock()-t0))/CLK_TCK, err) ;

    if ( (caps->Flags & LDVF_AFFECTPALETTE) && (out.Palette.Pal == NULL) )
    {
      /* LDV changed palette but most likely 'inplace' */
      /* Let's copy the palette from ldv_img           */
      memcpy( &out.Palette, &ldv_img->Palette, sizeof(LDV_PALETTE) ) ;
    }

    if ( !LDV_SUCCESS( err ) )
    {
      /* Restore back original number of planes as LDV failed to perform */
      /* Its job else transform back would be incorrect as working on a  */
      /* Wrong number of planes                                          */
      out.Raster.fd_nplanes = pldv_img->Raster.fd_nplanes ;
    }

    /* Note that even if LDV returned an error, we need to restore image back */
    /* So call BuildLdvImgFromLDV first                                       */
    if ( LDV_SUCCESS( BuildLdvImgFromLDV( &out, img_format_src ) ) && LDV_SUCCESS( err ) )
    {
      if ( img_sel.Raster.fd_addr )
      {
        int xy[8] ;
        int xs0, ys0, xd0, yd0, ws, hs, wd, hd, w, h ;
        int mode = S_ONLY ;

        if ( mode_vswr == MD_TRANS )      mode = S_OR_D ;
        else if ( mode_vswr == MD_XOR )   mode = S_XOR_D ;
        else if ( mode_vswr == MD_ERASE ) mode = NOTS_AND_D ;
        /* Replacer la selection dupliquee */
        /* Centrer le resultat sur le centre du bloc d'origine */
        wd = 1 + pldv_params->x2 - pldv_params->x1 ;
        hd = 1 + pldv_params->y2 - pldv_params->y1 ;
        ws = out.Raster.fd_w ;
        hs = out.Raster.fd_h ;
        if ( ws > wd )
        {
          w   = wd ;
          xs0 = ( ws - w ) >> 1 ;
          xd0 = 0 ; 
        }
        else
        {
          w   = ws ;
          xs0 = 0 ;
          xd0 = ( wd - w ) >> 1 ;
        }
        if ( hs > hd )
        {
          h   = hd ;
          ys0 = ( hs - h ) >> 1 ;
          yd0 = 0 ; 
        }
        else
        {
          h   = hs ;
          ys0 = 0 ;
          yd0 = ( hd - h ) >> 1 ;
        }

        xy[0] = xs0 ;
        xy[1] = ys0 ;
        xy[2] = xy[0] + w - 1 ;
        xy[3] = xy[1] + h - 1 ;
        xy[4] = pldv_params->x1 + xd0 ;
        xy[5] = pldv_params->y1 + yd0 ;
        xy[6] = xy[4] + w - 1 ;
        xy[7] = xy[5] + h - 1 ;
        vro_cpyfm( handle, mode, xy, &out.Raster, &pldv_img->Raster ) ;
        RaRasterFree( &img_sel.Raster ) ;
        if ( (caps->Flags & LDVF_OPINPLACE) == 0 ) Xfree( out.Raster.fd_addr ) ;
      }
      else
      {
        if ( (caps->Flags & LDVF_OPINPLACE) == 0 ) Xfree( ldv_img->Raster.fd_addr ) ;
        CopyMFDB( &ldv_img->Raster, &out.Raster ) ;
      }
      if ( pldv_img->Palette.Pal ) Xfree( pldv_img->Palette.Pal ) ;
      if ( pldv_img->Palette.Pal == out.Palette.Pal ) out.Palette.Pal = NULL ;
      if ( pldv_img->Context != out.Context ) free_ldvimg_context( pldv_img ) ;
      memcpy( &pldv_img->Palette, &out.Palette, sizeof(LDV_PALETTE) ) ;
      pldv_img->RasterFormat = out.RasterFormat ;
      pldv_img->Context      = out.Context ;
      free_ldvimg_context( pldv_img ) ;
    }
    else
    {
      if ( out.Raster.fd_addr && ((caps->Flags & LDVF_OPINPLACE) == 0) ) Xfree( out.Raster.fd_addr ) ;
      if ( out.Palette.Pal ) Xfree( out.Palette.Pal ) ;
    }
  }

  /* Run may have changed some LDV_PARAMS fields */
  memcpy( &pldv_params->Param[0], &ldv_params.Param[0], LDVNBMAX_PARAMETERS*sizeof(LDV_BASICPARAM) ) ;
  /* LDV may have returned free text to be displayed                      */
  /* Let's make sure we copy it back to the original LDV_PARAMS structure */
  memcpy( &pldv_params->ldv_txt_out, &ldv_params.ldv_txt_out, sizeof(ldv_params.ldv_txt_out) ) ;

  return err ;
}
