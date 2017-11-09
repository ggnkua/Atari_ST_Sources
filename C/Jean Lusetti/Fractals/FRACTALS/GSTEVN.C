/**************************************************/
/*----------------- GSTEVN.C ---------------------*/
/* Module des fonctions de gestion des ‚vŠnements */
/**************************************************/
#include      <ext.h>
#include     <math.h>
#include    <stdio.h>
#include   <string.h>
#include   <stdlib.h>

#include     "..\tools\xgem.h"
#include    "..\tools\print.h"
#include "..\tools\rasterop.h"

#include     "defs.h"
#include    "anime.h"
#include   "calcul.h"
#include  "fractal.h"
#include "fract_io.h"
#include "palettes.h"
#include "clgstevn.h"


#define CURSOR_UP  0x4800
#define CURSOR_DN  0x5000
#define CURSOR_LT  0x4B00
#define CURSOR_RT  0x4D00
#define PNPLUS     0x4E00
#define PNMOINS    0x4A00


#define HMAX         3000


extern char ev_num ; /* Num‚ro du fractal … re-‚valuer */

FRACTAL fr ;         /* Fractal … afficher en temps r‚el */
OBJECT *adr_menu ;   /* Adresse de la barre du menu      */
OBJECT *adr_info ;   /* Adresse de la boite d'infos      */
OBJECT *popup_name ;
OBJECT *popup_algo ;
int    xfr, yfr, wfr, hfr, handle_fr ; /* Infos sur fenˆtre temps r‚el */

char   titre[] = "Fractals" ;

void ajour_menu(void) ;
void window_update(int *msg) ;
void redraws(void) ;


void status_menu(int flag)
{
  menu_ienable(adr_menu, M_INFO, flag) ;
  menu_ienable(adr_menu, M_NOUVEAU, flag) ;
  menu_ienable(adr_menu, M_CHARGE, flag) ;
  menu_ienable(adr_menu, M_FERME, flag) ;
  menu_ienable(adr_menu, M_SAUVE, flag) ;
  menu_ienable(adr_menu, M_SAUVES, flag) ;
  menu_ienable(adr_menu, M_COPIER, flag) ;
  menu_ienable(adr_menu, M_EXPORT, flag) ;
  menu_ienable(adr_menu, M_QUITTE, flag) ;
  menu_ienable(adr_menu, M_ZOOMC, flag) ;
  menu_ienable(adr_menu, M_ZOOMF, flag) ;
  menu_ienable(adr_menu, M_INFOF, flag) ;
  menu_ienable(adr_menu, M_REPORT, flag) ;
  menu_ienable(adr_menu, M_LOADINIT, flag) ;
  menu_ienable(adr_menu, M_INIT, flag) ;
  menu_ienable(adr_menu, M_CALCUL, flag) ;
  menu_ienable(adr_menu, M_DUPLIQUE, flag) ;
  menu_ienable(adr_menu, M_TAILLE, flag) ;
  menu_ienable(adr_menu, M_PALETTE, flag) ;
  menu_ienable(adr_menu, M_PREFS, flag) ;
  menu_ienable(adr_menu, M_ANIMD, flag) ;
  menu_ienable(adr_menu, M_ANIMF, flag) ;
  menu_ienable(adr_menu, M_ANIMGO, flag) ;
  menu_ienable(adr_menu, M_ANIM_CHARGE, flag) ;
  menu_ienable(adr_menu, M_ANIM_RESUME, flag) ;
  menu_ienable(adr_menu, M_ANIMATE, flag) ;
  menu_ienable(adr_menu, M_ANIM_PARA, flag) ;
  menu_ienable(adr_menu, M_ANIMATION, flag) ;
  menu_ienable(adr_menu, M_OPTIONS, flag) ;
  menu_ienable(adr_menu, M_FICHIERS, flag) ;
}

void fshow_dialog(OBJECT *obj, char *title)
{
  status_menu(0) ;
  show_dialog(obj, title) ;
}

void fhide_dialog(void)
{
  hide_dialog() ;
  status_menu(1) ;
  ajour_menu() ;
}

void report(FRACTAL *fr)
{
  OBJECT *adr_report ;
  double hd, md, sd, r ;
  double htod, mtod, stod ;
  int    h, m, s, d ;
  int    clicked ;
  char   buf[50] ;

  Xrsrc_gaddr(R_TREE, FORM_REPORT, &adr_report) ;
  sprintf(buf, "%.3d (%.3d", fr->report.nbl_cpu, fr->report.pc_cpu) ;
  strcat(buf, "%)") ;
  write_text(adr_report, REPORT_CPU, buf) ;
  sprintf(buf, "%.3d (%.3d", fr->report.nbl_fpu, fr->report.pc_fpu) ;
  strcat(buf, "%)") ;
  write_text(adr_report, REPORT_FPU, buf) ;
  sprintf(buf, "%.3d (%.3d", fr->report.nbl_dsp, fr->report.pc_dsp) ;
  strcat(buf, "%)") ;
  write_text(adr_report, REPORT_DSP, buf) ;

  htod = 60.0*60.0*10.0 ;
  mtod = 60.0*10.0 ;
  stod = 10.0 ;
  hd   = (double)fr->report.t_calc/htod ;
  h    = (int) hd ;
  r    = (double)fr->report.t_calc-h*htod ;
  md   = r/mtod ;
  m    = (int) md ;
  r    = r-m*mtod ;
  sd   = r/stod ;
  s    = (int) sd ;
  d    = (int) (r-s*stod) ;
  memset(buf, 0, 50) ;
  sprintf(buf, "%.2d h, %.2d mn, %.2d s, %.1d '", h, m, s, d) ;
  write_text(adr_report, REPORT_TIME, buf) ;
  write_text(adr_report, REPORT_NAME, fr->nom) ;

  fshow_dialog(adr_report, titre) ;
  clicked = xform_do(-1, window_update) ;
  deselect(adr_report, clicked) ;
  fhide_dialog() ;
}

int same_aspect(FRACTAL *fr1, FRACTAL *fr2)
{
  if (fr1->type != fr2->type)             return(0) ;
  if (fr1->algorithme != fr2->algorithme) return(0) ;
  if (fr1->maxiter != fr2->maxiter)       return(0) ;
  if (fr1->ix != fr2->ix)                 return(0) ;
  if (fr1->iy != fr2->iy)                 return(0) ;
  if (fr1->xmin != fr2->xmin)             return(0) ;
  if (fr1->ymin != fr2->ymin)             return(0) ;
  if (fr1->xmax != fr2->xmax)             return(0) ;
  if (fr1->ymax != fr2->ymax)             return(0) ;
  if (fr1->largeur != fr2->largeur)       return(0) ;
  if (fr1->hauteur != fr2->hauteur)       return(0) ;
  if (fr1->centre_x != fr2->centre_x)     return(0) ;
  if (fr1->centre_y != fr2->centre_y)     return(0) ;

  return(1) ;
}

void ajust_double_in_text(char *buffer, double x)
{
  char temp[20] ;
  int  pos = 0 ;

  sprintf(temp, "%+.6e", x) ;
  buffer[0] = temp[0] ; buffer[1] = temp[1] ;
  for (pos = 2; pos <= 7; pos++) buffer[pos] = temp[1+pos] ;
  buffer[8]  = temp[10] ;
  buffer[9]  = temp[13] ;
  buffer[10] = temp[14] ;
  buffer[11] = 0 ;
}

double ajust_text_in_double(char *buffer)
{
  double nb ;
  double puiss ;
  char   temp[20] ;

  if (buffer[0] == '-') temp[0] = '-' ;
  else                  temp[0] = '+' ;
  temp[1] = buffer[1] ;
  temp[2] = '.' ;
  strncpy(&temp[3], &buffer[2], 6) ;
  temp[9] = 0 ;
  nb      = atof(temp) ;
  temp[0] = buffer[8] ;
  temp[1] = buffer[9] ;
  temp[2] = buffer[10] ;
  temp[3] = 0 ;
  puiss   = (double) atoi(temp) ;
  nb      = nb*pow(10,puiss) ;
  return(nb) ;
}

void img_fractal_update(int w_handle)
{
  int w_num ;
  int x, y ,w, h ;
  int xi, yi, wx, wy ;
  int rx, ry, rw, rh ;
  int posx, posy, is_icon ;
  int xyarray[8] ;

  w_num = num_wind(w_handle) ;
  if (w_num != -1)
  {
	v_hide_c(handle) ;
	wind_update(BEG_UPDATE) ;

	wind_get(w_handle, WF_WORKXYWH, &x, &y, &w, &h) ;
	wind_get(w_handle, WF_WORKXYWH, &xi, &yi, &wx, &wy) ;
	wind_get(w_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh) ;
	strcpy(window_name[w_num], fractal[w_num].nom) ;
	wind_set(window_handle[w_num], WF_NAME, window_name[w_num]) ;
	strcpy(window_info[w_num], "") ;
	wind_set(window_handle[w_num], WF_INFO, window_info[w_num]) ;

    is_icon = is_iconified(w_num) ;
    posx = winfo[w_num].x1 ;
    posy = winfo[w_num].y1 ;
	while (rw != 0)
	{
	  if (intersect(x, y, w, h, rx, ry, rw, rh, &xyarray[4]))
	  {
		xyarray[0] = xyarray[4]-xi ; xyarray[1] = xyarray[5]-yi ;
		xyarray[2] = xyarray[6]-xi ; xyarray[3] = xyarray[7]-yi ;
		if (xyarray[6] > Xmax)
		{
		  xyarray[2] = xyarray[2]-(xyarray[6]-Xmax) ;
		  xyarray[6] = Xmax ;
		}
		if (xyarray[7] > Ymax)
		{
		  xyarray[3] = xyarray[3]-(xyarray[7]-Ymax) ;
		  xyarray[7] = Ymax ;
		}
	    xyarray[0] += posx ; xyarray[1] += posy ;
	    xyarray[2] += posx ; xyarray[3] += posy ;
	    if (is_icon)
	    {
	      if (window_icon[w_num].fd_addr != NULL)
            vro_cpyfm(handle, S_ONLY, xyarray, &window_icon[w_num], &screen) ;
          else
          {
            vswr_mode(handle, MD_REPLACE) ;
            ftype.style     = FIS_HOLLOW ;
            ftype.color     = 0 ;
            ftype.sindex    = 0 ;
            ftype.perimeter = 0 ;
            set_filltype(&ftype) ;
            vr_recfl(handle, &xyarray[4]) ;
          }
        }
        else
	      vro_cpyfm(handle, S_ONLY, xyarray, &fractal[w_num].img, &screen) ;
	  }
	  wind_get(w_handle, WF_NEXTXYWH, &rx, &ry, &rw, &rh) ;
	}

	wind_update(END_UPDATE) ;
	v_show_c(handle, 1) ;
  }
}

