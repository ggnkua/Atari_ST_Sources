#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "..\tools\rzoom.h"
#include "..\tools\logging.h"
#include "..\tools\gwindows.h"
#include "..\tools\rasterop.h"

#include "defs.h"
#include "actions.h"
#include "rtzoom.h"
#include "..\vtoolbar.h"


#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  MFDB          TCWheel ;
  unsigned char *rt24 ;
  unsigned char *newT24 ;
  double        pclum, hf ;
  long          taille ;
  int           rvb[3] ;
  int           rvbnew[3] ;
  int           tcwrvb[3] ;
  int           xm, ym ;
  int           lxm, lym ;  /* Anciennes coordonn‚es de la croix TC */
}
WEXTENSION_TCWHEEL ;

GEM_WINDOW*    WndTCWheel ;
unsigned char* T24 = NULL ; /* Tampon allou‚ si mode True Color     */
int*           xctc = NULL ;   /* Pr‚calculs de la roue des couleurs   */


void ReleaseTCWheel(void)
{
  if ( T24 ) Xfree( T24 ) ;
  T24 = NULL ;
  if ( xctc ) Xfree (xctc ) ;
  xctc = NULL ;
}

int T24_init(short wd)
{
  FILE          *stream ;
  float         r3 = sqrt(3.0) ;
  float         xf, yf, af ;
  long          taille ;
  int*          xr3 ;
  int           r2 = wd*wd ;
  int           val ;
  int           x, y, i, k, l ;
  int           red_sector, green_sector ;
  int           lshift ;
  unsigned char *pt, vp, vm, va ;
  char          name[200] ;

  xr3 = (int*) Xalloc(2*wd*sizeof(int)) ;
  if (xr3 == NULL) return(-1) ;
  xctc = (int*) Xalloc(2*wd*sizeof(int)) ;
  if (xctc == NULL)
  {
    Xfree(xr3) ;
    return(-1) ;
  }

  af     = 3.0*(float)wd*(float)wd*M_PI ;
  taille = 100+(long)af ;
  T24 = (unsigned char *) Xalloc(taille) ;
  if (T24 == NULL)
  {
    Xfree(xctc) ;
    Xfree(xr3) ;
    return(-1) ;
  }

  for (i = -wd; i < wd; i++)
    xr3[wd+i] = (int) (0.5+(float)i*r3) ;
  for (y = 0; y < wd; y++)
    xctc[wd+y] = xctc[wd-y] = wd-(int)sqrt(r2-y*y) ;
  xctc[0] = wd ;

  sprintf( name, "%s\\TCW%d.DAT", init_path, wd ) ;
  stream = fopen( name, "rb" ) ;
  if ( stream != NULL )
  {
    fread( T24, 1, taille, stream ) ;
    fclose( stream ) ;
    Xfree(xr3) ;
    return( 0 ) ;
  }

  pt     = T24 ;
  lshift = 128/wd ;
  /* Note that this generation is NOT working on Aranym-JIT */
  /* For some reason, the red/green/blue sectors are wrongly evaluated */
  /* Hopefully, once the computation is saved to TCW* file it is OK */
  for (y = -wd; y < wd; y++)
  {
    k = xctc[wd+y] ;
    l = (2*wd)-1-k ;
    for (x = k; x < l; x++)
    {
      xf  = (float)(x-wd);
      yf  = (float)(-y) ;
      af  = r3*xf ;
      val = xr3[x] ;
      vp  = wd-1-(abs(val+y)>>1) ;
      vp  = vp << lshift ;
      vm  = wd-1-(abs(val-y)>>1) ;
      vm  = vm << lshift ;
      va  = wd-1-abs(y) ;
      va  = va << lshift ;
      red_sector   = (yf <= af) && (yf >= -af) ;
      green_sector = (yf >= af) && (yf >= 0.0) ;
      if (red_sector)
      {
        *pt++ = 255 ;
        *pt++ = vp ;
        *pt++ = vm ;
      }
      else if (green_sector)
      {
        *pt++ = vp ;
        *pt++ = 255 ;
        *pt++ = va ;
      }
      else
      {
        *pt++ = vm ;
        *pt++ = va ;
        *pt++ = 255 ;
      }
    }
  }

  Xfree(xr3) ;
  stream = fopen( name, "wb" ) ;
  if ( stream != NULL )
  {
    fwrite( T24, 1, taille, stream ) ;
    fclose (stream) ;
  }

  return(0) ;
}

