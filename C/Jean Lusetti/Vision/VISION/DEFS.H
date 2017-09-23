/********************************/
/* Structures du Project Vision */
/********************************/
#if !defined(__DEFS)
#define __DEFS

/* Nom de la version … compiler :                                              */
/* __VISION      : Version commerciale                                         */
/* __VISIONLIGHT : Version int‚gr‚e … Prom‚th‚e (logiciel de gestion m‚dicale) */
#define __VISION

/* Num‚ro de la version */
#define NO_VERSION   "4.0f"
#define MENU_NAME    "  Vision 4.0f"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


#if !defined(__STDIO)
#include <stdio.h>     /* Pour FILE et PATH_MAX */
#endif

#if !defined(__VDI__)
#include <vdi.h>       /* Pour la structure MFDB */
#endif

#ifndef __STDPROG
#include  "..\tools\stdprog.h"
#endif

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

#ifndef __IMAGE_IO
#include "..\tools\image_io.h"
#endif

#ifndef __LIST_H
#include "..\tools\list.h"
#endif

#define MAX_NB_CAR_LANGUE       14
#define MAX_NB_LANGUES          20

#ifndef __VMSG_H
#define __VMSG_H
#include "langues\francais\vmsg.h"
#endif

#define MAX_UNDO 99  /* Nombre maximal de buffers undo */
#define NB_TOOLS 20  /* Nombre total d'outils          */

#define TUNDO_MEMORY  0
#define TUNDO_KO	  1
#define TUNDO_SMART   2
#define TUNDO_DISK    3


/* Flags pour le champ flags de la config */
#define FLG_FORMFEED       0x0001
#define FLG_HELP           0x0002
/*#define FLG_SCROLLPOPUP  0x0004*/
#define FLG_MASKOUT        0x0008
#define FLG_DITHERAUTO     0x0010
#define FLG_SROUND         0x0020
#define FLG_SPLASH         0x0040
#define FLG_TOOLBAR        0x0080
#define FLG_LONGFNAME      0x0100
#define FLG_FORCEUSESTDVDI 0x0200

#define BLOC_RECTANGLE   0
#define BLOC_LASSO       1


typedef struct
{
  LIST_ENTRY ListEntry ;

  MFDB       img ;        /* Donn‚es sur l'image m‚moris‚e avec Undo  */
  MFDB       mask ;       /* Pour le lasso                            */
  GEM_WINDOW *gwindow ;
  int        x ;          /* Partie m‚moris‚e de l'image d'indice num */
  int        y ;
  int        w ;
  int        h ;
  int        mitem ;      /* Type de l'item dans le menu */
  int        disk ;       /* Undo sur disque si = 1      */
  void       *spec ;
  int        *palette ;
  int        nb_cpal ;
  int        undo_num ;  /* Pour nom du fichier */
  int        original_width ;
  int        original_height ;
}
UNDO_DEF ;

typedef struct
{
  INFO_IMAGE  inf_img ;

  /* Ancienne structure IMAGE */
  MFDB raster ;    /* Raster image complet        */
  MFDB zoom ;      /* Image en cours de zoom      */
  int  x1, y1 ;    /* Partie en cours de zoom     */
  int  x2, y2 ;
  int  zx, zy ;    /* Pour la fenˆtre zoom dans   */
  int  zw, zh ;    /* La fenˆtre des outils       */
  int  zzx, zzy ;
  int  zzw, zzh ;
  int  zoom_level ;    /* 1, 2, 4, 8 ou les oppos‚s   */
  char nom[PATH_MAX] ; /* Nom TOS complet             */
  /* Fin ancienne structure IMAGE */

  unsigned int modif   : 1 ; /* L'image a ete modifiee */
  unsigned int fdither : 1 ; /* L'image a ‚t‚ tram‚e   */
  unsigned int vx_rfu  : 14 ;

  LIST_ENTRY UndoListHead ;
  int        NbUndoBuffers ;
  UNDO_DEF*  Redo ;
}
VXIMAGE ;

