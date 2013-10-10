/******************************/
/*--------- ACTIONS.C --------*/
/* Module des fonctions       */
/* Appel‚es par l'utilisateur */
/******************************/
#include   <math.h>
#include <string.h>
#include <stdlib.h>
#include <process.h>

#include     "..\tools\stdprog.h"
#include     "..\tools\stdinput.h"
#include     "..\tools\stdmline.h"
#include     "..\tools\xgem.h"
#include      "..\tools\xfile.h"
#include     "..\tools\gwindows.h"
#include    "..\tools\print.h"
#include   "..\tools\xstdio.h"
#include   "..\tools\dither.h"
#include   "..\tools\img_io.h"
#include  "..\tools\clipbrd.h"
#include "..\tools\imgmodul.h"
#include "..\tools\rasterop.h"
#include "..\tools\frecurse.h"

#include     "defs.h"
#include     "undo.h"
#include   "rtzoom.h"
#include   "gstenv.h"
#include  "fullscr.h"
#include  "figures.h"
#include "visionio.h"
#include "register.h"
#include "vtoolbar.h"
#include "hexdump.h"
#include "forms\ftcwheel.h"
#include "forms\finfoimg.h"
#include "forms\fbconv.h"
#include "forms\fwpal.h"
#include "forms\fbuyme.h"

#include "ldv\ldvcom.h"
#include "forms\fldv.h"
#include "forms\fappldv.h"

VISION_CFG config ;
MOUSE_DEF  mf_gomme ;       /* Souris gomme                    */
MOUSE_DEF  mf_peint ;       /* Souris peinture                 */
MOUSE_DEF  mf_loupe ;       /* Souris loupe                    */
MOUSE_DEF  mf_pencil ;      /* Souris pinceau pour palette     */
MOUSE_DEF  mf_viseur ;      /* Souris en forme de viseur       */
MOUSE_DEF  mf_aerosol ;     /* Souris en forme d'a‚rosol       */
DATA_CLIP  vclip ;          /* Prochains paramŠtres clipboard  */
PENCIL     pencil ;         /* Pinceau courant                 */
int        mode_vswr ;      /* Mode de recopie                 */
int        densite = 20 ;   /* Densit‚ de l'aerosol            */
int        puissance = 10 ; /* Puissance de l'aerosol          */
int        xopen, yopen ;   /* Ouverture d'une fenˆtre         */

typedef struct
{
  BCONV_PARAMS *bconv ;
  FILE         *err_stream ;
  char         bconv_errfile[14] ;
  int          nb_bconv_fails ;

  GEM_WINDOW  *wconvprog ;
  long        total_nb_files_expected ;
  long        nb_files ;
  char        stop_conv ;
}
BATCH_CONV ;


void set_imgpalette(VXIMAGE *vimg)
{
  int rgb[3] ;

  if ( Truecolor ) return ;

  if ( ( vimg == NULL ) || ( vimg->inf_img.palette == NULL ) )
  {
    set_tospalette( old_pal, 16 ) ;
    rgb[0] = rgb[1] = rgb[2] = 0 ;
    vs_color( handle, 1, rgb ) ;

    return ;
  }

  if ( vimg->inf_img.vdi_palette ) set_vdipalette( vimg->inf_img.palette, (int) (vimg->inf_img.nb_cpal) ) ;
  else                             set_tospalette( vimg->inf_img.palette, (int) (vimg->inf_img.nb_cpal) ) ;
/*  if ( vimg->inf_img.nplans == 8 )
  {
    rgb[0] = rgb[1] = rgb[2] = 0 ;
    vs_color( handle, 1, rgb ) ;
  }
*/
  switch( config.color_protect )
  {
    case 1 : rgb[0] = rgb[1] = rgb[2] = 1000 ;
             vs_color(handle, 0, rgb) ;
             rgb[0] = rgb[1] = rgb[2] = 0 ;
             vs_color(handle, 1, rgb) ;
             rgb[0] = rgb[1] = rgb[2] = 753 ;
             vs_color(handle, 8, rgb) ;
             rgb[0] = rgb[1] = rgb[2] = 502 ;
             vs_color(handle, 9, rgb) ;
             break ;

    case 2 : set_tospalette(old_pal, 16) ;
             rgb[0] = rgb[1] = rgb[2] = 0 ;
             vs_color(handle, 1, rgb) ;
             break ;
  }
}

void traite_fullscreen(GEM_WINDOW *gwnd)
{
  if ( gwnd ) pleine_page( gwnd ) ;
  else        form_stop( 1, msg[MSG_NOIMG] ) ;
}


void traite_coupeff(int flag)
{
  VXIMAGE *vimage ;
  int xy[8] ;
  int tm ;

  if ( !GWIsWindowValid( vclip.gwindow ) ) return ;

  vimage    = (VXIMAGE *) vclip.gwindow->Extension ;

  tm = flag ? UCOUPE : UEFFACE ;
  undo_put(vclip.gwindow, vclip.x1, vclip.y1, vclip.x2, vclip.y2, tm, NULL ) ;

  xy[4] = vclip.x1 ; xy[5] = vclip.y1 ;
  xy[6] = vclip.x2 ; xy[7] = vclip.y2 ;
  if (vclip.form == BLOC_RECTANGLE)
  {
    xy[0] = vclip.x1 ; xy[1] = vclip.y1 ;
    xy[2] = vclip.x2 ; xy[3] = vclip.y2 ;
    vro_cpyfm(handle, ALL_WHITE, xy, &vimage->raster, &vimage->raster) ;
    if (Truecolor)
      vro_cpyfm(handle, D_INVERT, xy, &vimage->raster, &vimage->raster) ;
  }
  else
  {
    xy[0] = xy[1] = 0 ;
    xy[2] = vclip.x2-vclip.x1 ;
    xy[3] = vclip.y2-vclip.y1 ;
    vro_cpyfm(handle, NOTS_AND_D, xy, &clipboard.mask, &vimage->raster) ;
  }

  if (flag && (vclip.form == BLOC_RECTANGLE))
    clip_put(vclip.gwindow, vclip.x1, vclip.y1, vclip.x2, vclip.y2) ;

  GWRePaint( vclip.gwindow ) ;
  
  set_modif( vclip.gwindow ) ;
}

void traite_coupe(void)
{
  traite_coupeff(1) ;
}

void traite_efface(void)
{
  traite_coupeff(0) ;
}

void traite_copie(void)
{
  if (vclip.form == BLOC_RECTANGLE)
    clip_put(vclip.gwindow, vclip.x1, vclip.y1, vclip.x2, vclip.y2) ;
}

void traite_negatif(void)
{
  VXIMAGE *vimage ;
  int     xy[8] ;

  if ( !GWIsWindowValid( vclip.gwindow ) ) return ;

  vimage    = (VXIMAGE *) vclip.gwindow->Extension ;
  undo_put( vclip.gwindow, vclip.x1, vclip.y1, vclip.x2, vclip.y2, (vclip.form == BLOC_RECTANGLE) ? UNEGATIF : UNEGLASSO, NULL ) ;

  xy[4] = vclip.x1 ; xy[5] = vclip.y1 ;
  xy[6] = vclip.x2 ; xy[7] = vclip.y2 ;
  if (vclip.form == BLOC_RECTANGLE)
  {
    xy[0] = vclip.x1 ; xy[1] = vclip.y1 ;
    xy[2] = vclip.x2 ; xy[3] = vclip.y2 ;
    vro_cpyfm(handle, D_INVERT, xy, &vimage->raster, &vimage->raster) ;
  }
  else
  {
    if (config.flags & FLG_MASKOUT)
    {
      int xy[8] ;

      xy[0] = xy[1] = xy[4] = xy[5] = 0 ;
      xy[2] = xy[6] = clipboard.mask.fd_w-1 ;
      xy[3] = xy[7] = clipboard.mask.fd_h-1 ;
      vro_cpyfm(handle, D_INVERT, xy, &clipboard.mask, &clipboard.mask) ;
    }
    xy[0] = xy[1] = 0 ;
    xy[2] = vclip.x2-vclip.x1 ;
    xy[3] = vclip.y2-vclip.y1 ;
    vro_cpyfm(handle, S_XOR_D, xy, &clipboard.mask, &vimage->raster) ;
    if (config.flags & FLG_MASKOUT)
    {
      int xy[8] ;

      xy[0] = xy[1] = xy[4] = xy[5] = 0 ;
      xy[2] = xy[6] = clipboard.mask.fd_w-1 ;
      xy[3] = xy[7] = clipboard.mask.fd_h-1 ;
      vro_cpyfm(handle, D_INVERT, xy, &clipboard.mask, &clipboard.mask) ;
    }
  }

  GWRePaint( vclip.gwindow ) ;
  
  set_modif( vclip.gwindow ) ;
}

int clip_search(void)
{
  INFO_IMAGE info ;
  MFDB       img ;
  char       clip_path[200] ;
  char       name[200] ;

  if ( clbd_getpath(clip_path ) != 0 ) return( 0 ) ;
  strcpy( name, clip_path ) ;
  if ( Truecolor )
  {
    strcat( name, "SCRAP.TIF" ) ;
    if ( !FileExist( name ) ) return( 0 ) ;
  }
  else
  {
    strcat( name, "SCRAP.IMG" ) ;
    if ( !FileExist( name ) )
    {
      strcpy( name, clip_path ) ;
      strcat( name, "SCRAP.TIF" ) ;
      if ( !FileExist( name ) ) return( 0 ) ;
    }
  }

  /* name existe dans le clipboard */
  if ( img_format(name, &info ) != 0 ) return( 0 ) ;
  img.fd_nplanes  = nb_plane ;
  Force16BitsLoad = ( nb_plane == 16 ) ;
  if ( load_picture( name, &img, &info, NULL ) != 0 ) return( 0 ) ;

  if ( info.palette ) free( info.palette ) ;
  FreeClipboard() ;

  memcpy(&clipboard.img, &img, sizeof(MFDB)) ;
  clipboard.mitem    = 0 ;
  clipboard.gwindow  = NULL ;
  clipboard.x        = 0 ;
  clipboard.y        = 0 ;
  clipboard.w        = clipboard.img.fd_w-1 ;
  clipboard.h        = clipboard.img.fd_h-1 ;

  return( 1 ) ;
}