void makeT24(MFDB *img, unsigned char *new, float pc)
{
  float         val ;
  int           i ;
  int           x, y, k, l ;
  unsigned char newtab[256] ;
  unsigned char *pt ;
  int           x1, x2 ;
  short         wd = img->fd_w >> 1 ;
  unsigned char *pt24 ;

  pt = newtab ;
  pc = pc/100.0 ;
  for (i = 0; i < 256; i++)
  {
    val   = pc*(float)i ;
    *pt++ = (unsigned char) val ;
  }

  pt = new ;
  for (y = -wd; y < wd; y++)
  {
    k = xctc[wd+y] ;
    l = 2*wd-1-k ;
    for (x = k; x < l; x++)
    {
      *pt = newtab[*pt] ;
      pt++ ;
      *pt = newtab[*pt] ;
      pt++ ;
      *pt = newtab[*pt] ;
      pt++ ;
    }
  }

  img_raz( img ) ;

  if (img->fd_nplanes == 16 )
  {
    RGB          rgb ;
    unsigned int *pt16, *lstart ;

    pt16   = (unsigned int *) img->fd_addr ;
    pt24 = new ;
    lstart = pt16 ;
    for (y = -wd; y < wd-1; y++)
    {
      x1 = xctc[wd+y] ;
      x2 = 2*wd-1-xctc[wd+y] ;
      pt16 = lstart + x1 ;
      for (x = x1; x < x2; x++)
      {
        rgb.Red   = (unsigned char) *pt24++ ;
        rgb.Green = (unsigned char) *pt24++ ;
        rgb.Blue  = (unsigned char) *pt24++ ;
        *pt16++   = RVB16( &rgb ) ;
      }
      lstart += img->fd_w ;
    }
  }
  else if ( img->fd_nplanes == 24 )
  {

  }
  else if ( img->fd_nplanes == 32 )
  {
    RGB           rgb ;
    unsigned long *pt32, *lstart ;

    pt32   = (unsigned long *) img->fd_addr ;
    pt24   = new ;
    lstart = pt32 ;
    for (y = -wd; y < wd-1; y++)
    {
      x1   = xctc[wd+y] ;
      x2   = 2*wd-1-xctc[wd+y] ;
      pt32 = lstart + x1 ;
      for (x = x1; x < x2; x++)
      {
        rgb.Red   = *pt24++ ;
        rgb.Green = *pt24++ ;
        rgb.Blue  = *pt24++ ;
        *pt32++ = RVBX32( &rgb ) ;
      }
      lstart += img->fd_w ;
    }
  }

  tc_convert( img ) ;
}

int cdecl draw_tcwheel(PARMBLK *paramblk)
{
  WEXTENSION_TCWHEEL *wext = (WEXTENSION_TCWHEEL *) paramblk->pb_parm ;
  int                xy[8] ;
  int                cxy[4] ;

  if ( wext->TCWheel.fd_addr )
  {
    xy[0] = 0 ;
    xy[1] = 0 ;
    xy[2] = wext->TCWheel.fd_w-1 ;
    xy[3] = wext->TCWheel.fd_h-1 ;
    xy[4] = paramblk->pb_x ;
    xy[5] = paramblk->pb_y ;
    xy[6] = xy[4]+wext->TCWheel.fd_w-1 ;
    xy[7] = xy[5]+wext->TCWheel.fd_h-1 ;
    cxy[0] = paramblk->pb_xc ;
    cxy[1] = paramblk->pb_yc ;
    cxy[2] = paramblk->pb_xc+paramblk->pb_wc-1 ;
    cxy[3] = paramblk->pb_yc+paramblk->pb_hc-1 ;
    vs_clip(handle, 1, cxy) ;
    v_hide_c(handle) ;
    vro_cpyfm(handle, S_ONLY, xy, &wext->TCWheel, &screen) ;
    v_show_c(handle, 1) ;
    vs_clip(handle, 0, cxy) ;
  }

  return(0) ;
}

