/****************************************/
/*------------- FRACT_IO.C -------------*/
/* Module de gestion des chargements et */
/* Sauvegardes du Project FRACTAL.PRJ   */
/****************************************/
#include    <ext.h>
#include <string.h>
#include <stdlib.h>

#include              "defs.h"
#include           "fractal.h"
#include      "..\tools\lzw.h"
#include     "..\tools\xgem.h"
#include   "..\tools\xstdio.h"
#include   "..\tools\img_io.h"
#include   "..\tools\gif_io.h"
#include  "..\tools\clipbrd.h"
#include  "..\tools\tiff_io.h"
#include  "..\tools\rasterop.h"

#include   "gstevn.h"
#include   "calcul.h"
#include "clgstevn.h"


extern void redraws(void) ;

char *msg[1+MSG_ENDLIST] ; /* Tableau de pointeurs sur les messages   */
                           /* D'avertissements. Initialis‚ par MAIN.C */
FRACTAL_CFG config ;       /* Configuration de l'application  */
FRACTAL     Mandel ;       /* Structure utilis‚e pour stocker */
						   /* l'ensemble de Mandelbrot pour   */
						   /* Choisir un initialisateur.      */
char mask_fractal[60] ;    /* Masque pour fileselect()        */
char mask_ani[60] ;        /* Masque pour fileselect()        */
char mask_init[60] ;       /* Chemin des initilisateurs       */


int charge_mandel(int flag_search)
{
  FRACTAL save ;
  FILE    *stream ;
  char    name[200] ;
  int     ccalc, cdsp ;

  memcpy(&save, &Mandel, sizeof(FRACTAL)) ;
  if (flag_search == 0)
  {
    strcpy (mask_init, " :") ;
    mask_init[0] = 'A' + getdisk() ;
    getcurdir(0, mask_init+3) ;
    strcat(mask_init, "\\*.FRC") ;  
    sprintf(name, "_MANDEL_.%d", nb_colors) ;
  }
  else
  {
    char *c ;

    if (file_name(mask_init, "", name) != 1) return(0) ;
    strcpy(mask_init, name) ;
    c = strrchr(mask_init, '\\') ;
    *c = 0 ;
    strcat(mask_init, "\\*.FRC") ;  
  }

  Mandel.img.fd_addr = NULL ;
  graf_mouse(BUSYBEE, 0L) ;
  stream = fopen(name, "rb") ;
  if (stream == NULL)
  {
	memcpy(&Mandel, &fractal[0], sizeof(FRACTAL)) ;
	Mandel.maxiter  = 64 ;
	Mandel.img.fd_w = 400 ;
	Mandel.img.fd_h = (int) ((float)Mandel.img.fd_w*hauteur/largeur) ;
	Mandel.img.fd_wdwidth = Mandel.img.fd_w/16 ;
	Mandel.img.fd_addr = img_alloc(Mandel.img.fd_w, Mandel.img.fd_h, nb_plane) ;
	if (Mandel.img.fd_addr == NULL)
	{
	  form_stop(1, msg[MSG_INITERRMEM]) ;
	  graf_mouse(POINT_HAND, 0L) ;
	  return(0) ;
	}

    ccalc = config.calc_format ;
    cdsp  = config.dsp_on ;
	config.calc_format = ENTIER ;
	config.dsp_on      = (DspInfo.type == DSP_56001) ;
	flag_show          = 1 ;
	graf_mouse(ARROW, 0L) ;
	calcul_go(&Mandel, -1) ;
	config.calc_format = ccalc ;
	config.dsp_on      = cdsp ;

	return(1) ;
  }

  fread(&Mandel, sizeof(FRACTAL), 1, stream) ;
  if (Mandel.img.fd_nplanes != nb_plane)
  {
    form_stop(1, msg[MSG_BADINIT]) ;
    memcpy(&Mandel, &save, sizeof(FRACTAL)) ;
    return(0) ;
  }

  Mandel.img.fd_addr = img_alloc(Mandel.img.fd_w, Mandel.img.fd_h, nb_plane) ;
  if (Mandel.img.fd_addr == NULL)
  {
	form_stop(1, msg[MSG_INITERRMEM]) ;
	graf_mouse(ARROW, 0L) ;
    fclose(stream) ;
	return(0) ;
  }

  if (save.img.fd_addr != NULL) free(save.img.fd_addr) ;
  fread(Mandel.img.fd_addr, img_size(Mandel.img.fd_w, Mandel.img.fd_h, nb_plane), 1, stream) ;
  fclose(stream) ;

  graf_mouse(ARROW, 0L) ;
  return(1) ;
}

