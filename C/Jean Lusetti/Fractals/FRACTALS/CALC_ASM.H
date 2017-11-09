/***********************************************************/
/*--------------------- CALC_ASM.H ------------------------*/
/* Variables externes d‚finies dans FRA_CPU.S et FRAC_FPU.S*/
/***********************************************************/
extern int  max_iter ;   /* Nombre maximal d'it‚rations           */
extern int  type ;       /* Mandelbrot ou Julia                   */
extern long init_x ;     /* Partie r‚elle de l'iniialisateur      */
extern long init_y ;     /* Partie imaginaire de l'initialisateur */

extern long xmin ;	     /* Minimum r‚el sur (Ox) */
extern long ymax ;	     /* Maximum r‚el sur (Oy) */
extern long ech_x ;	     /* R‚el suivant sur (Ox) */
extern long ech_y ;	     /* R‚el suivant sur (Oy) */
extern long ech2_x ;     /* ech2_x = 2 * ech_x    */
extern long ech2_y ;     /* ech2_y = 2 * ech_y    */
extern long ccy ;        /* Variable temporaire commune */

extern int  nbpt_x ;     /* Nombre de points … calculer sur (Ox)   */
extern int  nbpt_y ;     /* Nombre de points … calculer sur (Oy)   */
extern int  curr_ligne ; /* Ligne en cours de calcul               */
extern int  stat_calc ;  /* 0 : OK, 1 : Le calcul a ‚t‚ interrompu */

extern int  nbl_cpu ;    /* Nombre de lignes calcul‚es par le 68030 */
extern int  nbl_fpu ;    /* Nombre de lignes calcul‚es par le 68882 */
extern int  nbl_dsp ;    /* Nombre de lignes calcul‚es par le 56001 */

extern double finit_x, finit_y ;
extern double fxmin, fymax, fech_x, fech_y, fech2_x, fech2_y ;
extern double delta, big, over ;
extern double fxc, fyc, fcos_a, fsin_a ;


void it_receive(void) ;

/***********************************************************************/
/* Lance le calcul asssembleur sur des entiers.                        */
/* NB : Il faut avoir pr‚alablement initialis‚ les variables ci-dessus */
/***********************************************************************/
void asm_fractal(void) ;

/***********************************************************************/
/* Lance le calcul asssembleur sur des flottants.                      */
/* NB : Il faut avoir pr‚alablement initialis‚ les variables ci-dessus */
/***********************************************************************/
void fasm_fractal(void) ;
