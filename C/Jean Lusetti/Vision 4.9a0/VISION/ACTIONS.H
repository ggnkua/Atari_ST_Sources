#ifndef __ACTIONS
#define __ACTIONS

/***********************/
/* Header de ACTIONS.C */
/***********************/
#if !defined(__IMAGE_IO_H)
#include "..\tools\image_io.h"
#endif

#if !defined(__DEFS_H)
#include "defs.h"
#endif

#if !defined(__AES__)
#include <xaes.h>
#endif

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif

#ifndef __LDVCOM_H
#include "ldv\ldvcom.h"
#endif

extern MOUSE_DEF  mf_gomme ;            /* Souris gomme                    */
extern MOUSE_DEF  mf_peint ;            /* Souris peinture                 */
extern MOUSE_DEF  mf_loupe ;            /* Souris loupe                    */
extern MOUSE_DEF  mf_pencil ;           /* Souris pinceau pour palette     */
extern MOUSE_DEF  mf_viseur ;           /* Souris en forme de viseur       */
extern MOUSE_DEF  mf_aerosol ;          /* Souris en forme d'a‚rosol       */
extern DATA_CLIP  vclip ;               /* Prochains paramŠtres clipboard  */
extern PENCIL     pencil ;              /* Pinceau courant                 */
extern int        mode_vswr ;           /* Mode de recopie                 */
extern int        densite ;             /* densit‚ de l'a‚rosol (0..99)    */
extern int        puissance ;           /* Puissance de l'aerosol          */
extern int        xopen, yopen ;        /* Ouverture d'une fenˆtre         */


/**************************************************/
/* Plein ‚cran sur l'image de la fenetre courante */
/**************************************************/
void traite_fullscreen(GEM_WINDOW* gwnd) ;

/************************************************************/
/* Affiche les infos sur l'image dans une boite de dialogue */
/************************************************************/
void traite_info(GEM_WINDOW* wnd) ;

/**************************************************************/
/* Gestion de l'utilisation des outils dans la fenˆtre active */
/**************************************************************/
void traite_action(GEM_WINDOW* cur_window) ;

/******************/
/* Couper un bloc */
/******************/
void traite_coupe(GEM_WINDOW* gwnd) ;

/******************/
/* Copier un bloc */
/******************/
void traite_copie(GEM_WINDOW* gwnd) ;

/******************/
/* Coller un bloc */
/******************/
void traite_colle(GEM_WINDOW* gwnd) ;

/****************************************************/
/* Effacement de la partie s‚lectionn‚e … la souris */
/****************************************************/
void traite_efface(void) ;

/********************************/
/* S‚lectionne toute la fenˆtre */
/********************************/
void traite_selectall(GEM_WINDOW* gwnd) ;

/*****************************************/
/* S‚lection d'une couleur de la palette */
/*****************************************/
void traite_palette(GEM_WINDOW* gwnd) ;

/****************************/
/* Cr‚er une nouvelle image */
/****************************/
void traite_nouveau(void) ;

/********************************/
/* Coller sur une nouvelle page */
/********************************/
void traite_ncolle(void) ;

/**************************************************/
/* Mise en place de la palette associ‚e … l'image */
/**************************************************/
void set_imgpalette(VXIMAGE* vimage) ;

void traite_conversion(GEM_WINDOW* gwnd) ;

/*********************************************************************/
/* Traitement du changement de la loupe                              */
/* flag_level != 0 : Flag = ancien niveau                            */
/* flag_level = 0  : le niveau courant est … mettre … jour           */
/* mx, my  : < 0 si le centre n'est pas specifie par la souris       */
/*********************************************************************/
int traite_loupe(GEM_WINDOW* cur_window, int flag_level, int mx, int my) ;

/**********************************************************/
/* Copie le n‚gatif d'une partie de l'image sur elle-mˆme */
/**********************************************************/
void traite_negatif(GEM_WINDOW* gwnd) ;

/*****************************************************/
/* Passage en mode main tant qu'on appuie sur espace */
/*****************************************************/
void traite_main(GEM_WINDOW* gwnd) ;

/***************************************************/
/* Switch protection couleur Maximale <-> Minimale */
/***************************************************/
void traite_tab(GEM_WINDOW* wnd) ;

/*************************/
/* Impression de l'image */
/*************************/
#ifndef __NO_PRINT
void traite_imprime(GEM_WINDOW* wnd) ;
#else
#define traite_imprime(wnd)
#endif

/*******************************************/
/* Affiche un popup pour un clic sur icone */
/*******************************************/
void traite_iconpopup(GEM_WINDOW* cur_window) ;

/***************************************/
/* Effectue des conversions de formats */
/***************************************/
#ifndef __NO_BATCH_CONV
void traite_batch_conversion(void* external_call) ;
#else
#define traite_batch_conversion(e)
#endif

GEM_WINDOW* nouvelle_wimage(char* nom, int nx, int ny, int nc, int tpmx, int tpmy) ;
void traite_ldv(GEM_WINDOW* cur_window) ;
LDV_STATUS do_ldv(LDV_MODULE* ldv, GEM_WINDOW* gwnd, LDV_PARAMS* ldv_params, int flags) ;

#endif
