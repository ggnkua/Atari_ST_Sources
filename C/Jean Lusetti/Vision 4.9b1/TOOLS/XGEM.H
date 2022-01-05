/*********************************/
/*------------ XGEM.H -----------*/
/*     GEM (and more) extensions */
/*********************************/
#if !defined(__XGEM_H)
#define __XGEM_H

#if !defined(__TIME)
#include <time.h>
#endif
#if !defined(__AES__)
#include "..\tools\xaes.h"
#endif
#if !defined(__VDI__)
#include <vdi.h>
#endif
#if !defined(__TOS)
#include <tos.h>
#endif

#ifndef __STDINPUT_H
#include "..\tools\stdinput.h"
#endif

#ifndef __XALLOC_H
#include "..\tools\xalloc.h"
#endif

#ifndef __XMEM_H
#include "..\tools\xmem.h"
#endif

#ifndef MIN
#define MIN(a,b)	((a) < (b) ? (a) : (b))
#endif

#ifndef MAX
#define MAX(a,b)	((a) > (b) ? (a) : (b))
#endif

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(v)  sizeof(v)/sizeof((v)[0])
#endif

#define GRAS     0x0001
#define FIN      0x0002
#define ITALIQUE 0x0004
#define SOULIGNE 0x0008
#define CONTOURS 0x0010


#define DSP_NONE        0
#define DSP_56001       1

/* If DSP is locked... */
#define DSPLOCK_WARN    0    /* Let user decide                    */
#define DSPLOCK_CANCEL  1    /* Cancel operation                   */
#define DSPLOCK_IGNORE  2    /* Let CPU handle it                  */
#define DSPLOCK_FORCE   3    /* Load new LOD, taking risk to crash */

typedef struct
{
  int style ;
  int color ;
  int st_kind ;
  int ed_kind ;
  int width ;
}
LINE_TYPE ;

typedef struct
{
  int style ;
  int color ;
  int height ;
}
MARKER_TYPE ;

typedef struct
{
  int style ;
  int color ;
  int sindex ;
  int perimeter ;
}
FILL_TYPE ;

typedef struct
{
  int wcar ;
  int hcar ;
  int wcell ;
  int hcell ;
  int angle ; /* 0, 900, 1800, ou 2700 */
  int font ;
  int color ;
  int attribute ;
  int hdisp ;
  int vdisp ;
  int fg_color ; /* Warning: not taking into account by VDI, have to manually set mode to MD_TRANS and draw filled rectangle before */
}
TEXT_TYPE ;

typedef struct
{
  int   gr_monumber;
  MFORM gr_mof ;
}
MOUSE_DEF ;

typedef struct
{
  char type ;             /* DSP_NONE, DSP_56001, ...                */
  char use ;              /* Faut il l'utiliser ?                    */
  char WhatToDoIfLocked ; /* DSPLOCK_... que faire s'il est bloqu‚ ? */
}
DSP_INFO ;

typedef struct
{
  long machine ;
  long cpu ;
  long fpu ;
  long video ;
  long sound ;
}
MACHINE_INFO ; 

typedef struct
{
  /* Pour la carte graphique */
  int RRed ;     /* Rotate Left pour rouge */
  int RGreen ;   /* Rotate Left pour vert  */
  int RBlue ;    /* Rotate Left pour bleu  */
  int Is15Bits ; /* Codage sur 15 bits ?   */
}
RVB_ORG ;

typedef struct
{
  unsigned int SubMenus     : 1 ;
  unsigned int Popups       : 1 ;
  unsigned int PopupsScroll : 1 ;
  unsigned int MNSelAdr     : 1 ;
}
AES_FEATURES ;

typedef struct
{
  unsigned int second : 5 ; /* A multiplier par 2 */
  unsigned int minute : 6 ;
  unsigned int hour   : 5 ;
}
TOS_TIME ;

typedef struct
{
  unsigned int day   : 5 ;
  unsigned int month : 4 ;
  unsigned int year  : 7 ;
}
TOS_DATE ;

