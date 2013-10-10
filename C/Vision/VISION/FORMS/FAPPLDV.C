#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"
#include "..\tools\numsld.h"
#include "..\tools\rzoom.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

#include "fappldv.h"
#include "actions.h"

#define FLG_NOSRCDISPLAY 1
typedef struct
{
  LDV_MODULE *ldv ;
  LDV_PARAMS ldv_params ;
  LDV_CAPS   *caps ; /* Pour le nombre de plans en question */
  GEM_WINDOW *wimg ;
  MFDB       src ;
  int        xc, yc, wc, hc ; /* Offsets et longueurs pour src */
  MFDB       dst ;
  int        flags ;

  NUM_SLD    NumSld[LDVNBMAX_PARAMETERS] ;
  int        nb_params ;
}
WEXTENSION_FAPPLDV ;

#define MIN_PREVIEW_SIZE 48

void draw_img(PARMBLK *parmblock, MFDB *img)
{
  int xy[8] ;
  int cxy[4] ;

  if ( intersect( parmblock->pb_xc, parmblock->pb_yc, parmblock->pb_wc, parmblock->pb_hc,
                  parmblock->pb_x,  parmblock->pb_y,  parmblock->pb_w,  parmblock->pb_h,
                  &xy[4] ) )
  {
    v_hide_c( handle ) ;
    if ( img->fd_addr )
    {
      xy[0] = xy[4] - parmblock->pb_x ;
      xy[1] = xy[5] - parmblock->pb_y ;
      xy[2] = xy[0] + xy[6] - xy[4] ;
      xy[3] = xy[1] + xy[7] - xy[5] ;
      vro_cpyfm(handle, S_ONLY, xy, img, &screen) ;
    }
    else
    {
      cxy[0] = parmblock->pb_xc ;
      cxy[1] = parmblock->pb_yc ;
      cxy[2] = parmblock->pb_xc + parmblock->pb_wc - 1 ;
      cxy[3] = parmblock->pb_yc + parmblock->pb_hc - 1 ;
      vs_clip( handle, 1, cxy ) ;
      vsl_ends( handle, 0, 0 ) ;
      vsl_width( handle, 3 ) ;
      vsl_color( handle, 1 ) ;
      line( parmblock->pb_x + parmblock->pb_w -1, parmblock->pb_y, parmblock->pb_x, parmblock->pb_y + parmblock->pb_h - 1  ) ;
      line( parmblock->pb_x, parmblock->pb_y, parmblock->pb_x + parmblock->pb_w -1, parmblock->pb_y + parmblock->pb_h - 1 ) ;
      vs_clip( handle, 0, cxy ) ;
    }
    v_show_c( handle, 1 ) ;
  }
}

int cdecl draw_src(PARMBLK *parmblock)
{
  WEXTENSION_FAPPLDV *wext = (WEXTENSION_FAPPLDV *) parmblock->pb_parm ;

  if ( ( wext->flags & FLG_NOSRCDISPLAY ) == 0 ) draw_img( parmblock, &wext->src ) ;

  return( 0 ) ;
}

int cdecl draw_dst(PARMBLK *parmblock)
{
  WEXTENSION_FAPPLDV *wext = (WEXTENSION_FAPPLDV *) parmblock->pb_parm ;

  draw_img( parmblock, &wext->dst ) ;

  return( 0 ) ;
}

void GetLDVParams(GEM_WINDOW *wnd, LDV_PARAMS *params)
{
  WEXTENSION_FAPPLDV *wext = wnd->DlgData->UserData ;
  LDV_MODULE         *ldv = wext->ldv ;
  OBJECT             *bobj = wnd->DlgData->BaseObject ;
  VXIMAGE            *vximage = wext->wimg->Extension ;
  float              ratio, yratio ;
  int                i ;

  memset( params, 0, sizeof(LDV_PARAMS) ) ;

  /* Recuperation du bloc a traiter */
  if ( selected( bobj, LDVA_SEL ) )
  {
    ratio  = (float)wext->wc / (float)vximage->raster.fd_w ;
    yratio = (float)wext->hc / (float)vximage->raster.fd_h ;
    if ( yratio < ratio ) ratio = yratio ;
    params->x1 = wext->xc + (int) (ratio * vclip.x1) ;
    params->y1 = wext->yc + (int) (ratio * vclip.y1) ;
    params->x2 = wext->xc + (int) (ratio * vclip.x2) ;
    params->y2 = wext->yc + (int) (ratio * vclip.y2) ;
  }
  else
  {
    /* Image entiere */
    params->x1 = 0 ; /* wext->xc ; */
    params->y1 = 0 ; /* wext->yc ; */
    params->x2 = wext->src.fd_w - 1 ; /* wext->xc + wext->wc - 1 ; */
    params->y2 = wext->src.fd_h - 1 ; /* wext->yc + wext->hc - 1 ; */
  }

  /* Recuperation des parametres du LDV */
  params->NbParams = 0 ;
  for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
  {
    if ( ldv->IniSpec.Params[i].Name[0] != 0 )
    {
      params->NbParams++ ;
      params->Param[i].s = wext->NumSld[i].Val ;
    }
  }
}