void window_update(int *msg)
{
  FILL_TYPE ftype ;
  int       xyarray[8] ;
  int       cxy[4] ;
  int       w_handle, w_num ;
  int       x, y ,w, h ;
  int       xi, yi, wx, wy ;
  int       rx, ry, rw, rh ;
  int       posx, posy ;
  int       is_icon ;

  w_handle = msg[3] ;
  w_num    = num_wind(w_handle) ;
  if (w_num != -1)     /* Si ce message concerne bien cette application */
  {
    is_icon = is_iconified(w_num) ;
	v_hide_c(handle) ;
	wind_update(BEG_UPDATE) ;

    cxy[0] = xdesk ; cxy[1] = ydesk ;
    cxy[2] = Xmax ; cxy[3] = Ymax ;
    vs_clip(handle, 1, cxy) ;

	x = msg[4] ; y = msg[5] ;
	w = msg[6] ; h = msg[7] ;
	wind_get(w_handle, WF_WORKXYWH, &xi, &yi, &wx, &wy) ;
	wind_get(w_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh) ;

    wind_get(w_handle, WF_HSLIDE, &posx) ;
    wind_get(w_handle, WF_VSLIDE, &posy) ;
    if (is_icon) posx = posy = 0 ;
    else
    {
      if (w_handle != w_ani_handle)
      {
        posx = (int) (0.5+(double)posx/1000.0*(double)(fractal[w_num].img.fd_w-wx)) ;
        posy = (int) (0.5+(double)posy/1000.0*(double)(fractal[w_num].img.fd_h-wy)) ;
      }
      else
      {
        posx = (int) (0.5+(double)posx/1000.0*(double)(virtuel.fd_w-wx)) ;
        posy = (int) (0.5+(double)posy/1000.0*(double)(virtuel.fd_h-wy)) ;
      }
    }
    winfo[w_num].x1 = posx ;      winfo[w_num].y1 = posy ;
    winfo[w_num].x2 = posx+wx-1 ; winfo[w_num].y2 = posy+wy-1 ;

	while (rw != 0)
	{
	  if (intersect(x, y, w, h, rx, ry, rw, rh, &xyarray[4]))
	  {
		xyarray[0] = xyarray[4]-xi ; xyarray[1] = xyarray[5]-yi ;
		xyarray[2] = xyarray[6]-xi ; xyarray[3] = xyarray[7]-yi ;
	    xyarray[0] += posx ; xyarray[1] += posy ;
	    xyarray[2] += posx ; xyarray[3] += posy ;
	    if (is_icon)
	    {
          if ((w_handle != w_ani_handle) && (window_icon[w_num].fd_addr != NULL))
            vro_cpyfm(handle, S_ONLY, xyarray, &window_icon[w_num], &screen) ;
          else
          {
            vswr_mode(handle, MD_REPLACE) ;
            ftype.style     = FIS_HOLLOW ;
            ftype.color     = 0 ;
            ftype.sindex    = 0 ;
            ftype.perimeter = 0 ;
            set_filltype(&ftype) ;
            vr_recfl(handle, &xyarray[4]) ;
          }
        }
        else
        {
          if (w_handle != w_ani_handle)
		    vro_cpyfm(handle, S_ONLY, xyarray, &fractal[w_num].img, &screen) ;
		  else
		    vro_cpyfm(handle, S_ONLY, xyarray, &virtuel, &screen) ;
	    }
	  }
	  wind_get(w_handle, WF_NEXTXYWH, &rx, &ry, &rw, &rh) ;
	}

    vs_clip(handle, 0, cxy) ;
	wind_update(END_UPDATE) ;
	v_show_c(handle, 1) ;
  }
}

int infos(FRACTAL *fr_src)
{
  FRACTAL fr ;
  double  pc ;
  double  he ;
  int     bouton, clicked ;
  int     nx, ny ;
  int     off_x, off_y ;
  int     type, algo, i ;
  char    buf[50] ;

  memcpy(&fr, fr_src, sizeof(FRACTAL)) ;

  if (fr.report.t_calc == 0) adr_info[INFO_REPORT].ob_state |=  DISABLED ;
  else                       adr_info[INFO_REPORT].ob_state &= ~DISABLED ;
  write_text(adr_info, INFO_NOM, fr.nom) ;
  ajust_double_in_text(buf, fr.ix) ;
  write_text(adr_info, INFO_INITX, buf) ;
  ajust_double_in_text(buf, fr.iy) ;
  write_text(adr_info, INFO_INITY, buf) ;
  write_text(adr_info, INFO_TYPE, fractal_name[fr.type]) ;
  type = fr.type ;
  if (!fpu_type) fr.algorithme = LSM ;
  if (set_algo(type, DEM) == 0) popup_algo[1+DEM].ob_state |= DISABLED ;
  else                          popup_algo[1+DEM].ob_state &= ~DISABLED ;
  if (set_inits(fr.type, 'x'))
  {
    adr_info[INFO_INITX].ob_state &= ~DISABLED ;
    adr_info[INFO_INITX].ob_flags |= EDITABLE ;
  }
  else
  {
    adr_info[INFO_INITX].ob_state |= DISABLED ;
    adr_info[INFO_INITX].ob_flags &= ~EDITABLE ;
  }
  if (set_inits(fr.type, 'y'))
  {
    adr_info[INFO_INITY].ob_state &= ~DISABLED ;
    adr_info[INFO_INITY].ob_flags |= EDITABLE ;
  }
  else
  {
    adr_info[INFO_INITY].ob_state |= DISABLED ;
    adr_info[INFO_INITY].ob_flags &= ~EDITABLE ;
  }
  write_text(adr_info, INFO_ALGO, fractal_algo[fr.algorithme]) ;
  algo = fr.algorithme ;

  sprintf(buf, "%.5d", fr.maxiter) ;
  write_text(adr_info, INFO_ITER, buf) ;
  if (selected(adr_info, INFO_FENETRE))
  {
	write_template(adr_info, INFO_X1, "Xmin:__.______E___") ;
	write_template(adr_info, INFO_X2, "Xmax   :__.______E___") ;
	write_template(adr_info, INFO_Y1, "Ymin:__.______E___") ;
	write_template(adr_info, INFO_Y2, "Ymax   :__.______E___") ;
	ajust_double_in_text(buf, fr.xmin) ;
	write_text(adr_info, INFO_X1, buf) ;
	ajust_double_in_text(buf, fr.xmax) ;
	write_text(adr_info, INFO_X2, buf) ;
	ajust_double_in_text(buf, fr.ymin) ;
	write_text(adr_info, INFO_Y1, buf) ;
	ajust_double_in_text(buf, fr.ymax) ;
	write_text(adr_info, INFO_Y2, buf) ;
  }
  else
  {
	write_template(adr_info, INFO_X1, "Xc  :__.______E___") ;
	write_template(adr_info, INFO_X2, msg[MSG_WIDTH]) ;
	write_template(adr_info, INFO_Y1, "Yc  :__.______E___") ;
	write_template(adr_info, INFO_Y2, msg[MSG_HEIGHT]) ;
	ajust_double_in_text(buf, fr.centre_x) ;
	write_text(adr_info, INFO_X1, buf) ;
	ajust_double_in_text(buf, fr.largeur) ;
	write_text(adr_info, INFO_X2, buf) ;
	ajust_double_in_text(buf, fr.centre_y) ;
	write_text(adr_info, INFO_Y1, buf) ;
	ajust_double_in_text(buf, fr.hauteur) ;
	write_text(adr_info, INFO_Y2, buf) ;
  }
  if ((fr.img.fd_w % 512) == 0) fr.img.fd_w += 16 ;
  nx  = fr.img.fd_w ;
  ny  = fr.img.fd_h ;
  pc  = 100.0*(double)(nx)*(double)(ny) ;
  pc /= (double)Xmax*(double)Ymax ;
  sprintf(buf, "%.3d %%", (int) pc) ;
  write_text(adr_info, INFO_TAILLE, buf) ;
  sprintf(buf, "%.4d x %.4d", nx, ny) ;
  write_text(adr_info, INFO_PIXEL, buf) ;

  do
  {
	fshow_dialog(adr_info, titre) ;
	do
	{
	  bouton = xform_do(INFO_ITER, window_update) ;
	  switch(bouton)
	  {
	    case INFO_TYPE    : deselect(adr_info, INFO_TYPE) ;
                            objc_offset(adr_info, INFO_TYPE, &off_x, &off_y) ;
                            clicked = popup_formdo(&popup_name, off_x, off_y, 1+type, 0) ;
                            if (clicked > 0) type = clicked-1 ;
                            write_text(adr_info, INFO_TYPE, fractal_name[type]) ;
                            objc_draw(adr_info, INFO_TYPE, 0, xdesk, ydesk, wdesk, hdesk) ;
                            if (set_inits(type, 'x'))
                            {
                              adr_info[INFO_INITX].ob_state &= ~DISABLED ;
                              adr_info[INFO_INITX].ob_flags |= EDITABLE ;
                            }
                            else
                            {
                              adr_info[INFO_INITX].ob_state |= DISABLED ;
                              adr_info[INFO_INITX].ob_flags &= ~EDITABLE ;
                            }
                            if (set_inits(type, 'y'))
                            {
                              adr_info[INFO_INITY].ob_state &= ~DISABLED ;
                              adr_info[INFO_INITY].ob_flags |= EDITABLE ;
                            }
                            else
                            {
                              adr_info[INFO_INITY].ob_state |= DISABLED ;
                              adr_info[INFO_INITY].ob_flags &= ~EDITABLE ;
                            }
                            objc_draw(adr_info, INFO_INITX, 0, xdesk, ydesk, wdesk, hdesk) ;
                            objc_draw(adr_info, INFO_INITY, 0, xdesk, ydesk, wdesk, hdesk) ;
                            if (set_algo(type, algo) == 0)
                            {
                              algo = LSM ;
                              write_text(adr_info, INFO_ALGO, fractal_algo[LSM]) ;
                            }
                            objc_draw(adr_info, INFO_ALGO, 0, xdesk, ydesk, wdesk, hdesk) ;
                            if (set_algo(type, DEM) == 0) popup_algo[1+DEM].ob_state |= DISABLED ;
                            else                          popup_algo[1+DEM].ob_state &= ~DISABLED ;
	                        break ;
	    case INFO_ALGO    : deselect(adr_info, INFO_ALGO) ;
                            objc_offset(adr_info, INFO_ALGO, &off_x, &off_y) ;
                            clicked = popup_formdo(&popup_algo, off_x, off_y, 1+algo, 0) ;
                            if (clicked > 0) algo = clicked-1 ;
                            write_text(adr_info, INFO_ALGO, fractal_algo[algo]) ;
                            objc_draw(adr_info, INFO_ALGO, 0, xdesk, ydesk, wdesk, hdesk) ; 
	                        break ;
		case INFO_MOINS   : if (nx > 96)
							{
							  nx -= 16 ;
							  if ((nx % 512) == 0) nx -= 16 ; /* Huh ? */
							  ny  = (int) (((double)nx*(double)Ymax)/(double)Xmax) ;
							  ny  = 3*(ny/3) ;
							  pc  = 100.0*(double)(nx)*(double)(ny) ;
							  pc /= (double)Xmax * (double)Ymax ;
							  sprintf(buf, "%.3d %%", (int) pc) ;
							  write_text(adr_info, INFO_TAILLE, buf) ;
							  objc_draw(adr_info, INFO_TAILLE, 0, xdesk, ydesk, wdesk, hdesk) ;
							  sprintf(buf, "%.4d x %.4d", nx, ny) ;
							  write_text(adr_info, INFO_PIXEL, buf) ;
							  objc_draw(adr_info, INFO_PIXEL, 0, xdesk, ydesk, wdesk, hdesk) ;
							}
							break ;
		case INFO_PLUS    : he = (double)(nx+16)*(double)Ymax/(double)Xmax ;
							if (he < HMAX)
							{
							  nx += 16 ;
							  if ((nx % 512) == 0) nx += 16 ; /* Huh ? */
							  ny  = (int) (((double)nx*(double)Ymax)/(double)Xmax) ;
							  ny  = 3*(ny/3) ;
							  pc  = 100.0*(double)(nx)*(double)(ny) ;
							  pc /= (double)Xmax * (double)Ymax ;
							  sprintf(buf, "%.4d %%", (int) pc) ;
							  write_text(adr_info, INFO_TAILLE, buf) ;
							  objc_draw(adr_info, INFO_TAILLE, 0, xdesk, ydesk, wdesk, hdesk) ;
							  sprintf(buf, "%.4d x %.4d", nx, ny) ;
							  write_text(adr_info, INFO_PIXEL, buf) ;
							  objc_draw(adr_info, INFO_PIXEL, 0, xdesk, ydesk, wdesk, hdesk) ;
							}
							break ;
		case INFO_CENTRE  :
		case INFO_FENETRE : if (selected(adr_info, INFO_FENETRE))
							{
							  write_template(adr_info, INFO_X1, "Xmin:__.______E___") ;
							  write_template(adr_info, INFO_X2, "Xmax   :__.______E___") ;
							  write_template(adr_info, INFO_Y1, "Ymin:__.______E___") ;
							  write_template(adr_info, INFO_Y2, "Ymax   :__.______E___") ;
							  ajust_double_in_text(buf, fr.xmin) ;
							  write_text(adr_info, INFO_X1, buf) ;
							  ajust_double_in_text(buf, fr.xmax) ;
							  write_text(adr_info, INFO_X2, buf) ;
							  ajust_double_in_text(buf, fr.ymin) ;
							  write_text(adr_info, INFO_Y1, buf) ;
							  ajust_double_in_text(buf, fr.ymax) ;
							  write_text(adr_info, INFO_Y2, buf) ;
							}
							else
							{
							  write_template(adr_info, INFO_X1, "Xc  :__.______E___") ;
							  write_template(adr_info, INFO_X2, msg[MSG_WIDTH]) ;
							  write_template(adr_info, INFO_Y1, "Yc  :__.______E___") ;
							  write_template(adr_info, INFO_Y2, msg[MSG_HEIGHT]) ;
							  ajust_double_in_text(buf, fr.centre_x) ;
							  write_text(adr_info, INFO_X1, buf) ;
							  ajust_double_in_text(buf, fr.largeur) ;
							  write_text(adr_info, INFO_X2, buf) ;
							  ajust_double_in_text(buf, fr.centre_y) ;
							  write_text(adr_info, INFO_Y1, buf) ;
							  ajust_double_in_text(buf, fr.hauteur) ;
							  write_text(adr_info, INFO_Y2, buf) ;
							}
							objc_draw(adr_info, INFO_X1, 0, xdesk, ydesk, wdesk, hdesk) ;
							objc_draw(adr_info, INFO_X2, 0, xdesk, ydesk, wdesk, hdesk) ;
							objc_draw(adr_info, INFO_Y1, 0, xdesk, ydesk, wdesk, hdesk) ;
							objc_draw(adr_info, INFO_Y2, 0, xdesk, ydesk, wdesk, hdesk) ;
							break ;
		case INFO_RAZ     : fr.xmin     = f_default.xmin ;
							fr.xmax     = f_default.xmax ;
							fr.ymin     = f_default.ymin ;
							fr.ymax     = f_default.ymax ;
							fr.centre_x = f_default.centre_x ;
							fr.centre_y = f_default.centre_y ;
							fr.largeur  = f_default.largeur ;
							fr.hauteur  = f_default.hauteur ;
							ajust_double_in_text(buf, fr.centre_x) ;
							if (selected(adr_info, INFO_FENETRE))
							{
							  write_template(adr_info, INFO_X1, "Xmin:__.______E___") ;
							  write_template(adr_info, INFO_X2, "Xmax   :__.______E___") ;
							  write_template(adr_info, INFO_Y1, "Ymin:__.______E___") ;
							  write_template(adr_info, INFO_Y2, "Ymax   :__.______E___") ;
							  ajust_double_in_text(buf, fr.xmin) ;
							  write_text(adr_info, INFO_X1, buf) ;
							  ajust_double_in_text(buf, fr.xmax) ;
							  write_text(adr_info, INFO_X2, buf) ;
							  ajust_double_in_text(buf, fr.ymin) ;
							  write_text(adr_info, INFO_Y1, buf) ;
							  ajust_double_in_text(buf, fr.ymax) ;
							  write_text(adr_info, INFO_Y2, buf) ;
							}
							else
							{
							  write_template(adr_info, INFO_X1, "Xc  :__.______E___") ;
							  write_template(adr_info, INFO_X2, msg[MSG_WIDTH]) ;
							  write_template(adr_info, INFO_Y1, "Yc  :__.______E___") ;
							  write_template(adr_info, INFO_Y2, msg[MSG_HEIGHT]) ;
							  ajust_double_in_text(buf, fr.centre_x) ;
							  write_text(adr_info, INFO_X1, buf) ;
							  ajust_double_in_text(buf, fr.largeur) ;
							  write_text(adr_info, INFO_X2, buf) ;
							  ajust_double_in_text(buf, fr.centre_y) ;
							  write_text(adr_info, INFO_Y1, buf) ;
							  ajust_double_in_text(buf, fr.hauteur) ;
							  write_text(adr_info, INFO_Y2, buf) ;
							}
							objc_draw(adr_info, INFO_X1, 0, xdesk, ydesk, wdesk, hdesk) ;
							objc_draw(adr_info, INFO_X2, 0, xdesk, ydesk, wdesk, hdesk) ;
							objc_draw(adr_info, INFO_Y1, 0, xdesk, ydesk, wdesk, hdesk) ;
							objc_draw(adr_info, INFO_Y2, 0, xdesk, ydesk, wdesk, hdesk) ;
							break ;
	  }
	}
	while ((bouton != INFO_OK) && (bouton != INFO_ANNULE) && (bouton != -1) &&
		   (bouton != INFO_REPORT) && (bouton != INFO_AIDE)) ;

	deselect(adr_info, bouton) ;
	fhide_dialog() ;

	if (bouton == INFO_AIDE)
	{
	  OBJECT *adr_info_aide ;

	  Xrsrc_gaddr(R_TREE, FORM_AIDE, &adr_info_aide) ;
	  fshow_dialog(adr_info_aide, titre) ;
	  clicked = xform_do(-1, window_update) ;
	  deselect(adr_info_aide, clicked) ;
	  fhide_dialog() ;
	}

    if (bouton == INFO_REPORT) report(&fr) ;
  }
  while (bouton == INFO_AIDE) ;

  if (bouton != INFO_OK) return(0) ;

  read_text(adr_info, INFO_TYPE, buf) ;
  for (i = FIRST_SET; i <= LAST_SET; i++)
    if (strcmp(buf, fractal_name[i]) == 0) fr_src->type = i ;

  read_text(adr_info, INFO_ALGO, buf) ;
  for (i = LSM; i <= DEM; i++)
    if (strcmp(buf, fractal_algo[i]) == 0) fr_src->algorithme = i ;

  fr_src->img.fd_w       = nx ;
  fr_src->img.fd_h       = ny ;
  fr_src->img.fd_wdwidth = nx/16 ;
  fr_src->img.fd_stand   = 0 ;
  fr_src->img.fd_nplanes = nb_plane ;
  
  read_text(adr_info, INFO_ITER, buf) ;
  fr_src->maxiter = atoi(buf) ;

  read_text(adr_info, INFO_NOM, buf) ;
  strcpy(fr_src->nom, buf) ;

  if (selected(adr_info, INFO_KEEPNB)) return(1) ;

  read_text(adr_info, INFO_INITX, buf) ;
  fr_src->ix = ajust_text_in_double(buf) ;
  read_text(adr_info, INFO_INITY, buf) ;
  fr_src->iy = ajust_text_in_double(buf) ;

  if (selected(adr_info, INFO_FENETRE))
  {
	read_text(adr_info, INFO_X1, buf) ;
	fr_src->xmin = ajust_text_in_double(buf) ;
	read_text(adr_info, INFO_Y1, buf) ;
	fr_src->ymin = ajust_text_in_double(buf) ;
	read_text(adr_info, INFO_X2, buf) ;
	fr_src->xmax = ajust_text_in_double(buf) ;
	read_text(adr_info, INFO_Y2, buf) ;
	fr_src->ymax = ajust_text_in_double(buf) ;

	fr_src->centre_x = (fr.xmin+fr.xmax)/2 ;
	fr_src->centre_y = (fr.ymin+fr.ymax)/2 ;
	fr_src->largeur  = fabs(fr.xmax-fr.xmin) ;
	fr_src->hauteur  = fabs(fr.ymax-fr.ymin) ;
  }
  else
  {
	read_text(adr_info, INFO_X1, buf) ;
	fr_src->centre_x = ajust_text_in_double(buf) ;
	read_text(adr_info, INFO_Y1, buf) ;
	fr_src->centre_y = ajust_text_in_double(buf) ;
	read_text(adr_info, INFO_X2, buf) ;
	fr_src->largeur  = fabs(ajust_text_in_double(buf)) ;
	read_text(adr_info, INFO_Y2, buf) ;
	fr_src->hauteur  = fabs(ajust_text_in_double(buf)) ;

	fr_src->xmin = fr.centre_x-fr.largeur/2 ;
	fr_src->ymin = fr.centre_y-fr.hauteur/2 ;
	fr_src->xmax = fr.centre_x+fr.largeur/2 ;
	fr_src->ymax = fr.centre_y+fr.hauteur/2 ;
  }

  return(1) ;
}

