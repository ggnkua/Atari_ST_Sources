#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "actions.h"

typedef struct
{
  TEXT_TYPE text ;
  int       start_font ;
  int       *tsort_fonts ; /* Tri des fontes */
}
DLGTEXTE_USER_DATA ;

static int  start_font ;  /* Memoriser la derniere position */

void show_fonts(GEM_WINDOW* wnd, int start_num)
{
  OBJECT             *obj      = wnd->DlgData->BaseObject ;
  DLGTEXTE_USER_DATA *dlg_data = wnd->DlgData->UserData ;
  float              ratio ;
  int                i, end_num, l ;
  int                lo = 23 ;
  char               buffer[32] ;

  end_num = start_num + 7 ;
  if ( end_num > 1+num_fonts ) end_num = 1+num_fonts ;
  for ( i = start_num; i < end_num; i++ )
  {
    vqt_name( handle, dlg_data->tsort_fonts[i], buffer ) ;
    for (l = (int)strlen(buffer); l < lo; l++) buffer[l] = ' ' ;
    buffer[lo] = 0 ;
    write_text(obj, TEXTE_FONT1+i-start_num, buffer) ;
    xobjc_draw( wnd->window_handle, obj, TEXTE_FONT1+i-start_num ) ;
  }

  ratio = 7.0/(float)(1+num_fonts) ;
  if (ratio > 1.0) ratio = 1.0 ;
  l = (int) ((float)obj[TEXTE_FONTBOX].ob_height*ratio) ;
  l-- ;
  if ( l < 10 ) l = 10 ;
  obj[TEXTE_FONTVUES].ob_height = l ;
  l = obj[TEXTE_FONTBOX].ob_height-l ;
  if (num_fonts > 6) obj[TEXTE_FONTVUES].ob_y = (l*(start_num-num_sys_font))/(1+num_fonts-7) ;
  else               obj[TEXTE_FONTVUES].ob_y = 0 ;
  obj[TEXTE_FONTVUES].ob_y++ ;
  xobjc_draw( wnd->window_handle, obj, TEXTE_FONTBOX ) ;
  xobjc_draw( wnd->window_handle, obj, TEXTE_FONTVUES ) ;
}

int cdecl draw_text(PARMBLK *paramblk)
{
  int xy[4] ;
  int xt, yt ;

  xy[0] = paramblk->pb_x ;
  xy[1] = paramblk->pb_y ;
  xy[2] = paramblk->pb_x+paramblk->pb_w-1 ;
  xy[3] = paramblk->pb_y+paramblk->pb_h-1 ;
  vs_clip(handle, 1, xy) ;
  vswr_mode(handle, MD_REPLACE) ;
  vsf_interior(handle, FIS_SOLID) ;
  vsf_color(handle, 0) ;
  xt = paramblk->pb_x+(paramblk->pb_w>>1) ;
  yt = paramblk->pb_y+(paramblk->pb_h>>1) ;
  v_hide_c(handle) ;
  vr_recfl(handle, xy) ;
  v_gtext(handle, xt, yt, "Vision") ;
  v_show_c(handle, 1) ;
  vs_clip(handle, 0, xy) ;

  return 0 ;
}

int font_index(int *tsort_fonts,int num)
{
  int i, ind ;

  ind = num_sys_font ;
  if ( tsort_fonts )
  {
    for ( i = 0; i < 1+num_fonts; i++ )
      if  ( tsort_fonts[i] == num )
      {
        ind = i ;
        break ;
     }
  }

  return ind ;
}

int cmp_font(const void *i, const void *j)
{
  int *one, *two;
  char s1[40], s2[40] ;

  one = (int *)i;
  two = (int *)j;
  vqt_name( handle, *one, s1 ) ;
  vqt_name( handle, *two, s2 ) ;

  return( strcmp( s1, s2 ) ) ;
}

