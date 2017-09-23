#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"
#include "..\tools\stdprog.h"

#include "..\tools\dither.h"
#include "..\tools\rasterop.h"
#include "..\tools\image_io.h"

#include "actions.h"
#include "undo.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  GEM_WINDOW *wnd ;
  VXIMAGE    *vimage ;

  int        nplan, newnplan ;
  int        dither_no ;
  char       gris ;
}
WEXTENSION_CONV ;


void OnInitDialogConv(void *w)
{
  GEM_WINDOW      *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_CONV *wext = wnd->DlgData->UserData ;
  VXIMAGE         *vimage = wext->vimage ;
  OBJECT          *adr_conv = wnd->DlgData->BaseObject ;
  char            *pos ;
  char            buf[20] ;

  pos = strrchr(vimage->inf_img.nom, '\\') ;
  if (pos != NULL)
  {
    pos++ ;
    write_text(adr_conv, CONV_ANAME, pos) ;
  }

  wext->nplan = vimage->inf_img.nplans ;
  if (wext->nplan > 8) strcpy(buf, "16M") ;
  else           sprintf(buf, "%.3d", 1 << wext->nplan) ;
  write_text(adr_conv, CONV_ACOL, buf) ;

  adr_conv[CONV_S2].ob_state   &= ~DISABLED ;
  adr_conv[CONV_S4].ob_state   &= ~DISABLED ;
  adr_conv[CONV_S16].ob_state  &= ~DISABLED ;
  adr_conv[CONV_S256].ob_state &= ~DISABLED ;
  deselect(adr_conv, CONV_S2) ;
  deselect(adr_conv, CONV_S4) ;
  deselect(adr_conv, CONV_S16) ;
  deselect(adr_conv, CONV_S256) ;
  switch(nb_planes(nb_colors))
  {
    case 1 : adr_conv[CONV_S4].ob_state   |= DISABLED ;
             adr_conv[CONV_S16].ob_state  |= DISABLED ;
             adr_conv[CONV_S256].ob_state |= DISABLED ;
             break ;
    case 2 : adr_conv[CONV_S16].ob_state  |= DISABLED ;
             adr_conv[CONV_S256].ob_state |= DISABLED ;
             break ;
    case 4 : adr_conv[CONV_S256].ob_state |= DISABLED ;
             break ;
  }

  if (Truecolor)
  {
    adr_conv[CONV_S2].ob_state   |= DISABLED ;
    adr_conv[CONV_S4].ob_state   |= DISABLED ;
    adr_conv[CONV_S16].ob_state  |= DISABLED ;
    adr_conv[CONV_S256].ob_state |= DISABLED ;
    select(adr_conv, CONV_RVBGRIS) ;
    deselect(adr_conv, CONV_S2) ;
    deselect(adr_conv, CONV_S4) ;
    deselect(adr_conv, CONV_S16) ;
    deselect(adr_conv, CONV_S256) ;
  }
  else
    deselect(adr_conv, CONV_RVBGRIS) ;
  switch(wext->nplan)
  {
    case 1 : select(adr_conv, CONV_S2) ;
             break ;
    case 2 : select(adr_conv, CONV_S4) ;
             break ;
    case 4 : select(adr_conv, CONV_S16) ;
             break ;
    case 8 : select(adr_conv, CONV_S256) ;
             break ;
  }

  if (wext->nplan >= 4) adr_conv[CONV_RVBGRIS].ob_state &= ~DISABLED ;
  else            adr_conv[CONV_RVBGRIS].ob_state |= DISABLED ;
}

