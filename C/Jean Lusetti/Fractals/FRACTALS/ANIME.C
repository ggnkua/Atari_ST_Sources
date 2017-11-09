/*********************************************/
/*--------------- ANIME.C -------------------*/
/* Module d'animation du Project FRACTAL.PRJ */
/*********************************************/
#include     <math.h>
#include   <stdlib.h>
#include   <string.h>

#include     "..\tools\xgem.h"
#include     "..\tools\xdsp.h"
#include   "..\tools\xstdio.h"
#include  "..\tools\fpu_cpu.h"
#include "..\tools\rasterop.h"
#include   "..\tools\gif_io.h"

#include     "defs.h"
#include   "gstevn.h"
#include   "calcul.h"
#include  "fractal.h"
#include "compress.h"
#include "calc_asm.h"
#include "fract_io.h"
#include "clgstevn.h"


#define CLAVIER   2                 /* Paramätre pour Bconstat()          */


STATUS_ANIMATION  stat_anim ;       /* Paramätres de l'animation          */
ANIMATION_FRACTAL info_sequence ;   /* DonnÇes sur la sÇquence en mÇmoire */
ANIMATION_FRACTAL ani_calc ;        /* SÇquence Ö calculer                */
OBJECT            *adr_form_canim ; /* Formulaire de calcul de sÇquence   */
MFDB              virtuel ;         /* Pour les update window             */
size_t            *size_compress ;  /* Idem mais pour la visualisation    */
int               w_ani_handle ;    /* Handle de la fenàtre animation     */
int               flag_ani ;        /* Pour affiche_progression_calcul()  */
int               nb_images ;       /* Nombre d'images en mÇmoire         */
int               posx, posy ;      /* Infos fenàtre animation            */
void              *ecr1          ;  /* Pour Çviter le scintellement, on   */
void              *ecr2          ;  /* Utilise la technique des 2 Çcrans. */
char              name_ani[100] ;   /* Nom du fichier animation           */
size_t            **tab_adr_img ;   /* Pointeur sur tableau des adresses  */


void init_module_anime(void)
{
  stat_anim.debut  = -1 ;
  stat_anim.fin    = -1 ;
  stat_anim.source =  MEMOIRE ;
  stat_anim.nb_vbl =  1 ;
  stat_anim.type   =  BOUCLE ;
  stat_anim.ecr2   =  0 ;

  flag_ani = 0 ;
  
  ani_calc.nb_image = 0 ;
  ani_calc.stopped  = 0 ;
  
  virtuel.fd_addr = NULL ;

  *name_ani     = 0 ;
  w_ani_handle  = -2 ;
  size_compress = NULL ;
  tab_adr_img   = NULL ;

  Xrsrc_gaddr(R_TREE, FORM_CANIM, &adr_form_canim) ;
}

void libere_sequence(void)
{
  int i ;

  if (tab_adr_img == NULL) return ;

  for (i = nb_images-1; i >= 0; i--)
    if (tab_adr_img[i] != NULL)
    {
      free(tab_adr_img[i]) ;
      tab_adr_img[i] = NULL ;
    }

  tab_adr_img = NULL ;
}

void quitte_module_anime()
{
  libere_sequence() ;
  if (virtuel.fd_addr != NULL) free(virtuel.fd_addr) ;
  if (size_compress != NULL) free(size_compress) ;
}

