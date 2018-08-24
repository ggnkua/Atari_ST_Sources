/************************************/
/*----------- GSTEVN.C -------------*/
/* Module de gestion des ‚vŠnements */
/************************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include "..\tools\stdprog.h"
#include "..\tools\stdinput.h"
#include "..\tools\xgem.h"
#include "..\tools\gwindows.h"
#include "..\tools\rasterop.h"
#include "..\tools\rzoom.h"

#include     "defs.h"
#include     "undo.h"
#include     "snap.h"
#include   "walbum.h"
#include   "rtzoom.h"
#include  "touches.h"
#include  "actions.h"
#include  "fullscr.h"
#include  "figures.h"
#include "visionio.h"
#include "filtrage.h"
#include "vtoolbar.h"
#include "hexdump.h"

#include "forms\fgeneral.h"
#include "forms\ftexte.h"
#include "forms\fformes.h"
#include "forms\fgomme.h"
#include "forms\fpref.h"
#include "forms\fbaratin.h"
#include "forms\fpencil.h"
#include "forms\faerosol.h"
#include "forms\fbloc.h"
#include "forms\falbum.h"
#include "forms\fsym.h"
#include "forms\fhisto.h"
#include "forms\ftaille.h"
#include "forms\fpal.h"

static int last_icon ;


void update_view(GEM_WINDOW *gw)
{
  VXIMAGE *vimage ;
  int zooms[]  = {1, 2, 4, 8, 16} ;
  int x, y, w, h ;
  int rc, rl ;
  int xi, yi, wx, wy ;
  int index ;

  if ( gw == NULL ) return ;
  vimage = (VXIMAGE *) gw->Extension ;

  for (index = 0; index < 4; index++)
    if (vimage->zoom_level == zooms[index]) break ;
  gw->GetWorkXYWH( gw, &x, &y, &w, &h ) ;
  wx = w/zooms[index] ;
  wy = h/zooms[index] ;
  GWGetHSlider( gw, &xi ) ;
  GWGetVSlider( gw, &yi ) ;
  rc = (int) (((long)xi*(long)(vimage->raster.fd_w-wx))/1000L) ;
  rl = (int) (((long)yi*(long)(vimage->raster.fd_h-wy))/1000L) ;
  vimage->x1 = rc ;      vimage->y1 = rl ;
  vimage->x2 = rc+wx-1 ; vimage->y2 = rl+wy-1 ;
}

void update_zview(GEM_WINDOW *gw)
{
  VXIMAGE *vimage ;
  float echx, echy, ech ;
  char   flag[1+NB_TOOLS] ;


  memset(flag, 0, 1+NB_TOOLS) ;
  flag[ZOOM_BOX] = 1 ;

  if (gw == NULL)
  {
    VToolBarUpdate( flag ) ;
    return ;
  }

  vimage = (VXIMAGE *) gw->Extension ;

  echx = (float)adr_icones[ZOOM_BOX].ob_width/(float)vimage->raster.fd_w ;
  echy = (float)adr_icones[ZOOM_BOX].ob_height/(float)vimage->raster.fd_h ;
  if (echx < echy) ech = echx ;
  else             ech = echy ;
  vimage->zw  = (int) ((float)vimage->raster.fd_w*ech) ;
  vimage->zh  = (int) ((float)vimage->raster.fd_h*ech) ;
  vimage->zx  = (adr_icones[ZOOM_BOX].ob_width-vimage->zw)/2 ;
  vimage->zy  = (adr_icones[ZOOM_BOX].ob_height-vimage->zh)/2 ;
  vimage->zzw = (int) ((float)(vimage->x2-vimage->x1)*ech) ;
  vimage->zzh = (int) ((float)(vimage->y2-vimage->y1)*ech) ;
  vimage->zzx = (int) ((float)vimage->x1*ech) ;
  vimage->zzy = (int) ((float)vimage->y1*ech) ;

  adr_icones[ZOOM_IN].ob_x      = vimage->zx ;
  adr_icones[ZOOM_IN].ob_y      = vimage->zy ;
  adr_icones[ZOOM_IN].ob_width  = vimage->zw ;
  adr_icones[ZOOM_IN].ob_height = vimage->zh ;

  adr_icones[ZOOM_VUE].ob_x      = vimage->zzx ;
  adr_icones[ZOOM_VUE].ob_y      = vimage->zzy ;
  adr_icones[ZOOM_VUE].ob_width  = vimage->zzw ;
  adr_icones[ZOOM_VUE].ob_height = vimage->zzh ;
  VToolBarUpdate( flag ) ;
}

void decheck_moutils(void)
{
  menu_icheck(GemApp.Menu, M_OPOINT, 0) ;
  menu_icheck(GemApp.Menu, M_OTRACE, 0) ;
  menu_icheck(GemApp.Menu, M_OLIGNE, 0) ;
  menu_icheck(GemApp.Menu, M_ORECTANGLE, 0) ;
  menu_icheck(GemApp.Menu, M_OGOMME, 0) ;
  menu_icheck(GemApp.Menu, M_OPLAN, 0) ;
  menu_icheck(GemApp.Menu, M_OCERCLE, 0) ;
  menu_icheck(GemApp.Menu, M_ODISQUE, 0) ;
  menu_icheck(GemApp.Menu, M_OPEINTURE, 0) ;
  menu_icheck(GemApp.Menu, M_OTEXTE, 0) ;
  menu_icheck(GemApp.Menu, M_OPINCEAU, 0) ;
  menu_icheck(GemApp.Menu, M_OAEROSOL, 0) ;
  menu_icheck(GemApp.Menu, M_OMAIN, 0) ;
  menu_icheck(GemApp.Menu, M_OPALETTE, 0) ;
  menu_icheck(GemApp.Menu, M_OKLIGNE, 0) ;
  menu_icheck(GemApp.Menu, M_OTABLEAU, 0) ;
  menu_icheck(GemApp.Menu, M_OBLOC, 0) ;
  menu_icheck(GemApp.Menu, M_OLOUPE, 0) ;
  menu_icheck(GemApp.Menu, M_OTEMP, 0) ;
}

void set_goodmouse(void)
{
  if (!config.souris_viseur)
  {
    if (mouse.gr_monumber != ARROW)
    {
      mouse.gr_monumber = ARROW ;
      set_mform(&mouse) ;
    }
  }
  else
  {
    if (mouse.gr_monumber != USER_DEF)
    {
      mouse.gr_monumber = USER_DEF ;
      memcpy(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)) ;
      set_mform(&mouse) ;
    }
    else
    if (memcmp(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)))
    {
      mouse.gr_monumber = USER_DEF ;
      memcpy(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)) ;
      set_mform(&mouse) ;
    }
  }
}

int ztool(int num)
{
  switch(num)
  {
    case PALETTE     :
    case TEMPERATURE :
    case POINT       :
    case LOUPE       :
    case ZOOM_VUE    : return(1) ;
    case PEINTURE    : if (ftype.sindex == 8) return(1) ;
                       /* Le remplissage est autoris‚ en zoom s'il */
                       /* Le motif … afficher est plein            */
  }

  return(0) ;
}

