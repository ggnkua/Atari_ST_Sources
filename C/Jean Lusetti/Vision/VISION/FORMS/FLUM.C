#include <string.h>
#include "..\tools\gwindows.h"

#include "..\tools\rasterop.h"

#include "defs.h"
#include "undo.h"
#include "actions.h"
#include "true_col.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  GEM_WINDOW *wnd ;
  VXIMAGE    *vimage ;
  INFO_IMAGE *inf_img ;

  int           w, w1, pc ;
  int           pal[6*256] ;
  unsigned char tc_lum[256] ;
}
WEXTENSION_FLUM ;


void set_tclum(unsigned char *lum, float pc)
{
  float         val, nbf, percent ;
  int           i ;
  int           nb_bit ;
  unsigned char *pt ;

  if ( nb_plane == 16 ) nb_bit = 5 ;
  else                  nb_bit = 8 ;
  pt      = lum ;
  percent = 1.0+pc ;
  nbf     = (float) (1 << nb_bit)-1.0 ;
  for (i = 0.0; i <= nbf; i = i+1.0)
  {
    val = percent*(float)i ;
    if (val > nbf) val = nbf ;
    *pt++ = (int) (0.5+val) ;
  }
}


void update_lightbox(GEM_WINDOW *wnd, long pc, int w)
{
  OBJECT          *adr_lumiere = wnd->DlgData->BaseObject ;
  WEXTENSION_FLUM *wext = wnd->DlgData->UserData ;
  VXIMAGE         *vimage ;
  INFO_IMAGE      *inf_img ;
  float           pcx ;
  char            buf[10] ;

  vimage  = wext->vimage ;
  inf_img = &vimage->inf_img ;

  adr_lumiere[LUMIERE_SLIDER].ob_x = w+(int)((pc*(long)w)/100L) ;
  sprintf(buf, "%+.2d", (int)pc) ;
  strcat(buf, "%") ;
  write_text(adr_lumiere, LUMIERE_PC, buf) ;
  xobjc_draw( wnd->window_handle, adr_lumiere, LUMIERE_PC ) ;
  xobjc_draw( wnd->window_handle, adr_lumiere, LUMIERE_BOX ) ;
  if ( Truecolor )
  {
    if ( !UseStdVDI )
    {
      pcx = (float)pc/100.0 ;
      set_tclum( wext->tc_lum, pcx ) ;
      screen_tcpal( wext->tc_lum, wext->tc_lum, wext->tc_lum, wext->wnd ) ;
    }
  }
  else
  {
    int *pt ;
    int x ;
    int cc ;

    memcpy( inf_img->palette, wext->pal, 6*inf_img->nb_cpal ) ;
    pt = inf_img->palette ;
    for (x = 0; x < inf_img->nb_cpal; x++)
    {
      cc   = (int) ((pc*(long)(*pt))/100L) ;
      *pt += cc ;
      pt++ ;
      cc   = (int) ((pc*(long)(*pt))/100L) ;
      *pt += cc ;
      pt++ ;
      cc   = (int) ((pc*(long)(*pt))/100L) ;
      *pt += cc ;
      pt++ ;
    }
    set_imgpalette( vimage ) ;
  }
}

void OnInitDialogFLum(void *w)
{
  GEM_WINDOW      *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_FLUM *wext = wnd->DlgData->UserData ;
  OBJECT          *adr_lumiere = wnd->DlgData->BaseObject ;

  memcpy( wext->pal, wext->inf_img->palette, 6*wext->inf_img->nb_cpal ) ;
  wext->w = adr_lumiere[LUMIERE_BOX].ob_width/2 ;
  vsf_interior(handle, FIS_SOLID) ;
  vswr_mode(handle, MD_REPLACE) ;
  write_text(adr_lumiere, LUMIERE_PC, "+00%") ;
  wext->w1 = adr_lumiere[LUMIERE_SLIDER].ob_width/2 ;
  adr_lumiere[LUMIERE_SLIDER].ob_x = wext->w - wext->w1 ;
}

