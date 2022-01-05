/******************************************/
/* Module de gestion du trac‚ des figures */
/* (cercles, lignes, remplissage ...)     */
/******************************************/
#include   <math.h>
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

#include     "..\tools\xgem.h"
#include  "..\tools\stdprog.h"
#include "..\tools\stdinput.h"
#include "..\tools\gwindows.h"
#include "..\tools\rasterop.h"
#include "..\tools\logging.h"

#include     "defs.h"
#include     "undo.h"
#include   "rtzoom.h"
#include   "gstenv.h"
#include  "actions.h"
#include "visionio.h"
#include "vtoolbar.h"
#include "forms\finputte.h"
#include "forms\ftableau.h"

typedef struct _TOOL_OBJECT_DATA
{
  GEM_WINDOW* gwnd ;
  VXIMAGE*    vimage ;
  MOUSE_DEF   save ;
  int         zoom_what ;
  int         x1, y1, x2, y2 ;
  int         xi, yi, wx, wy ;
  int         posx, posy ;
  int         xy[4] ;
  char        buf[100] ;
}
TOOL_OBJECT_DATA, *PTOOL_OBJECT_DATA ;


int check_color(VXIMAGE* vimage, int color)
{
  int err = 0 ;

  if ( !Truecolor )
    if ( ( 1 << vimage->inf_img.nplanes ) <= color )
    {
      form_stop(  MsgTxtGetMsg(hMsg, MSG_COLORERROR)  ) ;
      err = 1 ;
    }

  return err ;
}

void action_gomme(GEM_WINDOW* gwnd)
{
  VXIMAGE* vimage ;
  OBJECT*  adr_pgomme ;
  BITBLK*  image ;
  MFDB     motif ;
  MFDB     temp ;
  void*    adr_data ;
  int     xy[8] ;
  int     color_index[] = {1, 0} ;
  int     cxy[4] ;
  int     l ;
  int     xmin, ymin, xmax, ymax ;
  int     dummy ;
  int     xi, yi, wx, wy ;
  int     posx, posy ;
  int     wmode ;
  int     xm, ym, bm ;
  int     lxm = 0, lym = 0 ;
  int     zoom_what ;
  char    buf[100] ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE*) gwnd->Extension ;
  if ( vimage->zoom_level != 1 )
  {
    form_stop( MsgTxtGetMsg(hMsg, MSG_NOTOOLZ) ) ;
    return ;
  }

  Xrsrc_gaddr( R_TREE, GOMMES, &adr_pgomme ) ;
  image         = adr_pgomme[config.sgomme+GOMME_1].ob_spec.bitblk ;
  adr_data      = (void*) image->bi_pdata ;
  motif.fd_addr = img_alloc( 16, 16, screen.fd_nplanes ) ;
  if ( motif.fd_addr == NULL )
  {
    form_error(8) ;
    return ;
  }
  motif.fd_w       = 16 ;
  motif.fd_h       = 16 ;
  motif.fd_nplanes = screen.fd_nplanes ;
  motif.fd_wdwidth = motif.fd_w >> 4 ;
  CopyMFDB( &temp, &motif ) ;
  temp.fd_addr    = adr_data ;
  temp.fd_nplanes = 1 ;
  xy[0] = 0 ; xy[1] = 0 ; xy[2] = motif.fd_w-1 ; xy[3] = motif.fd_h-1 ;
  xy[4] = 0 ; xy[5] = 0 ; xy[6] = motif.fd_w-1 ; xy[7] = motif.fd_h-1 ;
  if ( Truecolor )
  {
    img_raz( &motif ) ; /* So eraser is a square */
    wmode = S_ONLY ;
  }
  else
  {
    vrt_cpyfm(handle, MD_REPLACE, xy, &temp, &motif, color_index) ;
    wmode = NOTS_AND_D ;
  }
  l     = 3 + ( (config.sgomme + GOMME_1 - 3) & 0x03 ) ;
  xy[0] = 8-l ;         xy[1] = xy[0] ;
  xy[2] = xy[0]+2*l-1 ; xy[3] = xy[0]+2*l-1 ;
  l     = 2*l-1 ;

  graf_mkstate(&xm, &ym, &bm, &dummy) ;
  xmin = xm-32 ; ymin = ym-32 ;
  xmax = xm+32 ; ymax = ym+32 ;
  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy ) ;
  cxy[0] = xi ;      cxy[1] = yi ;
  cxy[2] = xi+wx-1 ; cxy[3] = yi+wy-1 ;
  vs_clip(handle, 1, cxy) ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;
  vswr_mode(handle, mode_vswr) ;
  vsf_color(handle, pencil.color) ;
  vsf_interior(handle, FIS_SOLID) ;

  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;
  for(;;)
  {
    graf_mkstate(&xm, &ym, &bm, &dummy) ;
    if (bm == 0) break ;
    if ( !config.souris_viseur )
    {
      xy[4] = xm ;
      xy[5] = ym ;
      xy[6] = xm+l ;
      xy[7] = ym+l ;
    }
    else
    {
      xy[4] = xm-(l>>1) ;
      xy[5] = ym-(l>>1) ;
      xy[6] = xm+(l>>1) ;
      xy[7] = ym+(l>>1) ;
    }
    
    if ( (xm >= xi-16) && (ym >= yi-16) && (xm < xi+wx-1) && (ym < yi+wy-1) )
    {
      if (xy[6] >= xi+wx) xy[6] = xi+wx-1 ;
      if (xy[7] >= yi+wy) xy[7] = yi+wy-1 ;
      if (xy[4] < xmin) xmin = xy[4] ;
      if (xy[5] < ymin) ymin = xy[5] ;
      if (xy[6] > xmax) xmax = xy[6] ;
      if (xy[7] > ymax) ymax = xy[7] ;
      GWHideCursor( 0 ) ;
      vro_cpyfm(handle, wmode, xy, &motif, &screen) ;
      GWShowCursor( 0 ) ;
    }
    if ( (lxm != xm) || (lym != ym) )
    {
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( xm, ym, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
      lxm = xm ;
      lym = ym ;
    }
    sprintf( buf, MsgTxtGetMsg(hMsg, MSG_XY) , posx+xm-xi, posy+ym-yi ) ;
    GWSetWindowInfo( gwnd, buf ) ;
  }

  Xfree(motif.fd_addr) ;
  GWSetWindowInfo( gwnd, "" ) ;
  xmin -= 16 ; ymin -= 16 ;
  xmax += 16 ; ymax += 16 ;
  if (xmin < xi) xmin = xi ;
  if (ymin < yi) ymin = yi ;
  if (xmax > xi+wx-1) xmax = xi+wx-1 ;
  if (ymax > yi+wy-1) ymax = yi+wy-1 ;

  undo_put( gwnd, posx+xmin-xi, posy+ymin-yi, posx+xmax-xi, posy+ymax-yi, UGOMME, NULL ) ;
  if ((xmin != 20000) && (ymin != 20000))
    update_raster( gwnd, xmin, ymin, xmax, ymax ) ;
  set_modif( gwnd ) ;
  vs_clip(handle, 0, cxy) ;
}

void traite_point(GEM_WINDOW* gwnd)
{
  VXIMAGE* vimage ;
  int      xy[4] ;
  int      x, y, w, h ;
  int      xm, ym, bm, dummy ;
  int      xmin, ymin, xmax, ymax ;
  int      xi, yi, wx, wy ;
  int      posx, posy ;
  int      zoom_level ;
  int      lxm = 0, lym = 0 ;
  int      zoom_what ;
  char     buf[100] ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE*) gwnd->Extension ;
  if ( check_color( vimage, mtype.color ) ) return ;

  gwnd->GetWorkXYWH( gwnd, &x, &y, &w, &h ) ;
  xy[0] = x ; xy[1] = y ;
  xy[2] = x+w-1 ; xy[3] = y+h-1 ;
  vs_clip(handle, 1, xy) ;
  zoom_level = vimage->zoom_level ;

  set_markertype(&mtype) ;
  set_filltype(&ftype) ;
  if (zoom_level != 1)
    vsf_interior(handle, FIS_SOLID) ;    
  vswr_mode(handle, mode_vswr) ;
  xmin = ymin = 20000 ;
  xmax = ymax = 0 ;
  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy ) ;

  wx   = wx/zoom_level ;
  wy   = wy/zoom_level ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;
  
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;
  for(;;)
  {
    graf_mkstate(&xm, &ym, &bm, &dummy) ;
    if (bm != 1) break ;
    if ((xm >= x) && (ym >= y) && (xm < x+w) && (ym < y+h))
    {
      if (xm-32 < xmin) xmin = xm-32 ;
      if (xm+32 > xmax) xmax = xm+32 ;
      if (ym-32 < ymin) ymin = ym-32 ;
      if (ym+32 > ymax) ymax = ym+32 ;
      GWHideCursor( 0 ) ;
      if (zoom_level == 1) pset(xm, ym) ;
      else
      {
        /* Ajuster le point … affecter */
        xy[0] = (xm-xi)/zoom_level ;
        xy[1] = (ym-yi)/zoom_level ;
        xy[0] = xi+zoom_level*xy[0] ;
        xy[1] = yi+zoom_level*xy[1] ;
        xy[2] = xy[0]+zoom_level-1 ;
        xy[3] = xy[1]+zoom_level-1 ;
        vr_recfl(handle, xy) ;
      }
      GWShowCursor( 0 ) ;
    }
    if ( (lxm != xm) || (lym != ym) )
    {
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, xy) ;
        rtzoom_display( xm, ym, zoom_what ) ;
        vs_clip(handle, 1, xy) ;
      }
      lxm = xm ;
      lym = ym ;
    }
    sprintf( buf, MsgTxtGetMsg(hMsg, MSG_XY) , posx+(xm-xi)/zoom_level, posy+(ym-yi)/zoom_level ) ;
    GWSetWindowInfo( gwnd, buf ) ;
  }
  vs_clip(handle, 0, xy) ;

  GWSetWindowInfo( gwnd, "" ) ;
  if ( (xmin != 20000) && (ymin != 20000) )
  {
    if (xmin < x)     xmin = x ;
    if (ymin < y)     ymin = y ;
    if (xmax > x+w-1) xmax = x+w-1 ;
    if (ymax > y+h-1) ymax = y+h-1 ;
    undo_put( gwnd, posx, posy, posx+wx-1, posy+wy-1, UPOINT, NULL ) ;
    if ( vimage->zoom_level != 1 ) update_raster( gwnd, x, y, x+w-1, y+h-1 ) ;
    else                           update_raster( gwnd, xmin, ymin, xmax, ymax ) ;
  }
  set_modif( gwnd ) ;
}

