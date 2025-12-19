#include <string.h>
#include <stdlib.h>
#include "..\tools\xgem.h"
#include "..\tools\gwindows.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"
#include "..\tools\numsld.h"
#include "..\tools\stdmline.h"
#include "..\tools\rzoom.h"
#include "..\tools\logging.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

#include "fappldv.h"
#include "actions.h"

#define FLG_NOSRCDISPLAY   1
#define FLG_LDVERR         2
#define FLG_TEXTCHANGE     4 /* user edited TXT type, may be used to trig a refresh */
#define FLG_PALETTECHANGED 8 /* Palette has been changed from here */
typedef struct
{
  LDV_MODULE* ldv ;
  LDV_PARAMS  ldv_params ;
  LDV_CAPS*   caps ; /* Pour le nombre de plans en question */
  GEM_WINDOW* wimg ;
  MFDB        src ;
  int         xc, yc, wc, hc ; /* Offsets et longueurs pour src */
  MFDB        dst ;
  int         flags ;

  NUM_SLD     NumSld[LDVNBMAX_PARAMETERS] ;
  int         nb_params ;
  /* In case we have a LDVT_TEXT type for parameter, we need additional storage */
  /* See https://www.atari-forum.com/viewtopic.php?t=45602 for an explanation on this limitation */
  #define NMAX_CHARS 80
  char        te_ptext[NMAX_CHARS] ;
  char        te_ptmplt[NMAX_CHARS] ;
  char        te_pvalid[2] ; /* Only "X\0" is needed */
}
WEXTENSION_FAPPLDV ;

#define MIN_PREVIEW_SIZE 48


static void draw_img(PARMBLK* parmblock, MFDB* img)
{
  int xy[8] ;
  int cxy[4] ;

  if ( intersect( parmblock->pb_xc, parmblock->pb_yc, parmblock->pb_wc, parmblock->pb_hc,
                  parmblock->pb_x,  parmblock->pb_y,  parmblock->pb_w,  parmblock->pb_h, &xy[4] ) )
  {
    GWHideCursor() ;
    if ( img->fd_addr )
    {
      xy[0] = xy[4] - parmblock->pb_x ;
      xy[1] = xy[5] - parmblock->pb_y ;
      xy[2] = xy[0] + xy[6] - xy[4] ;
      xy[3] = xy[1] + xy[7] - xy[5] ;
      svro_cpyfmSOS( xy, img ) ;
    }
    else
    {
      cxy[0] = parmblock->pb_xc ;
      cxy[1] = parmblock->pb_yc ;
      cxy[2] = parmblock->pb_xc + parmblock->pb_wc - 1 ;
      cxy[3] = parmblock->pb_yc + parmblock->pb_hc - 1 ;
      svs_clipON( cxy ) ;
      svsl_ends( 0, 0 ) ;
      svsl_width( 3 ) ;
      (void)svsl_color( 1 ) ;
      line( parmblock->pb_x + parmblock->pb_w - 1, parmblock->pb_y, parmblock->pb_x, parmblock->pb_y + parmblock->pb_h - 1 ) ;
      line( parmblock->pb_x, parmblock->pb_y, parmblock->pb_x + parmblock->pb_w - 1, parmblock->pb_y + parmblock->pb_h - 1 ) ;
      svs_clipOFF( cxy ) ;
    }
    GWShowCursor() ;
  }
}

static int cdecl draw_src(PARMBLK* parmblock)
{
  WEXTENSION_FAPPLDV* wext = (WEXTENSION_FAPPLDV*) parmblock->pb_parm ;

  if ( (wext->flags & FLG_NOSRCDISPLAY) == 0 ) draw_img( parmblock, &wext->src ) ;

  return 0 ;
}

static int cdecl draw_dst(PARMBLK* parmblock)
{
  WEXTENSION_FAPPLDV* wext = (WEXTENSION_FAPPLDV*) parmblock->pb_parm ;
  void*               fd_addr = wext->dst.fd_addr ;

  if ( wext->flags & FLG_LDVERR ) wext->dst.fd_addr = NULL ; /* Fake image pointer to report error */
  draw_img( parmblock, &wext->dst ) ;
  wext->dst.fd_addr = fd_addr ;

  return 0 ;
}

static short ConsiderLDVParam(LDV_DEF_PARAM* dparam) /* For GUI */
{
  return( (dparam->Type == LDVT_SHORT) && (dparam->Name[0] != 0) ) ;
/*  return( dparam->Type != LDVT_FILE ) ;*/
}

