#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "..\tools\gwindows.h"

#include "..\tools\rasterop.h"

#include "defs.h"
#include "undo.h"
#include "actions.h"
#include "gstenv.h"
#include "ftcwheel.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  GEM_WINDOW *wnd ;
  VXIMAGE    *vimage ;
  INFO_IMAGE *inf_img ;

  float  hf ;

  int    rgb[3] ;
  int    curr_rgb[3] ;
  int    curr_pal[256*3] ;
  int    index ;
  int    stdeg, enddeg ;
  int    flag_aff ;
  int    nb_col_x ;
  int    ww, hh ;

}
WEXTENSION_PAL ;


char path_palette[PATH_MAX] ;


void cree_degrade(int start, int end)
{
  float r, g, b ;
  float c ;
  int   rgb[3] ;
  int   srgb[3] ;
  int   ergb[3] ;
  int   i ;
  int   nb ;

  if (start > end)
  {
    i     = start ;
    start = end ;
    end   = i ;
  }

  vq_color(handle, start, 0, srgb) ;
  vq_color(handle, end, 0, ergb) ;
  nb = 1+end-start ;
  r = (float)(ergb[0]-srgb[0])/(float)nb ;
  g = (float)(ergb[1]-srgb[1])/(float)nb ;
  b = (float)(ergb[2]-srgb[2])/(float)nb ;
  for (i = start; i <= end; i++)
  {
    c      = (float)srgb[0]+(float)(i-start)*r ;
    rgb[0] = (int) c ;
    c      = (float)srgb[1]+(float)(i-start)*g ;
    rgb[1] = (int) c ;
    c      = (float)srgb[2]+(float)(i-start)*b ;
    rgb[2] = (int) c ;
    vs_color(handle, i, rgb) ;
  }
}

void charge_palette(void)
{
  int  pal[256*3] ;
  int  ncol ;
  char name[200] ;
  char *pt ;

  if (*path_palette == 0)
  {
    Dgetpath( path_palette+2, 0 ) ;
    path_palette[1] = ':' ;
    path_palette[0] = 'A'+Dgetdrv() ;
    strcat(path_palette, "\\*.PAL") ;
  }

  if (file_name(path_palette, "", name))
  {
    FILE *stream ;

    ncol   = (int) file_size(name)/6 ;
    stream = fopen(name, "rb") ;
    if ( ( ncol < 0 ) || ( stream == NULL ) )
    {
      if ( stream ) fclose(stream) ;
      form_stop(1, MsgTxtGetMsg(hMsg, MSG_FILENOTEXIST) ) ;
      return ;
    }
    if (ncol > nb_colors) ncol = nb_colors ;
    fread(pal, 6, ncol, stream) ;
    fclose(stream) ;
    set_vdipalette(pal, ncol) ;
    strcpy(path_palette, name) ;
    pt = strrchr(path_palette, '\\') ;
    if (pt != NULL) *(1+pt) = 0 ;
    else            *path_palette = 0 ;
  }
}

void sauve_palette(void)
{
  int  pal[256*3] ;
  char name[200] ;
  char *pt ;

  if (*path_palette == 0)
  {
    Dgetpath( path_palette+2, 0 ) ;
    path_palette[1] = ':' ;
    path_palette[0] = 'A'+Dgetdrv() ;
    strcat(path_palette, "\\*.PAL") ;
  }

  if (file_name(path_palette, "", name))
  {
    FILE *stream ;

    stream = fopen(name, "wb") ;
    if (stream == NULL)
    {
      form_stop(1, MsgTxtGetMsg(hMsg, MSG_WRITEERROR) ) ;
      return ;
    }
    get_vdipalette(pal) ;
    if (fwrite(pal, 6, nb_colors, stream) != nb_colors)
      form_stop(1, MsgTxtGetMsg(hMsg, MSG_WRITEERROR) ) ;
    fclose(stream) ;
    strcpy(path_palette, name) ;
    pt = strrchr(path_palette, '\\') ;
    if (pt != NULL) *(1+pt) = 0 ;
    else            *path_palette = 0 ;
  }
}

