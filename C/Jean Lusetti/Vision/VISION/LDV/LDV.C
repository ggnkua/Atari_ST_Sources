#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "..\tools\scalemem.h"
#include "..\tools\gwindows.h"
#include "..\tools\rasterop.h"
#include "..\tools\frecurse.h"
#include "..\tools\xfile.h"
#include "..\tools\ini.h"

#include "actions.h"
#include "ldv\ldvcom.h"

static LDV_MODULE *Modules ;
static int        NbModules ;
static int        NumModule ;
static short      ListTypes[] = { TLDV_MODIFYIMG, TLDV_LOADIMG, TLDV_SAVEIMG } ;

#define VAPI_LDVVERSION 0x0103
static VAPI       *Vapi = NULL ;
static GEM_WINDOW *LdvProg = NULL ;


void cdecl PrSetText(long no_line, char *text)
{
  if ( LdvProg && ( no_line >= 0 ) && ( no_line <= 2 ) )
    StdProgWText( LdvProg, (int)no_line, text ) ;
}

void cdecl PrSetProg(long pc)
{
  if ( LdvProg ) LdvProg->ProgPc( LdvProg, (int)pc, NULL ) ;
}

long cdecl PrSetProgEx(long pc)
{
  long ret = 0 ;

  if ( LdvProg ) ret = LdvProg->ProgPc( LdvProg, (int)pc, NULL ) ;
  if ( ret != 0 ) LdvProg = NULL ;

  return( ret ) ;
}

void cdecl PrOptimize(long mask)
{
  if ( LdvProg )
  {
    StdProgDisplay030( LdvProg, (int)mask & 0x01 ) ;
    StdProgDisplayDSP( LdvProg, (int)mask & 0x02 ) ;
  }
}

void cdecl RaImgWhite(MFDB *img)
{
  img_raz( img ) ;
}

long cdecl RaIs15Bits(void)
{
  long is_15bits = 0 ;

  if ( nb_plane == 16 ) is_15bits = RVBOrg.Is15Bits ;

  return( is_15bits ) ;
}

void cdecl RaTCConvert(MFDB *img)
{
  tc_convert( img ) ;
}

void cdecl RaTCInvConvert(MFDB *img)
{
  tc_invconvert( img ) ;
}

void cdecl RaInd2RasterInit(MFDB *out, long width)
{
  int raz_done = 0 ;

  i2r_init( out, (short)width, raz_done ) ;
}

void cdecl RaInd2Raster(unsigned char *indexes, long nb_indexes)
{
  i2r_data = indexes ;
  i2r_nb   = nb_indexes ;
  ind2raster() ;
}

void cdecl RaRaster2Ind(short *pt_raster, long nb_pts, long nplans, unsigned char *out)
{
  raster2ind( (int*)pt_raster, out, nb_pts, (short)nplans ) ;
}

unsigned char * cdecl RaGetTOS2VDIArray(long nplanes)
{
  return( get_pttos2vdi( (short)nplanes ) ) ;
}

unsigned char * cdecl RaGetVDI2TOSArray(long nplanes)
{
  return( get_ptvdi2tos( (short)nplanes ) ) ;
}

unsigned long cdecl RaGetImgSize(long width, long height, long nplanes)
{
  return( (unsigned long) img_size( (int)width, (int)height, (int)nplanes ) ) ;
}

long cdecl RaRasterAlloc(MFDB *raster)
{
  size_t size ;

  size            = img_size( raster->fd_w, raster->fd_h, raster->fd_nplanes ) ;
  raster->fd_addr = malloc( size ) ;
  if ( raster->fd_addr )
  {
    raster->fd_wdwidth = raster->fd_w / 16 ;
    if ( raster->fd_w % 16 ) raster->fd_wdwidth++ ;

    return( 0 ) ;
  }

  return( -1 ) ; /* Erreur */
}

void cdecl RaRasterFree(MFDB *raster)
{
  if ( raster->fd_addr ) free( raster->fd_addr ) ;
  memset( raster, 0, sizeof(MFDB) ) ;
}

void cdecl RaTC15RemapColors(REMAP_COLORS *rc)
{
  TC15RemapColors( rc ) ;
}

void cdecl RaTC16RemapColors(REMAP_COLORS *rc)
{
  TC16RemapColors( rc ) ;
}

