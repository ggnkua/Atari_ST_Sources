#include "firenews.h"
/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern error fel;
char         system_dir[MAXSTRING], avserver[9],message[MAXSTRING];
long         ext_id;
extern short screenx,screeny,screenw,screenh;
extern short work_in[11], work_out[57], ap_id, graf_id, xy[4];
WIN_DIALOG   info_win,register_win,setup_win,sublist_win,server_win;
WIN_DIALOG   font_win,path_win,unsublist_win,read_win,group_win;
WIN_DIALOG   msglist_win,user_win,flags_win,switch_win;
WIN_TEXT     msglist_text,read_text,sublist_text,unsublist_text,server_text;
OBJECT       *menu_tree, *icons;
char         *alerts[MAX_ALERTS];
VARIABLES    tempvar;
ACTIVE       active;
FONT         font;
CONFIG       config,tempconf;
#ifdef LOGGING
LOGG         log;
long         freememory;
#endif