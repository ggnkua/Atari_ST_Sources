/*************************************************************/
/*----------------------- CLGSTEVN.C ------------------------*/
/* Module des appels des fonctions de gestion des ‚vŠnements */
/*************************************************************/
#include    <stdio.h>
#include   <string.h>
#include   <stdlib.h>

#include "..\tools\xgem.h"

#include     "defs.h"
#include    "anime.h"
#include   "calcul.h"
#include   "gstevn.h"
#include  "touches.h"
#include  "fractal.h"
#include "fract_io.h"


extern char fini ;   /* Indicateur de fin d'application de MAIN.C */
extern char ev_num ; /* Num‚ro du fractal … re-‚valuer de MAIN.C  */


void open_where(int wkind, int w, int h, int *xout, int *yout, int *wout, int *hout)
{
  int xo, yo, wo, ho ;
  int dummy ;

  wind_calc(WC_WORK, wkind, xdesk, ydesk, 16, 16, &xo, &yo, &dummy, &dummy) ;
  wind_calc(WC_BORDER, wkind, xo, yo, w, h, &dummy, &dummy, &wo, &ho) ;
  if (xdesk+wo > Xmax) w = w-(xdesk+wo-Xmax) ;
  if (ydesk+ho > Ymax) h = h-(ydesk+ho-Ymax) ;
  *xout = xo ; *yout = yo ;
  *wout = w ;  *hout = h ;
}

void update_view(int num)
{
  int wh ;
  int rc, rl ;
  int xi, yi, wx, wy ;

  if (num == -1) return ;

  wh = window_handle[num] ;
  wind_get(wh, WF_WORKXYWH, &xi, &yi, &wx, &wy) ;
  wind_get(wh, WF_HSLIDE, &xi) ;
  wind_get(wh, WF_VSLIDE, &yi) ;
  if (wh != w_ani_handle)
  {
    rc = (int) (0.5+(double)xi/1000.0*(double)(fractal[num].img.fd_w-wx)) ;
    rl = (int) (0.5+(double)yi/1000.0*(double)(fractal[num].img.fd_h-wy)) ;
  }
  else
  {
    rc = (int) (0.5+(double)xi/1000.0*(double)(virtuel.fd_w-wx)) ;
    rl = (int) (0.5+(double)yi/1000.0*(double)(virtuel.fd_h-wy)) ;
  }
  winfo[num].x1 = rc ;      winfo[num].y1 = rl ;
  winfo[num].x2 = rc+wx-1 ; winfo[num].y2 = rl+wy-1 ;
}

void set_imgpalette(int num)
{
  if (num_window == -1) return ;
  
  if (window_handle[num] != w_ani_handle)
    set_tospalette(fractal_pal[num], nb_colors) ;
}

void info_animation(void)
{
  OBJECT *adr_info_ani ;
  double oratio ;
  double hd, md, sd, r ;
  double htod, mtod, stod ;
  long   dsec ;
  int    h, m, s ;
  int    clicked ;
  char   buf[100] ;
							
  Xrsrc_gaddr(R_TREE, FORM_IANIM, &adr_info_ani) ;

  htod = 60.0*60.0*10.0 ;
  mtod = 60.0*10.0 ;
  stod = 10.0 ;
  dsec = 10*info_sequence.nb_csec ;
  hd   = (double)dsec/htod ;
  h    = (int) hd ;
  r    = (double)dsec-h*htod ;
  md   = r/mtod ;
  m    = (int) md ;
  r    = r-m*mtod ;
  sd   = r/stod ;
  s    = (int) sd ;
  memset(buf, 0, 50) ;
  sprintf(buf, "%.3d h %.2d mn %.2d s", h, m, s) ;
  write_text(adr_info_ani, IANIM_TCALC, buf) ;

  htod = 60.0*60.0*10.0 ;
  mtod = 60.0*10.0 ;
  stod = 10.0 ;
  dsec = 10*info_sequence.nb_isec ;
  hd   = (double)dsec/htod ;
  h    = (int) hd ;
  r    = (double)dsec-h*htod ;
  md   = r/mtod ;
  m    = (int) md ;
  r    = r-m*mtod ;
  sd   = r/stod ;
  s    = (int) sd ;
  memset(buf, 0, 50) ;
  sprintf(buf, "%.3d h %.2d mn %.2d s", h, m, s) ;
  write_text(adr_info_ani, IANIM_TCONV, buf) ;

  write_text(adr_info_ani, IANIM_DDATE, info_sequence.date_start) ;
  write_text(adr_info_ani, IANIM_FDATE, info_sequence.date_end) ;
  write_text(adr_info_ani, IANIM_DTIME, info_sequence.time_start) ;
  write_text(adr_info_ani, IANIM_FTIME, info_sequence.time_end) ;
  
  sprintf(buf, "%.4d", info_sequence.nb_image) ;
  write_text(adr_info_ani, IANIM_NBIMG, buf) ;
  
  if (*info_sequence.pack == 0) write_text(adr_info_ani, IANIM_TYPE, msg[MSG_NOCMP]) ;
  else                          write_text(adr_info_ani, IANIM_TYPE, msg[MSG_CMPDELTA]) ;
  
  oratio = (double) (adr_info_ani[IANIM_CPU].ob_width-2)*info_sequence.pc_ccpu/100.0 ;
  adr_info_ani[IANIM_PCCPU].ob_width = (int) oratio ;
  oratio = (double) (adr_info_ani[IANIM_FPU].ob_width-2)*info_sequence.pc_cfpu/100.0 ;
  adr_info_ani[IANIM_PCFPU].ob_width = (int) oratio ;
  oratio = (double) (adr_info_ani[IANIM_DSP].ob_width-2)*info_sequence.pc_cdsp/100.0 ;
  adr_info_ani[IANIM_PCDSP].ob_width = (int) oratio ;

  fshow_dialog(adr_info_ani, titre) ;
  clicked = xform_do(-1, window_update) ;
  fhide_dialog() ;
  deselect(adr_info_ani, clicked) ;
}