typedef struct
{
     long magic;                   /* muž $87654321 sein         */
     void *membot;                 /* Ende der AES- Variablen    */
     void *aes_start;              /* Startadresse               */
     long magic2;                  /* ist 'MAGX'                 */
     long date;                    /* Erstelldatum               */
     void (*chgres)(short res, short txt);  /* Aufl”sung „ndern    */
     void (**shel_vector)(void);   /* residentes Desktop         */
     char *aes_bootdrv;            /* von hieraus wurde gebootet */
     int  *vdi_device;             /* vom AES benutzter Treiber  */
     void *reservd1;               /* reserviert                 */
     void *reservd2;               /* reserviert                 */
     void *reservd3;               /* reserviert                 */
     int  version;                 /* Version ($0201 ist V2.1)   */
     int  release;                 /* 0=alpha..3=release         */
} AESVARS ;

typedef struct
{
  long     config_status;
  void    *dosvars;
  AESVARS *aesvars;
  void    *res1;
  void    *hddrv_functions;
  long    status_bits;
} MAGX_COOKIE ;

#ifndef BASEPAGE
typedef struct _BASEPAGE
{
   void     *p_lowtpa;          /* Start address of the TPA            */
   void     *p_hitpa;           /* First byte after the end of the TPA */
   void     *p_tbase;           /* Start address of the program code   */
   long      p_tlen;            /* Length of the program code          */
   void     *p_dbase;           /* Start address of the DATA segment   */
   long      p_dlen;            /* Length of the DATA section          */
   void     *p_bbase;           /* Start address of the BSS segment    */
   long      p_blen;            /* Length of the BSS section           */
   DTA      *p_dta;             /* Pointer to the default DTA          */
                                /* Warning: Points first to the        */
                                /* command line !                      */
   struct _BASEPAGE *p_parent;  /* Pointer to the basepage of the      */
                                /* calling processes                   */
   long      p_resrvd0;         /* Reserved                            */
   char     *p_env;             /* Address of the environment string   */
   char      p_resrvd1[80];     /* Reserved                            */
   char      p_cmdlin[128];     /* Command line                        */
}
BASEPAGE, *PBASEPAGE ;
#endif

extern MACHINE_INFO MachineInfo ;          /* Informations sur la machine        */
extern DSP_INFO     DspInfo ;              /* Informations sur le DSP            */
extern LINE_TYPE    ltype ;                /* D‚finition des paramŠtres lignes   */
extern MARKER_TYPE  mtype ;                /* D‚finition des paramŠtres point    */
extern FILL_TYPE    ftype ;                /* D‚finition du remplissage          */
extern TEXT_TYPE    ttype ;                /* D‚finition des attributs texte     */
extern MOUSE_DEF    mouse ;                /* Forme actuelle de la souris        */
extern MFDB screen ;                      /* Bloc MFDB format ‚cran             */
extern float aspectratio ;                /* Hauteur/Largeur d'un pixel         */
extern int  ap_id ;                       /* D‚claration de l'application       */
extern int  xdesk, ydesk ;                /* Coordonn‚es et tailles de la       */
extern int  wdesk, hdesk ;                /* Zone graphique exploitable.        */
extern int  handle ;                      /* Handle VDI                         */
extern int  Xmax, Ymax ;                  /* Coordonn‚es maximales de l'‚cran   */
extern int  h_car_max ;                   /* Hauteur maximale d'un caractŠre    */
extern int  num_sys_font ;                /* Indice de la fonte systŠme         */
extern int  num_fonts ;                   /* Nombre de fontes suppl‚mentaires   */
extern int  nb_colors ;                   /* Nombre de couleurs simultan‚es     */
extern int  Multitos ;                    /* 1 si l'AES est multitache          */
extern int  Truecolor ;                   /* 1 si le mode video est True Color  */
extern int  Gdos ;                        /* 0 si Gdos est absent               */ 
extern int  AESVersion ;                  /* Version de l'AES                   */
extern int  *old_pal ;                    /* Palette de couleurs initiale       */
extern char init_path[] ;                 /* R‚pertoire de lancement            */
extern int  UseStdVDI ;                   /* Format Atari (0) ou VDI (1)        */
extern RVB_ORG FRVBOrg16 ;
extern RVB_ORG FRVBOrg24 ;
extern RVB_ORG FRVBOrg32 ;
extern RVB_ORG RVBOrg ;
extern int vdi_sys_colors[3*16] ;
extern MAGX_COOKIE *MagXCookie ;
extern char rsrcAES ; /* 0: Interface routines, 1: AES routines */


