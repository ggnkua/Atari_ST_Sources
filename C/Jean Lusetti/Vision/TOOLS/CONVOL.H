/**********************/
/* Header de CONVOL.C */
/**********************/
#if !defined(__CONVOLUTION)
#define __CONVOLUTION

#if !defined(__IMAGE_IO)
#include "..\tools\image_io.h"
#endif


#define CONVOL_BADFILTERFILE -1
#define CONVOL_BADNBCOLORS   -2
#define CONVOL_MEMORY        -3
#define CONVOL_BADDSPFILE    -4
#define CONVOL_DSPERROR      -5
#define CONVOL_DSPBUSY       -6
#define CONVOL_LODNOTEXIST   -7


typedef struct
{
  unsigned char w ;      /* Nombre de colonnes                  */
  unsigned char h ;      /* Nombre de lignes                    */
  char name[30] ;        /* Nom normalis‚                       */
  char description[30] ; /* BrŠve description                   */
  char rfu[20] ;         /* Future extension                    */
  char *data ;           /* Pointeur sur le tableau de donn‚ees */
}
CONVOLUTION_FILTRE ;


/*************************************************************/
/* Chargement d'un fichier filtre dans la structure filter   */
/* En retour : 0                    : OK                     */
/*             CONVOL_BADFILTERFILE : Fichier inexistant ou  */
/*                                    non conforme au format */
/*             CONVOL_MEMORY        : M‚moire insuffisante   */
/*************************************************************/
int convolution_loadfilter(char *filtername, CONVOLUTION_FILTRE *filter) ;

/*************************************************************/
/* Sauvegarde d'un fichier filtre dans la structure filter   */
/* En retour :  0 : OK                                       */
/*             -1 : erreur d'‚criture                        */
/*************************************************************/
int convolution_savefilter(char *filtername, CONVOLUTION_FILTRE *filter) ;

/***************************************************************************/
/* Effectue la convolution de l'image in par le filtre filter              */
/* out est allou‚ par cette fonction                                       */
/* Le nombre de plans de l'image doit ˆtre au moins de 8 (niveaux de gris) */
/* Si DSPfile[0] = 0, le DSP ne sera pas utilis‚                           */
/* En retour : 0                  : OK                                     */
/*             CONVOL_BADNBCOLORS : Nombre de plans < 8                    */
/*             CONVOL_MEMORY      : M‚moire insuffisante                   */
/*             CONVOL_BADDSPFILE  : .LOD inexistant ou non conforme        */
/*             CONVOL_DSPERROR    : Erreur de traitement du DSP            */
/***************************************************************************/
int convolution(MFDB *in, INFO_IMAGE *info, MFDB *out, char *DSPfile, CONVOLUTION_FILTRE *filter, GEM_WINDOW *wprog) ;

#endif