int cdecl draw_colors(PARMBLK *parmblock)
{ 
  WEXTENSION_PAL *wext = (WEXTENSION_PAL *) parmblock->pb_parm ;
  int            xyc[4], xy[4] ;
  int            nb_col_y, col_y, col_x, ind_col ;
  	
  nb_col_y = wext->nb_col_x = (int)sqrt((double)nb_colors) ;
  wext->ww = (int)(parmblock->pb_w/wext->nb_col_x) ;
  wext->hh = (int)(parmblock->pb_h/nb_col_y) ;

  if (parmblock->pb_prevstate != parmblock->pb_currstate) return(0) ;

  xyc[0] = parmblock->pb_xc ;
  xyc[1] = parmblock->pb_yc ;
  xyc[2] = xyc[0]+parmblock->pb_wc ;
  xyc[3] = xyc[1]+parmblock->pb_hc ;
  vs_clip(handle, 1, xyc) ;

  vswr_mode(handle, MD_REPLACE) ;
  vsf_interior(handle, FIS_SOLID) ;
  vsf_style(handle, 7) ;
  vsf_perimeter(handle, 1) ;

  xy[1] = parmblock->pb_y ;
  xy[3] = xy[1]+wext->hh ;
  for (col_y = 0, ind_col = 0; col_y < nb_col_y; col_y++)
  {
    xy[0] = parmblock->pb_x ;
    xy[2] = xy[0]+wext->ww ;
    for (col_x = 0; col_x < wext->nb_col_x; col_x++, ind_col++)
    {
      vsf_color(handle, ind_col) ;
	  v_bar(handle, xy) ;
      xy[0] += wext->ww ;
      xy[2] += wext->ww ;
    }
    xy[1] += wext->hh ;
	xy[3] += wext->hh ;
  }
  vs_clip(handle, 0, xyc);

  return(0) ;
}

int cdecl draw_currentcolor(PARMBLK *parmblock)
{ 
  WEXTENSION_PAL *wext = (WEXTENSION_PAL *) parmblock->pb_parm ;
  int            xyc[4], xy[4] ;
  	
  if (parmblock->pb_prevstate != parmblock->pb_currstate) return(0) ;
  
  xyc[0] = parmblock->pb_xc ;
  xyc[1] = parmblock->pb_yc ;
  xyc[2] = xyc[0]+parmblock->pb_wc ;
  xyc[3] = xyc[1]+parmblock->pb_hc ;
  vs_clip(handle, 1, xyc);
	
  vswr_mode(handle, MD_REPLACE) ;
  vsf_interior(handle, FIS_SOLID) ;	
  vsf_style(handle, 7) ;
  vsf_perimeter(handle, 1) ;
  vsf_color(handle, wext->index) ;
  xy[0] = parmblock->pb_x ;
  xy[1] = parmblock->pb_y ;
  xy[2] = parmblock->pb_x+parmblock->pb_w-1 ;
  xy[3] = parmblock->pb_y+parmblock->pb_h-1 ;
  v_hide_c(handle) ;
  v_bar(handle, xy) ;
  v_show_c(handle, 1) ;
  vs_clip(handle, 0, xyc) ;

  return(0) ;
}

void OnInitDialogPal(void *w)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_PAL *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_mkpal = wnd->DlgData->BaseObject ;
  int            off_y ;
  char           buf[15] ;

  adr_mkpal[MKPAL_BOX].ob_spec.userblk->ub_code = draw_colors ;
  adr_mkpal[MKPAL_BOX].ob_spec.userblk->ub_parm = (long) wext ;
  adr_mkpal[MKPAL_CURRCOL].ob_spec.userblk->ub_code = draw_currentcolor ;
  adr_mkpal[MKPAL_CURRCOL].ob_spec.userblk->ub_parm = (long) wext ;

  get_vdipalette( wext->curr_pal ) ;
  wext->index = 0 ;
  wext->stdeg = wext->enddeg = 500 ;
  wext->hf    = (float) (adr_mkpal[MKPAL_REDBOX].ob_height-adr_mkpal[MKPAL_RED].ob_height) ;
  vq_color(handle, wext->index, 0, wext->rgb) ;
  sprintf(buf, "%.4d",wext->rgb[0]) ;
  write_text(adr_mkpal, MKPAL_TRED, buf) ;
  sprintf(buf, "%.4d", wext->rgb[1]) ;
  write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
  sprintf(buf, "%.4d", wext->rgb[2]) ;
  write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
  off_y = (int) ((1000-wext->rgb[0])*(float)wext->hf/1000.0) ;
  adr_mkpal[MKPAL_RED].ob_y = off_y ;
  off_y = (int) ((1000-wext->rgb[1])*(float)wext->hf/1000.0) ;
  adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
  off_y = (int) ((1000-wext->rgb[2])*(float)wext->hf/1000.0) ;
  adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
  wext->flag_aff = 0 ;
}

