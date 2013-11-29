#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


void OnInitDialogNewImg(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr_new = wnd->DlgData->BaseObject ;
  char       buf[50] ;

  deselect(adr_new, COLOR_2) ;
  deselect(adr_new, COLOR_4) ;
  deselect(adr_new, COLOR_16) ;
  deselect(adr_new, COLOR_256) ;
  deselect(adr_new, COLOR_TRUE) ;
  switch(nb_colors)
  {
    case 2  : select(adr_new, COLOR_2) ;
              break ;
    case 4  : select(adr_new, COLOR_4) ;
              break ;
    case 16 : select(adr_new, COLOR_16) ;
              break ;
    case 256: if (Truecolor) select(adr_new, COLOR_TRUE) ;
              else           select(adr_new, COLOR_256) ;
              break ;
  }
  if (nb_colors < 4)
  {
    adr_new[COLOR_4].ob_state  |= DISABLED ;
    adr_new[COLOR_T4].ob_state |= DISABLED ;
    adr_new[COLOR_T4].ob_flags &= ~TOUCHEXIT ;
  }
  else
  {
    adr_new[COLOR_4].ob_state  &= ~DISABLED ;
    adr_new[COLOR_T4].ob_state &= ~DISABLED ;
    adr_new[COLOR_T4].ob_flags |= TOUCHEXIT ;
  }
  if (nb_colors < 16)
  {
    adr_new[COLOR_16].ob_state  |= DISABLED ;
    adr_new[COLOR_T16].ob_state |= DISABLED ;
    adr_new[COLOR_T16].ob_flags &= ~TOUCHEXIT ;
  }
  else
  {
    adr_new[COLOR_16].ob_state  &= ~DISABLED ;
    adr_new[COLOR_T16].ob_state &= ~DISABLED ;
    adr_new[COLOR_T16].ob_flags |= TOUCHEXIT ;
  }
  if (nb_colors < 256)
  {
    adr_new[COLOR_256].ob_state  |= DISABLED ;
    adr_new[COLOR_T256].ob_state |= DISABLED ;
    adr_new[COLOR_T256].ob_flags &= ~TOUCHEXIT ;
  }
  else
  {
    adr_new[COLOR_256].ob_state  &= ~DISABLED ;
    adr_new[COLOR_T256].ob_state &= ~DISABLED ;
    adr_new[COLOR_T256].ob_flags |= TOUCHEXIT ;
  }

  if (Truecolor)
  {
    adr_new[COLOR_2].ob_state     |= DISABLED ;
    adr_new[COLOR_T2].ob_state    |= DISABLED ;
    adr_new[COLOR_T2].ob_flags    &= ~TOUCHEXIT ;
    adr_new[COLOR_4].ob_state     |= DISABLED ;
    adr_new[COLOR_T4].ob_state    |= DISABLED ;
    adr_new[COLOR_T4].ob_flags    &=~TOUCHEXIT ;
    adr_new[COLOR_16].ob_state    |= DISABLED ;
    adr_new[COLOR_T16].ob_state   |= DISABLED ;
    adr_new[COLOR_T16].ob_flags   &= ~TOUCHEXIT ;
    adr_new[COLOR_256].ob_state   |= DISABLED ;
    adr_new[COLOR_T256].ob_state  |= DISABLED ;
    adr_new[COLOR_T256].ob_flags  &= ~TOUCHEXIT ;
    adr_new[COLOR_TRUE].ob_state  &= ~DISABLED ;
    adr_new[COLOR_TTRUE].ob_state &= ~DISABLED ;
    adr_new[COLOR_TTRUE].ob_flags |= TOUCHEXIT ;
  }
  else
  {
    adr_new[COLOR_TRUE].ob_state  |= DISABLED ;
    adr_new[COLOR_TTRUE].ob_state |= DISABLED ;
    adr_new[COLOR_TTRUE].ob_flags &= ~TOUCHEXIT ;
  }

  sprintf(buf, "%.4d", 1+Xmax) ;
  write_text(adr_new, NEW_X, buf) ;
  sprintf(buf, "%.4d", 1+Ymax) ;
  write_text(adr_new, NEW_Y, buf) ;
}

int OnObjectNotifyNewImg(void *w, int obj)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr_new = wnd->DlgData->BaseObject ;
  int        nx, ny, nc ;
  int        tpmx, tpmy ;
  int        code = -1 ;
  char       buf[50] ;

  switch( obj )
  {
     case COLOR_T2   : deselect(adr_new, COLOR_4) ;
                       deselect(adr_new, COLOR_16) ;
                       deselect(adr_new, COLOR_256) ;
                       select(adr_new, COLOR_2) ;
                       break ;
     case COLOR_T4   : deselect(adr_new, COLOR_2) ;
                       deselect(adr_new, COLOR_16) ;
                       deselect(adr_new, COLOR_256) ;
                       select(adr_new, COLOR_4) ;
                       break ;
     case COLOR_T16  : deselect(adr_new, COLOR_4) ;
                       deselect(adr_new, COLOR_2) ;
                       deselect(adr_new, COLOR_256) ;
                       select(adr_new, COLOR_16) ;
                       break ;
     case COLOR_T256 : deselect(adr_new, COLOR_4) ;
                       deselect(adr_new, COLOR_16) ;
                       deselect(adr_new, COLOR_2) ;
                       select(adr_new, COLOR_256) ;
                       break ;
     case NEW_OK     : code = IDOK ;
                       break ;
     case NEW_CANCEL : code = IDCANCEL ;
                       break ;
  }

  xobjc_draw( wnd->window_handle, adr_new, COLOR_2 ) ;
  xobjc_draw( wnd->window_handle, adr_new, COLOR_4 ) ;
  xobjc_draw( wnd->window_handle, adr_new, COLOR_16 ) ;
  xobjc_draw( wnd->window_handle, adr_new, COLOR_256 ) ;

  if ( code == IDOK )
  {
    read_text(adr_new, NEW_X, buf) ;
    nx = atoi(buf) ;
    read_text(adr_new, NEW_Y, buf) ;
    ny = atoi(buf) ;
    read_text(adr_new, NEW_DPIX, buf) ;
    tpmx = atoi(buf) ;
    if (tpmx == 0) tpmx++ ;
    tpmx = (int) (25400.0/(double)tpmx) ;
    read_text(adr_new, NEW_DPIY, buf) ;
    tpmy = atoi(buf) ;
    if (tpmy == 0) tpmy++ ;
    tpmy = (int) (25400.0/(double)tpmy) ;
    if (selected(adr_new, COLOR_2))   nc = 2 ;
    else
    if (selected(adr_new, COLOR_4))   nc = 4 ;
    else
    if (selected(adr_new, COLOR_16))  nc = 16 ;
    else
    if (selected(adr_new, COLOR_256)) nc = 256 ;
    read_text(adr_new, NEW_NAME, buf) ;
    if (!Truecolor) strcat(buf, ".IMG") ;
    else            strcat(buf, ".TIF") ;

    nouvelle_wimage(buf, nx, ny, nc, tpmx, tpmy) ;
  }

  return( code ) ;
}

void traite_nouveau(void)
{
  GEM_WINDOW *dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_NEW ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = NULL ;
  dlg_data.OnInitDialog = OnInitDialogNewImg ;
  dlg_data.OnObjectNotify = OnObjectNotifyNewImg ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, NEW_X ) ;

  if ( code == IDOK )
  {

  }
}