#define Xrsrc_used (rsrcAES == 0)


/*****************************************************/
/* Initialisation du GEM :                           */
/* ap_id, handle, Xmax, Ymax, h_car_max et nb_colors */
/* MFDB screen comme destination vers l'‚cran        */
/* Cr‚e une nouvelle DTA                             */
/* Retourne ap_id. Si n‚gatif erreur de appl_init()  */
/*****************************************************/
int gem_init(void) ;

/*************************************************************/
/* Refermer l'application.                                   */
/* En retour : 1 : OK, l'application se termine normalement. */
/*             0 : Erreur de appl_exit().                    */
/*************************************************************/
int gem_exit(void) ;

/********************************************/
/* Remplissage de l'int‚rieur d'une fenˆtre */
/* Avec l'index de couleur VDI d‚sir‚       */
/********************************************/
void fill_window(int w_handle, int color_index) ;

/*******************************************************************/
/* Remplace les caractŠres accentu‚s d'une chaine par les          */
/* CaractŠres non accentu‚s.                                       */
/*******************************************************************/
void remove_accents(char *string) ;

/********************************************************/
/* Cr‚e une boite d'alerte avec un point d'exclamation. */
/* Exemple : form_exclamation(1, "[Attention !][OK]") ; */
/********************************************************/
int form_exclamation(char *string) ;

/*******************************************************************/
/* Cr‚e une boite d'alerte avec un point d'interrogation.          */
/* Exemple : form_interrogation(1, "[Chemin introuvable !][OK]") ; */
/*******************************************************************/
int form_interrogation(int default_return, char *string) ;

/*********************************************************/
/* Cr‚e une boite d'alerte avec un panneau Stop.         */
/* Exemple : form_stop(1, "[Vous perdrez tout !][OK]") ; */
/*********************************************************/
int form_stop(char *string) ;

/********************************************************************/
/* Affiche la boite de s‚lection des fichiers et retourne :         */
/* 0 : aucun fichier n'a ‚t‚ s‚lectionn‚                            */
/* 1 : le fichier dont le nom est point‚ par name a ‚t‚ s‚lectionn‚ */
/********************************************************************/
int filefolder_name(char* path_mask, char* def, int want_folder, char* name) ;
#define file_name(path_mask, def, name)  filefolder_name(path_mask, def, 0, name)
#define folder_name(path_mask, def, name)  filefolder_name(path_mask, def, 1, name)

/***********************************************/
/* Renvoit le nombre de plans n‚cessaires pour */
/* Coder un pixel sur nb_color couleurs        */
/***********************************************/
int nb_planes(int nb_color) ;

/******************************************************************/
/* Renvoit le tableau de conversion TOS -> VDI pour nplanes plans */
/******************************************************************/
unsigned char *get_pttos2vdi(int nplanes) ;

/******************************************************************/
/* Renvoit le tableau de conversion VDI -> TOS pour nplanes plans */
/******************************************************************/
unsigned char *get_ptvdi2tos(int nplanes) ;

/*********************************/
/* Positionne un point … l'‚cran */
/*********************************/
void pset(int x, int y) ;

/*************************************/
/* Trace une ligne entre deux points */
/*************************************/
void line(int x1, int y1, int x2, int y2) ;

/************************/
/* Dessine un rectangle */
/************************/
void rectangle(int x1, int y1, int x2, int y2) ;

/*******************************************************************/
/* Donne la zone commune … 2 rectangles                            */
/* En entr‚e :                                                     */
/* x1, y1, w1, h1 : Coordonn‚es et dimensions du premier rectangle */
/* x2, y2, w2, h2 : Coordonn‚es et dimensions du second rectangle  */
/* En sortie : 0 si l'intersection est vide                        */
/*             1 dans le cas contraire, la zone commune apparait   */
/*               dans pxyarray.                                    */
/*******************************************************************/
int intersect(int x1, int y1, int w1, int h1,
			  int x2, int y2, int w2, int h2, int *pxyarray) ;

/**********************************************/
/* Saisie des paramŠtres courants de la ligne */
/**********************************************/
void get_linetype(LINE_TYPE *type_line) ;