int charge_animation(char *name)
{
  ANIMATION_FRACTAL info_seq ;
  OBJECT            *adr_prog ;
  OBJECT            *adr_inf ;
  FILE              *stream ;
  double            ratio ;
  long              nb_lus ;
  long              size_img ;
  int               xyarray[4] ;
  int               nb_img ;
  int               n_window ;
  int               x, y, w, h ;
  int               ww, wh ;
  char              *tmp_compress ;
  char              fini = 0 ;

  Xrsrc_gaddr(R_TREE, FORM_PARANIM, &adr_inf) ;
  Xrsrc_gaddr(R_TREE, FORM_PROG, &adr_prog) ;

  stream = fopen(name, "rb") ;
  if (stream == NULL) return(1) ;

  strcpy(name_ani, name) ;
  if (*name)
  {
    fseek(stream, -sizeof(ANIMATION_FRACTAL), SEEK_END) ;
	fread(&info_seq, sizeof(ANIMATION_FRACTAL), 1, stream) ;
	memcpy(&info_sequence, &info_seq, sizeof(ANIMATION_FRACTAL)) ;
  }
  if (info_seq.fr_start.img.fd_nplanes != nb_plane)
  {
    fclose(stream) ;
	return(2) ;
  }

  if (virtuel.fd_addr != NULL)
  {
    int ret ;
    int new_handle ;

    ret = form_interrogation(2, msg[MSG_ANIISPRESENT]) ;
    if (ret == 2)
    {
      fclose(stream) ;
      return(3) ;
    }
    
    libere_sequence() ;
    free(virtuel.fd_addr) ;
    virtuel.fd_addr = NULL ;
	new_handle = close_window(w_ani_handle) ;
	num_window = num_wind(new_handle) ;
  }

  n_window = num_new_window() ;
  if (n_window == -1) return(-1) ;

  size_img = img_size(info_seq.fr_start.img.fd_w,
					  info_seq.fr_start.img.fd_h, nb_plane) ;

  virtuel.fd_addr = malloc(size_img) ;
  if (virtuel.fd_addr == NULL)
  {
    fclose(stream) ;
    return(-1) ;
  }

  rewind(stream) ;
  fread(virtuel.fd_addr, size_img, 1, stream) ;
  virtuel.fd_w       = info_seq.fr_start.img.fd_w ;
  virtuel.fd_h       = info_seq.fr_start.img.fd_h ;
  virtuel.fd_nplanes = info_seq.fr_start.img.fd_nplanes ;
  virtuel.fd_wdwidth = info_seq.fr_start.img.fd_w/16 ;
  virtuel.fd_stand   = 0 ;

  open_where(W_ALL, virtuel.fd_w, virtuel.fd_h, &x, &y, &w, &h) ;
  window_handle[n_window] = open_fwindow(W_ALL, x, y, w, h) ;
  if (window_handle[n_window] < 0) return(-1) ;

  w_ani_handle              = window_handle[n_window] ;
  num_window                = n_window ;
  window_opened[num_window] = 1 ;
  strcpy(window_name[num_window], " ANIMATION ") ;
  wind_set(window_handle[num_window], WF_NAME, window_name[num_window]) ;
  sprintf(window_info[num_window], msg[MSG_ANIINF],
  		  info_seq.nb_image, info_seq.fr_start.img.fd_w, info_seq.fr_start.img.fd_h, nb_colors) ;
  wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
  winfo[n_window].x1 = winfo[n_window].y1 = 0 ;
  winfo[n_window].x2 = w-1 ;
  winfo[n_window].y2 = y-1 ;
  ww = (int) (1000.0*(double)w/(double)info_seq.fr_start.img.fd_w) ;
  wh = (int) (1000.0*(double)h/(double)info_seq.fr_start.img.fd_h) ;
  wind_set(window_handle[n_window], WF_HSLIDE, 1) ;
  wind_set(window_handle[n_window], WF_VSLIDE, 1) ;
  wind_set(window_handle[n_window], WF_HSLSIZE, ww) ;
  wind_set(window_handle[n_window], WF_VSLSIZE, wh) ;

  if (*info_seq.pack)
  {
    long to_be_reserved ;

    to_be_reserved = info_seq.nb_image*sizeof(size_t) ;
    size_compress  = (size_t *) malloc(to_be_reserved) ;
    if (size_compress == NULL)
    {
      form_error(8) ;
      fclose(stream) ;
      return(5) ;
    }

    fseek(stream, -sizeof(ANIMATION_FRACTAL)-(info_seq.nb_image-1)*sizeof(long), SEEK_END) ;   
    fread(size_compress, to_be_reserved, 1, stream) ;
  }

  if (stat_anim.source == MEMOIRE)
  {
    tab_adr_img = (size_t **) malloc((info_seq.nb_image+1)*sizeof(size_t)) ;
    if (tab_adr_img == NULL)
    {
      free(size_compress) ;
      form_error(8) ;
      fclose(stream) ;
      return(5) ;
    }

    graf_mouse(BUSYBEE, 0L) ;
    tab_adr_img[0]  = (size_t *) malloc(size_img) ;
    if (tab_adr_img[0] == NULL)
    {
      free(tab_adr_img) ;
      tab_adr_img = NULL ;
      free(size_compress) ;
      form_error(8) ;
      fclose(stream) ;
      return(5) ;
    }
    rewind(stream) ;
    fread(tab_adr_img[0], size_img, 1, stream) ;
  }
  else 
  {
    fclose(stream) ;
    memcpy(&info_sequence, &info_seq, sizeof(ANIMATION_FRACTAL)) ;
    tab_adr_img = NULL ;
    return(0) ;
  }

  nb_img  = 1 ;
  if (*info_seq.pack && !selected(adr_inf, PARANIM_TR))
  {
    size_t max ;
    int    i ;
    
    max = 0 ;
    for (i = 0; i < info_seq.nb_image-1; i++)
      if (size_compress[i] > max) max = size_compress[i] ;
      
    tmp_compress = (char *) malloc(max) ;
    if (tmp_compress == NULL)
    {
      form_error(8) ;
      fclose(stream) ;
      free(size_compress) ;
      size_compress = NULL ;
      free(tab_adr_img) ;
      tab_adr_img = NULL ;
      return(-2) ;
    }
  }
  else tmp_compress = NULL ;

  vsf_interior(handle, FIS_PATTERN) ; /* Remplissage avec motif */
  vsf_style(handle, 4) ;
  vsf_color(handle, 1) ;

  write_text(adr_prog, PROG_TITRE, msg[MSG_LOADINGANI]) ;
  draw_dialog(adr_prog, titre) ;
  objc_offset(adr_prog, PROG_PC, &off_x, &off_y) ;
  while (!fini)
  {
	ratio = (double) (adr_prog[PROG_PC].ob_width)*((double)nb_img/(double)info_seq.nb_image) ;
	xyarray[0] = off_x ;
	xyarray[1] = off_y ;
	xyarray[2] = off_x + (int) ratio ;
	xyarray[3] = off_y + adr_prog[PROG_PC].ob_height-1 ;
	vr_recfl(handle, xyarray) ;
    if (*info_seq.pack && selected(adr_inf, PARANIM_TR))
        tab_adr_img[nb_img] = (size_t *) malloc(size_compress[nb_img-1]) ;
      else
        tab_adr_img[nb_img] = malloc(size_img) ;

    if (tab_adr_img[nb_img] == NULL) fini = 1 ;
    else
    {
      if (*info_seq.pack == 0)
        nb_lus = fread(tab_adr_img[nb_img], size_img, 1, stream) ;
      else
      {
        if (!selected(adr_inf, PARANIM_TR))
        {
          nb_lus = fread(tmp_compress, size_compress[nb_img-1], 1, stream) ;
          decompress((char *)tab_adr_img[nb_img-1], tmp_compress, size_img, (char *)tab_adr_img[nb_img]) ;
        }
        else
          nb_lus = fread(tab_adr_img[nb_img], size_compress[nb_img-1], 1, stream) ;
      }
      
      if (nb_lus != 1)
      {
        fini = 1 ;
        free(tab_adr_img[nb_img]) ;
      }
      else nb_img++ ;
    }

	if (nb_img == info_seq.nb_image) fini = 1 ;
  }

  nb_images = nb_img ;
  hide_dialog() ;
  
  if (nb_img != info_seq.nb_image)
  {
    double pc ;
    char   buf[100] ;
    
    pc = 100.0*(double)nb_img/(double)info_seq.nb_image ;
    memset(buf, 0, 100) ;
    sprintf(buf, msg[MSG_ANILOADED], nb_img, pc) ;
    strcat(buf, "%.][OK]") ;
    form_alert(1, buf) ;
  }

  if (tmp_compress != NULL) free(tmp_compress) ;
  fclose(stream) ;
  graf_mouse(POINT_HAND, 0L) ;
  memcpy(&info_sequence, &info_seq, sizeof(ANIMATION_FRACTAL)) ;
  
  return(0) ;
}

