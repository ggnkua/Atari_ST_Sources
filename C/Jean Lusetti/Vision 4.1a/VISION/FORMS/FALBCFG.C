#include <string.h>
#include "..\tools\gwindows.h"

#include "..\tools\catalog.h"
#include "..\tools\logging.h"

#include "defs.h"
#include "falbum.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  OBJECT *popup_shiftstart ;
  OBJECT *popup_shiftval ;

  int nb_units ;
}
WDLG_ALBCFG ;

typedef struct
{
  unsigned long show_categories ;
  int           s1, s2 ;

  unsigned char fshow_all ;
  unsigned char fplanes ;
  unsigned int  imgformat ;

  char     save_index ;

  int nb_visibles ;
  int nb_masked ;
  int first_visible ;
  int first_masked ;
  int nb_categories ;
  HCAT hCat ;
}
WEXTENSION_ALBCFG ;


void update_categorylist(GEM_WINDOW *wnd, OBJECT *adr_albumconf, unsigned long s_cat, int flag_aff)
{
  WEXTENSION_ALBCFG* wext = wnd->DlgData->UserData ;
  CATALOG_HEADER*    catalog_header = catalog_get_header(wext->hCat) ;
  int                i, ind ;
  char               buf[30] ;

  if ( !catalog_header )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }
  wext->nb_visibles = wext->nb_masked = 0 ;
  for (i = ACONF_VISIBLE1; i <= ACONF_VISIBLE6; i++) write_text(adr_albumconf, i, "                ") ;
  for (i = ACONF_MASKED1; i <= ACONF_MASKED6; i++) write_text(adr_albumconf, i, "                ") ;
  for (i = 0; i < wext->nb_categories; i++)
  {
    if (s_cat & (1UL << i))
    {
      ind = ACONF_VISIBLE1-wext->first_visible+wext->nb_visibles ;
      if ((ind >= ACONF_VISIBLE1) && (ind <= ACONF_VISIBLE6))
      {
        strcpy(buf, "                ") ;
        memcpy(buf, catalog_header->category_names[i], strlen(catalog_header->category_names[i])) ;
        write_text(adr_albumconf, ind, buf) ;
      }
      wext->nb_visibles++ ;
    }
    else
    {
      ind = ACONF_MASKED1-wext->first_masked+wext->nb_masked ;
      if ((ind >= ACONF_MASKED1) && (ind <= ACONF_MASKED6))
      {
        strcpy(buf, "                ") ;
        memcpy(buf, catalog_header->category_names[i], strlen(catalog_header->category_names[i])) ;
        write_text(adr_albumconf, ind, buf) ;
      }
      wext->nb_masked++ ;
    }
  }

  if (wext->nb_visibles > 0)
    adr_albumconf[ACONF_VISIBLESLD].ob_height = (int) ((float)(adr_albumconf[ACONF_VISIBLEBOX].ob_height)*
                                                       (float)(1+ACONF_VISIBLE6-ACONF_VISIBLE1)/(float)wext->nb_visibles) ;
  else
    adr_albumconf[ACONF_VISIBLESLD].ob_height = adr_albumconf[ACONF_VISIBLEBOX].ob_height ;

  if (adr_albumconf[ACONF_VISIBLESLD].ob_height > adr_albumconf[ACONF_VISIBLEBOX].ob_height)
    adr_albumconf[ACONF_VISIBLESLD].ob_height = adr_albumconf[ACONF_VISIBLEBOX].ob_height ;

  if (wext->nb_visibles > 1+ACONF_VISIBLE6-ACONF_VISIBLE1)
    adr_albumconf[ACONF_VISIBLESLD].ob_y = (int) ((float)wext->first_visible/(float)(wext->nb_visibles-2-ACONF_VISIBLE6+ACONF_VISIBLE1)*
                                                  (float)(adr_albumconf[ACONF_VISIBLEBOX].ob_height-adr_albumconf[ACONF_VISIBLESLD].ob_height)) ;
  else
  adr_albumconf[ACONF_VISIBLESLD].ob_y = 0 ;

  if (wext->nb_masked > 0)
    adr_albumconf[ACONF_MASKEDSLD].ob_height = (int) ((float)(adr_albumconf[ACONF_MASKEDBOX].ob_height)*
                                                       (float)(1+ACONF_MASKED6-ACONF_MASKED1)/(float)wext->nb_masked) ;
  else
    adr_albumconf[ACONF_MASKEDSLD].ob_height = adr_albumconf[ACONF_MASKEDBOX].ob_height ;

  if (adr_albumconf[ACONF_MASKEDSLD].ob_height > adr_albumconf[ACONF_MASKEDBOX].ob_height)
    adr_albumconf[ACONF_MASKEDSLD].ob_height = adr_albumconf[ACONF_MASKEDBOX].ob_height ;

  if (wext->nb_masked > 1+ACONF_MASKED6-ACONF_MASKED1)
    adr_albumconf[ACONF_MASKEDSLD].ob_y = (int) ((float)wext->first_masked/(float)(wext->nb_masked-2-ACONF_MASKED6+ACONF_MASKED1)*
                                                 (float)(adr_albumconf[ACONF_MASKEDBOX].ob_height-adr_albumconf[ACONF_MASKEDSLD].ob_height)) ;
  else
    adr_albumconf[ACONF_MASKEDSLD].ob_y = 0 ;


  if (flag_aff)
  {
    for (i = ACONF_VISIBLE1; i <= ACONF_VISIBLE6; i++) xobjc_draw( wnd->window_handle, adr_albumconf, i ) ;
    for (i = ACONF_MASKED1; i <= ACONF_MASKED6; i++) xobjc_draw( wnd->window_handle, adr_albumconf, i ) ;
    xobjc_draw( wnd->window_handle, adr_albumconf, ACONF_VISIBLEBOX ) ;
    xobjc_draw( wnd->window_handle, adr_albumconf, ACONF_MASKEDBOX ) ;
  }
}

