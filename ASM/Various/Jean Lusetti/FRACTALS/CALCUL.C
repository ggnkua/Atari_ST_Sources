/*******************************************/
/*--------------- CALCUL.C ----------------*/
/* Module de calcul du Project FRACTAL.PRJ */
/*******************************************/
#include      <ext.h>
#include     <math.h>
#include   <stdlib.h>
#include   <string.h>

#include     "..\tools\xgem.h"
#include     "..\tools\xdsp.h"
#include   "..\tools\xstdio.h"
#include  "..\tools\cookies.h"
#include  "..\tools\fpu_cpu.h"
#include "..\tools\rasterop.h"
#include "..\tools\image_io.h"

#include     "defs.h"
#include    "anime.h"
#include   "gstevn.h"
#include  "fractal.h"
#include "calc_asm.h"
#include "fract_io.h"


#define SYM_CENTRE  1   /* Sym‚trie par rapport … (0,0)         */
#define SYM_AXE     2   /* Sym‚trie par rapport … (Ox)          */
#define MAX_NBX  4096   /* Nombre maximal de points en abscisse */


DSP_DATA show_dsp ;            /* Pr‚calcul pour le calcul temps r‚el */
FRACTAL  fractal[NB_WINDOWS] ; /* Tableau de structures FRACTAL       */
INFOW    winfo[NB_WINDOWS] ;   /* Tableau des infos fenˆtre           */
FRACTAL  f_default ;           /* ParamŠtres par d‚faut               */
FRACTAL  frac ;                /* ParamŠtres du fractal calcul‚       */
DSP_DATA dsp_data ;            /* ParamŠtres … envoyer au DSP         */
OBJECT   *adr_form_calcul ;    /* Pointeur sur l'objet form_calcul    */
clock_t  start_time ;          /* Lancement du calcul                 */
clock_t  end_time ;            /* Fin du calcul                       */
double   ftoe ;                /* Conversion Flottant -> Entier       */
double   ftof ;                /* Conversion Flottant -> Fractionnel  */
double   min_delta ;           /* Pr‚cision du codage entier          */
double   wobj, hobj ;          /* Tailles de la barre de progression  */
long     preabsdsp[MAX_NBX] ;  /* Pr‚calcul abscisses pour DSP 56001  */ 
long     preabscpu[MAX_NBX] ;  /* Pr‚calcul abscisses pour CPU 680X0  */
                               /* Pour le temps r‚el :                */
long     showabsdsp[MAX_NBX] ; /* Pr‚calcul abscisses pour DSP 56001  */ 
long     showabscpu[MAX_NBX] ; /* Pr‚calcul abscisses pour CPU 680X0  */
long     pre_ligne[MAX_NBX] ;  /* Pr‚calcul pour stocke_orbite        */
long     dsp_code_size ;       /* Taille du code DSP en DSP Words     */
long     cos_a, sin_a ;        /* Cosinus et Sinus de l'angle         */
long     xc, yc ;              /* Centre de la rotation               */
int      angle ;               /*Angle de rotation (en minutes)       */
void     *xyorbit ;            /* Tableau des orbites pour MED        */
int      off_x, off_y ;        /* Coordonn‚es boite du calcul         */
int      largeur, hauteur ;    /* Dimensions par d‚faut des fenˆtres  */
int      cpu_type ;            /* Type de CPU (valeur du cookie)      */
int      fpu_type ;            /* Type de FPU (valeur du cookie)      */
int      dsp_busy ;            /* DSP non disponible                  */
int      ability ;             /* Identificateur du programme DSP     */
int      dsp_line ;            /* Ligne DSP en cours de calcul        */
int      acr_dsp ;             /* 1 si la pr‚cision du DSP est OK     */
int      use_dsp ;             /* 1 si on utilise le DSP              */
int      fractal_pal[NB_WINDOWS][3*256] ; /* Palettes associ‚es       */
int      nbl_cpu, nbl_fpu, nbl_dsp ;
int      stat_calc, max_iter, type, algo ;
int      nbpt_x, nbpt_y, curr_ligne, curr_x, curr_y ;
int      last_cpuline, last_dspline ;
char     with_dsp ;
char     flag_show = 1 ;       /* Flag affichage de la progression    */
char     *dsp_code ;           /* Pointeur sur le code binaire DSP    */
unsigned char *adr_data ;      /* Pointeur sur le tableau d'orbites   */