void zoom_centre(void)
{
  FRACTAL fr ;
  double  cx, cy, ex, ey, dh ;
  double  ratio ;
  double  posx, posy ;
  double  wish, accuracy ;
  int     xi1, yi1, wi, hi, xi2, yi2 ;
  int     xm, ym, xyarray[8] ;
  int     xs1, ys1, xs2, ys2 ;
  int     xr1, yr1, xr2, yr2 ;
  int     dy1 ;
  int     dx2, dy2 ;
  int     status ;
  int     flag_scroll = 0 ;
  int     new ;
  char    fini = 0 ;

  wind_update(BEG_UPDATE) ;
  accuracy = pow(2.0, -23.0)/ftof ;
  ratio    = (double)fractal[num_window].img.fd_w/(double)fractal[num_window].img.fd_h ;
  posx     = (double)winfo[num_window].x1*fractal[num_window].largeur/(double)fractal[num_window].img.fd_w ;
  posy     = (double)winfo[num_window].y1*fractal[num_window].hauteur/(double)fractal[num_window].img.fd_h ;
  wind_get(window_handle[num_window], WF_WORKXYWH, &xi1, &yi1, &wi, &hi) ;
  wind_set(window_handle[num_window], WF_TOP) ;
  img_fractal_update(window_handle[num_window]) ;
  xi2 = xi1+wi-1 ;
  yi2 = yi1+hi-1 ;
  xm  = (xi1+xi2)/2 ;
  ym  = (yi1+yi2)/2 ;
  vswr_mode(handle, MD_XOR) ;
  vsl_width(handle, 1) ;
  vsl_type(handle, SOLID) ;
  vsin_mode(handle, 1, 2) ;     /* Entr‚e mode sample pour la souris */
  xyarray[0] = xi1 ;   xyarray[1] = yi1 ;
  xyarray[2] = xi2 ;   xyarray[3] = yi2 ;
  vs_clip(handle, 1, xyarray) ; /* Travailler uniquement dans la fenˆtre */
  vsl_color(handle, 1) ;        /* Couleur 1 de trac‚ */
  vsm_locator(handle, xm, ym, &xs1, &ys1, &xs1) ;
  v_hide_c(handle) ;
  xs1 = xs2 = xm ;
  ys1 = ys2 = ym ;
  line(xi1, ys1, xi2, ys1) ;
  line(xs1, yi1, xs1, yi2) ;
  ex = fractal[num_window].largeur/(double)fractal[num_window].img.fd_w ;
  ey = fractal[num_window].hauteur/(double)fractal[num_window].img.fd_h ;
  cx = fractal[num_window].centre_x ;
  cy = fractal[num_window].centre_y ;
  cx += posx ;
  cy -= posy ;
  sprintf(window_info[num_window], "%.8e  %.8e", cx, cy) ;
  wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
  while (!fini)
  {
	vq_mouse(handle, &status, &xs2, &ys2) ;
    if (xs2 < xi1)
    {
      winfo[num_window].x1 -= 8 ;
      winfo[num_window].x2 -= 8 ;
      flag_scroll = 1 ;
    }
    if (ys2 < yi1)
    {
      winfo[num_window].y1 -= 8 ;
      winfo[num_window].y2 -= 8 ;
      flag_scroll = 1 ;
    }
    if (xs2 >= xi1+wi)
    {
      winfo[num_window].x1 += 8 ;
      winfo[num_window].x2 += 8 ;
      flag_scroll = 1 ;
    }
    if (ys2 >= yi1+hi)
    {
      winfo[num_window].y1 += 8 ;
      winfo[num_window].y2 += 8 ;
      flag_scroll = 1 ;
    }
    if (flag_scroll)
    {
      int xy[8] ;
      int delta ;

      if (winfo[num_window].x1 < 0)
      {
        delta = -winfo[num_window].x1 ;
        winfo[num_window].x1  = 0 ;
        winfo[num_window].x2 += delta ;
      }
      if (winfo[num_window].y1 < 0)
      {
        delta = -winfo[num_window].y1 ;
        winfo[num_window].y1  = 0 ;
        winfo[num_window].y2 += delta ;
      }
      if (winfo[num_window].x2 >= fractal[num_window].img.fd_w)
      {
        delta = -(winfo[num_window].x2-fractal[num_window].img.fd_w+1) ;
        winfo[num_window].x2  = fractal[num_window].img.fd_w-1 ;
        winfo[num_window].x1 += delta ;
      }
      if (winfo[num_window].y2 >= fractal[num_window].img.fd_h)
      {
        delta = -(winfo[num_window].y2-fractal[num_window].img.fd_h+1) ;
        winfo[num_window].y2  = fractal[num_window].img.fd_h-1 ;
        winfo[num_window].y1 += delta ;
      }
      xy[0] = winfo[num_window].x1 ; xy[1] = winfo[num_window].y1 ;
      xy[2] = winfo[num_window].x2 ; xy[3] = winfo[num_window].y2 ;
      xy[4] = xi1 ;                  xy[5] = yi1 ;
      xy[6] = xi1+wi-1 ;             xy[7] = yi1+hi-1 ;
      vro_cpyfm(handle, S_ONLY, xy, &fractal[num_window].img, &screen) ;
      flag_scroll = 0 ;
	  line(xi1, ys1, xi2, ys1) ;
	  line(xs1, yi1, xs1, yi2) ;
      posx = (double)winfo[num_window].x1*fractal[num_window].largeur/(double)fractal[num_window].img.fd_w ;
      posy = (double)winfo[num_window].y1*fractal[num_window].hauteur/(double)fractal[num_window].img.fd_h ;
    }
	 if ((xs2 != xs1) || (ys2 != ys1))
	 {
	   line(xi1, ys1, xi2, ys1) ;
	   line(xs1, yi1, xs1, yi2) ;
	   xs1 = xs2 ;
	   ys1 = ys2 ;
	   line(xi1, ys1, xi2, ys1) ;
	   line(xs1, yi1, xs1, yi2) ;
	   cx  = fractal[num_window].xmin+(xs1-xi1)*ex ;
	   cy  = fractal[num_window].ymin+fractal[num_window].hauteur-(ys1-yi1)*ey ;
	   cx += posx ;
	   cy -= posy ;
	   sprintf(window_info[num_window], "%.8e  %.8e", cx, cy) ;
	   wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
	 }

	 if (status == 1)
	 {
	   if ((xs1 >= xi1) && (xs1 <= xi2) && (ys1 >= yi1) && (ys1 <= yi2))
		 fini = 1 ;
	   else
	   {
		 v_show_c(handle, 1) ;
		 form_exclamation(1, msg[MSG_ZOOMCERR]) ;
		 v_hide_c(handle) ;
	   }
	 }
  }
  line(xi1, ys1, xi2, ys1) ;
  line(xs1, yi1, xs1, yi2) ;
  /* cx et cy contiennent maintenant les coordonn‚es du centre choisi */

  fini = 0 ;
  xr1  = xs1 ;  yr1 = ys1 ;
  xr2  = xs1 ;  yr2 = ys1 ;
  dy1  = ys1 ;
  dx2  = xs1 ;  dy2 = ys1 ;
  rectangle(xr1, yr1, xr2, yr2) ;

  do
  {
	vq_mouse(handle, &status, &dx2, &dy2) ;
  }
  while (status != 0) ;

  vsm_locator(handle, xs1, ys1, &dx2, &dy2, &dx2) ;
  while (!fini)
  {
	vq_mouse(handle, &status, &dx2, &dy2) ;
	if (dy2 != dy1)
	{
	  rectangle(xr1, yr1, xr2, yr2) ;
	  yr2 = dy2 ;
	  xr1 = (int) ((double)xs1 - (double)(yr2-ys1)*ratio) ;
	  xr2 = (int) ((double)xs1 + (double)(yr2-ys1)*ratio) ;
	  yr1 = ys1 - (yr2-ys1) ;
	  dy1 = dy2 ;
	  rectangle(xr1, yr1, xr2, yr2) ;
	  dh = 2*fabs(yr2-ys1)*ey ;
	  sprintf(window_info[num_window], msg[MSG_SEEH], dh) ;
      wish     = dh/fractal[num_window].img.fd_h ;
      if (wish > accuracy) strcat(window_info[num_window], " DSP") ;
	  wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
	}

	if (status == 1) fini = 1 ;
  }

  rectangle(xr1, yr1, xr2, yr2) ;
  v_show_c(handle, 1) ;
  memcpy(&fr, &fractal[num_window], sizeof(FRACTAL)) ;
  fr.largeur  = dh*(double)Xmax/(double)Ymax ;
  fr.hauteur  = dh ;
  fr.centre_x = cx ;
  fr.centre_y = cy ;
  fr.xmin     = cx - fr.largeur/2 ;
  fr.ymin     = cy - fr.hauteur/2 ;
  fr.xmax     = cx + fr.largeur/2 ;
  fr.ymax     = cy + fr.hauteur/2 ;

  new = (int) (0.5+1000.0*(double)winfo[num_window].x1/(double)(fractal[num_window].img.fd_w-wi)) ;
  wind_set(window_handle[num_window], WF_HSLIDE, new) ;
  new = (int) (0.5+1000.0*(double)winfo[num_window].y1/(double)(fractal[num_window].img.fd_h-hi)) ;
  wind_set(window_handle[num_window], WF_VSLIDE, new) ;
  select(adr_info, INFO_CENTRE) ;
  deselect(adr_info, INFO_FENETRE) ;
  adr_info[INFO_MOINS].ob_flags &= ~TOUCHEXIT ;
  adr_info[INFO_PLUS].ob_flags  &= ~TOUCHEXIT ;
  adr_info[INFO_MOINS].ob_state |= DISABLED ;
  adr_info[INFO_PLUS].ob_state  |= DISABLED ;
  wind_update(END_UPDATE) ;
  if (infos(&fr) == 1)
  {
	if (!same_aspect(&fr, &fractal[num_window]))
	{
	  ev_num          = num_window ;
	  event.ev_mflags = MU_KEYBD|MU_MESAG|MU_TIMER ;
	}
	memcpy(&fractal[num_window], &fr, sizeof(FRACTAL)) ;
	/* On recopie les coordonn‚es pour ‚viter */
	/* Un perte lors de zooms avanc‚s         */
	fractal[num_window].largeur  = fr.largeur ;
	fractal[num_window].hauteur  = fr.hauteur ;
	fractal[num_window].centre_x = fr.centre_x ;
	fractal[num_window].centre_y = fr.centre_y ;
	fractal[num_window].xmin     = fr.xmin ;
	fractal[num_window].ymin     = fr.ymin ;
	fractal[num_window].xmax     = fr.xmax ;
	fractal[num_window].ymax     = fr.ymax ;
  }

  vswr_mode(handle, MD_REPLACE) ;
  strcpy(window_name[num_window], fractal[num_window].nom) ;
  wind_set(window_handle[num_window], WF_NAME, window_name[num_window]) ;
  strcpy(window_info[num_window], "") ;
  wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
  vs_clip(handle, 0, xyarray) ; /* D‚sactiver le clipping */
}