static void GetLDVParams(GEM_WINDOW* wnd, LDV_PARAMS* params)
{
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;
  LDV_MODULE*         ldv = wext->ldv ;
  OBJECT*             bobj = wnd->DlgData->BaseObject ;
  VXIMAGE*            vximage = wext->wimg->Extension ;
  float               ratio, yratio ;
  int                 i ;

  /* Recuperation du bloc a traiter */
  if ( selected( bobj, LDVA_SEL ) )
  {
    ratio  = (float)wext->wc / (float)vximage->inf_img.mfdb.fd_w ;
    yratio = (float)wext->hc / (float)vximage->inf_img.mfdb.fd_h ;
    if ( yratio < ratio ) ratio = yratio ;
    params->x1 = wext->xc + (int) (ratio * vclip.x1) ;
    params->y1 = wext->yc + (int) (ratio * vclip.y1) ;
    params->x2 = wext->xc + (int) (ratio * vclip.x2) ;
    params->y2 = wext->yc + (int) (ratio * vclip.y2) ;
  }
  else
  {
    /* Image entiere */
    params->x1 = 0 ;
    params->y1 = 0 ;
    params->x2 = wext->src.fd_w - 1 ;
    params->y2 = wext->src.fd_h - 1 ;
  }

  /* Recuperation des parametres du LDV */
  params->NbParams = 0 ;
  for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
  {
    params->ParamType[i] = ldv->IniSpec.Params[i].Type ;
    if ( ConsiderLDVParam( &ldv->IniSpec.Params[i]) )
    {
      params->Param[i].s = wext->NumSld[i].Val ;
      params->NbParams++ ;
    }
    else if ( (ldv->IniSpec.Params[i].Type == LDVT_FILE) && (ldv->IniSpec.Params[i].Name[0] != 0) )
    {
      char buffer[PATH_MAX] ;
      char def[32] ;
      char* p ;

        p = strrchr( ldv->FileName, '.' ) ;
        if ( p ) *p = 0 ; /* Remove extension */
        /* Prompt for file name */
        sprintf( buffer, "%s\\*.TXT", init_path ) ;
        sprintf( def, "%s.TXT", ldv->FileName ) ;
        if ( file_name( buffer, def, buffer ) == 1 )
        {
          if ( params->Param[i].str ) Xfree( params->Param[i].str ) ;
          params->Param[i].str = Xstrdup( buffer ) ;
        }
        if ( p ) *p = '.' ; /* Restore extension */
    }
    else if ( ldv->IniSpec.Params[i].Type == LDVT_TEXT )
    {
      char buffer[512] ;

      read_text( bobj, i*(LDVA_LESS2-LDVA_LESS1) + LDVA_PARAM1, buffer ) ;
      if ( params->Param[i].str ) Xfree( params->Param[i].str ) ;
      params->Param[i].str = Xstrdup( buffer ) ;
      params->NbParams++ ;
    }
  }
}