int OnObjectNotifyFLum(void *w, int obj)
{
  GEM_WINDOW      *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_FLUM *wext = wnd->DlgData->UserData ;
  OBJECT          *adr_lumiere = wnd->DlgData->BaseObject ;
  int             xm, off_x, off_y, dummy ;
  int             code = -1 ;

  switch( obj )
  {
    case LUMIERE_MOINS  :
    case LUMIERE_PLUS   : if ( obj == LUMIERE_PLUS ) wext->pc++ ;
                          else                       wext->pc-- ;
                          if ( wext->pc > 99 )  wext->pc = 99 ;
                          if ( wext->pc < -99 ) wext->pc = -99 ;
                          update_lightbox( wnd, wext->pc, wext->w - wext->w1 ) ;
                          break ;
    case LUMIERE_BOX    : graf_mkstate( &xm, &dummy, &dummy, &dummy ) ;
                          objc_offset( adr_lumiere, LUMIERE_SLIDER, &off_x, &off_y ) ;
                          if ( xm > off_x ) wext->pc += 10 ;
                          else              wext->pc -= 10 ;
                          if ( wext->pc > 99 )  wext->pc = 99 ;
                          if ( wext->pc < -99 ) wext->pc = -99 ;
                          update_lightbox( wnd, wext->pc, wext->w - wext->w1 ) ;
                          break ;
    case LUMIERE_SLIDER : wext->pc = graf_slidebox( adr_lumiere, LUMIERE_BOX, LUMIERE_SLIDER, 0 ) ;
                          wext->pc = ( wext->pc-500 ) / 5 ;
                          update_lightbox( wnd, wext->pc, wext->w - wext->w1 ) ;
                          break ;
     case LUMIERE_OK    : code = IDOK ;
                          break ;
     case LUMIERE_CANCEL : code = IDCANCEL ;
                           break ;
  }

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

void traite_lumiere(GEM_WINDOW *gwnd)
{
  GEM_WINDOW      *dlg ;
  WEXTENSION_FLUM wext ;
  DLGDATA         dlg_data ;
  int             code ;

  if ( gwnd == NULL ) return ;
  wext.wnd     = gwnd ;
  wext.vimage  = (VXIMAGE *) gwnd->Extension ;
  wext.inf_img = &wext.vimage->inf_img ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_LUMIERE ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogFLum ;
  dlg_data.OnObjectNotify = OnObjectNotifyFLum ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( !Truecolor ) memcpy( wext.inf_img->palette, wext.pal, 6*wext.inf_img->nb_cpal ) ;

  if ( code == IDOK )
  {
    mouse_busy() ;
    undo_put( gwnd, 0, 0, wext.vimage->raster.fd_w-1, wext.vimage->raster.fd_h-1, ULUMIERE, NULL ) ;
    if ( Truecolor )
    {
      float pcx ;

      pcx = (float)wext.pc/100.0 ;
      set_tclum( wext.tc_lum, pcx ) ;
      make_tcpal( wext.tc_lum, wext.tc_lum, wext.tc_lum, gwnd ) ;
      GWRePaint( gwnd ) ;
    }
    else
    {
      float pcx ;
      int *pt ;
      int x, cc ;

      pcx = (float)wext.pc/100.0 ;
      pt  = wext.inf_img->palette ;
      for (x = 0; x < wext.inf_img->nb_cpal; x++)
      {
        cc   = pcx*(double)(*pt) ;
        *pt += cc ;
        if (*pt > 1000) *pt = 1000 ;
        pt++ ;
        cc   = pcx*(double)(*pt) ;
        *pt += cc ;
        if (*pt > 1000) *pt = 1000 ;
        pt++ ;
        cc   = pcx*(double)(*pt) ;
        *pt += cc ;
        if (*pt > 1000) *pt = 1000 ;
        pt++ ;
      }
      set_imgpalette( wext.vimage ) ;
    }
    set_modif( gwnd ) ;
    mouse_restore() ;
  }
  else
  {
    if ( Truecolor ) GWRePaint( gwnd ) ;
    else             set_imgpalette( wext.vimage ) ;
  }
}
