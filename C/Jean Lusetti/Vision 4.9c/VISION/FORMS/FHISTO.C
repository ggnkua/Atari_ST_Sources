#include <string.h>
#include "..\tools\gwindows.h"

#include "..\tools\rasterop.h"

#include "defs.h"
#include "undo.h"
#include "actions.h"
#include "gstenv.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  GEM_WINDOW* wnd ;
  VXIMAGE    *vimage ;
  INFO_IMAGE *inf_img ;

  HISTO histo ;
  int   hlarg ;
}
WEXTENSION_HISTO ;


static void draw_histo(PARMBLK* parmblock, short color_index, unsigned long* histo_data)
{
  int xyc[4] ;
  int x, y ;

  if ( parmblock && (parmblock->pb_prevstate == parmblock->pb_currstate) )
  {
    xyc[0] = parmblock->pb_xc ;
    xyc[1] = parmblock->pb_yc ;
    xyc[2] = xyc[0]+parmblock->pb_wc ;
    xyc[3] = xyc[1]+parmblock->pb_hc ;
    svs_clipON( xyc ) ;

    (void) svswr_mode( MD_REPLACE ) ;
    (void)svsl_color( color_index ) ;
    svsl_width( 1 ) ;
    GWHideCursor() ;
    y = parmblock->pb_y+parmblock->pb_h-1 ;
    for (x = parmblock->pb_x; x < parmblock->pb_x+parmblock->pb_w; x++)
      line(x, y, x, y-(int)(*histo_data++)) ;
    GWShowCursor() ;
    svs_clipOFF( xyc ) ;
  }
}

static int cdecl draw_histo_rouge(PARMBLK* parmblock)
{
  WEXTENSION_HISTO* wext = (WEXTENSION_HISTO*) parmblock->pb_parm ;

  draw_histo( parmblock, 2, wext->histo.rouge ) ;

  return 0 ;
}

static int cdecl draw_histo_vert(PARMBLK* parmblock)
{
  WEXTENSION_HISTO* wext = (WEXTENSION_HISTO*) parmblock->pb_parm ;

  draw_histo( parmblock, 3, wext->histo.vert ) ;

  return 0 ;
}

static int cdecl draw_histo_bleu(PARMBLK* parmblock)
{
  WEXTENSION_HISTO* wext = (WEXTENSION_HISTO*) parmblock->pb_parm ;

  draw_histo( parmblock, 4, wext->histo.bleu ) ;

  return 0 ;
}

static int cdecl draw_histo_index(PARMBLK* parmblock)
{
  WEXTENSION_HISTO* wext = (WEXTENSION_HISTO *) parmblock->pb_parm ;
  unsigned char*    tos2vdi ;
  unsigned long*    pth ;
  unsigned long     rgb24, rgb_inc ;
  int               xy[4], xyc[4], lxy[10], rgb[3] ;
  int               x, y ;

  if ( parmblock->pb_prevstate != parmblock->pb_currstate ) return 0 ;
  
  xyc[0] = parmblock->pb_xc ;
  xyc[1] = parmblock->pb_yc ;
  xyc[2] = xyc[0]+parmblock->pb_wc ;
  xyc[3] = xyc[1]+parmblock->pb_hc ;
  svs_clipON( xyc ) ;

  (void) svswr_mode( MD_REPLACE ) ;
  vsf_interior ( handle, FIS_SOLID ) ;
  svsf_perimeter( 0 ) ;
  svsl_width( 1 ) ;
  y = parmblock->pb_y+parmblock->pb_h-1 ;
  if ( Truecolor ) pth = wext->histo.gris ;
  else             pth = wext->histo.index ;
  tos2vdi = get_pttos2vdi( screen.fd_nplanes ) ;
  GWHideCursor() ;
  if ( wext->hlarg <= 1 )
  {
    rgb24   = 0 ;
    rgb_inc = 0x00010101L ;
    for ( x = parmblock->pb_x; x < parmblock->pb_x+parmblock->pb_w; x++ )
    {
      if ( Truecolor )
      {
        rgb24 += rgb_inc ;
        rgb[0] = (int) ((rgb24 & 0xFFL) << 2) ;
        if (rgb[0] > 1000) rgb[0] = 1000 ;
        rgb[1] = (int) (((rgb24 >> 8) & 0xFFL) << 2) ;
        if (rgb[1] > 1000) rgb[1] = 1000 ;
        rgb[2] = (int) (((rgb24 >> 16) & 0xFFL) << 2) ;
        if (rgb[2] > 1000) rgb[2] = 1000 ;
        svs_color( 17, rgb ) ;
        (void)svsl_color( 17 ) ;
      }
      else if ( tos2vdi ) (void)svsl_color( tos2vdi[pth-wext->histo.index] ) ;
      line( x, y, x, y-(int)(*pth++) ) ;
    }
  }
  else if ( tos2vdi )
  {
    xy[1] = y ;
    for ( x = parmblock->pb_x; x < parmblock->pb_x+parmblock->pb_w; x += wext->hlarg )
    {
      svsf_color(  tos2vdi[pth-wext->histo.index] ) ;
      xy[0] = x ;
      xy[2] = x+wext->hlarg ;
      xy[3] = y-(int)(*pth++) ;
      v_bar( handle, xy ) ;
      (void)svsl_color( 1 ) ;
      lxy[0] = x ;       lxy[1] = xy[3] ;
      lxy[2] = x+wext->hlarg ; lxy[3] = xy[3] ;
      lxy[4] = x+wext->hlarg ; lxy[5] = y ;
      lxy[6] = x ;       lxy[7] = y ;
      lxy[8] = x ;       lxy[9] = xy[3] ;
      sv_pline( 5, lxy ) ;
    }
  }
  GWShowCursor() ;
  svs_clipOFF( xyc ) ;

  return 0 ;
}