void traite_move(GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage ;
  float echx, echy ;
  float x, y ;
  int   zooms[]  = {1, 2, 4, 8, 16} ;
  int   w, h ;
  int   ix, iy, fx, fy ;
  int   lx, ly, lw, lh ;
  int   xi, yi, wx, wy ;
  int   index ;
  int   new ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  for (index = 0; index < 4; index++)
    if ( vimage->zoom_level == zooms[index] ) break ;

  objc_offset(adr_icones, ZOOM_IN, &lx, &ly) ;
  objc_offset(adr_icones, ZOOM_VUE, &ix, &iy) ;
  w  = adr_icones[ZOOM_VUE].ob_width ;
  h  = adr_icones[ZOOM_VUE].ob_height ;
  lw = adr_icones[ZOOM_IN].ob_width ;
  lh = adr_icones[ZOOM_IN].ob_height ;
  my_dragbox(w, h, ix, iy, lx, ly, lw, lh, &fx, &fy) ;
  echx = (float)(vimage->raster.fd_w) ;
  echx = echx/(float)lw ;
  echy = (float)(vimage->raster.fd_h) ;
  echy = echy/(float)lh ;
  gwnd->GetWorkXYWH( gwnd, &xi, &yi, &wx, &wy ) ;
  wx = wx/zooms[index] ;
  wy = wy/zooms[index] ;
  x  = (float)(fx-lx)*echx ;
  vimage->x1 = (int) (0.5+x) ;
  if (vimage->x1 < 0) vimage->x1 = 0 ;
  vimage->x2 = vimage->x1+wx-1 ;
  y = (float)(fy-ly)*echy ;
  vimage->y1 = (int)(0.5+y) ;
  if (vimage->y1 < 0) vimage->y1 = 0 ;
  vimage->y2 = vimage->y1+wy-1 ;
  if (vimage->y2 > vimage->raster.fd_h-1)
    vimage->y2 = vimage->raster.fd_h-1 ;
  adr_icones[ZOOM_VUE].ob_x = fx-lx ;
  adr_icones[ZOOM_VUE].ob_y = fy-ly ;
  new = (int) (0.5+1000.0*(float)vimage->x1/(float)(vimage->raster.fd_w-wx)) ;
  GWSetHSlider( gwnd, new ) ;
  new = (int) (0.5+1000.0*(float)vimage->y1/(float)(vimage->raster.fd_h-wy)) ;
  GWSetVSlider( gwnd, new ) ;
  if ( vimage->zoom_level != 1 )
    traite_loupe( gwnd, vimage->zoom_level, -1, -1 ) ;
  GWRePaint( gwnd ) ;
}

void select_icon(int mx, int my)
{
  VXIMAGE    *vimage ;
  GEM_WINDOW *gwnd = GemApp.CurrentGemWindow ;
  MOUSE_DEF  save ;
  int        num, is_vimg ;

  if ( gwnd == NULL ) return ;
  num = objc_find( adr_icones, 0, 200, mx, my ) ;
  if ( ( num == ZOOM_IN ) || ( num == ZOOM_BOX ) ) return ;
  is_vimg = ( gwnd && ( strcmp( gwnd->ClassName, VIMG_CLASSNAME ) == 0 ) ) ;
  vimage  = (VXIMAGE *) gwnd->Extension ;
  if ( is_vimg && ( vimage->zoom_level != 1 ) )
  {
    if ( !ztool( num ) )
    {
      form_stop( 1, MsgTxtGetMsg(hMsg, MSG_NOTOOLZ)  ) ;
      return ; /* Outil non autoris‚ en zoom */
    }
  }

  if (num != -1)
  {
    int  i ;
    char flag[1+NB_TOOLS];
    
    for (i = 1; i <= NB_TOOLS; i++)
      if (selected(adr_icones, i)) break ;

    if (i == 1+NB_TOOLS) i = num ;
    deselect(adr_icones, i) ;
    if (i != TEMPERATURE) last_icon = i ;
    if (last_icon == TEMPERATURE) last_icon = POINT ;
    select(adr_icones, num) ;
    memset(flag, 0, 1+NB_TOOLS) ;
    flag[i] = flag[num] = 1 ;
    VToolBarUpdate( flag ) ;
    if ( ( num != TEMPERATURE ) && ( num != PALETTE ) )
      decheck_moutils() ;

    switch(num)
    {
      case GOMME       : mouse.gr_monumber = USER_DEF ;
                         if (!config.souris_viseur)
                           memcpy(&mouse.gr_mof, &mf_gomme.gr_mof, sizeof(MFORM)) ;
                         else
                           memcpy(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)) ;
                         set_mform(&mouse) ;
                         menu_icheck(GemApp.Menu, M_OGOMME, 1) ;
                         break ;
      case LOUPE       : mouse.gr_monumber = USER_DEF ;
                         if (!config.souris_viseur)
                           memcpy(&mouse.gr_mof, &mf_loupe.gr_mof, sizeof(MFORM)) ;
                         else
                           memcpy(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)) ;
                         set_mform(&mouse) ;
                         menu_icheck(GemApp.Menu, M_OLOUPE, 1) ;
                         break ;
      case PEINTURE    : mouse.gr_monumber = USER_DEF ;
                         if (!config.souris_viseur)
                           memcpy(&mouse.gr_mof, &mf_peint.gr_mof, sizeof(MFORM)) ;
                         else
                           memcpy(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)) ;
                         set_mform(&mouse) ;
                         menu_icheck(GemApp.Menu, M_OPEINTURE, 1) ;
                         break ;
       case BLOC       : if (!config.souris_viseur)
                           mouse.gr_monumber = POINT_HAND ;
                         else
                         {
                           mouse.gr_monumber = USER_DEF ;
                           memcpy(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)) ;
                         }
                         set_mform(&mouse) ;
                         menu_icheck(GemApp.Menu, M_OBLOC, 1) ;
                         break ;
       case PALETTE    : memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;
                         mouse.gr_monumber = USER_DEF ;
                         memcpy(&mouse.gr_mof, &mf_pencil.gr_mof, sizeof(MFORM)) ;
                         set_mform(&mouse) ;
                         traite_palette( gwnd ) ;
                         deselect(adr_icones, num) ;
                         select(adr_icones, i) ;
                         memset(flag, 0, 1+NB_TOOLS) ;
                         flag[i] = flag[num] = flag[PALETTE] = 1 ;
                         VToolBarUpdate( flag ) ;
                         memcpy(&mouse, &save, sizeof(MOUSE_DEF)) ;
                         set_mform(&mouse) ;
                         break ;
       case TEMPERATURE: if ( gwnd == NULL ) break ;
	                     break ;
	   case TRACE      : menu_icheck(GemApp.Menu, M_OTRACE, 1) ;
	                     set_goodmouse() ;
	                     break ;
	   case POINT      : menu_icheck(GemApp.Menu, M_OPOINT, 1) ;
	                     set_goodmouse() ;
	                     break ;
	   case KLIGNE     : menu_icheck(GemApp.Menu, M_OKLIGNE, 1) ;
	                     set_goodmouse() ;
	                     break ;
	   case LIGNE      : menu_icheck(GemApp.Menu, M_OLIGNE, 1) ;
	                     set_goodmouse() ;
	                     break ;
	   case CERCLE     : menu_icheck(GemApp.Menu, M_OCERCLE, 1) ;
	                     set_goodmouse() ;
	                     break ;
	   case DISQUE     : menu_icheck(GemApp.Menu, M_ODISQUE, 1) ;
	                     set_goodmouse() ;
	                     break ;
	   case RECTANGLE  : menu_icheck(GemApp.Menu, M_ORECTANGLE, 1) ;
	                     set_goodmouse() ;
	                     break ;
	   case PLAN       : menu_icheck(GemApp.Menu, M_OPLAN, 1) ;
	                     set_goodmouse() ;
	                     break ;
	   case TEXTE      : menu_icheck(GemApp.Menu, M_OTEXTE, 1) ;
	                     set_goodmouse() ;
	                     break ;
	   case MAIN       : if (!config.souris_viseur)
                           mouse.gr_monumber = FLAT_HAND ;
                         else
                         {
                           mouse.gr_monumber = USER_DEF ;
                           memcpy(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)) ;
                         }
                         set_mform(&mouse) ;
                         menu_icheck(GemApp.Menu, M_OMAIN, 1) ;
                         break ;
       case PINCEAU    : mouse.gr_monumber = USER_DEF ;
                         memcpy(&mouse.gr_mof, &mf_pencil.gr_mof, sizeof(MFORM)) ;
                         menu_icheck(GemApp.Menu, M_OPINCEAU, 1) ;
                         set_mform(&mouse) ;
                         break ;
       case AEROSOL    : mouse.gr_monumber = USER_DEF ;
                         menu_icheck(GemApp.Menu, M_OAEROSOL, 1) ;
                         if (!config.souris_viseur)
                           memcpy(&mouse.gr_mof, &mf_aerosol.gr_mof, sizeof(MFORM)) ;
                         else
                           memcpy(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)) ;
                         set_mform(&mouse) ;
                         break ;
	   case TABLEAU    : menu_icheck(GemApp.Menu, M_OTABLEAU, 1) ;
	                     set_goodmouse() ;
	                     break ;
       case ZOOM_VUE   : mouse_busy() ;
                         traite_move( gwnd ) ;
                         deselect(adr_icones, num) ;
                         select(adr_icones, i) ;
                         memset(flag, 0, 1+NB_TOOLS) ;
                         flag[i] = flag[ZOOM_BOX] = flag[PALETTE] = 1 ;
                         VToolBarUpdate( flag ) ;
                         mouse_restore() ;
                         break ;
       default         : set_goodmouse() ;
	                     break ;
    }
  }
}

