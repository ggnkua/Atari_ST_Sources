#ifndef __TOUCHES
#define __TOUCHES

#include "..\tools\keys.h"
/********************************************************/
/*------------------- TOUCHES.H ------------------------*/
/* Touches d‚clenchant les options des menus d‚roulants */
/********************************************************/

#define NOUVEAU     KBD_CTRL_N    /* CTRL-N */
#define OUVRIR      KBD_CTRL_O    /* CTRL-O */
#define FERMER      KBD_CTRL_W    /* CTRL-W */
#define SAUVE       KBD_CTRL_S    /* CTRL-S */
#define SAUVES      KBD_CTRL_R    /* CTRL-R */
#define IMPRIMER    KBD_CTRL_P    /* CTRL-P */
#define QUITTER     KBD_CTRL_Q    /* CTRL-Q */

#define UNDO        KBD_UNDO    /* Undo   */
#define COUPER      KBD_CTRL_X  /* CTRL-X */
#define COPIER      KBD_CTRL_C  /* CTRL-C */
#define COLLER      KBD_CTRL_V  /* CTRL-V */
#define EFFACE      KBD_DELETE  /* Delete */
#define NEGATIF     KBD_CTRL_H  /* CTRL-H */
#define S_ALL       KBD_CTRL_A  /* CTRL-A */

#define PLEINE_PAGE KBD_ESCAPE   /* Escape */
#define INFOS       KBD_CTRL_I   /* CTRL-I */
#define CONVERSION  KBD_CTRL_Z   /* CTRL-Z */
#define PGENERAL    KBD_CTRL_G   /* CTRL-G */
#define PTEXTE      KBD_CTRL_T   /* CTRL-T */
#define PFORMES     KBD_CTRL_M   /* CTRL-M */
#define PGOMME      KBD_CTRL_E   /* CTRL-E */
#define STD_PAL     KBD_TAB      /*  Tab   */
#define PREF        KBD_CTRL_F   /* CTRL-F */
#define ESPACE      KBD_SPACE    /* Espace */
#define SYMETRIE    KBD_CTRL_K   /* CTRL-K */
#define TAILLE      KBD_CTRL_J   /* CTRL-J */
#define LDV         KBD_CTRL_U   /* CTRL-U */
#define DOPALETTE   KBD_CTRL_D   /* CTRL-D */
#define FILTRE      KBD_CTRL_Y   /* CTRL-Y */
#define PIPETTE     KBD_LESS     /*   <    */

#define ZOOM1       KBD_NP0      /* PN 0   */
#define ZOOM2       KBD_NP1      /* PN 1   */
#define ZOOM4       KBD_NP2      /* PN 2   */
#define ZOOM8       KBD_NP3      /* PN 3   */
#define ZOOM16      KBD_NP4      /* PN 4   */
#define ZOOMPLUS    KBD_NPPLUS   /* Pn +   */
#define ZOOMMOINS   KBD_NPMINUS  /* Pn -   */

/* Outils accessibles par les touches de fonction */

#define SNAPSHOT    KBD_NPTIMES   /* PN * */
#define SSNAPSHOT   KBD_NPDIV     /* PN / */

#endif