void init_default_fractal(void)
{
  strcpy(f_default.nom, "XXXXXXXXFRC") ;
  f_default.type       = MANDELBROT ;
  f_default.maxiter    = 32 ;
  f_default.ix         = 0 ;
  f_default.iy         = 0 ;
  f_default.algorithme = LSM ;

  f_default.xmin     = -2.5 ;
  f_default.ymin     = -2.5*(double)hauteur/(double)largeur ;
  f_default.xmax     =  2.5 ;
  f_default.ymax     =  2.5*(double)hauteur/(double)largeur ;
  f_default.largeur  =  f_default.xmax-f_default.xmin ;
  f_default.hauteur  =  f_default.ymax-f_default.ymin ;
  f_default.centre_x =  f_default.xmin+f_default.largeur/2 ;
  f_default.centre_y =  f_default.ymin+f_default.hauteur/2 ;

  f_default.img.fd_addr    = (int *) NULL ;
  f_default.img.fd_w       = largeur ;
  f_default.img.fd_h       = hauteur ;
  f_default.img.fd_wdwidth = largeur/16 ;
  f_default.img.fd_stand   = 0 ;
  f_default.img.fd_nplanes = nb_plane ;

  memset(&f_default.report, 0, sizeof(FRACTAL_REPORT)) ;
}

void init_real_time(void)
{
  double echx ;
  long   *pt1, *pt2, *pt ;
  int    i ;

  fr.maxiter = config.tr_maxiter ;
  fr.xmin = -2.5 ; fr.ymin = -1.56 ;
  fr.xmax = 2.5 ; fr.ymax = 1.56 ;
  fr.largeur = 5.0 ; fr.hauteur = 3.125 ;
  fr.centre_x = fr.centre_y = 0 ;
  fr.img.fd_w = config.tr_width ;
  fr.img.fd_h = config.tr_height ;
  fr.img.fd_nplanes = nb_plane ;
  fr.img.fd_wdwidth = fr.img.fd_w/16 ;
  fr.img.fd_stand = 0 ;

  show_dsp.max_iter = fr.maxiter ;
  show_dsp.type     = fr.type ;
  show_dsp.init_x   = ftob24(ftof*fr.ix) ;
  show_dsp.init_y   = ftob24(ftof*fr.iy) ;
  show_dsp.xmin     = ftob24(ftof*fr.xmin) ;
  show_dsp.ymax     = ftob24(ftof*fr.ymax) ;
  show_dsp.ech_x    = ftob24(ftof*(double)fr.largeur/(double)fr.img.fd_w) ;
  show_dsp.ech_y    = ftob24(ftof*(double)fr.hauteur/(double)fr.img.fd_h) ;
  show_dsp.ech2_x   = ftob24(ftof*2.0*(double)fr.largeur/(double)fr.img.fd_w) ;
  show_dsp.ech2_y   = ftob24(ftof*2.0*(double)fr.hauteur/(double)fr.img.fd_h) ;
  show_dsp.nbpt_x   = fr.img.fd_w ;
  show_dsp.nr1      = ftob24(ftof*1.0) ;
  show_dsp.angle    = 0 ;
  show_dsp.cos_a    = ftob24(ftof*1.0) ;
  show_dsp.sin_a    = 0 ;

  pt   = showabscpu ;  
  echx = fr.largeur/(double)fr.img.fd_w ;
  for (i = 0; i < fr.img.fd_w; i++) *pt++ = (long) (ftoe*(fr.xmin+(double)i*echx)) ;

  pt1 = showabscpu ;
  pt2 = showabsdsp ;
  for (i = 0; i < show_dsp.nbpt_x; i++)
  {
    *pt2 = (*pt1) >> 7 ;
    pt1++ ;
    pt2++ ;
  }
}

#pragma warn -parm
int set_inits(int type, char axe)
{
  switch(type)
  {
    case MANDELBROT :
    case JULIA      :
    case MANOWARM   :
    case MANOWARJ   :
    case BARNSLEYM  :
    case BARNSLEYJ  :
    case HYPERBASIN :
    case SPIDER     :
    case SIERPINSKI :
    case UNITY      : return(1) ;
  }

  return(0) ;
}
#pragma warn +parm

int set_algo(int type, int algo)
{
  switch(type)
  {
    case MANDELBROT :
    case JULIA      : return(1) ;
    case MANOWARM   :
    case MANOWARJ   :
    case BARNSLEYM  :
    case BARNSLEYJ  :
    case HYPERBASIN :
    case SPIDER     :
    case SIERPINSKI :
    case UNITY      : if (algo == LSM) return(1) ;
                      else             return(0) ;
  }

  return(0) ;
}

