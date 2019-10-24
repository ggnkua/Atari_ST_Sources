/* Fichier de d‚clarations pour le module INITIAL.C */

#ifdef PRINCIPAL
	#define DEC
#else
	#define DEC extern
#endif

DEC void init_toto (void);

/* On peut mettre ici les variables globales de INITIAL.C s'il y en a. */
DEC int mouse_x;
