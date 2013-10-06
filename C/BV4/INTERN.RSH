/* GEM Resource C Source */

#include <portab.h>
#include <aes.h>
#include "INTERN.H"

#if !defined(WHITEBAK)
#define WHITEBAK    0x0040
#endif
#if !defined(DRAW3D)
#define DRAW3D      0x0080
#endif

#define FLAGS9  0x0200
#define FLAGS10 0x0400
#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000
#define STATE8  0x0100
#define STATE9  0x0200
#define STATE10 0x0400
#define STATE11 0x0800
#define STATE12 0x1000
#define STATE13 0x2000
#define STATE14 0x4000
#define STATE15 0x8000

TEDINFO rs_tedinfo[] =
{ "xxxxxxxxxxxxxxxxxxxx",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, -1, 21, 1,
  "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 37, 1,
  "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy",
  "\0",
  "\0",
  IBM  , 0, TE_CNTR , 0x1180, 0, 0, 37, 1
};

BYTE *rs_frstr[] =
{ "[3][Veuillez vous placer DANS le|dossier PARX.SYS...|Please move the fileselector|IN your PARX.SYS folder...][ Ok ]",
  "[3][|Le fichier PARX.MEM n\047est|pas reconnu.][ Annuler ]",
  "[3][|Le fichier PARX.MEM est|trop vieux.|Contactez PARX Software.][ Annuler ]",
  "[3][|Le fichier PARX.MEM est|trop recent.|Contactez PARX Software.][ Annuler ]",
  "[3][|Impossible d\047ouvrir le|fichier.][ Annuler ]",
  "[3][|Erreur d\047allocation m\202moire|pour le bloc principal.][ Annuler ]",
  "[3][|Erreur d\047allocation m\202moire|pour les fen\210tres.][ Annuler ]",
  "[3][|Erreur d\047allocation m\202moire|pour les polices.][ Annuler ]",
  "[3][|Erreur d\047allocation m\202moire|pour le fichier RSC.][ Annuler ]",
  "[3][|Erreur de chargement du|fichier RSC.][ Annuler ]",
  "[3][|Erreur d\047initialisation des|objets Userdefs pour le|fichier RSC.][ Annuler ]",
  "Chemin du dossier PARX.SYS:",
  "Initialisation du Memory Manager",
  "Initialisation fen\210tres",
  "Initialisation de la VDI",
  "Initialisation des polices GDOS",
  "Initialisation",
  "Initialisation du fichier RSC",
  "Chargement du fichier",
  "Relocation du fichier",
  "Mise en place des objets Userdefs"
};

OBJECT rs_object[] =
{ 
  /******** Tree 0 FPROG ****************************************************/
        -1, FPROGT          , FPROGF          , G_BOX             ,   /* Object 0  */
  FLAGS9, STATE8, (LONG)0x00011180L,
  0x0000, 0x0000, 0x0026, 0x0006,
  FPROGF          ,       -1,       -1, G_BOXTEXT         ,   /* Object 1 FPROGT */
  NONE, SELECTED|OUTLINED, (LONG)&rs_tedinfo[0],
  0x0001, 0x0001, 0x0024, 0x0001,
         0, FPROG1          , FPROG2          , G_BOX             ,   /* Object 2 FPROGF */
  FLAGS10, NORMAL, (LONG)0x00001180L,
  0x0400, 0x0003, 0x0025, 0x0002,
  FPROG2          ,       -1,       -1, G_BOXTEXT         ,   /* Object 3 FPROG1 */
  FLAGS10, NORMAL, (LONG)&rs_tedinfo[1],
  0x0400, 0x0000, 0x0024, 0x0001,
  FPROGF          ,       -1,       -1, G_BOXTEXT         ,   /* Object 4 FPROG2 */
  LASTOB|FLAGS10, NORMAL, (LONG)&rs_tedinfo[2],
  0x0400, 0x0001, 0x0024, 0x0001
};

OBJECT *rs_trindex[] =
{ &rs_object[0]    /* Tree  0 FPROG            */
};