void traite_clavier(int key)
{
  int  w_num ;
  char name[100] ;

  switch(key)
  {
	case NOUVEAU  : if (num_new_window() != -1) nouveau() ;
					else
					form_exclamation(1, msg[MSG_NOMOREWINDOW]) ;
					break ;
	case OUVRIR   : w_num = num_new_window() ;
					if (w_num != -1)
					{
					  if (file_name(mask_fractal, "", name))
					  {
						if (charge_fractal(name) == 1)
						  form_error(8) ; /* M‚moire insuffisante ... */
					  }
					}
					else
					form_interrogation(1, msg[MSG_NOMOREWINDOW]) ;
					break ;
	case FERMER   : if (num_window != -1)
					{
					  int new_handle ;

					  if (window_handle[num_window] == w_ani_handle)
					  {
					    libere_sequence() ;
					    free(virtuel.fd_addr) ;
					    virtuel.fd_addr = NULL ;
					    w_ani_handle = -2 ;
					  }
					  else
					  {
						if (fractal[num_window].img.fd_addr != NULL)
						  free(fractal[num_window].img.fd_addr) ;
						memcpy(&fractal[num_window], &f_default, sizeof(FRACTAL)) ;
					  }
					  new_handle = close_window(window_handle[num_window]) ;
					  num_window = num_wind(new_handle) ;
					  set_imgpalette(num_window) ;
					}
					else form_exclamation(1, msg[MSG_NOWINDOW]) ;
					break ;
	case COPIER   : traite_copie(num_window) ;
	                break ;
	case EXPORT   : if ((num_window != -1) && (window_handle[num_window] != w_ani_handle))
					  sauve_image() ;
					break ;
    case IMPRIMER : traite_imprime() ;
                    break ;
	case SAUVE    : if ((num_window != -1) && (window_handle[num_window] != w_ani_handle))
					{
					  int  len ;
					  char name[150] ;
					  char ext[5] ;

					  strcpy(name, config.path_fractal) ;
					  strcat(name, fractal[num_window].nom) ;
					  len = (int) strlen(name) ;
					  strcpy(ext, &name[len-3]) ;
					  name[len-3] = '.' ;
					  memcpy(&name[len-2], ext, 4) ;
					  sauve_fractal(name, 0) ;
					}
					break ;
	case SAUVES   : if ((num_window != -1) && (window_handle[num_window] != w_ani_handle))
					{
					  if (window_handle[num_window] != w_ani_handle)
					  {
						if (file_name(mask_fractal, "", name))
						{
						  int  r ;
						  char *c ;

						  r = form_interrogation(2, msg[MSG_IMGSAVE]) ;
						  sauve_sfractal(name, r) ;
						  c = strrchr(name, '\\') ;
						  if (c == NULL) c = strrchr(name, ':') ;
						  if (c != NULL)
						  {
						    char *pt ;
						    
						    c++ ;
						    strcpy(fractal[num_window].nom, "___________") ;
						    pt = fractal[num_window].nom ;
						    while ((*c != 0) && (*c != '.'))
						    {
						      *pt = *c ;
						      pt++ ;
						      c++ ;
						    }
						    	  
						    if (*c == '.')
						    {
						      c++ ;
						      strcpy(&fractal[num_window].nom[8], c) ;
						    }
						  }
						}
					  }
					}
					break ;
	case QUITTER  : fini = 1 ;
					break ;
	case ZOOMC    : if (num_window != -1)
	                {
					  if (window_handle[num_window] != w_ani_handle) zoom_centre() ;
					}
					else form_exclamation(1, msg[MSG_NOWINDOW]) ;
					break ;
	case ZOOMF    : if (num_window != -1)
					{
					  if (window_handle[num_window] != w_ani_handle) zoom_zone() ;
					}
					else form_exclamation(1, msg[MSG_NOWINDOW]) ;
					break ;
	case LINIT    : charge_mandel(1) ;
	                break ;
	case INIT     : if (num_window != -1)
					{
					  if (window_handle[num_window] != w_ani_handle) init_fractal(&fractal[num_window]) ;
					}
					else form_exclamation(1, msg[MSG_NOWINDOW]) ;
					break ;
	case INFOF    : if (num_window != -1)
					{
					  if (window_handle[num_window] != w_ani_handle)
					  {
						FRACTAL last ;

						memcpy(&last, &fractal[num_window], sizeof(FRACTAL)) ;
						adr_info[INFO_MOINS].ob_flags &= ~TOUCHEXIT ;
						adr_info[INFO_PLUS].ob_flags  &= ~TOUCHEXIT ;
						adr_info[INFO_MOINS].ob_state |= DISABLED ;
						adr_info[INFO_PLUS].ob_state  |= DISABLED ;
						infos(&fractal[num_window]) ;
						strcpy(window_name[num_window], fractal[num_window].nom) ;
						wind_set(window_handle[num_window], WF_NAME, window_name[num_window]) ;
						strcpy(window_info[num_window], "") ;
						wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
						if (!same_aspect(&last, &fractal[num_window]))
						{
						  ev_num          = num_window ;
						  event.ev_mflags = MU_KEYBD|MU_MESAG|MU_TIMER ;
					    }
					  }
					}
					else form_exclamation(1, msg[MSG_NOWINDOW]) ;
					break ;
	case REPORT   : if (num_window != -1)
					{
					  if (window_handle[num_window] != w_ani_handle)
					  {
					    if (fractal[num_window].report.t_calc != 0)
						  report(&fractal[num_window]) ;
					    else form_exclamation(1, msg[MSG_CALCNOTDONE]) ;
					  }
					}
					else form_exclamation(1, msg[MSG_NOWINDOW]) ;
					break ;
	case CALCULER : if (num_window != -1)
 	                  if (window_handle[num_window] != w_ani_handle) lance_calcul(num_window) ;
					break ;
	case PREFS    : preferences() ;
					break ;
	case DUPLIQUE : if (num_window != -1)
					{
					  if (window_handle[num_window] != w_ani_handle) duplique() ;
					}
					else form_exclamation(1, msg[MSG_NOWINDOW]) ;
					break ;
	case TAILLE   : if (num_window != -1)
					{
					  if (window_handle[num_window] != w_ani_handle) change_taille() ;
					}
					else form_exclamation(1, msg[MSG_NOWINDOW]) ;
					break ;
	case PALETTE  : traite_palette() ;
	                break ;
  }
  
  graf_mouse(ARROW, 0L) ;
}