static void DoLDVPreview(GEM_WINDOW* wnd, int display)
{
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;
  VXIMAGE*            vimage = (VXIMAGE*) wext->wimg->Extension ;
  OBJECT*             bobj = wnd->DlgData->BaseObject ;
  LDV_PARAMS          ldv_params ;
  LDV_IMAGE           in_out ;
  LDV_MODULE*         ldv = wext->ldv ;
  LDV_CAPS*           caps ;
  LDV_STATUS          err ;
  void*               alloc_pal_ori = NULL ;
  int                 xy[8] ;
  int                 i, xc, yc ;

  caps = LDVGetNPlanesCaps( ldv, screen.fd_nplanes ) ;
  memzero( &in_out, sizeof(LDV_IMAGE) ) ;
  if ( wext->src.fd_addr && wext->dst.fd_addr )
  {
    GetLDVParams( wnd, &wext->ldv_params ) ;
    memcpy( &ldv_params, &wext->ldv_params, sizeof(LDV_PARAMS) ) ;
    in_out.RasterFormat = LDVF_SPECFORMAT ;
    in_out.Raster.fd_addr = NULL ;
    raster_duplicate( &wext->src, &in_out.Raster ) ;
    if ( caps && (caps->Flags & LDVF_AFFECTPALETTE) )
    {
      in_out.Palette.NbColors = (short) vimage->inf_img.nb_cpal ;
      if ( in_out.Palette.NbColors )
      {
        int taille = in_out.Palette.NbColors * (int)sizeof(VDI_ELEMENTPAL) ;

        in_out.Palette.Pal = (VDI_ELEMENTPAL*) Xalloc( taille ) ;
        if ( in_out.Palette.Pal == NULL ) return ;
        memcpy( in_out.Palette.Pal, vimage->inf_img.palette, taille ) ;
        alloc_pal_ori = in_out.Palette.Pal ;
      }
    }

    err = LDVDo( ldv, &wext->ldv_params, &in_out, LDVDOF_PREVIEW ) ;
    if ( LDV_SUCCESS( err ) )
    {
      int x0, y0, w0, h0 ;

      wext->flags &= ~FLG_LDVERR ;
      if ( wext->dst.fd_w < in_out.Raster.fd_w )
      {
        xc = 0 ;
        x0 = ( in_out.Raster.fd_w - wext->dst.fd_w ) >> 1 ;
        w0 = wext->dst.fd_w ;
      }
      else
      {
        xc = ( wext->dst.fd_w - in_out.Raster.fd_w ) >> 1 ;
        x0 = 0 ;
        w0 = in_out.Raster.fd_w ;
      }
      
      if ( wext->dst.fd_h < in_out.Raster.fd_h )
      {
        yc = 0 ;
        y0 = ( in_out.Raster.fd_h - wext->dst.fd_h ) >> 1 ;
        h0 = wext->dst.fd_h ;
      }
      else
      {
        yc = ( wext->dst.fd_h - in_out.Raster.fd_h ) >> 1 ;
        y0 = 0 ;
        h0 = in_out.Raster.fd_h ;
      }
      xy[0] = x0 ;
      xy[1] = y0 ;
      xy[2] = x0 + w0 - 1 ;
      xy[3] = y0 + h0 - 1 ;
      xy[4] = xc ;
      xy[5] = yc ;
      xy[6] = xy[4] + xy[2] - xy[0] ;
      xy[7] = xy[5] + xy[3] - xy[1] ;
      if ( (wext->dst.fd_h != in_out.Raster.fd_h) || (wext->dst.fd_w != in_out.Raster.fd_w) )
        img_raz( &wext->dst ) ;
      LDVAdapt2Planes( &in_out, wext->dst.fd_nplanes ) ;
      svro_cpyfmSO( xy, &in_out.Raster, &wext->dst ) ;
    }
    else wext->flags |= FLG_LDVERR ;

    if ( in_out.Raster.fd_addr ) Xfree( in_out.Raster.fd_addr ) ;
  }

  if ( LDV_SUCCESS( err ) && caps && (caps->Flags & LDVF_AFFECTPALETTE) )
  {
    void* tmp = vimage->inf_img.palette ;

    vimage->inf_img.palette = in_out.Palette.Pal ;
    set_imgpalette( vimage ) ;
    vimage->inf_img.palette = tmp ;
    wext->flags |= FLG_PALETTECHANGED ;
  }

  if ( display ) GWObjcDraw( wnd, bobj, LDVA_DST ) ;

  if ( in_out.Palette.Pal ) Xfree( in_out.Palette.Pal ) ;
  if ( alloc_pal_ori && (alloc_pal_ori != in_out.Palette.Pal) ) Xfree( alloc_pal_ori ) ; /* Palette has been re-allocated somewhere (e.g. dither.c) */

  /* Si le LDV a modifie les parametres, les mettre a jour */
  for ( i = 0; i < ldv_params.NbParams; i++ )
    if ( (ldv_params.ParamType[i] == LDVT_SHORT) && (ldv_params.Param[i].s != wext->ldv_params.Param[i].s ) )
    {
      SldNumSetVal( &wext->NumSld[i], wext->ldv_params.Param[i].s ) ;
      GWObjcDraw( wnd, bobj, wext->NumSld[i].IdBox ) ;
      GWObjcDraw( wnd, bobj, wext->NumSld[i].IdCurrentVal ) ;
    }
}

static void UpdateSrc(GEM_WINDOW* wnd)
{
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;
  VXIMAGE*            vximage = wext->wimg->Extension ;
  OBJECT*             bobj = wnd->DlgData->BaseObject ;
  MFDB                temp, *org ;
  float               pc, pcy ;
  int                 xy[8] ;

  if ( wext->src.fd_addr ) Xfree( wext->src.fd_addr ) ;
  wext->src.fd_addr = NULL ;
  org = &vximage->inf_img.mfdb ;

  wext->src.fd_w = bobj[LDVA_SRC].ob_width ;
  wext->src.fd_h = bobj[LDVA_SRC].ob_height ;
  wext->src.fd_wdwidth = W2WDWIDTH( wext->src.fd_w ) ;
  wext->src.fd_nplanes = vximage->inf_img.mfdb.fd_nplanes ;
  wext->src.fd_addr = img_alloc( wext->src.fd_w, wext->src.fd_h, wext->src.fd_nplanes ) ;
  if ( wext->src.fd_addr )
  {
    img_raz( &wext->src ) ;
    pc  = (float)wext->src.fd_w / (float) org->fd_w ;
    pcy = (float)wext->src.fd_h / (float) org->fd_h ;
    if ( pcy < pc ) pc = pcy ;
    temp.fd_addr = NULL ;
    temp.fd_w    = (int) ( 0.5 + (float)org->fd_w * pc ) ;
    temp.fd_h    = (int) ( 0.5 + (float)org->fd_h * pc ) ;
    if ( RasterZoom( org, &temp, NULL ) == 0 )
    {
      wext->xc = ( wext->src.fd_w - temp.fd_w ) >> 1 ;
      wext->yc = ( wext->src.fd_h - temp.fd_h ) >> 1 ;
      wext->wc = temp.fd_w ;
      wext->hc = temp.fd_h ;
      xy[0]    = xy[1] = 0 ;
      xy[2]    = temp.fd_w - 1 ;
      xy[3]    = temp.fd_h - 1 ;
      xy[4]    = wext->xc ;
      xy[5]    = wext->yc ;
      xy[6]    = wext->xc + temp.fd_w - 1 ;
      xy[7]    = wext->yc + temp.fd_h - 1 ;
      svro_cpyfmSO( xy, &temp, &wext->src ) ;
      Xfree( temp.fd_addr ) ;
    }
  }
}

