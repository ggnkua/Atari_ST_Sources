/*********************/
/*---- DITHER.H -----*/
/*********************/
#if !defined(__DITHER_H)
#define __DITHER_H

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif

#define DITHER_AUTO     0   /* Best choice                      */
#define DITHER_SEUIL    1   /* Dither with matrix               */
#define DITHER_GRIS     2   /* Grey level                       */
#define DITHER_216      3   /* TC --> 216 colors                */
#define DITHER_BICHRO   4   /* Any planes --> 2 color bichromie */


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
int dither(int method, INFO_IMAGE* inf, MFDB* out, GEM_WINDOW* wprog) ;

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

#endif
