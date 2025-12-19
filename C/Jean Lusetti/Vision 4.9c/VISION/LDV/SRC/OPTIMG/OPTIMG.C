/*
 *
 *
 *	Version PureC / Gcc
 */

#define PCGEMLIB 1 /* mettre 1 si les utilisateurs de Pure C
					* utilise les librairies GEM Pure C */

/* Fichiers headers */

#include <stdio.h>
#include <portab.h>
#if PCGEMLIB
#include <aes.h>
#include <vdi.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

#include <string.h>
#include <stdlib.h>
#include "..\..\ldg.h"
#include "..\..\vapi.h"
#include "..\..\ldv.h"
#include "..\..\mt_aes.h"

/* Prototypages */
LDV_INFOS* cdecl GetLDVCapabilities(VAPI *vapi) ;
LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;

typedef struct _ANALYSIS_DATA
{
  /* Internal data during analysis */
  unsigned char* pixel ;     /* Pixel under analysis            */
  long           add_pixel ; /* Offset to next pixel to analyze */

  /* For indexes */
  short* pt_img ;
  
  long npixels_sofar ;
  long npixels_add ;
  long npixels_total ;
}
ANALYSIS_DATA, *PANALYSIS_DATA ;

/* This is our structure to held image data */
/* And analyze outcome                      */
typedef struct _IMG_REPORT
{
  /* Inputs */
  LDV_IMAGE*    in ;
  char*         profile ;
  char          save_options[6][32] ; /* 0: 1 plane, 1: 4 planes, 2:8 planes, 3:16 planes, 4:24 planes, 5:32 planes */
  unsigned char limit_black ;
  unsigned char limit_white ;
  unsigned char diff_grey ;
  unsigned char enforce_smaller ;
  short         enforce_dither ;
  short         dither_method ;
  short         dither_outplanes ;
  short         dither_param ;

  ANALYSIS_DATA d ;

  /* Outcome */
  char is_dualtone ;
  char is_grey ;
  long ncolors ;
}
IMG_REPORT, *PIMG_REPORT ;

/* Variables globales */
PROC Proc[]  = {
                 "GetLDVCapabilities", "LDV capabilties", (void*)GetLDVCapabilities,
/* No preRun                 "PreRun", "Before Run", (void *)PreRun, */
                 "Run", "LDV routine", (void *)Run,
/* No preview                 "Preview", "Preview", (void *)Preview, */
              } ;

char Info[] = "LDV";

LDGLIB Ldg[] = {
        0x0103, /* version de la lib, recommand‚  */
        2,		  /* nombre de fonction dans la lib */
        Proc,	  /* Pointeurs vers nos fonctions   */
        Info,   /* Information sur la lib         */
        0x0,   	/* Flags de la lib, obligatoire   */
        NULL,
        };

#define CAPS (LDVF_ATARIFORMAT | LDVF_OPINPLACE | LDVF_SUPPORTPROG | LDVF_SUPPORTCANCEL | LDVF_NOSELECTION | LDVF_NOCHANGE)

/* Note that for this LDV, no matter what is returned as #nplanes for output */
/* As no LDV_IMAGE is returned, a file is generated                          */
LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* Taille de cette structure */
                       TLDV_MODIFYIMG,            /* Type du LDV               */
                       "Jean Lusetti",            /* Auteurs                   */
                       {
                         {  1, 1, CAPS }, /* Capacites pour 1 plan    */
                         {  4, 1, CAPS }, /* Capacites pour 4 plans    */
                         {  8, 1, CAPS }, /* Capacites pour 8 plans    */
                         { 16, 1, CAPS }, /* Capacites pour 16 plans   */
                         { 32, 1, CAPS }, /* Capacites pour 32 plans   */
                         { 0, 0, 0UL }    /* Fin de la liste des capacites */
                       },
                     } ;

VAPI* Vapi = NULL ;

/* VAPI macro check */
#define CHECK_VAPI(vapi) if ( (vapi == NULL) || (vapi->Header.Version < 0x0109) ) return ELDV_BADVAPIVERSION ;

unsigned char u5bto8b[32] ;
unsigned char u6bto8b[64] ;

/* 
 * Fonctions de la librairie
 */

LDV_INFOS* cdecl GetLDVCapabilities(VAPI* vapi)
{
  Vapi = vapi ;

  return( &LdvInfos ) ;
}

