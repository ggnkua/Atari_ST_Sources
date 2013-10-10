/********************************************************************/
/* Globala Variabler                                                */
/********************************************************************/
extern short        screenx , screeny , screenw , screenh;
extern short        work_in[ 11 ] , work_out[ 57 ] , ap_id , graf_id , xy[ 4 ];

extern char         system_dir[ MAXSTRING ] , avserver[ 9 ];
extern CONFIG       config , t_config;
extern VARIABLES	tempvar;
extern LOGG         log;
extern USERINFO		user , t_user;

extern WIN_DIALOG   info_win , register_win , main_win , url_win , message_win , chat_win , file_win;
extern OBJECT       *menu_tree , *icons;
extern char         *alerts[ MAX_ALERTS ];
