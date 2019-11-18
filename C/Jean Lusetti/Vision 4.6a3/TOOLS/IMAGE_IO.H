/****************************************/
/*------------- IMAGE_IO.H ------------ */
/*      header de IMAGE_IO.C            */
/* Ensemble de routines d'entr‚e-sortie */
/* D'images sp‚cifiques Atari           */
/****************************************/
#if !defined(__IMAGE_IO)
#define __IMAGE_IO

#if !defined(__VDI__)
#include <vdi.h>
#endif

#if !defined( __STDIO )
#include <stdio.h>
#endif

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

#ifndef __IMGLFMT
#include "..\tools\imglfmt.h"
#endif

#define MINIW 16
#define MINIH 16

#define FLIPFLOP_X  1
#define FLIPFLOP_Y  2


#define HISTO_SIZE   256


/* Macro utilis‚e pour afficher la progression 1 fois sur n */
#define MAY_UPDATE(wprog,x) ( wprog && ( (x & 0x0F) == 0x0F ) )
#define STOP_CODE(x)        ( (x) == 1 )
#ifndef ARRAY_SIZE
#define ARRAY_SIZE(v)  sizeof(v)/sizeof((v)[0])
#endif

typedef struct
{
  int unit ; /* PREF_UNITMS or PERF_UNITINTERNAL */

  size_t total_load_time ;  /* Grand total for loading/converting         */
  size_t dither_time ;      /* Time for dithering or expanding planes     */
  size_t disk_access_time ; /* I/O time                                   */
  size_t compress_time ;    /* decompress/compress time                   */
  size_t ind2raster_time ;  /* Index to bitplanes conversion time         */
  size_t stdformat_time ;   /* Standard/Specific format conversion time   */
  size_t identify_time ;    /* Time spent in img_format                   */

  /* Used for estimating duration */
  size_t itotal_load_time ;
  size_t idither_time ;
  size_t idisk_access_time ;
  size_t icompress_time ;
  size_t iind2raster_time ;
  size_t istdformat_time ;
  size_t iidentify_time ;
}
PERF_INFO ;
/* Note that all these fields might not be filled by image module */
/* In such a case, the value is PERF_NA                           */
#define PERF_NA ((size_t) -1L)

#define PERF_UNITINTERNAL  0
#define PERF_UNITMS        1

#define PERF_LOAD       0x01
#define PERF_DITHER     0x02
#define PERF_DISK       0x04
#define PERF_COMPRESS   0x08
#define PERF_IND2RASTER 0x10
#define PERF_STDFORMAT  0x20
#define PERF_IDENTIFY   0x40
#define PERF_ALL        ( PERF_LOAD | PERF_DITHER | PERF_DISK | PERF_COMPRESS | PERF_IND2RASTER | PERF_STDFORMAT | PERF_IDENTIFY )

typedef struct
{
  unsigned short predictor ;
  unsigned short byteorder ;
}
TIF_CARACTERISTICS ;

typedef struct
{
  short quality ;
  short progressive ;
}
JPG_CARACTERISTICS ;

typedef struct
{
  short channels ;
  short type ;
  short num_passes ;
  short bit_depth  ;
}
PNG_CARACTERISTICS ;

typedef struct
{
  short flipflop ;
  union
  {
    TIF_CARACTERISTICS tif ;
    JPG_CARACTERISTICS jpg ;
    PNG_CARACTERISTICS png ;
  } f ;
  
}
IMG_CARACTERISTICS, *PIMG_CARACTERISTICS ;