void setup_category(unsigned long *s_cat, int num, int flag_mask, int nb_categories)
{
  int i, j ;

  j = -1 ;
  for (i = 0; i < nb_categories; i++)
  {
    if (*s_cat & (1UL << i))
    {
      if (flag_mask)
        if (++j == num) break ;
    }
    else
    {
      if (!flag_mask)
        if (++j == num) break ;
    }
  }

  if (j == num)
  {
    if (flag_mask) *s_cat &= ~(1UL << i) ;
    else           *s_cat |= 1UL << i ;
  }
}

void OnInitDialogAlbCfg(void *w)
{
  GEM_WINDOW        *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_ALBCFG *wext = wnd->DlgData->UserData ;
  WDLG_ALBCFG       *wdlg = wnd->Extension ;
  OBJECT            *adr_albumconf = wnd->DlgData->BaseObject ;
  CATALOG_HEADER*    catalog_header = catalog_get_header(wext->hCat) ;
  CATALOG_FILTER*    catalog_filter = catalog_get_filter(wext->hCat) ;
  int               len, bouton ;
  int               i ;
  char              buf[20] ;

  if ( !catalog_header )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }
  len = (int) strlen("  A  ") ;
  wdlg->nb_units = 1+'Z'-'A' ;
  wdlg->popup_shiftstart = popup_make( wdlg->nb_units, len ) ;
  if ( wdlg->popup_shiftstart == NULL )
  {
    form_error(8) ;
    return ;
  }

  wdlg->popup_shiftval = popup_make( wdlg->nb_units, len ) ;
  if ( wdlg->popup_shiftval == NULL )
  {
    popup_kill( wdlg->popup_shiftstart, wdlg->nb_units ) ;
    form_error( 8 ) ;
    return ;
  }

  wext->nb_categories = 1 ;
  i                   = 0 ;
  while ( catalog_header->category_names[i][0] )
  {
    wext->nb_categories++ ;
    i++ ;
  }

  strcpy( buf, "  A  " ) ;
  for (i = 0; i < wdlg->nb_units; i++)
  {
    buf[2] = 'A'+i ;
    strcpy(wdlg->popup_shiftstart[1+i].ob_spec.free_string, buf) ;
    strcpy(wdlg->popup_shiftval[1+i].ob_spec.free_string, buf) ;
  }

  wext->s1 = catalog_header->shift_start ;
  wext->s2 = wext->s1+catalog_header->shift_value ;

  for (bouton = ACONF_MONO; bouton <= ACONF_TC; bouton += 2)
    if (catalog_filter->planes & (1 << ((bouton-ACONF_MONO) >> 1))) select(adr_albumconf, bouton) ;
    else                                                            deselect(adr_albumconf, bouton) ;
  for (bouton = ACONF_ART; bouton <= ACONF_TIFF; bouton += 2) deselect(adr_albumconf, bouton) ;
  deselect(adr_albumconf, ACONF_BMP) ; /* Pas … la suite ! */
  if (catalog_filter->format & (1 << F_ART))   select(adr_albumconf, ACONF_ART) ;
  if (catalog_filter->format & (1 << F_DEGAS)) select(adr_albumconf, ACONF_DEGAS) ;
  if (catalog_filter->format & (1 << F_GIF))   select(adr_albumconf, ACONF_GIF) ;
  if (catalog_filter->format & (1 << F_IMG))   select(adr_albumconf, ACONF_IMG) ;
  if (catalog_filter->format & (1 << F_JPEG))  select(adr_albumconf, ACONF_JPEG) ;
  if (catalog_filter->format & (1 << F_MAC))   select(adr_albumconf, ACONF_MAC) ;
  if (catalog_filter->format & (1 << F_NEO))   select(adr_albumconf, ACONF_NEO) ;
  if (catalog_filter->format & (1 << F_TARGA)) select(adr_albumconf, ACONF_TARGA) ;
  if (catalog_filter->format & (1 << F_TIFF))  select(adr_albumconf, ACONF_TIFF) ;
  if (catalog_filter->format & (1 << F_BMP))   select(adr_albumconf, ACONF_BMP) ;

  if (catalog_header->save_index) select(adr_albumconf, ACONF_SAVEINDEX) ;
  else                            deselect(adr_albumconf, ACONF_SAVEINDEX) ;

  wext->show_categories = catalog_filter->category ;
  wext->first_visible = wext->first_masked = 0 ;
  update_categorylist( wnd, adr_albumconf, wext->show_categories, 0 ) ;

  sprintf(buf, "  %c  ", 'A'+wext->s1) ;
  write_text(adr_albumconf, ACONF_SHIFTST, buf) ;
  sprintf(buf, "  %c  ", 'A'+wext->s2) ;
  write_text(adr_albumconf, ACONF_SHIFTEND, buf) ;
}