void traite_menu(int *mesg)
{
  int  w_num ;
  int  bouton ;
  char name[100] ;

  switch(mesg[4])
  {
	case M_INFO         : {
							OBJECT *adr_baratin ;

							Xrsrc_gaddr(R_TREE, FORM_BARATIN, &adr_baratin) ;
							fshow_dialog(adr_baratin, titre) ;
							bouton = xform_do(-1, window_update) ;
							deselect(adr_baratin, bouton) ;
							fhide_dialog() ;
						  }
						  break ;
	case M_NOUVEAU      : nouveau() ;
						  break ;
	case M_CHARGE       : w_num = num_new_window() ;
						  if (w_num != -1)
						  {
							if (file_name(mask_fractal, "", name))
						 	  if (charge_fractal(name) == 1) form_error(8) ;
						  }
						  else
							form_interrogation(1, msg[MSG_NOMOREWINDOW]) ;
						  break ;
	case M_FERME        : {
					 		int new_handle ;

							if (window_handle[num_window] == w_ani_handle)
							{
					    	  libere_sequence() ;
					    	  free(virtuel.fd_addr) ;
					    	  virtuel.fd_addr = NULL ;
					    	  w_ani_handle = -2 ;
					  		}
							else
							{
							  if (fractal[num_window].img.fd_addr != NULL)
								free(fractal[num_window].img.fd_addr) ;
							  memcpy(&fractal[num_window], &f_default, sizeof(FRACTAL)) ;
							}
							new_handle = close_window(window_handle[num_window]) ;
							num_window = num_wind(new_handle) ;
					        set_imgpalette(num_window) ;
						  }
					  	  break ;
	case M_COPIER       : traite_copie(num_window) ;
	                      break ;
	case M_EXPORT       : sauve_image() ;
                          break ;
	case M_SAUVE        : if (num_window != -1)
						  {
					  		int  len ;
					  		char name[150] ;
					  		char ext[5] ;

					  		strcpy(name, config.path_fractal) ;
					  		strcat(name, fractal[num_window].nom) ;
					  		len = (int) strlen(name) ;
					  		strcpy(ext, &name[len-3]) ;
					  		name[len-3] = '.' ;
					  		memcpy(&name[len-2], ext, 4) ;
					  		sauve_fractal(name, 0) ;
					  	  }
						  else
						    form_exclamation(1, msg[MSG_NOWINDOW]) ;
						  break ;
	case M_SAUVES       : if (num_window != -1)
						  {
                            if (window_handle[num_window] != w_ani_handle)
							  if (file_name(mask_fractal, "", name))
							  {
						  		int  r ;
						  		char *c ;

						  		r = form_interrogation(2, msg[MSG_IMGSAVE]) ;
						  		sauve_sfractal(name, r) ;
						  		c = strrchr(name, '\\') ;
						  		if (c == NULL) c = strrchr(name, ':') ;
						  		if (c != NULL)
						  		{
						    	  char *pt ;
						    
						    	  c++ ;
						    	  strcpy(fractal[num_window].nom, "___________") ;
						    	  pt = fractal[num_window].nom ;
						    	  while ((*c != 0) && (*c != '.'))
						    	  {
						    	    *pt = *c ;
						    	    pt++ ;
						    	    c++ ;
						    	  }
						    	  
						    	  if (*c == '.')
						    	  {
						    	    c++ ;
						    	    strcpy(&fractal[num_window].nom[8], c) ;
						    	  }
							    }
							  }
						  }
						  else form_exclamation(1, msg[MSG_NOWINDOW]) ;
						  break ;
    case M_IMPRIMER     : traite_imprime() ;
                          break ;
	case M_QUITTE       : fini = 1 ;
						  break ;
	case M_ZOOMC        : if (num_window != -1)
                          {
                            if (window_handle[num_window] != w_ani_handle) zoom_centre() ;
                          }
						  else form_exclamation(1, msg[MSG_NOWINDOW]) ;
						  break ;
	case M_ZOOMF        : if (num_window != -1)
                          {
                            if (window_handle[num_window] != w_ani_handle) zoom_zone() ;
						  }
						  else form_exclamation(1, msg[MSG_NOWINDOW]) ;
						  break ;
	case M_LOADINIT     : charge_mandel(1) ;
	                      break ;
	case M_INIT         : if (num_window != -1)
                          {
                            if (window_handle[num_window] != w_ani_handle) init_fractal(&fractal[num_window]) ;
						  }
						  else form_exclamation(1, msg[MSG_NOWINDOW]) ;
						  break ;
	case M_INFOF        : if (num_window != -1)
						  {
                            if (window_handle[num_window] != w_ani_handle)
							{
							  FRACTAL last ;

							  memcpy(&last, &fractal[num_window], sizeof(FRACTAL)) ;
						  	  adr_info[INFO_MOINS].ob_flags &= ~TOUCHEXIT ;
						  	  adr_info[INFO_PLUS].ob_flags  &= ~TOUCHEXIT ;
							  adr_info[INFO_MOINS].ob_state |= DISABLED ;
							  adr_info[INFO_PLUS].ob_state  |= DISABLED ;
							  infos(&fractal[num_window]) ;
							  strcpy(window_name[num_window], fractal[num_window].nom) ;
							  wind_set(window_handle[num_window], WF_NAME, window_name[num_window]) ;
							  strcpy(window_info[num_window], "") ;
							  wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
							  if (!same_aspect(&last, &fractal[num_window]))
							  {
								ev_num          = num_window ;
								event.ev_mflags = MU_KEYBD|MU_MESAG|MU_TIMER ;
					    	  }
							}
						  }
						  else form_exclamation(1, msg[MSG_NOWINDOW]) ;
						  break ;
	case M_REPORT       : if (window_handle[num_window] != w_ani_handle) 
							report(&fractal[num_window]) ;
						  break ;
	case M_CALCUL       : if (window_handle[num_window] != w_ani_handle) lance_calcul(num_window) ;
						  break ;
	case M_DUPLIQUE     : if (num_window != -1)
                          {
                            if (window_handle[num_window] != w_ani_handle) duplique() ;
                          }
						  else form_exclamation(1, msg[MSG_NOWINDOW]) ;
						  break ;
	case M_TAILLE       : if (num_window != -1)
						  {
							if (window_handle[num_window] != w_ani_handle) change_taille() ;
						  }
						  else form_exclamation(1, msg[MSG_NOWINDOW]) ;
						  break ;
	case M_PREFS        : preferences() ;
						  break ;
	case M_PALETTE      : traite_palette() ;
	                      break ;
	case M_FICHIERS     : {
							OBJECT *adr_aide_fic ;

							Xrsrc_gaddr(R_TREE, AIDE_FICHIERS, &adr_aide_fic) ;
							fshow_dialog(adr_aide_fic, titre) ;
							bouton = xform_do(-1, window_update) ;
							deselect(adr_aide_fic, bouton) ;
							fhide_dialog() ;
						  }
						  break ;
	case M_OPTIONS      : {
							OBJECT *adr_aide_opt ;

							Xrsrc_gaddr(R_TREE, AIDE_OPTIONS, &adr_aide_opt) ;
							fshow_dialog(adr_aide_opt, titre) ;
							bouton = xform_do(-1, window_update) ;
							deselect(adr_aide_opt, bouton) ;
							fhide_dialog() ;
						  }
						  break ;
	case M_ANIMATION    : {
							OBJECT *adr_aide_ani ;

							Xrsrc_gaddr(R_TREE, AIDE_ANIMATION, &adr_aide_ani) ;
							fshow_dialog(adr_aide_ani, titre) ;
							bouton = xform_do(-1, window_update) ;
							deselect(adr_aide_ani, bouton) ;
							fhide_dialog() ;
						  }
						  break ;
	case M_ANIMD        : stat_anim.debut = num_window ;
						  menu_icheck(adr_menu, M_ANIMD, 1) ;
						  break ;
	case M_ANIMF        : stat_anim.fin = num_window ;
						  menu_icheck(adr_menu, M_ANIMF, 1) ;
						  break ;
	case M_ANIM_RESUME  : info_animation() ;	
						  break ;
	case M_ANIMGO       : if (create_animation(&ani_calc) == 1)
                            if (ok_animate_parameters(&fractal[stat_anim.debut], &fractal[stat_anim.fin]))
							{
                              num_window = stat_anim.fin ;
						      wind_set(window_handle[num_window], WF_TOP) ;
						      strcpy(window_name[num_window], fractal[num_window].nom) ;
						      wind_set(window_handle[num_window], WF_NAME, window_name[num_window]) ;
						      strcpy(window_info[num_window], "") ;
						      wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;

                              calcule_animation() ;
                            }
						  break ;
	case M_ANIM_CHARGE  : if (file_name(mask_ani, "", name))
                          {
                            int result ;
							char buf[100] ;

						    result = charge_animation(name) ;
							switch(result)
                            {
                              case -1 : form_exclamation(1, msg[MSG_NOMOREWINDOW]) ;
										break ;
                              case  1 : form_interrogation(1, msg[MSG_FILENOTEXIST]) ;
                                        break ;
							  case  2 : sprintf(buf, msg[MSG_ANIERRLOAD], 1<<info_sequence.fr_start.img.fd_nplanes) ;
                                        form_stop(1, buf) ;
                                        break ;
                              case  3 : /* Une s‚quence est d‚j… pr‚sente */
                                        /* Et n'a pas ‚t‚ remplac‚e.      */
                                        break ;
                              case  4 : /* Le fichier contenant les tailles   */
                                        /* Des images compress‚ees est absent */
                                        break ;
                              case  5 : /* M‚moire insuffisante pour allouer */
										/* Le tableau des tailles des images */
                                        break ;
                            }
                          }
						  break ;
	 case M_ANIMATE     : if (w_ani_handle < 0) break ;
	                      wind_set(w_ani_handle, WF_TOP) ;
	                      animate() ;
                          if (num_window != -1)
                            wind_set(window_handle[num_window], WF_TOP) ;
						  break ;
	case M_ANIM_PARA    : {
							OBJECT *adr_para_ani ;

							Xrsrc_gaddr(R_TREE, FORM_PARANIM, &adr_para_ani) ;
						    adr_para_ani[PARANIM_DISQUE].ob_state  &= ~DISABLED ;
						    adr_para_ani[PARANIM_MEM].ob_state     &= ~DISABLED ;
						    adr_para_ani[PARANIM_PP].ob_state      &= ~DISABLED ;
						    adr_para_ani[PARANIM_TDISQUE].ob_state &= ~DISABLED ;
						    adr_para_ani[PARANIM_TMEM].ob_state    &= ~DISABLED ;
                            adr_para_ani[PARANIM_TR].ob_flags      |= SELECTABLE ;
                            
							if (w_ani_handle == -2)
							{
							  if (stat_anim.source == MEMOIRE)
							  {
							    select(adr_para_ani, PARANIM_MEM) ;
							    deselect(adr_para_ani, PARANIM_DISQUE) ;
							  }
							  else
							  {
							    deselect(adr_para_ani, PARANIM_MEM) ;
							    select(adr_para_ani, PARANIM_DISQUE) ;
							  }

                              if (stat_anim.type == PING_PONG)
                              {
                                select(adr_para_ani, PARANIM_PP) ;
                                deselect(adr_para_ani, PARANIM_BCL) ;
							  }
                              else
                              {
                                deselect(adr_para_ani, PARANIM_PP) ;
                                select(adr_para_ani, PARANIM_BCL) ;
                              }
                            }
                            else
                            {
                              adr_para_ani[PARANIM_TR].ob_flags &= ~SELECTABLE ;
                              
							  if (stat_anim.source == MEMOIRE)
							  {
							    select(adr_para_ani, PARANIM_MEM) ;
							    adr_para_ani[PARANIM_DISQUE].ob_state  |= DISABLED ;
							    adr_para_ani[PARANIM_TDISQUE].ob_state |= DISABLED ;
							  }
							  else
							  {
							    adr_para_ani[PARANIM_MEM].ob_state  |= DISABLED ;
							    adr_para_ani[PARANIM_TMEM].ob_state |= DISABLED ;
							    select(adr_para_ani, PARANIM_DISQUE) ;
							    deselect(adr_para_ani, PARANIM_MEM) ;
							    select(adr_para_ani, PARANIM_TR) ;
							  }

                              if ((*info_sequence.pack) && selected(adr_para_ani, PARANIM_TR))
                              {
                                select(adr_para_ani, PARANIM_BCL) ;
                                deselect(adr_para_ani, PARANIM_PP) ;
                                adr_para_ani[PARANIM_PP].ob_state |= DISABLED ;
                              }
                              else
                              {
                                if (stat_anim.type == PING_PONG)
                                {
                                  select(adr_para_ani, PARANIM_PP) ;
                                  deselect(adr_para_ani, PARANIM_BCL) ;
							    }
                                else
                                {
                                  deselect(adr_para_ani, PARANIM_PP) ;
                                  select(adr_para_ani, PARANIM_BCL) ;
                                }
                              }
                            
                            }
                            
						 	deselect(adr_para_ani, PARANIM_VBL11) ;
						 	deselect(adr_para_ani, PARANIM_VBL12) ;
							deselect(adr_para_ani, PARANIM_VBL13) ;
							deselect(adr_para_ani, PARANIM_VBL14) ;
							if (stat_anim.nb_vbl == 1) select(adr_para_ani, PARANIM_VBL11) ;
							if (stat_anim.nb_vbl == 2) select(adr_para_ani, PARANIM_VBL12) ;
							if (stat_anim.nb_vbl == 3) select(adr_para_ani, PARANIM_VBL13) ;
							if (stat_anim.nb_vbl == 4) select(adr_para_ani, PARANIM_VBL14) ;
							
							if (stat_anim.ecr2 == 1) select(adr_para_ani, PARANIM_ECR2) ;
							else                     deselect(adr_para_ani, PARANIM_ECR2) ;

							fshow_dialog(adr_para_ani, titre) ;
							bouton = xform_do(-1, window_update) ;
							deselect(adr_para_ani, bouton) ;
					 		fhide_dialog() ;

							if (bouton == PARANIM_OK)
							{
                              if (selected(adr_para_ani, PARANIM_MEM)) stat_anim.source = MEMOIRE ;
							  else 									   stat_anim.source = DISQUE ;
							  if (selected(adr_para_ani, PARANIM_VBL11)) stat_anim.nb_vbl = 1 ;
							  if (selected(adr_para_ani, PARANIM_VBL12)) stat_anim.nb_vbl = 2 ;
							  if (selected(adr_para_ani, PARANIM_VBL13)) stat_anim.nb_vbl = 3 ;
							  if (selected(adr_para_ani, PARANIM_VBL14)) stat_anim.nb_vbl = 4 ;

                              if (selected(adr_para_ani, PARANIM_PP))    stat_anim.type   = PING_PONG ;
                              else                                       stat_anim.type   = BOUCLE ;

							  if (selected(adr_para_ani, PARANIM_ECR2))  stat_anim.ecr2   = 1 ;
							  else                                       stat_anim.ecr2   = 0 ;
							}
						  }
						  break ;
    case M_CYCLING1     :
    case M_CYCLING2     : traite_cycling(mesg[4] == M_CYCLING1) ;
                          break ;
  }

  graf_mouse(ARROW, 0L) ;
  menu_tnormal(adr_menu, mesg[3], 1) ;
}