static int ppmf(int x, int w)
{
  return (int) (0.5+(float)x/1000.0*(float)w) ;
}

void traite_trace(GEM_WINDOW* gwnd)
{
  VXIMAGE* vimage ;
  int      xy[4] ;
  int      xm1, ym1, xm2, ym2, bm, dummy ;
  int      xmin, ymin, xmax, ymax ;
  int      xi, yi, wx, wy ;
  int      posx, posy ;
  int      lxm = 0, lym = 0 ;
  int      zoom_what ;
  char     buf[100] ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE*) gwnd->Extension ;

  if ( vimage->zoom_level != 1 )
  {
    form_stop( MsgTxtGetMsg(hMsg, MSG_NOTOOLZ) ) ;
    return ;
  }
  if ( check_color( vimage, mtype.color ) ) return ;

  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy) ;
  xy[0] = xi ;      xy[1] = yi ;
  xy[2] = xi+wx-1 ; xy[3] = yi+wy-1 ;
  vs_clip(handle, 1, xy) ;
  set_linetype(&ltype) ;
  vsl_ends(handle, SQUARE, SQUARE) ;
  vswr_mode(handle, mode_vswr) ;
  xmin = ymin = 20000 ;
  xmax = ymax = 0 ;
  GWGetHSlider( gwnd, &posx ) ;
  GWGetVSlider( gwnd, &posy ) ;
  posx = ppmf( posx, vimage->inf_img.mfdb.fd_w-wx ) ;
  posy = ppmf( posy, vimage->inf_img.mfdb.fd_h-wy ) ;

  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;
  graf_mkstate(&xm1, &ym1, &bm, &dummy) ;
  for(;;)
  {
    graf_mkstate(&xm2, &ym2, &bm, &dummy) ;
    if (bm != 1) break ;
    if ((xm2 >= xi) && (ym2 >= yi) && (xm2 < xi+wx) && (ym2 < yi+wy))
    {
      if (xm2-32 < xmin) xmin = xm2-32 ;
      if (xm2+32 > xmax) xmax = xm2+32 ;
      if (ym2-32 < ymin) ymin = ym2-32 ;
      if (ym2+32 > ymax) ymax = ym2+32 ;
      GWHideCursor( 0 ) ;
      line(xm1, ym1, xm2, ym2) ;
      GWShowCursor( 0 ) ;
      xm1 = xm2 ; ym1 = ym2 ;
    }
    if ( ( lxm != xm2 ) || ( lym != ym2 ) )
    {
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, xy) ;
        rtzoom_display( xm2, ym2, zoom_what ) ;
        vs_clip(handle, 1, xy) ;
      }
      lxm = xm2 ;
      lym = ym2 ;
    }
    sprintf( buf, MsgTxtGetMsg(hMsg, MSG_XY) , posx+xm2-xi, posy+ym2-yi ) ;
    GWSetWindowInfo( gwnd, buf ) ;
    if ( traite_thickness( GWGetKey() ) ) set_linetype(&ltype) ;
  }
  vs_clip(handle, 0, xy) ;

  GWSetWindowInfo( gwnd, "" ) ;
  if ((xmin != 20000) && (ymin != 20000))
  {
    if (xmin < xi)     xmin = xi ;
    if (ymin < yi)     ymin = yi ;
    if (xmax > xi+wx-1) xmax = xi+wx-1 ;
    if (ymax > yi+wy-1) ymax = yi+wy-1 ;
    undo_put( gwnd, posx+xmin-xi, posy+ymin-yi, posx+xmax-xi-1, posy+ymax-yi-1, UTRACE, NULL ) ;
    update_raster( gwnd, xmin, ymin, xmax, ymax ) ;
  }
  set_modif( gwnd ) ;
}

void traite_peinture(GEM_WINDOW* gwnd)
{
  VXIMAGE* vimage ;
  int      x, y, w, h ;
  int      mx, my, dummy ;
  int      xy[4] ;
  int      xi, yi, wx, wy ;
  int      posx, posy ;
  int      zoom_level ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE*) gwnd->Extension ;
  if ( check_color( vimage, mtype.color ) ) return ;

  if ( (ftype.sindex != 8) && (vimage->zoom_level != 1) )
  {
    form_stop( MsgTxtGetMsg(hMsg, MSG_ZOOMFILL) ) ;
    return ;
  }

  vswr_mode(handle, mode_vswr) ;
  gwnd->GetWorkXYWH( gwnd, &x, &y, &w, &h) ;
  GWSetWindowInfo( gwnd, MsgTxtGetMsg(hMsg, MSG_FILL)  ) ;
  zoom_level = vimage->zoom_level ;
  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy) ;
  wx   = wx/zoom_level ;
  wy   = wy/zoom_level ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;
  undo_put( gwnd, posx, posy, posx+wx-1, posy+wy-1, UPEINT, NULL ) ;
  xy[0] = x ;     xy[1] = y ;
  xy[2] = x+w-1 ; xy[3] = y+h-1 ;
  vs_clip(handle, 1, xy) ;
  set_filltype(&ftype) ;
  GWHideCursor( 0 ) ;
  graf_mkstate( &mx, &my, &dummy, &dummy ) ;
  v_contourfill(handle, mx, my, -1) ; /* -1 makes VISION crash should be fixed in Emutos 0.9.0 but not... */
  GWShowCursor( 0 ) ;
  vs_clip(handle, 0, xy) ;
  update_raster( gwnd, x, y ,x+w-1, y+h-1 ) ;
  set_modif( gwnd ) ;
  GWSetWindowInfo( gwnd, "" ) ;
}

