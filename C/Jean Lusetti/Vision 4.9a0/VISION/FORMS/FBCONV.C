#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"
#include "..\tools\logging.h"

#include "defs.h"
#include "frfiles.h"
#include "ftiff.h"
#include "ftarga.h"
#include "fjpeg.h"
#include "fbconv.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  OBJECT* popup_fmt ;
  OBJECT* popup_pb ;
  int     fmt, pb ;
  char*   buffer ;
}
WDLG_BCONV ;

typedef struct
{
  BCONV_PARAMS* p ;
}
WEXTENSION_BCONV ;


static void OnInitDialogBConv(void* w)
{
  GEM_WINDOW*       wnd = (GEM_WINDOW*) w ;
  WEXTENSION_BCONV* wext = wnd->DlgData->UserData ;
  WDLG_BCONV*       wdlg = wnd->Extension ;
  OBJECT*           adr_bconv = wnd->DlgData->BaseObject ;
  IID               iids[] = { IID_TIFF, IID_JPEG, IID_GIF, IID_TARGA, IID_BMP, IID_IMG } ;
  INFO_IMAGE_DRIVER caps ;
  int               i ;
  char              buffer[100] ;

  wdlg->buffer = (char*) Xalloc( PATH_MAX * NB_MAX_RFILES ) ;
  if ( wdlg->buffer == NULL ) return ;

  write_text( adr_bconv, BCONV_SRCPATH, "" ) ;
  write_text( adr_bconv, BCONV_DSTPATH, "" ) ;
  wdlg->popup_fmt = popup_make( 6, 11 ) ;
  if ( wdlg->popup_fmt == NULL )
  {
    Xfree( wdlg->buffer ) ;
    form_error(8) ;
    return ;
  }
  wdlg->popup_pb = popup_make( 2, 10 ) ;
  if ( wdlg->popup_pb == NULL )
  {
    Xfree( wdlg->buffer ) ;
    popup_kill( wdlg->popup_fmt, 6 ) ;
    form_error(8) ;
    return ;
  }

  wdlg->fmt = 0 ;

  for ( i = 0; i < ARRAY_SIZE(iids); i++ )
  { 
    get_imgdrivercapabilities( iids[i], &caps) ;
    sprintf( buffer, "  %s", caps.short_name ) ;
    if ( i == 0 ) write_text (adr_bconv, BCONV_DSTFMT, buffer ) ;
    strcpy( wdlg->popup_fmt[1+i].ob_spec.free_string, buffer ) ;
  }

  adr_bconv[BCONV_OPT].ob_state &= ~DISABLED ;

  wdlg->pb  = 0 ;
  write_text(adr_bconv, BCONV_PBCONV, MsgTxtGetMsg(hMsg, MSG_BCONVDIT) ) ;
  strcpy(wdlg->popup_pb[1].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_BCONVDIT) ) ;
  strcpy(wdlg->popup_pb[2].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_BCONVCAN) ) ;

  memzero( &wext->p->inf, sizeof(INFO_IMAGE) ) ;
  wext->p->inf.compress = 1 ; /* Par d‚faut, pas de compression TIFF */
  wext->p->inf.c.f.jpg.quality  = 90 ; /* Par d‚faut, qualit‚ JPEG = 90%     */

  select( adr_bconv, BCONV_DONOTHING ) ;
  deselect( adr_bconv, BCONV_REMOVESRC ) ;
  deselect( adr_bconv, BCONV_MOVESRC ) ;
  write_text( adr_bconv, BCONV_MOVEDEST, "" ) ;

  /* Extensions for image resizing feature if available (not for low res) */
  if ( adr_bconv->ob_tail >= BCONV_RW )
  {
    LoggingDo(LL_INFO, "Image resize feature available for Batch Conversion") ;
    deselect( adr_bconv, BCONV_RESIZE ) ;
    write_text( adr_bconv, BCONV_RW, "" ) ;
    write_text( adr_bconv, BCONV_RH, "" ) ;
  }
}

static void objc_redraws(GEM_WINDOW* wnd)
{
  int     h = wnd->window_handle ;
  OBJECT* adr_bconv = wnd->DlgData->BaseObject ;

  xobjc_draw( h, adr_bconv, BCONV_DONOTHING ) ;
  xobjc_draw( h, adr_bconv, BCONV_REMOVESRC ) ;
  xobjc_draw( h, adr_bconv, BCONV_MOVESRC ) ;
}

