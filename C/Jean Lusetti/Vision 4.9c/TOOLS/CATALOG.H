/***********************/
/* Header de CATALOG.C */
/***********************/
#if !defined(__CATALOG_H)
#define __CATALOG_H

#if !defined (__IMAGE_IO_H)
#include "..\tools\image_io.h"
#endif

#define MARKED_DELETED      '~'

/* Respecter l'ordre alphab‚tique ! */
#define F_ART         0
#define F_BMP         1
#define F_DEGAS       2
#define F_GIF         3
#define F_IFF         4
#define F_IMG         5
#define F_JPEG        6
#define F_MAC         7
#define F_NEO         8
#define F_PCD         9
#define F_PNG        10
#define F_TARGA      11
#define F_TIFF       12
#define F_TINY       13
#define F_XGA        14
#define F_UNKNOWN    15

#define MAX_CATEGORY        32
#define CATEGORY_DIVERS      0
#define CATEGORY_SIZE       16

#define SIZE_COMMENT       100

/* Erreurs du catalogue */
#define ECAT_NOERR             0
#define ECAT_FILENOTFOUND     -1
#define ECAT_BADVERSION       -2
#define ECAT_NOMEMORY         -3
#define ECAT_SEEK             -4
#define ECAT_READ             -5
#define ECAT_WRITE            -6
#define ECAT_BADINDEX         -7
#define ECAT_UPGRADEREQUIRED  -8
#define ECAT_ITEMEXIST        -21

/* Opaque catalog handle */
typedef void* HCAT ;


/* Entete du fichier catalogue */
typedef struct
{
  int      header_size ;
  int      version ;
  int      index_record_size ;
  int      width ;
  int      height ;
  long     nb_records ;
  long     nb_deleted ;
  char     catalog_name[16] ;
  char     date[12] ;
  char     comment[80] ;
  char     category_names[MAX_CATEGORY][16] ;
  char     cat_inifile[92] ; /* Extension de default_categorie */
  char     rfu[900] ;
  int      default_categorie ;
  int      shift_start ;
  int      shift_value ;
  unsigned save_index:1 ;
           rfu_flags :15 ;
}
CATALOG_HEADER ;

typedef struct
{
  char name[16] ;
  char comment[80] ;
  char date[12] ;
  long nb_records ;
  long nb_deleted ;
  long nb_1plane ;
  long size_1p ;
  long nb_2plane ;
  long size_2p ;
  long nb_4plane ;
  long size_4p ;
  long nb_8plane ;
  long size_8p ;
  long nb_tc ;
  long size_tc ;
}
CATALOG_STATS ;

/* Element du fichier index */
typedef struct
{
  char     name[8] ;      /* Nom image sans l'extension, ni de z‚ro terminal ! */
  unsigned nbplanes  :3 ; /* Nombre de plans                                   */
  unsigned format    :4 ; /* Format de l'image                                 */
  unsigned is_visible:1 ; /* Doit apparaitre dans la liste ?                   */
           date_time :8 ; /* Encodage date et heure                            */
  unsigned category_1:5 ; /* Cat‚gorie 1 de l'image                            */ 
  unsigned category_2:5 ; /* Cat‚gorie 2 de l'image                            */ 
  unsigned category_3:5 ; /* Cat‚gorie 3 de l'image                            */ 
           rfu_2     :1 ; /* Usage futur                                       */
  long     offset ;       /* Offset dans le fichier                            */
}
INDEX_RECORD_101 ; /* Previous INDEX_RECORD without proper date/time */

typedef struct
{
  char     name[8] ;      /* Image name, no extension nor tailing zero */
  unsigned nbplanes  :3 ; /* Number of planes                          */
  unsigned format    :4 ; /* Image format                              */
  unsigned is_visible:1 ; /* Has to be part of the list?               */
           rfu_1     :8 ; /* (old) date/time encoding                  */
  unsigned category_1:5 ; /* Category #1 of image                      */ 
  unsigned category_2:5 ; /* Category #2 of image                      */ 
  unsigned category_3:5 ; /* Category #3 of image                      */ 
           selected  :1 ; /* Icon selected                             */
  long     offset ;       /* Offset in file                            */
  long     date_time ;
  char     RFU[16] ;
}
INDEX_RECORD ;

/* Donn‚es sur le filtrage des ‚l‚ments */
typedef struct
{
  unsigned show_all:1 ;        /* No filter                       */
           filter_on_name:1 ;  /* Filter on name to perform       */
           contains:1 ;        /* Starts with (0) or contains (1) */
           rfu     :13 ;
  unsigned long category ;         /* Categories bitmask            */
  unsigned char planes ;           /* Bitplanes mask                */
  unsigned int  format ;           /* Formats mask                  */
  long          nb_visibles ;      /* Number of visible elements    */
  char          filter_name[8+1] ; /* Name mask                     */
}
CATALOG_FILTER ;