int OnObjectNotifyAlbCfg(void *w, int obj)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_ALBCFG *wext = wnd->DlgData->UserData ;
  WDLG_ALBCFG       *wdlg = wnd->Extension ;
  OBJECT            *adr_albumconf = wnd->DlgData->BaseObject ;
  float             pc ;
  int               i ;
  int               mx, my, clicked, dummy ;
  int               code = -1 ;
  char              buf[100] ;

  switch( obj )
  {
    case ACONF_MONO       :
    case ACONF_TMONO      : inv_select(adr_albumconf, ACONF_MONO) ;
                            break ;
    case ACONF_4C         :
    case ACONF_T4C        : inv_select(adr_albumconf, ACONF_4C) ;
                            break ;
    case ACONF_16C        :
    case ACONF_T16C       : inv_select(adr_albumconf, ACONF_16C) ;
                            break ;
    case ACONF_256C       :
    case ACONF_T256C      : inv_select(adr_albumconf, ACONF_256C) ;
                            break ;
    case ACONF_TC         :
    case ACONF_TTC        : inv_select(adr_albumconf, ACONF_TC) ;
                            break ;
    case ACONF_ART        :
    case ACONF_TART       : inv_select(adr_albumconf, ACONF_ART) ;
                            break ;
    case ACONF_DEGAS      :
    case ACONF_TDEGAS     : inv_select(adr_albumconf, ACONF_DEGAS) ;
                            break ;
    case ACONF_GIF        :
    case ACONF_TGIF       : inv_select(adr_albumconf, ACONF_GIF) ;
                            break ;
    case ACONF_IMG        :
    case ACONF_TIMG       : inv_select(adr_albumconf, ACONF_IMG) ;
                            break ;
    case ACONF_JPEG       :
    case ACONF_TJPEG      : inv_select(adr_albumconf, ACONF_JPEG) ;
                            break ;
    case ACONF_MAC        :
    case ACONF_TMAC       : inv_select(adr_albumconf, ACONF_MAC) ;
                            break ;
    case ACONF_NEO        :
    case ACONF_TNEO       : inv_select(adr_albumconf, ACONF_NEO) ;
                            break ;
    case ACONF_TARGA      :
    case ACONF_TTARGA     : inv_select(adr_albumconf, ACONF_TARGA) ;
                            break ;
    case ACONF_TIFF       :
    case ACONF_TTIFF      : inv_select(adr_albumconf, ACONF_TIFF) ;
                            break ;
    case ACONF_BMP        :
    case ACONF_TBMP       : inv_select(adr_albumconf, ACONF_BMP) ;
                            break ;
    case ACONF_VIS2MASK   : for (i = ACONF_VISIBLE1; i <= ACONF_VISIBLE6; i++)
                              if (selected(adr_albumconf, i)) break ;
                            if (i != 1+ACONF_VISIBLE6)
                            {
                              read_text(adr_albumconf, i, buf) ;
                              if (memcmp(buf, "     ", 5))
                              {
                                setup_category(&wext->show_categories, i-ACONF_VISIBLE1+wext->first_visible, 1, wext->nb_categories ) ;
                                if (wext->first_visible > 0) wext->first_visible-- ;
                                update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                              }
                            }
                            inv_select(adr_albumconf, obj) ;
                            break ;
    case ACONF_MASK2VIS   : for (i = ACONF_MASKED1; i <= ACONF_MASKED6; i++)
                              if (selected(adr_albumconf, i)) break ;
                            if (i != 1+ACONF_MASKED6)
                            {
                              read_text(adr_albumconf, i, buf) ;
                              if (memcmp(buf, "     ", 5))
                              {
                                setup_category(&wext->show_categories, i-ACONF_MASKED1+wext->first_masked, 0, wext->nb_categories ) ;
                                if (wext->first_masked > 0) wext->first_masked-- ;
                                update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                              }
                            }
                            inv_select(adr_albumconf, obj) ;
                            break ;
    case ACONF_MASKALL    : wext->show_categories = 0L ;
                            wext->first_visible   = wext->first_masked = 0 ;
                            update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            inv_select(adr_albumconf, obj) ;
                            break ;
    case ACONF_SEEALL     : wext->show_categories = 0xFFFFFFFFL ;
                            wext->first_visible   = wext->first_masked = 0 ;
                            update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            inv_select(adr_albumconf, obj) ;
                            break ;
    case ACONF_VISIBLEUP  : if (wext->first_visible > 0)
                            {
                              wext->first_visible-- ;
                              update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            }
                            break ;
    case ACONF_VISIBLEDN  : if (2+wext->first_visible+ACONF_VISIBLE6-ACONF_VISIBLE1 < wext->nb_visibles)
                            {
                              wext->first_visible++ ;
                              update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            }
                            break ;
    case ACONF_VISIBLEBOX : graf_mkstate(&mx, &my, &dummy, &dummy) ;
                            objc_offset(adr_albumconf, ACONF_VISIBLESLD, &dummy, &mx) ;
                            if (my > mx) wext->first_visible += 1+ACONF_VISIBLE6-ACONF_VISIBLE1 ;
                            else         wext->first_visible -= 1+ACONF_VISIBLE6-ACONF_VISIBLE1 ;
                            if (wext->first_visible < 0) wext->first_visible = 0 ;
                            if (wext->first_visible+2+ACONF_VISIBLE6-ACONF_VISIBLE1 > wext->nb_visibles)
                              wext->first_visible = wext->nb_visibles-2-ACONF_VISIBLE6+ACONF_VISIBLE1 ;
                            update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            break ;
    case ACONF_VISIBLESLD : pc = (float) graf_slidebox(adr_albumconf, ACONF_VISIBLEBOX, ACONF_VISIBLESLD, 1) ;
                            pc = (1000.0-pc)/10.0 ;
                            dummy = (int) ((100.0-pc)*(float)(adr_albumconf[ACONF_VISIBLEBOX].ob_height-adr_albumconf[ACONF_VISIBLESLD].ob_height)/100.0) ;
                            adr_albumconf[ACONF_VISIBLESLD].ob_y = dummy ;
                            wext->first_visible = (int) ((float)dummy*(float)(wext->nb_visibles-2-ACONF_VISIBLE6+ACONF_VISIBLE1)/(float)(adr_albumconf[ACONF_VISIBLEBOX].ob_height-adr_albumconf[ACONF_VISIBLESLD].ob_height)) ;
                            if (wext->first_visible < 0) wext->first_visible = 0 ;
                            if (wext->first_visible+2+ACONF_VISIBLE6-ACONF_VISIBLE1 > wext->nb_visibles)
                              wext->first_visible = wext->nb_visibles-2-ACONF_VISIBLE6+ACONF_VISIBLE1 ;
                            update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            break ;
    case ACONF_MASKEDUP   : if (wext->first_masked > 0)
                            {
                              wext->first_masked-- ;
                              update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            }
                            break ;
    case ACONF_MASKEDDN   : if (2+wext->first_masked+ACONF_MASKED6-ACONF_MASKED1 <= wext->nb_masked)
                            {
                              wext->first_masked++ ;
                              update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            }
                            break ;
    case ACONF_MASKEDBOX  : graf_mkstate(&mx, &my, &dummy, &dummy) ;
                            objc_offset(adr_albumconf, ACONF_MASKEDSLD, &dummy, &mx) ;
                            if (my > mx) wext->first_masked += 1+ACONF_MASKED6-ACONF_MASKED1 ;
                            else         wext->first_masked -= 1+ACONF_MASKED6-ACONF_MASKED1 ;
                            if (wext->first_masked < 0) wext->first_masked = 0 ;
                            if (wext->first_masked+2+ACONF_MASKED6-ACONF_MASKED1 > wext->nb_masked)
                              wext->first_masked = wext->nb_masked-2-ACONF_MASKED6+ACONF_MASKED1 ;
                            update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            break ;
    case ACONF_MASKEDSLD  : pc = (float) graf_slidebox(adr_albumconf, ACONF_MASKEDBOX, ACONF_MASKEDSLD, 1) ;
                            pc = (1000.0-pc)/10.0 ;
                            dummy = (int) ((100.0-pc)*(float)(adr_albumconf[ACONF_MASKEDBOX].ob_height-adr_albumconf[ACONF_MASKEDSLD].ob_height)/100.0) ;
                            adr_albumconf[ACONF_MASKEDSLD].ob_y = dummy ;
                            wext->first_masked = (int) ((float)dummy*(float)(wext->nb_masked-2-ACONF_MASKED6+ACONF_MASKED1)/(float)(adr_albumconf[ACONF_MASKEDBOX].ob_height-adr_albumconf[ACONF_MASKEDSLD].ob_height)) ;
                            if (wext->first_masked < 0) wext->first_masked = 0 ;
                            if (wext->first_masked+2+ACONF_MASKED6-ACONF_MASKED1 > wext->nb_masked)
                              wext->first_masked = wext->nb_masked-2-ACONF_MASKED6+ACONF_MASKED1 ;
                            update_categorylist( wnd, adr_albumconf, wext->show_categories, 1) ;
                            break ;
    case ACONF_SAVEINDEX  :
    case ACONF_TSAVEINDEX : inv_select(adr_albumconf, ACONF_SAVEINDEX) ;
                            break ;
    case ACONF_SHIFTST    : deselect(adr_albumconf, obj) ;
                            objc_offset(adr_albumconf, obj, &mx, &my) ;
                            clicked = popup_formdo(&wdlg->popup_shiftstart, mx, my, 1+wext->s1, -1) ;
                            if (clicked) wext->s1 = clicked-1 ;
                            sprintf(buf, "  %c  ", 'A'+wext->s1) ;
                            write_text(adr_albumconf, ACONF_SHIFTST, buf) ;
                            xobjc_draw( wnd->window_handle, adr_albumconf, ACONF_SHIFTST ) ;
                            break ;
    case ACONF_SHIFTEND   : deselect(adr_albumconf, obj) ;
                            objc_offset(adr_albumconf, obj, &mx, &my) ;
                            clicked = popup_formdo(&wdlg->popup_shiftval, mx, my, 1+wext->s2, -1) ;
                            if (clicked) wext->s2 = clicked-1 ;
                            sprintf(buf, "  %c  ", 'A'+wext->s2) ;
                            write_text(adr_albumconf, ACONF_SHIFTEND, buf) ;
                            xobjc_draw( wnd->window_handle, adr_albumconf, ACONF_SHIFTEND ) ;
                            break ;
     case ACONF_OK        : code = IDOK ;
                            break ;
     case ACONF_CANCEL    : code = IDCANCEL ;
                            break ;
  }

  if ( code == IDOK )
  {
    wext->fplanes   = 0 ;
    wext->fshow_all = 1 ;
    wext->imgformat = 0xFFFF ;
    for (obj = ACONF_MONO; obj <= ACONF_TC; obj += 2)
      if (selected(adr_albumconf, obj)) wext->fplanes  |= (1 << ((obj-ACONF_MONO) >> 1))  ;
      else                              wext->fshow_all = 0 ;

    if (!selected(adr_albumconf, ACONF_ART))   wext->imgformat &= ~(1 << F_ART) ;
    if (!selected(adr_albumconf, ACONF_DEGAS)) wext->imgformat &= ~(1 << F_DEGAS) ;
    if (!selected(adr_albumconf, ACONF_GIF))   wext->imgformat &= ~(1 << F_GIF) ;
    if (!selected(adr_albumconf, ACONF_JPEG))  wext->imgformat &= ~(1 << F_JPEG) ;
    if (!selected(adr_albumconf, ACONF_IMG))   wext->imgformat &= ~(1 << F_IMG) ;
    if (!selected(adr_albumconf, ACONF_MAC))   wext->imgformat &= ~(1 << F_MAC) ;
    if (!selected(adr_albumconf, ACONF_NEO))   wext->imgformat &= ~(1 << F_NEO) ;
    if (!selected(adr_albumconf, ACONF_TARGA)) wext->imgformat &= ~(1 << F_TARGA) ;
    if (!selected(adr_albumconf, ACONF_TIFF))  wext->imgformat &= ~(1 << F_TIFF) ;
    if (!selected(adr_albumconf, ACONF_BMP))   wext->imgformat &= ~(1 << F_BMP) ;

    wext->save_index = selected(adr_albumconf, ACONF_SAVEINDEX ) ;
  }

  return( code ) ;
}

