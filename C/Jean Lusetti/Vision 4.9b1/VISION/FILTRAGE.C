/***********************************************/
/*                  FILTRAGE.C                 */
/* Application d'un filtre de convolution      */
/* Sur une image ou une s‚lection              */
/***********************************************/
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>

#include     "..\tools\stdprog.h"
#include     "..\tools\stdinput.h"
#include     "..\tools\xgem.h"
#include   "..\tools\convol.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"

#include     "defs.h"
#include     "undo.h"
#include   "gstenv.h"
#include  "actions.h"
#include "visionio.h"
#include "forms\ftcwheel.h"
#include "forms\ffilter.h"



void traite_convolution(GEM_WINDOW* gwnd)
{
  GEM_WINDOW*        wprog ;
  VXIMAGE*           vimage ;
  CONVOLUTION_FILTRE filtre ;
  MFDB               virtuel, out ;
  int                xy[8] ;
  int                ret ;
  int                go_again ;
  int                choix ;
  int                x1, y1, x2, y2 ;
  int                undo_return ;
  char               DSPfile[200] ;
  char               handlelock ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE*) gwnd->Extension ;

  choix = choose_filter( &filtre, gwnd ) ;
  if (choix == 0) return ;
  if (choix == 1)
  {
    CopyMFDB( &virtuel, &vimage->inf_img.mfdb ) ;
    undo_return = undo_put( gwnd, 0, 0, vimage->inf_img.mfdb.fd_w-1, vimage->inf_img.mfdb.fd_h-1, UFILTRE, NULL ) ;
  }
  else
  {
    if (config.flags & FLG_MASKOUT)
    {
      x1 = y1 = 0 ;
      x2 = vimage->inf_img.mfdb.fd_w-1 ;
      y2 = vimage->inf_img.mfdb.fd_h-1 ;
      CopyMFDB( &virtuel, &vimage->inf_img.mfdb ) ;
    }
    else
    {
      x1 = vclip.x1-filtre.w ;
      x2 = vclip.x2+filtre.w+16 ;
      y1 = vclip.y1-filtre.h ;
      y2 = vclip.y2+filtre.h ;
      if (x1 < 0) x1 = 0 ;
      if (y1 < 0) y1 = 0 ;
      if (x2 > vimage->inf_img.mfdb.fd_w-1) x2 = vimage->inf_img.mfdb.fd_w-1 ;
      if (y2 > vimage->inf_img.mfdb.fd_h-1) y2 = vimage->inf_img.mfdb.fd_h-1 ;
  
      virtuel.fd_w       = 1+x2-x1 ;
      virtuel.fd_h       = 1+y2-y1 ;
      virtuel.fd_wdwidth = w2wdwidth( virtuel.fd_w ) ;
      virtuel.fd_nplanes = vimage->inf_img.mfdb.fd_nplanes ;
      virtuel.fd_stand   = vimage->inf_img.mfdb.fd_stand ;
      virtuel.fd_addr    = img_alloc(virtuel.fd_w, virtuel.fd_h, virtuel.fd_nplanes) ;
      if (virtuel.fd_addr == NULL)
      {
        form_error(8) ;
        return ;
      }

      xy[0] = x1 ; xy[1] = y1 ;
      xy[2] = x2 ; xy[3] = y2 ;
      xy[4] = xy[5] = 0 ;
      xy[6] = virtuel.fd_w-1 ; xy[7] = virtuel.fd_h-1 ;
      vro_cpyfm(handle, S_ONLY, xy, &vimage->inf_img.mfdb, &virtuel) ;
    }
    undo_return = undo_put( gwnd, x1, y1, x2, y2, UFILTRE, NULL ) ;
  }

  mouse_busy() ;
  strcpy(DSPfile, config.path_lod) ;
  strcat(DSPfile, "\\CONVOL.LOD") ;
  handlelock = DspInfo.WhatToDoIfLocked ;
  do
  {
    wprog = DisplayStdProg( MsgTxtGetMsg(hMsg, MSG_FILTRE) , "", "", CLOSER ) ;
    ret = convolution(&virtuel, &vimage->inf_img, &out, DSPfile, &filtre, wprog) ;
    GWDestroyWindow( wprog ) ;
    go_again = 0 ;
    if ((ret == CONVOL_DSPBUSY) && (config.dsphandlelock == DSPLOCK_WARN))
    {
      int rep ;

      rep = form_interrogation(1, MsgTxtGetMsg(hMsg, MSG_DSPLOCK) ) ;
      switch(rep)
      {
        case 1 : /* Forcer */
                 DspInfo.WhatToDoIfLocked = DSPLOCK_FORCE ;
                 go_again = 1 ;
                 break ;
        case 2 : /* Ignorer */
                 DspInfo.WhatToDoIfLocked = DSPLOCK_IGNORE ;
                 go_again = 1 ;
                 break ;
        case 3 : /* Annuler */
                 break ;
      }
    }
  }
  while (go_again) ;
  DspInfo.WhatToDoIfLocked = handlelock ;

  if (ret == 0)
  {
    if (choix == 2)
    {
      xy[0] = filtre.w ;
      xy[1] = filtre.h ;
      xy[2] = vclip.x2-vclip.x1-filtre.w ;
      xy[3] = vclip.y2-vclip.y1-filtre.h ;
      xy[4] = vclip.x1 ;
      xy[5] = vclip.y1 ;
      xy[6] = vclip.x2-filtre.w ;
      xy[7] = vclip.y2-filtre.h ;
      if (vclip.form == BLOC_RECTANGLE)
        vro_cpyfm(handle, S_ONLY, xy, &out, &vimage->inf_img.mfdb) ;
      else
      {
        int xyarray[8] ;

        memcpy(xyarray, xy, 8*sizeof(int)) ;
        if (config.flags & FLG_MASKOUT)
        {
          xy[0] = xy[1] = 0 ;
          xy[2] = clipboard.mask.fd_w-1 ;
          xy[3] = clipboard.mask.fd_h-1 ;
          xy[4] = vclip.x1 ;
          xy[5] = vclip.y1 ;
          xy[6] = xy[4]+clipboard.mask.fd_w-1 ;
          xy[7] = xy[5]+clipboard.mask.fd_h-1 ;
          vro_cpyfm(handle, S_AND_D, xy, &clipboard.mask, &vimage->inf_img.mfdb) ;
          vro_cpyfm(handle, NOTS_AND_D, xy, &clipboard.mask, &out) ;
          memcpy(xy, &xy[4], 4*sizeof(int)) ;
          vro_cpyfm(handle, S_OR_D, xy, &vimage->inf_img.mfdb, &out) ;
          Xfree(vimage->inf_img.mfdb.fd_addr) ;
          CopyMFDB( &vimage->inf_img.mfdb, &out ) ;
        }
        else
        {
          vro_cpyfm(handle, NOTS_AND_D, xyarray, &clipboard.mask, &vimage->inf_img.mfdb) ;
          xyarray[4] = filtre.w ;
          xyarray[5] = filtre.h ;
          xyarray[6] = filtre.w+xy[2]-xy[0] ;
          xyarray[7] = filtre.h+xy[3]-xy[1] ;
          vro_cpyfm(handle, S_AND_D, xyarray, &clipboard.mask, &out) ;
          vro_cpyfm(handle, S_OR_D, xy, &out, &vimage->inf_img.mfdb) ;
        }
      }
      if (!(config.flags & FLG_MASKOUT))
      {
        Xfree(virtuel.fd_addr) ;
        Xfree(out.fd_addr) ;
      }
    }
    else
    {
      Xfree(vimage->inf_img.mfdb.fd_addr) ;
      vimage->inf_img.mfdb.fd_addr = out.fd_addr ;
    }
    set_modif( gwnd ) ;
    if (vimage->zoom_level != 1)
      traite_loupe( gwnd, vimage->zoom_level, -1, -1 ) ;
    GWRePaint( gwnd ) ;
  }
  else
  {
    switch(ret)
    {
      case CONVOL_MEMORY        : form_error(8) ;
                                  if (undo_return == 0) free_lastundo( gwnd ) ;
                                  break ;
      case CONVOL_BADFILTERFILE : form_stop( MsgTxtGetMsg(hMsg, MSG_BADFILTER) ) ;
                                  break ;
      case CONVOL_BADNBCOLORS   : form_stop( MsgTxtGetMsg(hMsg, MSG_FNBCOLORS) ) ;
                                  break ;
      case CONVOL_BADDSPFILE    : form_stop( MsgTxtGetMsg(hMsg, MSG_BADLOD) ) ;
                                  break ;
      case CONVOL_DSPBUSY       : form_stop( MsgTxtGetMsg(hMsg, MSG_DSPISLOCKED) ) ;
                                  break ;
      case CONVOL_LODNOTEXIST   : form_stop( MsgTxtGetMsg(hMsg, MSG_DSPNOLOD) ) ;
                                  break ;
    }
  }
  mouse_restore() ;

  if (filtre.data != NULL) Xfree(filtre.data) ;
}
