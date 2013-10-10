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

int snap_wimage(char *nom, int x, int y, int nx, int ny)
{
  GEM_WINDOW *gwnd ;
  VXIMAGE *vimage ;
  INFO_IMAGE *inf_img ;
  int  w, h ;
  int  xo, yo, wo, ho ;
  int  nnx, nny ;

  gwnd = VImgCreateWindow() ;
  if ( gwnd == NULL )
  {
    form_stop( 1, msg[MSG_NOMOREWINDOW] ) ;
    return(-1) ;
  }
  vimage = (VXIMAGE *) gwnd->Extension ;
  inf_img = &vimage->inf_img ;

  if (nx < MINIW) nnx = MINIW ;
  else            nnx = nx ;
  if (ny < MINIH) nny = MINIH ;
  else            nny = ny ;

  vimage->raster.fd_addr = img_alloc( nnx, nny, nb_plane ) ;
  if ( vimage->raster.fd_addr == NULL )
  {
    GWDestroyWindow( gwnd ) ;
    form_error( 8 ) ;
    return( -2 ) ;
  }

  strcpy( inf_img->nom, nom ) ;
  inf_img->lformat  = IID_TIFF ;
  inf_img->version  = 1 ;
  inf_img->compress = 0 ;
  inf_img->largeur  = nnx ;
  inf_img->hauteur  = nny ;
  if ( Truecolor ) inf_img->nplans = 24 ;
  else             inf_img->nplans = nb_plane ;
  inf_img->lpix = 150 ;
  inf_img->hpix = 150 ;
  if ( Truecolor ) inf_img->palette  = NULL ;
  else
  {
    inf_img->palette = malloc( 6*nb_colors ) ;
    if ( inf_img->palette == NULL )
    {
      free( vimage->raster.fd_addr ) ;
      GWDestroyWindow( gwnd ) ;
      form_error( 8 ) ;
      return( -2 ) ;
    }
    get_tospalette( inf_img->palette ) ;
    inf_img->nb_cpal = nb_colors ;
  }
  vimage->raster.fd_w = nnx ;
  vimage->raster.fd_h = nny ;
  vimage->raster.fd_nplanes = nb_plane ;
  vimage->raster.fd_wdwidth = nnx/16 ;
  if (nnx % 16) vimage->raster.fd_wdwidth++ ;
  vimage->raster.fd_stand = 0 ;
  memset(&vimage->zoom, 0, sizeof(MFDB)) ;
  vimage->zoom_level = 1 ;
  vimage->modif      = 0 ;
  sprintf( vimage->nom, "%s\\%s", config.path_img, nom ) ;
  w = nnx ;
  h = nny ;

  img_raz( &vimage->raster ) ;
  set_snap( x, y, w, h, &vimage->raster, config.snap_flags & SF_MOUSE ) ;
  
  w = vimage->raster.fd_w ;
  h = vimage->raster.fd_h ;
  open_where( gwnd->window_kind, w, h, &xo, &yo, &wo, &ho ) ;
  if ( GWOpenWindow( gwnd, xo, yo, wo, ho ) != 0 )
  {
    if ( inf_img->palette ) free( inf_img->palette ) ;
    free( vimage->raster.fd_addr ) ;
    GWDestroyWindow( gwnd ) ;
    form_stop(1, msg[MSG_NOMOREWINDOW]) ;
    return(-1) ;
  }
  AttachPictureToWindow( gwnd ) ;

  return(0) ;
}
