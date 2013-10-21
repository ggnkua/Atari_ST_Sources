/*******************************************************/
/*------------------ ANIME.H --------------------------*/
/* Header du module d'animation du Project FRACTAL.PRJ */
/*******************************************************/
extern OBJECT            *adr_form_canim ; /* Formulaire de calcul de s‚quence   */
extern STATUS_ANIMATION  stat_anim ;       /* ParamŠtres de l'animation          */
extern ANIMATION_FRACTAL info_sequence ;   /* Donn‚es sur la s‚quence en m‚moire */
extern ANIMATION_FRACTAL ani_calc ;        /* S‚quence … calculer                */
extern OBJECT            *adr_form_canim ; /* Formulaire de calcul de s‚quence   */
extern MFDB              virtuel ;         /* Pour l'animation depuis le disque  */
extern int               w_ani_handle ;    /* Handle de la fenˆtre animation     */
extern int               flag_ani ;        /* Pour affiche_progression_calcul()  */


/********************************************/
/* Initialise les structures stat_anim, IMG */
/* Et les variables w_ani_handle, name_ani  */
/********************************************/
void init_module_anime(void) ;

/**************************************/
/* LibŠre la m‚moire propre au module */
/**************************************/
void quitte_module_anime(void) ;

/******************************************************/
/* LibŠre la m‚moire occup‚e par la s‚quence d'images */
/******************************************************/
void libere_sequence(void) ;

/*************************************************************/
/* Charge en m‚moire la s‚quence d'animation point‚ par name */
/* En retour : 0 : OK, la s‚quence est … pr‚sent en m‚moire  */
/*             1 : Le fichier sp‚cifi‚ n'existe pas          */
/*************************************************************/
int charge_animation(char *name) ;

/*********************************************/
/* Affiche la boite de dialogue informations */
/* De la s‚quence d'images … cacule.         */
/*********************************************/
int create_animation(ANIMATION_FRACTAL *data) ;

/************************************************************/
/* Lancement de l'animation                                 */
/*  0 : L'animation s'est bien d‚roul‚e.                    */
/* -1 : La fenˆtre animation n'est pas entiŠrement visible. */
/* -2 : M‚moire insuffisante.                               */
/************************************************************/
int animate(void) ;

/*****************************************************************/
/* V‚rifie la coh‚rence des paramŠtres pour calculer l'animation */
/* 1 : Les images extrˆmes ne sont pas identiques                */
/* 2 : Les types des fractals sont les mˆmes                     */
/* 3 : Les algorithmes de calcul sont les mˆmes                  */
/*****************************************************************/
int ok_animate_parameters(FRACTAL *fs, FRACTAL *fe) ;

/**********************************/
/* Lance le calcul de l'animation */
/**********************************/
int calcule_animation(void) ;