int create_animation(ANIMATION_FRACTAL *data)
{
  FRACTAL *start ;
  FRACTAL *end ;
  OBJECT  *adr_seq ;
  char    buf[50] ;
  int     valid ;

  memcpy(&ani_calc.fr_start, &fractal[stat_anim.debut], sizeof(FRACTAL)) ;
  memcpy(&ani_calc.fr_end, &fractal[stat_anim.fin], sizeof(FRACTAL)) ;
  start = &data->fr_start ;
  end   = &data->fr_end ;
  Xrsrc_gaddr(R_TREE, FORM_SEQUENCE, &adr_seq) ;

  sprintf(buf, "%+.8f", start->hauteur) ;
  write_text(adr_seq, SEQD_H, buf) ;
  sprintf(buf, "%+.8f,%+.8f", start->centre_x, start->centre_y) ;
  write_text(adr_seq, SEQD_C, buf) ;
  sprintf(buf, "%+.8f,%+.8f", start->ix, start->iy) ;
  write_text(adr_seq, SEQD_I, buf) ;

  sprintf(buf, "%+.8f", end->hauteur) ;
  write_text(adr_seq, SEQF_H, buf) ;
  sprintf(buf, "%+.8f,%+.8f", end->centre_x, end->centre_y) ;
  write_text(adr_seq, SEQF_C, buf) ;
  sprintf(buf, "%+.8f,%+.8f", end->ix, end->iy) ;
  write_text(adr_seq, SEQF_I, buf) ;

  if (start->type == JULIA) write_text(adr_seq, SEQ_TYPE, "JULIA") ;
  else                      write_text(adr_seq, SEQ_TYPE, "MANDELBROT") ;

  switch(start->algorithme)
  {
	case LSM : write_text(adr_seq, SEQ_ALGO, "MPN") ;
			   break ;
	case DEM : write_text(adr_seq, SEQ_ALGO, "MED") ;
			   break ;
	case CPM : write_text(adr_seq, SEQ_ALGO, "MPC") ;
			   break ;
  }

  if (ani_calc.nb_image == 0) ani_calc.nb_image = 10 ;
  sprintf(buf, "%.4d", ani_calc.nb_image) ;
  write_text(adr_seq, SEQ_NBIMG, buf) ;
  
  sprintf(buf, "%.4d", start->maxiter) ;
  write_text(adr_seq, SEQ_DMAX, buf) ;
  sprintf(buf, "%.4d", end->maxiter) ;
  write_text(adr_seq, SEQ_FMAX, buf) ;

  if (nb_colors == 2)
  {
    adr_seq[SEQ_ISOL].ob_state  &= ~DISABLED ;
    adr_seq[SEQ_TISOL].ob_state &= ~DISABLED ;
  }
  else
  {
    adr_seq[SEQ_ISOL].ob_state  |= DISABLED ;
    adr_seq[SEQ_TISOL].ob_state |= DISABLED ;
  }
    
  fshow_dialog(adr_seq, titre) ;
  valid = xform_do(SEQ_NAME, window_update) ;
  deselect(adr_seq, valid) ;
  fhide_dialog() ;

  if (valid == SEQ_OK)
  {
	read_text(adr_seq, SEQ_NBIMG, buf) ;
	ani_calc.nb_image = atoi(buf) ;
	read_text(adr_seq, SEQ_NAME, buf) ;
	strncpy(ani_calc.title, buf, 8) ;
	ani_calc.title[8] = '.' ;
	strcpy(&ani_calc.title[9], &buf[8]) ;
	read_text(adr_seq, SEQ_ROTATION, buf) ;
	ani_calc.rotation = atoi(buf) ;
	if (selected(adr_seq, SEQ_INVROT)) ani_calc.rotation = -ani_calc.rotation ;
	if (selected(adr_seq, SEQ_PACK)) *ani_calc.pack = 1 ;
	return(1) ;
  }

  return(0) ;
}

void ajour_fenetre_ani(MFDB *data)
{
  int xyarray[8] ;
  int cxy[4] ;
  int xi, yi, wx, wy ;
  int rx, ry, rw, rh ;

  cxy[0] = xdesk ; cxy[1] = ydesk ;
  cxy[2] = Xmax ;  cxy[3] = Ymax ;
  vs_clip(handle, 1, cxy) ;

  wind_get(w_ani_handle, WF_WORKXYWH, &xi, &yi, &wx, &wy) ;
  wind_get(w_ani_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh) ;

  while (rw != 0)
  {
    if (intersect(xdesk, ydesk, wdesk, hdesk, rx, ry, rw, rh, &xyarray[4]))
    {
      xyarray[0] = xyarray[4]-xi ; xyarray[1] = xyarray[5]-yi ;
      xyarray[2] = xyarray[6]-xi ; xyarray[3] = xyarray[7]-yi ;
      xyarray[0] += posx ; xyarray[1] += posy ;
	  xyarray[2] += posx ; xyarray[3] += posy ;
      vro_cpyfm(handle, S_ONLY, xyarray, data, &screen) ;
    }
    wind_get(w_ani_handle, WF_NEXTXYWH, &rx, &ry, &rw, &rh) ;
  }

  vs_clip(handle, 0, cxy) ;
}