void sort_fonts(GEM_WINDOW* wnd)
{
  DLGTEXTE_USER_DATA *dlg_data = wnd->DlgData->UserData ;
  int                i ;
  int                nb_fonts_displayed = 1 + TEXTE_FONT7 - TEXTE_FONT1 ;

  mouse_busy() ;
  for ( i = 0; i < 1+num_fonts; i++ ) dlg_data->tsort_fonts[i] = i ;
  qsort( dlg_data->tsort_fonts, 1+num_fonts, sizeof(int), cmp_font ) ;
  dlg_data->start_font = font_index( dlg_data->tsort_fonts, num_sys_font ) ;
  if ( dlg_data->start_font + nb_fonts_displayed > num_fonts )
    dlg_data->start_font = num_fonts - nb_fonts_displayed ;
  if ( dlg_data->start_font < 0 ) dlg_data->start_font = 0 ;

  mouse_restore() ;
}

void OnInitDialogText(void *w)
{
  GEM_WINDOW         *wnd = w ;
  OBJECT             *adr_ptext = wnd->DlgData->BaseObject ;
  DLGTEXTE_USER_DATA *dlg_data = wnd->DlgData->UserData ;
  int                j ;
  char               buf[50] ;

  dlg_data->tsort_fonts = (int *) Xalloc( 2 * (1 + num_fonts) ) ;

  if ( dlg_data->tsort_fonts ) sort_fonts( wnd ) ;
  dlg_data->start_font = start_font ;

  adr_ptext[TEXTE_VUE].ob_spec.userblk->ub_code = draw_text ;

  
  for ( j = TEXTE_FONT1; j <= TEXTE_FONT7; j++ )
    write_text(adr_ptext, j, "                    ") ;

  memcpy( &dlg_data->text, &ttype, sizeof(TEXT_TYPE) ) ;
  sprintf( buf, "%.3d", ttype.hcar ) ;
  write_text(adr_ptext, TEXTE_NTAILLE, buf ) ;
  sprintf( buf, "%.2d", ttype.angle / 10 ) ;
  write_text( adr_ptext, TEXTE_ANGLE, buf ) ;
  if ( dlg_data->text.attribute == 0 )
  {
    select(adr_ptext, TEXTE_NORMAL) ;
    deselect(adr_ptext, TEXTE_GRAS) ;
    deselect(adr_ptext, TEXTE_FIN) ;
    deselect(adr_ptext, TEXTE_ITALIQUE) ;
    deselect(adr_ptext, TEXTE_SOULIGNE) ;
    deselect(adr_ptext, TEXTE_CONTOURS) ;
  }
  else
  {
    checkbox_setstate( ttype.attribute & GRAS, adr_ptext, TEXTE_GRAS ) ;
    checkbox_setstate( ttype.attribute & FIN, adr_ptext, TEXTE_FIN ) ;
    checkbox_setstate( ttype.attribute & ITALIQUE, adr_ptext, TEXTE_ITALIQUE ) ;
    checkbox_setstate( ttype.attribute & SOULIGNE, adr_ptext, TEXTE_SOULIGNE ) ;
    checkbox_setstate( ttype.attribute & CONTOURS, adr_ptext, TEXTE_CONTOURS ) ;
/*
    if (ttype.attribute & GRAS)     select(adr_ptext, TEXTE_GRAS) ;
    else                            deselect(adr_ptext, TEXTE_GRAS) ;
    if (ttype.attribute & FIN)      select(adr_ptext, TEXTE_FIN) ;
    else                            deselect(adr_ptext, TEXTE_FIN) ;
    if (ttype.attribute & ITALIQUE) select(adr_ptext, TEXTE_ITALIQUE) ;
    else                            deselect(adr_ptext, TEXTE_ITALIQUE) ;
    if (ttype.attribute & SOULIGNE) select(adr_ptext, TEXTE_SOULIGNE) ;
    else                            deselect(adr_ptext, TEXTE_SOULIGNE) ;
    if (ttype.attribute & CONTOURS) select(adr_ptext, TEXTE_CONTOURS) ;
    else                            deselect(adr_ptext, TEXTE_CONTOURS) ;*/
  }

  for ( j = TEXTE_FONT1; j <= TEXTE_FONT7; j++ ) deselect( adr_ptext, j ) ; 
  j = font_index( dlg_data->tsort_fonts, ttype.font ) ;
  if ( j < dlg_data->start_font )        dlg_data->start_font = j ;
  else if ( j > dlg_data->start_font+6 ) dlg_data->start_font = ( ( j - 6 ) >= 0 ) ? j-6 : 0 ;
  select( adr_ptext, TEXTE_FONT1+j-dlg_data->start_font ) ;

  ttype.hdisp = 0 ;
  ttype.vdisp = 0 ;
  vswr_mode(handle, MD_REPLACE) ;
  set_texttype(&ttype) ;
  show_fonts( wnd, dlg_data->start_font ) ;
}