void init_module_calcul(void)
{
  COOKIE *cpu, *fpu ;
  int    i ;
  char   dspfile[200] ;

  strcpy (dspfile, " :") ;
  dspfile[0] = 'A' + getdisk();
  getcurdir(0, &dspfile[2]);
  strcat(dspfile, "\\") ;
  largeur   = (2*Xmax/3) & 0xFFF0 ; /* Multiple de 16 */
  hauteur   = (int) ((double)largeur*(double)Ymax/(double)Xmax) ;
  hauteur   = 3*(hauteur/3) ; /* Multiple de 3 */

  ftoe      = pow(2, 28) ;
  ftof      = 0.25 ; /* 1.0 DSP signifie 4.0 */
  min_delta = 1/ftoe ;

  cpu = cookie_find("_CPU") ;
  if (cpu != NULL) cpu_type = (int) cpu->data ;
  else             cpu_type = 0 ;

  fpu = cookie_find("_FPU") ;
  if (fpu != NULL) fpu_type = (int) (fpu->data >> 16) ;
  else             fpu_type = 0 ;

  init_default_fractal() ;
  for (i = 0; i < NB_WINDOWS; i++)
  {
	memcpy(&fractal[i], &f_default, sizeof(FRACTAL)) ;
	memset(fractal[i].nom, 0, 16) ;
	sprintf(fractal[i].nom, "FRACT%.3dFRC", i) ;
	memset(&winfo[0], 0, sizeof(INFOW)) ;
  }

  strcat(dspfile, "CALC_DSP.LOD") ;
  if (!file_exist(dspfile))
  {
    form_stop(1, msg[MSG_LODNOTFOUND]) ;
    ability = -1 ;
  }
  else
  {
    ability       = Dsp_RequestUniqueAbility() ;
    dsp_code_size = Dsp_LodToBinary(dspfile, dsp_code) ;
  }
  
  xyorbit = NULL ;

  Xrsrc_gaddr(R_TREE, FORM_CALCUL, &adr_form_calcul) ;

  init_real_time() ;
  Mandel.img.fd_addr = NULL ;
}

void orbvdi2tos(long nb)
{
  long          l ;
  unsigned char *pt ;
  unsigned char val ;
  unsigned char *vdi2tos ;

  vdi2tos = get_ptvdi2tos(nb_plane) ;
  pt = adr_data ;
  if (nb_colors == 2)
  {
    if (config.set_only)
      for (l = 0; l < (nb >> 4) ; l++)
      {
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
        if (*pt != 1) *pt = 0 ;
        pt++ ;
      }
  }
  else
  for (l = 0; l < (nb >> 4) ; l++)
  {
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
    val    = *pt ;
    *pt++ = vdi2tos[val] ;
  }
}

void orbite_to_raster(FRACTAL *fr, ZONE *zone, int w_handle)
{
  int          n_window ;
  int          nby ;
  unsigned int *pt ;

  if (flag_show && (w_handle != -1))
  {
    n_window = num_wind(w_handle) ;
    strcpy(window_info[n_window], msg[MSG_ORBCONV]) ;
    wind_set(window_handle[n_window], WF_INFO, window_info[n_window]) ;
  }

  nby = nbl_cpu+nbl_dsp+nbl_fpu ;
  if (nby > zone->h) nby = zone->h ;
  pt  = (unsigned int *) fr->img.fd_addr ;
  pt += ((long)zone->yi*img_size(nbpt_x, 1, nb_plane))/2 ;
  i2r_init(pt, fr->img.fd_w, fr->img.fd_nplanes) ;
  i2r_data = adr_data ;
  i2r_nb   = (long)(nby)*(long)nbpt_x ;
  orbvdi2tos(i2r_nb) ;
  ind2raster() ;
  if (flag_show && (w_handle != -1))
  {
    strcpy(window_info[n_window], "") ;
    wind_set(window_handle[n_window], WF_INFO, window_info[n_window]) ;
  }
}

int symetrie_possible(FRACTAL *fr)
{
  if (angle) return(0) ;

  switch(fr->type)
  {
	case MANDELBROT : if ((fabs(fr->ix) < 1E-06) && (fabs(fr->iy) < 1E-06))
						if ((fr->ymin < 0) && (fr->ymax > 0)) return(SYM_AXE) ;
					  break ;
    case SPIDER     :
    case HYPERBASIN :
	case MANOWARM   :
	case JULIA      : if (fabs(fr->iy) < 1E-06)
						if ((fr->ymin < 0) && (fr->ymax > 0)) return(SYM_AXE) ;
					  break ;
	case UNITY      : if ((fr->ymin < 0) && (fr->ymax > 0)) return(SYM_AXE) ;
  }

  return(0) ;
}

