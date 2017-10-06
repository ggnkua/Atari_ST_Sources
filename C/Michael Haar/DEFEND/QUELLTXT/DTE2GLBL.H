/* globale Variablen von DTE 2 */

extern OBJECT *hauptmenu;
extern boolean prgende, pause;
extern int w_handle, was_multi, timergeschw;
extern int einstell_timergeschw;
extern MFDB pics, spielbild;
extern SPIELER spieler;
extern SCHUSS schuss[MAX_SCHUESSE];
extern int level, anz_monster, anz_level;
extern MONSTER bild_monster[MAX_MONSTER];
extern LEVEL_MONSTER level_monster[MAX_LEVEL];
extern EXPLOSION explosion[MAX_EXPLOSIONEN];
extern int waitloops, schusswieder, einstell_sw_werd, sw_werd;
extern char infotext[80];
extern char offsnd[1024], explode[1024], hiscore[2048], lebensnd[1024], lifelost[1024], schussnd[1024], titelsnd[2048];