void DoLDVPreview(GEM_WINDOW *wnd, int display)
{
  WEXTENSION_FAPPLDV *wext = wnd->DlgData->UserData ;
  VXIMAGE            *vimage = (VXIMAGE*) wext->wimg->Extension ;
  OBJECT             *bobj = wnd->DlgData->BaseObject ;
  LDV_PARAMS         ldv_params ;
  LDV_IMAGE          in_out ;
  LDV_MODULE         *ldv = wext->ldv ;
  LDV_CAPS           *caps ;
  LDV_STATUS         err ;
  int                xy[8] ;
  int                i, xc, yc, taille ;

  caps = LDVGetNPlanesCaps( ldv, nb_plane ) ;
  memset( &in_out, 0, sizeof(LDV_IMAGE) ) ;
  if ( wext->src.fd_addr && wext->dst.fd_addr )
  {
    GetLDVParams( wnd, &wext->ldv_params ) ;
    memcpy( &ldv_params, &wext->ldv_params, sizeof(LDV_PARAMS) ) ;
    in_out.RasterFormat = LDVF_SPECFORMAT ;
    in_out.Raster.fd_addr = NULL ;
    raster_duplicate( &wext->src, &in_out.Raster ) ;
    if ( caps && ( caps->Flags & LDVF_AFFECTPALETTE ) )
    {
      in_out.Palette.NbColors = (short) vimage->inf_img.nb_cpal ;
      taille = in_out.Palette.NbColors * (int)sizeof(VDI_ELEMENTPAL) ;
      in_out.Palette.Pal      = (VDI_ELEMENTPAL *) malloc( taille ) ;
      if ( in_out.Palette.Pal == NULL ) return ;
      memcpy( in_out.Palette.Pal, vimage->inf_img.palette, taille ) ;
    }

    err = LDVDo( ldv, &wext->ldv_params, &in_out, 1, NULL ) ;
    if ( LDV_SUCCESS( err ) )
    {
      int x0, y0, w0, h0 ;

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
      if ( ( wext->dst.fd_h != in_out.Raster.fd_h ) || ( wext->dst.fd_w != in_out.Raster.fd_w ) )
        img_raz( &wext->dst ) ;
      vro_cpyfm( handle, S_ONLY, xy, &in_out.Raster, &wext->dst ) ;
    }
    if ( in_out.Raster.fd_addr ) free( in_out.Raster.fd_addr ) ;
  }

  if ( caps && ( caps->Flags & LDVF_AFFECTPALETTE ) )
  {
    void *tmp = vimage->inf_img.palette ;

    vimage->inf_img.palette = in_out.Palette.Pal ;
    set_imgpalette( vimage ) ;
    vimage->inf_img.palette = tmp ;
  }

  if ( display )
    xobjc_draw( wnd->window_handle, bobj, LDVA_DST ) ;

  if ( in_out.Palette.Pal ) free( in_out.Palette.Pal ) ;

  /* Si le LDV a modifie les parametres, les mettre a jour */
  for ( i = 0; i < ldv_params.NbParams; i++ )
    if ( ldv_params.Param[i].s != wext->ldv_params.Param[i].s )
    {
      SldNumSetVal( &wext->NumSld[i], wext->ldv_params.Param[i].s ) ;
      xobjc_draw( wnd->window_handle, bobj, wext->NumSld[i].IdBox ) ;
      xobjc_draw( wnd->window_handle, bobj, wext->NumSld[i].IdCurrentVal ) ;
    }
}

