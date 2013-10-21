/***********************************/
/* Gestion des palettes de couleur */
/***********************************/
#include    <ext.h>
#include   <math.h>
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>

#include     "defs.h"
#include   "calcul.h"
#include   "gstevn.h"
#include  "fractal.h"
#include "fract_io.h"

int  ww, hh, nb_col_x ;
int  index ;
int  curr_rgb[3] ;
char path_palette[200] ;


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
    getcurdir(0, path_palette+2) ;
    path_palette[1] = ':' ;
    path_palette[0] = 'A'+getdisk() ;
    strcat(path_palette, "\\") ;
  }

  if (file_name(path_palette, "*.PAL", name))
  {
    FILE *stream ;

    stream = fopen(name, "rb") ;
    if (stream == NULL)
    {
      form_stop(1, msg[MSG_FILENOTEXIST]) ;
      return ;
    }
    ncol   = (int) filelength(fileno(stream))/6 ;
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
    getcurdir(0, path_palette+2) ;
    path_palette[1] = ':' ;
    path_palette[0] = 'A'+getdisk() ;
    strcat(path_palette, "\\") ;
  }

  if (file_name(path_palette, "*.PAL", name))
  {
    FILE *stream ;

    stream = fopen(name, "wb") ;
    if (stream == NULL)
    {
      form_stop(1, msg[MSG_WRITEERROR]) ;
      return ;
    }
    get_vdipalette(pal) ;
    if (fwrite(pal, 6, nb_colors, stream) != nb_colors)
      form_stop(1, msg[MSG_WRITEERROR]) ;
    fclose(stream) ;
    strcpy(path_palette, name) ;
    pt = strrchr(path_palette, '\\') ;
    if (pt != NULL) *(1+pt) = 0 ;
    else            *path_palette = 0 ;
  }
}

