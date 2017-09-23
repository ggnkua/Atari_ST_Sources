/********************/
/* -- TRUE_COL.C -- */
/********************/
#include   <math.h>
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "..\tools\rasterop.h"

#include     "defs.h"
#include  "actions.h"


void make_tcpal(unsigned char *rpal, unsigned char *vpal, unsigned char *bpal, GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage ;
  void *addr ;
  long w, h, nb ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  addr = vimage->raster.fd_addr ;
  w    = (long)vimage->raster.fd_w ;
  h    = (long)vimage->raster.fd_h ;
  nb = w*h ;
  red_pal   = rpal ;
  green_pal = vpal ;
  blue_pal  = bpal ;

  if ( UseStdVDI ) tc_invconvert( &vimage->raster ) ;

  if ( nb_plane == 16 ) tc16_imgchange(addr, nb) ;
/*  else if ( nb_plane == 24 ) tc24_imgchange(addr, nb) ;*/
  else if ( nb_plane == 32 ) tc32_imgchange(addr, nb) ;

  if ( UseStdVDI )
    tc_convert( &vimage->raster ) ;

  if (vimage->zoom_level != 1)
  {
    nb = (long)vimage->zoom.fd_w*(long)vimage->zoom.fd_h ;
    tc_invconvert( &vimage->zoom ) ;
    tc16_imgchange(vimage->zoom.fd_addr, nb) ;
    tc_convert( &vimage->zoom ) ;
  }
}

void screen_tcpal(unsigned char *tcrpal, unsigned char *tcvpal, unsigned char *tcbpal, GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage ;
  int xyarray[4] ;
  int *adr_in ;
  int lo_inligne, lo_outligne ;
  int x, y, w, h ;
  int rx, ry, rw, rh ;
  int posx, posy ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;
  if ( gwnd->is_icon && ( gwnd->window_icon.fd_addr == NULL ) ) return ;

  wind_update(BEG_UPDATE) ;
  wind_get( gwnd->window_handle, WF_WORKXYWH, &x, &y, &w, &h) ;
  wind_get( gwnd->window_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh) ;
  red_pal   = tcrpal ;
  green_pal = tcvpal ;
  blue_pal  = tcbpal ;
  if ( gwnd->is_icon )
  {
    lo_inligne = 32*gwnd->window_icon.fd_wdwidth ;
    posx       = 0 ;
    posy       = 0 ;
  }
  else
  {
    if ( vimage->zoom_level != 1 )
    {
      lo_inligne = 32*vimage->zoom.fd_wdwidth ;
      posx       = 0 ;
      posy       = 0 ;
    }
    else
    {
      lo_inligne = 32*vimage->raster.fd_wdwidth ;
      posx       = vimage->x1 ;
      posy       = vimage->y1 ;
    }
  }
  lo_outligne = 2*(1+Xmax) ;

  v_hide_c(handle) ;
  while (rw != 0)
  {
    if (intersect(x, y, w, h, rx, ry, rw, rh, xyarray))
	{
	  if (xyarray[2] > Xmax) xyarray[2] = Xmax ;
	  if (xyarray[3] > Ymax) xyarray[3] = Ymax ;
      xrvb = xyarray[0] ;
      yrvb = xyarray[1] ;
      wrvb = 1+xyarray[2]-xyarray[0] ;
      hrvb = 1+xyarray[3]-xyarray[1] ;
      if ( gwnd->is_icon )
      {
        adr_in = (int *) gwnd->window_icon.fd_addr ;
      }
      else
      {
        if ( vimage->zoom_level != 1 )
          adr_in = (int *) vimage->zoom.fd_addr ;
        else
          adr_in = (int *) vimage->raster.fd_addr ;
      }
      adr_in += (long)(posx+xrvb-x)+(long)(posy+yrvb-y)*(long)(lo_inligne >> 1) ;
      tc16_rvbchange(lo_inligne, lo_outligne, adr_in) ;
	}
    wind_get( gwnd->window_handle, WF_NEXTXYWH, &rx, &ry, &rw, &rh ) ;
  }
  v_show_c(handle, 1) ;

  wind_update(END_UPDATE) ;
}
