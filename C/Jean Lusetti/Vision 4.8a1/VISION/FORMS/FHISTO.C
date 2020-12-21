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


int cdecl draw_histo_rouge(PARMBLK *parmblock)
{
  WEXTENSION_HISTO *wext = (WEXTENSION_HISTO *) parmblock->pb_parm ;
  unsigned long *pth ;
  int           xyc[4] ;
  int           x, y ;

  if (parmblock->pb_prevstate != parmblock->pb_currstate) return(0) ;
  
  xyc[0] = parmblock->pb_xc ;
  xyc[1] = parmblock->pb_yc ;
  xyc[2] = xyc[0]+parmblock->pb_wc ;
  xyc[3] = xyc[1]+parmblock->pb_hc ;
  vs_clip(handle, 1, xyc);
	
  vswr_mode(handle, MD_REPLACE) ;
  vsl_color(handle, 2) ;
  vsl_width(handle, 1) ;
  v_hide_c(handle) ;
  y = parmblock->pb_y+parmblock->pb_h-1 ;
  pth = wext->histo.rouge ;
  for (x = parmblock->pb_x; x < parmblock->pb_x+parmblock->pb_w; x++)
  {
    line(x, y, x, y-(int)(*pth++)) ;
  }
  v_show_c(handle, 1) ;
  vs_clip(handle, 0, xyc) ;

  return(0) ;
}

int cdecl draw_histo_vert(PARMBLK *parmblock)
{ 
  WEXTENSION_HISTO *wext = (WEXTENSION_HISTO *) parmblock->pb_parm ;
  unsigned long *pth ;
  int           xyc[4] ;
  int           x, y ;

  if (parmblock->pb_prevstate != parmblock->pb_currstate) return(0) ;
  
  xyc[0] = parmblock->pb_xc ;
  xyc[1] = parmblock->pb_yc ;
  xyc[2] = xyc[0]+parmblock->pb_wc ;
  xyc[3] = xyc[1]+parmblock->pb_hc ;
  vs_clip(handle, 1, xyc);
	
  vswr_mode(handle, MD_REPLACE) ;
  vsl_color(handle, 3) ;
  vsl_width(handle, 1) ;
  v_hide_c(handle) ;
  y = parmblock->pb_y+parmblock->pb_h-1 ;
  pth = wext->histo.vert ;
  for (x = parmblock->pb_x; x < parmblock->pb_x+parmblock->pb_w; x++)
  {
    line(x, y, x, y-(int)(*pth++)) ;
  }
  v_show_c(handle, 1) ;
  vs_clip(handle, 0, xyc) ;

  return(0) ;
}

int cdecl draw_histo_bleu(PARMBLK *parmblock)
{ 
  WEXTENSION_HISTO *wext = (WEXTENSION_HISTO *) parmblock->pb_parm ;
  unsigned long *pth ;
  int           xyc[4] ;
  int           x, y ;

  if (parmblock->pb_prevstate != parmblock->pb_currstate) return(0) ;
  
  xyc[0] = parmblock->pb_xc ;
  xyc[1] = parmblock->pb_yc ;
  xyc[2] = xyc[0]+parmblock->pb_wc ;
  xyc[3] = xyc[1]+parmblock->pb_hc ;
  vs_clip(handle, 1, xyc);
	
  vswr_mode(handle, MD_REPLACE) ;
  vsl_color(handle, 4) ;
  vsl_width(handle, 1) ;
  v_hide_c(handle) ;
  y = parmblock->pb_y+parmblock->pb_h-1 ;
  pth = wext->histo.bleu ;
  for (x = parmblock->pb_x; x < parmblock->pb_x+parmblock->pb_w; x++)
  {
    line(x, y, x, y-(int)(*pth++)) ;
  }
  v_show_c(handle, 1) ;
  vs_clip(handle, 0, xyc) ;

  return(0) ;
}