void show_color(GEM_WINDOW* wnd, float pc, int flag_lum, int *rvb_out)
{
  WEXTENSION_TCWHEEL *wext = (WEXTENSION_TCWHEEL *) wnd->DlgData->UserData ;
  OBJECT             *obj = wnd->DlgData->BaseObject ;
  float              coe ;
  int                cxy[4] ;
  int                xycol[4] ;
  int                rgb[3], rgbm[3] ;
  int                i ;
  int                xm, ym, dummy ;
  char               buf[10] ;

  graf_mkstate(&xm, &ym, &dummy, &dummy) ;
  objc_offset(obj, TCPAL_BOX, &cxy[0], &cxy[1]) ;
  cxy[2] = cxy[0]+obj[TCPAL_BOX].ob_width-1 ;
  cxy[3] = cxy[1]+obj[TCPAL_BOX].ob_height-1 ;
  v_hide_c(handle) ;
  if (flag_lum)
  {
    vs_clip(handle, 1, cxy) ;
    vswr_mode(handle, MD_XOR) ;
    vsm_color(handle, 1) ;
    vsm_type(handle, 5) ;
    vsm_height(handle, 3) ;
    if ((wext->lxm != 0) && (wext->lym != 0)) pset(cxy[0]+wext->lxm, cxy[1]+wext->lym) ;
    vs_clip(handle, 0, cxy) ;
    GetPixel( &wext->TCWheel, xm-cxy[0], ym-cxy[1], rgb ) ;
    memcpy( wext->tcwrvb, rgb, sizeof(rgb) ) ;
  }
  else
  {
    /* Old method using vro_cpyfm to copy from screen does not work on Aranym */
    /* For some reason; re-compute value from last color picked in True Color Wheel */
    /* It's because on Aranym, this box object is whited after a clck on it */
    int  x, y ;

    objc_offset(obj, TCPAL_LUM, &x, &y) ;
    coe    = (float)(xm-x)/(float) (obj[TCPAL_LUM].ob_width) ;
    rgb[0] = (int) (coe*(float)wext->tcwrvb[0]) ;
    rgb[1] = (int) (coe*(float)wext->tcwrvb[1]) ;
    rgb[2] = (int) (coe*(float)wext->tcwrvb[2]) ;
  }

  LoggingDo(LL_DEBUG, "RGB=%.3d,%.3d,%.3d", rgb[0], rgb[1], rgb[2]) ;

  if (flag_lum)
  {
    pset(xm, ym) ;
    wext->lxm = xm-cxy[0] ;
    wext->lym = ym-cxy[1] ;
  }

  sprintf(buf, "%.3d", rgb[0]) ;
  write_text(obj, TCPAL_RED, buf) ;
  xobjc_draw( wnd->window_handle,obj, TCPAL_RED ) ;
  sprintf(buf, "%.3d", rgb[1]) ;
  write_text(obj, TCPAL_GREEN, buf) ;
  xobjc_draw( wnd->window_handle,obj, TCPAL_GREEN ) ;
  sprintf(buf, "%.3d", rgb[2]) ;
  write_text(obj, TCPAL_BLUE, buf) ;
  xobjc_draw( wnd->window_handle,obj, TCPAL_BLUE ) ;

  rgbm[0] = RGB8BToRGBPM[rgb[0]] ;
  rgbm[1] = RGB8BToRGBPM[rgb[1]] ;
  rgbm[2] = RGB8BToRGBPM[rgb[2]] ;
  memcpy(rvb_out, rgbm, sizeof(rgbm)) ;
  objc_offset(obj, TCPAL_COLOR, &xycol[0], &xycol[1]) ;
  cxy[0] = xycol[0] ;
  cxy[1] = xycol[1] ;
  cxy[2] = cxy[0]+obj[TCPAL_COLOR].ob_width-1 ;
  cxy[3] = cxy[1]+obj[TCPAL_COLOR].ob_height-1 ;
  vs_clip(handle, 1, cxy) ;
  xycol[2] = xycol[0]+obj[TCPAL_COLOR].ob_width-1 ;
  xycol[3] = xycol[1]+obj[TCPAL_COLOR].ob_height-1 ;
  vs_color(handle, 17, rgbm) ;
  ltype.color = 17 ;
  vsl_color(handle, 17) ;
  ftype.color = 17 ;
  vsf_color(handle, 17) ;
  ttype.color = 17 ;
  vst_color(handle, 17) ;
  mtype.color = 17 ;
  vsf_color(handle, 17) ;
  vswr_mode(handle, MD_REPLACE) ;
  vr_recfl(handle, xycol) ;
  vs_clip(handle, 0, cxy) ;

  /* We should not comment out this line but on Aranym, */
  /* This object gets whited so  we must redraw         */
  /*if (flag_lum)*/
  {
    int step ;

    coe = 100.0/pc ;
    rgbm[0] = (int) (coe*(float)RGB8BToRGBPM[wext->tcwrvb[0]]) ;
    rgbm[1] = (int) (coe*(float)RGB8BToRGBPM[wext->tcwrvb[1]]) ;
    rgbm[2] = (int) (coe*(float)RGB8BToRGBPM[wext->tcwrvb[2]]) ;
    objc_offset(obj, TCPAL_LUM, &xycol[0], &xycol[1]) ;
    cxy[0] = xycol[0] ;
    cxy[1] = xycol[1] ;
    cxy[2] = cxy[0]+obj[TCPAL_LUM].ob_width-1 ;
    cxy[3] = cxy[1]+obj[TCPAL_LUM].ob_height-1 ;
    vs_clip(handle, 1, cxy) ;
    xycol[3] = xycol[1]+obj[TCPAL_LUM].ob_height-1 ;
    vswr_mode(handle, MD_REPLACE) ;
    vsl_type( handle, 1 ) ;
    if ( screen.fd_nplanes == 16 ) step = 8 ;
    else                  step = 1 ;
    xycol[2] = xycol[0]+step ;
    for (i = 0; i < obj[TCPAL_LUM].ob_width; i += step )
    {
      coe    = (float)(i)/(float) (obj[TCPAL_LUM].ob_width) ;
      rgb[0] = (int) (coe*(float)rgbm[0]) ;
      rgb[1] = (int) (coe*(float)rgbm[1]) ;
      rgb[2] = (int) (coe*(float)rgbm[2]) ;
      vs_color(handle, 17, rgb) ;
      if ( step == 1 ) line( xycol[0], xycol[1], xycol[0], xycol[3] ) ;
      else             vr_recfl(handle, xycol) ;
      xycol[0] += step ;
      xycol[2] += step ;
    }
    vs_clip(handle, 0, cxy) ;
  }
  v_show_c(handle, 1) ;
}

