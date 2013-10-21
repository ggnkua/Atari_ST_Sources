/**********************************/
/*----------- CALCUL.H -----------*/
/* Header des fonctions de calcul */
/**********************************/
#if !defined(__TIME)
#include <time.h>                    /* Pour la structure clock_t */
#endif
#if !defined(__XGEM)
#include "..\tools\xgem.h"
#endif
#if !defined (__DEFS)
#include "defs.h"
#endif

#define SYM_CENTRE  1     /* Sym‚trie par rapport … (0,0) */
#define SYM_AXE     2     /* Sym‚trie par rapport … (Ox)  */


extern OBJECT  *adr_form_calcul ;    /* Pointeur sur l'objet form_calcul    */
extern double  ftof ;                /* Conversion Flottant -> Fractionnel */
extern FRACTAL fractal[NB_WINDOWS] ; /* Tableau de structures FRACTAL      */
extern INFOW   winfo[NB_WINDOWS] ;   /* Infos sur les fenˆtres             */
extern FRACTAL f_default ;           /* ParamŠtres par d‚faut des fractals */
extern FRACTAL frac ;                /* Fractal en cours de calcul         */
extern clock_t start_time ;          /* Lancement du calcul                */
extern clock_t end_time ;            /* Fin du calcul                      */
extern int     largeur, hauteur ;    /* Dimensions par d‚faut des fenˆtres */
extern int     cpu_type ;            /* Type de CPU (valeur du cookie)     */
extern int     fpu_type ;            /* Type de FPU (valeur du cookie)     */
extern int     off_x, off_y ;        /* Coordonn‚es du formulaire calcul   */
extern int     ability ;             /* Identificateur du programme DSP    */
extern int     acr_dsp ;             /* 1 si la pr‚cision du DSP est OK    */
extern char    *dsp_code ;           /* Pointeur sur le code binaire DSP   */
extern long    dsp_code_size ;       /* Taille du code DSP en DSP Words    */
extern unsigned char *adr_data ;     /* Pointeur sur le tableau d'orbites  */
extern void    *xyorbit ;            /* Pour l'estimation de distance      */
extern int     fractal_pal[NB_WINDOWS][3*256] ; /* Palettes associ‚es      */
extern char    flag_show ;           /* Flag affichage progression         */
extern int     dsp_line ;            /* Ligne DSP en cours de calcul       */
extern int     nbpt_y ;              /* Nombre de lignes … calculer        */
extern int     angle ;               /* Rotation en dixiŠmes de degr‚s     */

/***************************************************************/
/* Initialise les variables ftoe, min_delta, is_fpu et is_dsp2 */
/***************************************************************/
void init_module_calcul(void) ;

/*************************************************************************/
/* Convertit le tableau des orbites en pixels dans la fenˆtre du fractal */
/*************************************************************************/
void orbite_to_raster(FRACTAL *fr, ZONE *zone, int w_handle) ;

/************************************************/
/* Remplit la structure FRACTAL_REPORT avec les */
/* Donn‚es sur le calcul qui s'est effectu‚     */
/************************************************/
void get_report(FRACTAL *fr) ;

/*************************************************************/
/* Connaitre les zones … calculer et … d‚duire.              */
/*************************************************************/
void get_fractal_zones(FRACTAL *fr, ZONE *calc, ZONE *deduct) ;

/*****************************************/
/* Initialise les variables de FRACTAL.S */
/*****************************************/
void init_asm_data(FRACTAL *fr) ;

/*********************************************************/
/* Indique si les donn‚es du fractal fr sont correctes : */
/* - La zone … calculer est incluse dans [-8,8]X[-8,8],  */
/* - La pr‚cision limite n'est pas atteinte.             */
/*********************************************************/
int data_ok(FRACTAL *fr) ;

/***********************************************************/
/* Commence le calcul en utilisant si possible la sym‚trie */
/* En retour :                                             */
/*             0 : Le calcul s'est correctement effectu‚,  */
/*             1 : Le calcul a ‚t‚ interrompu.             */
/***********************************************************/
int calcul_go(FRACTAL *fr, int w_handle) ;

/*****************************************/
/* Indique si un ensemble est sym‚trique */
/* Et si celle-ci est exploitable        */
/*****************************************/
int symetrie_possible(FRACTAL *fr) ;

/****************************************/
/* Lance le calcul en parallŠle CPU+DSP */
/****************************************/
void go_multi_calc(void) ;

/*******************************************************/
/* Mise … jour des paramŠtres de l'ensemble temps r‚el */
/*******************************************************/
void init_real_time(void) ;

int set_inits(int type, char axe) ;
int set_algo(int type, int algo) ;