int OnObjectNotifyPal(void *w, int obj)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_PAL *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_mkpal = wnd->DlgData->BaseObject ;
  int            off_x, off_y ;
  int            xm, ym, dummy ;
  int            pb_x, pb_y ;
  int            x1, y1, x2, y2 ;
  int            code = -1 ;
  char           buf[15] ;

  graf_mkstate( &xm, &ym, &dummy, &dummy ) ;

  switch( obj )
  {
    case MKPAL_MRED      :
    case MKPAL_PRED      : if ( obj == MKPAL_PRED ) wext->curr_rgb[0]++ ;
                           else                     wext->curr_rgb[0]-- ;
                           if (wext->curr_rgb[0] < 1)    wext->curr_rgb[0] = 1 ;
                           if (wext->curr_rgb[0] > 1000) wext->curr_rgb[0] = 1000 ;
                           off_y = (int) ((1000-wext->curr_rgb[0])*(float)wext->hf/1000.0) ;
                           adr_mkpal[MKPAL_RED].ob_y = off_y ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_REDBOX ) ;
                           sprintf(buf, "%.4d", wext->curr_rgb[0]) ;
                           write_text(adr_mkpal, MKPAL_TRED, buf) ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_TRED ) ;
                           vs_color(handle, wext->index, wext->curr_rgb) ;
                           break ;
    case MKPAL_MGREEN    :
    case MKPAL_PGREEN    : if ( obj == MKPAL_PGREEN ) wext->curr_rgb[1]++ ;
                           else                       wext->curr_rgb[1]-- ;
                           if (wext->curr_rgb[1] < 1)    wext->curr_rgb[1] = 1 ;
                           if (wext->curr_rgb[1] > 1000) wext->curr_rgb[1] = 1000 ;
                           off_y = (int) ((1000-wext->curr_rgb[1])*(float)wext->hf/1000.0) ;
                           adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_GREENBOX ) ;
                           sprintf(buf, "%.4d", wext->curr_rgb[1]) ;
                           write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_TGREEN ) ;
                           vs_color(handle, wext->index, wext->curr_rgb) ;
                           break ;
    case MKPAL_MBLUE     :
    case MKPAL_PBLUE     : if ( obj == MKPAL_PBLUE ) wext->curr_rgb[2]++ ;
                           else                      wext->curr_rgb[2]-- ;
                           if (wext->curr_rgb[2] < 1)    wext->curr_rgb[2] = 1 ;
                           if (wext->curr_rgb[2] > 1000) wext->curr_rgb[2] = 1000 ;
                           off_y = (int) ((1000-wext->curr_rgb[2])*(float)wext->hf/1000.0) ;
                           adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_BLUEBOX ) ;
                           sprintf(buf, "%.4d", wext->curr_rgb[2]) ;
                           write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_TBLUE ) ;
                           vs_color(handle, wext->index, wext->curr_rgb) ;
                           break ;
    case MKPAL_REDBOX    : 
                           objc_offset(adr_mkpal, MKPAL_RED, &off_x, &off_y) ;
                           if (ym > off_y) wext->curr_rgb[0] = wext->curr_rgb[0]-20 ;
                           else            wext->curr_rgb[0] = wext->curr_rgb[0]+20 ;
                           if (wext->curr_rgb[0] < 1)    wext->curr_rgb[0] = 1 ;
                           if (wext->curr_rgb[0] > 1000) wext->curr_rgb[0] = 1000 ;
                           off_y = (int) ((1000-wext->curr_rgb[0])*(float)wext->hf/1000.0) ;
                           adr_mkpal[MKPAL_RED].ob_y = off_y ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_REDBOX ) ;
                           sprintf(buf, "%.4d", wext->curr_rgb[0]) ;
                           write_text(adr_mkpal, MKPAL_TRED, buf) ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_TRED ) ;
                           vs_color(handle, wext->index, wext->curr_rgb) ;
                           break ;
    case MKPAL_GREENBOX  : 
                           objc_offset(adr_mkpal, MKPAL_GREEN, &off_x, &off_y) ;
                           if (ym > off_y) wext->curr_rgb[1] = wext->curr_rgb[1]-20 ;
                           else            wext->curr_rgb[1] = wext->curr_rgb[1]+20 ;
                           if (wext->curr_rgb[1] < 1)  wext->curr_rgb[1] = 1 ;
                           if (wext->curr_rgb[1] > 1000) wext->curr_rgb[1] = 1000 ;
                           off_y = (int) ((1000-wext->curr_rgb[1])*(float)wext->hf/1000.0) ;
                           adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_GREENBOX ) ;
                           sprintf(buf, "%.4d", wext->curr_rgb[1]) ;
                           write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_TGREEN ) ;
                           vs_color(handle, wext->index, wext->curr_rgb) ;
                           break ;
    case MKPAL_BLUEBOX   : 
                           objc_offset(adr_mkpal, MKPAL_BLUE, &off_x, &off_y) ;
                           if (ym > off_y) wext->curr_rgb[2] = wext->curr_rgb[2]-20 ;
                           else            wext->curr_rgb[2] = wext->curr_rgb[2]+20 ;
                           if (wext->curr_rgb[2] < 1)    wext->curr_rgb[2] = 1 ;
                           if (wext->curr_rgb[2] > 1000) wext->curr_rgb[2] = 1000 ;
                           off_y = (int) ((1000-wext->curr_rgb[2])*(float)wext->hf/1000.0) ;
                           adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_BLUEBOX ) ;
                           sprintf(buf, "%.4d", wext->curr_rgb[2]) ;
                           write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_TBLUE ) ;
                           vs_color(handle, wext->index, wext->curr_rgb) ;
                           break ;
    case MKPAL_RED       : wext->curr_rgb[0] = (float) graf_slidebox(adr_mkpal, MKPAL_REDBOX, MKPAL_RED, 1) ;
                           off_y = (int) (wext->curr_rgb[0]*(float)wext->hf/1000.0) ;
                           adr_mkpal[MKPAL_RED].ob_y = off_y ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_REDBOX ) ;
                           wext->curr_rgb[0] = 1000-wext->curr_rgb[0] ;
                           sprintf(buf, "%.4d", wext->curr_rgb[0]) ;
                           write_text(adr_mkpal, MKPAL_TRED, buf) ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_TRED ) ;
                           vs_color(handle, wext->index, wext->curr_rgb) ;
                           break ;
     case MKPAL_GREEN    : wext->curr_rgb[1] = (float) graf_slidebox(adr_mkpal, MKPAL_GREENBOX, MKPAL_GREEN, 1) ;
                           off_y = (int) (wext->curr_rgb[1]*(float)wext->hf/1000.0) ;
                           adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_GREENBOX ) ;
                           wext->curr_rgb[1] = 1000-wext->curr_rgb[1] ;
                           sprintf(buf, "%.4d", wext->curr_rgb[1]) ;
                           write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_TGREEN ) ;
                           vs_color(handle, wext->index, wext->curr_rgb) ;
                           break ;
    case MKPAL_BLUE      : wext->curr_rgb[2] = (float) graf_slidebox(adr_mkpal, MKPAL_BLUEBOX, MKPAL_BLUE, 1) ;
                           off_y = (int) (wext->curr_rgb[2]*(float)wext->hf/1000.0) ;
                           adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_BLUEBOX ) ;
                           wext->curr_rgb[2] = 1000-wext->curr_rgb[2] ;
                           sprintf(buf, "%.4d", wext->curr_rgb[2]) ;
                           write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                           xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_TBLUE ) ;
                           vs_color(handle, wext->index, wext->curr_rgb) ;
                           break ;
    case MKPAL_LOAD     : charge_palette() ;
                          deselect(adr_mkpal, obj) ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, obj ) ;
                          wext->flag_aff = 0 ;
                          break ;
    case MKPAL_SAVE     : sauve_palette() ;
                          deselect(adr_mkpal, obj) ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, obj ) ;
                          wext->flag_aff = 0 ;
                          break ;
    case MKPAL_START    :
    case MKPAL_END      : if ( obj == MKPAL_START ) wext->stdeg  = wext->index ;
                          else                      wext->enddeg = wext->index ;
                          if (selected(adr_mkpal, MKPAL_START) && selected(adr_mkpal, MKPAL_END))
                          {
                            deselect(adr_mkpal, MKPAL_START) ;
                            deselect(adr_mkpal, MKPAL_END) ;
                            xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_START ) ;
                            xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_END ) ;
                            cree_degrade(wext->stdeg, wext->enddeg) ;
                            wext->stdeg = wext->enddeg = 500 ;
                          }
                          break ;
    case MKPAL_APPLIQUE : read_text(adr_mkpal, MKPAL_TRED, buf) ;
                          wext->rgb[0] = atoi(buf) ;
                          off_y = (int) ((1000-wext->rgb[0])*(float)wext->hf/1000.0) ;
                          adr_mkpal[MKPAL_RED].ob_y = off_y ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_REDBOX ) ;
                          read_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                          wext->rgb[1] = atoi(buf) ;
                          off_y = (int) ((1000-wext->rgb[1])*(float)wext->hf/1000.0) ;
                          adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_GREENBOX ) ;
                          read_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                          wext->rgb[2] = atoi(buf) ;
                          off_y = (int) ((1000-wext->rgb[2])*(float)wext->hf/1000.0) ;
                          adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_BLUEBOX ) ;
                          vs_color(handle, wext->index, wext->rgb) ;
                          deselect(adr_mkpal, obj) ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, obj ) ;
                          break ;
    case MKPAL_BOX      : objc_offset(adr_mkpal, obj, &pb_x, &pb_y) ;
                          if (wext->flag_aff)
                          {
                            x1 = pb_x+(wext->index % wext->nb_col_x)*wext->ww ;
                            y1 = pb_y+(wext->index / wext->nb_col_x)*wext->hh ;
                            x2 = x1+wext->ww-1 ;
                            y2 = y1+wext->hh-1 ;
                            vsf_color(handle, 1) ;
                            vswr_mode(handle, MD_XOR) ;
                            vsl_width(handle, 3) ;
                            v_hide_c(handle) ;
                            rectangle(x1, y1, x2, y2) ;
                            v_show_c(handle, 1) ;
                          }
                          else wext->flag_aff = 1 ;
                          graf_mkstate(&xm, &ym, &dummy, &dummy) ;
                          wext->index = (xm-pb_x)/wext->ww+ wext->nb_col_x*((ym-pb_y)/wext->hh) ;
                          vq_color(handle, wext->index, 0, wext->rgb) ;
                          sprintf(buf, "%.4d", wext->rgb[0]) ;
                          write_text(adr_mkpal, MKPAL_TRED, buf) ;
                          sprintf(buf, "%.4d", wext->rgb[1]) ;
                          write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                          sprintf(buf, "%.4d", wext->rgb[2]) ;
                          write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_RGB ) ;
                          x1 = pb_x+wext->ww*((xm-pb_x)/wext->ww) ;
                          y1 = pb_y+wext->hh*((ym-pb_y)/wext->hh) ;
                          x2 = x1+wext->ww-1 ;
                          y2 = y1+wext->hh-1 ;
                          vsf_color(handle, 1) ;
                          v_hide_c(handle) ;
                          vswr_mode(handle, MD_XOR) ;
                          vsl_width(handle, 3) ;
                          rectangle(x1, y1, x2, y2) ;
                          v_show_c(handle, 1) ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_CURRCOL ) ;
                          off_y = (int) ((1000-wext->rgb[0])*(float)wext->hf/1000.0) ;
                          adr_mkpal[MKPAL_RED].ob_y = off_y ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_REDBOX ) ;
                          off_y = (int) ((1000-wext->rgb[1])*(float)wext->hf/1000.0) ;
                          adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_GREENBOX ) ;
                          off_y = (int) ((1000-wext->rgb[2])*(float)wext->hf/1000.0) ;
                          adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                          xobjc_draw( wnd->window_handle,adr_mkpal, MKPAL_BLUEBOX ) ;
                          break ;
     case MKPAL_OK      : code = IDOK ;
                          break ;
     case MKPAL_CANCEL  : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