void get_fractal_zones(FRACTAL *fr, ZONE *calc_zone, ZONE *deduct_zone)
{
  double ey ;

  calc_zone->xi   = 0 ;
  calc_zone->w    = fr->img.fd_w ;
  deduct_zone->xi = 0 ;
  deduct_zone->w  = fr->img.fd_w ;

  ey = (double)fr->img.fd_h/fr->hauteur ;
  if (fabs(fr->ymin) < fabs(fr->ymax))
  {
	calc_zone->yi   = 0 ;
	calc_zone->h    = 1+(int) (fabs(ey*fr->ymax)) ;
	deduct_zone->yi = calc_zone->h ;
	deduct_zone->h  = fr->img.fd_h-calc_zone->h ;

	fr->ymin    = 0.0 ;
	fr->hauteur = fabs(fr->ymax) ;
  }
  else
  {
	calc_zone->yi   = (int) fabs(ey*fr->ymax) ;
	calc_zone->h    = fr->img.fd_h-calc_zone->yi ;
	deduct_zone->yi = 0 ;
	deduct_zone->h  = calc_zone->yi ;

	fr->ymax    = 0.0 ;
	fr->hauteur = fabs(fr->ymin) ;
  }

  fr->centre_y = (fr->ymin+fr->ymax)/2 ;
  fr->img.fd_h = calc_zone->h ;
}

void get_report(FRACTAL *fr)
{
  double nbl_calc ;
  
  nbl_calc = (double) (nbpt_y) ;
  fr->report.t_calc  = (10*(end_time-start_time))/CLK_TCK ; /* En dixiŠmes de secondes */
  fr->report.nbl_cpu = nbl_cpu ;
  fr->report.nbl_fpu = nbl_fpu ;
  fr->report.nbl_dsp = nbl_dsp ;
  fr->report.pc_cpu  = (int) (100.0*(double)nbl_cpu/nbl_calc) ;
  fr->report.pc_fpu  = (int) (100.0*(double)nbl_fpu/nbl_calc) ;
  fr->report.pc_dsp  = (int) (100.0*(double)nbl_dsp/nbl_calc) ;
}

void affiche_progression_calcul(void)
{
  double ratio ;
  int   xyarray[4] ;

  if (!flag_show) return ;

  if (!flag_ani)
  {
    if (curr_ligne < nbpt_y)
      ratio = wobj*(double)curr_ligne/(double)nbpt_y ;
    else
      ratio = wobj ; 
    xyarray[0] = off_x ;
    xyarray[1] = off_y ;
    xyarray[2] = off_x + (int) ratio ;
    xyarray[3] = off_y + hobj ;
  }
  else
  {
    if (curr_ligne < nbpt_y)
      ratio = (double) (adr_form_canim[CANIM_CUR].ob_width-2)*((double)curr_ligne/(double)nbpt_y) ;
    else
      ratio = (double) (adr_form_canim[CANIM_CUR].ob_width-2) ; 
    xyarray[0] = off_x ;
    xyarray[1] = off_y ;
    xyarray[2] = off_x + (int) ratio ;
    xyarray[3] = off_y + adr_form_canim[CANIM_CUR].ob_height-1 ;
  }

  vr_recfl(handle, xyarray) ;
}

int ok_transmit(DSP_DATA *to, DSP_DATA*from)
{
  long mask = 0x00FFFFFFL ;
  
  if ((to->max_iter & mask) != (from->max_iter & mask)) return(0) ;
  if ((to->type & mask)     != (from->type & mask))     return(0) ;
  if ((to->init_x & mask)   != (from->init_x & mask))   return(0) ;
  if ((to->init_y & mask)   != (from->init_y & mask))   return(0) ;
  if ((to->xmin & mask)     != (from->xmin & mask))     return(0) ;
  if ((to->ymax & mask)     != (from->ymax & mask))     return(0) ;
  if ((to->ech_x & mask)    != (from->ech_x & mask))    return(0) ;
  if ((to->ech_y & mask)    != (from->ech_y & mask))    return(0) ;
  if ((to->ech2_x & mask)   != (from->ech2_x & mask))   return(0) ;
  if ((to->ech2_y & mask)   != (from->ech2_y & mask))   return(0) ;
  if ((to->nbpt_x & mask)   != (from->nbpt_x & mask))   return(0) ;
  if ((to->nr1    & mask)   != (from->nr1    & mask))   return(0) ;
  
  return(1) ;
}