void cdecl RaTC32RemapColors(REMAP_COLORS *rc)
{
  TC32RemapColors( rc ) ;
}

void cdecl RaRasterRotateGetDstMFDB(MFDB *in, MFDB *out, long angle)
{
  float cosinus, sinus ;

  raster_rgetdstmfdb( (int)angle, in, out, &cosinus, &sinus ) ;
}

long cdecl RaRasterRotate(MFDB *in, MFDB *out, long angle, long flags)
{
  LDV_STATUS status ;
  int        ret ;

  if ( flags & 0x01L ) /* Progression */
    ret = raster_rotate( in, out, (int) angle, LdvProg ) ;
  else
    ret = raster_rotate( in, out, (int) angle, NULL ) ;

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

  return( (long)status ) ;
}

void cdecl GEMMessageLoop(void *msg)
{
  EVENT event ;

  memcpy( &event.ev_mmgpbuf, msg, sizeof(event.ev_mmgpbuf) ) ;
  GeneralMesagHandler( &event ) ;
}

char* cdecl CoGetLDVPath(void)
{
  return( config.path_ldv ) ;
}

char* cdecl CoGetCurrentLanguage(void)
{
  return( config.language ) ;
}

unsigned long cdecl CoGetFunctionOptimizations(void *function)
{
  unsigned long code = 0 ;

  if ( MachineInfo.cpu >= 30L )
  {
    if ( ( function == (void *)Vapi->MeSCopyMemory16 ) ||
         ( function == (void *)Vapi->MeSCopyMemory32 ) ||
         ( function == (void *)Vapi->RaRasterRotate )  ||
         ( function == (void *)Vapi->RaInd2Raster )
       ) code |= 0x01 ;
  }

  if ( MachineInfo.sound & 0x080 ) /* DSP 56001 */
  {
  }

  return( code ) ;
}

long cdecl InOpen(char *file)
{
  return( (long) OpenIni( file ) ) ;
}

long cdecl InClose(HINI h_ini)
{
  return( CloseIni( h_ini ) ) ;
}

long cdecl InSaveAndClose(HINI h_ini, char *new_name)
{
  return( SaveAndCloseIni( h_ini, new_name ) ) ;
}

long cdecl InGetKey(HINI h_ini, char *section, char *key, char *val_key)
{
  return( GetIniKey( h_ini, section, key, val_key ) ) ;
}

long cdecl InSetKey(HINI h_ini, char *section, char *key, char *val_key)
{
  return( SetIniKey( h_ini, section, key, val_key ) ) ;
}

long cdecl InGetOrSetKey(HINI h_ini, char *section, char *key, char *val_default_key)
{
  return( GetOrSetIniKey( h_ini, section, key, val_default_key ) ) ;
}