void UpdateSrc(GEM_WINDOW *wnd)
{
  WEXTENSION_FAPPLDV *wext = wnd->DlgData->UserData ;
  VXIMAGE            *vximage = wext->wimg->Extension ;
  OBJECT             *bobj = wnd->DlgData->BaseObject ;
  MFDB               temp, *org ;
  float              pc, pcy ;
  int                xy[8] ;

  if ( wext->src.fd_addr ) free( wext->src.fd_addr ) ;
  wext->src.fd_addr = NULL ;
  org = &vximage->raster ;

  wext->src.fd_w = bobj[LDVA_SRC].ob_width ;
  wext->src.fd_h = bobj[LDVA_SRC].ob_height ;
  wext->src.fd_wdwidth = wext->src.fd_w / 16 ;
  if ( wext->src.fd_w % 16 ) wext->src.fd_wdwidth++ ;
  wext->src.fd_nplanes = vximage->raster.fd_nplanes ;
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
/*    if ( raster_pczoom( org, &temp, pc, pc, NULL ) == 0 )*/
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
      vro_cpyfm( handle, S_ONLY, xy, &temp, &wext->src ) ;
      free( temp.fd_addr ) ;
    }
  }
}

void DisplayParam(GEM_WINDOW *wnd, int param_no, int display)
{
  OBJECT *bobj  = wnd->DlgData->BaseObject ;
  int    nb_obj = LDVA_LESS2 - LDVA_LESS1 ;
  int    obj_start, i ;

  obj_start = LDVA_LIMITD1 + ( param_no - 1 ) * nb_obj ;
  for ( i = obj_start; i < obj_start + nb_obj; i++ )
  {
    if ( display ) bobj[i].ob_flags &= ~HIDETREE ;
    else           bobj[i].ob_flags |= HIDETREE ;
  }
}

void InitNumSld(GEM_WINDOW *wnd)
{
  WEXTENSION_FAPPLDV *wext = wnd->DlgData->UserData ;
  OBJECT             *bobj = wnd->DlgData->BaseObject ;
  LDV_MODULE         *ldv  = wext->ldv ;
  TEDINFO            *ted ;
  int                i ;
  int                obj_offset ;
  int                nb_obj = LDVA_LESS2 - LDVA_LESS1 ;
  char               buf[30] ;

  for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
  {
    if ( ldv->IniSpec.Params[i].Name[0] != 0 )
    {
      obj_offset                   = i * nb_obj ;
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
      ted = bobj[wext->NumSld[i].IdCurrentVal].ob_spec.tedinfo ;
      strcpy( ted->te_pvalid, "x99999" ) ;
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
      DisplayParam( wnd, i+1, 0 ) ;
    }
  }
}

void GetPreviewSize(int* src, int* dst)
{
  *src = config.ldv_preview_src_size ;
  *dst = config.ldv_preview_dst_size ;
  if ( *dst < MIN_PREVIEW_SIZE ) *dst = MIN_PREVIEW_SIZE ;
  if ( ( *src != 0 ) && ( *src != *dst ) ) *src = *dst ;
}