static void DisplayParam(GEM_WINDOW* wnd, int param_no, int display)
{
  OBJECT* bobj  = wnd->DlgData->BaseObject ;
  int     nb_obj = LDVA_LESS2 - LDVA_LESS1 ;
  int     obj_start, i ;

  obj_start = LDVA_LIMITD1 + ( param_no - 1 ) * nb_obj ;
  for ( i = obj_start; i < obj_start + nb_obj; i++ )
  {
    if ( display ) bobj[i].ob_flags &= ~HIDETREE ;
    else           bobj[i].ob_flags |= HIDETREE ;
  }
}

static void InitParamObjs(GEM_WINDOW* wnd)
{
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;
  OBJECT*             bobj = wnd->DlgData->BaseObject ;
  LDV_MODULE*         ldv  = wext->ldv ;
  int                 i ;
  int                 obj_offset ;
  int                 nb_obj = LDVA_LESS2 - LDVA_LESS1 ;
  char                buf[30] ;

  for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
  {
    obj_offset = i * nb_obj ;
    if ( ConsiderLDVParam( &ldv->IniSpec.Params[i] ) )
    {
      wext->NumSld[i].Obj          = bobj ;
      wext->NumSld[i].HAlign       = 1 ;
      wext->NumSld[i].IdBLess      = obj_offset + LDVA_LESS1 ;
      wext->NumSld[i].IdBox        = obj_offset + LDVA_BOX1 ;
      wext->NumSld[i].IdSlider     = obj_offset + LDVA_SLD1 ;
      wext->NumSld[i].IdBPlus      = obj_offset + LDVA_PLUS1 ;
      wext->NumSld[i].IdTitle      = obj_offset + LDVA_PARAM1 ;
      wext->NumSld[i].IdValMin     = obj_offset + LDVA_LIMITD1 ;
      wext->NumSld[i].IdValMax     = obj_offset + LDVA_LIMITU1 ;
      wext->NumSld[i].IdCurrentVal = obj_offset + LDVA_VAL1 ;
      wext->NumSld[i].Val          = ldv->IniSpec.Params[i].DefaultValue.s ;
      wext->NumSld[i].ValMin       = ldv->IniSpec.Params[i].MinValue.s ;
      wext->NumSld[i].ValMax       = ldv->IniSpec.Params[i].MaxValue.s ;
      wext->NumSld[i].Labels       = ldv->IniSpec.ParamLabels[i] ;
      LoggingDo(LL_DEBUG, "LDVParam#%d: min=%d, def=%d, max=%d, labels=%s", i, wext->NumSld[i].ValMin, wext->NumSld[i].Val, wext->NumSld[i].ValMax, wext->NumSld[i].Labels ? wext->NumSld[i].Labels:"<None>") ;
      CreateNumSld( &wext->NumSld[i] ) ;
      SldNumSetVal( &wext->NumSld[i], wext->NumSld[i].Val ) ;
      sprintf( buf, "%d", wext->NumSld[i].ValMin ) ;
      write_text( bobj, obj_offset + LDVA_LIMITD1, buf ) ;
      sprintf( buf, "%d", wext->NumSld[i].ValMax ) ;
      write_text( bobj, obj_offset + LDVA_LIMITU1, buf ) ;
      write_text( bobj, obj_offset + LDVA_PARAM1, ldv->IniSpec.Params[i].Name ) ;
    }
    else
    {
      DisplayParam( wnd, i+1, 0 ) ; /* Hide the corresponding GUI parameters */
      if ( (wext->te_ptmplt[0] == 0) && (ldv->IniSpec.Params[i].Type == LDVT_TEXT) ) /* wext is zeroed at start */
      {
        /* Let's trick the G_TEXT type a little bit to enable user to seize his/her text ... */
        OBJECT*  obj = &bobj[obj_offset + LDVA_PARAM1] ;
        TEDINFO* ted = obj->ob_spec.tedinfo ;

        obj->ob_type    = G_FBOXTEXT ;
        obj->ob_flags  &= ~HIDETREE ;
        obj->ob_flags  |= EDITABLE ;
        obj->ob_x       = 8 ;
        obj->ob_width   = bobj[0].ob_width-40 ;
        obj->ob_y      -= 8 ;
        obj->ob_height += 8 ;
        ted->te_font    = 3 ; /* Normal size */
        ted->te_just    = 0 ; /* Left aligned */
        ted->te_ptext   = wext->te_ptext ;
        ted->te_txtlen  = sizeof(wext->te_ptext)-1 ;
        ted->te_ptmplt  = wext->te_ptmplt ;
        ted->te_tmplen  = sizeof(wext->te_ptmplt)-1 ;
        memset( ted->te_ptmplt, '_', ted->te_tmplen ) ;  /* Next char is already 0 as wext is zeroed when created */
        ted->te_pvalid = wext->te_pvalid ;
        ted->te_pvalid[0] = 'X' ; /* Next char is already 0 as wext is zeroed when created */
        write_text( bobj, obj_offset + LDVA_PARAM1, ldv->IniSpec.Params[i].Name ) ;

        /* And use LDVA_PLUS1 of this 'slider' for an advanced edit button */
        obj = &bobj[obj_offset + LDVA_PLUS1] ;
        obj->ob_spec.free_string[0] = '+' ; obj->ob_spec.free_string[1] = 0 ;
        obj->ob_flags  &= ~HIDETREE ;
        obj->ob_x       = bobj[0].ob_width-24 ;
        obj->ob_y      += 8 ;
      }
    }
  }
}