/********************************************/
/* Saisie des paramŠtres courants du marker */
/********************************************/
void get_markertype(MARKER_TYPE *type_marker) ;

/*************************************************/
/* Saisie des paramŠtres courants du remplissage */
/*************************************************/
void get_filltype(FILL_TYPE *type_fill) ;

/*******************************************/
/* Saisie des paramŠtres courants du texte */
/*******************************************/
void get_texttype(TEXT_TYPE *type_text) ;

/*********************************/
/* Fixer les paramŠtres de ligne */
/*********************************/
void set_linetype(LINE_TYPE *type_line) ;

/**********************************/
/* Fixer les paramŠtres de marker */
/**********************************/
void set_markertype(MARKER_TYPE *type_marker) ;

/***************************************/
/* Fixer les paramŠtres de remplissage */
/***************************************/
void set_filltype(FILL_TYPE *type_fill) ;

/*********************************/
/* Fixer les paramŠtres du texte */
/*********************************/
void set_texttype(TEXT_TYPE *type_text) ;

/***************************************/
/* Indique si un objet est s‚lectionn‚ */
/***************************************/
int selected(OBJECT *arbre, int index) ;

/********************************/
/* Efface une boite de dialogue */
/********************************/
void hide_dialog(void) ;

/************************/
/* S‚lectionne un objet */
/************************/
void select(OBJECT *arbre, int index) ;

/***********************************/
/* Elimine la s‚lection d'un objet */
/***********************************/
void deselect(OBJECT *arbre, int index) ;

/**********************************************************/
/* Inverse l'‚tat de s‚lection d'un objet et le r‚affiche */
/**********************************************************/
void inv_select(OBJECT *arbre, int index) ;

/*********************/
/* Lit un objet TEXT */
/*********************/
void read_text(OBJECT *arbre, int index, char *string) ;

/**********************************/
/* Ecrit une chaine dans un arbre */
/**********************************/
void write_text(OBJECT *arbre, int index, char *string) ;

/*****************************/
/* Ecrit un nouveau template */
/*****************************/
void write_template(OBJECT *arbre, int index, char *string) ;

/*********************************************/
/* Affecte une extension … un nom de fichier */
/*********************************************/
void set_ext(char *name, char *ext) ;

/********************************************/
/* Retourne l'extension d'un nom de fichier */
/* En cas d'erreur, ext est mis a  "???"    */
/* Et la valeur de retour vaut 0 (1 sinon)  */
/********************************************/
int get_ext(char *name, char *ext) ;

/*************************************************************/
/* Affiche la souris 'Busy' en m‚morisant son ‚tat pr‚c‚dent */
/*************************************************************/
void mouse_busy(void) ;

/*************************************************************************/
/* Restaure l'‚tat de la souris pr‚c‚demment sauvegard‚ par mouse_busy() */
/*************************************************************************/
void mouse_restore(void) ;

/***************************************/
/* Changement de l'aspect de la souris */
/***************************************/
int set_mform(MOUSE_DEF *info) ;

/*******************************************************/
/* Mise en place d'une palette de couleurs niveaux RVB */
/* (0...1000) Indic‚e par le TOS                       */
/*******************************************************/
void set_tospalette(int *pal, int nb_col) ;

/********************************************************/
/* Mise en place d'une palette de couleurs niveaux RVB  */
/* (0...1000) Indic‚e par le TOS en pr‚cisant le d‚part */
/********************************************************/
void set_stospalette(int *pal, int nb_col, int start) ;

/***************************************/
/* Stockage de la palette TOS courante */
/***************************************/
void get_tospalette(int *pal) ;

/***************************************/
/* Stockage de la palette VDI courante */
/***************************************/
void get_vdipalette(int *pal) ;

/********************************************/
/* Mise en place d'une nouvelle palette VDI */
/********************************************/
void set_vdipalette(int *pal, int nb_col) ;

/*******************************************************************/
/* Attendre jusqu'… ce qu'un ‚vŠnement du type mask_event ait lieu */
/* NB : Cet ‚vŠnement ne doit pas ˆtre MU_TIMER                    */
/*******************************************************************/
void wait_for(int mask_event) ;