void traite_arrow(int *msg)
{
  int mesg[8] ;
  int whd, action ;
  int w_num ;
  int xi, yi, wxi, whi ;
  int new ;
  int rc, rl ;
  int w, h ;
  
  memcpy(mesg, msg, 16) ;
  whd   = msg[3] ;
  w_num = num_wind(whd) ;
  if (whd == w_ani_handle)
  {
    w = virtuel.fd_w ;
    h = virtuel.fd_h ;
  }
  else
  {
    w = fractal[w_num].img.fd_w ;
    h = fractal[w_num].img.fd_h ;
  }
  action = msg[4] ;

  wind_get(whd, WF_WORKXYWH, &xi, &yi, &wxi, &whi) ;
  mesg[4] = xi  ; mesg[5] = yi ;
  mesg[6] = wxi ; mesg[7] = whi ;
  wind_get(whd, WF_HSLIDE, &xi) ;
  wind_get(whd, WF_VSLIDE, &yi) ;
  rc = (int) (0.5+(double)xi/1000.0*(double)(w-wxi)) ;
  rl = (int) (0.5+(double)yi/1000.0*(double)(h-whi)) ;
  switch(action)
  {
    case WA_UPPAGE : rl = rl-whi ;
                     if (rl < 0) rl = 0 ;
                     new = (int) (0.5+1000.0*(double)rl/(double)(h-whi)) ;
                     wind_set(whd, WF_VSLIDE, new) ;
                     break ;
    case WA_DNPAGE : rl = rl+whi ;
                     if (rl+whi > h) rl = h-whi ;
                     new = (int) (0.5+1000.0*(double)rl/(double)(h-whi)) ;
                     wind_set(whd, WF_VSLIDE, new) ;
                     break ;
    case WA_LFPAGE : rc = rc-wxi ;
                     if (rc < 0) rc = 0 ; 
                     new = (int) (0.5+1000.0*(double)rc/(double)(w-wxi)) ;
                     wind_set(whd, WF_HSLIDE, new) ;
                     break ;
    case WA_RTPAGE : rc = rc+wxi ;
                     if (rc+wxi > w) rc = w-wxi ;
                     new = (int) (0.5+1000.0*(double)rc/(double)(w-wxi)) ;
                     wind_set(whd, WF_HSLIDE, new) ;
                     break ;
    case WA_UPLINE : rl -= 8 ;
                     if (rl < 0) rl = 0 ;
                     new = (int) (0.5+1000.0*(double)rl/(double)(h-whi)) ;
                     wind_set(whd, WF_VSLIDE, new) ;
                     break ;
    case WA_DNLINE : rl += 8 ;
                     if (rl+whi > h) rl = h-whi ;
                     new = (int) (0.5+1000.0*(double)rl/(double)(h-whi)) ;
                     wind_set(whd, WF_VSLIDE, new) ;
                     break ;
    case WA_LFLINE : rc -= 8 ;
                     if (rc < 0) rc = 0 ;  
                     new = (int) (0.5+1000.0*(double)rc/(double)(w-wxi)) ;
                     wind_set(whd, WF_HSLIDE, new) ;
                     break ;
    case WA_RTLINE : rc += 8 ;
                     if (rc+wxi > w) rc = w-wxi ;
                     new = (int) (0.5+1000.0*(double)rc/(double)(w-wxi)) ;
                     wind_set(whd, WF_HSLIDE, new) ;
                     break ;
  }
  
  update_view(w_num) ;
  window_update(mesg) ;
}

