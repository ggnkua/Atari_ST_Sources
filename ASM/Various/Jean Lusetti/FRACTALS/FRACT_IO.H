/*******************************/
/*-------- FRACT_IO.H ---------*/
/* Header du module FRACT_IO.C */
/*******************************/
extern FRACTAL_CFG config ;    /* Configuration de l'application        */
extern FRACTAL Mandel ;        /* Structure utilis‚e pour stocker       */
                               /* l'ensemble de Mandelbrot pour aider   */
					           /* … choisir un initialisateur.          */
extern char mask_fractal[60] ; /* Masques de recheche pour fileselect() */
extern char mask_ani[60] ;     /* Masque pour fileselect()              */
extern char *msg[1+MSG_ENDLIST] ; /* Tableau de pointeurs sur les messages   */
                                  /* D'avertissements. Initialis‚ par MAIN.C */


/*****************************************************/
/* Chargement en m‚moire de l'ensemble de Mandelbrot */
/* Utilis‚ pour aider au choix d'un initialisateur   */
/*****************************************************/
int charge_mandel(int flag_search) ;

/***************************************************/
/* Chargement en m‚moire d'un fractal pr‚c‚demment */
/* Sauvegard‚ avec sauve_fractal                   */
/***************************************************/
int charge_fractal(char *name) ;

/***************************************************/
/* Sauvegarde avec choix si le fichier existe d‚j… */
/***************************************************/
int sauve_sfractal(char *name, char flag_img) ;

/***************************************************************/
/* Sauvegarde avec ou sans l'image et sans v‚rification du nom */
/***************************************************************/
int sauve_fractal(char *name, char flag_img) ;

/**********************************************************/
/* Chargement de la configuration (structure FRACTAL_CFG) */
/**********************************************************/
void charge_config(void) ;

/**********************************/
/* Sauvegarde de la configuration */
/**********************************/
void sauve_config(void) ;

/**********************************/
/* Sauvegarde de l'image sous IMG */
/**********************************/
int sauve_image(void) ;

/**********************************************************/
/* Copie l'image et le fractal sp‚cifi‚ dans le clipboard */
/**********************************************************/
void traite_copie(int num) ;
