/**************************************************/
/*------------------ GSTEVN.H --------------------*/
/* Module des fonctions de gestion des ‚vŠnements */
/**************************************************/
extern OBJECT *adr_menu ; /* Adresse de la barre du menu */
extern OBJECT *adr_info ; /* Adresse de la boite d'infos */
extern char   titre[] ;
extern OBJECT *popup_name ;
extern OBJECT *popup_algo ;
extern FRACTAL fr ;         /* Fractal … afficher en temps r‚el */

/******************************************************/
/* Affichage d'une boite de dialogue dans une fenˆtre */
/******************************************************/
void fshow_dialog(OBJECT *obj, char *title) ;

/************************************************/
/* Effacement de la boite pr‚c‚demment affich‚e */
/************************************************/
void fhide_dialog(void) ;

/****************************************************/
/* Remise … jour de la partie visible de la fenˆtre */
/****************************************************/
void img_fractal_update(int w_handle) ;

/****************************/
/* Mise … jour des fenˆtres */
/****************************/
void window_update(int *msg) ;

/*********************************************************************/
/* Mise … jour des options autoris‚es et 'checked' du menu d‚roulant */
/*********************************************************************/
void ajour_menu(void) ;

/*********************************************************/
/* Gestion du formulaire des caract‚ristiques du fractal */
/*********************************************************/
int infos(FRACTAL *fr) ;

/*******************************************************/
/* Consulter/Modifier les pr‚f‚rences de l'application */
/*******************************************************/
void preferences(void) ;

/********************************************************/
/* Affiche le compte rendu du calcul du fractal courant */
/********************************************************/
void report(FRACTAL *fr) ;

/*****************************/
/* Traitement du zoom centre */
/*****************************/
void zoom_centre(void) ;

/***************************/
/* Traitement du zoom zone */
/***************************/
void zoom_zone(void) ;

/*************************************/
/* Aide au choix de l'initialisateur */
/*************************************/
void init_fractal(FRACTAL *fr) ;

/********************************************************************/
/* Lance le calcul si tous les paramŠtres sont valides et coh‚rents */
/********************************************************************/
int lance_calcul(int num_fractal) ;

/***********************************/
/* Cr‚e un nouvel ensemble fractal */
/**********************************/
void nouveau(void) ;

/*****************************************/
/* Effectue une copie du fractal courant */
/*****************************************/
void duplique(void) ;

/**************************************************/
/* Permet de changer la taille du fractal courant */
/**************************************************/
void change_taille(void) ;

/************************************************************/
/* Renvoit 0 si les deux images fractales sont diff‚rentes  */
/*         1 si les deux images sont identiques             */
/* Utlis‚ pour savoir si le calcul doit ˆtre fait … nouveau */
/************************************************************/
int same_aspect(FRACTAL *fr1, FRACTAL *fr2) ;

/*********************************/
/* Changer la palette de l'image */
/*********************************/
void traite_palette(void) ;

/*****************************/
/* Imprimer l'image courante */
/*****************************/
void traite_imprime(void) ;

void iconify_picture(int wnum) ;
void traite_cycling(int sens) ;