void traite_gem(int *mesg)
{
  int xi, yi, wxi, whi ;
  int xe, ye, wxe, whe ;
  int w_num, rc, rl ;
  int w, h ;

  w_num = num_wind(mesg[3]) ;
  if (mesg[3] != w_ani_handle)
  {
    w = fractal[w_num].img.fd_w ;
    h = fractal[w_num].img.fd_h ;
  }
  else
  {
    w = virtuel.fd_w ;
    h = virtuel.fd_h ;
  }
  switch(mesg[0])
  {
	 case MN_SELECTED : traite_menu(mesg) ;
						break ;
	 case WM_REDRAW   : window_update(mesg) ;
						break ;
	 case WM_TOPPED   : num_window = num_wind(mesg[3]) ;
						wind_set(mesg[3], WF_TOP) ;
						if (mesg[3] == w_ani_handle)
						{
						  strcpy(window_name[num_window], " ANIMATION ") ;
						  sprintf(window_info[num_window], msg[MSG_ANIINF],
  								  info_sequence.nb_image, info_sequence.fr_start.img.fd_w, info_sequence.fr_start.img.fd_h, nb_colors) ;
  						}
						else
						{
						  strcpy(window_name[num_window], fractal[num_window].nom) ;
						  strcpy(window_info[num_window], "") ;
						}
						wind_set(window_handle[num_window], WF_NAME, window_name[num_window]) ;
						wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
						set_imgpalette(num_window) ;
						break ;
	 case WM_CLOSED   : {
						  int new_handle ;

						  if (mesg[3] == w_ani_handle)
						  {
					        libere_sequence() ;
					    	free(virtuel.fd_addr) ;
					    	virtuel.fd_addr = NULL ;
					    	w_ani_handle = -2 ;
					  	  }
					  	  else
					  	  {
					  	    num_window = num_wind(mesg[3]) ;
							if (fractal[num_window].img.fd_addr != NULL) free(fractal[num_window].img.fd_addr) ;
							memcpy(&fractal[num_window], &f_default, sizeof(FRACTAL)) ;
					  	  }
					  	  new_handle = close_window(mesg[3]) ;
					  	  num_window = num_wind(new_handle) ;
  					      set_imgpalette(num_window) ;
						}
						break ;
	 case WM_MOVED    : wind_calc(WC_WORK, W_ALL, mesg[4], mesg[5], mesg[6], mesg[7],
								  &xi, &yi, &wxi, &whi) ;
						wind_calc(WC_BORDER, W_ALL, xi & 0xFFF0, yi, wxi, whi,
								  &xe, &ye, &wxe, &whe) ;
						wind_set(mesg[3], WF_CURRXYWH, xe, ye, wxe, whe) ;
						break ;
     case WM_HSLID    : wind_set(mesg[3], WF_HSLIDE, mesg[4]) ;
                        wind_get(mesg[3], WF_WORKXYWH, &xe, &ye, &wxe, &whe) ;
                        mesg[4] = xe;  mesg[5] = ye ;
                        mesg[6] = wxe; mesg[7] = whe ;
                        window_update(mesg) ;
                        update_view(num_wind(mesg[3])) ;
                        break ;
     case WM_VSLID    : wind_set(mesg[3], WF_VSLIDE, mesg[4]) ;
                        wind_get(mesg[3], WF_WORKXYWH, &xe, &ye, &wxe, &whe) ;
                        mesg[4] = xe;  mesg[5] = ye ;
                        mesg[6] = wxe; mesg[7] = whe ;
                        window_update(mesg) ;
                        update_view(num_wind(mesg[3])) ;
                        break ;
      case WM_SIZED   : wind_get(mesg[3], WF_WORKXYWH, &xi, &yi, &wxi, &whi) ;
                        wind_get(mesg[3], WF_HSLIDE, &xi) ;
                        wind_get(mesg[3], WF_VSLIDE, &yi) ;
                        rc = winfo[w_num].x1 ;
                        rl = winfo[w_num].y1 ;
                        wind_calc(WC_WORK, window_kind[w_num], mesg[4], mesg[5], mesg[6], mesg[7],
                                  &xe, &ye, &wxe, &whe) ;
                        if (wxe > w) wxe = w ;
                        if (whe > h) whe = h ;
                        wind_calc(WC_BORDER, window_kind[w_num], xe, ye, wxe, whe, &mesg[4], &mesg[5],
                                  &mesg[6], &mesg[7]) ;
                        wind_set(mesg[3], WF_CURRXYWH, mesg[4], mesg[5], mesg[6], mesg[7]) ;
                        xi = (int) (1000.0*(double)rc/(double)(w-wxe)) ;
                        yi = (int) (1000.0*(double)rl/(double)(h-whe)) ;
                        wind_set(mesg[3], WF_HSLIDE, xi) ;
                        wind_set(mesg[3], WF_VSLIDE, yi) ;
                        wxe = (int) (1000.0*(double)wxe/(double)w) ;
                        whe = (int) (1000.0*(double)whe/(double)h) ;
                        wind_set(mesg[3], WF_HSLSIZE, wxe) ;
                        wind_set(mesg[3], WF_VSLSIZE, whe) ;
                        must_be_fulled[w_num] = 1 ;
                        update_view(w_num) ;
                        break ;
      case WM_FULLED  : if (must_be_fulled[w_num])
                        {
                          wind_get(mesg[3], WF_WORKXYWH, &xi, &yi, &wxi, &whi) ;
                          wind_get(mesg[3], WF_HSLIDE, &xi) ;
                          wind_get(mesg[3], WF_VSLIDE, &yi) ;
                          rc = winfo[w_num].x1 ;
                          rl = winfo[w_num].y1 ;
                          wind_calc(WC_WORK, window_kind[w_num], xdesk, ydesk, wdesk, hdesk,
                                    &xe, &ye, &wxe, &whe) ;
                          if (wxe > w) wxe = w ;
                          if (whe > h) whe = h ;
                          wind_calc(WC_BORDER, window_kind[w_num], xe, ye, wxe, whe, &mesg[4], &mesg[5],
                                    &mesg[6], &mesg[7]) ;
                          wind_set(mesg[3], WF_CURRXYWH, mesg[4], mesg[5], mesg[6], mesg[7]) ;
                          winfo[w_num].x1 = rc ;       winfo[w_num].y1 = rl ;
                          winfo[w_num].x2 = rc+wxe-1 ; winfo[w_num].y2 = rl+whe-1 ;
                          xi = (int) (1000.0*(double)rc/(double)(w-wxe)) ;
                          yi = (int) (1000.0*(double)rl/(double)(h-whe)) ;
                          wind_set(mesg[3], WF_HSLIDE, xi) ;
                          wind_set(mesg[3], WF_VSLIDE, yi) ;
                          wxe = (int) (1000.0*(double)wxe/(double)w) ;
                          whe = (int) (1000.0*(double)whe/(double)h) ;
                          wind_set(mesg[3], WF_HSLSIZE, wxe) ;
                          wind_set(mesg[3], WF_VSLSIZE, whe) ;
                          must_be_fulled[w_num] = 0 ;
                          update_view(w_num) ;
                        }
                        else
                        {
                          wind_get(mesg[3], WF_PREVXYWH, &mesg[4], &mesg[5], &mesg[6], &mesg[7]) ;
                          wind_get(mesg[3], WF_WORKXYWH, &xi, &yi, &wxi, &whi) ;
                          wind_get(mesg[3], WF_HSLIDE, &xi) ;
                          wind_get(mesg[3], WF_VSLIDE, &yi) ;
                          rc = winfo[w_num].x1 ;
                          rl = winfo[w_num].y1 ;
                          wind_calc(WC_WORK, window_kind[w_num], mesg[4], mesg[5], mesg[6], mesg[7],
                                    &xe, &ye, &wxe, &whe) ;
                          if (wxe > w) wxe = w ;
                          if (whe > h) whe = h ;
                          wind_calc(WC_BORDER, window_kind[w_num], xe, ye, wxe, whe, &mesg[4], &mesg[5],
                                    &mesg[6], &mesg[7]) ;
                          wind_set(mesg[3], WF_CURRXYWH, mesg[4], mesg[5], mesg[6], mesg[7]) ;
                          xi = (int) (1000.0*(double)rc/(double)(w-wxe)) ;
                          yi = (int) (1000.0*(double)rl/(double)(h-whe)) ;
                          wind_set(mesg[3], WF_HSLIDE, xi) ;
                          wind_set(mesg[3], WF_VSLIDE, yi) ;
                          wxe = (int) (1000.0*(double)wxe/(double)w) ;
                          whe = (int) (1000.0*(double)whe/(double)h) ;
                          wind_set(mesg[3], WF_HSLSIZE, wxe) ;
                          wind_set(mesg[3], WF_VSLSIZE, whe) ;
                          update_view(w_num) ;
                          must_be_fulled[w_num] = 1 ;
                        }
                        break ;
      case WM_ARROWED : traite_arrow(mesg) ;
                        break ;
      case WM_ICONIFY : window_iconify(mesg) ;
                        if (window_icon[w_num].fd_addr == NULL) iconify_picture(w_num) ;
                        break;
      case WM_UNICONIFY:window_uniconify(mesg) ;
	                    break ;
  }
  
  graf_mouse(ARROW, 0L) ;
}