void OnInitDialogHisto(void* w)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_HISTO *wext = wnd->DlgData->UserData ;
  VXIMAGE          *vimage = wext->vimage ;
  OBJECT           *adr_histo = wnd->DlgData->BaseObject ;
  char             buf[10] ;

  adr_histo[HISTO_ROUGE].ob_spec.userblk->ub_code = draw_histo_rouge ;
  adr_histo[HISTO_ROUGE].ob_spec.userblk->ub_parm = (long) wext ;
  adr_histo[HISTO_VERT].ob_spec.userblk->ub_code  = draw_histo_vert ;
  adr_histo[HISTO_VERT].ob_spec.userblk->ub_parm  = (long) wext ;
  adr_histo[HISTO_BLEU].ob_spec.userblk->ub_code  = draw_histo_bleu ;
  adr_histo[HISTO_BLEU].ob_spec.userblk->ub_parm  = (long) wext ;
  adr_histo[HISTO_INDEX].ob_spec.userblk->ub_code = draw_histo_index ;
  adr_histo[HISTO_INDEX].ob_spec.userblk->ub_parm = (long) wext ;

  if (vimage->inf_img.mfdb.fd_nplanes <= 8)
  {
    sprintf(buf, "%d", (1 << vimage->inf_img.mfdb.fd_nplanes)-1) ;
    write_text(adr_histo, HISTO_LASTINDEX, buf) ;
  }
  svsl_type( SOLID) ;
  svsl_ends( SQUARE, SQUARE) ;
  if ( Truecolor )
  {
    adr_histo[HISTO_INDICE].ob_flags |= HIDETREE ;
    adr_histo[HISTO_GRIS].ob_flags   &= ~HIDETREE ;
  }
  else
  {
    adr_histo[HISTO_INDICE].ob_flags &= ~HIDETREE ;
    adr_histo[HISTO_GRIS].ob_flags   |= HIDETREE ;
  }
  if ( wext->histo.nb_colors_used > 65000L )
    sprintf( buf, "> 65000" ) ;
  else
    sprintf( buf, "%lu", wext->histo.nb_colors_used ) ;

  write_text( adr_histo, HISTO_NBCOLORS, buf ) ;
}

#pragma warn -par
int OnObjectNotifyHisto(void *w, int obj)
{
  int code = -1 ;

  switch( obj )
  {
    case HISTO_OK : code = IDOK ;
                    break ;
  }

  if ( code == IDOK )
  {

  }

  return code ;
}
#pragma warn +par

int FGetHisto(WEXTENSION_HISTO* wext)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_HISTO ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogHisto ;
  dlg_data.OnObjectNotify = OnObjectNotifyHisto ;

  return GWCreateAndDoModal( &dlg_data, 0 ) ;
}

void traite_histo(GEM_WINDOW* gwnd)
{
  WEXTENSION_HISTO wext ;
  GEM_WINDOW*      wprog ;
  OBJECT*          adr_histo ;
  VXIMAGE*         vimage ;
  INFO_IMAGE*      inf_img ;

  if ( gwnd == NULL ) return ;
  wext.wnd     = gwnd ;
  wext.vimage  = vimage = (VXIMAGE*) gwnd->Extension ;
  wext.inf_img = inf_img = &vimage->inf_img ;

  Xrsrc_gaddr( R_TREE, FORM_HISTO, &adr_histo ) ;
  wext.histo.norm = adr_histo[HISTO_ROUGE].ob_height ;
  wprog = DisplayStdProg( vMsgTxtGetMsg(MSG_HISTO) , "", "", CLOSER ) ;
  mouse_busy() ;
  wext.hlarg = (int) ((float)adr_histo[HISTO_ROUGE].ob_width/(float)(1 << vimage->inf_img.mfdb.fd_nplanes)) ;
  if ( compute_histo( inf_img, &wext.histo, wprog, UseStdVDI ) != 0 )
  {
    mouse_restore() ;
    PostMessage( wprog, GWM_DESTROY, NULL ) ;
    form_error_mem() ;
    return ;
  }
  mouse_restore() ;
  PostMessage( wprog, GWM_DESTROY, NULL ) ;

  FGetHisto( &wext ) ;
}
