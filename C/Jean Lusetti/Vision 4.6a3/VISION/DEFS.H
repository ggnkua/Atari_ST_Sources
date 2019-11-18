/********************************/
/* Structures du Project Vision */
/********************************/
#if !defined(__DEFS)
#define __DEFS

/* Version number */
#define NO_VERSION   "4.6a3"

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

#ifndef __IMGMODUL_H
#include "..\tools\imgmodul.h"
#endif

#ifndef __LIST_H
#include "..\tools\list.h"
#endif

#ifndef __MSG_TXT_H
#include  "..\tools\msgtxt.h"
#endif

extern HMSG hMsg ; /* For accessing messages */

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
  unsigned int vx_rfu  : 15 ;

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

#define LDVO_HIDE030            0x00000100L
#define LDVO_HIDEDSP            0x00000200L
#define LDVO_HIDEFPU            0x00000400L
#define LDV_PREVIEWDEFAULTSIZE  192

typedef struct
{
  char version[9+1] ;
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
  int          nb_undo ;
  int          ko_undo ;
  int          flags ;
  int          sgomme ;

  char path_language[PATH_MAX] ;
  char path_img[PATH_MAX] ;
  char path_lod[PATH_MAX] ;
  char path_filter[PATH_MAX] ;
  char path_album[PATH_MAX] ;
  char path_temp[PATH_MAX] ;
  char path_ldv[PATH_MAX] ;
  char path_zvldg[PATH_MAX] ;
  char path_zvslb[PATH_MAX] ;

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

  int wait_mini_sec ;
  int back          ;

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

  /* Ajouts LogFile */
  char          logging_file[PATH_MAX] ;
  unsigned long logging_flags ;
  int           logging_flushfreq ;

  /* Image Module priorities */
  char im_priority_global[1+NB_MST_MAX] ; /* 0 (not a valid MST_...) ends this array */

  /* Choice for Resource management                          */
  /* -1: Auto based on appl_getinfo (see Xrsrc_load)         */
  /*  0: xrsrc (interface color icons support for all AESes) */
  /*  1 rsrc as provided by AES                              */
  int rsrc_choice ;

  /* RFU */
  char rfu[52] ;
}
VISION_CFG ;

long SaveVISIONIniFile(VISION_CFG *cfg) ;

extern VISION_CFG config ;
extern char high_res ;

extern void GetAppTitle(char* buf) ;

extern void UpdateRTZoom4App(int use_rtzoom) ;

#endif