void traite_update_calc(int num)
{
  if (num != -1)  /* Si on doit r‚-‚valuer le calcul d'un fractal */
  {
	int valid ;

	valid = form_interrogation(1, msg[MSG_SETCHANGED]) ;
	if (valid == 1) lance_calcul(num) ;
  }
}

void traite_button(int button, int mx, int my, int mbreturn)
{
  int n_window ;
  int w_handle ;
  
  if (button != 2) return ;   /* Le bouton droit seulement */
  if (mbreturn != 1) return ; /* 1 Clic seulement */
  w_handle = wind_find(mx, my) ;
  n_window = num_wind(w_handle) ;
  if (n_window == -1) return ;
  if (window_handle[n_window] == w_ani_handle) info_animation() ;
  else
  {
	FRACTAL last ;

	memcpy(&last, &fractal[n_window], sizeof(FRACTAL)) ;
	adr_info[INFO_MOINS].ob_flags &= ~TOUCHEXIT ;
	adr_info[INFO_PLUS].ob_flags  &= ~TOUCHEXIT ;
	adr_info[INFO_MOINS].ob_state |= DISABLED ;
	adr_info[INFO_PLUS].ob_state  |= DISABLED ;
	infos(&fractal[n_window]) ;
	strcpy(window_name[n_window], fractal[n_window].nom) ;
	wind_set(window_handle[n_window], WF_NAME, window_name[n_window]) ;
	strcpy(window_info[n_window], "") ;
	wind_set(window_handle[n_window], WF_INFO, window_info[n_window]) ;
	if (!same_aspect(&last, &fractal[n_window]))
	{
	  ev_num     = n_window ;
	  num_window = n_window ;
	  event.ev_mflags = MU_KEYBD|MU_MESAG|MU_TIMER|MU_BUTTON ;
	  wind_set(window_handle[n_window], WF_TOP) ;
    }
  }
}