static int OnObjectNotifyBConv(void* w, int obj)
{
  GEM_WINDOW*       wnd = (GEM_WINDOW*) w ;
  WEXTENSION_BCONV* wext = wnd->DlgData->UserData ;
  WDLG_BCONV*       wdlg = wnd->Extension ;
  OBJECT*           adr_bconv = wnd->DlgData->BaseObject ;
  long              nb ;
  int               code = -1 ;
  int               i, off_x, off_y ;

  switch( obj )
  {
    case BCONV_SRCPATH:     wext->p->rfile[0].path[0] = 0 ; /* Else GetRFiles won't prompt */
                            nb = GetRFiles( wext->p->rfile, NB_MAX_RFILES, 1, wext->p->log_file ) ;
                            if ( nb > 0 )
                            {
                              strcpy(wdlg->buffer, "") ;
                              if ( wext->p->rfile[0].path[0] ) strcat( wdlg->buffer, wext->p->rfile[0].path ) ;
                              if ( wext->p->rfile[1].path[0] )
                              {
                                if ( wdlg->buffer[0] ) strcat( wdlg->buffer, ";" ) ;
                                strcat( wdlg->buffer,  wext->p->rfile[1].path ) ;
                              }
                              if (  wext->p->rfile[2].path[0]  )
                              {
                                if ( wdlg->buffer[0] ) strcat( wdlg->buffer, ";" ) ;
                                strcat( wdlg->buffer,  wext->p->rfile[2].path ) ;
                              }
                              if ( wext->p->rfile[3].path[0] )
                              {
                                if ( wdlg->buffer[0] ) strcat( wdlg->buffer, ";" ) ;
                                strcat( wdlg->buffer,  wext->p->rfile[3].path ) ;
                              }
                              write_text( adr_bconv, BCONV_SRCPATH, wdlg->buffer ) ;
                              wext->p->total_nb_files_expected = nb ;
                            }
                            deselect( adr_bconv, obj ) ;
                            xobjc_draw( wnd->window_handle, adr_bconv, obj ) ;
                            break ;
    case BCONV_DSTPATH:     read_text( adr_bconv, obj, wdlg->buffer ) ;
                            if ( folder_name( wext->p->dst_path, "", wdlg->buffer) == 1 )
                              write_text(adr_bconv, obj, wdlg->buffer) ;
                            deselect(adr_bconv, obj) ;
                            xobjc_draw( wnd->window_handle, adr_bconv, obj ) ;
                            break ;
    case BCONV_PBCONV :     objc_offset(adr_bconv, BCONV_PBCONV, &off_x, &off_y) ;
                            i = popup_formdo(&wdlg->popup_pb, off_x, off_y, 1+wdlg->pb, 0) ;
                            if (i > 0) wdlg->pb = i-1 ;
                            else       i = 1+wdlg->pb ;
                            deselect(adr_bconv, obj) ;
                            write_text(adr_bconv, BCONV_PBCONV, wdlg->popup_pb[i].ob_spec.free_string) ;
                            xobjc_draw( wnd->window_handle, adr_bconv, obj ) ;
                            break ;
    case BCONV_DSTFMT :     objc_offset(adr_bconv, BCONV_DSTFMT, &off_x, &off_y) ;
                            i = popup_formdo(&wdlg->popup_fmt, off_x, off_y, 1+wdlg->fmt, 0) ;
                            if (i > 0) wdlg->fmt = i-1 ;
                            else       i = 1+wdlg->fmt ;
                            deselect(adr_bconv, obj) ;
                            if ( (wdlg->fmt == 0) || (wdlg->fmt == 1) || (wdlg->fmt == 3) ) /* TIFF, JPG ou TGA */
                              adr_bconv[BCONV_OPT].ob_state &= ~DISABLED ;
                            else
                              adr_bconv[BCONV_OPT].ob_state |= DISABLED ;
                            write_text(adr_bconv, BCONV_DSTFMT, wdlg->popup_fmt[i].ob_spec.free_string) ;
                            xobjc_draw( wnd->window_handle, adr_bconv, obj ) ;
                            xobjc_draw( wnd->window_handle, adr_bconv, BCONV_OPT ) ;
                            break ;
    case BCONV_OPT    :     if (adr_bconv[BCONV_OPT].ob_state & DISABLED) break ;
                            switch(wdlg->fmt)
                            {
                               case 0 : /* TIFF */
                                        tiff_options( &wext->p->inf ) ;
                                        break ;
                               case 1 : /* JPEG */
                                        jpeg_options( &wext->p->inf ) ;
                                        break ;
                               case 3 : /* TARGA */
                                        targa_options( &wext->p->inf ) ;
                                        break ;
                             }
                             deselect(adr_bconv, obj) ;
                             xobjc_draw( wnd->window_handle, adr_bconv, obj ) ;
                             break ;
     case BCONV_DONOTHING  :
     case BCONV_TDONOTHING : select( adr_bconv, BCONV_DONOTHING ) ;
                             deselect( adr_bconv, BCONV_REMOVESRC ) ;
                             deselect( adr_bconv, BCONV_MOVESRC ) ;
                             objc_redraws( wnd ) ;
                             break ;
     case BCONV_REMOVESRC :
     case BCONV_TREMOVESRC : deselect( adr_bconv, BCONV_DONOTHING ) ;
                             select( adr_bconv, BCONV_REMOVESRC ) ;
                             deselect( adr_bconv, BCONV_MOVESRC ) ;
                             objc_redraws( wnd ) ;
                             break ;
    case BCONV_MOVEDEST  :  read_text( adr_bconv, obj, wdlg->buffer ) ;
                            if ( folder_name( wext->p->dst_path, "", wdlg->buffer) == 1 )
                              write_text(adr_bconv, obj, wdlg->buffer) ;
                            deselect(adr_bconv, obj) ;
                            xobjc_draw( wnd->window_handle, adr_bconv, obj ) ;
     case BCONV_MOVESRC :
     case BCONV_TMOVESRC :  deselect( adr_bconv, BCONV_DONOTHING ) ;
                            deselect( adr_bconv, BCONV_REMOVESRC ) ;
                            select( adr_bconv, BCONV_MOVESRC ) ;
                            objc_redraws( wnd ) ;
                            break ;
     case BCONV_TERASEDST : inv_select( adr_bconv, BCONV_ERASEDST ) ;
                            xobjc_draw( wnd->window_handle, adr_bconv, BCONV_ERASEDST ) ;
                            break ;
     case BCONV_TRESIZE :   inv_select( adr_bconv, BCONV_RESIZE ) ;
                            xobjc_draw( wnd->window_handle, adr_bconv, BCONV_ERASEDST ) ;
                            break ;
     case BCONV_OK    :     code = IDOK ;
                            break ;
     case BCONV_CANCEL :    code = IDCANCEL ;
                            break ;
  }

  if ( code == IDOK )
  {
    switch( wdlg->fmt )
    {
      case 0 : wext->p->inf.lformat = IID_TIFF ;
               break ;

      case 1 : wext->p->inf.lformat = IID_JPEG ;
               break ;

      case 2 : wext->p->inf.lformat = IID_GIF ;
               wext->p->inf.compress = 0 ;
               break ;

      case 3 : wext->p->inf.lformat = IID_TARGA ;
               wext->p->inf.compress = 0 ;
               break ;

      case 4 : wext->p->inf.lformat = IID_BMP ;
               wext->p->inf.compress = 0 ;
               break ;

      case 5 : wext->p->inf.lformat = IID_IMG ;
               wext->p->inf.compress = 0 ;
               break ;
    }
    read_text( adr_bconv, BCONV_DSTPATH,  wext->p->dst_path ) ;
    wext->p->bconv_handle_imcomp = wdlg->pb ;
    if ( selected( adr_bconv, BCONV_DONOTHING ) )      wext->p->manage_src = MS_DONOTHING ;
    else if ( selected( adr_bconv, BCONV_REMOVESRC ) ) wext->p->manage_src = MS_REMOVESRC ;
    else if ( selected( adr_bconv, BCONV_MOVESRC ) )   wext->p->manage_src = MS_MOVESRC ;
    read_text( adr_bconv, BCONV_MOVEDEST, wext->p->dst_movepath ) ;
    if ( selected( adr_bconv, BCONV_ERASEDST ) ) wext->p->manage_dst = MD_ERASEDST ;
    else                                         wext->p->manage_dst = MD_CANCELOPE ;
    /* Extensions for image resizing feature if available (not for low res) */
    if ( adr_bconv->ob_tail >= BCONV_RW )
    {
      wext->p->resize = 0 ;
      wext->p->rwidth = wext->p->rheight = 0 ;
      if ( selected( adr_bconv, BCONV_RESIZE ) )
      {
        char buffer[10] ;

        wext->p->resize = 1 ;
        read_text( adr_bconv, BCONV_RW,  buffer ) ;
        wext->p->rwidth = atoi( buffer ) ;
        read_text( adr_bconv, BCONV_RH,  buffer ) ;
        wext->p->rheight = atoi( buffer ) ;
        LoggingDo(LL_INFO, "Batch Conversion: Image resize if > %d x %d", wext->p->rwidth, wext->p->rheight) ;
      }
    }
  }

  return code ;
}

static int OnCloseDialogBConv(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  WDLG_BCONV* wdlg = wnd->Extension ;

  Xfree( wdlg->buffer ) ;
  popup_kill( wdlg->popup_pb, 2 ) ;
  popup_kill( wdlg->popup_fmt, 6 ) ;

  return( GWCloseDlg( w ) ) ;
}

int FBConv(BCONV_PARAMS *p)
{
  GEM_WINDOW       *dlg ;
  WEXTENSION_BCONV wext ;
  DLGDATA          dlg_data ;
  int              code ;

  wext.p = p ;
  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_BATCHCONV ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.ExtensionSize  = sizeof(WDLG_BCONV) ;
  dlg_data.OnInitDialog   = OnInitDialogBConv ;
  dlg_data.OnObjectNotify = OnObjectNotifyBConv ;
  dlg_data.OnCloseDialog  = OnCloseDialogBConv ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  return( code == IDOK ) ;
}