void traite_texte(GEM_WINDOW* gwnd)
{
  VXIMAGE *vimage ;
  LINE_TYPE ligne ;
  MOUSE_DEF save ;
  int       coord[8] ;
  int       cxy[4] ;
  int       xy[8] ;
  int       nxy[8] ;
  int       posx, posy ;
  int       x, y, w, h ;
  int       xm1, ym1, xm2, ym2 ;
  int       bm, dummy ;
  int       i, j ;
  int       bouton ;
  int       offx, offy ;
  int       len ;
  int       lxm = 0, lym = 0 ;
  int       zoom_what ;
  char      cflags[4] ;
  char      buf[100] ;
  char      flag[1+NB_TOOLS] ;
  char      texts[NB_TEXTS][100] ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;
  if (vimage->zoom_level != 1)
  {
    form_stop( MsgTxtGetMsg(hMsg, MSG_NOTOOLZ) ) ;
    return ;
  }
  if ( check_color( vimage, mtype.color ) ) return ;

  bouton = input_text( texts ) ;
  if ( bouton != IDOK ) return ;

  gwnd->GetWorkXYWH( gwnd, &x, &y, &w, &h ) ;
  GWRePaint( gwnd ) ;

  memset(flag, 1, 1+NB_TOOLS) ;
/*  update_tools(mesg, flag) ;*/
  VToolBarUpdate( flag ) ;
  set_texttype(&ttype) ;
  memzero(cflags, 4) ;
  len = 0 ;
  for (i = 0; i < 4; i++)
  {
    if ( texts[i][0] ) cflags[i] = 1 ;
    if (strlen(texts[i]) > len)
    {
      vqt_extent(handle, texts[i], coord) ;
      len = (int) strlen(texts[i]) ;
    }
  }

  offx = coord[6]-coord[0] ;
  offy = coord[7]-coord[1] ;

  wind_update(BEG_UPDATE) ;
  CopyMouseDef( &save, &mouse ) ;
  if (!config.souris_viseur)
  {
    mouse.gr_monumber = FLAT_HAND ;
    set_mform(&mouse) ;
  }
  ligne.style   = DOT ;
  ligne.color   = 1 ;
  ligne.st_kind = SQUARE ;
  ligne.ed_kind = SQUARE ;
  ligne.width   = 1 ;
  set_linetype(&ligne) ;
  vswr_mode(handle, MD_XOR) ;
  cxy[0] = x ;     cxy[1] = y ;
  cxy[2] = x+w-1 ; cxy[3] = y+h-1 ;
  vs_clip(handle, 1, cxy) ;
  graf_mkstate(&xm1, &ym1, &bm, &dummy) ;
  for (i = 0; i < 4; i++)
  {
    j       = 2*i ;
    xy[j]   = xm1+coord[j]-coord[0] ; ;
    xy[1+j] = ym1+coord[1+j]-coord[1] ;
  }

  GWHideCursor( 0 ) ;
  for (i = 0; i < 4; i++)
  {
    if (cflags[i])
    {
      nxy[0] = xy[0]+i*offx ;
      nxy[1] = xy[1]+i*offy ;
      nxy[2] = xy[2]+i*offx ;
      nxy[3] = xy[3]+i*offy ;
      nxy[4] = xy[4]+i*offx ;
      nxy[5] = xy[5]+i*offy ;
      nxy[6] = xy[6]+i*offx ;
      nxy[7] = xy[7]+i*offy ;
      v_pline(handle, 4, nxy) ;
    }
  }
  GWShowCursor( 0 ) ;

  posx = vimage->x1 ;
  posy = vimage->y1 ;
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;
  for(;;)
  {
    graf_mkstate(&xm2, &ym2, &bm, &dummy) ;
    if (bm != 0) break ;
    if ((xm2 != xm1) || (ym2 != ym1))
    {
      GWHideCursor( 0 ) ;
      for (i = 0; i < 4; i++)
      {
        if (cflags[i])
        {
          nxy[0] = xy[0]+i*offx ;
          nxy[1] = xy[1]+i*offy ;
          nxy[2] = xy[2]+i*offx ;
          nxy[3] = xy[3]+i*offy ;
          nxy[4] = xy[4]+i*offx ;
          nxy[5] = xy[5]+i*offy ;
          nxy[6] = xy[6]+i*offx ;
          nxy[7] = xy[7]+i*offy ;
          v_pline(handle, 4, nxy) ;
        }
      }

      for (i = 0; i < 4; i++)
      {
        j       = 2*i ;
        xy[j]   = xm2+coord[j]-coord[0] ;
        xy[1+j] = ym2+coord[1+j]-coord[1] ;
      }

      for (i = 0; i < 4; i++)
      {
        if (cflags[i])
        {
          nxy[0] = xy[0]+i*offx ;
          nxy[1] = xy[1]+i*offy ;
          nxy[2] = xy[2]+i*offx ;
          nxy[3] = xy[3]+i*offy ;
          nxy[4] = xy[4]+i*offx ;
          nxy[5] = xy[5]+i*offy ;
          nxy[6] = xy[6]+i*offx ;
          nxy[7] = xy[7]+i*offy ;
          v_pline(handle, 4, nxy) ;
        }
      }

      GWShowCursor( 0 ) ;
      xm1 = xm2 ; ym1 = ym2;
    }
    if ( ( lxm != xm2 ) || ( lym != ym2 ) )
    {
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( xm2, ym2, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
      lxm = xm2 ;
      lym = ym2 ;
    }
    sprintf( buf, MsgTxtGetMsg(hMsg, MSG_XY), posx+xy[0]-x, posy+xy[1]-y ) ;
    GWSetWindowInfo( gwnd, buf ) ;
  }
  GWHideCursor( 0 ) ;
  for (i = 0; i < 4; i++)
  {
    if (cflags[i])
    {
      nxy[0] = xy[0]+i*offx ;
      nxy[1] = xy[1]+i*offy ;
      nxy[2] = xy[2]+i*offx ;
      nxy[3] = xy[3]+i*offy ;
      nxy[4] = xy[4]+i*offx ;
      nxy[5] = xy[5]+i*offy ;
      nxy[6] = xy[6]+i*offx ;
      nxy[7] = xy[7]+i*offy ;
      v_pline(handle, 4, nxy) ;
    }
  }
  GWShowCursor( 0 ) ;

  if ((xm1 < x+w-1) && (ym1 < y+h-1) && (bm != 2))
  {
    undo_put( gwnd, posx, posy, posx+w-1, posy+h-1, UTEXTE, NULL ) ;
    set_texttype(&ttype) ;
    vswr_mode(handle, mode_vswr) ;
    GWHideCursor( 0 ) ;
    xm1 += (offx>>1) ;
    ym1 += offy ;
    for (i = 0; i < 4; i++)
    {
      if ( cflags[i] ) v_gtext( handle, xm1+i*offx, ym1+i*offy, texts[i] ) ;
    }
    GWShowCursor( 0 ) ;
    update_raster( gwnd, x, y, x+w-1, y+h-1 ) ;
    set_modif( gwnd ) ;
  }
  vs_clip(handle, 0, cxy) ;
  CopyMouseDef( &mouse, &save ) ;
  set_mform(&save) ;
  wind_update(END_UPDATE) ;
  
  GWSetWindowInfo( gwnd, "" ) ;
  GWRePaint( gwnd ) ;

  memset(flag, 1, 1+NB_TOOLS) ;
/*  update_tools(mesg, flag) ;*/
  VToolBarUpdate( flag ) ;

  clear_buffers( MU_BUTTON ) ;
}

static void v_ellipsea(int handle, int fill, int x, int y, int wx, int wy)
{
  wx = abs(wx) ;
  wy = abs(wy) ;
  if ( fill ) v_ellipse( handle, x, y, wx, wy ) ;
  else        v_ellarc( handle, x, y, wx, wy, 0, 3600 ) ;
}

static void MoveToolObject(TOOL_OBJECT_DATA* tod)
{
  int xm1, ym1, xm2, ym2, bm, dummy ;
  int dxc, dyc ;

  CopyMouseDef( &tod->save, &mouse ) ;
  if ( !config.souris_viseur )
  {
    mouse.gr_monumber = FLAT_HAND ;
    set_mform( &mouse ) ;
  }
  graf_mkstate( &xm1, &ym1, &bm, &dummy ) ;
  GWHideCursor( 0 ) ;
  rectangle( tod->x1, tod->y1, tod->x2, tod->y2 ) ;
  GWShowCursor( 0 ) ;
  do
  {
    graf_mkstate( &xm2, &ym2, &bm, &dummy ) ;
    dummy = 0 ;
    dxc   = xm2-xm1 ;
    dyc   = ym2-ym1 ;
    if ( xm2 < tod->xi )
    {
      tod->posx -= 8 ;
      if ( tod->posx < 0 ) tod->posx = 0 ;
      dummy = 1 ;
    }
    if ( ym2 < tod->yi )
    {
      tod->posy -= 8 ;
      if ( tod->posy < 0 ) tod->posy = 0 ;
      dummy = 1 ;
    }
    if (xm2 > tod->xi+tod->wx-1)
    {
      tod->posx += 8 ;
      if ( tod->posx+tod->wx > tod->vimage->inf_img.mfdb.fd_w) tod->posx = tod->vimage->inf_img.mfdb.fd_w-tod->wx ;
      dummy = 1 ;
    }
    if ( ym2 > tod->yi+tod->wy-1 )
    {
      tod->posy += 8 ;
      if ( tod->posy+tod->wy > tod->vimage->inf_img.mfdb.fd_h) tod->posy = tod->vimage->inf_img.mfdb.fd_h-tod->wy ;
      dummy = 1 ;
    }
    if ( dummy )
    {
      int xyarray[8] ;

      xyarray[0] = tod->posx ;           xyarray[1] = tod->posy ;
      xyarray[2] = tod->posx+tod->wx-1 ; xyarray[3] = tod->posy+tod->wy-1 ;
      xyarray[4] = tod->xi ;             xyarray[5] = tod->yi ;
      xyarray[6] = tod->xi+tod->wx-1 ;   xyarray[7] = tod->yi+tod->wy-1 ;
      GWHideCursor( 0 ) ;
      vro_cpyfm( handle, S_ONLY, xyarray, &tod->vimage->inf_img.mfdb, &screen ) ;
      GWShowCursor( 0 ) ;
    }
    if ( (xm1 != xm2) || (ym1 != ym2) )
    {
      GWHideCursor( 0 ) ;
      if (!dummy ) rectangle( tod->x1, tod->y1, tod->x2, tod->y2 ) ;
      tod->x1 = tod->x1+dxc ; tod->y1 = tod->y1+dyc ;
      tod->x2 = tod->x2+dxc ; tod->y2 = tod->y2+dyc ;
      rectangle( tod->x1, tod->y1, tod->x2, tod->y2 ) ;
      GWShowCursor( 0 ) ;
      xm1 = xm2 ; ym1 = ym2 ;
      if ( config.use_rtzoom )
      {
        vs_clip( handle, 0, tod->xy ) ;
        rtzoom_display( xm2, ym2, tod->zoom_what ) ;
        vs_clip( handle, 1, tod->xy ) ;
      }
      sprintf( tod->buf, MsgTxtGetMsg(hMsg, MSG_XY), tod->posx+xm2-tod->xi, tod->posy+ym2-tod->yi ) ;
      GWSetWindowInfo( tod->gwnd, tod->buf ) ;
    }
  }
  while ( bm == 0 ) ;
}

void traite_cercle(GEM_WINDOW* gwnd, int fill)
{
  TOOL_OBJECT_DATA tod ;
  int              dx, dy ;
  int              x, y, w, h ;
  int              xm1, ym1, xm2, ym2, bm, dummy ;
  int              xmin, ymin, xmax, ymax ;
  int              xc, yc ;
  int              tm, new ;
  int              lxm = 0, lym = 0 ;
 
  if ( gwnd == NULL ) return ;

  tod.gwnd   = gwnd ;
  tod.vimage = (VXIMAGE*) gwnd->Extension ;
  tod.zoom_what = config.rt_zoomwhat ;
  if ( tod.zoom_what == RTZ_SMART ) tod.zoom_what = RTZ_SCREEN ;
  if ( tod.vimage->zoom_level != 1 )
  {
    form_stop( MsgTxtGetMsg(hMsg, MSG_NOTOOLZ) ) ;
    return ;
  }
  if ( check_color( tod.vimage, ftype.color ) ) return ;

  gwnd->GetWorkXYWH( gwnd, &x, &y, &w, &h ) ;
  tod.xy[0] = x ;     tod.xy[1] = y ;
  tod.xy[2] = x+w-1 ; tod.xy[3] = y+h-1 ;
  vs_clip( handle, 1, tod.xy ) ;
  wind_update( BEG_UPDATE ) ;

  vswr_mode( handle, MD_XOR ) ;
  vsf_interior( handle, FIS_HOLLOW ) ;
  vsf_perimeter( handle, 1 ) ;
  vsl_width( handle, 1 ) ;
  vsl_ends( handle, SQUARE, SQUARE ) ;
  gwnd->GetWorkXYWH( gwnd, &tod.xi, &tod.yi, &tod.wx, &tod.wy) ;
  GWGetHSlider( gwnd, &tod.posx ) ;
  GWGetVSlider( gwnd, &tod.posy ) ;
  tod.posx = ppmf( tod.posx, tod.vimage->inf_img.mfdb.fd_w-tod.wx ) ;
  tod.posy = ppmf( tod.posy, tod.vimage->inf_img.mfdb.fd_h-tod.wy ) ;

  graf_mkstate( &xm1, &ym1, &bm, &dummy ) ;
  xc = xm1 ; yc = ym1 ;
  dx = xc-xm1 ;
  dy = yc-ym1 ;
  GWHideCursor( 0 ) ;
  v_ellipsea( handle, fill, xc, yc, dx, dy ) ;
  GWShowCursor( 0 ) ;
  do
  {
    graf_mkstate( &xm2, &ym2, &bm, &dummy ) ;
    if ( (xm2 != xm1) || (ym2 != ym1) )
    {
      dx = xc-xm1 ;
      dy = yc-ym1 ;
      GWHideCursor( 0 ) ;
      v_ellipsea( handle, fill, xc, yc, dx, dy ) ;
      dx = xc-xm2 ;
      dy = yc-ym2 ;
      v_ellipsea( handle, fill, xc, yc, dx, dy ) ;
      GWShowCursor( 0 ) ;
      xm1 = xm2 ; ym1 = ym2 ;
      if ( (lxm != xm2) || (lym != ym2) )
      {
        if ( config.use_rtzoom )
        {
          vs_clip( handle, 0, tod.xy ) ;
          rtzoom_display( xm2, ym2, tod.zoom_what ) ;
          vs_clip( handle, 1, tod.xy ) ;
        }
        lxm = xm2 ;
        lym = ym2 ;
      }
      sprintf( tod.buf, MsgTxtGetMsg(hMsg, MSG_R) , abs(dx), abs(dy) ) ;
      GWSetWindowInfo( gwnd, tod.buf ) ;
    }
  }
  while ( bm == 1 ) ;

  dx = xc-xm1 ;
  dy = yc-ym1 ;
  GWHideCursor( 0 ) ;
  v_ellipsea( handle, fill, xc, yc, dx, dy ) ;
  GWShowCursor( 0 ) ;
  dx = abs(dx) ;
  dy = abs(dy) ;
  if ( aspectratio < 1.0 )
  {
    tod.x1 = xc-dx ; tod.y1 = yc-(int)((double)dy/aspectratio) ;
    tod.x2 = xc+dx ; tod.y2 = yc+(int)((double)dy/aspectratio) ;
  }
  else
  {
    tod.y1 = yc-dy ; tod.x1 = xc-dx ;
    tod.y2 = yc+dy ; tod.x2 = xc+dx ;
  }
  do
  {
    graf_mkstate( &dummy, &dummy, &bm, &dummy ) ;
  }
  while ( bm > 0 ) ;

  GWSetWindowInfo( gwnd, MsgTxtGetMsg(hMsg, MSG_CERCLE)  ) ;

  MoveToolObject( &tod ) ;

  GWHideCursor( 0 ) ;
  if ( !dummy ) rectangle( tod.x1, tod.y1, tod.x2, tod.y2 ) ;
  GWShowCursor( 0 ) ;

  xc = (tod.x1+tod.x2)>>1 ; yc = (tod.y1+tod.y2)>>1 ;

  GWSetWindowInfo( gwnd, "" ) ;

  new = pmfr( tod.posx, tod.vimage->inf_img.mfdb.fd_w-tod.wx ) ;
  GWSetHSlider( gwnd, new ) ;
  new = pmfr( tod.posy, tod.vimage->inf_img.mfdb.fd_h-tod.wy ) ;
  GWSetVSlider( gwnd, new ) ;
 
  if ( bm == 2 )
  {
    vs_clip( handle, 0, tod.xy ) ;
    wind_update( END_UPDATE ) ;
    set_mform( &tod.save ) ;
    return ;
  }

  set_markertype( &mtype ) ;
  set_filltype( &ftype ) ;
  vswr_mode( handle, mode_vswr ) ;
  tm = UDISQUE ;
  if ( fill == 0 )
  {
    vsf_interior( handle, FIS_HOLLOW ) ;
    vsf_perimeter( handle, 1) ;
    vswr_mode( handle, MD_TRANS ) ;
    tm = UCERCLE ;
  }
  GWHideCursor( 0 ) ;
  v_ellipsea( handle, fill, xc, yc, dx, dy ) ;
  GWShowCursor( 0 ) ;
  vs_clip( handle, 0, tod.xy ) ;

  if ( aspectratio < 1.0 )
  {
    xmin = xc-dx ; xmax = xc+dx ;
    ymin = yc-(int)((double)dy/aspectratio) ;
    ymax = yc+(int)((double)dy/aspectratio) ;
  }
  else
  {
    ymin = yc-dy ; ymax = yc+dy ;
    xmin = xc-dx ;
    xmax = xc+dx ;
  }
  if ( xmin < tod.xi ) xmin = tod.xi ;
  if ( ymin < tod.yi ) ymin = tod.yi ;
  if ( xmax > tod.xi+tod.wx-1 ) xmax = tod.xi+tod.wx-1 ;
  if ( ymax > tod.yi+tod.wy-1 ) ymax = tod.yi+tod.wy-1 ;
  xmin = tod.posx+xmin-tod.xi ; xmax = tod.posx+xmax-tod.xi ;
  ymin = tod.posy+ymin-tod.yi ; ymax = tod.posy+ymax-tod.yi ;
  tod.vimage->x1 = tod.posx ;
  tod.vimage->y1 = tod.posy ;
  tod.vimage->x2 = tod.posx+tod.wx-1 ;
  tod.vimage->y2 = tod.posy+tod.wy-1 ;

  undo_put( gwnd, xmin, ymin, xmax, ymax, tm, NULL ) ;
  update_raster( gwnd, xmin-tod.posx+tod.xi, ymin-tod.posy+tod.yi, xmax-tod.posx+tod.xi, ymax-tod.posy+tod.yi ) ;
  set_modif( gwnd ) ;
  wind_update( END_UPDATE ) ;
  set_mform( &tod.save ) ;

  clear_buffers( MU_BUTTON ) ;
}

void traite_rectangle(GEM_WINDOW* gwnd, int fill)
{
  TOOL_OBJECT_DATA tod ;
  int              xyarray[4] ;
  int              xm, ym, xm1, ym1, xm2, ym2, bm ;
  int              dummy ;
  int              new ;
  int              xmin, xmax, ymin ,ymax ;
 
  if ( gwnd == NULL ) return ;

  tod.gwnd   = gwnd ;
  tod.vimage = (VXIMAGE*) gwnd->Extension ;
  tod.zoom_what = config.rt_zoomwhat ;
  if ( tod.zoom_what == RTZ_SMART ) tod.zoom_what = RTZ_SCREEN ;

  if ( tod.vimage->zoom_level != 1 )
  {
    form_stop( MsgTxtGetMsg(hMsg, MSG_NOTOOLZ) ) ;
    return ;
  }
  if ( check_color( tod.vimage, ltype.color ) ) return ;

  wind_update(BEG_UPDATE) ;
  do
  {
    graf_mkstate(&xm, &ym, &bm, &dummy) ;
  }
  while ( bm != 1 ) ;

  vswr_mode( handle, MD_XOR ) ;
  vsl_type( handle, DOT ) ;
  vsl_color( handle, ltype.color ) ;
  vsl_width( handle, 1 ) ;
  vsl_ends( handle, SQUARE, SQUARE ) ;
  gwnd->GetWorkXYWH( gwnd, &tod.xi, &tod.yi, &tod.wx, &tod.wy ) ;
  GWGetHSlider( gwnd, &tod.posx ) ;
  GWGetVSlider( gwnd, &tod.posy ) ;
  tod.posx = ppmf( tod.posx, tod.vimage->inf_img.mfdb.fd_w-tod.wx ) ;
  tod.posy = ppmf( tod.posy, tod.vimage->inf_img.mfdb.fd_h-tod.wy ) ;

  tod.xy[0] = tod.xi ;          tod.xy[1] = tod.yi ;
  tod.xy[2] = tod.xi+tod.wx-1 ; tod.xy[3] = tod.yi+tod.wy-1 ;
  vs_clip( handle, 1, tod.xy ) ;

  xm1 = xm ; ym1 = ym ;
  do
  {
    graf_mkstate( &xm2, &ym2, &bm, &dummy ) ;
    if ( (xm1 != xm2) || (ym1 != ym2) )
    {
      GWHideCursor( 0 ) ;
      rectangle( xm, ym, xm1, ym1 ) ;
      rectangle( xm, ym, xm2, ym2 ) ;
      GWShowCursor( 0 ) ;
      xm1 = xm2 ; ym1 = ym2 ;
      if ( config.use_rtzoom )
      {
        vs_clip( handle, 0, tod.xy ) ;
        rtzoom_display( xm2, ym2, tod.zoom_what ) ;
        vs_clip( handle, 1, tod.xy ) ;
      }
    }
    /* Interdire de sortir de la fenˆtre */
    if ( (xm2 < tod.xi) || (ym2 < tod.yi) || (xm2 > tod.xi+tod.wx-1) || (ym2 > tod.yi+tod.wy-1) ) bm = 1 ;
    sprintf( tod.buf, MsgTxtGetMsg(hMsg, MSG_LH) , abs(xm2-xm), abs(ym2-ym) ) ;
    GWSetWindowInfo( gwnd, tod.buf ) ;
  }
  while ( bm == 1 ) ;

  GWHideCursor( 0 ) ;
  rectangle( xm, ym, xm1, ym1 ) ;
  GWShowCursor( 0 ) ;
  tod.x1 = xm ;  tod.y1 = ym ;
  tod.x2 = xm1 ; tod.y2 = ym1 ;
  GWSetWindowInfo( gwnd, MsgTxtGetMsg(hMsg, MSG_RECTANGLE)  ) ;

  MoveToolObject( &tod ) ;

  GWHideCursor( 0 ) ;
  rectangle( tod.x1, tod.y1, tod.x2, tod.y2 ) ;
  GWShowCursor( 0 ) ;

  GWSetWindowInfo( gwnd, "" ) ;

  if ( bm == 2 )
  {
    vs_clip( handle, 0, tod.xy ) ;
    set_mform( &tod.save ) ;
    wind_update( END_UPDATE ) ;
    return ;
  }

  new = pmfr( tod.posx, tod.vimage->inf_img.mfdb.fd_w-tod.wx ) ;
  GWSetHSlider( gwnd, new ) ;
  new = pmfr( tod.posy, tod.vimage->inf_img.mfdb.fd_h-tod.wy ) ;
  GWSetVSlider( gwnd, new ) ;
  vswr_mode( handle, mode_vswr ) ;
  set_linetype( &ltype ) ;
  set_filltype( &ftype ) ;
  GWHideCursor( 0 ) ;
  xyarray[0] = tod.x1 ; xyarray[1] = tod.y1 ;
  xyarray[2] = tod.x2 ; xyarray[3] = tod.y2 ;
  if ( fill )
  {
    if ( config.flags & FLG_SROUND ) v_rfbox( handle, xyarray ) ;
    else
    {
      vr_recfl(handle, xyarray) ;
      if (ftype.perimeter) rectangle( tod.x1, tod.y1, tod.x2, tod.y2 ) ;
    }
  }
  else
  {
    if ( config.flags & FLG_SROUND ) v_rbox( handle, xyarray ) ;
    else                             rectangle( tod.x1, tod.y1, tod.x2, tod.y2 ) ;
  }
  GWShowCursor( 0 ) ;
  xmin = tod.x1 ; ymin = tod.y1 ;
  xmax = tod.x2 ; ymax = tod.y2 ;
  if ( xmin > xmax )
  {
    dummy = xmin ;
    xmin  = xmax ;
    xmax  = dummy ;
  }
  if ( ymin > ymax )
  {
    dummy = ymin ;
    ymin  = ymax ;
    ymax  = dummy ;
  }
  if ( !fill ) /* Prendre en compte l'‚paisseur et les lignes fl‚ch‚es */
  {
    xmin -= 32+ltype.width ;
    ymin -= 32+ltype.width ;
    xmax += 32+ltype.width ;
    ymax += 32+ltype.width ;
  }
  if (xmin < tod.xi)          xmin = tod.xi ;
  if (xmin > tod.xi+tod.wx-1) xmin = tod.xi+tod.wx-1 ;
  if (ymin < tod.yi)          ymin = tod.yi ;
  if (ymin > tod.yi+tod.wy-1) ymin = tod.yi+tod.wy-1 ;
  if (xmax < tod.xi)          xmax = tod.xi ;
  if (xmax > tod.xi+tod.wx-1) xmax = tod.xi+tod.wx-1 ;
  if (ymax < tod.yi)          ymax = tod.yi ;
  if (ymax > tod.yi+tod.wy-1) ymax = tod.yi+tod.wy-1 ;

  tod.vimage->x1 = tod.posx ;
  tod.vimage->y1 = tod.posy ;
  tod.vimage->x2 = tod.posx+tod.wx-1 ;
  tod.vimage->y2 = tod.posy+tod.wy-1 ;

  undo_put( gwnd, tod.posx+xmin-tod.xi, tod.posy+ymin-tod.yi, tod.posx+xmax-tod.xi, tod.posy+ymax-tod.yi, fill ? UPLAN:URECT, NULL ) ;
  
  update_raster( gwnd, xmin, ymin, xmax, ymax ) ;
  set_modif( gwnd ) ;
  set_mform( &tod.save ) ;
  vs_clip( handle, 0, tod.xy ) ;
  wind_update( END_UPDATE ) ;

  clear_buffers( MU_BUTTON ) ;
}

void traite_ligne(GEM_WINDOW* gwnd)
{
  VXIMAGE *vimage ;
  double xd, yd, dd ;
  int    cxy[4] ;
  int    dist, d2 ;
  int    xm1, ym1, xm2, ym2, xm, ym, bm, km ;
  int    xi, yi, wx, wy ;
  int    x, y ;
  int    posx, posy ;
  int    xmin, xmax, ymin, ymax ;
  int    zoom_what ;
  char   buf[100] ;
 
  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;

  if (vimage->zoom_level != 1)
  {
    form_stop( MsgTxtGetMsg(hMsg, MSG_NOTOOLZ) ) ;
    return ;
  }
  if ( check_color( vimage, ltype.color ) ) return ;

  wind_update(BEG_UPDATE) ;
  vswr_mode(handle, MD_XOR) ;
  vsl_type( handle, SOLID ) ;
  vsl_color( handle, ltype.color ) ;
  vsl_width( handle, 1 ) ;
  vsl_ends(handle, SQUARE, SQUARE) ;

  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy ) ;
  GWGetHSlider( gwnd, &posx) ;
  GWGetVSlider( gwnd, &posy) ;
  posx = ppmf( posx, vimage->inf_img.mfdb.fd_w-wx ) ;
  posy = ppmf( posy, vimage->inf_img.mfdb.fd_h-wy ) ;

  cxy[0] = xi ;      cxy[1] = yi ;
  cxy[2] = xi+wx-1 ; cxy[3] = yi+wy-1 ;
  vs_clip(handle, 1, cxy) ;

  graf_mkstate(&xm, &ym, &bm, &km) ;
  xm1 = xm ; ym1 = ym ;
  do
  {
    graf_mkstate(&xm2, &ym2, &bm, &km) ;
    if ((xm2 != xm1) || (ym1 != ym2))
    {
      sprintf( buf, MsgTxtGetMsg(hMsg, MSG_XY) , vimage->x1 + (xm2-xi) / vimage->zoom_level, vimage->y1 + (ym2-yi) / vimage->zoom_level ) ;
      GWSetWindowInfo( gwnd, buf ) ;
      GWHideCursor( 0 ) ;
      line(xm, ym, xm1, ym1) ;
      if ( traite_thickness( GWGetKey() ) ) set_linetype( &ltype ) ;
      if ((km & 0x03) == 0)
      {
        line(xm, ym, xm2, ym2) ; /* Pas d'appui sur shift */
        xm1 = xm2 ; ym1 = ym2 ;
      }
      else
      {
        xd   = (double)(xm-xm2) ;
        yd   = (double)(ym-ym2) ;
        dd   = sqrt(xd*xd+yd*yd) ;
        dist = (int) dd ;
        d2   = (int) (dd/sqrt(2.0)) ;
        if (xm > xm2)
        {
          if (ym > ym2)
          {
            if (xm-xm2 < ym-ym2)
            {
              x = xm ;
              y = ym-dist ;  /* Zone 3 */
            }
            else
            {
              x = xm-d2 ;
              y = ym-d2 ;   /* Zone 4 */
            }
          }
          else
          {
            if (xm-xm2 < ym2-ym)
            {
              x = xm-d2 ;
              y = ym+d2 ;   /* Zone 6 */
            }
            else
            {
              x = xm-dist ;
              y = ym ;            /* Zone 5 */
            }
          }
        }
        else
        {
          if (ym > ym2)
          {
            if (xm2-xm > ym-ym2)
            {
              x = xm+dist ;
              y = ym  ;            /* Zone 1 */
            }
            else
            {
              x = xm+d2 ;
              y = ym-d2 ;   /* Zone 2 */
            }
          }
          else
          {
            if (xm2-xm > ym2-ym)
            {
              x = xm+d2 ;
              y = ym+d2 ;   /* Zone 8 */
            }
            else
            {
              x = xm ;
              y = ym+dist ;   /* Zone 7 */
            }
          }
        }
        line(xm, ym, x, y) ;
        xm1 = x ; ym1 = y ;
      }
      GWShowCursor( 0 ) ;
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( xm2, ym2, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
    }
    /* Interdire de sortir de la fenˆtre */
    if ((xm2 < xi) || (ym2 < yi) || (xm2 > xi+wx-1) || (ym2 > yi+wy-1)) bm = 1 ;
  }
  while (bm == 1) ;
  
  GWSetWindowInfo( gwnd, "" ) ;

  GWHideCursor( 0 ) ;
  line(xm, ym, xm1, ym1) ;

  vswr_mode(handle, mode_vswr) ;
  set_linetype( &ltype ) ;
  line(xm, ym, xm1, ym1) ;
  GWShowCursor( 0 ) ;

  xmin = xm  ; ymin = ym ;
  xmax = xm1 ; ymax = ym1 ;
  if (xmax < xmin)
  {
    km   = xmax ;
    xmax = xmin ;
    xmin = km ;
  }
  if (ymax < ymin)
  {
    km   = ymax ;
    ymax = ymin ;
    ymin = km ;
  }
  /* Prendre en compte l'‚paisseur et les lignes fl‚ch‚es */
  xmin -= 32+ltype.width ;
  ymin -= 32+ltype.width ;
  xmax += 32+ltype.width ;
  ymax += 32+ltype.width ;

  if (xmin < xi)      xmin = xi ;
  if (xmin > xi+wx-1) xmin = xi+wx-1 ;
  if (ymin < yi)      ymin = yi ;
  if (ymin > yi+wy-1) ymin = yi+wy-1 ;
  if (xmax < xi)      xmax = xi ;
  if (xmax > xi+wx-1) xmax = xi+wx-1 ;
  if (ymax < yi)      ymax = yi ;
  if (ymax > yi+wy-1) ymax = yi+wy-1 ;
  undo_put( gwnd, posx+xmin-xi, posy+ymin-yi, posx+xmax-xi, posy+ymax-yi, ULIGNE, NULL ) ;
  
  update_raster( gwnd, xmin, ymin, xmax, ymax ) ;
  set_modif( gwnd ) ;
  vs_clip(handle, 0, cxy) ;
  wind_update(END_UPDATE) ;
}

void traite_kligne(GEM_WINDOW* gwnd)
{
  VXIMAGE *vimage ;
  double xd, yd, dd ;
  int    cxy[4] ;
  int    dist, d2 ;
  int    xm1, ym1, xm2, ym2, xm, ym, bm, km ;
  int    xi, yi, wx, wy ;
  int    x, y ;
  int    posx, posy ;
  int    xmin, xmax, ymin, ymax ;
  int    zoom_what ;
  char   buf[100] ;
 
  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;

  if ( vimage->zoom_level != 1 )
  {
    form_stop(  MsgTxtGetMsg(hMsg, MSG_NOTOOLZ)  ) ;
    return ;
  }
  if ( check_color( vimage, ltype.color ) ) return ;

  wind_update(BEG_UPDATE) ;
  vswr_mode(handle, MD_XOR) ;
  set_linetype(&ltype) ;
  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy ) ;
  GWGetHSlider( gwnd, &posx) ;
  GWGetVSlider( gwnd, &posy) ;
  posx = ppmf( posx, vimage->inf_img.mfdb.fd_w-wx ) ;
  posy = ppmf( posy, vimage->inf_img.mfdb.fd_h-wy ) ;

  cxy[0] = xi ;      cxy[1] = yi ;
  cxy[2] = xi+wx-1 ; cxy[3] = yi+wy-1 ;
  vs_clip(handle, 1, cxy) ;

  graf_mkstate(&xm, &ym, &bm, &km) ;
  xm1  = xm ; ym1  = ym ;
  xmin = xm ; ymin = ym ;
  xmax = xm ; ymax = ym ;
  do
  {
    graf_mkstate(&xm2, &ym2, &bm, &km) ;
    if ((xm2 != xm1) || (ym1 != ym2))
    {
      sprintf( buf, MsgTxtGetMsg(hMsg, MSG_XY) , vimage->x1 + (xm2-xi) / vimage->zoom_level, vimage->y1 + (ym2-yi) / vimage->zoom_level ) ;
      GWSetWindowInfo( gwnd, buf ) ;
      GWHideCursor( 0 ) ;
      line(xm, ym, xm1, ym1) ;
      if ( traite_thickness( GWGetKey() ) ) set_linetype(&ltype) ;
      if ((km & 0x03) == 0)
      {
        line(xm, ym, xm2, ym2) ; /* Pas d'appui sur shift */
        xm1 = xm2 ; ym1 = ym2 ;
      }
      else
      {
        xd   = (double)(xm-xm2) ;
        yd   = (double)(ym-ym2) ;
        dd   = sqrt(xd*xd+yd*yd) ;
        dist = (int) dd ;
        d2   = (int) (dd/sqrt(2.0)) ;
        if (xm > xm2)
        {
          if (ym > ym2)
          {
            if (xm-xm2 < ym-ym2)
            {
              x = xm ;
              y = ym-dist ;  /* Zone 3 */
            }
            else
            {
              x = xm-d2 ;
              y = ym-d2 ;   /* Zone 4 */
            }
          }
          else
          {
            if (xm-xm2 < ym2-ym)
            {
              x = xm-d2 ;
              y = ym+d2 ;   /* Zone 6 */
            }
            else
            {
              x = xm-dist ;
              y = ym ;            /* Zone 5 */
            }
          }
        }
        else
        {
          if (ym > ym2)
          {
            if (xm2-xm > ym-ym2)
            {
              x = xm+dist ;
              y = ym  ;            /* Zone 1 */
            }
            else
            {
              x = xm+d2 ;
              y = ym-d2 ;   /* Zone 2 */
            }
          }
          else
          {
            if (xm2-xm > ym2-ym)
            {
              x = xm+d2 ;
              y = ym+d2 ;   /* Zone 8 */
            }
            else
            {
              x = xm ;
              y = ym+dist ;   /* Zone 7 */
            }
          }
        }
        line(xm, ym, x, y) ;
        xm1 = x ; ym1 = y ;
      }
      GWShowCursor( 0 ) ;
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( xm2, ym2, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
    }
    if (bm == 1)
    {
      GWHideCursor( 0 ) ;
      line(xm, ym, xm1, ym1) ;
      vswr_mode(handle, mode_vswr) ;
      line(xm, ym, xm1, ym1) ;
      vswr_mode(handle, MD_XOR) ;
      GWShowCursor( 0 ) ;
      if (xm < xmin)  xmin = xm ;
      if (ym < ymin)  ymin = ym ;
      if (xm > xmax)  xmax = xm ;
      if (ym > ymax)  ymax = ym ;
      if (xm1 < xmin) xmin = xm1 ;
      if (ym1 < ymin) ymin = ym1 ;
      if (xm1 > xmax) xmax = xm1 ;
      if (ym1 > ymax) ymax = ym1 ;
      xm = xm1 ;
      ym = ym1 ;
    }
    /* Interdire de sortir de la fenˆtre */
    if ((xm2 < xi) || (ym2 < yi) || (xm2 > xi+wx-1) || (ym2 > yi+wy-1)) bm = 0 ;
  }
  while (bm != 2) ;
  
  GWSetWindowInfo( gwnd, "" ) ;

  GWHideCursor( 0 ) ;
  line(xm, ym, xm1, ym1) ;
  GWShowCursor( 0 ) ;

  if (xmax < xmin)
  {
    km   = xmax ;
    xmax = xmin ;
    xmin = km ;
  }
  if (ymax < ymin)
  {
    km   = ymax ;
    ymax = ymin ;
    ymin = km ;
  }
  /* Prendre en compte l'‚paisseur et les lignes fl‚ch‚es */
  xmin -= 32+ltype.width ;
  ymin -= 32+ltype.width ;
  xmax += 32+ltype.width ;
  ymax += 32+ltype.width ;

  if (xmin < xi)      xmin = xi ;
  if (xmin > xi+wx-1) xmin = xi+wx-1 ;
  if (ymin < yi)      ymin = yi ;
  if (ymin > yi+wy-1) ymin = yi+wy-1 ;
  if (xmax < xi)      xmax = xi ;
  if (xmax > xi+wx-1) xmax = xi+wx-1 ;
  if (ymax < yi)      ymax = yi ;
  if (ymax > yi+wy-1) ymax = yi+wy-1 ;
  undo_put( gwnd, posx+xmin-xi, posy+ymin-yi, posx+xmax-xi, posy+ymax-yi, ULIGNES, NULL ) ;
  
  update_raster( gwnd, xmin, ymin, xmax, ymax ) ;
  set_modif( gwnd ) ;
  vs_clip(handle, 0, cxy) ;
  wind_update(END_UPDATE) ;
}

void traite_tableau(GEM_WINDOW* gwnd)
{
  VXIMAGE *vimage ;
  MOUSE_DEF save ;
  double    nx, ny ;
  int       xyarray[8] ;
  int       cxy[4] ;
  int       xi, yi, wx, wy ;
  int       xm, ym, xm1, ym1, xm2, ym2, bm ;
  int       x1, y1, x2, y2 ;
  int       dx, dy ;
  int       posx, posy ;
  int       dummy ;
  int       new ;
  int       xmin, xmax, ymin ,ymax ;
  int       bouton ;
  int       rw, rh ;
  int       nbx, nby ;
  int       i, x, y ;
  int       zoom_what ;
  char      buf[50] ;
 
  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;

  if (vimage->zoom_level != 1)
  {
    form_stop( MsgTxtGetMsg(hMsg, MSG_NOTOOLZ) ) ;
    return ;
  }
  if ( check_color( vimage, ltype.color ) ) return ;

  CopyMouseDef( &save, &mouse ) ;
  do
  {
    graf_mkstate(&xm, &ym, &bm, &dummy) ;
  }
  while (bm != 1) ;

  vswr_mode(handle, MD_XOR) ;
  vsl_type(handle, DOT) ;
  vsl_color( handle, ltype.color ) ;
  vsl_width(handle, 1) ;
  vsl_ends(handle, SQUARE, SQUARE) ;

  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy ) ;
  GWGetHSlider( gwnd, &posx) ;
  GWGetVSlider( gwnd, &posy) ;
  posx = ppmf( posx, vimage->inf_img.mfdb.fd_w-wx ) ;
  posy = ppmf( posy, vimage->inf_img.mfdb.fd_h-wy ) ;

  cxy[0] = xi ;      cxy[1] = yi ;
  cxy[2] = xi+wx-1 ; cxy[3] = yi+wy-1 ;
  vs_clip(handle, 1, cxy) ;

  xm1 = xm ; ym1 = ym ;
  do
  {
    graf_mkstate(&xm2, &ym2, &bm, &dummy) ;
    if ((xm1 != xm2) || (ym1 != ym2))
    {
      GWHideCursor( 0 ) ;
      rectangle(xm, ym, xm1, ym1) ;
      rectangle(xm, ym, xm2, ym2) ;
      GWShowCursor( 0 ) ;
      xm1 = xm2 ; ym1 = ym2 ;
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( xm2, ym2, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
    }
    /* Interdire de sortir de la fenˆtre */
    if ((xm2 < xi) || (ym2 < yi) || (xm2 > xi+wx-1) || (ym2 > yi+wy-1)) bm = 1 ;
    sprintf( buf, MsgTxtGetMsg(hMsg, MSG_LH) , abs(xm2-xm), abs(ym2-ym) ) ;
    GWSetWindowInfo( gwnd, buf ) ;
  }
  while (bm == 1) ;

  GWHideCursor( 0 ) ;
  rectangle(xm, ym, xm1, ym1) ;
  GWShowCursor( 0 ) ;
  x1 = xm ;  y1 = ym ;
  x2 = xm1 ; y2 = ym1 ;
  if (!config.souris_viseur)
  {
    mouse.gr_monumber = FLAT_HAND ;
    set_mform(&mouse) ;
  }

  GWSetWindowInfo( gwnd, MsgTxtGetMsg(hMsg, MSG_RECTANGLE)  ) ;

  graf_mkstate(&xm1, &ym1, &bm, &dummy) ;
  GWHideCursor( 0 ) ;
  rectangle(x1, y1, x2, y2) ;
  GWShowCursor( 0 ) ;
  do
  {
    graf_mkstate(&xm2, &ym2, &bm, &dummy) ;
    dummy = 0 ;
    dx = xm2-xm1 ;
    dy = ym2-ym1 ;
    if (xm2 < xi)
    {
      posx -= 8 ;
      if (posx < 0) posx = 0 ;
      dummy = 1 ;
    }
    if (ym2 < yi)
    {
      posy -= 8 ;
      if (posy < 0) posy = 0 ;
      dummy = 1 ;
    }
    if (xm2 > xi+wx-1)
    {
      posx += 8 ;
      if (posx+wx > vimage->inf_img.mfdb.fd_w) posx = vimage->inf_img.mfdb.fd_w-wx ;
      dummy = 1 ;
    }
    if (ym2 > yi+wy-1)
    {
      posy += 8 ;
      if (posy+wy > vimage->inf_img.mfdb.fd_h) posy = vimage->inf_img.mfdb.fd_h-wy ;
      dummy = 1 ;
    }
    if (dummy)
    {
      xyarray[0] = posx ;      xyarray[1] = posy ;
      xyarray[2] = posx+wx-1 ; xyarray[3] = posy+wy-1 ;
      xyarray[4] = xi ;        xyarray[5] = yi ;
      xyarray[6] = xi+wx-1 ;   xyarray[7] = yi+wy-1 ;
      GWHideCursor( 0 ) ;
      vro_cpyfm(handle, S_ONLY, xyarray, &vimage->inf_img.mfdb, &screen) ;
      GWShowCursor( 0 ) ;
    }
    if ((xm1 != xm2) || (ym1 != ym2) || !dummy)
    {
      GWHideCursor( 0 ) ;
      if (!dummy) rectangle(x1, y1, x2, y2) ;
      x1 = x1+dx ; y1 = y1+dy ;
      x2 = x2+dx ; y2 = y2+dy ;
      rectangle(x1, y1, x2, y2) ;
      GWShowCursor( 0 ) ;
      xm1 = xm2 ; ym1 = ym2 ;
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( xm2, ym2, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
    }
    sprintf( buf, MsgTxtGetMsg(hMsg, MSG_XY) , posx+xm2-xi, posy+ym2-yi ) ;
    GWSetWindowInfo( gwnd, buf ) ;
  }
  while (bm == 0) ;

  GWHideCursor( 0 ) ;
  rectangle(x1, y1, x2, y2) ;
  GWShowCursor( 0 ) ;

  GWSetWindowInfo( gwnd, "") ;

  if (bm == 2)
  {
    vs_clip(handle, 0, cxy) ;
    return ;
  }

  new = pmfr( posx, vimage->inf_img.mfdb.fd_w-wx ) ;
  GWSetHSlider( gwnd, new ) ;
  new = pmfr( posy, vimage->inf_img.mfdb.fd_h-wy ) ;
  GWSetVSlider( gwnd, new) ;
  vswr_mode(handle, mode_vswr) ;

  set_mform(&save) ;
  bouton = get_tableau( &nbx, &nby ) ;
  if ( bouton != IDOK ) return ;
  GWRePaint( gwnd ) ;

  rw = 1+abs(x2-x1) ;
  rh = 1+abs(y2-y1) ;
  nx  = (double)rw/(double)nbx ;
  ny  = (double)rh/(double)nby ;

  if (x1 > x2) xm1 = x2 ;
  else         xm1 = x1 ;
  if (y1 > y2) ym1 = y2 ;
  else         ym1 = y1 ;
  set_linetype(&ltype) ;
  vs_clip(handle, 1, cxy) ;
  GWHideCursor( 0 ) ;
  for (i = 0; i <= nby; i++)
  {
    y = (int) ((double)ym1+ny*(double)i) ;
    line(xm1, y, xm1+rw, y) ;
  }
  for (i = 0; i <= nbx; i++)
  {
    x = (int) ((double)xm1+nx*(double)i) ;
    line(x, ym1, x, ym1+rh) ;
  }
  GWShowCursor( 0 ) ;

  xmin = xm1    ; ymin = ym1 ;
  xmax = xm1+rw ; ymax = ym1+rh ;
  xmin -= 32+ltype.width ;
  ymin -= 32+ltype.width ;
  xmax += 32+ltype.width ;
  ymax += 32+ltype.width ;

  if (xmin < xi)      xmin = xi ;
  if (xmin > xi+wx-1) xmin = xi+wx-1 ;
  if (ymin < yi)      ymin = yi ;
  if (ymin > yi+wy-1) ymin = yi+wy-1 ;
  if (xmax < xi)      xmax = xi ;
  if (xmax > xi+wx-1) xmax = xi+wx-1 ;
  if (ymax < yi)      ymax = yi ;
  if (ymax > yi+wy-1) ymax = yi+wy-1 ;

  vimage->x1 = posx ;
  vimage->y1 = posy ;
  vimage->x2 = posx+wx-1 ;
  vimage->y2 = posy+wy-1 ;

/*  update_view(num_window) ;*/
  undo_put( gwnd, posx+xmin-xi, posy+ymin-yi, posx+xmax+rw-xi, posy+ymax+rh-yi, UTAB, NULL ) ;
  update_raster( gwnd, xmin, ymin, xmax, ymax ) ;
  set_modif( gwnd ) ;
  vs_clip(handle, 0, cxy) ;
  do
  {
    graf_mkstate(&xm2, &ym2, &bm, &dummy) ;
  }
  while ( bm != 0 ) ;
}

void traite_aerosol(GEM_WINDOW* gwnd)
{
  VXIMAGE* vimage ;
  clock_t  t0 ;
  int      xy[4] ;
  int      x, y, w, h ;
  int      xm, ym, bm, dummy ;
  int      xi, yi, wx, wy ;
  int      posx, posy ;
  int      xa, ya ;
  int      i, nb, pchit ;
  int      zoom_what ;
  char     buf[100] ;
 
  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE*) gwnd->Extension ;
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;

  if ( check_color( vimage, mtype.color ) ) return ;

  if ( vimage->zoom_level != 1 )
  {
    form_stop(  MsgTxtGetMsg(hMsg, MSG_NOTOOLZ)  ) ;
    return ;
  }

  gwnd->GetWorkXYWH( gwnd, &x, &y, &w, &h ) ;
  xy[0] = x ; xy[1] = y ;
  xy[2] = x+w-1 ; xy[3] = y+h-1 ;
  vs_clip(handle, 1, xy) ;

  vsm_type(handle, 1) ;
  vsm_color(handle, mtype.color) ;
  vswr_mode(handle, mode_vswr) ;
  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy) ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;
  nb    = (int) ((double) (puissance*puissance)*(double)densite/100.0) ;
  pchit = puissance>>2 ;
  LoggingDo(LL_DEBUG, "Aerosol pschit=%d", pchit) ;
  t0 = clock() ;
  for(;;)
  {
    graf_mkstate(&xm, &ym, &bm, &dummy) ;
    if (bm != 1) break ;
    if ((xm >= x) && (ym >= y) && (xm < x+w) && (ym < y+h) && (clock()-t0>CLK_TCK/10)) /* No more than 10 updates/s */
    {
      GWHideCursor( 0 ) ;
      for (i = 0; i < nb; i++)
      {
        xa    = xm-random(puissance) ;
        ya    = ym-random(puissance) ;
        xa   += random(pchit) ;
        ya   += random(pchit) ;
        pset(xa, ya) ;
      }
      GWShowCursor( 0 ) ;
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, xy) ;
        rtzoom_display( xm, ym, zoom_what ) ;
        vs_clip(handle, 1, xy) ;
      }
      t0 = clock() ;
      sprintf( buf, MsgTxtGetMsg(hMsg, MSG_XY) , posx+xm-xi, posy+ym-yi ) ;
      GWSetWindowInfo( gwnd, buf ) ;
    }
  }
  vs_clip(handle, 0, xy) ;

  GWSetWindowInfo( gwnd, "" ) ;
  undo_put( gwnd, posx, posy, posx+wx-1, posy+wy-1, UAEROSOL, NULL ) ;
  update_raster( gwnd, x, y, x+w-1, y+h-1 ) ;

  set_modif( gwnd ) ;
}