void zoom_zone(void)
{
  FRACTAL fr, frn ;
  double  ex, ey, dh ;
  double  posx, posy ;
  double  wish, accuracy ;
  int     xi1, yi1, wi, hi, xi2, yi2 ;
  int     xm, ym, xyarray[8] ;
  int     xs, ys ;
  int     xr1, yr1, xr2, yr2 ;
  int     dx, dy ;
  int     status, dep ;
  int     new ;
  int     flag_scroll = 0 ;
  char    fini = 0 ;

  wind_update(BEG_UPDATE) ;
  wind_get(window_handle[num_window], WF_WORKXYWH, &xi1, &yi1, &wi, &hi) ;
  wind_set(window_handle[num_window], WF_TOP) ;
  img_fractal_update(window_handle[num_window]) ;
  xi2 = xi1+wi-1 ;
  yi2 = yi1+hi-1 ;
  xm  = (xi1+xi2)/2 ;
  ym  = (yi1+yi2)/2 ;
  vswr_mode(handle, MD_XOR) ;
  vsl_type(handle, SOLID) ;
  vsl_ends(handle, SQUARE, SQUARE) ;
  vsl_width(handle, 1) ;
  vsin_mode(handle, 1, 2) ;     /* Entr‚e mode sample pour la souris */
  xyarray[0] = xi1 ;   xyarray[1] = yi1 ;
  xyarray[2] = xi2 ;   xyarray[3] = yi2 ;
  vs_clip(handle, 1, xyarray) ; /* Travailler uniquement dans la fenˆtre */
  vsl_color(handle, 1) ;        /* Couleur 1 de trac‚ */
  dx  = wi/4 ; dy = (int) ((double)dx*(double)Ymax/(double)Xmax) ;
  xr1 = xm-dx/2 ; yr1 = ym-dy/2 ;
  xr2 = xm+dx/2 ; yr2 = ym+dy/2 ;
  vsm_locator(handle, xr1, yr1, &xs, &ys, &xs) ;
  v_hide_c(handle) ;
  rectangle(xr1, yr1, xr2, yr2) ;
  xs = xr1 ; ys = yr1 ;
  ex = fractal[num_window].largeur/(double)fractal[num_window].img.fd_w ;
  ey = fractal[num_window].hauteur/(double)fractal[num_window].img.fd_h ;
  dh = fabs(dy)*ey ;
  sprintf(window_info[num_window], msg[MSG_SEEH], dh) ;
  accuracy = pow(2.0, -23.0)/ftof ;
  wish     = dh/fractal[num_window].img.fd_h ;
  if (wish > accuracy) strcat(window_info[num_window], " DSP") ;
  wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;

  while (kbhit()) getch() ;
  while (!fini)
  {
	vq_mouse(handle, &status, &xs, &ys) ;

    if (xs < xi1)
    {
      winfo[num_window].x1 -= 8 ;
      winfo[num_window].x2 -= 8 ;
      flag_scroll = 1 ;
    }
    if (ys < yi1)
    {
      winfo[num_window].y1 -= 8 ;
      winfo[num_window].y2 -= 8 ;
      flag_scroll = 1 ;
    }
    if (xs >= xi1+wi)
    {
      winfo[num_window].x1 += 8 ;
      winfo[num_window].x2 += 8 ;
      flag_scroll = 1 ;
    }
    if (ys >= yi1+hi)
    {
      winfo[num_window].y1 += 8 ;
      winfo[num_window].y2 += 8 ;
      flag_scroll = 1 ;
    }
    if (flag_scroll)
    {
      int xy[8] ;
      int delta ;

      if (winfo[num_window].x1 < 0)
      {
        delta = -winfo[num_window].x1 ;
        winfo[num_window].x1  = 0 ;
        winfo[num_window].x2 += delta ;
      }
      if (winfo[num_window].y1 < 0)
      {
        delta = -winfo[num_window].y1 ;
        winfo[num_window].y1  = 0 ;
        winfo[num_window].y2 += delta ;
      }
      if (winfo[num_window].x2 >= fractal[num_window].img.fd_w)
      {
        delta = -(winfo[num_window].x2-fractal[num_window].img.fd_w+1) ;
        winfo[num_window].x2  = fractal[num_window].img.fd_w-1 ;
        winfo[num_window].x1 += delta ;
      }
      if (winfo[num_window].y2 >= fractal[num_window].img.fd_h)
      {
        delta = -(winfo[num_window].y2-fractal[num_window].img.fd_h+1) ;
        winfo[num_window].y2  = fractal[num_window].img.fd_h-1 ;
        winfo[num_window].y1 += delta ;
      }
      xy[0] = winfo[num_window].x1 ; xy[1] = winfo[num_window].y1 ;
      xy[2] = winfo[num_window].x2 ; xy[3] = winfo[num_window].y2 ;
      xy[4] = xi1 ;                  xy[5] = yi1 ;
      xy[6] = xi1+wi-1 ;             xy[7] = yi1+hi-1 ;
      vro_cpyfm(handle, S_ONLY, xy, &fractal[num_window].img, &screen) ;
      flag_scroll = 0 ;
	  rectangle(xr1, yr1, xr2, yr2) ;
    }
	if ((xs != xr1) || (ys != yr1))
	{
	  rectangle(xr1, yr1, xr2, yr2) ;
	  xr1 = xs ;       yr1 = ys ;
	  xr2 = xr1 + dx ; yr2 = yr1 + dy ;
	  rectangle(xr1, yr1, xr2, yr2) ;
	}
	else
	{
	  if (status == 1) dep = -2 ;
	  if (status == 2) dep = +2 ;
	  if (status != 0)
	  {
		rectangle(xr1, yr1, xr2, yr2) ;
		dx += dep ;  dy = (int) ((double)dx*(double)Ymax/(double)Xmax) ;
		dh  = fabs(dy)*ey ;
		xr2 = xr1 + dx ; yr2 = yr1 + dy ;
		rectangle(xr1, yr1, xr2, yr2) ;
		sprintf(window_info[num_window], msg[MSG_SEEH], dh) ;
        wish = dh/fractal[num_window].img.fd_h ;
        if (wish > accuracy) strcat(window_info[num_window], " DSP") ;
		wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
	  }
	}
	fini = kbhit() ;
  }

  rectangle(xr1, yr1, xr2, yr2) ;
  v_show_c(handle, 1) ;
  memcpy(&fr, &fractal[num_window], sizeof(FRACTAL)) ;
  posx = (double)winfo[num_window].x1*fractal[num_window].largeur/(double)fractal[num_window].img.fd_w ;
  posy = (double)winfo[num_window].y1*fractal[num_window].hauteur/(double)fractal[num_window].img.fd_h ;
  new = (int) (0.5+1000.0*(double)winfo[num_window].x1/(double)(fractal[num_window].img.fd_w-wi)) ;
  wind_set(window_handle[num_window], WF_HSLIDE, new) ;
  new = (int) (0.5+1000.0*(double)winfo[num_window].y1/(double)(fractal[num_window].img.fd_h-hi)) ;
  wind_set(window_handle[num_window], WF_VSLIDE, new) ;
  fr.largeur  = dh*(double)Xmax/(double)Ymax ;
  fr.hauteur  = dh ;
  fr.xmin     = fractal[num_window].xmin + (xr1-xi1)*ex ;
  fr.ymax     = fractal[num_window].ymax - (yr1-yi1)*ey ;
  fr.centre_x = fr.xmin + fr.largeur/2 ;
  fr.centre_y = fr.ymax - fr.hauteur/2 ;
  fr.xmax     = fr.xmin + fr.largeur ;
  fr.ymin     = fr.ymax - fr.hauteur ;

  fr.centre_x += posx ;
  fr.xmin     += posx ;
  fr.xmax     += posx ;
  fr.centre_y -= posy ;
  fr.ymin     -= posy ;
  fr.ymax     -= posy ;
  
  deselect(adr_info, INFO_CENTRE) ;
  select(adr_info, INFO_FENETRE) ;
  adr_info[INFO_MOINS].ob_flags &= ~TOUCHEXIT ;
  adr_info[INFO_PLUS].ob_flags  &= ~TOUCHEXIT ;
  adr_info[INFO_MOINS].ob_state |= DISABLED ;
  adr_info[INFO_PLUS].ob_state  |= DISABLED ;
  memcpy(&frn, &fr, sizeof(FRACTAL)) ;
  wind_update(END_UPDATE) ;
  if (infos(&fr) == 1)
  {
	if (!same_aspect(&fr, &fractal[num_window]))
	{
	  ev_num          = num_window ;
	  event.ev_mflags = MU_KEYBD|MU_MESAG|MU_TIMER ;
	}
	memcpy(&fractal[num_window], &fr, sizeof(FRACTAL)) ;
	/* On recopie les coordonn‚es pour ‚viter */
	/* Un perte lors de zooms avanc‚s         */
	fractal[num_window].largeur  = frn.largeur ;
	fractal[num_window].hauteur  = frn.hauteur ;
	fractal[num_window].centre_x = frn.centre_x ;
	fractal[num_window].centre_y = frn.centre_y ;
	fractal[num_window].xmin     = frn.xmin ;
	fractal[num_window].ymin     = frn.ymin ;
	fractal[num_window].xmax     = frn.xmax ;
	fractal[num_window].ymax     = frn.ymax ;
  }

  vswr_mode(handle, MD_REPLACE) ;
  strcpy(window_info[num_window], "") ;
  wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
  vs_clip(handle, 0, xyarray) ; /* D‚sactiver le clipping */
}

