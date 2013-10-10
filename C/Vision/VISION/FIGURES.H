#ifndef __FIGURES
#define __FIGURES

/***********************/
/* Header de FIGURES.C */
/***********************/

#ifndef __GWINDOWS
#include "..\tools\gwindows.h"
#endif

void action_gomme(GEM_WINDOW *gwnd) ;
void traite_point(GEM_WINDOW *gwnd) ;
void traite_trace(GEM_WINDOW *gwnd) ;
void traite_peinture(GEM_WINDOW *gwnd) ;
void traite_texte(GEM_WINDOW *gwnd) ;
void traite_cercle(GEM_WINDOW *gwnd, int fill) ;
void traite_rectangle(GEM_WINDOW *gwnd, int fill) ;
void traite_ligne(GEM_WINDOW *gwnd) ;
void traite_kligne(GEM_WINDOW *gwnd) ;
void traite_tableau(GEM_WINDOW *gwnd) ;
void traite_aerosol(GEM_WINDOW *gwnd) ;
void traite_pinceau(GEM_WINDOW *gwnd) ;

#endif