int OnObjectNotifyConv(void *w, int obj)
{
  GEM_WINDOW      *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_CONV *wext = wnd->DlgData->UserData ;
  OBJECT          *adr_conv = wnd->DlgData->BaseObject ;
  int             code = -1 ;

  switch( obj )
  {
    case CONV_DITHERNO   :
    case CONV_TDITHERNO  : if (!selected(adr_conv, CONV_DITHERNO))
                           {
                             inv_select(adr_conv, CONV_DITHERNO) ;
                             inv_select(adr_conv, CONV_DITHERMAT) ;
                           }
                           break ;
    case CONV_DITHERMAT  :
    case CONV_TDITHERMAT : if (!selected(adr_conv, CONV_DITHERMAT))
                           {
                             inv_select(adr_conv, CONV_DITHERNO) ;
                             inv_select(adr_conv, CONV_DITHERMAT) ;
                           }
                           break ;
     case CONV_OK        : code = IDOK ;
                           break ;
     case CONV_CANCEL    : code = IDCANCEL ;
                           break ;
  }

  if ( code == IDOK )
  {
    wext->newnplan = wext->nplan ;
    if (selected(adr_conv, CONV_S2))   wext->newnplan = 1 ;
    if (selected(adr_conv, CONV_S4))   wext->newnplan = 2 ;
    if (selected(adr_conv, CONV_S16))  wext->newnplan = 4 ;
    if (selected(adr_conv, CONV_S256)) wext->newnplan = 8 ;
    wext->gris      = selected( adr_conv, CONV_RVBGRIS) ;
    wext->dither_no = selected(adr_conv, CONV_DITHERNO) ;
  }

  return( code ) ;
}

void rvb2gris(GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  mouse_busy() ;
  make_greyimage( &vimage->raster, &vimage->inf_img ) ;

  if ( vimage->raster.fd_nplanes <= 8 ) set_imgpalette( vimage ) ;
  else                                  GWRePaint( gwnd ) ;

  set_modif( gwnd ) ;
  mouse_restore() ;
}

void raz_imgplanes(GEM_WINDOW *gwnd, int new_nplanes)
{
  VXIMAGE *vimage ;
  long taille ;
  long i, toti ;
  int  *pt_img ;
  int  add ;

  if ( gwnd == NULL ) return ;
  vimage = gwnd->Extension ;

  taille = vimage->raster.fd_nplanes-new_nplanes ;
  if (taille <= 0) return ;
  add    = vimage->raster.fd_nplanes ;
  taille = taille*2 ;
  pt_img = (int *) vimage->raster.fd_addr ;
  pt_img = pt_img+new_nplanes ;
  toti   = (long)vimage->raster.fd_h*(long)vimage->raster.fd_wdwidth ;
  for (i = 0; i < toti; i++)
  {
    memset(pt_img, 0, taille) ;
    pt_img = pt_img+add ;
  }
}

void traite_conversion(GEM_WINDOW *gwnd)
{
  GEM_WINDOW      *dlg, *wprog ;
  VXIMAGE         *vimage ;
  WEXTENSION_CONV wext ;
  DLGDATA         dlg_data ;
  int             code ;

  if ( gwnd == NULL ) return ;

  wext.wnd    = gwnd ;
  wext.vimage = vimage = gwnd->Extension ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_CONVERSION ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogConv ;
  dlg_data.OnObjectNotify = OnObjectNotifyConv ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code != IDOK ) return ;

  undo_put( gwnd, 0, 0, vimage->raster.fd_w-1, vimage->raster.fd_h-1, UCONVERT, NULL ) ;

  if ( wext.newnplan == wext.nplan )
  {
    if ( wext.gris ) rvb2gris( gwnd ) ;
    return ;
  }

  if ( wext.nplan < wext.newnplan ) vimage->inf_img.nplans = wext.newnplan ;
  else
  {
    int rep = rep = form_interrogation(2, msg[MSG_DECNPLAN]) ;

    if (rep == 2) return ;
    if ( wext.dither_no ) raz_imgplanes( gwnd, wext.newnplan ) ;
    else
    {
      MFDB temp ;

      temp.fd_nplanes = wext.newnplan ;
      wprog = DisplayStdProg( msg[MSG_DITHER], "", "", CLOSER ) ;
      mouse_busy() ;
      if ( dither( DITHER_SEUIL, &vimage->raster, &vimage->inf_img, &temp, wprog ) == -1 )
      {
        mouse_restore() ;
        form_error(8) ;
        GWDestroyWindow( wprog ) ;
        return ;
      }
      mouse_restore() ;
      GWDestroyWindow( wprog ) ;
      free( vimage->raster.fd_addr ) ;
      if (temp.fd_nplanes < nb_plane ) incnbplanes(&temp, nb_planes(nb_colors)) ;
      vimage->raster.fd_addr = temp.fd_addr ;
    }
    vimage->inf_img.nplans  = wext.newnplan ;
    vimage->inf_img.nb_cpal = 1 << wext.newnplan ;
    set_modif( gwnd ) ;
    GWRePaint( gwnd ) ;
  }
}