void show_pc(GEM_WINDOW* wnd, float pc)
{
  OBJECT *adr_24bits = wnd->DlgData->BaseObject ;
  char   buf[10] ;

  sprintf(buf, "%.3d", (int) (0.5+pc)) ;
  strcat(buf, "%") ;
  write_text(adr_24bits, TCPAL_PERCENT, buf) ;
  xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_PERCENT ) ;
}

static int OnIconify(void *w, int xywh[4])
{
  GEM_WINDOW         *wnd = (GEM_WINDOW* ) w ;
  WEXTENSION_TCWHEEL *wext = wnd->DlgData->UserData ;
  MFDB               icon ;
  float              pcx, pcy ;
  float              pc ;
  int                dummy, wx, wy ;

  GWOnIconify( wnd, xywh ) ;
  if ( wnd->window_icon.fd_addr == NULL )
  {
    wnd->GetWorkXYWH( wnd, &dummy, &dummy, &wx, &wy ) ;
    pcx = (float)wx / (float)wext->TCWheel.fd_w ;
    pcy = (float)wy / (float)wext->TCWheel.fd_h ;
    if ( pcx > pcy ) pc = pcy ;
    else             pc = pcx ;
    icon.fd_addr = NULL ;
    icon.fd_w    = (int) ( 0.5 + (float)wext->TCWheel.fd_w * pc ) ;
    icon.fd_h    = (int) ( 0.5 + (float)wext->TCWheel.fd_h * pc ) ;
    if ( RasterZoom( &wext->TCWheel, &icon, NULL ) == 0 )
    {
      if ( wnd->window_icon.fd_addr ) Xfree( wnd->window_icon.fd_addr ) ;
      CopyMFDB( &wnd->window_icon, &icon ) ;
    }
  }

  return( 0 ) ;
}

