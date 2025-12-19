/************************/
/* Header de RASTERPO.C */
/************************/
#if !defined __RASTEROP_H
#define __RASTEROP_H

#if !defined(__IMAGE_IO_H)
#include "..\tools\image_io.h"
#endif

#if !defined(__XGEM_H)
#include "..\tools\xgem.h"
#endif

extern void*  i2r_data ;  /* Adresse courante en entr‚e     */
extern void*  i2rout ;    /* Adresse courante de sortie     */
extern void*  red_pal ;   /* Palette True Color rouge */
extern void*  green_pal ; /* Palette True Color vert  */
extern void*  blue_pal ;  /* Palette True Color bleu  */
extern size_t i2r_nb ;     /* Nombre d'indices … transf‚rer  */
extern int    i2rx ;       /* x courant pour ind2raster()    */
extern int    i2r_a16 ;    /* = 1 si utilisation des routines optimis‚es */
extern int    i2r_use030 ; /* = 1 si utilisation de routines 68030 */
extern char   ignore_a16 ; /* D‚sactive l'optimation automatique */
extern int    xrvb ;
extern int    yrvb ;
extern int    wrvb ;
extern int    hrvb ;


/* Pour tc_convert() */
#define OPLANE_RVB     0
#define OPLANE_RBV     1
#define OPLANE_VRB     2
#define OPLANE_VBR     3
#define OPLANE_BVR     4
#define OPLANE_BRV     5
#define OPLANE_ATARI   OPLANE_RVB

#define OPLANE_FIRST   OPLANE_RVB
#define OPLANE_LAST    OPLANE_BRV
#define NB_OPLANE      (1+OPLANE_LAST-OPLANE_FIRST)

typedef struct _RGB
{
  unsigned short Pad ; /* Make sure we are 2 byte aligned */
  unsigned char  Red ;
  unsigned char  Green ;
  unsigned char  Blue ;
}
RGB, *PRGB ;

unsigned short RVB16(RGB* rgb) ;
unsigned long  RVB32(RGB* rgb) ;
unsigned long  RVBX32(RGB* rgb) ;

extern           int RGB8BToRGBPM[256] ;
extern unsigned char RGBPMToRGB8B[1001] ;

/*****************************************************************/
/* Zoom d'un raster MFDB.                                        */
/* Le MFDB out est initialis‚ par la fonction, la lib‚ration de  */
/* La m‚moire est laiss‚e au d‚veloppeur.                        */
/* out est cr‚e par le zoom de la zone xy dans le raster in      */
/* Si un des levels est nul, la d‚formation correspondante n'est */
/* Pas effectu‚e. Si le level = 1, c'est une simple recopie      */
/*****************************************************************/
int raster_zoom(MFDB *in, MFDB *out, int xy[4], int x_level, int y_level) ;

/*****************************************************************/
/* Zoom en pourcentage d'un raster MFDB.                         */
/* Le MFDB out est initialis‚ par la fonction, la lib‚ration de  */
/* La m‚moire est laiss‚e au d‚veloppeur.                        */
/* En retour :  0 : OK                                           */
/*             -1 : M‚moire insuffisante                         */
/*****************************************************************/
int raster_pczoom(MFDB *in, MFDB *out, int pcx, int pcy, GEM_WINDOW* wprog) ;

/***************************************************************************/
/* Sym‚trie verticale de rasters                                           */
/* En entr‚e : handle    : identificateur de p‚riph‚rique VDI              */
/*             *xyarray  : Idem vro_cpyfm()                                */
/*             *src      : Description du raster source                    */
/*             *dest     : Description du raster destination               */
/* En sortie :  0 : OK                                                     */
/*             -1 : M‚moire insuffisante								   */	
/***************************************************************************/
int raster_symvrt(int *xyarray, MFDB *src, MFDB *dest) ;

/********************************************************/
/* Sym‚trie horizontale simple d'un raster sur lui mˆme */
/********************************************************/
int raster_hsym(MFDB *img, int pxy[4]) ;
int smart_hsym(MFDB *img) ; /* Whole image */

/******************************************************/
/* Sym‚trie verticale simple d'un raster sur lui mˆme */
/******************************************************/
int raster_vsym(MFDB *img, int *pxy) ;