typedef struct
{
  int        form ;
  GEM_WINDOW *gwindow ;
  int        x1 ;
  int        y1 ;
  int        x2 ;
  int        y2 ; 
}
DATA_CLIP ;

typedef struct
{
  int type ;
  int height ;
  int color ;
}
PENCIL ;

#define RTZ_IMG    0
#define RTZ_SCREEN 1
#define RTZ_SMART  2

#define RTZ_MINSIZE   64
#define RTZ_MAXSIZE   (1 + Xmax)/2

#define LF_FLGAPPEND  0x0001

#define SF_ALLSCREEN  0x0001
#define SF_RECT       0x0002
#define SF_MOUSE      0x0004

#define LDVO_SHOWPERF           0x00000001L
#define LDVO_MEPRIORITY         0x00000002L
#define LDV_PREVIEWDEFAULTSIZE  192

typedef struct
{
  char version[6] ;
  int  nb_languages ;
  char language[MAX_NB_CAR_LANGUE] ;
  char all_languages[MAX_NB_LANGUES][MAX_NB_CAR_LANGUE] ;

  unsigned int flag_fullscreen : 1 ;
  unsigned int w_info          : 1 ;
  unsigned int quitte          : 1 ;
  unsigned int clip_gem        : 1 ;
  unsigned int souris_viseur   : 1 ;
  unsigned int color_protect   : 2 ;
  unsigned int dither_method   : 2 ;
  unsigned int dspuse          : 1 ;
  unsigned int dsphandlelock   : 2 ;
  unsigned int type_undo       : 2 ;
  unsigned int use_redo        : 1 ;
  unsigned int g_rfu           : 1 ;
  char         nb_undo ;
  int          ko_undo ;
  int          flags ;
  char         sgomme ;

  char path_language[PATH_MAX] ;
  char path_img[PATH_MAX] ;
  char path_lod[PATH_MAX] ;
  char path_filter[PATH_MAX] ;
  char path_album[PATH_MAX] ;
  char path_temp[PATH_MAX] ;
  char path_ldv[PATH_MAX] ;

  /* Ajout Diaporama */
  unsigned int do_not_show_mouse : 1 ;
  unsigned int do_not_cls_scr    : 1 ;
  unsigned int cycle             : 1 ;
  unsigned int display_type      : 2 ;
  unsigned int ignore_vss        : 1 ;
  unsigned int aff_name          : 1 ;
  unsigned int aff_prog          : 1 ;
  unsigned int transition        : 3 ;
  unsigned int d_rfu             : 5 ;

  char wait_mini_sec ;
  char back          ;

  /* Ajout Zoom Temps Reel */
  unsigned int use_rtzoom     : 1 ;
  unsigned int rt_respectgem  : 1 ;
  unsigned int rt_optimizepos : 1 ;
  unsigned int rt_hidemouse   : 1 ;
  unsigned int rt_zoomwhat    : 2 ;
  unsigned int rt_rfu         : 10 ;
  int      rt_width ;
  int      rt_height ;
  int      rt_zoomlevel ;

  /* Ajouts LogFile */
  char         log_file[PATH_MAX] ;
  unsigned int log_flags ;
  FILE         *log_stream ;

  /* Options SnapShot */
  unsigned int snap_flags ;
  unsigned int snap_keyviaconfig ;
  unsigned int snap_keydirect ;

  /* Options LDV */
  unsigned long ldv_options ;
  int           ldv_preview_src_size ;
  int           ldv_preview_dst_size ;

  /* RFU */
  char rfu[56] ;
}
VISION_CFG ;

long SaveVISIONIniFile(VISION_CFG *cfg) ;

extern VISION_CFG config ;
extern char *undo_item[] ;    /* Titre de l'item menu Undo       */
extern char *msg[] ;          /* Tableau de pointeurs sur les messages    */
                              /* D'avertissements. Initialis‚ par VMAIN.C */
extern int haute_resolution ; /* Dans VMAIN.C */
extern long key_protect2 ;
extern char vision_prg_access[] ;
extern char vision_rsc_access[] ;

void handle_maingemmsg(void) ;
void handle_walbgemmsg(void) ;

#endif