static void GetDefaultSaveOptions(IMG_REPORT* img_report)
{
  strcpy( &img_report->save_options[0][0], "fmt=TIF;compression=lzw" ) ; /* 1 Plane   */
  strcpy( &img_report->save_options[1][0], "fmt=TIF;compression=lzw" ) ; /* 4 Planes  */
  strcpy( &img_report->save_options[2][0], "fmt=TIF;compression=lzw" ) ; /* 8 Planes  */
  strcpy( &img_report->save_options[3][0], "fmt=JPG;quality=90" ) ;      /* 16 Planes */
  strcpy( &img_report->save_options[4][0], "fmt=JPG;quality=90" ) ;      /* 24 Planes */
  strcpy( &img_report->save_options[5][0], "fmt=JPG;quality=90" ) ;      /* 32 Planes */
}

static short LoadProfile(IMG_REPORT* img_report)
{
  long  profile_found = 0 ;
  short i ;
  char* path_ldv ;
  char* language ;
  char* keys[] = { "1", "4", "8", "16", "24", "32" } ;

  if ( img_report->profile == NULL ) return -1 ;

  path_ldv = Vapi->CoGetLDVPath() ;
  language = Vapi->CoGetCurrentLanguage() ;
  if ( path_ldv && language )
  {
    long found ;
    char filename[256] ;
    char buffer[128] ;

    sprintf( filename, "%s\\%s\\OPTIMG.INI", path_ldv, language ) ;
    Vapi->LoDoLog(LL_INFO,"optimg.ldv: Looking into %s to find profile %s", filename, img_report->profile) ;
    for ( i = 0; i < ARRAY_SIZE(keys); i++ )
      if ( Vapi->InGetKeyFromFile( filename, img_report->profile, keys[i], &img_report->save_options[i][0] ) == 1 ) profile_found = 1 ;
    if ( !profile_found )
    {
      sprintf( filename, "%s\\OPTIMG.INI", path_ldv ) ;
      Vapi->LoDoLog(LL_INFO,"optimg.ldv: Looking into %s to find profile %s", filename, img_report->profile) ;
      Vapi->LoDoLog(LL_INFO,"optimg.ldv: Looking into non language specific %s to find profile %s ...", filename, img_report->profile) ;
      for ( i = 0; i < ARRAY_SIZE(keys); i++ )
        if ( Vapi->InGetKeyFromFile( filename, img_report->profile, keys[i], &img_report->save_options[i][0] ) == 1 ) profile_found = 1 ;
    }
    found = Vapi->InGetKeyFromFile( filename, img_report->profile, "limit_black", buffer ) ;
    if ( found ) img_report->limit_black = (unsigned char) atoi( buffer ) ;
    else         img_report->limit_black = 0 ;
    found = Vapi->InGetKeyFromFile( filename, img_report->profile, "limit_white", buffer ) ;
    if ( found ) img_report->limit_white = (unsigned char) atoi( buffer ) ;
    else         img_report->limit_white = 255 ;
    found = Vapi->InGetKeyFromFile( filename, img_report->profile, "diff_grey", buffer ) ;
    if ( found ) img_report->diff_grey = (unsigned char) atoi( buffer ) ;
    else         img_report->diff_grey = 0 ;
    found = Vapi->InGetKeyFromFile( filename, img_report->profile, "enforce_smaller", buffer ) ;
    if ( found ) img_report->enforce_smaller = (unsigned char) atoi( buffer ) ;
    else         img_report->enforce_smaller = 0 ;

    /* Keys to enforce dither method */
    found = Vapi->InGetKeyFromFile( filename, img_report->profile, "enforce_dither", buffer ) ;
    if ( found ) img_report->enforce_dither = (short) atoi( buffer ) ;
    else         img_report->enforce_dither = 0 ;
    if ( img_report->enforce_dither )
    {
      found = Vapi->InGetKeyFromFile( filename, img_report->profile, "dither_method", buffer ) ;
      if ( found ) img_report->dither_method = (short) atoi( buffer ) ;
      else         img_report->dither_method = 0 ;
      found = Vapi->InGetKeyFromFile( filename, img_report->profile, "dither_outplanes", buffer ) ;
      if ( found ) img_report->dither_outplanes = (short) atoi( buffer ) ;
      else         img_report->dither_outplanes = 0 ;
      found = Vapi->InGetKeyFromFile( filename, img_report->profile, "dither_param", buffer ) ;
      if ( found ) img_report->dither_param = (short) atoi( buffer ) ;
      else         img_report->dither_param = 0 ;
    }
  }
  else Vapi->LoDoLog(LL_WARNING,"optimg.ldv: Can't access LDV (%s) or language path (%s)!", path_ldv, language) ;

  return !profile_found ; /* 0 if found */
}

