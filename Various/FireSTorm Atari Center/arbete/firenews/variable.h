/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern error fel;
extern char         system_dir[MAXSTRING], avserver[9], message[MAXSTRING]; 
extern long         ext_id;
extern VARIABLES    tempvar;
extern ACTIVE       active;
extern FONT         font;
extern CONFIG       config,tempconf;
extern short        screenx,screeny,screenw,screenh;
extern short        work_in[11], work_out[57], ap_id, graf_id, xy[4];
extern WIN_DIALOG   info_win,register_win,setup_win,sublist_win,server_win;
extern WIN_DIALOG   font_win,path_win,unsublist_win,read_win,group_win;
extern WIN_DIALOG   msglist_win,user_win,flags_win,switch_win;
extern WIN_TEXT     msglist_text,read_text,sublist_text,unsublist_text,server_text;
extern OBJECT       *menu_tree, *icons;
extern char         *alerts[MAX_ALERTS];
#ifdef LOGGING
extern LOGG         log;
extern long         freememory;
#endif