void traite_espace(GEM_WINDOW *gwnd)
{
  VXIMAGE   *vimage ;
  MOUSE_DEF save ;
  EVENT     ev ;
  int       i ;
  int       dummy, bouton ;
  char      flag[1+NB_TOOLS];

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;
  if ( vimage->zoom_level != 1 )
  {
    form_stop(1, MsgTxtGetMsg(hMsg, MSG_NOTOOLZ) ) ;
    return ;
  }

  memcpy(&save, &mouse, sizeof(MOUSE_DEF)) ;

  for (i = 1; i <= NB_TOOLS; i++)
    if (selected(adr_icones, i)) break ; 

  if ((i == 1+NB_TOOLS) || (i == MAIN)) return ;
  deselect(adr_icones, i) ;
  if (!config.souris_viseur) mouse.gr_monumber = FLAT_HAND ;
  else
  {
    mouse.gr_monumber = USER_DEF ;
    memcpy(&mouse.gr_mof, &mf_viseur.gr_mof, sizeof(MFORM)) ;
  }
  set_mform(&mouse) ;
  select(adr_icones, MAIN) ;
  memset(flag, 0, 1+NB_TOOLS) ; 
  flag[i] = flag[MAIN] = 1 ;
  VToolBarUpdate( flag ) ;

  do
  {
    graf_mkstate(&dummy, &dummy, &bouton, &dummy) ;
  }
  while (bouton != 1) ;
  traite_main( gwnd ) ;
  ev.ev_mflags     = MU_KEYBD | MU_TIMER ;
  ev.ev_mtlocount  = 200 ;
  ev.ev_mthicount  = 0 ;
  while (EvntMulti(&ev) != MU_TIMER) ;
  select(adr_icones, i) ;
  deselect(adr_icones, MAIN) ;
  VToolBarUpdate( flag ) ;
  set_mform(&save) ;
}

void select_zoom(GEM_WINDOW *gwnd, int mzoom)
{
  VXIMAGE *vimage ;
  int     mx, my, dummy ;
  int     last ;

  if ( gwnd == NULL ) return ;
  vimage = (VXIMAGE *) gwnd->Extension ;

  last = vimage->zoom_level ;
  switch(mzoom)
  {
    case M_Z11  : vimage->zoom_level = 1 ;
                  break ;
    case M_Z21  : vimage->zoom_level = 2 ;
                  break ;
    case M_Z41  : vimage->zoom_level = 4 ;
                  break ;
    case M_Z81  : vimage->zoom_level = 8 ;
                  break ;
    case M_Z161 : vimage->zoom_level = 16 ;
                  break ;
  }

  graf_mkstate( &mx, &my, &dummy, &dummy ) ;
  traite_loupe( gwnd, last, mx, my ) ;
}

void traite_snapshot_key(int key)
{
  if ( key == config.snap_keyviaconfig )  snap( 1 ) ;
  else
  if ( key == config.snap_keydirect ) snap( 0 ) ;
}