void traite_pinceau(GEM_WINDOW* gwnd)
{
  VXIMAGE* vimage ;
  int      xy[8] ;
  int      cxy[4] ;
  int      l ;
  int      xm, ym, bm ;
  int      xmin, ymin, xmax, ymax ;
  int      dummy ;
  int      xi, yi, wx, wy ;
  int      posx, posy ;
  int      xc, yc ;
  int      lxm = 0, lym = 0 ;
  int      zoom_what ;
  char     buf[100] ;
 
  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE*) gwnd->Extension ;
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;
  if ( check_color( vimage, pencil.color ) ) return ;

  if ( vimage->zoom_level != 1 )
  {
    form_stop( MsgTxtGetMsg(hMsg, MSG_NOTOOLZ) ) ;
    return ;
  }

  l = pencil.height ;
  LoggingDo(LL_DEBUG,"Pencil height:%d", l) ;

  graf_mkstate(&xm, &ym, &bm, &dummy) ;
  xmin = xm-32 ; ymin = ym-32 ;
  xmax = xm+32 ; ymax = ym+32 ;
  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy ) ;
  cxy[0] = xi ;      cxy[1] = yi ;
  cxy[2] = xi+wx-1 ; cxy[3] = yi+wy-1 ;
  vs_clip(handle, 1, cxy) ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;
  vswr_mode(handle, mode_vswr) ;
  vsf_color(handle, pencil.color) ;
  vsf_interior(handle, FIS_SOLID) ;

  for(;;)
  {
    graf_mkstate(&xm, &ym, &bm, &dummy) ;
    if (bm == 0) break ;
    if (!config.souris_viseur)
    {
      xy[4] = xm ;
      xy[5] = ym ;
      xy[6] = xm+l ;
      xy[7] = ym+l ;
    }
    else
    {
      xy[4] = xm-(l>>1) ;
      xy[5] = ym-(l>>1) ;
      xy[6] = xm+(l>>1) ;
      xy[7] = ym+(l>>1) ;
    }
    
    if ( (xm >= xi-16) && (ym >= yi-16) && (xm < xi+wx-1) && (ym < yi+wy-1) )
    {
      int ph = pencil.height >> 1 ;

      if (xy[6] >= xi+wx) xy[6] = xi+wx-1 ;
      if (xy[7] >= yi+wy) xy[7] = yi+wy-1 ;
      if (xy[4] < xmin) xmin = xy[4] ;
      if (xy[5] < ymin) ymin = xy[5] ;
      if (xy[6] > xmax) xmax = xy[6] ;
      if (xy[7] > ymax) ymax = xy[7] ;
      xc = xm ;
      yc = ym ;
      GWHideCursor( 0 ) ;
      switch(pencil.type)
      {
        case 0 : xy[0] = xc-ph ;
                 xy[1] = yc-ph ;
                 xy[2] = xc+ph ;
                 xy[3] = yc+ph ;
                 vr_recfl(handle, xy) ;
                 break ;
        case 1 : v_circle(handle, xc, yc, ph) ;
                 break ;
        case 2 : xy[0] = xc ;
                 xy[1] = yc-ph ;
                 xy[2] = xc+ph ;
                 xy[3] = yc ;
                 xy[4] = xc ;
                 xy[5] = yc+ph ;
                 xy[6] = xc-ph ;
                 xy[7] = yc ;
                 v_fillarea(handle, 4, xy) ;
                 break ;
      }
    }
    GWShowCursor( 0 ) ;
    
    if ( ( lxm != xm ) || ( lym != ym ) )
    {
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( xm, ym, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
      lxm = xm ;
      lym = ym ;
    }
    sprintf( buf, MsgTxtGetMsg(hMsg, MSG_XY) , posx+xm-xi, posy+ym-yi ) ;
    GWSetWindowInfo( gwnd, buf ) ;
    traite_thickness( GWGetKey() ) ;
  }

  GWSetWindowInfo( gwnd, ""  ) ;
  xmin -= 16 ; ymin -= 16 ;
  xmax += 16 ; ymax += 16 ;
  if (xmin < xi) xmin = xi ;
  if (ymin < yi) ymin = yi ;
  if (xmax > xi+wx-1) xmax = xi+wx-1 ;
  if (ymax > yi+wy-1) ymax = yi+wy-1 ;

  undo_put( gwnd, posx+xmin-xi, posy+ymin-yi, posx+xmax-xi, posy+ymax-yi, UPINCEAU, NULL ) ;
  if ((xmin != 20000) && (ymin != 20000))
    update_raster( gwnd, xmin, ymin, xmax, ymax ) ;
  set_modif( gwnd ) ;
  vs_clip(handle, 0, cxy) ;
}