void cdecl MeSCopyMemory8(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm_smemcpy8( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl MeSCopyMemory16(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm_smemcpy16( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl MeSCopyMemory32(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm_smemcpy32( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl Me030SCopyMemory8(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm030_smemcpy8( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl Me030SCopyMemory16(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm030_smemcpy16( dst, src, nb_elems_dst, nb_elems_src ) ;
}

void cdecl Me030SCopyMemory32(void *dst, void *src, unsigned long nb_elems_dst, unsigned long nb_elems_src)
{
  asm030_smemcpy32( dst, src, nb_elems_dst, nb_elems_src ) ;
}

VAPI *LDVInitVAPI(void)
{
  if ( Vapi == NULL )
  {
    Vapi = (VAPI *) calloc( 1, sizeof(VAPI) ) ;
    if ( Vapi )
    {
      Vapi->Header.Version = VAPI_LDVVERSION ;
      Vapi->Header.StrSize = sizeof(VAPI) ;

      Vapi->Header.Global         = _GemParBlk.global ;
      Vapi->Header.GEMMessageLoop = GEMMessageLoop ;

      /* Progress Interface */
      Vapi->PrSetProg    = PrSetProg ;
      Vapi->PrOptimize   = PrOptimize ;
      Vapi->PrSetText    = PrSetText ;
      Vapi->PrSetProgEx  = PrSetProgEx ;

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

      /* INI Interface */
      Vapi->InOpen         = InOpen ;
      Vapi->InClose        = InClose ;
      Vapi->InSaveAndClose = InSaveAndClose ;
      Vapi->InGetKey       = InGetKey ;
      Vapi->InSetKey       = InSetKey ;
      Vapi->InGetOrSetKey  = InGetOrSetKey ;

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
    }
  }

  return( Vapi ) ;
}

int LDVSetValueFromString(char *buf, int type, LDV_BASICPARAM *p)
{
  int set = 1 ;

  switch( type )
  {
    case LDVT_SHORT : p->s = atoi( buf ) ;
                      break ;

    case LDVT_FLOAT : p->f = atof( buf ) ;
                      break ;

    default :         set = 0 ;
                      break ;
  }

  return( set ) ;
}

int LDVGetIniSpec(char *base_path, LDV_MODULE *ldv_module)
{
  HINI hini ;
  int  err = 0 ;
  int  i, max_len ;
  char name[PATH_MAX] ;
  char *point ;
  char short_name[16] ;
  char long_name[32] ;
  char description[80] ;
  char buf[200] ;

  point = strrchr( ldv_module->FileName, '.' ) ;
  if ( point ) *point = 0 ;
  sprintf( name, "%s\\%s\\%s.INI", base_path, config.language, ldv_module->FileName ) ;
  if ( !FileExist( name ) ) sprintf( name, "%s\\%s.INI", base_path, ldv_module->FileName ) ;
  hini = OpenIni( name ) ;
  if ( ( hini != -1 ) && FileExist( name ) )
  {
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
    max_len  = 1 + (int) strlen( short_name ) ;
    max_len += 1 + (int) strlen( long_name ) ;
    max_len += 1 + (int) strlen( description ) ;
    ldv_module->IniSpec.ShortName = (char *) malloc( max_len ) ;
    if ( ldv_module->IniSpec.ShortName )
    {
      strcpy( ldv_module->IniSpec.ShortName, short_name ) ;
      strcpy( ldv_module->IniSpec.ShortName + 1 + strlen( short_name ), long_name ) ;
      strcpy( ldv_module->IniSpec.ShortName + 1 + strlen( short_name ) + 1 + strlen( long_name ), description ) ;
      ldv_module->IniSpec.LongName    = ldv_module->IniSpec.ShortName + 1 + strlen( short_name ) ;
      ldv_module->IniSpec.Description = ldv_module->IniSpec.LongName  + 1 + strlen( long_name ) ;
    }

    /* Parameters */
    for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
    {
      /* Name */
      buf[0] = 0 ;
      sprintf( name, "Parameter%d", 1 + i ) ;
      GetIniKey( hini, name, "Name", buf ) ;
      max_len = (int) sizeof(ldv_module->IniSpec.Params[i].Name) - 1 ;
      if ( strlen( buf ) > max_len ) buf[max_len] = 0 ;
      strcpy( ldv_module->IniSpec.Params[i].Name, buf ) ;

      /* Type */
      buf[0] = 0 ;
      GetIniKey( hini, name, "Type", buf ) ;
      ldv_module->IniSpec.Params[i].Type = atoi( buf ) ;

      /* MinValue */
      buf[0] = 0 ;
      GetIniKey( hini, name, "MinValue", buf ) ;
      LDVSetValueFromString( buf, ldv_module->IniSpec.Params[i].Type, &ldv_module->IniSpec.Params[i].MinValue ) ;        

      /* DefaultValue */
      buf[0] = 0 ;
      GetIniKey( hini, name, "DefaultValue", buf ) ;
      LDVSetValueFromString( buf, ldv_module->IniSpec.Params[i].Type, &ldv_module->IniSpec.Params[i].DefaultValue ) ;        

      /* MaxValue */
      buf[0] = 0 ;
      GetIniKey( hini, name, "MaxValue", buf ) ;
      LDVSetValueFromString( buf, ldv_module->IniSpec.Params[i].Type, &ldv_module->IniSpec.Params[i].MaxValue ) ;        

      /* FloatIncrement */
      buf[0] = 0 ;
      GetIniKey( hini, name, "FloatIncrement", buf ) ;
      ldv_module->IniSpec.Params[i].FloatIncrement = atof( buf ) ;

      /* Verification de la validite */
      if ( ldv_module->IniSpec.Params[i].MinValue.s == ldv_module->IniSpec.Params[i].MaxValue.s )
        ldv_module->IniSpec.Params[i].Name[0] = 0 ; /* Ignorer ce parametre */
    }

    CloseIni( hini ) ;
  }
  else err = 1 ;
  *point ='.' ;

  return( err ) ; 
}

void LDVReleaseInterface(LDV_MODULE *mod, int iid)
{
  void *old_interface = NULL ;

  if ( mod && ( mod->Infos.Type & iid ) )
  {
    switch( iid )
    {
      case TLDV_MODIFYIMG : old_interface  = mod->IModifImg ;
                            mod->IModifImg = NULL ;
                            break ;

      case TLDV_LOADIMG   : old_interface = mod->ILoadImg ;
                            mod->ILoadImg = NULL ;
                            break ;

      case TLDV_SAVEIMG   : old_interface = mod->ISaveImg ;
                            mod->ISaveImg = NULL ;
                            break ;
    }
  }

  if ( old_interface )
  {
    free( old_interface ) ;
    mod->NbReferences-- ;
  }
}

void *LDVGetInterface(LDV_MODULE *mod, int iid)
{
  LDG  *ldg ;
  void *interface = NULL ;

  if ( mod && ( mod->Infos.Type & iid ) )
  {
    ldg = mod->Ldg ;
    switch( iid )
    {
      case TLDV_MODIFYIMG : if ( mod->IModifImg ) LDVReleaseInterface( mod, iid ) ;
                            mod->IModifImg = (ILDVModifImg *) calloc( 1, sizeof(ILDVModifImg) ) ;
                            if ( mod->IModifImg )
                            {
                              mod->IModifImg->PreRun    = ldg_find( "PreRun", ldg ) ;
                              mod->IModifImg->Run       = ldg_find( "Run", ldg ) ;
                              mod->IModifImg->Preview   = ldg_find( "Preview", ldg ) ;
                              mod->IModifImg->GetParams = ldg_find( "GetParams", ldg ) ;
                            }
                            interface = mod->IModifImg ;
                            break ;

      case TLDV_LOADIMG   : if ( mod->ILoadImg ) LDVReleaseInterface( mod, iid ) ;
                            mod->ILoadImg = (ILDVLoadImg *) calloc( 1, sizeof(ILDVLoadImg) ) ;
                            if ( mod->ILoadImg )
                            {
                            }
                            interface = mod->ILoadImg ;
                            break ;

      case TLDV_SAVEIMG   : if ( mod->ISaveImg ) LDVReleaseInterface( mod, iid ) ;
                            mod->ISaveImg = (ILDVSaveImg *) calloc( 1, sizeof(ILDVSaveImg) ) ;
                            if ( mod->ISaveImg )
                            {
                            }
                            interface = mod->ISaveImg ;
                            break ;
    }
  }

  if ( interface ) mod->NbReferences++ ;

  return( interface ) ;
}

void LDVReleaseAllInterfaces(LDV_MODULE *ldv_module)
{
  short index ;

  for ( index = 0; index < sizeof(ListTypes)/sizeof(short); index++ )
    LDVReleaseInterface( ldv_module, ListTypes[index] ) ;
}

void LDVGetAllInterfaces(LDV_MODULE *ldv_module)
{
  short index ;

  for ( index = 0; index < sizeof(ListTypes)/sizeof(short); index++ )
    LDVGetInterface( ldv_module, ListTypes[index] ) ;
}

void LDVUnloadFunctions(LDV_MODULE *ldv_module)
{
  LDVReleaseAllInterfaces( ldv_module ) ;
  ldg_term( ap_id, ldv_module->Ldg ) ;
  ldv_module->Ldg = NULL ;
}

LDV_STATUS LDVInit(char *file, LDV_MODULE *ldv_module, int minimal_infos)
{
  LDV_INFOS  *ldv_infos ;
  LDG        *ldg ;
  LDV_STATUS err = ELDV_NOERROR ;
  char       *slash, *lname = file ;
  char       base_path[PATH_MAX] ;

  if ( minimal_infos )
  {
    if ( ldv_module->FileName ) free( ldv_module->FileName ) ;
    memset( ldv_module, 0, sizeof(LDV_MODULE) ) ;
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
      free( ldv_module->FileName ) ;
      ldv_module->FileName = malloc( 1 + strlen( lname ) ) ;
      if ( ldv_module->FileName == NULL ) return( ELDV_NOTENOUGHMEMORY ) ;
    }
    strcpy( ldv_module->FileName, lname ) ;
  }
  else
  {
    ldv_module->FileName = malloc( 1 + strlen( lname ) ) ;
    if ( ldv_module->FileName == NULL ) return( ELDV_NOTENOUGHMEMORY ) ;
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
  }

  if ( !err )
  {
    if ( minimal_infos )
    {
      LDVGetIniSpec( base_path, ldv_module ) ;
      LDVUnloadFunctions( ldv_module ) ;
    }
    else LDVGetAllInterfaces( ldv_module ) ;
  }

  return( err ) ;
}

LDV_STATUS LDVLoadFunctions(char *path, LDV_MODULE *mod)
{
  char filename[PATH_MAX] ;

  sprintf( filename, "%s\\%s", path, mod->FileName ) ;
  return( LDVInit( filename, mod, 0 ) ) ;
}

LDV_CAPS *LDVGetNPlanesCaps(LDV_MODULE *mod, int nplanes)
{
  LDV_CAPS *caps ;

  caps = &mod->Infos.Caps[0] ;
  while ( caps->NbPlanes )
  {
    if ( caps->NbPlanes == nplanes ) break ;
    else                             caps++ ;
  }

  if ( caps->NbPlanes == 0 ) caps = NULL ;

  return( caps ) ;
}

#pragma warn -par
void add_ldv(char *file, DTA *dta, void *user_data)
{
  /* Toujours le cas a priori */
  if ( NumModule < NbModules )
  {
    if ( LDVInit( file, &Modules[NumModule], 1 ) == 0 ) NumModule++ ;
  }
}
#pragma warn +par

LDV_MODULE *LDVGetModuleList(char *path, int *nb_ldv)
{
  Modules   = NULL ;
  NbModules = (int) count_files( path, "*.LDV", 0, NULL ) ;

  if ( NbModules > 0 )
  {
    Vapi = LDVInitVAPI() ;

    /* Le dernier module (non valide) sera rempli de zeros */
    NumModule = 0 ;
    Modules = (LDV_MODULE *) calloc( 1+NbModules, sizeof(LDV_MODULE) ) ;
    if ( Modules ) find_files( config.flags & FLG_LONGFNAME, path, "*.LDV", add_ldv, NULL ) ;
    else           NbModules = 0 ;
  }

  if ( nb_ldv ) *nb_ldv = NbModules ;

  return( Modules ) ;
}

void LDVFreeModuleList(LDV_MODULE *module_list)
{
  LDV_MODULE *mod ;
  int        i ;

  mod = module_list ;
  for ( i = 0; i < NbModules; i++, mod++ )
  {
    if ( mod->IniSpec.ShortName ) free( mod->IniSpec.ShortName ) ;
    if ( mod->FileName ) free( mod->FileName ) ;
    if ( mod->Ldg ) LDVUnloadFunctions( mod ) ;
  }

  free( module_list ) ;
  if ( Vapi ) free( Vapi ) ;
  Vapi = NULL ;
}

LDV_MODULE *GetLdvByLdg(LDV_MODULE *ldv_list, LDG *ldg)
{
  LDV_MODULE *ldv_module = NULL ;
  LDV_MODULE *cldv = ldv_list ;

  if ( ldv_list )
  {
    while ( cldv->Ldg && ( ldv_module == NULL ) )
    {
      if ( cldv->Ldg == ldg ) ldv_module = cldv ;
      else                    cldv++ ;
    }
  }

  return( ldv_module ) ;
}

LDV_STATUS LDVAlloc(LDV_IMAGE *img)
{
  LDV_STATUS err = ELDV_NOERROR ;

  if ( img->Raster.fd_w && img->Raster.fd_h )
  {
    img->Raster.fd_addr = img_alloc( img->Raster.fd_w, img->Raster.fd_h,img->Raster.fd_nplanes ) ;
    if ( img->Raster.fd_addr == NULL )
      err = ELDV_NOTENOUGHMEMORY ;
    else
    {
      img->Raster.fd_wdwidth = img->Raster.fd_w / 16 ;
      if ( img->Raster.fd_w % 16 ) img->Raster.fd_wdwidth++ ;
    }
  }

  if ( img->Palette.NbColors > 0 )
  {
    img->Palette.Pal = calloc( img->Palette.NbColors, sizeof(VDI_ELEMENTPAL) ) ;
    if ( img->Palette.Pal == NULL ) err = ELDV_NOTENOUGHMEMORY ;
  }

  return( err ) ;
}

int GetBestImgFormat(LDV_CAPS *caps)
{
  int img_format ;

  switch( caps->NbPlanes )
  {
    case 1   :
    case 2   :
    case 4   :
    case 8   : if ( caps->Flags & LDVF_SPECFORMAT ) img_format = (int)LDVF_SPECFORMAT ;
               else
               if ( caps->Flags & LDVF_STDFORMAT ) img_format = (int)LDVF_STDFORMAT ;
               else
               if ( caps->Flags & LDVF_ATARIFORMAT ) img_format = (int)LDVF_ATARIFORMAT ;
               else                                  img_format = (int)LDVF_ATARIFORMAT ;
               break ;

    case 16  :
    case 24  :
    case 32  : if ( caps->Flags & LDVF_SPECFORMAT ) img_format = (int)LDVF_SPECFORMAT ;
               else
               if ( caps->Flags & LDVF_ATARIFORMAT ) img_format = (int)LDVF_ATARIFORMAT ;
               else                                  img_format = (int)LDVF_ATARIFORMAT ;
               break ;

    default  : img_format = (int)LDVF_SPECFORMAT ;
               break ;
  }

  return( img_format ) ;
}

LDV_STATUS FormatLdvImgFromSpec(LDV_IMAGE *ldv_img, int new_format)
{
  MFDB        previous_img, std_img ;
  LDV_STATUS  err = ELDV_NOERROR ;

  /* ldv_img->raster doit valoir LDVF_SPECFORMAT */
  if ( ldv_img->RasterFormat != LDVF_SPECFORMAT ) return( ELDV_GENERALFAILURE ) ;

  memcpy( &previous_img, &ldv_img->Raster, sizeof(MFDB) ) ;
  if ( ldv_img->RasterFormat != new_format )
  {
    switch( new_format )
    {
      case LDVF_STDFORMAT   : if ( ldv_img->Raster.fd_nplanes <= 8 )
                              {
                                memcpy( &std_img, &ldv_img->Raster, sizeof(MFDB) ) ;
                                std_img.fd_addr = img_alloc( std_img.fd_w, std_img.fd_h, std_img.fd_nplanes ) ;
                                if ( std_img.fd_addr == NULL ) err = ELDV_NOTENOUGHMEMORY ;
                                if ( LDV_SUCCESS( err ) )
                                {
                                  std_img.fd_stand = 1 ;
                                  vr_trnfm( handle, &ldv_img->Raster, &std_img ) ;
                                  free( ldv_img->Raster.fd_addr ) ;
                                  memcpy( &ldv_img->Raster, &std_img, sizeof(MFDB) ) ;
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

  return( err ) ;
}

LDV_STATUS FormatLdvImgToSpec(LDV_IMAGE *ldv_img)
{
  MFDB        img ;
  LDV_STATUS  err = ELDV_NOERROR ;

  switch( ldv_img->RasterFormat )
  {
    case LDVF_SPECFORMAT  : err = ELDV_NOERROR ;
                            break ;

    case LDVF_STDFORMAT   : if ( ldv_img->Raster.fd_nplanes <= 8 )
                            {
                              memcpy( &img, &ldv_img->Raster, sizeof(MFDB) ) ;
                              img.fd_addr = img_alloc( img.fd_w, img.fd_h, img.fd_nplanes ) ;
                              if ( img.fd_addr == NULL ) err = ELDV_NOTENOUGHMEMORY ;
                              if ( LDV_SUCCESS( err ) )
                              {
                                img.fd_stand = 0 ;
                                vr_trnfm( handle, &ldv_img->Raster, &img ) ;
                                free( ldv_img->Raster.fd_addr ) ;
                                memcpy( &ldv_img->Raster, &img, sizeof(MFDB) ) ;
                              }
                            }
                            else
                              err = ELDV_GENERALFAILURE ;
                            break ;

    case LDVF_ATARIFORMAT : if ( UseStdVDI && ( ldv_img->Raster.fd_nplanes <= 8 ) )
                            {
                              memcpy( &img, &ldv_img->Raster, sizeof(MFDB) ) ;
                              img.fd_addr = img_alloc( img.fd_w, img.fd_h, img.fd_nplanes ) ;
                              if ( img.fd_addr )
                              {
                                img.fd_stand = 1 ;
                                ClassicAtari2StdVDI( &ldv_img->Raster, &img ) ;
                                ldv_img->Raster.fd_stand = 0 ;
                                vr_trnfm( handle, &img, &ldv_img->Raster ) ;
                                free( img.fd_addr ) ;
                              }
                              else
                                err = ELDV_NOTENOUGHMEMORY ;
                            }
                            else if ( UseStdVDI ) tc_convert( &ldv_img->Raster ) ;
                            break ;

    default               : err = ELDV_GENERALFAILURE ;
                            break ;
  }

  if ( LDV_SUCCESS( err ) ) ldv_img->RasterFormat = (int)LDVF_SPECFORMAT ;

  return( err ) ;
}

LDV_STATUS LDVDo(LDV_MODULE *ldv, LDV_PARAMS *pldv_params, LDV_IMAGE *pldv_img, int preview, LDV_PERF *perfs)
{
  LDV_PARAMS   ldv_params ;
  LDV_CAPS     *caps ;
  ILDVModifImg *IModifImg = ldv->IModifImg ;
  LDV_IMAGE    *ldv_img, img_sel, out ;
  LDV_STATUS   err ;
  size_t       t0, t00 ;
  int          img_format ;

  if ( IModifImg == NULL ) return( ELDV_BADINTERFACE ) ;
  if ( preview ) perfs = NULL ;
  if ( perfs ) t00 = clock() ;

  ldv_img = pldv_img ;
  memcpy( &ldv_params, pldv_params, sizeof(LDV_PARAMS) ) ;
  caps = LDVGetNPlanesCaps( ldv, ldv_img->Raster.fd_nplanes ) ;
  if ( caps == NULL ) return( ELDV_NBPLANESNOTSUPPORTED ) ;

  if (
       ( ( ldv_params.x1 != 0 ) || ( ldv_params.y1 != 0  ) ||
         ( ldv_params.x2 != ldv_img->Raster.fd_w -1 ) || ( ldv_params.y2 != ldv_img->Raster.fd_h -1 )
       ) &&
       ( caps->Flags & LDVF_NOSELECTION )
     )
  {
    int xy[8] ;

    /* Dupliquer la selection, le LDV ne peut pas travailler sur une partie d'image */
    memcpy( &img_sel, ldv_img, sizeof(LDV_IMAGE) ) ;
    img_sel.Raster.fd_w    = 1 + ldv_params.x2 - ldv_params.x1 ;
    img_sel.Raster.fd_h    = 1 + ldv_params.y2 - ldv_params.y1 ;
    RaRasterAlloc( &img_sel.Raster ) ;
    if ( img_sel.Raster.fd_addr == NULL ) return( ELDV_NOTENOUGHMEMORY ) ;
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
  else memset( &img_sel, 0, sizeof(LDV_IMAGE) ) ;

  if ( perfs ) t0 = clock() ;
  img_format = GetBestImgFormat( caps ) ;
  err        = FormatLdvImgFromSpec( ldv_img, img_format ) ;
  if ( perfs ) perfs->pre_ldv_ms = (1000L * (clock() - t0) ) / CLK_TCK ;
  if ( !LDV_SUCCESS( err ) ) return( err ) ;

  memset( &out, 0, sizeof(LDV_IMAGE) ) ;
  out.Raster.fd_nplanes = caps->NbPlanesOut ;
  out.RasterFormat      = img_format ;

  if ( perfs ) t0 = clock() ;
  err = IModifImg->PreRun( ldv_img, &ldv_params, &out ) ;
  if ( perfs )
  {
    perfs->prerun_ms = (1000L * (clock() - t0) ) / CLK_TCK ;
    t0               = clock() ;
  }

  if ( LDV_SUCCESS( err ) )
  {
    if ( caps->Flags & LDVF_OPINPLACE )
    {
      memcpy( &out, ldv_img, sizeof(LDV_IMAGE) ) ;
      out.Raster.fd_nplanes = caps->NbPlanesOut ;
    }
    else
    {
      err = LDVAlloc( &out ) ;
      if ( !LDV_SUCCESS( err ) ) RaRasterFree( &img_sel.Raster ) ;
    }
  }

  if ( perfs ) perfs->pre_ldv_ms += (1000L * (clock() - t0) ) / CLK_TCK ;
  if ( LDV_SUCCESS( err ) )
  {
    if ( preview )
    {
      if ( IModifImg->Preview ) err = IModifImg->Preview( ldv_img, &ldv_params, &out ) ;
      else                      err = ELDV_PREVIEWNOTSUPPORTED ;
    }
    else
    {
      if ( IModifImg->Run )
      {
        int nflags ; 

        if ( caps->Flags & LDVF_SUPPORTCANCEL ) nflags = 0 ;
        else                                    nflags = CLOSER ; /* Pas d'annulation possible par defaut */
        if ( ( caps->Flags & LDVF_SUPPORTPROG ) && ( LdvProg == NULL ) )
          LdvProg = DisplayStdProg( "", "", "", nflags ) ;
        if ( LdvProg ) GWSetWindowCaption( LdvProg, "LDV ..." ) ;
        if ( perfs ) t0 = clock() ;
        err = IModifImg->Run( ldv_img, &ldv_params, &out ) ;
        if ( perfs ) perfs->run_ms = (1000L * (clock() - t0) ) / CLK_TCK ;
        if ( ( caps->Flags & LDVF_SUPPORTPROG ) && LdvProg )
          GWDestroyWindow( LdvProg ) ;
        LdvProg = NULL ;
      }
      else
        err = ELDV_RUNNOTSUPPORTED ;
    }

    if ( LDV_SUCCESS( err ) )
    {
      if ( perfs ) t0 = clock() ;
      err = FormatLdvImgToSpec( &out ) ;
      if ( LDV_SUCCESS( err ) )
      {
        if ( img_sel.Raster.fd_addr )
        {
          int xy[8] ;
          int xs0, ys0, xd0, yd0, ws, hs, wd, hd, w, h ;
          int mode = S_ONLY ;

          if (mode_vswr == MD_TRANS)      mode = S_OR_D ;
          else if (mode_vswr == MD_XOR)   mode = S_XOR_D ;
          else if (mode_vswr == MD_ERASE) mode = NOTS_AND_D ;
          /* Replacer la selection dupliquee */
          /*  Centrer le resultat sur le centre du bloc d'origine */
          wd    = 1 + pldv_params->x2 - pldv_params->x1 ;
          hd    = 1 + pldv_params->y2 - pldv_params->y1 ;
          ws    = out.Raster.fd_w ;
          hs    = out.Raster.fd_h ;
          if ( ws > wd )
          {
            w   = wd ;
            xs0 = ( ws - w ) / 2 ;
            xd0 = 0 ; 
          }
          else
          {
            w   = ws ;
            xs0 = 0 ;
            xd0 = ( wd - w ) / 2 ;
          }
          if ( hs > hd )
          {
            h   = hd ;
            ys0 = ( hs - h ) / 2 ;
            yd0 = 0 ; 
          }
          else
          {
            h   = hs ;
            ys0 = 0 ;
            yd0 = ( hd - h ) / 2 ;
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
          if ( ( caps->Flags & LDVF_OPINPLACE ) == 0 ) free( out.Raster.fd_addr ) ;
        }
        else
        {
          if ( ( caps->Flags & LDVF_OPINPLACE ) == 0 ) free( ldv_img->Raster.fd_addr ) ;
          memcpy( &ldv_img->Raster, &out.Raster, sizeof(MFDB) ) ;
        }
      }
      if ( perfs ) perfs->post_ldv_ms = (1000L * (clock() - t0) ) / CLK_TCK ;
    }
    else
    {
      if ( ( caps->Flags & LDVF_OPINPLACE ) == 0 ) free( out.Raster.fd_addr ) ;
      if ( out.Palette.Pal ) free( out.Palette.Pal ) ;
    }      
  }

  if ( perfs ) perfs->total_ms = (1000L * (clock() - t00) ) / CLK_TCK ;

  /* Run peut avoir modifie les valeurs des parametres */
  memcpy( &pldv_params->Param[0], &ldv_params.Param[0], LDVNBMAX_PARAMETERS*sizeof(LDV_BASICPARAM) ) ;

  return( err ) ;
}

