/*********************/
/*---- DITHER.H -----*/
/*********************/
#if !defined(__DITHER_H)
#define __DITHER_H

#if !defined(__IMAGE_IO_H)
#include "..\tools\image_io.h"
#endif

#define DITHER_AUTO       0   /* Best choice                                                   */
#define DITHER_MATRIXMONO 1   /* Dither with matrix                                            */
#define DITHER_GREY       2   /* Grey level                                                    */
#define DITHER_216        3   /* TC --> 216 colors                                             */
#define DITHER_DUALTONE   4   /* Any planes --> 2 color dual-tone                              */
#define DITHER_FIXEDPAL   5   /* Any planes --> fixed palette of n colors                      */
#define DITHER_16         6   /* >16 colors --> 16 colors with system palette, no matrix       */
#define DITHER_16_4x4M    7   /* >16 colors --> 16 colors with system palette using 4x4 matrix */


/***********************************************/
/* R‚duction du nombre de couleurs d'un raster */
/* out->fd_nplanes doit contenir le nombre de  */
/* Plans d‚sir‚s pour le r‚sultat.             */
/* out est cr‚e par cette fonction.            */
/* En retour :                                 */
/*              0 : OK                         */
/*             -1 : M‚moire insuffisante       */
/*             -2 : Donn‚es incoh‚rentes       */
/***********************************************/
int dither(int method, INFO_IMAGE* inf_in, INFO_IMAGE* inf_out, GEM_WINDOW* wprog) ;

/***********************************************/
/* R‚duction du nombre de couleurs d'un raster */
/* out->fd_nplanes doit contenir le nombre de  */
/* Plans d‚sir‚s pour le r‚sultat.             */
/* out est cr‚e par cette fonction.            */
/* De plus, un facteur d'‚chelle est autoris‚  */
/* En retour :                                 */
/*              0 : OK                         */
/*             -1 : M‚moire insuffisante       */
/*             -2 : Donn‚es incoh‚rentes       */
/***********************************************/
int dither_ratio(MFDB* in, INFO_IMAGE* inf, MFDB* out, int pc_x, int pc_y, GEM_WINDOW* wprog) ;

/* Release global resources allocated to perform dithering (to be called when dithering is no longer needed) */
void dither_release(void) ;

#endif