void animate_from_memory(void)
{
  OBJECT *adr_inf ;
  long   taille_img ;
  int    xyarray[8] ;
  int    x, y, w, h ;
  int    wait ;
  int    sens = 1 ;
  int    real_time ;
  int    num_img ;
  char   *ecran_physique ;

  Xrsrc_gaddr(R_TREE, FORM_PARANIM, &adr_inf) ;
  real_time = *info_sequence.pack && selected(adr_inf, PARANIM_TR) ;
  
  wind_get(w_ani_handle, WF_WORKXYWH, &x, &y, &w, &h) ;
  xyarray[0]     = 0   ;   xyarray[1] = 0 ;
  xyarray[2]     = w-1 ;   xyarray[3] = h-1 ;
  xyarray[4]     = x ;     xyarray[5] = y ;
  xyarray[6]     = x+w-1 ; xyarray[7] = y+h-1 ;
  xyarray[0] += posx ; xyarray[1] += posy ;
  xyarray[2] += posx ; xyarray[3] += posy ;
  if (xyarray[6] > Xmax)
  {
    xyarray[6] = Xmax ;
    xyarray[2] = xyarray[6]-xyarray[4] ;
  }
  if (xyarray[7] > Ymax)
  {
    xyarray[7] = Ymax ;
    xyarray[3] = xyarray[7]-xyarray[5] ;
  }

  ecran_physique = (void *) Physbase() ;
  taille_img     = img_size(virtuel.fd_w, virtuel.fd_h, nb_plane) ;
  num_img        = 0 ;
  do
  {
    if ((num_img == -1) || (num_img == nb_images))
    {
      if (real_time || selected(adr_inf, PARANIM_BCL))
      {
        sens    = 1 ;
        num_img = 0 ;
      }
      else
      {
        if (selected(adr_inf, PARANIM_PP))
        {
          sens = 1-sens ;
          if (sens == 1) num_img = 0 ;
          else           num_img = nb_images-1 ;
        }
        else
        {
          sens    = 1 ;
          num_img = 0 ;
        }
      }
    }

    if (real_time)
    {
      if (num_img != 0)
        decompress(virtuel.fd_addr, (char *)tab_adr_img[num_img], taille_img, virtuel.fd_addr) ;
      else
        memcpy(virtuel.fd_addr, tab_adr_img[0], taille_img) ;
    }
    else   
      virtuel.fd_addr = tab_adr_img[num_img] ;

    if (Multitos) ajour_fenetre_ani(&virtuel) ;
    else          vro_cpyfm(handle, S_ONLY, xyarray, &virtuel, &screen) ;

    if (stat_anim.ecr2)
    {
      if (ecran_physique == ecr1)
      {
        Setscreen(ecr1, ecr2, -1) ;
        ecran_physique = ecr2 ;
      }
      else
      {
        Setscreen(ecr2, ecr1, -1) ;
        ecran_physique = ecr1 ;
      }
    }

    if (sens == 1) num_img++ ;
    else           num_img-- ;    

    for (wait = 0; wait < stat_anim.nb_vbl; wait++) Vsync() ;
  }
  while (Bconstat(CLAVIER) == 0) ;
}

void animate_from_disk(void)
{
  long taille_img ;
  long a_lire ;
  long abs_pos ;
  long last_img ;
  int  handle_fic ;
  int  xyarray[8] ;
  int  x, y, w, h ;
  int  wait ;
  int  sens = 1 ;
  int  real_time ;
  int  num_img ;
  void *ecran_physique ;
  void *where ;
  char *rt_buf ;

  wind_get(w_ani_handle, WF_WORKXYWH, &x, &y, &w, &h) ;
  xyarray[0]     = 0   ;   xyarray[1] = 0 ;
  xyarray[2]     = w-1 ;   xyarray[3] = h-1 ;
  xyarray[4]     = x ;     xyarray[5] = y ;
  xyarray[6]     = x+w-1 ; xyarray[7] = y+h-1 ;
  xyarray[0] += posx ; xyarray[1] += posy ;
  xyarray[2] += posx ; xyarray[3] += posy ;
  if (xyarray[6] > Xmax)
  {
    xyarray[6] = Xmax ;
    xyarray[2] = xyarray[6]-xyarray[4] ;
  }
  if (xyarray[7] > Ymax)
  {
    xyarray[7] = Ymax ;
    xyarray[3] = xyarray[7]-xyarray[5] ;
  }

  taille_img = img_size(virtuel.fd_w, virtuel.fd_h, nb_plane) ;
  real_time  = *info_sequence.pack ;
  if (real_time)
  {
    size_t max ;
    int    i ;
    
    max = 0 ;
    for (i = 0; i < info_sequence.nb_image-1; i++)
      if (size_compress[i] > max) max = size_compress[i] ;
      
    rt_buf = (char *) malloc(max) ;
    if (rt_buf == NULL)
    {
      form_error(8) ;
      return ;
    }
    
    last_img = -size_compress[info_sequence.nb_image-2]-sizeof(long)*(info_sequence.nb_image-1)-sizeof(ANIMATION_FRACTAL) ;
  }
  else last_img = -taille_img-sizeof(ANIMATION_FRACTAL) ;
  
  handle_fic = (int) Fopen(name_ani, FO_READ) ;
  if (handle_fic < 0)
  {
    form_interrogation(1, msg[MSG_FILENOTEXIST]) ;
    return ;
  }

  ecran_physique = (void *) Physbase() ;
  num_img        = -1 ;
  do
  {
    if (real_time)
    {
      if (num_img == -1)
      {
        a_lire = taille_img ;
        where  = virtuel.fd_addr ;
      }
      else
      {
        a_lire = size_compress[num_img] ;
        where  = (void *) rt_buf ;
      }
    }
    else
    {
      a_lire = taille_img ;
      where  = virtuel.fd_addr ;
    }
    
    Fread(handle_fic, a_lire, where) ;
    
    if (real_time && (num_img != -1))
      decompress(virtuel.fd_addr, where, taille_img, virtuel.fd_addr) ;

    if (Multitos) ajour_fenetre_ani(&virtuel) ;
    else          vro_cpyfm(handle, S_ONLY, xyarray, &virtuel, &screen) ;

    if (sens == 0)
    {
      abs_pos = Fseek(-taille_img<<1, handle_fic, 1) ;
      num_img-- ;
      if (abs_pos == 0)
      {
        sens    = 1 ;
        num_img = -1 ;
      }
    }
    else num_img++ ;
    
    if ((num_img == info_sequence.nb_image-1) && (sens == 1))
    {
      if (!real_time)
      {
        if (stat_anim.type == BOUCLE)
        {
          Fseek(0, handle_fic, 0) ;
          num_img = -1 ;
        }
        else
        {
          sens = 1-sens ;
          if (sens == 1)
          {
            Fseek(0, handle_fic, 0) ;
            num_img = -1 ;
          }
          else
          {
            Fseek(last_img, handle_fic, 2) ;
            num_img = info_sequence.nb_image-1 ;
          }
        }
      }
      else
      {
        Fseek(0, handle_fic, 0) ;
        num_img = -1 ;        
      }
    }

    if ((num_img == -1) && (sens == 0))
    {
      if (stat_anim.type == BOUCLE)
      {
        Fseek(last_img, handle_fic, 2) ;
        num_img = -1 ;
      }
      else
      {
        sens = 1-sens ;
        if (sens == 1)
        {
          Fseek(0, handle_fic, 0) ;
          num_img = -1 ;
        }
        else
        {
          Fseek(last_img, handle_fic, 2) ;
          num_img = info_sequence.nb_image-1 ;
        }
      }
    }

    if (stat_anim.ecr2)
    {
      if (ecran_physique == ecr1)
      {
        Setscreen(ecr1, ecr2, -1) ;
        ecran_physique = ecr2 ;
      }
      else
      {
        Setscreen(ecr2, ecr1, -1) ;
        ecran_physique = ecr1 ;
      }
    }

    for (wait = 0; wait < stat_anim.nb_vbl; wait++) Vsync() ;
  }
  while (Bconstat(CLAVIER) == 0) ;

  if (real_time) free(rt_buf) ;

  Fclose(handle) ;
}

