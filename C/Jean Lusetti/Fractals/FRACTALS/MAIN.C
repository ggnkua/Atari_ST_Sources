/***********************************************/
/*------------------ MAIN.C -------------------*/
/* Programme principal du calcul des ensembles */
/* Fractals de MANDELBROT et de JULIA.         */
/* (c) LUSETTI Jean Novembre 92                */
/***********************************************/
#include    <stdio.h>
#include   <stdlib.h>
#include   <string.h>

#include "..\tools\xgem.h"

#include     "defs.h"
#include    "anime.h"
#include   "gstevn.h"
#include   "calcul.h"
#include  "fractal.h"
#include "palettes.h"
#include "fract_io.h"
#include "clgstevn.h"


char fini   =  0 ; /* Indicateur de fin d'application        */
char ev_num = -1 ; /* Indicateur de r‚-‚valuation du fractal */
char fractal_name[1+LAST_SET][20] ;
char fractal_algo[1+LAST_SET][10] ;


void init_forms(void)
{  
  OBJECT *obj ;

  switch(cpu_type)
  {
	case  0 : write_text(adr_form_calcul, CALC_CPU, "  CPU 68000") ;
			  break ;
	case 10 : write_text(adr_form_calcul, CALC_CPU, "  CPU 68010") ;
			  break ;
	case 20 : write_text(adr_form_calcul, CALC_CPU, "  CPU 68020") ;
			  break ;
	case 30 : write_text(adr_form_calcul, CALC_CPU, "  CPU 68030") ;
			  break ;
	case 40 : write_text(adr_form_calcul, CALC_CPU, "  CPU 68040") ;
			  break ;
  }

  adr_form_calcul[CALC_FPU].ob_state &= ~DISABLED ;
  switch(fpu_type & 0x000E)  /* Isole les bits 1 … 3 */
  {
	case 0  : write_text(adr_form_calcul, CALC_FPU, "  FPU 6888?") ;
			  adr_form_calcul[CALC_FPU].ob_state |= DISABLED ;
			  break ;
	case 2  : write_text(adr_form_calcul, CALC_FPU, "  FPU 6888?") ;
			  break ;
	case 4  : write_text(adr_form_calcul, CALC_FPU, "  FPU 68881") ;
			  break ;
	case 8  : write_text(adr_form_calcul, CALC_FPU, "  FPU 68882") ;
			  break ;
	case 16 : write_text(adr_form_calcul, CALC_FPU, "  FPU 68040") ;
			  break ;
  }

  switch(cpu_type)
  {
	case  0 : write_text(adr_form_canim, CALCA_CPU, "  CPU 68000") ;
			  break ;
	case 10 : write_text(adr_form_canim, CALCA_CPU, "  CPU 68010") ;
			  break ;
	case 20 : write_text(adr_form_canim, CALCA_CPU, "  CPU 68020") ;
			  break ;
	case 30 : write_text(adr_form_canim, CALCA_CPU, "  CPU 68030") ;
			  break ;
	case 40 : write_text(adr_form_canim, CALCA_CPU, "  CPU 68040") ;
			  break ;
  }

  switch(fpu_type & 0x000E)  /* Isole les bits 1 … 3 */
  {
	case 0  : write_text(adr_form_canim, CALCA_FPU, "  FPU 6888?") ;
			  adr_form_canim[CALCA_FPU].ob_state |= DISABLED ;
			  break ;
	case 2  : write_text(adr_form_canim, CALCA_FPU, "  FPU 6888?") ;
			  break ;
	case 4  : write_text(adr_form_canim, CALCA_FPU, "  FPU 68881") ;
			  break ;
	case 8  : write_text(adr_form_canim, CALCA_FPU, "  FPU 68882") ;
			  break ;
	case 16 : write_text(adr_form_canim, CALCA_FPU, "  FPU 68040") ;
			  break ;
  }

  Xrsrc_gaddr(R_TREE, FORM_MKPALETTE, &obj) ;
  obj[MKPAL_BOX].ob_spec.userblk->ub_code = draw_colors ;

  Xrsrc_gaddr(R_TREE, FORM_MKPALETTE, &obj) ;
  obj[MKPAL_CURRCOL].ob_spec.userblk->ub_code = draw_currentcolor ;
  *path_palette = 0 ;  
}

void init_msg(void)
{
  OBJECT *adr_msg ;
  int    i = 0 ;

  Xrsrc_gaddr(R_TREE, FORM_MESSAGES, &adr_msg) ;
  for (i = 1; i < MSG_ENDLIST; i++)
    msg[i] = adr_msg[i].ob_spec.free_string ;
}

void init_popup(void)
{
  int i ;

  strcpy(fractal_name[MANDELBROT], " Mandelbrot ") ;
  strcpy(fractal_name[JULIA], " Julia ") ;
  strcpy(fractal_name[MANOWARM], " ManowarM ") ;
  strcpy(fractal_name[MANOWARJ], " ManowarJ ") ;
  strcpy(fractal_name[UNITY], " Unity ") ;
  strcpy(fractal_name[BARNSLEYM], " BarnsleyM ") ;
  strcpy(fractal_name[BARNSLEYJ], " BarnsleyJ ") ;
  strcpy(fractal_name[HYPERBASIN], " HyperBasin ") ;
  strcpy(fractal_name[SPIDER], " Spider ") ;
  strcpy(fractal_name[SIERPINSKI], " Sierpinski ") ;
  strcpy(fractal_algo[LSM], " MPN ") ;
  strcpy(fractal_algo[DEM], " MED ") ;

  popup_name = popup_make(1+LAST_SET, 12) ;
  for (i = FIRST_SET; i <= LAST_SET; i++)
    strcpy(popup_name[1+i].ob_spec.free_string, fractal_name[i]) ;

  popup_algo = popup_make(2, 5) ;
  for (i = LSM; i <= DEM; i++)
    strcpy(popup_algo[1+i].ob_spec.free_string, fractal_algo[i]) ;

  if (!fpu_type) popup_algo[1+DEM].ob_state |= DISABLED ;
}