int sauve_image(void)
{
  OBJECT     *adr_export ;
  INFO_IMAGE inf ;
  int        palette[256*6] ;
  int        bouton ;
  int        ret ;
  char       name[200] ;
  char       fmt[10] ;

  Xrsrc_gaddr(R_TREE, FORM_EXPORT, &adr_export) ;
  fshow_dialog(adr_export, titre) ;
  bouton = xform_do(0, window_update) ;
  deselect(adr_export, bouton) ;
  fhide_dialog() ;
  if (bouton == EXPORT_CANCEL) return(0) ;

  redraws() ;

  if (file_name(config.path_fractal, "", name))
  {
    redraws() ;
    inf.largeur   = fractal[num_window].img.fd_w ;
    inf.hauteur   = fractal[num_window].img.fd_h ;
    inf.predictor = 0 ;
    inf.byteorder = MOTOROLA ;
    inf.lpix      = 0x152 ;
    inf.hpix      = 0x152 ;
    inf.nb_cpal   = nb_colors ;
    inf.nplans    = fractal[num_window].img.fd_nplanes ;
    get_tospalette(palette) ;
    inf.palette  = palette ;
    inf.compress = 0 ;
    if ( selected(adr_export, EXPORT_XIMG) ) strcpy( fmt, "IMG" ) ;
    else if ( selected(adr_export, EXPORT_GIF) ) strcpy( fmt, "GIF" ) ;
    else /* Export en TIF */
    {
      strcpy( fmt, "TIF" ) ;
      if ( selected( adr_export, EXPORT_TIFFLZW ) ) inf.compress = 5 ; /* LZW */
      else                                          inf.compress = 1 ;
    }
    ret = save_picture(name,  fmt, &fractal[num_window].img, &inf) ;
  }

  return(ret) ;
}

int lzwfrc_compress(FILE *stream, MFDB *mfdb)
{
  long          lo_3lines ;
  long          in_pos ;
  long          *lzw_nb ;
  int           i_offset ;
  int           l3 ;
  int           ret, pc ;
  unsigned char *pt ;

  mouse_busy() ;
  in_pos = ftell(stream) ;
  l3     = mfdb->fd_h/3 ;
  lzw_nb = (long *) calloc(l3, sizeof(long)) ;
  if (lzw_nb == NULL) return(-3) ;
  fwrite(lzw_nb, sizeof(long), l3, stream) ;
  stdprog_show(msg[MSG_ENCODAGELZW], "", "") ;
  if (MachineInfo.cpu >= 30L) stdprog_display030() ;
  lo_3lines  = 3L*2L*(long)mfdb->fd_wdwidth*(long)mfdb->fd_nplanes ;
  pt         = (unsigned char *) mfdb->fd_addr ;
  for (i_offset = 0; i_offset < l3; i_offset++)
  {
    code_size = 9 ;
    ret = lzw_init(8, NULL, 0) ;
    if (ret == 0) ret = lzw_compress(pt, lo_3lines, stream, &lzw_nb[i_offset]) ;
    if (ret != 0) break ;
    pt += lo_3lines ;
    if ((i_offset & 0x03) == 0x03)
    {
      pc = (int) ((100L*(long)(i_offset+1))/(long)l3) ;
      stdprog_pc(pc) ;
    }
  }
  stdprog_hide() ;
  fseek(stream, in_pos, SEEK_SET) ;
  fwrite(lzw_nb, sizeof(long), l3, stream) ;
  fseek(stream, 0, SEEK_END) ;
  free(lzw_nb) ;
  mouse_restore() ;

  return(ret) ;
}

int lzwfrc_decompress(FILE *stream, MFDB *mfdb)
{
  long          *lzw_nb ;
  int           i_offset, l3 ;
  long          lo_3lines ;
  long          nb_out ;
  int           pc ;
  unsigned char *pt ;
  unsigned char *buffer ;

  mouse_busy() ;
  stdprog_show(msg[MSG_DECODAGELZW], "", "") ;
  if (MachineInfo.cpu >= 30L) stdprog_display030() ;
  l3     = mfdb->fd_h/3 ;
  lzw_nb = (long *) malloc(l3*sizeof(long)) ;
  if (lzw_nb == NULL) return(-3) ;
  fread(lzw_nb, sizeof(long), l3, stream) ;
  buffer    = (unsigned char *) malloc(8192) ;
  if (buffer == NULL)
  {
    free(lzw_nb) ;
    return(-3) ;
  }
  pt        = (unsigned char *) mfdb->fd_addr ;
  lo_3lines = 3L*2L*(long)mfdb->fd_wdwidth*(long)mfdb->fd_nplanes ;
  nb_out    = 0 ;
  bit1      = 7 ;
  code_size = 9 ;
  pt_in     = buffer ;
  bit_shift = 0 ;
  if (lzw_init(8, buffer, 0) != 0)
  {
    free(buffer) ;
    free(lzw_nb) ;
    return(-3) ;
  }
  for (i_offset = 0; i_offset < l3; i_offset++)
  {
    fread(buffer, 1, lzw_nb[i_offset], stream) ;
    bit1      = 7 ;
    code_size = 9 ;
    pt_in     = buffer ;
    bit_shift = 0 ;
    nb_out = lzw_decompress(buffer, pt, lzw_nb[i_offset]) ;
    if (nb_out == 0) break ;
    pt += lo_3lines ;
    if ((i_offset & 0x03) == 0x03)
    {
      pc = (int) ((100L*(long)(i_offset+1))/(long)l3) ;
      stdprog_pc(pc) ;
    }
  }
  stdprog_hide() ;
  fseek(stream, -6*nb_colors, SEEK_END) ; /* Se positionne sur la palette */
  free(buffer) ;
  free(lzw_nb) ;
  mouse_restore() ;

  return(0) ;
}