void show_set(void)
{
  int xy[8] ;
  int rx, ry, rw, rh ;

  flag_show = 0 ;
 
  calcul_go(&fr, handle_fr) ;
  wind_get(handle_fr, WF_FIRSTXYWH, &rx, &ry, &rw, &rh) ;
  while (rw != 0)
  {
    if (intersect(xfr, yfr, wfr, hfr, rx, ry, rw, rh, &xy[4]))
	{
	  xy[0] = xy[4]-xfr ; xy[1] = xy[5]-yfr ;
	  xy[2] = xy[6]-xfr ; xy[3] = xy[7]-yfr ;
      vro_cpyfm(handle, S_ONLY, xy, &fr.img, &screen) ;
	}
	wind_get(handle_fr, WF_NEXTXYWH, &rx, &ry, &rw, &rh) ;
  }

  flag_show = 1 ;
}

void get_init_fractal(int w_num, double *ix, double *iy)
{
  double  cx, cy, ex, ey ;
  int     xi1, yi1, wi, hi, xi2, yi2 ;
  int     xm, ym, xyarray[4] ;
  int     xs1, ys1, xs2, ys2 ;
  int     status ;
  char    fini = 0 ;

  wind_update(BEG_UPDATE) ;
  wind_get(window_handle[w_num], WF_WORKXYWH, &xi1, &yi1, &wi, &hi) ;
  xi2 = xi1 + wi ;
  yi2 = yi1 + hi ;
  xm  = (xi1+xi2)/2 ;
  ym  = (yi1+yi2)/2 ;
  vswr_mode(handle, MD_XOR) ;
  vsl_type(handle, SOLID) ;
  vsin_mode(handle, 1, 2) ;     /* Entr‚e mode sample pour la souris */
  xyarray[0] = xi1 ;   xyarray[1] = yi1 ;
  xyarray[2] = xi2 ;   xyarray[3] = yi2 ;
  vs_clip(handle, 1, xyarray) ; /* Travailler uniquement dans la fenˆtre */
  vsl_color(handle, 1) ;        /* Couleur 1 de trac‚ */
  vsl_width(handle, 1) ;
  vsm_locator(handle, xm, ym, &xs1, &ys1, &xs1) ;
  xs1 = xs2 = xm ;
  ys1 = ys2 = ym ;
  v_hide_c(handle) ;
  line(xi1, ys1, xi2, ys1) ;
  line(xs1, yi1, xs1, yi2) ;
  v_show_c(handle, 1) ;
  ex = Mandel.largeur/wi ;
  ey = Mandel.hauteur/hi ;
  fr.ix = cx = Mandel.centre_x ;
  fr.iy = cy = Mandel.centre_y ;
  sprintf(window_info[w_num], "%.3e  %.3e", cx, cy) ;
  wind_set(window_handle[w_num], WF_INFO, window_info[w_num]) ;
  init_real_time() ;
  vs_clip(handle, 0, xyarray) ; /* D‚sactiver le clipping */
  show_set() ;
  vs_clip(handle, 1, xyarray) ; /* R‚activer le clipping */
  while (!fini)
  {
	 vq_mouse(handle, &status, &xs2, &ys2) ;
	 if ((xs2 != xs1) || (ys2 != ys1))
	 {
	   v_hide_c(handle) ;
	   line(xi1, ys1, xi2, ys1) ;
	   line(xs1, yi1, xs1, yi2) ;
	   xs1 = xs2 ;
	   ys1 = ys2 ;
	   line(xi1, ys1, xi2, ys1) ;
	   line(xs1, yi1, xs1, yi2) ;
	   cx = Mandel.xmin + (xs1-xi1)*ex ;
	   cy = Mandel.ymin + Mandel.hauteur
			- (ys1-yi1)*ey ;
	   sprintf(window_info[w_num], "%.5e  %.5e", cx, cy) ;
	   wind_set(window_handle[w_num], WF_INFO, window_info[w_num]) ;
       v_show_c(handle, 1) ;
	   fr.ix = cx ;
	   fr.iy = cy ;
	   if ((fabs(fr.ix) < 4.0) && (fabs(fr.iy) < 4.0))
	   {
         vs_clip(handle, 0, xyarray) ; /* D‚sactiver le clipping */
	     show_set() ;
         vs_clip(handle, 1, xyarray) ; /* R‚activer le clipping */
       }
	 }

	 fini = (status == 1) ;
  }
  line(xi1, ys1, xi2, ys1) ;
  line(xs1, yi1, xs1, yi2) ;
  /* cx et cy contiennent maintenant les coordonn‚es du centre choisi */

  vswr_mode(handle, MD_REPLACE) ;
  vs_clip(handle, 0, xyarray) ; /* D‚sactiver le clipping */
  *ix = cx ;
  *iy = cy ;
  wind_update(END_UPDATE) ;
}