static long md_grey(long abs_diff, long max_diff)
{
  if ( abs_diff > max_diff ) return abs_diff ;
  else                       return max_diff ;
}

static void fast_isgrey(IMG_REPORT* img_report)
{
  /* Quick check to see if all pixels in diagonal are grey */
  MFDB*          in = &img_report->in->Raster ;
  long           add_pixel = (in->fd_nplanes >> 3) ;
  unsigned char* pixel = in->fd_addr ;
  unsigned short pix16, diff_grey = img_report->diff_grey ;
  short          h ;
  unsigned char  r, g, b ;

  add_pixel +=  add_pixel*16L*(long)in->fd_wdwidth ; /* Offset to next pixel in diagonal */
  for( h = 0 ; img_report->is_grey && (h < in->fd_h-1); h++, pixel += add_pixel )
  {
    if ( in->fd_nplanes == 16 )
    {
      pix16 = *pixel ; /* RRRRRGGGGGGBBBBB*/
      r     = u5bto8b[pix16 >> 11] ;          /* Value on 5 bits remapped to 8 bits */
      g     = u6bto8b[(pix16 >> 5) & 0x1F] ;  /* Value on 6 bits remapped to 8 bits */
      b     = u5bto8b[pix16 & 0x1F] ;         /* Value on 5 bits remapped to 8 bits */
    }
    else
    {
      r = pixel[0] ;
      g = pixel[1] ;
      b = pixel[2] ;
    }
    if ( abs( r-g ) > diff_grey )      img_report->is_grey = 0 ;
    else if ( abs( r-b ) > diff_grey ) img_report->is_grey = 0 ;
    else if ( abs( g-b ) > diff_grey ) img_report->is_grey = 0 ;
  }

  if ( !img_report->is_grey )
  {
    if ( in->fd_nplanes == 16 ) Vapi->LoDoLog(LL_INFO,"optimg.ldv: fast_isgrey, not grey: %d %d %d (%X)", (short)r, (short)g, (short)b, pix16) ;
    else                        Vapi->LoDoLog(LL_INFO,"optimg.ldv: fast_isgrey, not grey: %d %d %d", (short)r, (short)g, (short)b) ;
  }
}

static short AnalyzeFromVISION(IMG_REPORT* img_report)
{
  HISTO histo ;
  short status ;

  Vapi->LoDoLog(LL_INFO,"optimg.ldv: Requesting VISION to compute histogram...") ;
  Vapi->PrSetText( 1, "Requesting histograms to VISION..." ) ;
  histo.norm = 256 ; /* Normalize stats to 0...256 scale */
  status = Vapi->ImComputeHistogram( img_report->in, &histo ) ;
  Vapi->LoDoLog(LL_INFO,"optimg.ldv: histogram done with status %d", status) ;
  if ( status == 0 )
  {
    long  max_diff_grey = 0 ;
    long  r, g, b, ref_diff_grey ;
    short i, grey1 = 0 ;

    ref_diff_grey = img_report->diff_grey ;
    for ( i = 0; img_report->is_grey && (i < HISTO_SIZE); i++ )
    {
      r = histo.red[i] ;
      g = histo.green[i] ;
      b = histo.blue[i] ;
      max_diff_grey = md_grey( labs( r-g ), max_diff_grey ) ;
      max_diff_grey = md_grey( labs( r-b ), max_diff_grey ) ;
      max_diff_grey = md_grey( labs( g-b ), max_diff_grey ) ;
      if ( max_diff_grey > ref_diff_grey ) img_report->is_grey = 0 ;
    }
    Vapi->LoDoLog(LL_INFO,"optimg.ldv: max difference grey=%ld", max_diff_grey) ;

    /* As histogram will report "perfect grey" if image has colors fully aligned (i.e. full 16M picture), let's make a fast check on grey levels */
    if ( img_report->is_grey && (img_report->in->Raster.fd_nplanes > 8) )
    {
      fast_isgrey( img_report ) ;
      if ( img_report->is_grey ) grey1 = 1 ;
    }
    if ( !img_report->is_grey )
    {
      i-- ;
      Vapi->LoDoLog(LL_INFO,"optimg.ldv: image is not grey level and so not dual-tone") ;
      if ( grey1 ) Vapi->LoDoLog(LL_INFO,"optimg.ldv: RGB[%d]=%ld,%ld,%ld", i, r, g, b) ;
      img_report->is_dualtone = 0 ;
    }
    else if ( img_report->limit_black < img_report->limit_white )
    {
      for ( i = img_report->limit_black; img_report->is_dualtone && (i < img_report->limit_white); i++ )
      {
        if ( histo.grey[i] > ref_diff_grey ) img_report->is_dualtone = 0 ;
      }
      if ( !img_report->is_dualtone )
      {
        i-- ;
        Vapi->LoDoLog(LL_INFO,"optimg.ldv: image is not dual tone") ;
        Vapi->LoDoLog(LL_INFO,"optimg.ldv: Grey[%d]=%ld", i, histo.grey[i]) ;
      }
    }
    img_report->ncolors = histo.nb_colors_used ;
  }

  return status ;
}

