/**************************************************************************/
/* UFSL Initialisation function                                           */
/**************************************************************************/
typedef int (*UFSL_INIT)( void ) ;

/**************************************************************************/
/* Standard Fontselector                                                  */
/**************************************************************************/
typedef int (*UFSL)(
  int   handle,   /* Handle of the VDI Workstation                        */
  int   fonts,    /* Gesamtzahl of the loaded Fonts                       */
  int   flag,     /* 0 = All Fonts, 1 = Only monospaced Fonts             */
  char  *info,    /* Infotext                                             */
  int   *fontid,  /* GewÑhlte Font-ID                                     */
  int   *fontsize /* GewÑhlte Font-Grîûe                                  */
);

/**************************************************************************/
/* Benutzerdefinierte Hilfefunktion, sofern gewÅnscht. Nur wenn diese     */
/* ungleich NULL ist, wird der Hilfe-Knopf Åberhaupt aktiviert.           */
/**************************************************************************/
typedef int (*UFSL_HELP)( void ) ;

/**************************************************************************/
/* Redraw-Funktion                                                        */
/* Die Redraw-Funktion wird NICHT bei folgenden Ereignissen aufgerufen:   */
/* WM_TOPPED, WM_NEWTOP, WM_CLOSED.                                       */
/**************************************************************************/
typedef void (*MSGFUNC)(
  int event,    /* Event                                                  */
  int *msgbuff  /* Message-Puffer                                         */
);


typedef struct {
  unsigned long id;               /* Kennung des xUFSL (xUFS)             */
  unsigned int  version;          /* Version (BCD-Format)                 */
  unsigned int  dialtyp;          /* Dialog type                          */
  UFSL_INIT     fontsel_init;     /* Initialisation function (Dummy)      */
  UFSL          fontsel_input;    /* Standard selector function           */
  OBJECT        *helpbutton;      /* Help button (BOXTEXT), maximale      */
                                  /* Text length 9 Chars (NOT checked!)   */
  UFSL_HELP     helpfunc;         /* Eigene Help function                 */
  char          *examplestr;      /* Example text for Fontdarstellung     */
  MSGFUNC       msgfunc;          /* Redraw function                      */
} UFSL_Struct ;