static void GetPreviewSize(int* src, int* dst)
{
  *src = config.ldv_preview_src_size ;
  *dst = config.ldv_preview_dst_size ;
  if ( *dst < MIN_PREVIEW_SIZE ) *dst = MIN_PREVIEW_SIZE ;
  if ( (*src != 0) && (*src != *dst) ) *src = *dst ;
}

static void SetupGUI(GEM_WINDOW* wnd)
{
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;
  OBJECT*             bobj = wnd->DlgData->BaseObject ;
  LDV_MODULE*         ldv  = wext->ldv ;
  int                 dx, dx1, dy, dsize, psrc_size, pdst_size ;
  int                 preview_size, preview_max_size, w_max, h_max ;
  int                 i, j, hreduction, nb_obj_params, part ;

  wext->nb_params = 0 ;
  for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
    if ( ldv->IniSpec.Params[i].Name[0] != 0 ) wext->nb_params++ ;

  w_max = ( wdesk - 16 ) >> 1 ;
  w_max &= 0xFFF0 ; /* Multiple de 16 */
  h_max  = hdesk - 32 - ( bobj[0].ob_height - ( bobj[LDVA_OK].ob_y - 16 ) ) ;
  h_max -= ( bobj[LDVA_LESS2].ob_y - bobj[LDVA_LESS1].ob_y ) * wext->nb_params ;
  h_max &= 0xFFF0 ; /* Multiple de 16 */
  if ( h_max > w_max ) preview_max_size = w_max - 16 ;
  else                 preview_max_size = h_max - 16 ;

  if ( preview_max_size < MIN_PREVIEW_SIZE ) preview_max_size = MIN_PREVIEW_SIZE ;

  GetPreviewSize( &psrc_size, &pdst_size ) ;
  preview_size = psrc_size + pdst_size ;
  if ( preview_size > preview_max_size ) preview_size = preview_max_size ;
  bobj[0].ob_width += preview_size - ( bobj[LDVA_SRC].ob_width + bobj[LDVA_DST].ob_width ) ;
  if ( bobj[0].ob_width < 240 ) bobj[0].ob_width = 240 ;

  dy = bobj[LDVA_DST].ob_height ;
  if ( psrc_size > 0 )
  {
    psrc_size  = preview_size >> 1 ;
    psrc_size &= 0xFFF0 ; /* Multiple de 16 */
    pdst_size  = psrc_size ;
    dsize      = psrc_size - bobj[LDVA_SRC].ob_width ;
    bobj[LDVA_SRC].ob_width  += dsize ;
    bobj[LDVA_SRC].ob_height += dsize ;
    bobj[LDVA_DST].ob_x       = dsize + ( bobj[LDVA_DST].ob_x - bobj[LDVA_SRC].ob_x ) + 8 ;
    bobj[LDVA_DST].ob_width  += dsize ;
    bobj[LDVA_DST].ob_height += dsize ;
  }
  else
  { /* Pas d'affichage de la source */
    wext->flags |= FLG_NOSRCDISPLAY ;
    bobj[LDVA_SRC].ob_width  = preview_size ;
    bobj[LDVA_SRC].ob_height = preview_size ;
    bobj[LDVA_DST].ob_width  = preview_size ;
    bobj[LDVA_DST].ob_height = preview_size ;
    bobj[LDVA_DST].ob_x      = ( bobj[0].ob_width - bobj[LDVA_DST].ob_width ) >> 1 ;
  }

  dy -= bobj[LDVA_DST].ob_height ;
  bobj[LDVA_TSEL].ob_y -= dy ;
  bobj[LDVA_SEL].ob_y  -= dy ;
  nb_obj_params = LDVA_LIMITD2 - LDVA_LIMITD1 ;
  dx1 = bobj[LDVA_PLUS1].ob_x - ( bobj[LDVA_BOX1].ob_x + bobj[LDVA_BOX1].ob_width ) ;
  dx  = bobj[0].ob_width - ( bobj[LDVA_PLUS1].ob_x + bobj[LDVA_PLUS1].ob_width ) - 8 ;
  for ( j=0; j < wext->nb_params; j++ )
  {
    i = j * nb_obj_params ;
    bobj[LDVA_LESS1+i].ob_y    -= dy ;
    bobj[LDVA_BOX1+i].ob_y     -= dy ;
    bobj[LDVA_PLUS1+i].ob_y    -= dy ;
    bobj[LDVA_PARAM1+i].ob_y   -= dy ;
    bobj[LDVA_LIMITD1+i].ob_y  -= dy ;
    bobj[LDVA_LIMITU1+i].ob_y  -= dy ;
    bobj[LDVA_VAL1+i].ob_y     -= dy ;
    bobj[LDVA_BOX1+i].ob_width += dx ;
    bobj[LDVA_PLUS1+i].ob_x     = bobj[LDVA_BOX1+i].ob_x + bobj[LDVA_BOX1+i].ob_width + dx1 ;
    bobj[LDVA_PARAM1+i].ob_x    = bobj[LDVA_BOX1+i].ob_x + ( bobj[LDVA_BOX1+i].ob_width - bobj[LDVA_PARAM1+i].ob_width ) >> 1 ;
    bobj[LDVA_LIMITU1+i].ob_x   = bobj[LDVA_BOX1+i].ob_x + bobj[LDVA_BOX1+i].ob_width - bobj[LDVA_LIMITU1+i].ob_width ;
    bobj[LDVA_VAL1+i].ob_x      = bobj[LDVA_BOX1+i].ob_x + ( bobj[LDVA_BOX1+i].ob_width - bobj[LDVA_VAL1+i].ob_width ) >> 1 ;
  }

  bobj[LDVA_TITLE].ob_x   = ( bobj[0].ob_width - bobj[LDVA_TITLE].ob_width ) >> 1 ;
  hreduction              = bobj[0].ob_height - bobj[LDVA_OK].ob_y ;
  if ( wext->nb_params > 0 ) bobj[0].ob_height = bobj[LDVA_BOX1+i].ob_y + bobj[LDVA_BOX1+i].ob_height + 8 + bobj[LDVA_OK].ob_height + hreduction ;
  else                       bobj[0].ob_height = bobj[LDVA_DST].ob_y + bobj[LDVA_DST].ob_height + 8 + bobj[LDVA_OK].ob_height + hreduction ;
  bobj[LDVA_OK].ob_y      = bobj[0].ob_height - hreduction ;
  bobj[LDVA_PREVIEW].ob_y = bobj[0].ob_height - hreduction ;
  bobj[LDVA_CANCEL].ob_y  = bobj[0].ob_height - hreduction ;

  part = (bobj[0].ob_width-16-bobj[LDVA_OK].ob_width-bobj[LDVA_PREVIEW].ob_width-bobj[LDVA_CANCEL].ob_width) >> 2 ;
  if ( part < 0 ) part = 0 ;
  bobj[LDVA_OK].ob_x      = part ;
  bobj[LDVA_PREVIEW].ob_x = bobj[LDVA_OK].ob_x + bobj[LDVA_OK].ob_width + part ;
  bobj[LDVA_CANCEL].ob_x  = bobj[LDVA_PREVIEW].ob_x + bobj[LDVA_PREVIEW].ob_width + part ;
}