void put_bloc(GEM_WINDOW *wnd, int x, int y, int mode)
{
  int xy[8] ;
  int w, h ;
  int xi, yi, wx, wy ;
  int wlimit, hlimit ;

  w = clipboard.w ;
  h = clipboard.h ;
  wnd->GetWorkXYWH( wnd, &xi, &yi, &wx, &wy ) ;
  if ( ( x < xi ) || ( x >= xi + wx ) || ( y < yi ) || ( y >= yi + wy ) ) return ;

  wlimit = xi + wx - x ;
  hlimit = yi + wy - y ;
  if ( w > wlimit ) w = wlimit ;
  if ( h > hlimit ) h = hlimit ;
  xy[0] = 0 ;
  xy[1] = 0 ;
  xy[2] = w-1 ;
  xy[3] = h-1 ;
  xy[4] = x ;
  xy[5] = y ;
  xy[6] = xy[4]+w-1 ;
  xy[7] = xy[5]+h-1 ;

  if (clipboard.mask.fd_addr != NULL) /* Image au lasso */
  {
    vro_cpyfm(handle, NOTS_AND_D, xy, &clipboard.mask, &screen) ;
    vro_cpyfm(handle, S_OR_D, xy, &clipboard.img, &screen) ;
  }
  else
    vro_cpyfm(handle, mode, xy, &clipboard.img, &screen) ;
}

void restore_img(int posx, int posy, int x, int y)
{
  VXIMAGE *vimage ;
  MFDB *src ;
  int  xy[8] ;
  int  w, h ;
  int  xi, yi, wx, wy ;
  int  wlimit, hlimit ;

  if ( GemApp.CurrentGemWindow == NULL ) return ;
  vimage = (VXIMAGE *) GemApp.CurrentGemWindow->Extension ;

  w = clipboard.w ;
  h = clipboard.h ;
  GemApp.CurrentGemWindow->GetWorkXYWH( GemApp.CurrentGemWindow, &xi, &yi, &wx, &wy ) ;
  if ( ( x < xi ) || ( x >= xi + wx ) || ( y < yi ) || ( y >= yi + wy ) ) return ;

  wlimit = xi + wx - x ;
  hlimit = yi + wy - y ;
  if ( w > wlimit ) w = wlimit ;
  if ( h > hlimit ) h = hlimit ;

  if ( vimage->zoom_level == 1 )
    src = &vimage->raster ;
  else
  {
    src = &vimage->zoom ;
    posx -= vimage->x1 ;
    posy -= vimage->y1 ;
  }

  xy[0] = posx ;
  xy[1] = posy ;
  xy[2] = posx+w-1 ;
  xy[3] = posy+h-1 ;
  xy[4] = x ;
  xy[5] = y ;
  xy[6] = xy[4]+w-1 ;
  xy[7] = xy[5]+h-1 ;
  vro_cpyfm( handle, S_ONLY, xy, src, &screen ) ;
}

void traite_colle(GEM_WINDOW *cur_window)
{
  VXIMAGE *vimage ;
  MOUSE_DEF save ;
  int       xy[8] ;
  int       i ;
  int       xi, yi, wx, wy ;
  int       posx, posy ;
  int       x, y ;
  int       mode ;
  int       xm1, ym1, xm2, ym2, bm ;
  int       deltax, deltay ;
  int       rw, rh ;
  int       new ;
  int       dummy ;
  int       zoom_level ;
  int       zoom_what ;
  int       hm = config.rt_hidemouse ;
  char      flag[1+NB_TOOLS] ;
  char      buf[100] ;
 
  if ( cur_window == NULL ) return ;
  vimage     = (VXIMAGE *) cur_window->Extension ;
  zoom_level = vimage->zoom_level ;

  if ( clipboard.gwindow == NULL )
    if ( clip_search() == 0 ) return ;

  if ( clipboard.img.fd_nplanes > vimage->raster.fd_nplanes )
  {
    int rep ;

    rep = form_interrogation(1, msg[MSG_WARNPASTE]) ;
    if (rep == 2) return ;
  }

  wind_update(BEG_UPDATE) ;

  /* Recherche de l'outil actif */
  for (i = 1; i <= NB_TOOLS; i++)
    if (selected(adr_icones, i)) break ;

  deselect(adr_icones, i) ;
  select(adr_icones, BLOC) ;
  memset( flag, 0, 1+NB_TOOLS ) ;
  flag[i] = flag[BLOC] = 1 ;
  VToolBarUpdate( flag ) ;

  if (!config.souris_viseur)
  {
    mouse.gr_monumber = POINT_HAND ;
    set_mform(&mouse) ;
  }

  if (mode_vswr == MD_REPLACE)    mode = S_ONLY ;
  else if (mode_vswr == MD_TRANS)  mode = S_OR_D ;
  else if (mode_vswr == MD_XOR)     mode = S_XOR_D ;
  else if (mode_vswr == MD_ERASE)    mode = NOTS_AND_D ;
  cur_window->GetWorkXYWH( cur_window, &xi, &yi, &wx, &wy ) ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;
  memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;
  if (!config.souris_viseur)
  {
    mouse.gr_monumber = FLAT_HAND ;
    set_mform(&mouse) ;
  }

  graf_mkstate(&xm1, &ym1, &bm, &dummy) ;
  vswr_mode(handle, MD_XOR) ;
  vsl_color(handle, 1) ;
  vsl_type(handle, DOT) ;
  xy[0] = xi ;      xy[1] = yi ;
  xy[2] = xi+wx-1 ; xy[3] = yi+wy-1 ;
  xy[4]  = xi ;           xy[5] = yi ;
  xy[6]  = xi+wx-1 ;      xy[7] = yi+wy-1 ;
  v_hide_c(handle) ;
  put_bloc( cur_window, xm1, ym1, mode ) ;
  v_show_c(handle, 1) ;
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART )
  {
    zoom_what           = RTZ_SCREEN ;
    config.rt_hidemouse = 1 ;
  }
  do
  {
    graf_mkstate(&xm2, &ym2, &bm, &dummy) ;
    if (bm != 0) break ;
    if (((xm2 < xi) || (xm2 > xi+wx-1) || (ym2 < yi) || (ym2 > yi+wy-1)) && (zoom_level == 1))
    {
      deltax = deltay = 0 ;
      if (xm2 < xi)      deltax = -16 ;
      if (xm2 > xi+wx-1) deltax =  16 ;
      if (ym2 < yi)      deltay = -16 ;
      if (ym2 > yi+wy-1) deltay =  16 ;
      posx += deltax ;
      posy += deltay ;
      if (posx < 0) posx = 0 ;
      if (posx+wx > vimage->raster.fd_w) posx = vimage->raster.fd_w-wx ;
      if (posy < 0) posy = 0 ;
      if (posy+wy > vimage->raster.fd_h) posy = vimage->raster.fd_h-wy ;
      xy[0] = posx ;      xy[1] = posy ;
      xy[2] = posx+wx-1 ; xy[3] = posy+wy-1 ;
      v_hide_c(handle) ;
      vro_cpyfm(handle, S_ONLY, xy, &vimage->raster, &screen) ;
      put_bloc( cur_window, xm2, ym2, mode ) ;
      v_show_c(handle, 1) ;
      xm1 = xm2 ; ym1 = ym2 ;
      if ( config.use_rtzoom ) rtzoom_display( xm2, ym2, zoom_what ) ;
    }
    else if ( ( xm2 != xm1 ) || ( ym2 != ym1 ) )
    {
      if ((zoom_level == 1) || ((zoom_level != 1) && (xm2 >= xi) && (ym2 >= yi)))
      {
        v_hide_c(handle) ;
        restore_img( posx+xm1-xi, posy+ym1-yi, xm1, ym1 ) ;
        put_bloc( cur_window, xm2, ym2, mode ) ;
        v_show_c(handle, 1) ;
        xm1 = xm2 ; ym1 = ym2 ;
        if ( config.use_rtzoom ) rtzoom_display( xm2, ym2, zoom_what ) ;
        sprintf( buf, msg[MSG_XYLH], posx+xm2-xi, posy+ym2-yi, clipboard.w, clipboard.h ) ;
        GWSetWindowInfo( cur_window, buf ) ;
      }
    }
  }
  while (bm == 0) ;

  v_hide_c(handle) ;
  if ( bm == 2 ) restore_img( posx+xm1-xi, posy+ym1-yi, xm1, ym1 ) ;
  v_show_c(handle, 1) ;

  GWSetWindowInfo( cur_window, "" ) ;

  x = xm2 ; y = ym2 ;

  if (zoom_level == 1)
  {
    new = (int) (0.5+1000.0*(double)posx/(double)(vimage->raster.fd_w-wx)) ;
    GWSetHSlider( cur_window, new ) ;
    new = (int) (0.5+1000.0*(double)posy/(double)(vimage->raster.fd_h-wy)) ;
    GWSetVSlider( cur_window, new ) ;
    vimage->x1 = posx ;
    vimage->y1 = posy ;
    vimage->x2 = posx+wx-1 ;
    vimage->y2 = posy+wy-1 ;
  }

  if ((x < xi+wx-1) && (y < yi+wy-1) && (bm != 2))
  {
    xy[0] = 0 ;         xy[1] = 0 ;
    xy[4] = posx+(x-xi)/zoom_level ; xy[5] = posy+(y-yi)/zoom_level ;
    if (xy[4] < 0) xy[4] = 0 ;
    if (xy[5] < 0) xy[5] = 0 ;
    rw = clipboard.w/zoom_level ;
    if (xy[4]+rw > vimage->raster.fd_w)
      rw = vimage->raster.fd_w-xy[4] ;
    xy[2] = xy[0]+rw-1 ; xy[6] = xy[4]+rw-1 ;
    rh = clipboard.h/zoom_level ;
    if (xy[5]+rh > vimage->raster.fd_h)
      rh = vimage->raster.fd_h-xy[5] ;
    xy[3] = xy[1]+rh-1 ; xy[7] = xy[5]+rh-1 ;
  
    undo_put(cur_window, xy[4], xy[5], xy[6], xy[7], UCOLLE, NULL ) ;
    if (zoom_level == 1)
    {
      if (clipboard.mask.fd_addr != NULL)
      {
        vro_cpyfm(handle, NOTS_AND_D, xy, &clipboard.mask, &vimage->raster) ;
        vro_cpyfm(handle, S_OR_D, xy, &clipboard.img, &vimage->raster) ;
      }
      else
        vro_cpyfm(handle, mode, xy, &clipboard.img, &vimage->raster) ;
    }
    else
      update_raster( cur_window, xi, yi, xi+wx-1, yi+wy-1 ) ;
  
    GWRePaint( cur_window ) ;
    set_modif( cur_window ) ;
  }

  wind_update(END_UPDATE) ;
  clear_buffers(MU_BUTTON) ;
  set_mform(&save) ;
  config.rt_hidemouse = hm ;
}