void SetupGUI(GEM_WINDOW *wnd)
{
  WEXTENSION_FAPPLDV *wext = wnd->DlgData->UserData ;
  OBJECT             *bobj = wnd->DlgData->BaseObject ;
  LDV_MODULE         *ldv  = wext->ldv ;
  int                dx, dx1, dy, dsize, psrc_size, pdst_size ;
  int                preview_size, preview_max_size, w_max, h_max ;
  int                i, j, hreduction, nb_obj_params, part ;

  wext->nb_params = 0 ;
  for ( i = 0; i < LDVNBMAX_PARAMETERS; i++ )
    if ( ldv->IniSpec.Params[i].Name[0] != 0 ) wext->nb_params++ ;

  w_max = ( wdesk - 16 ) / 2 ;
  if ( w_max & 0x0F ) w_max &= 0xFFF0 ; /* Multiple de 16 */
  h_max  = hdesk - 32 - ( bobj[0].ob_height - ( bobj[LDVA_OK].ob_y - 16 ) ) ;
  h_max -= ( bobj[LDVA_LESS2].ob_y - bobj[LDVA_LESS1].ob_y ) * wext->nb_params ;
  if ( h_max & 0x0F ) h_max &= 0xFFF0 ; /* Multiple de 16 */
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
    psrc_size = preview_size / 2 ;
    if ( psrc_size & 0x0F ) psrc_size &= 0xFFF0 ; /* Multiple de 16 */
    pdst_size = psrc_size ;
    dsize     = psrc_size - bobj[LDVA_SRC].ob_width ;
    bobj[LDVA_SRC].ob_width  += dsize ;
    bobj[LDVA_SRC].ob_height += dsize ;
    bobj[LDVA_DST].ob_x      =  dsize + ( bobj[LDVA_DST].ob_x - bobj[LDVA_SRC].ob_x ) + 8 ;
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
    bobj[LDVA_DST].ob_x      = ( bobj[0].ob_width - bobj[LDVA_DST].ob_width ) / 2 ;
  }

  dy -= bobj[LDVA_DST].ob_height ;
  bobj[LDVA_TSEL].ob_y -= dy ;
  bobj[LDVA_SEL].ob_y  -= dy ;
  nb_obj_params = LDVA_LIMITD2 - LDVA_LIMITD1 ;
  dx1 = bobj[LDVA_PLUS1].ob_x - ( bobj[LDVA_BOX1].ob_x + bobj[LDVA_BOX1].ob_width ) ;
  dx  = bobj[0].ob_width - ( bobj[LDVA_PLUS1].ob_x + bobj[LDVA_PLUS1].ob_width ) - 8 ;
  for ( j = 0; j < wext->nb_params; j++ )
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
    bobj[LDVA_PARAM1+i].ob_x    = bobj[LDVA_BOX1+i].ob_x + ( bobj[LDVA_BOX1+i].ob_width - bobj[LDVA_PARAM1+i].ob_width ) / 2 ;
    bobj[LDVA_LIMITU1+i].ob_x   = bobj[LDVA_BOX1+i].ob_x + bobj[LDVA_BOX1+i].ob_width - bobj[LDVA_LIMITU1+i].ob_width ;
    bobj[LDVA_VAL1+i].ob_x      = bobj[LDVA_BOX1+i].ob_x + ( bobj[LDVA_BOX1+i].ob_width - bobj[LDVA_VAL1+i].ob_width ) / 2 ; ;
  }

  bobj[LDVA_TITLE].ob_x   = ( bobj[0].ob_width - bobj[LDVA_TITLE].ob_width ) / 2 ;
  hreduction              = bobj[0].ob_height - bobj[LDVA_OK].ob_y ;
  if ( wext->nb_params > 0 )
    bobj[0].ob_height = bobj[LDVA_BOX1+i].ob_y + bobj[LDVA_BOX1+i].ob_height + 8 + bobj[LDVA_OK].ob_height + hreduction ;
  else
    bobj[0].ob_height = bobj[LDVA_DST].ob_y + bobj[LDVA_DST].ob_height + 8 + bobj[LDVA_OK].ob_height + hreduction ;
  bobj[LDVA_OK].ob_y      = bobj[0].ob_height - hreduction ;
  bobj[LDVA_PREVIEW].ob_y = bobj[0].ob_height - hreduction ;
  bobj[LDVA_CANCEL].ob_y  = bobj[0].ob_height - hreduction ;
  part                    = (bobj[0].ob_width-16)/3 ;
  bobj[LDVA_OK].ob_x      = 8 + ( part - bobj[LDVA_OK].ob_width ) / 2 ;
  bobj[LDVA_PREVIEW].ob_x = part + ( part - bobj[LDVA_OK].ob_width ) / 2 ;
  bobj[LDVA_CANCEL].ob_x  = 2*part + ( part - bobj[LDVA_OK].ob_width ) / 2 ;

}

static void OnInitDialog(void *w)
{
  GEM_WINDOW         *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_FAPPLDV *wext = wnd->DlgData->UserData ;
  VXIMAGE            *vximage = wext->wimg->Extension ;
  OBJECT             *bobj = wnd->DlgData->BaseObject ;

  SetupGUI( wnd ) ;

  bobj[LDVA_SRC].ob_spec.userblk->ub_code = draw_src ;
  bobj[LDVA_SRC].ob_spec.userblk->ub_parm = (long) wext ;
  bobj[LDVA_DST].ob_spec.userblk->ub_code = draw_dst ;
  bobj[LDVA_DST].ob_spec.userblk->ub_parm = (long) wext ;

  UpdateSrc( wnd ) ;
  wext->caps = LDVGetNPlanesCaps( wext->ldv, wext->src.fd_nplanes ) ;

/*  if ( ( vclip.gwindow == wext->wimg ) && ( ( wext->caps->Flags & LDVF_NOSELECTION ) == 0 ) )*/
  if ( vclip.gwindow == wext->wimg )
  {
    bobj[LDVA_SEL].ob_state  &= ~DISABLED ;
    bobj[LDVA_TSEL].ob_state &= ~DISABLED ;
    select( bobj, LDVA_SEL ) ;
  }
  else
  {
    bobj[LDVA_SEL].ob_state  |= DISABLED ;
    bobj[LDVA_TSEL].ob_state |= DISABLED ;
    deselect( bobj, LDVA_SEL ) ;
  }

  InitNumSld( wnd ) ;

  if ( wext->caps && ( wext->caps->Flags & LDVF_SUPPORTPREVIEW ) )
  {
    wext->dst.fd_w = bobj[LDVA_DST].ob_width ;
    wext->dst.fd_h = bobj[LDVA_DST].ob_height ;
    wext->dst.fd_wdwidth = wext->dst.fd_w / 16 ;
    if ( wext->dst.fd_w % 16 ) wext->dst.fd_wdwidth++ ;
    wext->dst.fd_nplanes = vximage->raster.fd_nplanes ;
    wext->dst.fd_addr = img_alloc( wext->dst.fd_w, wext->dst.fd_h, wext->dst.fd_nplanes ) ;
    if ( wext->dst.fd_addr ) img_raz( &wext->dst ) ;
    bobj[LDVA_PREVIEW].ob_state &= ~DISABLED ;

    DoLDVPreview( wnd, 0 ) ;
  }
  else bobj[LDVA_PREVIEW].ob_state |= DISABLED ;
}

