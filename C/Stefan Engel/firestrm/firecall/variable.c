#include "firecall.h"
/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern error  fel;
char          system_dir[MAXSTRING]="", *logtext=NULL; 
VARIABLES     tempvar;
CONFIG        *config=NULL;
FILE          *logfile=NULL;
MLIST         *phonelist=NULL;

extern short  screenx,screeny,screenw,screenh;
extern short  work_in[11], work_out[57], ap_id, graf_id, xy[4];
WIN_DIALOG    info_win,register_win,popup_win,list_win,setup_win;
WIN_DIALOG    log_win,export_win;
OBJECT        *menu_tree=NULL, *icons=NULL;
char          *alerts[MAX_ALERTS];

#ifdef LOGGING
LOGG         log;
#endif