void traite_selectall(GEM_WINDOW *wnd)
{
  VXIMAGE *vimage ;

  if ( wnd == NULL ) return ;
  vimage = wnd->Extension ;
  vclip.form    = BLOC_RECTANGLE ;
  vclip.gwindow = wnd ;
  vclip.x1      = 0 ;
  vclip.y1      = 0 ;
  vclip.x2      = vimage->raster.fd_w-1 ;
  vclip.y2      = vimage->raster.fd_h-1 ;
  GWRePaint( wnd ) ;
}

void analyse_lasso(int *xy, int nb)
{
  GEM_WINDOW    *cur_window = GemApp.CurrentGemWindow ;
  VXIMAGE       *vimage ;
  MFDB          mask, masked_img ;
  int           xyarray[8] ;
  int           cxy[4] ;
  int           *c ;
  int           xi, yi, wx, wy ;
  int           xmin, ymin, xmax, ymax ;
  int           i ;
  int           color_mask, color ;
  unsigned char *tos2vdi ;

  if ( cur_window == NULL ) return ;
  vimage = cur_window->Extension ;

  GWSetWindowInfo( cur_window, msg[MSG_CALCLASSO] ) ;
  cur_window->GetWorkXYWH( cur_window, &xi, &yi, &wx, &wy ) ;
  xmin = ymin = 32767 ;
  xmax = ymax = -32767 ;
  c = xy ;
  for (i = 0; i < nb; i++)
  {
    if (*c > xmax) xmax = *c ;
    if (*c < xmin) xmin = *c ;
    c++ ;
    if (*c > ymax) ymax = *c ;
    if (*c < ymin) ymin = *c ;
    c++ ;
  }
  xy[2*nb]   = xy[0] ;
  xy[1+2*nb] = xy[1] ;

  if (xmin < xi)     xmin = xi ;
  if (xmin >= xi+wx) xmin = xi+wx-1 ;
  if (ymin < yi)     ymin = yi ;
  if (ymin >= yi+wy) ymin = yi+wy-1 ;
  if (xmax < xi)     xmax = xi ;
  if (xmax >= xi+wx) xmax = xi+wx-1 ;
  if (ymax < yi)     ymax = yi ;
  if (ymax >= yi+wy) ymax = yi+wy-1 ;

  memset(&masked_img, 0, sizeof(MFDB)) ;
  masked_img.fd_w = 1+xmax-xmin ;
  masked_img.fd_h = 1+ymax-ymin ;
  masked_img.fd_nplanes = nb_plane ;
  masked_img.fd_wdwidth = masked_img.fd_w/16 ;
  if (masked_img.fd_w % 16) masked_img.fd_wdwidth++ ;
  masked_img.fd_addr = img_alloc(masked_img.fd_w, masked_img.fd_h, masked_img.fd_nplanes) ;
  if (masked_img.fd_addr == NULL)
  {
    form_error(8) ;
    GWSetWindowInfo( cur_window, "" ) ;
    return ;
  }

  xyarray[0] = vimage->x1+xmin-xi ; xyarray[1] = vimage->y1+ymin-yi ;
  xyarray[2] = vimage->x1+xmax-xi ; xyarray[3] = vimage->y1+ymax-yi ;
  xyarray[4] = xyarray[5] = 0 ;
  xyarray[6] = masked_img.fd_w-1 ;
  xyarray[7] = masked_img.fd_h-1 ;
  vro_cpyfm(handle, S_ONLY, xyarray, &vimage->raster, &masked_img) ;

  cxy[0] = xmin ; cxy[1] = ymin ;
  cxy[2] = xmax ; cxy[3] = ymax ;
  vs_clip(handle, 1, cxy) ;
  if (Truecolor)
  {
    int rgb[3] ;

    rgb[0] = rgb[1] = rgb[2] = 0 ;
    vs_color(handle, 17, rgb) ;
    rgb[0] = rgb[1] = rgb[2] = 1000 ;
    vs_color(handle, 18, rgb) ;
    color      = 17 ;
    color_mask = 18 ;
  }
  else
  {
    tos2vdi    = get_pttos2vdi( nb_plane ) ;
    if ( tos2vdi )
    {
      color      = tos2vdi[0] ;
      color_mask = tos2vdi[(1 << nb_plane)-1] ;
    }
  }
  vswr_mode(handle, MD_REPLACE) ;
  vsf_interior(handle, FIS_SOLID) ;
  vsf_color(handle, color) ;
  vsl_color(handle, color) ;
  vsf_perimeter(handle, 0) ;
  v_hide_c(handle) ;
  vr_recfl(handle, cxy) ;
  v_show_c(handle, 1) ;
  vsf_color(handle, color_mask) ;
  vsl_color(handle, color_mask) ;
  v_hide_c(handle) ;
  v_fillarea(handle, 1+nb, xy) ;
  v_show_c(handle, 1) ;
  vs_clip(handle, 0, cxy) ;

  memset(&mask, 0, sizeof(MFDB)) ;
  mask.fd_w = 1+xmax-xmin ;
  mask.fd_h = 1+ymax-ymin ;
  mask.fd_nplanes = nb_plane ;
  mask.fd_wdwidth = mask.fd_w/16 ;
  if (mask.fd_w % 16) mask.fd_wdwidth++ ;
  mask.fd_addr = img_alloc(mask.fd_w, mask.fd_h, mask.fd_nplanes) ;
  if (mask.fd_addr == NULL)
  {
    form_error(8) ;
    free(masked_img.fd_addr) ;
    GWSetWindowInfo( cur_window, "" ) ;
    return ;
  }

  xyarray[0] = xmin ; xyarray[1] = ymin ;
  xyarray[2] = xmax ; xyarray[3] = ymax ;
  xyarray[4] = xyarray[5] = 0 ;
  xyarray[6] = mask.fd_w-1 ;
  xyarray[7] = mask.fd_h-1 ;
  v_hide_c(handle) ;
  vro_cpyfm(handle, S_ONLY, xyarray, &screen, &mask) ;
  v_show_c(handle, 1) ;

  memcpy(xyarray, &xyarray[4], 4*sizeof(int)) ;
  vro_cpyfm(handle, S_AND_D, xyarray, &mask, &masked_img) ;

  clip_putlasso(cur_window, xmin, ymin, xmax, ymax, &mask, &masked_img) ;  

  vclip.form     = BLOC_LASSO ;
  vclip.gwindow  = cur_window ;
  vclip.x1   = vimage->x1+xmin-xi ;
  vclip.y1   = vimage->y1+ymin-yi ;
  vclip.x2   = vimage->x1+xmax-xi ;
  vclip.y2   = vimage->y1+ymax-yi ;

  GWSetWindowInfo( cur_window, "" ) ;
}

