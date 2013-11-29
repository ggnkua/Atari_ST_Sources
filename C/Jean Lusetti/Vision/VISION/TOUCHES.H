#ifndef __TOUCHES
#define __TOUCHES

/********************************************************/
/*------------------- TOUCHES.H ------------------------*/
/* Touches d‚clenchant les options des menus d‚roulants */
/********************************************************/

#define NOUVEAU     0x310E    /* CTRL-N */
#define OUVRIR      0x180F    /* CTRL-O */
#define FERMER      0x2C17    /* CTRL-W */
#define SAUVE       0x1F13    /* CTRL-S */
#define SAUVES      0x1312    /* CTRL-R */
#define IMPRIMER    0x1910    /* CTRL-P */
#define QUITTER     0x1E11    /* CTRL-Q */

#define UNDO        0x6100    /* Undo   */
#define COUPER      0x2D18    /* CTRL-X */
#define COPIER      0x2E03    /* CTRL-C */
#define COLLER      0x2F16    /* CTRL-V */
#define EFFACE      0x537F    /* Delete */
#define NEGATIF     0x2308    /* CTRL-H */
#define S_ALL       0x1001    /* CTRL-A */

#define PLEINE_PAGE 0x011B    /* Escape */
#define INFOS       0x1709    /* CTRL-I */
#define CONVERSION  0x111A    /* CTRL-Z */
#define PGENERAL    0x2207    /* CTRL-G */
#define PTEXTE      0x1414    /* CTRL-T */
#define PFORMES     0x270D    /* CTRL-M */
#define PGOMME      0x1205    /* CTRL-E */
#define STD_PAL     0x0F09    /*  Tab   */
#define PREF        0x2106    /* CTRL-F */
#define ESPACE      0x3920    /* Espace */
#define SYMETRIE    0x250B    /* CTRL-K */
/* #define LUMIERE     0x260C     CTRL-L */
/* #define GAMMA       0x3002     CTRL-B */
#define TAILLE      0x240A    /* CTRL-J */
#define LDV         0x1615    /* CTRL-U */
#define DOPALETTE   0x2004    /* CTRL-D */
#define FILTRE      0x1519    /* CTRL-Y */
#define PIPETTE     0x603C    /*   <    */

#define ZOOM1       0x7030    /* PN 0   */
#define ZOOM2       0x6D31    /* PN 1   */
#define ZOOM4       0x6E32    /* PN 2   */
#define ZOOM8       0x6F33    /* PN 3   */
#define ZOOM16      0x6A34    /* PN 4   */
#define ZOOMPLUS    0x4E2B    /* Pn +   */
#define ZOOMMOINS   0x4A2D    /* Pn -   */

/* Outils accessibles par les touches de fonction */

#define SNAPSHOT    0x662A   /* PN * */
#define SSNAPSHOT   0x652F   /* PN / */

#endif