int OnCloseAlbCfg(void *w)
{
  GEM_WINDOW  *wnd = (GEM_WINDOW *) w ;
  WDLG_ALBCFG *wdlg = wnd->Extension ;

  popup_kill( wdlg->popup_shiftval, wdlg->nb_units ) ;
  popup_kill( wdlg->popup_shiftstart, wdlg->nb_units ) ;

  return( GWCloseDlg( w ) ) ;
}

int OnTxtBubbleAlbCfg(void *w, int mx, int my, char *txt)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr_form =  wnd->DlgData->BaseObject ;
  int        objet, trouve = 1 ;

  objet = objc_find( adr_form, 0, MAX_DEPTH, mx, my ) ; 
  switch( objet )
  {
    case ACONF_VIS2MASK  : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HACONFV2M) ) ;
                           break ;
    case ACONF_MASK2VIS  : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HACONFM2V) ) ;
                           break ;
    case ACONF_TSAVEINDEX:
    case ACONF_SAVEINDEX : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HACONFINDEX) ) ;
                           break ;
    case ACONF_SHIFTST   :
    case ACONF_SHIFTEND  : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HACONFSHIFT) ) ;
                           break ;
    default              : trouve = 0 ;
  }
  if ((objet >= ACONF_VISIBLE1) && (objet <= ACONF_VISIBLE6))
  {
    strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HACONFVIS) ) ;
    trouve = 1 ;
  }
  if ((objet >= ACONF_MASKED1) && (objet <= ACONF_MASKED6))
  {
    strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HACONFMASK) ) ;
    trouve = 1 ;
  }

  return( trouve ) ; 
}