void traite_lasso(void)
{
  GEM_WINDOW    *cur_window = GemApp.CurrentGemWindow ;
  VXIMAGE       *vimage ;
  int lassoxy[1000] ; /* NVDI ne va pas au del… */
  int nbpt = 0 ;
  int xy[4] ;
  int xm1, ym1, xm2, ym2, bm, dummy ;
  int xi, yi, wx, wy ;
  int last_x, last_y ;
  int a, b ;
  int posx, posy ;
  int zoom_what ;
  char buf[100] ;
 
  if ( cur_window == NULL ) return ;
  vimage = cur_window->Extension ;

  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;

  cur_window->GetWorkXYWH( cur_window, &xi, &yi, &wx, &wy ) ;
  xy[0] = xi ;      xy[1] = yi ;
  xy[2] = xi+wx-1 ; xy[3] = yi+wy-1 ;
  vs_clip(handle, 1, xy) ;
  set_linetype(&ltype) ;
  vsl_ends(handle, SQUARE, SQUARE) ;
  vswr_mode(handle, MD_XOR) ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;

  graf_mkstate(&xm1, &ym1, &bm, &dummy) ;
  last_x = last_y = -1 ;
  sprintf( buf, msg[MSG_XYLASSO], posx+xm1-xi, posy+ym1-yi, nbpt ) ;
  GWSetWindowInfo( cur_window, buf ) ;
  do
  {
    graf_mkstate(&xm2, &ym2, &bm, &dummy) ;
    if (((xm1 != xm2) || (ym1 != ym2)) && (last_x != -1))
    {
      v_hide_c(handle) ;
      line(last_x, last_y, xm1, ym1) ;
      line(last_x, last_y, xm2, ym2) ;
      v_show_c(handle, 1) ;
      xm1 = xm2 ;
      ym1 = ym2 ;
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, xy) ;
        rtzoom_display( xm2, ym2, zoom_what ) ;
        vs_clip(handle, 1, xy) ;
      }
      sprintf( buf, msg[MSG_XYLASSO], posx+xm2-xi, posy+ym2-yi, nbpt ) ;
      GWSetWindowInfo( cur_window, buf ) ;
    }
    if ((bm == 1) && (nbpt < 1000))
    {
      if (nbpt)
      {
        a = xm2-lassoxy[2*(nbpt-1)] ;
        b = ym2-lassoxy[1+2*(nbpt-1)] ;
      }
      if ((a*a+b*b > 4) || (nbpt == 0))
      {
        lassoxy[2*nbpt]   = xm2 ;
        lassoxy[1+2*nbpt] = ym2 ;
        nbpt++ ;
        last_x = xm1 = xm2 ;
        last_y = ym1 = ym2 ;
      }
    }
  }
  while (bm != 2) ;
  vs_clip(handle, 0, xy) ;

  if (nbpt > 1) analyse_lasso(lassoxy, nbpt) ;
  else
  {
    vclip.gwindow= NULL ;
    vclip.x1 = vclip.y1 = vclip.x2 = vclip.y2 = 0 ;
    return ;
  }

  GWRePaint( cur_window ) ;
}