typedef struct
{
  IID  lformat ;               /* MUST be set before calling img_format                              */
                               /* IID_UNKNOWN: file format detection based on file extension         */
                               /* Other:       forced file format, module decided on ImagePriorities */
  MFDB        mfdb ;           /* fd_nplanes field MUST be set before calling load_picture           */
                               /* -1: load image with number of colors reported by image             */
                               /* Other: Load image and adapt it (dither or expand colors            */
                               /*        To this number of planes                                    */
                               /* MFDB hodling image data after load_picture call                    */
  void*       prog ;           /* MUST be set before calling img_format as a GEM_WINDOW* to report   */
                               /* Progression                                                        */

  /* Following fileds will be filled by img_format call:                                             */
  char filename[PATH_MAX] ;

  unsigned short compress ;    /* Depends on format                  */

  short  width ;               /* In pixels                          */
  short  height ;
  short  nplanes ;             /* # of planes for a pixel            */

  short  lpix ;                /* Pixel width in microns             */
  short  hpix ;                /* Pixel height in microns            */
 
  void* palette ;              /* NULL if no palette                 */
                               /* Each element is 3 16bit word wide: */
                               /* word 0 : Red level   0...1000      */
                               /* word 1 : Green level 0...1000      */
                               /* word 2 : Blue level  0...1000      */
  long nb_cpal ;               /* Number of colors in palette        */

  IMG_CARACTERISTICS c ;  

  PERF_INFO   perf_info ;      /* Performances for loading           */

  /* Internal module usage for managing images modules for loading   */
  void*       img_modules[6] ; /* List of potential candidates       */
  short       nb_modules ;     /* Number of candidates               */

  int has_been_dithered: 1 ;
  int multiple_images:   1 ;
  int RFU:              14 ;
}
INFO_IMAGE ;

#define IEF_P1     0x0001
#define IEF_P2     0x0002
#define IEF_P4     0x0004
#define IEF_P8     0x0008
#define IEF_P16    0x0010
#define IEF_P24    0x0020
#define IEF_P32    0x0040
#define IEF_NOCOMP 0x0080
#define IEF_RLE    0x0100
#define IEF_LZW    0x0200
#define IEF_PBIT   0x0400
#define IEF_JPEG   0x0800

typedef struct
{
  unsigned long iid ;
  char          short_name[16] ;
  char          name[40] ;
  unsigned int  version ;             /* 0x0120 pour 1.2 */
  char          file_extension[6] ;

  unsigned int import ; /* IEF_... */
  unsigned int export ; /* IEF_... */

  char known_extensions[1+(4*12)] ; /* "JPG\0JPEG\0JPE\0\0" */
}
INFO_IMAGE_DRIVER ;


typedef struct
{
  unsigned long rouge[HISTO_SIZE] ;
  unsigned long vert[HISTO_SIZE] ;
  unsigned long bleu[HISTO_SIZE] ;
  unsigned long gris[HISTO_SIZE] ;
  unsigned long index[HISTO_SIZE] ;
  unsigned long nb_colors ;
  unsigned long norm ;
  unsigned long nb_colors_used ;
}
HISTO ;

extern unsigned char palind[] ;    /* Pour remap des couleurs */
extern char          img_analyse ; /* 1 si le remplacement des 16 indices GEM doit  */
                                   /* Etre analys‚ et les indices modifi‚s au mieux */
extern char          DitherMethod ;
extern char          FinalNbPlanes ;
extern void          *NaturalFormat ;
extern int           NaturalWidth ;
extern char          Force16BitsLoad ; /* Force le chargement en 16 bits meme si image 24 bits */

/* Image library Error codes */
#define EIMG_SUCCESS             (0)
#define EIMG_FILENOEXIST        (-1)
#define EIMG_DATAINCONSISTENT   (-2)
#define EIMG_NOMEMORY           (-3)
#define EIMG_DECOMPRESERR       (-4)
#define EIMG_UNKOWNFORMAT       (-5)
#define EIMG_OPTIONNOTSUPPORTED (-6)
#define EIMG_UNKNOWNCOMPRESSION (-7)
#define EIMG_USERCANCELLED      (-8)
#define EIMG_NOJPEGDRIVER       (-9)
#define EIMG_NOPNGSLB           (-10)
#define EIMG_NOPNGDRIVER        (-11)
#define EIMG_MODULERROR         (-12)



/******************************************************************************/
/* Alloue la taille m‚moire pour une image de w colonnes, h lignes et n plans */
/******************************************************************************/
/*void *img_alloc(int w, int h, int n) ;*/
/* This will ease who called img_alloc as Xalloc reports file/line in logging */
#define img_alloc(w,h,n) Xalloc( img_size( w, h, n ) )

/*********************************************************/
/* Conversion d'un raster ligne Atari (plans entrelac‚s) */
/* En un raster img (plans dispos‚s successivement       */
/*********************************************************/
void raster2imgline(int *raster, int *img_line, size_t long_ligne, int nplanes) ;

/******************************************************/
/* Adapte une image raster ayant un nombre n de plans */
/* A un raster avec un nombre m de plans (n < m)      */
/******************************************************/
int incnbplanes(MFDB *data, int nb_plan) ;