int cdecl draw_histo_index(PARMBLK *parmblock)
{
  WEXTENSION_HISTO *wext = (WEXTENSION_HISTO *) parmblock->pb_parm ;
  unsigned char *tos2vdi ;
  unsigned long *pth ;
  unsigned long rgb24, rgb_inc ;
  int           xy[4], xyc[4], lxy[10], rgb[3] ;
  int           x, y ;

  if (parmblock->pb_prevstate != parmblock->pb_currstate) return(0) ;
  
  xyc[0] = parmblock->pb_xc ;
  xyc[1] = parmblock->pb_yc ;
  xyc[2] = xyc[0]+parmblock->pb_wc ;
  xyc[3] = xyc[1]+parmblock->pb_hc ;
  vs_clip(handle, 1, xyc);

  vswr_mode(handle, MD_REPLACE) ;
  vsf_interior(handle, FIS_SOLID) ;
  vsf_perimeter(handle, 0) ;
  vsl_width(handle, 1) ;
  v_hide_c(handle) ;
  y = parmblock->pb_y+parmblock->pb_h-1 ;
  if (Truecolor) pth = wext->histo.gris ;
  else           pth = wext->histo.index ;
  tos2vdi = get_pttos2vdi(screen.fd_nplanes) ;
  if ( wext->hlarg <= 1 )
  {
    rgb24    = 0 ;
    rgb_inc  = 0x00010101L ;
    for (x = parmblock->pb_x; x < parmblock->pb_x+parmblock->pb_w; x++)
    {
      if (Truecolor)
      {
        rgb24 += rgb_inc ;
        rgb[0] = (int) ((rgb24 & 0xFFL) << 2) ;
        if (rgb[0] > 1000) rgb[0] = 1000 ;
        rgb[1] = (int) (((rgb24 >> 8) & 0xFFL) << 2) ;
        if (rgb[1] > 1000) rgb[1] = 1000 ;
        rgb[2] = (int) (((rgb24 >> 16) & 0xFFL) << 2) ;
        if (rgb[2] > 1000) rgb[2] = 1000 ;
        vs_color(handle, 17, rgb) ;
        vsl_color(handle, 17) ;
      }
      else if ( tos2vdi )
        vsl_color(handle, tos2vdi[pth-wext->histo.index]) ;
      line(x, y, x, y-(int)(*pth++)) ;
    }
  }
  else if ( tos2vdi )
  {
    xy[1] = y ;
    for (x = parmblock->pb_x; x < parmblock->pb_x+parmblock->pb_w; x += wext->hlarg)
    {
      vsf_color(handle, tos2vdi[pth-wext->histo.index]) ;
      xy[0] = x ;
      xy[2] = x+wext->hlarg ;
      xy[3] = y-(int)(*pth++) ;
      v_bar(handle, xy) ;
      vsl_color(handle, 1) ;
      lxy[0] = x ;       lxy[1] = xy[3] ;
      lxy[2] = x+wext->hlarg ; lxy[3] = xy[3] ;
      lxy[4] = x+wext->hlarg ; lxy[5] = y ;
      lxy[6] = x ;       lxy[7] = y ;
      lxy[8] = x ;       lxy[9] = xy[3] ;
      v_pline(handle, 5, lxy) ;
    }
  }
  v_show_c(handle, 1) ;
  vs_clip(handle, 0, xyc) ;

  return( 0 ) ;
}

void OnInitDialogHisto(void *w)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW* ) w ;
  WEXTENSION_HISTO *wext = wnd->DlgData->UserData ;
  VXIMAGE          *vimage = wext->vimage ;
  OBJECT           *adr_histo = wnd->DlgData->BaseObject ;
  char             buf[10] ;

  adr_histo[HISTO_ROUGE].ob_spec.userblk->ub_code = draw_histo_rouge ;
  adr_histo[HISTO_ROUGE].ob_spec.userblk->ub_parm = (long) wext ;
  adr_histo[HISTO_VERT].ob_spec.userblk->ub_code  = draw_histo_vert ;
  adr_histo[HISTO_VERT].ob_spec.userblk->ub_parm = (long) wext ;
  adr_histo[HISTO_BLEU].ob_spec.userblk->ub_code  = draw_histo_bleu ;
  adr_histo[HISTO_BLEU].ob_spec.userblk->ub_parm = (long) wext ;
  adr_histo[HISTO_INDEX].ob_spec.userblk->ub_code = draw_histo_index ;
  adr_histo[HISTO_INDEX].ob_spec.userblk->ub_parm = (long) wext ;

  if (vimage->inf_img.mfdb.fd_nplanes <= 8)
  {
    sprintf(buf, "%d", (1 << vimage->inf_img.mfdb.fd_nplanes)-1) ;
    write_text(adr_histo, HISTO_LASTINDEX, buf) ;
  }
  vsl_type(handle, SOLID) ;
  vsl_ends(handle, SQUARE, SQUARE) ;
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
  GEM_WINDOW* dlg ;
  DLGDATA     dlg_data ;
  int         code ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_HISTO ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogHisto ;
  dlg_data.OnObjectNotify = OnObjectNotifyHisto ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return( code ) ;
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

  Xrsrc_gaddr(R_TREE, FORM_HISTO, &adr_histo) ;
  wext.histo.norm = adr_histo[HISTO_ROUGE].ob_height ;
  wprog = DisplayStdProg( MsgTxtGetMsg(hMsg, MSG_HISTO) , "", "", CLOSER ) ;
  mouse_busy() ;
  wext.hlarg = (int) ((float)adr_histo[HISTO_ROUGE].ob_width/(float)(1 << vimage->inf_img.mfdb.fd_nplanes)) ;
  if ( compute_histo( inf_img, &wext.histo, wprog, UseStdVDI ) != 0 )
  {
    mouse_restore() ;
    PostMessage( wprog, GWM_DESTROY, NULL ) ;
    form_error(8) ;
    return ;
  }
  mouse_restore() ;
  PostMessage( wprog, GWM_DESTROY, NULL ) ;

  FGetHisto( &wext ) ;
}
