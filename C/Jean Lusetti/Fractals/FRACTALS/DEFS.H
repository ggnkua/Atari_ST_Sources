/***********************************************************/
/*--------------------- DEFS.H ----------------------------*/
/* D‚finitions des constantes et des structures utilis‚es  */
/* Par les modules MAIN.C, FRACT_IO.C, CALCUL.C et ANIME.C */
/***********************************************************/
#if !defined (__DEFS)
#define __DEFS

#if !defined(__VDI__)
#include <vdi.h>       /* Pour la structure MFDB */
#endif

#ifndef __FRACTALS
#include "fractal.h"
#endif

#define VERSION    "2.0c"

/******************************/
/* D‚finitions des constantes */
/******************************/
#define MENU_NAME    "  Fractals 2.0 "
#define MANDELBROT  0
#define JULIA       1
#define MANOWARM    2
#define MANOWARJ    3
#define UNITY       4
#define BARNSLEYM   5
#define BARNSLEYJ   6
#define HYPERBASIN  7
#define SPIDER      8
#define SIERPINSKI  9
#define FIRST_SET   MANDELBROT
#define LAST_SET    SPIDER

#define ENTIER      0
#define REEL        1

#define MEMOIRE     0
#define DISQUE      1

#define PING_PONG   0   /* Animation en allers-retours          */
#define BOUCLE      1   /* Animation par boucle sur la s‚quence */

#define LSM         0   /* Level Set Method            */
#define DEM         1   /* Distance Estimator Method   */
#define CPM         2   /* Continuous Potential Method */

#define BLOC        0   /* Sauvegarde image format MFDB + bitmap Atari */
#define FIMG        1	/* Sauvegarde sous le format IMG               */

#define ERR_ZONE   -1   /* Le calcul se fait dans [-4,4]x[-4,4] */
#define ERR_DELTA  -2   /* La pr‚cision limite est atteinte     */
#define ERR_INCOMP -3   /* MED et calcul sur des entiers        */


typedef struct
{
  long t_calc ;   /* Temps de calcul en dixiŠmes de secondes     */
  int  nbl_cpu ;  /* Nombre de lignes calcul‚es par le CPU 68030 */
  int  nbl_fpu ;  /* Nombre de lignes calcul‚es par le FPU 68882 */
  int  nbl_dsp ;  /* Nombre de lignes calcul‚es par le DSP 56001 */
  int  pc_cpu ;   /* Pourcentage correspondant pour le CPU 68030 */
  int  pc_fpu ;   /* Pourcentage correspondant pour le FPU 68882 */
  int  pc_dsp ;   /* Pourcentage correspondant pour le DSP 56001 */
} FRACTAL_REPORT ;

typedef struct
{
  char   nom[16] ;
  char   type ;           /* MANDELBROT, JULIA ...                  */
  char   algorithme ;     /* M‚thode par niveaux (LSM)              */
                          /* Ou estimation de distance (DEM)        */
  int    maxiter ;        /* Nombre maximal d'it‚rations par point  */
  double ix ;             /* Partie r‚elle de l'initialisateur      */
  double iy ;             /* Partie imaginaire de l'initialisateur  */
  double xmin ;           /* Zone de calcul de chaque fractal       */
  double ymin ;           /* Dans le plan complexe                  */
  double xmax ;           /* xmax = xmin + largeur                  */
  double ymax ;           /* ymax = ymin + hauteur                  */
  double largeur ;        /* Donn‚es redondantes mais elles servent */
  double hauteur ;        /* Bien les 2 repr‚sentations possibles   */
  double centre_x ;       /* Abscisse du centre                     */
  double centre_y ;       /* Ordonn‚e du centre                     */

  MFDB   img ;            /* Donn‚es sur l'image au format MFDB     */

  FRACTAL_REPORT report ; /* Compte rendu du calcul                 */
} FRACTAL ;

typedef struct
{
  FRACTAL fr_start ;       /* Donn‚es sur le premier fractal                 */
  FRACTAL fr_end ;         /* Donn‚es sur le dernier fractal                 */
  int     nb_image ;       /* Nombre d'images calcul‚es                      */
  int     stopped ;        /* 1 si le calcul a ‚t‚ interrompu                */
  long    nb_csec  ;       /* Temps de calcul en secondes                    */
  long    nb_isec ;        /* Temps de conversion de l'image en secondes     */
  double  pc_ccpu ;        /* Pourcentage de participation du CPU au calcul  */
  double  pc_cfpu ;        /* Pourcentage de participation du FPU au calcul  */
  double  pc_cdsp ;        /* Pourcentage de participation du DSP au calcul  */
  char    time_start[30] ; /* Heure de lancement du calcul                   */
  char    time_end[30] ;   /* Heure de fin du calcul                         */
  char    date_start[30] ; /* Date du lancement du calcul                    */
  char    date_end[30] ;   /* Date de la fin du calcul                       */
  char    title[20] ;      /* Titre donn‚ … l'animation                      */
  char    pack[98] ;       /* Nom complet du fichier contenant les longueurs */
                           /* Des images compress‚es. Utilis‚ seulement si   */
                           /* L'option de compression est active.            */
  int     rotation ;       /* Angle de rotation en dixiŠmes de degr‚s        */
} ANIMATION_FRACTAL ;

typedef struct
{                   /* Structure contenant les donn‚es du calcul */
  long max_iter ;   /* A envoyer au DSP                          */
  long type ;       /* Ces donn‚es seront converties en format   */
  long init_x ;     /* 24 Bits du DSP afin d'ˆtre envoy‚es.      */
  long init_y ;
  long xmin ;
  long ymax ;
  long ech_x ;
  long ech_y ;
  long ech2_x ;
  long ech2_y ;
  long nbpt_x ;
  long nr1 ;
  long angle ;
  long cos_a ;
  long sin_a ;
  long xc ;
  long yc ;
} DSP_DATA ;

typedef struct
{
  char debut ;      /* Flag indiquant si le d‚but a ‚t‚ fix‚   */
  char fin ;        /* Flag indiquant si la fin a ‚t‚ fix‚e    */
  char source ;     /* Flag indiquant la source de l'animation */
  char nb_vbl ;     /* Nombre de VBL par image                 */
  char type ;       /* PING_PONG ou BOUCLE                     */
  char ecr2 ;       /* 1 si on utilise un ‚cran logique        */
} STATUS_ANIMATION ;

typedef struct
{
  int xi, yi ;      /* Coordonn‚es du point sup‚rieur gauche */
  int w, h ;        /* Largeur et hauteur de la zone         */
} ZONE ;

typedef struct
{
  char         version[6] ;       /* Majeur.MineurRevision (ex 2.0b) */
  char         path_fractal[60] ;
  char         path_ani[50] ;
  int          calc_format ;
  int          tr_width ;
  int          tr_height ;
  int          tr_maxiter ;
  unsigned int lzw_frc   : 1 ;
               dsp_on    : 1 ;
               set_only  : 1 ;
               rfu_flags : 13 ;
  char         rfu[100] ;
} FRACTAL_CFG ;

typedef struct
{
  int x1, y1 ;
  int x2, y2 ;
}
INFOW ;

extern char fractal_name[1+LAST_SET][20] ;
extern char fractal_algo[1+LAST_SET][10] ;
extern char *msg[] ;          /* Tableau de pointeurs sur les */
                              /* Messages d'avertissements.   */

#endif