#pragma warn -par
static int OnTimer(void* w, int mx, int my)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;

  if ( wext->flags & FLG_TEXTCHANGE )
  {
    DoLDVPreview( wnd, 1 ) ;
    wext->flags &= ~FLG_TEXTCHANGE ;
  }

  return 0 ;
}

static int OnEditField(void* w, int edit_id)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;

  wext->flags |= FLG_TEXTCHANGE ; /* Just to trig refresh on next timer tick */

  return 0 ;
}
#pragma warn +par

static void OnInitDialog(void* w)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;
  VXIMAGE*            vximage = wext->wimg->Extension ;
  OBJECT*             bobj = wnd->DlgData->BaseObject ;

  SetupGUI( wnd ) ;

  bobj[LDVA_SRC].ob_spec.userblk->ub_code = draw_src ;
  bobj[LDVA_SRC].ob_spec.userblk->ub_parm = (long) wext ;
  bobj[LDVA_DST].ob_spec.userblk->ub_code = draw_dst ;
  bobj[LDVA_DST].ob_spec.userblk->ub_parm = (long) wext ;

  UpdateSrc( wnd ) ;
  wext->caps = LDVGetNPlanesCaps( wext->ldv, wext->src.fd_nplanes ) ;

  if ( vclip.gwindow == wext->wimg )
  {
    bobj[LDVA_SEL].ob_state  &= ~DISABLED ;
    bobj[LDVA_TSEL].ob_state &= ~DISABLED ;
    select( bobj, LDVA_SEL ) ;
  }
  else
  {
    bobj[LDVA_SEL].ob_flags  |= HIDETREE ;
    bobj[LDVA_TSEL].ob_flags |= HIDETREE ;
  }

  InitParamObjs( wnd ) ;

  if ( wext->caps && (wext->caps->Flags & LDVF_SUPPORTPREVIEW) )
  {
    wext->dst.fd_w       = bobj[LDVA_DST].ob_width ;
    wext->dst.fd_h       = bobj[LDVA_DST].ob_height ;
    wext->dst.fd_wdwidth = W2WDWIDTH( wext->dst.fd_w ) ;
    wext->dst.fd_nplanes = vximage->inf_img.mfdb.fd_nplanes ;
    wext->dst.fd_addr    = img_alloc( wext->dst.fd_w, wext->dst.fd_h, wext->dst.fd_nplanes ) ;
    if ( wext->dst.fd_addr ) img_raz( &wext->dst ) ;
    bobj[LDVA_PREVIEW].ob_state &= ~DISABLED ;

    DoLDVPreview( wnd, 0 ) ;
  }
  else bobj[LDVA_PREVIEW].ob_state |= DISABLED ;

  if ( wext->caps->Flags & LDVF_REALTIMEPARAMS )
  {
    wnd->OnTimer = OnTimer ;
    GWSetTimer( wnd, 300, NULL ) ;
  }
}