void init_dsp_data(FRACTAL *fr)
{
  DSP_DATA chk ;
  double   rad ;
  long     *pt1, *pt2, *pdsp ;
  int      i ;
  int      header[2] ;

  if (flag_show == 0) memcpy(&dsp_data, &show_dsp, sizeof(DSP_DATA)) ;
  else
  {
    dsp_data.max_iter = fr->maxiter ;
    dsp_data.xmin     = ftob24(ftof*fr->xmin) ;
    dsp_data.ymax     = ftob24(ftof*fr->ymax) ;
    dsp_data.ech_x    = ftob24(ftof*(double)fr->largeur/(double)fr->img.fd_w) ;
    dsp_data.ech_y    = ftob24(ftof*(double)fr->hauteur/(double)fr->img.fd_h) ;
    dsp_data.ech2_x   = ftob24(ftof*2.0*(double)fr->largeur/(double)fr->img.fd_w) ;
    dsp_data.ech2_y   = ftob24(ftof*2.0*(double)fr->hauteur/(double)fr->img.fd_h) ;
    dsp_data.nbpt_x   = fr->img.fd_w ;
    dsp_data.nr1      = ftob24(ftof*1.0) ;
    dsp_data.angle    = angle ;
    rad               = (double)angle*M_PI/1800.0 ;
    dsp_data.cos_a    = ftob24(ftof*cos(rad)) ;
    dsp_data.sin_a    = ftob24(ftof*sin(rad));
    dsp_data.xc       = ftob24(ftof*0.5*(fr->xmin+fr->xmax)) ;
    dsp_data.yc       = ftob24(ftof*0.5*(fr->ymin+fr->ymax)) ;
  }
  dsp_data.init_x = ftob24(ftof*fr->ix) ;
  dsp_data.init_y = ftob24(ftof*fr->iy) ;
  dsp_data.type   = fr->type ;

  header[0] = 1 ; /* Envoi des paramŠtres du calcul */
  header[1] = (int) (sizeof(DSP_DATA)/sizeof(long)) ;
  Dsp_BlkWords((long *) header, 2, (long *) header, 0L) ;
  Dsp_BlkUnpacked(&dsp_data.max_iter, 17, &chk.max_iter, 17) ;
  if (!ok_transmit(&dsp_data, &chk))
  {
    form_stop(1, msg[MSG_DSPCOMERR]) ;
    dsp_code_size = -1 ;
  }

  /* Envoi des pr‚calculs des abscisses pour compenser */
  /* La perte due au passage de 32 bits en 24 bits     */
  if (flag_show)
  {
    pt1 = preabscpu ;
    pt2 = preabsdsp ;
    for (i = 0; i < dsp_data.nbpt_x; i++)
    {
      *pt2 = (*pt1) >> 7 ;
      pt1++ ;
      pt2++ ;
    }
    pdsp = preabsdsp ;
  }
  else pdsp = showabsdsp ;

  Dsp_BlkUnpacked(pdsp, dsp_data.nbpt_x, pdsp, 0L) ;
}

void receiver(void)
{
  int      to_dsp[4] ;
  long     ydsp ;
  unsigned char *pt ;

  if (!config.dsp_on) return ;
  if (dsp_line > nbpt_y)  return ;
  if ((dsp_code_size <= 0) || (ability == -1) || (acr_dsp != 1) || (use_dsp != 1))
    return ;

  if (Dsp_Hf2() == 1) return ;

  pt  = adr_data ;
  pt += (long)dsp_line*(long)nbpt_x ;
  Dsp_BlkBytes(pt, 0L, pt, 3*nbpt_x) ;

  nbl_dsp    += 3 ;
  curr_ligne += 3 ;
  ccy        -= ech2_y+ech_y ;
  if ((curr_ligne >= nbpt_y) || (stat_calc == 1))
  {
    to_dsp[0] = 3 ; /* Informe le DSP que le calcul est termin‚ */
    to_dsp[1] = 0 ; /* Rien d'autre … transmettre */
    Dsp_BlkWords((long *) to_dsp, 2, (long *) to_dsp, 0L) ;
    last_dspline = dsp_line ;
    dsp_line = nbpt_y+3 ;
  }
  else
  {
    to_dsp[0] = 2 ;          /* Le calcul continue */
    to_dsp[1] = 1 ;          /* Encore une information … transmettre */
    Dsp_BlkWords((long *) to_dsp, 2, (long *) to_dsp, 0L) ;
    ydsp = ftob24(ftof*(double)ccy/ftoe) ;
    Dsp_BlkUnpacked(&ydsp, 1, &ydsp, 0L) ;
    dsp_line = curr_ligne ;
    with_dsp = 1 ;
  }

  if (flag_show) affiche_progression_calcul() ;
}

void precalcul(FRACTAL *fr)
{
  double echx ;
  int    i ;
  long   *pt ;

  if (flag_show == 0) memcpy(preabscpu, showabscpu, sizeof(long)*nbpt_x) ;
  else
  {
    pt = preabscpu ;  
    echx = fr->largeur/(double)fr->img.fd_w ;
    
    for (i = 0; i < nbpt_x; i++)
      *pt++ = (long) (ftoe*(fr->xmin+(double)i*echx)) ;
  }
}