void Adapt2Resolution(OBJECT* form_tcwheel)
{
  if ( (Xmax > 1439) && (Ymax > 899) )
  {
    int add_tcpal_box = form_tcwheel[TCPAL_BOX].ob_width ;

    LoggingDo(LL_INFO, "Resolution is over 1440x900, True Color wheel deserves bigger size, adding %d pixels", add_tcpal_box) ;
    /* Change form/_BOX/_BOXPC width and height and move all objects to right */
    form_tcwheel[0].ob_width          += add_tcpal_box ;
    form_tcwheel[0].ob_height         += add_tcpal_box ;
    form_tcwheel[TCPAL_BOX].ob_width  += add_tcpal_box ;
    form_tcwheel[TCPAL_BOX].ob_height += add_tcpal_box ;

    form_tcwheel[TCPAL_LUM].ob_width += add_tcpal_box ;
    form_tcwheel[TCPAL_LUM].ob_y     += add_tcpal_box ;

    form_tcwheel[TCPAL_OK].ob_x     += add_tcpal_box/3 ;
    form_tcwheel[TCPAL_OK].ob_y     += add_tcpal_box ;
    form_tcwheel[TCPAL_CANCEL].ob_x += add_tcpal_box/3 ;
    form_tcwheel[TCPAL_CANCEL].ob_y += add_tcpal_box ;

    form_tcwheel[TCPAL_TITLE].ob_x     += add_tcpal_box>>1 ;

    form_tcwheel[TCPAL_TC0].ob_y += add_tcpal_box ;
    form_tcwheel[TCPAL_TC0].ob_x += add_tcpal_box ;

    form_tcwheel[TCPAL_BOXPC].ob_height += add_tcpal_box ;
    form_tcwheel[TCPAL_BOXPC].ob_x      += add_tcpal_box ;

    form_tcwheel[TCPAL_LUMMOINS].ob_y       += add_tcpal_box ;
    form_tcwheel[TCPAL_LUMMOINS].ob_x       += add_tcpal_box ;
    form_tcwheel[TCPAL_LUMPLUS].ob_x        += add_tcpal_box ;

    form_tcwheel[TCPAL_TRED].ob_y    += add_tcpal_box>>1 ;
    form_tcwheel[TCPAL_TGREEN].ob_y  += add_tcpal_box>>1 ;
    form_tcwheel[TCPAL_TBLUE].ob_y   += add_tcpal_box>>1 ;
    form_tcwheel[TCPAL_RED].ob_y     += add_tcpal_box>>1 ;
    form_tcwheel[TCPAL_GREEN].ob_y   += add_tcpal_box>>1 ;
    form_tcwheel[TCPAL_BLUE].ob_y    += add_tcpal_box>>1 ;
    form_tcwheel[TCPAL_COLOR].ob_y   += add_tcpal_box>>1 ;
    form_tcwheel[TCPAL_PERCENT].ob_y += add_tcpal_box>>1 ;

    form_tcwheel[TCPAL_TRED].ob_x    += add_tcpal_box ;
    form_tcwheel[TCPAL_TGREEN].ob_x  += add_tcpal_box ;
    form_tcwheel[TCPAL_TBLUE].ob_x   += add_tcpal_box ;
    form_tcwheel[TCPAL_RED].ob_x     += add_tcpal_box ;
    form_tcwheel[TCPAL_GREEN].ob_x   += add_tcpal_box ;
    form_tcwheel[TCPAL_BLUE].ob_x    += add_tcpal_box ;
    form_tcwheel[TCPAL_COLOR].ob_x   += add_tcpal_box ;
    form_tcwheel[TCPAL_PERCENT].ob_x += add_tcpal_box ;
  }
}