static void gui2ttype(OBJECT* adr_ptext)
{
  if ( selected( adr_ptext, TEXTE_NORMAL ) ) ttype.attribute = 0 ;
  else
  {
    ttype.attribute = 0 ;
    if (selected( adr_ptext, TEXTE_GRAS ) )     ttype.attribute |= GRAS ;
    if (selected( adr_ptext, TEXTE_FIN ) )      ttype.attribute |= FIN ;
    if (selected( adr_ptext, TEXTE_ITALIQUE ) ) ttype.attribute |= ITALIQUE ;
    if (selected( adr_ptext, TEXTE_SOULIGNE ) ) ttype.attribute |= SOULIGNE ;
    if (selected( adr_ptext, TEXTE_CONTOURS ) ) ttype.attribute |= CONTOURS ;
  }
}

static int OnObjectNotifyText(void *w, int obj)
{
  GEM_WINDOW* wnd = w ;
  OBJECT    *adr_ptext = wnd->DlgData->BaseObject ;
  DLGTEXTE_USER_DATA *dlg_data = wnd->DlgData->UserData ;
  PARMBLK   parmblk ;
  float     pc, hf ;
  int       code = -1 ;
  int       x, y, i, j, ym, dummy ;
  char      buf[50] ;

  hf = (double) (adr_ptext[TEXTE_FONTBOX].ob_height-adr_ptext[TEXTE_FONTVUES].ob_height) ;
  objc_offset(adr_ptext, TEXTE_VUE, &x, &y) ;
  switch( obj )
  {
    case TEXTE_NORMAL   :
    case TEXTE_TNORMAL  : select(adr_ptext, TEXTE_NORMAL) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_NORMAL ) ;
                          deselect(adr_ptext, TEXTE_GRAS) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_GRAS ) ;
                          deselect(adr_ptext, TEXTE_FIN) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_FIN ) ;
                          deselect(adr_ptext, TEXTE_ITALIQUE) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_ITALIQUE ) ;
                          deselect(adr_ptext, TEXTE_SOULIGNE) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_SOULIGNE ) ;
                          deselect(adr_ptext, TEXTE_CONTOURS) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_CONTOURS ) ;
                          break ;
    case TEXTE_TGRAS    :
    case TEXTE_TFIN     :
    case TEXTE_TSOULIGNE:
    case TEXTE_TITALIQUE:
    case TEXTE_TCONTOURS: inv_select(adr_ptext, 1+obj) ;
                          if (!selected(adr_ptext, TEXTE_GRAS)
                              && !selected(adr_ptext, TEXTE_ITALIQUE)
                              && !selected(adr_ptext, TEXTE_FIN)
                              && !selected(adr_ptext, TEXTE_SOULIGNE)
                              && !selected(adr_ptext, TEXTE_CONTOURS))
                          {
                            select(adr_ptext, TEXTE_NORMAL) ;
                            xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_NORMAL ) ;
                          }
                          else
                          {
                            deselect(adr_ptext, TEXTE_NORMAL) ;
                            xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_NORMAL ) ;
                          }
                          break ;
    case TEXTE_GRAS     :
    case TEXTE_FIN      :
    case TEXTE_SOULIGNE :
    case TEXTE_ITALIQUE :
    case TEXTE_CONTOURS : inv_select(adr_ptext, obj) ;
                          if (!selected(adr_ptext, TEXTE_GRAS)
                              && !selected(adr_ptext, TEXTE_ITALIQUE)
                              && !selected(adr_ptext, TEXTE_FIN)
                              && !selected(adr_ptext, TEXTE_SOULIGNE)
                              && !selected(adr_ptext, TEXTE_CONTOURS))
                          {
                            select(adr_ptext, TEXTE_NORMAL) ;
                            xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_NORMAL ) ;
                          }
                          else
                          {
                            deselect(adr_ptext, TEXTE_NORMAL) ;
                            xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_NORMAL ) ;
                          }
                          break ;
    case TEXTE_HMOINS   :
    case TEXTE_HPLUS    : if (obj == TEXTE_HMOINS) ttype.hcar -= 1 ;
                          else                     ttype.hcar += 1 ;
                          if (ttype.hcar < 1) ttype.hcar   = 1 ;
                          if (ttype.hcar > 144) ttype.hcar = 144 ;
                          sprintf(buf, "%.3d", ttype.hcar) ;
                          write_text(adr_ptext, TEXTE_NTAILLE, buf) ;
                          deselect(adr_ptext, obj) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, obj ) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_NTAILLE ) ;
                          break ;
    case TEXTE_RMOINS   :
    case TEXTE_RPLUS    : read_text(adr_ptext, TEXTE_ANGLE, buf) ;
                          ttype.angle = 10*atoi( buf ) ;
                          if ( obj == TEXTE_RMOINS ) ttype.angle -= 100 ;
                          else                       ttype.angle += 100 ;
                          if ( ttype.angle < 0 )     ttype.angle += 3600 ;
                          if ( ttype.angle >= 3600 ) ttype.angle -= 3600 ;
                          sprintf( buf, "%.3d", ttype.angle/10 ) ;
                          write_text( adr_ptext, TEXTE_ANGLE, buf ) ;
                          deselect( adr_ptext, obj ) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, obj ) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_ANGLE ) ;
                          break ;
    case TEXTE_FONT1    :
    case TEXTE_FONT2    :
    case TEXTE_FONT3    :
    case TEXTE_FONT4    :
    case TEXTE_FONT5    :
    case TEXTE_FONT6    :
    case TEXTE_FONT7    : for ( i = TEXTE_FONT1; i <= TEXTE_FONT7; i++ ) deselect( adr_ptext, i ) ;
                          if ( dlg_data->tsort_fonts ) ttype.font = dlg_data->tsort_fonts[dlg_data->start_font+obj-TEXTE_FONT1] ;
                          select( adr_ptext, obj ) ;
                          show_fonts( wnd, dlg_data->start_font ) ;
                          break ;
    case TEXTE_FONTMOINS:
    case TEXTE_FONTPLUS : j = font_index( dlg_data->tsort_fonts, ttype.font ) ;
                          if ((j >= dlg_data->start_font) && (j <= dlg_data->start_font+6))
                            deselect(adr_ptext, TEXTE_FONT1+j-dlg_data->start_font) ;
                          if (obj == TEXTE_FONTMOINS) dlg_data->start_font-- ;
                          else                        dlg_data->start_font++ ;
                          if (dlg_data->start_font < num_sys_font)  dlg_data->start_font = num_sys_font ;
                          if (dlg_data->start_font+7 > 1+num_fonts) dlg_data->start_font = 1+num_fonts-7 ;
                          if ((j >= dlg_data->start_font) && (j <= dlg_data->start_font+6))
                            select(adr_ptext, TEXTE_FONT1+j-dlg_data->start_font) ;
                          show_fonts( wnd, dlg_data->start_font) ;
                          break ;
    case TEXTE_FONTBOX  : j = font_index( dlg_data->tsort_fonts, ttype.font ) ;
                          if ((j >= dlg_data->start_font) && (j <= dlg_data->start_font+6))
                            deselect(adr_ptext, TEXTE_FONT1+j-dlg_data->start_font) ;
                          graf_mkstate(&dummy, &ym, &dummy, &dummy) ;
                          objc_offset(adr_ptext, TEXTE_FONTVUES, &dummy, &y) ;
                          if (ym < y) dlg_data->start_font -= 7 ;
                          else        dlg_data->start_font += 7 ;
                          if (dlg_data->start_font < num_sys_font) dlg_data->start_font = num_sys_font ;
                          if (dlg_data->start_font+7 > 1+num_fonts) dlg_data->start_font = 1+num_fonts-7 ;
                          if ((j >= dlg_data->start_font) && (j <= dlg_data->start_font+6))
                            select(adr_ptext, TEXTE_FONT1+j-dlg_data->start_font) ;
                          show_fonts( wnd, dlg_data->start_font) ;
                          break ;
    case TEXTE_FONTVUES : j = font_index( dlg_data->tsort_fonts, ttype.font ) ;
                          if ((j >= dlg_data->start_font) && (j <= dlg_data->start_font+6))
                            deselect(adr_ptext, TEXTE_FONT1+j-dlg_data->start_font) ;
                          pc = (float) graf_slidebox(adr_ptext, TEXTE_FONTBOX, TEXTE_FONTVUES, 1) ;
                          pc = (1000.0-pc)/10.0 ;
                          y  = (int) ((100.0-pc)*(double)hf/100.0) ;
                          adr_ptext[TEXTE_FONTVUES].ob_y = y ;
                          dlg_data->start_font = (int) ((float)y*(float)(1+num_fonts-7)/hf) ;
                          if (dlg_data->start_font < num_sys_font) dlg_data->start_font = num_sys_font ;
                          if (dlg_data->start_font+7 > 1+num_fonts) dlg_data->start_font = 1+num_fonts-7 ;
                          if ((j >= dlg_data->start_font) && (j <= dlg_data->start_font+6))
                            select(adr_ptext, TEXTE_FONT1+j-dlg_data->start_font) ;
                          show_fonts( wnd, dlg_data->start_font) ;
                          break ;
    case TEXTE_TEST     : deselect(adr_ptext, obj) ;
                          xobjc_draw( wnd->window_handle, adr_ptext, obj ) ;
                          break ;
    case TEXTE_OK       : code = IDOK ;
                          break ;
    case TEXTE_CANCEL   : code = IDCANCEL ;
                          break ;
  }
  gui2ttype( adr_ptext ) ;
  read_text(adr_ptext, TEXTE_NTAILLE, buf) ;
  ttype.hcar = atoi(buf) ;
  read_text(adr_ptext, TEXTE_ANGLE, buf) ;
  ttype.angle = 10*atoi( buf ) ;
  if (ttype.hcar < 1) ttype.hcar   = 1 ;
  if (ttype.hcar > 144) ttype.hcar = 144 ;
  sprintf(buf, "%.3d", ttype.hcar) ;
  write_text(adr_ptext, TEXTE_NTAILLE, buf) ;
  xobjc_draw( wnd->window_handle, adr_ptext, TEXTE_NTAILLE ) ;
  set_texttype(&ttype) ;
  objc_offset(adr_ptext, TEXTE_VUE, &parmblk.pb_x, &parmblk.pb_y) ;
  parmblk.pb_w = adr_ptext[TEXTE_VUE].ob_width ; 
  parmblk.pb_h = adr_ptext[TEXTE_VUE].ob_height ; 
  draw_text(&parmblk) ;

  if ( code == IDOK ) gui2ttype( adr_ptext ) ;

  return code ;
}

int OnCloseText(void *w)
{
  GEM_WINDOW         *wnd = w ;
  DLGTEXTE_USER_DATA *dlg_data = wnd->DlgData->UserData ;

  start_font = dlg_data->start_font ;
  Xfree( dlg_data->tsort_fonts ) ;

  return( GWCloseDlg( w ) ) ;
}

void traite_ptexte(void)
{
  GEM_WINDOW         *dlg ;
  DLGDATA            dlg_data ;
  DLGTEXTE_USER_DATA user_data ;
  int                bouton ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId = FORM_TEXTE ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &user_data ;
  dlg_data.OnInitDialog   = OnInitDialogText ;
  dlg_data.OnObjectNotify = OnObjectNotifyText ;
  dlg_data.OnCloseDialog  = OnCloseText ;

  dlg     = GWCreateDialog( &dlg_data ) ;
  bouton  = GWDoModal( dlg, TEXTE_NTAILLE ) ;
  if ( bouton == IDCANCEL ) memcpy( &ttype, &user_data.text, sizeof(TEXT_TYPE) ) ;
}