int animate(void)
{
  long taille_ecran ;
  int  x, y, w, h ;
  void *old_phys_base ;
  void *nouveau_ecran ;
  void *adr_img_ani ;

  wind_get(w_ani_handle, WF_WORKXYWH, &x, &y ,&w, &h) ;
  
  if (stat_anim.ecr2 == 1)
  {
    taille_ecran  = img_size(1+Xmax, 1+Ymax, nb_plane) ;
    nouveau_ecran = malloc(taille_ecran) ;
    if (nouveau_ecran == NULL)
    {
      form_stop(1, msg[MSG_ERRSCREEN]) ;
      return(-2) ;
    }
  }
  else nouveau_ecran = Physbase() ;
  old_phys_base = (void *) Physbase() ;
  ecr1 = old_phys_base ;
  ecr2 = nouveau_ecran ;
  memcpy(ecr2, old_phys_base, taille_ecran) ;
  Setscreen(ecr1, ecr2, -1) ;
  adr_img_ani = virtuel.fd_addr ;
  wind_get(w_ani_handle, WF_HSLIDE, &posx) ;
  wind_get(w_ani_handle, WF_VSLIDE, &posy) ;
  posx = (int) (0.5+(double)posx/1000.0*(double)(virtuel.fd_w-w)) ;
  posy = (int) (0.5+(double)posy/1000.0*(double)(virtuel.fd_h-h)) ;

  if (stat_anim.source == MEMOIRE) animate_from_memory() ;
  else                             animate_from_disk() ;

  Setscreen(old_phys_base, old_phys_base, -1) ;
  if (stat_anim.ecr2 == 1) free(nouveau_ecran) ;
  virtuel.fd_addr = adr_img_ani ;
  ajour_fenetre_ani(&virtuel) ;
  return(0) ;
}

int ok_animate_parameters(FRACTAL *fs, FRACTAL *fe)
{
  switch(data_ok(fs))
  {
    case ERR_DELTA : form_stop(1, msg[MSG_ANIDLTERR1]) ;
                     return(0) ;
    case ERR_ZONE  : form_stop(1, msg[MSG_ANIACRERR1]) ;
                     return(0) ;
  }

  switch(data_ok(fe))
  {
    case ERR_DELTA : form_stop(1, msg[MSG_ANIDLTERR2]) ;
                     return(0) ;
    case ERR_ZONE  : form_stop(1, msg[MSG_ANIACRERR2]) ;
                     return(0) ;
  }

  if (fs->type != fe->type)
  {
    form_stop(1, msg[MSG_ANINOTSAMET]) ;
    return(0) ;
  }

  if (fs->algorithme != fe->algorithme)
  {
    form_stop(1, msg[MSG_ANISAMEA]) ;
    return(0) ;
  }

  if (fs->img.fd_w != fe->img.fd_w)
  {
    form_stop(1, msg[MSG_ANISAMEW]) ;
    return(0) ;
  }

  if (fs->img.fd_h != fe->img.fd_h)
  {
    form_stop(1, msg[MSG_ANISAMEH]) ;
    return(0) ;
  }

  if (memcmp(&fs->maxiter, &fe->maxiter, sizeof(int)+10*sizeof(double)) == 0)
  {
	form_stop(1, msg[MSG_ANISAME]) ;
	return(0) ;
  }

  return(1) ;
}

void remove_isol_pts(MFDB *data)
{
  unsigned char *pt ;
  int           x, y ;
  
  if (nb_colors != 2) return ;
  pt = (unsigned char *) data->fd_addr ;
  for (y = 0; y < data->fd_h; y++)
    for (x = 0; x < data->fd_w; x += 8)
    {
      if (*pt)
      {
        if ((*pt == 0x80) || (*pt == 0x40) || (*pt == 0x20) || (*pt == 0x10) ||
            (*pt == 0x08) || (*pt == 0x04) || (*pt == 0x02)) *pt = 0 ;
      }
      pt++ ;
    }
}