void OnInitDialogTCWheel(void *w)
{
  GEM_WINDOW         *wnd = (GEM_WINDOW* ) w ;
  WEXTENSION_TCWHEEL *wext = wnd->DlgData->UserData ;
  OBJECT             *adr_24bits = wnd->DlgData->BaseObject ;
  int                off_x, off_y, off_xp, off_yp ;
  int                err = 0 ;

  adr_24bits[TCPAL_BOX].ob_spec.userblk->ub_code = draw_tcwheel ;
  adr_24bits[TCPAL_BOX].ob_spec.userblk->ub_parm = (long) wext ;

  /* Define the True Color Wheel width */
  Adapt2Resolution(adr_24bits) ;
  ZeroMFDB( &wext->TCWheel ) ;
  wext->TCWheel.fd_w = adr_24bits[TCPAL_BOX].ob_width ;

  LoggingDo(LL_DEBUG, "TCWheel width=%d", wext->TCWheel.fd_w) ;

  if ( T24 == NULL ) err = T24_init(wext->TCWheel.fd_w>>1) ;
  if ( err )
  {
    form_error( 8 ) ;
    return ;
  }

  wext->taille = (long)wext->TCWheel.fd_w*(long)wext->TCWheel.fd_w*3L ;
  wext->newT24 = (unsigned char *) Xalloc(wext->taille) ;
  if (wext->newT24 == NULL)
  {
    form_error(8) ;
    return ;
  }
  memcpy(wext->newT24, T24, wext->taille) ;

  vq_color(handle, 17, 1, wext->rvb) ;
  memcpy(wext->rvbnew, wext->rvb, 6) ;
  memcpy(wext->tcwrvb, wext->rvb, 6) ;
  wext->TCWheel.fd_wdwidth = w2wdwidth( wext->TCWheel.fd_w ) ;
  wext->TCWheel.fd_h       = adr_24bits[TCPAL_BOX].ob_height ;
  wext->TCWheel.fd_nplanes = screen.fd_nplanes ;
  wext->TCWheel.fd_addr    = img_alloc( wext->TCWheel.fd_w, wext->TCWheel.fd_h, wext->TCWheel.fd_nplanes ) ;
  if ( wext->TCWheel.fd_addr == NULL )
  {
    Xfree( wext->newT24 ) ;
    form_error(8) ;
    return ;
  }

  objc_offset(adr_24bits, TCPAL_LUMSLIDER, &off_x, &off_y) ;
  objc_offset(adr_24bits, TCPAL_BOXPC, &off_xp, &off_yp) ;
  off_y = off_y-off_yp ;
  wext->hf    = (double) (adr_24bits[TCPAL_BOXPC].ob_height-adr_24bits[TCPAL_LUMSLIDER].ob_height) ;
  wext->pclum = 100.0*(1.0-(double)off_y/wext->hf) ;
  makeT24( &wext->TCWheel, wext->newT24, wext->pclum ) ;
  wext->rt24 = wext->newT24 ;
  vsf_interior(handle, FIS_SOLID) ;
  vsf_color(handle, 17) ;
  vswr_mode(handle, MD_REPLACE) ;
  wext->lxm = wext->lym = 0 ;

  wnd->OnIconify = OnIconify ;
}