static void RedrawGUI1(GEM_WINDOW* wnd, int obj_clicked, int obj, NUM_SLD* num_sld)
{
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;
  OBJECT*             bobj = wnd->DlgData->BaseObject ;
  LDV_CAPS*           caps = wext->caps ;

  deselect( bobj, obj_clicked ) ;
  GWObjcDraw( wnd, bobj, obj_clicked ) ;
  GWObjcDraw( wnd, bobj, num_sld->IdCurrentVal ) ;
  GWObjcDraw( wnd, bobj, num_sld->IdBox ) ;
  if ( caps->Flags & LDVF_REALTIMEPARAMS )
  {
    DoLDVPreview( wnd, 1 ) ;
    GWObjcDraw( wnd, bobj, obj ) ;
  }
}

static int EditAdvancedText(WEXTENSION_FAPPLDV* wext)
{
  MLINES_PARAMS mlp ;
  char*         c = wext->te_ptext ;
  int           nl ;
  int           i, loff, code ;

  memzero( &mlp, sizeof(MLINES_PARAMS) ) ;
  nl = loff = 0 ;
  while ( *c && (nl < MLP_LINEMAX) )
  {
    /* Copy current text */
    if ( *c == '\n' ) { nl++ ; loff = 0 ; }
    else              mlp.mesg[nl][loff++] = *c ;
    c++ ;
  }
  strncpy( mlp.title, vMsgTxtGetMsg(MSG_EDITADVTEXT), sizeof(mlp.title)-1 ) ;
  strcpy( mlp.ok_caption, "OK" ) ;
  strcpy( mlp.cancel_caption, vMsgTxtGetMsg(MSG_CANCEL) ) ;
  strcpy( mlp.templates_caption, vMsgTxtGetMsg(MSG_TEMPLATES) ) ;
  sprintf( mlp.templates_filemask, "%s\\*.ATT", config.path_ldv ) ;
  mlp.show_alllines = 1 ;
  code = FormStdMLines( &mlp ) ;
  if ( code == IDOK )
  {
    /* Copy advanced text after edit */
    char* lastc ;

    c     = wext->te_ptext ;
    lastc = c + sizeof(wext->te_ptext)-1 ;
    memzero( c, sizeof(wext->te_ptext) ) ;
    for ( i=0; (c < lastc) && (i < MLP_NLINES); i++ )
    {
      char* src = &mlp.mesg[i][0] ;

      if ( *src && i ) *c++ = '\n' ; /* This line is not empty, let's sdd a '\n' */
      while ( *src && (c < lastc) ) *c++ = *src++ ;
    }
  }

  return code ;
}