CATALOG_HEADER* catalog_get_header(HCAT hCat) ;
CATALOG_FILTER* catalog_get_filter(HCAT hCat) ;
INDEX_RECORD*   catalog_get_index_record(HCAT hCat) ;

/**********************************************************************/
/* Cr‚ation d'un nouveau catalogue                                    */
/* En retour :  0 : OK                                                */
/*             -1 : Impossible de cr‚er le r‚pertoire                 */
/*             -2 : Impossible de cr‚er les fichiers                  */
/*             -3 : M‚moire insuffisante                              */
/**********************************************************************/
HCAT catalog_new(char *acess_path, char *cat_name, int* status) ;

/**********************************************************************/
/* Ouverture d'un nouveau catalogue                                   */
/* En retour :  0 : OK                                                */
/*             -1 : Catalogue introuvable                             */
/*             -2 : Mauvaise version                                  */
/*             -3 : M‚moire insuffisante                              */
/**********************************************************************/
HCAT catalog_open(char *cat_name, GEM_WINDOW* wprog, int* status) ;

/*********************************************************/
/* Ajout d'une nouvelle image                            */
/* filename pointe le nom de l'image … ajouter           */
/* En retour :    0 : OK                                 */
/*             != 0 : Code compatible avec celui de la   */
/*                     bibliotheque IMAGE_IO             */
/*********************************************************/
int catalog_add(HCAT hCat, char *filename, GEM_WINDOW* wprog) ;

/****************************************************/
/* Fermeture du catalogue pr‚c‚demment ouvert       */
/* En retour :  0 : OK                              */
/*             -1 : Impossible de sauver le fichier */
/*                  d'index (erreur grave)          */
/****************************************************/
int catalog_close(HCAT hCat) ;

int  catalog_remove(HCAT hCat, long index) ;
int  catalog_removesel(HCAT hCat, int files, GEM_WINDOW* wprog) ;
void catalog_setrem(HCAT hCat, char *rem) ;
void catalog_getstdinfos(HCAT hCat, long ind, char *nom, char *fmt, char *nplanes) ;
int  catalog_loadicon(HCAT hCat, long index, INFO_IMAGE *inf, char *comment) ;
void catalog_getfullname(HCAT hCat, long num_index, char *name) ;
void catalog_stats(HCAT hCat, CATALOG_STATS *stats) ;
int  catalog_addcategory(HCAT hCat, char *category) ;
void catalog_setimgcomment(HCAT hCat, long index, char *comment) ;
void catalog_getimgcomment(HCAT hCat, long index, char *comment) ;
int  catalog_setcategory(HCAT hCat, long index, int category_id, int category_no) ;
void catalog_sort_index(HCAT hCat) ;
void catalog_setsaveindex(HCAT hCat, int flag_save) ;
void catalog_update(HCAT hCat, char *text) ;
void catalog_encrypt_datetime(DTA *dta, INDEX_RECORD *rec) ;

#define EH_LINKIMG    0x0001 /* Copier et lier les images  */
#define EH_SHOWNAMES  0x0002 /* Afficher le nom des images */
typedef struct
{
  /* Donnees sur les vignettes */
  long first ;
  long last ;

  /* Donnees sur le tableau */
  int pc ;
  int nb_img_per_line ;
  int nb_img_per_row ;
  int border_width ;
  int flags ; /* EH_... */

  /* Donnees sur les pages */
  char          back_file[PATH_MAX] ;
  unsigned char back_color[3] ; /* RGB (0...255) */
  char          page_title[50] ;
  char          path[PATH_MAX] ; /* Les repertoires mini et img seront creees */
  char          base_name[7] ;   /* Nom de base pour les pages suivantes %d   */
  int           num ;            /* Numero de la page a suivre                */
  char          previous_label[30] ;
  char          next_label[30] ;
  char          page_label[30] ;
  char          app_name[30] ;
  HCAT          hCat ;
}
CHTML_EXPORT ;

int  catalog_ehtml(CHTML_EXPORT *exp, GEM_WINDOW* wprog) ;
int  catalog_setcatini(HCAT hCat, int cat_ini) ;
int  catalog_applyini(HCAT hCat, char* msgtxt) ;
int  catalog_upgrade(char *cat_name, GEM_WINDOW* wprog) ;
long catalog_getnsel(HCAT hCat) ;


#endif