static void handle_tcpal(GEM_WINDOW* wnd, int off_y)
{
  WEXTENSION_TCWHEEL* wext = wnd->DlgData->UserData ;
  OBJECT*             adr_24bits = wnd->DlgData->BaseObject ;

  adr_24bits[TCPAL_LUMSLIDER].ob_y = off_y ;
  memcpy( wext->newT24, T24, wext->taille ) ;
  makeT24( &wext->TCWheel, wext->newT24, wext->pclum ) ;
  show_pc( wnd, wext->pclum ) ;
  xobjc_draw( wnd->window_handle, adr_24bits, TCPAL_BOX ) ;
  xobjc_draw( wnd->window_handle, adr_24bits, TCPAL_BOXPC ) ;
  xobjc_draw( wnd->window_handle, adr_24bits, TCPAL_LUMSLIDER ) ;
}

static int OnObjectNotifyTCWheel(void *w, int obj)
{
  GEM_WINDOW         *wnd = (GEM_WINDOW* ) w ;
  WEXTENSION_TCWHEEL *wext = wnd->DlgData->UserData ;
  OBJECT             *adr_24bits = wnd->DlgData->BaseObject ;
  int                code = -1 ;
  int                off_x, off_y ;
  int                valid = 0, xm, ym, dummy ;
  char               buffer[20] ;
  char               flag[1+NB_TOOLS] ;

  memzero( flag, 1+NB_TOOLS ) ;
  flag[PALETTE] = 1 ;
  graf_mkstate(&xm, &ym, &dummy, &dummy) ;

  switch( obj )
  {
    case TCPAL_LUM       : show_color( wnd, wext->pclum, 0, wext->rvbnew) ;
                           if ( config.use_rtzoom ) rtzoom_display( xm, ym, 1 ) ;
                           valid = 1 ;
                           break ;
    case TCPAL_BOX       :
                           show_color( wnd, wext->pclum, 1, wext->rvbnew) ;
                           if ( config.use_rtzoom ) rtzoom_display( xm, ym, 1 ) ;
                           valid = 1 ;
                           break ;
    case TCPAL_LUMMOINS  :
    case TCPAL_LUMPLUS   : if (obj == TCPAL_LUMPLUS) wext->pclum = wext->pclum+1.0 ;
                           else                         wext->pclum = wext->pclum-1.0 ;
                           if (wext->pclum < 1.0)   wext->pclum = 1.0 ;
                           if (wext->pclum > 100.0) wext->pclum = 100.0 ;
                           off_y = (int) ((100.0-wext->pclum)*(double)wext->hf/100.0) ;
                           handle_tcpal( wnd, off_y ) ;
/*                           adr_24bits[TCPAL_LUMSLIDER].ob_y = off_y ;
                           memcpy(wext->newT24, T24, wext->taille) ;
                           makeT24( &wext->TCWheel, wext->newT24, wext->pclum) ;
                           show_pc( wnd, wext->pclum) ;
                           xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_BOX ) ;
                           xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_BOXPC ) ;
                           xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_LUMSLIDER ) ;*/
                           break ;
    case TCPAL_BOXPC     : graf_mkstate( &wext->xm, &wext->ym, &dummy, &dummy ) ;
                           objc_offset(adr_24bits, TCPAL_LUMSLIDER, &off_x, &off_y) ;
                           if (ym > off_y) wext->pclum = wext->pclum-10.0 ;
                           else            wext->pclum = wext->pclum+10.0 ;
                           if (wext->pclum < 1.0)   wext->pclum = 1.0 ;
                           if (wext->pclum > 100.0) wext->pclum = 100.0 ;
                           off_y = (int) ((100.0-wext->pclum)*(double)wext->hf/100.0) ;
                           handle_tcpal( wnd, off_y ) ;
/*                           adr_24bits[TCPAL_LUMSLIDER].ob_y = off_y ;
                           memcpy(wext->newT24, T24, wext->taille) ;
                           makeT24( &wext->TCWheel, wext->newT24, wext->pclum) ;
                           show_pc( wnd, wext->pclum) ;
                           xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_BOX ) ;
                           xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_BOXPC ) ;
                           xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_LUMSLIDER ) ;*/
                           break ;
    case TCPAL_LUMSLIDER : wext->pclum = (float) graf_slidebox(adr_24bits, TCPAL_BOXPC, TCPAL_LUMSLIDER, 1) ;
                           wext->pclum = (1000.0-wext->pclum)/10.0 ;
                           off_y = (int) ((100.0-wext->pclum)*(double)wext->hf/100.0) ;
                           handle_tcpal( wnd, off_y ) ;
/*                           adr_24bits[TCPAL_LUMSLIDER].ob_y = off_y ;
                           memcpy(wext->newT24, T24, wext->taille) ;
                           makeT24( &wext->TCWheel, wext->newT24, wext->pclum) ;
                           show_pc( wnd, wext->pclum) ;
                           xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_BOX ) ;
                           xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_BOXPC ) ;
                           xobjc_draw( wnd->window_handle,adr_24bits, TCPAL_LUMSLIDER ) ;*/
                           break ;
     case TCPAL_OK       : code = IDOK ;
                           valid = 1 ;
                           break ;
     case TCPAL_CANCEL   : code = IDCANCEL ;
                           break ;
  }

  if ( valid )
  {
    read_text(adr_24bits, TCPAL_RED, buffer) ;
    wext->rvbnew[0] = atoi(buffer) ;
    wext->rvbnew[0] = RGB8BToRGBPM[wext->rvbnew[0]] ;
    read_text(adr_24bits, TCPAL_GREEN, buffer) ;
    wext->rvbnew[1] = atoi(buffer) ;
    wext->rvbnew[1] = RGB8BToRGBPM[wext->rvbnew[1]] ;
    read_text(adr_24bits, TCPAL_BLUE, buffer) ;
    wext->rvbnew[2] = atoi(buffer) ;
    wext->rvbnew[2] = RGB8BToRGBPM[wext->rvbnew[2]] ;
    vs_color(handle, 17, wext->rvbnew) ;
    ltype.color  = 17 ;
    mtype.color  = 17 ;
    ttype.color  = 17 ;
    ftype.color  = 17 ;
    pencil.color = 17 ;
    VToolBarUpdate( flag ) ;
  }
  else if ( code == IDCANCEL )
  {
    vs_color(handle, 17, wext->rvb) ;
    ltype.color  = 17 ;
    mtype.color  = 17 ;
    ttype.color  = 17 ;
    ftype.color  = 17 ;
    pencil.color = 17 ;
    VToolBarUpdate( flag ) ;
  }

  return( code ) ;
}