static LDV_STATUS ImgAnalyze(IMG_REPORT* img_report)
{
  LDV_IMAGE* in = img_report->in ;
  short      status ;

  img_report->is_dualtone = 1 ;
  img_report->is_grey     = 1 ;

  if ( LoadProfile( img_report ) != 0 )
  {
    /* For some reason, profile is not found */
    /* Let's defaut to TIF/JPEG outputs      */
    Vapi->LoDoLog(LL_INFO, "optimg.ldv: getting hard-coded default profile") ;
    GetDefaultSaveOptions( img_report ) ;
  }

  if ( in->Raster.fd_nplanes == 1 ) return 1 ;

  Vapi->LoDoLog(LL_INFO, "optimg.ldv: image is %dx%dx%d", in->Raster.fd_w, in->Raster.fd_h, in->Raster.fd_nplanes) ;
  Vapi->LoDoLog(LL_INFO, "optimg.ldv: ImgAnalyze enforce_smaller = %d", (short)img_report->enforce_smaller) ;
  Vapi->LoDoLog(LL_INFO, "optimg.ldv: ImgAnalyze limit_black     = %d", (short)img_report->limit_black) ;
  Vapi->LoDoLog(LL_INFO, "optimg.ldv: ImgAnalyze limit_white     = %d", (short)img_report->limit_white) ;
  Vapi->LoDoLog(LL_INFO, "optimg.ldv: ImgAnalyze diff_grey       = %d", (short)img_report->diff_grey) ;
  Vapi->LoDoLog(LL_INFO, "optimg.ldv: ImgAnalyze enforce_dither  = %d", (short)img_report->enforce_dither) ;
  if ( img_report->enforce_dither )
  {
    Vapi->LoDoLog(LL_INFO, "optimg.ldv:      ImgAnalyze method     = %d", (short)img_report->dither_method) ;
    Vapi->LoDoLog(LL_INFO, "optimg.ldv:      ImgAnalyze outplanes  = %d", (short)img_report->dither_outplanes) ;
    Vapi->LoDoLog(LL_INFO, "optimg.ldv:      ImgAnalyze param      = %d", (short)img_report->dither_param) ;
  }

  if ( img_report->enforce_dither )
  {
    Vapi->LoDoLog(LL_INFO,"optimg.ldv: profile enforces dither method=%d, outplanes=%d, param=%d", img_report->dither_method, img_report->dither_outplanes, img_report->dither_param ) ;
    status = 1 ;
  }
  else
  {
    status = ( AnalyzeFromVISION( img_report ) == 0 ) ;
    if ( img_report->is_grey )     { Vapi->LoDoLog(LL_INFO,"optimg.ldv: image is grey level") ; status = 1 ; }
    if ( img_report->is_dualtone ) { Vapi->LoDoLog(LL_INFO,"optimg.ldv: image is dual tone") ; status = 1 ; }
    Vapi->LoDoLog(LL_INFO,"optimg.ldv: %ld colors found", img_report->ncolors) ;
  }

  return status ;
}