int OnAppKeyPressed(int key)
{
  int xt, yt, dummy ;
  int code = GW_EVTCONTINUEROUTING ;
  int mx, my ;

  WndToolBar->GetWorkXYWH( WndToolBar, &xt, &yt, &dummy, &dummy ) ;
  graf_mkstate( &mx, &my, &dummy, &dummy ) ;

  switch( key )
  {
	case NOUVEAU     : traite_nouveau() ;
	                   break ;

	case OUVRIR      : traite_ouvre(0) ;
				       break ;

	case IMPRIMER    : traite_imprime( NULL ) ;
	                   break ;

	case QUITTER     : code = GW_EVTQUITAPP ;
					   break ;

	case PGENERAL    : traite_pgeneral() ;
	                   break ;

	case PTEXTE      : traite_ptexte() ;
	                   break ;

	case PFORMES     : traite_pformes() ;
	                   break ;

	case PGOMME      : traite_pgomme() ;
	                   break ;

	case STD_PAL     : traite_tab( NULL ) ;
	                   break ;

	case PREF        : traite_preferences() ;
                       set_goodmouse() ;
	                   break ;

    case F1          : mx = xt+adr_icones[POINT].ob_x+8 ;
	                   my = yt+adr_icones[POINT].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case SF1         : mx = xt+adr_icones[TRACE].ob_x+8 ;
	                   my = yt+adr_icones[TRACE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case F2          : mx = xt+adr_icones[PINCEAU].ob_x+8 ;
	                   my = yt+adr_icones[PINCEAU].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case SF2         : mx = xt+adr_icones[AEROSOL].ob_x+8 ;
	                   my = yt+adr_icones[AEROSOL].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case F3          : mx = xt+adr_icones[KLIGNE].ob_x+8 ;
	                   my = yt+adr_icones[KLIGNE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case SF3         : mx = xt+adr_icones[LIGNE].ob_x+8 ;
	                   my = yt+adr_icones[LIGNE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case F4          : mx = xt+adr_icones[CERCLE].ob_x+8 ;
	                   my = yt+adr_icones[CERCLE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case SF4         : mx = xt+adr_icones[RECTANGLE].ob_x+8 ;
	                   my = yt+adr_icones[RECTANGLE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case F5          : mx = xt+adr_icones[DISQUE].ob_x+8 ;
	                   my = yt+adr_icones[DISQUE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case SF5         : mx = xt+adr_icones[PLAN].ob_x+8 ;
	                   my = yt+adr_icones[PLAN].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case F6          : mx = xt+adr_icones[PEINTURE].ob_x+8 ;
	                   my = yt+adr_icones[PEINTURE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case SF6         : mx = xt+adr_icones[GOMME].ob_x+8 ;
	                   my = yt+adr_icones[GOMME].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case F7          : mx = xt+adr_icones[TEXTE].ob_x+8 ;
	                   my = yt+adr_icones[TEXTE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case SF7         : mx = xt+adr_icones[LOUPE].ob_x+8 ;
	                   my = yt+adr_icones[LOUPE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case F8          : mx = xt+adr_icones[TEMPERATURE].ob_x+8 ;
	                   my = yt+adr_icones[TEMPERATURE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case SF8         : mx = xt+adr_icones[TABLEAU].ob_x+8 ;
	                   my = yt+adr_icones[TABLEAU].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case F9          : mx = xt+adr_icones[MAIN].ob_x+8 ;
	                   my = yt+adr_icones[MAIN].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case SF9         : mx = xt+adr_icones[BLOC].ob_x+8 ;
	                   my = yt+adr_icones[BLOC].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;

	case F10         : mx = xt+adr_icones[PALETTE].ob_x+8 ;
	                   my = yt+adr_icones[PALETTE].ob_y+8 ;
	                   select_icon( mx, my ) ;
	                   break ;
  }

  traite_snapshot_key( key ) ;

  return( code ) ;
}

void make_undo_item(UNDO_DEF *undo)
{
  int  i ;
  char buffer[80] ;
  char *pt, *pt1 ;

  strcpy( buffer, MsgTxtGetMsg(hMsg, MSG_UNDO)  ) ;
  if ( undo )
  {
    i = undo->mitem ;
    if ( i )
    {
      pt = strchr( buffer+3, ' ' ) ;
      if ( pt )
      {
        pt++ ;
        pt1 = MsgTxtGetMsg(hMsg, i+MSG_UNDO)  ;
        while ( *pt1 ) *pt++ = *pt1++ ;
      }
    }
  }
  menu_text( GemApp.Menu, M_UNDO, buffer ) ;
}

void OnAppUpdateGUI(void)
{
  GEM_WINDOW *gwnd = GemApp.CurrentGemWindow ;
  OBJECT     *menu ;
  VXIMAGE    *vimage = NULL ;
  UNDO_DEF   *undo = NULL ;

  if ( gwnd && ( strcmp( gwnd->ClassName, VIMG_CLASSNAME ) == 0 ) )
  {
    vimage = (VXIMAGE *) gwnd->Extension ;
    undo   = GetUndoBuffer( vimage ) ;
  }

  menu = GemApp.Menu ;
  GWSetMenuStatus( 1 ) ;
  menu_ienable( menu, M_BARATIN, 1 ) ; /* Cas special : sinon A propos de ... reste grise ??? */
  make_undo_item( undo ) ;
  if ( vimage )
  {
    int check_zoom = 0 ;

    if ( undo == NULL )
    {
      menu[M_UNDO].ob_state |= DISABLED ;
      if ( vimage->Redo == NULL ) menu[M_CLEARBUF].ob_state |= DISABLED ;
    }

	  if ( vimage->Redo == NULL ) menu[M_REFAIRE].ob_state |= DISABLED ;

    switch( vimage->zoom_level )
    {
      case 1  : if ( ( menu[M_Z11].ob_state & CHECKED ) == 0 ) check_zoom = M_Z11 ;
                break ;
      case 2  : if ( ( menu[M_Z21].ob_state & CHECKED ) == 0 ) check_zoom = M_Z21 ;
                break ;
      case 4  : if ( ( menu[M_Z41].ob_state & CHECKED ) == 0 ) check_zoom = M_Z41 ;
                break ;
      case 8  : if ( ( menu[M_Z81].ob_state & CHECKED ) == 0 ) check_zoom = M_Z81 ;
                break ;
      case 16 : if ( ( menu[M_Z161].ob_state & CHECKED ) == 0 ) check_zoom = M_Z161 ;
                break ;
    }
    if ( check_zoom != 0 )
    {
      menu_icheck( GemApp.Menu, M_Z11, 0 ) ;
      menu_icheck( GemApp.Menu, M_Z21, 0 ) ;
      menu_icheck( GemApp.Menu, M_Z41, 0 ) ;
      menu_icheck( GemApp.Menu, M_Z81, 0 ) ;
      menu_icheck( GemApp.Menu, M_Z161, 0 ) ;
      menu_icheck( GemApp.Menu, check_zoom, 1 ) ;
    }

    if ( !GWIsWindowValid( vclip.gwindow ) )
	  {
	    menu[M_COUPE].ob_state   |= DISABLED ;
	    menu[M_COPIE].ob_state   |= DISABLED ;
	    menu[M_EFFACE].ob_state  |= DISABLED ;
	    menu[M_NEGATIF].ob_state |= DISABLED ;
	  }

	  if ( nb_colors < 256 ) menu[M_CONVOLUTION].ob_state |= DISABLED ; /*menu_ienable( GemApp.Menu, M_CONVOLUTION, 0 ) ;*/
	  if ( Truecolor )       menu[M_PALETTE].ob_state |= DISABLED ; /*menu_ienable( GemApp.Menu, M_PALETTE, 0 ) ;*/
  }
  else
  {
    if ( gwnd && ( strcmp( gwnd->ClassName, HEXDUMP_CLASSNAME ) == 0 ) )
    {
	    menu[M_FERME].ob_state  &= ~DISABLED ;
	    menu[M_SAUVE].ob_state  &= ~DISABLED ;
	    menu[M_SAUVES].ob_state &= ~DISABLED ;
    }
    else
    {
	    menu[M_FERME].ob_state  |= DISABLED ;
	    menu[M_SAUVE].ob_state  |= DISABLED ;
	    menu[M_SAUVES].ob_state |= DISABLED ;
    }
    menu[M_UNDO].ob_state        |= DISABLED ;
    menu[M_CLEARBUF].ob_state    |= DISABLED ;
	  menu[M_REFAIRE].ob_state     |= DISABLED ;
	  menu[M_COUPE].ob_state       |= DISABLED ;
    menu[M_COLLE].ob_state       |= DISABLED ;
	  menu[M_COPIE].ob_state       |= DISABLED ;
    menu[M_EFFACE].ob_state      |= DISABLED ;
    menu[M_NEGATIF].ob_state     |= DISABLED ;
    menu[M_SELECTIONNE].ob_state |= DISABLED ;
    menu[M_PLEIN].ob_state       |= DISABLED ;
    menu[M_PLEINECRAN].ob_state  |= DISABLED ;
    menu[M_INFO].ob_state        |= DISABLED ;
    menu[M_CONVERSION].ob_state  |= DISABLED ;
    menu[M_Z11].ob_state         |= DISABLED ;
    menu[M_Z21].ob_state         |= DISABLED ;
    menu[M_Z41].ob_state         |= DISABLED ;
    menu[M_Z81].ob_state         |= DISABLED ;
    menu[M_Z161].ob_state        |= DISABLED ;
    menu[M_SYMETRIE].ob_state    |= DISABLED ;
    menu[M_LDV].ob_state         |= DISABLED ;
    menu[M_MKPALETTE].ob_state   |= DISABLED ;
    menu[M_TAILLE].ob_state      |= DISABLED ;
    menu[M_MKPALETTE].ob_state   |= DISABLED ;
    menu[M_CONVOLUTION].ob_state |= DISABLED ;
    menu[M_HISTO].ob_state       |= DISABLED ;
  }

  if ( config.color_protect == 0 ) menu_icheck( GemApp.Menu, M_PALETTE, 0 ) ;
}

int OnAppMenuSelected(int t_id, int m_id)
{
  int code = GW_EVTCONTINUEROUTING ;

  switch( m_id )
  {
	case M_BARATIN      : display_baratin( high_res ) ;
						  break ;
	case M_NOUVEAU      : traite_nouveau() ;
	                      break ;
	case M_OUVRE        : traite_ouvre(0) ;
					      break ;
	case M_OUVRES       : traite_ouvre(1) ;
					      break ;
	case M_BATCHCONV    : traite_batch_conversion() ;
	                      break ;
	case M_IMPRIME      : traite_imprime( NULL ) ;
	                      break ;
	case M_QUITTE       : code = GW_EVTQUITAPP ;
						  break ;
	case M_NCOLLE       : traite_ncolle() ;
	                      break ;
    case M_CATALOG      : traite_album(NULL) ;
                          break ;
	case M_PGENERAL     : traite_pgeneral() ;
	                      break ;
	case M_PTEXTE       : traite_ptexte() ;
	                      break ;
	case M_PFORMES      : traite_pformes() ;
	                      break ;
	case M_PGOMME       : traite_pgomme() ;
	                      break ;
	case M_PALETTE      : traite_tab( NULL ) ;
	                      break ;
	case M_PREF         : traite_preferences() ;
                          set_goodmouse() ;
	                      break ;
	case M_OPOINT       : OnAppKeyPressed( F1 ) ;
	                      break ;
	case M_OTRACE       : OnAppKeyPressed( SF1 ) ;
	                      break ;
	case M_OLIGNE       : OnAppKeyPressed( SF3 ) ;
	                      break ;
	case M_OKLIGNE      : OnAppKeyPressed( F3 ) ;
	                      break ;
	case M_ORECTANGLE   : OnAppKeyPressed( SF4 ) ;
	                      break ;
	case M_OPLAN        : OnAppKeyPressed( SF5 ) ;
	                      break ;
	case M_OCERCLE      : OnAppKeyPressed( F4 ) ;
	                      break ;
	case M_ODISQUE      : OnAppKeyPressed( F5 ) ;
	                      break ;
	case M_OPEINTURE    : OnAppKeyPressed( F6 ) ;
	                      break ;
	case M_OPALETTE     : OnAppKeyPressed( F10 ) ;
	                      break ;
	case M_OGOMME       : OnAppKeyPressed( SF6 ) ;
	                      break ;
	case M_OTEXTE       : OnAppKeyPressed( F7 ) ;
	                      break ;
	case M_OPINCEAU     : OnAppKeyPressed( F2 ) ;
	                      break ;
	case M_OAEROSOL     : OnAppKeyPressed( SF2 ) ;
	                      break ;
	case M_OTABLEAU     : OnAppKeyPressed( SF8 ) ;
	                      break ;
	case M_OTEMP        : OnAppKeyPressed( F8 ) ;
	                      break ;
	case M_OLOUPE       : OnAppKeyPressed( SF7 ) ;
	                      break ;
	case M_OMAIN        : OnAppKeyPressed( F9 ) ;
	                      break ;
	case M_OBLOC        : OnAppKeyPressed( SF9 ) ;
	                      break ;
  }

  GWOnMenuSelected( t_id, m_id ) ;

  return( code ) ;
}

void param_icon(int mx, int my)
{
  int ob_num ;
      
  ob_num = objc_find( adr_icones, 0, 200, mx, my ) ;
  switch( ob_num )
  {
    case PLAN      :
    case TRACE     :
    case POINT     :
    case LIGNE     :
    case KLIGNE    :
    case PEINTURE  :
    case RECTANGLE :
    case TABLEAU   :
    case DISQUE    : traite_pformes() ;
                     break ;
    case PINCEAU   : traite_ppinceau() ;
                     break ;
    case TEXTE     : traite_ptexte() ;
                     break ;
    case GOMME     : traite_pgomme() ;
                     break ;
    case AEROSOL   : traite_paerosol() ;
                     break ;
    case BLOC      : traite_pbloc() ;
                     break ;
  }
}

int OnVImgTopped(GEM_WINDOW *wnd)
{
  GWOnTopped( wnd ) ;
  set_imgpalette( wnd->Extension ) ;

  return( 0 ) ;
}

void iconify_picture(GEM_WINDOW *wnd)
{
  VXIMAGE *vimage ;
  MFDB    temp ;
  float   pcx, pcy ;
  int     xy[8] ;
  int     w, h, dummy ;
  int     nw ;

  vimage = (VXIMAGE *) wnd->Extension ;
  wnd->GetWorkXYWH( wnd, &dummy, &dummy, &w, &h ) ;
  memset( &wnd->window_icon, 0, sizeof(MFDB) ) ;
  wnd->window_icon.fd_addr = img_alloc( w, h, nb_plane ) ;
  if ( wnd->window_icon.fd_addr == NULL ) return ;
  wnd->window_icon.fd_w = w ;
  wnd->window_icon.fd_h = h ;
  wnd->window_icon.fd_wdwidth = w/16 ;
  if (w % 16) wnd->window_icon.fd_wdwidth++ ;
  wnd->window_icon.fd_nplanes = nb_plane ;

  img_raz( &wnd->window_icon ) ;
  pcx = (float)w/(float)vimage->raster.fd_w ;
  pcy = (float)h/(float)vimage->raster.fd_h ;
  if (pcx > pcy) pcx = pcy ;
  else           pcy = pcx ;
  /* R‚duit la taille de l'image … une icone */
  temp.fd_addr = NULL ;
  temp.fd_w    = (int) ( 0.5 + (float)vimage->raster.fd_w * pcx ) ;
  temp.fd_h    = (int) ( 0.5 + (float)vimage->raster.fd_h * pcx ) ;
/*  raster_pczoom( &vimage->raster, &temp, pcx, pcy, NULL ) ;*/
  RasterZoom( &vimage->raster, &temp, NULL ) ;
  if ( temp.fd_addr == NULL )
  {
    Xfree( wnd->window_icon.fd_addr ) ;
    memset( &wnd->window_icon, 0, sizeof(MFDB) ) ;
    return ;
  }

  nw = (int) ((float)vimage->raster.fd_w*(float)pcx) ;
  if (nw > w) nw = w ;
  xy[0] = xy[1] = 0 ;
  xy[2] = nw-1 ;
  xy[3] = temp.fd_h-1 ;
  xy[4] = (w-nw) >> 1 ;
  xy[5] = (h-temp.fd_h) >> 1 ;
  xy[6] = xy[4]+nw-1 ;
  xy[7] = xy[5]+temp.fd_h-1 ;
  vro_cpyfm(handle, S_ONLY, xy, &temp,&wnd->window_icon ) ;
  Xfree( temp.fd_addr ) ;
}

int GetRVBForVIMG(GEM_WINDOW *wnd, int mx, int my, int rvb[3])
{
  VXIMAGE *vimage = wnd->Extension ;
  int index = -1 ;
  int xpos, ypos ;
  int xi, yi, dummy ;

  if ( Truecolor )
  {
    xpos = vimage->x1 + mx / vimage->zoom_level ;
    ypos = vimage->y1 + my / vimage->zoom_level ;
    GetPixel( &vimage->raster, xpos, ypos, rvb ) ;
  }
  else
  {
    wnd->GetWorkXYWH( wnd, &xi, &yi, &dummy, &dummy ) ;
    v_hide_c( handle ) ;
    v_get_pixel( handle, xi + mx, yi + my, &dummy, &index ) ;
    v_show_c( handle, 1 ) ;
    vq_color( handle, index, 1, rvb ) ;
  }

  return( index ) ;
}

void draw_selection(GEM_WINDOW *wnd, int xywh[4], int xi, int yi)
{
  VXIMAGE   *vimage = (VXIMAGE *) wnd->Extension ;
  int       cxy[4] ;
  int       posx, posy ;
  int       x1, y1, x2, y2 ;

  if ( vimage->zoom_level != 1 ) return ;

  posx = vimage->x1 ;
  posy = vimage->y1 ;
  vswr_mode(handle, MD_REPLACE) ;
  vsl_color(handle, 1) ;
  vsl_ends(handle, SQUARE, SQUARE) ;
  vsl_width(handle, 1) ;
  vsl_type(handle, DOT) ;

  x1 = xi+vclip.x1-posx ; y1 = yi+vclip.y1-posy ;
  x2 = xi+vclip.x2-posx ; y2 = yi+vclip.y2-posy ;
  cxy[0] = xywh[0] ; cxy[1] = xywh[1] ;
  cxy[2] = cxy[0] + xywh[2] - 1 ;
  cxy[3] = cxy[1] + xywh[3] - 1 ;
  vs_clip( handle, 1, cxy ) ;
  rectangle( x1, y1, x2, y2 ) ;
  vs_clip( handle, 0, cxy ) ;
}

void paint_zone(int *xy)
{
  int index ;

  if ( !Truecolor ) index = 0 ;
  else
  {
    int rgb[3] = { 1000, 1000, 1000 } ;

    index = 19 ;
    vs_color( handle, index, rgb ) ;
  }
  vswr_mode( handle, MD_REPLACE ) ;
  vsf_color( handle, index ) ;
  vsf_interior( handle, FIS_SOLID ) ;
  vsf_perimeter( handle, 0 ) ;
  vr_recfl( handle, xy ) ;
}

void OnVImgDraw(GEM_WINDOW *wnd, int xywh[4])
{
  VXIMAGE *vimage ;
  int     w, h ;
  int     off_x, off_y, xi, yi, dummy ;
  int     xy[8] ;
  int     posx, posy ;

  vimage = (VXIMAGE *) wnd->Extension ;

  if ( vimage->zoom_level == 1 )
  {
    posx = vimage->x1 ;
    posy = vimage->y1 ;
  }
  else
    posx = posy = 0 ;

  w = xywh[2] ;
  h = xywh[3] ;
  xy[4] = xywh[0] ;         xy[5] = xywh[1] ;
  xy[6] = xywh[0] + w - 1 ; xy[7] = xywh[1] + h - 1 ;

  wnd->GetWorkXYWH( wnd, &xi, &yi, &dummy, &dummy ) ;
  off_x = xywh[0] - xi ;
  off_y = xywh[1] - yi ;
  xy[0] = off_x + posx ; xy[1] = off_y + posy ;
  xy[2] = xy[0] + w - 1 ;
  xy[3] = xy[1] + h - 1 ;
  
  if ( vimage->zoom_level == 1 ) vro_cpyfm( handle, S_ONLY, xy, &vimage->raster, &screen ) ;
  else                           vro_cpyfm( handle, S_ONLY, xy, &vimage->zoom, &screen ) ;

  if ( vclip.gwindow == wnd ) draw_selection( wnd, xywh, xi, yi ) ;
}

void FreeRelatedMemory(GEM_WINDOW *gwnd)
{
  traite_effbuffers( gwnd ) ;

  if ( clipboard.gwindow == gwnd ) FreeClipboard() ;

  if ( vclip.gwindow == gwnd )
  {
    vclip.gwindow = NULL ;
    vclip.x1  = 0 ; vclip.y1  = 0 ;
    vclip.x2  = 0 ; vclip.y2  = 0 ;
  }
}

int OnVImgClose(GEM_WINDOW *gwnd)
{
  VXIMAGE *vimage = (VXIMAGE *) gwnd->Extension ;
  int     code = GW_EVTCONTINUEROUTING ;

  if ( vimage->modif )
  {
    if ( form_interrogation(1, MsgTxtGetMsg(hMsg, MSG_IMAGECHANGE)  ) == 1 )
      traite_sauves( gwnd, 0 ) ;
  }

  if ( vimage->raster.fd_addr )  Xfree( vimage->raster.fd_addr ) ;
  if ( vimage->zoom.fd_addr )    Xfree( vimage->zoom.fd_addr ) ;
  if ( vimage->inf_img.palette ) Xfree( vimage->inf_img.palette ) ;
  FreeRelatedMemory( gwnd ) ;
  GWOnClose( gwnd ) ;

  if ( config.quitte )
    if ( GWGetWindowByClass( VIMG_CLASSNAME ) == NULL ) code = GW_EVTQUITAPP ;

  return( code ) ;
}

int OnVImgKeyPressed(GEM_WINDOW *gwnd, int key)
{
  VXIMAGE *vimage = (VXIMAGE *) gwnd->Extension ;
  int     xt, yt, mx, my, dummy ;
  int     code = GW_EVTSTOPROUTING ;

  switch( key )
  {
	case FERMER      : gwnd->OnClose( gwnd ) ;
				  	   break ;

	case SAUVE       : traite_sauves( gwnd, 0 ) ;
					   break ;

	case SAUVES      : traite_sauves( gwnd, 1 ) ;
  					   break ;

    case IMPRIMER    : traite_imprime( gwnd ) ;
                       break ;

	case UNDO        : undo_restore( gwnd ) ;
	                   break ;

	case COUPER      : traite_coupe( gwnd ) ;
	                   break ;

	case COPIER      : traite_copie( gwnd ) ;
	                   break ;

	case COLLER      : traite_colle( gwnd ) ;
	                   break ;

    case EFFACE      : traite_efface() ;
                       break ;

    case NEGATIF     : traite_negatif( gwnd ) ;
                       break ;

    case S_ALL       : traite_selectall( gwnd ) ;
                       break ;

	case STD_PAL     : traite_tab( gwnd ) ;
	                   break ;

	case PLEINE_PAGE : traite_fullscreen( gwnd ) ;
	                   break ;

	case INFOS       : traite_info( gwnd ) ;
	                   break ;

	case CONVERSION  : traite_conversion( gwnd ) ;
	                   break ;

	case ESPACE      : traite_espace( gwnd ) ;
	                   break ;

    case ZOOM1       : select_zoom( gwnd, M_Z11) ;
                       break ;

    case ZOOM2       : select_zoom( gwnd, M_Z21) ;
                       break ;

    case ZOOM4       : select_zoom( gwnd, M_Z41) ;
                       break ;

    case ZOOM8       : select_zoom( gwnd, M_Z81) ;
                       break ;

    case ZOOM16      : select_zoom( gwnd, M_Z161) ;
                       break ;

    case ZOOMPLUS    : vimage->zoom_level *= 2 ;
                       if ( vimage->zoom_level > 16 )
                       {
                         vimage->zoom_level = 16 ;
                         return( GW_EVTSTOPROUTING ) ;
                       }
                       graf_mkstate( &mx, &my, &dummy, &dummy ) ;
                       traite_loupe( gwnd, vimage->zoom_level, mx, my ) ;
                       break ;

    case ZOOMMOINS   : vimage->zoom_level /= 2 ;
                       if ( vimage->zoom_level == 0 )
                       {
                         vimage->zoom_level = 1 ;
                         return( GW_EVTSTOPROUTING ) ;
                       }
                       graf_mkstate( &mx, &my, &dummy, &dummy ) ;
                       traite_loupe( gwnd, vimage->zoom_level, mx, my ) ;
                       break ;

	case SYMETRIE    : traite_symetrie( gwnd ) ;
	                   break ;

	case TAILLE      : traite_taille( gwnd ) ;
	                   break ;

	case LDV         : traite_ldv( gwnd ) ;
	                   break ;

	case FILTRE      : traite_convolution( gwnd ) ;
	                   break ;

    case DOPALETTE   : traite_makepalette( gwnd ) ;
                       break ;

    case PIPETTE     : WndToolBar->GetWorkXYWH( WndToolBar, &xt, &yt, &dummy, &dummy ) ;
                       mx = xt+adr_icones[TEMPERATURE].ob_x+8 ;
	                   my = yt+adr_icones[TEMPERATURE].ob_y+8 ;
	                   select_icon( mx, my ) ;
                       break ;

    default :          code = GW_EVTCONTINUEROUTING ;
                       break ;
  }

  traite_snapshot_key( key ) ;

  return( code ) ;
}

int OnVImgMenuSelected(GEM_WINDOW *wnd, int t_id, int m_id)
{
  int code = GW_EVTSTOPROUTING ;

  switch( m_id )
  {
	case M_FERME        : wnd->OnClose( wnd ) ;
					  	  break ;

	case M_SAUVE        : traite_sauves( wnd, 0 ) ;
	                      break ;

	case M_SAUVES       : traite_sauves( wnd, 1 ) ;
	                      break ;

    case M_IMPRIME      : traite_imprime( wnd ) ;
                          break ;

	case M_UNDO         : undo_restore( wnd ) ;
	                      break ;

	case M_REFAIRE      : traite_refaire( wnd ) ;
	                      break ;

	case M_CLEARBUF     : traite_effbuffers( wnd ) ;
	                      break ;

	case M_COUPE        : traite_coupe( wnd ) ;
	                      break ;

	case M_COPIE        : traite_copie( wnd ) ;
	                      break ;

	case M_COLLE        : traite_colle( wnd ) ;
	                      break ;

    case M_EFFACE       : traite_efface() ;
                          break ;

    case M_NEGATIF      : traite_negatif( wnd ) ;
                         break ;

    case M_SELECTIONNE  : traite_selectall( wnd ) ;
                          break ;

	case M_PLEIN        : traite_fullscreen( wnd ) ;
	                      break ;

	case M_PLEINECRAN   : traite_pleinecran( wnd ) ;
	                      break ;

	case M_INFO         : traite_info( wnd ) ;
	                      break ;

	case M_CONVERSION   : traite_conversion( wnd ) ;
	                      break ;

	case M_Z11          :
	case M_Z21          :
	case M_Z41          :
	case M_Z81          :
	case M_Z161         : select_zoom( wnd, m_id ) ;
	                      break ;

	case M_SYMETRIE     : traite_symetrie( wnd ) ;
	                      break ;

	case M_TAILLE       : traite_taille( wnd ) ;
	                      break ;

	case M_LDV          : traite_ldv( wnd ) ;
	                      break ;

	case M_CONVOLUTION  : traite_convolution( wnd ) ;
	                      break ;

	case M_PALETTE      : traite_tab( wnd ) ;
	                      break ;

    case M_MKPALETTE    : traite_makepalette( wnd ) ;
                          break ;

    case M_HISTO        : traite_histo( wnd ) ;
                          break ;

    default :             code = GW_EVTCONTINUEROUTING ;
                          break ;
  }

  GWOnMenuSelected( t_id, m_id ) ;

  return( code ) ;
}

void OnVImgArrow(GEM_WINDOW *gwnd, int action)
{
  VXIMAGE *vimage = (VXIMAGE *) gwnd->Extension ;
  long    wdiv, hdiv ;
  int     zooms[] = {1, 2, 4, 8, 16} ;
  int     new ;
  int     rc, rl ;
  int     w, h ;
  int     index ;
  int     hsld = 1 ;
 
  for (index = 0; index < 4; index++)
    if ( vimage->zoom_level == zooms[index] ) break ;

  rc = vimage->x1 ;
  rl = vimage->y1 ;
  w  = 1+vimage->x2-vimage->x1 ;
  h  = 1+vimage->y2-vimage->y1 ;
  wdiv = vimage->raster.fd_w-w ;
  if (wdiv <= 0) wdiv = 1 ;
  hdiv = vimage->raster.fd_h-h ;
  if (hdiv <= 0) hdiv = 1 ;
  switch(action)
  {
    case WA_UPPAGE : rl -= h ;
                     if (rl < 0) rl = 0 ;
                     new = (int) ((1000L*(long)rl)/hdiv) ;
                     hsld = 0 ;
                     break ;
    case WA_DNPAGE : rl += h ;
                     if (rl+h >= vimage->raster.fd_h)
                       rl = vimage->raster.fd_h-h ;
                     new = (int) ((1000L*(long)rl)/hdiv) ;
                     hsld = 0 ;
                     break ;
    case WA_LFPAGE : rc -= w ;
                     if (rc < 0) rc = 0 ; 
                     new = (int) ((1000L*(long)rc)/wdiv) ;
                     break ;
    case WA_RTPAGE : rc += w ;
                     if (rc+w >= vimage->raster.fd_w)
                       rc = vimage->raster.fd_w-w ;
                     new = (int) ((1000L*(long)rc)/wdiv) ;
                     break ;
    case WA_UPLINE : rl -= 8 ;
                     if (rl < 0) rl = 0 ;
                     new = (int) ((1000L*(long)rl)/hdiv) ;
                     hsld = 0 ;
                     break ;
    case WA_DNLINE : rl += 8 ;
                     if (rl+h >= vimage->raster.fd_h)
                       rl = vimage->raster.fd_h-h ;
                     new = (int) ((1000L*(long)rl)/hdiv) ;
                     hsld = 0 ;
                     break ;
    case WA_LFLINE : rc -= 8 ;
                     if (rc < 0) rc = 0 ;  
                     new = (int) ((1000L*(long)rc)/wdiv) ;
                     break ;
    case WA_RTLINE : rc += 8 ;
                     if (rc+w >= vimage->raster.fd_w)
                       rc = vimage->raster.fd_w-w ;
                     new = (int) ((1000L*(long)rc)/wdiv) ;
                     break ;
  }

  vimage->x1 = rc ;
  vimage->y1 = rl ;
  vimage->x2 = rc+w-1 ;
  vimage->y2 = rl+h-1 ;
  if ( vimage->zoom_level == 1 )
  {
    GWRePaint( gwnd ) ;
    if ( hsld ) GWSetHSlider( gwnd, new ) ;
    else        GWSetVSlider( gwnd, new ) ;
  }
  else
    traite_loupe( gwnd, vimage->zoom_level, -1, -1 ) ;

  update_zview( gwnd ) ;
}

void OnVImgHSlider(GEM_WINDOW *wnd, int pos)
{
  VXIMAGE *vimage = (VXIMAGE *) wnd->Extension ;
  int     wx ;

  wx         = 1 + vimage->x2 - vimage->x1 ;
  vimage->x1 = (int) (((long)pos*(long)(vimage->raster.fd_w-wx))/1000L) ;
  vimage->x2 = vimage->x1 + wx - 1 ;

  if ( vimage->zoom_level == 1 )
  {
    GWRePaint( wnd ) ;
    GWOnHSlider( wnd, pos ) ;
  }
  else traite_loupe( wnd, vimage->zoom_level, -1, -1 ) ;
  
  update_zview( wnd ) ;
}

void OnVImgVSlider(GEM_WINDOW *wnd, int pos)
{
  VXIMAGE *vimage = (VXIMAGE *) wnd->Extension ;
  int     wy ;

  wy         = 1 + vimage->y2 - vimage->y1 ;
  vimage->y1 = (int) (((long)pos*(long)(vimage->raster.fd_h-wy))/1000L) ;
  vimage->y2 = vimage->y1 + wy - 1 ;

  if ( vimage->zoom_level == 1 )
  {
    GWRePaint( wnd ) ;
    GWOnVSlider( wnd, pos ) ;
  }
  else traite_loupe( wnd, vimage->zoom_level, -1, -1 ) ;
   update_zview( wnd ) ;
}

void OnVImgSize(GEM_WINDOW *wnd, int xywh[4])
{
  VXIMAGE *vimage = (VXIMAGE *) wnd->Extension ;
  void    *virtuel ;
  int     do_it = 1 ;
  int     rc, rl ;
  int     index ;
  int     wxi, whi ;
  int     xi, yi, wxe, whe ;
  int     zooms[] = {1, 2, 4, 8, 16} ;

  for ( index = 0; index < 4; index++ )
    if ( vimage->zoom_level == zooms[index] ) break ;

  if ( vimage->zoom_level != 1 )
  {
    /* Teste si il y a suffisament de m‚moire pour le zoom */
    virtuel = img_alloc( xywh[2], xywh[3], nb_plane ) ;
    if ( virtuel == NULL )
    {
      do_it = 0 ;
      form_error(8) ;
    }
    else Xfree( virtuel ) ;
  }
  if ( !do_it ) return ;

  rc = vimage->x1 ;
  rl = vimage->y1 ;
  wind_calc( WC_WORK, wnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &xywh[0], &xywh[1], &xywh[2], &xywh[3]) ;
  wxi = xywh[2]/zooms[index] ;
  whi = xywh[3]/zooms[index] ;
  if (wxi > vimage->raster.fd_w) wxi = vimage->raster.fd_w ;
  if (whi > vimage->raster.fd_h) whi = vimage->raster.fd_h ;
  if (rc+wxi >= vimage->raster.fd_w) rc = vimage->raster.fd_w-wxi ;
  if (rl+whi >= vimage->raster.fd_h) rl = vimage->raster.fd_h-whi ;
  vimage->x1 = rc ;
  vimage->y1 = rl ;
  vimage->x2 = rc+wxi-1 ;
  vimage->y2 = rl+whi-1 ;
  if ( vimage->zoom_level != 1 ) traite_loupe( wnd, vimage->zoom_level, -1, -1 ) ;
  else
  {
    wind_calc( WC_BORDER, wnd->window_kind, xywh[0], xywh[1], wxi, whi, &xi, &yi, &wxe, &whe ) ;
    xywh[0] = xi ; xywh[1] = yi ;
    xywh[2] = wxe ; xywh[3] = whe ; /* Pour GWOnSize quand il fera wind_set( .., WF_CURRXYWH */
    xi = (int) (0.5+1000.0*(float)vimage->x1/(float)(vimage->raster.fd_w-wxi)) ;
    yi = (int) (0.5+1000.0*(float)vimage->y1/(float)(vimage->raster.fd_h-whi)) ;
    GWSetHSlider( wnd, xi) ;
    GWSetVSlider( wnd, yi) ;
    wxe = (int) (0.5+1000.0*(float)wxi/(float)vimage->raster.fd_w) ;
    whe = (int) (0.5+1000.0*(float)whi/(float)vimage->raster.fd_h) ;
    GWSetHSliderSize( wnd, wxe) ;
    GWSetVSliderSize( wnd, whe) ;
    update_zview( wnd ) ;
    GWOnSize( wnd, xywh ) ;
  }
}

int OnVImgFulled(GEM_WINDOW *wnd)
{
  VXIMAGE *vimage = (VXIMAGE *) wnd->Extension ;
  float   zratio[] = {1.0, 2.0, 4.0, 8.0, 16.0} ;
  int     zooms[] = {1, 2, 4, 8, 16} ;
  int     xywh[4] ;
  int     xi, yi ;
  int     xe, ye, wxe, whe ;
  int     wxee, whee ;
  int     index ;
  int     offset ;

  for (index = 0; index < 4; index++)
    if ( vimage->zoom_level == zooms[index] ) break ;

  wind_calc( WC_WORK, wnd->window_kind, xopen, yopen, wdesk-(xopen-xdesk), hdesk-(yopen-ydesk),
             &xe, &ye, &wxe, &whe ) ;

  /* On s'assure que wxe et whe sont multiples du niveau de zoom */
  wxe  = (int)zratio[index]*(wxe/(int)zratio[index]) ;
  whe  = (int)zratio[index]*(whe/(int)zratio[index]) ;

  wxee = (int) ((float)wxe/zratio[index]) ;
  whee = (int) ((float)whe/zratio[index]) ;
  if (wxee > vimage->raster.fd_w)
  {
    wxe  = (vimage->raster.fd_w)*zooms[index] ;
    wxee = (int) ((float)wxe/zratio[index]) ;
  }
  if (whee > vimage->raster.fd_h)
  {
    whe  = (vimage->raster.fd_h)*zooms[index] ;
    whee = (int) ((float)whe/zratio[index]) ;
  }

  wind_calc( WC_BORDER, wnd->window_kind, xe, ye, wxe, whe, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  vimage->x2 = vimage->x1 + wxee - 1 ;
  vimage->y2 = vimage->y1 + whee - 1 ;
  if ( vimage->x2 >= vimage->raster.fd_w )
  {
    offset = 1 + vimage->x2 - vimage->raster.fd_w ;

    vimage->x1 -= offset ;
    vimage->x2 -= offset ;
  }
  if ( vimage->y2 >= vimage->raster.fd_h )
  {
    offset = 1 + vimage->y2 - vimage->raster.fd_h ;

    vimage->y1 -= offset ;
    vimage->y2 -= offset ;
  }
 
  xi = (int) (0.5+1000.0*(float)vimage->x1/(float)(vimage->raster.fd_w-wxee)) ;
  yi = (int) (0.5+1000.0*(float)vimage->y1/(float)(vimage->raster.fd_h-whee)) ;
  GWSetHSlider( wnd, xi ) ;
  GWSetVSlider( wnd, yi ) ;
  wxe = (int) (0.5+1000.0*(float)wxee/(float)vimage->raster.fd_w) ;
  whe = (int) (0.5+1000.0*(float)whee/(float)vimage->raster.fd_h) ;
  GWSetHSliderSize( wnd, wxe ) ;
  GWSetVSliderSize( wnd, whe ) ;
  if ( vimage->zoom_level != 1 )
  {
    traite_loupe( wnd, vimage->zoom_level, -1, -1 ) ;
    wnd->must_be_fulled = 0 ;
  }
  else GWOnFulled( wnd, xywh ) ;
  update_zview( wnd ) ;

  return( 0 ) ;
}

int OnVImgRestoreFulled(GEM_WINDOW *wnd)
{
  VXIMAGE *vimage = (VXIMAGE *) wnd->Extension ;
  float   zratio[] = {1.0, 2.0, 4.0, 8.0, 16.0} ;
  int     zooms[] = {1, 2, 4, 8, 16} ;
  int     xywh[4] ;
  int     xi, yi ;
  int     xe, ye, wxe, whe ;
  int     wxee, whee ;
  int     index ;
  
  for (index = 0; index < 4; index++)
    if ( vimage->zoom_level == zooms[index] ) break ;

  wind_get( wnd->window_handle, WF_PREVXYWH, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  wind_calc( WC_WORK, wnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &xe, &ye, &wxe, &whe ) ;

  /* On s'assure que wxe et whe sont multiple du niveau de zoom */
  wxe  = (int)zratio[index]*(wxe/(int)zratio[index]);
  whe  = (int)zratio[index]*(whe/(int)zratio[index]) ;

  wxee = (int) ((float)wxe/zratio[index]) ;
  whee = (int) ((float)whe/zratio[index]) ;
  if (wxee > vimage->raster.fd_w) wxe = vimage->raster.fd_w ;
  if (whee > vimage->raster.fd_h) whe = vimage->raster.fd_h ;

  wind_calc( WC_BORDER, wnd->window_kind, xe, ye, wxe, whe, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  xi = (int) (0.5+1000.0*(float)vimage->x1/(float)(vimage->raster.fd_w-wxee)) ;
  yi = (int) (0.5+1000.0*(float)vimage->y1/(float)(vimage->raster.fd_h-whee)) ;
  GWSetHSlider( wnd, xi ) ;
  GWSetVSlider( wnd, yi ) ;
  wxe = (int) (0.5+1000.0*(float)wxee/(float)vimage->raster.fd_w) ;
  whe = (int) (0.5+1000.0*(float)whee/(float)vimage->raster.fd_h) ;
  GWSetHSliderSize( wnd, wxe ) ;
  GWSetVSliderSize( wnd, whe ) ;
  if ( vimage->zoom_level != 1 )
  {
    traite_loupe( wnd, vimage->zoom_level, -1, -1 ) ;
    wnd->must_be_fulled = 1 ;
  }
  else GWOnRestoreFulled( wnd, xywh ) ;

  update_zview( wnd ) ;

  return( GW_EVTSTOPROUTING ) ;
}

int OnVImgIconify(GEM_WINDOW *wnd, int xywh[4])
{
  GWOnIconify( wnd, xywh ) ;
  if ( wnd->window_icon.fd_addr == NULL ) iconify_picture( wnd ) ;

  return( 0 ) ;
}

int OnVImgUnIconify(GEM_WINDOW *wnd, int xywh[4])
{
  GWOnUnIconify( wnd, xywh ) ;
  PostMessage( wnd, WM_TOPPED, NULL ) ;
  update_zview( wnd ) ;

  return( GW_EVTSTOPROUTING ) ;
}

#pragma warn -par
int OnVImgMouseMove(GEM_WINDOW *gwnd, int button, int kstate, int mx, int my)
{
  VXIMAGE *vimage ;
  int     stx, sty ;
  int     ratio ;
  int     index ;
  int     rgb[3] ;
  char    msgxy[50] ;
  char    msgrvb[50] ;
  char    buf[100] ;

  vimage = (VXIMAGE *) gwnd->Extension ;
  if ( gwnd->window_kind & INFO )
  {
    if ( mx >= 0 )
    {
      stx   = vimage->x1 ;
      sty   = vimage->y1 ;
      ratio = vimage->zoom_level ;
      sprintf( msgxy, MsgTxtGetMsg(hMsg, MSG_XY) , stx + mx / ratio, sty + my / ratio ) ;
      index = GetRVBForVIMG( gwnd, mx, my, rgb ) ;
      if ( index < 0 ) sprintf( msgrvb, MsgTxtGetMsg(hMsg, MSG_RVB), rgb[0], rgb[1], rgb[2] ) ;
      else             sprintf( msgrvb, MsgTxtGetMsg(hMsg, MSG_RVBI), rgb[0], rgb[1], rgb[2], index ) ;
      sprintf( buf, "%s %s", msgxy, msgrvb ) ;
      GWSetWindowInfo( gwnd, buf ) ;
    }
    else GWSetWindowInfo( gwnd, "" ) ; /* Sortie de zone */
  }

  return( GW_EVTSTOPROUTING ) ;
}

int OnVImgLButtonDown(GEM_WINDOW *wnd, int mk_state, int x, int y)
{
  if ( wnd->is_icon ) return( 0 ) ;

  traite_action( wnd ) ;

  return( GW_EVTSTOPROUTING ) ;
}

int OnVImgDLButtonDown(GEM_WINDOW *wnd, int mk_state, int x, int y)
{
  if ( wnd->is_icon ) return( 0 ) ;

  return( GW_EVTSTOPROUTING ) ;
}

int OnVImgRButtonDown(GEM_WINDOW *wnd, int mk_state, int x, int y)
{
  traite_iconpopup( wnd ) ;

  return( GW_EVTSTOPROUTING ) ;
}

int OnVImgDRButtonDown(GEM_WINDOW *wnd, int mk_state, int x, int y)
{
  if ( wnd->is_icon ) return( 0 ) ;

  return( GW_EVTSTOPROUTING ) ;
}
#pragma warn +par

int OnVImgProgPc(void *wnd, int pc, char *txt)
{
  char buf[100] ;

  if ( ( pc < 100 ) && txt ) sprintf( buf, "%s (%d %%)...", txt, pc ) ;
  else                       buf[0] = 0 ;

  GWSetWindowInfo( wnd, buf ) ;

  return( 0 ) ;
}
