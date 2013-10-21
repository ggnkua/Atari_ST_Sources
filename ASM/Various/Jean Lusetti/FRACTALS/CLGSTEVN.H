/*************************************************************/
/*--------------------- CLGSTEVN.H --------------------------*/
/* Module des appels des fonctions de gestion des ‚vŠnements */
/*************************************************************/

/*************************************/
/* Traitement des raccourcis clavier */
/*************************************/
void traite_clavier(int key) ;

/****************************************************/
/* Traitement des ‚vŠnements GEM autres que le menu */
/****************************************************/
void traite_gem(int *msg) ;

/************************************************************/
/* Traitement des actions d‚clench‚es par le menu d‚roulant */
/************************************************************/
void traite_menu(int *msg) ;

/*********************************************************************/
/* Re-calcul du num‚ro du fractal si une modification a ‚t‚ d‚tect‚e */
/*********************************************************************/
void traite_update_calc(int num) ;

/*****************************************************************/
/* Traitement de l'appui sur le bouton droit : Affichage de la   */
/* Boite infos du fractal de la fenetre sur laquelle on a cliqu‚ */
/*****************************************************************/
void traite_button(int button, int mx, int my, int mbreturn) ;

/*****************************************************/
/* Prise en compte des Redraws sans attente blocante */
/* Utilis‚ sous Multitos pendant le calcul           */
/*****************************************************/
void udt_scr(void) ;

/***********************************/
/* Mise en place de la palette TOS */
/***********************************/
void set_imgpalette(int num) ;

/********************************************/
/* Donne la position d'une fenˆtre … ouvrir */
/********************************************/
void open_where(int wkind, int w, int h, int *xout, int *yout, int *wout, int *hout) ;

/*********************************************/
/* Mise … jour de la structure infos fenˆtre */
/*********************************************/
void update_view(int num) ;