int sauve_fractal(char *name, char flag_img)
{
  FRACTAL fr ;
  FILE    *stream ;
  long    taille ;
  int     ret = 0 ;
  
  memcpy(&fr, &fractal[num_window], sizeof(FRACTAL)) ;
  if (flag_img != 1) fr.img.fd_addr = NULL ;
  else if (config.lzw_frc) fr.img.fd_addr = (void *) 1L ;

  stream = fopen(name, "wb+") ;
  if (stream == NULL)
  {
    form_stop(1, msg[MSG_FILENOTEXIST]) ;
    return(-1) ;
  }
  fwrite(&fr, sizeof(FRACTAL), 1, stream) ;
  if (flag_img == 1)
  {
    if (!config.lzw_frc)
    {
      taille = img_size(fr.img.fd_w, fr.img.fd_h, nb_plane) ;
	  if (fwrite(fr.img.fd_addr, taille, 1, stream) != 1) ret = -1 ;
	}
	else
	  ret = lzwfrc_compress(stream, &fractal[num_window].img) ;
  }
  if (fwrite(&fractal_pal[num_window][0], 6, nb_colors, stream) != nb_colors) ret = 1 ;

  fclose(stream) ;
  return(ret) ;
}

int sauve_sfractal(char *name, char flag_img)
{
  if (file_exist(name))
  {
    int rep ;

    rep = form_stop(1, msg[MSG_FILEEXISTS]) ;
    if (rep == 2) return(1) ;
  }
  return(sauve_fractal(name, flag_img)) ;
}

int charge_fractal(char *name)
{
  FILE *stream ;
  long image ;
  int  n_window ;
  int  x, y, w, h ;
  int  ww, wh ;
  char buf[150] ;

  n_window = num_new_window() ; /* On sait que c'est d‚j… possible */

  graf_mouse(BUSYBEE, 0L) ;
  stream = fopen(name, "rb") ;
  if (stream == NULL)
  {
	form_interrogation(1, msg[MSG_FILENOTEXIST]) ;
	return(-1) ;
  }

  fread(&fractal[n_window], sizeof(FRACTAL), 1, stream) ;
  image = (long) fractal[n_window].img.fd_addr ;

  open_where(W_ALL, fractal[n_window].img.fd_w, fractal[n_window].img.fd_h,
             &x, &y, &w, &h) ;
  if (AESversion >= 0x0410)
	window_handle[n_window] = open_fwindow(W_ALL | SMALLER, x, y, w, h) ;
  else
    window_handle[n_window] = open_fwindow(W_ALL, x, y, w, h) ;
  if (window_handle[n_window] < 0)
  {
	form_exclamation(1, msg[MSG_NOMOREWINDOW]) ;
	return(-2) ;
  }

  num_window                = n_window ;
  window_opened[num_window] = 1 ;
  strcpy(window_name[num_window], fractal[num_window].nom) ;
  wind_set(window_handle[num_window], WF_NAME, window_name[num_window]) ;
  strcpy(window_info[num_window], "") ;
  wind_set(window_handle[num_window], WF_INFO, window_info[num_window]) ;
  winfo[n_window].x1 = winfo[n_window].y1 = 0 ;
  winfo[n_window].x2 = w-1 ;
  winfo[n_window].y2 = y-1 ;
  ww = (int) (1000.0*(double)w/(double)fractal[n_window].img.fd_w) ;
  wh = (int) (1000.0*(double)h/(double)fractal[n_window].img.fd_h) ;
  wind_set(window_handle[n_window], WF_HSLIDE, 1) ;
  wind_set(window_handle[n_window], WF_VSLIDE, 1) ;
  wind_set(window_handle[n_window], WF_HSLSIZE, ww) ;
  wind_set(window_handle[n_window], WF_VSLSIZE, wh) ;

  fractal[num_window].img.fd_addr = img_alloc(fractal[num_window].img.fd_w,
                                              fractal[num_window].img.fd_h,
                                              nb_plane) ;
  if (fractal[num_window].img.fd_addr == NULL)
  {
	int n_handle ;

	fclose(stream) ;
	form_stop(1, msg[MSG_IMGERRMEM]) ;
	n_handle   = close_window(window_handle[num_window]) ;
	num_window = num_wind(n_handle) ;
	return(1) ;
  }

  if (image) /* L'image a ‚t‚ ‚galement sauv‚e */
  {
	if (fractal[num_window].img.fd_nplanes != nb_plane)
	{
	  sprintf(buf, msg[MSG_IMGNOTSAME], 1 << fractal[num_window].img.fd_nplanes) ;
	  form_stop(1, buf) ;
	  fractal[num_window].img.fd_nplanes = nb_plane ; /* Rend le MFDB compatible avec l'‚cran */
	  img_raz(&fractal[num_window].img) ;
	  fclose(stream) ;
	  return(0) ;
	}
	if (image != 1L)
	{
	  long taille ;

      taille = img_size(fractal[num_window].img.fd_w, fractal[num_window].img.fd_h, nb_plane) ;
      fread(fractal[num_window].img.fd_addr, taille, 1, stream) ;
    }
    else
      lzwfrc_decompress(stream, &fractal[num_window].img) ;
	if (fread(&fractal_pal[num_window], 6, nb_colors, stream) != nb_colors)
	  get_tospalette(&fractal_pal[num_window][0]) ;
  }
  else
  {
   	fractal[num_window].img.fd_nplanes = nb_plane ; /* Rend le MFDB compatible avec l'‚cran */
    img_raz(&fractal[num_window].img) ;
	if (fread(&fractal_pal[num_window], 6, nb_colors, stream) != nb_colors)
	  get_tospalette(&fractal_pal[num_window][0]) ;
  }

  set_imgpalette(num_window) ;
  fclose(stream) ;
  return(0) ;
}

