/***********************/
/*----- FULLSCR.C -----*/
/***********************/
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

#include     "..\tools\stdprog.h"
#include     "..\tools\stdinput.h"
#include     "..\tools\xgem.h"
#include     "..\tools\gwindows.h"
#include   "..\tools\img_io.h"
#include "..\tools\rasterop.h"
#include "..\tools\rzoom.h"
#include "..\tools\image_io.h"

#include     "defs.h"
#include  "touches.h"
#include  "actions.h"
#include "visionio.h"


void pleine_page(GEM_WINDOW* gwnd)
{
  VXIMAGE *vimage ;
  EVENT evnt ;
  int   xyarray[8] ;
  int   largeur, hauteur ;
  int   posx, posy ;
  int   which ;
  int   unit ;
  char  xscroll, yscroll ;
  char  fin = 0 ;
  char  cp ;
  
  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  memzero( &evnt, sizeof(EVENT) ) ;
  evnt.ev_mflags    = MU_KEYBD | MU_BUTTON | MU_TIMER ;
  evnt.ev_mbclicks  = 258 ; evnt.ev_bmask = 3 ;
 
  cls_gemscreen() ;
  wind_update(BEG_UPDATE) ;
  cp = config.color_protect ;
  config.color_protect = 0 ;
  set_imgpalette( vimage ) ;
  v_hide_c(handle) ;
  
  largeur = vimage->inf_img.mfdb.fd_w ;
  hauteur = vimage->inf_img.mfdb.fd_h ;
  posx    = (screen.fd_w-largeur)>>1 ;
  if (posx < 0) posx = 0 ;
  posy = (screen.fd_h-hauteur)>>1 ;
  if (posy < 0) posy = 0 ;
  xscroll = 0 ;
  yscroll = 0 ;
  
  if (posx == 0)
  {
    xyarray[0] = 0 ;
    xyarray[2] = Xmax ;
    xscroll    = 1 ;
  }
  else
  {
    xyarray[0] = 0 ;
    xyarray[2] = largeur-1 ;
  }
  
  if (posy == 0)
  {
    xyarray[1] = 0 ;
    xyarray[3] = Ymax ;
    yscroll    = 1 ;
  }
  else
  {
    xyarray[1] = 0 ;
    xyarray[3] = hauteur-1 ;
  }
  
  xyarray[4] = posx ; xyarray[5] = posy ;
  xyarray[6] = posx+xyarray[2]-xyarray[0] ;
  xyarray[7] = posy+xyarray[3]-xyarray[1]  ;
  vro_cpyfm(handle, S_ONLY, xyarray, &vimage->inf_img.mfdb, &screen) ;

  do
  {
    which = EvntMulti( &evnt ) ;
    if ( which & MU_KEYBD )
    {
      unit = 4 ;
	  switch( evnt.ev_mkreturn )
	  {
      case CURSOR_LSUP:
      case CURSOR_RSUP: unit = 32 ;
	    case CURSOR_UP : if ( yscroll )
	                     {
	                       xyarray[1] -= unit ;
	                       xyarray[3] -= unit ;
	                       if (xyarray[1] < 0)
	                       {
	                         xyarray[1] = 0 ;
	                         xyarray[3] = Ymax ;
	                       }
                           vro_cpyfm(handle, S_ONLY, xyarray, &vimage->inf_img.mfdb, &screen) ;
                         }
	                     break ;

      case CURSOR_LSDN:
      case CURSOR_RSDN: unit = 32 ;
	    case CURSOR_DN : if (yscroll)
	                     {
	                       xyarray[1] += unit ;
	                       xyarray[3] += unit ;
	                       if (xyarray[3] > hauteur-1)
	                       {
	                         xyarray[3] = hauteur-1 ;
	                         xyarray[1] = hauteur-Ymax-1 ;
	                       }
                           vro_cpyfm(handle, S_ONLY, xyarray, &vimage->inf_img.mfdb, &screen) ;
                         }
	                     break ;

      case CURSOR_LSLT:
      case CURSOR_RSLT: unit = 32 ;
	    case CURSOR_LT : if (xscroll)
	                     {
	                       xyarray[0] -= unit ;
	                       xyarray[2] -= unit ;
	                       if (xyarray[0] < 0)
	                       {
	                         xyarray[0] = 0 ;
	                         xyarray[2] = Xmax ;
	                       }
                           vro_cpyfm(handle, S_ONLY, xyarray, &vimage->inf_img.mfdb, &screen) ;
                         }
	                     break ;

      case CURSOR_LSRT:
      case CURSOR_RSRT: unit = 32 ;
	    case CURSOR_RT : if (xscroll)
	                     {
	                       xyarray[0] += unit ;
	                       xyarray[2] += unit ;
	                       if (xyarray[2] > largeur-1)
	                       {
	                         xyarray[2] = largeur-1 ;
	                         xyarray[0] = largeur-Xmax-1 ;
	                       }
                           vro_cpyfm(handle, S_ONLY, xyarray, &vimage->inf_img.mfdb, &screen) ;
                         }
	                     break ;

        case QUITTER :   fin = 1 ;
                         break ;

	    default        : fin = 1 ;
	                     break ;
      }
    }
    if ( which & MU_BUTTON ) fin = 1 ;
  }
  while ( !fin ) ;

  restore_gemscreen(GemApp.Menu) ;
  v_show_c(handle, 1) ;
  config.color_protect = cp ;
  set_imgpalette( vimage ) ;
  wind_update(END_UPDATE) ;
}

