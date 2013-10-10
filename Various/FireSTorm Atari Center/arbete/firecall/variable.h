/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern error fel;
extern char         system_dir[MAXSTRING], *logtext; 
extern VARIABLES    tempvar;
extern CONFIG       *config;
extern FILE         *logfile,*serialfile;
extern MLIST        *phonelist;

extern short        screenx,screeny,screenw,screenh;
extern short        work_in[11], work_out[57], ap_id, graf_id, xy[4];
extern WIN_DIALOG   info_win,register_win,popup_win,list_win,setup_win;
extern WIN_DIALOG   log_win,export_win;
extern OBJECT       *menu_tree, *icons;
extern char         *alerts[MAX_ALERTS];

#ifdef LOGGING
extern LOGG         log;
#endif