static int OnObjectNotify(void *w, int obj)
{
  GEM_WINDOW         *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_FAPPLDV *wext = wnd->DlgData->UserData ;
  LDV_CAPS           *caps = wext->caps ;
  VXIMAGE            *vximage = wext->wimg->Extension ;
  OBJECT             *bobj = wnd->DlgData->BaseObject ;
  int                nb_obj = LDVA_LESS2 - LDVA_LESS1 ;
  int                obj_clicked, nsld, mx, my, dummy ;
  int                code = -1 ;

  graf_mkstate( &mx, &my, &dummy, &dummy ) ;
  obj_clicked = obj ;
  if ( ( obj >= LDVA_LESS1 ) && ( obj < LDVA_OK ) )
  {
    obj -= LDVA_LESS1 ;
    nsld = obj / nb_obj ;
    obj  = LDVA_LESS1 + (obj % nb_obj) ;
  }

  switch( obj )
  {
     case LDVA_LESS1   : SldNumGetVal( &wext->NumSld[nsld] ) ;
                         SldNumSetVal( &wext->NumSld[nsld], wext->NumSld[nsld].Val - 1 ) ;
                         deselect( bobj, obj_clicked ) ;
                         xobjc_draw( wnd->window_handle, bobj, obj_clicked ) ;
                         xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdCurrentVal ) ;
                         xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdBox ) ;
                         if ( caps->Flags & LDVF_REALTIMEPARAMS )
                         {
                           DoLDVPreview( wnd, 1 ) ;
                           xobjc_draw( wnd->window_handle, bobj, obj ) ;
                         }
                         break ;

     case LDVA_PLUS1   : SldNumGetVal( &wext->NumSld[nsld] ) ;
                         SldNumSetVal( &wext->NumSld[nsld], wext->NumSld[nsld].Val + 1 ) ;
                         deselect( bobj, obj_clicked ) ;
                         xobjc_draw( wnd->window_handle, bobj, obj_clicked ) ;
                         xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdCurrentVal ) ;
                         xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdBox ) ;
                         if ( caps->Flags & LDVF_REALTIMEPARAMS )
                         {
                           DoLDVPreview( wnd, 1 ) ;
                           xobjc_draw( wnd->window_handle, bobj, obj ) ;
                         }
                         break ;

     case LDVA_BOX1    : SldNumClickBox( &wext->NumSld[nsld], mx, my ) ;
                         deselect( bobj, obj_clicked ) ;
                         xobjc_draw( wnd->window_handle, bobj, obj_clicked ) ;
                         xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdCurrentVal ) ;
                         xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdBox ) ;
                         if ( caps->Flags & LDVF_REALTIMEPARAMS )
                         {
                           DoLDVPreview( wnd, 1 ) ;
                           xobjc_draw( wnd->window_handle, bobj, obj ) ;
                         }
                         break ;

     case LDVA_SLD1    : SldNumMoveSlider( &wext->NumSld[nsld] ) ;
                         deselect( bobj, obj_clicked ) ;
                         xobjc_draw( wnd->window_handle, bobj, obj_clicked ) ;
                         xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdCurrentVal ) ;
                         xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdBox ) ;
                         if ( caps->Flags & LDVF_REALTIMEPARAMS )
                         {
                           DoLDVPreview( wnd, 1 ) ;
                           xobjc_draw( wnd->window_handle, bobj, obj ) ;
                         }
                         break ;

     case LDVA_TSEL    :
     case LDVA_SEL     : inv_select( bobj, LDVA_SEL ) ;
                         xobjc_draw( wnd->window_handle, bobj, LDVA_SEL ) ;
                         UpdateSrc( wnd ) ;
                         DoLDVPreview( wnd, 1 ) ;
                         xobjc_draw( wnd->window_handle, bobj, LDVA_SRC ) ;
                         break ;

    case LDVA_PREVIEW  : deselect( bobj, obj ) ;
                         for ( nsld = 0; nsld < wext->nb_params; nsld++ )
                         {
                           SldNumGetVal( &wext->NumSld[nsld] ) ;
                           xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdCurrentVal ) ;
                           xobjc_draw( wnd->window_handle, bobj, wext->NumSld[nsld].IdBox ) ;
                         }
                         DoLDVPreview( wnd, 1 ) ;
                         xobjc_draw( wnd->window_handle, bobj, obj ) ;
                         break ;

     case LDVA_OK      : code = IDOK ;
                         break ;

     case LDVA_CANCEL  : code = IDCANCEL ;
                         break ;
  }

  if ( code == IDOK )
  {
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
      wext->ldv_params.x2 = vximage->raster.fd_w - 1 ;
      wext->ldv_params.y2 = vximage->raster.fd_h - 1 ;
    }
  }

  return( code ) ;
}