static char* GetSaveOptions(IMG_REPORT* img_report, short nplanes)
{
  short planes[] = { 1, 4, 8, 16, 24, 32 } ;
  short i ;
  char* save_options = NULL ;

  for ( i = 0; (save_options == NULL) && (i < ARRAY_SIZE(planes)); i++ )
    if ( planes[i] == nplanes ) save_options = &img_report->save_options[i][0] ;

  Vapi->LoDoLog(LL_INFO, "optimg.ldv: GetSaveOptions(%d planes): %s", nplanes, save_options ? save_options:NULL) ;
  return save_options ;
}

static char* GetBestImgMatch(IMG_REPORT* img_report, long* method, long* param, LDV_IMAGE* out)
{
  LDV_IMAGE* in = img_report->in ;

  out->Raster.fd_nplanes = in->Raster.fd_nplanes ;
  *method                = -1 ;
  *param                 = 0 ;

  if ( img_report->enforce_dither )
  {
    out->Raster.fd_nplanes = img_report->dither_outplanes ;
    *method                = img_report->dither_method ;
    *param                 = img_report->dither_param ;
  }
  else if ( img_report->is_dualtone )
  {
    out->Raster.fd_nplanes = 1 ;
    *method                = 4 ;
    *param                 = 50 ;
  }
  else if ( img_report->is_grey )
  {
    out->Raster.fd_nplanes = (img_report->ncolors <= 16L) ? 4:8 ;
    *method                = 2 ;
  }
  else if ( img_report->ncolors < 2048L )
  {
    if ( in->Raster.fd_nplanes > 8 )
    {
      out->Raster.fd_nplanes = 8 ;
      *method                = 3 ;
    }
  }

  return GetSaveOptions( img_report, out->Raster.fd_nplanes ) ;
}

static long file_size(char* name)
{
  FILE* stream = fopen( name, "rb" ) ;
  long  size ;
  
  if ( stream == NULL ) return -1 ;

  fseek( stream, 0, SEEK_END ) ;
  size = ftell( stream ) ;
  fclose( stream ) ;

  return size ;
}