static int OnObjectNotify(void* w, int obj)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;
  LDV_MODULE*         ldv  = wext->ldv ;
  VXIMAGE*            vximage = wext->wimg->Extension ;
  OBJECT*             bobj = wnd->DlgData->BaseObject ;
  NUM_SLD*            num_sld ;
  int                 obj_clicked, nsld, mx, my, dummy ;
  int                 code = -1 ;

  graf_mkstate( &mx, &my, &dummy, &dummy ) ;
  obj_clicked = obj ;
  if ( (obj >= LDVA_LESS1) && (obj < LDVA_OK) )
  {
    obj    -= LDVA_LESS1 ;
    nsld    = obj / (LDVA_LESS2-LDVA_LESS1) ;
    num_sld = &wext->NumSld[nsld] ;
    obj     = LDVA_LESS1 + (obj % (LDVA_LESS2-LDVA_LESS1) ) ;
  }

  switch( obj )
  {
     case LDVA_LESS1   : SldNumGetVal( num_sld ) ;
                         SldNumSetVal( num_sld, num_sld->Val - 1 ) ;
                         RedrawGUI1( wnd, obj_clicked, obj, num_sld ) ;
                         break ;

     case LDVA_PLUS1   : if ( ldv->IniSpec.Params[nsld].Type == LDVT_TEXT ) /* Special case as this button is also used to trig advanced edit for a text parameter */
                         {
                           if ( EditAdvancedText( wext ) == IDOK )
                           {
                             write_text( bobj, nsld*(LDVA_LESS2-LDVA_LESS1) + LDVA_PARAM1, wext->te_ptext ) ;
                             deselect( bobj, obj_clicked ) ;
                             GWObjcDraw( wnd, bobj, obj_clicked ) ;
                             GWObjcDraw( wnd, bobj, nsld*(LDVA_LESS2-LDVA_LESS1) + LDVA_PARAM1 ) ;
                             if ( wext->caps->Flags & LDVF_REALTIMEPARAMS ) DoLDVPreview( wnd, 1 ) ;
                           }
                         }
                         else
                         {
                           SldNumGetVal( num_sld ) ;
                           SldNumSetVal( num_sld, num_sld->Val + 1 ) ;
                           RedrawGUI1( wnd, obj_clicked, obj, num_sld ) ;
                         }
                         break ;

     case LDVA_BOX1    : SldNumClickBox( num_sld, mx, my ) ;
                         RedrawGUI1( wnd, obj_clicked, obj, num_sld ) ;
                         break ;

     case LDVA_SLD1    : SldNumMoveSlider( num_sld ) ;
                         RedrawGUI1( wnd, obj_clicked, obj, num_sld ) ;
                         break ;

     case LDVA_TSEL    :
     case LDVA_SEL     : inv_select( bobj, LDVA_SEL ) ;
                         GWObjcDraw( wnd, bobj, LDVA_SEL ) ;
                         UpdateSrc( wnd ) ;
                         DoLDVPreview( wnd, 1 ) ;
                         GWObjcDraw( wnd, bobj, LDVA_SRC ) ;
                         break ;

    case LDVA_PREVIEW  : deselect( bobj, obj ) ;
                         for ( nsld = 0; nsld < wext->nb_params; nsld++ )
                         {
                           if ( ldv->IniSpec.Params[nsld].Type == LDVT_SHORT )
                           {
                             num_sld = &wext->NumSld[nsld] ;
                             SldNumGetVal( num_sld ) ;
                             GWObjcDraw( wnd, bobj, num_sld->IdCurrentVal ) ;
                             GWObjcDraw( wnd, bobj, num_sld->IdBox ) ;
                           }
                         }
                         DoLDVPreview( wnd, 1 ) ;
                         GWObjcDraw( wnd, bobj, obj ) ;
                         break ;

     case LDVA_OK      : code = IDOK ;
                         break ;

     case LDVA_CANCEL  : code = IDCANCEL ;
                         break ;
  }

  if ( code == IDOK )
  {
    removeCRCF( wext->te_ptext ) ; /* If we have a TEXT type, let's remove all CR/CF */
    GetLDVParams( wnd, &wext->ldv_params ) ;
    /* Remise a jour des parametres de position dans l'image source */
    if ( selected( bobj, LDVA_SEL ) )
    {
      wext->ldv_params.x1 = vclip.x1 ;
      wext->ldv_params.y1 = vclip.y1 ;
      wext->ldv_params.x2 = vclip.x2 ;
      wext->ldv_params.y2 = vclip.y2 ;
    }
    else
    {
      wext->ldv_params.x1 = 0 ;
      wext->ldv_params.y1 = 0 ;
      wext->ldv_params.x2 = vximage->inf_img.mfdb.fd_w - 1 ;
      wext->ldv_params.y2 = vximage->inf_img.mfdb.fd_h - 1 ;
    }
  }

  return code ;
}

static int OnClose(void* w)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FAPPLDV* wext = wnd->DlgData->UserData ;

  if ( wext->dst.fd_addr ) Xfree( wext->dst.fd_addr ) ;
  if ( wext->src.fd_addr ) Xfree( wext->src.fd_addr ) ;

  if ( wext->caps->Flags & LDVF_REALTIMEPARAMS ) GWKillTimer( wnd ) ;

  return( GWCloseDlg( w ) ) ;
}

int ApplyLDV(LDV_MODULE* ldv, GEM_WINDOW* wnd, LDV_PARAMS* p)
{
  WEXTENSION_FAPPLDV wext ;
  DLGDATA            dlg_data ;
  int                code ;

  memzero( &wext, sizeof(WEXTENSION_FAPPLDV) ) ;
  GWZeroDlgData( &dlg_data ) ;
  wext.wimg               = wnd ;
  wext.ldv                = ldv ;
  dlg_data.RsrcId         = FORM_LDVAPPLY ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialog ;
  dlg_data.OnObjectNotify = OnObjectNotify ;
  dlg_data.OnCloseDialog  = OnClose ;
  dlg_data.OnEditField    = OnEditField ;

  code = GWCreateAndDoModal( &dlg_data, ldv->IniSpec.Params[0].Name[0] ? LDVA_VAL1:0 ) ;
  if ( (code == IDCANCEL) && (wext.flags & FLG_PALETTECHANGED) ) set_imgpalette( (VXIMAGE*) wnd->Extension ) ;

  memcpy( p, &wext.ldv_params, sizeof(LDV_PARAMS) ) ; /* Not only if IDOK as some text type may have to be freed */

  return code ;
}