void init_fractal(FRACTAL *fr_in)
{
  FRACTAL frac ;
  double  ix, iy ;
  int     last_handle ;
  int     xyarray[8] ;
  int     num ;
  int     wy, dummy ;

  if (num_window == -1) return ;

  wfr = fr.img.fd_w ;
  hfr = fr.img.fd_h ;
  fr.maxiter  = config.tr_maxiter ;
  fr.type     = fractal[num_window].type ;
  fr.img.fd_addr = img_alloc(fr.img.fd_w, fr.img.fd_h, nb_plane) ;
  if (fr.img.fd_addr == NULL)
  {
    form_error(8) ;
    return ;
  }
  fr.img.fd_w = wfr ;
  fr.img.fd_h = hfr ;
  fr.img.fd_nplanes = nb_plane ;
  fr.img.fd_wdwidth = wfr/16 ;
  fr.img.fd_stand = 0 ;
  if ((set_inits(fractal[num_window].type, 'x') == 0) && (set_inits(fractal[num_window].type, 'y') == 0))
    return ;

  wind_calc(WC_WORK, NAME, (Xmax-wfr-8) & 0xFFF0,
			Ymax-hfr-32, wfr, hfr, &dummy, &wy, &dummy, &dummy) ;
  handle_fr = open_fwindow(NAME, (Xmax-wfr-8) & 0xFFF0, wy, wfr, hfr) ;
  if (handle_fr < 0)
  {
	form_interrogation(1, msg[MSG_NOMOREWINDOW]) ;
	free(fr.img.fd_addr) ;
	close_window(handle_fr) ;
	return ;
  }

  wind_get(handle_fr, WF_WORKXYWH, &xfr, &yfr, &wfr, &hfr) ;
  last_handle = window_handle[num_window] ;
  num         = num_new_window() ;
  if (num == -1)
  {
	form_interrogation(1, msg[MSG_NOMOREWINDOW]) ;
	free(fr.img.fd_addr) ;
	close_window(handle_fr) ;
	return ;
  }

  wind_calc(WC_WORK, NAME|INFO, ((Xmax-Mandel.img.fd_w)/2) & 0xFFF0,
			ydesk, Mandel.img.fd_w, Mandel.img.fd_h, &dummy, &wy, &dummy, &dummy) ;
  window_handle[num] = open_fwindow(NAME|INFO, 16,
									wy, Mandel.img.fd_w, Mandel.img.fd_h) ;
  if (window_handle[num] < 0)
  {
	form_interrogation(1, msg[MSG_NOMOREWINDOW]) ;
	free(fr.img.fd_addr) ;
	close_window(handle_fr) ;
	return ;
  }

  window_opened[num] = 1 ;
  strcpy(window_name[num], " MANDELBROT ") ;
  wind_set(window_handle[num], WF_NAME, window_name[num]) ;

  xyarray[0] = 0 ;                 xyarray[1] = 0 ;
  xyarray[2] = Mandel.img.fd_w-1 ; xyarray[3] = Mandel.img.fd_h-1 ;

  wind_get(window_handle[num], WF_WORKXYWH, &xyarray[4], &xyarray[5], &xyarray[6], &xyarray[7]) ;
  xyarray[6] = xyarray[4] + Mandel.img.fd_w-1 ;
  xyarray[7] = xyarray[5] + Mandel.img.fd_h-1 ;
  v_hide_c(handle) ;
  vro_cpyfm(handle, S_ONLY, xyarray, &Mandel.img, &screen) ;
  v_show_c(handle, 1) ;

  get_init_fractal(num, &ix, &iy) ;

  close_window(handle_fr) ;
  close_window(window_handle[num]) ;
  redraws() ;

  memcpy(&frac, fr_in, sizeof(FRACTAL)) ;
  frac.ix = ix ;
  frac.iy = iy ;
  adr_info[INFO_MOINS].ob_flags &= ~TOUCHEXIT ;
  adr_info[INFO_PLUS].ob_flags  &= ~TOUCHEXIT ;
  adr_info[INFO_MOINS].ob_state |= DISABLED ;
  adr_info[INFO_PLUS].ob_state  |= DISABLED ;
  if (infos(&frac) == 1)
  {
	if (!same_aspect(&frac, fr_in))
	{
	  ev_num          = num_window ;
	  event.ev_mflags = MU_KEYBD|MU_MESAG|MU_TIMER ;
	}
	
	memcpy(fr_in, &frac, sizeof(FRACTAL)) ;
  }

  free(fr.img.fd_addr) ;
  wind_set(last_handle, WF_TOP, 0, 0, 0, 0) ;
}

int lance_calcul(int num_fractal)
{
  int status ;

  switch(data_ok(&fractal[num_fractal]))
  {
	case ERR_INCOMP : if (fpu_type) config.calc_format = REEL ;
	                  else
	                  {
	                    form_exclamation(1, msg[MSG_NEEDFPU]) ;
	                    return(-1) ;
	                  }
	                  break ;
	case ERR_ZONE   : form_exclamation(1, msg[MSG_ERRZONE]) ;
					  return(-1) ;
	case ERR_DELTA  : form_exclamation(1, msg[MSG_ERRDELTA]) ;
			 		  return(-1) ;
  }

  wind_set(window_handle[num_fractal], WF_TOP) ;
  status = calcul_go(&fractal[num_fractal], window_handle[num_fractal]) ;

  return(status) ;
}

void ajour_menu(void)
{
  int new_num ;

  new_num = num_new_window() ;
  if (new_num != -1)
  {
	menu_ienable(adr_menu, M_NOUVEAU, 1) ;
	menu_ienable(adr_menu, M_CHARGE, 1) ;
	if ((num_window != -1) && (window_handle[num_window] != w_ani_handle))
	      menu_ienable(adr_menu, M_DUPLIQUE, 1) ;
	else  menu_ienable(adr_menu, M_DUPLIQUE, 0) ;
  }
  else
  {
	menu_ienable(adr_menu, M_NOUVEAU, 0) ;
	menu_ienable(adr_menu, M_CHARGE, 0) ;
	menu_ienable(adr_menu, M_DUPLIQUE, 0) ;
  }

  if (stat_anim.debut != -1)
  {
    if (window_opened[stat_anim.debut] != 1)
    {
	  menu_icheck(adr_menu, M_ANIMD, 0) ;
	  stat_anim.debut = -1 ;
    }
  }
  if (stat_anim.fin != -1)
  {
    if (window_opened[stat_anim.fin] != 1)
    {
	  menu_icheck(adr_menu, M_ANIMF, 0) ;
	  stat_anim.fin = -1 ;
    }
  }

  if (num_window != -1)
  {
	menu_ienable(adr_menu, M_FERME, 1) ;
	if (window_handle[num_window] != w_ani_handle)
	{
	  menu_ienable(adr_menu, M_SAUVE, 1) ;
	  menu_ienable(adr_menu, M_SAUVES, 1) ;
	  menu_ienable(adr_menu, M_COPIER, 1) ;
	  menu_ienable(adr_menu, M_EXPORT, 1) ;
	  menu_ienable(adr_menu, M_IMPRIMER, 1) ;
	  menu_ienable(adr_menu, M_ZOOMC, 1) ;
	  menu_ienable(adr_menu, M_ZOOMF, 1) ;
	  menu_ienable(adr_menu, M_CALCUL, 1) ;
	  if ((set_inits(fractal[num_window].type, 'x') == 1) || (set_inits(fractal[num_window].type, 'y') == 1))
	    menu_ienable(adr_menu, M_INIT, 1) ;
	  else
	    menu_ienable(adr_menu, M_INIT, 0) ;
	  menu_ienable(adr_menu, M_TAILLE, 1) ;
	  if (nb_colors >= 16)
	  {
	    menu_ienable(adr_menu, M_CYCLING1, 1) ;
	    menu_ienable(adr_menu, M_CYCLING2, 1) ;
	  }
	  else
	  {
	    menu_ienable(adr_menu, M_CYCLING1, 0) ;
	    menu_ienable(adr_menu, M_CYCLING2, 0) ;
	  }
	}
	else
	{
	  menu_ienable(adr_menu, M_SAUVE, 0) ;
	  menu_ienable(adr_menu, M_SAUVES, 0) ;
	  menu_ienable(adr_menu, M_COPIER, 0) ;
	  menu_ienable(adr_menu, M_EXPORT, 0) ;
	  menu_ienable(adr_menu, M_IMPRIMER, 0) ;
	  menu_ienable(adr_menu, M_ZOOMC, 0) ;
	  menu_ienable(adr_menu, M_ZOOMF, 0) ;
	  menu_ienable(adr_menu, M_CALCUL, 0) ;
	  menu_ienable(adr_menu, M_INIT, 0) ;
	  menu_ienable(adr_menu, M_TAILLE, 0) ;
	  menu_ienable(adr_menu, M_CYCLING1, 0) ;
	  menu_ienable(adr_menu, M_CYCLING2, 0) ;
	}
	menu_ienable(adr_menu, M_INFOF, 1) ;
	if (window_handle[num_window] == w_ani_handle)
	{
	  menu_ienable(adr_menu, M_REPORT, 0) ;
	  menu_ienable(adr_menu, M_INFOF, 0) ;
	}
	else
	{
	  if (fractal[num_window].report.t_calc != 0)
		   menu_ienable(adr_menu, M_REPORT, 1) ;
	  else menu_ienable(adr_menu, M_REPORT, 0) ;
	}
  }
  else
  {
	menu_ienable(adr_menu, M_FERME, 0) ;
	menu_ienable(adr_menu, M_SAUVE, 0) ;
	menu_ienable(adr_menu, M_SAUVES, 0) ;
	menu_ienable(adr_menu, M_COPIER, 0) ;
	menu_ienable(adr_menu, M_EXPORT, 0) ;
    menu_ienable(adr_menu, M_IMPRIMER, 0) ;
	menu_ienable(adr_menu, M_ZOOMC, 0) ;
	menu_ienable(adr_menu, M_ZOOMF, 0) ;
	menu_ienable(adr_menu, M_CALCUL, 0) ;
	menu_ienable(adr_menu, M_INIT, 0) ;
	menu_ienable(adr_menu, M_INFOF, 0) ;
	menu_ienable(adr_menu, M_REPORT, 0) ;
	menu_ienable(adr_menu, M_TAILLE, 0) ;
    menu_ienable(adr_menu, M_CYCLING1, 0) ;
    menu_ienable(adr_menu, M_CYCLING2, 0) ;
  }

  if ((num_window != -1) && (window_handle[num_window] != w_ani_handle))
  {
	menu_ienable(adr_menu, M_ANIMD, 1) ;
	menu_ienable(adr_menu, M_ANIMF, 1) ;
  }
  else
  {
	menu_ienable(adr_menu, M_ANIMD, 0) ;
	menu_ienable(adr_menu, M_ANIMF, 0) ;
  }

  if ((stat_anim.debut != -1) && (stat_anim.fin != -1))
	menu_ienable(adr_menu, M_ANIMGO, 1) ;
  else
	menu_ienable(adr_menu, M_ANIMGO, 0) ;

  if (virtuel.fd_addr == NULL)
  {
	menu_ienable(adr_menu, M_ANIM_RESUME, 0) ;
    menu_ienable(adr_menu, M_ANIMATE, 0) ;
  }
  else
  {
	menu_ienable(adr_menu, M_ANIM_RESUME, 1) ;
    menu_ienable(adr_menu, M_ANIMATE, 1) ;
  }
}

void nouveau(void)
{
  int w_num ;
  int x, y, w, h ;

  w_num = num_new_window() ;
  if (w_num == -1)
  {
	form_exclamation(1, msg[MSG_NOWINDOW]) ;
	return ;
  }

  memset(&fractal[w_num].report, 0, sizeof(FRACTAL_REPORT)) ;
  adr_info[INFO_MOINS].ob_flags |= TOUCHEXIT ;
  adr_info[INFO_PLUS].ob_flags  |= TOUCHEXIT ;
  adr_info[INFO_MOINS].ob_state &= ~DISABLED ;
  adr_info[INFO_PLUS].ob_state  &= ~DISABLED ;
  if (infos(&fractal[w_num]) == 1)
  {
	fractal[w_num].img.fd_addr = img_alloc(fractal[w_num].img.fd_w, fractal[w_num].img.fd_h, nb_plane) ;
	if (fractal[w_num].img.fd_addr != NULL)
	{
	  int last_num ;

	  last_num   = num_window ;
	  num_window = w_num ;
	  img_raz(&fractal[w_num].img) ;
	  open_where(W_ALL, fractal[w_num].img.fd_w, fractal[w_num].img.fd_h,
	             &x, &y, &w, &h) ;
      if (AESversion >= 0x0410)
	    window_handle[w_num] = open_fwindow(W_ALL | SMALLER, x, y, w, h) ;
	  else
	    window_handle[w_num] = open_fwindow(W_ALL, x, y, w, h) ;
	  if (window_handle[w_num] >= 0)
	  {
	    int ww, wh ;

		window_opened[w_num] = 1 ;
		strcpy(window_name[w_num], fractal[w_num].nom) ;
		wind_set(window_handle[w_num], WF_NAME, window_name[w_num]) ;
		strcpy(window_info[w_num], "") ;
		wind_set(window_handle[w_num], WF_INFO, window_info[w_num]) ;
		winfo[w_num].x1 = winfo[w_num].y1 = 0 ;
		winfo[w_num].x2 = w-1 ;
		winfo[w_num].y2 = y-1 ;
        ww = (int) (1000.0*(double)w/(double)fractal[w_num].img.fd_w) ;
        wh = (int) (1000.0*(double)h/(double)fractal[w_num].img.fd_h) ;
        wind_set(window_handle[w_num], WF_HSLIDE, 1) ;
        wind_set(window_handle[w_num], WF_VSLIDE, 1) ;
        wind_set(window_handle[w_num], WF_HSLSIZE, ww) ;
        wind_set(window_handle[w_num], WF_VSLSIZE, wh) ;
	  }
	  else
	  {
		form_interrogation(1, msg[MSG_NOMOREWINDOW]) ;
		free(fractal[w_num].img.fd_addr) ;
		fractal[w_num].img.fd_addr    = NULL ;
		fractal[w_num].img.fd_w       = largeur ;
		fractal[w_num].img.fd_h       = hauteur ;
		fractal[w_num].img.fd_wdwidth = largeur/16 ;
		fractal[w_num].img.fd_stand   = 0 ;
		fractal[w_num].img.fd_nplanes = nb_plane ;
		get_tospalette(&fractal_pal[num_window][0]) ;
		window_opened[w_num] = 0 ;
		window_handle[w_num] = -2 ;
		num_window           = last_num ;
	  }
	}
	else
	  form_stop(1, msg[MSG_IMGERRMEM]) ;
  }
}