int calcule_animation(void)
{
  MFDB    std_img ;
  FRACTAL fr, fr1 ;
  OBJECT  *form_seq ;
  EVENT   saved ;
  ZONE    zone_calc, zone_deduct ;
  FILE    *stream ;
  double  h_reduc, xc_reduc, yc_reduc, ix_reduc, iy_reduc, iter_reduc ;
  double  ratio ;
  double  oratio ;
  double  fnum_img ;
  double  accuracy, wish ;
  size_t  *info_taille ;
  size_t  tcompress ;       
  long    size_img ;
  long    taille ;
  long    nbl_cpu, nbl_fpu, nbl_dsp, nbl_total ;
  int     palette[256*6] ;
  int     xyarray[8] ;
  int     xi, yi ;
  int     wx ,wy ;
  int     which ;
  int     num_img ;
  int     off_x1, off_y1 ;
  int     dsp_busy ;
  int     r = 1 ;
  int     ret = 0 ;
  int     symetrie ;
  char    name[200] ;
  char    buf[40] ;
  void    *last_img ;
      
  memcpy(&saved, &event, sizeof(EVENT)) ;

  strcpy(name, config.path_ani) ;
  strcat(name, ani_calc.title) ;
  if (file_exist(name))
  {
	r = form_stop(2, msg[MSG_FILEEXISTS]) ;
	if (r == 2)	return(-1) ;
  }

  stream = fopen(name, "wb+") ;
  if (stream == NULL)
  {
    form_stop(1, msg[MSG_WRITEERROR]) ;
    return(-1) ;
  }

  Xrsrc_gaddr(R_TREE, FORM_SEQUENCE, &form_seq) ;
  if (selected(form_seq, SEQ_CENTRE))
  {
    if (ani_calc.fr_end.hauteur < ani_calc.fr_start.hauteur)
    {
      ani_calc.fr_start.centre_x = ani_calc.fr_end.centre_x ;
      ani_calc.fr_start.centre_y = ani_calc.fr_end.centre_y ;
      ani_calc.fr_start.xmin     = ani_calc.fr_start.centre_x-ani_calc.fr_start.largeur/2 ;
      ani_calc.fr_start.xmax     = ani_calc.fr_start.centre_x+ani_calc.fr_start.largeur/2 ;
      ani_calc.fr_start.ymin     = ani_calc.fr_start.centre_y-ani_calc.fr_start.hauteur/2 ;
      ani_calc.fr_start.ymax     = ani_calc.fr_start.centre_y+ani_calc.fr_start.hauteur/2 ;
    }
    else
    {
      ani_calc.fr_end.centre_x = ani_calc.fr_start.centre_x ;
      ani_calc.fr_end.centre_y = ani_calc.fr_start.centre_y ;
      ani_calc.fr_end.xmin     = ani_calc.fr_end.centre_x-ani_calc.fr_end.largeur/2 ;
      ani_calc.fr_end.xmax     = ani_calc.fr_end.centre_x+ani_calc.fr_end.largeur/2 ;
      ani_calc.fr_end.ymin     = ani_calc.fr_end.centre_y-ani_calc.fr_end.hauteur/2 ;
      ani_calc.fr_end.ymax     = ani_calc.fr_end.centre_y+ani_calc.fr_end.hauteur/2 ;
    }
  }
  
  h_reduc    = pow(ani_calc.fr_end.hauteur/ani_calc.fr_start.hauteur, 1.0/(double) (ani_calc.nb_image-1)) ;
  xc_reduc   = (ani_calc.fr_end.centre_x-ani_calc.fr_start.centre_x)/(double) (ani_calc.nb_image-1) ;
  yc_reduc   = (ani_calc.fr_end.centre_y-ani_calc.fr_start.centre_y)/(double) (ani_calc.nb_image-1) ;
  ix_reduc   = (ani_calc.fr_end.ix-ani_calc.fr_start.ix)/(double) (ani_calc.nb_image-1) ;
  iy_reduc   = (ani_calc.fr_end.iy-ani_calc.fr_start.iy)/(double) (ani_calc.nb_image-1) ;
  iter_reduc = ((double)ani_calc.fr_end.maxiter-(double)ani_calc.fr_start.maxiter)/(double) (ani_calc.nb_image-1) ;
  ratio      = ani_calc.fr_end.largeur/ani_calc.fr_end.hauteur ;

  fr.type       = ani_calc.fr_end.type ;
  fr.algorithme = ani_calc.fr_end.algorithme ;
  memcpy(&fr.img, &ani_calc.fr_end.img, sizeof(MFDB)) ;

  ani_calc.stopped = 0 ;
  ani_calc.nb_csec = 0 ;
  ani_calc.nb_isec = 0 ;
  ani_calc.pc_ccpu = 0 ;
  ani_calc.pc_cfpu = 0 ;
  ani_calc.pc_cdsp = 0 ;

  nbl_cpu = 0 ;
  nbl_fpu = 0 ;
  nbl_dsp = 0 ;

  size_img = img_size(ani_calc.fr_end.img.fd_w, ani_calc.fr_end.img.fd_h, nb_plane) ;

  taille   = (long)ani_calc.fr_end.img.fd_w*(long)(3+ani_calc.fr_end.img.fd_h) ;
  adr_data = (unsigned char *) malloc(taille) ;
  if (adr_data == NULL)
  {
    form_error(8) ;
    return(-2) ;
  }
  
  if (selected(form_seq, SEQ_PACK))
  {
    info_taille = (size_t *) malloc(sizeof(size_t)*(1+ani_calc.nb_image)) ;
    if (info_taille == NULL)
    {
      form_error(8) ;
      free(adr_data) ;
      return(-2) ;
    }
    
    last_img = (void *) malloc(size_img) ;
    if (last_img == NULL)
    {
      form_error(8) ;
      free(info_taille) ;
      free(adr_data) ;
      return(-2) ;
    }
  }
  
  adr_form_canim[CALCA_CPU].ob_state = CHECKED ;

  adr_form_canim[CALCA_FPU].ob_state &= ~DISABLED ;
  if (fpu_type && (config.calc_format == REEL))
  {
    adr_form_canim[CALCA_CPU].ob_state &= ~CHECKED ;
	adr_form_canim[CALCA_FPU].ob_state |= CHECKED ;
  }
  else
  {
    adr_form_canim[CALCA_CPU].ob_state |= CHECKED ;
	adr_form_canim[CALCA_FPU].ob_state &= ~CHECKED ;
  }	

  wind_get(window_handle[num_window], WF_WORKXYWH, &xi, &yi, &wx, &wy) ;

  fr.hauteur = ani_calc.fr_start.hauteur ;
  flag_ani   = 1 ;
  nbl_total  = 0 ;

  if (ani_calc.fr_start.algorithme == DEM)
  {
    long taille ;
    int  maxiter ;

    maxiter = ani_calc.fr_start.maxiter ;
    if (ani_calc.fr_end.maxiter > maxiter) maxiter = ani_calc.fr_end.maxiter ;
    taille  = 2*sizeof(FPU_DOUBLE)*(size_t)(2+maxiter) ;
    xyorbit = malloc(taille) ;
    if (xyorbit == NULL)
    {
      graf_mouse(ARROW, 0L) ;
      form_error(8) ;
      free(last_img) ;
      free(info_taille) ;
      free(adr_data) ;
      return(-1) ;
    }
  }

  if ( UseStdVDI )
  {
    memcpy(&std_img, &fractal[num_window].img, sizeof(MFDB)) ;
    std_img.fd_addr = img_alloc(std_img.fd_w, std_img.fd_h, std_img.fd_nplanes) ;
    if (std_img.fd_addr == NULL)
    {
      graf_mouse(ARROW, 0L) ;
      form_error(8) ;
      free( xyorbit ) ;
      free(last_img) ;
      free(info_taille) ;
      free(adr_data) ;
      return(-1) ;
    }
  }

  get_time_date(ani_calc.time_start, ani_calc.date_start) ;
  draw_dialog(adr_form_canim, titre) ;
  angle = -ani_calc.rotation ;
  for (num_img = 0; num_img < ani_calc.nb_image; num_img++)
  {
    angle      += ani_calc.rotation ;
	fnum_img    = (double) num_img ;
	fr.ix       = ani_calc.fr_start.ix+fnum_img*ix_reduc ;
	fr.iy       = ani_calc.fr_start.iy+fnum_img*iy_reduc ;
	fr.maxiter  = (int) (ani_calc.fr_start.maxiter+fnum_img*iter_reduc) ;
	fr.centre_x = ani_calc.fr_start.centre_x+fnum_img*xc_reduc ;
	fr.centre_y = ani_calc.fr_start.centre_y+fnum_img*yc_reduc ;
	fr.largeur  = fr.hauteur*ratio ;
	fr.xmin     = fr.centre_x-fr.largeur/2 ;
	fr.xmax     = fr.centre_x+fr.largeur/2 ;
	fr.ymin     = fr.centre_y-fr.hauteur/2 ;
	fr.ymax     = fr.centre_y+fr.hauteur/2 ;

    wish     = fr.largeur/(double)fr.img.fd_w ;
    accuracy = pow(2.0, -23.0)/ftof ;
    acr_dsp  = (wish > accuracy) ;
    if ((acr_dsp == 1) && (config.dsp_on == 1)  && (config.calc_format == ENTIER))
    {
	  dsp_busy = Dsp_Lock() ;

      if (!dsp_busy && (config.calc_format == ENTIER))
	    adr_form_canim[CALCA_DSP].ob_state |= CHECKED ;
      else
	    adr_form_canim[CALCA_DSP].ob_state &= ~CHECKED ;
    }
    else adr_form_canim[CALCA_DSP].ob_state &= ~CHECKED ;
    
    if (ability == -1) adr_form_canim[CALCA_DSP].ob_state &= ~CHECKED ;
    if (!dsp_busy && (ability != -1))
    {
      if (dsp_code_size <= 0)
      {
        adr_form_canim[CALCA_DSP].ob_state &= ~CHECKED ;
        Dsp_Unlock() ;
        dsp_busy = 0 ;
      }
    }
    else
	  adr_form_canim[CALCA_DSP].ob_state &= ~CHECKED ;

    sprintf(buf, "%d/%d", 1+num_img, ani_calc.nb_image) ;
    write_text(adr_form_canim, CANIM_TPROG, buf) ;
    objc_draw(adr_form_canim, CALCA_DSP, 0, xdesk, ydesk, wdesk, hdesk) ;
    objc_draw(adr_form_canim, CANIM_CUR, 0, xdesk, ydesk, wdesk, hdesk) ;
    objc_draw(adr_form_canim, CANIM_TPROG, 0, xdesk, ydesk, wdesk, hdesk) ;
	vswr_mode(handle, MD_TRANS) ;
	vsf_interior(handle, FIS_PATTERN) ;
	vsf_style(handle, 4) ;
	vsf_color(handle, 1) ;
	objc_offset(adr_form_canim, CANIM_CUR, &off_x, &off_y) ;
	objc_offset(adr_form_canim, CANIM_GLO, &off_x1, &off_y1) ;
    oratio      = (double) (adr_form_canim[CANIM_GLO].ob_width-2)*((1.0+fnum_img)/(double) ani_calc.nb_image) ;
    xyarray[0]  = off_x1 ;
    xyarray[1]  = off_y1 ;
    xyarray[2]  = off_x1 + (int) oratio ;
    xyarray[3]  = off_y1 + adr_form_canim[CANIM_GLO].ob_height-1 ;
	vr_recfl(handle, xyarray) ;

    symetrie = symetrie_possible(&fr) ;
    switch(symetrie)
    {
	  case SYM_AXE : memcpy(&fr1, &fr, sizeof(FRACTAL)) ;
                     memcpy(&frac, &fr, sizeof(FRACTAL)) ;
				     get_fractal_zones(&fr1, &zone_calc, &zone_deduct) ;
				     memset(adr_data, 0, taille) ;
				     init_asm_data(&fr1) ;
				     start_time = clock() ;
				     go_multi_calc() ;
				     end_time = clock() ;
				     get_report(&fr1) ;
				     break ;
	  default      : memset(adr_data, 0, taille) ;
                     memcpy(&fr1, &fr, sizeof(FRACTAL)) ;
                     memcpy(&frac, &fr, sizeof(FRACTAL)) ;
		  		     init_asm_data(&fr1) ;
				     start_time = clock() ;
	 			     go_multi_calc() ;
				     end_time = clock() ;
				     get_report(&fr1) ;
				     zone_calc.xi = 0 ;  zone_calc.yi = 0 ;
				     zone_calc.w  = wx ; zone_calc.h  = wy ;
				     break ;
    }

    if (!dsp_busy && (ability != -1) && config.dsp_on && (acr_dsp == 1) && (dsp_code_size > 0)) Dsp_Unlock() ;
    
	ani_calc.nb_csec += fr1.report.t_calc ;
	nbl_cpu          += fr1.report.nbl_cpu ;
	nbl_fpu          += fr1.report.nbl_fpu ;
	nbl_dsp          += fr1.report.nbl_dsp ;
	nbl_total        += (long) zone_calc.h ;
	fr.hauteur        = fr.hauteur*h_reduc ;
	
	if (stat_calc == 1)
	{
	  char buf[60] ;

	  ani_calc.stopped = 1 ;
	  sprintf(buf, msg[MSG_ANICANCEL], num_img) ;
	  form_stop(1, buf) ;
	  ret = -2 ;
	  break ;
	}

	start_time = clock() ;
	img_raz(&fractal[num_window].img) ;
	orbite_to_raster(&fractal[num_window], &zone_calc, window_handle[num_window]) ;

    if (UseStdVDI)
    {
      std_img.fd_stand = 1 ;
      ClassicAtari2StdVDI( &fractal[num_window].img, &std_img ) ;
      vr_trnfm( handle, &std_img, &fractal[num_window].img ) ;
    }

	if (symetrie == SYM_AXE)
	{
	  if (zone_calc.yi == 0)
	  {
	    xyarray[1] = zone_deduct.yi-zone_deduct.h ;
	    xyarray[3] = zone_deduct.yi-1 ;
	    xyarray[5] = zone_deduct.yi ;
	    xyarray[7] = fractal[num_window].img.fd_h-1 ;
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

	  raster_symvrt(handle, xyarray, &fractal[num_window].img, &fractal[num_window].img) ;
	}
	end_time = clock() ;
	ani_calc.nb_isec += (10*(end_time-start_time))/CLK_TCK;
	
	if (selected(form_seq, SEQ_ISOL)) remove_isol_pts(&fractal[num_window].img) ;

	img_fractal_update(window_handle[num_window]) ;
	event.ev_mflags    = MU_MESAG|MU_TIMER ;
    event.ev_mbclicks  = 0 ;
    event.ev_bmask     = 0 ;
    event.ev_mbstate   = 0 ;
	event.ev_mtlocount = 100 ;
	do
	{
	  which = EvntMulti(&event) ;
	  if ((which == MU_MESAG) && (event.ev_mmgpbuf[0] == WM_REDRAW))
	    window_update(event.ev_mmgpbuf) ;
	}
	while (which != MU_TIMER) ;

    if (selected(form_seq, SEQ_PACK))
    {
      if (num_img == 0)
      {
        memcpy(last_img, fractal[num_window].img.fd_addr, size_img) ;
	    if (fwrite(fr.img.fd_addr, size_img, 1, stream) != 1)
	    {
	      char buf[100] ;

	      sprintf(buf, msg[MSG_ANIERRWRITE], num_img) ;
	      form_stop(1, buf) ;
	      ret = -1 ;
	      break ;
	    }
      }
      else
      {
        tcompress = compress((char *)last_img, (char *) fractal[num_window].img.fd_addr, size_img, stream) ;
        if (tcompress > 0) info_taille[num_img-1] = tcompress ;
        else
        {
	      char buf[100] ;

	      sprintf(buf, msg[MSG_ANIERRWRITE], num_img) ;
	      form_stop(1, buf) ;
	      ret = -1 ;
	      break ;
        }
        memcpy(last_img, fractal[num_window].img.fd_addr, size_img) ;
      }
    }
    else
    {
	  if (fwrite(fr.img.fd_addr, size_img, 1, stream) != 1)
	  {
	    char buf[100] ;

	    sprintf(buf, msg[MSG_ANIERRWRITE], num_img) ;
	    form_stop(1, buf) ;
	    ret = -1 ;
	    break ;
	  }
	}

    if (selected(form_seq, SEQ_SAVGIF))
    {
      INFO_IMAGE inf ;
      
      sprintf(name, "%s%.4d.GIF", config.path_ani, num_img) ;
      inf.largeur   = fractal[num_window].img.fd_w ;
      inf.hauteur   = fractal[num_window].img.fd_h ;
      inf.predictor = 0 ;
      inf.byteorder = 0 ; /* Sans importance */
      inf.lpix      = 0x152 ;
      inf.hpix      = 0x152 ;
      inf.nb_cpal   = nb_colors ;
      inf.nplans    = fractal[num_window].img.fd_nplanes ;
      get_tospalette(palette) ;
      inf.palette  = palette ;
      inf.compress = 0 ;
      hide_dialog() ;
      ret = save_picture( name,  "GIF", &fractal[num_window].img, &inf ) ;
      draw_dialog(adr_form_canim, titre) ;
	  if (ret)
	  {
	    char buf[100] ;

	    sprintf(buf, msg[MSG_ANIERRWRITE], num_img) ;
	    form_stop(1, buf) ;
	    ret = -1 ;
	    break ;
	  }
    }
  }

  if (selected(form_seq, SEQ_PACK) && (num_img > 1))
  {
    fwrite(info_taille, sizeof(long), num_img-1, stream) ;
    *ani_calc.pack = 1 ;
  }

  flag_ani = 0 ;
  get_time_date(ani_calc.time_end, ani_calc.date_end) ;
  ani_calc.nb_csec /= 10 ;
  ani_calc.nb_isec /= 10 ;
  ani_calc.nb_image = num_img ;
  ani_calc.pc_ccpu  = 100.0*(double)nbl_cpu/(double)nbl_total ;
  ani_calc.pc_cfpu  = 100.0*(double)nbl_fpu/(double)nbl_total ;
  ani_calc.pc_cdsp  = 100.0*(double)nbl_dsp/(double)nbl_total ;
  fwrite(&ani_calc, sizeof(ANIMATION_FRACTAL), 1, stream) ;
  fclose(stream) ;

  hide_dialog() ;

  if ( UseStdVDI ) free(std_img.fd_addr) ;
  if (xyorbit != NULL)
  {
    free(xyorbit) ;
    xyorbit = NULL ;
  }
  if (selected(form_seq, SEQ_PACK))
  {
    free(last_img) ;
    free(info_taille) ;
  }
  free(adr_data) ;

  if (selected(form_seq, SEQ_SAVGIF))
  {
    FILE *stream ;
    int  i ;

    /* GÇnäre le fichier pour GIF2FLI */
    sprintf(name, "%sLISTE.LST", config.path_ani) ;
    stream = fopen(name, "wb") ;
    if (stream != NULL)
    {
      for (i = 0; i < num_img; i++)
        fprintf(stream, "%s%.4d.GIF\n",  config.path_ani, i) ;
      fclose(stream) ;
    }
  }

  memcpy(&event, &saved, sizeof(EVENT)) ;
  return(ret) ;
}