/********************************************/
/* Rotation d'une partie d'un raster image  */
/* out est initialis‚ par cette fonction et */
/* Doit donc ˆtre lib‚r‚ par le programmeur */
/* En retour :  0 : OK                      */
/*             -1 : M‚moire insuffisante    */
/********************************************/
void raster_rgetdstmfdb(int angle, MFDB *in, MFDB *out, float *c, float *s) ;
int  raster_rotate(MFDB *in, MFDB *out, int angle, GEM_WINDOW* wprog) ;

/********************************************/
/* Initialisation de la fonction ind2raster */
/********************************************/
/*void i2r_init(void *start_out, int max_x, int nplan) ;*/
void i2r_init(MFDB *out, int max_x, int raz_done) ;

/*************************************************************/
/* Transformation d'indices TOS unsigned char au format MFDB */
/*************************************************************/
void ind2raster(void) ;

/******************************************/
/* Transformation d'indices TOS 4 plans   */
/* Avec 2 pixels par octet au format MFDB */
/******************************************/
void find2raster(void) ;

/**************************************************************/
/* Transformation d'une s‚rie de points raster en indices TOS */
/**************************************************************/
void raster2ind(int *pt_raster, unsigned char *out, long nb_pts, int nplans) ;

/**************************************************/
/* Transformation d'indices TOS 4 bits stock‚s en */
/* Octets en une suite de 2 indices par octets    */
/**************************************************/
void ind4plans(unsigned char *buffer, unsigned long nb) ;

/****************************************************/
/* Transformation d'une image True Color 24 bits en */
/* Une image True Color 16 bits au format du FALCON */
/****************************************************/
void tc24to16_i2r(void) ;

/*************************************************************/
/* Transformation d'une image True Color 32 bits au format   */
/* TARGA en une image True Color 16 bits au format du FALCON */
/*************************************************************/
void tc32targato16(void) ;
void tc32targato24(void) ;
void tc32targato32(void) ;

/*************************************************************/
/* Transformation d'une image True Color 24 bits au format   */
/* TARGA en une image True Color 16 bits au format du FALCON */
/*************************************************************/
void tc24targato16(void) ;
void tc24targato24(void) ;
void tc24targato32(void) ;

/*************************************************************/
/* Transformation d'une image True Color 16 bits au format   */
/* TARGA en une image True Color 16 bits au format du FALCON */
/*************************************************************/
void tc16targato16(void) ;
void tc16targato24(void) ;
void tc16targato32(void) ;

/****************************************************/
/* Transformation d'une image True Color 24 bits au */
/* Format entrelac‚ (RR..VV..BB) en une image       */
/* True Color 16 bits au format du FALCON           */
/****************************************************/
void tc24ito16(long l_plane) ;

/*************************************************/
/* Transformation d'une image True Color 16 bits */
/* Du FALCON en une image True Color 24 bits.    */
/*************************************************/
void tc16to24(int *pt_img, unsigned char *buffer, long nb_pts) ;
void tc16to32(int *pt_img, unsigned long *buffer, long nb_pts) ;
void tc24to32(unsigned char *pt_img, unsigned long *buffer, long nb_pts) ;

/*************************************************/
/* Transformation d'une image True Color 32 bits */
/* RVB0 en une image True Color 24 bits RVB.     */
/*************************************************/
void tc32to24(long *pt_img, unsigned char *buffer, long nb_pts) ;

/****************************************************/
/* Transformation d'une image True Color 16 bits    */
/* Du FALCON en une image TARGA True Color 24 bits. */
/****************************************************/
void tc16totarga24(int *pt_img, unsigned char *buffer, long nb_pts) ;
void tc24totarga24(int *pt_img, unsigned char *buffer, long nb_pts) ;
void tc32totarga24(int *pt_img, unsigned char *buffer, long nb_pts) ;

/****************************************************/
/* Transformation d'une image True Color 16 bits    */
/* Du FALCON en une image TARGA True Color 16 bits. */
/****************************************************/
void tc16totarga16(int *pt_img, int *buffer, long nb_pts) ;

/***************************************************/
/* Changement TRUE COLOR FALCON des intensit‚s RVB */
/* Par une nouvelle s‚rie d'intensit‚s.            */
/***************************************************/
void tc16_rvbchange(int lo_inligne, int lo_outligne, void *adr_in) ;

/*******************************************/
/* Idem mais pour une image raster entiŠre */
/*******************************************/
void tc16_imgchange(void *adr_in, long nb) ;
void tc32_imgchange(void *adr_in, long nb) ;

/************************************************************/
/* Protection des 16 premiŠres couleurs GEM en 256 couleurs */
/************************************************************/
void pal_ajust(void) ;