void duplique(void)
{
  int w_num ;
  int x, y, w, h ;
  int ww, wh ;

  w_num = num_new_window() ;
  if (w_num != -1)
  {
	memcpy(&fractal[w_num], &fractal[num_window], sizeof(FRACTAL)) ;
	strcpy(fractal[w_num].nom, "XXXXXXXXFRC") ;
	if (raster_duplicate(&fractal[num_window].img, &fractal[w_num].img) == 0)
	{
	  int last_num ;

	  last_num   = num_window ;
	  num_window = w_num ;
	  open_where(W_ALL, fractal[w_num].img.fd_w, fractal[w_num].img.fd_h,
	             &x, &y, &w, &h) ;
      if (AESversion >= 0x0410)
	    window_handle[w_num] = open_fwindow(W_ALL | SMALLER, x, y, w, h) ;
	  else
	    window_handle[w_num] = open_fwindow(W_ALL, x, y, w, h) ;
	  if (window_handle[w_num] >= 0)
	  {
		window_opened[w_num] = 1 ;
		strcpy(window_name[w_num], fractal[w_num].nom) ;
		wind_set(window_handle[w_num], WF_NAME, window_name[w_num]) ;
		strcpy(window_info[w_num], "") ;
		wind_set(window_handle[w_num], WF_INFO, window_info[w_num]) ;
		winfo[w_num].x1 = winfo[w_num].y1 = 0 ;
		winfo[w_num].x2 = w-1 ;
		winfo[w_num].y2 = y-1 ;
        ww = (int) (1000.0*(double)w/(double)fractal[w_num].img.fd_w) ;
        wh = (int) (1000.0*(double)h/(double)fractal[w_num].img.fd_h) ;
        wind_set(window_handle[w_num], WF_HSLIDE, 1) ;
        wind_set(window_handle[w_num], WF_VSLIDE, 1) ;
        wind_set(window_handle[w_num], WF_HSLSIZE, ww) ;
        wind_set(window_handle[w_num], WF_VSLSIZE, wh) ;
	  }
	  else
	  {
		form_interrogation(1, msg[MSG_NOMOREWINDOW]) ;
		free(fractal[w_num].img.fd_addr) ;
		fractal[w_num].img.fd_addr    = (int *) NULL ;
		fractal[w_num].img.fd_w       = largeur ;
		fractal[w_num].img.fd_h       = hauteur ;
		fractal[w_num].img.fd_wdwidth = largeur/16 ;
		fractal[w_num].img.fd_stand   = 0 ;
		fractal[w_num].img.fd_nplanes = nb_plane ;
		get_tospalette(&fractal_pal[num_window][0]) ;
		window_opened[w_num] = 0 ;
		window_handle[w_num] = -2 ;
		num_window           = last_num ;
	  }
	}
	else
	{
	  int n_handle ;

	  form_stop(1, msg[MSG_IMGERRMEM]) ;
	  n_handle   = close_window(window_handle[w_num]) ;
	  num_window = num_wind(n_handle) ;
	}
  }
  else form_interrogation(1, msg[MSG_NOMOREWINDOW]) ;
}

void change_taille(void)
{
  OBJECT *adr_form_taille ;
  double max, he ;
  long   ataille, staille ;
  int    x, y, xw, yw ;
  int    w, h, pc ;
  int    ww, wh ;
  int    clicked ;
  void   *pt ;
  char   buf[30] ;
  
  Xrsrc_gaddr(R_TREE, FORM_TAILLE, &adr_form_taille) ;
  form_center(adr_form_taille, &x, &y, &xw, &yw) ;
  max = (double) Xmax*(double) Ymax ;
  w  = fractal[num_window].img.fd_w ;
  h  = fractal[num_window].img.fd_h ;
  pc = (int) (100.0*((double)w*(double)h)/max) ;
  sprintf(buf, "%.4dx%.4d Pixels", w, h) ;
  write_text(adr_form_taille, TAILLE_XYA, buf) ;
  write_text(adr_form_taille, TAILLE_XYS, buf) ;
  ataille = img_size(w, h, nb_plane) >> 10 ;
  sprintf(buf, msg[MSG_TAILLE], ataille) ;
  write_text(adr_form_taille, TAILLE_OCTA, buf) ;
  write_text(adr_form_taille, TAILLE_OCTS, buf) ;
  sprintf(buf, " %.2d%\%", pc) ;
  write_text(adr_form_taille, TAILLE_PCA, buf) ;
  write_text(adr_form_taille, TAILLE_PCS, buf) ;
  staille = ataille ;

  fshow_dialog(adr_form_taille, titre) ;
  do
  {
    clicked = xform_do(-1, window_update) ;
    switch(clicked)
    {
      case TAILLE_MOINS : if (w > 96)
						  {
							w -= 16 ;
						    if ((w % 512) == 0) w -= 16 ; /* Huh ? */
							h  = (int) (((double)w*(double)Ymax)/(double)Xmax) ;
							h  = 3*(h/3) ;
							pc  = (int) (100.0*(double)w*(double)h/max) ;
							sprintf(buf, " %.2d%\%", pc) ;
							write_text(adr_form_taille, TAILLE_PCS, buf) ;
							objc_draw(adr_form_taille, TAILLE_PCS, 0, xdesk, ydesk, wdesk, hdesk) ;
							sprintf(buf, "%.4dx%.4d Pixels", w, h) ;
							write_text(adr_form_taille, TAILLE_XYS, buf) ;
							objc_draw(adr_form_taille, TAILLE_XYS, 0, xdesk, ydesk, wdesk, hdesk) ;
							staille = img_size(w, h, nb_plane) >> 10 ;
							sprintf(buf, msg[MSG_TAILLE], staille) ;
							write_text(adr_form_taille, TAILLE_OCTS, buf) ;
							objc_draw(adr_form_taille, TAILLE_OCTS, 0, xdesk, ydesk, wdesk, hdesk) ;
						  }
						  break ;
	  case TAILLE_PLUS  : he = (double)(w+16)*(double)Ymax/(double)Xmax ;
						  if (he < HMAX)
						  {
							w += 16 ;
						    if ((w % 512) == 0) w += 16 ; /* Huh ? */
							h  = (int) (((double)w*(double)Ymax)/(double)Xmax) ;
							h  = 3*(h/3) ;
							pc  = (int) (100.0*(double)w*(double)h/max) ;
							sprintf(buf, " %.2d%\%", pc) ;
							write_text(adr_form_taille, TAILLE_PCS, buf) ;
							objc_draw(adr_form_taille, TAILLE_PCS, 0, xdesk, ydesk, wdesk, hdesk) ;
							sprintf(buf, "%.2dx%.4d Pixels", w, h) ;
							write_text(adr_form_taille, TAILLE_XYS, buf) ;
							objc_draw(adr_form_taille, TAILLE_XYS, 0, xdesk, ydesk, wdesk, hdesk) ;
							staille = img_size(w, h, nb_plane) >> 10 ;
							sprintf(buf, msg[MSG_TAILLE], staille) ;
							write_text(adr_form_taille, TAILLE_OCTS, buf) ;
							objc_draw(adr_form_taille, TAILLE_OCTS, 0, xdesk, ydesk, wdesk, hdesk) ;
						  }
						  break ;
	}
  }
  while ((clicked != TAILLE_OK) && (clicked != TAILLE_CANCEL) && (clicked != -1)) ;
  
  deselect(adr_form_taille, clicked) ;
  fhide_dialog() ;
  if ((clicked == TAILLE_CANCEL) || (clicked == -1)) return ;
  
  pt = img_alloc(w, h, nb_plane) ;
  if (pt == NULL)
  {
    form_error(8) ;
    return ;
  }

  free(fractal[num_window].img.fd_addr) ;
  fractal[num_window].img.fd_addr    = pt ;
  fractal[num_window].img.fd_w       = w ;
  fractal[num_window].img.fd_h       = h ;
  fractal[num_window].img.fd_wdwidth = w/16 ;

  img_raz(&fractal[num_window].img) ;
  close_window(window_handle[num_window]) ;
  open_where(W_ALL, fractal[num_window].img.fd_w, fractal[num_window].img.fd_h,
             &x, &y, &w, &h) ;
  if (AESversion >= 0x0410)
    window_handle[num_window] = open_fwindow(W_ALL | SMALLER, x, y, w, h) ;
  else
    window_handle[num_window] = open_fwindow(W_ALL, x, y, w, h) ;
  strcpy(window_name[num_window], fractal[num_window].nom) ;
  window_opened[num_window] = 1 ;
  winfo[num_window].x1 = winfo[num_window].y1 = 0 ;
  winfo[num_window].x2 = w-1 ;
  winfo[num_window].y2 = y-1 ;
  ww = (int) (1000.0*(double)w/(double)fractal[num_window].img.fd_w) ;
  wh = (int) (1000.0*(double)h/(double)fractal[num_window].img.fd_h) ;
  wind_set(window_handle[num_window], WF_HSLIDE, 1) ;
  wind_set(window_handle[num_window], WF_VSLIDE, 1) ;
  wind_set(window_handle[num_window], WF_HSLSIZE, ww) ;
  wind_set(window_handle[num_window], WF_VSLSIZE, wh) ;
  ev_num          = num_window ;
  event.ev_mflags = MU_KEYBD|MU_MESAG|MU_TIMER|MU_BUTTON ;
}