LDV_STATUS cdecl Run(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  LDV_STATUS status = ELDV_NOERROR ;
  IMG_REPORT img_report ;
  short      copy_file = 1 ; /* In case we don't find a better choice than the current one */
  char       in_file[256] ;
  char       out_file[256] ;
  char       buf[256] ;
  char*      pout_file ;
  char*      profile ;

  CHECK_VAPI( Vapi ) ;

  pout_file = params->Param[0].str ;
  profile   = params->Param[1].str ;
  Vapi->LoDoLog(LL_INFO, "optimg.ldv: dest:%s, profile=%s", pout_file ? pout_file:"<null>", profile ? profile:"<null>") ;
  if ( pout_file == NULL ) return ELDV_INVALIDPARAMETER ;

  status = Vapi->ImGetStdData( in, "filename", in_file, sizeof(in_file) ) ;
  if ( !LDV_SUCCESS( status ) ) return status ;

  strcpy( out_file, pout_file ) ;
  if ( Vapi->FiFolderExist( pout_file ) )
  {
    char* last_slash = strrchr( in_file, '\\' ) ;

    Vapi->LoDoLog(LL_INFO, "optimg.ldv: %s is a folder", pout_file ) ;
    if ( last_slash ) strcat( out_file, last_slash ) ; /* Just copy filename without folder before */
    else              strcat( out_file, in_file ) ;
  }

  sprintf( buf, "Analyzing %s...", in_file ) ;
  Vapi->PrSetText( 0, buf ) ;
  Vapi->PrSetText( 1, "Requesting histograms to VISION..." ) ;
  if ( LDVPROG_CANCEL( Vapi->PrSetProgEx( 0 ) ) ) { Vapi->LoDoLog(LL_INFO, "optimg.ldv: user requested cancel") ; return ELDV_CANCELLED ; }
  memset( &img_report, 0, sizeof(img_report) ) ;
  img_report.in      = in ;
  img_report.profile = profile ;
  if ( ImgAnalyze( &img_report ) == 1 )
  {
    long  method, param ;
    char* save_options ;

    save_options = GetBestImgMatch( &img_report, &method, &param, out ) ;
    if ( save_options )
    {
      Vapi->LoDoLog(LL_INFO,"optimg.ldv: dither method=%ld", method) ;
      sprintf( buf, "Optimizing %s...", in_file ) ;
      Vapi->PrSetText( 0, buf ) ;
      Vapi->PrSetText( 1, "Requesting dithering to VISION..." ) ;
      if ( LDVPROG_CANCEL( Vapi->PrSetProgEx( 33 ) ) ) status =  ELDV_CANCELLED ;
      else if ( method != -1 )                         status = Vapi->ImDither( method, param, in, out ) ;
      if ( LDV_SUCCESS( status ) )
      {
        char  local_outfile[256] ; /* As we have to set the format as extension */
        char  buffer[128] ;
        char  out_ext[16] ;
        char* c ;
        char* ext ;

        if ( method != -1 ) Vapi->ImFree( in ) ; /* We just dither the image sucessfully, let's free the original one */
        else                memcpy( out, in, sizeof(LDV_IMAGE) ) ;
        if ( sscanf( save_options, "fmt=%s", buffer ) == 1 ) /* format is the first field returned by GetBestImgMatch */
        {
          c = strchr( buffer, ';' ) ;
          if ( c ) { *c = 0 ; strcpy( out_ext, buffer ) ; }
          else     strcpy( out_ext, buffer ) ;
          strcpy( local_outfile, out_file ) ;
          c = strrchr( local_outfile, '\\' ) ;
          if ( c ) ext = strrchr( 1+c, '.' ) ;
          else     ext = strrchr( local_outfile, '.' ) ;
          if ( ext ) *(1+ext) = 0 ;
          if ( c ) strcat( 1+c, out_ext ) ;
          Vapi->LoDoLog(LL_INFO, "optimg.ldv: optimizing image file %s to %s with options: %s", in_file, local_outfile, save_options ) ;
          Vapi->PrSetText( 1, "Requesting saving to VISION..." ) ;
          if ( LDVPROG_CANCEL( Vapi->PrSetProgEx( 66 ) ) ) status =  ELDV_CANCELLED ;
          else                                             status = Vapi->ImSave( local_outfile, out, save_options ) ;
          if ( LDV_SUCCESS( status ) )
          {
            if ( img_report.enforce_smaller )
            {
              long l1, l2 ;

              l1 = file_size( in_file ) ;
              l2 = file_size( local_outfile ) ;
              if ( (l2 > 0) && (l1 > l2) ) copy_file = 0 ;
              else                         { unlink( local_outfile ) ; Vapi->LoDoLog(LL_INFO, "optimg.ldv: optimized file is bigger (%ldKB vs %ldKB), keeping original one", l1>>10, l2>>10 ) ; }
            }
            else copy_file = 0 ;
          }
          else { Vapi->LoDoLog(LL_ERROR, "optimg.ldv: ImSave returned %ld", status ) ; status = ELDV_GENERALFAILURE ; }
        }
        else { Vapi->LoDoLog(LL_ERROR, "optimg.ldv: image format not found in save options %s", save_options ) ; status = ELDV_GENERALFAILURE ; }
      }
      else Vapi->LoDoLog(LL_ERROR, "optimg.ldv: ImDither returned %ld", status ) ;
    }
    else Vapi->LoDoLog(LL_INFO, "optimg.ldv: can't find a better setting" ) ;
  }
  else Vapi->LoDoLog(LL_INFO, "optimg.ldv: ImgAnalyze did not identify a possible optimization" ) ;

  if ( status == ELDV_CANCELLED ) Vapi->LoDoLog(LL_INFO, "optimg.ldv: user requested cancel") ;
  else if ( copy_file )
  {
    Vapi->LoDoLog(LL_INFO, "optimg.ldv: duplicating image file %s to %s", in_file, out_file ) ;
    Vapi->PrSetText( 1, "Duplicating original file..." ) ;
    Vapi->PrSetProgEx( 85 ) ;
    status = Vapi->FiCopyFileR( in_file, out_file ) ;
    if ( !LDV_SUCCESS( status ) )
    {
      Vapi->LoDoLog(LL_ERROR, "optimg.ldv: FiCopyFileR returned %ld", status ) ;
      status = ELDV_GENERALFAILURE ;
    }
  }
  Vapi->PrSetText( 1, "" ) ;

  return status ;
}

static void uinit()
{
  short i ;

  for ( i = 0; i < 32; i++ ) u5bto8b[i] = (unsigned char) (0.5+(i*256.0)/32.0) ;
  for ( i = 0; i < 64; i++ ) u6bto8b[i] = (unsigned char) (0.5+(i*256.0)/64.0) ;
}

int main(void)
{
  ldg_init( Ldg ) ;

  return 0 ;
}