/******************************************************/
/* Transformation d'une colonne raster en indices TOS */
/* Le buffer est rempli par le d‚but                  */
/******************************************************/
void row2dind(MFDB *in, int col, unsigned char *buffer) ;

/******************************************************/
/* Transformation d'une colonne raster en indices TOS */
/* Le buffer est rempli par la fin                    */
/******************************************************/
void row2find(MFDB *in, int col, unsigned char *buffer) ;

/*****************************************/
/* Rotation de 90 degr‚s d'un raster     */
/* En retour : 0 : OK                    */
/*             -1 : M‚moire insuffisante */
/*****************************************/
int raster_r90(MFDB *in, MFDB *out, GEM_WINDOW* wprog) ;

/****************************************/
/* Allocation et copie d'un raster       */
/* En retour : 0 : OK                    */
/*             -1 : M‚moire insuffisante */
/*****************************************/
int raster_duplicate(MFDB *in, MFDB *out) ;

/**********************************************************/
/* Conversion d'une image index‚e en une image True Color */
/**********************************************************/
int index2truecolor(MFDB *in, INFO_IMAGE *inf, MFDB *out, GEM_WINDOW* wprog) ;

/*******************************************************/
/* Transformation du format Atari … plans entrelac‚s   */
/* Au format VDI … plans … la suite les uns des autres */
/*******************************************************/
void ClassicAtari2StdVDI(MFDB *in, MFDB *out) ;

/*******************************************************/
/* Transformation du format VDI … plans … la suite les */
/* Uns des autres au format Atari … plans entrelac‚s   */
/*******************************************************/
void StdVDI2ClassicAtari(MFDB *in, MFDB *out) ;

/****************************************/
/* Sym‚trie X d'une image sur elle meme */
/****************************************/
int raster_Xsym(MFDB *img) ;

/*****************************************/
/* Mise … z‚ro des donn‚es image         */
/*****************************************/
void img_raz(MFDB *img) ;

/*****************************************************************/
/* Conversions True Color (ATARI Standard --> Specifique)        */
/*****************************************************************/
int  FindScreenOrg(RVB_ORG* rvb_org) ;
void tc_convert(MFDB* img) ;
/* Reciproque */
void tc_invconvert(MFDB* img) ;



void GetPixel(MFDB* img, int x, int y, int* rgb) ;

void make_greyimage(INFO_IMAGE* inf, short no_std_vdi) ;

#ifndef REMAP_COLORS
typedef struct
{
  unsigned char* red ;
  unsigned char* green ;
  unsigned char* blue ;
  void*          pt_img ;
  long           nb_pts ;
}
REMAP_COLORS ;
#endif

/* Little macro that increases a number to its first multiple of 16 */
#ifndef ALIGN16
/*#define ALIGN16(x) ( ((x) & 0x0F) ? (16+((x) & 0xFFF0)) : (x) )*/
#define ALIGN16(x) ( (x+15) & 0xFFF0 )
#endif


void TC15RemapColors(REMAP_COLORS* rc) ;
void TC16RemapColors(REMAP_COLORS* rc) ;
void TC32RemapColors(REMAP_COLORS* rc) ;

void rasterop_init(void) ;
void rasterop_exit(void) ;

void RasterResetUnusedData(MFDB *img) ;

void tc24to32ip(char* past_last_byteTC24, char* past_last_byteTC32, unsigned long nbpix) ;
void tc24to16ip(char* src, char* dst, unsigned long nbpix) ;

void tc2432to16(void* pt_img, short* pt_img16, long npixels, long b32) ;
#define tc24to16(pt_img, pt_img16, npixels) tc2432to16(pt_img, pt_img16, npixels, 0L)
#define tc32to16(pt_img, pt_img16, npixels) tc2432to16(pt_img, pt_img16, npixels, 1L)

void make_rgbpal2tc( unsigned char* rgbpal, int nb_cpal, void* tctab, int nplanes) ;

short rgb3b2rgbm(short rgb3b) ;
short rgbm2rgb3b(short rgbm) ;

void ZeroMFDB(MFDB* mfdb) ;
void CopyMFDB(MFDB* out, MFDB* in) ;

void  tc32totc16grey(MFDB* in, MFDB* out) ;
short tc16totc32(MFDB*in, MFDB* out) ;
short tc32totc16(MFDB*in, MFDB* out) ;
short tc24totc16(MFDB*in, MFDB* out) ;

size_t img_size(int w, int h, int nplanes) ;

#define W2WDWIDTH(w) ((w+15)>>4)

#endif