void traite_palette(void)
{
  OBJECT *adr_mkpal ;
  float  hf ;
  int    curr_pal[256*3] ;
  int    rgb[3] ;
  int    bouton ;
  int    x1, y1, x2, y2 ;
  int    xm, ym, dummy ;
  int    pb_x, pb_y ;
  int    flag_aff = 0 ;
  int    stdeg, enddeg ;
  int    off_x, off_y ;
  char   buf[10] ;

  get_vdipalette(curr_pal) ;
  Xrsrc_gaddr(R_TREE, FORM_MKPALETTE, &adr_mkpal) ;
  index = 0 ;
  stdeg = enddeg = 500 ;
  hf    = (float) (adr_mkpal[MKPAL_REDBOX].ob_height-adr_mkpal[MKPAL_RED].ob_height) ;
  vq_color(handle, index, 0, rgb) ;
  sprintf(buf, "%.4d", rgb[0]) ;
  write_text(adr_mkpal, MKPAL_TRED, buf) ;
  sprintf(buf, "%.4d", rgb[1]) ;
  write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
  sprintf(buf, "%.4d", rgb[2]) ;
  write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
  off_y = (int) ((1000-rgb[0])*(float)hf/1000.0) ;
  adr_mkpal[MKPAL_RED].ob_y = off_y ;
  off_y = (int) ((1000-rgb[1])*(float)hf/1000.0) ;
  adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
  off_y = (int) ((1000-rgb[2])*(float)hf/1000.0) ;
  adr_mkpal[MKPAL_BLUE].ob_y = off_y ;

  fshow_dialog(adr_mkpal, titre) ;
  do
  {
    bouton = xform_do(MKPAL_TRED, window_update) ;
    if (bouton == -1) break ;
    bouton &= 32767 ;
    vq_color(handle, index, 0, curr_rgb) ;
    switch(bouton)
    {
      case MKPAL_MRED      :
      case MKPAL_PRED      : if (bouton == MKPAL_PRED) curr_rgb[0]++ ;
                             else                      curr_rgb[0]-- ;
                             if (curr_rgb[0] < 1)    curr_rgb[0] = 1 ;
                             if (curr_rgb[0] > 1000) curr_rgb[0] = 1000 ;
                             off_y = (int) ((1000-curr_rgb[0])*(float)hf/1000.0) ;
                             adr_mkpal[MKPAL_RED].ob_y = off_y ;
                             objc_draw(adr_mkpal, MKPAL_REDBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                             sprintf(buf, "%.4d", curr_rgb[0]) ;
                             write_text(adr_mkpal, MKPAL_TRED, buf) ;
                             objc_draw(adr_mkpal, MKPAL_TRED, 0, xdesk, ydesk, wdesk, hdesk) ;
                             vs_color(handle, index, curr_rgb) ;
                             break ;
      case MKPAL_MGREEN    :
      case MKPAL_PGREEN    : if (bouton == MKPAL_PGREEN) curr_rgb[1]++ ;
                             else                      curr_rgb[1]-- ;
                             if (curr_rgb[1] < 1)    curr_rgb[1] = 1 ;
                             if (curr_rgb[1] > 1000) curr_rgb[1] = 1000 ;
                             off_y = (int) ((1000-curr_rgb[1])*(float)hf/1000.0) ;
                             adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                             objc_draw(adr_mkpal, MKPAL_GREENBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                             sprintf(buf, "%.4d", curr_rgb[1]) ;
                             write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                             objc_draw(adr_mkpal, MKPAL_TGREEN, 0, xdesk, ydesk, wdesk, hdesk) ;
                             vs_color(handle, index, curr_rgb) ;
                             break ;
      case MKPAL_MBLUE     :
      case MKPAL_PBLUE     : if (bouton == MKPAL_PBLUE) curr_rgb[2]++ ;
                             else                      curr_rgb[2]-- ;
                             if (curr_rgb[2] < 1)    curr_rgb[2] = 1 ;
                             if (curr_rgb[2] > 1000) curr_rgb[2] = 1000 ;
                             off_y = (int) ((1000-curr_rgb[2])*(float)hf/1000.0) ;
                             adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                             objc_draw(adr_mkpal, MKPAL_BLUEBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                             sprintf(buf, "%.4d", curr_rgb[2]) ;
                             write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                             objc_draw(adr_mkpal, MKPAL_TBLUE, 0, xdesk, ydesk, wdesk, hdesk) ;
                             vs_color(handle, index, curr_rgb) ;
                             break ;
      case MKPAL_REDBOX    : graf_mkstate(&xm, &ym, &dummy, &dummy) ;
                             objc_offset(adr_mkpal, MKPAL_RED, &off_x, &off_y) ;
                             if (ym > off_y) curr_rgb[0] = curr_rgb[0]-20 ;
                             else            curr_rgb[0] = curr_rgb[0]+20 ;
                             if (curr_rgb[0] < 1)    curr_rgb[0] = 1 ;
                             if (curr_rgb[0] > 1000) curr_rgb[0] = 1000 ;
                             off_y = (int) ((1000-curr_rgb[0])*(float)hf/1000.0) ;
                             adr_mkpal[MKPAL_RED].ob_y = off_y ;
                             objc_draw(adr_mkpal, MKPAL_REDBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                             sprintf(buf, "%.4d", curr_rgb[0]) ;
                             write_text(adr_mkpal, MKPAL_TRED, buf) ;
                             objc_draw(adr_mkpal, MKPAL_TRED, 0, xdesk, ydesk, wdesk, hdesk) ;
                             vs_color(handle, index, curr_rgb) ;
                             break ;
      case MKPAL_GREENBOX    : graf_mkstate(&xm, &ym, &dummy, &dummy) ;
                             objc_offset(adr_mkpal, MKPAL_GREEN, &off_x, &off_y) ;
                             if (ym > off_y) curr_rgb[1] = curr_rgb[1]-20 ;
                             else            curr_rgb[1] = curr_rgb[1]+20 ;
                             if (curr_rgb[1] < 1)    curr_rgb[1] = 1 ;
                             if (curr_rgb[1] > 1000) curr_rgb[1] = 1000 ;
                             off_y = (int) ((1000-curr_rgb[1])*(float)hf/1000.0) ;
                             adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                             objc_draw(adr_mkpal, MKPAL_GREENBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                             sprintf(buf, "%.4d", curr_rgb[1]) ;
                             write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                             objc_draw(adr_mkpal, MKPAL_TGREEN, 0, xdesk, ydesk, wdesk, hdesk) ;
                             vs_color(handle, index, curr_rgb) ;
                             break ;
      case MKPAL_BLUEBOX    : graf_mkstate(&xm, &ym, &dummy, &dummy) ;
                             objc_offset(adr_mkpal, MKPAL_BLUE, &off_x, &off_y) ;
                             if (ym > off_y) curr_rgb[2] = curr_rgb[2]-20 ;
                             else            curr_rgb[2] = curr_rgb[2]+20 ;
                             if (curr_rgb[2] < 1)    curr_rgb[2] = 1 ;
                             if (curr_rgb[2] > 1000) curr_rgb[2] = 1000 ;
                             off_y = (int) ((1000-curr_rgb[2])*(float)hf/1000.0) ;
                             adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                             objc_draw(adr_mkpal, MKPAL_BLUEBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                             sprintf(buf, "%.4d", curr_rgb[2]) ;
                             write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                             objc_draw(adr_mkpal, MKPAL_TBLUE, 0, xdesk, ydesk, wdesk, hdesk) ;
                             vs_color(handle, index, curr_rgb) ;
                             break ;
      case MKPAL_RED       : curr_rgb[0] = (float) graf_slidebox(adr_mkpal, MKPAL_REDBOX, MKPAL_RED, 1) ;
                             off_y = (int) (curr_rgb[0]*(float)hf/1000.0) ;
                             adr_mkpal[MKPAL_RED].ob_y = off_y ;
                             objc_draw(adr_mkpal, MKPAL_REDBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                             curr_rgb[0] = 1000-curr_rgb[0] ;
                             sprintf(buf, "%.4d", curr_rgb[0]) ;
                             write_text(adr_mkpal, MKPAL_TRED, buf) ;
                             objc_draw(adr_mkpal, MKPAL_TRED, 0, xdesk, ydesk, wdesk, hdesk) ;
                             vs_color(handle, index, curr_rgb) ;
                             break ;
      case MKPAL_GREEN     : curr_rgb[1] = (float) graf_slidebox(adr_mkpal, MKPAL_GREENBOX, MKPAL_GREEN, 1) ;
                             off_y = (int) (curr_rgb[1]*(float)hf/1000.0) ;
                             adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                             objc_draw(adr_mkpal, MKPAL_GREENBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                             curr_rgb[1] = 1000-curr_rgb[1] ;
                             sprintf(buf, "%.4d", curr_rgb[1]) ;
                             write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                             objc_draw(adr_mkpal, MKPAL_TGREEN, 0, xdesk, ydesk, wdesk, hdesk) ;
                             vs_color(handle, index, curr_rgb) ;
                             break ;
      case MKPAL_BLUE      : curr_rgb[2] = (float) graf_slidebox(adr_mkpal, MKPAL_BLUEBOX, MKPAL_BLUE, 1) ;
                             off_y = (int) (curr_rgb[2]*(float)hf/1000.0) ;
                             adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                             objc_draw(adr_mkpal, MKPAL_BLUEBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                             curr_rgb[2] = 1000-curr_rgb[2] ;
                             sprintf(buf, "%.4d", curr_rgb[2]) ;
                             write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                             objc_draw(adr_mkpal, MKPAL_TBLUE, 0, xdesk, ydesk, wdesk, hdesk) ;
                             vs_color(handle, index, curr_rgb) ;
                             break ;
      case MKPAL_LOAD     : charge_palette() ;
                            deselect(adr_mkpal, bouton) ;
                            objc_draw(adr_mkpal, bouton, 0, xdesk, ydesk, wdesk, hdesk) ;
                            flag_aff = 0 ;
                            break ;
      case MKPAL_SAVE     : sauve_palette() ;
                            deselect(adr_mkpal, bouton) ;
                            objc_draw(adr_mkpal, bouton, 0, xdesk, ydesk, wdesk, hdesk) ;
                            flag_aff = 0 ;
                            break ;
      case MKPAL_START    :
      case MKPAL_END      : if (bouton == MKPAL_START) stdeg  = index ;
                            else                       enddeg = index ;
                            if (selected(adr_mkpal, MKPAL_START) && selected(adr_mkpal, MKPAL_END))
                            {
                              deselect(adr_mkpal, MKPAL_START) ;
                              deselect(adr_mkpal, MKPAL_END) ;
                              objc_draw(adr_mkpal, MKPAL_START, 0, xdesk, ydesk, wdesk, hdesk) ;
                              objc_draw(adr_mkpal, MKPAL_END, 0, xdesk, ydesk, wdesk, hdesk) ;
                              cree_degrade(stdeg, enddeg) ;
                              stdeg = enddeg = 500 ;
                            }
                            break ;
      case MKPAL_APPLIQUE : read_text(adr_mkpal, MKPAL_TRED, buf) ;
                            rgb[0] = atoi(buf) ;
                            off_y = (int) ((1000-rgb[0])*(float)hf/1000.0) ;
                            adr_mkpal[MKPAL_RED].ob_y = off_y ;
                            objc_draw(adr_mkpal, MKPAL_REDBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                            read_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                            rgb[1] = atoi(buf) ;
                            off_y = (int) ((1000-rgb[1])*(float)hf/1000.0) ;
                            adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                            objc_draw(adr_mkpal, MKPAL_GREENBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                            read_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                            rgb[2] = atoi(buf) ;
                            off_y = (int) ((1000-rgb[2])*(float)hf/1000.0) ;
                            adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                            objc_draw(adr_mkpal, MKPAL_BLUEBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                            vs_color(handle, index, rgb) ;
                            deselect(adr_mkpal, bouton) ;
                            objc_draw(adr_mkpal, bouton, 0, xdesk, ydesk, wdesk, hdesk) ;
                            break ;
      case MKPAL_BOX : objc_offset(adr_mkpal, bouton, &pb_x, &pb_y) ;
                       if (flag_aff)
                       {
                         x1 = pb_x+(index % nb_col_x)*ww ;
                         y1 = pb_y+(index / nb_col_x)*hh ;
                         x2 = x1+ww-1 ;
                         y2 = y1+hh-1 ;
                         vsf_color(handle, 1) ;
                         vswr_mode(handle, MD_XOR) ;
                         vsl_width(handle, 3) ;
                         v_hide_c(handle) ;
                         rectangle(x1, y1, x2, y2) ;
                         v_show_c(handle, 1) ;
                       }
                       else flag_aff = 1 ;
                       graf_mkstate(&xm, &ym, &dummy, &dummy) ;
                       index = (xm-pb_x)/ww+ nb_col_x*((ym-pb_y)/hh) ;
                       vq_color(handle, index, 0, rgb) ;
                       sprintf(buf, "%.4d", rgb[0]) ;
                       write_text(adr_mkpal, MKPAL_TRED, buf) ;
                       sprintf(buf, "%.4d", rgb[1]) ;
                       write_text(adr_mkpal, MKPAL_TGREEN, buf) ;
                       sprintf(buf, "%.4d", rgb[2]) ;
                       write_text(adr_mkpal, MKPAL_TBLUE, buf) ;
                       objc_draw(adr_mkpal, MKPAL_RGB, 3, xdesk, ydesk, wdesk, hdesk) ;
                       x1 = pb_x+ww*((xm-pb_x)/ww) ;
                       y1 = pb_y+hh*((ym-pb_y)/hh) ;
                       x2 = x1+ww-1 ;
                       y2 = y1+hh-1 ;
                       vsf_color(handle, 1) ;
                       v_hide_c(handle) ;
                       vswr_mode(handle, MD_XOR) ;
                       vsl_width(handle, 3) ;
                       rectangle(x1, y1, x2, y2) ;
                       v_show_c(handle, 1) ;
                       objc_draw(adr_mkpal, MKPAL_CURRCOL, 0, xdesk, ydesk, wdesk, hdesk) ;
                       off_y = (int) ((1000-rgb[0])*(float)hf/1000.0) ;
                       adr_mkpal[MKPAL_RED].ob_y = off_y ;
                       objc_draw(adr_mkpal, MKPAL_REDBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                       off_y = (int) ((1000-rgb[1])*(float)hf/1000.0) ;
                       adr_mkpal[MKPAL_GREEN].ob_y = off_y ;
                       objc_draw(adr_mkpal, MKPAL_GREENBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                       off_y = (int) ((1000-rgb[2])*(float)hf/1000.0) ;
                       adr_mkpal[MKPAL_BLUE].ob_y = off_y ;
                       objc_draw(adr_mkpal, MKPAL_BLUEBOX, 1, xdesk, ydesk, wdesk, hdesk) ;
                       break ;
    }
  }
  while ((bouton != MKPAL_OK) && (bouton != MKPAL_CANCEL) && (bouton != -1)) ;
  if (bouton != -1) deselect(adr_mkpal, bouton) ;
  fhide_dialog() ;

  if ((bouton == MKPAL_CANCEL) || (bouton == -1))
    set_vdipalette(curr_pal, nb_colors) ;
  else
    get_tospalette(&fractal_pal[num_window][0]) ;
}

int cdecl draw_colors(PARMBLK *parmblock)
{ 
  int xyc[4], xy[4] ;
  int nb_col_y, col_y, col_x, ind_col ;
  	
  nb_col_y = nb_col_x = (int)sqrt((double)nb_colors) ;
  ww = (int)(parmblock->pb_w/nb_col_x) ;
  hh = (int)(parmblock->pb_h/nb_col_y) ;

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
  xy[3] = xy[1]+hh ;
  for (col_y = 0, ind_col = 0; col_y < nb_col_y; col_y++)
  {
    xy[0] = parmblock->pb_x ;
    xy[2] = xy[0]+ww ;
    for (col_x = 0; col_x < nb_col_x; col_x++, ind_col++)
    {
      vsf_color(handle, ind_col) ;
	  v_bar(handle, xy) ;
      xy[0] += ww ;
      xy[2] += ww ;
    }
    xy[1] += hh ;
	xy[3] += hh ;
  }
  vs_clip(handle, 0, xyc);

  return(0) ;
}

int cdecl draw_currentcolor(PARMBLK *parmblock)
{ 
  int xyc[4], xy[4] ;
  	
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
  vsf_color(handle, index) ;
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