int FGetAlbCfg(WEXTENSION_ALBCFG *wext)
{
  GEM_WINDOW *dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_ALBUMCONFIG ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = wext ;
  dlg_data.ExtensionSize  = sizeof(WDLG_ALBCFG) ;
  dlg_data.OnInitDialog   = OnInitDialogAlbCfg ;
  dlg_data.OnObjectNotify = OnObjectNotifyAlbCfg ;
  dlg_data.OnCloseDialog  = OnCloseAlbCfg ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  dlg->OnTxtBubble   = OnTxtBubbleAlbCfg ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

int album_config(HCAT hCat)
{
  WEXTENSION_ALBCFG wext ;
  int               code ;

  wext.hCat = hCat ;
  code = FGetAlbCfg( &wext ) ;
  if ( code == IDOK )
  {
    CATALOG_HEADER* catalog_header = catalog_get_header( hCat ) ;
    CATALOG_FILTER* catalog_filter = catalog_get_filter( hCat ) ;

    if ( catalog_header && catalog_filter )
    {
      catalog_filter->planes   = wext.fplanes ;
      catalog_filter->show_all = wext.fshow_all ;
      catalog_filter->format   = 0xFFFF ;
      catalog_filter->format   = wext.imgformat ;
      catalog_filter->category = wext.show_categories ;

      if ((catalog_filter->format != 0xFFFF) || (catalog_filter->category != 0xFFFF)) catalog_filter->show_all = 0 ;
      catalog_header->shift_start = wext.s1 ;
      catalog_header->shift_value = wext.s2-wext.s1 ;
      catalog_setsaveindex( hCat, wext.save_index ) ;
    }
    else LoggingDo(LL_ERROR, "Invalid hCat");
  }

  return( code ) ;
}