int FGetPal(WEXTENSION_PAL *wext)
{
  GEM_WINDOW *dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_MKPALETTE ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogPal ;
  dlg_data.OnObjectNotify = OnObjectNotifyPal ;
  dlg_data.WKind          = SMALLER ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return( code ) ;
}


void traite_makepalette(GEM_WINDOW *gwnd)
{
  WEXTENSION_PAL wext ;
  VXIMAGE        *vimage ;
  INFO_IMAGE     *inf_img ;
  int            code ;

  if ( gwnd == NULL ) return ;
  wext.wnd    = gwnd ;
  wext.vimage = vimage = (VXIMAGE *) gwnd->Extension ;
  wext.inf_img = inf_img = &vimage->inf_img ;

  if ( Truecolor )
  {
    traite_24bitspal( gwnd ) ;
    return ;
  }


  code = FGetPal( &wext ) ;

  if ( code == IDCANCEL )
  {
    set_vdipalette( wext.curr_pal, nb_colors ) ;
    return ;
  }
  else
  {
    int the_pal[3*256] ;
    int nbc ;

    get_tospalette( the_pal ) ;
    nbc = nb_colors ;
    if (nbc > inf_img->nb_cpal) nbc = (int) inf_img->nb_cpal ;
    if ( inf_img->palette ) memcpy(inf_img->palette, the_pal, 6*nbc) ;
  }
}