void preferences(void)
{
  OBJECT *adr_pref ;
  int    clicked ;
  int    w, h ;
  char   buffer[200] ;
  char   nom[200] ;

  Xrsrc_gaddr(R_TREE, FORM_PREF, &adr_pref) ;
  select(adr_pref, PREF_ENTIER) ;
  deselect(adr_pref, PREF_REEL) ;
  if (!fpu_type) adr_pref[PREF_REEL].ob_state |= DISABLED ;
  else
  {
	adr_pref[PREF_REEL].ob_state &= ~DISABLED ;
	if (config.calc_format == REEL)
	{
	  deselect(adr_pref, PREF_ENTIER) ;
	  select(adr_pref, PREF_REEL) ;
	}
  }

  if (config.dsp_on) select(adr_pref, PREF_DSP) ;
  else               deselect(adr_pref, PREF_DSP) ;
  if (config.lzw_frc) select(adr_pref, PREF_LZWSAVE) ;
  else                deselect(adr_pref, PREF_LZWSAVE) ;

  write_text(adr_pref, PREF_FRACTALS, config.path_fractal) ;
  write_text(adr_pref, PREF_ANI, config.path_ani) ;

  if (nb_colors == 2)
  {
    if (config.set_only) select(adr_pref, PREF_SET) ;
    else                 deselect(adr_pref, PREF_SET) ;
    adr_pref[PREF_SET].ob_state   &= ~DISABLED ;
    adr_pref[PREF_TSET1].ob_state &= ~DISABLED ;
    adr_pref[PREF_TSET2].ob_state &= ~DISABLED ;
  }
  else
  {
    deselect(adr_pref, PREF_SET) ;
    adr_pref[PREF_SET].ob_state   |= DISABLED ;
    adr_pref[PREF_TSET1].ob_state |= DISABLED ;
    adr_pref[PREF_TSET2].ob_state |= DISABLED ;
  }

  if (UseStdVDI) select(adr_pref, PREF_USESTDVDI) ;
  else           deselect(adr_pref, PREF_USESTDVDI) ;

  sprintf(buffer, "%d", config.tr_width) ;
  write_text(adr_pref, PREF_RTX, buffer) ;
  sprintf(buffer, "%d", config.tr_height) ;
  write_text(adr_pref, PREF_RTY, buffer) ;
  sprintf(buffer, "%d", config.tr_maxiter) ;
  write_text(adr_pref, PREF_RTMAXITER, buffer) ;

  fshow_dialog(adr_pref, titre) ;
  do
  {
    clicked = xform_do(PREF_RTMAXITER, window_update) ;
    if (clicked == -1) break ;
    switch(clicked)
    {
      case PREF_FRACTALS :
      case PREF_ANI      : fhide_dialog() ;
                           if (clicked == PREF_FRACTALS) read_text(adr_pref, PREF_FRACTALS, buffer) ;
                           else                          read_text(adr_pref, PREF_ANI, buffer) ;
                           buffer[strlen(buffer)] = 0 ;
                           redraws() ;

                           if (file_name(buffer, "", nom) == 1)
                           {
                             char *last_slash ;

                             last_slash = strrchr(nom, '\\') ;
                             if (last_slash != NULL)
                             {
                               *(1+last_slash) = 0 ;
                               if (clicked == PREF_FRACTALS) write_text(adr_pref, PREF_FRACTALS, nom) ;
                               else                          write_text(adr_pref, PREF_ANI, nom) ;
                             }
                           }

                           redraws() ;
                           if (clicked == PREF_FRACTALS) deselect(adr_pref, PREF_FRACTALS) ;
                           else                          deselect(adr_pref, PREF_ANI) ;
                           fshow_dialog(adr_pref, titre) ;
                           break ;
      case PREF_RTPLUS   :
      case PREF_RTMOINS  : read_text(adr_pref, PREF_RTX, buffer) ;
                           w = atoi(buffer) ;
                           if (clicked == PREF_RTPLUS)
                           {
                             if (w < 256) w += 16 ;
                           }
                           else if (w > 80) w -= 16 ;
                           h = (int) ((double)w*(double)Ymax/(double)Xmax) ;
                           h = (h/3)*3 ;
                           sprintf(buffer, "%d", w) ;
                           write_text(adr_pref, PREF_RTX, buffer) ;
                           sprintf(buffer, "%d", h) ;
                           write_text(adr_pref, PREF_RTY, buffer) ;
                           objc_draw(adr_pref, PREF_RTX, 0, xdesk, ydesk, wdesk, hdesk) ;
                           objc_draw(adr_pref, PREF_RTY, 0, xdesk, ydesk, wdesk, hdesk) ;
                           inv_select(adr_pref, clicked) ;
                           break ;
    }
  }
  while ((clicked != PREF_CANCEL) && (clicked != PREF_SAUVE) && (clicked != PREF_OK)) ;
  deselect(adr_pref, clicked) ;
  fhide_dialog() ;

  if ((clicked == PREF_CANCEL) || (clicked == -1)) return ;

  if (selected(adr_pref, PREF_ENTIER)) config.calc_format = ENTIER ;
  else                                 config.calc_format = REEL ;
  config.dsp_on   = selected(adr_pref, PREF_DSP) ;
  config.set_only = selected(adr_pref, PREF_SET) ;
  config.lzw_frc  = selected(adr_pref, PREF_LZWSAVE) ;

  read_text(adr_pref, PREF_RTX, buffer) ;
  config.tr_width = atoi(buffer) ;
  read_text(adr_pref, PREF_RTY, buffer) ;
  config.tr_height = atoi(buffer) ;
  read_text(adr_pref, PREF_RTMAXITER, buffer) ;
  config.tr_maxiter = atoi(buffer) ;

  UseStdVDI = selected(adr_pref, PREF_USESTDVDI) ; 

  read_text(adr_pref, PREF_FRACTALS, config.path_fractal) ;
  read_text(adr_pref, PREF_ANI, config.path_ani) ;
  strcpy(mask_fractal, config.path_fractal) ;
  strcat(mask_fractal, "*.FRC") ;
  strcpy(mask_ani, config.path_ani) ;
  strcat(mask_ani, "*.FAN") ;

  init_real_time() ;
  if (clicked == PREF_SAUVE) sauve_config() ;
}

void udt_scr(void)
{
  EVENT saved ;
  int   which ;

  if (!flag_show) return ;
  if (dsp_line > nbpt_y) return ;

  memcpy(&saved, &event, sizeof(EVENT)) ;
  event.ev_mflags    = MU_MESAG | MU_TIMER ;
  event.ev_mtlocount = 20 ;
  do
  {
	which = EvntMulti(&event) ;
	if (which & MU_MESAG) window_update(event.ev_mmgpbuf) ;
  }
  while (which & MU_MESAG) ;
  
  memcpy(&event, &saved, sizeof(EVENT)) ;
}

void redraws(void)
{
  EVENT evnt ;
  int   which ;

  evnt.ev_mflags    = MU_MESAG | MU_TIMER;
  evnt.ev_mtlocount = 200 ;
  evnt.ev_mthicount = 0 ;
  do
  {
    which = EvntMulti(&evnt) ;
    if ((which == MU_MESAG) && (evnt.ev_mmgpbuf[0] == WM_REDRAW))
      traite_gem(evnt.ev_mmgpbuf) ;
  }
  while (which != MU_TIMER) ;
}

void traite_imprime(void)
{
  INFO_IMAGE info ;

  if (num_window == -1) return ;

  info.nb_cpal = nb_colors ;
  info.palette = &fractal_pal[num_window][0] ;
  info.lpix    = info.hpix = 0x152 ;
  info.largeur = fractal[num_window].img.fd_w ;
  info.hauteur = fractal[num_window].img.fd_h ;
  info.nplans  = fractal[num_window].img.fd_nplanes ;

  status_menu(0) ;
  switch(print_image(&fractal[num_window].img, &info))
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
  }
  status_menu(1) ;
  ajour_menu() ;
}

void iconify_picture(int wnum)
{
  MFDB temp ;
  int  xy[8] ;
  int  w, h, dummy ;
  int  pcx, pcy, nw ;

  wind_get(window_handle[wnum], WF_WORKXYWH, &dummy, &dummy, &w, &h) ;
  memset(&window_icon[wnum], 0, sizeof(MFDB)) ;
  window_icon[wnum].fd_addr = img_alloc(w, h, nb_plane) ;
  if (window_icon[wnum].fd_addr == NULL) return ;
  window_icon[wnum].fd_w = w ;
  window_icon[wnum].fd_h = h ;
  window_icon[wnum].fd_wdwidth = w/16 ;
  if (w % 16) window_icon[wnum].fd_wdwidth++ ;
  window_icon[wnum].fd_nplanes = nb_plane ;

  img_raz(&window_icon[wnum]) ;
  pcx = (int) (100.0*(float)w/(float)fractal[wnum].img.fd_w) ;
  pcy = (int) (100.0*(float)h/(float)fractal[wnum].img.fd_h) ;
  if (pcx > pcy) pcx = pcy ;
  else           pcy = pcx ;
  /* R‚duit la taille de l'image … une icone */
  raster_pczoom(&fractal[wnum].img, &temp, pcx, pcy, nullprog_pc) ;
  if (temp.fd_addr == NULL)
  {
    free(window_icon[wnum].fd_addr) ;
    memset(&window_icon[wnum], 0, sizeof(MFDB)) ;
    return ;
  }

  nw = (int) ((float)fractal[wnum].img.fd_w*(float)pcx/100.0) ;
  if (nw > w) nw = w ;
  xy[0] = xy[1] = 0 ;
  xy[2] = nw-1 ;
  xy[3] = temp.fd_h-1 ;
  xy[4] = (w-nw) >> 1 ;
  xy[5] = (h-temp.fd_h) >> 1 ;
  xy[6] = xy[4]+nw-1 ;
  xy[7] = xy[5]+temp.fd_h-1 ;
  vro_cpyfm(handle, S_ONLY, xy, &temp, &window_icon[wnum]) ;
  free(temp.fd_addr) ;
}

void traite_cycling (int sens)
{
  long evnt_clavier ;
  int  xyarray[8] ;
  int  largeur, hauteur ;
  int  posx, posy ;
  int  ev_kreturn ;
  int  unit ;
  int  nb_wait, cpt = 4 ;
  int clic_souris, dummy ;
  char xscroll, yscroll ;
  char fin = 0 ;
  
  if (num_window == -1) return ;

  vsf_color(handle, 1) ;
  cls_gemscreen() ;
  wind_update(BEG_UPDATE) ;
  v_hide_c(handle) ;
  
  while (kbhit()) getch() ;
  largeur = fractal[num_window].img.fd_w ;
  hauteur = fractal[num_window].img.fd_h ;
  posx    = (1+Xmax-largeur)/2 ;
  if (posx < 0) posx = 0 ;
  posy = (1+Ymax-hauteur)/2 ;
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
  vro_cpyfm(handle, S_ONLY, xyarray, &fractal[num_window].img, &screen) ;
  cycling_init() ;

  do
  {
   for (nb_wait = 0; nb_wait < cpt; nb_wait++) Vsync() ;
    cycling_do(sens) ;
    evnt_clavier = kbhit() ;
    if (evnt_clavier)
      ev_kreturn = (int) (Bconin(2) >> 8) ;
    graf_mkstate(&dummy, &dummy, &clic_souris, &dummy) ;
	if (clic_souris) fin = 1 ;
	else
	if (evnt_clavier)
	{
	  if (Kbshift(-1) & 0x00000003) unit = 32 ;
	  else                          unit = 4 ;
	  switch(ev_kreturn)
	  {
	    case CURSOR_UP : if (yscroll)
	                     {
	                       xyarray[1] -= unit ;
	                       xyarray[3] -= unit ;
	                       if (xyarray[1] < 0)
	                       {
	                         xyarray[1] = 0 ;
	                         xyarray[3] = Ymax ;
	                       }
                           vro_cpyfm(handle, S_ONLY, xyarray, &fractal[num_window].img, &screen) ;
                         }
	                     break ;
	    case CURSOR_DN : if (yscroll)
	                     {
	                       xyarray[1] += unit ;
	                       xyarray[3] += unit ;
	                       if (xyarray[3] > hauteur-1)
	                       {
	                         xyarray[3] = hauteur-1 ;
	                         xyarray[1] = hauteur-Ymax-1 ;
	                       }
                           vro_cpyfm(handle, S_ONLY, xyarray, &fractal[num_window].img, &screen) ;
                         }
	                     break ;
	    case CURSOR_LT : if (xscroll)
	                     {
	                       xyarray[0] -= unit ;
	                       xyarray[2] -= unit ;
	                       if (xyarray[0] < 0)
	                       {
	                         xyarray[0] = 0 ;
	                         xyarray[2] = Xmax ;
	                       }
                           vro_cpyfm(handle, S_ONLY, xyarray, &fractal[num_window].img, &screen) ;
                         }
	                     break ;
	    case CURSOR_RT : if (xscroll)
	                     {
	                       xyarray[0] += unit ;
	                       xyarray[2] += unit ;
	                       if (xyarray[2] > largeur-1)
	                       {
	                         xyarray[2] = largeur-1 ;
	                         xyarray[0] = largeur-Xmax-1 ;
	                       }
                           vro_cpyfm(handle, S_ONLY, xyarray, &fractal[num_window].img, &screen) ;
                         }
	                     break ;
	    case PNMOINS   : cpt++ ;
	                     if (cpt > 200) cpt = 200 ;
	                     break ;
	    case PNPLUS    : cpt-- ;
	                     if (cpt < 1) cpt = 1 ;
	                     break ;
	    default        : fin = 1 ;
	                     break ;
	  }
	}
  }
  while (!fin) ;

  cycling_terminate() ;
  restore_gemscreen(adr_menu) ;
  v_show_c(handle, 1) ;
  wind_update(END_UPDATE) ;
}