int OnCloseDialogTCWheel(void *w)
{
  GEM_WINDOW         *wnd = (GEM_WINDOW* ) w ;
  WEXTENSION_TCWHEEL *wext = wnd->DlgData->UserData ;

  Xfree( wext->TCWheel.fd_addr ) ;
  Xfree( wext->newT24 ) ;
  Xfree( wext ) ;
  WndTCWheel = NULL ;

  return( GWCloseDlg( w ) ) ;
}

void traite_24bitspal(GEM_WINDOW* gwnd)
{
  DLGDATA            dlg_data ;
  WEXTENSION_TCWHEEL *wext ;

  if ( gwnd == NULL ) return ;
  if ( WndTCWheel )
  {
    PostMessage( WndTCWheel, WM_TOPPED, NULL ) ;
    return ;
  }

  wext = Xcalloc( 1, sizeof(WEXTENSION_TCWHEEL) ) ;
  if ( wext == NULL )
  {
    form_error(8) ;
    return ;
  }
  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_TCPALETTE ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogTCWheel ;
  dlg_data.OnObjectNotify = OnObjectNotifyTCWheel ;
  dlg_data.OnCloseDialog  = OnCloseDialogTCWheel ;
  dlg_data.WKind          = SMALLER ;

  WndTCWheel = GWCreateDialog( &dlg_data ) ;
}