/***************************************************************/
/* Vider les buffers relatifs aux ‚vŠnement de type mask_event */
/* NB : Cet ‚vŠnement ne doit pas ˆtre MU_TIMER                */
/***************************************************************/
void clear_buffers(int mask_event) ;

/**************************************************************/
/* Remplace graf_dragbox() que je n'arrive pas … utiliser !!! */
/**************************************************************/
void my_dragbox(int w, int h, int ix, int iy, int lx, int ly,
                int lw, int lh, int *fx, int *fy) ;

int xform_do(int start_ob) ;
/*int xform_do(int start_ob, void (*redraws)()) ;*/

/*******************************************************/
/* Renvoit la taille en octets d'un fichier.           */
/* Si le fichier n'existe pas, la fonction renvoit -1 .*/
/*******************************************************/
long file_size(char *name) ;

/****************************************/
/* Renvoit les infos DTA sur un fichier */
/* 0 : OK, sinon le fichier n'xiste pas */
/****************************************/
int file_getinfo(char *filename, DTA *info) ;

void get_time_date(char *time, char *date) ;
void get_england_time_date(char *time, char *date) ;


int popup_formdo(OBJECT **arbre, int x, int y, int item, int scroll) ;
OBJECT *popup_make(int nb_objets, int nb_cara) ;
void popup_kill(OBJECT *pop_up, int nb_objets) ;
int popup_formdo_menu(int m_id, int n_items) ;

void xobjc_draw(int w_handle, OBJECT *obj, int num) ;
int xobjc_hasflag(OBJECT *tree, int index, int flag) ;


void cls_gemscreen(void) ;
void restore_gemscreen(OBJECT *menu) ;

/* XrRessource */
int Xrsrc_load(char *rsc_name, int rsrc_choice) ;
int Xrsrc_gaddr(int re_gtype, int re_gindex, void *gaddr) ;
int Xrsrc_free(void) ;
int Xrsrc_obfix(OBJECT *re_otree, int re_oobject) ;
void Xrsrc_fix(OBJECT *obj) ;

OBJECT* xobjc_copy(OBJECT *obj) ;

int can_usevro(int nb_planes) ;
void xvro_cpyfm(int handle, int vr_mode, int *xy, MFDB *src, MFDB *dest) ;
void vro_cpyfmtc16(int *xy, MFDB *in, MFDB *out) ;
void vro_cpyfmtc24(int *xy, MFDB *in, MFDB *out) ;

int* cycling_init(void) ;
void cycling_do(int sens) ;
void cycling_terminate(int *save_pal) ;

int Icon2MFDB(ICONBLK *icnblk, MFDB *out) ;
int Cicon2MFDB(CICONBLK *icnblk, MFDB *out) ;

int GetMagicVersion(void) ;

#define TFPU_NONE     0L
#define TFPU_68881    68881L
#define TFPU_68882    68882L
#define TFPU_68040    68040L /* Internal to CPU */
#define TFPU_68060    68060L /* Internal to CPU */

void LogMFDB(MFDB* mfdb) ;
long get_fpu(void) ;

short InternetAvailable(void) ;

void memrep(void* mem, size_t size, char old_char, char new_char) ;
void strrep(char* string, char old_char, char new_char) ;
char* dzt_string2sep(char* string, char sep, char* output) ;

long XPexec(int mode, char* name, void* cmdline, void* envptr) ;

extern char* pkbshift ; /* Don't use this, use macro below */
#define xKbshift() ((long)(*pkbshift))

short cal_pc(long current, long max) ;

int sform_dial(int fo_diflag, int fo_dilx, int fo_dily, int fo_dilw, int fo_dilh) ;

void removeCRCF(char* string) ;

char* ignore_spaces(char* c) ;

void CopyMouseDef(MOUSE_DEF* out, MOUSE_DEF* in) ;
void CopyMForm(MFORM* out, MFORM* in) ;

void checkbox_setstate(int state, OBJECT* tree, int index) ;
void radio_select(OBJECT* tree, int* indexes, int nb_index, int sel) ;

char* long2ASC(long val) ;
short count_char(char* s, char c) ;

char* reduce_string_if_required(char* string, char* buffer, size_t dst_len) ;

char form_set_mode(char silent) ;

#endif