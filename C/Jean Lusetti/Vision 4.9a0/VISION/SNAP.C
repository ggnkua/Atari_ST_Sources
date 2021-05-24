#include  <stdio.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\stdprog.h"
#include     "..\tools\stdinput.h"
#include     "..\tools\xgem.h"
#include     "..\tools\image_io.h"
#include     "..\tools\rasterop.h"

#include     "defs.h"
#include     "undo.h"
#include   "gstenv.h"
#include   "rtzoom.h"
#include  "actions.h"
#include "visionio.h"


void set_snap(int x, int y, int w, int h, MFDB *img, int mouse)
{
  int xy[8] ;

  xy[0] = x ;         xy[1] = y ;
  xy[2] = x + w - 1 ; xy[3] = y + h - 1 ;
  xy[4] = 0 ;         xy[5] = 0 ;
  xy[6] = w - 1 ;     xy[7] = h - 1 ;

  if ( !mouse ) v_hide_c( handle ) ;
  vro_cpyfm( handle, S_ONLY, xy, &screen, img ) ;
  if ( !mouse ) v_show_c( handle, 1 ) ;
}

int snap_wimage(char* nom, int x, int y, int nx, int ny)
{
  GEM_WINDOW* gwnd ;
  VXIMAGE*    vimage ;
  INFO_IMAGE* inf_img ;
  int         w, h ;
  int         xo, yo, wo, ho ;
  int         nnx, nny ;

  gwnd = VImgCreateWindow() ;
  if ( gwnd == NULL )
  {
    form_stop( 1, MsgTxtGetMsg(hMsg, MSG_NOMOREWINDOW)  ) ;
    return -1 ;
  }
  vimage  = (VXIMAGE*) gwnd->Extension ;
  inf_img = &vimage->inf_img ;

  if ( nx < MINIW ) nnx = MINIW ;
  else              nnx = nx ;
  if ( ny < MINIH ) nny = MINIH ;
  else              nny = ny ;

  vimage->inf_img.mfdb.fd_addr = img_alloc( nnx, nny, screen.fd_nplanes ) ;
  if ( vimage->inf_img.mfdb.fd_addr == NULL )
  {
    GWDestroyWindow( gwnd ) ;
    form_error( 8 ) ;
    return -2 ;
  }

  if ( nom[1] == ':' ) strcpy( inf_img->filename, nom ) ; /* nom is Full path */
  else                 sprintf( inf_img->filename, "%s\\%s", config.path_img, nom ) ;
  inf_img->lformat  = IID_TIFF ;
  inf_img->compress = 0 ;
  inf_img->width    = nnx ;
  inf_img->height   = nny ;
  if ( Truecolor ) inf_img->nplanes = 24 ;
  else             inf_img->nplanes = screen.fd_nplanes ;
  inf_img->lpix = 150 ;
  inf_img->hpix = 150 ;
  if ( Truecolor ) inf_img->palette  = NULL ;
  else
  {
    inf_img->palette = Xalloc( 6*nb_colors ) ;
    if ( inf_img->palette == NULL )
    {
      Xfree( vimage->inf_img.mfdb.fd_addr ) ;
      GWDestroyWindow( gwnd ) ;
      form_error( 8 ) ;
      return -2 ;
    }
    get_tospalette( inf_img->palette ) ;
    inf_img->nb_cpal = nb_colors ;
  }
  vimage->inf_img.mfdb.fd_w = nnx ;
  vimage->inf_img.mfdb.fd_h = nny ;
  vimage->inf_img.mfdb.fd_nplanes = screen.fd_nplanes ;
  vimage->inf_img.mfdb.fd_wdwidth = w2wdwidth( nnx ) ;
  vimage->inf_img.mfdb.fd_stand = 0 ;
  ZeroMFDB(&vimage->zoom) ;
  vimage->zoom_level = 1 ;
  vimage->modif      = 0 ;
  w = nnx ;
  h = nny ;

  img_raz( &vimage->inf_img.mfdb ) ;
  set_snap( x, y, w, h, &vimage->inf_img.mfdb, config.snap_flags & SF_MOUSE ) ;
  
  w = vimage->inf_img.mfdb.fd_w ;
  h = vimage->inf_img.mfdb.fd_h ;
  open_where( gwnd->window_kind, w, h, &xo, &yo, &wo, &ho ) ;
  if ( GWOpenWindow( gwnd, xo, yo, wo, ho ) != 0 )
  {
    if ( inf_img->palette ) Xfree( inf_img->palette ) ;
    Xfree( vimage->inf_img.mfdb.fd_addr ) ;
    GWDestroyWindow( gwnd ) ;
    form_stop( 1, MsgTxtGetMsg(hMsg, MSG_NOMOREWINDOW) ) ;
    return -1 ;
  }
  AttachPictureToWindow( gwnd ) ;

  return 0 ;
}