int init(void)
{
  int i ;
  
  if (gem_init() < 0) return(-1) ;

  if (rsrc_load("FRACTAL.RSC") == 0)
  {
	v_show_c(handle, 1) ;
	form_stop(1, "[Le fichier ressource|est absent !][Fin]") ;
	gem_exit() ;

	return(1) ;
  }

  init_msg() ;

  if (Xmax < 639)
  {
	v_show_c(handle, 1) ;
	form_stop(1, msg[MSG_RESOLERR]) ;
    rsrc_free() ;

	gem_exit() ;
	return(1) ;
  }

  if (Ymax < 399)
  {
	v_show_c(handle, 1) ;
	form_stop(1, msg[MSG_RESOLERR]) ;
    rsrc_free() ;

	gem_exit() ;
	return(1) ;
  }

  if (Truecolor)
  {
	v_show_c(handle, 1) ;
	form_stop(1, msg[MSG_ERRTRUECOLOR]) ;
    rsrc_free() ;

	gem_exit() ;
	return(1) ;
  }

  dsp_code = (char *) malloc(6000) ;
  if (dsp_code == NULL)
  {
	v_show_c(handle, 1) ;
	form_error(8) ;
    rsrc_free() ;

	gem_exit() ;
	return(1) ;
  }

  Xrsrc_gaddr(R_TREE, M_FRAC, &adr_menu) ;
  Xrsrc_gaddr(R_TREE, FORM_INFO, &adr_info) ;
  select(adr_info, INFO_CENTRE) ;     /* Par d‚faut, on choisit le */
  deselect(adr_info, INFO_FENETRE) ;  /* mode de rep‚rage central  */

  menu_bar(adr_menu, 1) ;
  if (Multitos || !_app) menu_register(ap_id, MENU_NAME) ;
  charge_config() ;
  init_module_calcul() ;
  init_module_anime() ;

  if (charge_mandel(0) == 0)
  {
	v_show_c(handle, 1) ;
    rsrc_free() ;

	gem_exit() ;
	return(1) ;
  }

  init_popup() ;

  event.ev_mflags     = MU_KEYBD|MU_MESAG|MU_BUTTON ;
  event.ev_mbclicks   = 1 ;
  event.ev_bmask      = 2 ;
  event.ev_mbstate    = 2 ;
  event.ev_mm1flags   = 0 ;
  event.ev_mm1x       = 0 ;
  event.ev_mm1y       = 0 ;
  event.ev_mm1width   = 0 ;
  event.ev_mm1height  = 0 ;
  event.ev_mm2flags   = 0 ;
  event.ev_mm2x       = 0 ;
  event.ev_mm2y       = 0 ;
  event.ev_mm2width   = 0 ;
  event.ev_mm2height  = 0 ;
  event.ev_mtlocount  = 100 ;
  event.ev_mthicount  = 0 ;

  for (i = 0; i < NB_WINDOWS; i++) get_tospalette(&fractal_pal[i][0]) ; 

  init_forms() ;

  return(0) ;
}

int quitte(void)
{
  int i ;
  int ret = 0 ;

  popup_kill(popup_name, 1+LAST_SET) ;
  popup_kill(popup_algo, 2) ;

  for (i = 0; i < NB_WINDOWS; i++)
  {
	if (window_opened[i] == 1) close_window(window_handle[i]) ;
	if (fractal[i].img.fd_addr != NULL) free(fractal[i].img.fd_addr) ;
  }

  free(dsp_code) ;
  if (Mandel.img.fd_addr != NULL) free(Mandel.img.fd_addr) ;
  quitte_module_anime() ;

  menu_bar(adr_menu, 0) ;
  rsrc_free() ;

  if (gem_exit() == 0) ret = 1 ;

  return(ret) ;
}


int main(void)
{
  int which ;
  int ret ;

  if (init() != 0) return(1) ;
#ifdef MEMDEBUG
  set_MemdebugOptions(c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, 
                      0L, 0,
                      "STATS.MEM",
                      "ERROR.MEM"
                     ) ;
#endif

  while (!fini)
  {
	ajour_menu() ;
	which = EvntMulti(&event) ;
	if (which & MU_KEYBD) traite_clavier(event.ev_mkreturn) ;
	if (which & MU_MESAG) traite_gem(event.ev_mmgpbuf) ;
	if (which & MU_TIMER)
	{
	  traite_update_calc(ev_num) ;
	  ev_num = -1 ;
	  event.ev_mflags = MU_KEYBD | MU_MESAG | MU_BUTTON ;
	}
	if (which & MU_BUTTON) traite_button(event.ev_mmobutton, event.ev_mmox, event.ev_mmoy, event.ev_mbreturn) ;
  }

  ret = quitte() ;
  return(ret) ;
}