void init_asm_data(FRACTAL *fr)
{
  double rad ;
  long  *pt ;
  long  pred ;
  int   i ;

  nbpt_x   = fr->img.fd_w ;
  nbpt_y   = fr->img.fd_h ;
  max_iter = fr->maxiter ;
  type     = fr->type ;
  algo     = fr->algorithme ;

  pt   = pre_ligne ;
  pred = (long) (-nbpt_x) ;
  for (i = 0; i < nbpt_y+3; i++)
  {
    pred += (long) nbpt_x ;
    *pt++ = pred ;
  }

  if (config.calc_format == ENTIER)
  {
    init_x = (long) (ftoe*fr->ix) ;
    init_y = (long) (ftoe*fr->iy) ;
    xmin   = (long) (ftoe*fr->xmin) ;
    ymax   = (long) (ftoe*fr->ymax) ;
    ech_x  = (long) (ftoe*fr->largeur/fr->img.fd_w) ;
    ech_y  = (long) (ftoe*fr->hauteur/fr->img.fd_h) ;
    ech2_x = (long) (2*ftoe*fr->largeur/fr->img.fd_w) ;
    ech2_y = (long) (2*ftoe*fr->hauteur/fr->img.fd_h) ;

    precalcul(fr) ;
    rad    = (double)angle*M_PI/1800.0 ;  /* Angle en dixiŠmes de degr‚s */
    cos_a  = (long) (ftoe*cos(rad)) ;
    sin_a  = (long) (ftoe*sin(rad)) ;
    xc     = (long) (ftoe*0.5*(fr->xmin+fr->xmax)) ;
    yc     = (long) (ftoe*0.5*(fr->ymin+fr->ymax)) ;
  }
  else
  {
    FPU_DOUBLE fpu_x ;
    double     x ;
    double     rad ;

    cpu2fpudouble(&fr->ix, &fpu_x) ;
    memcpy(&finit_x, &fpu_x, sizeof(FPU_DOUBLE)) ;

    cpu2fpudouble(&fr->iy, &fpu_x) ;
    memcpy(&finit_y, &fpu_x, sizeof(FPU_DOUBLE)) ;

    cpu2fpudouble(&fr->xmin, &fpu_x) ;
    memcpy(&fxmin, &fpu_x, sizeof(FPU_DOUBLE)) ;

    cpu2fpudouble(&fr->ymax, &fpu_x) ;
    memcpy(&fymax, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = (double)fr->largeur/(double)fr->img.fd_w ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&fech_x, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = (double)fr->hauteur/(double)fr->img.fd_h ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&fech_y, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = (double)fr->largeur/(double)fr->img.fd_w ;
    x = 2.0*x ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&fech2_x, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = (double)fr->hauteur/(double)fr->img.fd_h ;
    x = 2.0*x ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&fech2_y, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = 10000.0 ; /*/fr->largeur ;*/
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&big, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = 1e+25 ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&over, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = 0.20*fr->largeur/(double)fr->img.fd_w ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&delta, &fpu_x, sizeof(FPU_DOUBLE)) ;
    
    rad = (double)angle*M_PI/1800.0 ;
    x   = cos(rad) ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&fcos_a, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = sin(rad) ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&fsin_a, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = (fr->xmin+fr->xmax)/2.0 ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&fxc, &fpu_x, sizeof(FPU_DOUBLE)) ;

    x = (fr->ymin+fr->ymax)/2.0 ;
    cpu2fpudouble(&x, &fpu_x) ;
    memcpy(&fyc, &fpu_x, sizeof(FPU_DOUBLE)) ;
  }
}

void dsp_go(void)
{
  int  to_dsp[2] ;
  long ydsp ;

  with_dsp = 0 ;
  if ((dsp_code_size > 0) && (ability != -1) && (acr_dsp == 1) && (use_dsp == 1) && (config.dsp_on))
  {
    Dsp_ExecProg(dsp_code, dsp_code_size, ability) ;
    init_dsp_data(&frac) ;
    if (dsp_code_size == -1) return ; /* Communication incorrecte */
    curr_ligne += 3 ;
    ccy        -= ech2_y+ech_y ;
    to_dsp[0] = 2 ;          /* Le calcul commence pour le DSP       */
    to_dsp[1] = 1 ;          /* Encore une information … transmettre */
    Dsp_BlkWords((long *) to_dsp, 2, (long *) to_dsp, 0L) ;
    ydsp = ftob24(ftof*(double)ccy/ftoe) ;
    Dsp_BlkUnpacked(&ydsp, 1, &ydsp, 0L) ;
    dsp_line = curr_ligne ;
  }
}

int data_ok(FRACTAL *fr)
{
  if (config.calc_format == ENTIER)
  {
	if (fabs(fr->xmin) > 4.0) return(ERR_ZONE) ;
	if (fabs(fr->xmax) > 4.0) return(ERR_ZONE) ;
	if (fabs(fr->ymin) > 4.0) return(ERR_ZONE) ;
	if (fabs(fr->ymax) > 4.0) return(ERR_ZONE) ;
	if (fabs(fr->ix) > 4.0)   return(ERR_ZONE) ;
	if (fabs(fr->iy) > 4.0)   return(ERR_ZONE) ;

	if (fr->largeur < min_delta*fr->img.fd_w) return(ERR_DELTA) ;
	if (fr->hauteur < min_delta*fr->img.fd_h) return(ERR_DELTA) ;
  }

  if ((fr->algorithme == DEM) && (config.calc_format == ENTIER))
    return (ERR_INCOMP) ;

  return(0) ;
}