/**********************************************************/
/* Transforme un raster de n plans en un raster … m plans */
/* Avec n > m. Ne garde que les premiers plans            */
/**********************************************************/
int decnbplanes(MFDB *in, MFDB *out) ;

/*****************************************************************/
/* Reconnaissance du format de l'image et initialisation         */
/* De la structure g‚n‚rale INFO_IMAGE inf                       */
/* Pour trouver le format du fichier, on se base sur l'extension */
/* Si celle ci est inconnue, on prend en compte format           */
/* En retour :  0 : OK, les infos sont dans inf                  */
/*             -1 : Fichier non trouv‚                           */
/*             -2 : Format non reconnu                           */
/*             -3 : M‚moire insuffisante pour stocker la palette */
/*****************************************************************/
int img_format(char* name, INFO_IMAGE* inf) ;

/*****************************************************************/
/* Reconnaissance du format de l'image                           */
/* Le format est ‚crit dans le champ format de INFO_IMAGE        */
/* Pour trouver le format du fichier, on se base sur l'extension */
/*****************************************************************/
IID img_getstdformat(char *nom, INFO_IMAGE *inf) ;

/*************************************/
/* Chargement d'une image en m‚moire */
/*************************************/
int load_picture(INFO_IMAGE* inf) ;

/**************************/
/* Sauvegarde d'une image */
/**************************/
int save_picture(char *name, MFDB *img, INFO_IMAGE *inf, GEM_WINDOW *wprog) ;

/********************************************/
/* Construction d'une nouvelle courbe Gamma */
/********************************************/
void set_gamma(float gamma, int tab[1024]) ;

/**************************************************************/
/* Changer une palette VDI en tenant compte de la table Gamma */
/**************************************************************/
void make_vdigamma(int *rtab, int *vtab, int *btab, void *palette, int nb) ;

/***************************************/
/* Nouvelle courbe gamma en True Color */
/***************************************/
void set_tcgamma(float gamma, unsigned char *curve, int nb_bits) ;

/*****************************************/
/* Calcul de la taille d'une image       */
/*****************************************/
size_t img_size(int w, int h, int nplanes) ;

/************************************************/
/* Indique si une palette est … niveaux de gris */
/************************************************/
int grey_level(INFO_IMAGE *info) ;

/********************************************************/
/* Construit une palette niveaux de gris compatible GEM */
/********************************************************/
int set_greylevel(int n, INFO_IMAGE *inf) ;

/************************************/
/* Informations sur le driver image */
/************************************/
int get_imgdrivercapabilities(long lfmt, INFO_IMAGE_DRIVER *cap) ;

/**************************/
/* Calculs d'histogrammes */
/**************************/
int compute_histo(MFDB *img, INFO_IMAGE *inf, HISTO *histo, GEM_WINDOW *wprog) ;

/*********************************************************************************/
/* Renvoie l'index VDI correspondant … la couleur la plus proche dans la palette */
/*********************************************************************************/
int get_nearest_vdi_index(int *rvb, void *tos_pal, long nb_cpal) ;

/***************************************************************************************/
/* Transforme ‚ventuellement un MFDB format ‚cran en formats standard et Atari Classic */
/***************************************************************************************/
int MakeMFDBClassicAtari(MFDB *mfdb, MFDB *std) ;

/**********************************************************************************/
/* Copie un raster NON TC dans un autre, ind‚pendemment de la r‚solution courante */
/**********************************************************************************/
void smart_fit(MFDB *in, MFDB *out, int *xy) ;

/**************************************************/
/* Indique si le format naturel doit etre utilise */
/**************************************************/
int may_use_natural_format(int final_nbplanes, int mfdb_nbplanes) ;

/*****************************************/
/* Assure la coherence d'une palette VDI */
/*****************************************/
void make_safepalette(INFO_IMAGE *inf) ;

/***********************************************/
/* Routines servant … mesurer les performances */
/***********************************************/
void perf_reset(unsigned int perf, PERF_INFO *perf_info) ;
void perf_start(unsigned int perf, PERF_INFO *perf_info) ;
void perf_stop(unsigned int perf, PERF_INFO *perf_info) ;
void perf_setunit(int unit, PERF_INFO *perf_info) ;


void TerminateImgLib(void) ;

#endif