void traite_pleinecran(GEM_WINDOW* gwnd)
{
  GEM_WINDOW* wprog ;
  VXIMAGE    *vimage ;
  MFDB       out ;
  float      x_level, y_level, level ;
  int        xy[8] ;
  int        cp ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  mouse_busy() ;
  x_level = (float)(Xmax-2)/(float)vimage->inf_img.mfdb.fd_w ;
  y_level = (float)(Ymax-2)/(float)vimage->inf_img.mfdb.fd_h ;
  if (x_level > y_level) level = y_level ;
  else                   level = x_level ;
  wprog = DisplayStdProg(MsgTxtGetMsg(hMsg, MSG_CALCREDUC) , "", "", CLOSER ) ;
  out.fd_addr = NULL ;
  out.fd_w    = (int) ( 0.5 + (float)vimage->inf_img.mfdb.fd_w * level ) ;
  out.fd_h    = (int) ( 0.5 + (float)vimage->inf_img.mfdb.fd_h * level ) ;
/*  if (raster_pczoom(&vimage->inf_img.mfdb, &out, level, level, wprog))*/
  if ( RasterZoom( &vimage->inf_img.mfdb, &out, wprog ) )
  {
    GWDestroyWindow( wprog ) ;
    form_error(8) ;
    mouse_restore() ;
    return ;
  }
  GWDestroyWindow( wprog ) ;

  mouse_restore() ;

  cp = config.color_protect ;
  config.color_protect = 0 ;
  set_imgpalette( vimage ) ;
  cls_gemscreen() ;

  clear_buffers( MU_KEYBD | MU_BUTTON ) ;
  xy[0] = 0 ;
  xy[1] = 0 ;
  xy[2] = out.fd_w-1 ;
  xy[3] = out.fd_h-1 ;
  xy[4] = (Xmax-xy[2])>>1 ;
  xy[5] = (Ymax-xy[3])>>1 ;
  xy[6] = xy[4]+xy[2] ;
  xy[7] = xy[5]+xy[3] ;
  v_hide_c(handle) ;

  wind_update(BEG_UPDATE) ;
  vro_cpyfm(handle, S_ONLY, xy, &out, &screen) ;
  wait_for( MU_KEYBD | MU_BUTTON ) ;
  wind_update(END_UPDATE) ;

  Xfree(out.fd_addr) ;
  restore_gemscreen(GemApp.Menu) ;
  v_show_c(handle, 1) ;
  config.color_protect = cp ;
  set_imgpalette( vimage ) ;
}