void go_multi_calc(void)
{
  if (fpu_type && (config.calc_format == REEL)) fasm_fractal() ;
  else
  {
    asm_fractal() ;
    if ((stat_calc == 0) && with_dsp)
    while (dsp_line < nbpt_y)
    {
      delay(10) ;
      receiver() ;
    }
  }
}
  
int calcul_go(FRACTAL *fr, int w_handle)
{
  ZONE   zone_calc, zone_deduct ;
  double accuracy, wish ;
  long   taille ;
  int    xyarray[8] ;
  int    symetrie ;
  int    flag_img = 1 ;
  int    type_calc ;
  int    w_num = num_wind(w_handle) ;

  type_calc = config.calc_format ;

  if (flag_show)
  {
    if (fpu_type && (config.calc_format == REEL))
    {
      adr_form_calcul[CALC_CPU].ob_state &= ~CHECKED ;
	  adr_form_calcul[CALC_FPU].ob_state |= CHECKED ;
    }
    else
    {
      adr_form_calcul[CALC_CPU].ob_state |= CHECKED ;
	  adr_form_calcul[CALC_FPU].ob_state &= ~CHECKED ;
    }	
    wish     = fr->largeur/(double)fr->img.fd_w ;
    accuracy = pow(2.0, -23.0)/ftof ;
    acr_dsp  = (wish > accuracy) ;
  }
  else
  {
    acr_dsp = 1 ;
    config.calc_format = ENTIER ;
  }

  use_dsp  = 1 ;
  if ((acr_dsp == 1) && (config.dsp_on) && (config.calc_format == ENTIER))
  {
    if (ability != -1)
    {
      do
      {
	    dsp_busy = Dsp_Lock() ;
	    if (dsp_busy && flag_show)
	      use_dsp = form_interrogation(1, msg[MSG_DSPBUSY]) ;
	    else
	    {
	      use_dsp = !dsp_busy ;
	      break ;
	    }
      }
      while (use_dsp == 1) ;
    }

    if (use_dsp == 3) return(-1) ;
    if (!dsp_busy && (config.calc_format == ENTIER))
	  adr_form_calcul[CALC_DSP].ob_state |= CHECKED ;
    else
	  adr_form_calcul[CALC_DSP].ob_state &= ~CHECKED ;

    if (ability == -1) adr_form_calcul[CALC_DSP].ob_state &= ~CHECKED ;
    if (!dsp_busy && (ability != -1) && (use_dsp == 1))
    {
      if (dsp_code_size <= 0)
      {
        form_stop(1, msg[MSG_BINCODE]) ;
        adr_form_calcul[CALC_DSP].ob_state &= ~CHECKED ;
        Dsp_Unlock() ;
        dsp_busy = 0 ;
      }
    }
  }
  else
	adr_form_calcul[CALC_DSP].ob_state &= ~CHECKED ;

  if (flag_show)
  {
    vswr_mode(handle, MD_TRANS) ;
    vsf_interior(handle, FIS_PATTERN) ;
    vsf_style(handle, 4) ;
    vsf_color(handle, 1) ;
    graf_mouse(BUSYBEE, 0L) ;
    draw_dialog(adr_form_calcul, titre) ;
    objc_offset(adr_form_calcul, CALCUL_TEXT, &off_x, &off_y) ;
    wobj = adr_form_calcul[CALCUL_TEXT].ob_width-2 ;
    hobj = adr_form_calcul[CALCUL_TEXT].ob_height-1 ;
  }

  if (fr->algorithme == DEM)
  {
    taille  = 2*sizeof(FPU_DOUBLE)*(size_t)(2+fr->maxiter) ;
    xyorbit = malloc(taille) ;
    if (xyorbit == NULL)
    {
      if (flag_show) hide_dialog() ;
      graf_mouse(ARROW, 0L) ;
      form_error(8) ;
      Dsp_Unlock() ;
      return(-1) ;
    }
  }
  else
    xyorbit = NULL ;

  angle    = 0 ;
  symetrie = symetrie_possible(fr) ;
  switch(symetrie)
  {
	case SYM_AXE : memcpy(&frac, fr, sizeof(FRACTAL)) ;
				   get_fractal_zones(&frac, &zone_calc, &zone_deduct) ;
				   taille   = (long)frac.img.fd_w*(long)(3+frac.img.fd_h) ;
				   adr_data = (unsigned char *) malloc(taille) ;
				   if (adr_data == NULL)
				   {
					 if (flag_show) hide_dialog() ;
					 graf_mouse(ARROW, 0L) ;
					 form_error(8) ;
					 Dsp_Unlock() ;
                     if (xyorbit != NULL)
                     {
                       free(xyorbit) ;
                       xyorbit = NULL ;
                     }
                     config.calc_format = type_calc ;
					 return(-1) ;
				   }
				   init_asm_data(&frac) ;
				   start_time = clock() ;
				   go_multi_calc() ;
				   end_time = clock() ;
				   if (flag_show)
				   {
				     get_report(&frac) ;
				     memcpy(&fr->report, &frac.report, sizeof(FRACTAL_REPORT)) ;
				     if (stat_calc == 1)
					   flag_img = form_stop(1, msg[MSG_CALCCANCEL]) ;
				   }
				   break ;
	default      : taille   = (long)fr->img.fd_w*(long)fr->img.fd_h ;
				   adr_data = (unsigned char *) malloc(taille) ;
				   if (adr_data == NULL)
				   {
					 if (flag_show) hide_dialog() ;
					 graf_mouse(ARROW, 0L) ;
					 form_error(8) ;
					 Dsp_Unlock() ;
                     if (xyorbit != NULL)
                     {
                       free(xyorbit) ;
                       xyorbit = NULL ;
                     }
                     config.calc_format = type_calc ;
					 return(-1) ;
				   }
                   memcpy(&frac, fr, sizeof(FRACTAL)) ;
				   init_asm_data(&frac) ;
				   start_time = clock() ;
				   go_multi_calc() ;
				   end_time = clock() ;
				   get_report(fr) ;
				   zone_calc.xi = 0 ;  zone_calc.yi = 0 ;
				   zone_calc.w  = fr->img.fd_w ; zone_calc.h  = fr->img.fd_h ;
				   if (flag_show && (stat_calc == 1))
				     flag_img = form_stop(1, msg[MSG_CALCCANCEL]) ;
				   break ;
  }

  if (!dsp_busy && (ability != -1) && config.dsp_on && (acr_dsp == 1) && (dsp_code_size > 0))
    Dsp_Unlock() ;

  if (xyorbit != NULL)
  {
    free(xyorbit) ;
    xyorbit = NULL ;
  }

  if (flag_img == 1)
  {
	img_raz(&fr->img) ;
	orbite_to_raster(fr, &zone_calc, w_handle) ;
    free(adr_data) ;
    if (UseStdVDI)
    {
      MFDB std_img ;

      memcpy(&std_img, &fr->img, sizeof(MFDB)) ;
      std_img.fd_addr = img_alloc(std_img.fd_w, std_img.fd_h, std_img.fd_nplanes) ;
      if (std_img.fd_addr == NULL)
      {
		 if (flag_show) hide_dialog() ;
		 graf_mouse(ARROW, 0L) ;
		 form_error(8) ;
		 return(-1) ;
      }
      std_img.fd_stand = 1 ;
      ClassicAtari2StdVDI(&fr->img, &std_img) ;
      vr_trnfm(handle, &std_img, &fr->img) ;
      free(std_img.fd_addr) ;
    }
	if (symetrie == SYM_AXE)
	{
	  if (zone_calc.yi == 0)
	  {
	    xyarray[1] = zone_deduct.yi-zone_deduct.h ;
	    xyarray[3] = zone_deduct.yi-1 ;
	    xyarray[5] = zone_deduct.yi ;
	    xyarray[7] = fr->img.fd_h-1 ;
	  }
	  else
	  {
	    xyarray[1] = zone_calc.yi ;
	    xyarray[3] = zone_calc.yi+zone_deduct.h-1 ;
	    xyarray[5] = zone_deduct.yi ;
	    xyarray[7] = zone_deduct.yi+zone_deduct.h-1 ;
	  }
	  xyarray[0] = zone_calc.xi ;
	  xyarray[2] = xyarray[0]+zone_calc.w-1 ;
	  xyarray[4] = zone_deduct.xi ;
	  xyarray[6] = xyarray[4]+zone_deduct.w-1 ;

	  raster_symvrt(handle, xyarray, &fr->img, &fr->img) ;
	}
  }
  else free(adr_data) ;

  if (flag_show) hide_dialog() ;

  if (flag_show && (w_handle != -1))
  {
    if (window_icon[w_num].fd_addr != NULL)
    {
      free(window_icon[w_num].fd_addr) ;
      window_icon[w_num].fd_addr = NULL ;
      if (is_iconified(w_num)) iconify_picture(w_num) ;
    }
    img_fractal_update(w_handle) ;
    graf_mouse(ARROW, 0L) ;
  }

  config.calc_format = type_calc ;
  return(stat_calc) ;
}