static int OnClose(void *w)
{
  GEM_WINDOW         *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_FAPPLDV *wext = wnd->DlgData->UserData ;

  if ( wext->dst.fd_addr ) free( wext->dst.fd_addr ) ;
  if ( wext->src.fd_addr ) free( wext->src.fd_addr ) ;

  return( GWCloseDlg( w ) ) ;
}

int ApplyLDV(LDV_MODULE *ldv, GEM_WINDOW *wnd, LDV_PARAMS *p)
{
  ILDVModifImg *IModifImg = ldv->IModifImg ;
  int          code ;

  if ( IModifImg->GetParams == NULL )
  {
    GEM_WINDOW         *dlg ;
    WEXTENSION_FAPPLDV wext ;
    DLGDATA            dlg_data ;

    memset( &wext, 0, sizeof(WEXTENSION_FAPPLDV) ) ;
    wext.wimg = wnd ;
    wext.ldv  = ldv ;
    memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
    dlg_data.RsrcId         = FORM_LDVAPPLY ;
    strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
    dlg_data.UserData       = &wext ;
    dlg_data.OnInitDialog   = OnInitDialog ;
    dlg_data.OnObjectNotify = OnObjectNotify ;
    dlg_data.OnCloseDialog  = OnClose ;

    dlg  = GWCreateDialog( &dlg_data ) ;
    if ( ldv->IniSpec.Params[0].Name[0] ) code = GWDoModal( dlg, LDVA_VAL1 ) ;
    else                                  code = GWDoModal( dlg, 0 ) ;

    if ( code == IDOK ) memcpy( p, &wext.ldv_params, sizeof(LDV_PARAMS) ) ;
  }
  else
  {
    VXIMAGE    *vimage = wnd->Extension ;
    LDV_IMAGE  ldv_img ;
    LDV_STATUS status ;
    int        taille ;

    memset( &ldv_img, 0, sizeof(LDV_IMAGE) ) ;
    ldv_img.RasterFormat = LDVF_SPECFORMAT ;
    memcpy( &ldv_img.Raster, &vimage->raster, sizeof(MFDB) ) ;
    ldv_img.Palette.NbColors = (short) vimage->inf_img.nb_cpal ;
    taille = ldv_img.Palette.NbColors * (int)sizeof(VDI_ELEMENTPAL) ;
    if ( taille > 0 ) ldv_img.Palette.Pal = (VDI_ELEMENTPAL *) malloc( taille ) ;
    if ( ldv_img.Palette.Pal ) memcpy( ldv_img.Palette.Pal, vimage->inf_img.palette, taille ) ;
    else                       ldv_img.Palette.NbColors = 0 ;
    
    status = IModifImg->GetParams( &ldv_img, p, config.path_ldv ) ;

    if ( ldv_img.Palette.Pal ) free( ldv_img.Palette.Pal ) ;
    if ( status == ELDV_NOERROR ) code = IDOK ;
    else                          code = IDCANCEL ;
  }

  return( code ) ;
}