void traite_blocsimple(void)
{
  GEM_WINDOW    *cur_window = GemApp.CurrentGemWindow ;
  VXIMAGE       *vimage ;
  int xy[8] ;
  int cxy[4] ;
  int xi, yi, wx, wy ;
  int posx, posy ;
  int xe, ye ;
  int x1, y1, x2, y2 ;
  int new ;
  int bm, dummy ;
  int deltax, deltay ;
  int xr, yr ;
  int zoom_what ;
  char buf[100] ;
 
  if ( cur_window == NULL ) return ;
  vimage = cur_window->Extension ;

  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;
  cur_window->GetWorkXYWH( cur_window, &xi, &yi, &wx, &wy ) ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;

  vsl_type(handle, DOT) ;
  vsl_color(handle, 1) ;
  vsl_width(handle, 1) ;
  vsl_ends(handle, SQUARE, SQUARE) ;
  graf_mkstate(&xe, &ye, &bm, &dummy) ;
  xr     = posx+xe-xi ; yr = posy+ye-yi ;
  x1     = xe ; y1 = ye ;
  xy[4]  = xi ;      xy[5] = yi ;
  xy[6]  = xi+wx-1 ; xy[7] = yi+wy-1 ;
  cxy[0] = xi ;      cxy[1] = yi ;
  cxy[2] = xi+wx-1 ; cxy[3] = yi+wy-1 ;
  vs_clip(handle, 1, cxy) ;

  do
  {
    graf_mkstate(&x2, &y2, &bm, &dummy) ;
    vswr_mode(handle, MD_XOR) ;
    if ((x2 < xi) || (x2 > xi+wx-1) || (y2 < yi) || (y2 > yi+wy-1))
    {
      v_hide_c(handle) ;
      rectangle(xe, ye, x1, y1) ;
      deltax = deltay = 0 ;
      if (x2 < xi)      deltax = -16 ;
      if (x2 > xi+wx-1) deltax =  16 ;
      if (y2 < yi)      deltay = -16 ;
      if (y2 > yi+wy-1) deltay =  16 ;
      posx += deltax ;
      posy += deltay ;
      if (posx < 0) posx = 0 ;
      if (posx+wx > vimage->raster.fd_w)
        posx = vimage->raster.fd_w-wx ;
      if (posy < 0) posy = 0 ;
      if (posy+wy > vimage->raster.fd_h)
        posy = vimage->raster.fd_h-wy ;
      xe = xi+xr-posx ;
      ye = yi+yr-posy ;
      xy[0] = posx ;      xy[1] = posy ;
      xy[2] = posx+wx-1 ; xy[3] = posy+wy-1 ;
      vro_cpyfm(handle, S_ONLY, xy, &vimage->raster, &screen) ;
      rectangle(xe, ye, x2, y2) ;
      v_show_c(handle, 1) ;
      x1 = x2 ; y1 = y2 ;
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( x2, y2, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
    }
    else if ((x1 != x2) || (y1 != y2))
    {
      v_hide_c(handle) ;
      rectangle(xe, ye, x1, y1) ;      
      rectangle(xe, ye, x2, y2) ;
      v_show_c(handle, 1) ;
      x1 = x2 ; y1 = y2 ;
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( x2, y2, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
    }
    sprintf( buf, msg[MSG_LH], abs(1+x2-xe), abs(1+y2-ye) ) ;
    GWSetWindowInfo( cur_window, buf ) ;
  }
  while (bm == 1) ;

  GWSetWindowInfo( cur_window, "" ) ;
  if (x2 < xi)      x2 = xi ;
  if (x2 > xi+wx-1) x2 = xi+wx-1 ;
  if (y2 < yi)      y2 = yi ;
  if (y2 > yi+wy-1) y2 = yi+wy-1 ;

  vs_clip(handle, 0, cxy) ;
  /* D‚s‚lection de la zone */
  if ((xr == posx+x2-xi) || (yr == posy+y2-yi))
  {
    vclip.gwindow = NULL ;
    vclip.x1 = vclip.y1 = vclip.x2 = vclip.y2 = 0 ;
    return ;
  }

  new = (int) (0.5+1000.0*(double)posx/(double)(vimage->raster.fd_w-wx)) ;
  GWSetHSlider( cur_window, new ) ;
  new = (int) (0.5+1000.0*(double)posy/(double)(vimage->raster.fd_h-wy)) ;
  GWSetVSlider( cur_window, new ) ;

  vimage->x1 = posx ;
  vimage->y1 = posy ;
  vimage->x2 = posx+wx-1 ;
  vimage->y2 = posy+wy-1 ;

  vclip.gwindow = cur_window ;
  vclip.x1      = xr ;
  vclip.y1      = yr ;
  vclip.x2      = posx+x2-xi ;
  vclip.y2      = posy+y2-yi ;
  if (vclip.x1 > vclip.x2)
  {
    new      = vclip.x1 ;
    vclip.x1 = vclip.x2 ;
    vclip.x2 = new ;
  }
  if (vclip.y1 > vclip.y2)
  {
    new      = vclip.y1 ;
    vclip.y1 = vclip.y2 ;
    vclip.y2 = new ;
  }
}

void traite_bloc(void)
{
  GEM_WINDOW    *cur_window = GemApp.CurrentGemWindow ;
  VXIMAGE       *vimage ;
 
  if ( cur_window == NULL ) return ;
  vimage = cur_window->Extension ;
  
  if ( vimage->zoom_level != 1 )
  {
    form_stop(1, msg[MSG_NOTOOLZ]) ;
    return ;
  }

  if (vclip.form == BLOC_RECTANGLE) traite_blocsimple() ;
  else                              traite_lasso() ;

  update_zview( cur_window ) ;
  clear_buffers( MU_BUTTON ) ;
}

void traite_palette(void)
{
  GEM_WINDOW *cur_window = GemApp.CurrentGemWindow ;

 if ( cur_window == NULL ) return ;

  if ( Truecolor ) traite_24bitspal( cur_window ) ;
  else             traite_selpalindex( cur_window ) ;
}

GEM_WINDOW *nouvelle_wimage(char *nom, int nx, int ny, int nc, int tpmx, int tpmy)
{
  GEM_WINDOW    *gwnd ;
  VXIMAGE       *vimage ;
  INFO_IMAGE    *inf_img ;
  int  w, h ;
  int  xo, yo, wo, ho ;
  int  nnx, nny ;

  gwnd = VImgCreateWindow() ;
  if ( gwnd == NULL )
  {
    form_stop( 1, msg[MSG_NOMOREWINDOW] ) ;
    return( NULL ) ;
  }
  vimage = gwnd->Extension ;
  inf_img = &vimage->inf_img ;

  if (nx < MINIW) nnx = MINIW ;
  else            nnx = nx ;
  if (ny < MINIH) nny = MINIH ;
  else            nny = ny ;

  vimage->raster.fd_addr = img_alloc( nnx, nny, nb_plane ) ;
  if ( vimage->raster.fd_addr == NULL )
  {
    GWDestroyWindow( gwnd ) ;
    form_error(8) ;
    return( NULL ) ;
  }

  strcpy( inf_img->nom, nom ) ;
  if ( Truecolor ) inf_img->lformat = IID_TIFF ;
  else             inf_img->lformat = IID_IMG ;
  inf_img->version  = 1 ;
  inf_img->compress = 0 ;
  inf_img->largeur  = nnx ;
  inf_img->hauteur  = nny ;
  if ( Truecolor ) inf_img->nplans = 24 ;
  else             inf_img->nplans = nb_planes( nc ) ;
  inf_img->lpix     = tpmx ;
  inf_img->hpix     = tpmy ;
  if ( Truecolor ) inf_img->palette  = NULL ;
  else
  {
    inf_img->palette = malloc( 6*nb_colors ) ;
    if ( inf_img->palette == NULL )
    {
      free( vimage->raster.fd_addr ) ;
      GWDestroyWindow( gwnd ) ;
      form_error(8) ;
      return( NULL ) ;
    }
    get_tospalette( inf_img->palette ) ;
    inf_img->nb_cpal = nc ;
  }
  vimage->raster.fd_w = nnx ;
  vimage->raster.fd_h = nny ;
  vimage->raster.fd_nplanes = nb_plane ;
  vimage->raster.fd_wdwidth = nnx/16 ;
  if (nnx % 16) vimage->raster.fd_wdwidth++ ;
  vimage->raster.fd_stand = 0 ;
  memset( &vimage->zoom, 0, sizeof(MFDB) ) ;
  vimage->zoom_level = 1 ;
  vimage->modif      = 0 ;
  sprintf( vimage->nom, "%s\\%s", config.path_img, nom ) ;

  img_raz( &vimage->raster ) ;
  w = vimage->raster.fd_w ;
  h = vimage->raster.fd_h ;
  open_where( gwnd->window_kind, w, h, &xo, &yo, &wo, &ho ) ;
  if ( GWOpenWindow( gwnd, xo, yo, wo, ho ) != 0 )
  {
    form_stop( 1, msg[MSG_NOMOREWINDOW] ) ;
    free( vimage->raster.fd_addr ) ;
    if ( inf_img->palette ) free( inf_img->palette ) ;
    return( NULL ) ;
  }
  AttachPictureToWindow( gwnd ) ;

  return( gwnd ) ;
}

void traite_ncolle(void)
{
  GEM_WINDOW *new_wnd ;
  VXIMAGE    *new_vimage ;
  int        xy[8] ;
  int        w, h ;
  int        tpmx, tpmy ;
  char       name[50] ;

  if ( clipboard.gwindow == NULL )
    if ( clip_search() == 0 ) return ;

  w    = clipboard.w ;
  h    = clipboard.h ;
  tpmx = (int) (27070.0/(double)w) ;
  tpmy = (int) (27070.0/(double)h) ;
  if ( Truecolor ) strcpy( name, "NEW.TIF" ) ;
  else             strcpy( name, "NEW.IMG" ) ;

  new_wnd = nouvelle_wimage( name, w, h, 1 << clipboard.img.fd_nplanes, tpmx, tpmy ) ;
  if ( new_wnd == NULL ) return ;
  new_vimage = (VXIMAGE *) new_wnd->Extension ;

  xy[0] = 0 ;   xy[1] = 0 ;
  xy[2] = w-1 ; xy[3] = h-1 ;
  xy[4] = 0 ;   xy[5] = 0 ;
  xy[6] = w-1 ; xy[7] = h-1 ;

  vro_cpyfm( handle, S_ONLY, xy, &clipboard.img, &new_vimage->raster ) ;

  FreeClipboard() ;
}

int traite_loupe(GEM_WINDOW *cur_window, int flag_level, int mx, int my)
{
  VXIMAGE *vimage ;
  int xy[4] ;
  int zooms[] = {1, 2, 4, 8, 16} ;
  int largx, largy ;
  int index ;
  int xi, yi, wx, wy ;
  int x1, y1, x2, y2 ;
  int wxe, whe ;
  int cx, cy, cw, ch ;
  int last ;
  int keybd ;

  if ( cur_window == NULL ) return(-1) ;
  vimage = cur_window->Extension ;

  for (index = 0; index < 4; index++)
    if (vimage->zoom_level == zooms[index]) break ;
  if (flag_level == 0)
  {
    last  = index ;
    keybd = (int) Kbshift(-1) ;
    if (keybd & 0x0003) index-- ;
    else                index++ ;
  }
  else
  {
    for (last = 0; last < 4; last++)
      if (flag_level == zooms[last]) break ;
  }
  if (index < 0) return(-1) ;
  if (index > 4) return(-1) ;
  vimage->zoom_level = zooms[index] ;

  cur_window->GetWorkXYWH( cur_window, &xi, &yi, &wx, &wy) ;
  if ( ( mx >= 0 ) && ( my >= 0 ) )
  {
    x1     = vimage->x1+(mx-xi)/zooms[last] ;
    y1     = vimage->y1+(my-yi)/zooms[last] ;
    largx  = wx/zooms[index] ;
    if (largx & 0x01) largx++ ;
    x1    -= largx/2 ;
    x2     = x1+largx-1 ;
    largy  = wy/zooms[index] ;
    if (largy & 0x01) largy++ ;
    y1    -= largy/2 ;
    y2     = y1+largy-1 ;
    if (x1 < 0)
    {
     x1 = 0 ;
     x2 = largx-1 ;
    }
    if (x2 > vimage->raster.fd_w-1)
    {
      x2 = vimage->raster.fd_w-1 ;
      x1 = 1+x2-largx ;
    }
    if (y1 < 0)
    {
      y1 = 0 ;
      y2 = largy-1 ;
    }
    if (y2 > vimage->raster.fd_h-1)
    {
      y2 = vimage->raster.fd_h-1 ;
      y1 = 1+y2-largy ;
    }

    vimage->x1 = x1 ; vimage->y1 = y1 ;
    vimage->x2 = x2 ; vimage->y2 = y2 ;
  }

  if (vimage->x1 < 0) vimage->x1 = 0 ;
  if (vimage->y1 < 0) vimage->y1 = 0 ;
  if (vimage->x2 >= vimage->raster.fd_w)
    vimage->x2 = vimage->raster.fd_w-1 ;
  if (vimage->y2 >= vimage->raster.fd_h)
    vimage->y2 = vimage->raster.fd_h-1 ;
  xy[0] = vimage->x1 ; xy[1] = vimage->y1 ;
  xy[2] = vimage->x2 ; xy[3] = vimage->y2 ;
  GWSetWindowInfo( cur_window, msg[MSG_CALCULZOOM] ) ;
  if ( vimage->zoom.fd_addr ) free( vimage->zoom.fd_addr ) ;
  if ( raster_zoom(&vimage->raster, &vimage->zoom,
       xy, zooms[index], zooms[index]) == -1 )
  {
    form_error(8) ;
    vimage->zoom_level = 1 ;
    GWSetWindowInfo( cur_window, "" ) ;
    GWRePaint( cur_window ) ;

    return(-1) ;
  }

  GWSetWindowInfo( cur_window, "" ) ;
  wx = 1+vimage->x2-vimage->x1 ;
  wy = 1+vimage->y2-vimage->y1 ;
  GWGetCurrXYWH( cur_window, &xi, &yi, &cw, &ch ) ;
  wind_calc( WC_WORK, cur_window->window_kind, xi, yi, wdesk-xi, hdesk-yi, &cx, &cy, &cw, &ch ) ;
  if ( wx*zooms[index] > cw )
  {
    wx = cw / zooms[index] ;
    vimage->x2 = vimage->x1 + wx - 1 ;
  }
  if ( wy*zooms[index] > ch )
  {
    wy = ch / zooms[index] ;
    vimage->y2 = vimage->y1 + wy - 1 ;
  }

  cur_window->GetWorkXYWH( cur_window, &xi, &yi, &cw, &ch ) ;
  wind_calc( WC_BORDER, cur_window->window_kind, xi, yi, wx*zooms[index], wy*zooms[index],
            &cx, &cy, &cw, &ch ) ;
  GWSetCurrXYWH( cur_window, cx, cy, cw, ch ) ;
  xi = (int) (0.5+1000.0*(float)vimage->x1/(float)(vimage->raster.fd_w-(double)wx)) ;
  yi = (int) (0.5+1000.0*(float)vimage->y1/(float)(vimage->raster.fd_h-(double)wy)) ;
  GWSetHSlider( cur_window, xi ) ;
  GWSetVSlider( cur_window, yi ) ;
  wxe = (int) (0.5+1000.0*(float)wx/(float)vimage->raster.fd_w) ;
  whe = (int) (0.5+1000.0*(float)wy/(float)vimage->raster.fd_h) ;
  GWSetHSliderSize( cur_window, wxe ) ;
  GWSetVSliderSize( cur_window, whe ) ;

  GWRePaint( cur_window ) ;

  update_zview(cur_window) ;
  if (vimage->zoom_level == 1)
  {
    free(vimage->zoom.fd_addr) ;
    vimage->zoom.fd_addr = NULL ;
  }

  return(0) ;
}

void traite_main(void)
{
  GEM_WINDOW    *cur_window = GemApp.CurrentGemWindow ;
  VXIMAGE       *vimage ;
  int xyarray[8] ;
  int cxy[4] ;
  int xm1, ym1, xm2, ym2, bouton, dummy ;
  int xi, yi, wx, wy ;
  int posx, posy ;
  int new ;
  int cont = 1 ;
  int hm = config.rt_hidemouse ;
  int zoom_what ;

  if ( cur_window == NULL ) return ;
  vimage = cur_window->Extension ;

  if ( vimage->zoom_level != 1 ) return ;
  posx = vimage->x1 ;
  posy = vimage->y1 ;
  cur_window->GetWorkXYWH( cur_window, &xi, &yi, &wx, &wy) ;
  cxy[0] = xi ;          cxy[1] = yi ;
  cxy[2] = xi+wx-1 ;     cxy[3] = yi+wy-1 ;
  if (cxy[2] > Xmax)     cxy[2] = Xmax ;
  if (cxy[3] > Ymax)     cxy[3] = Ymax ;
  vs_clip(handle, 1, cxy) ;
  xyarray[4] = xi ;      xyarray[5] = yi ;
  xyarray[6] = xi+wx-1 ; xyarray[7] = yi+wy-1 ;
  wind_update(BEG_UPDATE) ;
  graf_mkstate(&xm1, &ym1, &bouton, &dummy) ;
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART )
  {
    zoom_what           = RTZ_SCREEN ;
    config.rt_hidemouse = 1 ;
  }
  while (cont)
  {
    graf_mkstate(&xm2, &ym2, &bouton, &dummy) ;
    if ((xm2 != xm1) || (ym1 != ym2))
    {
      posx = posx-xm2+xm1 ;
      posy = posy-ym2+ym1 ;
      if (posx < 0) posx = 0 ;
      if (posy < 0) posy = 0 ;
      if (posx+wx >= vimage->raster.fd_w)
        posx = vimage->raster.fd_w-wx ;
      if (posy+wy >= vimage->raster.fd_h)
        posy = vimage->raster.fd_h-wy ;
      xyarray[0] = posx ;      xyarray[1] = posy ;
      xyarray[2] = posx+wx-1 ; xyarray[3] = posy+wy-1 ;
      v_hide_c(handle) ;
      vro_cpyfm(handle, S_ONLY, xyarray, &vimage->raster, &screen) ;
      v_show_c(handle, 1) ;
      if ( config.use_rtzoom )
      {
        vs_clip(handle, 0, cxy) ;
        rtzoom_display( xm2, ym2, zoom_what ) ;
        vs_clip(handle, 1, cxy) ;
      }
      xm1 = xm2 ; ym1 = ym2 ;
    }
    cont = (xm1 >= xi) && (ym1 >= yi) & (xm1 < xi+wx) && (ym1 < yi+wy) && bouton ;
  }

  wind_update(END_UPDATE) ;
  vs_clip(handle, 0, cxy) ;
  new = (int) (0.5+1000.0*(double)posx/(double)(vimage->raster.fd_w-wx)) ;
  GWSetHSlider( cur_window, new ) ;
  new = (int) (0.5+1000.0*(double)posy/(double)(vimage->raster.fd_h-wy)) ;
  GWSetVSlider( cur_window, new ) ;

  vimage->x1 = posx ;
  vimage->y1 = posy ;
  vimage->x2 = posx+wx-1 ;
  vimage->y2 = posy+wy-1 ;

  update_zview( cur_window ) ;
  config.rt_hidemouse = hm ;
}

void traite_action(GEM_WINDOW *cur_window)
{
  int  num ;
  int  xm, ym, dummy ;
  int  xi, yi, wx, wy ;
  int  mx, my ;
  int  index ;
  int  rgb[3] ;
  char flag[1+NB_TOOLS] ;

  memset( flag, 0, 1+NB_TOOLS ) ;
  /* V‚rifie que le clic est bien … l'int‚rieur de la zone image */
  cur_window->GetWorkXYWH( cur_window,  &xi, &yi, &wx, &wy ) ;
  graf_mkstate(&xm, &ym, &dummy, &dummy) ;
  if ((xm < xi) || (xm >= xi+wx) || (ym < yi) || (ym >= yi+wy)) return ;

  /* Recherche de l'outil actif */
  for (num = 1; num <= NB_TOOLS; num++)
    if (selected(adr_icones, num)) break ;

  switch( num )
  {
    case GOMME       : action_gomme(cur_window) ;
                       break ;
    case POINT       : traite_point(cur_window) ;
                       break ;
    case TRACE       : traite_trace(cur_window) ;
                       break ;
    case AEROSOL     : traite_aerosol(cur_window) ;
                       break ;
    case PEINTURE    : traite_peinture(cur_window) ;
                       break ;
    case BLOC        : traite_bloc() ;
                       break ;
    case TEXTE       : traite_texte(cur_window) ;
                       break ;
    case RECTANGLE   : traite_rectangle(cur_window,0) ;
                       break ;
    case PLAN        : traite_rectangle(cur_window,1) ;
                       break ;
    case CERCLE      : traite_cercle(cur_window,0) ;
                       break ;
    case DISQUE      : traite_cercle(cur_window,1) ;
                       break ;
    case LIGNE       : traite_ligne(cur_window) ;
                       break ;
    case KLIGNE      : traite_kligne(cur_window) ;
                       break ;
    case LOUPE       : graf_mkstate( &mx, &my, &dummy, &dummy ) ;
                       traite_loupe( cur_window, 0, mx, my ) ;
                       break ;
    case TABLEAU     : traite_tableau(cur_window) ;
                       break ;
    case MAIN        : traite_main() ;
                       break ;
    case PINCEAU     : traite_pinceau(cur_window) ;
                       break ;
    case TEMPERATURE : graf_mkstate( &mx, &my, &dummy, &dummy ) ;
                       index = GetRVBForVIMG( cur_window, mx-xi, my-yi, rgb ) ;
                       if ( index < 0 )
                       { /* True Color */
                         index = 17 ;
                         rgb[0] = RGB8BToRGBPM[rgb[0]] ;
                         rgb[1] = RGB8BToRGBPM[rgb[1]] ;
                         rgb[2] = RGB8BToRGBPM[rgb[2]] ;
                         vs_color( handle, index, rgb ) ;
                       }
                       ltype.color  = index ;
                       mtype.color  = index ;
                       ttype.color  = index ;
                       ftype.color  = index ;
                       pencil.color = index ;
                       flag[PALETTE] = 1 ;
                       VToolBarUpdate( flag ) ;
                       break ;
  }
}

LDV_STATUS traite_ldvundo(LDV_MODULE *ldv, LDV_PARAMS *ldv_params, GEM_WINDOW *cur_window)
{
  XUNDO      xundo ;
  VXIMAGE    *vimage = cur_window->Extension ;
  LDV_CAPS   *caps ;
  LDV_IMAGE  ldv_img, out ;
  LDV_STATUS err ;

  memset( &ldv_img, 0, sizeof(ldv_img) ) ;
  memcpy( &ldv_img.Raster, &vimage->raster, sizeof(MFDB) ) ;
  caps = LDVGetNPlanesCaps( ldv, ldv_img.Raster.fd_nplanes ) ;
  if ( caps == NULL ) return( ELDV_NBPLANESNOTSUPPORTED ) ;

  ldv_img.Palette.NbColors = (short) vimage->inf_img.nb_cpal ;
  ldv_img.Palette.Pal      = (VDI_ELEMENTPAL *) vimage->inf_img.palette ;

  memset( &out, 0, sizeof(out) ) ;
  out.RasterFormat = LDVF_SPECFORMAT ;
  out.Raster.fd_nplanes = caps->NbPlanesOut ;
  err = ldv->IModifImg->PreRun( &ldv_img, ldv_params, &out ) ;
  if ( LDV_SUCCESS( err ) )
  {
    memset( &xundo, 0, sizeof(xundo) ) ;
    xundo.spec = caps ;
    xundo.nb_bytes_to_allocate_and_copy = sizeof(LDV_CAPS) ;
    if ( undo_put( cur_window, ldv_params->x1, ldv_params->y1,
                               ldv_params->x2, ldv_params->y2, ULDV, &xundo )
       )
      err = ELDV_NOTENOUGHMEMORY ;
  }

  return( err ) ;
}

LDV_STATUS do_ldv(LDV_MODULE *ldv, GEM_WINDOW *gwnd, LDV_PARAMS *ldv_params)
{
  VXIMAGE    *vimage = gwnd->Extension ;
  LDV_PARAMS ldv_params_before_run ;
  LDV_IMAGE  ldv_img ;
  LDV_CAPS   *caps ;
  LDV_PERF   ldv_perfs ;
  LDV_STATUS err, undo_return ;
  int        xo, yo, wo, ho ;
  int        ww, wh, dummy ;
  int        old_w, old_h ;

  mouse_busy() ;
  /* Undo */
  memcpy( &ldv_params_before_run, ldv_params, sizeof(LDV_PARAMS) ) ;
  undo_return = traite_ldvundo( ldv, &ldv_params_before_run, gwnd ) ;
  if ( !LDV_SUCCESS( undo_return ) )
  {
    /* Prevenir ? */
  }

  /* Appliquer ce LDV a l'image */
  memset( &ldv_img, 0, sizeof(ldv_img) ) ;
  memcpy( &ldv_img.Raster, &vimage->raster, sizeof(MFDB) ) ;
  ldv_img.RasterFormat     = LDVF_SPECFORMAT ;
  ldv_img.Palette.NbColors = (short) vimage->inf_img.nb_cpal ;
  ldv_img.Palette.Pal      = (VDI_ELEMENTPAL *) vimage->inf_img.palette ;
  old_w                    = vimage->raster.fd_w ;
  old_h                    = vimage->raster.fd_h ;
  if ( config.ldv_options & LDVO_SHOWPERF )
    err = LDVDo( ldv, ldv_params, &ldv_img, 0, &ldv_perfs ) ;
  else
    err = LDVDo( ldv, ldv_params, &ldv_img, 0, NULL ) ;
  if ( LDV_SUCCESS( err ) )
  {
    if ( config.ldv_options & LDVO_SHOWPERF )
    {
      GEM_WINDOW    *wnd ;
      MLINES_PARAMS mparams ;

      memset( &mparams, 0, sizeof(MLINES_PARAMS) ) ;
      sprintf( mparams.msg[0], "          LDV Performances :" ) ;
      sprintf( mparams.msg[2], "[LDV] PreRun           : %.02f sec", (float)ldv_perfs.prerun_ms / 1000.0 ) ;
      sprintf( mparams.msg[3], "[LDV] Run              : %.02f sec", (float)ldv_perfs.run_ms / 1000.0 ) ;
      sprintf( mparams.msg[4], "Pre Vision processing  : %.02f sec", (float)ldv_perfs.pre_ldv_ms / 1000.0 ) ;
      sprintf( mparams.msg[5], "Post Vision processing : %.02f sec", (float)ldv_perfs.post_ldv_ms / 1000.0 ) ;
      sprintf( mparams.msg[6], "Total time             : %.02f sec", (float)ldv_perfs.total_ms / 1000.0 ) ;
      mparams.ok_button = 1 ;
      wnd = DisplayStdMLines( &mparams ) ;
      if ( wnd ) GWDoModal( wnd, -1 ) ;
    }
    memcpy( &vimage->raster, &ldv_img.Raster, sizeof(MFDB) ) ;
    vimage->inf_img.nb_cpal = ldv_img.Palette.NbColors ;
    vimage->inf_img.palette = ldv_img.Palette.Pal ;

    vimage->inf_img.largeur = vimage->raster.fd_w ;
    vimage->inf_img.hauteur = vimage->raster.fd_h ;

    if ( vimage->zoom.fd_addr ) free( vimage->zoom.fd_addr ) ;
    vimage->modif      = 0 ;
    vimage->zoom_level = 1 ;

    caps = LDVGetNPlanesCaps( ldv, nb_plane ) ;
    if ( caps && ( caps->Flags & LDVF_AFFECTPALETTE ) )
      set_imgpalette( gwnd->Extension ) ;

    if ( ( old_w != vimage->raster.fd_w ) || ( old_h != vimage->raster.fd_h ) || vimage->zoom.fd_addr )
    {
      vimage->x1           = 0 ;
      vimage->y1           = 0 ;
      vimage->zoom.fd_addr = NULL ; /* La liberation a deja eu lieu */
      open_where( gwnd->window_kind, vimage->raster.fd_w, vimage->raster.fd_h, &xo, &yo, &wo, &ho) ;
      if ( gwnd->is_icon )
      {
        int xywh[4] ;

        xywh[0] = xo ; xywh[1] = yo ;
        xywh[2] = wo ; xywh[3] = ho ;
        GWOnUnIconify( gwnd, xywh ) ;
      }
      else
        GWSetCurrXYWH( gwnd, xo, yo, wo, ho) ;
      gwnd->GetWorkXYWH( gwnd, &dummy, &dummy, &wo, &ho) ;
      vimage->x2 = vimage->x1 + wo - 1 ;
      vimage->y2 = vimage->y1 + ho - 1 ;
      ww = (int) (1000.0*(double)wo/(double)vimage->raster.fd_w) ;
      wh = (int) (1000.0*(double)ho/(double)vimage->raster.fd_h) ;
      GWSetHSlider( gwnd, 1 ) ;
      GWSetVSlider( gwnd, 1) ;
      GWSetHSliderSize( gwnd, ww ) ;
      GWSetVSliderSize( gwnd, wh ) ;
    }
    memset( &vimage->zoom, 0, sizeof(MFDB) ) ;
    set_modif( gwnd ) ;
    update_zview( gwnd ) ;
    GWInvalidate( gwnd ) ;
  }
  else if ( undo_return == 0 ) free_lastundo( gwnd ) ;

  mouse_restore() ;

  return( err ) ;
}

char *get_ldv_msgerr(LDV_STATUS err)
{
  char *msg_err ;

  if ( LDV_SUCCESS( err ) ) return( NULL ) ;

  switch( (int)err )
  {
    case ELDV_INVALIDPARAMETER :     msg_err = msg[MSG_ELDVPINVALID] ;
                                     break ;

    case ELDV_NBPLANESNOTSUPPORTED : msg_err = msg[MSG_ELDVNBPLANES] ;
                                     break ;

    case ELDV_NOTENOUGHMEMORY :      msg_err = msg[MSG_ELDVMEMORY] ;
                                     break ;

    case ELDV_PREVIEWNOTSUPPORTED :  msg_err = msg[MSG_ELDVNOPREV] ;
                                     break ;

    case ELDV_RUNNOTSUPPORTED :      msg_err = msg[MSG_ELDVRUN] ;
                                     break ;

    case ELDV_BADVAPIVERSION  :      msg_err = msg[MSG_ELDVVAPI] ;
                                     break ;

    case ELDV_IMGFORMATMISMATCH :    msg_err = msg[MSG_ELDVIMGFMT] ;
                                     break ;

    case ELDV_GENERALFAILURE :       msg_err = msg[MSG_ELDVGENERAL] ;
                                     break ;

    case ELDV_CANCELLED :            msg_err = NULL ;
                                     break ;

    default :                        msg_err = msg[MSG_ELDVGENERAL] ;
                                     break ;
  }

  return( msg_err ) ;
}

void traite_ldv(GEM_WINDOW *cur_window)
{
  LDV_MODULE *ldv ;
  LDV_PARAMS ldv_params ;
  LDV_STATUS err ;
  char       *msg_err ;

  ldv = LDVSelect( cur_window ) ;
  if ( ldv )
  {
    if ( ApplyLDV( ldv, cur_window, &ldv_params ) == IDOK )
    {
      err = do_ldv( ldv, cur_window, &ldv_params ) ;
      if ( !LDV_SUCCESS( err ) )
      {
        msg_err = get_ldv_msgerr( err ) ;
        if ( msg_err ) form_stop( 1, msg_err ) ;
      }
    }
    LDVUnloadFunctions( ldv ) ;
  }
}

void traite_iconpopup(GEM_WINDOW *cur_window)
{
  OBJECT     *popup ;
  int        clicked ;
  int        mx, my ;
  int        i, dummy ;
  int        st_pop = MSG_POPOPEN ;
  int        ed_pop = MSG_POPLDV ;
#define MSG_HEXDUMP (1+MSG_POPLDV)    /* Hex Dump ajoute en dur */
  int        nb_items = 1 + ed_pop - st_pop + 1 ;
  char       path[PATH_MAX] ;
  char       file[PATH_MAX] ;
  char       mask[20] ;

  if ( cur_window == NULL ) return ;
 
  popup = popup_make( nb_items, 20 ) ;
  if ( popup == NULL ) return ;
  for ( i = st_pop; i <= ed_pop; i++ )
  {
    strcpy( popup[1+i-MSG_POPOPEN].ob_spec.free_string, msg[i] ) ;
    popup[1+i-st_pop].ob_flags |= SELECTABLE ;
  }

  /* Ajout Hex Dump */
  strcpy( popup[1+MSG_HEXDUMP-MSG_POPOPEN].ob_spec.free_string, "  Hexa Dump ... " ) ;
  popup[1+MSG_HEXDUMP-st_pop].ob_flags |= SELECTABLE ;

  graf_mkstate( &mx, &my, &dummy, &dummy ) ;
  clicked = popup_formdo( &popup, mx-16, my, 1, 0 ) ;
  popup_kill( popup, nb_items ) ;

  switch ( st_pop+clicked-1 )
  {
    case MSG_POPOPEN    : if ( cur_window->is_icon ) cur_window->OnUnIconify( cur_window, cur_window->xywh_bicon ) ;
                          break ;

    case MSG_POPMAX     : if ( cur_window->is_icon ) cur_window->OnUnIconify( cur_window, cur_window->xywh_bicon ) ;
                          PostMessage( cur_window, WM_FULLED, NULL ) ;
                          break ;

    case MSG_POPPALETTE : traite_palette() ;
                          break ;
    case MSG_POPINFO    : traite_info( cur_window ) ;
	                      break ;

    case MSG_POPSAVE    : traite_sauves( cur_window, 0 ) ;
                          break ;

    case MSG_POPSAVEAS  : traite_sauves( cur_window, 1 ) ;
                          break ;

    case MSG_POPCLOSE   : GWDestroyWindow( cur_window ) ;
                          break ;

    case MSG_HEXDUMP    :
    case MSG_POPRUN     : if ( st_pop+clicked-1 == MSG_POPRUN ) strcpy( mask, "*.PRG" ) ;
                          else                                  strcpy( mask, "*.*" )  ;
                          sprintf( path, "%s\\%s", init_path, mask ) ;
                          if ( file_name( path, "", file ) == 1 )
                          {
                            if ( mask[2] == 'P' )
                            {
                              if ( Multitos ) Pexec( 100, file, NULL, NULL ) ;
                              else            Pexec(   0, file, NULL, NULL ) ;
                            }
                            else CreateHexDump( file ) ;
                          }
                          break ;

     case MSG_POPLDV    : traite_ldv( cur_window ) ;
                          break ;
 }
}

void traite_tab(GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage ;

  if ( gwnd == NULL ) return ;
  vimage = gwnd->Extension ;

  switch(config.color_protect)
  {
    case 0 :
    case 1 : config.color_protect = 2 ;
             break ;
    case 2 : config.color_protect = 0 ;
             break ;
  }
  set_imgpalette( vimage ) ;
}

void traite_imprime(GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage = NULL ;
  INFO_IMAGE inf ;
  MFDB       raster ;

  if ( gwnd != NULL )
  {
    vimage = gwnd->Extension ;
    memcpy(&raster, &vimage->raster, sizeof(MFDB)) ;
    memcpy(&inf, &vimage->inf_img, sizeof(INFO_IMAGE)) ;
  }
  else
  {
    memset(&raster, 0, sizeof(MFDB)) ;
    memset(&inf, 0, sizeof(INFO_IMAGE)) ;
  }
  switch(print_image(&raster, &inf))
  {
    case PNOGDOS   : form_stop(1, msg[MSG_PNOGDOS]) ;
                     break ;
    case PTIMEOUT  : form_stop(1, msg[MSG_PTIMEOUT]) ;
                     break ;
    case PWRITERR  : form_stop(1, msg[MSG_PWRITERR]) ;
                     break ;
    case PNOHANDLE : form_stop(1, msg[MSG_PNOHANDLE]) ;
                     break ;
    case PROTERR   : form_error(8) ;
                     break ;
    case PNODRIVER : form_stop(1, msg[MSG_PNODRIVER]) ;
                     break ;
  }
}

void bconv_inform_error(char *name, int err, BATCH_CONV *batch_conv)
{
  char buf[200] ;

  batch_conv->nb_bconv_fails++ ;
  if ( batch_conv->err_stream == NULL )
  {
    batch_conv->err_stream = fopen( batch_conv->bconv_errfile, "wb+" ) ;
    sprintf( buf, msg[MSG_BCONVERR], batch_conv->bconv_errfile ) ;
    fwrite( buf, strlen(buf), 1, batch_conv->err_stream ) ;
  }
  if ( batch_conv->err_stream )
  {
    char msg_werr[50], *p ;

    sprintf( buf, msg[MSG_ERRCONV], name ) ;
    switch( err )
    {
      case -1  :
      case -2  : strcpy( msg_werr, 1+msg[MSG_WRITEERROR] ) ;
                 p = strchr( msg_werr, '.' ) ;
                 if ( p ) *p = 0 ;
                 sprintf( buf, "%s\n", msg_werr ) ;
                 break ;
      case -3  : strcat( buf, msg[MSG_CATAMEM] ) ;
                 break ;
      case -4  : 
      case -10 : strcat( buf, msg[MSG_BCONVOUTERR] ) ;
                 break ;
      case -11 : sprintf( buf, msg[MSG_BCONVMOVERR], name ) ;
                 break ;
      case -12 : sprintf( buf, msg[MSG_BCONVMOVERR], name ) ;
                 break ;
      default  : strcat( buf, "???\n" ) ;
                 break ;
    }
    fwrite( buf, strlen(buf), 1, batch_conv->err_stream ) ;
  }
}

void ManageSrc(BATCH_CONV *batch_conv, char *name)
{
  char dst[PATH_MAX] ;
  char *slash ;

  switch( batch_conv->bconv->manage_src )
  {
    case MS_DONOTHING :
                        break ;

    case MS_REMOVESRC : if ( unlink( name ) ) bconv_inform_error( name, -11, batch_conv ) ;
                        break ;

    case MS_MOVESRC   : slash = strrchr( name, '\\' ) ;
                        if ( slash ) sprintf( dst, "%s\\%s", batch_conv->bconv->dst_movepath, 1+slash ) ;
                        else         sprintf( dst, "%s\%s", batch_conv->bconv->dst_movepath, name ) ;
                        if ( MoveFile( name, dst ) ) bconv_inform_error( name, -12, batch_conv ) ;
                        break ;
  }
}

#pragma warn -par
void conv_img(char *name, DTA *dta, void *user_data)
{
  BATCH_CONV *batch_conv = (BATCH_CONV *) user_data ;
  INFO_IMAGE inf ;
  MFDB       out ;
  long       loutfmt ;
  int        old_std_vdi = UseStdVDI ;
  int        err = 0 ;
  int        pc, do_it ;
  char       name_out[200] ;
  char       *nom, *c ;

  if ( batch_conv->stop_conv ) return ;

  UseStdVDI   = 0 ;
  inf.palette = NULL ;
  out.fd_addr = NULL ;
  if ( DImgGetIIDFromFile( name ) != 0 )
  {
    memset( &out, 0, sizeof(MFDB) ) ;
    err = img_format( name, &inf ) ;
    if ( !err )
    {
      out.fd_nplanes = -1 ; /* Garder le meme nombre de plans */
      do_it          = 1 ;

      loutfmt = batch_conv->bconv->inf.lformat ;
      if ( loutfmt == IID_GIF )
      {
        if ( batch_conv->bconv->inf.nplans > 8 )
        {
          if ( batch_conv->bconv->bconv_handle_imcomp == 1 ) do_it          = 0 ;
          else                                               out.fd_nplanes = 8 ;
        }
      }
      else
      if ( loutfmt == IID_TIFF )
      {
        if ( batch_conv->bconv->inf.nplans > 8 )
        {
          if ( batch_conv->bconv->bconv_handle_imcomp == 1 ) do_it          = 0 ;
          else                                               out.fd_nplanes = 8 ;
        }
      }
      else
      if ( loutfmt == IID_TARGA )
      {
        if ( batch_conv->bconv->inf.nplans <= 8 )
        {
          if ( batch_conv->bconv->bconv_handle_imcomp == 1 ) do_it          = 0 ;
          else                                               out.fd_nplanes = 24 ;
        }
      }
      else
      if ( loutfmt == IID_JPEG )
      {
        if ( batch_conv->bconv->inf.nplans <= 8 )
        {
          if ( batch_conv->bconv->bconv_handle_imcomp == 1 ) do_it          = 0 ;
          else                                               out.fd_nplanes = 24 ;
        }
      }

      nom = strrchr(name, '\\') ;
      if ( do_it && nom )
      {
        IMG_MODULE* img_module ;

        nom++ ;
        c = strrchr(nom, '.') ;
        if ( c ) *c = 0 ;
        img_module = DImgGetModuleFromIID( batch_conv->bconv->inf.lformat ) ;
        if ( img_module == NULL )
        {
          do_it = 0 ;
          err   = -10 ;
        }
        else
        {
          sprintf( name_out, "%s\\%s.%s", batch_conv->bconv->dst_path, nom, img_module->Capabilities.file_extension ) ;
          if ( c != NULL ) *c = '.' ;
          if ( FileExist( name_out ) && ( batch_conv->bconv->manage_dst == MD_CANCELOPE ) )
          {
            do_it = 0 ;
            err   = -2 ;
          }
        }
      }
      if ( do_it )
      {
        char buf[50] ;

        Force16BitsLoad = ( batch_conv->bconv->inf.nplans == 16 ) ;
        if ( batch_conv->wconvprog && ( batch_conv->total_nb_files_expected >= 0 ) )
        {
          pc = (int) ( ( batch_conv->nb_files * 100L ) / batch_conv->total_nb_files_expected ) ;
          batch_conv->nb_files++ ;
          StdProgWText( batch_conv->wconvprog, 0, msg[MSG_LOADINGIMG] ) ;
          StdProgWText( batch_conv->wconvprog, 1, name ) ;
          sprintf( buf, "%ld/%ld", batch_conv->nb_files, batch_conv->total_nb_files_expected ) ;
          batch_conv->stop_conv = batch_conv->wconvprog->ProgPc( batch_conv->wconvprog, pc, buf ) ;
        }
        if ( !batch_conv->stop_conv )
        {
          err = load_picture( name, &out, &inf, NULL ) ;
          if ( !err )
          {
            inf.compress = batch_conv->bconv->inf.compress ;
            inf.quality  = batch_conv->bconv->inf.quality ;
            inf.nplans   = out.fd_nplanes ;
            StdProgWText( batch_conv->wconvprog, 0, msg[MSG_SAVINGIMG] ) ;
            StdProgWText( batch_conv->wconvprog, 1, name_out ) ;
            inf.lformat = loutfmt ;
            err = save_picture( name_out, &out, &inf, NULL ) ;
          }
        }
      }
      else if ( err == 0 ) err = -10 ;
    }
    if ( out.fd_addr ) free( out.fd_addr ) ;
    if ( inf.palette ) free( inf.palette ) ;
    if ( err ) bconv_inform_error( name, err, batch_conv ) ;
    else       ManageSrc( batch_conv, name ) ;
  }
  UseStdVDI = old_std_vdi ;
}
#pragma warn +par

void traite_batch_conversion(void)
{
  BATCH_CONV batch_conv ;
  int        i, analyse = img_analyse ;
  char       buffer[PATH_MAX] ;

  shareware_reminder( 2 ) ;

  memset( &batch_conv, 0, sizeof(batch_conv) ) ;
  strcpy( batch_conv.bconv_errfile, "CONVERT.ERR" ) ;
  batch_conv.bconv = (BCONV_PARAMS *) calloc( sizeof(BCONV_PARAMS), 1 ) ;
  if ( batch_conv.bconv == NULL )
  {
    form_error(8) ;
    return ;
  }
  sprintf( batch_conv.bconv->log_file, "%s\\RFILES.LOG", config.path_temp ) ;
  if ( FBConv( batch_conv.bconv ) == 1 )
  {
    img_analyse                        = 0 ;
    batch_conv.total_nb_files_expected = batch_conv.bconv->total_nb_files_expected ;
    if ( batch_conv.total_nb_files_expected > 0 )
    {
      batch_conv.wconvprog = DisplayStdProg( msg[MSG_LOADINGIMG], "", "", 0 ) ;
      GWSetWindowCaption( batch_conv.wconvprog, msg[MSG_BCONV] ) ;
      mouse_busy() ;
      batch_conv.stop_conv = 0 ;
      if ( batch_conv.bconv->rfile[0].recurse )
      {
        FILE *stream = fopen( batch_conv.bconv->log_file, "rb" ) ;
        char *cr ;

        if ( stream )
        {
          while ( fgets( buffer, PATH_MAX, stream ) )
          {
            cr = strchr( buffer, '\r' ) ;
            if ( cr ) *cr = 0 ;
            cr = strchr( buffer, '\n' ) ;
            if ( cr ) *cr = 0 ;
            conv_img( buffer, NULL, &batch_conv ) ;
          }
          fclose( stream ) ;
        }
      }
      else
      {
        for ( i = 0; i < NB_MAX_RFILES; i++ )
          if ( batch_conv.bconv->rfile[i].path[0] != 0 )
            find_files( config.flags & FLG_LONGFNAME, batch_conv.bconv->rfile[i].path, batch_conv.bconv->rfile[i].mask, conv_img, &batch_conv ) ;
      }
      img_analyse = analyse ;
      mouse_restore() ;
      if ( batch_conv.err_stream )
      {
        sprintf( buffer, msg[MSG_CATAEND], batch_conv.nb_bconv_fails ) ;
        fwrite( buffer, strlen(buffer), 1, batch_conv.err_stream ) ;
        fclose( batch_conv.err_stream ) ;
        batch_conv.err_stream = NULL ;
        sprintf( buffer, msg[MSG_ERRSEEFILE], batch_conv.bconv_errfile ) ;
        form_stop( 1, buffer ) ;
      }
      GWDestroyWindow( batch_conv.wconvprog ) ;
    }
  }
  unlink( batch_conv.bconv->log_file ) ;
  free( batch_conv.bconv ) ;
}