void charge_config(void)
{
  FILE *stream ;

  graf_mouse(BUSYBEE, 0L) ;
  stream = fopen("FRACTAL.CFG", "rb") ;
  if (stream != NULL)
  {
	fread(&config, sizeof(FRACTAL_CFG), 1, stream) ;
	fclose(stream) ;
  }

  if (memcmp(config.version, VERSION, 4))
  {
    memset(&config, 0, sizeof(FRACTAL_CFG)) ;
	config.path_fractal[0] = 'A' + getdisk();
	config.path_fractal[1] = ':';
	getcurdir(0, &config.path_fractal[2]);
	strcat(config.path_fractal, "\\");
	strcpy(config.path_ani, config.path_fractal) ;
	config.calc_format = ENTIER ;
	config.dsp_on      = 1 ;
	config.tr_width    = 144 ;
	config.tr_height   = 105 ;
	config.tr_maxiter  = 48 ;
    config.lzw_frc     = 1 ;
  }

  strcpy(mask_fractal, config.path_fractal) ;
  strcat(mask_fractal, "*.FRC") ;
  strcpy(mask_ani, config.path_ani) ;
  strcat(mask_ani, "*.FAN") ;

  init_real_time() ;
  graf_mouse(ARROW, 0L) ;
}

void sauve_config(void)
{
  FILE *stream ;

  stream = fopen("FRACTAL.CFG", "wb") ;
  if (stream != NULL)
  {
    strcpy(config.version, VERSION) ;
    fwrite(&config, sizeof(FRACTAL_CFG), 1, stream) ;
    if (fclose(stream) != 0) form_stop(1, msg[MSG_WRITEERROR]) ;
  }
  else form_stop(1, msg[MSG_WRITEERROR]) ;
}

void traite_copie(int num)
{
  INFO_IMAGE inf ;
  int        palette[256*6] ;
  char       path[200], name[200] ;

  if (num == -1) return ;
  if (clbd_getpath(path))
  {
    form_stop(1, msg[MSG_CLIPERR]) ;
    return ;
  }

  strcpy(name, path) ;
  strcat(name, "SCRAP.IMG") ;
  inf.lpix    = 0x152 ;
  inf.hpix    = 0x152 ;
  inf.nb_cpal = nb_colors ;
  inf.nplans  = fractal[num_window].img.fd_nplanes ;
  get_tospalette(palette);
  inf.palette = palette ;
  graf_mouse(BUSYBEE, NULL) ;
  switch( save_picture( name, "IMG", &fractal[num_window].img, &inf ) )
  {
    case -1 :
    case -2 : form_stop(1, msg[MSG_WRITEERROR]) ;
              return ;
    case -3 : form_error(8) ;
              return ;
  }
  
  strcpy(name, path) ;
  strcat(name, "SCRAP.FRC") ;
  sauve_fractal(name, 0) ;
}
